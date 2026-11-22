// Column code of the ambient drone (007): low chords of the chapter's mood swelling in once per bar, an octave answer on the
// second half. Beating (row 3) = a detuned saw layer under the sines: its amount and detune at once. Button 1 = the next of
// three drone chords of the mood.
(
var fx = ~ce.moodFx;
(
states: (echo: 0, droneBeatL: 0),
strip: (space: \k2, echoSend: \echo, lanes: [(name: \main), (name: \beat, fade: \droneBeatL)]),
maps: (droneCents: (ccs: [\k3], fn: { |c| 30 * c })),
update: { |col, send| col.setState(\droneBeatL, col.knob(\k3), send); fx.echoSend(col, send, \echo, 0) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.moodOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, c = col.knob(\k3), out = List[];
	var lp = (lpOn: 1, bright: kit[\ccMap].(\k1), lo: 120, hi: 4000, tone: kit[\tone], vib: 0.15, vibmod: kit[\wob], hold: 16);
	var chord = fr[\moods][fr.moodAt(tr, b)][\drones][col[\patLatch].atBar(b)], adsr = kit[\adsr], syn = kit[\syn];
	if((k % 16) == 0) { chord.do { |m|
		out.add(syn.(\sine, m, 0.7, lp ++ adsr.(1.5, 1, 0.7, 3)));
		out.add(syn.(\sawtooth, m, 0.18, lp ++ adsr.(1.5, nil, 0.6, 3) ++ (cents: col.mapBusOf(\droneCents), lane: \beat,
			g: 0.18 * c, midi: m + (0.3 * c), nolog: c <= 0), \sdSynthFx));
	} };
	if((k % 16) == 8) { chord.do { |m| out.add(syn.(\triangle, m + 12, 0.25, lp ++ adsr.(1, nil, 0.5, 2.5))) } };
	out
}
)
)
