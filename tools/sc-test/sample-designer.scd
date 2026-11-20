// Feature tests for the Sample Designer (sc/lib/designer.scd): every project in sc/lab/samples/ loads, its machine
// passes ~ce.checkSound, the audition plays notes with rhythm, buttons switch blocks, types and patterns.
// No sound server: the project is played into a score in the language (as tools/sc-test/run.scd).
// usage: sclang tools/sc-test/sample-designer.scd [<sound> <project.sample.json>]
//   → one line per check (PASS / FAIL), exit code 0 = all passed
//   <sound>: also check that the library sound sc/sounds/<sound>.scd (an export) loads and plays the project
(
var root = thisProcess.nowExecutingPath.dirname.dirname.dirname, fails = 0, passes = 0, check, loadCe, play, files;
var sound = thisProcess.argv[0];
SystemClock.sched(120, { "FAIL timeout after 120 s".postln; 1.exit });
check = { |name, fn|
	var ok = false, msg = "";
	{ ok = fn.value } .try { |err| msg = " (" ++ err.errorString ++ ")" };
	if(ok == true) { passes = passes + 1; "PASS %".format(name).postln }
		{ fails = fails + 1; "FAIL %%".format(name, msg).postln };
};
loadCe = { var ce = (root +/+ "sc/lib/ce.scd").load;
	(root +/+ "sc/lib/designer.scd").load; ce.quiet = true; ce.uiOn = false; ce };
// plays a project for `bars` bars; presses = [[bar, cc], …]; returns [ce, [[beat, stem, event], …]]
play = { |file, bars, presses, soundName|
	var ce = loadCe.value, track = ce.sampleProject(file, soundName), msgs, ctl;
	msgs = ce.prepare(ScoreStreamPlayer.new, track);
	ctl = Prout({ var t = 0;
		(presses ? []).do { |p| var at = p[0] * 4;
			if(at > t) { (type: \rest, dur: at - t).yield; t = at };
			(type: \ceCtl, cc: p[1], v: 1, dur: 0.25).yield; (type: \ceCtl, cc: p[1], v: 0, dur: 0).yield; t = t + 0.25 } });
	ce.log = List[];
	ce.makeScore(Ppar([ctl, ce.patterns]).asStream, bars * 4, track.bpm / 60, msgs);
	[ce, ce.log.asArray]
};
{
	files = (root +/+ "sc/lab/samples/*.sample.json").pathMatch.sort;
	check.("Sample Designer projects found", { files.size >= 2 });
	files.do { |file|
		var name = file.basename.replace(".sample.json", ""), ce, log;
		check.("% loads, its machine is a library-format sound, the audition plays".format(name), {
			#ce, log = play.(file, 4); log.size > 0 });
		check.("% audition has rhythm (hits on several 16ths)".format(name), {
			log.collect { |l| (l[0] * 4).round % 16 }.asSet.size >= 2 });
		check.("% shows a label on every block control and on column 8".format(name), {
			var tags = ce.uiTags.keys.asArray.collect(_.asString);
			var n = (ce.track.project["sources"] ++ ce.track.project["chain"]).size;
			(1..n).every { |c| ["k1", "k2", "k3", "fader", "b1", "b2"].every { |r| tags.includesEqual("16:" ++ c ++ "." ++ r) } }
				and: { ["k1", "k2", "k3", "fader", "b1", "b2"].every { |r| tags.includesEqual("g." ++ r) } } });
		check.("% button 1 turns block 1 off, button 2 steps its type".format(name), {
			var id = ce.track.project["sources"][0]["id"], on = ce.sampleParam(id, "on"), type = ce.sampleParam(id, "type");
			var on0, type0;
			#ce, log = play.(file, 1);
			on0 = ce.stateVal[on]; type0 = ce.stateVal[type];
			#ce, log = play.(file, 1, [[0.25, 37], [0.5, 45]]);
			(ce.stateVal[on] == (1 - on0)) and: { ce.stateVal[type] != type0 } });
		check.("% Pattern (column 8) switches the audition at the next bar".format(name), {
			var plain = play.(file, 4)[1], pressed = play.(file, 4, [[1.5, 44]])[1];
			var after = { |l| l.select { |x| x[0] >= 8 }.collect { |x| [x[0], x[2][\freq], x[2][\amp]] } };
			var before = { |l| l.select { |x| x[0] < 8 }.collect { |x| [x[0], x[2][\freq], x[2][\amp]] } };
			(before.(plain) == before.(pressed)) and: { after.(plain) != after.(pressed) } });
		check.("% Save sends the current values".format(name), {
			var values;
			#ce, log = play.(file, 1);
			values = ce.track.designerValues(ce);
			(values[\blocks].size == (ce.track.project["sources"] ++ ce.track.project["chain"]).size)
				and: { ce.toJSON(values).contains("\"audition\"") } });
	};
	sound !? {
		check.("exported sound % loads (checkSound) and plays its project".format(sound), {
			var ce = loadCe.value; ce.loadSound(sound);
			play.(thisProcess.argv[1] ? files[0], 2, nil, sound)[1].size > 0 });
	};
	"% passed, % failed".format(passes, fails).postln;
	(fails > 0).binaryValue.exit;
}.try { |err| err.reportError; "FAIL test run crashed".postln; 1.exit };
)
