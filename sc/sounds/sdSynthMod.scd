// Voice: superdough's basic synth (as sdSynth) plus the modulations track 008 uses: FM (Strudel fm / fmh), a pitch
// envelope (penv, pattack/pdecay/psustain/prelease), a low-pass envelope (lpenv, lpattack/lpdecay/lpsustain/
// lprelease) and the waveshaper (shape). Same chain as superdough: oscillator × 0.3 × ADSR × gain → low-pass (with its
// envelope) → high-pass (Thin) → band-pass → shape → pan. Own sound (not sdSynth) so 009's voice stays as it is;
// with fmi 0, penv 0, lpenv 0 and shape 0 it plays exactly as sdSynth.
// FM as superdough: the modulator runs at freq × fmh and adds fmi × freq × fmh Hz to the carrier's frequency; the
// browser starts it when the note is scheduled (modPhase -1: random per note); offline renders start it at time 0
// (the track passes that phase for comparisons). Pitch envelope: superdough's ADSR on the oscillator's detune in cents
// (penv semitones; anchor = sustain level, as superdough's default). Filter envelope: exponential, from the cutoff to
// cutoff × 2^lpenv (at most 20 kHz) and back to cutoff × (1 + lps × (2^lpenv − 1)).
(
name: \sdSynthMod,
role: \voice,
about: "Strudel's basic synth voice with FM, pitch envelope, filter envelope and waveshaper (superdough)",
mono: false,
hpf: 0,
wavetables: (sawBuf: \saw, sqBuf: \square),
params: ~ce.sdParams((
	wave: (default: 0, spec: [0, 3, \lin, 1], label: "Wave", about: "0 sine, 1 triangle, 2 saw, 3 square"),
	vib: (default: 0, spec: [0, 20], label: "Vibrato rate", about: "Hz (Strudel vib), 0 = none"),
	vibmod: (default: 0.5, spec: [0, 2], label: "Vibrato depth", about: "semitones (Strudel vibmod)"),
	fmi: (default: 0, spec: [0, 10], label: "FM index", about: "Strudel fm: depth of the frequency modulation"),
	fmh: (default: 1, spec: [0.25, 8, \exp], label: "FM ratio", about: "Strudel fmh: modulator frequency / carrier"),
	modPhase: (default: -1, spec: [-1, 6.2832], label: "Mod phase", about: "start phase of the modulator; -1 = random"),
	penv: (default: 0, spec: [-48, 48], label: "Pitch env", about: "semitones at the start of the note (0 = none)"),
	lpenv: (default: 0, spec: [0, 8], label: "Filter env", about: "octaves the low-pass opens at the attack (0 = none)"),
	shape: (default: 0, spec: [0, 0.99], label: "Shape", about: "waveshaper drive (superdough shape), 0 = clean"),
)),
def: SynthDef(\ce_sdSynthMod, { |out = 0, amp = 1, hold = 0.1, freq = 440, wave = 0, sawBuf = 0, sqBuf = 0, vib = 0, vibmod = 0.5,
	fmi = 0, fmh = 1, modPhase = -1,
	penv = 0, pa = 0.001, pd = 0.001, ps = 0.001, pr = 0.01,
	lpenv = 0, la = 0.005, ld = 0.14, ls = 0, lr = 0.1,
	shape = 0,
	a = 0.001, d = 0.05, s = 0.6, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1|
	var wt = ~ce.wavetableIndex(freq);
	// pitch envelope (cents, linear) and vibrato on the detune
	var cents = penv * 100, pEnv = EnvGen.ar(~ce.adsr(pa, pd, ps, pr, hold, cents.neg * ps, cents * (1 - ps)));
	var det = pEnv + (SinOsc.ar(vib) * vibmod * 100 * (vib > 0));
	// FM: the modulator at freq × fmh, its output × fmi × its frequency added to the carrier (Hz)
	var mf = freq * fmh, ph = Select.kr(modPhase < 0, [modPhase, Rand(0, 2pi)]);
	var f = (freq + (SinOsc.ar(mf, ph) * fmi * mf)) * (2 ** (det / 1200));
	var sig = Select.ar(wave, [SinOsc.ar(f), LFTri.ar(f), Osc.ar(sawBuf + wt, f), Osc.ar(sqBuf + wt, f)]);
	var cut, fmax, fEnv, x;
	sig = sig * 0.3 * EnvGen.ar(~ce.adsr(a, d, s, r, hold)) * amp;
	// low-pass with its envelope (factor on the cutoff), then Thin's high-pass and the band-pass
	cut = ~ce.cutoff(bright, lo, hi, tone) * cutMul;
	fmax = (2 ** lpenv).min(20000 / cut.max(1));
	fEnv = Select.ar(lpenv > 0, [DC.ar(1), EnvGen.ar(~ce.adsr(la, ld, ls, lr, hold, 1, fmax, \exp))]);
	x = Select.ar(lpOn > 0, [sig, ~ce.lpf(sig, cut * fEnv, ~ce.rq(lpq))]);
	x = ~ce.thinHpf(x, hp, thinF, hpq);
	x = Select.ar(bp > 0, [x, ~ce.bpf(x, bp.max(10), bpq)]);
	// superdough's shape: s' = 2s / (1 − s), y = (1 + s') x / (1 + s' |x|)
	x = { |sh| var k = 2 * sh / (1 - sh); (1 + k) * x / (1 + (k * x.abs)) }.(shape.clip(0, 0.999));
	x = Select.ar(pan >= 0, [[x, x], ~ce.webPan([x, x], pan, 0)]);
	Line.kr(0, 0, hold + r.max(pr) + 0.05, doneAction: 2);
	OffsetOut.ar(out, x);
}),
)
