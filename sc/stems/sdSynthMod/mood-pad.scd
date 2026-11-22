// Column code of the ambient pad (007): slow chords of the chapter's scale (saw + triangle), one per 2 bars. Swell (row 3): still
// chords struck every bar up to re-struck, breathing chords on half notes. Button 1 = three progressions: calm, circling, open.
// Button 2 (Freeze) holds the chord that was playing when it went down.
(
var fx = ~ce.moodFx;
(
states: (echo: 0),
strip: (space: \k2, echoSend: \echo),
update: { |col, send| fx.echoSend(col, send, \echo, 0) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.moodOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var c = col.knob(\k3), fm = fx.fadeMain(c), fe = fx.fadeExtra(c), out = List[], lp, ms, pan, syn = kit[\syn], adsr = kit[\adsr];
	var chords = [[0, 2, 4, 6], [1, 3, 5, 8], [2, 4, 6, 8], [3, 5, 7, 9], [5, 7, 9, 11], [6, 8, 10, 12]];
	var progs = [[0, 0, 3, 3], [0, 2, 3, 1], [0, 4, 3, 5]];
	var idx = progs[col[\patLatch].atBar(b)][(b / 2).floor % 4];
	if(col.held(\b2)) { st[\kept] = st[\kept] ? idx; idx = st[\kept] } { st[\kept] = nil };
	ms = chords[idx].collect { |d| fr.degMidi(d, 3, fr.moodAt(tr, b)) };
	lp = (lpOn: 1, bright: kit[\ccMap].(\k1), lo: 300, hi: 8000, tone: kit[\tone], vib: 0.15, vibmod: kit[\wob]);
	pan = 0.3 + (0.4 * ce.sine(t / 5));
	if(fm > 0 and: { s16 == 0 }) { ms.do { |m|
		out.add(syn.(\sawtooth, m, 0.22 * fm, lp ++ (hold: 16, pan: pan) ++ adsr.(1.2, nil, 0.8, 3)));
		out.add(syn.(\triangle, m, 0.35 * fm, lp ++ (hold: 16) ++ adsr.(0.8, nil, 0.8, 3)));
	} };
	if(fe > 0 and: { (s16 % 8) == 0 }) { ms.do { |m| [\sawtooth, \triangle].do { |w|
		out.add(syn.(w, m, 0.25 * fe, lp ++ (hold: 8, pan: pan) ++ adsr.(0.9, 1, 0.15, 1.2))) } } };
	out
}
)
)
