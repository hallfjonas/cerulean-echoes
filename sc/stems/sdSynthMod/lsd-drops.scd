// Column code of the lsd-fx drops (017-lsd-fx): water drops (a sine whose pitch jumps up as it starts) scattered across the
// stereo field, close (short room), in the 3rd and 7th bar of every 8-bar phrase, on the mood's scale. Cluster (row 3): up
// to six more drops in 32nds, shared by the figure's hits. Button 1: eight figures (drip, trickle, splash, pair, off-beats,
// falling, rising, a new one each phrase). Button 2 (Underwater): the figure in every bar, two octaves down, longer, muffled
// and wobbling, while held. Space scales room (from 0.15) and echo (from 0.1).
(
// [16th in the bar, degree]
var figs = [
	[[6, 0]],
	[[6, 0], [7, 2], [9, 4]],
	[[12, 0], [12.5, 2], [13, 4], [13.5, 6], [14, 7]],
	[[2, 4], [10, 0]],
	[[2, 0], [6, 2], [14, 4]],
	[[8, 7], [9, 5], [10, 4], [11, 2]],
	[[8, 0], [9, 2], [10, 4], [11, 7]]
];
(
states: (room: 0.9 * 0.15, echo: 0.1),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.15 + (0.55 * s)), send); col.setState(\echo, 0.1 + (0.5 * s), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16;
	var adsr = kit[\adsr], syn = kit[\syn], held = col.held(\b2), out = List[], v = col[\patLatch].atBar(b);
	var fig = if(v < figs.size) { figs[v] } {
		3.collect { |i| var r = { |o| ce.rand(b + (0.1 * i) + o) }; [(r.(0.13) * 15).round, (r.(0.29) * 8).trunc] } };
	var n = (6 * col.knob(\k3) / fig.size).round.asInteger;
	// every drop of the bar: the figure, each hit with its cluster
	var drops = fig.collect { |h, i| [[h[0], h[1], 0]] ++ n.collect { |j| var r = { |o| ce.rand(b + (0.01 * i) + (0.1 * j) + o) };
		[h[0] + (0.5 * (j + 1)), h[1] + (r.(0.41) * 5).trunc - 2, 0.3 + (0.4 * r.(0.47))] } }.flatten(1);
	if(held or: { [2, 6].includes((b % 8).asInteger) }) {
		drops.select { |d| d[0].floor == s16 }.do { |d| var r = ce.rand(k + d[0] + 0.61), g = 0.24 * (1 - d[2]);
			var m = fr.degMidi(d[1], if(held) { 4 } { 6 }, tr.chapterAt(b));
			var a = (lpOn: 1, bright: col.knob(\k1), lo: if(held) { 600 } { 3000 }, hi: if(held) { 2500 } { 14000 }, tone: kit[\tone],
				at: d[0] % 1, pan: 0.08 + (0.84 * r), hold: 1);
			out.add(if(held) {
				syn.(\sine, m, 1.4 * g, a ++ (penv: -5, pd: 0.12, ps: 0.001, vib: 7, vibmod: 0.3) ++ adsr.(0.002, 0.4, 0, 0.1))
			} { syn.(\sine, m, g, a ++ (penv: -9, pd: 0.04, ps: 0.001) ++ adsr.(0.001, 0.09, 0, 0.02)) }) } };
	out
}
)
)
