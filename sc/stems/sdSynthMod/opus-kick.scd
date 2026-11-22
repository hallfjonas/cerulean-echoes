// Column code of the opus kick (016): a soft, round sine kick on C2 with a pitch drop, a sub thump on C1 under it, a light
// 909 click from Punch (soft thump at 0 -> round kick at 1). Wumms (column 8's fader): louder, longer, deeper thump, driven.
// Button 1 held: double time (8 kicks per bar); button 2 held: drop out. Out in the Break. No echo.
(
strip: (space: \k2),
b1: { |col| },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), b = (k / 16).floor, step = if(col.held(\b1)) { 2 } { 4 }, p, w, gw, lp, adsr = kit[\adsr];
	var punch2 = { |p, soft, round| soft + ((round - soft) * p) };
	if(col[\track].breakAt(b) or: { col.held(\b2) } or: { k % step != 0 }) { [] } {
		p = col.knob(\k3); w = ce.val(ce.stemGlobal.master); gw = 0.85 * kit[\dB].(1.5 * w);
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 600, hi: 6000, tone: kit[\tone], shape: 0.25 * w, hold: step);
		[
			kit[\syn].(\sine, 36, gw, lp ++ (penv: punch2.(p, 10, 20) + (6 * w), pd: punch2.(p, 0.1, 0.06))
				++ adsr.(punch2.(p, 0.014, 0.005), punch2.(p, 0.6, 0.45) * (1 + (0.4 * w)), 0, 0.06)),
			kit[\smp].("tr909/bd-01.wav", "RolandTR909_bd:0", punch2.(p, 0, 0.15) * gw, lp ++ (hold: -1), \sdSampleMod),
			kit[\syn].(\sine, 24, (0.3 + (0.25 * w)) * gw, lp ++ adsr.(0.01, 0.35, 0, 0.1))
		].reject { |n| n.amp <= 0 }
	}
}
)
