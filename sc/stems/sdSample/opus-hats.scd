// Column code of the opus hats (016): a fast, swung closed 909 hat (right) and an open hat on the off-beat (Groove, Open,
// Fast). Complexity (row 3) adds quiet 32nd skips; button 2: closed x x ~ x with the open hat ringing longer. Plays in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), b = (k / 16).floor, s16 = k % 16, q = k % 4, out = List[], v = col[\patLatch].atBar(b), c = col.knob(\k3);
	var lp, hit, closed, open, adsr = kit[\adsr];
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 9000, hi: 18000, tone: kit[\fog], hp: 1800);
	hit = { |rel, tag, g, args| kit[\smp].(rel, tag, g * 3.2, lp ++ (args ? ())) };
	closed = { |g, at = 0, len = 1| hit.("tr909/hh-00.wav", "RolandTR909_hh:0", g, (pan: 0.72, at: at, hold: len) ++ adsr.(nil, 0.035, 0, 0.02)) };
	open = { |g, len = 1, dec = 0.2, rel = 0.06| hit.("tr909/oh-00.wav", "RolandTR909_oh:0", g, (pan: 0.56, hold: len) ++ adsr.(nil, dec, 0, rel)) };
	if(col.held(\b2).not) {
		switch(v,
			0, { [0.22, 0.12, nil, 0.16][q] !? { |g| out.add(closed.(g, if(k.odd) { 0.12 } { 0 })) };
				if(q == 2) { out.add(open.(0.3)) } },
			1, { if(q == 2) { out.add(open.(0.36)) }; if(q == 0) { out.add(closed.(0.1)) } },
			2, { [0.2, 0.15, nil, 0.18][q] !? { |g| out.add(closed.(g, if(k.odd) { 0.2 } { 0 })) };
				if(k % 8 == 7) { [0, 0.5].do { |at| out.add(closed.(0.1, at, 0.5)) } };
				if([2, 10].includes(s16)) { out.add(open.(0.32)) } });
	} {
		[0.14, 0.14, nil, 0.14][q] !? { |g| out.add(closed.(g)) };
		if(q == 2) { out.add(open.(0.34, 2, 0.45, 0.1)) };
	};
	if(c > 0) { 2.do { |j| if(ce.rand((k + (j / 2)) / 16) >= 0.75) { out.add(closed.(c * 0.12, j / 2, 0.5)) } } };
	out.reject { |n| n.amp <= 0 }
}
)
