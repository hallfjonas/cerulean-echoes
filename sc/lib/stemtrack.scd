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
//   build: { |frame, track, ce| }            more latches or buttons, after the stem columns
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
~ce.loadTrack = { |self, path| if(path.endsWith(".track")) { self.loadStemTrack(path) } { path.load } };
~ce.stemSlots = ['1:1', '1:2', '1:3', '1:4', '1:5', '1:6', '1:7', '2:1', '2:2', '2:3', '2:4', '2:5', '2:6', '2:7'];
~ce.stemGlobal = (fog: 20, thin: 28, tension: 36, master: 12, chapter: 44, break: 52);

~ce.loadStemTrack = { |self, path|
	var json = self.readJSON(path), dir = path.dirname, frameFile = dir +/+ json[\frame], frame = frameFile.load;
	var bpm = self.numOf(json[\tempo]), glob = self.stemGlobal, chapters = json[\chapters];
	var track = (
		name: json[\name], bpm: bpm, swing: self.numOf(json[\swing] ? 0), frame: frame, frameFile: frameFile,
		slots: (), columns: (), pending: (), lkNote: frame[\lkNote], lkCtl: frame[\lkCtl], lkPadNames: frame[\lkPadNames],
		global: (fog: glob.fog, thin: glob.thin, tension: glob.tension, master: glob.master),
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
			[["Chapter"] ++ pend.(chapters[self.chapter.now], chapters[self.chapter.pending]),
				["Chord", self.chordAt(TempoClock.default.bar.max(0)).name],
				["Break"] ++ pend.(onOff[self.breakL.now], onOff[self.breakL.pending])]
		},
		uiGlobal: { |self, ce| (b1: [chapters[self.chapter.now], chapters[self.chapter.pending]],
			b2: [["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending]],
			b2on: self.breakL.pending == 1) },
		uiChordAt: { |self, bar| self.chordAt(bar).name },
		// the step engine asks a slot, not a column: a swap waiting for this slot takes over on the bar line
		slotStep: { |self, slot, k|
			var msgs = if(k % 16 == 0 and: { self.pending[slot].notNil }) { self.switchSlot(slot) } { [] };
			msgs ++ self.columns[slot].stepNotes(k)
		},
		switchSlot: { |self, slot|
			var ce = self.ce, col = self.pending.removeAt(slot), msgs = List[], node = ce.stripNode[col[\stemName]][\main];
			var tension = if(col[\tension]) { ce.ccIndex(self.global.tension) } { -1 };
			self.columns[slot] = col;
			self.slots[slot] = col[\stem][\ref];
			msgs.add((msg: [\n_set, node, \hpOwn, col[\hpOwn], \thinOn, col.thinOnStrip.asInteger, \trim, col[\gain],
				\tEchoOn, col[\tension].asInteger, \roomOut, ce.orbitBus[col[\orbit]] ? 0,
				\delayOut, ce.orbitDelayBus[col[\orbit]] ? 0, \tension, 0]));
			msgs.add((msg: [\n_map, node, \tension, tension]));
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
			self.chapter = ce.latch(frame[\chapterBars] ? 4, 0, { |i| ce.status("Chapter", chapters[i]); ce.uiPush });
			ce.cycleButton(glob.chapter, chapters.size, { |s|
				self.chapter.pending = s; ce.status("Chapter (next)", chapters[s]) });
			self.breakL = ce.latch(1, 0, { |i| ce.status("Break", i); ce.uiPush });
			ce.cycleButton(glob.break, 2, { |s| self.breakL.pending = s });
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
	self.stemSlots.do { |slot| track.slots[slot] !? { |ref|
		track.columns[slot] = self.stemColumn(self.loadStem(ref), slot, track) } };
	track.stems = self.stemSlots.select { |slot| track.columns[slot].notNil }.collect { |slot|
		self.columnStem(track.columns[slot], track) } ++ (frame[\stems] ? []);
	track.states = (frame[\states] ? ()).copy;
	track.columns.do { |col| track.states.putAll(col.stateValues) };
	track.maps = (frame[\maps] ? ()).copy;
	track.columns.do { |col| track.maps.putAll(col[\maps]) };
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
		hpOwn: col[\hpOwn], roomR: col.stateName(\room), echoSend: if(col[\echoOn]) { col.stateName(\echo) },
		thin: col.thinOnStrip, trim: col[\gain], tension: col[\tension], tensionEcho: col[\tension],
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
			var out = ln.copy; [\level, \roomR, \echoSend, \space, \echo].do { |key| ln[key] !? { |x| out[key] = ref.(x) } };
			out } };
	};
	entry
};

// The @ tags of a stem track (read by the web UI instead of the file's comments): modes, a heading and six @ctl
// lines per slot from the stems, then the frame file's own `// @` lines. tools/stems/stem-tags.mjs makes the same.
~ce.stemTrackTags = { |self, track|
	var lines = List["// @layout % (stem track)".format(track.name), "// @mode 16 Mode 1 — Foundation",
		"// @mode 2 Mode 2 — Colour"];
	self.stemSlots.do { |slot| track[\columns][slot] !? { |col|
		var s = slot.asString, mode = if(s[0] == $1) { "16" } { "2" }, n = s[2], stem = col[\stem];
		var role = stem[\meta][\role].asString;
		lines.add("// @col %:% % %".format(mode, n, n, role[0].toUpper.asString ++ role.drop(1)));
		[\k1, \k2, \k3, \fader, \b1, \b2].do { |kk| var c = stem[\controls][kk];
			lines.add("// @ctl %:%.% % | %".format(mode, n, kk, c[\label], c[\about])) }
	} };
	lines ++ File.readAllString(track[\frameFile]).split($\n).select { |l| l.beginsWith("// @") }
};

// Swap hook (the stem swap in the player): the stem `ref` takes over `slot` at the next bar line, the other columns
// play on. load.(msgs, done) delivers the new sounds, samples and state buses to the server and then calls done
// (default: live, sent in a Routine with s.sync). A slot must hold a stem already (an empty slot has no strip: load
// the changed track instead). Returns the new column.
~ce.swapSlot = { |self, slot, ref, load|
	var track = self.track, known = self.sounds.keys.copy, col, msgs;
	slot = slot.asSymbol;
	if(track[\columns].isNil or: { track[\columns][slot].isNil }) {
		Error("slot % holds no stem: load the track with it instead".format(slot)).throw };
	col = self.stemColumn(self.loadStem(ref), slot, track);
	col.startCol(self);
	msgs = self.soundMsgs(col[\sounds].reject { |s| known.includes(s) }) ++ self.stateMsgs(col.stateValues);
	load = load ? { |m, done| fork { self.sendInit(m); done.value } };
	load.(msgs, { track[\pending][slot] = col });
	col
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
