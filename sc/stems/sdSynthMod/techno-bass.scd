// Column code of the techno bass (008): a dark rolling line on the chord root: saws through a resonant low-pass that snaps
// open on every note, a wide top layer above 200 Hz (left, and right 12 ms later). 3-3-2, Rolling, Acid, Stomp;
// Complexity (row 3) rolls quiet ghost 16ths (or 32nds) into the gaps; button 2 an octave up. Out in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16;
	var out = List[], l, deg, c, w, lp, oct, note, adsr = kit[\adsr], line = kit[\line];
	var vels = [0.7, 0.8, 1, 0.75], envs = [1.8, 2.2, 3.2, 2];
	var topLate = 0.012 * (tr.bpm / 60) * 4;
	st[\lines] = st[\lines] ?? { [
		[["0 ~ ~ 0 ~ ~ 0 ~ 0 ~ ~ 0 ~ ~ 0 ~"], "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0"],
		[["~ 0 0 7 ~ 0 0 0 ~ 0 0 7 ~ 0 2 0", "~ 0 0 7 ~ 0 0 0 ~ 0 -1 0 ~ 4 2 -1"], "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0"],
		[["~ ~ 0 ~ 7 ~ 0 2 ~ ~ 0 ~ 6 ~ 0 ~", "~ ~ 0 ~ 7 ~ 0 2 ~ ~ 0 ~ -2 ~ -1 ~"], "~ 0 ~ 0 ~ 0 ~ ~ ~ 0 ~ 0 ~ 0 ~ 7"],
		[["~ ~ 0 ~ ~ ~ 0 0 ~ ~ 0 ~ ~ 7 0 ~", "~ ~ 0 ~ ~ ~ 0 0 ~ ~ 0 ~ ~ 2 -2 ~"], "~ 0 ~ 7 ~ 0 ~ ~ ~ 0 ~ 7 ~ ~ ~ ~"],
	].collect { |x| [x[0].collect(line), line.(x[1])] } };
	if(tr.breakAt(b)) { [] } {
		l = st[\lines][col[\patLatch].atBar(b)];
		c = col.knob(\k3); oct = if(col.held(\b2)) { 12 } { 0 };
		w = 0.8 + (0.45 * ce.sine(b / 16));
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 350 * w, hi: 2500 * w, tone: kit[\tone],
			lpq: 7, la: 0.002, ld: 0.11, ls: 0, lr: 0.01, shape: 0.35) ++ adsr.(0.003, 0.16, 0.15, 0.06);
		note = { |deg, at, len, g, args, dm = 0| var i = (s16 + at).floor % 4, m = fr.degMidi(deg + fr.rootAt(tr, b), 2, tr.chapterAt(b)) + oct + dm;
			kit[\syn].(\sawtooth, m, g * vels[i], lp ++ (lpenv: envs[i], hold: len, at: at, len16: len, vel: vels[i]) ++ (args ? ())) };
		deg = l[0][b % l[0].size][s16];
		deg !? {
			out.add(note.(deg, 0, 1, 0.3));
			out.add(note.(deg, 0, 1, 0.3 * 1.5, (pan: 0, hp: 200)));
			out.add(note.(deg, topLate, 1, 0.3 * 1.5, (pan: 1, hp: 200)));
		};
		if(c > 0) {
			var g = l[1], n = g.size / 16;
			n.asInteger.do { |j| g[(s16 * n) + j] !? { |d|
				var at = j / n, len = 1 / n;
				out.add(note.(d, at, len, c * 0.16));
				out.add(note.(d, at, len, c * 0.16, nil, 0.1));
			} }
		};
		out
	}
}
)
