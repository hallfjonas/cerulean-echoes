// Column code of the techno clap (008): a short 909 clap on 2 and 4, the full one for the drop (tail + double); Simple,
// Pickup, Drop. Complexity (row 3) adds a quiet clap before beat 3, then small double taps. Button 2: a snare swell over 4
// bars (hits left out at random, fewer and fewer). Tension's roll (last fifth of the knob) plays also in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var out = List[], c = col.knob(\k3), v, tn, r, lp, hit, adsr = kit[\adsr], ramp = kit[\ramp];
	st[\claps] = st[\claps] ?? { [
		[Dictionary[4 -> [0.8, 4], 12 -> [0.8, 4]]],
		[Dictionary[4 -> [0.8, 4], 12 -> [0.8, 1], 15 -> [0.35, 1]]],
		[Dictionary[4 -> [0.8, 4], 12 -> [0.8, 4]], Dictionary[4 -> [0.8, 4], 12 -> [0.8, 2], 14 -> [0.5, 2]]]] };
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 1500 * (8 ** 0.9), hi: 12000, tone: kit[\fog], hp: 400, pan: 0.48);
	hit = { |rel, tag, g, args| kit[\smp].(rel, tag, g * 1.75, lp ++ (args ? ())) };
	if(col.held(\b2)) { st[\swellStart] = st[\swellStart] ? t.floor } { st[\swellStart] = nil };
	if(tr.breakAt(b).not) {
		v = col[\patLatch].atBar(b);
		st[\claps][v][b % st[\claps][v].size][s16] !? { |x|
			out.add(hit.("tr909/cp-00.wav", "RolandTR909_cp:0", x[0], (hold: x[1]) ++
				if(v == 2) { adsr.(0.001, 0.12, 0, 0.06) } { adsr.(0.001, 0.05, 0, 0.03) })) };
		if(c > 0 and: { s16 == 8 }) { out.add(hit.("tr909/cp-00.wav", "RolandTR909_cp:0", 0.22 * ramp.(c, 0, 0.5), (hold: 4) ++ adsr.(0.001, 0.05, 0, 0.03))) };
		if(c > 0.5 and: { s16 == 6 }) { out.add(hit.("tr909/cp-00.wav", "RolandTR909_cp:0", 0.15 * ramp.(c, 0.5, 1), (hold: 2) ++ adsr.(0.001, 0.05, 0, 0.03))) };
		if(st[\swellStart].notNil) {
			r = ((t.floor - st[\swellStart]) / 4).clip(0, 1);
			if(ce.rand(t) > (0.85 * ((1 - r) ** 1.5))) {
				out.add(hit.("tr909/sd-00.wav", "RolandTR909_sd:0", (0.05 + (0.45 * r * r)) * (0.7 + (0.3 * ce.rand(t.floor))),
					(rate: 0.9 + (0.3 * r * r)))) }
		};
	};
	tn = ramp.(ce.val(tr.global.tension), 0.8, 1);
	if(tn > 0 and: { ce.rand(t) > (0.8 * ((1 - tn) ** 1.5)) }) {
		out.add(hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.05 + (0.4 * tn * tn))) };
	out.reject { |n| n.amp <= 0 }
}
)
