// Column code of the groove FX (001, 002): the phrase (button 1: 8, 16 or 4 bars): a pink-noise riser in its last bar, a
// falling tail and a low boom on D after it. Complexity (row 3) adds a rising saw in the last bar (from 0) and a small
// riser in the middle of the phrase (from 0.5); button 2 is a riser by hand (4 bars). Space scales the room from 0.3.
(
states: (room: 0.9 * 0.3),
strip: (roomR: \room),
update: { |col, send| col.setState(\room, 0.9 * (0.3 + (0.7 * col.knob(\k2))), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var x = s16 / 16, len = [8, 16, 4][col[\patLatch].atBar(b)], c = col.knob(\k3), adsr = kit[\adsr], noise = kit[\noise];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 2000, hi: 16000, tone: kit[\tone]), out = List[], r;
	var riser = { |pos, g| noise.(0, g * (0.1 + (0.9 * pos * pos)), lp ++ (hold: 1, bp: 300 * (25 ** pos), bpq: 1.5,
		pan: 0.3 + (0.4 * ce.sine(2 * t))) ++ adsr.(0.03, nil, 1, 0.12)) };
	st[\rise] = st[\rise] ?? { kit[\heldRamp].(col, 4) };
	if((b % len) == (len - 1)) {
		out.add(riser.(x, 1));
		if(c > 0) { out.add(kit[\syn].(\sawtooth, 50 + (12 * x), kit[\ramp].(c, 0, 0.5) * 0.06, lp ++ (hold: 1) ++ adsr.(0.01, nil, 1, 0.05))) };
	};
	if((b % len) == 0) {
		out.add(noise.(0, 0.6 * ((1 - x) ** 2), lp ++ (hold: 1, bp: 6000 * ((1 / 20) ** x), bpq: 1) ++ adsr.(0.005, nil, 1, 0.2)));
		if(s16 == 0) { out.add(kit[\syn].(\sine, 38, 0.45, lp ++ (hold: 16, penv: 12, pd: 0.25) ++ adsr.(0.005, 1.2, 0, 0.3))) };
	};
	if((b % len) == ((len / 2) - 1) and: { c > 0.5 }) { out.add(riser.(x, 0.5) ++ (amp: 0.5 * (0.1 + (0.9 * x * x)) * kit[\ramp].(c, 0.5, 1))
		++ (g: 0.5 * (0.1 + (0.9 * x * x)) * kit[\ramp].(c, 0.5, 1))) };
	r = st[\rise].(t);
	r !? { out.add(riser.(r, 1.2)) };
	out.reject { |n| n.amp <= 0 }
}
)
