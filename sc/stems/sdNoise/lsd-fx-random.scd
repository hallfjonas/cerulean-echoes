// Column code of the lsd FX risers (017-lsd-fx-2; lsd-fx-more.scd with a random choice first): the phrase: a swirling
// riser in its last bar (pink noise through a climbing band-pass and a narrow ringing band falling against it), a tail
// on its first bar. Button 1: every 16 bars one of the eight phrases below at random, then the eight in turn: 8, 16 or
// 4 bars with a tail picked anew each phrase (noise + boom, a laser fall + boom, a ringing wooden bell over falling
// noise), 8 bars with one fixed tail, 8 bars with a dive (a saw and a sine falling three octaves over 2 bars), 16 bars
// taking the four tails in turn. Complexity (row 3) adds a rising saw (from 0), a small riser in the middle (from 0.5)
// and a dub siren in the last half (from 0.75); button 2 is a riser by hand (4 bars). Space scales room (from 0.4) and
// echo (from 0.2).
(
// [phrase length in bars, tail (nil: picked anew, \turn: the four in turn)]
var phrases = [[8, nil], [16, nil], [4, nil], [8, 0], [8, 1], [8, 2], [8, 3], [16, \turn]];
(
states: (room: 0.9 * 0.4, echo: 0.2),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.4 + (0.6 * s)), send); col.setState(\echo, 0.2 + (0.6 * s), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, s16 = k % 16, x = s16 / 16, v = col[\patLatch].atBar(b), ph = phrases[if(v > 0) { v - 1 } {
		(ce.rand((b / 16).floor + 0.59) * phrases.size).trunc.asInteger }], len = ph[0];
	var c = col.knob(\k3), lp = (lpOn: 1, bright: col.knob(\k1), lo: 2000, hi: 16000, tone: kit[\tone]), out = List[], r, pos = b % len;
	var tail = switch(ph[1], nil, { (ce.rand((b - pos) + 0.77) * 3).trunc.asInteger }, \turn, { ((b / len).floor % 4).asInteger }, { ph[1] }), adsr = kit[\adsr], syn = kit[\syn], noise = kit[\noise], ramp = kit[\ramp];
	var riser = { |p, g| [noise.(0, g * (0.1 + (0.9 * p * p)), lp ++ (hold: 1, bp: 300 * (25 ** p), bpq: 1.5,
			pan: 0.5 + ((0.2 + (0.25 * p)) * sin(2pi * t * (2 + (6 * p))))) ++ adsr.(0.03, nil, 1, 0.12)),
		noise.(0, g * 0.5 * p, lp ++ (hold: 1, bp: 6000 * ((1 / 12) ** p), bpq: 7, pan: 0.5 - (0.3 * sin(2pi * t * 3))) ++ adsr.(0.03, nil, 1, 0.12))] };
	st[\rise] = st[\rise] ?? { kit[\heldRamp].(col, 4) };
	if(pos == (len - 1)) {
		out.addAll(riser.(x, 1));
		if(c > 0) { out.add(syn.(\sawtooth, 53 + (12 * x), ramp.(c, 0, 0.5) * 0.06, lp ++ (hold: 1) ++ adsr.(0.01, nil, 1, 0.05))) };
	};
	if(pos == 0) {
		switch(tail,
			0, { out.add(noise.(0, 0.6 * ((1 - x) ** 2), lp ++ (hold: 1, bp: 6000 * ((1 / 20) ** x), bpq: 1) ++ adsr.(0.005, nil, 1, 0.2)));
				if(s16 == 0) { out.add(syn.(\sine, 41, 0.45, lp ++ (hold: 16, penv: 12, pd: 0.25) ++ adsr.(0.005, 1.2, 0, 0.3))) } },
			1, { if(s16 == 0) { out.add(syn.(\sawtooth, 41, 0.14, lp ++ (hold: 8, penv: 36, pd: 1.4, ps: 0.001, lpq: 14, lo: 900, hi: 900,
					bright: 0) ++ adsr.(0.002, 1.6, 0, 0.3)));
				out.add(syn.(\sine, 41, 0.45, lp ++ (hold: 16, penv: 12, pd: 0.25) ++ adsr.(0.005, 1.2, 0, 0.3))) } },
			2, { out.add(noise.(0, 0.35 * ((1 - x) ** 2), lp ++ (hold: 1, bp: 4000 * ((1 / 10) ** x), bpq: 2) ++ adsr.(0.005, nil, 1, 0.2)));
				if([0, 6].includes(s16)) { [65, 72].do { |m, i| out.add(ce.note(\modalPerc, lp ++ (kind: 1, freq: (m + (12 * (s16 / 6))).midicps,
					decay: 1.8, glide: 0, hard: 0.8, skin: 0, amp: 0.5 - (0.15 * i), pan: 0.3 + (0.4 * i), hold: 1, thinF: kit[\thin],
					tag: "bell", g: 0.5 - (0.15 * i), midi: m))) } } },
			3, { if(s16 == 0) { [[\sawtooth, 53, 0.12], [\sine, 41, 0.4]].do { |w| out.add(syn.(w[0], w[1], w[2], lp ++ (hold: 32, penv: 36,
					pd: 3.2, ps: 0.001, lpq: 4) ++ adsr.(0.005, 3.4, 0, 0.4))) } };
				out.add(noise.(0, 0.25 * ((1 - (t % 1)) ** 2), lp ++ (hold: 1, bp: 3000 * ((1 / 10) ** x), bpq: 1.5) ++ adsr.(0.005, nil, 1, 0.2))) });
	};
	if(pos == ((len / 2) - 1) and: { c > 0.5 }) { var g = 0.5 * ramp.(c, 0.5, 1);
		out.addAll(riser.(x, 1).collect { |n| n ++ (amp: n.amp * g, g: n.g * g) }) };
	if(c > 0.75 and: { pos >= (len / 2) } and: { (s16 % 8) == 0 } and: { ce.rand(b + 0.19) < 0.5 }) {
		out.add(syn.(\sine, 77 + (5 * (s16 / 8)), 0.12 * ramp.(c, 0.75, 1), lp ++ (hold: 7, vib: 5.5, vibmod: 0.6, penv: -5, pd: 0.5,
			ps: 0.001, pan: 0.3 + (0.4 * (s16 / 8))) ++ adsr.(0.05, nil, 1, 0.4))) };
	r = st[\rise].(t);
	r !? { out.addAll(riser.(r, 1.2)) };
	out.reject { |n| n.amp <= 0 }
}
)
)
