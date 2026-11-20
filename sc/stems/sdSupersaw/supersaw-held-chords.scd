// Column code of the 009 harmony (lab/harmonie/harmonie-4, column 2): held chords from E3 up, struck where the chord
// changes and again every 4 bars; JX-10 strings (supersaws) ↔ soft Hammond B3 (sines, slow Leslie) on knob 3. Both
// layers always sound: their blend and the low-pass follow the knobs while the chord sounds (state buses). Space: the
// labs' strip (room from 0.35, the 1/8 echo first); Echo throw: long echo while held. Format: sc/lib/stems.scd.
(
var voicing = (Am9: [55, 59, 60, 64], D9: [54, 57, 60, 64], Am7: [55, 57, 60, 64], Cmaj7: [55, 59, 60, 64],
	Em7: [55, 59, 62, 64], Fmaj7: [53, 57, 60, 64], Fadd9: [53, 55, 57, 60], Gadd9: [55, 57, 59, 62], G11: [53, 55, 60, 62],
	Dm7: [53, 57, 60, 62], Gm: [55, 58, 62, 65], 'Em/G': [55, 59, 62, 64], Dm9: [52, 53, 57, 60], Gm9: [53, 57, 58, 62],
	Bm: [59, 62, 66, 71]);
var harmNotes = { |name| var pcs = (voicing[name.asSymbol] ? []).collect { |m| m % 12 };
	(52..76).select { |m| pcs.includes(m % 12) }.keep(4) };
(
// asked at fader 0 too: its look-ahead moves the Chapter and Chords latches as in 009-house.scd
gate: false,
states: (level: 0, room: 0, echo: 0, cut: 1000, jx: 0, b3: 0),
strip: (level: \level, roomR: \room, echoSend: \echo, orbit: 3, ownDelay: [0.5, 0.15]),
update: { |col, send|
	var ce = col[\ce], br = col.knob(\k1), sp = col.knob(\k2), v = col.knob(\k3), held = col.held(\b2);
	col.setState(\level, col.knob(\fader) * (4 * (br - 0.5)).dbamp, send);
	col.setState(\room, ce.labRoom(sp), send);
	col.setState(\echo, if(held) { 0.65 } { 0.6 * ce.labEcho(sp) }, send);
	col.setState(\cut, (400 * (15 ** br)).min(18000), send);
	col.setState(\jx, cos(v * 0.5pi) * (v < 0.999).binaryValue, send);
	col.setState(\b3, sin(v * 0.5pi) * (v > 0.001).binaryValue, send);
},
notes: { |col, k|
	var ce = col[\ce], bpm = col[\track].bpm, nameAt = { |x| col.chordAtK(x, true)[\name] };
	var name = nameAt.(k), c = k, start, e, out = List[], t = k / 16, v, jx, b3, vel, at, cut, env, ev, d, held;
	var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	while { c > (k - 64) and: { nameAt.(c - 1) == name } } { c = c - 1 };
	if(c == (k - 64)) { c = 64 * (k / 64).floor };
	start = c + (64 * ((k - c) / 64).floor);
	if(start != k) { [] } {
		e = k + 1;
		while { (e - k) < 64 and: { nameAt.(e) == name } } { e = e + 1 };
		v = col.knob(\k3); jx = cos(v * 0.5pi) * (v < 0.999).binaryValue; b3 = sin(v * 0.5pi) * (v > 0.001).binaryValue;
		vel = 0.85 + (0.15 * ce.perlin(t)); at = if(k.odd) { 0.12 } { 0 };
		cut = col.stateMapOf(\cut);
		harmNotes.(name).do { |m|
			var lp = (lpOn: 1, lo: cut, hi: cut, tone: tone, thinF: thin, at: at, hold: e - k);
			env = (a: 0.35, d: 0.1, s: 1, r: 0.8);
			[[m, 0.08, 0.6, 0.5], [m + 0.1, 0.05, 0.9, 0.3]].do { |x|
				out.add(ce.note(col[\sample], (freq: x[0].midicps, unison: 2, detune: x[1], spread: x[2],
					amp: x[3] * 0.24 * vel, mix: col.stateMapOf(\jx), nolog: jx <= 0, tag: "supersaw",
					g: x[3] * 0.24 * jx * vel, midi: x[0]) ++ lp ++ env))
			};
			env = (a: 0.06, d: 0.001, s: 1, r: 0.25);
			[[0, 0.14], [12, 0.11]].do { |dg| [[-0.04, 0.3], [0.04, 0.7]].do { |dp|
				var mm = m + dg[0] + dp[0], g = dg[1] * 0.47 * vel;
				out.add(ce.note(\sdSynth, (wave: 0, freq: mm.midicps, vib: 0.8, vibmod: 0.08, pan: dp[1], amp: g,
					mix: col.stateMapOf(\b3), nolog: b3 <= 0, tag: "sine", g: g * b3, midi: mm) ++ lp ++ env))
			} };
		};
		held = col.held(\b2); ev = ce.labEcho(col.knob(\k2));
		d = (if(held) { 0.65 } { 0.6 * ev }).max(col.tensionEcho);
		if(d > 0) {
			var tf = if(held) { [0.75 * 60 / bpm, 0.62] } { [30 / bpm, 0.15 + (0.35 * ev)] };
			out.add((msg: [\n_set, col.delayNode, \time, tf[0], \feedback, tf[1]], at: at))
		};
		out
	}
}
)
)
