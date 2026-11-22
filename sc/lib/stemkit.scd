// Helpers for stem code files (sc/stems/*/*.scd): the Strudel semantics and chord helpers of the lab columns ported in
// 009-house, shared so a stem never copies them. Chords are the frame's (~ce.chordOf): bass, tones, scale (pitch
// classes, in the frame's order).
(
// Strudel's swingBy(x, 8) for an onset p in 16ths: an onset in the first half of an 8th stays; one in the second half
// comes x of a 16th later and is lost if that pushes it past the 8th; one just before the middle (within x) plays twice
~ce.swingAt = { |self, p, x = 0.12| var u = p % 2;
	if(u < 1) { if((u + x) >= 1) { [0, x] } { [0] } } { if((u + x) < 2) { [x] } { [] } } };
// the labs' channel strip: room from 0.35 of Space, the 1/8 echo first (full at half the knob)
~ce.labRoom = { |self, sp| 0.8 * ((sp - 0.35) / 0.65).max(0) };
~ce.labEcho = { |self, sp| if(sp > 0) { (0.4 + (1.2 * sp)).min(1) } { 0 } };
// a mini-notation string as a table: 16th of the period → [[offset in the 16th, length in 16ths, value]]
~ce.miniTable = { |self, str| var m = self.mini(str), t = Dictionary[];
	m.events.do { |e| var p = e[0] * 16, k = p.floor.asInteger; t[k] = (t[k] ? []).add([p - k, e[1] * 16, e[2]]) };
	(period: m.period * 16, steps: t) };
// pitch classes of a chord (bass and tones)
~ce.chordPcs = { |self, c| ([c[\bass] % 12] ++ c[\tones].collect { |m| m % 12 }).asSet.asArray };
// n steps of the scale sc (pitch classes) from MIDI note m (n < 0: down)
~ce.scaleSteps = { |self, m, sc, n| var x = m, d = n.sign;
	n.abs.do { x = x + d; while { sc.includes(x % 12).not } { x = x + d } }; x };
// the n chord notes below top (within an octave), highest first
~ce.chordBelow = { |self, c, top, n| var p = self.chordPcs(c), o = List[];
	(top - 1, top - 2 .. top - 12).do { |m| if(o.size < n and: { p.includes(m % 12) }) { o.add(m) } }; o };
// the chord note in lo..hi closest to target (the lowest on a tie)
~ce.chordNear = { |self, c, lo, hi, target| var p = self.chordPcs(c), best = lo;
	(lo..hi).do { |m| if(p.includes(m % 12) and: { (m - target).abs < (best - target).abs }) { best = m } }; best };
// a sample map's closest key (the first in the map's order on a tie): [key MIDI, file]
~ce.closestKey = { |self, keys, note| keys[keys.minIndex { |kk, i| (kk[0] - note).abs + (i * 1e-6) }] };
// the lift of a button held in st (st.lift, st.held): up over 2 bars while held, down over 1 bar after; the notes of
// 16th k hear the lift up to 16th k − 1 (Strudel: the tap that moves it is queried after the stems)
~ce.liftStep = { |self, st, k| var was = st[\lift];
	if(st[\lastK].notNil) {
		st[\lift] = if(st[\lastHeld]) { (st[\lift] + (1 / 32)).min(1) } { (st[\lift] - (1 / 16)).max(0) } };
	st[\lastK] = k; st[\lastHeld] = st[\held];
	if(st[\lift] != was and: { k % 4 == 0 or: { st[\lift] == 0 } or: { st[\lift] == 1 } }) { self.uiPush };
	st[\lift] };
)
