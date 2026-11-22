// Column code of the groove acid of 002: as groove-acid.scd, a calmer filter (250 ... 2200 Hz, x 2 while Open is held, a slow
// 0.85 ... 1.15 sine), less resonance, no drive.
(
strip: (space: \k2, echo: 0.2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, out = List[], adsr = kit[\adsr];
	var vels = [1, 0.55, 0.8, 0.55];
	st[\lines] = st[\lines] ?? { ["0 0 7 0 ~ 0 2 0 0 ~ 7 0 4 ~ 0 2", "0 ~ ~ 0 ~ ~ 7 ~ ~ 0 ~ ~ 2 ~ 0 ~",
		"<[0 0 7 0 2 0 3 0 0 ~ 7 0 4 0 3 2] [0 0 7 0 2 0 3 0 7 ~ 8 7 4 3 2 1]>"].collect(kit[\table]) };
	kit[\eventsAt].(st[\lines][col[\patLatch].atBar(b)], k).do { |e|
		var m = fr.degMidi(e[2] + fr.rootAt(tr, b), 2, tr.chapterAt(b)), q = col.knob(\k3);
		var f = if(col.held(\b2)) { 2 } { 1 } * (0.85 + (0.3 * ce.sine(b / 8)));
		out.add(kit[\syn].(\sawtooth, m, 0.32 * vels[k % 4], (lpOn: 1, bright: col.knob(\k1), lo: 250 * f, hi: 2200 * f,
			tone: kit[\tone], lpq: 4 + (7 * q), lpenv: 1.5 + (2 * q), la: 0.002, ld: 0.1, ls: 0, lr: 0.01, hp: 140,
			at: e[0], hold: e[1]) ++ adsr.(0.002, 0.14, 0.15, 0.04)))
	};
	out
}
)
