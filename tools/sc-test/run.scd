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
// Play a track for `bars` bars into a score with every fader and the master up; `presses` = [[bar, cc], …] (a press
// of a 16th), [[bar, cc, beats], …] (held that long) or [[bar, function], …] (called at that time).
// Returns the note log: [[beat, stem, event], …]
play = { |file, bars, presses|
	var ce = loadCe.value, track = ce.loadTrack(file), msgs, ctl, stream;
	msgs = ce.prepare(ScoreStreamPlayer.new, track);
	// faders of columns 1-7 on both pages and the master (column 8): up
	((5..12) ++ (53..59)).do { |c| ce.cc[ce.ccAlias[c] ? c] = 1; msgs = msgs.add([\c_set, ce.ccIndex(c), 1]) };
	ctl = Prout({ var t = 0;
		(presses ? []).sort { |a, b| a[0] <= b[0] }.do { |p| var at = p[0] * 4;
			if(at > t) { (type: \rest, dur: at - t).yield; t = at };
			if(p[1].isKindOf(Function)) { p[1].value } {
				(type: \ceCtl, cc: p[1], v: 1, dur: p[2] ? 0.25).yield; (type: \ceCtl, cc: p[1], v: 0, dur: 0).yield;
				t = t + (p[2] ? 0.25) } } });
	ce.log = List[];
	~lastCe = ce;
	stream = Ppar([ctl, ce.patterns]).asStream;
	ce.makeScore(stream, bars * 4, track.bpm / 60, msgs);
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

	// --- stems and stem tracks (sc/lib/stems.scd, addons.scd, stemtrack.scd) ---
	{
		var demo = root +/+ "sc/tracks/090-stem-demo/090-stem-demo.track";
		var bassRef = "bassWarm/bass-warm-brightness-space-length-pattern-octave.stem";
		var of = { |log, stem, from = 0, to = inf|
			log.select { |l| (l[1] == stem) and: { l[0] >= from } and: { l[0] < to } } };
		var beatsOf = { |log, stem, from, to| of.(log, stem, from, to).collect { |l| l[0].round(1e-3) } };
		// a stem track prepared in a score, its columns started, faders of columns 1 and 4 and the master up
		var ready = { var ce = loadCe.value, track = ce.loadTrack(demo);
			ce.prepare(ScoreStreamPlayer.new, track); ce.patterns; [5, 8, 12].do { |c| ce.cc[c] = 1 }; [ce, track] };
		check.("stem: a .stem loads as a column with its sample, patterns and add-on", {
			var ce = loadCe.value, track = ce.loadTrack(demo), col = track.columns['1:1'];
			(col[\sample] == \kick909) and: { col[\pats].size == 3 } and: { col[\addon] === ce.addons[\dropOut] }
				and: { track.stems.collect(_.name) == [\s1_1, \s1_4] } });
		check.("stem track: both stems play, the bass on the chord's root", {
			var log = play.(demo, 4), bass = of.(log, \s1_4);
			(of.(log, \s1_1).size == 16) and: { bass.size == 24 } and: { bass.every { |l| l[2][\midi] == 33 } } });
		check.("stem: Pattern cycles at the next bar", {
			var log = play.(demo, 4, [[1.5, 40]]);
			(beatsOf.(log, \s1_4, 4, 8) == beatsOf.(play.(demo, 4), \s1_4, 4, 8))
				and: { beatsOf.(log, \s1_4, 8, 12) == [8.5, 9.5, 10.5, 11.5] } });
		check.("stem: a knob reaches its bus, notes read the bus", {
			var x = ready.value, ce = x[0], sent = List[], note;
			ce.setCC(13, 0.5, { |m| sent.add(m) });
			note = x[1].columns['1:1'].stepNotes(0)[0];
			sent.any { |m| m == [\c_set, ce.stateBus[\s1_1_bright], 0.5] }
				and: { note[\bright] == ce.stateMap(\s1_1_bright) } });
		check.("stem: the add-on fires (Drop out mutes the kick, Octave lifts the bass)", {
			var log = play.(demo, 4, [[1, 45, 4], [2, 48, 4]]);
			of.(log, \s1_1, 4, 8).isEmpty and: { of.(log, \s1_1, 8, 12).size == 4 }
				and: { of.(log, \s1_4, 8, 12).every { |l| l[2][\midi] == 45 } }
				and: { of.(log, \s1_4, 12, 16)[0][2][\midi] == 33 } });
		check.("stem: every add-on of sc/stems/addons.json is built and changes what plays", {
			var x = ready.value, ce = x[0], col = x[1].columns['1:4'];
			var ids = File.readAllString(root +/+ "sc/stems/addons.json").parseJSON["addons"].keys.asArray.sort;
			var sig = { (0..63).collect { |k|
				col.stepNotes(k).collect { |n| [n[\instrument], n[\midi], n[\hold], n[\at], n[\amp]] } }
				++ col.stateValues.asSortedArray };
			var off = sig.value;
			ids.every { |id| var on, addon = ce.addons[id.asSymbol];
				(addon[\sounds] ? []).do { |s| if(ce.sounds[s].isNil) { ce.loadSound(s) } };
				col[\addon] = addon; col[\addonMode] = \hold; ce.cc[48] = 1; col[\addonState][\since] = nil;
				on = sig.value; ce.cc[48] = 0;
				if(on == off) { "  add-on % changes nothing".format(id).postln };
				on != off } });
		check.("stem: silent columns are gated (no hits made at fader 0)", {
			var x = ready.value, ce = x[0], col = x[1].columns['1:1'], asked = 0, notes;
			col[\patternHits] = { asked = asked + 1; [] };
			ce.cc[5] = 0; notes = (0..31).collect { |k| col.stepNotes(k) };
			ce.cc[5] = 1; (0..3).do { |k| col.stepNotes(k) };
			(asked == 4) and: { notes.every(_.isEmpty) } });
		check.("stem: Break takes out the stems marked break out at the next bar", {
			var log = play.(demo, 4, [[0.5, 52]]);
			(of.(log, \s1_1, 0, 4).size == 4) and: { of.(log, \s1_1, 4, 16).isEmpty } and: { of.(log, \s1_4, 4, 16).isEmpty } });
		check.("stem: code hatch files (stem, knob, b1, b2) load and play", {
			var x = ready.value, ce = x[0], dir = Platform.defaultTempDir +/+ "ce-stem-code", stem, col, notes;
			var write = { |name, code| File.mkdir(dir); File.use(dir +/+ name, "w", { |f| f.write(code) }) };
			write.("hits.scd", "{ |col, k| if(k % 8 == 0) { [(at: 0, dur: 2, note: 7, vel: 0.5)] } { [] } }");
			write.("knob.scd", "{ |v, col| (dark: v) }");
			write.("press.scd", "{ |col| col[\\pressed] = true }");
			write.("addon.scd", "(mute: true)");
			stem = ce.loadStem(bassRef);
			stem[\dir] = dir; stem[\code] = "hits.scd";
			stem[\controls][\k3] = (label: "Dark", about: "x.", code: "knob.scd");
			stem[\controls][\b1][\code] = "press.scd";
			stem[\controls][\b2] = (label: "Mute", about: "x.", mode: "hold", code: "addon.scd");
			col = ce.stemColumn(stem, '1:4', x[1]); col.startCol(ce); x[1].columns['1:4'] = col;
			ce.cc[32] = 0.5;
			notes = (0..15).collect { |k| col.stepNotes(k) }.flatten(1);
			col.pressB1; ce.cc[48] = 1;
			(notes.size == 2) and: { notes.every { |n| (n[\midi] == 40) and: { n[\amp] == 0.5 } and: { n[\dark] == 0.5 } } }
				and: { col[\pressed] == true } and: { col.stepNotes(16).isEmpty } });
		check.("swap: a stem takes over its slot at the next bar, the other columns play on", {
			var log = play.(demo, 4, [[1.5, { ~lastCe.swapSlot('1:1', bassRef, { |msgs, done| done.value }) }]]);
			var tags = ~lastCe.track.tagLines, swapped = of.(log, \s1_1, 8, 16);
			of.(log, \s1_1, 0, 8).every { |l| l[2][\instrument] == \ce_kick909 } and: { swapped.notEmpty }
				and: { swapped.every { |l| l[2][\instrument] == \ce_bassWarm } }
				and: { tags.includesEqual("// @ctl 16:1.b2 Octave | one octave up while held.") }
				and: { beatsOf.(log, \s1_4, 0, 16) == beatsOf.(play.(demo, 4), \s1_4, 0, 16) } });
		check.("stem track: @ctl lines from the stems and the frame", {
			var ce = loadCe.value, lines = ce.loadTrack(demo).tagLines;
			lines.do { |l| ("TAG " ++ l).postln };
			lines.includesEqual("// @ctl 16:4.k3 Length | short ↔ long.")
				and: { lines.includesEqual("// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).") } });
		// the 009 pilot: 14 stems, 13 of them column code (sc/stems/*/*.scd), the frame's harmony
		{
			var house = root +/+ "sc/tracks/009-house/009-house.track";
			check.("009 stem track: 14 stems load, every column makes notes", {
				var ce = loadCe.value, track = ce.loadTrack(house);
				ce.prepare(ScoreStreamPlayer.new, track); ce.patterns;
				((5..12) ++ (53..59)).do { |c| ce.cc[c] = 1 };
				(track.columns.size == 14) and: {
					track.columns.every { |col| (0..127).any { |k| col.stepNotes(k).reject { |n| n[\msg].notNil }.notEmpty } } } });
			// stem format 2: the 009 drums, sub, bass and harmony are JSON (kits, layers, amounts, lengths, held chords)
			{
				var ce = loadCe.value, track = ce.loadTrack(house), at = { |slot, k| track.columns[slot].stepNotes(k) };
				var bufs = { |notes| notes.collect { |n| ce.sampleBuffers.findKeyForValue(n[\buf]) } };
				ce.prepare(ScoreStreamPlayer.new, track); ce.patterns;
				((5..12) ++ (53..59)).do { |c| ce.cc[c] = 1 };
				check.("stem format 2: a kit's notes pick its files, played to their end", {
					var n = at.('1:5', 4);
					(bufs.(n) == ["tr909/cp-00.wav"]) and: { n[0][\hold] == -1 } });
				check.("stem format 2: Complexity layers come in from a knob value", {
					var off, on, more;
					ce.cc[33] = 0; off = [at.('1:5', 8), at.('1:5', 6)];
					ce.cc[33] = 0.25; on = [at.('1:5', 8), at.('1:5', 6)];
					ce.cc[33] = 0.75; more = [at.('1:5', 8), at.('1:5', 6)];
					ce.cc[33] = 0;
					(off.flatten(1).isEmpty) and: { on[0].size == 1 } and: { on[1].isEmpty } and: { more[1].size == 1 } });
				check.("stem format 2: a cross-fade knob trades one layer for another", {
					var hats, shaker;
					ce.cc[34] = 0; hats = bufs.(at.('1:6', 2));
					ce.cc[34] = 1; shaker = bufs.(at.('1:6', 2));
					ce.cc[34] = 0;
					(hats == ["tr909/oh-00.wav"]) and: { shaker == ["tr727/sh-00.wav"] } });
				check.("stem format 2: a length knob relative to the note (sub Length)", {
					var long, short;
					ce.cc[31] = 0; long = at.('1:3', 1).collect(_[\hold]);
					ce.cc[31] = 1; short = at.('1:3', 1).collect(_[\hold]);
					ce.cc[31] = 0;
					(long == [3, 3]) and: { short.every { |h| (h - 1.05).abs < 1e-9 } } });
				check.("stem format 2: held chords struck on a change, layers on a live mix", {
					var n = at.('2:1', 0);
					(n.size == 24) and: { at.('2:1', 1).isEmpty } and: { n.every { |x| x[\mix].asString[0] == $c } }
						and: { n.collect(_[\midi]).asSet.includes(52) } });
				check.("stem format 2: a chance layer (conga ghosts) plays from Complexity on", {
					var count = { (0..63).collect { |k| at.('1:7', k).size }.sum }, none, some;
					ce.cc[35] = 0; none = count.value; ce.cc[35] = 1; some = count.value; ce.cc[35] = 0;
					some > none });
			}.value;
			check.("009 stem track: Chords on the chords column steps the frame's progressions", {
				var log = play.(house, 12, [[1.5, 85], [1.7, 44]]), track = ~lastCe.track;
				(track.prog.now == 1) and: { track.chordAt(8).name == "Am7" } and: { track.chordAt(0).name == "Am9" } });
			// keys (2:2) makes its own button-2 press and knob hooks; vibraphone wants the same strip
			check.("009 swap: the outgoing stem's own hooks and latches leave with it", {
				var vib = "vibraphone/vibraphone-brightness-space-complexity-pattern-echo-throw.stem", keys, before, ce, log;
				log = play.(house, 4, [[0.5, { var c = ~lastCe; keys = c.track.columns['2:2'];
					before = [(c.pressFns[94] ? []).size, c.ccHooks[62].size, c.latches.includes(keys[\patLatch])] }],
					[1.5, { ~lastCe.swapSlot('2:2', vib, { |m, done| done.value }) }]]);
				ce = ~lastCe;
				(before == [1, 2, true]) and: { (ce.pressFns[94] ? []).isEmpty } and: { ce.ccHooks[62].size == 1 }
					and: { ce.latches.includes(keys[\patLatch]).not } and: { ce.track.slots['2:2'] == vib }
					and: { of.(log, \s2_2, 8, 16).notEmpty } });
			check.("009 swap: a stem that needs another strip is refused live; a load takes it in place of the file's", {
				var ce = loadCe.value, track = ce.loadTrack(house, "{ \"1:4\": \"%\" }".format(bassRef));
				ce.prepare(ScoreStreamPlayer.new, track);
				(track.slots['1:4'] == bassRef) and: { ce.swapProblem('1:4', ce.loadTrack(house).slots['1:4']).notNil }
					and: { ce.swapProblem('1:1', "kick909/kick909-brightness-space-punch-pattern-drop-out.stem").isNil } });
		}.value;
	}.value;

	// --- every live track ---
	tracks = (root +/+ "sc/tracks/*/*.scd").pathMatch.sort.select { |f| f.basename.splitext[0] == f.dirname.basename };
	check.("SC live tracks found", { tracks.size >= 4 });
	tracks.do { |file|
		var name = file.basename.splitext[0], log, pressed;
		check.("% loads and plays notes with the faders up".format(name), {
			log = play.(file, 4); log.size > 0 });
		// the Launchkey's knob 1 sends CC 21 (its default): it must reach the track (brightness of the keys)
		check.("% Launchkey knob 1 (CC 21) reaches the track".format(name), {
			var ce = ~lastCe; ce.setLkCC(21, 0.7, {}); ce.stateVal[\lkBright] == 0.7 });
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
