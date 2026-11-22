// Column code of the ambient bass (010): a triangle + a quiet saw 0.07 semitone below on the low chord root, a soft filter pluck
// and a little drive (Rolling, Off-beat, Melodic). Complexity (row 3) rolls extra 16th notes in between; button 2 an octave
// up. Out in the Break. Room, no echo.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\bass]),
strip: (roomR: \bassRoom),
update: { |col, send| fx.apply(col, send, \bass) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, l, s16 = k % 16, c = col.knob(\k3), out = List[], lp, note, fe;
	var line = kit[\line];
	st[\lines] = st[\lines] ?? { [["[~ 0 0 ~] [~ 0 0 ~] [~ 0 0 ~] [~ 0 4 ~]", "[~ ~ ~ 0]*4"], ["[~ 0]*4", "[~ ~ ~ 0]*4"],
		["[0 ~ ~ 0] [~ ~ 4 ~] [~ 0 ~ ~] [2 ~ 4 ~]", "[~ 0 ~ ~]*4"]].collect { |l| l.collect { |x|
			var v = if(x.endsWith("*4")) { (line.(x.drop(-2)) ! 4).flatten } { line.(x) };
			if(v.size == 8) { v.collect { |y| [y !? { [y, 2] }, nil] }.flatten } { v.collect { |y| y !? { [y, 1] } } } } } };
	fr.rootAt(tr, b);
	if(tr.breakAt(b)) { [] } {
		l = st[\lines][col[\patLatch].atBar(b)];
		fe = ce.sdADSR(nil, 0.15, 0, nil, [0.005, 0.14, 0, 0.1]);
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 250, hi: 2000, tone: kit[\tone], lpq: 3, lpenv: 1.5, la: fe[0], ld: fe[1], ls: fe[2],
			lr: fe[3], shape: 0.2) ++ kit[\adsr].(0.004, 0.2, 0.35, 0.07);
		note = { |x, g| var m = fr.degMidi(x[0] + fr.lowAt(tr, b), 2) + if(col.held(\b2)) { 12 } { 0 };
			[kit[\syn].(\triangle, m, g, lp ++ (hold: x[1])), kit[\syn].(\sawtooth, m - 0.07, g * 0.35, lp ++ (hold: x[1]))] };
		l[0][s16] !? { |x| out.addAll(note.(x, 0.5)) };
		if(c > 0) { l[1][s16] !? { |x| out.addAll(note.(x, 0.35 * c)) } };
		out
	}
}
)
)
