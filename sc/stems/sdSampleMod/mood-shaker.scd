// Column code of the ambient shaker (007): the VCSL small shaker in three figures (8ths, 16ths, rocking 3-3-2). Complexity (row
// 3): from 0.02 quiet ghost 16ths, from the middle a cabasa on beat 4. Brightness also moves the level by plus or minus 2 dB.
// Button 2 = a long dotted-8th echo while held. Sits out the Break.
(
var fx = ~ce.moodFx;
(
states: (echo: 0.05, room: 0.225),
maps: (trim: (ccs: [\k1], fn: { |b| 0.89 * (10 ** (4 * (b - 0.5) / 20)) })),
strip: (roomR: \room, echoSend: \echo, trim: \trim),
update: { |col, send| fx.roomSend(col, send, \room); fx.echoSend(col, send, \echo, 0.1, true, true) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.moodOf(col), b = (k / 16).floor, t = k / 16, s16 = k % 16, kk = col.knob(\k3);
	var toks = kit[\toks], num = kit[\num], out = List[], step, n, vel, lp, f;
	var figs = st[\figs] ?? { var v = [["0 2", "1 0.6", 8], ["0 6 2 6", "0.9 0.4 0.7 0.45", 16],
		["0 ~ 6 2 ~ 6 0 ~ 1 ~ 6 3 ~ 6 1 ~", "1 0 0.4 0.75 0 0.4 0.9 0 1 0 0.4 0.75 0 0.4 0.9 0", 16]].collect { |f|
		[toks.(f[0]).collect(num), toks.(f[1]).collect(_.asFloat), f[2]] }; st[\figs] = v; v };
	var file = { |n| "vcsl/shaker_small/" ++ ["Mid_ShakerDouble_Down", "Mid_ShakerDouble_Up", "Mid_ShakerHighFaster_Down",
		"Mid_ShakerHighFaster_Up", "Mid_ShakerLowFaster_Down", "Mid_ShakerLowFaster_Up"][n div: 2] ++ "_rr" ++ ((n % 2) + 1) ++ ".flac" };
	f = figs[col[\patLatch].atBar(b)];
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 1500, hi: 16000, tone: kit[\tone]);
	if(f[2] == 16 or: { k.even }) {
		step = if(f[2] == 16) { k } { k / 2 };
		n = f[0][step % f[0].size]; vel = f[1][step % f[1].size];
		if(n.notNil and: { vel > 0 }) { out.add(kit[\smp].(file.(n.asInteger), "shaker_small", 4 * vel, lp)) }
	};
	if(kk > 0.02 and: { ce.rand(t) >= (1 - (0.15 + (0.85 * kk))) }) {
		out.add(kit[\smp].(file.([4, 5, 6, 7][k % 4]), "shaker_small", 4 * 0.45, lp ++ (pan: 0.6))) };
	if(kk > 0.5 and: { s16 == 12 }) {
		out.add(kit[\smp].(["vcsl/cabasa/Cabasa1_Hit_rr1_Mid.flac", "vcsl/cabasa/Cabasa1_Hit_rr2_Mid.flac"][b % 2], "cabasa", 2.5,
			lp ++ (pan: 0.35))) };
	out
}
)
)
