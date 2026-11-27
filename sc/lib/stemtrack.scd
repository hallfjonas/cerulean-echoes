// Stem tracks: sc/tracks/<id>/<id>.track (JSON, docs/features/stems.md) = stem versions on the 14 slots ('1:1'-'1:7'
// Mode 1, '2:1'-'2:7' Mode 2) + the frame, an SC file next to it. ~ce.loadTrack(path) turns it into the same track
// Event as a hand-written sc/tracks/*/*.scd, so prepare, the mixer, the step engine and the web UI play it unchanged.
// The track gives the global column 8 (Fog, Thin, Tension, Master; Chapter steps through `chapters`, Break takes the
// stems with frame.break "out" out at the next bar) and the swing (a fraction of a 16th the off 16ths come late).
// The frame file returns an Event:
//   chordAt: { |frame, track, bar| chord }   required: the chord of a bar (track.chapterAt(bar) = the chapter), a
//                                            chord made with ~ce.chordOf
//   chapterBars                              Chapter switches at the next phrase of this many bars (default 4)
//   orbits, states, samples, maps, stems     merged into the track (stems: e.g. the Launchkey's own stem)
//   lkNote, lkCtl, lkPadNames                the Launchkey, as in a hand-written track
//   lkKeys: (slots: ['2:1', …], start: '2:4', cc: 21, level: \lkLevel, tone: \lkBright)   the keys play one of
//                                            these columns through its own strip (~ce.lkColumnNotes; lkNote then gets
//                                            the pads only), the Launchkey knob `cc` picks it; level, tone: state buses
//   build: { |frame, track, ce| }            more latches or buttons, after the stem columns
//   global: (fog: cc, thin: cc, tension: cc, master: cc)   the CCs the strips read instead of column 8's Fog, Thin,
//                                            Tension and Master (007: its Room knob is the strips' Tension, no Thin)
//   masterless: true                         no master in the track's global: the strips ignore column 8's fader (stems
//                                            that want it as a drive read it themselves)
//   tensionEchoAmt, tensionRoomAmt           how far Tension opens the echo and the room (mixer.scd)
//   uiHead, uiGlobal: { |frame, track, ce| } the web UI's head line and column 8 buttons instead of the default
// and its `// @` comment lines (column 8, Launchkey) are added to the @ctl lines the stems make (stemTrackTags).
(
~ce.noteNumber = { |self, name|
	var m = name.asString.toLower.findRegexp("^([a-g])(#|b)?(-?[0-9])$");
	12 * (m[3][1].asInteger + 1) + (c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11)[m[1][1].asSymbol]
		+ (m[2][1] == "#").binaryValue - (m[2][1] == "b").binaryValue
};
// A chord from note names: bass ("a1"), tones ("c4 e4 g4 b4"), scale (pitch names, "a b c d e f# g").
// root = the bass's pitch class at or above the lowest tone (0 of pitch "scale").
~ce.chordOf = { |self, name, bass, tones, scale|
	var b = self.noteNumber(bass), t = tones.split($ ).collect { |n| self.noteNumber(n) }, low = t.minItem;
	(name: name, bass: b, tones: t, root: low + ((b - low) % 12),
		scale: scale.split($ ).collect { |n| self.noteNumber(n ++ "4") % 12 })
};
// slots (stem tracks only): a JSON object { "1:4": ref, … } that replaces those slots of the file (the player's swaps)
// A Stem Designer project (stemlab.scd) hands loadStemTrack the track Event it made (json) instead of a file:
//   dir (where the frame lies), backing: { 'b:1': ref, … } stems that play without a controller, ccCount, lab: true
//   (the Chapter and Break buttons stay free for the designer, the master fader and button 1 of column 8 set the
//   level of everything, of the columns or of the backing, see stemlab.scd), chapter (the start chapter)
~ce.loadTrack = { |self, path, slots| if(path.endsWith(".track")) { self.loadStemTrack(path, slots) } { path.load } };
// A Stem Designer project (track.lab) has the global level (the master fader) and one of its own for the columns and
// one for the backing: virtual CCs the designer sets from the master fader (stemlab.scd), the strips and the gate read them
~ce.labLevelCc = (stems: 200, context: 201);
~ce.masterCcOf = { |self, col|
	if(col[\track][\lab] == true) { self.labLevelCc[if(col[\slot].asString[0] == $b) { \context } { \stems }] }
};
~ce.stemSlots = ['1:1', '1:2', '1:3', '1:4', '1:5', '1:6', '1:7', '2:1', '2:2', '2:3', '2:4', '2:5', '2:6', '2:7'];
~ce.stemGlobal = (fog: 20, thin: 28, tension: 36, master: 12, chapter: 44, break: 52);

~ce.loadStemTrack = { |self, path, slots, project|
	var json = project ?? { self.readJSON(path) }, dir = json[\dir] ? path.dirname, frameFile = dir +/+ json[\frame], frame = frameFile.load;
	var bpm = self.numOf(json[\tempo]), glob = self.stemGlobal, chapters = json[\chapters];
	var track;
	// a function the frame does not have fails with its name (an Event would answer nil, and the column stay silent)
	frame[\forward] = { |fr, selector| Error("the frame has no %".format(selector)).throw };
	track = (
		name: json[\name], bpm: bpm, swing: self.numOf(json[\swing] ? 0), frame: frame, frameFile: frameFile,
		slots: (), columns: (), backing: (), pending: (), lab: json[\lab] == true,
		ccCount: json[\ccCount], ccStart: (), lkNote: frame[\lkNote], lkCtl: frame[\lkCtl], lkStart: frame[\lkStart],
		lkPadNames: frame[\lkPadNames], lkKeys: frame[\lkKeys], lkKeysSlot: frame[\lkKeys] !? { |k| k[\start] },
		global: frame[\global] ?? { if(frame[\masterless] == true) { (fog: glob.fog, thin: glob.thin, tension: glob.tension) } {
			(fog: glob.fog, thin: glob.thin, tension: glob.tension, master: glob.master) } },
		tensionEchoAmt: frame[\tensionEchoAmt], tensionRoomAmt: frame[\tensionRoomAmt],
		aliases: [\fog, \thin, \tension, \master, \chapter, \break].collect { |r| (glob[r] + 48) -> glob[r] }.asDict,
		orbits: frame[\orbits] ?? { (1: (ir: "ir/orbit-0.6.wav", delay: [0.75 * 60 / bpm, 0.2]),
			2: (ir: "ir/orbit-1.2.wav", delay: [0.75 * 60 / bpm, 0.3])) },
		samples: frame[\samples], maps: frame[\maps],
		chapterAt: { |self, bar| self.chapter.atBar(bar) },
		chordAt: { |self, bar| self[\frame].chordAt(self, bar) },
		chordAtK: { |self, k, push = false|
			if(self[\frame][\chordAtK].notNil) { self[\frame].chordAtK(self, k, push) } {
				self.chordAt(((k + if(push) { 2 } { 0 }) / 16).floor) } },
		breakAt: { |self, bar| self.breakL.atBar(bar) == 1 },
		uiHead: { |self, ce|
			var pend = { |now, next| if(now == next) { [now] } { [now, next] } }, onOff = ["Beat on", "Beat off"];
			if(frame[\uiHead].notNil) { frame[\uiHead].(frame, self, ce) } {
				[["Chapter"] ++ pend.(chapters[self.chapter.now], chapters[self.chapter.pending]),
					["Chord", self.chordAt(TempoClock.default.bar.max(0)).name],
					["Break"] ++ pend.(onOff[self.breakL.now], onOff[self.breakL.pending])] }
		},
		uiGlobal: { |self, ce|
			if(frame[\uiGlobal].notNil) { frame[\uiGlobal].(frame, self, ce) } {
				(b1: [chapters[self.chapter.now], chapters[self.chapter.pending]],
					b2: [["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending]],
					b2on: self.breakL.pending == 1) } },
		uiChordAt: { |self, bar| self.chordAt(bar).name },
		// the step engine asks a slot, not a column: a swap waiting for this slot takes over on the bar line. A column
		// whose code throws (a stem that needs what this frame lacks) goes quiet and is reported once; the others play on
		slotStep: { |self, slot, k|
			var msgs = if(k % 16 == 0 and: { self.pending[slot].notNil }) { self.switchSlot(slot) } { [] };
			var col = self.columns[slot] ?? { self.backing[slot] }, notes = [];
			// the try is its own statement: a primitive that fails inside it corrupts an expression the try is part of
			if(col[\failed].isNil) { notes = { col.stepNotes(k) }.try { |e| self.columnFailed(slot, col, e); [] } };
			msgs ++ notes
		},
		columnFailed: { |self, slot, col, error|
			var name = col[\stem][\name].asString;
			col[\failed] = error.errorString.replace("ERROR: ", "");
			"Slot % (%) is silent: %".format(slot, name, col[\failed]).warn;
			self.ce.uiSend('/ce/stemerror', slot.asString, name, col[\failed])
		},
		// the outgoing column's own hooks and latches leave with it; the strip takes the new stem's settings (its shape
		// is the same, ~ce.swapProblem)
		switchSlot: { |self, slot|
			var ce = self.ce, col = self.pending.removeAt(slot), msgs = List[], name = col[\stemName];
			var node = ce.stripNode[name][\main], entry = ce.columnStem(col, self), orbit = entry[\orbit];
			var tension = if(col[\tension]) { ce.ccIndex(self.global.tension) } { -1 };
			var delayBus = ce.stemDelayBus[name] ? ce.orbitDelayBus[orbit];
			self.columns[slot] !? { |old| ce.dropHooks(old) };
			self.columns[slot] = col;
			self.slots[slot] = col[\stem][\ref];
			msgs.add((msg: [\n_set, node, \hpOwn, col[\hpOwn], \thinOn, col.thinOnStrip.asInteger,
				\tEchoOn, (col[\tension] and: { col[\tensionEchoOn] }).asInteger, \roomOut, ce.orbitBus[orbit] ? 0, \roomOn, ce.orbitBus[orbit].notNil.asInteger,
				\delayOut, delayBus ? 0, \delayOn, ((entry[\echo].notNil or: { entry[\echoSend].notNil })
					and: { delayBus.notNil }).asInteger, \tension, 0]
				++ if(entry[\trim].isNumber) { [\trim, entry[\trim]] } { [] }));
			msgs.add((msg: [\n_map, node, \tension, tension]));
			entry[\ownDelay] !? { |d| msgs.add((msg: [\n_set, ce.stemDelayNode[name], \time, d[0], \feedback, d[1]])) };
			col.refreshStates({ |m| msgs.add((msg: m)) });
			col.showRow;
			self.tagLines = ce.stemTrackTags(self);
			ce.status(slot, col[\stem][\name]);
			ce.uiLayout;
			ce.uiPush;
			msgs.asArray
		},
		build: { |self, ce|
			self.ce = ce;
			self.chapter = ce.latch(frame[\chapterBars] ? 4, json[\chapter] ? 0, { |i| ce.status("Chapter", chapters[i]); ce.uiPush });
			self.breakL = ce.latch(1, 0, { |i| ce.status("Break", i); ce.uiPush });
			if(self.lab.not) {
				ce.cycleButton(glob.chapter, chapters.size, { |s|
					self.chapter.pending = s; ce.status("Chapter (next)", chapters[s]) });
				ce.cycleButton(glob.break, 2, { |s| self.breakL.pending = s })
			};
			self.backing.do { |col| col.startCol(ce) };
			self.columns.do { |col| col.startCol(ce); col.showRow };
			// the controls reach whatever column the slot holds now (a swap replaces the column, not the hooks)
			self.columns.keysDo { |slot| var cc = ce.slotCCs(slot);
				[\k1, \k2, \k3, \fader].do { |kk| ce.onCC(cc[kk], { |v, send| self.columns[slot].refreshStates(send) }) };
				ce.onCC(cc[\b2], { |v, send| self.columns[slot].b2Change(v, send) });
				ce.onPress(cc[\b1], { self.columns[slot].pressB1 });
			};
			frame[\build] !? { |f| f.(frame, self, ce) };
		}
	);
	json[\slots].keysValuesDo { |slot, ref| track.slots[slot] = ref };
	slots !? { self.jsonEvent(slots.parseJSON).keysValuesDo { |slot, ref| track.slots[slot] = ref } };
	self.stemSlots.do { |slot| track.slots[slot] !? { |ref|
		track.columns[slot] = self.stemColumn(self.loadStem(ref), slot, track) } };
	(json[\backing] ? ()).keysValuesDo { |slot, ref|
		var col = self.stemColumn(self.loadStem(ref), slot, track);
		track.backing[slot.asSymbol] = col;
		col[\ccs].values.do { |c| track.ccStart[c] = 0 };
		track.ccStart[col[\ccs][\fader]] = 1
	};
	track.columns.do { |col| [\k1, \k2, \k3].do { |kk|
		col[\stem][\controls][kk][\default] !? { |d| track.ccStart[col[\ccs][kk]] = self.numOf(d) } } };
	if(track.lab) { track.ccStart[glob.master] = 1; track.ccStart[self.labLevelCc[\stems]] = 1; track.ccStart[self.labLevelCc[\context]] = 1 };
	track.stems = self.stemSlots.select { |slot| track.columns[slot].notNil }.collect { |slot|
		self.columnStem(track.columns[slot], track) } ++ track.backing.values.collect { |col|
		self.columnStem(col, track) } ++ (frame[\stems] ? []);
	track.states = (frame[\states] ? ()).copy;
	track.columns.do { |col| track.states.putAll(col.stateValues) };
	track.backing.do { |col| track.states.putAll(col.stateValues) };
	track.maps = (frame[\maps] ? ()).copy;
	track.columns.do { |col| track.maps.putAll(col[\maps]) };
	track.backing.do { |col| track.maps.putAll(col[\maps]) };
	track.tagLines = self.stemTrackTags(track);
	track
};

// The stem entry of a column for ~ce.prepare: its strip (fader, room and echo send on the column's state buses, the
// stem's gain as trim, Thin and Tension unless the stem opts out) and its notes through the slot
// A stem without echo (no knob, add-on or column code sends to it) gets no echo send, so Tension's echo leaves it dry.
// Column code gives its own strip (stems.scd): its Symbols name the column's states, maps or controls.
~ce.columnStem = { |self, col, track|
	var slot = col[\slot], strip = col[\colCode] !? { |c| c[\strip] }, ref = { |x| col.stripRef(x) };
	var entry = (name: col[\stemName], sounds: col[\sounds], level: col[\ccs][\fader], orbit: col[\orbit],
		hpOwn: col[\hpOwn], master: self.masterCcOf(col), roomR: col.stateName(\room), echoSend: if(col[\echoOn]) { col.stateName(\echo) },
		thin: col.thinOnStrip, trim: col[\gain], tension: col[\tension], tensionEcho: col[\tension] and: { col[\tensionEchoOn] },
		notes: { |k| track.slotStep(slot, k) });
	if(col[\boostOn] == true) { entry[\level] = col.stateName(\boost) };
	if(col[\maps].includesKey(col.mapName(\trim))) { entry[\trim] = col.mapName(\trim) };
	col[\echoOwn] !? { var e = col.echoValues(false); entry[\ownDelay] = [e[0] * 60 / track.bpm, e[1]];
		col[\echoNow] = entry[\ownDelay] };
	strip !? {
		entry.removeAt(\roomR); entry.removeAt(\echoSend);
		[\level, \orbit, \roomR, \echoSend, \space, \echo, \trim].do { |key|
			strip[key] !? { |x| entry[key] = ref.(x) } };
		// ownDelay: [time in beats, feedback], so the stem keeps its echo in beats at any tempo
		strip[\ownDelay] !? { |d| entry[\ownDelay] = [d[0] * 60 / track.bpm, d[1]] };
		strip[\lanes] !? { |lanes| entry[\lanes] = lanes.collect { |ln|
			var out = ln.copy; [\level, \fade, \roomR, \echoSend, \space, \echo, \trim].do { |key| ln[key] !? { |x| out[key] = ref.(x) } };
			out } };
	};
	entry
};

// The Launchkey keys on a stem track whose frame has lkKeys: they play one column (track.lkKeysSlot) into that
// column's own strip, so orbit, room, echo and trim follow the column, also after a swap; its fader does not reach
// them. A column can play keys when its column code has keys: { |col, note, vel| notes } or its stem is pitched JSON
// (no column code, no kit): then a key plays one hit of its first layer at the key's note, the knobs as they are.
~ce.lkColumnPlayable = { |self, col|
	col.notNil and: { if(col[\colCode].notNil) { col[\colCode][\keys].notNil } {
		(col[\pitch] != \none) and: { col[\kit].isNil } } }
};
~ce.lkColumnChoices = { |self|
	var t = self.track;
	t[\lkKeys][\slots].select { |s| self.lkColumnPlayable(t[\columns][s]) }
};
~ce.lkColumnLabel = { |self|
	var col = self.track[\columns][self.track[\lkKeysSlot]];
	var name = col !? { (col[\stem][\meta][\label] ? col[\stem][\meta][\role]).asString };
	if(name.isNil) { "–" } { name[0].toUpper.asString ++ name.drop(1) }
};
// the knob value v picks the choice in its zone; the start column holds until the knob moves
~ce.lkColumnSelect = { |self, v|
	var t = self.track, choices = self.lkColumnChoices;
	if(choices.notEmpty) {
		t[\lkKeysSlot] = choices[(v * choices.size).floor.asInteger.min(choices.size - 1)];
		self.status("Keys", self.lkColumnLabel);
		self.uiPush }
};
// the notes of a key: the column's, with the tone (× the low-pass range, neutral at half), the key pan (knob 8) and the
// level on top
~ce.lkColumnNotes = { |self, note, vel|
	var t = self.track, cfg = t[\lkKeys], col = t[\columns][t[\lkKeysSlot]];
	var level = cfg[\level] !? { |x| self.stateVal[x] } ? 1;
	var tone = cfg[\tone] !? { |x| 2 ** (4 * ((self.stateVal[x] ? 0.5) - 0.5)) } ? 1;
	if((level <= 0) or: { self.lkColumnPlayable(col).not }) { [] } {
		var lanes = self.stemBus[col[\stemName]], pan = self.lkKeyPanArgs(note), notes;
		notes = if(col[\colCode].notNil) { col[\colCode][\keys].(col, note, vel) } {
			var k = (TempoClock.default.beats * 4).floor.asInteger.max(0), hit = (at: 0, dur: 4, note: 0, vel: vel);
			[col.noteOf(hit, k, (k / 16).floor, col.knobValues(false), false, col[\layers][0])]
				.reject(_.isNil).collect { |n| n.put(\freq, note.midicps).put(\midi, note) } };
		(notes ? []).do { |n| if(n[\instrument].notNil) {
			if(lanes[n[\lane]].isNil) { n.removeAt(\lane) };
			n[\lo] !? { |x| n[\lo] = x * tone };
			n[\hi] !? { |x| n[\hi] = x * tone };
			n.putAll(pan);
			n[\post] = (n[\post] ? 1) * level } };
		notes ? []
	}
};

// The @ tags of a stem track (read by the web UI instead of the file's comments): modes, a heading and six @ctl
// lines per slot from the stems, then the frame file's own `// @` lines. tools/stems/stem-tags.mjs makes the same.
~ce.stemTrackTags = { |self, track|
	var lines = List["// @layout % (stem track)".format(track.name), "// @mode 16 Mode 1 — Foundation",
		"// @mode 2 Mode 2 — Colour"];
	self.stemSlots.do { |slot| track[\columns][slot] !? { |col|
		var s = slot.asString, mode = if(s[0] == $1) { "16" } { "2" }, n = s[2], stem = col[\stem];
		// the column's name: the stem's own label (Birds), else its role (Fx)
		var role = (stem[\meta][\label] ? stem[\meta][\role]).asString;
		lines.add("// @col %:% % %".format(mode, n, n, role[0].toUpper.asString ++ role.drop(1)));
		[\k1, \k2, \k3, \fader, \b1, \b2].do { |kk| var c = stem[\controls][kk];
			lines.add("// @ctl %:%.% % | %".format(mode, n, kk, c[\label], c[\about])) }
	} };
	lines = lines ++ File.readAllString(track[\frameFile]).split($\n).select { |l| l.beginsWith("// @") };
	track[\labTags] !? { |f| f.(lines) } ? lines
};

// Swap hook (the stem swap in the player): the stem `ref` takes over `slot` at the next bar line, the other columns
// play on. load.(msgs, done) delivers the new sounds, samples and state buses to the server and then calls done
// (default: live, sent in a Routine with s.sync). A slot must hold a stem already (an empty slot has no strip: load
// the changed track instead). Returns the new column.
~ce.swapSlot = { |self, slot, ref, load|
	var track = self.track, known = self.serverSounds, col, msgs, fresh;
	slot = slot.asSymbol;
	if(track[\columns].isNil or: { track[\columns][slot].isNil }) {
		Error("slot % holds no stem: load the track with it instead".format(slot)).throw };
	col = self.stemColumn(self.loadStem(ref), slot, track);
	col.startCol(self);
	load = load ? self[\swapLoad];
	fresh = col[\sounds].reject { |s| known.includes(s) }.asSet.asArray;
	msgs = self.soundMsgs(fresh) ++ self.stateMsgs(col.stateValues);
	known.addAll(fresh);
	load = load ? { |m, done| fork { self.sendInit(m); done.value } };
	// a second swap before the bar line replaces the first one
	load.(msgs, { track[\pending][slot] !? { |was| self.dropHooks(was) }; track[\pending][slot] = col });
	col
};

// Why `ref` cannot take over `slot` while the track plays (nil: it can). The slot's mixer strip was made at the load for
// the stem it held then, so the new stem must want the same strip: fader, room and echo sends, lanes, an own echo line
// (its time and feedback may differ), a mapped trim, and only map buses the track has. Otherwise: load the track with
// the new stem (the player's fallback, a short gap).
~ce.swapProblem = { |self, slot, ref|
	var track = self.track, old, col, shape;
	slot = slot.asSymbol;
	old = track[\columns] !? { |c| c[slot] };
	shape = { |c| var e = self.columnStem(c, track);
		[\level, \roomR, \echoSend, \space, \echo, \fade, \lanes].collect { |k| e[k] }
			++ [e[\ownDelay].notNil, if(e[\trim].isNumber) { 1 } { e[\trim] }] };
	case
	{ old.isNil } { "slot % holds no stem".format(slot) }
	{ col = self.stemColumn(self.loadStem(ref), slot, track); shape.(col).asCompileString != shape.(old).asCompileString }
		{ "the new stem needs another mixer strip" }
	{ col[\maps].keys.any { |m| self.mapBus[m].isNil } } { "the new stem needs map buses the track does not have" }
	{ nil }
};

// Set-up messages of sounds loaded after ~ce.prepare: SynthDefs, sample buffers, wavetables (as prepare makes them)
~ce.soundMsgs = { |self, names|
	var srv = self.server, msgs = List[];
	names.do { |name| var snd = self.sounds[name];
		snd.def.add;
		msgs.add([\d_recv, snd.def.asBytes]);
		((snd.samples ? ()).values ++ (snd[\files] ? [])).do { |rel| if(self.sampleBuffers[rel].isNil) {
			var path = if(rel.beginsWith("repo:")) { self.root.dirname +/+ "samples" +/+ rel.drop(5) } {
				self.root +/+ "samples" +/+ rel };
			var b = srv.bufferAllocator.alloc(1), ch = SoundFile.use(path, { |f| f.numChannels });
			self.sampleBuffers[rel] = b;
			self.sampleMono[rel] = ch == 1;
			msgs.add([\b_allocReadChannel, b, path, 0, 0] ++ if(ch == 1) { [0, 0] } { [0, 1] });
		} };
		(snd.wavetables ? ()).do { |shape| if(self.wavetableBase[shape].isNil) {
			var base = srv.bufferAllocator.alloc(4);
			self.wavetableBase[shape] = base;
			self.wavetableHarmonics.do { |n, i|
				msgs.add([\b_alloc, base + i, 8192]);
				msgs.add([\b_gen, base + i, \sine1, 6] ++ (1..n).collect(self.wavetableShapes[shape]));
			}
		} };
	};
	msgs.asArray
};
// State buses a swapped-in column needs and the slot does not have yet
~ce.stateMsgs = { |self, values|
	var msgs = List[];
	values.keysValuesDo { |name, v| if(self.stateBus[name].isNil) {
		self.stateBus[name] = self.server.controlBusAllocator.alloc(1);
		self.stateVal[name] = v;
		msgs.add([\c_set, self.stateBus[name], v]);
	} };
	msgs.asArray
};
)
