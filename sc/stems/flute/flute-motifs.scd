// Column code of the 009 flute (lab/melodie/melodie-4, column 6): motifs on the chord tones from G4 up, A A B A A A B D
// over 8 bars; Complexity from a third: two extra notes in the gaps (random, more towards 1), from three quarters a
// trill into a note. Each note is cut from a recorded phrase (the closest pitch, transposed). Format: sc/lib/stems.scd.
(
var motifs = [
	[["[2 ~ ~ 3 ~ ~ 2 ~ 1 ~ ~ 2 ~ ~ 3 ~]", "[2 ~ ~ 3 ~ ~ 4 ~ 3 ~ ~ 2 ~ ~ 1 ~]", "[2 ~ ~ 3 ~ ~ 2 ~ 1 ~ ~ 0 ~ ~ ~ ~]"],
		"[~ ~ ~ ~ ~ 4 ~ ~ ~ ~ 4 ~ ~ ~ ~ ~]", "[~@14 2 ~]"],
	[["[3@3 ~ 2 ~ 3@4 ~@6]", "[~ ~ 1 ~ 2 ~ ~ 1@3 ~ 0@3 ~@3]", "[3@3 ~ 4 ~ 3@3 2 ~ ~ ~@4]"],
		"[~@8 2 ~@4 3 ~ ~]", "[~ ~ ~ 2 ~@12]"],
	[["[2 ~ 3 ~ 2 ~ 1 ~ 2 ~ 3 ~ 4 ~ 3 ~]", "[2 ~ 3 ~ 4 ~ 3 ~ 2 ~ 1 ~ 2 ~ ~ ~]", "[2 ~ 3 ~ 2 ~ 1 ~ 0 ~ ~ ~ ~ ~ ~ ~]"],
		"[~ ~ 3 ~ ~ ~ 2 ~ ~ ~ 3 ~ ~ ~ 4 ~]", "[~@12 2 ~@3]"],
];
var voicingOf = { |c| (Am9: [55, 59, 60, 64], D9: [54, 57, 60, 64])[c[\name].asSymbol] ? c[\tones] };
(
states: (level: 0, room: 0, echo: 0),
strip: (level: \level, roomR: \room, echoSend: \echo, orbit: 3, ownDelay: [0.75, 0.55]),
start: { |col, ce|
	col[\st][\phrases] = motifs.collect { |m| var a = m[0][0], b = m[0][1], d = m[0][2];
		[ce.miniTable("<" ++ [a, a, b, a, a, a, b, d].join(" ") ++ ">"), ce.miniTable(m[1]), ce.miniTable(m[2])] };
	col[\st][\pool] = ();
},
update: { |col, send|
	col.setState(\level, col.knob(\fader) * 2.0 * (4 * (col.knob(\k1) - 0.5)).dbamp, send);
	col.setState(\room, 0.9 * (0.2 + (0.8 * col.knob(\k2))), send);
	col.setState(\echo, if(col.held(\b2)) { 0.65 } { 0 }, send);
},
notes: { |col, k|
	var ce = col[\ce], st = col[\st], bpm = col[\track].bpm, snd = ce.sounds[col[\sample]];
	var ph = st[\phrases][col[\patLatch].atBar((k / 16).floor)], br = col.knob(\k1), out = List[], events = List[];
	var cut = (900 * ((14000 / 900) ** br)).min(18000), adsr = ce.sdADSR(0.02, nil, nil, 0.09);
	var cx = col.knob(\k3), xNb = if(cx < 0.33) { 1 } { 1 - ((cx - 0.33) / 0.67) }, held = col.held(\b2);
	var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var chordNotes = { |c| st[\pool][c[\name].asSymbol] ?? { var pcs = voicingOf.(c).collect { |m| m % 12 };
		st[\pool][c[\name].asSymbol] = (67..91).select { |m| pcs.includes(m % 12) }.keep(8); st[\pool][c[\name].asSymbol] } };
	(ph[0][\steps][k % ph[0][\period]] ? []).do { |e| events.add([k + e[0], e[1], e[2]]) };
	(ph[1][\steps][k % ph[1][\period]] ? []).do { |e| var p = k + e[0]; if(ce.rand(p / 16) > xNb) { events.add([p, e[1], e[2]]) } };
	if(cx >= 0.75) {
		(ph[2][\steps][k % ph[2][\period]] ? []).do { |e| 4.do { |i| var p = k + e[0] + (i * e[1] / 4);
			if(ce.rand(p / 16) > 0.4) { events.add([p, e[1] / 4, e[2] + (i % 2)]) } } }
	};
	events.do { |e|
		var p = e[0], t = p / 16, m, x, vel;
		m = chordNotes.(col.chordAtK((p + 0.5).floor.asInteger, true)).wrapAt(e[2]);
		while { m > 77 } { m = m - 12 };
		x = snd[\notes][snd[\notes].minIndex { |n, i| (n[3] - m).abs + (i * 1e-9) }];
		vel = 0.75 + (0.25 * ce.perlin(t));
		ce.swingAt(p).do { |sw| out.add(ce.note(col[\sample], (buf: ce.sampleBuffers[snd[\files][x[0]]], stereoIn: 0,
			begin: x[1] / snd[\lens][x[0]], rate: 2 ** ((m - x[3]) / 12), amp: 0.8 * vel, a: adsr[0], d: adsr[1], s: adsr[2],
			r: adsr[3], hold: e[1], at: p - k + sw, pan: 0.55,
			lpOn: 1, lo: cut, hi: cut, tone: tone, thinF: thin, tag: "m4_fl", g: vel))) }
	};
	if(out.notEmpty and: { held or: { col.tensionEcho > 0 } }) {
		out.add((msg: [\n_set, col.delayNode, \time, 0.75 * 60 / bpm, \feedback, if(held) { 0.62 } { 0.55 }],
			at: out[0][\at]))
	};
	out
}
)
)
