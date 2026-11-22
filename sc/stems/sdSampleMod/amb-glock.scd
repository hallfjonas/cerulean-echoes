// Column code of the ambient glockenspiel (010): VCSL glockenspiel on chord tones above the root (D5) on random 16ths, struck as
// by hand: eight random patterns. Complexity (row 3): from a few notes per bar to a busy pattern (about 60 % of the 16ths).
// Button 2 (Run): chord runs, denser while held, on their own lane with their own room and echo.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\bells, \run]),
strip: (lanes: [(name: \main, roomR: \bellsRoom, echoSend: \bellsEcho), (name: \run, roomR: \runRoom, echoSend: \runEcho)]),
update: { |col, send| fx.apply(col, send, \bells); fx.apply(col, send, \run) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, out = List[];
	var r = ce.rand(t + (1024 * col[\patLatch].atBar(b))), keep = 0.1 + (0.5 * col.knob(\k3)), rr;
	var tones = [0, 2, 4, 6, 7, 9, 11], run = [0, 2, 4, 6, 7, 9, 11, 13, 14, 13, 11, 9, 7, 6, 4, 2];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 3000, hi: 16000, tone: kit[\tone]);
	fr.rootAt(tr, b);
	if(r >= (1 - keep)) { out.add(kit[\glock].(fr.degMidi(tones[(7 * r).trunc] + fr.rootAt(tr, b), 5), 0.45 + (0.4 * r), lp ++ (pan: 0.25 + (0.5 * r)))) };
	if(col.held(\b2)) { st[\bellStart] = st[\bellStart] ? t.floor } { st[\bellStart] = nil };
	if(st[\bellStart].notNil) {
		rr = ((t.floor - st[\bellStart]) / 2).clip(0, 1);
		2.do { |j| var u = t + (j / 32);
			if(ce.rand(u) >= (0.85 - (0.75 * rr))) {
				out.add(kit[\glock].(fr.degMidi(run[((k * 2) + j) % 16] + fr.rootAt(tr, b), 5), (0.35 + (0.55 * rr)) * (0.7 + (0.3 * ce.rand(t.floor))),
					lp ++ (at: j / 2, hold: 0.5, pan: 0.3 + (0.4 * ce.sine(u * 2)), lane: \run))) } }
	};
	out
}
)
)
