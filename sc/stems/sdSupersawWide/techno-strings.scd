// Column code of the techno strings (008): background strings on an open F minor (F4 C5 F5 A flat 5), a new note every 2
// bars; each move changes one voice (five moves, 8 bars). Sound (row 3) fades JX-10 strings (wide supersaws) <-> analogue
// strings (squares, saw, triangle), equal power, a lane each: it acts at once. Button 2 throws an echo. Space scales the
// room from 0.3. Brightness acts at once.
(
states: (room: 0.9 * 0.3, echo: 0, jx: 1, analog: 0),
strip: (roomR: \room, echoSend: \echo, lanes: [(name: \jx, fade: \jx), (name: \analog, fade: \analog)]),
update: { |col, send| var v = col.knob(\k3);
	col.setState(\room, 0.9 * (0.3 + (0.7 * col.knob(\k2))), send);
	col.setState(\echo, if(col.held(\b2)) { 0.85 } { 0 }, send);
	col.setState(\jx, cos(v * pi / 2) * (v < 0.999).binaryValue, send);
	col.setState(\analog, sin(v * pi / 2) * (v > 0.001).binaryValue, send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, out = List[], v = col.knob(\k3);
	var cv = cos(v * pi / 2), sv = sin(v * pi / 2), lp, env, an, adsr = kit[\adsr];
	st[\moves] = st[\moves] ?? { var hold = { |m| [[m, 4]] };
		[
			[hold.(65), [[72, 3], [73, 1]], hold.(77), hold.(80)],
			[[[65, 3], [63, 1]], hold.(72), [[77, 3], [75, 1]], hold.(80)],
			[hold.(65), [[72, 1], [73, 1], [74, 1], [73, 1]], hold.(77), hold.(80)],
			[hold.(65), hold.(72), [[77, 1], [76, 1], [75, 1], [74, 1]], hold.(80)],
			[hold.(65), [[72, 1], [73, 2], [72, 1]], hold.(77), [[80, 2], [82, 1], [80, 1]]],
		].collect { |mv| mv.collect { |vo| vo.collect { |x| x[0] ! x[1] }.flatten } } };
	if(k % 32 != 0) { [] } {
		lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 500, hi: 7000, tone: kit[\tone], hold: 32);
		st[\moves][col[\patLatch].atBar(b)].do { |voice|
			var m = voice[(b % 8 / 2).floor];
			if(v < 0.999) {
				env = adsr.(0.35, 0.1, 1, 0.8) ++ (lane: \jx);
				[[0, 0.08, 0.6, 0.5], [0.1, 0.05, 0.9, 0.3]].do { |x|
					out.add(ce.note(\sdSupersawWide, (freq: (m + x[0]).midicps, unison: 2, dtn: x[1], spread: x[2], amp: x[3] * 0.24,
						thinF: kit[\thin], tag: "supersaw", g: x[3] * 0.24 * cv, midi: m + x[0]) ++ lp ++ env)) } };
			if(v > 0.001) {
				an = lp ++ adsr.(0.45, 0.1, 1, 1) ++ (vib: 5, vibmod: 0.04, lpq: 2, lane: \analog);
				[[\square, 0, 0.045, 0.4], [\square, 0.09, 0.045, 0.6], [\sawtooth, 12.06, 0.025, -1], [\triangle, -12, 0.035, -1]].do { |x|
					out.add(kit[\syn].(x[0], m + x[1], x[2], an ++ (pan: x[3])) ++ (g: x[2] * sv)) } };
		};
		out
	}
}
)
