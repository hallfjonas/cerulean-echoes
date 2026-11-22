// Column code of the groove rumble (002): not the kick's tail but its echo in the room: a sine that drops a little in
// pitch, through a dark reverb (orbit 4). Pulse, Roll, Bounce; Motion (row 3) makes the filter up to 27.5 % darker (Strudel
// reads its sine at the bar start, where it is 0); button 2 (Swell) makes it longer and louder. Out in the Break. Space
// scales the room from 0.35.
(
states: (room: 0.9 * 0.35),
strip: (roomR: \room),
update: { |col, send| col.setState(\room, 0.9 * (0.35 + (0.5 * col.knob(\k2))), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, out = List[], held = col.held(\b2);
	st[\pats] = st[\pats] ?? { ["[~ ~ x ~]*4", "[~ x ~ x]*4", "<[~ ~ x ~]*4 [~ x ~ x]*4>"].collect(kit[\table]) };
	if(col[\track].breakAt(b).not) {
		kit[\eventsAt].(st[\pats][col[\patLatch].atBar(b)], k).do { |e|
			var mv = 1 - (0.55 * col.knob(\k3) * (0.5 + (0.5 * sin(pi * b))));
			out.add(kit[\syn].(\sine, 38, if(held) { 1.35 } { 1 }, (lpOn: 1, bright: col.knob(\k1), lo: 120 * mv, hi: 600 * mv,
				tone: kit[\tone], penv: 5, pd: 0.04, at: e[0], hold: e[1]) ++ kit[\adsr].(0.006, if(held) { 0.4 } { 0.18 }, 0, 0.06)))
		}
	};
	out
}
)
