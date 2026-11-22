// Column code of the opus bass (016): a short, sparse figure on the chord root (Sparse, Call, Roll; two bars alternating):
// a saw + a triangle through a resonant low-pass that opens on every note, a wide top layer above 200 Hz (left, and right 12
// ms later). Complexity (row 3) adds a few ghost notes; button 2 an octave up. Wumms (column 8's fader) drives it. Out in
// the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16;
	var out = List[], l, deg, c, w, gw, f, lp, oct, note, adsr = kit[\adsr], line = kit[\line];
	var envs = [1.5, 1.8, 2.6, 1.6], topLate = 0.012 * (tr.bpm / 60) * 4;
	st[\lines] = st[\lines] ?? { [
		[["~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ 7 ~ ~"], "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0"],
		[["~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0 0", "~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"], "~ ~ ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~"],
		[["~ ~ 0 ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ 7 ~ ~", "~ ~ 0 ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ -1 ~ ~"], "~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ 0"],
	].collect { |x| [x[0].collect(line), line.(x[1])] } };
	if(tr.breakAt(b)) { [] } {
		l = st[\lines][col[\patLatch].atBar(b)];
		c = col.knob(\k3); oct = if(col.held(\b2)) { 12 } { 0 }; w = ce.val(ce.stemGlobal.master); gw = kit[\dB].(w);
		f = (350 * ((2500 / 350) ** col.knob(\k1))).max(350 + (150 * w)) * (0.8 + (0.45 * ce.sine(b / 16)));
		lp = (lpOn: 1, bright: 0, lo: f, hi: f, tone: kit[\tone], lpq: 4, lpenv: envs[s16 % 4], la: 0.003, ld: 0.12, ls: 0, lr: 0.01,
			shape: 0.15 + (0.2 * w)) ++ adsr.(0.004, 0.14, 0.1, 0.08);
		note = { |wave, deg, at, g, args| var m = fr.degMidi(deg + fr.rootAt(tr, b), 2, tr.chapterAt(b)) + oct;
			kit[\syn].(wave, m, g * gw, lp ++ (hold: 1, at: at) ++ (args ? ())) };
		deg = l[0][b % 2][s16];
		deg !? {
			out.add(note.(\sawtooth, deg, 0, 0.75 * 0.3));
			out.add(note.(\triangle, deg, 0, 0.6 * 0.3));
			out.add(note.(\sawtooth, deg, 0, 0.3 * 1.2, (pan: 0, hp: 200)));
			out.add(note.(\sawtooth, deg, topLate, 0.3 * 1.2, (pan: 1, hp: 200)));
		};
		if(c > 0) { l[1][s16] !? { |d|
			out.add(note.(\sawtooth, d, 0, 0.75 * (c * 0.16)));
			out.add(note.(\triangle, d, 0, 0.6 * (c * 0.16)));
		} };
		out
	}
}
)
