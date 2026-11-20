// Launchkey keys as the Strudel tracks 008, 009 and 010 play them ("keys play the sounds of Jonas' keys in 009"):
// six sounds in three pairs on knobs 2-4 — piano → Rhodes, organ B3 → M1, vibraphone → marimba. A pair knob in
// thirds: 0 off, A fades in, A blends into B (equal power, an optional dip in dB in the middle), B fades out. Every
// key plays each sound that is on, through its own low-pass (knob 1 over the sound's range, a harder key opens it up
// to an octave), release 0.5 s, gain × 2 (LK_KEYS_GAIN). Loaded by the tracks that use it (not by ce.scd).
// ~ce.lkKeysNotes(note, vel, mix, args): mix = the three pair knobs (0..1); args: hold (16ths), lane, tone (bus symbol),
// bright (bus symbol or number: knob 1), thinF … — merged into every note. Brightness is a bus: it acts on sounding keys.
(
// a pair knob → [level A, level B]
~ce.lkPair = { |self, v, dip = 0|
	var lvl = if(v < (1/3)) { 3 * v } { if(v > (2/3)) { 3 - (3 * v) } { 1 } };
	var c = if(v < (1/3)) { 0 } { if(v > (2/3)) { 1 } { (3 * v) - 1 } };
	var d = 10 ** (dip.neg * sin(pi * c) / 20);
	[cos(c * pi / 2), sin(c * pi / 2)].collect { |x| if(x < 1e-6) { 0 } { lvl * x * d } }
};
// the samples (nearest key, the first on a tie), as the Strudel tracks map them
~ce.lkKeysMaps = (
	stein: [[54, "F#3"], [56, "G#3"], [58, "A#3"], [60, "C4"], [62, "D4"], [64, "E4"]].collect { |x|
		[x[0], "repo:vcsl-keys/JHPiano_Sus_Close_" ++ x[1] ++ "_vl3_rr1.flac"] },
	jrh: [[55, "A_055__G3"], [59, "A_059__B3"], [62, "A_062__D4"], [65, "A_065__F4"]].collect { |x| [x[0], "jrhodes/" ++ x[1] ++ "_3.flac"] });
~ce.lkKeysFiles = ~ce.lkKeysMaps.values.collect { |m| m.collect(_[1]) }.flatten
	++ ~ce.fontFiles("0110_JCLive_sf2_file") ++ ~ce.fontFiles("0120_JCLive_sf2_file");
~ce.lkKeysSounds = [\sdSampleMod, \sdSynthMod, \sdFont];
~ce.lkKeysNotes = { |self, note, vel, mix, args|
	var lv = self.lkPair(mix[0], -1.3) ++ self.lkPair(mix[1], 1.3) ++ self.lkPair(mix[2]);
	var touch = 2 ** (2 * (vel - 0.5)), out = List[];
	var adsr = { |a, d, s, r| var v = self.sdADSR(a, d, s, r ? 0.5, [0.001, 0.05, 0.6, 0.01]); (a: v[0], d: v[1], s: v[2], r: v[3]) };
	var lp = { |lo, hi| (lpOn: 1, lo: lo * touch, hi: hi * touch) };
	var smp = { |map, g, lo, hi| var m = note, k = self.lkKeysMaps[map].inject(nil, { |b, x| if(b.isNil or: { (x[0] - m).abs < (b[0] - m).abs }) { x } { b } });
		self.note(\sdSampleMod, (buf: self.sampleBuffers[k[1]], stereoIn: (self.sampleMono[k[1]] != true).asInteger, rate: 2 ** ((m - k[0]) / 12),
			amp: g * vel, tag: map.asString, g: g * vel, midi: m, a: 0.001, d: 0.001, s: 1, r: 0.5) ++ args ++ lp.(lo, hi)) };
	var syn = { |wave, m, g, env, lo, hi, more| self.note(\sdSynthMod, (wave: [\sine, \triangle, \sawtooth, \square].indexOf(wave), freq: m.midicps,
		amp: g * vel, tag: wave.asString, g: g * vel, midi: m) ++ env ++ args ++ lp.(lo, hi) ++ (more ? ())) };
	var font = { |preset, tag, m, g, lo, hi| var z = self.fontNote(preset, m);
		z !? { self.note(\sdFont, z ++ (amp: g * vel, tag: tag, g: g * vel, midi: m, a: 0.001, d: 0.001, s: 1, r: 0.5) ++ args ++ lp.(lo, hi)) } };
	var gk = 2;   // LK_KEYS_GAIN
	if(lv[0] > 0) { out.add(smp.(\stein, 0.6 * 0.49 / 0.955 * 0.99 * lv[0] * gk, 250, 8100)) };
	if(lv[1] > 0) { out.add(smp.(\jrh, 0.6 * 0.292 / 0.955 * 0.902 * lv[1] * gk, 250, 2000)) };
	// organ B3: sines on the root, a 12th and an octave above, each a little sharp and flat (left / right), vibrato
	if(lv[2] > 0) { [0, 19, 12].do { |d, j| [-0.04, 0.04].do { |dt, side|
		out.add(syn.(\sine, note + d + dt, [0.12, 0.07, 0.1][j] * 1.82 * 0.85 * lv[2] * gk, adsr.(0.004), 250, 2000,
			(vib: 0.8, vibmod: 0.08, pan: if(side == 1) { 0.7 } { 0.3 }))) } } };
	// M1 organ: a square an octave up, sines two octaves up and a 19th up (a short click)
	if(lv[3] > 0) {
		out.add(syn.(\square, note + 12, 0.22 * 0.42 * 1.85 * lv[3] * gk, adsr.(0.002, 0.25, 0.7), 250, 5000));
		out.add(syn.(\sine, note + 24, 0.18 * 0.42 * 1.85 * lv[3] * gk, adsr.(0.002, 0.25, 0.7), 250, 5000));
		out.add(syn.(\sine, note + 31, 0.25 * 0.42 * 1.85 * lv[3] * gk, adsr.(0.001, 0.08, 0), 250, 5000));
	};
	if(lv[4] > 0) { out.add(font.("0110_JCLive_sf2_file", "gm_vibraphone", note - 12, 0.65 * 0.91 * lv[4] * gk, 250, 4000)) };
	if(lv[5] > 0) { out.add(font.("0120_JCLive_sf2_file", "gm_marimba", note, 0.7 * 1.38 * lv[5] * gk, 250, 3000)) };
	out.reject(_.isNil).asArray
};
)
