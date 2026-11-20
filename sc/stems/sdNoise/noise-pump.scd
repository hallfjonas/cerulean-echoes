// Column code of the 009 noise pump: a short breath of pink noise after every kick (a sidechain pump without a
// compressor), out in the Break; Motion moves its low-pass and pan with slow sines read at the bar start (as Strudel
// reads knobs per bar). Button 2: its own riser (band-pass sweep 0 → 1 over 2 bars), on a lane with a fixed room,
// playing in the Break too. Format: sc/lib/stems.scd (column code).
(
var synthDef = [0.001, 0.05, 0.6, 0.01];
(
gate: false,
strip: (lanes: [(name: \pump, orbit: 1, space: \k2, echo: 0.15), (name: \riser, orbit: 2, space: (fixed: 0.3), echo: 0)]),
start: { |col, ce| col[\st][\riserStart] = nil },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], b = (k / 16).floor, t = k / 16, out = List[], v, m, w, p, r;
	var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var adsr = { |a, d, s, rr| var x = ce.sdADSR(a, d, s, rr, synthDef); (a: x[0], d: x[1], s: x[2], r: x[3]) };
	if(col.held(\b2)) { st[\riserStart] = st[\riserStart] ? t.floor } { st[\riserStart] = nil };
	if(col[\track].breakAt(b).not) {
		v = col[\patLatch].atBar(b); m = col.knob(\k3);
		w = ce.sine(t.floor / 2); p = ce.sine(t.floor / 3);
		[
			{ if(k % 4 == 1) { [3, 1.4, adsr.(0.1, nil, 0.5, 0.02), 2000] } },
			{ if(k % 4 == 2) { [2, 1.4, adsr.(0.04, nil, 0.4, 0.04), 3000] } },
			{ if(k % 4 != 0) { [1, [0.6, 1, 0.7][k % 4 - 1] * 1.4, adsr.(0.01, 0.05, 0, nil), 4000] } }
		][v].value !? { |n|
			out.add(ce.note(col[\sample], (color: 0, amp: n[1], hold: n[0], lane: \pump, hp: n[3], thinF: thin,
				lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 2000, hi: 14000, tone: tone, cutMul: 1 - (0.7 * m * w),
				pan: 0.5 + (m * (p - 0.5)), tag: "pink", g: n[1]) ++ n[2]))
		}
	};
	if(st[\riserStart].notNil) {
		r = ((t.floor - st[\riserStart]) / 2).clip(0, 1);
		if(r > 0) { out.add(ce.note(col[\sample], (color: 0, amp: r * 0.35, hold: 1, lane: \riser, thinF: thin,
			bp: 300 * (20 ** r), bpq: 4, pan: ce.sine(t * 2), tag: "pink", g: r * 0.35) ++ adsr.(0.03, nil, 0.8, 0.15))) }
	};
	out
}
)
)
