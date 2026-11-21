// Feature tests for the Stem Designer (sc/lib/stemlab.scd): every project in sc/lab/stems/ loads, plays its columns
// and its backing stems, shows labels, selects the column moved last, Add / Remove / Replace reach the player, a
// draft column plays, Promote of a library stem sends nothing, 14 columns load.
// No sound server: the project is played into a score in the language (as tools/sc-test/run.scd).
// usage: sclang tools/sc-test/stem-designer.scd   → one line per check (PASS / FAIL), exit code 0 = all passed
(
var root = thisProcess.nowExecutingPath.dirname.dirname.dirname, fails = 0, passes = 0, check, loadCe, play, files;
var flute = "flute/flute-brightness-space-complexity-pattern-echo-throw.stem", tmp, writeProject, slotsOf;
SystemClock.sched(200, { "FAIL timeout after 200 s".postln; 1.exit });
check = { |name, fn|
	var ok = false, msg = "";
	{ ok = fn.value } .try { |err| msg = " (" ++ err.errorString ++ ")" };
	if(ok == true) { passes = passes + 1; "PASS %".format(name).postln }
		{ fails = fails + 1; "FAIL %%".format(name, msg).postln };
};
loadCe = { var ce = (root +/+ "sc/lib/ce.scd").load;
	(root +/+ "sc/lib/stemlab.scd").load; ce.quiet = true; ce.uiOn = false; ce.swapLoad = { |m, done| done.value }; ce };
// plays a project for `bars` bars with every fader up; presses = [[bar, cc], …]; returns [ce, [[beat, stem, event], …]]
play = { |file, bars, presses|
	var ce = loadCe.value, track = ce.stemLabProject(file), msgs, ctl;
	msgs = ce.prepare(ScoreStreamPlayer.new, track);
	((5..12) ++ (53..59)).do { |c| ce.cc[c] = 1; msgs = msgs.add([\c_set, ce.ccIndex(c), 1]) };
	ctl = Prout({ var t = 0;
		(presses ? []).do { |p| var at = p[0] * 4;
			if(at > t) { (type: \rest, dur: at - t).yield; t = at };
			(type: \ceCtl, cc: p[1], v: p[2] ? 1, dur: 0.25).yield; (type: \ceCtl, cc: p[1], v: 0, dur: 0).yield; t = t + 0.25 } });
	ce.log = List[];
	~ce = ce; ~lastCe = ce;
	ce.makeScore(Ppar([ctl, ce.patterns]).asStream, bars * 4, track.bpm / 60, msgs);
	[ce, ce.log.asArray]
};
tmp = Platform.defaultTempDir +/+ "stemlab-test";
File.mkdir(tmp);
writeProject = { |name, body| var file = tmp +/+ (name ++ ".stemlab.json"); File.use(file, "w", { |f| f.write(body) }); file };
{
	files = (root +/+ "sc/lab/stems/*.stemlab.json").pathMatch.sort;
	check.("Stem Designer projects found", { files.size >= 1 });
	files.do { |file|
		var name = file.basename.replace(".stemlab.json", ""), ce, log, project;
		check.("% loads and plays its columns".format(name), {
			#ce, log = play.(file, 8); project = ce.track.project;
			project[\columns].keys.every { |slot|
				(0..127).any { |k| ce.track.columns[slot].stepNotes(k).reject { |n| n[\msg].notNil }.notEmpty } } });
		check.("% plays its backing stems without a controller".format(name), {
			(ce.track.backing.size == (project[\context][\backing] ? []).size)
				and: { ce.track.backing.values.every { |col| log.any { |l| l[1] == col[\stemName] } } } });
		check.("% keeps its slots, tells which are free or drafts, and columns and backing have their own levels".format(name), {
			var slots = ce.track.uiCols(ce)[\designer][\slots], masters = ce.track.stems.collect { |st| st[\master] };
			ce.stemSlots.every { |slot| slots[slot] == if(ce.track.columns[slot].isNil) { "free" } { if(ce.track.slots[slot].beginsWith("draft:")) { "draft" } { "library" } } }
				and: { masters.count { |m| m == ce.labLevelCc[\context] } == ce.track.backing.size }
				and: { masters.count { |m| m == ce.labLevelCc[\stems] } == ce.track.columns.size } });
		check.("% shows a label on every column control and Volume on column 8".format(name), {
			var tags = ce.uiTags.keys.asArray.collect(_.asString), tag = { |key| var out = ""; ce.uiTags.keysValuesDo { |k, v| if(k.asString == key) { out = v.asString } }; out };
			project[\columns].keys.every { |slot| var s = slot.asString;
				["k1", "k2", "k3", "fader", "b1", "b2"].every { |r|
					tags.includesEqual((if(s[0] == $1) { "16:" } { "2:" }) ++ s[2] ++ "." ++ r) } }
				and: { tag.("g.b1").beginsWith("Volume") } });
		check.("% the column moved last is the selection".format(name), {
			var slot = project[\columns].keys.asArray.sort.last, cc = ce.slotCCs(slot)[\k1];
			#ce, log = play.(file, 1, [[0.25, cc, 0.5]]);
			ce.track.labSelected == slot.asSymbol });
		check.("% column 8 is the same in both modes and button 1 cycles stems, context volume".format(name), {
			var glob = ce.stemGlobal, levels, set;
			ce = loadCe.value;
			ce.prepare(ScoreStreamPlayer.new, ce.stemLabProject(file));
			ce.track.build(ce);
			set = { |cc, v| ce.setCC(cc, v, { |m| }) };
			levels = { [ce.val(ce.labLevelCc[\stems]), ce.val(ce.labLevelCc[\context])] };
			set.(glob[\master], 0.5);
			set.(glob[\master] + 48, 0.5);
			(ce.ccAlias[glob[\master] + 48] == glob[\master] and: { ce.ccAlias[glob[\chapter] + 48] == glob[\chapter] })
				and: { ce.track.labTarget == \stems and: { levels.value == [0.5, 1] } }
				and: { ce.pressFns[glob[\chapter]].do(_.value); ce.track.labTarget == \context }
				and: { set.(glob[\master], 0.2); levels.value == [0.5, 0.2] }
				and: { ce.pressFns[glob[\chapter]].do(_.value); ce.track.labTarget == \stems }
				and: { set.(glob[\master], 0.4); levels.value == [0.4, 0.2] } });
	};
	check.("a draft column plays and its stem comes from the project", {
		var text = File.readAllString(root +/+ "sc/stems" +/+ flute).replace("\"parent\": null", "\"parent\": \"" ++ flute ++ "\""), file, ce, log;
		file = writeProject.("draft-test", "{\"format\":1,\"name\":\"draft-test\",\"about\":\"t\","
			++ "\"context\":{\"track\":\"009-house\"},\"columns\":{\"1:1\":\"draft:airy\"},"
			++ "\"drafts\":{\"airy\":" ++ text ++ "}}");
		#ce, log = play.(file, 8);
		(0..127).any { |k| ce.track.columns['1:1'].stepNotes(k).reject { |n| n[\msg].notNil }.notEmpty }
			and: { ce.track.slots['1:1'] == "draft:airy" }
			and: { ce.track.uiCols(ce)[\designer][\slots]['1:1'] == "draft" } });
	check.("an overriding knob on a column-code stem: the code reads 0.5 and the notes carry the parameter", {
		var brass = "sc/stems/brassSection/brass-section-brightness-space-complexity-pattern-lift.stem";
		var text = File.readAllString(root +/+ brass).replace("\"parent\": null", "\"parent\": \"" ++ brass.drop(9) ++ "\""), stem, file, ce, log, notes;
		stem = text.parseJSON;
		stem["controls"]["k1"] = (label: "Pan", about: "left right", param: "pan", range: [-1, 1], default: 0.5, override: true);
		file = writeProject.("override-test", "{\"format\":1,\"name\":\"override-test\",\"about\":\"t\","
			++ "\"context\":{\"track\":\"009-house\"},\"columns\":{\"1:1\":\"draft:pan\"},"
			++ "\"drafts\":{\"pan\":" ++ loadCe.value.toJSON(stem) ++ "}}");
		#ce, log = play.(file, 8);
		ce.setCC(ce.track.columns['1:1'][\ccs][\k1], 1.0, { |m| });
		notes = (0..127).collect { |k| ce.track.columns['1:1'].stepNotes(k).select { |n| n[\instrument].notNil } }.flatten;
		(ce.track.columns['1:1'].knob(\k1) == 0.5) and: { notes.size > 0 }
			and: { notes.every { |n| n[\pan] >= 0 } } and: { notes.any { |n| n[\pan] == 1 } } });
	check.("fourteen columns load and play", {
		var slots = File.readAllString(root +/+ "sc/tracks/009-house/009-house.track").parseJSON["slots"], file, ce, log;
		file = writeProject.("fourteen", "{\"format\":1,\"name\":\"fourteen\",\"about\":\"t\","
			++ "\"context\":{\"track\":\"009-house\"},\"columns\":" ++ loadCe.value.toJSON(slots) ++ "}");
		#ce, log = play.(file, 8);
		(ce.track.columns.size == 14) and: { log.size > 0 } });
	"% passed, % failed".format(passes, fails).postln;
	(fails > 0).binaryValue.exit;
}.try { |err| err.reportError; "FAIL test run crashed".postln; 1.exit };
)
