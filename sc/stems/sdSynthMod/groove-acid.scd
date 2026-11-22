// Column code of the groove acid (001, 002): a 303-style line in 16ths on the chord root and the mood's scale: a resonant
// saw, accents open the filter, no slides. Brightness sets the filter, Resonance the squeal; button 2 opens it. Plays in
// the Break.
(
strip: (space: \k2, echo: 0.25),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, out = List[], adsr = kit[\adsr];
	var vels = [1, 0.55, 0.8, 0.55];
	st[\lines] = st[\lines] ?? { ["0 0 7 0 ~ 0 2 0 0 ~ 7 0 4 ~ 0 2", "0 ~ ~ 0 ~ ~ 7 ~ ~ 0 ~ ~ 2 ~ 0 ~",
		"<[0 0 7 0 2 0 3 0 0 ~ 7 0 4 0 3 2] [0 0 7 0 2 0 3 0 7 ~ 8 7 4 3 2 1]>"].collect(kit[\table]) };
	kit[\eventsAt].(st[\lines][col[\patLatch].atBar(b)], k).do { |e|
		var m = fr.degMidi(e[2] + fr.rootAt(tr, b), 2, tr.chapterAt(b)), q = col.knob(\k3);
		var f = if(col.held(\b2)) { 3 } { 1 } * (0.7 + (0.7 * ce.sine(b / 8)));
		out.add(kit[\syn].(\sawtooth, m, 0.32 * vels[k % 4], (lpOn: 1, bright: col.knob(\k1), lo: 250 * f, hi: 3000 * f,
			tone: kit[\tone], lpq: 6 + (16 * q), lpenv: 2 + (3 * q), la: 0.002, ld: 0.12, ls: 0, lr: 0.01, shape: 0.3, hp: 140,
			at: e[0], hold: e[1]) ++ adsr.(0.002, 0.16, 0.2, 0.04)))
	};
	out
}
)
