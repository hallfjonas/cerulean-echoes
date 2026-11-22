// Column code of the ambient lead (010): lines with held notes on the chord (D4): a triangle + a saw through an "o" vowel, with
// vibrato; eight melodies. Complexity (row 3): a third below, then a canon half a bar later an octave up. Button 2 throws a
// long echo (0.85). Echo and room from Space (0.25 ... 1) and Tension.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\lead]),
strip: (roomR: \leadRoom, echoSend: \leadEcho),
update: { |col, send| fx.apply(col, send, \lead, true, true) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16, c = col.knob(\k3), out = List[], l;
	var adsr = kit[\adsr], lp, voice, ramp = kit[\ramp];
	st[\leads] = st[\leads] ?? { ["4 _ _ _ ~ ~ 2 _ 0 _ _ _ ~ ~ ~ ~", "~ ~ 7 _ _ _ 6 _ 4 _ _ _ ~ ~ ~ ~", "0 _ _ 2 _ _ 4 _ _ _ _ _ ~ ~ ~ ~",
		["4 _ _ _ 5 _ 4 _ 2 _ _ _ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ 0 _ _ _ _ _ ~ ~"], "~ ~ ~ ~ 2 _ _ _ 4 _ _ _ 6 _ _ _",
		"7 _ _ _ _ _ ~ ~ 4 _ _ _ _ _ ~ ~", "~ ~ 4 _ 2 _ 0 _ _ _ _ _ ~ ~ ~ ~", ["0 _ 2 _ 4 _ _ _ _ _ _ _ ~ ~ ~ ~", "~ ~ ~ ~ 6 _ _ _ 4 _ _ _ _ _ ~ ~"]]
		.collect { |l| (if(l.isString) { [l] } { l }).collect(kit[\longLine]) } };
	fr.rootAt(tr, b);
	l = st[\leads][col[\patLatch].atBar(b)];
	lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 600, hi: 5000, tone: kit[\tone], vib: 4.5, vibmod: 0.07) ++ adsr.(0.08, 0.3, 0.7, 0.4);
	voice = { |deg, len, g, args| var m = fr.degMidi(deg + fr.rootAt(tr, b), 4);
		out.add(kit[\syn].(\triangle, m, 0.35 * g, lp ++ (hold: len) ++ (args ? ())));
		out.add(kit[\syn].(\sawtooth, m, 0.1 * g, lp ++ (hold: len, vowel: 3) ++ (args ? ()), \sdSynthFx)) };
	l[b % l.size][s16] !? { |x|
		voice.(x[0], x[1], 1);
		if(c > 0) { voice.(x[0] - 2, x[1], 0.55 * ramp.(c, 0, 0.5)) } };
	if(c > 0.5) { var u = k - 8, bb = (u / 16).floor; l = st[\leads][col[\patLatch].atBar(bb)];
		l[bb % l.size][u % 16] !? { |x| voice.(x[0] + 7, x[1], 0.4 * ramp.(c, 0.5, 1), (pan: 0.65)) } };
	out
}
)
)
