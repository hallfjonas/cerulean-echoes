// Column code of the groove arp (001, 002): the Italo-disco arpeggio over the chord root and the mood's scale, in 16ths: a
// plucked square and saw, panned left and right per 16th. Up, Up-down, Octaves, Italo; button 2 an octave up; Length
// (row 3) is the decay.
(
strip: (space: \k2, echo: 0.3),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, s16 = k % 16, out = List[], adsr = kit[\adsr], syn = kit[\syn];
	st[\tables] = st[\tables] ?? { ["[0 2 4 6]*4", "[0 2 4 7 4 2]*2 0 2 4 7", "[0 7]*8", "[0 7 4 7 2 7 4 7]*2"].collect(kit[\table]) };
	kit[\eventsAt].(st[\tables][col[\patLatch].atBar(b)], k).do { |e|
		var m = fr.degMidi(e[2] + fr.rootAt(tr, b), 4, tr.chapterAt(b)) + if(col.held(\b2)) { 12 } { 0 };
		var lp = (lpOn: 1, bright: col.knob(\k1), lo: 800, hi: 9000, tone: kit[\tone], at: e[0], hold: e[1],
			pan: [0.35, 0.65][(s16 + e[0] + 1e-6).floor.asInteger % 2]) ++ adsr.(0.002, 0.08 + (0.25 * col.knob(\k3)), 0, 0.05);
		out.add(syn.(\square, m, 0.43, lp));
		out.add(syn.(\sawtooth, m + 0.08, 0.3, lp))
	};
	out
}
)
