// Sound library: every sound is one file in sc/sounds/ that returns an Event in a fixed format (sounds/README.md).
// Tracks refer to sounds by name and give a preset (parameter values); they never copy sound code.
(
~ce.loadSound = { |self, name|
	var path = self.root +/+ "sounds" +/+ name.asString ++ ".scd";
	var snd = path.load;
	var problems = self.checkSound(snd, name);
	if(problems.notEmpty) { Error("sound % is not in the library format: %".format(name, problems.join("; "))).throw };
	self.sounds[name.asSymbol] = snd;
	self.defs[snd.def.name.asSymbol] = snd.def;
	snd
};

// A sound is "finished" (may go into the library) when this finds nothing.
~ce.checkSound = { |self, snd, name|
	var p = List[];
	if(snd.isKindOf(Event).not) { p.add("the file must return an Event") } {
		if(snd.name != name.asSymbol) { p.add("name must be \\" ++ name) };
		[\role, \about, \params, \def, \hpf, \mono].do { |k| if(snd[k].isNil) { p.add("missing key " ++ k) } };
		if(snd.def.isKindOf(SynthDef).not) { p.add("def must be a SynthDef") } {
			var controls = snd.def.allControlNames.collect(_.name);
			// standard inputs of every sound
			[\out, \amp, \hold].do { |c| if(controls.includes(c).not) { p.add("SynthDef lacks the standard input " ++ c) } };
			if(controls.includes(\gate)) { p.add("no gate: sounds end by themselves after hold + release") };
			(snd.params ? ()).keysValuesDo { |k, spec|
				if(controls.includes(k).not) { p.add("param % is not a SynthDef control".format(k)) };
				[\default, \spec, \label].do { |f| if(spec[f].isNil) { p.add("param % lacks %".format(k, f)) } };
			};
		};
	};
	p
};

// Buffers a sound needs: (key: "relative/path.wav") under sc/samples/
~ce.sampleBuffers = Dictionary.new;   // path (String) → bufnum
~ce.bufferFor = { |self, rel| self.sampleBuffers[rel] };
);

// Envelope as superdough (Strudel) shapes it: attack, decay, sustain level, release, from min to max, cut short when
// the note (hold, seconds) ends before attack + decay. Works with UGens as arguments. curve: \lin or \exp.
(
~ce.adsr = { |self, a, d, s, r, hold, min = 0, max = 1, curve = \lin|
	var t1, l1, sv, t2, l2, t3;
	if(curve == \exp) { min = min.max(0.001); max = max.max(0.001) };
	t1 = a.min(hold); l1 = min + ((max - min) * (t1 / a));
	sv = min + (s * (max - min));
	t2 = (hold - a).clip(0, d); l2 = l1 + ((sv - max) * (t2 / d));
	t3 = (hold - a - d).max(0);
	Env([min, l1, l2, l2, min], [t1, t2, t3, r], curve)
};
// Low-pass cutoff of a sound: brightness 0..1 over lo..hi (exponential), × the global tone (fog / tension),
// kept within 80 Hz .. 18 kHz like the Strudel tracks; lag against zipper noise
~ce.cutoff = { |self, bright, lo, hi, tone|
	(lo * ((hi / lo) ** Lag.kr(bright, 0.02)) * Lag.kr(tone, 0.02)).clip(80, 18000)
};
// WebAudio biquad Q is in dB: rq for the filters below
~ce.rq = { |self, qDb = 1| 1 / (10 ** (qDb / 20)) };
// 2-pole low-/high-pass as WebAudio's BiquadFilterNode computes it (RBJ cookbook), on SOS. Own implementation
// instead of BLowPass/BHiPass: the coefficients come straight from the current cutoff (control or audio rate), the
// same in every SuperCollider version. freq is kept between 10 Hz and 0.49 × the sample rate.
~ce.biquad = { |self, in, freq, rq, type = \lp|
	var w0 = 2pi * freq.clip(10, SampleRate.ir * 0.49) * SampleDur.ir;
	var c = cos(w0), alpha = sin(w0) * 0.5 * rq, n = 1 / (1 + alpha);
	var b0 = if(type == \lp) { (1 - c) * 0.5 } { (1 + c) * 0.5 };
	var b1 = if(type == \lp) { 1 - c } { (1 + c).neg };
	SOS.ar(in, b0 * n, b1 * n, b0 * n, 2 * c * n, (alpha - 1) * n)
};
~ce.lpf = { |self, in, freq, rq| self.biquad(in, freq, rq, \lp) };
~ce.hpf = { |self, in, freq, rq| self.biquad(in, freq, rq, \hp) };
);

