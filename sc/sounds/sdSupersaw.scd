// Voice: superdough's supersaw (Strudel `s("supersaw")`): `unison` band-limited saws spread over `detune` semitones
// (voice n at n × detune / (unison − 1) − detune / 2), each starting at a random phase, alternately panned left/right
// by `spread`; envelope peak 0.3 / √unison. Up to 4 voices. Then Strudel's filters and panner.
(
name: \sdSupersaw,
role: \voice,
about: "Strudel's supersaw: detuned band-limited saws, random phases, spread across the stereo field",
mono: false,
hpf: 0,
params: ~ce.sdParams((
	unison: (default: 5, spec: [1, 4, \lin, 1], label: "Voices", about: "number of saws (here at most 4)"),
	detune: (default: 0.18, spec: [0, 2], label: "Detune", about: "spread of the voices in semitones"),
	spread: (default: 0.6, spec: [0, 1], label: "Stereo", about: "how far the voices go left / right"),
)),
def: SynthDef(\ce_sdSupersaw, { |out = 0, amp = 1, hold = 0.1, freq = 440, unison = 2, detune = 0.18, spread = 0.6,
	a = 0.001, d = 0.05, s = 0.6, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1|
	var n = unison.clip(1, 4), ps = Select.kr(n > 1, [0, spread.clip(0, 1)]) * 0.5 + 0.5;
	var gl = (1 - ps).sqrt, gr = ps.sqrt, scale = Select.kr(n > 1, [0, detune / (n - 1).max(1)]), centre = Select.kr(n > 1, [0, detune * 0.5]);
	var sig = 4.collect { |i|
		var f = freq * (2 ** (((i * scale) - centre) / 12));
		// a rising saw ±1 (SC's Saw falls, ±0.5), started at a random phase (a random part of one period late)
		var v = DelayC.ar(Saw.ar(f) * -2, 0.05, Rand(0, 1) / f) * (i < n);
		if(i.even) { [v * gl, v * gr] } { [v * gr, v * gl] }
	}.sum;
	sig = sig * EnvGen.ar(~ce.adsr(a, d, s, r, hold, 0, 0.3 / n.sqrt)) * amp;
	sig = ~ce.sdFx(sig, (lpOn: lpOn, bright: bright, lo: lo, hi: hi, tone: tone, cutMul: cutMul, lpq: lpq, hp: hp,
		thinF: thinF, hpq: hpq, bp: bp, bpq: bpq, pan: pan, stereoIn: 1));
	Line.kr(0, 0, hold + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig);
}),
)
