// Column code of the groove snare of 002: as groove-snare.scd, Tension's roll a little quieter (0.4).
(
states: (room: 0.9 * 0.15),
strip: (roomR: \room),
update: { |col, send| col.setState(\room, 0.9 * (0.15 + (0.7 * col.knob(\k2))), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16;
	var adsr = kit[\adsr], syn = kit[\syn], smp = kit[\smp], noise = kit[\noise], eventsAt = kit[\eventsAt];
	var v = col[\patLatch].atBar(b), out = List[], r, tr;
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 1500, hi: 12000, tone: kit[\fog]);
	var gate = 0.2 + (0.45 * col.knob(\k3));
	var roll = { |amount, g| if(ce.rand(t) >= (0.85 - (0.75 * amount))) {
		out.add(smp.("tr909/sd-00.wav", "RolandTR909_sd:0", g * (0.15 + (0.85 * amount * amount)), lp ++ adsr.(nil, 0.12, 0, nil))) } };
	st[\gated] = st[\gated] ?? { kit[\table].("~ x ~ x") };
	st[\clap] = st[\clap] ?? { kit[\table].("~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ x") };
	st[\rise] = st[\rise] ?? { kit[\heldRamp].(col, 2) };
	if(v < 2) { eventsAt.(st[\gated], k).do { |e|
		out.add(smp.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.8, lp ++ (at: e[0]) ++ adsr.(nil, 0.3, 0, nil)));
		out.add(noise.(1, 0.3, lp ++ (at: e[0], hold: e[1] * gate, hp: 900, bp: 3500, bpq: 0.6) ++ adsr.(0.002, 0.06, 0.4, 0.006)));
		out.add(syn.(\triangle, 50, 0.35, lp ++ (at: e[0], hold: e[1], penv: 5, pd: 0.03) ++ adsr.(nil, 0.09, 0, nil)));
		if(v == 1) { out.add(smp.("tr909/cp-00.wav", "RolandTR909_cp:0", 0.5, lp ++ (at: e[0] + (0.004 * 16), pan: 0.47))) };
	} };
	if(v == 2) { eventsAt.(st[\clap], k).do { |e| out.add(smp.("tr909/cp-00.wav", "RolandTR909_cp:0", 0.75, lp ++ (at: e[0], pan: 0.47))) } };
	r = st[\rise].(t);
	r !? { roll.(r, 0.5) };
	tr = kit[\ramp].(ce.val(col[\track].global.tension), 0.8, 1);
	if(tr > 0) { roll.(tr, 0.4) };
	out
}
)
