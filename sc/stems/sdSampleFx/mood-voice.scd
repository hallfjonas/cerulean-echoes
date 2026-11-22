// Column code of the ambient voice (007): a spoken recording running with the clock: every beat plays the beat-long slice where
// the clock is, with the radio's hiss and crackle under it. Distortion (row 3) goes from radio to rougher to crushed and
// broken, on map buses, at once. Button 2 (Stutter) = each 16th replays the start of its beat while held.
(
var fx = ~ce.moodFx;
(
states: (echo: 0),
maps: (
	vHp: (ccs: [\k3], fn: { |a| 350 + (250 * (2 * a).min(1)) }),
	vBq: (ccs: [\k3], fn: { |a| 0.8 + (1.7 * (2 * a).min(1)) }),
	vShape: (ccs: [\k3], fn: { |a| 0.15 + (0.25 * (2 * a).min(1)) }),
	vPre: (ccs: [\k3], fn: { |a| 1 - (0.45 * ((2 * a) - 1).max(0)) }),
	vDist: (ccs: [\k3], fn: { |a| var c = ((2 * a) - 1).max(0); (c > 0) * (0.5 + (4.5 * c)) }),
	vCrush: (ccs: [\k3], fn: { |a| var c = ((2 * a) - 1).max(0); (c > 0.35) * (10 - (7 * (c - 0.35) / 0.65)) }),
	vCoarse: (ccs: [\k3], fn: { |a| var c = ((2 * a) - 1).max(0); Select.kr(c > 0.7, [1, (1 + (7 * (c - 0.7) / 0.3)).round]) }),
	vHiss: (ccs: [\k3], fn: { |a| 0.015 + (0.045 * (2 * a).min(1)) }),
	vCrackle: (ccs: [\k3], fn: { |a| 0.1 + (0.2 * (2 * a).min(1)) })),
strip: (space: \k2, echoSend: \echo),
update: { |col, send| fx.echoSend(col, send, \echo, 0.15, false, false, false) },
notes: { |col, k|
	var ce = col[\ce], kit = ce.moodOf(col), a = col.knob(\k3), r = (2 * a).min(1), c = ((2 * a) - 1).max(0), stut = col.held(\b2);
	var davidSec = 552.9, beat = 60 / col[\track].bpm;
	var pos = (((k / 4).floor * beat) % davidSec) / davidSec, out = List[], adsr = kit[\adsr];
	var lp = (lpOn: 1, bright: kit[\ccMap].(\k1), lo: 1500, hi: 16000, tone: kit[\fog]);
	if(stut or: { (k % 4) == 0 }) {
		out.add(kit[\smp].("voice/david.flac", "david", 1 - (0.45 * c), lp ++ (amp: 1, begin: pos, hold: if(stut) { 1 } { 4 },
			pre: col.mapBusOf(\vPre), hp: col.mapBusOf(\vHp), bp: 1600, bpq: col.mapBusOf(\vBq), shape: col.mapBusOf(\vShape),
			distort: col.mapBusOf(\vDist), crush: col.mapBusOf(\vCrush), coarse: col.mapBusOf(\vCoarse)), \sdSampleFx))
	};
	if((k % 4) == 0) {
		out.add(kit[\noise].(0, 0.015 + (0.045 * r), lp ++ (amp: col.mapBusOf(\vHiss), hp: 1200, hold: 4) ++ adsr.(0.01, nil, nil, 0.05)));
		out.add(ce.note(\sdCrackle, (amp: col.mapBusOf(\vCrackle), density: 0.03, hold: 4, tag: "crackle", g: 0.1 + (0.2 * r))
			++ lp ++ adsr.(0.01, nil, nil, 0.05)))
	};
	out
}
)
)
