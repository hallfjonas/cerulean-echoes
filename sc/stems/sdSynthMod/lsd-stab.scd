// Column code of the lsd stab (017): an acid dub chord on the chord root and the mood's scale: root (twice, detuned, wide),
// third, seventh, ninth on saws and a square an octave below, through a resonant low-pass that snaps shut. Every third hit an
// accent (counted on through the bars), slides between near notes, the filter wandering on two slow cycles (7 and 3 bars).
// Eight figures. Vanish (row 3) leaves bars out at random (up to 85 %); the answer plays in those bars. The shape is fixed
// here (snap 3 octaves, decay 0.17 s, Q 8, no drive): the translation has no Stab Shape column. Button 2 throws an echo.
(
states: (room: 0.9 * 0.25, echo: 0),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| col.setState(\room, 0.9 * (0.25 + (0.75 * col.knob(\k2))), send);
	col.setState(\echo, if(col.held(\b2)) { 0.85 } { 0 }, send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var l, row, d, snap = 3, len = 0.17, reso = 8, w, lp, out = List[], count, acc, prev, slide, mood = tr.chapterAt(b), root = fr.rootAt(tr, b);
	var adsr = kit[\adsr], syn = kit[\syn], dB = kit[\dB];
	st[\stabs] = st[\stabs] ?? { [
		["~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~"],
		["~ ~ 0 ~ ~ ~ 0 ~ ~ ~ 2 ~ ~ 0 ~ ~", "~ ~ 0 ~ ~ ~ 0 ~ ~ ~ -1 ~ ~ 0 ~ ~"],
		["~ ~ 0 ~ ~ 0 ~ ~ 4 ~ ~ 0 ~ ~ 2 ~"],
		["~ 0 ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ ~", "~ 0 ~ 0 ~ ~ 2 ~ ~ 0 ~ ~ -1 ~ ~ ~"],
		["~ ~ 0 ~ 0 ~ ~ ~ ~ ~ 7 ~ ~ ~ ~ ~", "~ ~ 0 ~ 0 ~ ~ ~ ~ ~ 6 ~ ~ 4 ~ ~"],
		["~ ~ ~ 0 ~ ~ 0 ~ ~ ~ ~ 0 ~ ~ 0 ~"],
		["~ 0 0 ~ 2 ~ 0 ~ ~ 4 ~ 0 ~ 2 0 ~"],
		["~ ~ 0 0 ~ ~ 0 ~ ~ ~ 0 ~ ~ 0 ~ ~", "~ ~ 0 0 ~ ~ -1 ~ ~ ~ -3 ~ ~ -1 ~ ~"],
	].collect { |p| p.collect(kit[\line]) } };
	st[\voices] = [[\sawtooth, 0, 0, 0.2], [\sawtooth, 0, 0.12, 0.8], [\sawtooth, 2, 0, 0.42], [\sawtooth, 6, 0, 0.58],
		[\square, 8, 0, 0.5], [\square, -7, 0, 0.5]];
	l = st[\stabs][col[\patLatch].atBar(b)]; row = l[b % l.size]; d = row[s16];
	if(d.isNil or: { fr.stabHere(tr, b).not }) { [] } {
		count = row.select(_.notNil).size;
		acc = (((0..15).count { |i| (i < s16) and: { row[i].notNil } } + (b * count)) % 3) == 0;
		prev = [1, 2, 3].collect { |o| s16 - o }.detect { |i| (i >= 0) and: { row[i].notNil } };
		slide = if(prev.notNil and: { row[prev] != d }) { fr.degMidi(row[prev] + root, 3, mood) - fr.degMidi(d + root, 3, mood) } { 0 };
		w = 0.55 + (0.6 * ce.sine(t / 7)) + (0.35 * ce.sine(t / 3));
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 400 * w, hi: 4000 * w, tone: kit[\tone], hp: 300,
			lpq: reso + if(acc) { 5 } { 0 }, lpenv: snap + if(acc) { 1.5 } { 0 }, la: 0.002, ld: len * if(acc) { 0.7 } { 0.47 },
			ls: 0, lr: 0.01, shape: 0.25) ++ adsr.(0.002, len * if(acc) { 1.4 } { 1 }, 0, 0.08);
		[[0, 1]].do { |pt, j|
			var bend = if(slide != 0 and: { j == 0 }) { (penv: slide, pd: 0.07, ps: 0.001) } { (penv: 0.5, pd: 0.05, ps: 0.001) };
			st[\voices].do { |x| var m = fr.degMidi(d + x[1] + root, 3, mood) + x[2];
				out.add(syn.(x[0], m, 0.22 * dB.(0) * if(acc) { 1.35 } { 1 },
					lp ++ bend ++ (at: pt[0], hold: pt[1], pan: x[3] + (0.1 * if(k.odd) { 1 } { -1 })))) }
		};
		out
	}
}
)
