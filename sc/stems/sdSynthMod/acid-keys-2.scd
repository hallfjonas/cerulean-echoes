// Column code of the acid keys 2 (018-acid-tech-house): the voice of acid-keys.scd (two detuned saws, a triangle an
// octave up, an FM tine) with a bouncing default figure. Bounce: syncopated 16th stabs around the kick in a 4-bar
// phrase, the off 16ths swung; accents snap (a harder filter pluck, a tiny pitch drop, a little drive) and strum the
// chord from low to high, ghost hits are short, dark and play the lower three notes only; the phrase ends on a lifted
// chord (one step up) that pushes into the next bar. Then the patterns of acid-keys.scd: off-beat stabs, a 2-bar comp,
// one swelling chord per bar, silent (the Launchkey alone). Chords: Fm9, Fm9, Dbmaj9, Eb9 in Dark (they follow the
// Chapter's mood). Length (row 3): short stab ↔ long, ringing chord. Space scales room and echo; button 2 throws a long
// echo while held. The Launchkey keys play the voice as acid-keys.scd does (keys, called by the frame).
(
var chords = [[0, 2, 4, 6, 8], [0, 2, 4, 6, 8], [-2, 0, 2, 4, 6], [-1, 1, 3, 5, 7]];
// a velocity per 16th ("~" = rest), one string per bar of the figure; Bounce: 1 = accent, below 0.7 = ghost, above 1.5:
// the chord one step up (2 = accent, 1.6 = ghost); the last pattern is silent
var rhythms = [
	["~ ~ 1 ~ ~ 0.6 ~ 1 ~ ~ 1 ~ ~ 0.6 1 ~", "~ ~ 1 ~ ~ 0.6 ~ 1 ~ 0.6 ~ 1 ~ ~ 1 ~",
		"~ ~ 1 ~ ~ 0.6 ~ 1 ~ ~ 1 ~ ~ 0.6 1 ~", "~ ~ 1 ~ ~ 0.6 ~ 1 ~ ~ 1 ~ 2 ~ 2 1.6"],
	["~ ~ 1 ~ ~ ~ 0.8 ~ ~ ~ 1 ~ ~ ~ 0.8 ~"],
	["~ ~ 1 ~ ~ 0.8 ~ ~ ~ ~ 0.9 ~ ~ ~ 0.7 ~", "~ ~ 1 ~ ~ ~ 0.8 ~ ~ 0.9 ~ ~ 0.8 ~ ~ ~"],
	["1 ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"],
	[]
];
// one key of MIDI note m: the saws, the triangle and the tine; env carries the ADSR and hold (16ths)
var voice = { |kit, m, g, lp, env, pan|
	[kit[\syn].(\sawtooth, m - 0.08, 0.11 * g, lp ++ env ++ (pan: (pan - 0.2).clip(0, 1), vib: 4.2, vibmod: 0.05)),
		kit[\syn].(\sawtooth, m + 0.08, 0.11 * g, lp ++ env ++ (pan: (pan + 0.2).clip(0, 1), vib: 3.7, vibmod: 0.05)),
		kit[\syn].(\triangle, m + 12, 0.05 * g, lp ++ env ++ (pan: pan)),
		kit[\syn].(\sine, m, 0.1 * g,
			lp ++ kit[\adsr].(0.002, 0.35, 0, 0.2) ++ (hold: env[\hold], pan: pan, fmi: 1.2, fmh: 3))]
};
var filter = { |ce, col, kit, vel|
	(lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 500, hi: 7000, tone: kit[\tone], lpq: 1.8,
		lpenv: 1 + (1.5 * vel), la: 0.004, ld: 0.3, ls: 0.35, lr: 0.3) };
// a Bounce hit: [chord degrees, gain, filter and snap, envelope, strum per note in 16ths]
var bounce = { |kit, base, degs, v, len, swing|
	var lift = v > 1.5, vel = if(lift) { v - 1 } { v }, acc = vel >= 0.9, ghost = vel < 0.7;
	var ds = if(lift) { degs + 1 } { degs };
	case
	{ ghost } { [ds.keep(3), 0.3, base ++ (lo: 350, hi: 4000, lpenv: 1.2, ld: 0.08, ls: 0.15, at: swing),
		kit[\adsr].(0.002, 0.09, 0.15, 0.08) ++ (hold: 0.6), 0] }
	{ acc } { [ds, 0.62, base ++ (lpq: 2.6, lpenv: 3.6, ld: 0.14, ls: 0.25, shape: 0.18, penv: 0.35, pd: 0.03,
		ps: 0.001, at: swing), kit[\adsr].(0.002, 0.25, 0.35, 0.12 + (0.5 * len)) ++ (hold: 1.2 + (5 * len)), 0.05] }
	{ [ds, 0.45, base ++ (lpenv: 2, ld: 0.12, at: swing),
		kit[\adsr].(0.002, 0.18, 0.3, 0.1 + (0.4 * len)) ++ (hold: 1 + (4 * len)), 0] }
};
(
states: (room: 0.9 * 0.3, echo: 0.1),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.3 + (0.6 * s)), send);
	col.setState(\echo, if(col.held(\b2)) { 0.85 } { 0.1 + (0.35 * s) }, send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, s16 = k % 16, pat = col[\patLatch].atBar(b), r = rhythms[pat], len = col.knob(\k3);
	var mood = tr.chapterAt(b), root = fr.rootAt(tr, b);
	var v, env, degs, hit, pan, out = List[];
	st[\rows] = st[\rows] ?? { rhythms.collect { |x| x.collect(kit[\line]) } };
	v = if(r.isEmpty) { nil } { st[\rows][pat][b % r.size][s16] };
	v !? {
		degs = chords[b % chords.size];
		pan = { |i, n| 0.5 + (0.3 * ((i / (n - 1)) - 0.5)) };
		if(pat == 0) {
			hit = bounce.(kit, filter.(ce, col, kit, if(v > 1.5) { v - 1 } { v }), degs, v, len,
				if(s16.odd) { 0.1 } { 0 });
			hit[0].do { |d, i| var m = fr.degMidi(d + root, 3, mood);
				out.addAll(voice.(kit, m, hit[1], hit[2] ++ (at: hit[2][\at] + (i * hit[4])), hit[3],
					pan.(i, hit[0].size))) }
		} {
			env = if(pat == 3) { kit[\adsr].(0.35, 1.5, 0.7, 0.8 + (1.2 * len)) ++ (hold: 12 + (4 * len)) } {
				kit[\adsr].(0.005, 0.5, 0.5, 0.25 + len) ++ (hold: 1 + (11 * len)) };
			degs.do { |d, i| var m = fr.degMidi(d + root, 3, mood);
				out.addAll(voice.(kit, m, 0.5 * v, filter.(ce, col, kit, v), env, pan.(i, degs.size))) }
		}
	};
	out
},
keys: { |col, note, vel|
	var ce = col[\ce], kit = ce.kitOf(col), len = col.knob(\k3);
	var env = kit[\adsr].(0.004, 0.7, 0.55, 0.4 + (1.2 * len)) ++ (hold: 2 + (14 * len));
	voice.(kit, note, 0.4 + (0.9 * vel), filter.(ce, col, kit, vel) ++ (lane: \keys), env, 0.5)
}
)
)
