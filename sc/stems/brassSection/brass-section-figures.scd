// Column code of the 009 brass (lab/blaeser/disco-blaeser-3): a full section (trumpets, horns, trombones) on the chord,
// nine figures [16th, length, complexity level, kind]; each repetition of a short figure rests with 30 % (every 4th
// always plays), every hit but the one is left out with 25 % (a hash: the same on every pass). Complexity adds pickups
// and extra hits. Lift (button 2 held): up over two bars, down over one; doubling, harmony, brighter, up to +3 dB.
// Format: sc/lib/stems.scd (column code).
(
var bn = { |p, len, lv = 0, kind = \hit| (p: p, len: len, lv: lv, kind: kind) };
var figs = [
	[32, [bn.(14, 1), bn.(16, 3), bn.(30, 1), bn.(0, 3), bn.(13, 1, 1), bn.(29, 1, 1), bn.(22, 1, 2), bn.(8, 1, 2)]],
	[32, [bn.(0, 1), bn.(3, 1), bn.(6, 2), bn.(24, 1), bn.(27, 3), bn.(10, 1, 1), bn.(23, 1, 1), bn.(31, 1, 2), bn.(14, 1, 2)]],
	[16, [bn.(0, 1), bn.(3, 1), bn.(6, 1), bn.(10, 2), bn.(12, 1), bn.(14, 1, 1), bn.(15, 1, 2), bn.(8, 1, 2)]],
	[32, [bn.(13, 1), bn.(14, 1), bn.(16, 2), bn.(29, 1), bn.(30, 1), bn.(0, 2), bn.(6, 1, 1), bn.(22, 1, 1), bn.(23, 1, 2),
		bn.(10, 1, 2)]],
	[32, [bn.(0, 1), bn.(3, 1), bn.(6, 1), bn.(16, 1), bn.(19, 1), bn.(22, 2), bn.(28, 1, 1), bn.(30, 1, 1), bn.(12, 1, 2),
		bn.(27, 1, 2)]],
	[32, [bn.(0, 3), bn.(14, 1, 1), bn.(22, 1, 1), bn.(8, 1, 2)]],
	[64, [bn.(62, 1), bn.(0, 3), bn.(30, 1, 1), bn.(46, 1, 1), bn.(38, 1, 2), bn.(54, 1, 2)]],
	[64, [bn.(56, 6, 0, \swell), bn.(0, 2), bn.(30, 1, 1), bn.(46, 1, 2)]],
	[32, [bn.(24, 6, 0, \swell), bn.(30, 1), bn.(0, 2), bn.(3, 1, 1), bn.(6, 1, 1), bn.(10, 1, 2), bn.(14, 1, 2)]],
];
var ens = (lead: [[\sso_tp, 0.45, 0, 0.45], [\sso_hn, 0.45, 6, 0.55]], dbl: [[\sso_tp, 0.32, 9, 0.6]],
	harm: [[\sso_hn, 0.4, 8, 0.5], [\sso_tp, 0.25, 4, 0.6]], low: [[\sso_tb, 0.5, 11, 0.6]]);
var sus = (sso_tp: [\sso_tp_sus, 0.8], sso_hn: [\sso_hn_sus, 0.45], sso_tb: [\sso_tb_sus, 0.6]);
var leadOf = { |ce, c| var p = ce.chordPcs(c), best = 67;
	(67..76).do { |m| if(p.includes(m % 12) and: { (m - 72).abs < (best - 72).abs }) { best = m } }; best };
(
gate: false,
states: (level: 0, room: 0, echo: 0),
strip: (level: \level, roomR: \room, echoSend: \echo, orbit: 3, ownDelay: [0.75, 0.55]),
start: { |col, ce| col[\st][\lift] = 0; col[\st][\lastHeld] = false; col[\st][\held] = false },
update: { |col, send|
	col[\st][\held] = col.held(\b2);
	col.setState(\level, col.knob(\fader) * 0.42 * (4 * (col.knob(\k1) - 0.5)).dbamp, send);
	col.setState(\room, 0.9 * (0.3 + (0.7 * col.knob(\k2))), send);
	col.setState(\echo, 0, send);
},
notes: { |col, k|
	var ce = col[\ce], st = col[\st], bpm = col[\track].bpm, maps = ce.sounds[col[\sample]][\maps];
	var bms = 16 / (240 / bpm * 1000), tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var lift = ce.liftStep(st, k), fig = figs[col[\patLatch].atBar((k / 16).floor)], len = fig[0], p = k % len, out = List[];
	var cx = col.knob(\k3), lvl = if(cx < 0.33) { 0 } { if(cx < 0.66) { 1 } { 2 } }, lg = (3 * lift).dbamp;
	var rd = (k / len).floor.asInteger + if(p >= (len - 2)) { 1 } { 0 };
	var cut = 900 * ((8000 / 900) ** col.knob(\k1));
	if((len <= 32 and: { rd % 4 != 0 } and: { ce.hash3(rd, len, 41) < 0.3 }).not) {
		fig[1].do { |n|
			if(n[\p] == p and: { n[\lv] <= lvl }
				and: { (n[\p] != 0 and: { n[\kind] != \swell } and: { ce.hash3(rd, n[\p], 43) < 0.25 }).not }) {
				var c = col.chordAtK(k, true), lead = leadOf.(ce, c), held = n[\kind] == \swell, soft = if(n[\lv] > 0) { 0.7 } { 1 };
				var bright = 0.75 + (0.6 * lift), adsr = ce.sdADSR(if(held) { 0.6 * n[\len] / 16 * 240 / bpm } { 0.003 }, nil, nil,
					if(held) { 0.35 } { if(n[\len] >= 3) { 0.2 } { 0.12 } });
				var dur = if(n[\len] == 1) { 0.9 } { n[\len] - 0.3 };
				var close = ce.chordBelow(c, lead, 3), harm = if(held) { [close[1], close[2], close[0] !? { |x| x - 12 }] } { close.keep(2) };
				var voices = ens[\lead].collect { |x| [x, lead, 1] } ++ ens[\low].collect { |x| [x, lead - 12, 1] }
					++ ens[\dbl].collect { |x| [x, lead, 0.6 + (0.4 * lift)] }
					++ harm.collect { |m| ens[\harm].collect { |x| [x, m, 0.7 + (0.3 * lift)] } }.flatten(1)
					++ if(lift > 0.5) { [[ens[\lead][0], lead + 12, 0.5 * (lift - 0.5) * 2]] } { [] };
				voices.do { |v| var x = v[0], note = v[1], f = v[2];
					if(note.notNil) {
						var sn = if(held) { sus[x[0]][0] } { x[0] }, g2 = if(held) { sus[x[0]][1] } { 1 };
						var key = ce.closestKey(maps[sn], note);
						var at = (x[2] + (8 * ce.hash3(k, note, sn.asString.size))) * bms;
						var g = x[1] * g2 * soft * f * lg;
						ce.swingAt(k + at).do { |sw| out.add(ce.note(col[\sample], (buf: ce.sampleBuffers[key[1]], stereoIn: 1,
							rate: 2 ** ((note - key[0]) / 12), amp: g, a: adsr[0], d: adsr[1], s: adsr[2], r: adsr[3], hold: dur,
							at: at + sw, pan: x[3], lpOn: 1, lo: cut * bright, hi: cut * bright, tone: tone, thinF: thin,
							tag: sn.asString, g: g, midi: note))) }
					}
				}
			}
		}
	};
	if(out.notEmpty and: { col.tensionEcho > 0 }) {
		out.add((msg: [\n_set, col.delayNode, \time, 0.75 * 60 / bpm, \feedback, 0.55], at: out[0][\at]))
	};
	out
}
)
)
