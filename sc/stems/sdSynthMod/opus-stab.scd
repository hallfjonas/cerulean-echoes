// Column code of the opus stab (016): root + fifth on detuned saws (+ a square below) through a resonant low-pass that snaps
// shut: eight figures, on the chord root. Vanish (row 3) leaves bars out at random (up to 85 %); the answer plays in those
// bars. The shape is fixed here (snap 3 octaves, decay 0.17 s, Q 8, no drive): the translation of 016 has no Stab Shape
// column. Button 2 throws an echo. Space scales the room from 0.25. Tension sends no echo to it.
(
states: (room: 0.9 * 0.25, echo: 0),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| col.setState(\room, 0.9 * (0.25 + (0.75 * col.knob(\k2))), send);
	col.setState(\echo, if(col.held(\b2)) { 0.85 } { 0 }, send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16;
	var l, d, len = 0.17, w, lp, out = List[];
	st[\stabs] = st[\stabs] ?? { [
		["~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~"],
		["~ ~ 0 ~ ~ ~ 0 ~ ~ ~ 0 ~ ~ 0 ~ ~"],
		["~ ~ 0 ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~", "~ ~ 0 ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ 7 ~ ~"],
		["~ 0 ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ ~"],
		["~ ~ 0 ~ 0 ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~", "~ ~ 0 ~ 0 ~ ~ ~ ~ ~ -1 ~ ~ ~ ~ ~"],
		["~ ~ ~ 0 ~ ~ 0 ~ ~ ~ ~ 0 ~ ~ 0 ~"],
		["~ ~ 0 ~ ~ 0 ~ ~ ~ ~ 0 ~ ~ ~ ~ ~", "~ ~ 0 ~ ~ 0 ~ ~ ~ ~ 0 ~ ~ ~ -1 ~"],
		["~ ~ 0 0 ~ ~ 0 ~ ~ ~ 0 ~ ~ 0 ~ ~"],
	].collect { |p| p.collect(kit[\line]) } };
	l = st[\stabs][col[\patLatch].atBar(b)]; d = l[b % l.size][s16];
	if(d.isNil or: { fr.stabHere(tr, b).not }) { [] } {
		w = 0.75 + (0.6 * ce.sine(b / 12));
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 400 * w, hi: 4000 * w, tone: kit[\tone], hp: 400,
			lpq: 8, lpenv: 3, la: 0.002, ld: len * 0.47, ls: 0, lr: 0.01, shape: 0.25) ++ kit[\adsr].(0.002, len, 0, 0.08);
		[[\sawtooth, 0], [\sawtooth, 0.15], [\sawtooth, 7], [\square, -12]].do { |x|
			out.add(kit[\syn].(x[0], fr.degMidi(d + fr.rootAt(tr, b), 3, tr.chapterAt(b)) + x[1], 0.3, lp ++ (at: 0, hold: 1))) };
		out
	}
}
)
