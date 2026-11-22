// Column code of the techno dark percussion (008): FM claves (c7 c7 g6 c7 in every beat), a white-noise shaker on every
// 16th, eight clave figures. Complexity (row 3) adds metal ticks in the gaps, falling zaps, and at the top an event may
// play twice in its own time. Button 2: a roll of scattered 32nds (shaker + metal) that fills in and gets louder over 2 bars.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], bpm = tr.bpm, b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var v = col[\patLatch].atBar(b), dn = col.knob(\k3), r = ce.rand(t), rr, x, adsr = kit[\adsr], ramp = kit[\ramp];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 5000, hi: 18000, tone: kit[\tone]), evs = List[], out = List[];
	var fmNote = { |m, fmi, fmh, g, at, len, args| kit[\syn].(\sine, m, g, lp ++ (fmi: fmi, fmh: fmh, at: at, hold: len,
		modPhase: kit[\modPhase].(k, at, m.midicps * fmh, bpm)) ++ args) };
	var noise = { |color, g, hp, at, len, env, args| ce.note(\sdNoise, (color: color, amp: g, hold: len, at: at, hp: hp, thinF: kit[\thin],
		tag: ["pink", "white"][color], g: g) ++ lp ++ env ++ (args ? ())) };
	st[\rhythms] = st[\rhythms] ?? { ["x ~ ~ x ~ ~ x ~ ~ x ~ ~ x ~ x ~", "~ ~ x ~ ~ x ~ ~ x ~ ~ ~ x ~ ~ ~", "x ~ x ~ ~ ~ x ~ x ~ ~ ~ x ~ ~ ~",
		"~ x ~ ~ x ~ ~ x ~ ~ x ~ ~ x ~ ~", "x ~ ~ ~ ~ x ~ ~ ~ ~ x ~ ~ ~ x ~", "~ ~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~",
		"x ~ ~ x ~ ~ ~ x ~ ~ x ~ ~ ~ x ~", "~ x ~ x ~ ~ x ~ ~ x ~ x ~ ~ x ~"].collect { |x| x.split($ ).collect(_ == "x") } };
	if(col.held(\b2)) { st[\rollStart] = st[\rollStart] ? t.floor } { st[\rollStart] = nil };
	if(st[\rhythms][v][s16]) { evs.add(fmNote.([96, 96, 91, 96][s16 % 4], 0.4, 1, 0.32, 0, 1, adsr.(0.001, 0.035, 0, 0.02) ++ (pan: 0.7))) };
	evs.add(noise.(1, [0.16, 0.09, 0.13, 0.09][s16 % 4], 7000, 0, 1, adsr.(0.008, 0.035, 0, 0.02), (pan: 0.3)));
	if(dn > 0 and: { st[\rhythms][v][s16].not } and: { r > (1 - (0.7 * ramp.(dn, 0, 0.4))) }) {
		evs.add(fmNote.(77, 5, 1.414, 0.16, 0, 1, adsr.(0.001, 0.04, 0, 0.03) ++ (pan: 0.3 + (0.4 * ce.perlin(t / 2))))) };
	if(dn > 0.4 and: { r > (1 - (0.3 * ramp.(dn, 0.4, 0.75))) }) {
		evs.add(kit[\syn].(\sine, 72, 0.2, lp ++ (hold: 1, penv: -24, pd: 0.05, pan: 0.25 + (0.5 * r)) ++ adsr.(0.001, 0.06, 0, 0.03))) };
	if(st[\rollStart].notNil) {
		rr = ((t.floor - st[\rollStart]) / 2).clip(0, 1);
		2.do { |j| var u = t + (j / 32), vel = 0.4 + (0.6 * rr);
			if(ce.rand(u) > (0.85 - (0.75 * rr))) {
				evs.add(noise.(1, 0.14 * vel, 6000, j / 2, 0.5, adsr.(0.004, 0.025, 0, 0.015)));
				evs.add(fmNote.(77, 5, 1.414, 0.1 * vel, j / 2, 0.5, adsr.(0.001, 0.04, 0, 0.03) ++ (pan: 0.3 + (0.4 * ce.perlin(u / 2)))));
			} }
	};
	x = ramp.(dn, 0.75, 1) * 0.35;
	evs.do { |e|
		var at = e[\at] ? 0, ru = ce.rand(t + (at / 16)), len = e[\hold];
		case
		{ ru < x } { [0, len / 2].do { |o| var e2 = e.copy; e2[\at] = at + o; e2[\hold] = len / 2;
			e2[\modPhase] !? { if(ce.webaudioPhase == true) { e2[\modPhase] = kit[\modPhase].(k, at + o, e2[\freq] * e2[\fmh], bpm) } };
			out.add(e2) } }
		{ ru > x } { out.add(e) }
	};
	out
}
)
