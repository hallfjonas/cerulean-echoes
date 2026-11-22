// Column code of the groove FX of 002: soft cues, kept clean: the riser stops at 4.5 kHz, the noise is quiet, the default
// phrase is 16 bars (16, 8, 4). Complexity adds a soft rising triangle in the last bar; button 2 is a riser by hand.
(
states: (room: 0.9 * 0.3),
strip: (roomR: \room),
update: { |col, send| col.setState(\room, 0.9 * (0.3 + (0.6 * col.knob(\k2))), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var x = s16 / 16, len = [16, 8, 4][col[\patLatch].atBar(b)], c = col.knob(\k3), adsr = kit[\adsr], noise = kit[\noise];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 2000, hi: 12000, tone: kit[\tone]), out = List[], r;
	var riser = { |pos, g| noise.(0, g * (0.08 + (0.6 * pos * pos)), lp ++ (hold: 1, bp: 300 * (15 ** pos), bpq: 2.5,
		pan: 0.35 + (0.3 * ce.sine(2 * t))) ++ adsr.(0.03, nil, 1, 0.12)) };
	st[\rise] = st[\rise] ?? { kit[\heldRamp].(col, 4) };
	if((b % len) == (len - 1)) {
		out.add(riser.(x, 1));
		if(c > 0 and: { s16.even }) { out.add(kit[\syn].(\triangle, 62 + (12 * x), kit[\ramp].(c, 0, 1) * 0.08, lp ++ (hold: 2) ++ adsr.(0.02, nil, 1, 0.08))) };
	};
	if((b % len) == 0) {
		out.add(noise.(0, 0.35 * ((1 - x) ** 2), lp ++ (hold: 1, bp: 4000 * ((1 / 15) ** x), bpq: 2) ++ adsr.(0.005, nil, 1, 0.2)));
		if(s16 == 0) { out.add(kit[\syn].(\sine, 38, 0.4, lp ++ (hold: 16, penv: 12, pd: 0.25) ++ adsr.(0.005, 1.2, 0, 0.3))) };
	};
	r = st[\rise].(t);
	r !? { out.add(riser.(r, 1)) };
	out.reject { |n| n.amp <= 0 }
}
)
