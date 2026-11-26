// Column code of the lsd-fx metal (017-lsd-fx): a metal hit (Dirt-Samples metal) played at other speeds, on the right and
// far away (big room), in the 5th bar of every 8-bar phrase. Weight (row 3): light ting ↔ slow heavy clang with a low FM
// gong under the first hit. Button 1: eight figures (clank, ting, gong, scrape, chain, crash swell, anvil, a new one each
// phrase). Button 2 (Reverse): the figure in every bar, played backwards, while held. Space scales room (from 0.4) and
// echo (from 0.15).
(
var metal = "dirt/metal-00.wav", crash = "tr909/cr-00.wav";
// [16th in the bar, speed (below 0: backwards), level, file, drive]
var figs = [
	[[4, 0.5, 1]],
	[[6, 1.5, 0.7], [9, 1.8, 0.5]],
	[[0, 0.3, 1]],
	[[0, -0.5, 0.8]],
	[[10, 1, 0.6], [10.5, 0.9, 0.5], [11, 0.8, 0.6], [12, 0.6, 0.8]],
	[[0, -0.6, 0.5, crash]],
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
	var fig = figs[if(v < figs.size) { v } { (ce.rand((b / 8).floor + 0.71) * figs.size).trunc.asInteger }];
	if(held or: { (b % 8) == 4 }) {
		fig.do { |h, i| if(h[0].floor == s16) {
			var file = h[3] ? metal, r = ce.rand(k + 0.37), rate = h[1] * (1 - (0.5 * w)) * if(held) { -1 * h[1].sign } { 1 };
			var a = (lpOn: 1, bright: col.knob(\k1), lo: 3000, hi: 18000, tone: kit[\tone], at: h[0] % 1, pan: 0.68 + (0.24 * r));
			out.add(kit[\smp].(file, file.basename, 0.5 * h[2], a ++ (rate: rate, shape: h[4] ? 0), \sdSampleMod));
			if(i == 0 and: { w > 0 }) { out.add(kit[\syn].(\sine, fr.degMidi(0, 2, tr.chapterAt(b)), 0.3 * w,
				a ++ (hold: 8, fmi: 1.5, fmh: 1.414, penv: 2, pd: 0.3, ps: 0.001) ++ kit[\adsr].(0.005, 2.5, 0, 0.5))) } } } };
	out
}
)
)
