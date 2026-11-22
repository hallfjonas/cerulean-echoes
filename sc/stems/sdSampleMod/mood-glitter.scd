// Column code of the ambient glitter (007): VCSL glockenspiel at random on the 16ths on the chapter's scale. Complexity (row 3):
// a drop now and then (about one per bar) up to a sparkling rain (about 70 % of the 16ths). Button 1 = high, very high, middle
// register (new notes each time). Button 2 (Run) = scale runs in 32nds, denser while held, on their own lane with their own echo.
(
var fx = ~ce.moodFx;
(
states: (glitEcho: 0, glitRunEcho: 0),
strip: (space: \k2, lanes: [(name: \main, echoSend: \glitEcho), (name: \run, echoSend: \glitRunEcho)]),
update: { |col, send| fx.echoSend(col, send, \glitEcho, 0.55); fx.echoSend(col, send, \glitRunEcho, 0.4) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.moodOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16;
	var v = col[\patLatch].atBar(b), octs = [5, 6, 4], oct = octs[v], out = List[], r, keep, rr, mood = fr.moodAt(tr, b);
	var tones = [0, 1, 2, 4, 5, 7, 8, 9, 11], run = [0, 1, 2, 4, 5, 7, 8, 9, 11, 9, 8, 7, 5, 4, 2, 1];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 3000, hi: 16000, tone: kit[\tone], hold: 1) ++ kit[\adsr].(nil, nil, nil, 1.2);
	var glock = { |m, g, args| var pick = kit[\vcslPick].(\glockenspiel, m);
		kit[\smp].(pick[0], "glockenspiel", g, lp ++ (rate: pick[1], midi: m) ++ args) };
	r = ce.rand(t + kit[\seed].(col[\patLatch], b)); keep = 0.06 + (0.64 * col.knob(\k3));
	if(r >= (1 - keep)) { out.add(glock.(fr.degMidi(tones[(9 * r).trunc], oct, mood), 0.15 + (0.25 * r), (pan: r))) };
	if(col.held(\b2)) { st[\glitStart] = st[\glitStart] ? t.floor } { st[\glitStart] = nil };
	if(st[\glitStart].notNil) {
		rr = ((t.floor - st[\glitStart]) / 2).clip(0, 1);
		2.do { |j| var u = t + (j / 32), ru = ce.rand(u);
			if(ru >= (0.85 - (0.75 * rr))) {
				out.add(glock.(fr.degMidi(run[((k * 2) + j) % 16], oct, mood), (0.2 + (0.3 * rr)) * (0.7 + (0.3 * ce.rand(t.floor))),
					(at: j / 2, hold: 0.5, pan: 0.3 + (0.4 * ce.sine(u * 2)), lane: \run))) } }
	};
	out
}
)
)
