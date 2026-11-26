// Column code of the lsd-fx whooshes (017-lsd-fx): one noise whoosh per 8-bar phrase that travels through the stereo field
// and ends on the downbeat of the phrase's 5th bar. Length (row 3): half a bar ↔ two bars. Button 1: eight paths (left to
// right, right to left, up, down, circle, pass-by, there and back, one of them at random each phrase). Button 2 (Swirl):
// noise circling the room once a beat, swelling in over a bar, while held. Space scales room (from 0.4) and echo (from 0.1).
(
// a path: progress 0..1 -> [pan, band-pass Hz, level]
var paths = [
	{ |p| [0.05 + (0.9 * p), 400 * (15 ** sin(pi * p)), sin(pi * p) ** 1.5] },
	{ |p| [0.95 - (0.9 * p), 400 * (15 ** sin(pi * p)), sin(pi * p) ** 1.5] },
	{ |p| [0.5 + (0.15 * sin(2pi * p)), 300 * (30 ** p), p ** 2] },
	{ |p| [0.5 - (0.15 * sin(2pi * p)), 9000 * ((1 / 30) ** p), (1 - p) ** 1.5] },
	{ |p| [0.5 + (0.45 * sin(4pi * p)), 600 * (8 ** sin(pi * p)), sin(pi * p)] },
	{ |p| [0.05 + (0.9 * p), 5000 * ((1 / 8) ** p), (1 - (2 * (p - 0.5)).abs) ** 2] },
	{ |p| var q = (2 * p) % 1; [if(p < 0.5) { 0.05 + (0.9 * q) } { 0.95 - (0.9 * q) }, 500 * (12 ** sin(pi * q)), sin(pi * q) ** 1.5] }
];
(
states: (room: 0.9 * 0.4, echo: 0.1),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.4 + (0.6 * s)), send); col.setState(\echo, 0.1 + (0.4 * s), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), st = col[\st], b = (k / 16).floor, t = k / 16, out = List[];
	var len = (8 + (24 * col.knob(\k3))).round.asInteger, end = (b - (b % 8) + 4) * 16, from = end - len;
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 3000, hi: 16000, tone: kit[\tone]), adsr = kit[\adsr], noise = kit[\noise];
	if(k >= from and: { k < end }) {
		var fb = (from / 16).floor, v = col[\patLatch].atBar(fb);
		var path = paths[if(v < paths.size) { v } { (ce.rand((fb / 8).floor + 0.53) * paths.size).trunc.asInteger }];
		2.do { |i| var x = path.(((k - from) + (i / 2) + 0.25) / len);
			out.add(noise.(1, 0.4 * x[2], lp ++ (at: i / 2, hold: 0.5, bp: x[1], bpq: 2, pan: x[0]) ++ adsr.(0.02, nil, 1, 0.08))) } };
	if(col.held(\b2)) { var g;
		st[\since] = st[\since] ? k; g = ((k - st[\since] + 1) / 16).clip(0, 1);
		2.do { |i| var u = t + (i / 32);
			out.add(noise.(1, 0.3 * g, lp ++ (at: i / 2, hold: 0.5, bp: 900 * (6 ** ce.sine(u / 2)), bpq: 3,
				pan: 0.5 + (0.45 * sin(8pi * u))) ++ adsr.(0.02, nil, 1, 0.08))) } } { st[\since] = nil };
	out.reject { |n| n.amp <= 0 }
}
)
)
