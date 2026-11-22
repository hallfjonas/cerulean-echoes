// Column code of the ambient kick (010): a sine body on D2 with a pitch drop + the 909 kick. Softness (row 3): firm 909 -> deep
// soft thump without click. Straight, Pickup before the 1, Gap (no 4th kick every 4th bar). Button 2 held: drop out. Out in
// the Break. Room, no echo (Tension moves the room: see ~ce.ambientFx).
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\kick]),
strip: (roomR: \kickRoom),
update: { |col, send| fx.apply(col, send, \kick) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, x, s, g, lp, adsr = kit[\adsr], padsr = kit[\padsr];
	st[\pats] = st[\pats] ?? { var four = Dictionary[0 -> [1, 4], 4 -> [1, 4], 8 -> [1, 4], 12 -> [1, 4]];
		[{ four }, { Dictionary[0 -> [1, 4], 4 -> [1, 4], 8 -> [1, 4], 12 -> [1, 1], 15 -> [0.4, 1]] },
			{ |b| if((b % 4) == 3) { Dictionary[0 -> [1, 4], 4 -> [1, 4], 8 -> [1, 4]] } { four } }] };
	fr.rootAt(tr, b);
	x = st[\pats][col[\patLatch].atBar(b)].(b)[k % 16];
	if(tr.breakAt(b) or: { col.held(\b2) } or: { x.isNil }) { [] } {
		s = col.knob(\k3); g = x[0] * 0.8;
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 1500, hi: 10000, tone: kit[\tone], hold: x[1]);
		[kit[\syn].(\sine, 38, g, lp ++ (penv: 24 - (12 * s)) ++ padsr.(nil, 0.035 + (0.045 * s)) ++ adsr.(0.002 + (0.012 * s), 0.4 + (0.2 * s), 0, 0.05)),
		 kit[\smp].("tr909/bd-01.wav", "RolandTR909_bd:0", g * 0.75 * (1 - s), lp)].reject { |n| n.amp <= 0 }
	}
}
)
)
