// Column code of the 009 congas: TR-727 conga low and bongos high / low, quiet, a perlin touch and a slow pan; Complexity
// adds random ghost notes; Fill = a run over the bar. The sample of a hit is its note (2, 3, 4) and the touch is
// random: code. Format: sc/lib/stems.scd (column code).
(
var files = Dictionary[2 -> "tr727/perc-02.wav", 3 -> "tr727/perc-03.wav", 4 -> "tr727/perc-04.wav"];
var lines = ["4 ~ ~ 2 ~ ~ 3 ~ 4 ~ ~ 2 ~ 3 ~ ~", "~ ~ 4 2 ~ ~ 4 ~ ~ 3 ~ 2 ~ ~ 4 ~", "3 ~ 2 ~ 4 ~ 2 3 ~ 2 ~ 4 ~ ~ 2 ~"]
	.collect { |l| l.split($ ).collect { |x| if(x == "~") { nil } { x.asInteger } } };
var fill = "2 2 3 3 2 3 4 4 2 2 3 3 4 3 4 4".split($ ).collect(_.asInteger);
(
strip: (orbit: 1, space: \k2, echo: 0.3),
notes: { |col, k|
	var ce = col[\ce], b = (k / 16).floor, t = k / 16, s16 = k % 16, out = List[], c = col.knob(\k3), r;
	var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var hit = { |n, g| var rel = files[n], x = ce.sdADSR(nil, nil, nil, nil);
		ce.note(col[\sample], (buf: ce.sampleBuffers[rel], stereoIn: (ce.sampleMono[rel] != true).asInteger,
			amp: g, hold: -1, thinF: thin, tag: "RolandTR727_perc:" ++ n, g: g, a: x[0], d: x[1], s: x[2], r: x[3],
			lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 1000, hi: 12000, tone: tone,
			pan: 0.35 + (0.3 * ce.sine(t / 4)))) };
	lines[col[\patLatch].atBar(b)][s16] !? { |n| out.add(hit.(n, 0.18 + (0.08 * ce.perlin(t)))) };
	r = ce.rand(t);
	if(c > 0 and: { r >= 0.55 }) { out.add(hit.((r * 2).trunc.asInteger + 2, c * 0.08)) };
	if(col.held(\b2)) { out.add(hit.(fill[s16], 0.22)) };
	out.reject { |n| n[\amp] <= 0 }
}
)
)
