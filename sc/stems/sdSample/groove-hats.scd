// Column code of the groove hats (001, 002): 909 hats: the house off-beat open hat and closed 16ths (Off-beat, Disco,
// Rave); Swing (row 3) pushes the off 16ths late; button 2 holds an open hat on every off-beat 8th. Plays in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, s16 = k % 16;
	var out = List[], sw = 0.3 * col.knob(\k3), adsr = kit[\adsr], smp = kit[\smp], eventsAt = kit[\eventsAt];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 8000, hi: 18000, tone: kit[\fog], hp: 1800);
	var closed = { |g, at, len| out.add(smp.("tr909/hh-00.wav", "RolandTR909_hh:0", g * 3, lp ++ (pan: 0.68, at: at, hold: len) ++ adsr.(nil, 0.035, 0, 0.02))) };
	var open = { |g, at, len, dec = 0.18, rel = 0.05| out.add(smp.("tr909/oh-00.wav", "RolandTR909_oh:0", g * 3, lp ++ (pan: 0.56, at: at, hold: len) ++ adsr.(nil, dec, 0, rel))) };
	st[\pats] = st[\pats] ?? { [
		[[\open, "[~ x]*4", 0.32], [\closed, "[x ~ ~ x]*4", 0.12]],
		[[\open, "[~ ~ x ~]*4", 0.3], [\closed, "[x x ~ x]*4", [0.2, 0.12, 0, 0.15]]],
		[[\open, "[~ ~ x ~]*4", 0.28], [\closed, "x*16", [0.18, 0.1, 0, 0.13]], [\closed, "[~ ~ ~ ~ ~ ~ ~ [x x]]*2", 0.08]],
	].collect { |p| p.collect { |x| [x[0], kit[\table].(x[1]), x[2]] } } };
	st[\heldClosed] = st[\heldClosed] ?? { kit[\table].("[x x ~ x]*4") };
	st[\heldOpen] = st[\heldOpen] ?? { kit[\table].("[~ oh]*4") };
	if(col.held(\b2).not) {
		st[\pats][col[\patLatch].atBar(b)].do { |x| eventsAt.(x[1], k).do { |e|
			var g = if(x[2].isArray) { x[2][s16 % 4] } { x[2] }, at = e[0] + kit[\swingAt].(s16 + e[0], sw);
			if(g > 0) { if(x[0] == \open) { open.(g, at, e[1]) } { closed.(g, at, e[1]) } } } };
	} {
		eventsAt.(st[\heldClosed], k).do { |e| closed.(0.14, e[0], e[1]) };
		eventsAt.(st[\heldOpen], k).do { |e| open.(0.34, e[0], e[1], 0.45, 0.1) };
	};
	out
}
)
