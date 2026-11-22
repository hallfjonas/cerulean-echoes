// Column code of the ambient rim (007): a short triangle blip with a breath of white noise on the backbeat. Complexity (row 3)
// adds quiet clicks on random 16ths. Button 1 = backbeat, late ghost, offset click. Button 2 = a 16th roll growing over the
// bar while held. Sits out the Break.
(
var fx = ~ce.moodFx;
(
states: (echo: 0),
strip: (space: \k2, echoSend: \echo),
update: { |col, send| fx.echoSend(col, send, \echo, 0.25) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.moodOf(col), b = (k / 16).floor, t = k / 16, s16 = k % 16, c = col.knob(\k3), hits = List[], x, r, out = List[], lp;
	var rims = [Dictionary[4 -> [0.5, 4], 12 -> [0.5, 4]], Dictionary[4 -> [0.5, 4], 12 -> [0.5, 1], 15 -> [0.3, 1]],
		Dictionary[6 -> [0.5, 2], 12 -> [0.5, 4]]];
	x = rims[col[\patLatch].atBar(b)][s16]; x !? { hits.add(x) };
	r = ce.rand(t + kit[\seed].(col[\patLatch], b));
	if(c > 0 and: { r >= (1 - (0.4 * c)) }) { hits.add([0.08 + (0.1 * r), 1]) };
	if(col.held(\b2)) { hits.add([0.1 + (0.35 * (t % 1)), 1]) };
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 1200, hi: 12000, tone: kit[\tone], pan: 0.45);
	hits.do { |h|
		out.add(kit[\syn].(\triangle, 81, h[0], lp ++ (hold: h[1]) ++ kit[\adsr].(nil, 0.045, 0, nil)));
		out.add(kit[\noise].(1, h[0] * 0.5, lp ++ (hold: h[1], hp: 2500) ++ kit[\adsr].(nil, 0.012, 0, nil)));
	};
	out
}
)
)
