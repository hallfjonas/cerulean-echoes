// Column code of the lsd percussion (017): a pair of bongos (macho C5, hembra F4) and a conga (C4) played by hand (modal skins:
// open tones, slaps, fingertips, the thumb), each drum in its place in the stereo field, a little uneven in time and
// strength (Pillow, Gallop, 3-3-2). Complexity (row 3): fingertips and thumbs fill the gaps, then flams before open tones and
// little 32nd rolls. Button 2: a run across the drums, getting stronger. Plays in the Break.
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), b = (k / 16).floor, t = k / 16, s16 = k % 16, out = List[];
	var p, c = col.knob(\k3), main, lp, ramp = kit[\ramp];
	var strokes = { |str| str.split($ ).reject(_.isEmpty).collect { |x| if(x == "~") { nil } { x.asSymbol } } };
	var drums = (M: [72, 0.62, 1, 1], H: [65, 0.4, 1.38, 1], C: [60, 0.28, 2, 0.6]);
	var kinds = (O: [0.16, 0.07, 0.45, 0.12, 0.8], S: [0.05, 0.12, 0.95, 0.85, 0.7], f: [0.035, 0.02, 0.6, 0.25, 0.3],
		T: [0.05, 0.03, 0.2, 0.05, 0.35]);
	var hit = { |drum, sk, at, vel| var d = drums[drum], s = kinds[sk], v = s[4] * d[3] * vel;
		ce.note(\modalPerc, lp ++ (kind: 0, freq: d[0].midicps, decay: s[0] * if(sk == \O) { d[2] } { 1 }, glide: s[1],
			hard: s[2] * (0.7 + (0.3 * v)), skin: s[3], amp: 1.35 * v, pan: d[1], at: at, hold: 1, thinF: kit[\thin],
			tag: drum.asString ++ sk, g: 1.35 * v, midi: d[0])) };
	var feel = { |j, drum| ((if(k.odd) { 0.06 } { 0 }) + (if(drum == \H) { 0.04 } { 0 }) + (0.05 * (ce.rand(t + (0.13 * j)) - 0.5))).max(0) };
	var human = { |j| 0.88 + (0.24 * ce.rand(t + 0.5 + (0.29 * j))) };
	st[\pats] = st[\pats] ?? { [
		["~ ~ O ~ ~ ~ ~ f ~ ~ S ~ ~ ~ O ~", "O ~ ~ ~ ~ ~ O ~ ~ ~ ~ O ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ S ~ ~ ~"],
		["~ ~ O f ~ ~ ~ f S ~ ~ ~ O f O ~", "O ~ ~ ~ O ~ ~ ~ ~ ~ O ~ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ S ~ ~ ~"],
		["~ ~ O ~ ~ ~ ~ S ~ ~ O ~ ~ ~ S ~", "O ~ ~ ~ ~ ~ O ~ ~ ~ ~ ~ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ O ~ ~ ~"],
	].collect { |x| x.collect(strokes) } };
	st[\fill] = st[\fill] ?? { strokes.("M H M H M M H H M H C H C ~ C ~") };
	p = st[\pats][col[\patLatch].atBar(b)];
	lp = (lpOn: 1, bright: col.knob(\k1), lo: 2500, hi: 14000, tone: kit[\tone]);
	main = [[\M, p[0][s16]], [\H, p[1][s16]], [\C, p[2][s16]]].select { |x| x[1].notNil };
	main.do { |x, j| out.add(hit.(x[0], x[1], feel.(j, x[0]), human.(j))) };
	if(main.isEmpty and: { ce.rand(t + 0.71) < ramp.(c, 0, 0.5) }) {
		out.add(if(k.even) { hit.(\M, \f, feel.(3, \M), human.(3)) } { hit.(\H, \T, feel.(3, \H), human.(3)) }) };
	if(c > 0.5) { [[\M, p[0][(s16 + 1) % 16]], [\H, p[1][(s16 + 1) % 16]]].do { |x|
		if(x[1] == \O and: { ce.rand(t + 0.9) < ramp.(c, 0.5, 1) }) { out.add(hit.(x[0], \f, 0.65, 0.7)) } } };
	if(c > 0.75 and: { s16 >= 13 }) { 2.do { |j|
		if(ce.rand(t + (0.5 * j) + 0.33) < ramp.(c, 0.75, 1)) { out.add(hit.(\M, \f, 0.5 * j, 0.6 + (0.2 * j))) } } };
	if(col.held(\b2)) { st[\fill][s16] !? { |d| out.add(hit.(d, \O, 0, 0.5 + (0.5 * (s16 / 15)))) } };
	out
}
)
