// Feature tests for the SuperCollider side: do the building blocks and every live track still do their job?
// Loose checks only (something plays, a press changes what plays, a value arrives), never "is the output identical".
// No sound server needed: tracks are played into a score in the language (like sc/tools/render.scd, without the
// audio render).
// usage: sclang tools/sc-test/run.scd        → one line per check (PASS / FAIL), exit code 0 = all passed
(
var root = thisProcess.nowExecutingPath.dirname.dirname.dirname, fails = 0, passes = 0, check, loadCe, play, tracks, missing;
// a hung check must not hang the test run
SystemClock.sched(240, { "FAIL timeout after 240 s".postln; 1.exit });
check = { |name, fn|
	var ok = false, msg = "";
	{ ok = fn.value } .try { |err| msg = " (" ++ err.errorString ++ ")" };
	if(ok == true) { passes = passes + 1; "PASS %".format(name).postln } { fails = fails + 1; "FAIL %%".format(name, msg).postln };
};
loadCe = { var ce = (root +/+ "sc/lib/ce.scd").load; ce.quiet = true; ce.uiOn = false; ce };
// Play a track for `bars` bars into a score with every fader and the master up; `presses` = [[bar, cc], …].
// Returns the note log: [[beat, stem, event], …]
play = { |file, bars, presses|
	var ce = loadCe.value, track = file.load, msgs, ctl, stream;
	msgs = ce.prepare(ScoreStreamPlayer.new, track);
	// faders of columns 1-7 on both pages and the master (column 8): up
	((5..12) ++ (53..59)).do { |c| ce.cc[ce.ccAlias[c] ? c] = 1; msgs = msgs.add([\c_set, ce.ccIndex(c), 1]) };
	ctl = Prout({ var t = 0;
		(presses ? []).sort { |a, b| a[0] <= b[0] }.do { |p| var at = p[0] * 4;
			if(at > t) { (type: \rest, dur: at - t).yield; t = at };
			(type: \ceCtl, cc: p[1], v: 1, dur: 0.25).yield; (type: \ceCtl, cc: p[1], v: 0, dur: 0).yield; t = t + 0.25 } });
	ce.log = List[];
	stream = Ppar([ctl, ce.patterns]).asStream;
	ce.makeScore(stream, bars * 4, track.bpm / 60, msgs);
	~lastCe = ce;
	ce.log.asArray
};
// sample files a track loads that are not on disk (the loader itself does not complain)
missing = { |ce| ce.sampleBuffers.keys.asArray.reject { |rel|
	File.exists(if(rel.beginsWith("repo:")) { ce.root.dirname +/+ "samples" +/+ rel.drop(5) } { ce.root +/+ "samples" +/+ rel }) } };
// what plays, as text per note: beat, stem and every number of the note (pitch, gain, filter …)
~sig = { |log, fromBeat = 0| log.select { |l| l[0] >= fromBeat }.collect { |l|
	var e = l[2], keys = e.keys.asArray.select { |k| e[k].isNumber and: { [\dur, \delta, \latency, \timingOffset].includes(k).not } }.sort;
	"% % %".format(l[0].round(1e-4), l[1], keys.collect { |k| e[k].round(1e-4) }) } };

{
	// --- building blocks ---
	check.("mini-notation: alternation, repeats, weights", {
		var ce = loadCe.value, m = ce.mini("<[0 ~ 2]!3 [~ 4@2]>");
		(m.period == 4) and: { m.events.size == 7 } });
	check.("mini-notation: notes stay names, numbers become numbers", {
		var ce = loadCe.value, m = ce.mini("c3 [e3 g3] 7");
		m.events.collect(_[2]) == ["c3", "e3", "g3", 7] });
	check.("latch: a press switches at the next bar, not before", {
		var ce = loadCe.value, l = ce.latch(1);
		l.atBar(0); l.pending = 1;
		(l.atBar(0.5) == 0) and: { l.atBar(1) == 1 } and: { l.atBar(1.9) == 1 } });
	check.("pattern button: each press picks the next pattern, wrapping around", {
		var ce = loadCe.value.ccBase_(0), l = ce.change(37, 3, "test"), press = { ce.setCC(37, 1, {}); ce.setCC(37, 0, {}) };
		press.value; l.atBar(1); press.value; l.atBar(2); press.value; l.atBar(3);
		l.now == 0 });
	check.("two Launch Controls: the one moved last wins", {
		var ce = loadCe.value.ccBase_(0);
		ce.server = (sendMsg: { });
		ce.midiPorts[1] = (name: "LCXL3 1", kind: \lc); ce.midiPorts[2] = (name: "LCXL3 2", kind: \lc);
		ce.midiCC(127, 13, 1); ce.midiCC(0, 13, 2);
		ce.val(13) == 0 });
	check.("Launch Control ports are found by name, DAW ports are not", {
		var ce = loadCe.value;
		(ce.midiKindOf("LCXL3 1 MIDI") == \lc) and: { ce.midiKindOf("LCXL3 1 DAW") != \lc } });

	// --- every live track ---
	tracks = (root +/+ "sc/tracks/*/*.scd").pathMatch.sort;
	check.("SC live tracks found", { tracks.size >= 4 });
	tracks.do { |file|
		var name = file.basename.splitext[0], log, pressed;
		check.("% loads and plays notes with the faders up".format(name), {
			log = play.(file, 4); log.size > 0 });
		check.("% every sample file it loads exists".format(name), {
			var m = missing.(~lastCe); if(m.notEmpty) { ("  missing: " ++ m.join(", ")).postln }; m.isEmpty });
		check.("% several stems play".format(name), {
			log.notNil and: { log.collect(_[1]).asSet.size >= 3 } });
		// the first Pattern / Chords button (button row 1) of the track's @ctl lines, pressed in bar 1:
		// what plays from bar 2 on changes, what played before does not
		check.("% Pattern button changes what plays at the next bar".format(name), {
			var line = File.readAllString(file).split($\n).detect { |l| "^// @ctl (16|2):([1-7])\\.b1 (Pattern|Chords) ".matchRegexp(l) };
			var pos = line.split($ )[2].split($.)[0].split($:), cc = 36 + pos[1].asInteger + (if(pos[0] == "2") { 48 } { 0 });
			pressed = play.(file, 4, [[1.5, cc]]);
			(~sig.(log, 8) != ~sig.(pressed, 8)) and: { ~sig.(log, 0).keep(~sig.(log, 0).count { |s| s.split($ )[0].asFloat < 6 }) == ~sig.(pressed, 0).keep(~sig.(pressed, 0).count { |s| s.split($ )[0].asFloat < 6 }) } });
	};

	"% passed, % failed".format(passes, fails).postln;
	(fails > 0).binaryValue.exit;
}.try { |err| err.reportError; "FAIL test run crashed".postln; 1.exit };
)
