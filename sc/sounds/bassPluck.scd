// Plucked bass: saw + square an octave down, filter pluck.
// Exported by the Sample Designer from sc/lab/samples/bass-pluck.sample.json; blocks: osc1 (Saw), osc2 (Square), filter (Low-pass), env (Gate), lfo (Sine, off), chorus (Chorus, off), drive (Soft).
// The machine below is a copy of sc/lab/samples/machine.scd at export time: every block parameter stays live.
(
var machine = (
// Sample Designer machine: the SynthDef of a block chain (sources summed, then the effects in chain order, the
// envelope and LFO as modulators). Returns a function { |defName, blocks, defaults| SynthDef }:
//   blocks   [[id, kind], …] in column order; kinds and their knobs: blocks.json
//   defaults param → value; every block has the parameters <id><Knob> (knobs 0..1), <id>Level, <id>On, <id>Type
// Every parameter is a SynthDef control: mapped to a bus it acts at once, also on sounding notes. An exported library
// sound (sc/sounds/<name>.scd) carries a copy of this file, so a later change here never changes an exported sound.
{ |defName, blocks, defaults|
	var d = defaults ? ();
	var pname = { |id, key| (id.asString ++ key[0].toUpper ++ key.drop(1)).asSymbol };
	var has = { |kind| blocks.any { |b| b[1].asSymbol == kind } };
	var idOf = { |kind| blocks.detect { |b| b[1].asSymbol == kind } !? { |b| b[0] } };
	SynthDef(defName, { |out = 0, post = 1, amp = 1, hold = 0.25, freq = 110, bright = 1, tone = 1|
		var kr = { |id, key, lag = 0.02| var n = pname.(id, key); n.kr(d[n] ? 0, lag) };
		var on = { |id| kr.(id, "on", 0) > 0.5 };
		var pick = { |id, list| Select.ar(kr.(id, "type", 0).round.clip(0, list.size - 1), list) };
		var pickK = { |id, list| Select.kr(kr.(id, "type", 0).round.clip(0, list.size - 1), list) };
		var mix = { |id, dry, wet| var m = kr.(id, "level") * on.(id); (dry * (1 - m)) + (wet * m) };
		var env, shape, lfoPitch = 0, lfoCut = 0, sig = 0, plain;
		plain = EnvGen.ar(~ce.adsr(0.005, 0.01, 1, 0.05, hold));
		shape = idOf.(\env) !? { |id|
			var a = 0.001 * (2000 ** kr.(id, "attack", 0)), dc = 0.01 * (400 ** kr.(id, "decay", 0));
			var s = kr.(id, "sustain", 0), r = 0.02 + (0.3 * dc);
			var oneShot = EnvGen.ar(Env.perc(a, dc, 1, -4)), gate = EnvGen.ar(~ce.adsr(a, dc, s, r, hold));
			Select.ar(on.(id), [plain, pick.(id, [oneShot, gate])])
		} ? plain;
		env = shape * (idOf.(\env) !? { |id| Select.kr(on.(id), [1, kr.(id, "level")]) } ? 1);
		idOf.(\lfo) !? { |id|
			var rate = 0.1 * (200 ** kr.(id, "rate")), depth = kr.(id, "level") * on.(id);
			var shapes = [SinOsc.kr(rate), LFTri.kr(rate), LFPulse.kr(rate, 0, 0.5, 2, -1), LFNoise0.kr(rate),
				EnvGen.kr(Env.perc(0.001, rate.reciprocal.clip(0.02, 5)))];
			var m = pickK.(id, shapes) * depth;
			lfoPitch = m * 12 * kr.(id, "pitch").squared;
			lfoCut = m * 4 * kr.(id, "cutoff");
		};
		blocks.do { |b| var id = b[0], lvl = kr.(id, "level") * on.(id);
			switch(b[1].asSymbol,
				\tone, {
					var bendEnv = EnvGen.kr(Env([1, 0], [0.005 * (80 ** kr.(id, "bendTime"))], -4));
					var f = 25 * (64 ** kr.(id, "pitch")) * (2 ** (((48 * kr.(id, "bend") * bendEnv) + lfoPitch) / 12));
					sig = sig + (pick.(id, [SinOsc.ar(f), LFTri.ar(f), Pulse.ar(f, 0.5), Saw.ar(f)]) * 0.5 * lvl) },
				\noise, {
					var centre = 100 * (120 ** kr.(id, "colour")), rq = 0.05 * (40 ** kr.(id, "width"));
					var metal = Mix(Pulse.ar([205.3, 304.4, 369.6, 522.7, 540, 800] * (centre / 1000).max(0.2))) / 6;
					var n = BPF.ar(pick.(id, [WhiteNoise.ar, PinkNoise.ar * 2, metal]), centre.clip(20, 18000), rq);
					var ne = EnvGen.ar(Env.perc(0.001, 0.005 * (200 ** kr.(id, "decay")), 1, -4));
					sig = sig + (n * rq.reciprocal.sqrt * ne * 0.5 * lvl) },
				\click, {
					var cut = 500 * (30 ** kr.(id, "tone")), len = 0.0005 * (40 ** kr.(id, "length"));
					var count = 1 + (3 * kr.(id, "repeat")).round;
					var burst = Mix((0..3).collect { |i| EnvGen.ar(Env([0, 0, 1, 0], [i * 0.009, 0.0003, len], -4)) * (i < count) });
					var src = pick.(id, [SinOsc.ar(cut * 0.5), LPF.ar(WhiteNoise.ar, cut)]);
					sig = sig + (src * burst * 0.6 * lvl) },
				\osc, {
					var semis = ((kr.(id, "tune", 0) - 0.5) * 48).round, c = kr.(id, "detune") * 30;
					var f = freq * (2 ** ((semis + lfoPitch) / 12)), fold = 1 + (4 * kr.(id, "fold"));
					var voice = { |g| pick.(id, [Saw.ar(g), Pulse.ar(g, 0.5), LFTri.ar(g), SinOsc.ar(g)]) };
					var o = (voice.(f * (2 ** (c / 1200))) + voice.(f * (2 ** (c.neg / 1200)))) * 0.5;
					sig = sig + ((o * fold).fold2(1) * 0.4 * lvl) }
			)
		};
		sig = sig ! 2;
		blocks.do { |b| var id = b[0];
			switch(b[1].asSymbol,
				\filter, {
					// the envelope moves the cutoff at audio rate: block-wise jumps of the coefficients blow up the filter
					var sweep = 2 ** ((6 * kr.(id, "envAmount") * shape) + lfoCut);
					var cut = (30 * (600 ** kr.(id, "cutoff")) * sweep).clip(20, 18000);
					var rq = ~ce.rq(24 * kr.(id, "resonance")), bq = 0.5 + (19.5 * kr.(id, "resonance").squared);
					var res = [~ce.lpf(sig, cut, rq), ~ce.hpf(sig, cut, rq)] * rq.sqrt;
					sig = mix.(id, sig, pick.(id, res ++ [~ce.bpf(sig, cut, bq) * bq.sqrt.min(2)])) },
				\drive, {
					var g = 40 ** kr.(id, "amount"), bias = 0.5 * kr.(id, "bias"), x = (sig * g) + bias;
					var crush = Latch.ar(sig, Impulse.ar(SampleRate.ir / g.max(1))).round(2 ** ((12 * kr.(id, "amount")) - 15));
					var wet = pick.(id, [x.tanh - bias.tanh, (x.fold2(1) - bias.fold2(1)), crush]);
					wet = ~ce.lpf(LeakDC.ar(wet), 500 * (36 ** kr.(id, "tone")), ~ce.rq(0)) * 0.7;
					sig = mix.(id, sig, wet) },
				\chorus, {
					var rate = 0.05 * (100 ** kr.(id, "rate")), depth = 0.008 * kr.(id, "depth"), w = kr.(id, "width");
					var mono = Mix(sig) * 0.5, lfo = SinOsc.kr(rate, [0, pi]) * 0.5 + 0.5;
					var ch = DelayC.ar(mono, 0.03, 0.006 + (depth * lfo));
					var fl = CombC.ar(mono, 0.02, 0.0005 + (depth * 0.5 * lfo), 0.2);
					var wet = pick.(id, [ch, fl]);
					wet = [(wet[0] * (1 + w)) + (wet[1] * (1 - w)), (wet[1] * (1 + w)) + (wet[0] * (1 - w))] * 0.5;
					sig = mix.(id, sig, wet) }
			)
		};
		sig = ~ce.lpf(sig * env * amp, ~ce.cutoff(bright, 300, 18000, tone), ~ce.rq(0));
		DetectSilence.ar(shape, 0.0001, 0.05, doneAction: 2);
		Line.kr(0, 0, hold + 9, doneAction: 2);
		OffsetOut.ar(out, sig * post);
	})
}
);
var params = (
	osc1Tune: (default: 0.5, spec: [0, 1], label: "Osc Tune", about: "two octaves down ↔ two up, in semitones."),
	osc1Fold: (default: 0, spec: [0, 1], label: "Osc Fold", about: "clean ↔ folded, more overtones."),
	osc1Detune: (default: 0.2, spec: [0, 1], label: "Osc Detune", about: "one voice ↔ two voices beating."),
	osc1Level: (default: 0.8, spec: [0, 1], label: "Osc Level", about: "oscillator level."),
	osc1On: (default: 1, spec: [0, 1, \lin, 1], label: "Osc On", about: "block on / off"),
	osc1Type: (default: 0, spec: [0, 3, \lin, 1], label: "Osc Type", about: "Saw, Square, Triangle, Sine"),
	osc2Tune: (default: 0.25, spec: [0, 1], label: "Osc Tune", about: "two octaves down ↔ two up, in semitones."),
	osc2Fold: (default: 0, spec: [0, 1], label: "Osc Fold", about: "clean ↔ folded, more overtones."),
	osc2Detune: (default: 0, spec: [0, 1], label: "Osc Detune", about: "one voice ↔ two voices beating."),
	osc2Level: (default: 0.5, spec: [0, 1], label: "Osc Level", about: "oscillator level."),
	osc2On: (default: 1, spec: [0, 1, \lin, 1], label: "Osc On", about: "block on / off"),
	osc2Type: (default: 1, spec: [0, 3, \lin, 1], label: "Osc Type", about: "Saw, Square, Triangle, Sine"),
	filterCutoff: (default: 0.35, spec: [0, 1], label: "Filter Cutoff", about: "closed ↔ open."),
	filterResonance: (default: 0.35, spec: [0, 1], label: "Filter Resonance", about: "smooth ↔ ringing peak."),
	filterEnvAmount: (default: 0.5, spec: [0, 1], label: "Filter Env amount", about: "static ↔ opens with each note."),
	filterLevel: (default: 1, spec: [0, 1], label: "Filter Mix", about: "dry ↔ filtered."),
	filterOn: (default: 1, spec: [0, 1, \lin, 1], label: "Filter On", about: "block on / off"),
	filterType: (default: 0, spec: [0, 2, \lin, 1], label: "Filter Type", about: "Low-pass, High-pass, Band-pass"),
	envAttack: (default: 0, spec: [0, 1], label: "Envelope Attack", about: "hard ↔ slow fade in."),
	envDecay: (default: 0.35, spec: [0, 1], label: "Envelope Decay", about: "short ↔ long fall."),
	envSustain: (default: 0.3, spec: [0, 1], label: "Envelope Sustain", about: "falls to silence ↔ holds full level."),
	envLevel: (default: 0.9, spec: [0, 1], label: "Envelope Level", about: "level of the whole voice."),
	envOn: (default: 1, spec: [0, 1, \lin, 1], label: "Envelope On", about: "block on / off"),
	envType: (default: 1, spec: [0, 1, \lin, 1], label: "Envelope Type", about: "One-shot, Gate"),
	lfoRate: (default: 0.5, spec: [0, 1], label: "LFO Rate", about: "slow ↔ fast (Envelope: long ↔ short)."),
	lfoPitch: (default: 0, spec: [0, 1], label: "LFO Pitch", about: "no vibrato ↔ wide vibrato."),
	lfoCutoff: (default: 0.2, spec: [0, 1], label: "LFO Cutoff", about: "filter stays ↔ filter sweeps."),
	lfoLevel: (default: 0.5, spec: [0, 1], label: "LFO Depth", about: "how much the LFO moves anything."),
	lfoOn: (default: 0, spec: [0, 1, \lin, 1], label: "LFO On", about: "block on / off"),
	lfoType: (default: 0, spec: [0, 4, \lin, 1], label: "LFO Type", about: "Sine, Triangle, Square, Random, Envelope"),
	chorusRate: (default: 0.3, spec: [0, 1], label: "Chorus Rate", about: "slow ↔ fast movement."),
	chorusDepth: (default: 0.3, spec: [0, 1], label: "Chorus Depth", about: "subtle ↔ deep wobble."),
	chorusWidth: (default: 0.5, spec: [0, 1], label: "Chorus Width", about: "centre ↔ wide stereo."),
	chorusLevel: (default: 0.4, spec: [0, 1], label: "Chorus Mix", about: "dry ↔ chorused."),
	chorusOn: (default: 0, spec: [0, 1, \lin, 1], label: "Chorus On", about: "block on / off"),
	chorusType: (default: 0, spec: [0, 1, \lin, 1], label: "Chorus Type", about: "Chorus, Flanger"),
	driveAmount: (default: 0.2, spec: [0, 1], label: "Drive Amount", about: "warm ↔ heavy distortion."),
	driveTone: (default: 0.5, spec: [0, 1], label: "Drive Tone", about: "dark ↔ bright after the drive."),
	driveBias: (default: 0, spec: [0, 1], label: "Drive Bias", about: "even ↔ lopsided, buzzier distortion."),
	driveLevel: (default: 0.3, spec: [0, 1], label: "Drive Mix", about: "dry ↔ driven."),
	driveOn: (default: 1, spec: [0, 1, \lin, 1], label: "Drive On", about: "block on / off"),
	driveType: (default: 0, spec: [0, 2, \lin, 1], label: "Drive Type", about: "Soft, Fold, Crush"),
	bright: (default: 1, spec: [0, 1], label: "Brightness", about: "dull ↔ open"),
	tone: (default: 1, spec: [0.05, 2.5, \exp], label: "Tone", about: "global factor (Fog, Tension)"),
);
(
name: \bassPluck,
role: \bass,
about: "Plucked bass: saw + square an octave down, filter pluck.",
mono: true,
hpf: 0,
params: params,
def: machine.(\ce_bassPluck, [[\osc1, \osc], [\osc2, \osc], [\filter, \filter], [\env, \env], [\lfo, \lfo], [\chorus, \chorus], [\drive, \drive]], params.collect(_[\default])),
)
)
