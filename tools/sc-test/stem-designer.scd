// Feature tests for the Stem Designer (sc/lib/stemlab.scd): every project in sc/lab/stems/ loads, plays its columns
// and its backing stems, shows labels, selects the column moved last, A/B swaps a column against the context track's
// stem, a draft column plays, Promote reaches the player, 14 columns load.
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
		check.("% shows a label on every column control and A/B and Promote on column 8".format(name), {
			var tags = ce.uiTags.keys.asArray.collect(_.asString), tag = { |key| var out = ""; ce.uiTags.keysValuesDo { |k, v| if(k.asString == key) { out = v.asString } }; out };
			project[\columns].keys.every { |slot| var s = slot.asString;
				["k1", "k2", "k3", "fader", "b1", "b2"].every { |r|
					tags.includesEqual((if(s[0] == $1) { "16:" } { "2:" }) ++ s[2] ++ "." ++ r) } }
				and: { tag.("g.b1").beginsWith("A/B") and: { tag.("g.b2").beginsWith("Promote") } } });
		check.("% the column moved last is the selection".format(name), {
			var slot = project[\columns].keys.asArray.sort.last, cc = ce.slotCCs(slot)[\k1];
			#ce, log = play.(file, 1, [[0.25, cc, 0.5]]);
			ce.track.labSelected == slot.asSymbol });
		check.("% A/B swaps the selected column to the context track's stem at the next bar".format(name), {
			var slot = project[\select].asSymbol;
			#ce, log = play.(file, 2, [[0.25, ce.stemGlobal[\chapter]]]);
			(ce.track.labShowing[slot] == \original) and: { ce.track.pending[slot].isNil }
				and: { ce.track.slots[slot] == (ce.readJSON(root +/+ "sc/tracks/009-house/009-house.track")[\slots][slot]) } });
		check.("% Promote tells the player the selected column".format(name), {
			var sent = nil;
			ce = loadCe.value; ce.uiOn = true; ce.uiAddr = (sendMsg: { |self ... msg| sent = msg });
			ce.prepare(ScoreStreamPlayer.new, ce.stemLabProject(file));
			ce.track.build(ce);
			ce.pressFns[ce.stemGlobal[\break]].do(_.value);
			sent.notNil and: { sent[0] == '/ce/promote' } });
	};
	check.("a draft column plays and its stem comes from the project", {
		var text = File.readAllString(root +/+ "sc/stems" +/+ flute).replace("\"parent\": null", "\"parent\": \"" ++ flute ++ "\""), file, ce, log;
		file = writeProject.("draft-test", "{\"format\":1,\"name\":\"draft-test\",\"about\":\"t\","
			++ "\"context\":{\"track\":\"009-house\"},\"columns\":{\"2:4\":\"draft:airy\"},"
			++ "\"drafts\":{\"airy\":" ++ text ++ "}}");
		#ce, log = play.(file, 8);
		(0..127).any { |k| ce.track.columns['2:4'].stepNotes(k).reject { |n| n[\msg].notNil }.notEmpty }
			and: { ce.track.slots['2:4'] == "draft:airy" } });
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
