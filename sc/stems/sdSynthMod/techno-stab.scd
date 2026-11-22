// Column code of the techno stab (008): root + fifth on detuned saws (+ a square below) through a resonant low-pass that
// snaps shut: eight figures. Variation (row 3): a ratchet (the stab twice in 32nds), then an octave jump, each by chance.
// Button 2 throws an echo. Space scales the room from 0.25. Tension sends no echo to it.
(
states: (room: 0.9 * 0.25, echo: 0),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| col.setState(\room, 0.9 * (0.25 + (0.75 * col.knob(\k2))), send);
	col.setState(\echo, if(col.held(\b2)) { 0.85 } { 0 }, send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var l, d, vary = col.knob(\k3), x1 = 0.35 * vary, x2 = 0.2 * vary, r = ce.rand(t), parts, w, lp, out = List[];
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
	if(d.isNil) { [] } {
		parts = if(r < x1) { [[0, 0.5], [0.5, 0.5]] } { if(r > x1) { [[0, 1]] } { [] } };
		w = 0.75 + (0.6 * ce.sine(b / 12));
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 400 * w, hi: 4000 * w, tone: kit[\tone], hp: 400,
			lpq: 8, lpenv: 3, la: 0.002, ld: 0.08, ls: 0, lr: 0.01, shape: 0.25) ++ kit[\adsr].(0.002, 0.17, 0, 0.08);
		parts.do { |pt|
			var ru = ce.rand(t + (pt[0] / 16)), dd = d + if(ru < x2) { 7 } { 0 }, m;
			if(ru != x2) {
				m = fr.degMidi(dd + fr.rootAt(tr, b), 3, tr.chapterAt(b));
				[[\sawtooth, 0], [\sawtooth, 0.15], [\sawtooth, 7], [\square, -12]].do { |x|
					out.add(kit[\syn].(x[0], m + x[1], 0.3, lp ++ (at: pt[0], hold: pt[1]))) }
			}
		};
		out
	}
}
)
