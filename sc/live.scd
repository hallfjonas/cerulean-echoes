// Play a track live with the Launch Control XL 3s: boot, load the track, connect the controllers, start on the
// next bar. Open this file in the SuperCollider IDE, set the track below, select all, evaluate (Cmd-Return).
// Stop: ~ce.stopTrack.  All faders down at the start: nothing sounds until the master fader (column 8) is up.
// The LC view (web UI) opens in the browser: it shows everything and works with the mouse when no Launch Control is
// at hand. It needs Node.js (https://nodejs.org); without it the track plays as usual, just without the view.
(
var here = thisProcess.nowExecutingPath.dirname;
var trackName = "009-house";
var openBrowser = true;                 // false: start the view without opening a browser tab
// still starting from a moment ago? Then leave it alone (two starts at once would play twice)
if(~ceStarting == true) { Error("live.scd is already starting: wait for the ▶ line").throw };
// a previous run of this file: stop it completely (its patterns would keep sending notes to the old server)
if(~ce.notNil) { try { ~ce.stopTrack } };
TempoClock.default.clear;
s = Server.default;
s.options.sampleRate = 48000;
// No microphone wanted. A Bluetooth headset whose mic is opened (also as the system's default input) drops to
// 16 kHz call quality, so the input is pinned to the built-in microphone (and not used).
s.options.numInputBusChannels = 0;
s.options.inDevice = try { ServerOptions.inDevices.detect { |d| d.contains("MacBook") or: { d.contains("Built-in") } } };
s.options.hardwareBufferSize = 128;     // small interface buffer: knobs and faders act within a few ms
s.options.memSize = 65536;
s.options.numWireBufs = 256;
s.options.maxNodes = 4096;          // all stems at once: many short notes overlap
s.options.numBuffers = 2048;        // the track loads ~350 samples
s.latency = 0.2;                        // only the patterns run ahead; controller moves go to the buses at once
~ce = (here +/+ "lib/ce.scd").load;
~ce.trackFile = here +/+ "tracks" +/+ trackName +/+ trackName ++ ".scd";
~track = ~ce.trackFile.load;
// the bridge for the web UI (Node.js): started once, keeps running if it already runs
~ce.startBridge = { |self|
	var node = ["/opt/homebrew/bin/node", "/usr/local/bin/node", "/usr/bin/node"].detect { |p| File.exists(p) }
		?? { "/bin/zsh -lc 'command -v node'".unixCmdGetStdOut.stripWhiteSpace };
	if(node.isNil or: { node.isEmpty }) { "Node.js not found: no LC view (the track plays anyway)".warn } {
		self.bridgePid = ("exec" + node.quote + (here +/+ "ui/bridge.mjs").quote).unixCmd({ |code|
			if(code != 0) { "LC view bridge stopped (code %): already running, or see the post window".format(code).postln } });
		if(openBrowser) { SystemClock.sched(1.5, { "open http://localhost:7770".unixCmd; nil }) };
	}
};
~ce.stopTrack = { |self| self.player !? (_.stop); self.midiWatch !? (_.stop); self.stopUI; self.server.freeAll;
	MIDIdef(\ce_midi).free; self.bridgePid !? { |pid| ("kill" + pid).unixCmd }; self.bridgePid = nil; "stopped".postln };
~ce.bootTrack = {
~ceStarting = true;
s.waitForBoot {
	~ceStarting = false;
	~ce.sendInit(~ce.prepare(s, ~track));
	{ ~ce.connectMidi } .try { |e| "MIDI not available (%): the track plays, no controller".format(e.errorString).warn };
	TempoClock.default.tempo = ~track.bpm / 60;
	~ce.player = ~ce.patterns.play(TempoClock.default, quant: 4);
	~ce.startUI;
	~ce.startBridge;
	"▶ % — % BPM. Master fader (column 8) up to hear it.".format(~track.name, ~track.bpm).postln;
	"Audio: % Hz (asked for %), output: %, input: %".format(s.actualSampleRate.round, s.options.sampleRate,
		s.options.outDevice ? "system default", s.options.inDevice ? "system default").postln;
	if(s.actualSampleRate < 44000) {
		("The audio output runs at % Hz: everything above % Hz is missing. Usually a Bluetooth headset in call mode: "
		++ "choose another output (System Settings → Sound), or close apps that use its microphone, then restart.")
		.format(s.actualSampleRate.round, (s.actualSampleRate / 2).round).warn };
};
};
// a server that already runs keeps its old settings: restart it so the options above count
if(s.serverRunning) { s.quit(onComplete: { ~ce.bootTrack }) } { ~ce.bootTrack };
)
