// Column code of the groove chords (001, 002): Juno-like 7th chords on the frame's progression and mood (two saws 0.1
// apart, a square). Button 1 picks the progression (the frame), button 2 the rhythm (the frame's latch): off-beat,
// boogie, held. Length (row 3) is the decay.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, out = List[], adsr = kit[\adsr], syn = kit[\syn];
	st[\tables] = st[\tables] ?? { fr[\rhythms].collect { |r| kit[\table].(r[1]) } };
	kit[\eventsAt].(st[\tables][tr.rhythm.atBar(b)], k).do { |e|
		var len = 0.12 + (0.6 * col.knob(\k3));
		var lp = (lpOn: 1, bright: col.knob(\k1), lo: 400, hi: 7000, tone: kit[\tone], lpenv: 1.5, la: 0.003, ld: 0.15, ls: 0.4, lr: 0.01,
			at: e[0], hold: e[1]) ++ adsr.(0.004, len, 0.25, 0.12);
		fr.tonesAt(tr, b, [0, 2, 4, 6], 3).do { |m|
			out.add(syn.(\sawtooth, m, 0.3, lp ++ (pan: 0.3)));
			out.add(syn.(\sawtooth, m + 0.1, 0.3, lp ++ (pan: 0.3)));
			out.add(syn.(\square, m, 0.17, lp))
		}
	};
	out
}
)
