// Column code of the 009 strings (lab/streicher/disco-streicher-4): SSO + VSCO sections, five figures [16th, kind,
// length, scale steps off the top note, chord lookahead] (stabs, runs onto the one, a swell); Complexity (or the lift)
// in stages: unison → + octave → + a third under runs → + celli two octaves down. A note's own echo (0, 0.3, 0.5 ×
// Space) picks its lane. Lift: section grows while held. Format: sc/lib/stems.scd (column code).
(
var sn = { |p, kind, len, off = 0, at = 0, more| (p: p, kind: kind, len: len, off: off, at: at, acc: 1) ++ (more ? ()) };
var top = (acc: 1.5, hard: true, echo: 0.3);
var runTo = { |end, n, l| (0..n - 1).collect { |i| sn.((end - n + i) % l, \line, 1, i - n, n - i) }
	++ [sn.(end % l, \stab, 2, 0, 0, top)] };
var figs = [
	[32, [sn.(0, \stab, 2, 0, 0, (echo: 0.5, hard: true))]],
	[32, runTo.(32, 4, 32)],
	[64, runTo.(64, 8, 64)],
	[64, [sn.(0, \stab, 2, 0, 0, (echo: 0.5, hard: true)), sn.(32, \swell, 30)]],
	[64, [0, -1, 0, 1, 0, -1, -2, -1].collect { |o, i| sn.(56 + i, \line, 1, o, 8 - i) } ++ [sn.(0, \stab, 2, 0, 0, top)]],
];
var line = [[\sso_vn, 0.55, 0.42], [\vs_vn, 1.6, 0.52], [\sso_vn2, 0.5, 0.58]];
var fill = [[\sso_va, 0.45, 0.6], [\vs_va, 1.25, 0.45]];
(
gate: false,
states: (level: 0, room: 0, echo0: 0, echo3: 0, echo5: 0),
strip: (level: \level, roomR: \room, orbit: 3, ownDelay: [0.75, 0.55],
	lanes: [(name: \main, echoSend: \echo0), (name: \echo3, echoSend: \echo3), (name: \echo5, echoSend: \echo5)]),
start: { |col, ce| col[\st][\lift] = 0; col[\st][\lastHeld] = false; col[\st][\held] = false },
update: { |col, send| var s2 = 0.3 + (0.7 * col.knob(\k2));
	col[\st][\held] = col.held(\b2);
	col.setState(\level, col.knob(\fader) * 0.59 * (4 * (col.knob(\k1) - 0.5)).dbamp, send);
	col.setState(\room, 0.9 * s2, send);
	col.setState(\echo0, 0, send);
	col.setState(\echo3, (0.3 * 2 * s2).min(0.9), send);
	col.setState(\echo5, (0.5 * 2 * s2).min(0.9), send);
},
notes: { |col, k|
	var ce = col[\ce], st = col[\st], bpm = col[\track].bpm, maps = ce.sounds[col[\sample]][\maps];
	var lms = 16 / (240 / bpm * 1000), tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var lift = ce.liftStep(st, k), fig = figs[col[\patLatch].atBar((k / 16).floor)], len = fig[0], p = k % len;
	var hits = fig[1].select { |n| n[\p] == p }, out = List[], echoOn = false;
	var v3 = col.knob(\k3), stage = max(if(v3 < 0.25) { 0 } { if(v3 < 0.5) { 1 } { if(v3 < 0.75) { 2 } { 3 } } }, (lift * 3).floor);
	var lg = (3 * lift).dbamp, rr = (k + 5) % 3, cut = 1200 * (10 ** col.knob(\k1));
	hits.do { |n|
		var c = col.chordAtK(k + n[\at], true), sc = c[\scale];
		var m = ce.scaleSteps(ce.chordNear(c, 72, 81, 76), sc, n[\off]), swell = n[\kind] == \swell;
		var base = if(swell) { (dur: n[\len], a: 0.9, r: 0.8) } { (dur: 6, a: 0.002, r: 0.4) };
		var adsr = ce.sdADSR(base[\a], nil, nil, base[\r]), echo = n[\echo] ? 0;
		var bright = 0.8 + (0.5 * lift) + if(n[\hard] == true) { 0.3 } { 0 };
		var voice = { |sname, note, gain, ms, pan|
			var key = ce.closestKey(maps[sname], note), g = gain * n[\acc] * lg;
			var dt = (ms + (4 * ce.hash3(k, note, sname.asString.size))) * lms;
			ce.swingAt(k + dt).do { |sw| out.add(ce.note(col[\sample], (buf: ce.sampleBuffers[key[1]], stereoIn: 1,
				rate: 2 ** ((note - key[0]) / 12), amp: g, a: adsr[0], d: adsr[1], s: adsr[2], r: adsr[3], hold: base[\dur],
				at: dt + sw, pan: pan, lpOn: 1, lo: (cut * bright).min(18000), hi: (cut * bright).min(18000), tone: tone,
				thinF: thin, lane: [\main, \echo3, \echo5][[0, 0.3, 0.5].indexOf(echo)], tag: sname.asString, g: g,
				midi: note))) };
			if(echo > 0) { echoOn = true }
		};
		if(swell) {
			voice.(\sso_vn_sus, m, 0.35, 0, 0.45);
			if(stage >= 1) { voice.(\sso_va_sus, m - 12, 0.3, 6, 0.6) };
			ce.chordBelow(c, m, 2).do { |x| voice.(\sso_va_sus, x, 0.28, 9, 0.55) };
		} {
			var l1 = line[rr], l2 = line[(rr + 1) % 3];
			voice.(l1[0], m, l1[1], 0, l1[2]);
			if(stage >= 1) { voice.(l2[0], m + 12, l2[1] * 0.6, 12, l2[2]) };
			if(n[\kind] == \stab) {
				ce.chordBelow(c, m, 2).do { |x, j| var f = fill[(rr + j) % 2]; voice.(f[0], x, f[1], 8, f[2]) };
				voice.(\sso_vc, c[\bass] + 12, 0.5, 4, 0.65);
				if(n[\hard] == true) { voice.(\sso_vn_piz, m, 0.55, 0, 0.5) };
			} {
				if(stage >= 2) { var f = fill[rr % 2]; voice.(f[0], ce.scaleSteps(m, sc, -2), f[1] * 0.8, 8, 0.6) };
				if(stage >= 3) { voice.(\sso_vc, m - 24, 0.4, 5, 0.65) };
			}
		}
	};
	if(out.notEmpty and: { echoOn or: { col.tensionEcho > 0 } }) {
		out.add((msg: [\n_set, col.delayNode, \time, 0.75 * 60 / bpm, \feedback, 0.55], at: out[0][\at]))
	};
	out
}
)
)
