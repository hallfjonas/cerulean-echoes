// Column code of the ambient pad (010): detuned saws + a triangle on the chapter's 7th and 9th chords, struck every bar: voicing
// Warm, Open (9th), Wide. Swell (row 3): the chord's level dips with a slow sine (2 bars). Button 2 (Freeze) holds the
// current chord for everybody while held (the frame). Brightness acts at once.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\pad]),
strip: (roomR: \padRoom, echoSend: \padEcho),
update: { |col, send| fx.apply(col, send, \pad) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, out = List[], sw, lp;
	var voicings = [[0, 2, 4, 6], [2, 4, 6, 8], [-7, 4, 6, 9]], adsr = kit[\adsr], syn = kit[\syn];
	fr.rootAt(tr, b);
	if((k % 16) != 0) { [] } {
		sw = 1 - (0.75 * col.knob(\k3) * ce.sine(t / 2));
		lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 300, hi: 5000, tone: kit[\tone], hold: 16, pan: 0.3 + (0.4 * ce.sine(t / 5)));
		voicings[col[\patLatch].atBar(b)].do { |d| var m = fr.degMidi(d + fr.rootAt(tr, b), 3);
			out.add(syn.(\sawtooth, m, 0.2 * sw, lp ++ adsr.(0.8, nil, 0.8, 1.8)));
			out.add(syn.(\sawtooth, m + 0.14, 0.2 * sw, lp ++ adsr.(0.8, nil, 0.8, 1.8)));
			out.add(syn.(\triangle, m, 0.25 * sw, lp ++ adsr.(0.8, nil, 0.8, 1.8))) };
		out
	}
}
)
)
