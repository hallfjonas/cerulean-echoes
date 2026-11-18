// Kick: the TR-909 bass drum (sample) with a short sine body under it, tuned to the key (track 009 kick).
// Port of the Strudel kick in tracks/009-house: sample at 0.75, linear decay 0.28 s − 0.06 × punch; body = sine with
// a pitch drop of 24 + 12 × punch semitones over 30 ms, decay 0.16 s, level 0.35 + 0.2 × punch; both through one
// low-pass (brightness).
(
name: \kick909,
role: \kick,
about: "909 kick sample + tuned sine body with pitch drop; punch = shorter sample, harder drop, louder body",
mono: true,
hpf: 0,
samples: (bd: "tr909/bd-01.wav"),
params: (
	punch:  (default: 0, spec: [0, 1], label: "Punch", about: "tight ↔ hard"),
	body:   (default: 33, spec: [24, 48, \lin, 1], label: "Body note", about: "MIDI note of the sine body (A1 = 33)"),
	bright: (default: 0, spec: [0, 1], label: "Brightness", about: "dull ↔ bright"),
	lo:     (default: 4000, spec: [80, 18000, \exp], label: "Low-pass min", about: "cutoff at brightness 0"),
	hi:     (default: 16000, spec: [80, 18000, \exp], label: "Low-pass max", about: "cutoff at brightness 1"),
	tone:   (default: 1, spec: [0.05, 2.5, \exp], label: "Tone", about: "global factor (Fog, Tension)"),
),
def: SynthDef(\ce_kick909, { |out = 0, amp = 1, hold = 0.48, punch = 0, body = 33, bright = 0, lo = 4000, hi = 16000,
	tone = 1, bd = 0|
	var p = punch, dec = 0.28 - (0.06 * p), penv = (24 + (12 * p)) * 100;
	var smp = PlayBuf.ar(2, bd, BufRateScale.ir(bd)) * EnvGen.ar(~ce.adsr(0.001, dec, 0, 0.02, hold)) * 0.75;
	var cents = EnvGen.ar(~ce.adsr(0.001, 0.03, 0.001, 0.001, hold, penv.neg * 0.001, penv * 0.999));
	var bodyEnv = EnvGen.ar(~ce.adsr(0.001, 0.16, 0, 0.03, hold));
	var bod = SinOsc.ar(body.midicps * (2 ** (cents / 1200))) * bodyEnv * 0.3 * (0.35 + (0.2 * p));
	var sig = (smp + bod) * amp;
	sig = ~ce.lpf(sig, ~ce.cutoff(bright, lo, hi, tone), ~ce.rq(1));
	Line.kr(0, 0, hold.max(0.3) + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig);
}),
)
