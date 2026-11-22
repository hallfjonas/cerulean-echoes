// Column code of the ambient sub (010): a sine + a triangle on the low chord root (A, B flat, C an octave down), a 16th after the
// kick: Pump, Off-beat, Long (one note per bar). Length (row 3) is the clip; button 2 an octave up. Out in the Break. Room,
// no echo.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\sub]),
strip: (roomR: \subRoom),
update: { |col, send| fx.apply(col, send, \sub) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, v = col[\patLatch].atBar(b), s16 = k % 16, len, m, clip, env;
	fr.rootAt(tr, b);
	len = switch(v, 0, { if((s16 % 4) == 1) { 3 } }, 1, { if((s16 % 4) == 2) { 2 } }, 2, { if(s16 == 1) { 15 } });
	if(tr.breakAt(b) or: { len.isNil }) { [] } {
		m = fr.degMidi(fr.lowAt(tr, b), 2) + if(col.held(\b2)) { 12 } { 0 };
		clip = 1 - (0.65 * col.knob(\k3));
		env = (hold: len * clip) ++ kit[\adsr].(0.015, nil, 1, 0.04);
		[kit[\syn].(\sine, m, 0.5, env), kit[\syn].(\triangle, m, 0.1 + (0.17 * col.knob(\k1)), env)]
	}
}
)
)
