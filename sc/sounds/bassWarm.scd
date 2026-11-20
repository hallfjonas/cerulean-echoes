// Bass: warm analog (saw + square + sine sub) through a resonant low-pass with an envelope. From the bass lab
// (lab/bass/house-bass-4), sound 3. superdough: saw 0.2 + square 0.15 + sine an octave below 0.3; filter envelope
// 2 octaves up (1 ms), down to 0.3 of that in 0.2 s, Q 2 dB; amp ADSR 3 ms / 0.3 s / 0.6 / 0.08 s.
(
name: \bassWarm,
role: \bass,
about: "warm analog bass: saw + square + sine sub, resonant low-pass with a pluck envelope",
mono: true,
hpf: 0,
wavetables: (sawBuf: \saw, sqBuf: \square),
params: (
	bright: (default: 0, spec: [0, 1], label: "Brightness", about: "dull ↔ bright"),
	lo:     (default: 250, spec: [80, 18000, \exp], label: "Low-pass min", about: "cutoff at brightness 0"),
	hi:     (default: 3500, spec: [80, 18000, \exp], label: "Low-pass max", about: "cutoff at brightness 1"),
	tone:   (default: 1, spec: [0.05, 2.5, \exp], label: "Tone", about: "global factor (Fog, Tension)"),
	dark:   (default: 0, spec: [0, 1], label: "Dead note", about: "1 = cutoff × 0.6 (ghost notes)"),
	level:  (default: 1, spec: [0, 1], label: "Level", about: "continuous gain (sound blend)"),
),
def: SynthDef(\ce_bassWarm, { |out = 0, post = 1, amp = 1, hold = 0.1, freq = 55, bright = 0, lo = 250, hi = 3500, tone = 1,
	dark = 0, level = 1, sawBuf = 0, sqBuf = 0|
	var env = EnvGen.ar(~ce.adsr(0.003, 0.3, 0.6, 0.08, hold));
	// saw and square from wavetables with WebAudio's waveforms and phase: blended with the M1 organ's triangle
	// (row 3 between 0.5 and 1) their fundamentals add up as in Strudel (with Saw/Pulse they partly cancel)
	var wt = ~ce.wavetableIndex(freq);
	var sig = (Osc.ar(sawBuf + wt, freq) * 0.2) + (Osc.ar(sqBuf + wt, freq) * 0.15) + (SinOsc.ar(freq / 2) * 0.3);
	var fenv = EnvGen.ar(~ce.adsr(0.001, 0.2, 0.3, 0.01, hold, 1, 4, \exp));
	var cut = (~ce.cutoff(bright, lo, hi, tone) * (1 - (0.4 * dark)) * fenv).min(20000);
	sig = ~ce.lpf(sig * env * 0.3 * amp, cut, ~ce.rq(2));
	Line.kr(0, 0, hold + 0.12, doneAction: 2);
	OffsetOut.ar(out, ((sig * Lag.kr(level, 0.02)) ! 2) * post);   // post: the fader at the note's start (Strudel postgain)
}),
)
