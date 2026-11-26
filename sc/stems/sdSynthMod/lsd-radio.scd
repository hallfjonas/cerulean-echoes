// Column code of the lsd-fx radio (017-lsd-fx): a word in Morse code, band-passed square bleeps in the middle, near (short
// slap echo), in the 6th bar of every 8-bar phrase, on the root, 5th or octave of the mood. Static (row 3): clean ↔ crackle
// and hiss around the word, the bleeps drifting. Button 1: eight words (SOS, CQ, LSD, QRZ, ACID, DUB, FM, three random
// letters each phrase). Button 2 (Tune): a whistle and hiss gliding like a turned shortwave dial, while held. Space scales
// room (from 0.1) and echo (from 0.25).
(
var morse = (a: ".-", b: "-...", c: "-.-.", d: "-..", f: "..-.", i: "..", l: ".-..", m: "--", o: "---", q: "--.-", r: ".-.",
	s: "...", u: "..-", z: "--..");
var words = ["sos", "cq", "lsd", "qrz", "acid", "dub", "fm"];
// a word as [[start, length]] in 16ths: dit 1/2, dah 3/2, a 1/2 gap inside a letter, 3/2 between letters
var timeline = { |word| var at = 0, out = List[];
	word.do { |ch| morse[ch.asSymbol].do { |sym| var len = if(sym == $-) { 1.5 } { 0.5 }; out.add([at, len]); at = at + len + 0.5 };
		at = at + 1 };
	out };
var tables = words.collect(timeline);
(
states: (room: 0.9 * 0.1, echo: 0.25),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.1 + (0.6 * s)), send); col.setState(\echo, 0.25 + (0.45 * s), send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), st = col[\st], tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16;
	var adsr = kit[\adsr], syn = kit[\syn], noise = kit[\noise], c = col.knob(\k3), out = List[];
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 3000, hi: 12000, tone: kit[\tone]);
	var start = (b - (b % 8) + 5) * 16, ph = (b / 8).floor, sb = (start / 16).floor, v = col[\patLatch].atBar(sb);
	var table = if(v < tables.size) { tables[v] } {
		timeline.(3.collect { |i| morse.keys.asArray.sort[(ce.rand(ph + (0.1 * i) + 0.83) * morse.size).trunc.asInteger].asString }.join) };
	var m = fr.degMidi([0, 4, 7][(ce.rand(ph + 0.23) * 3).trunc.asInteger], 5, tr.chapterAt(sb));
	var span = table.last.sum;
	table.select { |e| (start + e[0]).floor == k }.do { |e|
		out.add(syn.(\square, m, 0.14, lp ++ (at: e[0] % 1, hold: e[1], bp: 1800, bpq: 2, pan: 0.46 + (0.08 * ce.rand(k + 0.19)),
			penv: c * 0.6 * (ce.rand(k + 0.43) - 0.5), pd: 0.2, ps: 0.001) ++ adsr.(0.003, nil, 1, 0.01))) };
	if(c > 0 and: { k >= (start - 4) } and: { k < (start + span + 4) } and: { ce.rand(t + 0.07) < (0.6 * c) }) {
		out.add(noise.(1, (0.04 + (0.1 * ce.rand(t + 0.11))) * c, lp ++ (at: ce.rand(t + 0.13), hold: 0.1 + (0.3 * ce.rand(t + 0.17)),
			bp: 2500, bpq: 1.5, pan: 0.4 + (0.2 * ce.rand(t + 0.29))) ++ adsr.(0.001, nil, 1, 0.01))) };
	if(col.held(\b2)) { var mm = 74 + (26 * ce.perlin(t * 1.5)), was = st[\tune] ? mm;
		st[\tune] = mm;
		out.add(syn.(\sine, mm, 0.07, lp ++ (hold: 1, pan: 0.5, penv: was - mm, pd: 0.11, ps: 0.001) ++ adsr.(0.005, nil, 1, 0.03)));
		out.add(noise.(1, 0.05, lp ++ (hold: 1, bp: 2 * mm.midicps, bpq: 4, pan: 0.5) ++ adsr.(0.01, nil, 1, 0.03))) } { st[\tune] = nil };
	out
}
)
)
