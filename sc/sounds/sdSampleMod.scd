// Voice: superdough's sampler (as sdSample) plus its waveshaper (shape; also stands in for distort with the default
// s-curve: distort d = shape k / (2 + k), k = e^d − 1), which sits after the filters and before the panner, and a
// ceiling for the low-pass (cutMax: a sound's own cutoff that Fog / Tension never open beyond). Own sound so 009's
// sdSample stays as it is; with shape 0 and no ceiling it plays exactly as sdSample.
(
name: \sdSampleMod,
role: \voice,
about: "sample player as Strudel's sampler, with superdough's shape (waveshaper)",
mono: false,
hpf: 0,
params: ~ce.sdParams((
	buf: (default: 0, spec: [0, 1023, \lin, 1], label: "Buffer", about: "2-channel sample buffer"),
	rate: (default: 1, spec: [0.25, 4, \exp], label: "Speed", about: "playback speed"),
	shape: (default: 0, spec: [0, 0.99], label: "Shape", about: "waveshaper drive (superdough shape), 0 = clean"),
	cutMax: (default: 20000, spec: [80, 20000, \exp], label: "Low-pass ceiling", about: "the low-pass never above this (Hz)"),
)),
def: SynthDef(\ce_sdSampleMod, { |out = 0, amp = 1, hold = -1, buf = 0, rate = 1, begin = 0, shape = 0, cutMax = 20000,
	a = 0.001, d = 0.001, s = 1, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1, stereoIn = 1|
	var len = Select.kr(hold < 0, [hold, BufDur.ir(buf) * (1 - begin) / rate.abs]);
	var sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate,
		startPos: Select.kr(rate < 0, [begin * BufFrames.ir(buf), ((1 - begin) * BufFrames.ir(buf)) - 1]));
	var cut = (~ce.cutoff(bright, lo, hi, tone) * cutMul).min(cutMax), k;
	sig = sig * EnvGen.ar(~ce.adsr(a, d, s, r, len)) * amp;
	sig = Select.ar(lpOn > 0, [sig, ~ce.lpf(sig, cut, ~ce.rq(lpq))]);
	sig = ~ce.thinHpf(sig, hp, thinF, hpq);
	sig = Select.ar(bp > 0, [sig, ~ce.bpf(sig, bp.max(10), bpq)]);
	k = 2 * shape.clip(0, 0.999) / (1 - shape.clip(0, 0.999));
	sig = (1 + k) * sig / (1 + (k * sig.abs));
	sig = Select.ar(pan >= 0, [sig, ~ce.webPan(sig, pan, stereoIn)]);
	Line.kr(0, 0, len + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig);
}),
)
