// Column code of the groove strings (001, 002): disco strings (a supersaw and a saw an octave up) on the chord: Held,
// Stabs or an Octave line. Swipe (row 3): a fast scale run up to the chord root in the last bar, every 4 bars (up to half
// the knob) or every 2; button 2 swipes every bar. Space scales the room from 0.25.
(
states: (room: 0.9 * 0.25),
strip: (roomR: \room),
update: { |col, send| col.setState(\room, 0.9 * (0.25 + (0.75 * col.knob(\k2))), send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, s16 = k % 16, out = List[], c = col.knob(\k3), every, adsr = kit[\adsr], eventsAt = kit[\eventsAt];
	var lp = (lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 700, hi: 9000, tone: kit[\tone]);
	var str = { |m, args| out.add(ce.note(\sdSupersaw, (freq: m.midicps, unison: 2, detune: 0.1, spread: 0.7, amp: 0.31, thinF: kit[\thin],
		tag: "supersaw", g: 0.31, midi: m) ++ lp ++ args)); out.add(kit[\syn].(\sawtooth, m + 12, 0.09, lp ++ args)) };
	var swipeNotes = { eventsAt.(st[\swipe], k).do { |e| str.(fr.degMidi(e[2] + fr.rootAt(tr, b), 4, tr.chapterAt(b)),
		(at: e[0], hold: e[1]) ++ adsr.(0.005, 0.05, 0.6, 0.08)) } };
	st[\stabs] = st[\stabs] ?? { kit[\table].("~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ ~ x ~") };
	st[\octLine] = st[\octLine] ?? { kit[\table].("<[7 ~ ~ ~ 6 ~ ~ ~ 4 ~ ~ ~ ~ ~ ~ ~] [7 ~ ~ ~ 9 ~ ~ ~ 8 ~ 7 ~ ~ ~ ~ ~]>") };
	st[\swipe] = st[\swipe] ?? { kit[\table].("~ ~ ~ [-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 ~]") };
	switch(col[\patLatch].atBar(b),
		0, { if(s16 == 0) { fr.tonesAt(tr, b, [0, 2, 4], 4).do { |m| str.(m, (hold: 16) ++ adsr.(0.25, nil, 0.9, 0.6)) } } },
		1, { eventsAt.(st[\stabs], k).do { |e| fr.tonesAt(tr, b, [0, 2, 4], 4).do { |m| str.(m, (at: e[0], hold: e[1]) ++ adsr.(0.01, 0.15, 0.2, 0.15)) } } },
		2, { eventsAt.(st[\octLine], k).do { |e| str.(fr.degMidi(e[2] + fr.rootAt(tr, b), 4, tr.chapterAt(b)), (at: e[0], hold: e[1]) ++ adsr.(0.05, nil, 0.8, 0.4)) } });
	every = if(c <= 0) { 0 } { if(c < 0.5) { 4 } { 2 } };
	if(every > 0 and: { (b % every) == (every - 1) }) { swipeNotes.() };
	if(col.held(\b2)) { swipeNotes.() };
	out
}
)
