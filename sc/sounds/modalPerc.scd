// Voice: a struck body as resonators (modal synthesis): a hand or stick strike (a click plus a short noise burst,
// softer = darker) excites a bank of tuned resonators. kind 0 = a drum skin (bongo, conga: the modes of a loaded
// membrane, the pitch falls a little right after the strike as the skin relaxes, plus a puff of skin noise);
// kind 1 = a wooden bar or block (the modes of a free bar, high ones die fast). decay = ring time of the lowest mode
// (60 dB); a muffled stroke is a short decay. Then superdough's filters and panner (low-pass, Thin, band-pass, pan).
(
name: \modalPerc,
role: \perc,
about: "modal percussion: strike → tuned resonators; kind 0 drum skin (bongo, conga), 1 wood bar / block",
mono: false,
hpf: 0,
params: ~ce.sdParams((
	freq: (default: 349, spec: [40, 4000, \exp], label: "Pitch", about: "Hz of the lowest mode"),
	kind: (default: 0, spec: [0, 1, \lin, 1], label: "Body", about: "0 drum skin, 1 wood"),
	decay: (default: 0.15, spec: [0.01, 2, \exp], label: "Decay", about: "ring time of the lowest mode (s)"),
	glide: (default: 0.06, spec: [0, 0.5], label: "Glide", about: "pitch above the rest pitch at the strike (×)"),
	hard: (default: 0.5, spec: [0, 1], label: "Hardness", about: "soft (dark strike) ↔ hard (bright click)"),
	skin: (default: 0.2, spec: [0, 1], label: "Skin", about: "noise of the hand on the skin (slap)"),
)),
def: SynthDef(\ce_modalPerc, { |out = 0, post = 1, amp = 1, hold = 0.1, freq = 349, kind = 0, decay = 0.15, glide = 0.06,
	hard = 0.5, skin = 0.2,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1|
	var strike = (Impulse.ar(0) + (WhiteNoise.ar * EnvGen.ar(Env.perc(0.0003, 0.0015)) * 0.12));
	var exc = LPF.ar(strike, 1500 + (hard * hard * 14000));
	// the skin relaxes after the strike: the pitch falls from freq × (1 + glide) to freq in ~40 ms
	var f = freq * (1 + (glide * EnvGen.kr(Env([1, 0], [0.04], -4))));
	var skinBank = DynKlank.ar(`[[1, 1.52, 2.02, 2.47, 2.94], [1, 0.55, 0.38, 0.25, 0.14], [1, 0.5, 0.36, 0.27, 0.18]],
		exc, f, 0, decay);
	var woodBank = DynKlank.ar(`[[1, 2.76, 5.4, 8.93], [1, 0.42, 0.18, 0.07], [1, 0.32, 0.14, 0.07]], exc, f, 0, decay);
	var slap = BPF.ar(WhiteNoise.ar, 2800 + (hard * 2400), 0.8) * EnvGen.ar(Env.perc(0.0004, 0.012 + (0.025 * skin))) * skin;
	var x = (Select.ar(kind, [skinBank, woodBank]) * 0.16) + (slap * 0.35);
	x = LeakDC.ar(x) * amp;
	x = ~ce.sdFx([x, x], (lpOn: lpOn, bright: bright, lo: lo, hi: hi, tone: tone, cutMul: cutMul, lpq: lpq, hp: hp,
		thinF: thinF, hpq: hpq, bp: bp, bpq: bpq, pan: pan, stereoIn: 0));
	Line.kr(0, 0, decay * 1.1 + 0.06, doneAction: 2);
	OffsetOut.ar(out, x * post);   // post: the fader at the note's start
}),
)
