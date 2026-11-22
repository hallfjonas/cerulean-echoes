// Column code of the ambient bass (007): a sine sub with a quiet saw an octave up on the chapter's scale, a new note every 2
// bars. Groove (row 3): a soft swell every bar, a 3-3-2 pulse fading in up to 0.5, at 1 only the pulse (from the next note).
// Button 1 = the next of three bass lines; button 2 = one octave up while held. Sits out the Break.
(
var fx = ~ce.moodFx;
(
strip: (space: \k2),
notes: { |col, k|
	var ce = col[\ce], kit = ce.moodOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, s16 = k % 16, c = col.knob(\k3);
	var fm = fx.fadeMain(c), fe = fx.fadeExtra(c), out = List[], deg, m1, m2, oct, lp, syn = kit[\syn], adsr = kit[\adsr];
	var degs = [0, 0, 0, 4, 3, 5, -2, 1], mood = fr.moodAt(tr, b);
	deg = degs[(8 * ce.rand(((b + kit[\seed].(col[\patLatch], b)) / 2).floor)).trunc.asInteger];
	oct = if(col.held(\b2)) { 12 } { 0 };
	m1 = fr.degMidi(deg, 1, mood) + oct; m2 = fr.degMidi(deg, 2, mood) + oct;
	lp = (lpOn: 1, bright: kit[\ccMap].(\k1), lo: 80, hi: 2000, tone: kit[\tone]);
	if(fm > 0 and: { s16 == 0 }) {
		out.add(syn.(\sine, m1, 0.6 * fm, lp ++ (hold: 16) ++ adsr.(0.8, nil, 0.9, 2)));
		out.add(syn.(\sawtooth, m2, 0.1 * fm, lp ++ (hold: 16) ++ adsr.(0.8, nil, 0.7, 2)));
	};
	if(fe > 0 and: { [0, 6, 12].includes(s16) }) {
		out.add(syn.(\sine, m1, 0.6 * fe, lp ++ (hold: 2) ++ adsr.(nil, 0.4, 0.2, 0.3)));
		out.add(syn.(\sawtooth, m2, 0.1 * fe, lp ++ (hold: 2) ++ adsr.(nil, 0.25, 0, 0.2)));
	};
	out
}
)
)
