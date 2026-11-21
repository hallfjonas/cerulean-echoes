// Column code of the 009 vibraphone (lab/melodie/melodie-2): three phrases on the chord (off-beat arp, tresillo in the
// scale, the Escravos call two octaves lower), Strudel's random choices at the same times. Complexity 0 = the core,
// from 15 % the written figure, from 45 % random fills, from 75 % random doubles and neighbour notes. Space: the labs'
// strip and longer notes (×4 … ×16). Format: sc/lib/stems.scd (column code).
(
var call = ["[g3@3 ~ f#3 e3@2 d3@7 ~ d3]", "[c3@2 b2 c3@2 e3@2 d3@5 ~@4]"];
var phrases = [
	[\offbeat, "[~ ~ ~ 1 ~@5 3 ~@6]", "<[~ 0 ~ ~ ~@2 2 ~@5 2 ~ 1 ~]!7 [~ 0 ~ ~ ~@2 2 ~@5 3 ~ 4 ~]>",
		"[~ ~ 4 ~ 3 1 ~ 5 2 ~ 4 0 ~ 3 ~ 5]"],
	[\tresillo, "[0 ~ ~ 4 ~ ~ 0 ~@9]", "<[~@10 -1 ~ 2 ~@3]!3 [~@10 2 ~ [4 4] ~@3]>", "[~ 2 ~ ~ 1 ~ ~ 4 ~ 3 ~ 4 ~ 5 4 ~]"],
	[\call, "<~ ~ ~ ~ ~ ~ " ++ call.join(" ") ++ ">", nil, nil],
];
var degOf = (9: 0, 11: 1, 0: 2, 2: 3, 4: 4, 5: 5, 7: 6);
var voicingOf = { |c| (Am9: [55, 59, 60, 64], D9: [54, 57, 60, 64])[c[\name].asSymbol] ? c[\tones] };
(
states: (level: 0, room: 0, echo: 0),
strip: (level: \level, roomR: \room, echoSend: \echo, orbit: 3, ownDelay: [0.5, 0.15]),
start: { |col, ce|
	col[\st][\phrases] = phrases.collect { |p| (kind: p[0], layers: p[1..].collect { |s| s !? { ce.miniTable(s) } }) };
	col[\st][\pool] = ();
},
update: { |col, send|
	var ce = col[\ce], sp = col.knob(\k2);
	col.setState(\level, col.knob(\fader) * 0.7 * (4 * (col.knob(\k1) - 0.5)).dbamp, send);
	col.setState(\room, ce.labRoom(sp), send);
	col.setState(\echo, if(col.held(\b2)) { 0.65 } { 0.6 * ce.labEcho(sp) }, send);
},
notes: { |col, k|
	var ce = col[\ce], st = col[\st], bpm = col[\track].bpm, keys = ce.sounds[col[\sample]][\keys];
	var ph = st[\phrases][col[\patLatch].atBar((k / 16).floor)], br = col.knob(\k1), clip = 4 * (4 ** col.knob(\k2));
	var cut = (600 * (20 ** br)).min(18000), out = List[], cx = col.knob(\k3), events = List[];
	var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var chordNotes = { |c| st[\pool][c[\name].asSymbol] ?? { var pcs = voicingOf.(c).collect { |m| m % 12 };
		st[\pool][c[\name].asSymbol] = (52..76).select { |m| pcs.includes(m % 12) }.keep(8); st[\pool][c[\name].asSymbol] } };
	var x1 = if(cx < 0.75) { 0 } { 0.35 * (cx - 0.75) / 0.25 }, x2 = if(cx < 0.75) { 0 } { 0.2 * (cx - 0.75) / 0.25 };
	var xRest = if(cx > 0.15) { 0 } { 1 }, xFill = if(cx < 0.45) { 1 } { 1 - (0.7 * (cx - 0.45) / 0.55) };
	var held, ev, d;
	// a double's second half can start up to half a note later: look back over the longest note
	(k - 8 .. k).do { |j|
		ph[\layers].do { |lay, li|
			if(lay.notNil) {
				(lay[\steps][j % lay[\period]] ? []).do { |e|
					var p = j + e[0], r = ce.rand(p / 16);
					if(li == 0 or: { r > [0, xRest, xFill][li] }) {
						var parts = if(r > x1) { [[p, e[1]]] } {
							if((1 - r) > (1 - x1)) { [[p, e[1] / 2], [p + (e[1] / 2), e[1] / 2]] } { [] } };
						parts.do { |q| if(q[0].floor == k) {
							var r2 = ce.rand(q[0] / 16);
							if(r2 > x2) { events.add([q[0], q[1], e[2], 0]) } {
								if((1 - r2) > (1 - x2)) { events.add([q[0], q[1], e[2], 1]) } }
						} }
					}
				}
			}
		}
	};
	events.do { |e|
		var p = e[0], t = p / 16, m, key, vel;
		m = switch(ph[\kind],
			\offbeat, { chordNotes.(col.chordAtK((p + 0.5).floor.asInteger, true)).wrapAt(e[2] + e[3]) },
			\tresillo, { var c = col.chordAtK(p.floor.asInteger, false), sc = c[\scale];
				var steps = sc.collect { |x| (x - 9) % 12 }.sort;
				var dd = e[2] + e[3] + (degOf[c[\bass] % 12] ? 0);
				57 + (12 * (dd / 7).floor) + steps[dd % 7] },
			\call, { var s = e[2], sc = col.chordAtK(p.floor.asInteger, false)[\scale];
				if(s.beginsWith("f#") and: { sc.includes(5) }) { s = "f" ++ s[2..] }; ce.noteNumber(s) });
		key = keys.minIndex { |kk, i| (kk[0] - m).abs + (i * 1e-6) };
		vel = 0.6 + (0.4 * ce.perlin(t));
		ce.swingAt(p).do { |sw| out.add(ce.note(col[\sample], (buf: ce.sampleBuffers[keys[key][1]], stereoIn: 1,
			rate: 2 ** ((m - keys[key][0]) / 12), amp: 0.8 * vel, a: 0.001, d: 0.001, s: 1, r: 0.1, hold: e[1] * clip,
			at: p - k + sw, pan: 0.4 + (0.2 * ce.sine(t / 3)),
			lpOn: 1, lo: cut, hi: cut, tone: tone, thinF: thin, tag: "vibraphone", g: vel, midi: m))) }
	};
	if(out.notEmpty) {
		held = col.held(\b2); ev = ce.labEcho(col.knob(\k2));
		d = (if(held) { 0.65 } { 0.6 * ev }).max(col.tensionEcho);
		if(d > 0) {
			var tf = if(held) { [0.75 * 60 / bpm, 0.62] } { [30 / bpm, 0.15 + (0.35 * ev)] };
			out.add((msg: [\n_set, col.delayNode, \time, tf[0], \feedback, tf[1]], at: out[0][\at]))
		}
	};
	out
}
)
)
