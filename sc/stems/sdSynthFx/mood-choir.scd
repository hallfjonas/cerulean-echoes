// Column code of the ambient choir (007): saws through a vowel filter (a, o, u, e) on the chapter's scale, a new note every half
// bar: one voice with a 0.12-semitone copy. Complexity (row 3): 0 = one voice, 0.5 = a third above joins, 1 = a fifth too.
// Button 1 = middle, low, high register (new melody each time). Button 2 (Full choir) = all three voices while held.
(
var fx = ~ce.moodFx;
(
states: (echo: 0),
strip: (space: \k2, echoSend: \echo),
update: { |col, send| fx.echoSend(col, send, \echo, 0) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.moodOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, v = col[\patLatch].atBar(b);
	var octs = [4, 3, 5], vowels = [0, 3, 4, 1], cv, d, out = List[], lp, voice;
	if((k % 8) != 0) { [] } {
		cv = if(col.held(\b2)) { 1 } { col.knob(\k3) };
		d = 2 * (5 * ce.rand(t + kit[\seed].(col[\patLatch], b))).trunc;
		lp = (lpOn: 1, bright: kit[\ccMap].(\k1), lo: 500, hi: 10000, tone: kit[\tone], vib: 0.15, vibmod: kit[\wob], hold: 8,
			vowel: vowels[(b / 2).floor % 4]) ++ kit[\adsr].(0.7, nil, 0.8, 1.8);
		voice = { |off, g, dm = 0| var m = fr.degMidi(d + off, octs[v], fr.moodAt(tr, b)) + dm; kit[\syn].(\sawtooth, m, g, lp, \sdSynthFx) };
		out.add(voice.(0, 0.2)); out.add(voice.(0, 0.2, 0.12));
		if(cv > 0) { out.add(voice.(2, kit[\ramp].(cv, 0, 0.5) * 0.21)) };
		if(cv > 0.5) { out.add(voice.(4, kit[\ramp].(cv, 0.5, 1) * 0.17)) };
		out
	}
}
)
)
