// Column code of the techno kick (008): a sine kick tuned to C2 (the fifth of F) with a pitch drop and a little 909 click on
// top. Punch (row 3) goes soft -> round -> hard (attack, decay, pitch drop, click, drive). Button 1 held: double time (8
// kicks per bar); button 2 held: drop out. Out in the Break. No echo.
(
strip: (space: \k2),
b1: { |col| },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), b = (k / 16).floor, dbl = col.held(\b1), step = if(dbl) { 2 } { 4 }, p, vel, sh, lp;
	var adsr = kit[\adsr], punch3 = kit[\punch3];
	if(col[\track].breakAt(b) or: { col.held(\b2) } or: { k % step != 0 }) { [] } {
		p = col.knob(\k3); vel = punch3.(p, 1, 1, 0.56); sh = punch3.(p, 0, 0, 0.4);
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 900, hi: 9000, tone: kit[\tone], shape: sh);
		[
			kit[\syn].(\sine, 36, 0.8 * vel, (hold: step, penv: punch3.(p, 12, 24, 36), pd: punch3.(p, 0.09, 0.05, 0.03))
				++ adsr.(punch3.(p, 0.016, 0.004, 0.001), punch3.(p, 0.55, 0.4, 0.3), 0, 0.05) ++ lp),
			kit[\smp].("tr909/bd-01.wav", "RolandTR909_bd:0", punch3.(p, 0, 0.3, 0.7) * 0.8 * vel, lp, \sdSampleMod)
		].reject { |n| n.amp <= 0 }
	}
}
)
