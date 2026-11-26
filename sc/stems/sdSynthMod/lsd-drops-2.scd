// Column code of the lsd-fx drops (017-lsd-fx-2): a few drops off the 16th grid, in the 3rd and 7th bar of every 8-bar
// phrase, on the mood's scale, further away than lsd-drops.scd. Seven figures, each its own voice: cave (low drops that
// jump up as they start), glass (an FM sine ringing and sinking), bell (a wooden bell beating against its double),
// swell (a drop that grows in, as if played backwards), spark (an FM metal flicker), drift (one drop falling out of
// tune and travelling left to right), well (a deep falling bloop with a faint high ghost). Cluster (row 3): up to six
// more of the voice in 32nds around the figure. Button 1: one figure at random each phrase, then the seven in turn.
// Button 2 (Deep): the figure in every bar as a low, muffled, wobbling sine, while held. Space scales room (from 0.3)
// and echo (from 0.2).
(
// [16th in the bar, degree, voice, octave, level, pan (nil: random), detune in semitones]
var figs = [
	[[5.3, 0, \cave, 5, 1], [8.05, 4, \cave, 5, 0.5], [13.6, 2, \cave, 4, 0.7]],
	[[2.5, 4, \glass, 6, 0.8], [9.25, 0, \glass, 6, 0.6]],
	[[4, 0, \bell, 4, 1], [10.5, 1, \bell, 5, 0.5]],
	[[1, 4, \swell, 5, 1], [9, 0, \swell, 5, 0.7]],
	[[3.75, 7, \spark, 5, 1], [3.875, 9, \spark, 5, 0.6], [11.4, 5, \spark, 5, 0.8]],
	[[6.2, 0, \drift, 5, 1, 0.2, 0], [9.7, 0, \drift, 5, 0.6, 0.5, -0.35], [13.2, 0, \drift, 5, 0.35, 0.8, -0.7]],
	[[1, 0, \well, 3, 1]]
];
(
states: (room: 0.9 * 0.3, echo: 0.2),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.3 + (0.5 * s)), send); col.setState(\echo, 0.2 + (0.45 * s), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16;
	var adsr = kit[\adsr], syn = kit[\syn], held = col.held(\b2), out = List[], v = col[\patLatch].atBar(b);
	var fig = figs[if(v > 0) { v - 1 } { (ce.rand((b / 8).floor + 0.13) * figs.size).trunc.asInteger }];
	var n = (6 * col.knob(\k3) / fig.size).round.asInteger;
	// every drop of the bar: the figure, each hit with its cluster
	var drops = fig.collect { |h, i| [h] ++ n.collect { |j| var r = { |o| ce.rand(b + (0.01 * i) + (0.1 * j) + o) };
		[h[0] + (0.5 * (j + 1)), h[1] + (r.(0.41) * 5).trunc - 2, h[2], h[3], h[4] * (0.3 + (0.4 * r.(0.47))), nil, h[6] ? 0] } }.flatten(1);
	var voice = { |d, m, g, a| switch(d[2],
		\cave, { [syn.(\sine, m, g, a ++ (penv: -12, pd: 0.06, ps: 0.001) ++ adsr.(0.001, 0.22, 0, 0.03))] },
		\glass, { [syn.(\sine, m, 1.4 * g, a ++ (hold: 5, lo: 5000, fmi: 3, fmh: 3.5, penv: -0.4, pd: 0.6, ps: 0.001) ++ adsr.(0.001, 0.5, 0, 0.1))] },
		\bell, { [0, 0.12].collect { |dt, i| var gg = 0.7 * g * [1, 0.6][i], mm = m + dt;
			ce.note(\modalPerc, a ++ (kind: 1, freq: mm.midicps, decay: 1.6, glide: 0, hard: 0.6, skin: 0, amp: gg,
				pan: (a[\pan] + [0, 0.3][i]).fold(0, 1), thinF: kit[\thin], tag: "bell", g: gg, midi: mm)) } },
		\swell, { [syn.(\sine, m, g, a ++ (hold: 3, penv: -3, pd: 0.3, ps: 0.001) ++ adsr.(0.28, 0.02, 0, 0.02))] },
		\spark, { [syn.(\sine, m, 2 * g, a ++ (lo: 5000, fmi: 6, fmh: 1.414) ++ adsr.(0.001, 0.04, 0, 0.03))] },
		\drift, { [syn.(\sine, m, g, a ++ (hold: 3, penv: 0.7, pd: 0.6, ps: 0.001) ++ adsr.(0.001, 0.3, 0, 0.05))] },
		\well, { [syn.(\sine, m, 0.7 * g, a ++ (hold: 6, penv: 12, pd: 0.15, ps: 0.001, lo: 400, hi: 3000) ++ adsr.(0.001, 0.6, 0, 0.1)),
			syn.(\sine, m + 48, 0.12 * g, a ++ (hold: 6, fmi: 1, fmh: 2, pan: 1 - a[\pan]) ++ adsr.(0.05, 0.9, 0, 0.2))] }) };
	if(held or: { [2, 6].includes((b % 8).asInteger) }) {
		drops.select { |d| d[0].floor == s16 }.do { |d| var r = ce.rand(k + d[0] + 0.61), g = 0.24 * d[4];
			var a = (lpOn: 1, bright: col.knob(\k1), lo: if(held) { 600 } { 2500 }, hi: if(held) { 2500 } { 14000 }, tone: kit[\tone],
				at: d[0] % 1, pan: d[5] ?? { 0.08 + (0.84 * r) }, hold: 1);
			if(held) {
				out.add(syn.(\sine, fr.degMidi(d[1], 4, tr.chapterAt(b)), 0.9 * g,
					a ++ (penv: -5, pd: 0.12, ps: 0.001, vib: 7, vibmod: 0.3) ++ adsr.(0.002, 0.4, 0, 0.1)))
			} { out.addAll(voice.(d, fr.degMidi(d[1], d[3], tr.chapterAt(b)) + (d[6] ? 0), g, a)) } } };
	out
}
)
)
