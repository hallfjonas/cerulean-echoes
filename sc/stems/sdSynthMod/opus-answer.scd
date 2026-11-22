// Column code of the opus answer (016): short square blips at the end of every second bar, left and right, with a long echo:
// eight phrase rhythms. Voices (row 3) adds the third, the fifth and the 7th, strummed apart; from 0.75 some notes spill
// over into the bars between. Button 2: random extra answers on the back ten 16ths. Where the stab leaves a bar (and the
// stab's fader is up) the phrase plays there too; these layers add up, so a note can play twice. Space scales room and echo.
(
states: (room: 0.9 * 0.35, echo: 0.55 * 2 * 0.35),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = 0.35 + (0.65 * col.knob(\k2));
	col.setState(\room, 0.9 * s, send); col.setState(\echo, (0.55 * 2 * s).min(0.9), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var v = col[\patLatch].atBar(b), vo = col.knob(\k3), wild = kit[\ramp].(vo, 0.75, 1), r = ce.rand(t), n = 0, tn, lp, out = List[];
	var tones = [0, 2, 4, 6, 7];
	st[\rhythms] = st[\rhythms] ?? { ["~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x x ~",
		"~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~ x", "~ ~ ~ ~ ~ ~ x ~ ~ ~ x ~ ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ ~ ~ ~ ~",
		"~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x ~ x ~ ~", "~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~ ~ ~ x x"].collect { |x| x.split($ ).collect(_ == "x") } };
	if((b % 2) == 1) { if(st[\rhythms][v][s16]) { n = 1 } } {
		if(col.held(\b2)) { if(s16 >= 6 and: { r >= 0.7 }) { n = n + 1 } }
			{ if(wild > 0 and: { st[\rhythms][v][s16] } and: { r >= (1 - (0.6 * wild)) }) { n = n + 1 } };
		if(st[\rhythms][v][s16] and: { fr.stabHere(tr, b).not } and: { ce.val(56) > 0 }) { n = n + 1 };
	};
	if(n == 0) { [] } {
		tn = tones[(5 * ce.rand(t + (1024 * v))).trunc.asInteger];
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 2000, hi: 12000, tone: kit[\tone], hold: 1, pan: [0.2, 0.8][s16 % 2])
			++ kit[\adsr].(nil, 0.07, 0, 0.05);
		n.do { [[0, 0.54, 0], [2, kit[\ramp].(vo, 0, 0.375) * 0.42, 1], [4, kit[\ramp].(vo, 0.375, 0.75) * 0.36, 2], [6, wild * 0.3, 3]].do { |x|
			if(x[1] > 0) { out.add(kit[\syn].(\square, fr.degMidi(tn + x[0] + fr.rootAt(tr, b), 5, tr.chapterAt(b)), x[1],
				lp ++ (at: x[2] * wild / 4))) } } };
		out
	}
}
)
