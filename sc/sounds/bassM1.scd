// Bass: M1 organ bass (Korg M1 house organ style). From the bass lab (lab/bass/house-bass-4), sound 2.
// superdough: triangle 0.5 + sine a twelfth and an octave up (+19 semitones) 0.12 + sine an octave below 0.35;
// amp ADSR 2 ms / 0.2 s / 0.45 / 0.06 s; per-note low-pass (brightness).
(
name: \bassM1,
role: \bass,
about: "M1 organ bass: triangle with a quiet high partial and a sine an octave below",
mono: true,
hpf: 0,
params: (
	bright: (default: 0, spec: [0, 1], label: "Brightness", about: "dull ↔ bright"),
	lo:     (default: 300, spec: [80, 18000, \exp], label: "Low-pass min", about: "cutoff at brightness 0"),
	hi:     (default: 3000, spec: [80, 18000, \exp], label: "Low-pass max", about: "cutoff at brightness 1"),
	tone:   (default: 1, spec: [0.05, 2.5, \exp], label: "Tone", about: "global factor (Fog, Tension)"),
	dark:   (default: 0, spec: [0, 1], label: "Dead note", about: "1 = cutoff × 0.6 (ghost notes)"),
	level:  (default: 1, spec: [0, 1], label: "Level", about: "continuous gain (sound blend)"),
),
def: SynthDef(\ce_bassM1, { |out = 0, amp = 1, hold = 0.1, freq = 55, bright = 0, lo = 300, hi = 3000, tone = 1,
	dark = 0, level = 1|
	var env = EnvGen.ar(~ce.adsr(0.002, 0.2, 0.45, 0.06, hold));
	var sig = (LFTri.ar(freq) * 0.5) + (SinOsc.ar(freq * (2 ** (19/12))) * 0.12) + (SinOsc.ar(freq / 2) * 0.35);
	sig = sig * env * 0.3 * amp;
	sig = ~ce.lpf(sig, ~ce.cutoff(bright, lo, hi, tone) * (1 - (0.4 * dark)), ~ce.rq(1));
	Line.kr(0, 0, hold + 0.1, doneAction: 2);
	OffsetOut.ar(out, (sig * Lag.kr(level, 0.02)) ! 2);
}),
)
