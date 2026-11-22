// Column code of the groove bass (001, 002): the disco octave bass on the scale degrees of the chord root and the mood: a
// saw and a square through a filter envelope, a sine an octave below. Octaves, Boogie or Gallop; button 2 an octave up.
// Master drives it. Out in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, out = List[], adsr = kit[\adsr], syn = kit[\syn];
	st[\lines] = st[\lines] ?? { ["[0 7]*8", "0 ~ ~ 0 7 ~ 0 ~ ~ 0 ~ 7 4 ~ 6 ~", "[0 ~ 7 7]*4"].collect(kit[\table]) };
	if(tr.breakAt(b).not) {
		kit[\eventsAt].(st[\lines][col[\patLatch].atBar(b)], k).do { |e|
			var m = fr.degMidi(e[2] + fr.rootAt(tr, b), 2, tr.chapterAt(b)) + if(col.held(\b2)) { 12 } { 0 };
			var len = 0.12 + (0.3 * col.knob(\k3)), w = ce.val(ce.stemGlobal.master), gw = kit[\dB].(2 * w);
			var lp = (lpOn: 1, bright: col.knob(\k1), lo: 300, hi: 3500, tone: kit[\tone], shape: 0.1 + (0.25 * w), at: e[0], hold: e[1]);
			var env = lp ++ (lpq: 5, lpenv: 2.5, la: 0.002, ld: 0.09, ls: 0.2, lr: 0.01) ++ adsr.(0.003, len, 0.15, 0.05);
			out.add(syn.(\sawtooth, m, 0.32 * gw, env));
			out.add(syn.(\square, m, 0.18 * gw, env));
			out.add(syn.(\sine, m - 12, 0.35 * gw, lp ++ adsr.(0.004, len, 0.3, 0.05)))
		}
	};
	out
}
)
