// Column code of the ambient clap / rim (010): a 909 clap / rimshot on 2 and 4 (Clap, Rim with a pickup, Both). Complexity
// (row 3): a quiet rim before beat 3, then small double taps. Button 2: a snare roll growing over the bar while held.
// Tension's roll (last quarter of the knob) fills in 16ths. The low-pass is Brightness x Fog only. Out in the Break.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\clap]),
strip: (roomR: \clapRoom, echoSend: \clapEcho),
update: { |col, send| fx.apply(col, send, \clap) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var p, c = col.knob(\k3), tn, out = List[], lp, hit, ramp = kit[\ramp];
	st[\pats] = st[\pats] ?? { [[Dictionary[4 -> 0.7, 12 -> 0.7], Dictionary[]], [Dictionary[], Dictionary[4 -> 0.6, 12 -> 0.6, 15 -> 0.3]],
		[Dictionary[4 -> 0.6, 12 -> 0.6], Dictionary[3 -> 0.35, 10 -> 0.3]]] };
	fr.rootAt(tr, b);
	if(tr.breakAt(b)) { [] } {
		p = st[\pats][col[\patLatch].atBar(b)];
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 3500, hi: 14000, tone: kit[\fog], hp: 300, pan: 0.47);
		hit = { |file, tag, g| out.add(kit[\smp].(file, tag, g * 0.9, lp)) };
		p[0][s16] !? { |g| hit.("tr909/cp-00.wav", "RolandTR909_cp:0", g) };
		p[1][s16] !? { |g| hit.("tr909/rim-00.wav", "RolandTR909_rim:0", g) };
		if(c > 0 and: { s16 == 8 }) { hit.("tr909/rim-00.wav", "RolandTR909_rim:0", 0.25 * ramp.(c, 0, 0.5)) };
		if(c > 0.5) { Dictionary[6 -> 0.18, 14 -> 0.15][s16] !? { |g| hit.("tr909/rim-00.wav", "RolandTR909_rim:0", g * ramp.(c, 0.5, 1)) } };
		if(col.held(\b2)) { hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.1 + (0.4 * (t % 1))) };
		tn = ramp.(ce.val(tr.global.tension), 0.75, 1);
		if(tn > 0 and: { ce.rand(t) >= (0.75 * (1 - tn)) }) { hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.06 + (0.29 * tn)) };
		out
	}
}
)
)
