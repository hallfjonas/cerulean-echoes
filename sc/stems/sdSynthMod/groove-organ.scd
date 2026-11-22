// Column code of the groove organ stab (002): the chord's root, third and fifth on drawbar-like sines and a square (a
// fifth above the octave): Stab, Call, Off-beat. Decay (row 3) is the length; Space is the echo send, and button 2 throws
// a long echo.
(
states: (echo: 0),
strip: (space: \k2, echoSend: \echo),
update: { |col, send| col.setState(\echo, if(col.held(\b2)) { 0.8 } { (0.3 * col.knob(\k2)).min(0.9) }, send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, out = List[], adsr = kit[\adsr], syn = kit[\syn];
	st[\stabs] = st[\stabs] ?? { ["~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ ~ x ~", "<[x ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ ~] ~>", "[~ ~ x ~]*4"].collect(kit[\table]) };
	kit[\eventsAt].(st[\stabs][col[\patLatch].atBar(b)], k).do { |e|
		var lp = (lpOn: 1, bright: col.knob(\k1), lo: 1200, hi: 9000, tone: kit[\tone], at: e[0], hold: e[1])
			++ adsr.(0.002, 0.12 + (0.5 * col.knob(\k3)), 0, 0.08);
		fr.tonesAt(tr, b, [0, 2, 4], 4).do { |m|
			out.add(syn.(\sine, m, 0.5, lp));
			out.add(syn.(\square, m + 12, 0.11, lp));
			out.add(syn.(\sine, m + 19, 0.18, lp))
		}
	};
	out
}
)
