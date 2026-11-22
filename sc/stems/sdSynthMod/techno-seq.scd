// Column code of the techno sequence (008): a hypnotic FM mallet loop (3, 5 or 7 steps against the 4/4) on the chord, with
// echo: eight loops. Complexity (row 3) thins the loop below full, turns a quarter of its notes into passing notes, and
// brings in extra notes one by one. Button 2 an octave up. Space scales room and echo.
(
states: (room: 0.9 * 0.3, echo: 0.4 * 2 * 0.3),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = 0.3 + (0.7 * col.knob(\k2));
	col.setState(\room, 0.9 * s, send); col.setState(\echo, (0.4 * 2 * s).min(0.9), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var v = col[\patLatch].atBar(b), rg = col.knob(\k3), r = ce.rand(t), degs = List[], l, d;
	st[\seqs] = st[\seqs] ?? { ["0 ~ 0 4 ~", "0 ~ 6 ~ 4 ~ 0", "0 4 ~", "0 ~ ~ 2 ~ 4 ~", "4 ~ 0 ~ 0", "0 ~ 3 ~ 0 4 ~", "6 ~ 4 ~ ~", "0 0 ~ 4 ~ 2 ~"].collect(kit[\line]) };
	st[\extras] = st[\extras] ?? { [
		[[0.12, 0, 11], [0.245, 0, 4], [0.37, 2, 9], [0.495, 6, 15], [0.62, -3, 3], [0.745, -3, 2], [0.87, -7, 1], [0.995, 11, 5]],
		[[0.12, 2, 14], [0.245, 2, 8], [0.37, 0, 0], [0.495, -3, 4], [0.62, 6, 13], [0.745, 7, 7], [0.87, 7, 5], [0.995, 11, 10]],
		[[0.12, 2, 14], [0.245, 4, 0], [0.37, 2, 1], [0.495, 4, 15], [0.62, 4, 10], [0.745, 6, 2], [0.87, 7, 3], [0.995, 11, 13]],
		[[0.12, 0, 0], [0.245, 2, 10], [0.37, 4, 1], [0.495, 4, 2], [0.62, -3, 3], [0.745, 4, 9], [0.87, -7, 14], [0.995, 7, 12]],
		[[0.12, 2, 13], [0.245, 0, 14], [0.37, 2, 15], [0.495, 6, 11], [0.62, 6, 7], [0.745, -3, 3], [0.87, -4, 8], [0.995, -4, 1]],
		[[0.12, 4, 4], [0.245, 0, 3], [0.37, 2, 2], [0.495, 4, 9], [0.62, -3, 10], [0.745, 4, 1], [0.87, 7, 13], [0.995, -4, 7]],
		[[0.12, 2, 11], [0.245, 0, 3], [0.37, 2, 0], [0.495, 6, 10], [0.62, 7, 15], [0.745, 7, 5], [0.87, -7, 13], [0.995, 7, 4]],
		[[0.12, 4, 0], [0.245, 4, 11], [0.37, 2, 12], [0.495, 4, 1], [0.62, 6, 7], [0.745, 6, 6], [0.87, 7, 4], [0.995, 7, 8]]] };
	l = st[\seqs][v]; d = l[k % l.size];
	if(d.notNil and: { r > (0.5 * (1 - rg)) }) { degs.add([d + if(r < (0.25 * rg)) { [1, -1][b % 2] } { 0 }, 1]) };
	st[\extras][v].do { |x| if(rg > x[0] and: { s16 == x[2] }) { degs.add([x[1], 0.85]) } };
	degs.collect { |x|
		var m = fr.degMidi(x[0] + fr.rootAt(tr, b), 4, tr.chapterAt(b)) + if(col.held(\b2)) { 12 } { 0 } + (-0.06 + (0.12 * r));
		var g = (0.47 + (0.27 * ce.perlin(t))) * x[1], f = m.midicps;
		kit[\syn].(\sine, m, g, (fmi: 0.4 + (1.6 * col.knob(\k1)), fmh: 2, modPhase: kit[\modPhase].(k, 0, f * 2, tr.bpm), hold: 1,
			pan: 0.35 + (0.3 * ce.sine(t / 3)), lpOn: 1, bright: col.knob(\k1), lo: 1500, hi: 12000, tone: kit[\tone])
			++ kit[\adsr].(0.003, 0.28, 0, 0.25))
	}
}
)
