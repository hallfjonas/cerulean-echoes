// Voice: superdough's sampler (Strudel `s("…")` with a sample bank) — plays a sample with Strudel's envelope,
// filters and panner, so a drum stem ports 1:1. The track resolves the envelope with ~ce.sdADSR (samples:
// defaults 1 ms / 1 ms / 1 / 10 ms) and passes hold = -1 when the sample plays to its end (no clip, release, loop).
// Buffers have 2 channels (a mono file is read into both); stereoIn = 0 for mono files (the panner differs).
(
name: \sdSample,
role: \voice,
about: "sample player as Strudel's sampler: ADSR, low-pass (brightness), high-pass (Thin), band-pass, WebAudio pan",
mono: false,
hpf: 0,
params: ~ce.sdParams((
	buf: (default: 0, spec: [0, 1023, \lin, 1], label: "Buffer", about: "2-channel sample buffer"),
	rate: (default: 1, spec: [0.25, 4, \exp], label: "Speed", about: "playback speed"),
)),
def: SynthDef(\ce_sdSample, { |out = 0, post = 1, amp = 1, hold = -1, buf = 0, rate = 1, begin = 0,
	a = 0.001, d = 0.001, s = 1, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1, stereoIn = 1|
	// a negative rate plays the sample backwards from its end (superdough: speed < 0 reverses the buffer)
	var len = Select.kr(hold < 0, [hold, BufDur.ir(buf) * (1 - begin) / rate.abs]);
	var sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate,
		startPos: Select.kr(rate < 0, [begin * BufFrames.ir(buf), ((1 - begin) * BufFrames.ir(buf)) - 1]));
	sig = sig * EnvGen.ar(~ce.adsr(a, d, s, r, len)) * amp;
	sig = ~ce.sdFx(sig, (lpOn: lpOn, bright: bright, lo: lo, hi: hi, tone: tone, cutMul: cutMul, lpq: lpq, hp: hp,
		thinF: thinF, hpq: hpq, bp: bp, bpq: bpq, pan: pan, stereoIn: stereoIn));
	Line.kr(0, 0, len + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig * post);   // post: the fader at the note's start (Strudel postgain)
}),
)
