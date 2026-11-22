// Column code of the opus sub (016): as the techno sub (008), louder with Wumms (column 8's fader): +4 dB per Wumms, and the
// triangle brighter by 0.15 per Wumms.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, x, m, clip, env, w, gw;
	st[\pats] = st[\pats] ?? { [
		Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [0, 3]],
		Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [4, 3]],
		Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [0, 1], 15 -> [0, 1]]] };
	x = if(tr.breakAt(b).not) { st[\pats][col[\patLatch].atBar(b)][k % 16] };
	if(x.isNil) { [] } {
		m = fr.degMidi(x[0] + fr.rootAt(tr, b), 1, tr.chapterAt(b)) + if(col.held(\b2)) { 12 } { 0 };
		clip = 1 - (0.65 * col.knob(\k3));
		env = kit[\adsr].(0.015, nil, 1, 0.04) ++ (hold: x[1] * clip, len16: x[1] * clip);
		w = ce.val(ce.stemGlobal.master); gw = kit[\dB].(4 * w);
		[kit[\syn].(\sine, m, 0.9 * gw, env), kit[\syn].(\triangle, m, (0.18 + (0.3 * col.knob(\k1)) + (0.15 * w)) * gw, env)]
	}
}
)