// A note of a library sound: its defaults, its sample buffers, then the given args (a preset, mapped buses, …)
(
~ce.note = { |self, name, args|
	var snd = self.sounds[name], e = (instrument: snd.def.name);
	snd.params.keysValuesDo { |k, p| e[k] = p.default };
	(snd.samples ? ()).keysValuesDo { |k, rel| e[k] = self.sampleBuffers[rel] };
	(snd.wavetables ? ()).keysValuesDo { |k, shape| e[k] = self.wavetableBase[shape] };
	e.putAll(args ? ());
	e
};
);

// Band-limited wavetables with WebAudio's exact waveforms and phase (OscillatorNode 'sawtooth' / 'square'), for
// sounds whose layers must keep their phase relation (warm bass: saw + square + triangle of another sound add up
// in phase). Four tables per shape, fewer harmonics for higher notes: pick one with ~ce.wavetableIndex(freq).
(
~ce.wavetableShapes = (
	saw: { |k| (-1 ** (k + 1)) * 2 / (pi * k) },
	square: { |k| if(k.odd) { 4 / (pi * k) } { 0 } },
);
~ce.wavetableHarmonics = [200, 100, 50, 25];   // for notes up to 100 Hz, 200 Hz, 400 Hz, above
~ce.wavetableIndex = { |self, freq| (freq > 100) + (freq > 200) + (freq > 400) };   // works on UGens
);

// ---------------------------------------------------------------------------------------------------------------
// superdough building blocks (Strudel's audio engine), used by the sd* voices in sounds/
(
// getADSRValues: the envelope Strudel actually uses for given attack/decay/sustain/release (nil = not set).
// defaults: what a voice uses when none is set (samples: [0.001, 0.001, 1, 0.01], synths/noise: [0.001, 0.05, 0.6, 0.01])
~ce.sdADSR = { |self, a, d, s, r, defaults|
	if(a.isNil and: { d.isNil } and: { s.isNil } and: { r.isNil }) { defaults ? [0.001, 0.001, 1, 0.01] } {
		var sus = s ?? { if((a.notNil and: { d.isNil }) or: { a.isNil and: { d.isNil } }) { 1 } { 0.001 } };
		[(a ? 0).max(0.001), (d ? 0).max(0.001), sus.min(1), (r ? 0).max(0.01)]
	}
};
// WebAudio StereoPannerNode (pan 0..1 as in Strudel, 0.5 = centre). Mono input: equal power. Stereo input: the
// other formula (a stereo sample keeps both channels, one side is folded into the other).
~ce.webPan = { |self, sig, pan, stereoIn|
	var p = (pan * 2 - 1).clip(-1, 1), x;
	var mono = sig[0], monoOut = [mono * cos((p + 1) * 0.25pi), mono * sin((p + 1) * 0.25pi)];
	var l = sig[0], r = sig[1];
	var left = [l + (r * cos((p + 1) * 0.5pi)), r * sin((p + 1) * 0.5pi)];
	var right = [l * cos(p * 0.5pi), r + (l * sin(p * 0.5pi))];
	// Select over [[L, R], [L, R]] expands per channel: [Select([L1, L2]), Select([R1, R2])]
	var st = Select.ar(p > 0, [left, right]);
	Select.ar(stereoIn, [monoOut, st])
};
// WebAudio band-pass (constant 0 dB peak; its Q is linear, unlike low-/high-pass)
~ce.bpf = { |self, in, freq, q = 1|
	var w0 = 2pi * freq.clip(10, SampleRate.ir * 0.49) * SampleDur.ir;
	var c = cos(w0), alpha = sin(w0) / (2 * q), n = 1 / (1 + alpha);
	SOS.ar(in, alpha * n, 0, alpha.neg * n, 2 * c * n, (alpha - 1) * n)
};
// High-pass of a note with Thin, as the Strudel tracks do it per note: own cutoff (0 = none), Thin factor f:
// f ≤ 1 → own cutoff only; f > 1 → max(own, min(5000, own × f)) with own = 30 Hz when the note has none
~ce.thinHpf = { |self, in, own, thinF, qDb = 1|
	var f = Lag.kr(thinF, 0.02), base = Select.kr(own > 0, [30, own]);
	var cut = Select.kr(f > 1, [base, (base * f).min(5000).max(base)]);
	var mix = ((f - 1) / 0.02).clip(0, 1).max(own > 0);
	XFade2.ar(in, self.hpf(in, cut, self.rq(qDb)), mix * 2 - 1)
};
);

