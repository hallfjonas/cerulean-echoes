// Column code of the lsd-fx zaps (017-lsd-fx): laser zaps on the left, one figure per 8-bar phrase, in its 2nd bar; Rate
// (row 3) adds the figure in the 6th, 4th and 8th bar. Button 1: eight figures (pew, zip, pew pew, triplet, bounce, dive,
// chirp, one of them at random each phrase), pitched on the mood's scale. Button 2 (Ping-pong): the figure in every bar,
// each zap echoing right, left, right in dotted 8ths. Space scales room (from 0.2) and echo (from 0.2).
(
// [16th in the bar, kind, degree]
var figs = [
	[[6, \down, 0]],
	[[10, \up, 0]],
	[[4, \down, 0], [7, \down, 2]],
	[[8, \down, 0], [9.333, \down, 2], [10.667, \down, 4]],
	[[4, \bounce, 0], [7, \bounce, 2], [9, \bounce, 4], [10.5, \bounce, 7], [11.5, \bounce, 9]],
	[[2, \dive, 0]],
	[[2, \chirp, 0], [14, \chirp, 4]]
];
(
states: (room: 0.9 * 0.2, echo: 0.2),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.2 + (0.6 * s)), send); col.setState(\echo, 0.2 + (0.5 * s), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16;
	var adsr = kit[\adsr], syn = kit[\syn], held = col.held(\b2), out = List[];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 2500, hi: 14000, tone: kit[\tone]);
	var slots = [1, 5, 3, 7].keep(1 + (col.knob(\k3) * 3.99).floor.asInteger);
	var figAt = { |bb| var v = col[\patLatch].atBar(bb);
		figs[if(v < figs.size) { v } { (ce.rand((bb / 8).floor + 0.31) * figs.size).trunc.asInteger }] };
	var hitsAt = { |kk| var bb = (kk / 16).floor;
		if(held or: { slots.includes((bb % 8).asInteger) }) { figAt.(bb).select { |h| h[0].floor == (kk % 16) }.collect { |h| [h, bb] } } { [] } };
	var zap = { |h, bb, g, pan| var m = { |o| fr.degMidi(h[2], o, tr.chapterAt(bb)) }, a = lp ++ (at: h[0] % 1, pan: pan);
		switch(h[1],
			\down, { syn.(\square, m.(5), g, a ++ (hold: 1, penv: 24, pd: 0.12, ps: 0.001, lpq: 6) ++ adsr.(0.001, 0.14, 0, 0.03)) },
			\up, { syn.(\sawtooth, m.(4), g, a ++ (hold: 1, penv: -24, pd: 0.1, ps: 0.001, lpq: 6) ++ adsr.(0.001, 0.12, 0, 0.03)) },
			\bounce, { syn.(\sine, m.(6), g, a ++ (hold: 1, fmi: 2, fmh: 2, penv: 12, pd: 0.05, ps: 0.001) ++ adsr.(0.001, 0.08, 0, 0.02)) },
			\dive, { syn.(\sawtooth, m.(5), 0.7 * g, a ++ (hold: 8, penv: 36, pd: 1.4, ps: 0.001, lpq: 10, lo: 1200, hi: 6000)
				++ adsr.(0.002, 1.6, 0, 0.3)) },
			\chirp, { syn.(\sine, m.(6), g, a ++ (hold: 1, fmi: 3, fmh: 1.5, penv: -12, pd: 0.06, ps: 0.001) ++ adsr.(0.001, 0.1, 0, 0.02)) }) };
	hitsAt.(k).do { |x| out.add(zap.(x[0], x[1], 0.22, 0.1 + (0.2 * ce.rand(k + 0.7)))) };
	if(held) { (1..3).do { |j| hitsAt.(k - (3 * j)).do { |x|
		out.add(zap.(x[0], x[1], 0.22 * (0.55 ** j), [0.12, 0.88][j % 2])) } } };
	out
}
)
)
