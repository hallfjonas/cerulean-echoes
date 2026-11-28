// Column code of the lsd strings (017): the JX strings (wide supersaws) on the chords, four voices (root, fifth, octave, tenth
// above the chord root, F4 upwards), bowed in a 3-3-2 pulse or swelling over 2 bars (Bow). Each move (Lift, Sink, Line up, Line
// down, Chain) walks one voice through the 8 bars. Their filter and their spread breathe on two slow cycles. Audible from
// Tension 0, Tension brings them up (a map on the strip, at once). Button 2 throws an echo. Space scales the room from 0.3.
// The Launchkey keys (keys, the frame's lkKeys): a key bows one voice at its own pitch, short or swelling as Bow says.
(
states: (room: 0.9 * 0.3, echo: 0),
maps: (trim: (ccs: [36], fn: { |t| 0.7 * (0.45 + (0.55 * (t / 0.6).clip(0, 1))) })),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| col.setState(\room, 0.9 * (0.3 + (0.7 * col.knob(\k2))), send);
	col.setState(\echo, if(col.held(\b2)) { 0.85 } { 0 }, send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var out = List[], bow = col.knob(\k3), unit = (b % 8 / 2).floor, mv, play, adsr = kit[\adsr];
	st[\moves] = st[\moves] ?? { [
		[[0, 0, 0, 0], [4, 4, 4, 5], [7, 7, 7, 7], [9, 9, 9, 9]],
		[[0, 0, 0, -1], [4, 4, 4, 4], [7, 7, 7, 6], [9, 9, 9, 9]],
		[[0, 0, 0, 0], [4, 5, 6, 5], [7, 7, 7, 7], [9, 9, 9, 9]],
		[[0, 0, 0, 0], [4, 4, 4, 4], [7, 6, 5, 6], [9, 9, 9, 9]],
		[[0, 0, 0, 0], [4, 5, 5, 4], [7, 7, 7, 7], [9, 9, 10, 9]],
	] };
	st[\pulse] = [[0, 5, 1], [6, 5, 0.8], [12, 3, 0.9]];
	play = { |len, g, env| var lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 500, hi: 7000, tone: kit[\tone], hold: len,
		cutMul: 0.65 + (0.35 * ce.sine(t / 7)) + (0.25 * ce.sine(t / 3)));
		mv.do { |voice, i| var m = fr.degMidi(voice[unit] + fr.rootAt(tr, b), 4, tr.chapterAt(b));
			[[0, 0.06 + (0.1 * ce.sine((t / 5) + (0.25 * i))), 0.6, 0.5], [0.1, 0.05, 0.9, 0.3]].do { |x|
				out.add(ce.note(\sdSupersawWide, (freq: (m + x[0]).midicps, unison: 2, dtn: x[1], spread: x[2], amp: x[3] * 0.55 * g,
					thinF: kit[\thin], tag: "supersaw", g: x[3] * 0.55 * g, midi: m + x[0]) ++ lp ++ env)) } } };
	mv = st[\moves][col[\patLatch].atBar(b)];
	if(bow < 0.5) {
		st[\pulse].do { |p| if(p[0] == s16) { var len = p[1] * (0.55 + (0.9 * bow));
			play.(len, p[2], adsr.(0.02 + (0.12 * bow), 0.25, 0.65, 0.3)) } }
	} {
		if(k % 32 == 0) { play.(32, 0.85, adsr.(0.35 + (4.4 * (bow - 0.5)), 0.1, 1, 0.8)) }
	};
	out
},
keys: { |col, note, vel|
	var ce = col[\ce], kit = ce.kitOf(col), bow = col.knob(\k3), t = TempoClock.default.beats / 4;
	// a single voice against the column's four, under the strip's Tension trim: louder, so a key is heard at Tension 0
	var g = 2.5 * vel;
	var len = if(bow < 0.5) { 5 * (0.55 + (0.9 * bow)) } { 16 };
	var env = if(bow < 0.5) { kit[\adsr].(0.02 + (0.12 * bow), 0.25, 0.65, 0.3) } {
		kit[\adsr].(0.35 + (4.4 * (bow - 0.5)), 0.1, 1, 0.8) };
	var lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 500, hi: 7000, tone: kit[\tone], hold: len,
		cutMul: 0.65 + (0.35 * ce.sine(t / 7)) + (0.25 * ce.sine(t / 3)));
	[[0, 0.06 + (0.1 * ce.sine(t / 5)), 0.6, 0.5], [0.1, 0.05, 0.9, 0.3]].collect { |x|
		ce.note(\sdSupersawWide, (freq: (note + x[0]).midicps, unison: 2, dtn: x[1], spread: x[2], amp: x[3] * 0.55 * g,
			thinF: kit[\thin], tag: "supersaw", g: x[3] * 0.55 * g, midi: note + x[0]) ++ lp ++ env) }
}
)
