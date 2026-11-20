// Voice: superdough's synth bass drum (Strudel `s("sbd")`, synth.mjs): a triangle whose detune falls exponentially
// from penv semitones to 0 over pdecay, through a tanh(2x) saturation, held at 1 for 20 ms and then decaying
// exponentially over `decay`; a burst of brown noise (1.2 → 0.001 over 25 ms) on top; the mix fades out over the
// last 10 ms at decay + 10 ms (the note's own length does not matter). No 0.3 factor (unlike the other synths).
// Then superdough's chain: gain → low-pass → high-pass (Thin) → band-pass → pan.
(
name: \sdSbd,
role: \kick,
about: "Strudel's sbd: triangle with pitch drop, saturation and a brown-noise click (superdough synth.mjs)",
mono: false,
hpf: 0,
samples: (brownBuf: "noise/brown.wav"),
params: ~ce.sdParams((
	decay: (default: 0.5, spec: [0.01, 4, \exp], label: "Decay", about: "seconds"),
	penv: (default: 36, spec: [0, 48], label: "Pitch drop", about: "semitones at the start"),
	pdecay: (default: 0.5, spec: [0.005, 2, \exp], label: "Pitch decay", about: "seconds"),
)),
def: SynthDef(\ce_sdSbd, { |out = 0, post = 1, amp = 1, hold = 0.1, freq = 65.406, decay = 0.5, penv = 36, pdecay = 0.5, brownBuf = 0,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1|
	var cents = (penv * 100).max(0.002), end = decay + 0.01;
	var det = EnvGen.ar(Env([cents, 0.001, 0.001], [pdecay, 60], \exp));
	var tri = LFTri.ar(freq * (2 ** (det / 1200)));
	var body = (2 * tri).tanh * EnvGen.ar(Env([1, 1, 0.001], [0.02, decay], \exp));
	var noise = PlayBuf.ar(2, brownBuf, 1, loop: 1)[0] * EnvGen.ar(Env([1.2, 0.001], [0.025], \exp));
	var sig = (body + noise) * EnvGen.ar(Env([1, 1, 0], [(end - 0.01).max(0), 0.01])) * amp;
	sig = ~ce.sdFx([sig, sig], (lpOn: lpOn, bright: bright, lo: lo, hi: hi, tone: tone, cutMul: cutMul, lpq: lpq, hp: hp,
		thinF: thinF, hpq: hpq, bp: bp, bpq: bpq, pan: pan, stereoIn: 0));
	Line.kr(0, 0, end + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig * post);   // post: the fader at the note's start (Strudel postgain)
}),
)
