// Add-on library: what button 2 of a stem does (sc/stems/addons.json lists ids, labels, modes and args; the format is
// in docs/features/stems.md). A stem names one by its id; a stem's b2 "code" file returns an Event of the same shape.
// Every hook is optional and is only asked while the add-on is on:
//   mute: true                           the stem plays nothing (from the next note)
//   hits: { |a, col, k, hits| hits }     the step's hits (Events: at, dur in 16ths, note, vel) → the hits to play
//   params: { |a, col, p| }              p: the column's knob values (bright, room, echo …), changed in place; acts
//                                        at once on sounding notes when the parameter is on a knob
//   hold: factor on every note length
//   transpose: semitones added to every pitched note
//   notes: { |a, col, k| notes }         extra notes, made with ~ce.note (e.g. the riser's noise)
//   sounds: [names]                      sounds the add-on plays besides the stem's sample
// a = (args: the stem's b2 args, since: the 16th it turned on, argNum: { |a, key, default| a number arg })
(
~ce.addons = (
	dropOut: (mute: true),
	echoThrow: (params: { |a, col, p| p[\echo] = (p[\echo] ? 0).max(0.6); p[\room] = (p[\room] ? 0).max(0.2) }),
	octave: (transpose: { |a| a.argNum(\steps, 12) }),
	riser: (sounds: [\sdNoise], notes: { |a, col, k|
		var bars = a.argNum(\bars, 2), rise = ((k - a[\since]) / 16 / bars).clip(0, 1);
		if(k % 4 == 0) {
			[col.ce.note(\sdNoise, (color: 1, lpOn: 1, lo: 300, hi: 12000, bright: rise, amp: 0.1 + (0.5 * rise), hold: 4,
				a: 0.01, d: 0.05, s: 1, r: 0.05, tone: col.toneArg))]
		} { [] }
	}),
	roll: (hits: { |a, col, k| [(at: 0, dur: 1, note: col.noteAt(k / 16), vel: 0.25 + (0.75 * (k % 16) / 15))] }),
	fill: (hits: { |a, col, k|
		var rhythm = col.miniOf(a[\args][\rhythm] ? "x!16"), notes = a[\args][\notes] !? { |n| col.miniOf(n) };
		col.hitsOf(rhythm, k).collect { |h| h[\note] = notes !? { |n| col.miniValue(n, h[\t]) } ?? { col.noteAt(h[\t]) }; h }
	}),
	open: (params: { |a, col, p| p[\bright] = ((p[\bright] ? 0) + 0.35).min(1) }, hold: 3),
	long: (hold: 3),
	swell: (hits: { |a, col, k, hits|
		var grow = ((k - a[\since] + 1) / 16 / a.argNum(\bars, 4)).clip(0, 1);
		if(hits.any { |h| h[\at] == 0 }) { hits } {
			hits ++ [(at: 0, dur: 1, note: col.noteAt(k / 16), vel: 0.1 + (0.9 * grow))] }
	}),
	stutter: (hits: { |a, col, k| col.patternHits(k - (k % 4)).collect { |h| h[\at] = 0; h[\dur] = 1; h } }),
	ratchet: (hits: { |a, col, k, hits| hits.collect { |h|
		var n = (h[\dur] / 0.5).floor.asInteger.clip(2, 4);
		n.collect { |i| (at: h[\at] + (0.5 * i), dur: 0.5, note: h[\note], vel: h[\vel] * (1 - (0.15 * i))) }
	}.flatten(1) }),
	burst: (hits: { |a, col, k, hits|
		if(col.ce.rand((k + 0.5) / 16) < 0.35 and: { hits.any { |h| h[\at] == 0 }.not }) {
			hits ++ [(at: 0, dur: 1, note: col.noteAt(k / 16), vel: 1)] } { hits }
	}),
	lift: (params: { |a, col, p| p[\bright] = ((p[\bright] ? 0) + 0.25).min(1) },
		hits: { |a, col, k, hits|
			if(k.even and: { hits.isEmpty }) { [(at: 0, dur: 1, note: col.noteAt(k / 16), vel: 0.6)] } { hits } }),
);
)
