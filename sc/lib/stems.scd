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

~ce.loadStem = { |self, ref|
	var path = self.root +/+ "stems" +/+ ref, stem = self.readJSON(path);
	stem[\ref] = ref;
	stem[\dir] = path.dirname;
	stem
};

// The CCs of a slot ('1:4' = Mode 1 column 4, '2:1' = Mode 2 column 1; Mode 2 = CC + 48)
~ce.slotCCs = { |self, slot|
	var s = slot.asString, n = s[2].digit, plus = if(s[0] == $2) { 48 } { 0 };
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
	var ccs = self.slotCCs(slot), maps = (), gain = self.numOf(stem[\gain] ? 1);
	// a column's map named trim is its strip trim: the stem's gain multiplies it
	(colCode !? { |c| c[\maps] } ? ()).keysValuesDo { |name, m|
		maps[(stemName ++ "_" ++ name).asSymbol] = (ccs: m[\ccs].collect { |c| ccs[c] ? c },
			fn: if(name == \trim) { { |...in| m[\fn].valueArray(in) * gain } } { m[\fn] }) };
	(extra ++ (addon[\sounds] ? [])).do { |name| if(self.sounds[name].isNil) { self.loadSound(name) } };
	(stem[\sample][\preset] ? ()).keysValuesDo { |k, v| preset[k] = self.numOf(v) };
	(b2[\args] ? ()).keysValuesDo { |k, v|
		args[k] = if(v.isString and: { "^-?[0-9.]+$".matchRegexp(v) }) { v.asFloat } { v } };
	[\k1, \k2, \k3].do { |kk| var knob = controls[kk];
		var one = { |t| (param: t[\param].asSymbol, lo: self.numOf(t[\range][0]), hi: self.numOf(t[\range][1]),
			exp: t[\curve] == "exp") };
		case
		{ knob[\param].notNil } { targets[kk] = [one.(knob)] }
		{ knob[\targets].notNil } { targets[kk] = knob[\targets].collect(one) }
		{ knob[\code].notNil } { knobCode[kk] = (stem[\dir] +/+ knob[\code]).load }
	};
	(
		ce: ce, track: track, stem: stem, slot: slot.asSymbol, stemName: stemName, ccs: ccs,
		sample: sample, sounds: [sample] ++ extra ++ (addon[\sounds] ? []), pitch: stem[\pitch].asSymbol,
		colCode: colCode, maps: maps, st: (),
		echoOn: targets.values.flatten(1).any { |t| t[\param] == \echo } or: { addon === self.addons[\echoThrow] },
		gain: gain, preset: preset, inputs: inputs, hpOwn: snd.hpf,
		orbit: if(self.lowRoles.includes(stem[\meta][\role].asSymbol)) { 1 } { 2 },
		fog: opt.(\fog), thin: opt.(\thin), tension: opt.(\tension), swing: opt.(\swing), breakOut: frame[\break] == "out",
		targets: targets, knobCode: knobCode,
		holdKnob: targets.values.flatten(1).any { |t| t[\param] == \hold },
		busParams: targets.values.flatten(1).collect { |t| t[\param] }.asSet.asArray
			.select { |p| inputs.includes(p) and: { [\hold, \amp].includes(p).not } },
		pats: stem[\patterns].collect { |p| (label: p[\label], rhythm: mini.(p[\rhythm]), notes: mini.(p[\notes]),
			vel: mini.(p[\velocity])) },
		stemCode: if(colCode.isNil) { code },
		b1Code: controls[\b1][\code] !? { |c| (stem[\dir] +/+ c).load },
		addon: addon, addonMode: b2[\mode].asSymbol, addonState: (args: args, since: nil,
			argNum: { |a, key, default| a[\args][key] ? default }),
		miniCache: (),

		// the sound's thin input does Thin per note (sd voices); else the strip does it
		thinOnStrip: { |col| col[\thin] and: { col[\inputs].includes(\thinF).not } },
		stateName: { |col, param| (col[\stemName] ++ "_" ++ param).asSymbol },
		knob: { |col, kk| col[\ce].val(col[\ccs][kk]) },
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
			col[\toneArg] = if(col[\fog] and: { col[\inputs].includes(\tone) }) {
				("c" ++ if(col[\tension]) { ce.toneBus } { ce.fogBus }).asSymbol };
			col[\thinArg] = if(col[\thin] and: { col[\inputs].includes(\thinF) }) { ("c" ++ ce.thinBus).asSymbol };
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
			if(t[\exp] and: { t[\lo] > 0 } and: { t[\hi] > 0 }) { t[\lo] * ((t[\hi] / t[\lo]) ** v) } {
				t[\lo] + ((t[\hi] - t[\lo]) * v) }
		},
		// the preset, the knobs, then the add-on: parameter → value; space becomes the room send
		knobValues: { |col, on|
			var p = col[\preset].copy;
			col[\targets].keysValuesDo { |kk, list| var v = col.knob(kk); list.do { |t| p[t[\param]] = col.mapKnob(t, v) } };
			p[\room] = 0.9 * (p.removeAt(\space) ? 0);
			p[\echo] = p[\echo] ? 0;
			if(on) { col[\addon][\params] !? { |f| f.(col[\addonState], col, p) } };
			p
		},
		// the state buses of the column: its knob parameters, room and echo send
		stateValues: { |col|
			var p, out = (), now = col[\ce][\stateVal] ? ();
			if(col[\colCode].notNil) {
				(col[\colCode][\states] ? ()).keysValuesDo { |k, v| var n = col.stateName(k); out[n] = now[n] ? v } } {
				p = col.knobValues(col.addonOn(nil));
				(col[\busParams] ++ [\room, \echo]).do { |param| out[col.stateName(param)] = p[param] } };
			out
		},
		refreshStates: { |col, send|
			if(col[\colCode].notNil) { col[\colCode][\update] !? { |f| f.(col, send) } } {
				col.stateValues.keysValuesDo { |name, v| col[\ce].setState(name, v, send) } } },
		// column code with gate: false is asked at fader 0 too (its state moves on; notes at level 0 are not played)
		gated: { |col, bar|
			var ce = col[\ce], always = col[\colCode] !? { |c| c[\gate] == false } ? false;
			(always.not and: { (ce.val(col[\ccs][\fader]) <= 0) or: { ce.val(col[\track].global.master) <= 0 } })
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
		patternHits: { |col, k|
			var pat = col[\pats][col[\patLatch].atBar((k / 16).floor)];
			if(col[\stemCode].notNil) { col[\stemCode].(col, k) ? [] } {
				col.hitsOf(pat[\rhythm], k).collect { |h|
					h[\note] = if(pat[\notes].isNil) { 0 } { col.miniValue(pat[\notes], h[\t]) };
					h[\vel] = pat[\vel] !? { |v| col.miniValue(v, h[\t]) } ? 1;
					h
				}.select { |h| h[\note].notNil }
			}
		},
		// the note value of the current pattern at cycle time t (0 without notes)
		noteAt: { |col, t|
			var pat = col[\pats][col[\patLatch].atBar(t.floor)];
			if(pat[\notes].isNil) { 0 } { col.miniValue(pat[\notes], t) }
		},
		midiOf: { |col, v, bar|
			var c = col.chordAt(bar), n = if(v.isString) { col[\ce].noteNumber(v) } { v }, i = n.round.asInteger;
			switch(col[\pitch],
				\midi, { n },
				\root, { c[\bass] + n },
				\chord, { var t = c[\tones].copy.sort; t.wrapAt(i) + (12 * (i / t.size).floor) },
				\scale, { var iv = c[\scale].collect { |pc| (pc - c[\root]) % 12 }.asSet.asArray.sort;
					c[\root] + iv.wrapAt(i) + (12 * (i / iv.size).floor) })
		},
		noteOf: { |col, h, k, bar, p, on|
			var ce = col[\ce], args = p.copy, m, at = h[\at], ad = col[\addon];
			var hold = if(col[\holdKnob]) { p[\hold] * 4 * col[\track].bpm / 60 } { h[\dur] };
			if(col[\pitch] != \none) {
				m = h[\note] !? { |v| col.midiOf(v, bar) };
				if(on and: { m.notNil }) { ad[\transpose] !? { |f| m = m + f.(col[\addonState]) } };
			};
			if(col[\pitch] != \none and: { m.isNil }) { nil } {
				[\room, \echo, \hold].do { |key| args.removeAt(key) };
				col[\busParams].do { |param| args[param] = ce.stateMap(col.stateName(param)) };
				col[\knobCode].keysValuesDo { |kk, f| args.putAll(f.(col.knob(kk), col) ? ()) };
				col[\toneArg] !? { |x| args[\tone] = x };
				col[\thinArg] !? { |x| args[\thinF] = x };
				m !? { args[\freq] = m.midicps; args[\midi] = m };
				if(col[\swing] and: { ((k % 16) + at).floor.asInteger.odd }) { at = at + (col[\track].swing ? 0) };
				args[\amp] = (p[\amp] ? 1) * (h[\vel] ? 1);
				args[\at] = at;
				args[\hold] = hold * if(on) { ad[\hold] ? 1 } { 1 };
				ce.note(col[\sample], args)
			}
		},
		// the notes of 16th k (asked by the step engine through the stem track's slot)
		stepNotes: { |col, k|
			var bar = (k / 16).floor, on, a = col[\addonState], ad = col[\addon], hits, out = [], p;
			on = col[\colCode].isNil and: { col.addonOn(bar) };
			if(on) { a[\since] = a[\since] ? k } { a[\since] = nil };
			case
			{ col.gated(bar) or: { on and: { ad[\mute] == true } } } { [] }
			{ col[\colCode].notNil } { col[\colCode][\notes].(col, k) ? [] }
			{
				hits = col.patternHits(k);
				if(on) { ad[\hits] !? { |f| hits = f.(a, col, k, hits) } };
				if(hits.notEmpty) {
					p = col.knobValues(on);
					out = hits.collect { |h| col.noteOf(h, k, bar, p, on) }.reject(_.isNil);
				};
				if(on) { ad[\notes] !? { |f| out = out ++ f.(a, col, k) } };
				out
			}
		},
	)
};
)
