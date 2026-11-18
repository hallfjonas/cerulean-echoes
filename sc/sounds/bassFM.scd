// Bass: FM sine (Daft Punk style) with a sine an octave below. From the bass lab (lab/bass/house-bass-4), sound 1.
// superdough: sine carrier, modulator at the same frequency, index 2 with an exponential envelope (1 ms up, 0.12 s
// down to 0.1); amp ADSR 2 ms / 0.2 s / 0.5 / 0.05 s; carrier 0.45, sub 0.2; per-note low-pass (brightness).
(
name: \bassFM,
role: \bass,
about: "FM bass: sine with an FM bite at the attack, plus a sine an octave below",
mono: true,
hpf: 0,
params: (
	bright: (default: 0, spec: [0, 1], label: "Brightness", about: "dull ↔ bright"),
	lo:     (default: 400, spec: [80, 18000, \exp], label: "Low-pass min", about: "cutoff at brightness 0"),
	hi:     (default: 5000, spec: [80, 18000, \exp], label: "Low-pass max", about: "cutoff at brightness 1"),
	tone:   (default: 1, spec: [0.05, 2.5, \exp], label: "Tone", about: "global factor (Fog, Tension)"),
	dark:   (default: 0, spec: [0, 1], label: "Dead note", about: "1 = cutoff × 0.6 (ghost notes)"),
	level:  (default: 1, spec: [0, 1], label: "Level", about: "continuous gain (sound blend)"),
	index:  (default: 2, spec: [0, 8], label: "FM index", about: "FM depth at the attack"),
	modPhase: (default: -1, spec: [-1, 6.2832], label: "Mod phase", about: "start phase of the modulator; -1 = random per note (as in the browser)"),
),
def: SynthDef(\ce_bassFM, { |out = 0, amp = 1, hold = 0.1, freq = 55, bright = 0, lo = 400, hi = 5000, tone = 1,
	dark = 0, level = 1, index = 2, modPhase = -1|
	var env = EnvGen.ar(~ce.adsr(0.002, 0.2, 0.5, 0.05, hold));
	var fmEnv = EnvGen.ar(~ce.adsr(0.001, 0.12, 0.1, 0.01, hold, 0, 1, \exp));
	// the browser starts the modulator when the note is scheduled, not on the beat: its phase is random per note
	var ph = Select.kr(modPhase < 0, [modPhase, Rand(0, 2pi)]);
	var car = SinOsc.ar(freq + (SinOsc.ar(freq, ph) * index * freq * fmEnv)) * 0.45;
	var sig = (car + (SinOsc.ar(freq / 2) * 0.2)) * env * 0.3 * amp;
	sig = ~ce.lpf(sig, ~ce.cutoff(bright, lo, hi, tone) * (1 - (0.4 * dark)), ~ce.rq(1));
	Line.kr(0, 0, hold + 0.1, doneAction: 2);
	OffsetOut.ar(out, (sig * Lag.kr(level, 0.02)) ! 2);
}),
)
