// Voice: superdough's crackle noise (Strudel `s("crackle").density(d)`, noise.mjs): a fresh 2-second buffer per note
// in which each sample is a random value in −1..1 with probability density / 100, else 0 — random clicks, about
// density × 480 per second at 48 kHz. Here as Dust2 with that rate. × 0.3 and the ADSR, then filters and panner.
(
name: \sdCrackle,
role: \voice,
about: "Strudel's crackle noise: random clicks (density), ADSR, filters, pan",
mono: false,
hpf: 0,
params: ~ce.sdParams((
	density: (default: 0.03, spec: [0, 1], label: "Density", about: "clicks: density / 100 of the samples"),
)),
def: SynthDef(\ce_sdCrackle, { |out = 0, post = 1, amp = 1, hold = 0.1, density = 0.03,
	a = 0.001, d = 0.05, s = 0.6, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1|
	var sig = Dust2.ar(density * 0.01 * SampleRate.ir);
	sig = sig * 0.3 * EnvGen.ar(~ce.adsr(a, d, s, r, hold)) * amp;
	sig = ~ce.sdFx([sig, sig], (lpOn: lpOn, bright: bright, lo: lo, hi: hi, tone: tone, cutMul: cutMul, lpq: lpq, hp: hp,
		thinF: thinF, hpq: hpq, bp: bp, bpq: bpq, pan: pan, stereoIn: 0));
	Line.kr(0, 0, hold + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig * post);   // post: the fader at the note's start (Strudel postgain)
}),
)
