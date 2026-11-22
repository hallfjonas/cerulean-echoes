// Helpers for stem code files (sc/stems/*/*.scd): the Strudel semantics and chord helpers of the lab columns ported in
// 009-house, shared so a stem never copies them. Chords are the frame's (~ce.chordOf): bass, tones, scale (pitch
// classes, in the frame's order).
(
// Strudel's swingBy(x, 8) for an onset p in 16ths: an onset in the first half of an 8th stays; one in the second half
// comes x of a 16th later and is lost if that pushes it past the 8th; one just before the middle (within x) plays twice
~ce.swingAt = { |self, p, x = 0.12| var u = p % 2;
	if(u < 1) { if((u + x) >= 1) { [0, x] } { [0] } } { if((u + x) < 2) { [x] } { [] } } };
// the labs' channel strip: room from 0.35 of Space, the 1/8 echo first (full at half the knob)
~ce.labRoom = { |self, sp| 0.8 * ((sp - 0.35) / 0.65).max(0) };
~ce.labEcho = { |self, sp| if(sp > 0) { (0.4 + (1.2 * sp)).min(1) } { 0 } };
// a mini-notation string as a table: 16th of the period → [[offset in the 16th, length in 16ths, value]]
~ce.miniTable = { |self, str| var m = self.mini(str), t = Dictionary[];
	m.events.do { |e| var p = e[0] * 16, k = p.floor.asInteger; t[k] = (t[k] ? []).add([p - k, e[1] * 16, e[2]]) };
	(period: m.period * 16, steps: t) };
// pitch classes of a chord (bass and tones)
~ce.chordPcs = { |self, c| ([c[\bass] % 12] ++ c[\tones].collect { |m| m % 12 }).asSet.asArray };
// n steps of the scale sc (pitch classes) from MIDI note m (n < 0: down)
~ce.scaleSteps = { |self, m, sc, n| var x = m, d = n.sign;
	n.abs.do { x = x + d; while { sc.includes(x % 12).not } { x = x + d } }; x };
// the n chord notes below top (within an octave), highest first
~ce.chordBelow = { |self, c, top, n| var p = self.chordPcs(c), o = List[];
	(top - 1, top - 2 .. top - 12).do { |m| if(o.size < n and: { p.includes(m % 12) }) { o.add(m) } }; o };
// the chord note in lo..hi closest to target (the lowest on a tie)
~ce.chordNear = { |self, c, lo, hi, target| var p = self.chordPcs(c), best = lo;
	(lo..hi).do { |m| if(p.includes(m % 12) and: { (m - target).abs < (best - target).abs }) { best = m } }; best };
// a sample map's closest key (the first in the map's order on a tie): [key MIDI, file]
~ce.closestKey = { |self, keys, note| keys[keys.minIndex { |kk, i| (kk[0] - note).abs + (i * 1e-6) }] };
// the lift of a button held in st (st.lift, st.held): up over 2 bars while held, down over 1 bar after; the notes of
// 16th k hear the lift up to 16th k − 1 (Strudel: the tap that moves it is queried after the stems)
~ce.liftStep = { |self, st, k| var was = st[\lift];
	if(st[\lastK].notNil) {
		st[\lift] = if(st[\lastHeld]) { (st[\lift] + (1 / 32)).min(1) } { (st[\lift] - (1 / 16)).max(0) } };
	st[\lastK] = k; st[\lastHeld] = st[\held];
	if(st[\lift] != was and: { k % 4 == 0 or: { st[\lift] == 0 } or: { st[\lift] == 1 } }) { self.uiPush };
	st[\lift] };

// The note helpers of the groove tracks' column code (001, 002 and their relatives): a synth, a sample or a noise note as
// the sd sounds take them, with the log tags (tag, g, midi) the event comparison reads. Made once per column after the
// server set-up (the buses exist): ~ce.kitOf(col) makes it on the first call and keeps it in the column's state.
~ce.kitOf = { |self, col| col[\st][\kit] ?? { var kit = self.grooveKit; col[\st][\kit] = kit; kit } };
~ce.grooveKit = { |self|
	var ce = self, synthDef = [0.001, 0.05, 0.6, 0.01], waves = (sine: 0, triangle: 1, sawtooth: 2, square: 3);
	var thin = ("c" ++ ce.thinBus).asSymbol;
	var adsr = { |a, d, s, r, def| var v = ce.sdADSR(a, d, s, r, def); (a: v[0], d: v[1], s: v[2], r: v[3]) };
	(
		tone: ("c" ++ ce.toneBus).asSymbol, fog: ("c" ++ ce.fogBus).asSymbol, thin: thin, adsr: adsr,
		syn: { |wave, m, g, args| ce.note(\sdSynthMod, (wave: waves[wave], freq: m.midicps, amp: g, thinF: thin,
			tag: wave.asString, g: g, midi: m) ++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) },
		smp: { |rel, tag, g, args, sound = \sdSample| ce.note(sound, (buf: ce.sampleBuffers[rel],
			stereoIn: (ce.sampleMono[rel] != true).asInteger, amp: g, hold: -1, thinF: thin, tag: tag, g: g)
			++ adsr.(nil, nil, nil, nil) ++ (args ? ())) },
		noise: { |color, g, args| ce.note(\sdNoise, (color: color, amp: g, thinF: thin, tag: ["pink", "white"][color], g: g)
			++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) },
		dB: { |x| 10 ** (x / 20) },
		ramp: { |v, from, to| ((v - from) / (to - from)).clip(0, 1) },
		// a mini-notation string as a table: 16th of the period -> [[offset in the 16th, length in 16ths, value]]
		table: { |str| var m = ce.mini(str), t = Dictionary[];
			m.events.do { |e| var p = e[0] * 16, k = (p + 1e-6).floor.asInteger; t[k] = (t[k] ? []).add([p - k, e[1] * 16, e[2]]) };
			(period: (m.period * 16).round.asInteger, steps: t) },
		eventsAt: { |tb, k| tb.steps[k % tb.period] ? [] },
		// Strudel's swingBy(x, 8) for one onset (pos in 16ths): an event in the second half of its 8th comes x later
		swingAt: { |pos, x| if(((pos / 2) % 1) >= (0.5 - 1e-6)) { x } { 0 } },
		name2midi: { |nm| var m = nm.findRegexp("^([a-g])(b|#)?(-?[0-9])$");
			(12 * (m[3][1].asInteger + 1)) + (c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11)[m[1][1].asSymbol]
			+ (m[2][1] == "#").binaryValue - (m[2][1] == "b").binaryValue },
		// a step line as Strudel writes it ("~ 0 ~ 7 ...") -> [degree or nil per step]
		line: { |str| str.split($ ).reject(_.isEmpty).collect { |x| if(x == "~") { nil } { x.asFloat } } },
		// straight lines through three values: soft at 0, round at 0.5, hard at 1
		punch3: { |p, soft, round, hard| if(p < 0.5) { soft + ((round - soft) * 2 * p) } { round + ((hard - round) * ((2 * p) - 1)) } },
		// the FM modulator's start phase: offline as superdough's render has it (started at time 0), live random
		modPhase: { |k, at, freq, bpm| if(ce.webaudioPhase == true) { (2pi * freq * ((k + at) / 4 / (bpm / 60))) % 2pi } { -1 } },
		// 0 -> 1 over `bars` while the column's button 2 is held (steps per bar); nil while it is not held
		heldRamp: { |col, bars| var st = ();
			{ |t| if(col.held(\b2)) { st[\from] = st[\from] ? t.floor; ((t.floor - st[\from]) / bars).clip(0, 1) }
				{ st[\from] = nil; nil } } }
	)
};

// The note helpers of the ambient house track's column code (010): the groove kit with the sound a synth note plays, a sample
// note on sdSampleMod, a pink noise note, the pitch-envelope arguments, the VCSL glockenspiel, step lines with held notes,
// and the track's tone map (Fog x Tension squared). ~ce.ambientOf(col) makes it once per column.
~ce.ambientFx = (
	// layer -> [echo (nil: dry), space function (nil: the knob itself)], as Strudel's bus / dryBus
	layers: (kick: [nil], noise: [0.15], riser: [0, { 0.3 }], sub: [nil], bass: [nil], clap: [0.2], hats: [0.2], perc: [0.3],
		pad: [0.15], keys: [0.4], keys2: [0.3], arp: [0.35, { |s| 0.3 + (0.7 * s) }], lead: [0.3, { |s| 0.25 + (0.75 * s) }],
		ans: [0.45, { |s| 0.35 + (0.65 * s) }], bells: [0.5], run: [0.4], birds: [0.3, { |s| 0.3 + (0.7 * s) }],
		birds2: [0.5, { |s| 0.3 + (0.7 * s) }], birds3: [0.4, { |s| 0.3 + (0.7 * s) }]),
	// start values of the room and echo states of the layers `names`
	startStates: { |fx, names| var out = ();
		names.do { |k| var e = fx.layers[k][0], f = fx.layers[k][1] ? { |s| s }, s0 = f.(0);
			out[(k ++ "Room").asSymbol] = 0.9 * s0;
			e !? { out[(k ++ "Echo").asSymbol] = (e * 2 * s0).min(0.9) } };
		out },
	// room = 0.9 x space raised by Tension x 0.5 towards 0.95; echo = max(min(0.9, echo x 2 x space), Tension's echo 0 -> 0.4
	// over 0 ... 0.7); the echo throw (button 2 held): 0.85. space: the column's Space knob moves it (else a fixed layer)
	apply: { |fx, col, send, name, space = true, throw = false|
		var ce = col[\ce], e = fx.layers[name][0], f = fx.layers[name][1] ? { |s| s };
		var s = f.(if(space) { col.knob(\k2) } { 0 }), t = ce.val(ce.stemGlobal.tension), r = 0.9 * s;
		col.setState((name ++ "Room").asSymbol, r + ((0.95 - r) * 0.5 * t), send);
		e !? { var d = (e * 2 * s).min(0.9).max(((t / 0.7).clip(0, 1)) * 0.4);
			if(throw and: { col.held(\b2) }) { d = 0.85 };
			col.setState((name ++ "Echo").asSymbol, d, send) } }
);
~ce.ambientKit = { |self|
	var ce = self, kit = self.grooveKit, thin = kit[\thin], adsr = kit[\adsr], synthDef = [0.001, 0.05, 0.6, 0.01];
	var waves = (sine: 0, triangle: 1, sawtooth: 2, square: 3), glockKeys = [[72, "glock_soft_C5_02"], [84, "glock_soft_C6_01"],
		[96, "glock_soft_C7_03"], [92, "glock_loud_G#6_01"], [67, "glock_soft_G4_01"], [79, "glock_soft_G5_01"], [91, "glock_soft_G6_01"]];
	var out = kit.copy;
	out[\tone] = ("c" ++ ce.mapBus[\tone]).asSymbol;
	out[\syn] = { |wave, m, g, args, sound = \sdSynthMod| ce.note(sound, (wave: waves[wave], freq: m.midicps, amp: g, thinF: thin,
		tag: wave.asString, g: g, midi: m) ++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	out[\smp] = { |rel, tag, g, args| ce.note(\sdSampleMod, (buf: ce.sampleBuffers[rel], stereoIn: (ce.sampleMono[rel] != true).asInteger,
		amp: g, hold: -1, thinF: thin, tag: tag, g: g) ++ adsr.(nil, nil, nil, nil) ++ (args ? ())) };
	out[\noise] = { |g, args| ce.note(\sdNoise, (color: 0, amp: g, thinF: thin, tag: "pink", g: g) ++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	out[\padsr] = { |a, d, s, r| var v = ce.sdADSR(a, d, s, r, [0.2, 0.001, 1, 0.001]); (pa: v[0], pd: v[1], ps: v[2], pr: v[3]) };
	out[\glock] = { |m, g, args| var best = glockKeys.inject(nil, { |b, x| if(b.isNil or: { (x[0] - m).abs < (b[0] - m).abs }) { x } { b } });
		out[\smp].("vcsl/glockenspiel/" ++ best[1] ++ ".flac", "glockenspiel", g, (rate: 2 ** ((m - best[0]) / 12), midi: m, hold: 1)
			++ adsr.(nil, nil, nil, 1.2) ++ args) };
	// a step line ("~ 0 ~ 7 ...", brackets of a 16-step bar removed) -> [value or nil per step]
	out[\line] = { |str| str.replace("[", " ").replace("]", " ").split($ ).reject(_.isEmpty).collect { |x| if(x == "~") { nil } { x.asFloat } } };
	// a line with "_" (elongation) -> [16th -> [degree, length in 16ths]]
	out[\longLine] = { |str| var t = str.split($ ).reject(_.isEmpty), d = Dictionary.new;
		t.do { |x, i| if(x != "~" and: { x != "_" }) { var n = 1; while { (i + n) < t.size and: { t[i + n] == "_" } } { n = n + 1 }; d[i] = [x.asFloat, n] } };
		d };
	out
};
~ce.ambientOf = { |self, col| col[\st][\akit] ?? { var kit = self.ambientKit; col[\st][\akit] = kit; kit } };

// The note helpers of the ambient mood track's column code (007): synth, sample and noise notes with superdough's default
// envelopes, VCSL pitch picking, the FM modulator phase, ~ce.moodOf(col) makes them once per column. ~ce.moodFx sets the echo
// and room send states of a column's layer (Strudel bus(): max(min(0.9, echo x 2 x space), Tension's echo)).
~ce.vcslMaps = (
	vibraphone_bowed: [[45, "A2"], [69, "A4"], [62, "D4"], [52, "E3"], [76, "E5"], [55, "G3"]],
	xylophone_soft_ff: [[60, "C4"], [72, "C5"], [84, "C6"], [96, "C7"], [55, "G3"], [67, "G4"], [79, "G5"], [91, "G6"]],
	glockenspiel: [[72, "C5"], [84, "C6"], [96, "C7"], [92, "G#6"], [67, "G4"], [79, "G5"], [91, "G6"]]);
~ce.vcslFileOf = (
	vibraphone_bowed: { |k| "vcsl/vibraphone_bowed/Vibes_bowed_" ++ k ++ "_rr1_Main.flac" },
	xylophone_soft_ff: { |k| "vcsl/xylophone_soft_ff/Xylo_Soft_" ++ k ++ "_ff_01_far.flac" },
	glockenspiel: { |k| "vcsl/glockenspiel/" ++ Dictionary["C5" -> "glock_soft_C5_02", "C6" -> "glock_soft_C6_01",
		"C7" -> "glock_soft_C7_03", "G#6" -> "glock_loud_G#6_01", "G4" -> "glock_soft_G4_01", "G5" -> "glock_soft_G5_01",
		"G6" -> "glock_soft_G6_01"][k] ++ ".flac" });
// the nearest VCSL key to MIDI note m (the first on a tie): [file, playback rate]
~ce.vcslPickOf = { |self, name, m| var best = self.vcslMaps[name].inject(nil, { |b, x| if(b.isNil or: { (x[0] - m).abs < (b[0] - m).abs }) { x } { b } });
	[self.vcslFileOf[name].(best[1]), 2 ** ((m - best[0]) / 12)] };
~ce.vcslFiles = { |self| self.vcslMaps.keys.asArray.collect { |nm| self.vcslMaps[nm].collect { |x| self.vcslFileOf[nm].(x[1]) } }.flatten };
~ce.moodFx = (
	tensionCC: 36,
	fadeMain: { |fx, k| (2 * (1 - k)).clip(0, 1) },
	fadeExtra: { |fx, k| (2 * k).clip(0, 1) },
	echoSend: { |fx, col, send, state, amount, lab = false, throw = false, tensionEcho = true|
		var ce = col[\ce], s = col.knob(\k2), space = if(lab) { 0.25 + (0.75 * s) } { s };
		var d = (amount * 2 * space).min(0.9).max(if(tensionEcho) { ((ce.val(fx.tensionCC) / 0.5).clip(0, 1)) * 0.5 } { 0 });
		if(throw and: { col.held(\b2) }) { d = d.max(0.65) };
		col.setState(state, d, send) },
	roomSend: { |fx, col, send, state| col.setState(state, 0.9 * (0.25 + (0.75 * col.knob(\k2))), send) },
	tensionHook: { |fx, col, ce| ce.onCC(fx.tensionCC, { |v, send| col.refreshStates(send) }) }
);
~ce.moodKit = { |self, col|
	var ce = self, synthDef = [0.001, 0.05, 0.6, 0.01], bpm = col[\track].bpm;
	var waves = (sine: 0, triangle: 1, sawtooth: 2, square: 3), kit = ();
	var adsr = { |a, d, s, r, def| var v = ce.sdADSR(a, d, s, r, def); (a: v[0], d: v[1], s: v[2], r: v[3]) };
	kit[\tone] = ("c" ++ ce.mapBus[\tone]).asSymbol;
	kit[\fog] = ("c" ++ ce.fogBus).asSymbol;
	kit[\wob] = ("c" ++ ce.mapBus[\wobble]).asSymbol;
	kit[\adsr] = adsr;
	kit[\padsr] = { |a, d, s, r| var v = ce.sdADSR(a, d, s, r, [0.2, 0.001, 1, 0.001]); (pa: v[0], pd: v[1], ps: v[2], pr: v[3]) };
	kit[\syn] = { |wave, m, g, args, sound = \sdSynthMod| ce.note(sound, (wave: waves[wave], freq: m.midicps, amp: g,
		tag: wave.asString, g: g, midi: m) ++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	kit[\smp] = { |rel, tag, g, args, sound = \sdSampleMod| ce.note(sound, (buf: ce.sampleBuffers[rel],
		stereoIn: (ce.sampleMono[rel] != true).asInteger, amp: g, hold: -1, tag: tag, g: g) ++ adsr.(nil, nil, nil, nil) ++ (args ? ())) };
	kit[\noise] = { |color, g, args| ce.note(\sdNoise, (color: color, amp: g, tag: ["pink", "white", "brown"][color], g: g)
		++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	kit[\modPhase] = { |k, at, freq| if(ce.webaudioPhase == true) { (2pi * freq * ((k + at) / 4 / (bpm / 60))) % 2pi } { -1 } };
	kit[\seed] = { |latch, b| 1024 * latch.atBar(b) };
	kit[\vcslPick] = { |name, m| ce.vcslPickOf(name, m) };
	kit[\ramp] = { |v, from, to| ((v - from) / (to - from)).clip(0, 1) };
	kit[\fadeMain] = { |k| ~ce.moodFx.fadeMain(k) };
	kit[\fadeExtra] = { |k| ~ce.moodFx.fadeExtra(k) };
	kit[\toks] = { |str| str.split($ ).reject(_.isEmpty) };
	kit[\num] = { |x| if(x == "~") { nil } { x.asFloat } };
	kit[\ccMap] = { |kk| ce.ccMap(col[\ccs][kk]) };
	kit
};
~ce.moodOf = { |self, col| col[\st][\mkit] ?? { var kit = self.moodKit(col); col[\st][\mkit] = kit; kit } };

// The figure machinery of the marimba and tom columns (007; lab/harmony/midori-5): a layer = a figure of scale degrees (nil =
// rest), one per step (16 / 12 / 8 steps per bar), cycling over its own length regardless of the bar, first note accented.
~ce.figureKit = { |self|
	var kit = (), toks = { |str| str.split($ ).reject(_.isEmpty) }, num = { |x| if(x == "~") { nil } { x.asFloat } };
	var md = { |a, n| ((a % n) + n) % n };
	kit[\md] = md;
	kit[\toks] = toks;
	kit[\layer] = { |fig, oct = 1, pan = 0.5, g = 0.5, steps = 16|
		var t = if(fig.isString) { toks.(fig).collect(num) } { fig }, f = t.detectIndex(_.notNil);
		(fig: t, vel: t.collect { |x, j| if(j == f) { 1 } { 0.6 } }, oct: oct, pan: pan, g: g, steps: steps, late: 0) };
	kit[\padTo] = { |fig, n| var t = toks.(fig); (t ++ ("~" ! (n - t.size).max(0))).join(" ") };
	kit[\shift] = { |fig, sh| toks.(fig).collect { |x| if(x == "~") { x } { (x.asFloat + sh).asInteger.asString } }.join(" ") };
	kit[\euclid] = { |hits, n, notes, rot = 0| var j = 0;
		n.collect { |k| if(((md.(k + rot, n) * hits) % n) < hits) { var x = notes[j % notes.size]; j = j + 1; x.asString } { "~" } }.join(" ") };
	// the notes of a layer in [t0, t1): its steps j at j / steps + late (late: bars, or a function of the bar)
	kit[\hits] = { |ly, t0, b, extra| var lt = ly[\late].value(b), ns = ly[\steps], t1 = t0 + (1/16), out = List[], j, tb;
		j = (((t0 - lt) * ns) - 1e-7).ceil;
		while { tb = (j / ns) + lt; tb < (t1 - 1e-7) } {
			var i = md.(j, ly[\fig].size), d = ly[\fig][i];
			if(d.notNil and: { ly[\vel][i] > 0 }) { out.add((deg: d, vel: ly[\vel][i], at: (tb - t0) * 16, u: tb - lt) ++ (extra ? ())) };
			j = j + 1 };
		out };
	kit
};
)
