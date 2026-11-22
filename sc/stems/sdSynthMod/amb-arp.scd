// Column code of the ambient pluck arp (010): a triangle + a saw pluck on the chord tones above the root (D4) in 16ths: eight arp
// shapes. Complexity (row 3): some notes left out below full, passing notes (9th, 6th) by chance. Button 2 an octave up.
// Echo and room from Space (0.3 ... 1) and Tension.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\arp]),
strip: (roomR: \arpRoom, echoSend: \arpEcho),
update: { |col, send| fx.apply(col, send, \arp) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, a, rg = col.knob(\k3), r = ce.rand(t), d, m, g, lp;
	st[\arps] = st[\arps] ?? { [[0, 2, 4, 2], [0, 2, 4, 6], [4, 2, 0, 2], [2, 4, 6, 8, 6, 4, 2, 4], [0, nil, 2, 4, nil, 2, 4, nil], \poly,
		[6, 4, 2, 4], \alt] };
	fr.rootAt(tr, b);
	a = st[\arps][col[\patLatch].atBar(b)];
	d = case { a == \poly } { [0, 2, 4, 6, 4][k % 5] } { a == \alt } { [[0, 2, 4, 6], [2, 4, 6, 8]][b % 2][k % 4] } { a[k % a.size] };
	if(d.isNil or: { r < (0.35 * (1 - rg)) }) { [] } {
		if(r < (0.25 * rg)) { d = d + [1, 5][b % 2] };
		m = fr.degMidi(d + fr.rootAt(tr, b), 4) + if(col.held(\b2)) { 12 } { 0 };
		g = 0.45 + (0.2 * ce.perlin(t));
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 900, hi: 8000, tone: kit[\tone], hold: 1, pan: 0.3 + (0.4 * ce.sine(t / 3)))
			++ kit[\adsr].(0.003, 0.16, 0, 0.1);
		[kit[\syn].(\triangle, m, g, lp), kit[\syn].(\sawtooth, m, g, lp)]
	}
}
)
)
