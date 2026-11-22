// Column code of the ambient birds (010): sine chirps with a quick pitch sweep onto the note (from up to 10 semitones off) on
// chord tones, D6 / D7, in three layers on their own lanes (each with its own room and echo): eight call rhythms. Complexity
// (row 3): more calls, an octave higher. Button 2 (Flock): a whole flock of random 32nds calls while held.
(
var fx = ~ce.ambientFx;
(
states: fx.startStates([\birds, \birds2, \birds3]),
strip: (lanes: [(name: \main, roomR: \birdsRoom, echoSend: \birdsEcho), (name: \more, roomR: \birds2Room, echoSend: \birds2Echo),
	(name: \held, roomR: \birds3Room, echoSend: \birds3Echo)]),
update: { |col, send| fx.apply(col, send, \birds); fx.apply(col, send, \birds2); fx.apply(col, send, \birds3) },
start: { |col, ce| ce.onCC(ce.stemGlobal.tension, { |v, send| col.refreshStates(send) }) },
notes: { |col, k|
	var ce = col[\ce], st = col[\st], kit = ce.ambientOf(col), tr = col[\track], fr = tr[\frame], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var v = col[\patLatch].atBar(b), a = col.knob(\k3), out = List[], tones = [0, 2, 4, 7], r, adsr = kit[\adsr], padsr = kit[\padsr];
	var noteAt = { |u| tones[(4 * ce.rand(((u + (1024 * v)) * 32).floor / 32)).trunc] };
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 2000, hi: 14000, tone: kit[\tone]);
	var chirp = { |u, oct, g, len, lane, pan| var r = ce.rand(u), m = fr.degMidi(noteAt.(u) + fr.rootAt(tr, b), oct);
		out.add(kit[\syn].(\sine, m, g, lp ++ (at: (u - t) * 16, hold: len, pan: pan, lane: lane, penv: -8 + (18 * r))
			++ padsr.(nil, 0.05) ++ adsr.(0.003, 0.05 + (0.05 * r), 0, 0.03))) };
	st[\rh] = st[\rh] ?? { var h = [[0, 0.5], [0.5, 0.5]], one = [[0, 1]];
		[[Dictionary[10 -> h]], [Dictionary[3 -> one, 13 -> one]], [Dictionary[6 -> [[0, 1/3], [1/3, 1/3], [2/3, 1/3]]]],
			[Dictionary[12 -> h, 14 -> one], Dictionary[]], [Dictionary[1 -> h]], [Dictionary[5 -> one, 14 -> one]],
			[Dictionary[], Dictionary[8 -> [[0, 0.25], [0.25, 0.25], [0.5, 0.25], [0.75, 0.25]]]], [Dictionary[14 -> h, 15 -> one]]] };
	fr.rootAt(tr, b);
	r = st[\rh][v];
	r[b % r.size][s16] !? { |offs| offs.do { |o| var u = t + (o[0] / 16); chirp.(u, 6, 0.22, o[1], \main, 0.25 + (0.5 * ce.rand(u))) } };
	2.do { |j| var u = t + (j / 32);
		if(a > 0 and: { ce.rand(u) >= (1 - (0.18 * a)) }) { chirp.(u, 7, 0.15 * a, 0.5, \more, ce.rand(u)) };
		if(col.held(\b2) and: { ce.rand(u) >= 0.4 }) { chirp.(u, 6, 0.2, 0.5, \held, ce.rand(u)) } };
	out
}
)
)
