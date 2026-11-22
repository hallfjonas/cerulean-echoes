// Column code of the opus pads (016): one pad (two detuned saws + a triangle), held chords (Pump 0 ... 1) or chords pumped on
// every beat (Pump 0.5 ... 1) on the frame's chords and mood. Tension brings it in (30 % -> full: a map on the strip, at
// once). Button 1 is the progression for everybody (the frame), button 2 the chord colour. Space scales the room from 0.3.
(
states: (room: 0.9 * 0.3),
maps: (trim: (ccs: [36], fn: { |t| 1.2 * (0.3 + (0.7 * (t / 0.5).clip(0, 1))) })),
strip: (roomR: \room),
update: { |col, send| col.setState(\room, 0.9 * (0.3 + (0.7 * col.knob(\k2))), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var out = List[], p = col.knob(\k3), fm = kit[\ramp].(p, 1, 0.5), fx = kit[\ramp].(p, 0, 0.5), adsr = kit[\adsr], syn = kit[\syn];
	var pin = 0.3 + (0.7 * kit[\ramp].(ce.val(tr.global.tension), 0, 0.5)), notes, lp, layer, sp, tp;
	if((s16 % 4) != 0) { [] } {
		notes = fr[\padColours][tr.colour.atBar(b)][1].collect { |d| fr.degMidi(d + fr.rootAt(tr, b), 3, tr.chapterAt(b)) };
		lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 250, hi: 6000, tone: kit[\tone]);
		sp = 0.15 + (0.7 * ce.sine(t / 5)); tp = 0.85 - (0.7 * ce.sine(t / 5));
		layer = { |m, g, env| [0, 0.1].collect { |dm| syn.(\sawtooth, m + dm, 0.045 * g, lp ++ (pan: sp) ++ env) ++ (g: 0.045 * g * pin) }
			++ [syn.(\triangle, m, 0.08 * g, lp ++ (pan: tp) ++ env) ++ (g: 0.08 * g * pin)] };
		if(fm > 0 and: { s16 == 0 }) { notes.do { |m| out.addAll(layer.(m, fm, (hold: 16) ++ adsr.(0.9, nil, 0.8, 2))) } };
		if(fx > 0) { notes.do { |m| out.addAll(layer.(m, fx, (hold: 4) ++ adsr.(0.06 + (0.14 * p), nil, 1, 0.04))) } };
		out
	}
}
)
