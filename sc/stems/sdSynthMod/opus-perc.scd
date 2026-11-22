// Column code of the opus percussion (016): the techno percussion (008) with a low sine conga slap (+ a little skin noise)
// on the 7th 8th instead of the rimshot. Plays in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, s16 = k % 16, out = List[];
	var v = col[\patLatch].atBar(b), c = col.knob(\k3), lp, bongo, adsr = kit[\adsr], ramp = kit[\ramp];
	var steps = { |str, len| var l = str.split($ ).reject(_.isEmpty), d = Dictionary[], n = 16 / l.size;
		l.do { |x, i| if(x != "~") { d[(i * n).asInteger] = [x, len ? n] } }; d };
	st[\low] = st[\low] ?? { ["f4 ~ ~ f4 ~ c5 ~ ~", "f4 ~ f4 ~ ~ f4 ~ c5", "f4 ~ ~ f4 ~ ~ f4 ~"].collect { |x| steps.(x) } };
	st[\high] = st[\high] ?? { ["~ c6 ~ f5 ~ ~ c6 ~", "~ f5 ~ ~ c6 ~ f5 ~", "~ ~ c6 ~ ~ ~ ~ f5 ~ ~ c6 ~ ~ ~ f5 ~"].collect { |x| steps.(x) } };
	st[\ghost1] = st[\ghost1] ?? { steps.("~ ~ eb5 ~ ~ ab5 ~ c5") };
	st[\ghost2] = st[\ghost2] ?? { steps.("~ c6 ~ ab5 c6 ~ eb5 ~ c5 ~ ~ eb5 ~ c5 ab5 ~") };
	st[\fill] = st[\fill] ?? { steps.("f5 eb5 c5 ab4 f5 eb5 c5 ab4 c5 ab4 f4 eb4 f4 ~ f4 ~") };
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 700, hi: 5000, tone: kit[\tone], pan: 0.15 + (0.7 * ce.sine(t / 13.3)));
	bongo = { |x, dec, g| kit[\syn].(\sine, kit[\name2midi].(x[0]), g * 1.6, lp ++ (hold: x[1]) ++ adsr.(nil, dec, 0, dec / 2)) };
	st[\low][v][s16] !? { |x| out.add(bongo.(x, 0.085, 0.55)) };
	st[\high][v][s16] !? { |x| out.add(bongo.(x, 0.045, 0.7)) };
	if(s16 == 12) {
		out.add(kit[\syn].(\sine, 68, 0.4 * 1.6, lp ++ (hold: 2, penv: 7, pd: 0.015) ++ adsr.(0.002, 0.07, 0, 0.04)));
		out.add(kit[\noise].(1, 0.05 * 1.6, lp ++ (hold: 2, hp: 2500) ++ adsr.(0.001, 0.015, 0, 0.01)))
	};
	if(c > 0) { st[\ghost1][s16] !? { |x| out.add(bongo.(x, 0.035, ramp.(c, 0, 0.5) * 0.5)) } };
	if(c > 0.5) { st[\ghost2][s16] !? { |x| out.add(bongo.(x, 0.025, ramp.(c, 0.5, 1) * 0.45)) } };
	if(col.held(\b2)) { st[\fill][s16] !? { |x| out.add(bongo.(x, 0.05, 0.6)) } };
	out.reject { |n| n.amp <= 0 }
}
)
