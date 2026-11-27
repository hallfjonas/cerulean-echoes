// Column code of the acid funk bass (018-acid-tech-house): a busy, syncopated line on the root that stays off the kick,
// with octave pops, walk-downs and slides (2-bar figures: Funk, Octave, Bounce). A saw and a square through a resonant
// low-pass that plucks on every note (an octave pop opens it wider: the accent), a sine for the body. A note glides in
// from the one before it when that is at most two 16ths earlier. Complexity (row 3) adds short muted ghost notes;
// button 2 an octave up. Wumms (column 8's fader) drives it. Out in the Break.
(
// per figure: bar A, bar B (scale degrees on the root, "~" = rest), the ghost notes
var lines = [
	["~ ~ 0 ~ ~ 0 ~ 7 ~ ~ 0 ~ 3 ~ 4 ~", "~ ~ 0 ~ ~ 0 ~ 7 ~ 6 ~ 4 ~ 3 ~ 2", "~ 0 ~ ~ ~ ~ ~ ~ 0 ~ ~ 0 ~ ~ ~ ~"],
	["~ ~ 0 7 ~ 0 ~ 7 ~ ~ 0 7 ~ 0 7 ~", "~ ~ 0 7 ~ 0 ~ 7 ~ ~ 0 7 ~ 6 4 ~", "~ 0 ~ ~ ~ ~ 0 ~ ~ 0 ~ ~ ~ ~ ~ 0"],
	["~ ~ 0 ~ 0 ~ ~ 7 ~ ~ 0 ~ 4 ~ 6 7", "~ ~ 0 ~ 0 ~ ~ 7 ~ ~ 0 ~ -3 ~ -1 0", "~ 0 ~ ~ ~ ~ 0 ~ ~ 0 ~ ~ ~ ~ ~ ~"]
];
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, s16 = k % 16, out = List[], adsr = kit[\adsr];
	var l, row, deg, ghost, prev, slide, acc, w, gw, f, lp, oct, mood, root, midiOf;
	st[\lines] = st[\lines] ?? { lines.collect { |x| x.collect(kit[\line]) } };
	if(tr.breakAt(b)) { [] } {
		l = st[\lines][col[\patLatch].atBar(b)]; row = l[b % 2]; deg = row[s16];
		ghost = if(deg.isNil and: { col.knob(\k3) > 0 }) { l[2][s16] };
		mood = tr.chapterAt(b); root = fr.rootAt(tr, b); oct = if(col.held(\b2)) { 12 } { 0 };
		midiOf = { |d| fr.degMidi(d + root, 2, mood) + oct };
		w = ce.val(ce.stemGlobal.master); gw = kit[\dB].(w);
		f = (300 * ((2200 / 300) ** col.knob(\k1))).max(300 + (150 * w)) * (0.85 + (0.3 * ce.sine(b / 8)));
		deg !? {
			prev = [1, 2].collect { |o| s16 - o }.detect { |i| (i >= 0) and: { row[i].notNil } };
			slide = if(prev.notNil and: { row[prev] != deg }) { midiOf.(row[prev]) - midiOf.(deg) } { 0 };
			acc = deg >= 7;
			lp = (lpOn: 1, bright: 0, lo: f, hi: f, tone: kit[\tone], lpq: 6, lpenv: if(acc) { 3.2 } { 2.2 }, la: 0.002,
				ld: if(acc) { 0.16 } { 0.1 }, ls: 0, lr: 0.01, shape: 0.12 + (0.2 * w), hold: 1.5)
				++ if(slide != 0) { (penv: slide, pd: 0.06, ps: 0.001) } { () };
			out.add(kit[\syn].(\sawtooth, midiOf.(deg), 0.26 * gw * if(acc) { 1.2 } { 1 },
				lp ++ adsr.(0.003, 0.18, 0.25, 0.06)));
			out.add(kit[\syn].(\square, midiOf.(deg), 0.14 * gw, lp ++ adsr.(0.003, 0.18, 0.25, 0.06)));
			out.add(kit[\syn].(\sine, midiOf.(deg), 0.3 * gw, lp ++ (lpenv: 0) ++ adsr.(0.004, 0.22, 0.4, 0.06)));
		};
		ghost !? { |d|
			out.add(kit[\syn].(\sawtooth, midiOf.(d), 0.12 * col.knob(\k3).sqrt * gw,
				(lpOn: 1, bright: 0, lo: f * 0.7, hi: f * 0.7, tone: kit[\tone], lpq: 3, lpenv: 1, la: 0.002, ld: 0.04,
					ls: 0, lr: 0.01, hold: 0.5) ++ adsr.(0.002, 0.04, 0, 0.03)))
		};
		out
	}
}
)
)
