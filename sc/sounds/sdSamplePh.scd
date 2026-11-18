// Voice: superdough's sampler with its phaser (Strudel phaserrate / phaserdepth / phasercenter / phasersweep): as
// sdSample, then one notch filter (WebAudio biquad, linear Q) whose frequency a triangle LFO detunes. Own voice, so
// the plain sampler does not compute a phaser it does not use (the guitar's Lift needs it).
// superdough: notch at center + 282 Hz, Q = 2 − min(2 × depth, 1.9), LFO ±sweep cents (triangle; its phase starts
// at frac(note time in seconds × rate), as superdough's LFO worklet does).
(
name: \sdSamplePh,
role: \voice,
about: "sample player as sdSample plus superdough's phaser (one swept notch)",
mono: false,
hpf: 0,
params: ~ce.sdParams((
	buf: (default: 0, spec: [0, 1023, \lin, 1], label: "Buffer", about: "2-channel sample buffer"),
	rate: (default: 1, spec: [0.25, 4, \exp], label: "Speed", about: "playback speed"),
	phRate: (default: 1, spec: [0.05, 10, \exp], label: "Phaser rate", about: "LFO speed in Hz"),
	phDepth: (default: 0.75, spec: [0, 1], label: "Phaser depth", about: "notch width (Q 2 → 0.1)"),
	phCenter: (default: 1000, spec: [100, 8000, \exp], label: "Phaser centre", about: "Hz (+ 282 as superdough)"),
	phSweep: (default: 2000, spec: [0, 4800], label: "Phaser sweep", about: "LFO range in cents (±)"),
)),
def: SynthDef(\ce_sdSamplePh, { |out = 0, amp = 1, hold = -1, buf = 0, rate = 1, begin = 0,
	a = 0.001, d = 0.001, s = 1, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1, stereoIn = 1,
	phRate = 1, phDepth = 0.75, phCenter = 1000, phSweep = 2000, phPhase = 0|
	var len = Select.kr(hold < 0, [hold, BufDur.ir(buf) * (1 - begin) / rate]);
	var sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, startPos: begin * BufFrames.ir(buf));
	var ph = (phPhase + Sweep.kr(0, phRate)).frac, tri = Select.kr(ph >= 0.5, [ph * 2, 2 - (ph * 2)]);
	var freq = (phCenter + 282) * (2 ** ((tri - 0.5) * phSweep * 2 / 1200));
	var q = 2 - (phDepth * 2).clip(0, 1.9);
	var w0 = 2pi * freq.clip(10, SampleRate.ir * 0.49) * SampleDur.ir, c = cos(w0), alpha = sin(w0) / (2 * q), n = 1 / (1 + alpha);
	sig = sig * EnvGen.ar(~ce.adsr(a, d, s, r, len)) * amp;
	sig = ~ce.sdFx(sig, (lpOn: lpOn, bright: bright, lo: lo, hi: hi, tone: tone, cutMul: cutMul, lpq: lpq, hp: hp,
		thinF: thinF, hpq: hpq, bp: bp, bpq: bpq, pan: pan, stereoIn: stereoIn));
	sig = SOS.ar(sig, n, -2 * c * n, n, 2 * c * n, (alpha - 1) * n);   // the notch, after the panner (superdough's order)
	Line.kr(0, 0, len + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig);
}),
)
