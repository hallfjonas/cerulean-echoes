// Which library stems fail in which frame? Every stem of sc/stems goes onto a slot of every stem track (14 stems per
// load, one per slot), plays 16 bars into a score (faders up through the column hooks, Tension 0.6), and each column
// whose code failed (it went quiet, sc/lib/stemtrack.scd) prints one line:
//   ERROR <track id> <stem ref> | <first line of the error>
// A batch that throws outside the columns (a stem's hook on load) is tried again one stem per load.
// usage: sclang tools/sc-test/stem-frames.scd [<track id> …]   (no ids: every stem track)
(
var root = thisProcess.nowExecutingPath.dirname.dirname.dirname, only = thisProcess.argv;
var slots = [1, 2].collect { |m| (1..7).collect { |c| "%:%".format(m, c) } }.flatten;
var refs = (root +/+ "sc/stems/*/*.stem").pathMatch.collect { |p| p.drop((root +/+ "sc/stems/").size) };
var tracks = (root +/+ "sc/tracks/*/*.track").pathMatch.select { |p|
	only.isEmpty or: { only.includesEqual(p.basename.splitext[0]) } };
var firstLine = { |text| text.split($\n).reject(_.isEmpty).first ? "" }, run;
SystemClock.sched(1200, { "FAIL timeout after 1200 s".postln; 1.exit });
// plays these refs on the first slots of the track; [ref, error or nil] per ref
run = { |file, batch|
	var ce = (root +/+ "sc/lib/ce.scd").load, track, msgs, pats;
	var map = "{%}".format(batch.collect { |ref, i| "\"%\": \"%\"".format(slots[i], ref) }.join(", "));
	ce.quiet = true; ce.uiOn = false;
	track = ce.loadTrack(file, map);
	msgs = ce.prepare(ScoreStreamPlayer.new, track);
	pats = ce.patterns;
	(((5..12) ++ (53..59)).collect { |c| [c, 1] } ++ [[36, 0.6]]).do { |c|
		ce.setCC(c[0], c[1], { |m| msgs = msgs.add(m) }, true) };
	ce.makeScore(Ppar([pats]).asStream, 16 * 4, track.bpm / 60, msgs);
	batch.collect { |ref, i| [ref, track.columns[slots[i].asSymbol][\failed]] }
};
{
	tracks.do { |file| var id = file.basename.splitext[0];
		refs.clump(slots.size).do { |batch|
			var res = { run.(file, batch) }.try { |e|
				batch.collect { |ref| [ref, { run.(file, [ref])[0][1] }.try { |e1| e1.errorString }] } };
			res.do { |r| r[1] !? { |err| "ERROR % % | %".format(id, r[0], firstLine.(err).replace("ERROR: ", "")).postln } } };
		"DONE %".format(id).postln };
	0.exit
}.forkIfNeeded;
)
