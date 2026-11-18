// Voice: superdough's noise (Strudel `s("pink" | "white" | "brown")`): a 2-second noise buffer, looped and played
// from its start on every note (as superdough does), × 0.3 and the ADSR, then filters and panner. The buffers are
// made like superdough makes them (tools/sc-port/noise-buffers.py), at 48 kHz; played at rate 1 like there.
(
name: \sdNoise,
role: \voice,
about: "Strudel's noise voice: pink / white / brown noise buffer with ADSR, filters, pan",
mono: false,
hpf: 0,
samples: (pinkBuf: "noise/pink.wav", whiteBuf: "noise/white.wav", brownBuf: "noise/brown.wav"),
params: ~ce.sdParams((
	color: (default: 0, spec: [0, 2, \lin, 1], label: "Colour", about: "0 pink, 1 white, 2 brown"),
)),
def: SynthDef(\ce_sdNoise, { |out = 0, amp = 1, hold = 0.1, color = 0, pinkBuf = 0, whiteBuf = 0, brownBuf = 0,
	a = 0.001, d = 0.05, s = 0.6, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1|
	var buf = Select.kr(color, [pinkBuf, whiteBuf, brownBuf]);
	var sig = PlayBuf.ar(2, buf, 1, loop: 1)[0];
	sig = sig * 0.3 * EnvGen.ar(~ce.adsr(a, d, s, r, hold)) * amp;
	sig = ~ce.sdFx([sig, sig], (lpOn: lpOn, bright: bright, lo: lo, hi: hi, tone: tone, cutMul: cutMul, lpq: lpq, hp: hp,
		thinF: thinF, hpq: hpq, bp: bp, bpq: bpq, pan: pan, stereoIn: 0));
	Line.kr(0, 0, hold + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig);
}),
)
