// Column code of the techno rumble (008): the kick's sound low-passed into a dark reverb (its own orbit), on the 3rd and 4th
// 16th of every beat (three patterns). Motion breathes the filter and adds a 16th echo. Button 2: a noise riser on its own
// lane (orbit 2, a fixed room) over 2 bars. Space scales the room 0.35 ... 0.8. Out in the Break (the riser plays on).
(
states: (room: 0.9 * 0.35, echo: 0),
strip: (lanes: [(name: \pump, orbit: 3, roomR: \room, echoSend: \echo), (name: \riser, orbit: 2, roomR: 0.9 * 0.3, echoSend: 0)]),
update: { |col, send| var s = 0.35 + (0.45 * col.knob(\k2)), m = col.knob(\k3);
	col.setState(\room, 0.9 * s, send); col.setState(\echo, (0.4 * m * 2 * s).min(0.9), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, out = List[], m, w, lp, r;
	var adsr = kit[\adsr], hits = [[2, 3], [1, 2, 3], [2]];
	if(col.held(\b2)) { st[\riserStart] = st[\riserStart] ? t.floor } { st[\riserStart] = nil };
	if(col[\track].breakAt(b).not and: { hits[col[\patLatch].atBar(b)].includes(k % 4) }) {
		m = col.knob(\k3); w = ce.sine(b / 2);
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 100, hi: 500, tone: kit[\tone], cutMul: 1 - (0.6 * m * w), lane: \pump);
		out.add(kit[\syn].(\sine, 36, 0.5 * 0.67, (hold: 1, penv: 12, pd: 0.05) ++ adsr.(nil, 0.3, 0, nil) ++ lp));
		out.add(kit[\smp].("tr909/bd-01.wav", "RolandTR909_bd:0", 0.2 * 0.67, lp, \sdSampleMod))
	};
	if(st[\riserStart].notNil) {
		r = ((t.floor - st[\riserStart]) / 2).clip(0, 1);
		if(r > 0) { out.add(ce.note(\sdNoise, (color: 0, amp: r * 1.4, hold: 1, lane: \riser, thinF: kit[\thin],
			bp: 300 * (20 ** r), bpq: 4, pan: ce.sine(t * 2), tag: "pink", g: r * 1.4) ++ adsr.(0.03, nil, 0.8, 0.15, [0.001, 0.05, 0.6, 0.01]))) }
	};
	out
}
)
