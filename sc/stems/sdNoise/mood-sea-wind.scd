// Column code of the ambient sea and wind (007): brown-noise waves every half bar and pink-noise gusts in 8ths through a wandering
// band-pass; the knob (row 3) crossfades them on the lanes' fades, at once. Button 1 = the next of three random patterns.
// Button 2 = a riser: 16th noise bursts, a band-pass climbing 300 Hz to 6 kHz over 2 bars, while held.
(
var fx = ~ce.moodFx;
(
states: (echo: 0, seaL: 1, gustL: 0),
strip: (space: \k2, echoSend: \echo, lanes: [(name: \sea, fade: \seaL), (name: \gust, fade: \gustL), (name: \riser)]),
update: { |col, send| var c = col.knob(\k3);
	col.setState(\seaL, fx.fadeMain(c), send);
	col.setState(\gustL, fx.fadeExtra(c) * (0.22 ** col.knob(\k1)), send);
	fx.echoSend(col, send, \echo, 0) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.moodOf(col), b = (k / 16).floor, t = k / 16, c = col.knob(\k3);
	var fm = fx.fadeMain(c), fe = fx.fadeExtra(c), out = List[], tone = kit[\tone], noise = kit[\noise], adsr = kit[\adsr];
	var tt = t + kit[\seed].(col[\patLatch], b), r = ce.rand(tt), lp = (lpOn: 1, bright: kit[\ccMap].(\k1), lo: 700, hi: 12000, tone: tone), rr;
	if((k % 8) == 0 and: { r >= 0.25 }) {
		out.add(noise.(2, 6, lp ++ (cutMul: 0.35 + (0.65 * ce.sine(tt / 3)), pan: 0.2 + (0.6 * r), hold: 8, lane: \sea,
			g: 6 * fm, nolog: fm <= 0) ++ adsr.(0.6 + r, nil, 0.8, 1.5 + (1.5 * r))))
	};
	if((k % 2) == 0) {
		var amp = 6 + (32 * ce.perlin(tt));
		out.add(noise.(0, amp, lp ++ (bp: 400 + (1800 * (ce.sine(tt / 7) + (0.15 * r))), bpq: 2 + (5 * r), pan: ce.sine(tt / 4),
			hold: 2, lane: \gust, g: amp * (0.22 ** col.knob(\k1)) * fe, nolog: fe <= 0) ++ adsr.(0.3, nil, 0.7, 0.8)))
	};
	if(col.held(\b2)) { st[\riserStart] = st[\riserStart] ? t.floor } { st[\riserStart] = nil };
	if(st[\riserStart].notNil) {
		rr = ((t.floor - st[\riserStart]) / 2).clip(0, 1);
		if(rr > 0) { out.add(noise.(0, rr * 1.6, (bp: 300 * (20 ** rr), bpq: 4, pan: ce.sine(t * 2), hold: 1, lane: \riser)
			++ adsr.(0.03, nil, 0.8, 0.15))) }
	};
	out
}
)
)
