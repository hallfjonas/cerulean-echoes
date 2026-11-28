// Stems: a .stem file (sc/stems/<sample>/<name>.stem, format in docs/features/stems.md) becomes one LC column on any
// slot of a stem track (stemtrack.scd). A column makes its notes per 16th for the step engine (steps.scd):
//   hits      the pattern of button 1 (mini-notation, one cycle = one bar): Events (at, dur in 16ths, t = cycle time,
//             note, vel); a stem "code" file makes them instead
//   add-on    button 2 (addons.scd) changes the hits, the knob values, the length, the pitch, or adds notes
//   notes     every hit → a note of the sample: pitch from the frame's chord, knob parameters on state buses (they act
//             at once, also on sounding notes), `hold` and `amp` read at the note's start, swing on the off 16ths
// Knob values: space → the strip's room send (0.9 × space), echo → its echo send; hold (seconds) → note length.
// Gated: a column whose fader or the master is at 0, or that sits out the Break, makes no hits at all.
// Code hatch (files next to the stem, each returns a Function):
//   stem code   { |col, k| hits }               the hits of 16th k (col[\patLatch], col.knob(\k3), col.chordAt(bar))
//   knob code   { |v, col| (param: value, …) }  merged into every note from the next note on (v = the knob 0..1)
//   b1 code     { |col| }                       called on each press instead of "next pattern at the next bar"
//   b2 code     returns an add-on Event (see addons.scd)
// Column code: a stem code file may return an Event instead of a Function, for a column JSON cannot describe at all
// (009's lab columns). It plays finished notes and owns its controls; every key is optional except notes:
//   notes: { |col, k| notes }      the notes (~ce.note Events, `\lane`, `\hold` in 16ths) and control messages of 16th k
//   start: { |col, ce| }           after the server set-up: latches, own hooks (col.st holds the column's state)
//   update: { |col, send| }        on every move of a knob, the fader or button 2: set the column's state buses
//   b1: { |col| }                  button 1 instead of "next pattern at the next bar"
//   keys: { |col, note, vel| }    a Launchkey key on this column (the frame's lkKeys, stemtrack.scd): its notes
//   gate: false                    asked at fader 0 too (state that moves every 16th: lifts, look-ahead)
//   states: (name: start value)    the column's state buses (col.setState, col.stateMapOf)
//   maps: (name: (ccs: [\k1 …], fn: { |v …| ugen }))   server-side values of the column's controls (col.mapBusOf)
//   strip: (orbit, ownDelay, level, roomR, echoSend, space, echo, trim, lanes)   the column's strip; a Symbol names one
//          of its states, maps or controls (\k2 = its knob 2 CC)
// The sample's `extra` sounds (stem file) are the further sounds the code plays.
(
// JSON → Events with Symbol keys. sclang's parseJSON keeps every scalar a String: numbers are read where used.
~ce.jsonEvent = { |self, x|
	case
	{ x.isKindOf(Dictionary) } { var e = (); x.keysValuesDo { |k, v| e[k.asSymbol] = self.jsonEvent(v) }; e }
	{ x.isKindOf(Array) } { x.collect { |v| self.jsonEvent(v) } }
	{ x }
};
~ce.readJSON = { |self, path| self.jsonEvent(File.readAllString(path).parseJSON) };
~ce.numOf = { |self, x| if(x.isString) { x.asFloat } { x } };

// ref "draft:<id>": a stem inside a Stem Designer project (self.stemDrafts, stemlab.scd); its code files lie next to
// its parent stem, else next to the project
~ce.loadStem = { |self, ref|
	var path = self.root +/+ "stems" +/+ ref, stem;
	if(ref.beginsWith("draft:")) {
		stem = self.stemDrafts[ref.drop(6).asSymbol].deepCopy;
		stem[\dir] = stem[\parent] !? { |p| (self.root +/+ "stems" +/+ p).dirname } ? (self.root +/+ "lab" +/+ "stems")
	} {
		stem = self.readJSON(path);
		stem[\dir] = path.dirname
	};
	stem[\ref] = ref;
	stem
};

// The CCs of a slot ('1:4' = Mode 1 column 4, '2:1' = Mode 2 column 1; Mode 2 = CC + 48)
// A slot 'b:n' (a Stem Designer's backing stem) has CCs above 127 that no controller sends: it plays as it is.
~ce.slotCCs = { |self, slot|
	var s = slot.asString, n = s[2].digit, plus = case { s[0] == $2 } { 48 } { s[0] == $b } { 152 } { 0 };
	(k1: 12 + n + plus, k2: 20 + n + plus, k3: 28 + n + plus, fader: 4 + n + plus, b1: 36 + n + plus, b2: 44 + n + plus)
};

~ce.lowRoles = [\kick, \perc, \hats, \clap, \sub, \bass];

~ce.stemColumn = { |self, stem, slot, track|
	var ce = self, controls = stem[\controls], b2 = controls[\b2], frame = stem[\frame] ? ();
	var opt = { |k| frame[k] != "false" };
	var sample = stem[\sample][\name].asSymbol, snd = self.sounds[sample] ?? { self.loadSound(sample) };
	var inputs = snd.def.allControlNames.collect(_.name);
	var addon = b2[\addon] !? { |id| self.addons[id.asSymbol] } ?? { b2[\code] !? { |c| (stem[\dir] +/+ c).load } } ? ();
	var stemName = ("s" ++ slot.asString.replace(":", "_")).asSymbol;
	var targets = (), knobCode = (), preset = (), args = ();
	var mini = { |str| str !? { self.mini(str.asString) } };
	var code = stem[\code] !? { |c| (stem[\dir] +/+ c).load }, colCode = if(code.isKindOf(Event)) { code };
	var extra = (stem[\sample][\extra] ? []).collect(_.asSymbol);
	var ccs = self.slotCCs(slot), maps = (), gain = self.numOf(stem[\gain] ? 1), layers, busParams;
	// a column's map named trim is its strip trim: the stem's gain multiplies it
	(colCode !? { |c| c[\maps] } ? ()).keysValuesDo { |name, m|
		maps[(stemName ++ "_" ++ name).asSymbol] = (ccs: m[\ccs].collect { |c| ccs[c] ? c },
			fn: if(name == \trim) { { |...in| m[\fn].valueArray(in) * gain } } { m[\fn] }) };
	(extra ++ (addon[\sounds] ? [])).do { |name| if(self.sounds[name].isNil) { self.loadSound(name) } };
	(stem[\sample][\preset] ? ()).keysValuesDo { |k, v| preset[k] = self.numOf(v) };
	(b2[\args] ? ()).keysValuesDo { |k, v|
		args[k] = if(v.isString and: { "^-?[0-9.]+$".matchRegexp(v) }) { v.asFloat } { v } };
	[\k1, \k2, \k3].do { |kk| var knob = controls[kk];
		var one = { |t| (param: t[\param].asSymbol, lo: self.numOf(t[\range] !? { |r| r[0] } ? 0),
			hi: self.numOf(t[\range] !? { |r| r[1] } ? 1), exp: t[\curve] == "exp",
			points: t[\points] !? { |ps| ps.collect { |pt| pt.collect { |x| self.numOf(x) } } }) };
		case
		{ knob[\param].notNil } { targets[kk] = [one.(knob)] }
		{ knob[\targets].notNil } { targets[kk] = knob[\targets].collect(one) }
		{ knob[\code].notNil } { knobCode[kk] = (stem[\dir] +/+ knob[\code]).load }
	};
	// format 2: a knob on trim is the strip's gain, made on the server from the knob (× the stem's gain)
	targets.keysValuesDo { |kk, list| list.do { |t| if(t[\param] == \trim) {
		maps[(stemName ++ "_trim").asSymbol] = (ccs: [ccs[kk]], fn: { |v|
			if(t[\exp]) { t[\lo] * ((t[\hi] / t[\lo]) ** v) } { t[\lo] + ((t[\hi] - t[\lo]) * v) } * gain }) } } };
	layers = self.stemLayers(stem);
	layers.do { |l| if(l[\sound] != sample and: { extra.includes(l[\sound]).not }) { extra = extra.add(l[\sound]) } };
	busParams = targets.values.flatten(1).collect { |t| t[\param] }.asSet.asArray
		.select { |p| layers.any { |l| l[\inputs].includes(p) } and: { [\hold, \amp].includes(p).not } };
	layers.do { |l| l[\busParams] = busParams.select { |p| l[\inputs].includes(p) } };
	(
		ce: ce, track: track, stem: stem, slot: slot.asSymbol, stemName: stemName, ccs: ccs,
		sample: sample, sounds: [sample] ++ extra ++ (addon[\sounds] ? []), pitch: stem[\pitch].asSymbol,
		colCode: colCode, maps: maps, st: (),
		echoOn: targets.values.flatten(1).any { |t| t[\param] == \echo } or: { addon === self.addons[\echoThrow] }
			or: { stem[\echo].notNil },
		gain: gain, preset: preset, inputs: inputs, hpOwn: snd.hpf,
		orbit: stem[\orbit] !? { |o| self.numOf(o).asInteger } ?? {
			if(self.lowRoles.includes(stem[\meta][\role].asSymbol)) { 1 } { 2 } },
		fog: opt.(\fog), thin: opt.(\thin), tension: opt.(\tension), swing: opt.(\swing), breakOut: frame[\break] == "out",
		tensionFilter: opt.(\tensionFilter), tensionEchoOn: opt.(\tensionEcho),
		targets: targets, knobCode: knobCode,
		overridden: if(colCode.isNil) { [] } { [\k1, \k2, \k3].select { |kk| controls[kk][\override].asString == "true" } },
		holdKnob: targets.values.flatten(1).any { |t| t[\param] == \hold },
		boostOn: targets.values.flatten(1).any { |t| t[\param] == \boost },
		busParams: busParams,
		pats: stem[\patterns].collect { |p| self.stemPart(p) },
		layers: layers,
		kit: stem[\sample][\kit],
		register: stem[\register] !? { |r| self.numOf(r).asInteger },
		push: stem[\push] == "true" or: { stem[\push] == true },
		ungated: layers.any { |l| l[\pats].any { |p| p[\strike].notNil } },
		echoOwn: stem[\echo] !? { |e| [self.numOf(e[\beats] ? 0.75), self.numOf(e[\feedback] ? 0.3)] },
		stemCode: if(colCode.isNil) { code },
		b1Code: controls[\b1][\code] !? { |c| (stem[\dir] +/+ c).load },
		addon: addon, addonMode: b2[\mode].asSymbol, addonState: (args: args, since: nil,
			argNum: { |a, key, default| a[\args][key] ? default }),
		miniCache: (),

		// the sound's thin input does Thin per note (sd voices); else the strip does it
		thinOnStrip: { |col| col[\thin] and: { col[\inputs].includes(\thinF).not } },
		stateName: { |col, param| (col[\stemName] ++ "_" ++ param).asSymbol },
		rawKnob: { |col, kk| col[\ce].val(col[\ccs][kk]) },
		// what column code reads: a knob the designer gave another job ("override") reads as its middle position
		knob: { |col, kk| if(col[\overridden].includes(kk)) { 0.5 } { col.rawKnob(kk) } },
		held: { |col, kk| col[\ce].held(col[\ccs][kk]) },
		chordAt: { |col, bar| col[\track].chordAt(bar) },
		// the chord at 16th k; push: the next bar's chord two 16ths early (the frame's chordAtK, else the bar's chord)
		chordAtK: { |col, k, push = false| col[\track].chordAtK(k, push) },
		// column code: its state buses and maps by short name
		setState: { |col, name, v, send| col[\ce].setState(col.stateName(name), v, send) },
		stateMapOf: { |col, name| col[\ce].stateMap(col.stateName(name)) },
		mapName: { |col, name| (col[\stemName] ++ "_" ++ name).asSymbol },
		mapBusOf: { |col, name| ("c" ++ col[\ce].mapBus[col.mapName(name)]).asSymbol },
		delayNode: { |col| col[\ce].stemDelayNode[col[\stemName]] },
		// Tension's echo send (0 → 0.45 over the first half of the knob), as the strips compute it
		tensionEcho: { |col| (col[\ce].val(col[\track].global.tension) / 0.5).clip(0, 1) * 0.45 },
		// a strip value of column code: a Symbol names one of its states, maps or controls
		stripRef: { |col, x|
			var cc = col[\colCode];
			case
			{ x.isKindOf(Symbol).not } { x }
			{ (cc[\states] ? ()).includesKey(x) } { col.stateName(x) }
			{ (cc[\maps] ? ()).includesKey(x) } { col.mapName(x) }
			{ col[\ccs].includesKey(x) } { col[\ccs][x] }
			{ x }
		},
		// after the server set-up (buses exist), before the first note: latches, the add-on's state, the global inputs.
		// The latches and the hooks column code makes here belong to the column (a swap drops them, ~ce.dropHooks).
		startCol: { |col, ce| ce.owning(col, {
			var names = col[\pats].collect { |p| p[\label] };
			col[\patLatch] = ce.latch(1, 0, { |i| ce.status(col[\slot], names[i]); ce.uiPush });
			if(col[\addonMode] == \step) { col[\b2Latch] = ce.latch(1, 0) };
			col[\layers].do { |l|
				l[\toneArg] = if(col[\fog] and: { l[\inputs].includes(\tone) }) {
					("c" ++ if(col[\tension] and: { col[\tensionFilter] }) { ce.toneBus } { ce.fogBus }).asSymbol };
				l[\thinArg] = if(col[\thin] and: { l[\inputs].includes(\thinF) }) { ("c" ++ ce.thinBus).asSymbol } };
			col[\toneArg] = col[\layers][0][\toneArg];
			col[\thinArg] = col[\layers][0][\thinArg];
			col[\colCode] !? { |c| c[\start] !? { |f| f.(col, ce) } };
		}) },
		// the MIDI panel shows the pattern of button 1 (Mode 1: jojo:<n>, Mode 2: jonas:<n>)
		showRow: { |col| var s = col[\slot].asString;
			col[\ce].uiRows[((if(s[0] == $1) { "jojo:" } { "jonas:" }) ++ s[2]).asSymbol] =
				(latch: col[\patLatch], names: col[\pats].collect { |p| p[\label] }) },
		pressB1: { |col|
			var l = col[\patLatch], frame = col[\track][\frame] ? ();
			var b1 = col[\b1Code] ?? { col[\colCode] !? { |c| c[\b1] } };
			// Chords on a chords stem steps the frame's progressions when the frame has them
			var chords = (col[\stem][\controls][\b1][\label] == "Chords") and: { frame[\nextChords].notNil };
			case
			{ b1.notNil } { b1.(col) }
			{ chords } { frame[\nextChords].(frame, col[\track]) }
			{
				l.pending = (l.pending + 1) % col[\pats].size;
				col[\ce].status(col[\slot].asString ++ " (next)", col[\pats][l.pending][\label]) }
		},
		// button 2: toggle and step act on the press; every change refreshes the knob values (the add-on may change them)
		b2Change: { |col, v, send|
			if(v > 0.5 and: { (col[\b2Prev] ? 0) <= 0.5 }) {
				switch(col[\addonMode],
					\toggle, { col[\toggleOn] = col[\toggleOn] != true },
					\step, { col[\b2Latch].pending = (col[\b2Latch].pending + 1) % (col[\addonState].argNum(\states, 2)) })
			};
			col[\b2Prev] = v;
			col.refreshStates(send)
		},
		addonOn: { |col, bar|
			switch(col[\addonMode],
				\hold, { col[\ce].held(col[\ccs][\b2]) },
				\toggle, { col[\toggleOn] == true },
				\step, { (if(bar.isNil) { col[\b2Latch].now } { col[\b2Latch].atBar(bar) }) > 0 },
				{ false })
		},
		mapKnob: { |col, t, v|
			case
			{ t[\points].notNil } { col[\ce].stemCurve(t[\points], v) }
			{ t[\exp] and: { t[\lo] > 0 } and: { t[\hi] > 0 } } { t[\lo] * ((t[\hi] / t[\lo]) ** v) }
			{ t[\lo] + ((t[\hi] - t[\lo]) * v) }
		},
		// the preset, the knobs, then the add-on: parameter → value; space becomes the room send (a knob on room sets it)
		knobValues: { |col, on|
			var p = col[\preset].copy;
			col[\targets].keysValuesDo { |kk, list| var v = col.rawKnob(kk); list.do { |t| p[t[\param]] = col.mapKnob(t, v) } };
			if(p[\space].notNil or: { p[\room].isNil }) { p[\room] = 0.9 * (p.removeAt(\space) ? 0) };
			p[\echo] = p[\echo] ? 0;
			if(on) { col[\addon][\params] !? { |f| f.(col[\addonState], col, p) } };
			p
		},
		// format 2: what a layer's amount or chance reads (a knob, button 2's add-on state, Tension) through its points
		sourceValue: { |col, src, bar|
			switch(src, \b2, { col.addonOn(bar).binaryValue }, \tension, { col[\ce].val(col[\track].global.tension) },
				{ col.knob(src) })
		},
		amountOf: { |col, a, bar| col[\ce].stemCurve(a[\points], col.sourceValue(a[\source], bar), a[\power]) },
		// its own echo: [time in beats, feedback] from the stem's echo, the knobs and the add-on
		echoValues: { |col, on|
			var p = col.knobValues(on), e = col[\echoOwn];
			[p[\echoTime] ? e[0], p[\echoFeedback] ? e[1]]
		},
		// the state buses of the column: its knob parameters, room and echo send; format 2: the fader × boost, the
		// live amounts of its layers
		stateValues: { |col|
			var p, out = (), now = col[\ce][\stateVal] ? ();
			if(col[\colCode].notNil) {
				(col[\colCode][\states] ? ()).keysValuesDo { |k, v| var n = col.stateName(k); out[n] = now[n] ? v } } {
				p = col.knobValues(col.addonOn(nil));
				(col[\busParams] ++ [\room, \echo]).do { |param| out[col.stateName(param)] = p[param] };
				if(col[\boostOn]) { out[col.stateName(\boost)] = col.knob(\fader) * p[\boost] };
				col[\layers].do { |l| l[\amount] !? { |a| a[\param] !? {
					out[col.stateName(l[\live])] = col.amountOf(a, nil) } } } };
			out
		},
		// knobs, fader and button 2 set the state buses; a stem with its own echo sets its time and feedback
		refreshStates: { |col, send|
			var e, node;
			if(col[\colCode].notNil) { col[\colCode][\update] !? { |f| f.(col, send) } } {
				col.stateValues.keysValuesDo { |name, v| col[\ce].setState(name, v, send) };
				node = col[\ce][\stemDelayNode] !? { |d| d[col[\stemName]] };
				if(col[\echoOwn].notNil and: { node.notNil }) {
					e = col.echoValues(col.addonOn(nil));
					e = [e[0] * 60 / col[\track].bpm, e[1]];
					if(e != col[\echoNow]) { col[\echoNow] = e; send.([\n_set, node, \time, e[0], \feedback, e[1]]) } } } },
		// column code with gate: false and a stem with held chords are asked at fader 0 too (state and look-ahead move
		// on; notes at level 0 are not played)
		gated: { |col, bar|
			var ce = col[\ce], always = col[\colCode] !? { |c| c[\gate] == false } ? col[\ungated];
			var master = ce.masterCcOf(col) ? col[\track].global[\master];
			(always.not and: { (ce.val(col[\ccs][\fader]) <= 0) or: { master.notNil and: { ce.val(master) <= 0 } } })
				or: { col[\breakOut] and: { col[\track].breakAt(bar) } }
		},
		miniOf: { |col, str| var key = str.asSymbol, cache = col[\miniCache];
			cache[key] ?? { var m = col[\ce].mini(str); cache[key] = m; m } },
		// the value of a mini-notation at cycle time t (nil on a rest)
		miniValue: { |col, m, t|
			var tt = t % m.period, ev = m.events.detect { |e| (e[0] <= (tt + 1e-6)) and: { tt < (e[0] + e[1] - 1e-6) } };
			ev !? { ev[2] }
		},
		// the events of a rhythm that start in 16th k: hits with at (offset in the 16th), dur (16ths), t, note (the value)
		hitsOf: { |col, m, k|
			var span = m.period * 16, base = k - (k % span), r = k % span;
			m.events.select { |e| (e[0] * 16 + 1e-6).floor == r }.collect { |e|
				(at: (e[0] * 16) - r, dur: e[1] * 16, t: (base / 16) + e[0], note: e[2]) }
		},
		// the hits of the first layer (a stem code file makes them instead)
		patternHits: { |col, k|
			if(col[\stemCode].notNil) { col[\stemCode].(col, k) ? [] } { col.layerHits(col[\layers][0], k) }
		},
		// the hits of a layer in 16th k: its pattern's rhythm (or held chords), each with its note, velocity, length
		// factor, parameters, envelope and voices
		layerHits: { |col, l, k|
			var part = l[\pats][col[\patLatch].atBar((k / 16).floor)], ce = col[\ce];
			var hits = case
			{ part[\strike].notNil } { col.strikeHits(part[\strike], k) }
			{ part[\rhythm].notNil } { col.hitsOf(part[\rhythm], k) }
			{ [] };
			hits.collect { |h|
				h[\note] = if(part[\notes].isNil) { 0 } { col.miniValue(part[\notes], h[\t]) };
				h[\vel] = part[\vel] !? { |v| ce.stemValueAt(v, h[\t], col) } ? 1;
				part[\length] !? { |m| h[\length] = col.miniValue(m, h[\t]) };
				part[\params] !? { |ps| h[\params] = (); ps.keysValuesDo { |kk, v|
					ce.stemValueAt(v, h[\t], col) !? { |x| h[\params][kk] = x } } };
				h[\env] = part[\env];
				h[\voices] = part[\voices];
				h
			}.select { |h| h[\note].notNil }
		},
		// a held chord: struck where the chord changes (with push: two 16ths early) and again every span 16ths after,
		// held until the next change (at most span 16ths)
		strikeHits: { |col, span, k|
			var nameAt = { |x| col.chordAtK(x, col[\push])[\name] }, name = nameAt.(k), c = k, start, e;
			while { (c > (k - span)) and: { nameAt.(c - 1) == name } } { c = c - 1 };
			if(c == (k - span)) { c = span * (k / span).floor };
			start = c + (span * ((k - c) / span).floor);
			if(start != k) { [] } {
				e = k + 1;
				while { ((e - k) < span) and: { nameAt.(e) == name } } { e = e + 1 };
				[(at: 0, dur: e - k, t: k / 16, note: 0)] }
		},
		// the note value of the current pattern at cycle time t (0 without notes)
		noteAt: { |col, t|
			var pat = col[\pats][col[\patLatch].atBar(t.floor)];
			if(pat[\notes].isNil) { 0 } { col.miniValue(pat[\notes], t) }
		},
		// a note value as MIDI at 16th k, through the chord there (push: two 16ths early) and the stem's register
		midiOf: { |col, v, k|
			var c = col.chordAtK(k, col[\push]), n = if(v.isString) { col[\ce].noteNumber(v) } { v }, i = n.round.asInteger;
			var reg = col[\register], fold = { |m| if(reg.isNil) { m } { reg + ((m - reg) % 12) } };
			switch(col[\pitch],
				\midi, { n },
				\root, { fold.(c[\bass]) + n },
				\chord, { var t = c[\tones].copy.sort, pcs;
					if(reg.isNil) { t.wrapAt(i) + (12 * (i / t.size).floor) } {
						pcs = t.collect { |m| m % 12 };
						if(i >= 0) { (reg .. reg + 96).select { |m| pcs.includes(m % 12) }[i] } {
							(reg - 1, reg - 2 .. reg - 96).select { |m| pcs.includes(m % 12) }[i.neg - 1] } } },
				\scale, { var iv = c[\scale].collect { |pc| (pc - c[\root]) % 12 }.asSet.asArray.sort;
					fold.(c[\root]) + iv.wrapAt(i) + (12 * (i / iv.size).floor) })
		},
		// one note of a hit: the knob values p, the hit's own parameters, its layer's sound, kit file, pitch, envelope,
		// swing and amount (amt: × amp, or live on a parameter). A sound with a modulator phase input gets the WebAudio
		// phase of the note's time in a render (comparisons with Strudel).
		noteOf: { |col, h, k, bar, p, on, layer, amt = 1|
			var ce = col[\ce], l = layer ?? { col[\layers][0] }, args = p.copy, m, at = h[\at], ad = col[\addon], hold, file;
			var live = l[\amount] !? { |a| a[\param] };
			(h[\params] ? ()).keysValuesDo { |kk, v| args[kk] = v };
			hold = case
			{ col[\kit].notNil } { -1 }
			{ col[\holdKnob] } { args[\hold] * 4 * col[\track].bpm / 60 }
			{ h[\dur] * (h[\length] ? 1) * (args[\length] ? 1) };
			if(col[\pitch] != \none) {
				m = h[\note] !? { |v| col.midiOf(v, k) };
				m !? { m = m + l[\transpose] + (args[\transpose] ? 0) };
				if(on and: { m.notNil }) { ad[\transpose] !? { |f| m = m + f.(col[\addonState]) } };
			};
			col[\kit] !? { |kit| file = kit[h[\note].asString.asSymbol] };
			if((col[\pitch] != \none and: { m.isNil }) or: { col[\kit].notNil and: { file.isNil } }) { nil } {
				[\room, \echo, \hold, \space, \length, \boost, \trim, \transpose, \echoTime, \echoFeedback].do { |key|
					args.removeAt(key) };
				l[\busParams].do { |param| args[param] = ce.stateMap(col.stateName(param)) };
				col[\knobCode].keysValuesDo { |kk, f| args.putAll(f.(col.rawKnob(kk), col) ? ()) };
				l[\toneArg] !? { |x| args[\tone] = x };
				l[\thinArg] !? { |x| args[\thinF] = x };
				file !? { args[\buf] = ce.sampleBuffers[file]; args[\stereoIn] = (ce.sampleMono[file] != true).asInteger };
				m !? { args[\freq] = m.midicps; args[\midi] = m };
				(h[\env] !? { |e| ce.sdADSR(e[\a], e[\d], e[\s], e[\r]) } ?? { l[\envDefault] }) !? { |e|
					[\a, \d, \s, \r].do { |key, i| args[key] = e[i] } };
				if(col[\swing] and: { ((k % 16) + at).floor.asInteger.odd }) { at = at + (l[\swing] ? col[\track].swing ? 0) };
				args[\amp] = (args[\amp] ? 1) * (h[\vel] ? 1) * if(live.isNil) { amt } { 1 };
				live !? { args[live] = ce.stateMap(col.stateName(l[\live])); if(amt <= 0) { args[\nolog] = true } };
				if(m.notNil and: { ce.webaudioPhase == true } and: { l[\inputs].includes(\modPhase) }) {
					args[\modPhase] = (2pi * m.midicps * ((k + at) / 4 / (col[\track].bpm / 60))) % 2pi };
				args[\at] = at;
				args[\hold] = hold * if(on) { ad[\hold] ? 1 } { 1 };
				ce.note(l[\sound], args)
			}
		},
		// the parameters of the overriding knobs on every note column code made: pan moves the note's own pan, the rest
		// replaces it (space, echo and trim are strip settings of the code and stay with it)
		overrideNotes: { |col, notes|
			col[\overridden].do { |kk| col[\targets][kk].do { |t| var v = col.mapKnob(t, col.rawKnob(kk));
				if([\space, \echo, \trim, \hold, \boost].includes(t[\param]).not) { notes.do { |n|
					if(n.isKindOf(Event) and: { n[\instrument].notNil }) {
						n[t[\param]] = if(t[\param] == \pan) { ((n[\pan] ? 0) + v).clip(-1, 1) } { v } } } } } };
			notes
		},
		// the notes of 16th k (asked by the step engine through the stem track's slot)
		// every layer: its amount (0: no notes, unless a live amount plays on), hits, chance, voices; the add-on's hits
		stepNotes: { |col, k|
			var bar = (k / 16).floor, on, a = col[\addonState], ad = col[\addon], out = List[], p;
			on = col[\colCode].isNil and: { col.addonOn(bar) };
			if(on) { a[\since] = a[\since] ? k } { a[\since] = nil };
			case
			{ col.gated(bar) or: { on and: { ad[\mute] == true } } } { [] }
			{ col[\colCode].notNil } { col.overrideNotes(col[\colCode][\notes].(col, k) ? []) }
			{
				col[\layers].do { |l, i|
					var amt = l[\amount] !? { |x| col.amountOf(x, bar) } ? 1, hits, c;
					if((amt > 0) or: { l[\amount] !? { |x| x[\param].notNil and: { x[\play] } } ? false }) {
						hits = if(i == 0) { col.patternHits(k) } { col.layerHits(l, k) };
						if(on and: { i == 0 }) { ad[\hits] !? { |f| hits = f.(a, col, k, hits) } };
						l[\chance] !? { |x| c = if(x.isNumber) { x } { col.amountOf(x, bar) };
							hits = hits.select { |h| col[\ce].rand((k + h[\at]) / 16) >= (1 - c) } };
						if(hits.notEmpty) {
							p = p ?? { col.knobValues(on) };
							hits.do { |h| (h[\voices] ? [0]).do { |o| var hh = h;
								if(o != 0) { hh = h.copy; hh[\note] = h[\note] + o };
								col.noteOf(hh, k, bar, p, on, l, amt) !? { |n| out.add(n) } } } } }
				};
				if(on) { ad[\notes] !? { |f| out = out ++ f.(a, col, k) } };
				out.asArray
			}
		},
	)
};
)
