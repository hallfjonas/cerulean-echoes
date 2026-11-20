// SuperCollider as the player's engine: boots once, then plays whatever track the player asks for.
// Started by the player's server (tools/trajectory/sc-link.mjs) as `sclang sc/engine.scd <port> <server port>`, no IDE
// needed.
// Talks OSC with the player's server on UDP <port> (default 57131; not 57130, the port of live.scd's LC view bridge,
// so both can run), with the messages of the LC view (lib/ui.scd), plus:
//   player → SC: /ce/load <track file path>   stop what plays, load that track, start it at bar 0
//                /ce/stop                     stop what plays (the server keeps running)
//                /ce/quit                     stop and end sclang (the server quits with it)
//   SC → player: /ce/ready                    booted, waiting for a track
//                /ce/loaded <name>            the track plays (bar 0 starts now)
//                /ce/stopped                  nothing plays
//                /ce/error <text>             a load failed
// Controllers go straight to SC (MIDI), never through the player. Live play from the IDE stays sc/live.scd.
(
var here = thisProcess.nowExecutingPath.dirname, port = (thisProcess.argv[0] ? "57131").asInteger;
var serverPort = (thisProcess.argv[1] ? "57140").asInteger;
var toPlayer = NetAddr("127.0.0.1", port), stopTrack, loadTrack;
// its own sound server on its own port: never the IDE's default server (localhost:57110), so the engine and a
// SuperCollider IDE session (live.scd) can run side by side without taking over each other's server
s = Server(\ceEngine, NetAddr("127.0.0.1", serverPort));
Server.default = s;
// the server settings of live.scd, except the input device
s.options.sampleRate = 48000;
s.options.numInputBusChannels = 0;
// no input device pinned (live.scd pins the built-in mic): started headless, opening that device waits for a
// microphone permission that never comes, and the boot hangs. A Bluetooth headset may then drop to call quality:
// the warning below says so.
s.options.inDevice = nil;
s.options.hardwareBufferSize = 128;
s.options.memSize = 65536;
s.options.numWireBufs = 256;
s.options.maxNodes = 4096;
s.options.numBuffers = 2048;
s.latency = 0.2;

// the clock keeps running (other code may still schedule on TempoClock.default); a load replaces it
stopTrack = {
	~ce !? { |ce| ce.player !? (_.stop); ce.player = nil; ce.stopUI };
	~ceClock !? { |c| c.clear };
	s.freeAll;
};
loadTrack = { |path|
	var old = ~ce, ce, track;
	stopTrack.value;
	// a fresh core per track (latches, buttons, buses start clean); allocators from 0, so every load reuses the same
	// buffer and bus numbers instead of running out after a few switches
	s.newAllocators;
	ce = (here +/+ "lib/ce.scd").load;
	ce.trackFile = path;
	ce.uiAddr = toPlayer;
	track = path.load;
	ce.sendInit(ce.prepare(s, track));
	// MIDI: keep the ports already connected (connecting twice would double every message)
	old !? { ce.midiPorts = old.midiPorts; old.midiWatch !? (_.stop) };
	{ ce.connectMidi } .try { |e| "MIDI not available (%): the track plays, no controller".format(e.errorString).warn };
	// a new clock per load: bar 0 = now, as the player expects (scripts and takes count bars from the load)
	old = ~ceClock;
	~ceClock = TempoClock(track.bpm / 60).permanent_(true);
	TempoClock.default = ~ceClock;
	old !? { |c| c.stop };
	ce.player = ce.patterns.play(~ceClock, quant: 1);
	ce.startUI;
	~ce = ce;
	toPlayer.sendMsg('/ce/loaded', track.name.asString);
	"▶ % — % BPM".format(track.name, track.bpm).postln;
};

OSCdef(\ce_host_load, { |msg| var path = msg[1].asString;
	fork { { loadTrack.(path) }.try { |e| e.reportError; toPlayer.sendMsg('/ce/error', e.errorString) } }
}, '/ce/load').permanent_(true);
OSCdef(\ce_host_stop, { stopTrack.value; toPlayer.sendMsg('/ce/stopped') }, '/ce/stop').permanent_(true);
OSCdef(\ce_host_quit, { stopTrack.value; s.quit; 0.exit }, '/ce/quit').permanent_(true);

s.waitForBoot {
	toPlayer.sendMsg('/ce/ready');
	"SC engine ready: waiting for the player (UDP %)".format(NetAddr.langPort).postln;
	if(s.actualSampleRate < 44000) {
		"The audio output runs at % Hz (Bluetooth headset in call mode?): choose another output.".format(s.actualSampleRate.round).warn };
};
)
