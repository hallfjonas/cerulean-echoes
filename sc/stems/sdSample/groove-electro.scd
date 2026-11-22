// Column code of the groove electro (001, 002): 808 cowbell and Simmons-style synth toms (a sine dropping 7 semitones, a
// click of band-passed white noise); Cowbell, Toms or Both. Row 3 brings in the 909 rim; button 2 plays a tom fill.
// Plays in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor;
	var adsr = kit[\adsr], syn = kit[\syn], smp = kit[\smp], noise = kit[\noise], eventsAt = kit[\eventsAt], table = kit[\table];
	var v = col[\patLatch].atBar(b), c = col.knob(\k3), out = List[];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 1200, hi: 10000, tone: kit[\fog]);
	var cowbell = { |e| out.add(smp.("tr808/cb-00.wav", "rolandtr808_cb", 0.45, lp ++ (at: e[0], pan: 0.62) ++ adsr.(nil, 0.25, 0, nil))) };
	var tom = { |e, g| var m = kit[\name2midi].(e[2]);
		out.add(syn.(\sine, m, g, lp ++ (at: e[0], hold: e[1], penv: 7, pd: 0.12, pan: 0.38) ++ adsr.(0.001, 0.28, 0, 0.05)));
		out.add(noise.(1, g * 0.15, lp ++ (at: e[0], hold: e[1], bp: 1800, pan: 0.38, midi: m) ++ adsr.(0.001, 0.02, 0, nil))) };
	st[\cow] = st[\cow] ?? { table.("~ ~ x ~ ~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~") };
	st[\tomsA] = st[\tomsA] ?? { table.("<[~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~] [~ ~ ~ ~ ~ ~ ~ ~ ~ ~ d3 ~ a2 ~ f2 ~]>") };
	st[\tomsB] = st[\tomsB] ?? { table.("<[~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~] [~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ d3 a2 ~ f2]>") };
	st[\rims] = st[\rims] ?? { table.("~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~") };
	st[\fill] = st[\fill] ?? { table.("d3 ~ c3 ~ a2 ~ g2 ~ f2 ~ d2 ~ d2 ~ ~ ~") };
	if(v != 1) { eventsAt.(st[\cow], k).do(cowbell) };
	if(v == 1) { eventsAt.(st[\tomsA], k).do { |e| tom.(e, 0.5) } };
	if(v == 2) { eventsAt.(st[\tomsB], k).do { |e| tom.(e, 0.45) } };
	if(c > 0) { eventsAt.(st[\rims], k).do { |e| out.add(smp.("tr909/rim-00.wav", "RolandTR909_rim:0", c * 0.35, lp ++ (at: e[0], pan: 0.55))) } };
	if(col.held(\b2)) { eventsAt.(st[\fill], k).do { |e| tom.(e, 0.5) } };
	out
}
)
