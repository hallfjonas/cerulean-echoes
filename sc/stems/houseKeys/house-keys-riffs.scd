// Column code of the 009 keys (keys lab round 19): short stabs in Kerri Chandler's voicing, 6 rhythms on Am9 (D9 in
// the Am9 D9 progression), then 5 riffs that bring their own chords: while the fader is up the frame takes the riff's
// chords for the whole track (col.riffAt). Six sounds in three pairs (piano → Rhodes, B3 → M1, vibes → marimba):
// Sound (button 2) turns the knobs into the sound mix and the fader into the overtones. A hit before a longer rest is
// harder. Format: sc/lib/stems.scd (column code).
(
var rb = { |...bars| bars.join };
var riff = { |name, rhythm, seq, voic, names| [name, rhythm, (seq: seq, voic: voic, names: names)] };
var keyPats = [
	["Chain", ".x..x..x.x..x..x", nil], ["Shifted chain", "...x..x..x.x..x.", nil], ["Pairs", ".x.x..x..x.x..x.", nil],
	["3-3-2", "x..x..x...x..x..", nil], ["Kerri syncopation", "..x..x...x.x..x.", nil], ["Kerri-Riff", "x..x..x..x..x.x.", nil],
	riff.("Kerri video", "x..x..x..x..x.x.", "AAAAAADDDDDDDDGG",
		(A: [55, 59, 60, 64], D: [48, 52, 53, 57], G: [53, 57, 58, 62]), (A: "Am9", D: "Dm9", G: "Gm9")),
	riff.("Checkmate", rb.("..x..x..x.x..x.x", "..x..x..x.x..x.x"), rb.("AAAAAAAAAAAAAAAG", "GGGGGGGGGGGGGGGA"),
		(A: [57, 60, 64], G: [58, 62, 67]), (A: "Am7", G: "Gm")),
	riff.("Atmosphere", rb.("..x...x...x...x.", "..x...x...x..x.."), rb.("MMMMMMMMMMfMMMMM", "qqqqqqqqqqqqqqqq"),
		(M: [55, 57, 60, 64], f: [55, 57, 62, 64], q: [55, 59, 64]), (M: "Am7", f: "Am7", q: "Em/G")),
	riff.("Turn Off", rb.("x..x..x..x..x.x.", "..x..x..x...x..x"), rb.("AAAAAADDDDDDEEEE", "bbbbbvvvvvvvbbbA"),
		(A: [57, 60, 64], D: [57, 62, 65], E: [59, 64, 67], b: [59, 62, 66], v: [54, 59, 62]),
		(A: "Am7", D: "Dm7", E: "Em7", b: "Bm", v: "Bm")),
	riff.("Chicago", rb.("x...x...x-.x..x.", "..x..x.....x....", "x...x...x-.x..x.", "..x..x.....x...."),
		rb.("AAAAAAAAAAAAAACC", "CCCCCCCCCCCCCCCC", "FFFFFFFFFFFFFFDD", "DDDDDDDDDDDDDDDD"),
		(A: [55, 59, 60, 64], C: [55, 59, 62, 64], F: [57, 60, 64, 65], D: [54, 57, 60, 64]),
		(A: "Am9", C: "Cmaj7", F: "Fmaj7", D: "D9")),
];
var isHit = { |c| c != $. and: { c != $- } };
var gapT = { |p, i| var d = 1; while { d < p.size and: { isHit.(p[(i + d) % p.size]).not } } { d = d + 1 };
	(0.2 + (0.2 * d)).min(0.9) };
var touch = keyPats.collect { |kp|
	var p = kp[1], hits = (0..p.size - 1).select { |i| isHit.(p[i]) }, mean = hits.collect { |i| gapT.(p, i) }.sum / hits.size;
	var t = (0..p.size - 1).collect { |i| if(isHit.(p[i])) { (0.5 + ((gapT.(p, i) - mean) * 4 * 0.25)).clip(0, 1) } { 0 } };
	var w = p.as(Array).collect { |c| if(c == $x) { 0.64 } { 0 } }.sum;
	var d = (0..p.size - 1).collect { |i| if(isHit.(p[i])) { (0.8 * (0.6 + (0.8 * t[i]))).squared } { 0 } }.sum;
	(touch: t, norm: (w / d).sqrt)
};
var voicing = (Am9: [55, 59, 60, 64], D9: [54, 57, 60, 64]);
var m1k = 0.42, keyLevel = 0.88;
var range = (piano: [250, 8100], rhodes: [250, 2000], b3: [250, 2000], m1: [250, 5000], vibes: [250, 4000], marimba: [250, 3000]);
var sweep = { |v| if(v < (1/3)) { [3 * v, 0] } { if(v > (2/3)) { [3 - (3 * v), 1] } { [1, (3 * v) - 1] } } };
var xfade = { |c| [cos(c * 0.5pi), sin(c * 0.5pi)].collect { |x| if(x < 1e-6) { 0 } { x } } };
var pairLevels = { |v, dip = 0| var lc = sweep.(v), ab = xfade.(lc[1]), d = (dip.neg * sin(pi * lc[1])).dbamp;
	[lc[0] * ab[0] * d, lc[0] * ab[1] * d] };
(
// with Sound on the fader sets the overtones, not the level: the column is not gated on its fader
gate: false,
states: (level: 0, room: 0, echo: 0),
strip: (level: \level, roomR: \room, echoSend: \echo, orbit: 3, ownDelay: [0.5, 0.15]),
start: { |col, ce|
	var ks = (val: [0, 0, 0, 0], mix: [0.5, 0, 0], e: 0.5, shift: 0);
	col[\st][\ks] = ks;
	ce.cycleButton(col[\ccs][\b2], 2, { |sh| ks.shift = sh; ce.status("Keys", if(sh == 1) { "SOUND" } { "normal" }); ce.uiPush });
	[\k1, \k2, \k3, \fader].do { |kk, i| ce.onCC(col[\ccs][kk], { |v, send|
		if(ks.shift == 1) { if(i < 3) { ks.mix[i] = v } { ks.e = v } } { ks.val[i] = v } }) };
	// a riff brings its own chords while the keys fader is up: the frame asks here
	col[\riffAt] = { |c, b| if(ks.val[3] <= 0) { nil } { keyPats[c[\patLatch].atBar(b)][2] } };
},
update: { |col, send| var ce = col[\ce], ks = col[\st][\ks];
	col.setState(\level, ks.val[3], send);
	col.setState(\room, ce.labRoom(ks.val[1]), send);
	col.setState(\echo, 0.6 * ce.labEcho(ks.val[1]), send);
},
notes: { |col, k|
	var ce = col[\ce], ks = col[\st][\ks], bpm = col[\track].bpm, maps = ce.sounds[col[\sample]][\maps];
	var b = (k / 16).floor, step = k % 16, pix = col[\patLatch].atBar(b), kp = keyPats[pix], pat = kp[1], rf = kp[2];
	var pos = if(rf.notNil) { k % pat.size } { step }, sym = pat[pos], ties = 0, notes, out = List[];
	var br, sp, len, kt, hitT, hitGain, hitCut, res, tGain, tAtk, ev, dur, layers, at, tEcho;
	var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	if(isHit.(sym).not) { [] } {
		while { (pos + ties + 1) < pat.size and: { pat[pos + ties + 1] == $- } } { ties = ties + 1 };
		notes = if(rf.notNil) { rf.voic[rf.seq[pos].asSymbol] } {
			var ch = col.chordAt(if(step >= 14) { b + 1 } { b }); voicing[ch[\name].asSymbol] ? voicing[\Am9] };
		#br, sp, len = ks.val;
		kt = touch[pix]; hitT = kt.touch[pos];
		hitGain = (0.6 + (0.8 * hitT)) * kt.norm * 0.8;
		hitCut = 2 ** (8 * ks.e * (hitT - 0.5));
		res = 4 + (8 * ((br - (2/3)) * 3).max(0)); tGain = (4 * (br - 0.5)).dbamp;
		tAtk = if(br < 0.3) { 0.02 * (1 - (br / 0.3)) } { 0 };
		ev = ce.labEcho(sp); tEcho = col.tensionEcho;
		dur = (1 + ties) * (4 ** len);
		at = if(k.odd) { 0.12 } { 0 };
		layers = [[\piano, pairLevels.(ks.mix[0], -1.3)[0]], [\rhodes, pairLevels.(ks.mix[0], -1.3)[1]],
			[\b3, pairLevels.(ks.mix[1], 1.3)[0]], [\m1, pairLevels.(ks.mix[1], 1.3)[1]],
			[\vibes, pairLevels.(ks.mix[2])[0]], [\marimba, pairLevels.(ks.mix[2])[1]]].select { |l| l[1] > 0 };
		layers.do { |l|
			var src = l[0], cut = range[src][0] * ((range[src][1] / range[src][0]) ** br) * hitCut;
			var base = (lpOn: 1, lo: cut, hi: cut, tone: tone, lpq: res, thinF: thin, hold: dur, at: at, pan: 0.47);
			var gainOf = { |g| keyLevel * g * 0.955 * hitGain * tGain * l[1] };
			notes.do { |n|
				switch(src,
					\piano, { var key = ce.closestKey(maps[\piano], n), g = gainOf.(0.6 * 0.49 / 0.955 * 0.99);
						out.add(ce.note(col[\sample], base ++ (buf: ce.sampleBuffers[key[1]], stereoIn: 1,
							rate: 2 ** ((n - key[0]) / 12), amp: g, a: tAtk.max(0.001), d: 0.001, s: 1, r: 0.15, tag: "stein",
							g: g, midi: n))) },
					\rhodes, { var key = ce.closestKey(maps[\rhodes], n), g = gainOf.(0.6 * 0.292 / 0.955 * 0.902);
						out.add(ce.note(col[\sample], base ++ (buf: ce.sampleBuffers[key[1]], stereoIn: 0,
							rate: 2 ** ((n - key[0]) / 12), amp: g, a: tAtk.max(0.001), d: 0.001, s: 1, r: 0.15, tag: "jrh",
							g: g, midi: n))) },
					\b3, { [0, 19, 12].do { |d, j| [-0.04, 0.04].do { |dt, side|
						var g = gainOf.([0.12, 0.07, 0.1][j] * 1.82 * 0.85), m = n + d + dt;
						out.add(ce.note(\sdSynth, base ++ (wave: 0, freq: m.midicps, vib: 0.8, vibmod: 0.08,
							pan: [0.3, 0.7][side], amp: g, a: 0.004.max(tAtk), d: 0.001, s: 1, r: 0.15, tag: "sine", g: g,
							midi: m))) } } },
					\m1, { [[3, 12, 0.22, 0.002, 0.25, 0.7], [0, 24, 0.18, 0.002, 0.25, 0.7], [0, 31, 0.25, 0.001, 0.08, 0]].do { |x|
						var g = gainOf.(x[2] * m1k * 1.85), m = n + x[1];
						out.add(ce.note(\sdSynth, base ++ (wave: x[0], freq: m.midicps, amp: g, a: x[3].max(tAtk), d: x[4],
							s: x[5], r: 0.15, tag: if(x[0] == 3) { "square" } { "sine" }, g: g, midi: m))) } },
					\vibes, { var g = gainOf.(0.65 * 0.91), z = ce.fontNote("0110_JCLive_sf2_file", n - 12);
						z !? { out.add(ce.note(\sdFont, base ++ z ++ (amp: g, a: tAtk.max(0.001), d: 0.001, s: 1, r: 0.15,
							tag: "gm_vibraphone", g: g, midi: n - 12))) } },
					\marimba, { var g = gainOf.(0.7 * 1.38), z = ce.fontNote("0120_JCLive_sf2_file", n);
						z !? { out.add(ce.note(\sdFont, base ++ z ++ (amp: g, a: tAtk.max(0.001), d: 0.001, s: 1, r: 0.15,
							tag: "gm_marimba", g: g, midi: n))) } }
				)
			}
		};
		if((0.6 * ev).max(tEcho) > 0) {
			out.add((msg: [\n_set, col.delayNode, \time, 30 / bpm, \feedback, 0.15 + (0.35 * ev)], at: at)) };
		out
	}
}
)
)
