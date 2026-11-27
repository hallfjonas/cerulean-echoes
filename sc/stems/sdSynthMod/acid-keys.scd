// Column code of the acid keys (018-acid-tech-house): soft synth keys, two detuned saws with a slow vibrato (left and
// right), a triangle an octave up and an FM tine on the attack, through a low-pass that opens on the hit and settles.
// Chords of the mood's scale on the root in a 4-bar cycle (Fm9, Fm9, Dbmaj9, Eb9 in Dark; they follow the Chapter's
// mood). Patterns: off-beat stabs, a 2-bar comp, one swelling chord per bar, or silent (the Launchkey alone). Length
// (row 3): short stab ↔ long, ringing chord. Space scales room and echo; button 2 throws a long echo while held. The
// Launchkey keys play the same voice (keys, called by the frame): Brightness, Length and Space reach them, the column's
// Level does not (the mod wheel is their level).
(
var chords = [[0, 2, 4, 6, 8], [0, 2, 4, 6, 8], [-2, 0, 2, 4, 6], [-1, 1, 3, 5, 7]];
// a velocity per 16th ("~" = rest), one string per bar of the figure; the last pattern is silent
var rhythms = [
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
	var v, env, degs, out = List[];
	st[\rows] = st[\rows] ?? { rhythms.collect { |x| x.collect(kit[\line]) } };
	v = if(r.isEmpty) { nil } { st[\rows][pat][b % r.size][s16] };
	v !? {
		degs = chords[b % chords.size];
		env = if(pat == 2) { kit[\adsr].(0.35, 1.5, 0.7, 0.8 + (1.2 * len)) ++ (hold: 12 + (4 * len)) } {
			kit[\adsr].(0.005, 0.5, 0.5, 0.25 + len) ++ (hold: 1 + (11 * len)) };
		degs.do { |d, i| var m = fr.degMidi(d + root, 3, mood), pan = 0.5 + (0.3 * ((i / (degs.size - 1)) - 0.5));
			out.addAll(voice.(kit, m, 0.5 * v, filter.(ce, col, kit, v), env, pan)) }
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
