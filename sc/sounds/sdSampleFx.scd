// Voice: superdough's sampler (as sdSampleMod: start point, speed, ADSR, low-pass with a ceiling, high-pass, band-pass)
// plus the rest of superdough's chain that track 007 uses, in superdough's order: vibrato on the playback (vib / vibmod,
// on the source's detune), a gain before the filters (pre: a mapped bus, e.g. a distortion knob's level drop), then
// low-pass → high-pass → band-pass → coarse (sample-and-hold every n samples, restarted every 128-sample block)
// → crush (round to 2^(crush − 1) steps; 0 = off) → shape → distort (s-curve, k = e^d − 1; 0 = clean) → pan.
// Every effect parameter may be a mapped bus, so a knob changes sounding notes. With the defaults it plays as sdSampleMod.
(
name: \sdSampleFx,
role: \voice,
about: "sample player as Strudel's sampler with vibrato, coarse, crush, shape and distort (superdough's chain)",
mono: false,
hpf: 0,
params: ~ce.sdParams((
	buf: (default: 0, spec: [0, 1023, \lin, 1], label: "Buffer", about: "2-channel sample buffer"),
	rate: (default: 1, spec: [0.25, 4, \exp], label: "Speed", about: "playback speed"),
	vib: (default: 0, spec: [0, 20], label: "Vibrato rate", about: "Hz (Strudel vib), 0 = none"),
	vibmod: (default: 0.5, spec: [0, 2], label: "Vibrato depth", about: "semitones (Strudel vibmod)"),
	pre: (default: 1, spec: [0, 2], label: "Pre-gain", about: "level before the filters and the distortion"),
	coarse: (default: 1, spec: [1, 16, \lin, 1], label: "Coarse", about: "keep every n-th sample (1 = clean)"),
	crush: (default: 0, spec: [0, 16], label: "Crush", about: "bit depth (0 = clean)"),
	shape: (default: 0, spec: [0, 0.99], label: "Shape", about: "waveshaper drive (superdough shape), 0 = clean"),
	distort: (default: 0, spec: [0, 8], label: "Distort", about: "superdough distort (s-curve), 0 = clean"),
	cutMax: (default: 20000, spec: [80, 20000, \exp], label: "Low-pass ceiling", about: "the low-pass never above this (Hz)"),
)),
def: SynthDef(\ce_sdSampleFx, { |out = 0, post = 1, amp = 1, hold = -1, buf = 0, rate = 1, begin = 0, vib = 0, vibmod = 0.5, pre = 1,
	coarse = 1, crush = 0, shape = 0, distort = 0, cutMax = 20000,
	a = 0.001, d = 0.001, s = 1, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1, stereoIn = 1|
	var len = Select.kr(hold < 0, [hold, BufDur.ir(buf) * (1 - begin) / rate.abs]);
	var vr = 2 ** (SinOsc.kr(vib) * vibmod * (vib > 0) / 12);
	var sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate * vr,
		startPos: Select.kr(rate < 0, [begin * BufFrames.ir(buf), ((1 - begin) * BufFrames.ir(buf)) - 1]));
	var cut = (~ce.cutoff(bright, lo, hi, tone) * cutMul).min(cutMax), k, c, n, q;
	sig = sig * EnvGen.ar(~ce.adsr(a, d, s, r, len)) * amp * Lag.kr(pre, 0.02);
	sig = Select.ar(lpOn > 0, [sig, ~ce.lpf(sig, cut, ~ce.rq(lpq))]);
	sig = ~ce.thinHpf(sig, hp, thinF, hpq);
	sig = Select.ar(bp > 0, [sig, ~ce.bpf(sig, bp.max(10), bpq)]);
	// coarse: hold every c-th sample of a 128-sample block
	c = coarse.round.max(1); n = Phasor.ar(0, 1, 0, 128);
	sig = Select.ar(c > 1, [sig, Latch.ar(sig, (n % c) < 0.5)]);
	// crush: 2^(crush − 1) steps per unit
	q = 2 ** (crush.max(1) - 1);
	sig = Select.ar(crush > 0, [sig, (sig * q).round / q]);
	k = 2 * shape.clip(0, 0.999) / (1 - shape.clip(0, 0.999));
	sig = (1 + k) * sig / (1 + (k * sig.abs));
	k = distort.exp - 1;
	sig = (1 + k) * sig / (1 + (k * sig.abs));
	sig = Select.ar(pan >= 0, [sig, ~ce.webPan(sig, pan, stereoIn)]);
	Line.kr(0, 0, len + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig * post);   // post: the fader at the note's start (Strudel postgain)
}),
)
