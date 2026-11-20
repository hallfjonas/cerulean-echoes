// Mixer: one channel strip per stem (thin/high-pass, master, reverb send), effect returns per orbit, master.
// Signal flow (node order): sources → strips → returns → master → hardware out.
// Levels are linear like the Strudel faders; the master has a trim and a limiter (ceiling -1 dBFS) as the last link.
(
// Global column: derived factors the sounds and strips read (same formulas as the Strudel tracks)
//   tone = fog factor × tension opening (every low-pass), fogF = fog only (hats, clap: "high" stems),
//   thinF = factor on every high-pass (Thin)
~ce.defs[\ce_global] = SynthDef(\ce_global, { |fog = 0, thin = 0, tension = 0, toneOut, fogOut, thinOut|
	var f = 0.06 ** fog;
	Out.kr(toneOut, f * (1 + (1.5 * tension)));
	Out.kr(fogOut, f);
	Out.kr(thinOut, (1 / 0.06) ** thin);
});

// Channel strip. hpOwn: the sound's own high-pass (Hz), 0 = none. Thin multiplies it (a sound without one starts
// at 30 Hz); Thin at 0 adds no filter at all (the filter fades in over the first 2 % of the knob).
// WebAudio biquads (Strudel) take Q in dB: Q 1 dB → rq = 1 / 10^(1/20).
// level: a lane's crossfade level (acts at once); the fader itself acts per note (post, see ~ce.noteLevel).
// trim: the stem's own gain (a number or a mapped bus), on top of level × master.
// thinOn 0: the stem's voices do Thin themselves (per note, sd voices). Delay send (Strudel bus()): echo × 2 ×
// space, at most 0.9, or Tension's echo (0 → 0.45 over the first half of the knob) where that is larger; delayOn 0
// for dry stems (Strudel dryBus: kick, sub, bass).
~ce.defs[\ce_strip] = SynthDef(\ce_strip, { |in, out, level = 0, master = 0, trim = 1, thinF = 1, hpOwn = 0, thinOn = 1,
	space = 0, tension = 0, roomOut, roomOn = 1, delayOut, delayOn = 0, echo = 0, rDirect = -1, dDirect = -1, tEchoOn = 1|
	var sig = In.ar(in, 2), f = Lag.kr(thinF, 0.02), base = hpOwn.max(30) * (hpOwn <= 0) + (hpOwn * (hpOwn > 0));
	var cut = (base * f).min(5000).max(base);
	var hp = ~ce.hpf(sig, cut, 1 / (10 ** (1/20)));
	var mix = ((f - 1) / 0.02).clip(0, 1).max(hpOwn > 0);
	// room: 0.9 × space (lab columns: their own amount from a state bus), Tension opens it up to 0.95
	var r = Select.kr(rDirect >= 0, [0.9 * space, rDirect]), room = Lag.kr(r + ((0.95 - r) * tension), 0.02) * roomOn;
	var dbase = Select.kr(dDirect >= 0, [(echo * 2 * space).min(0.9), dDirect]);
	var dsend = Lag.kr(dbase.max((tension / 0.5).clip(0, 1) * 0.45 * tEchoOn), 0.02) * delayOn;   // tEchoOn 0: no Tension echo
	sig = Select.ar(thinOn > 0, [sig, XFade2.ar(sig, hp, mix * 2 - 1)]);
	sig = sig * Lag.kr(level * master * trim, 0.02);
	Out.ar(out, sig);
	Out.ar(roomOut, sig * room);
	Out.ar(delayOut, sig * dsend);
});

// Delay return of one orbit (superdough's feedback delay: y = x(t − T) + feedback × y(t − T)), into the master
~ce.defs[\ce_delay] = SynthDef(\ce_delay, { |in, out, time = 0.36, feedback = 0.2|
	// A new echo time does not jump (that clicks and smears the tail): two delay lines, both always fed; the
	// silent one takes the new time and is faded in over 60 ms while the other fades out (equal power).
	var x = In.ar(in, 2), ch = Changed.kr(time) + Impulse.kr(0), sel = PulseCount.kr(ch) % 2;
	var tA = Latch.kr(time, ch * sel), tB = Latch.kr(time, (ch * (1 - sel)) + Impulse.kr(0));
	var fb = Lag.kr(feedback.clip(0.001, 0.98), 0.05);
	var line = { |t| CombL.ar(x, 2, t, t * log(0.001) / log(fb)) };
	Out.ar(out, XFade2.ar(line.(tB), line.(tA), Lag.kr(sel, 0.06) * 2 - 1));
});

// Reverb return of one orbit: convolution with the impulse response Strudel's orbit reverb has for that room size
// (measured from superdough, tools/sc-port/reverb-ir.mjs). irL / irR: PartConv spectral buffers.
// PartConv answers fftSize / 2 − blockSize samples late (2048: 20 ms). So the IR is split: its head (those samples)
// with fftSize = 2 × blockSize (no delay), the rest with 2048, whose delay is exactly the head's length: no pre-delay.
~ce.defs[\ce_reverb] = SynthDef(\ce_reverb, { |in, out, headL, headR, tailL, tailR, headSize = 128, tailSize = 2048|
	var sig = In.ar(in, 2);
	Out.ar(out, [PartConv.ar(sig[0], headSize, headL) + PartConv.ar(sig[0], tailSize, tailL),
		PartConv.ar(sig[1], headSize, headR) + PartConv.ar(sig[1], tailSize, tailR)]);
});

// Master: trim, limiter (ceiling -1 dBFS, should hardly work), hardware out 1/2.
~ce.defs[\ce_master] = SynthDef(\ce_master, { |in, out = 0, trimDb = 0, limit = 1|
	var sig = In.ar(in, 2) * trimDb.dbamp;
	sig = Select.ar(limit > 0, [sig, Limiter.ar(sig, -1.dbamp, 0.005)]);
	Out.ar(out, sig);
});
)
