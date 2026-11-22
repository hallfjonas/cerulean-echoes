// Column code of the ambient wood and drops (007): FM sine clicks at random on the 16ths, some gliding up 9 semitones into their
// note, on the chapter's scale. Complexity (row 3): a click now and then up to a busy pattern. Button 1 = the next of three
// random patterns; button 2 = almost every 16th plays while held. Sits out the Break.
(
var fx = ~ce.moodFx;
(
states: (echo: 0),
strip: (space: \k2, echoSend: \echo),
update: { |col, send| fx.echoSend(col, send, \echo, 0.4) },
start: { |col, ce| fx.tensionHook(col, ce) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.moodOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, tt, r, keep, m, f, args;
	tt = t + kit[\seed].(col[\patLatch], b); r = ce.rand(tt);
	keep = if(col.held(\b2)) { 0.85 } { 0.06 + (0.5 * col.knob(\k3)) };
	if(r < (1 - keep)) { [] } {
		m = fr.degMidi((5 * r).trunc, 5, fr.moodAt(tr, b)); f = m.midicps;
		args = (hold: 1, fmi: 4 * col.knob(\k1), fmh: 2.76, modPhase: kit[\modPhase].(k, 0, f * 2.76), pan: r,
			lpOn: 1, bright: 0, lo: 9000, hi: 9000, tone: kit[\tone]) ++ kit[\adsr].(nil, 0.05 + (0.09 * r), 0, nil);
		if(r < 0.4) { args = args ++ (penv: -9) ++ kit[\padsr].(0.04) };
		[kit[\syn].(\sine, m, 0.2 + (0.2 * r), args)]
	}
}
)
)
