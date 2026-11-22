// Column code of the opus accents (016): rare, short, high one-shots (sine, chirp, drop, pluck) on the 16th grid: about one hit
// in two bars (Rate 0) up to two per bar (Rate 1), each a shot and a pitch at random (F minor pentatonic, F6 - A flat 7); shot,
// pitch and whether it plays come from the same random number of the 16th, as in Strudel. Eight random series. Button 2
// (Burst): the series twice as fast, half of it, in 32nds. Space scales the room from 0.2.
(
states: (room: 0.9 * 0.2),
strip: (roomR: \room),
update: { |col, send| col.setState(\room, 0.9 * (0.2 + (0.8 * col.knob(\k2))), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, v = col[\patLatch].atBar(b), rate = col.knob(\k3), out = List[], lp;
	var accNotes = [89, 92, 94, 96, 99, 101, 104], adsr = kit[\adsr];
	var shots = [[\sine, 1, 3, 3.5, 0, 0, 0.05, 0], [\sine, 0, 0, 1, 12, 0.03, 0.06, 0], [\sine, 0, 0, 1, -24, 0.04, 0.07, -12],
		[\triangle, 0, 0, 1, 0, 0, 0.09, -12], [\sine, 1, 6, 1.414, 0, 0, 0.03, 0]];
	var hit = { |r, u, g, at, len| var sh = shots[(r * 5).trunc.asInteger], m = accNotes[(r * 7).trunc.asInteger] + sh[7];
		var args = lp ++ (pan: 0.1 + (0.8 * ce.rand(u)), at: at, hold: len) ++ adsr.(0.001, sh[6], 0, 0.04);
		if(sh[4] != 0) { args = args ++ (penv: sh[4], pd: sh[5]) };
		kit[\syn].(sh[0], m, g, args) };
	var r0 = ce.rand(t + (1024 * v));
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 5000, hi: 18000, tone: kit[\tone]);
	if(r0 >= (1 - ((4 ** rate) / 32))) { out.add(hit.(r0, t, 0.12 + (0.18 * ce.perlin(t / 7)), 0, 1)) };
	if(col.held(\b2)) { 2.do { |j| var u = t + (j / 32);
		if(ce.rand(u) >= 0.5) { out.add(hit.(ce.rand(2 * u), u, 0.2, j / 2, 0.5)) } } };
	out
}
)
