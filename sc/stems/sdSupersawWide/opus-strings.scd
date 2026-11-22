// Column code of the opus strings (016): the JX-10 strings (wide supersaws) on an open F minor (F4 C5 F5 A flat 5), a new note
// every 2 bars; each move changes one voice (five moves, 8 bars). Tension brings them in (silent below 0.2, full from 0.7: a
// map on the strip, at once; below 0.2 the notes run silently and stay out of the log). Swell (row 3) is the attack, 0.35
// ... 2.55 s. Button 2 throws an echo. Space scales the room from 0.3.
(
states: (room: 0.9 * 0.3, echo: 0),
maps: (trim: (ccs: [36], fn: { |t| 0.7 * ((t - 0.2) / 0.5).clip(0, 1) })),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| col.setState(\room, 0.9 * (0.3 + (0.7 * col.knob(\k2))), send);
	col.setState(\echo, if(col.held(\b2)) { 0.85 } { 0 }, send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], b = (k / 16).floor, out = List[];
	var sIn = kit[\ramp].(ce.val(tr.global.tension), 0.2, 0.7), lp, env, adsr = kit[\adsr];
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
		env = adsr.(0.35 + (2.2 * col.knob(\k3)), 0.1, 1, 0.8);
		st[\moves][col[\patLatch].atBar(b)].do { |voice|
			var m = voice[(b % 8 / 2).floor];
			[[0, 0.08, 0.6, 0.5], [0.1, 0.05, 0.9, 0.3]].do { |x|
				out.add(ce.note(\sdSupersawWide, (freq: (m + x[0]).midicps, unison: 2, dtn: x[1], spread: x[2], amp: x[3] * 0.24,
					thinF: kit[\thin], tag: "supersaw", g: x[3] * 0.24 * sIn, midi: m + x[0], nolog: sIn <= 0) ++ lp ++ env)) };
		};
		out
	}
}
)
