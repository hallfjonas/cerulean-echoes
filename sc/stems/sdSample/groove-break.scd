// Column code of the groove break (001, 002): a breakbeat under the four on the floor (syncopated kick, snare with ghost
// notes, 8th hats): Two-step, Funk, Choppy. Chop (row 3) splits half the hits into 32nds; button 2 stutters the last
// beat. Plays in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var c = col.knob(\k3), out = List[], adsr = kit[\adsr], eventsAt = kit[\eventsAt], kitHits, hits;
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 1000, hi: 12000, tone: kit[\tone], pan: 0.5);
	st[\kits] = st[\kits] ?? { [
		["x ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~", "~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x"],
		["x ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~", "~ ~ ~ ~ x ~ ~ x ~ x ~ ~ x ~ ~ ~", "~ x ~ ~ ~ ~ x ~ ~ ~ ~ x ~ ~ ~ x"],
		["x ~ ~ x ~ ~ x ~ ~ ~ x ~ ~ ~ ~ ~", "~ ~ ~ ~ x ~ ~ ~ ~ x ~ ~ x ~ x ~", "~ ~ x ~ ~ x ~ ~ ~ ~ ~ x ~ ~ ~ ~"],
	].collect { |one| one.collect(kit[\table]) } };
	st[\hh] = st[\hh] ?? { kit[\table].("[x ~]*8") };
	kitHits = st[\kits][col[\patLatch].atBar(b)];
	hits = List[];
	if(eventsAt.(kitHits[0], k).notEmpty) { hits.add(["tr909/bd-01.wav", "RolandTR909_bd:0", 0.5, 0.18, 0, 90]) };
	if(eventsAt.(kitHits[1], k).notEmpty) { hits.add(["tr909/sd-00.wav", "RolandTR909_sd:0", 0.55, 0.16, 0, 0]) };
	if(eventsAt.(kitHits[2], k).notEmpty) { hits.add(["tr909/sd-00.wav", "RolandTR909_sd:0", 0.18, 0.06, 0, 0]) };
	if(eventsAt.(st[\hh], k).notEmpty) { hits.add(["tr909/hh-00.wav", "RolandTR909_hh:0", [0.18, 0.1][(s16 / 2).floor % 2], 0.03, nil, 0]) };
	hits.do { |h|
		var note = { |g, at| out.add(kit[\smp].(h[0], h[1], g, lp ++ (at: at, hp: h[5]) ++ adsr.(nil, h[3], h[4], nil))) };
		if(col.held(\b2) and: { s16 >= 12 }) { note.(h[2], 0); note.(h[2], 0.5) } { note.(h[2], 0) };
		if(c > 0 and: { ce.rand(t) >= 0.5 }) { 2.do { |j| if(ce.rand(t + (j / 32)) >= (1 - (0.5 * c))) { note.(0.6, j / 2) } } };
	};
	out
}
)
