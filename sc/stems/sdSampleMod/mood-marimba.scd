// Column code of the ambient marimba (007; lab/harmony/midori-5, Takada): VCSL soft xylophone playing figures of scale degrees laid
// over each other, five patterns: cycles, canon, cells, Euclid, build-up. Complexity (row 3) brings the layers in one by one.
// Brightness also moves the level by plus or minus 2 dB. Button 2 = a long dotted-8th echo while held.
(
var fx = ~ce.moodFx, fkit = ~ce.figureKit;
(
states: (echo: 0.06, room: 0.225),
maps: (trim: (ccs: [\k1], fn: { |b| 1.3 * (10 ** (4 * (b - 0.5) / 20)) })),
strip: (roomR: \room, echoSend: \echo, trim: \trim),
update: { |col, send| fx.roomSend(col, send, \room); fx.echoSend(col, send, \echo, 0.12, true, true) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.moodOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t0 = k / 16;
	var kn = col.knob(\k3), ls, swell = 1, cm = 1, out = List[];
	var fk = st[\fk] ?? { var f = fkit, layer = f[\layer], padTo = f[\padTo], shift = f[\shift], euclid = f[\euclid];
		var c5 = ["4 ~ 7 ~ 9", 1, 0.3], c7 = ["0 ~ ~ 2 ~ 4 ~", 0, 0.7], anchor = ["0 ~ ~ ~ ~ ~ ~ ~ 4 ~ ~ ~ ~ ~ ~ ~", 0, 0.5];
		var sim = [[0, 1, 0.3], [2, 1, 0.7], [-3, 1, 0.5], [4, 0, 0.45]];
		var eu = { |list| list.collect { |x| layer.(euclid.(x[0], x[1], x[2], x[5] ? 0), x[3], x[4]) } };
		var build = [["0 ~ 4 7 ~ 4 2 ~", 1, 0.35], ["0 ~ 4 7 ~ 4 2 ~ ~", 1, 0.65], ["7 ~ ~ 9 ~ ~ 4", 1, 0.5],
			["0 ~ ~ ~ ~ ~ -3 ~ ~ ~", 0, 0.5], ["11 ~ ~ 9 ~ ~ ~ ~ ~ 7 ~", 2, 0.55, 0.35],
			["4 7 9 7 4 2 4 7 9 11", 1, 0.3, 0.35], ["7 9 11 9 7 4 7 9 11", 2, 0.7, 0.3]];
		var v = (
			zyklen: [c5, c7, anchor, ["7 ~ 4 ~ 2 ~ 4 ~ 6 ~ 4 ~", 1, 0.5], ["9 ~ 7 ~ 4 ~ ~ 6 ~ 4 ~", 1, 0.55],
				["2 ~ 4 ~ ~ 7 ~ ~ 11 ~ 9 ~ ~", 1, 0.45]].collect { |s| layer.(*s) },
			canon: [[0, 1, 0.3], [3, 1, 0.7], [5, 0, 0.5], [11, 2, 0.6]].collect { |x|
				layer.("7 ~ 6 4 ~ 2 4 ~ 9 ~ 7 ~", x[1], x[2], if(x[1] == 2) { 0.35 } { 0.5 }) ++ (late: x[0] / 16) },
			cells: [7, 8, 9, 10].collect { |n, i| layer.(padTo.(shift.("0 ~ 4 7 ~ 9", sim[i][0]), n), sim[i][1], sim[i][2]) },
			euclids: [
				eu.([[3, 8, [4, 7, 2], 1, 0.3], [2, 5, [9, 6], 1, 0.7], [3, 11, [0, 4, 2], 0, 0.5], [2, 13, [11, 9], 1, 0.5]]),
				eu.([[3, 8, [4, 7, 2], 1, 0.3], [5, 13, [0, 2, 4, 2, 7], 1, 0.7], [4, 11, [9, 7, 6, 4], 1, 0.5], [3, 16, [0, -3, 2], 0, 0.5]]),
				eu.([[5, 8, [4, 7, 9, 7, 2], 1, 0.3], [7, 13, [0, 2, 4, 7, 4, 2, 6], 1, 0.7], [7, 16, [9, 7, 4, 6, 11, 9, 7], 1, 0.5, 3],
					[4, 9, [0, 4, -3, 2], 0, 0.5]])],
			build: build.collect { |s| layer.(*s) });
		st[\fk] = v; v };
	var hits = fkit[\hits], md = fkit[\md];
	var upTo = { |list, kn| list.select { |x, v| v < (1 + ((list.size - 1) * kn).round) } };
	ls = switch(col[\patLatch].atBar(b),
		0, { upTo.(fk[\zyklen], kn) }, 1, { upTo.(fk[\canon], kn) }, 2, { upTo.(fk[\cells], kn) },
		3, { upTo.(fk[\euclids][(3 * kn).floor.min(2)], kn) },
		4, { swell = 0.7 + (0.7 * kn); cm = 0.6 + (1.4 * kn); upTo.(fk[\build], kn).select { |x, v| md.(b, 64) >= (v * 4) } });
	ls.do { |ly| hits.(ly, t0, b).do { |h|
		var m = fr.degMidi(h[\deg], 3 + ly[\oct], fr.moodAt(tr, h[\u].floor)), pick = kit[\vcslPick].(\xylophone_soft_ff, m), g = ly[\g] * swell * h[\vel];
		out.add(kit[\smp].(pick[0], "xylophone_soft_ff", g, (rate: pick[1], midi: m, at: h[\at], pan: ly[\pan],
			lpOn: 1, bright: col.knob(\k1), lo: 600, hi: 6000, tone: kit[\tone], cutMul: cm)))
	} };
	out
}
)
)
