// Voice: sdSynthMod (superdough's basic synth with FM, pitch / filter envelopes, shape) plus two things track 007
// needs: superdough's vowel filter (Strudel vowel: five band-passes in parallel with the formant gains, × 8 makeup,
// after the band-pass; vowelFormant table of superdough vowel.mjs, here a e i o u) and a constant pitch offset in
// cents (cents; a mapped bus, so a detune knob acts on sounding notes). With vowel -1 and cents 0 it plays as sdSynthMod.
(
name: \sdSynthFx,
role: \voice,
about: "Strudel's basic synth voice with FM, envelopes, shape, vowel filter and a live pitch offset (superdough)",
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
	vowel: (default: -1, spec: [-1, 4, \lin, 1], label: "Vowel", about: "-1 none, 0 a, 1 e, 2 i, 3 o, 4 u"),
	cents: (default: 0, spec: [-100, 100], label: "Detune", about: "pitch offset in cents"),
)),
def: SynthDef(\ce_sdSynthFx, { |out = 0, post = 1, amp = 1, hold = 0.1, freq = 440, wave = 0, sawBuf = 0, sqBuf = 0, vib = 0, vibmod = 0.5,
	fmi = 0, fmh = 1, modPhase = -1,
	penv = 0, pa = 0.001, pd = 0.001, ps = 0.001, pr = 0.01,
	lpenv = 0, la = 0.005, ld = 0.14, ls = 0, lr = 0.1,
	shape = 0, vowel = -1, cents = 0,
	a = 0.001, d = 0.05, s = 0.6, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1|
	var wt = ~ce.wavetableIndex(freq);
	// pitch envelope (cents, linear) and vibrato on the detune
	var pc = penv * 100, pEnv = EnvGen.ar(~ce.adsr(pa, pd, ps, pr, hold, pc.neg * ps, pc * (1 - ps)));
	var det = pEnv + Lag.kr(cents, 0.02) + (SinOsc.ar(vib) * vibmod * 100 * (vib > 0));
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
	// vowel: the five formants of the vowel (band-passes, linear Q), each × its gain, summed × 8
	x = Select.ar(vowel >= 0, [x, { |v|
		var tab = [
			[[660, 1120, 2750, 3000, 3350], [1, 0.5012, 0.0708, 0.0631, 0.0126], [80, 90, 120, 130, 140]],      // a
			[[440, 1800, 2700, 3000, 3300], [1, 0.1995, 0.1259, 0.1, 0.1], [70, 80, 100, 120, 120]],           // e
			[[270, 1850, 2900, 3350, 3590], [1, 0.0631, 0.0631, 0.0158, 0.0158], [40, 90, 100, 120, 120]],     // i
			[[430, 820, 2700, 3000, 3300], [1, 0.3162, 0.0501, 0.0794, 0.01995], [40, 80, 100, 120, 120]],     // o
			[[370, 630, 2750, 3000, 3400], [1, 0.1, 0.0708, 0.0316, 0.01995], [40, 60, 100, 120, 120]]];      // u
		var pick = { |j, i| Select.kr(v, tab.collect { |t| t[j][i] }) };
		5.collect { |i| ~ce.bpf(x, pick.(0, i), pick.(2, i)) * pick.(1, i) }.sum * 8
	}.(vowel.max(0))]);
	// superdough's shape: s' = 2s / (1 − s), y = (1 + s') x / (1 + s' |x|)
	x = { |sh| var k = 2 * sh / (1 - sh); (1 + k) * x / (1 + (k * x.abs)) }.(shape.clip(0, 0.999));
	x = Select.ar(pan >= 0, [[x, x], ~ce.webPan([x, x], pan, 0)]);
	Line.kr(0, 0, hold + r.max(pr) + 0.05, doneAction: 2);
	OffsetOut.ar(out, x * post);   // post: the fader at the note's start (Strudel postgain)
}),
)
