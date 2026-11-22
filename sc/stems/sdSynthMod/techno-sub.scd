// Column code of the techno sub (008): a pumping sine (+ a triangle for brightness) on the chord root, each note a 16th after
// the kick. Pump, Fifth (beat 4 on the fifth), Syncopated (beat 4 split); Length (row 3) is the clip; button 2 an octave
// up. Brightness is the triangle's level. Out in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, x, m, clip, env, tg;
	st[\pats] = st[\pats] ?? { [
		Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [0, 3]],
		Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [4, 3]],
		Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [0, 1], 15 -> [0, 1]]] };
	x = if(tr.breakAt(b).not) { st[\pats][col[\patLatch].atBar(b)][k % 16] };
	if(x.isNil) { [] } {
		m = fr.degMidi(x[0] + fr.rootAt(tr, b), 1, tr.chapterAt(b)) + if(col.held(\b2)) { 12 } { 0 };
		clip = 1 - (0.65 * col.knob(\k3));
		env = kit[\adsr].(0.015, nil, 1, 0.04) ++ (hold: x[1] * clip, len16: x[1] * clip);
		tg = 0.18 + (0.3 * col.knob(\k1));
		[kit[\syn].(\sine, m, 0.9, env), kit[\syn].(\triangle, m, tg, env)]
	}
}
)
