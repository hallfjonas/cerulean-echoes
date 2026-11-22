// Column code of the techno hats (008): open 909 hats on the off-beats, crisp, closed 16ths around them (Open, Open + 16ths,
// Driving). Complexity (row 3) adds quiet 16ths, then little 32nd rolls, left out at random; button 2: the open hats ring
// longer, on every 8th. Plays in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, out = List[], v = col[\patLatch].atBar(b), c = col.knob(\k3);
	var lp, hit, open, adsr = kit[\adsr], ramp = kit[\ramp];
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 9000, hi: 18000, tone: kit[\fog], hp: 1800, pan: 0.62);
	hit = { |rel, tag, g, args| kit[\smp].(rel, tag, g * 3.2, lp ++ (args ? ())) };
	open = { |g, dec, rel, len| hit.("tr909/oh-00.wav", "RolandTR909_oh:0", g, (hold: len) ++ adsr.(nil, dec, 0, rel)) };
	if(col.held(\b2).not) {
		if(k % 4 == 2) { out.add(open.([0.42, 0.36, 0.34][v], 0.18, 0.05, 2)) };
		switch(v,
			1, { [0.2, 0.12, nil, 0.14][k % 4] !? { |g| out.add(hit.("tr909/hh-00.wav", "RolandTR909_hh:0", g)) } },
			2, { out.add(hit.("tr909/hh-00.wav", "RolandTR909_hh:0", 0.1 + (0.2 * ce.sine(2 * t)))) });
	} {
		if(k.even) { out.add(open.([0.26, 0.4][(k / 2) % 2], 0.4, 0.1, 2)) }
	};
	if(c > 0 and: { ce.rand(t) > 0.4 }) { out.add(hit.("tr909/hh-00.wav", "RolandTR909_hh:0", ramp.(c, 0, 0.5) * 0.12)) };
	if(c > 0.5) { 2.do { |j| var tj = (k + (j / 2)) / 16;
		if(ce.rand(tj) > 0.8) { out.add(hit.("tr909/hh-00.wav", "RolandTR909_hh:0", ramp.(c, 0.5, 1) * 0.18, (at: j / 2))) } } };
	out.reject { |n| n.amp <= 0 }
}
)
