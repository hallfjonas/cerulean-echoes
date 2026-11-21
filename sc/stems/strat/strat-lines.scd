// Column code of the 009 guitar (lab/gitarre/disco-gitarre-3): plucked Stratocaster notes, eight lines [16th, length,
// what (top / ch / pen / strum, step), accent] on the chord tones; Complexity in four steps: line → + dead notes on the
// e's → + a variation (one chord tone up) in bars 4 and 8 → + a 16th motor of dead notes and a pentatonic fill at the
// end of bar 8. Lift (button 2 held): phaser, brighter, echo, +3 dB. Format: sc/lib/stems.scd (column code).
(
var gn = { |p, len, what, acc = 1| (p: p, len: len, what: what, acc: acc) };
var lines = [
	[16, [gn.(2, 2, [\top, 0]), gn.(6, 1, [\ch, 0]), gn.(8, 2, [\top, 12]), gn.(11, 1, [\strum]), gn.(15, 1, [\strum])]],
	[16, [gn.(9, 1, [\ch, 2]), gn.(10, 1, [\ch, 1]), gn.(11, 1, [\ch, 0]), gn.(12, 3, [\top, 0], 1.1)]],
	[32, [gn.(4, 1, [\ch, 1]), gn.(6, 1, [\ch, 0]), gn.(7, 2, [\top, 0]), gn.(20, 1, [\top, -1]), gn.(22, 1, [\ch, 0]),
		gn.(24, 2, [\ch, 1])]],
	[16, [gn.(0, 2, [\top, 0], 1.1), gn.(3, 2, [\top, 0]), gn.(6, 2, [\top, 0]), gn.(10, 1, [\top, 0], 0.8)]],
	[64, [gn.(56, 1, [\pen, 4]), gn.(57, 1, [\pen, 3]), gn.(58, 2, [\pen, 2]), gn.(60, 1, [\pen, 1]), gn.(61, 3, [\pen, 0]),
		gn.(0, 2, [\top, 0])]],
	[16, [gn.(3, 1, [\top, 0]), gn.(6, 1, [\top, 0]), gn.(7, 1, [\ch, 0]), gn.(11, 1, [\top, 0]), gn.(14, 2, [\top, -1])]],
	[16, [gn.(1, 1, [\top, 0]), gn.(2, 1, [\ch, 0]), gn.(5, 1, [\top, 0]), gn.(6, 1, [\ch, 0]), gn.(9, 1, [\top, 0]),
		gn.(10, 1, [\ch, 1]), gn.(13, 2, [\top, 0])]],
	[16, [gn.(13, 1, [\ch, 1]), gn.(14, 1, [\ch, 0]), gn.(15, 1, [\top, -1]), gn.(0, 2, [\top, 0], 1.25), gn.(6, 1, [\top, 0], 0.8)]],
];
var penta = [9, 0, 2, 4, 7];
// begin 0.0032 of the original 4.01 s files (176912 frames), the cut files are 1.5 s (66150 frames)
var begin = 0.0032 * 176912 / 66150;
var chordUp = { |ce, c, m| var p = ce.chordPcs(c), x = m + 1; while { p.includes(x % 12).not } { x = x + 1 }; x };
var pitch = { |ce, what, c, sc, up|
	var t0 = ce.chordNear(c, 67, 79, 72), top = if(up) { chordUp.(ce, c, t0) } { t0 }, w = what[0], r = what[1];
	switch(w,
		\top, { [if(r == 12) { top + 12 } { ce.scaleSteps(top, sc, r) }] },
		\ch, { [ce.chordBelow(c, top, 3)[r]] },
		\pen, { [57 + 12 + penta[r] - 9 + (if(penta[r] < 9) { 12 } { 0 }) + (if(up) { 2 } { 0 })] },
		\strum, { ce.chordBelow(c, top + 1, 2) },
		{ [] })
};
(
gate: false,
states: (level: 0, room: 0, echo: 0),
strip: (level: \level, roomR: \room, echoSend: \echo, orbit: 3, ownDelay: [0.5, 0.15]),
start: { |col, ce| col[\st][\lift] = 0; col[\st][\lastHeld] = false; col[\st][\held] = false },
update: { |col, send| var sp = col.knob(\k2);
	col[\st][\held] = col.held(\b2);
	col.setState(\level, col.knob(\fader) * 0.76 * (4 * (col.knob(\k1) - 0.5)).dbamp, send);
	col.setState(\room, 0.8 * ((sp - 0.35) / 0.65).max(0), send);
},
notes: { |col, k|
	var ce = col[\ce], st = col[\st], bpm = col[\track].bpm, maps = ce.sounds[col[\sample]][\maps];
	var lms = 16 / (240 / bpm * 1000), tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var lift = ce.liftStep(st, k), li = col[\patLatch].atBar((k / 16).floor), ln = lines[li], len = ln[0], notes = ln[1];
	var p = k % len, s16 = k % 16, p128 = k % 128, bar8 = (p128 / 16).floor;
	var v3 = col.knob(\k3), lvl = if(v3 < 0.25) { 0 } { if(v3 < 0.5) { 1 } { if(v3 < 0.75) { 2 } { 3 } } }, lg = (3 * lift).dbamp;
	var c = col.chordAtK(k, true), sc = c[\scale], out = List[];
	var inFill = lvl >= 3 and: { p128 >= 120 };
	var hits = if(inFill) { [gn.(p, 1, [\pen, 4 - (4.min(((p128 - 120) * 5 / 8).floor))], if(p128 == 120) { 1.1 } { 0.9 })] } {
		notes.select { |n| n[\p] == p } };
	var up = lvl >= 2 and: { bar8 == 3 or: { bar8 == 7 } };
	var bright = 0.85 + (0.5 * lift), sp = col.knob(\k2), e = if(sp > 0) { (0.4 + (1.2 * sp)).min(1) } { 0 };
	var cut = 800 * ((7000 / 800) ** col.knob(\k1)) * bright;
	var tSec = { |dt| (k + dt) / 16 * 240 / bpm };
	var play = { |take, m, dur, a, r, g, dt, lpCut|
		var key = ce.closestKey(maps[take], m);
		ce.swingAt(k + dt).do { |sw| out.add(ce.note(if(lift > 0) { \sdSamplePh } { col[\sample] }, (buf: ce.sampleBuffers[key[1]],
			stereoIn: 1, begin: begin, rate: 2 ** ((m - key[0]) / 12), amp: g, a: a, d: 0.001, s: 1, r: r, hold: dur,
			at: dt + sw, pan: 0.4, lpOn: 1, lo: lpCut.min(18000), hi: lpCut.min(18000), tone: tone, thinF: thin,
			phRate: 0.4, phDepth: 0.75 * lift, phCenter: 1200, phSweep: 900 * (lift > 0).binaryValue,
			phPhase: (tSec.(dt + sw) * 0.4).frac, tag: take.asString, g: g, midi: m))) }
	};
	hits.do { |n|
		pitch.(ce, n[\what], c, sc, up).reject(_.isNil).do { |m, j|
			var strum = n[\what][0] == \strum, take = ("strat" ++ (1 + (ce.hash3(p, m, li) * 3).floor.asInteger)).asSymbol;
			var adsr = ce.sdADSR(0.002, nil, nil, if(strum) { 0.03 } { 0.12 });
			play.(take, m, if(strum) { 0.6 } { n[\len] * 0.9 }, adsr[0], adsr[3],
				5 * n[\acc] * lg * (if(strum) { 0.7 } { 1 }), ((j * 4) + (3 * ce.hash3(k, m, j))) * lms, cut)
		}
	};
	if(hits.isEmpty and: { lvl >= 3 or: { lvl >= 1 and: { [1, 5, 9, 13].includes(s16) } } }
		and: { notes.any { |n| n[\p] == ((p - 1) % len) and: { n[\len] >= 2 } }.not }) {
		var adsr = ce.sdADSR(0.001, nil, nil, 0.02);
		play.(("strat" ++ (1 + (k % 3))).asSymbol, ce.chordBelow(c, ce.chordNear(c, 67, 79, 72), 3)[2] ? 60, 0.35,
			adsr[0], adsr[3], (if(s16.odd) { 2.2 } { 1.6 }) * lg, 2 * lms, cut.min(900))
	};
	if(out.notEmpty) {
		var d = if(e > 0) { 0.6 * e } { 0.25 * lift }, at = out[0][\at];
		out.add((msg: [\c_set, ce.stateBus[col.stateName(\echo)], d], at: at));
		if(d.max(col.tensionEcho) > 0) {
			out.add((msg: [\n_set, col.delayNode, \time, if(e > 0) { 30 / bpm } { 0.75 * 60 / bpm },
				\feedback, if(e > 0) { 0.15 + (0.35 * e) } { 0.55 }], at: at))
		}
	};
	out
}
)
)
