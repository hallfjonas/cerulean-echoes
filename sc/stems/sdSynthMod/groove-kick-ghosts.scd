// Column code of the groove kick of 002: a 909 kick with a sine body on D, three rhythms, Master drives it. Ghosts (row 3):
// soft sine thumps without the 909 click on syncopated 16ths that change every bar; the first half of the knob brings in
// one layer, the second half a busier one. Out in the Break and while button 2 (Hold) is held.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, out = List[], c = col.knob(\k3);
	var adsr = kit[\adsr], syn = kit[\syn], smp = kit[\smp], dB = kit[\dB], ramp = kit[\ramp], eventsAt = kit[\eventsAt];
	var ghost = { |e, g| out.add(syn.(\sine, 38, g, (lpOn: 1, bright: col.knob(\k1), lo: 600, hi: 9000, tone: kit[\tone],
		penv: 8, pd: 0.03, at: e[0], hold: e[1]) ++ adsr.(0.004, 0.11, 0, 0.03))) };
	st[\kicks] = st[\kicks] ?? { ["x*4", "<x*4 [x x x [x ~ ~ x]]>", "x ~ x ~"].collect(kit[\table]) };
	st[\ghosts] = st[\ghosts] ?? { ["<[~ ~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~] [~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ x ~ ~ ~ ~]>",
		"<[~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ x ~] [~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x]>"].collect(kit[\table]) };
	if(col[\track].breakAt(b).not and: { col.held(\b2).not }) {
		eventsAt.(st[\kicks][col[\patLatch].atBar(b)], k).do { |e|
			var w = ce.val(ce.stemGlobal.master), gw = 0.9 * dB.(1.5 * w);
			var lp = (lpOn: 1, bright: col.knob(\k1), lo: 600, hi: 9000, tone: kit[\tone], shape: 0.2 * w, at: e[0], hold: e[1]);
			out.add(smp.("tr909/bd-01.wav", "RolandTR909_bd:0", 0.6 * gw, lp ++ (hold: -1) ++ adsr.(nil, 0.5, 0, nil), \sdSampleMod));
			out.add(syn.(\sine, 38, 0.65 * gw, lp ++ (penv: 14 + (6 * w), pd: 0.05)
				++ adsr.(0.002, 0.28 * (1 + (0.4 * w)), 0, 0.05)))
		};
		if(c > 0) { eventsAt.(st[\ghosts][0], k).do { |e| ghost.(e, ramp.(c, 0, 0.5) * 0.4) } };
		if(c > 0.5) { eventsAt.(st[\ghosts][1], k).do { |e| ghost.(e, ramp.(c, 0.5, 1) * 0.32) } };
	};
	out
}
)
