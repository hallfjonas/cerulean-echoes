// Column code of the techno FX / breath (008): pink-noise grains whose level and band-pass breathe slowly (one breath per 2,
// 4, 8 or 1 bar): a slow sine x a depth that changes from breath to breath, eased (a long quiet part, a short peak).
// Complexity (row 3) adds chord pulses in 8ths (root, fifth, octave), from half also 16ths an octave up; button 2 opens the
// breath fully. Space scales the room from 0.08. Brightness acts at once.
(
states: (room: 0.9 * 0.08),
strip: (roomR: \room),
update: { |col, send| col.setState(\room, 0.9 * (0.08 + (0.92 * col.knob(\k2))), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, len = [2, 4, 8, 1][col[\patLatch].atBar(b)];
	var a = col.knob(\k3), r = ce.rand(t), out = List[], adsr = kit[\adsr], chord;
	var br = if(col.held(\b2)) { 1 } { ((ce.sine(t / len) * (0.3 + (0.7 * ce.perlin(t / (2 * len))))) ** 1.6) };
	var lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 1500, hi: 14000, tone: kit[\tone]);
	if(r > 0.5) { out.add(ce.note(\sdNoise, (color: 0, amp: (1 + (6 * br)) * (0.5 + (0.5 * r)), hold: 1, thinF: kit[\thin],
		bp: 400 * (6 ** br) * (0.6 + (1.1 * ce.perlin(t / 11))), bpq: 0.8, pan: 0.1 + (0.8 * r),
		tag: "pink", g: (1 + (6 * br)) * (0.5 + (0.5 * r))) ++ lp ++ adsr.(0.08, nil, 0.8, 0.12 + (0.28 * r)))) };
	if(a > 0) {
		chord = [0, 4, 7].collect { |d| fr.degMidi(d + fr.rootAt(tr, b), 4, tr.chapterAt(b)) };
		if(k.even and: { r > 0.25 }) { chord.do { |m| out.add(kit[\syn].(\triangle, m, 0.15 * br * (a / 0.5).clip(0, 1),
			lp ++ (hold: 2) ++ adsr.(0.02, nil, 0.8, 0.1))) } };
		if(a > 0.5) { chord.do { |m| out.add(kit[\syn].(\sine, m + 12, 0.09 * br * ((a - 0.5) / 0.5).clip(0, 1),
			lp ++ (hold: 1) ++ adsr.(0.01, nil, 0.6, 0.08))) } };
	};
	out.reject { |n| n.amp <= 0 }
}
)