// The effect chain of a superdough voice, in superdough's order: low-pass → high-pass (with Thin) → band-pass → pan.
// sig: [left, right] (a mono voice passes [x, x] with stereoIn 0). c: the voice's controls (see sounds/sdSample.scd).
(
~ce.sdFx = { |self, sig, c|
	var cut = self.cutoff(c.bright, c.lo, c.hi, c.tone) * c.cutMul;
	sig = Select.ar(c.lpOn > 0, [sig, self.lpf(sig, cut, self.rq(c.lpq))]);
	sig = self.thinHpf(sig, c.hp, c.thinF, c.hpq);
	sig = Select.ar(c.bp > 0, [sig, self.bpf(sig, c.bp.max(10), c.bpq)]);
	Select.ar(c.pan >= 0, [sig, self.webPan(sig, c.pan, c.stereoIn)])
};
// controls every sd voice has (name → default), and their library description
~ce.sdControls = (lpOn: 0, bright: 0, lo: 1000, hi: 1000, tone: 1, cutMul: 1, lpq: 1, hp: 0, thinF: 1, hpq: 1,
	bp: 0, bpq: 1, pan: -1, stereoIn: 0, a: 0.001, d: 0.001, s: 1, r: 0.01);
~ce.sdParams = { |self, more|
	(
		bright: (default: 0, spec: [0, 1], label: "Brightness", about: "low-pass: 0..1 over lo..hi (exponential)"),
		lo: (default: 1000, spec: [80, 18000, \exp], label: "Low-pass min", about: "cutoff at brightness 0"),
		hi: (default: 1000, spec: [80, 18000, \exp], label: "Low-pass max", about: "cutoff at brightness 1"),
		tone: (default: 1, spec: [0.05, 2.5, \exp], label: "Tone", about: "global factor (Fog, Tension)"),
		thinF: (default: 1, spec: [1, 17], label: "Thin", about: "global factor on the high-pass"),
		pan: (default: -1, spec: [-1, 1], label: "Pan", about: "0..1 as Strudel; -1 = no panner"),
	) ++ (more ? ())
};
);

// Soundfont zones (sc/samples/gm/<preset>/zones.json, from tools/sc-port/soundfont-extract.py): the files a track
// loads, and the zone of a note as the fontloader finds it (the first with keyRangeLow ≤ note ≤ keyRangeHigh + 1)
(
~ce.fontZones = { |self, preset|
	self.fontCache = self.fontCache ? ();
	self.fontCache[preset.asSymbol] ?? {
		var z = File.readAllString(self.root +/+ "samples" +/+ "gm" +/+ preset +/+ "zones.json").parseJSON.collect { |x|
			var n = { |k| x[k].asFloat };
			(lo: n.("keyRangeLow"), hi: n.("keyRangeHigh"), base: n.("originalPitch") - (100 * n.("coarseTune")) - n.("fineTune"),
				loopStart: n.("loopStart") / n.("sampleRate"), loopEnd: n.("loopEnd") / n.("sampleRate"),
				loop: (n.("loopStart") > 1) and: { n.("loopStart") < n.("loopEnd") }, file: x["file"]) };
		self.fontCache[preset.asSymbol] = z; z }
};
~ce.fontFiles = { |self, preset| self.fontZones(preset).collect(_[\file]).reject(_.isNil) };
// args of an sdFont note: buffer, rate, loop (nil if the zone has no sample)
~ce.fontNote = { |self, preset, note|
	var z = self.fontZones(preset).detect { |x| x[\lo] <= note and: { (x[\hi] + 1) >= note } };
	if(z.isNil or: { z[\file].isNil }) { nil } {
		(buf: self.sampleBuffers[z[\file]], stereoIn: 0, rate: 2 ** (((100 * note) - z[\base]) / 1200),
			loopOn: z[\loop].binaryValue, loopStart: z[\loopStart], loopEnd: z[\loopEnd]) }
};
);
