// Voice: Strudel's General MIDI soundfont player (gm_* sounds, @strudel/soundfonts with the WebAudioFont presets):
// one zone's sample (extracted by tools/sc-port/soundfont-extract.py into sc/samples/gm/<preset>/), pitched by
// 2^((100 × note − base) / 1200) with base = originalPitch − 100 × coarseTune − fineTune, looped between the
// zone's loop points when it has them, an ADSR whose peak is 0.3 (as the fontloader), then superdough's filters
// and panner. The track picks the zone with ~ce.fontZone(preset, note) and passes buf / rate / loop points.
(
name: \sdFont,
role: \voice,
about: "General MIDI soundfont zone as Strudel's gm_* sounds: pitch, loop, ADSR (peak 0.3), filters, pan",
mono: false,
hpf: 0,
params: ~ce.sdParams((
	buf: (default: 0, spec: [0, 1023, \lin, 1], label: "Buffer", about: "the zone's sample (2 channels)"),
	rate: (default: 1, spec: [0.125, 8, \exp], label: "Speed", about: "playback rate from the zone's pitch"),
	loopOn: (default: 0, spec: [0, 1, \lin, 1], label: "Loop", about: "1 = the zone loops"),
	loopStart: (default: 0, spec: [0, 10], label: "Loop start", about: "seconds"),
	loopEnd: (default: 0, spec: [0, 10], label: "Loop end", about: "seconds"),
)),
def: SynthDef(\ce_sdFont, { |out = 0, amp = 1, hold = 0.25, buf = 0, rate = 1, loopOn = 0, loopStart = 0, loopEnd = 0,
	a = 0.001, d = 0.001, s = 1, r = 0.01,
	lpOn = 0, bright = 0, lo = 1000, hi = 1000, tone = 1, cutMul = 1, lpq = 1, hp = 0, thinF = 1, hpq = 1,
	bp = 0, bpq = 1, pan = -1, stereoIn = 0|
	// read position in frames: straight through, or (looped) wrapped into [loopStart, loopEnd) once past loopEnd
	var sr = BufSampleRate.ir(buf), ls = loopStart * sr, le = loopEnd * sr;
	var pos = Sweep.ar(0, sr * rate);
	var wrapped = Select.ar((loopOn > 0) * (pos >= le), [pos, ls + ((pos - ls) % (le - ls).max(1))]);
	var sig = BufRd.ar(2, buf, wrapped.min(BufFrames.ir(buf) - 1), 0, 4);   // cubic, as PlayBuf
	sig = sig * (pos < (BufFrames.ir(buf) + (loopOn * 1e9)));   // not looped: silent after the end (SC: left to right)
	sig = sig * EnvGen.ar(~ce.adsr(a, d, s, r, hold)) * 0.3 * amp;
	sig = ~ce.sdFx(sig, (lpOn: lpOn, bright: bright, lo: lo, hi: hi, tone: tone, cutMul: cutMul, lpq: lpq, hp: hp,
		thinF: thinF, hpq: hpq, bp: bp, bpq: bpq, pan: pan, stereoIn: stereoIn));
	Line.kr(0, 0, hold + r + 0.05, doneAction: 2);
	OffsetOut.ar(out, sig);
}),
)
