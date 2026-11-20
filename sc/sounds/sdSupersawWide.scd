// Voice: superdough's supersaw (Strudel `s("supersaw")`) as sdSupersaw, with up to 8 saws (the 008 Launchkey pad
// plays 7: `unison(7)`). Voice n at n × detune / (unison − 1) − detune / 2 semitones, each at a random phase,
// alternately panned left / right by `spread`; envelope peak 0.3 / √unison; then Strudel's filters and panner.
// Own sound (not sdSupersaw) so 009's voice stays as it is; it costs twice the saws, so only where more than 4 are asked.
(
name: \sdSupersawWide,
role: \voice,
about: "Strudel's supersaw with up to 8 detuned saws (random phases, stereo spread)",
mono: false,
hpf: 0,
params: ~ce.sdParams((
	unison: (default: 7, spec: [1, 8, \lin, 1], label: "Voices", about: "number of saws (at most 8)"),
	// not called `detune`: a note Event adds its `detune` key (Hz) to `freq`
	dtn: (default: 0.18, spec: [0, 2], label: "Detune", about: "spread of the voices in semitones (Strudel detune)"),
	spread: (default: 0.6, spec: [0, 1], label: "Stereo", about: "how far the voices go left / right"),
)),
def: SynthDef(\ce_sdSupersawWide, { |out = 0, post = 1, amp = 1, hold = 0.1, freq = 440, unison = 7, dtn = 0.18, spread = 0.6,
	a = 0.001, d = 0.05, s = 0.6, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1|
	var n = unison.clip(1, 8), ps = Select.kr(n > 1, [0, spread.clip(0, 1)]) * 0.5 + 0.5;
	var gl = (1 - ps).sqrt, gr = ps.sqrt;
	// dtn may be a mapped bus (live): the voices spread at once
	var dt = Lag.kr(dtn, 0.02), scale = Select.kr(n > 1, [0, dt / (n - 1).max(1)]), centre = Select.kr(n > 1, [0, dt * 0.5]);
	var sig = 8.collect { |i|
		var f = freq * (2 ** (((i * scale) - centre) / 12));
		// a rising saw ±1 (SC's Saw falls, ±0.5), started at a random phase (a random part of one period late)
		var v = DelayC.ar(Saw.ar(f) * -2, 0.05, Rand(0, 1) / f) * (i < n);
		if(i.even) { [v * gl, v * gr] } { [v * gr, v * gl] }
	}.sum;
	var cut = ~ce.cutoff(bright, lo, hi, tone) * cutMul;
	sig = sig * EnvGen.ar(~ce.adsr(a, d, s, r, hold, 0, 0.3 / n.sqrt)) * amp;
	sig = Select.ar(lpOn > 0, [sig, ~ce.lpf(sig, cut, ~ce.rq(Lag.kr(lpq, 0.02)))]);
	sig = ~ce.thinHpf(sig, hp, thinF, hpq);
	sig = Select.ar(bp > 0, [sig, ~ce.bpf(sig, bp.max(10), bpq)]);
	sig = Select.ar(pan >= 0, [sig, ~ce.webPan(sig, pan, 1)]);
	Line.kr(0, 0, hold + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig * post);   // post: the fader at the note's start (Strudel postgain)
}),
)
