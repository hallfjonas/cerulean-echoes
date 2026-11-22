// Column code of the lsd wood (017): two FM wood blocks, a wooden log (modal, an octave under the low block) and a triangle
// mallet, swung by Bounce (Rave, Spin = the high block every third 16th, three against four, Tumble = Rave with flams and a
// mallet line over 8 bars). Each hit a little uneven. Button 2: a roll of 32nds; Tension's roll builds the drop, also in the
// Break. The low-pass is Brightness (4000 ... 16000 Hz) x Fog only. Plays in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var out = List[], v = col[\patLatch].atBar(b), c = col.knob(\k3), lp, r, tn, adsr = kit[\adsr], bpm = tr.bpm;
	var block = { |m, g, pan, at = 0, len = 1, vel = 1| kit[\syn].(\sine, m, (g * 1.4) * vel, lp ++ (fmi: 1.2, fmh: 3.47,
		modPhase: kit[\modPhase].(k, at, m.midicps * 3.47, bpm), pan: pan, at: at, hold: len) ++ adsr.(0.001, 0.045, 0, 0.03)) };
	var mallet = { |m, g, pan, at = 0, vel = 1| kit[\syn].(\triangle, m, (g * 1.4) * vel, lp ++ (pan: pan, at: at, hold: 1) ++ adsr.(0.002, 0.11, 0, 0.06)) };
	var log = { |m, g, pan, at = 0, vel = 1| ce.note(\modalPerc, lp ++ (kind: 1, freq: m.midicps, decay: 0.11, glide: 0, hard: 0.75,
		skin: 0, amp: g * vel, pan: pan, at: at, hold: 1, thinF: kit[\thin], tag: "log", g: g * vel, midi: m)) };
	var vels = [1, 0.62, 0.85, 0.7];
	var hits = { |str| str.split($ ).reject(_.isEmpty).collect(_ == "x") };
	st[\woods] = st[\woods] ?? { var lines = { |l| l.collect { |x| [x[0], if(x[1].isString) { var h = hits.(x[1]); { |k| h[k % 16] } } { x[1] }] ++ x[2..] } };
		[
			[[\block, "~ x ~ x ~ x x ~ ~ x ~ x x ~ x x", [79], 0.34, 0.3], [\block, "~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ x ~ ~", [72], 0.45, 0.22],
				[\log, "~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ x ~ ~", [60], 0.3, 0.4], [\mallet, "~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~", [65, 72, 68, 72], 0.33, 0.38]],
			[[\block, { |k| k % 3 == 1 }, [79, 79, 80, 79], 0.32, 0.3], [\block, "~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ x ~ ~", [72], 0.45, 0.22],
				[\log, "~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ x ~ ~", [60], 0.3, 0.4],
				[\mallet, "~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~", [65, 72, 68, 72, 65, 75, 72, 68], 0.33, 0.38]],
			[[\block, "~ x ~ x ~ x x ~ ~ x ~ x x ~ x x", [79], 0.34, 0.3], [\block, "~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~", [79], 0.16, 0.34, 0.5],
				[\block, "~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~ x", [72], 0.45, 0.22], [\log, "~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~ x", [60], 0.3, 0.4],
				[\mallet, "~ ~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~", [65, 72, 68, 72, 65, 72, 75, 77], 0.3, 0.62]],
		].collect(lines) };
	st[\rise] = st[\rise] ?? { kit[\heldRamp].(col, 2) };
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 4000, hi: 16000, tone: kit[\fog]);
	st[\woods][v].do { |x| if(x[1].(k)) {
		var at = (x[5] ? 0) + if(k.odd) { 0.1 + (0.4 * c) } { 0 }, m = x[2][b % x[2].size];
		var vel = vels[s16 % 4] * (0.9 + (0.2 * ce.rand(t + (0.37 * x[2][0]))));
		out.add(switch(x[0], \block, { block.(m, x[3], x[4], at, 1, vel) }, \log, { log.(m, x[3], x[4], at, vel) },
			{ mallet.(m, x[3], x[4], at, vel) })) } };
	r = st[\rise].(t);
	r !? { 2.do { |j| if(ce.rand((k + (j / 2)) / 16) >= (0.85 - (0.75 * r))) {
		out.add(block.([72, 79][b % 2], 0.12 + (0.3 * r), 0.3, j / 2, 0.5)) } } };
	tn = kit[\ramp].(ce.val(tr.global.tension), 0.8, 1);
	if(tn > 0 and: { ce.rand(t) >= (0.8 * ((1 - tn) ** 1.5)) }) { out.add(block.(72, 0.05 + (0.4 * tn * tn), 0.25)) };
	out
}
)
