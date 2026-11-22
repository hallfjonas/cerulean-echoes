// Column code of the ambient noise pump (010): pink noise glued to the kick (orbit 1): Pump (3 16ths after every kick), Off-beat
// (the 8th off-beats), Waves (one swell every 2 bars). Motion (row 3): the filter breathes and the noise wanders left and
// right. Button 2: a riser on its own lane (orbit 2): 16th noise bursts, a band-pass climbing 300 Hz -> 6 kHz over 2 bars.
// Out in the Break (the riser plays on).
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\noise, \riser]),
strip: (lanes: [(name: \pump, orbit: 1, roomR: \noiseRoom, echoSend: \noiseEcho), (name: \riser, orbit: 2, roomR: \riserRoom, echoSend: \riserEcho)]),
update: { |col, send| fx.apply(col, send, \noise); fx.apply(col, send, \riser, false) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, p, m = col.knob(\k3), out = List[], rr;
	var adsr = kit[\adsr];
	st[\pats] = st[\pats] ?? { [[1, 3, 4, (a: 0.14, s: 0.7, r: 0.03, hp: 900, g: 2)], [2, 2, 4, (a: 0.08, s: 0.5, r: 0.06, hp: 1800, g: 2)],
		[0, 32, 32, (a: 1.8, s: 1, r: 1.8, hp: 400, g: 1.4)]] };
	fr.rootAt(tr, b);
	p = st[\pats][col[\patLatch].atBar(b)];
	if(tr.breakAt(b).not and: { (k % p[2]) == p[0] }) {
		out.add(kit[\noise].(p[3].g * 0.4, (hold: p[1], hp: p[3].hp, lane: \pump, lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 1500,
			hi: 12000, tone: kit[\tone], cutMul: 1 - (0.7 * m * ce.sine(t / 2)), pan: 0.5 + (m * (ce.sine(t / 3) - 0.5)))
			++ adsr.(p[3][\a], nil, p[3][\s], p[3][\r])))
	};
	if(col.held(\b2)) { st[\riserStart] = st[\riserStart] ? t.floor } { st[\riserStart] = nil };
	if(st[\riserStart].notNil) {
		rr = ((t.floor - st[\riserStart]) / 2).clip(0, 1);
		if(rr > 0) { out.add(kit[\noise].(rr * 0.35, (bp: 300 * (20 ** rr), bpq: 4, pan: ce.sine(t * 2), hold: 1, lane: \riser)
			++ adsr.(0.03, nil, 0.8, 0.15))) }
	};
	out
}
)
)
