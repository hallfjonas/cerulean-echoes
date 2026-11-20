// Column code of the 009 bass (lab/bass/house-bass-4): lines of tokens per 16th, R root, r root short, O / o octave
// long / short, 3 5 7 scale steps above (in the bar's scale), F fifth below, g dead note, A approach the next note (a
// semitone below it), - hold, . rest. Knob 3 fades FM → M1 organ → warm analog (equal power; a side at exactly 0
// plays no notes); the change of chord comes two 16ths early. Format: sc/lib/stems.scd (column code).
(
var lines = [
	["R..R..R.R..R..R.", "R..R..R.R..R.5.A"],
	[".R.5g.7.O.gR.5.F", ".R.5g.7.O.7g5.3A"],
	["RgRgO.RgRg5.RgO7", "RgRgO.RgRg5.R.7A"],
].collect(_.join);
var sounds = [[\bassFM, 0.77], [\bassM1, 0.71], [\bassWarm, 0.69]];
var blend = [
	{ |v| if(v < 0.5) { cos(v * pi) * (v < 0.499).binaryValue } { 0 } },
	{ |v| if(v < 0.5) { sin(v * pi) * (v > 0.001).binaryValue } { cos((v - 0.5) * pi) * (v < 0.999).binaryValue } },
	{ |v| if(v > 0.5) { sin((v - 0.5) * pi) * (v > 0.501).binaryValue } { 0 } },
];
var steps = ($R: 0, $r: 0, $g: 0, $o: 7, $2: 1, $3: 2, $4: 3, $5: 4, $6: 5, $7: 6, $O: 7, $9: 8, $F: -3);
var noteToks = "Rr234567Oo9F";
var md = { |k, n| k % n };
var tone = { |col, k, tok|
	var c = col.chordAtK(k, true), sc = c[\scale], rp = c[\bass] % 12;
	var r = 41 + md.(rp - 5, 12), j = steps[tok] ? 0, onBass = "RrgOoF".includes(tok);
	var d0 = if(onBass) { sc.indexOf(rp) ? 0 } { "ABCDEFG".indexOf(c[\name][0]) };
	var iv = md.(sc[md.(d0 + j, 7)] - rp, 12);
	r + if(iv == 0 and: { onBass.not }) { 12 } { iv } + (12 * (j / 7).floor)
};
var approach = { |col, line, k|
	var t = 1, n = line.size, tok;
	while { t < 16 and: { noteToks.includes(line[md.(k + t, n)]).not } } { t = t + 1 };
	tok = line[md.(k + t, n)];
	if(noteToks.includes(tok).not) { tok = $R };
	tone.(col, k + t, tok) - 1
};
(
strip: (orbit: 1, space: \k2, trim: \trim),
maps: (
	trim: (ccs: [\k1], fn: { |b| 1.55 * (4 * (b - 0.5)).dbamp }),
	blend0: (ccs: [\k3], fn: { |v| (v < 0.5) * cos(v * pi) * (v < 0.499) }),
	blend1: (ccs: [\k3], fn: { |v| ((v < 0.5) * sin(v * pi) * (v > 0.001))
		+ ((v >= 0.5) * cos((v - 0.5) * pi) * (v < 0.999)) }),
	blend2: (ccs: [\k3], fn: { |v| (v > 0.5) * sin((v - 0.5) * pi) * (v > 0.501) }),
),
notes: { |col, k|
	var ce = col[\ce], bpm = col[\track].bpm, b = (k / 16).floor, line, n, tok, dur = 1, short, nxt, m, vel, clip, v;
	line = lines[col[\patLatch].atBar(b)]; n = line.size; tok = line[md.(k, n)];
	if(tok == $. or: { tok == $- }) { [] } {
		while { dur < n and: { line[md.(k + dur, n)] == $- } } { dur = dur + 1 };
		short = (tok == $r) or: { tok == $o };
		nxt = line[md.(k + dur, n)];
		m = if(tok == $A) { approach.(col, line, k) } { tone.(col, k, tok) } + if(col.held(\b2)) { 12 } { 0 };
		vel = if(tok == $g) { 0.3 } { if(md.(k, 4) == 2) { 1 } { if(md.(k, 2) == 1) { 0.8 } { 0.9 } } };
		clip = 0.933 * if(tok == $g) { 0.35 } { if(short) { 0.4 } { if(nxt == $.) { 0.85 } { 1.02 } } };
		v = col.knob(\k3);
		sounds.collect { |sg, i|
			if(blend[i].(v) > 0) {
				ce.note(sg[0], (freq: m.midicps, amp: sg[1] * vel, hold: dur * clip,
					at: if(k.odd) { 0.12 } { 0 },
					bright: ce.ccMap(col[\ccs][\k1]), tone: ("c" ++ ce.toneBus).asSymbol,
					dark: (tok == $g).binaryValue, level: col.mapBusOf(("blend" ++ i).asSymbol),
					midi: m, len16: dur * clip, vel: vel,
					// comparisons only: the modulator phase superdough has offline (started at time 0)
					modPhase: if(ce.webaudioPhase == true) {
						(2pi * m.midicps * ((k + if(k.odd) { 0.12 } { 0 }) / 4 / (bpm / 60))) % 2pi } { -1 }))
			}
		}.reject(_.isNil)
	}
}
)
)
