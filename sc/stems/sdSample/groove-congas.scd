// Column code of the groove percussion of 002: a conga low and bongos high and low (TR-727) on three patterns (Congas,
// + Cowbell, + Shaker); everything pans slowly. Complexity (row 3) adds quiet ghost bongos; button 2 plays an 80s synth-tom
// run (a sine dropping in pitch). Plays in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, s16 = k % 16, v = col[\patLatch].atBar(b);
	var c = col.knob(\k3), out = List[], adsr = kit[\adsr], syn = kit[\syn], smp = kit[\smp], noise = kit[\noise], eventsAt = kit[\eventsAt];
	var lp = { |e| (lpOn: 1, bright: col.knob(\k1), lo: 1200, hi: 9000, tone: kit[\fog], at: e[0],
		pan: 0.3 + (0.4 * ce.sine((k + e[0]) / 16 / 11))) };
	var conga = { |e, n, g| out.add(smp.("tr727/perc-0" ++ n ++ ".wav", "RolandTR727_perc:" ++ n, g, lp.(e))) };
	var tom = { |e| var m = kit[\name2midi].(e[2]);
		out.add(syn.(\sine, m, 0.5, lp.(e) ++ (hold: e[1], penv: 7, pd: 0.12) ++ adsr.(0.001, 0.28, 0, 0.05)));
		out.add(noise.(1, 0.07, lp.(e) ++ (hold: e[1], bp: 1800, midi: m) ++ adsr.(0.001, 0.02, 0, nil))) };
	st[\congas] = st[\congas] ?? { [["~ ~ ~ x ~ ~ x ~ ~ ~ ~ x ~ x ~ ~", 4, 0.5], ["~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x", 2, 0.4],
		["<[~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~] [~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~]>", 3, 0.4]].collect { |x| [kit[\table].(x[0]), x[1], x[2]] } };
	st[\cow] = st[\cow] ?? { kit[\table].("~ ~ x ~ ~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~") };
	st[\shaker] = st[\shaker] ?? { kit[\table].("x*16") };
	st[\ghosts] = st[\ghosts] ?? { kit[\table].("~ ~ x ~ ~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~") };
	st[\fill] = st[\fill] ?? { kit[\table].("d3 ~ c3 ~ a2 ~ g2 ~ f2 ~ d2 ~ d2 ~ ~ ~") };
	st[\congas].do { |x| eventsAt.(x[0], k).do { |e| conga.(e, x[1], x[2]) } };
	if(v == 1) { eventsAt.(st[\cow], k).do { |e| out.add(smp.("tr808/cb-00.wav", "rolandtr808_cb", 0.3, lp.(e) ++ adsr.(nil, 0.25, 0, nil))) } };
	if(v == 2) { eventsAt.(st[\shaker], k).do { |e| out.add(smp.("tr727/sh-00.wav", "RolandTR727_sh:0", [0.25, 0.12, 0.18, 0.12][s16 % 4], lp.(e))) } };
	if(c > 0) { eventsAt.(st[\ghosts], k).do { |e| conga.(e, 2, c * 0.22) } };
	if(col.held(\b2)) { eventsAt.(st[\fill], k).do(tom) };
	out
}
)
