// Column code of the 009 clap: the 909 clap on 2 and 4 (pickup, fill every 4th bar); Complexity adds rim ghosts (beat
// 3 up to half, two more past half); Roll = a snare roll growing over the bar; past half of Tension a random snare
// roll (the track's build-up, read here). Three samples per column need code. Format: sc/lib/stems.scd.
(
var ramp = { |v, from, to| ((v - from) / (to - from)).clip(0, 1) };
(
strip: (orbit: 1, space: \k2, echo: 0.2),
notes: { |col, k|
	var ce = col[\ce], b = (k / 16).floor, s16 = k % 16, out = List[], c = col.knob(\k3), g, tr, t = k / 16;
	var fog = ("c" ++ ce.fogBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var hit = { |rel, tag, gain| var x = ce.sdADSR(nil, nil, nil, nil);
		ce.note(col[\sample], (buf: ce.sampleBuffers[rel], stereoIn: (ce.sampleMono[rel] != true).asInteger,
			amp: gain * 0.8, hold: -1, thinF: thin, tag: tag, g: gain * 0.8, a: x[0], d: x[1], s: x[2], r: x[3],
			lpOn: 1, bright: ce.ccMap(col[\ccs][\k1]), lo: 3500, hi: 14000, tone: fog, hp: 300, pan: 0.48)) };
	g = switch(col[\patLatch].atBar(b),
		0, { Dictionary[4 -> 0.8, 12 -> 0.8][s16] },
		1, { Dictionary[4 -> 0.8, 12 -> 0.8, 15 -> 0.35][s16] },
		2, { if(b % 4 == 3) { Dictionary[4 -> 0.8, 12 -> 0.8, 14 -> 0.5][s16] } { Dictionary[4 -> 0.8, 12 -> 0.8][s16] } });
	g !? { out.add(hit.("tr909/cp-00.wav", "RolandTR909_cp:0", g)) };
	if(c > 0 and: { s16 == 8 }) { out.add(hit.("tr909/rim-00.wav", "RolandTR909_rim:0", 0.25 * ramp.(c, 0, 0.5))) };
	if(c > 0.5) { Dictionary[6 -> 0.18, 14 -> 0.15][s16] !? { |x|
		out.add(hit.("tr909/rim-00.wav", "RolandTR909_rim:0", x * ramp.(c, 0.5, 1))) } };
	if(col.held(\b2)) { out.add(hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.1 + (0.4 * (t % 1)))) };
	tr = ramp.(ce.val(col[\track].global.tension), 0.5, 1);
	if(tr > 0 and: { ce.rand(t) >= (0.5 * (1 - tr)) }) { out.add(hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.1 + (0.35 * tr))) };
	out.reject { |n| n[\amp] <= 0 }
}
)
)
