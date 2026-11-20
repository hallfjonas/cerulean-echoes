// Column code of the 009 sub: a sine on the chord's bass note (per 16th: a keys riff may change the chord inside a
// bar) with a triangle that Brightness brings in, a 16th after the kick; Length shortens every note to 35 %. Two waves
// per hit and a length relative to the pattern's note need code. Format: sc/lib/stems.scd (column code).
(
var synthDef = [0.001, 0.05, 0.6, 0.01];
(
strip: (orbit: 1, space: \k2),
notes: { |col, k|
	var ce = col[\ce], b = (k / 16).floor, v = col[\patLatch].atBar(b), thin = ("c" ++ ce.thinBus).asSymbol;
	var dur = switch(v, 0, { if(k % 4 == 1) { 3 } }, 1, { if(k % 4 == 2) { 2 } }, 2, { if(k % 8 == 1) { 7 } });
	var m, clip, x, env, tri;
	if(dur.isNil) { [] } {
		m = col.chordAtK(k, false)[\bass] + if(col.held(\b2)) { 12 } { 0 };
		clip = 1 - (0.65 * col.knob(\k3));
		x = ce.sdADSR(0.015, nil, 1, 0.04, synthDef); env = (a: x[0], d: x[1], s: x[2], r: x[3]);
		tri = 0.1 + (0.17 * col.knob(\k1));
		[
			ce.note(col[\sample], (wave: 0, freq: m.midicps, amp: 0.5, hold: dur * clip, thinF: thin, tag: "sine", g: 0.5,
				midi: m) ++ env),
			ce.note(col[\sample], (wave: 1, freq: m.midicps, amp: tri, hold: dur * clip, thinF: thin, tag: "triangle",
				g: tri, midi: m) ++ env)
		]
	}
}
)
)
