// Column code of the groove hook (001, 002): the playful top line on the key, not the chord: the same tune over every
// progression (a square and a triangle an octave up). Movement (row 3) is the vibrato; Space is the echo send, and
// button 2 throws a long echo.
(
states: (echo: 0),
strip: (space: \k2, echoSend: \echo),
update: { |col, send| col.setState(\echo, if(col.held(\b2)) { 0.8 } { (0.4 * col.knob(\k2)).min(0.9) }, send) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.kitOf(col), tr = col[\track], fr = tr[\frame];
	var b = (k / 16).floor, out = List[], adsr = kit[\adsr], syn = kit[\syn];
	st[\hooks] = st[\hooks] ?? { ["<[~ ~ 4 ~ 4 ~ 2 ~ 4 ~ ~ 5 ~ 4 ~ ~] ~ [~ ~ 4 ~ 4 ~ 2 ~ 4 ~ ~ 7 ~ 6 ~ 4] ~>",
		"<[7 ~ ~ 6 ~ ~ 4 ~ ~ ~ 2 ~ 4 ~ ~ ~] ~ [7 ~ ~ 6 ~ ~ 4 ~ ~ ~ 2 ~ 1 ~ 0 ~] ~>",
		"<[0 ~ 2 ~ 4 ~ ~ ~ 2 ~ 4 ~ 5 ~ 4 ~] ~>",
		"<[~ 4 4 ~ 4 ~ 5 4 ~ ~ 2 ~ ~ ~ ~ ~] [~ 4 4 ~ 4 ~ 5 7 ~ ~ 6 ~ ~ 4 ~ ~]>"].collect(kit[\table]) };
	kit[\eventsAt].(st[\hooks][col[\patLatch].atBar(b)], k).do { |e|
		var m = fr.degMidi(e[2], 4, tr.chapterAt(b));
		var lp = (lpOn: 1, bright: col.knob(\k1), lo: 900, hi: 9000, tone: kit[\tone], at: e[0], hold: e[1] * 0.9,
			vib: 4.5, vibmod: 0.35 * col.knob(\k3)) ++ adsr.(0.01, 0.15, 0.55, 0.12);
		out.add(syn.(\square, m, 0.36, lp));
		out.add(syn.(\triangle, m + 12, 0.2, lp))
	};
	out
}
)
