// Column code of the lsd-fx radio (017-lsd-fx-2): a broken transmission from deep space in the 6th bar of every 8-bar
// phrase (some reach into the 7th), in the middle, on the root, 5th or octave of the mood. Seven gestures: mayday (SOS
// in Morse, sent again lower and breaking off), sat (a satellite's two-tone beeps passing by, falling in pitch), pulsar
// (ticking in triplets over two low thumps), chime (a numbers station's wobbly four-note chime, again an octave down
// and fainter), glitch (scattered square bursts at wild pitches and a stutter), siren (a distant two-tone siren rising
// and falling), doom (a low FM drone swelling under rumble, a high tone falling away). Static (row 3): clean ↔ crackle
// and hiss around it, notes drifting and dropping out. Button 1: one gesture at random each phrase, then the seven in
// turn. Button 2 (Tune): a whistle and hiss gliding like a turned shortwave dial, while held. Space scales room (from
// 0.15) and echo (from 0.25).
// The Launchkey keys (keys, the frame's lkKeys): a key sends the first beat of the gesture (a random one per press
// while Pattern is on Random) an octave above its own pitch; Static drops notes and drifts them as in the column.
(
var morse = (o: "---", s: "...");
// a word as [[start, length]] in 16ths: dit 1/2, dah 3/2, a 1/2 gap inside a letter, 3/2 between letters
var timeline = { |word| var at = 0, out = List[];
	word.do { |ch| morse[ch.asSymbol].do { |sym| var len = if(sym == $-) { 1.5 } { 0.5 }; out.add([at, len]); at = at + len + 0.5 };
		at = at + 1 };
	out };
var sos = timeline.("sos");
// a gesture: phrase number, a random function -> events (pos and len in 16ths from the bar's start, m = semitones over the
// base note, noise: a noise colour instead of a wave, args: more note arguments)
var gestures = [
	{ |ph, r| sos.collect { |e, i| (pos: e[0], len: e[1], wave: \square, m: -0.1 * i, g: 0.14, bp: 1800) }
		++ sos.select { |e| e[0] < 8 }.collect { |e, i| (pos: 16 + e[0], len: e[1], wave: \square, m: -2 - (0.3 * i),
			g: 0.1 * (1 - (i / 8)), bp: 1400, drop: 0.15 + (0.08 * i)) } },
	{ |ph, r| 8.collect { |i| var p = i / 8; (pos: 2 * i, len: 0.75, wave: \square, m: [12, 7][i % 2] + 2.5 - (5 * p),
		g: 0.13 * (0.3 + (0.7 * sin(pi * (p + 0.06)))), pan: 0.15 + (0.7 * p), bp: 2200) } },
	{ |ph, r| 24.collect { |i| var p = i / 24; (pos: i * 2 / 3, len: 0.1, noise: 1, g: 0.2 * sin(pi * p), bp: 3000, bpq: 1,
		pan: 0.4 + (0.2 * r.(i + 0.5))) }
		++ [0, 8].collect { |p| (pos: p, len: 2, wave: \sine, m: -24, g: 0.3, args: (penv: 12, pd: 0.08, ps: 0.001)
			++ (a: 0.001, d: 0.3, s: 0, r: 0.05)) } },
	{ |ph, r| [[0, 12], [1.5, 7], [3, 3], [4.5, 0]].collect { |x, i| [0, 8].collect { |rep|
		(pos: x[0] + rep, len: 1.5, wave: \triangle, m: x[1] - (12 * (rep / 8)) + (0.3 * (r.(i + rep + 0.7) - 0.5)),
			g: 0.16 * [1, 0.45][rep / 8], args: (vib: 5, vibmod: 0.15) ++ (a: 0.005, d: 0.4, s: 0, r: 0.1)) } }.flatten },
	{ |ph, r| 12.collect { |i| (pos: (r.(i + 0.1) * 32).trunc / 2, len: [0.25, 0.5][(r.(i + 0.2) * 2).trunc], wave: [\square, \sawtooth][i % 2],
		m: [-12, 0, 7, 19, 24, 31][(r.(i + 0.3) * 6).trunc], g: 0.035, args: (shape: 0.6)) }
		++ 4.collect { |i| (pos: 10 + (i / 2), len: 0.25, wave: \square, m: 19, g: 0.04 * (1 - (0.2 * i)), args: (shape: 0.6)) } },
	{ |ph, r| var curve = { |i| -5 + (12 * (sin(pi * (i / 24).clip(0, 1)) ** 0.7)) };
		24.collect { |i| [0, 6].collect { |dm, j| (pos: i, len: 1, wave: \sawtooth, m: curve.(i) + dm, g: 0.15 * [1, 0.5][j],
			bp: 1200, bpq: 3, args: (penv: curve.(i - 1) - curve.(i), pd: 0.11, ps: 0.001) ++ (a: 0.005, d: 0.1, s: 1, r: 0.03)) } }.flatten },
	{ |ph, r| 4.collect { |i| (pos: 4 * i, len: 4, wave: \sine, m: -36, g: 0.2 * sin(pi * ((i + 0.5) / 4)),
		args: (fmi: 0.5 + (0.8 * i), fmh: 0.5) ++ (a: 0.1, d: 0.1, s: 1, r: 0.2)) }
		++ 4.collect { |i| (pos: 4 * i, len: 4, noise: 0, g: 0.08, bp: 200, bpq: 1, args: (a: 0.2, d: 0.1, s: 1, r: 0.3)) }
		++ [(pos: 12, len: 8, wave: \sine, m: 12, g: 0.05, args: (penv: 0.001, pd: 0.001, ps: 0.001, vib: 0.3, vibmod: 2)
			++ (a: 0.3, d: 1.8, s: 0, r: 0.3))] }
];
(
states: (room: 0.9 * 0.15, echo: 0.25),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.15 + (0.6 * s)), send); col.setState(\echo, 0.25 + (0.45 * s), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), st = col[\st], tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16;
	var adsr = kit[\adsr], syn = kit[\syn], noise = kit[\noise], c = col.knob(\k3), out = List[];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 3000, hi: 12000, tone: kit[\tone]);
	var start = (b - (b % 8) + 5) * 16, ph = (b / 8).floor, sb = (start / 16).floor, v = col[\patLatch].atBar(sb);
	var r = { |o| ce.rand(ph + (0.01 * o) + 0.83) };
	var g = gestures[if(v > 0) { v - 1 } { (r.(0.37) * gestures.size).trunc.asInteger }];
	var evs = if((k >= (start - 4)) and: { k < (start + 36) }) { g.(ph, r) } { [] };
	var m0 = fr.degMidi([0, 4, 7][(ce.rand(ph + 0.23) * 3).trunc.asInteger], 5, tr.chapterAt(sb));
	var span = evs.collect { |e| e[\pos] + e[\len] }.maxItem ? 0;
	evs.select { |e| (start + e[\pos]).floor == k }.do { |e, i|
		var gone = ce.rand(k + (0.01 * i) + 0.53) < ((e[\drop] ? 0) + (0.35 * c));
		var a = lp ++ (at: e[\pos] % 1, hold: e[\len], pan: e[\pan] ?? { 0.46 + (0.08 * ce.rand(k + 0.19)) })
			++ if(e[\bp].notNil) { (bp: e[\bp], bpq: e[\bpq] ? 2) } { () } ++ adsr.(0.003, nil, 1, 0.01);
		if(gone.not) {
			if(e[\noise].notNil) { out.add(noise.(e[\noise], e[\g], a ++ (e[\args] ? ()))) } {
				var drift = if((e[\args] ? ())[\penv].isNil) { (penv: c * 0.6 * (ce.rand(k + 0.43) - 0.5), pd: 0.2, ps: 0.001) } { () };
				out.add(syn.(e[\wave], m0 + e[\m], e[\g], a ++ drift ++ (e[\args] ? ()))) } } };
	if(c > 0 and: { k >= (start - 4) } and: { k < (start + span + 4) } and: { ce.rand(t + 0.07) < (0.6 * c) }) {
		out.add(noise.(1, (0.04 + (0.1 * ce.rand(t + 0.11))) * c, lp ++ (at: ce.rand(t + 0.13), hold: 0.1 + (0.3 * ce.rand(t + 0.17)),
			bp: 2500, bpq: 1.5, pan: 0.4 + (0.2 * ce.rand(t + 0.29))) ++ adsr.(0.001, nil, 1, 0.01))) };
	if(col.held(\b2)) { var mm = 74 + (26 * ce.perlin(t * 1.5)), was = st[\tune] ? mm;
		st[\tune] = mm;
		out.add(syn.(\sine, mm, 0.07, lp ++ (hold: 1, pan: 0.5, penv: was - mm, pd: 0.11, ps: 0.001) ++ adsr.(0.005, nil, 1, 0.03)));
		out.add(noise.(1, 0.05, lp ++ (hold: 1, bp: 2 * mm.midicps, bpq: 4, pan: 0.5) ++ adsr.(0.01, nil, 1, 0.03))) } { st[\tune] = nil };
	out.reject { |n| n.amp <= 0 }
},
keys: { |col, note, vel|
	var ce = col[\ce], kit = ce.kitOf(col), c = col.knob(\k3), v = col[\patLatch].now, out = List[];
	var g = gestures[if(v > 0) { v - 1 } { gestures.size.rand }];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 3000, hi: 12000, tone: kit[\tone]);
	g.(0, { |o| 1.0.rand }).select { |e| e[\pos] < 4 }.do { |e|
		var a = lp ++ (at: e[\pos], hold: e[\len].min(4 - e[\pos]), pan: e[\pan] ? 0.5)
			++ if(e[\bp].notNil) { (bp: e[\bp], bpq: e[\bpq] ? 2) } { () } ++ kit[\adsr].(0.003, nil, 1, 0.01);
		if(1.0.rand >= ((e[\drop] ? 0) + (0.35 * c))) {
			if(e[\noise].notNil) { out.add(kit[\noise].(e[\noise], e[\g] * vel, a ++ (e[\args] ? ()))) } {
				var drift = if((e[\args] ? ())[\penv].isNil) {
					(penv: c * 0.6 * (1.0.rand - 0.5), pd: 0.2, ps: 0.001) } { () };
				out.add(kit[\syn].(e[\wave], note + 12 + e[\m], e[\g] * vel, a ++ drift ++ (e[\args] ? ()))) } } };
	out.reject { |n| n.amp <= 0 }.asArray
}
)
)
