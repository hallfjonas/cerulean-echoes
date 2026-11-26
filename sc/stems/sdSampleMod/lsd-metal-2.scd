// Column code of the lsd-fx metal (017-lsd-fx-2): a metal hit (Dirt-Samples metal) played at other speeds, on the right
// and far away (big room), in the 5th bar of every 8-bar phrase. Weight (row 3): light ting ↔ slow heavy clang with a
// low FM gong under the first hit. Button 1: one of the six figures at random each phrase, then the six in turn (clank,
// ting, gong, scrape, chain, anvil). Button 2 (Rewind): the figure in every bar, played backwards, while held. Space
// scales room (from 0.4) and echo (from 0.15). The Launchkey keys play the same metal (keys, called by the frame): a key
// strikes a figure at its own pitch (C4 = the sample's own speed), a random one on every press while Pattern is on Random,
// else the chosen one. Brightness, Weight (a low gong under the hit), Space, Rewind and Pattern shape it live; the column's
// Level does not reach the keys, whose level is the mod wheel.
(
var metal = "dirt/metal-00.wav";
// [16th in the bar, speed (below 0: backwards), level, file, drive]
var figs = [
	[[4, 0.5, 1]],
	[[6, 1.5, 0.7], [9, 1.8, 0.5]],
	[[0, 0.3, 1]],
	[[0, -0.5, 0.8]],
	[[10, 1, 0.6], [10.5, 0.9, 0.5], [11, 0.8, 0.6], [12, 0.6, 0.8]],
	[[3, 0.8, 0.9, metal, 0.5], [11, 0.75, 0.9, metal, 0.5]]
];
(
states: (room: 0.9 * 0.4, echo: 0.15),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.4 + (0.6 * s)), send); col.setState(\echo, 0.15 + (0.45 * s), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16;
	var held = col.held(\b2), w = col.knob(\k3), out = List[], v = col[\patLatch].atBar(b);
	var fig = figs[if(v > 0) { v - 1 } { (ce.rand((b / 8).floor + 0.71) * figs.size).trunc.asInteger }];
	if(held or: { (b % 8) == 4 }) {
		fig.do { |h, i| if(h[0].floor == s16) {
			var file = h[3] ? metal, r = ce.rand(k + 0.37), rate = h[1] * (1 - (0.5 * w)) * if(held) { -1 * h[1].sign } { 1 };
			var a = (lpOn: 1, bright: col.knob(\k1), lo: 3000, hi: 18000, tone: kit[\tone], at: h[0] % 1, pan: 0.68 + (0.24 * r));
			out.add(kit[\smp].(file, file.basename, 0.5 * h[2], a ++ (rate: rate, shape: h[4] ? 0), \sdSampleMod));
			if(i == 0 and: { w > 0 }) { out.add(kit[\syn].(\sine, fr.degMidi(0, 2, tr.chapterAt(b)), 0.3 * w,
				a ++ (hold: 8, fmi: 1.5, fmh: 1.414, penv: 2, pd: 0.3, ps: 0.001) ++ kit[\adsr].(0.005, 2.5, 0, 0.5))) } } } };
	out
},
keys: { |col, note, vel|
	var ce = col[\ce], kit = ce.kitOf(col), w = col.knob(\k3), v = col[\patLatch].now, out = List[];
	var fig = figs[if(v > 0) { v - 1 } { figs.size.rand }], first = fig[0];
	var a = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 3000, hi: 18000, tone: kit[\tone], lane: \metal,
		pan: 0.3 + (0.4 * ((note - 48) / 36).clip(0, 1)));
	fig.do { |h, i| var file = h[3] ? metal, dir = if(col.held(\b2)) { -1 } { h[1].sign };
		var rate = dir * (h[1].abs / first[1].abs) * (2 ** ((note - 60) / 12)) * (1 - (0.5 * w)), at = (at: h[0] - first[0]);
		out.add(kit[\smp].(file, file.basename, 0.5 * h[2] * vel, a ++ at ++ (rate: rate, shape: h[4] ? 0), \sdSampleMod));
		if(i == 0 and: { w > 0 }) { out.add(kit[\syn].(\sine, (note - 24).max(24), 0.3 * w * vel,
			a ++ at ++ (hold: 8, fmi: 1.5, fmh: 1.414, penv: 2, pd: 0.3, ps: 0.001) ++ kit[\adsr].(0.005, 2.5, 0, 0.5))) } };
	out.asArray
}
)
)
