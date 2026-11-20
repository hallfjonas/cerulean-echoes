// Column code of the 009 hats: the house off-beat (a short open 909 hat) and closed 16ths, swung 0.2; knob 3 trades
// the hats for TR-727 shakers (hats → both → shaker); Open = open hats on every 8th. Four samples and a cross-fade per
// hit need code. Format: sc/lib/stems.scd (column code).
(
var ramp = { |v, from, to| ((v - from) / (to - from)).clip(0, 1) };
var open = [0.5, 0.5, 0.45];
var closed = [Dictionary[3 -> 0.12], Dictionary[0 -> 0.2, 1 -> 0.1, 3 -> 0.15], Dictionary[0 -> 0.26, 1 -> 0.13, 3 -> 0.2]];
(
strip: (orbit: 1, space: \k2, echo: 0.2),
notes: { |col, k|
	var ce = col[\ce], b = (k / 16).floor, v = col[\patLatch].atBar(b), mix = col.knob(\k3), out = List[], fm, fx;
	var fog = ("c" ++ ce.fogBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var lp = { (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 4000, hi: 16000, tone: fog, pan: 0.56) };
	var smp = { |rel, tag, g, args| var x = ce.sdADSR(nil, nil, nil, nil);
		ce.note(col[\sample], (buf: ce.sampleBuffers[rel], stereoIn: (ce.sampleMono[rel] != true).asInteger,
			amp: g, hold: -1, thinF: thin, tag: tag, g: g, a: x[0], d: x[1], s: x[2], r: x[3]) ++ args) };
	var env = { |d| var x = ce.sdADSR(nil, d, 0, nil); (a: x[0], d: x[1], s: x[2], r: x[3]) };
	fm = ramp.(mix, 1, 0.5); fx = ramp.(mix, 0, 0.5) * 2.5;
	if(k % 4 == 2) {
		out.add(smp.("tr909/oh-00.wav", "RolandTR909_oh:0", open[v] * fm * 0.9, lp.() ++ env.(0.15)));
		out.add(smp.("tr727/sh-00.wav", "RolandTR727_sh:0", open[v] * fx * 0.9, lp.()));
	};
	closed[v][k % 4] !? { |c|
		var sw = if(k.odd) { 0.2 } { 0 };
		out.add(smp.("tr909/hh-00.wav", "RolandTR909_hh:0", c * fm * 0.9, lp.() ++ (at: sw)));
		out.add(smp.("tr727/sh-01.wav", "RolandTR727_sh:1", c * fx * 0.9, lp.() ++ (at: sw)));
	};
	if(col.held(\b2) and: { k.even }) {
		out.add(smp.("tr909/oh-00.wav", "RolandTR909_oh:0", 0.3 * 0.9, lp.() ++ env.(0.22))) };
	out.reject { |n| n[\amp] <= 0 }
}
)
)
