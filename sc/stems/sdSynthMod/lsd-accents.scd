// Column code of the lsd accents (017): rare, short, high one-shots on the 16th grid, with their own echo: about one hit in two
// bars (Rate 0) up to two per bar (Rate 1), each a shot and a pitch at random (F minor pentatonic, F6 - A flat 7). Nine
// shots: glass and metal (real FM), chirp, drop, pluck, a laser zap, a bleep run, an acid squelch, a ringing wooden bell; one
// hit in six jumps an octave, the sines drift a little in pitch as they ring. Eight random series. Button 2 (Burst): the
// series twice as fast, half of it, in 32nds. Space scales room (from 0.3) and echo (from 0.3).
(
states: (room: 0.9 * 0.3, echo: 0.3),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.3 + (0.7 * s)), send); col.setState(\echo, 0.3 + (0.5 * s), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, v = col[\patLatch].atBar(b), rate = col.knob(\k3), out = List[], lp;
	var accNotes = [89, 92, 94, 96, 99, 101, 104], adsr = kit[\adsr], syn = kit[\syn];
	var shots = [[\syn, \sine, 3, 3.5, 0, 0, 0.05, 0], [\syn, \sine, 0, 1, 12, 0.03, 0.06, 0], [\syn, \sine, 0, 1, -24, 0.04, 0.07, -12],
		[\syn, \triangle, 0, 1, 0, 0, 0.09, -12], [\syn, \sine, 6, 1.414, 0, 0, 0.03, 0], [\syn, \sawtooth, 0, 1, -36, 0.12, 0.15, -12],
		[\run, \square, 0, 1, 0, 0, 0.03, -12], [\squelch, \square, 0, 1, 0, 0, 0.12, -24], [\bell, \sine, 0, 1, 0, 0, 0.9, -12]];
	var hit = { |u, g, at, len| var rr = { |o| ce.rand(u + (1024 * v) + o) };
		var sh = shots[(rr.(0.11) * shots.size).trunc.asInteger];
		var m = accNotes[(rr.(0.23) * 7).trunc.asInteger] + sh[7] + if(rr.(0.37) < (1 / 6)) { [-12, 12][(rr.(0.41) * 2).trunc.asInteger] } { 0 };
		var args = lp ++ (pan: 0.05 + (0.9 * rr.(0.53)), at: at, hold: len) ++ adsr.(0.001, sh[6], 0, 0.04);
		if(sh[2] > 0) { args = args ++ (fmi: sh[2], fmh: sh[3]) };
		args = args ++ if(sh[4] != 0) { (penv: sh[4], pd: sh[5], ps: 0.001) } { (penv: 0.6 * (rr.(0.67) - 0.5), pd: 0.3, ps: 0.001) };
		switch(sh[0],
			\run, { 3.collect { |i| syn.(sh[1], m + [0, 7, 12][i], g * 0.7, args ++ (at: at + (len * i / 3), hold: len / 3)) } },
			\squelch, { [syn.(sh[1], m, g, args ++ (lo: 300, hi: 300, bright: 0, lpq: 16, lpenv: 5, la: 0.002, ld: 0.09, ls: 0, lr: 0.02))] },
			\bell, { [ce.note(\modalPerc, args ++ (kind: 1, freq: m.midicps, decay: sh[6], glide: 0, hard: 0.9, skin: 0, amp: g,
				thinF: kit[\thin], tag: "bell", g: g, midi: m))] },
			{ [syn.(sh[1], m, g, args)] }) };
	var r0 = ce.rand(t + (1024 * v));
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 5000, hi: 18000, tone: kit[\tone]);
	if(r0 >= (1 - ((4 ** rate) / 32))) { out.addAll(hit.(t, 0.12 + (0.18 * ce.perlin(t / 7)), 0, 1)) };
	if(col.held(\b2)) { 2.do { |j| var u = t + (j / 32);
		if(ce.rand(u) >= 0.5) { out.addAll(hit.(2 * u, 0.2, j / 2, 0.5)) } } };
	out
}
)
