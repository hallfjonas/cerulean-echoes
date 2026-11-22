// Column code of the techno pads (008): a pad (two detuned saws + a triangle, slow attack) and a techno pad (three saws, left /
// middle / right) together on the frame's chords and mood. Pump (row 3) fades from held chords (struck once per bar) to
// chords struck on every beat, the attack growing with Pump. Button 1 is the progression for everybody (the frame),
// button 2 the chord colour (the frame's latch). Space scales the room from 0.3. Brightness acts at once.
(
states: (room: 0.9 * 0.3),
strip: (roomR: \room),
update: { |col, send| col.setState(\room, 0.9 * (0.3 + (0.7 * col.knob(\k2))), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var out = List[], p = col.knob(\k3), fm = kit[\ramp].(p, 1, 0.5), fx = kit[\ramp].(p, 0, 0.5), notes, lp, saws3, adsr = kit[\adsr], syn = kit[\syn];
	if((s16 % 4) != 0) { [] } {
		notes = fr[\padColours][tr.colour.atBar(b)][1].collect { |d| fr.degMidi(d + fr.rootAt(tr, b), 3, tr.chapterAt(b)) };
		lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 250, hi: 6000, tone: kit[\tone]);
		saws3 = { |m, g, args| [[0, 0.5], [0.12, 0.1], [-0.11, 0.9]].collect { |x| syn.(\sawtooth, m + x[0], g, lp ++ (pan: x[1]) ++ args) } };
		if(fm > 0 and: { s16 == 0 }) {
			var sp = 0.15 + (0.7 * ce.sine(t / 5)), tp = 0.85 - (0.7 * ce.sine(t / 5));
			notes.do { |m|
				[0, 0.1].do { |dm| out.add(syn.(\sawtooth, m + dm, 0.028 * fm, lp ++ (hold: 16, pan: sp) ++ adsr.(0.9, nil, 0.8, 2))) };
				out.add(syn.(\triangle, m, 0.056 * fm, lp ++ (hold: 16, pan: tp) ++ adsr.(0.6, nil, 0.8, 2)));
				out.addAll(saws3.(m, 0.0224 * fm, (hold: 16) ++ adsr.(0.5, nil, 1, 1.5)));
			}
		};
		if(fx > 0) {
			var env = adsr.(0.06 + (0.14 * p), nil, 1, 0.04) ++ (hold: 4);
			notes.do { |m|
				out.addAll(saws3.(m, 0.0224 * fx, env));
				out.add(syn.(\triangle, m, 0.056 * fx, lp ++ env));
			}
		};
		out
	}
}
)
