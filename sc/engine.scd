// SuperCollider as the player's engine: boots once, then plays whatever track the player asks for.
// Started by the player's server (tools/trajectory/sc-link.mjs) as `sclang sc/engine.scd <port> <server port>`, no IDE
// needed.
// Talks OSC with the player's server on UDP <port> (default 57131; not 57130, the port of live.scd's LC view bridge,
// so both can run), with the messages of the LC view (lib/ui.scd), plus:
//   player → SC: /ce/load <track file path> [cc <n> <v> … lk <n> <v> …]
//                                             stop what plays, load that track, start it at bar 0; the CCs (0..1) after
//                                             cc / lk are set before the first note (an auto-perform script's bar 0)
//                /ce/stop                     stop what plays (the server keeps running)
//                /ce/quit                     stop and end sclang (the server quits with it)
//                /ce/record start <wav path>  record the master output (bus 0, 2 channels, 16 bit, the server's own sample
//                                             rate) to that file with DiskOut; /ce/record stop closes it
//   SC → player: /ce/ready                    booted, waiting for a track
//                /ce/loaded <name>            the track plays (bar 0 starts now)
//                /ce/stopped                  nothing plays
//                /ce/error <text>             a load failed
//                /ce/recording <path> <rate>  the recording runs (answer to /ce/record start)
//                /ce/recorded <path>          the WAV is closed (stop, a load, /ce/stop, /ce/quit all end a recording)
//                /ce/recerror <text>          a recording could not start
// Controllers go straight to SC (MIDI), never through the player. Live play from the IDE stays sc/live.scd.
(
var here = thisProcess.nowExecutingPath.dirname, port = (thisProcess.argv[0] ? "57131").asInteger;
var serverPort = (thisProcess.argv[1] ? "57140").asInteger;
var mute = "CE_SC_MUTE".getenv == "1", toPlayer = NetAddr("127.0.0.1", port), stopTrack, loadTrack, setInit, current, recorder, recStart, recStop;
// its own sound server on its own port: never the IDE's default server (localhost:57110), so the engine and a
// SuperCollider IDE session (live.scd) can run side by side without taking over each other's server
s = Server(\ceEngine, NetAddr("127.0.0.1", serverPort));
Server.default = s;
// the server settings of live.scd, except the input device and the sample rate: the device's own rate (asking for
// 48 kHz makes the server quit when the device offers 44.1 kHz, or 16 kHz for a Bluetooth headset in call mode);
// samples and reverbs follow the rate, the warning below says when it is too low
s.options.sampleRate = nil;
s.options.numInputBusChannels = 0;
// No microphone is ever opened: a Bluetooth headset (MOMENTUM 4 …) whose mic is opened switches to call mode,
// 16 kHz, and everything sounds dull. live.scd pins the built-in mic; started headless, that can wait for a
// microphone permission. So the input is an output-only built-in device (the speakers): nothing to record, no mic,
// no permission. Fallback: the built-in mic, as in live.scd.
s.options.inDevice = ServerOptions.outDevices.detect { |d| d.containsi("MacBook") or: { d.containsi("Built-in") } or: { d.containsi("Speakers") } }
	?? { ServerOptions.inDevices.detect { |d| d.containsi("MacBook") or: { d.containsi("Built-in") } } };
s.options.hardwareBufferSize = 128;
s.options.memSize = 65536;
s.options.numWireBufs = 256;
s.options.maxNodes = 4096;
s.options.numBuffers = 2048;
s.latency = 0.2;

// Recording of the master output: a DiskOut synth at the tail of the root group reads bus 0 into a 2-channel buffer
// that streams to a 16-bit WAV. Ended by /ce/record stop and by everything that frees the nodes (a load, /ce/stop,
// /ce/quit), so the file is always closed properly. Every end is answered with /ce/recorded <path>.
SynthDef(\ceRecord, { |buf| DiskOut.ar(buf, In.ar(0, 2)) }).add;
recStop = {
	var r = recorder;
	recorder = nil;
	r !? {
		s.sendMsg('/n_free', r[\node]);
		r[\buf].close;
		r[\buf].free;
		{ s.sync; toPlayer.sendMsg('/ce/recorded', r[\path]) }.fork(SystemClock);   // not the default clock: a load clears it
	};
};
recStart = { |path|
	if(recorder.notNil) { toPlayer.sendMsg('/ce/recerror', "already recording") } {
		var buf = Buffer.alloc(s, 32768, 2);
		recorder = (path: path, buf: buf, node: s.nextNodeID);   // set at once: a second start is refused
		{
			{
				s.sync;
				buf.write(path, "wav", "int16", 0, 0, true);
				s.sync;
				s.sendMsg('/s_new', \ceRecord, recorder[\node], 1, 0, \buf, buf.bufnum);
				toPlayer.sendMsg('/ce/recording', path, s.actualSampleRate.round.asInteger);
			}.try { |e|
				recorder = nil;
				toPlayer.sendMsg('/ce/recerror', e.errorString);
			};
		}.fork(SystemClock);
	};
};

// the clock keeps running (other code may still schedule on TempoClock.default); a load replaces it
stopTrack = {
	recStop.value;
	~ce !? { |ce| ce.player !? (_.stop); ce.player = nil; ce.stopUI };
	~ceClock !? { |c| c.clear };
	s.freeAll;
};
// the values a load starts with: init = [cc, n, v, …, lk, n, v, …] as /ce/load sends them (LC CCs, Launchkey CCs)
setInit = { |ce, init|
	var kind = \cc, i = 0, send = { |m| s.sendMsg(*m) };
	while { i < init.size } {
		if(init[i].isKindOf(Symbol) or: { init[i].isString }) { kind = init[i].asSymbol; i = i + 1 } {
			var n = init[i].asInteger, v = init[i + 1].asFloat.clip(0, 1);
			if(kind == \lk) { ce.setLkCC(n, v, send) } { ce.setCC(n, v, send) };
			i = i + 2
		}
	}
};
loadTrack = { |path, init|
	var old = ~ce, ce, track, pattern;
	current = path;
	stopTrack.value;
	// a fresh core per track (latches, buttons, buses start clean); allocators from 0, so every load reuses the same
	// buffer and bus numbers instead of running out after a few switches
	s.newAllocators;
	ce = (here +/+ "lib/ce.scd").load;
	ce.trackFile = path;
	ce.uiAddr = toPlayer;
	// tests and agents' trial runs (CE_SC_MUTE=1): the master goes to a bus no speaker hears, so nothing plays beside
	// the user's own set (the groups sit at the tail of the root group, after Server.volume: muting that would not reach them)
	if(mute) { ce.mainOut = s.options.numAudioBusChannels - 2 };   // the last two buses: the allocators never get there
	track = path.load;
	ce.sendInit(ce.prepare(s, track));
	// MIDI: keep the ports already connected (connecting twice would double every message)
	old !? { ce.midiPorts = old.midiPorts; ce.lcRaw = old.lcRaw; old.midiWatch !? (_.stop) };
	{ ce.connectMidi } .try { |e| "MIDI not available (%): the track plays, no controller".format(e.errorString).warn };
	// a new clock per load: bar 0 = now, as the player expects (scripts and takes count bars from the load)
	old = ~ceClock;
	~ceClock = TempoClock(track.bpm / 60).permanent_(true);
	TempoClock.default = ~ceClock;
	old !? { |c| c.stop };
	// build the track (latches, buttons, control hooks), then set the load's values, then the first note
	pattern = ce.patterns;
	setInit.(ce, init ? []);
	ce.player = pattern.play(~ceClock, quant: 1);
	ce.startUI;
	~ce = ce;
	toPlayer.sendMsg('/ce/loaded', track.name.asString);
	"▶ % — % BPM".format(track.name, track.bpm).postln;
};

OSCdef(\ce_host_load, { |msg| var path = msg[1].asString, init = msg.drop(2);
	fork { { loadTrack.(path, init) }.try { |e| e.reportError; toPlayer.sendMsg('/ce/error', e.errorString) } }
}, '/ce/load').permanent_(true);
OSCdef(\ce_host_record, { |msg|
	if(msg[1].asString == "start") { recStart.(msg[2].asString) } { recStop.value }
}, '/ce/record').permanent_(true);
OSCdef(\ce_host_stop, { current = nil; stopTrack.value; toPlayer.sendMsg('/ce/stopped') }, '/ce/stop').permanent_(true);
OSCdef(\ce_host_quit, { fork { stopTrack.value; s.sync; s.quit; 0.exit } }, '/ce/quit').permanent_(true);

// After the laptop slept, the language catches up on everything it missed and floods the server ("scheduler queue
// is full"): no more sound, keys and pads stay dark. A watchdog notices the jump in time (> 4 s between its 1 s
// ticks), clears the server's queue and starts the current track again, cleanly at bar 0.
~ceWake.stop;
~ceWake = Routine { var last = Main.elapsedTime, now;
	loop {
		1.wait;
		now = Main.elapsedTime;
		if((now - last) > 4 and: { current.notNil } and: { s.serverRunning }) {
			"woke up after % s: clearing the server queue, starting % again".format((now - last).round(0.1), current.basename).postln;
			s.sendMsg('/clearSched');
			fork { { loadTrack.(current) }.try { |e| e.reportError; toPlayer.sendMsg('/ce/error', e.errorString) } };
		};
		last = now;
	}
}.play(SystemClock);

s.waitForBoot {
	if(mute) { "SC engine muted (CE_SC_MUTE=1): the master plays into a private bus".postln };
	toPlayer.sendMsg('/ce/ready');
	"SC engine ready: waiting for the player (UDP %)".format(NetAddr.langPort).postln;
	if(s.actualSampleRate < 44000) {
		"The audio output runs at % Hz (Bluetooth headset in call mode?): choose another output.".format(s.actualSampleRate.round).warn };
};
)
