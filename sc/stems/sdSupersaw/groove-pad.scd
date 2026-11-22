// Column code of the groove pad (001, 002): an 80s chorus pad (supersaw, slow attack), one chord per bar (7, 9, Sus,
// Fifths). Tension brings it in (a map on the strip, at once). Movement sweeps the filter over 8 bars; button 2 throws
// an echo. Space scales the room from 0.3.
(
states: (room: 0.9 * 0.3, echo: 0),
maps: (trim: (ccs: [36], fn: { |t| 0.3 + (0.7 * (t / 0.5).clip(0, 1)) })),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send|
	col.setState(\room, 0.9 * (0.3 + (0.7 * col.knob(\k2))), send);
	col.setState(\echo, if(col.held(\b2)) { 0.8 } { 0 }, send)
},
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, pin = 0.3 + (0.7 * kit[\ramp].(ce.val(tr.global.tension), 0, 0.5)), lp;
	var shapes = [[0, 2, 4, 6], [0, 2, 4, 6, 8], [0, 3, 4, 7], [0, 4, 7]];
	if((k % 16) != 0) { [] } {
		lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 300, hi: 6000, tone: kit[\tone],
			cutMul: 1 + (col.knob(\k3) * 0.8 * sin(2pi * b / 8)), hold: 16) ++ kit[\adsr].(0.8, nil, 0.9, 1.6);
		fr.tonesAt(tr, b, shapes[col[\patLatch].atBar(b)], 3).collect { |m|
			ce.note(\sdSupersaw, (freq: m.midicps, unison: 3, detune: 0.15, spread: 0.8, amp: 0.41, thinF: kit[\thin],
				tag: "supersaw", g: 0.41 * pin, midi: m) ++ lp) }
	}
}
)
