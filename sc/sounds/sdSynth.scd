// Voice: superdough's basic synth (Strudel `s("sine" | "triangle" | "sawtooth" | "square")`): an oscillator with
// WebAudio's waveform and phase, × 0.3 and the ADSR, then Strudel's filters and panner. wave: 0 sine, 1 triangle,
// 2 sawtooth, 3 square. Envelope defaults of synths (none set): 1 ms / 50 ms / 0.6 / 10 ms (~ce.sdADSR).
(
name: \sdSynth,
role: \voice,
about: "Strudel's basic synth voice: sine / triangle / sawtooth / square with ADSR, filters, pan",
mono: false,
hpf: 0,
wavetables: (sawBuf: \saw, sqBuf: \square),
params: ~ce.sdParams((
	wave: (default: 0, spec: [0, 3, \lin, 1], label: "Wave", about: "0 sine, 1 triangle, 2 saw, 3 square"),
	vib: (default: 0, spec: [0, 20], label: "Vibrato rate", about: "Hz (Strudel vib), 0 = none"),
	vibmod: (default: 0.5, spec: [0, 2], label: "Vibrato depth", about: "semitones (Strudel vibmod)"),
)),
def: SynthDef(\ce_sdSynth, { |out = 0, amp = 1, hold = 0.1, freq = 440, wave = 0, sawBuf = 0, sqBuf = 0, vib = 0, vibmod = 0.5,
	a = 0.001, d = 0.05, s = 0.6, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1|
	var wt = ~ce.wavetableIndex(freq);
	// vibrato as superdough: a sine (from the note's start) on the detune, vibmod semitones
	var f = freq * (2 ** ((SinOsc.ar(vib) * vibmod * (vib > 0)) / 12));
	var sig = Select.ar(wave, [SinOsc.ar(f), LFTri.ar(f), Osc.ar(sawBuf + wt, f), Osc.ar(sqBuf + wt, f)]);
	sig = sig * 0.3 * EnvGen.ar(~ce.adsr(a, d, s, r, hold)) * amp;
	sig = ~ce.sdFx([sig, sig], (lpOn: lpOn, bright: bright, lo: lo, hi: hi, tone: tone, cutMul: cutMul, lpq: lpq, hp: hp,
		thinF: thinF, hpq: hpq, bp: bp, bpq: bpq, pan: pan, stereoIn: 0));
	Line.kr(0, 0, hold + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig);
}),
)
