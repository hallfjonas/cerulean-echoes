// Column code of the ambient deep chords (010): rootless 3rd, 5th, 7th and 9th above the root (D3) as FM e-piano stabs (+ a
// triangle) on the pattern's 16ths: eight deep-house rhythms. Length (row 3): long ringing chords <-> short choppy stabs. Button
// 2 (Stab): a chord on every off-beat while held, on its own lane with its own room and echo. Brightness is the filter.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\keys, \keys2]),
strip: (lanes: [(name: \main, roomR: \keysRoom, echoSend: \keysEcho), (name: \off, roomR: \keys2Room, echoSend: \keys2Echo)]),
update: { |col, send| fx.apply(col, send, \keys); fx.apply(col, send, \keys2) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16, r, len = 1.2 * (0.1 ** col.knob(\k3)), out = List[];
	var adsr = kit[\adsr], syn = kit[\syn];
	var chord = { |lane, hold = 1| [2, 4, 6, 8].do { |d| var m = fr.degMidi(d + fr.rootAt(tr, b), 3), env = adsr.(0.005, len, 0.05, 0.6 * len);
		var lp = (lpOn: 1, bright: col.knob(\k1), lo: 600, hi: 8000, tone: kit[\tone], hold: hold, shape: 0.1, pan: 0.45, lane: lane);
		out.add(syn.(\sine, m, 0.32, lp ++ env ++ (fmi: 0.7, fmh: 1, modPhase: kit[\modPhase].(k, 0, m.midicps, tr.bpm))));
		out.add(syn.(\triangle, m, 0.14, lp ++ env)) } };
	st[\rh] = st[\rh] ?? { ["~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ ~", "x ~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~", "~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ x ~",
		"x ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~", "~ ~ ~ x ~ ~ ~ x ~ ~ ~ ~ ~ ~ x ~", ["x ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~"],
		"~ x ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~ ~", "x ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~ ~ ~"].collect { |r| (if(r.isString) { [r] } { r }).collect { |x| x.split($ ).collect(_ == "x") } } };
	fr.rootAt(tr, b);
	r = st[\rh][col[\patLatch].atBar(b)];
	if(r[b % r.size][s16]) { chord.(\main) };
	if(col.held(\b2) and: { (s16 % 4) == 2 }) { chord.(\off, 2) };
	out
}
)
)
