// Offline render of a track (or some of its stems) for a scenario, with an event log for the comparison.
// usage: sclang render.scd <track.scd|track.track> <scenario.json> <out-prefix> [stem,stem,…]
//   scenario (same file as for tools/sc-port/strudel-run.mjs): { "bpm": 124, "cycles": 8, "cc": { "5": 1 },
//     "events": [ { "t": 2.5, "cc": 37, "v": 1 } ] }   — t in bars (cycles), cc values 0..1
// Writes <out-prefix>.wav (48 kHz float stereo, the master without trim and limiter) and <out-prefix>.events.json.
(
// any error ends sclang (otherwise a failed render would wait forever)
OSCFunc.trace(false);
{
var args = thisProcess.argv, here = thisProcess.nowExecutingPath.dirname;
var trackFile = args[0], scen = File.readAllString(args[1]).parseJSON, prefix = args[2], only = args[3];
var ce, track, server, msgs, bps, cycles, ctl, ctlPat, score, json, f, num, isLk, ccOf;
num = { |x| if(x.isString) { x.asFloat } { x } };
isLk = { |k| k.asString.beginsWith("lk") };
ccOf = { |k| if(isLk.(k)) { k.asString } { k.asInteger } };   // "lk31" stays a string: a Launchkey control
ce = (here.dirname +/+ "lib/ce.scd").load;
ce.quiet = true; ce.trimDb = 0; ce.limit = 0;
// comparisons: the FM modulator starts where superdough's offline render has it; "livePhase": true = random as live
ce.webaudioPhase = (scen["livePhase"] != true) and: { scen["livePhase"] != "true" };
// a Sample Designer project: scenario "sound" plays its exported library sound instead of the machine
track = if(trackFile.endsWith(".sample.json")) {
	(here.dirname +/+ "lib/designer.scd").load; ce.sampleProject(trackFile, scen["sound"]) } { ce.loadTrack(trackFile) };
if(only.notNil) { var names = only.split($,).collect(_.asSymbol); track.stems = track.stems.select { |s| names.includes(s.name) } };
server = ScoreStreamPlayer.new;
bps = num.(scen["bpm"] ? track.bpm) / 60;
cycles = num.(scen["cycles"] ? 8);
msgs = ce.prepare(server, track);
// CCs: numbers = the LC layout; "lk31" = a Launchkey control (its own, ~ce.lkCC)
(scen["cc"] ? ()).keysValuesDo { |k, v| var c = k.asInteger;
	if(isLk.(k)) { ce.lkCC[k.asString.drop(2).asInteger] = num.(v) } {
		ce.cc[ce.ccAlias[c] ? c] = num.(v); msgs = msgs.add([\c_set, ce.ccIndex(c), num.(v)]) } };
// control changes as events (first in the Ppar, so they come before notes at the same time)
ctl = (scen["events"] ? []).collect { |e| [num.(e["t"]) * 4, ccOf.(e["cc"]), num.(e["v"])] }
	// Launchkey keys and pads: [t, \key, note, velocity 0..1, channel 0-based]
	++ (scen["keyEvents"] ? []).collect { |e| [num.(e["t"]) * 4, \key, num.(e["note"]), num.(e["vel"] ? 100) / 127, num.(e["chan"] ? 1) - 1] };
ctl = ctl.sort { |a, b| a[0] <= b[0] };
// initial knob positions also go through the column hooks (lab columns take a value that is not 0, as Strudel's
// first query does); they come first, at time 0
ctl = (scen["cc"] ? ()).keys.asArray.sort.collect { |k| [0, ccOf.(k), num.(scen["cc"][k]), true] }.select { |c| c[2] != 0 } ++ ctl;
ctlPat = Prout({ var t = 0;
	ctl.do { |c| if(c[0] > t) { (type: \rest, dur: c[0] - t).yield; t = c[0] };
		case
		{ c[1] == \key } { (type: \ceLk, key: c[2], vel: c[3], chan: c[4], dur: 0).yield }
		{ c[1].isString } { (type: \ceLk, lkCc: c[1].drop(2).asInteger, v: c[2], dur: 0).yield }
		{ (type: \ceCtl, cc: c[1], v: c[2], force: c[3] ? false, dur: 0).yield } };
});
ce.log = List[];
score = ce.makeScore(Ppar([ctlPat, ce.patterns]).asStream, cycles * 4, bps, msgs);
// event log
f = File(prefix ++ ".events.json", "w");
f.write("[");
ce.log.do { |l, i|
	var e = l[2], keys = e.keys.asArray.reject { |k| [\server, \schedBundle, \schedBundleArray, \type, \group, \out, \latency, \dur, \delta, \timingOffset].includes(k) }.sort;
	if(i > 0) { f.write(",\n") };
	f.write("{\"b\":%,\"stem\":\"%\",\"v\":{".format((l[0] / 4).round(1e-6), l[1]));
	keys.do { |k, j| var v = e[k];
		if(j > 0) { f.write(",") };
		f.write("\"%\":%".format(k, if(v.isNumber) { v.asFloat.round(1e-6) } { "\"" ++ v.asString ++ "\"" }));
	};
	f.write("}}");
};
f.write("]\n"); f.close;
// buffer number → sample file, so two renders of the same notes compare by file (<out-prefix>.buffers.json)
f = File(prefix ++ ".buffers.json", "w");
f.write("{" ++ ce.sampleBuffers.keys.asArray.sort.collect { |rel|
	"\"%\":\"%\"".format(ce.sampleBuffers[rel], rel) }.join(",") ++ "}\n");
f.close;
// instrument → the inputs its SynthDef reads (<out-prefix>.controls.json): a comparison ignores every other key
f = File(prefix ++ ".controls.json", "w");
f.write("{" ++ ce.log.collect { |l| l[2][\instrument] }.asSet.asArray.reject(_.isNil).collect { |name|
	var snd = ce.sounds.values.detect { |x| x.def.name.asSymbol == name.asSymbol };
	var names = snd !? { |x| x.def.allControlNames.collect(_.name) } ?? {
		SynthDescLib.global[name.asSymbol] !? { |d| d.controlNames } } ? [];
	"\"%\":[%]".format(name, names.collect { |c| "\"%\"".format(c) }.join(","))
}.join(",") ++ "}\n");
f.close;
// CE_NO_AUDIO=1: the event log only, no audio render
if("CE_NO_AUDIO".getenv.notNil) { "rendered % (events only)".format(prefix).postln; 0.exit };
// the command file next to the output (recordNRT's default temp name is the same in every sclang process: two
// renders at once would overwrite each other's); kept with env CE_OSC=1, for debugging
score.recordNRT(prefix ++ ".nrt.osc", prefix ++ ".wav", sampleRate: 48000, headerFormat: "WAV", sampleFormat: "float",
	options: ServerOptions.new.numOutputBusChannels_(2).sampleRate_(48000).memSize_(65536).numWireBufs_(256),
	duration: cycles * 4 / bps + 2, action: {
		if("CE_OSC".getenv.isNil) { File.delete(prefix ++ ".nrt.osc") };
		"rendered %".format(prefix).postln; 0.exit });
}.try { |err| err.reportError; "RENDER ERROR".postln; 1.exit };
)
