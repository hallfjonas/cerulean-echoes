// Column code of the ambient marimba (010): a sine + a partial two octaves up, a phrase at the end of every second bar on
// random chord tones (new ones per change): eight phrase rhythms. Complexity (row 3): one voice, + a third above, + a fifth
// (three-part marimba). Button 2 (Answer): the phrase plays in every bar while held. Echo and room from Space (0.35 ... 1).
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\ans]),
strip: (roomR: \ansRoom, echoSend: \ansEcho),
update: { |col, send| fx.apply(col, send, \ans) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var v = col[\patLatch].atBar(b), c = col.knob(\k3), out = List[], tn, tones = [0, 2, 4, 6, 7], ramp = kit[\ramp];
	st[\rh] = st[\rh] ?? { ["~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x x ~",
		"~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~ x", "~ ~ ~ ~ ~ ~ x ~ ~ ~ x ~ ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ ~ ~ ~ ~",
		"~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x ~ x ~ ~", "~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~ ~ ~ x x"].collect { |r| r.split($ ).collect(_ == "x") } };
	fr.rootAt(tr, b);
	if(st[\rh][v][s16].not or: { col.held(\b2).not and: { (b % 2) == 0 } }) { [] } {
		tn = tones[(5 * ce.rand(t + (1024 * v))).trunc];
		[[0, 0.6], [2, if(c > 0) { 0.5 * ramp.(c, 0, 0.5) } { 0 }], [4, if(c > 0.5) { 0.42 * ramp.(c, 0.5, 1) } { 0 }]].do { |x|
			if(x[1] > 0) { var m = fr.degMidi(tn + x[0] + fr.rootAt(tr, b), 4);
				var lp = (lpOn: 1, bright: col.knob(\k1), lo: 1200, hi: 9000, tone: kit[\tone], hold: 1, pan: [0.3, 0.7][s16 % 2])
					++ kit[\adsr].(0.002, 0.22, 0, 0.1);
				out.add(kit[\syn].(\sine, m, x[1], lp)); out.add(kit[\syn].(\sine, m + 24, x[1] * 0.15, lp)) } };
		out
	}
}
)
)
