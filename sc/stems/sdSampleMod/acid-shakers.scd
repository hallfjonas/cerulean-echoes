// Column code of the acid shakers (018-acid-tech-house): the VCSL small shaker as a 16th groove, the down strokes on
// the even 16ths and the up strokes on the odd ones (a little late, swung), slightly right; a low shaker answers on the
// left at the end of every half bar. Patterns: 16ths, Rock (3-3-2 accents), Off-beat (the "and" of every beat with
// ghost 16ths). Complexity (row 3): more ghost strokes and, from the middle, a cabasa on beat 4 of every second bar.
// Space scales the room; button 2 throws a dotted-8th echo while held. Sits out the Break.
(
var dir = "vcsl/shaker_small/Mid_Shaker";
var file = { |kind, up, rr| dir ++ kind ++ if(up) { "_Up_rr" } { "_Down_rr" } ++ rr ++ ".flac" };
var cabasa = ["vcsl/cabasa/Cabasa1_Hit_rr1_Mid.flac", "vcsl/cabasa/Cabasa1_Hit_rr2_Mid.flac"];
// a velocity per 16th (0 = rest)
var figs = [
	[0.45, 0.25, 0.8, 0.3] ! 4,
	[0.85, 0.3, 0.3, 0.85, 0.3, 0.3, 0.85, 0.3, 0.85, 0.3, 0.3, 0.85, 0.3, 0.3, 0.85, 0.3],
	[0, 0.15, 0.85, 0.15] ! 4
].collect(_.flatten);
(
states: (room: 0.9 * 0.15, echo: 0),
strip: (roomR: \room, echoSend: \echo),
update: { |col, send| var s = col.knob(\k2);
	col.setState(\room, 0.9 * (0.1 + (0.6 * s)), send);
	col.setState(\echo, if(col.held(\b2)) { 0.7 } { 0.25 * s }, send) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.kitOf(col), tr = col[\track], b = (k / 16).floor, t = k / 16, s16 = k % 16;
	var kk = col.knob(\k3), out = List[], vel, up = s16.odd, rr = (b % 2).asInteger + 1, swing = if(up) { 0.1 } { 0 };
	var lp = (lpOn: 1, bright: col.knob(\k1), lo: 2000, hi: 16000, tone: kit[\tone]);
	var hit = { |rel, g, args| out.add(kit[\smp].(rel, rel.basename, g, lp ++ args, \sdSampleMod)) };
	if(tr.breakAt(b)) { [] } {
		vel = figs[col[\patLatch].atBar(b)][s16];
		if(vel <= 0 and: { kk > 0.02 } and: { ce.rand(t) >= (1 - (0.6 * kk)) }) { vel = 0.12 };
		if(vel > 0) {
			hit.(file.(if(vel > 0.6) { "HighFaster" } { "Double" }, up, rr), 3 * vel, (at: swing, pan: 0.62)) };
		if(s16 == 7 or: { s16 == 15 }) { hit.(file.("LowFaster", true, rr), 3 * 0.35, (at: swing, pan: 0.3)) };
		if(kk > 0.5 and: { s16 == 12 } and: { b.odd }) { hit.(cabasa[(b / 2).floor.asInteger % 2], 2.2, (pan: 0.4)) };
		out
	}
}
)
)
