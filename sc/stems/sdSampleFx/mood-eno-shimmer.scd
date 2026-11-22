// Column code of the ambient bowed vibraphone and shimmer (007): ENO = VCSL bowed vibraphone, single notes on six loops of
// different lengths that drift apart (row 3 = how many loops); SHIMMER = high triangle swells, a new tone every 2 / 1 / 4 bars,
// with an FM bell chord on row 3. Button 1 = the note set (calm, lydian, low) and the shimmer's pace. Button 2 (Layer) picks Eno,
// Shimmer, or both at the next bar. Each layer has its own lane: room, echo and trim.
(
var fx = ~ce.moodFx;
(
states: (enoEcho: 0.15, enoRoom: 0.225, shimEcho: 0, shimFmEcho: 0),
maps: (enoTrim: (ccs: [\k1], fn: { |b| 10 ** (4 * (b - 0.5) / 20) })),
strip: (lanes: [(name: \main, roomR: \enoRoom, echoSend: \enoEcho, trim: \enoTrim),
	(name: \tri, space: \k2, echoSend: \shimEcho, trim: 1.86), (name: \fm, space: \k2, echoSend: \shimFmEcho, trim: 1.86)]),
update: { |col, send| fx.roomSend(col, send, \enoRoom); fx.echoSend(col, send, \enoEcho, 0.3, true);
	fx.echoSend(col, send, \shimEcho, 0); fx.echoSend(col, send, \shimFmEcho, 0.6) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.moodOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t0 = k / 16, t1 = t0 + (1/16);
	var v = col[\patLatch].atBar(b), layer = col[\b2Latch].atBar(b), adsr = kit[\adsr], syn = kit[\syn], out = List[];
	var loops = [5.3, 6.7, 7.9, 9.1, 10.7, 12.3], offs = [0, 2.1, 4.4, 1.3, 6.2, 3.5];
	var sets = [[0, 4, 8, 7, 11, 12], [3, 6, 4, 8, 10, 13], [0, -3, 4, 2, 7, 1]], stretch = [1, 1, 1.5], lens = [2, 1, 4];
	var sl = stretch[v], n, len, a, d, lp, tt;
	if(layer != 1) {
		n = 2 + (4 * col.knob(\k3)).round;
		6.do { |i| if(i < n) {
			var len = loops[i] * sl, j = ((t0 - (offs[i] * sl)) / len - 1e-7).ceil, tb = (offs[i] * sl) + (j * len);
			if(tb < (t1 - 1e-7)) {
				var m = fr.degMidi(sets[v][i], 3, fr.moodAt(tr, tb.floor)), pick = kit[\vcslPick].(\vibraphone_bowed, m);
				out.add(kit[\smp].(pick[0], "vibraphone_bowed", 6, (rate: pick[1], midi: m, at: (tb - t0) * 16, hold: len / 3 * 16,
					pan: 0.2 + (0.6 * ((i * 0.37) % 1)), lpOn: 1, bright: kit[\ccMap].(\k1), lo: 800, hi: 12000, tone: kit[\tone],
					vib: 0.15, vibmod: kit[\wob]) ++ adsr.(0.6, nil, nil, 3), \sdSampleFx))
			}
		} }
	};
	len = lens[v]; a = col.knob(\k3);
	tt = b + kit[\seed].(col[\patLatch], b);
	if(layer != 0 and: { (k % 16) == 0 } and: { (tt % len) == 0 }) {
		d = (7 * ce.rand((tt / len).floor)).trunc;
		lp = (lpOn: 1, bright: kit[\ccMap].(\k1), lo: 1500, hi: 14000, tone: kit[\tone], vib: 0.15, vibmod: kit[\wob], hold: len * 16);
		out.add(syn.(\triangle, fr.degMidi(d, 5, fr.moodAt(tr, b)), 0.18, lp ++ (pan: 0.2 + (0.6 * ce.sine(t0 / 9)), lane: \tri)
			++ adsr.(2.5, nil, 0.7, 4)));
		if(a > 0) { [2, 4].do { |x| var m = fr.degMidi(d + x, 5, fr.moodAt(tr, b));
			out.add(syn.(\sine, m, 0.14 * a, lp ++ (fmi: 2 * a, fmh: 2, modPhase: kit[\modPhase].(k, 0, m.midicps * 2),
				pan: ce.sine(t0 / 7), lane: \fm) ++ adsr.(1.5, nil, 0.6, 4))) } }
	};
	out
}
)
)
