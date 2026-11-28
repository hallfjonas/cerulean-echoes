// Column code of the lsd leads (017-lsd-fx-2): the two leads of 017-groove-lsd in one column, the hypnotic FM mallet loop
// (techno-seq.scd) and the rubbery answer blips (lsd-answer.scd). Button 1 steps through seven combinations: the loop alone,
// the blips alone, four duos of a loop and a phrase, and a trade (the loop in bars 1-4 of 8, the blips in bars 5-8). The
// blips also play where the stab leaves a bar (frame.stabGap). Complexity fills the loop in and adds the blips' voices.
// Button 2 lifts the loop an octave. Space scales room and echo of both.
// The Launchkey keys (keys, the frame's lkKeys): a key plays one note of the FM mallet loop at its own pitch (button 2
// lifts it an octave); Complexity blends the rubbery blip in, an octave up.
(
states: (room: 0.9 * 0.3, echo: 0.5 * 2 * 0.3),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = 0.3 + (0.7 * col.knob(\k2));
	col.setState(\room, 0.9 * s, send); col.setState(\echo, (0.5 * 2 * s).min(0.9), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var rg = col.knob(\k3), r = ce.rand(t), mood = tr.chapterAt(b), root = fr.rootAt(tr, b), combo, half, loop, blips;
	st[\combos] = st[\combos] ?? { [[0, nil], [nil, 0], [0, 0], [2, 3], [4, 1], [6, 5], [3, 7, \trade]] };
	st[\seqs] = st[\seqs] ?? { ["0 ~ 0 4 ~", "0 ~ 6 ~ 4 ~ 0", "0 4 ~", "0 ~ ~ 2 ~ 4 ~", "4 ~ 0 ~ 0", "0 ~ 3 ~ 0 4 ~", "6 ~ 4 ~ ~", "0 0 ~ 4 ~ 2 ~"].collect(kit[\line]) };
	st[\extras] = st[\extras] ?? { [
		[[0.12, 0, 11], [0.245, 0, 4], [0.37, 2, 9], [0.495, 6, 15], [0.62, -3, 3], [0.745, -3, 2], [0.87, -7, 1], [0.995, 11, 5]],
		[[0.12, 2, 14], [0.245, 2, 8], [0.37, 0, 0], [0.495, -3, 4], [0.62, 6, 13], [0.745, 7, 7], [0.87, 7, 5], [0.995, 11, 10]],
		[[0.12, 2, 14], [0.245, 4, 0], [0.37, 2, 1], [0.495, 4, 15], [0.62, 4, 10], [0.745, 6, 2], [0.87, 7, 3], [0.995, 11, 13]],
		[[0.12, 0, 0], [0.245, 2, 10], [0.37, 4, 1], [0.495, 4, 2], [0.62, -3, 3], [0.745, 4, 9], [0.87, -7, 14], [0.995, 7, 12]],
		[[0.12, 2, 13], [0.245, 0, 14], [0.37, 2, 15], [0.495, 6, 11], [0.62, 6, 7], [0.745, -3, 3], [0.87, -4, 8], [0.995, -4, 1]],
		[[0.12, 4, 4], [0.245, 0, 3], [0.37, 2, 2], [0.495, 4, 9], [0.62, -3, 10], [0.745, 4, 1], [0.87, 7, 13], [0.995, -4, 7]],
		[[0.12, 2, 11], [0.245, 0, 3], [0.37, 2, 0], [0.495, 6, 10], [0.62, 7, 15], [0.745, 7, 5], [0.87, -7, 13], [0.995, 7, 4]],
		[[0.12, 4, 0], [0.245, 4, 11], [0.37, 2, 12], [0.495, 4, 1], [0.62, 6, 7], [0.745, 6, 6], [0.87, 7, 4], [0.995, 7, 8]]] };
	st[\rhythms] = st[\rhythms] ?? { ["~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x x ~",
		"~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~ x", "~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ x ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ ~ ~ ~ ~",
		"~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x ~ ~ x ~", "~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~ ~ ~ x x"].collect { |x| x.split($ ).collect(_ == "x") } };
	loop = { |v| var l = st[\seqs][v], d = l[k % l.size], degs = List[];
		if(d.notNil and: { r > (0.5 * (1 - rg)) }) { degs.add([d + if(r < (0.25 * rg)) { [1, -1][b % 2] } { 0 }, 1]) };
		st[\extras][v].do { |x| if(rg > x[0] and: { s16 == x[2] }) { degs.add([x[1], 0.85]) } };
		degs.collect { |x|
			var m = fr.degMidi(x[0] + root, 4, mood) + if(col.held(\b2)) { 12 } { 0 } + (-0.06 + (0.12 * r));
			var g = 0.8 * (0.47 + (0.27 * ce.perlin(t))) * x[1], f = m.midicps;
			kit[\syn].(\sine, m, g, (fmi: 0.4 + (1.6 * col.knob(\k1)), fmh: 2, modPhase: kit[\modPhase].(k, 0, f * 2, tr.bpm), hold: 1,
				pan: 0.35 + (0.3 * ce.sine(t / 3)), lpOn: 1, bright: col.knob(\k1), lo: 1500, hi: 12000, tone: kit[\tone])
				++ kit[\adsr].(0.003, 0.28, 0, 0.25)) } };
	blips = { |v| var wild = kit[\ramp].(rg, 0.75, 1), tones = [0, 2, 4, 6, 7], n = 0, tn, lp, out = List[];
		if((b % 2) == 1) { if(st[\rhythms][v][s16]) { n = 1 } } {
			if(wild > 0 and: { st[\rhythms][v][s16] } and: { r >= (1 - (0.6 * wild)) }) { n = n + 1 };
			if(st[\rhythms][v][s16] and: { fr[\stabGap].notNil } and: { fr.stabGap(tr, b) }) { n = n + 1 } };
		tn = tones[(5 * ce.rand(t + (1024 * v))).trunc.asInteger];
		lp = (lpOn: 1, bright: col.knob(\k1), lo: 2000, hi: 12000, tone: kit[\tone], hold: 1, pan: [0.12, 0.88][s16 % 2],
			penv: 0.5, pd: 0.03, ps: 0.001) ++ kit[\adsr].(nil, 0.085, 0, 0.06);
		n.do { [[0, 0.54, 0], [2, kit[\ramp].(rg, 0, 0.375) * 0.42, 1], [4, kit[\ramp].(rg, 0.375, 0.75) * 0.36, 2], [6, wild * 0.3, 3]].do { |x|
			if(x[1] > 0) { var m = fr.degMidi(tn + x[0] + root, 5, mood);
				out.add(kit[\syn].(\square, m, x[1], lp ++ (at: x[2] * wild / 4)));
				out.add(kit[\syn].(\sine, m + 12, 0.35 * x[1], lp ++ (at: x[2] * wild / 4) ++ kit[\adsr].(nil, 0.06, 0, 0.04))) } } };
		out };
	combo = st[\combos][col[\patLatch].atBar(b)];
	half = if(combo[2] == \trade) { (b % 8) < 4 };
	(if(combo[0].notNil and: { half != false }) { loop.(combo[0]) } { [] })
		++ (if(combo[1].notNil and: { half != true }) { blips.(combo[1]) } { [] })
},
keys: { |col, note, vel|
	var ce = col[\ce], kit = ce.kitOf(col), t = TempoClock.default.beats / 4, blip = kit[\ramp].(col.knob(\k3), 0.5, 1);
	var m = note + if(col.held(\b2)) { 12 } { 0 }, out = List[];
	out.add(kit[\syn].(\sine, m, 0.8 * 0.6 * vel, (fmi: 0.4 + (1.6 * col.knob(\k1)), fmh: 2, hold: 1,
		pan: 0.35 + (0.3 * ce.sine(t / 3)), lpOn: 1, bright: col.knob(\k1), lo: 1500, hi: 12000, tone: kit[\tone])
		++ kit[\adsr].(0.003, 0.28, 0, 0.25)));
	if(blip > 0) { var lp = (lpOn: 1, bright: col.knob(\k1), lo: 2000, hi: 12000, tone: kit[\tone], hold: 1,
			penv: 0.5, pd: 0.03, ps: 0.001) ++ kit[\adsr].(nil, 0.085, 0, 0.06);
		out.add(kit[\syn].(\square, m + 12, 0.54 * blip * vel, lp));
		out.add(kit[\syn].(\sine, m + 24, 0.35 * 0.54 * blip * vel, lp ++ kit[\adsr].(nil, 0.06, 0, 0.04))) };
	out.asArray
}
)
