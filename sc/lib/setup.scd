// Setting up a track on a server (live) or in a score (offline): buses, groups, buffers, mixer synths.
// track (see tracks/*/): (name, bpm, global: (fog, thin, tension, master: CCs), stems: [(name, sounds, out bus,
// level/space CCs, hpOwn, orbit)], orbits: (n: (ir: "…wav")), build: { |ce, track| … patterns … })
(
~ce.prepare = { |self, server, track|
	var msgs = List[], defsSent = Set[], bufNum = { server.bufferAllocator.alloc(1) };
	var ctl = { |n = 1| server.controlBusAllocator.alloc(n) }, aud = { |n = 2| server.audioBusAllocator.alloc(n) };
	var node = { server.nodeAllocator.alloc }, prep;
	self.server = server;
	self.track = track;
	self.pressFns = (); self.latches = List[]; self.ccAlias = (); self.uiRows = (); self.ccHooks = ();   // a fresh session (re-running starts clean)
	self.ccBase = ctl.(track[\ccCount] ? 128);
	(track[\ccStart] ? ()).keysValuesDo { |c, v| self.cc[c] = v; msgs.add([\c_set, self.ccBase + c, v]) };
	self.toneBus = ctl.(); self.fogBus = ctl.(); self.thinBus = ctl.();
	self.masterIn = aud.();
	self.groups = (ctl: node.(), src: node.(), strips: node.(), fx: node.(), master: node.());
	(track.aliases ? ()).keysValuesDo { |from, to| self.ccAlias[from] = to };
	// sounds the track uses
	track.stems.do { |st| st.sounds.do { |snd| if(self.sounds[snd].isNil) { self.loadSound(snd) } } };
	self.serverSounds = self.sounds.keys.copy;   // their SynthDefs go to the server below (a swap sends the ones it adds)
	// SynthDefs (also into the SynthDescLib: events then send every control of a sound, not just freq/amp)
	self.defs.do { |d| d.add; msgs.add([\d_recv, d.asBytes]) };
	// samples
	// samples: every buffer has 2 channels (a mono file is read into both); sampleMono remembers mono files
	self.sampleMono = Dictionary.new; self.sampleBuffers = Dictionary.new;
	self.loadSample = { |self, rel|
		if(self.sampleBuffers[rel].isNil) {
			// "repo:…" = a file in the repository's own samples/ folder, else under sc/samples/
			var path = if(rel.beginsWith("repo:")) { self.root.dirname +/+ "samples" +/+ rel.drop(5) } { self.root +/+ "samples" +/+ rel };
			var b = bufNum.(), ch = SoundFile.use(path, { |f| f.numChannels });
			self.sampleBuffers[rel] = b;
			self.sampleMono[rel] = ch == 1;
			msgs.add([\b_allocReadChannel, b, path, 0, 0] ++ if(ch == 1) { [0, 0] } { [0, 1] });
		};
		self.sampleBuffers[rel]
	};
	// samples: buffer args of the sound; files: the files a sound's notes pick by name (a wrapper sound, sounds/README.md)
	self.sounds.do { |snd| ((snd.samples ? ()).values ++ (snd[\files] ? [])).do { |rel| self.loadSample(rel) } };
	(track.samples ? []).do { |rel| self.loadSample(rel) };
	// wavetables (sounds with `wavetables: (arg: \shape)`): 4 consecutive buffers per shape
	self.wavetableBase = ();
	self.sounds.do { |snd| (snd.wavetables ? ()).do { |shape|
		if(self.wavetableBase[shape].isNil) {
			var base = server.bufferAllocator.alloc(4);
			self.wavetableBase[shape] = base;
			self.wavetableHarmonics.do { |n, i|
				msgs.add([\b_alloc, base + i, 8192]);
				msgs.add([\b_gen, base + i, \sine1, 6] ++ (1..n).collect(self.wavetableShapes[shape]));
			}
		}
	} };
	// groups in order
	[\ctl, \src, \strips, \fx, \master].do { |g| msgs.add([\g_new, self.groups[g], 1, 0]) };   // tail of root, in order
	// global column
	msgs.add([\s_new, \ce_global, node.(), 0, self.groups.ctl,
		\toneOut, self.toneBus, \fogOut, self.fogBus, \thinOut, self.thinBus,
		\fog, self.ccMap(track.global.fog), \thin, self.ccMap(track.global.thin), \tension, self.ccMap(track.global.tension)]);
	// map buses: values the track derives from controls on the server (e.g. a sound blend from one knob), so they
	// follow the knob at once. maps: (name: (ccs: [cc, …], fn: { |in0, in1, …| ugen }))
	// state buses (track.states: (name: start value)): set by the language (~ce.setState), read by synths / strips
	self.stateBus = (); self.stateVal = ();
	(track.states ? ()).keysValuesDo { |name, v0|
		var bus = ctl.(); self.stateBus[name] = bus; self.stateVal[name] = v0; msgs.add([\c_set, bus, v0]) };
	self.stateMap = { |self, name| ("c" ++ self.stateBus[name]).asSymbol };
	self.mapBus = ();
	(track.maps ? ()).keysValuesDo { |name, m|
		var bus = ctl.(), def = SynthDef(("ce_map_" ++ name).asSymbol, { |out|
			Out.kr(out, m[\fn].valueArray(m.ccs.collect { |cc| Lag.kr(In.kr(self.ccIndex(cc)), 0.02) }))
		});
		self.mapBus[name] = bus;
		def.add;
		msgs.add([\d_recv, def.asBytes]);
		msgs.add([\s_new, def.name, node.(), 1, self.groups.ctl, \out, bus]);
	};
	// orbit returns
	self.orbitBus = (); self.orbitDelayBus = (); self.orbitDelayNode = ();
	// part of an IR file (both channels) as PartConv spectra: [left, right]
	prep = { |path, start, len, fft| var specSize = fft * (len / (fft / 2)).roundUp.asInteger;
		[0, 1].collect { |ch| var ir = bufNum.(), spec = bufNum.();
			msgs.add([\b_allocReadChannel, ir, path, start, len, ch]);
			msgs.add([\b_alloc, spec, specSize]);
			msgs.add([\b_gen, spec, "PreparePartConv", ir, fft]);
			spec } };
	(track.orbits ? ()).keysValuesDo { |n, o|
		var bus = aud.(), bs = server.options.blockSize, headSize = 2 * bs, tailSize = 2048, head = (tailSize / 2) - bs;
		// an IR measured at the server's sample rate if there is one (ir/orbit-0.6-44100.wav), else the 48 kHz one
		var sr = (server.sampleRate ? 48000).round.asInteger;
		var alt = self.root +/+ "samples" +/+ o.ir.splitext[0] ++ "-" ++ sr ++ ".wav";
		var path = if(File.exists(alt)) { alt } { self.root +/+ "samples" +/+ o.ir };
		var frames = SoundFile.use(path, { |f| f.numFrames }), h, t;
		self.orbitBus[n] = bus;
		if(o[\delay].notNil) {
			var dbus = aud.(), dnode = node.();
			self.orbitDelayBus[n] = dbus; self.orbitDelayNode[n] = dnode;
			msgs.add([\s_new, \ce_delay, dnode, 1, self.groups.fx, \in, dbus, \out, self.masterIn,
				\time, o[\delay][0], \feedback, o[\delay][1]]);
		};
		// IR head (first `head` frames, small FFT) and tail (the rest, big FFT), per channel: see ce_reverb
		h = prep.(path, 0, head, headSize); t = prep.(path, head, frames - head, tailSize);
		msgs.add([\s_new, \ce_reverb, node.(), 1, self.groups.fx, \in, bus, \out, self.masterIn,
			\headL, h[0], \headR, h[1], \tailL, t[0], \tailR, t[1], \headSize, headSize, \tailSize, tailSize]);
	};
	// a stem with its own echo (ownDelay: [time, feedback]): its delay line instead of the orbit's, so columns with
	// different echo times do not keep resetting one shared delay (notes set it with n_set on stemDelayNode)
	self.stemDelayBus = (); self.stemDelayNode = ();
	track.stems.do { |st| st[\ownDelay] !? { |d| var dbus = aud.(), dnode = node.();
		self.stemDelayBus[st.name] = dbus; self.stemDelayNode[st.name] = dnode;
		msgs.add([\s_new, \ce_delay, dnode, 1, self.groups.fx, \in, dbus, \out, self.masterIn, \time, d[0], \feedback, d[1]]) } };
	// stems: an audio bus and a strip each; a stem with lanes (layers on other orbits or with another echo) gets
	// one bus and strip per lane, all on the stem's fader. Notes pick their lane with \lane (default: the first).
	self.stemBus = (); self.levelSrc = (); self.stripNode = ();
	track.stems.do { |st|
		var snd = self.sounds[st.sounds[0]], lanes = st.lanes ?? { [(name: \main)] };
		var val = { |x| if(x.isKindOf(Symbol)) { ("c" ++ self.mapBus[x]).asSymbol } { x } };
		self.stemBus[st.name] = (); self.levelSrc[st.name] = (); self.stripNode[st.name] = ();
		lanes.do { |ln, i|
			var bus = aud.(), orbit = ln.orbit ? st.orbit, space = ln.space ? st.space, id = node.();
			self.stemBus[st.name][ln.name] = bus;
			self.stripNode[st.name][ln.name] = id;
			// the fader (a CC, a state bus or a number; a lane may have its own): read at each note's start (noteLevel)
			self.levelSrc[st.name][ln.name] = ln[\level] ? st.level;
			if(i == 0) { self.stemBus[st.name][\main] = bus; self.levelSrc[st.name][\main] = ln[\level] ? st.level };
			msgs.add([\s_new, \ce_strip, id, 1, self.groups.strips,
				\in, bus, \out, self.masterIn, \hpOwn, st.hpOwn ? snd.hpf, \thinOn, (st[\thin] != false).asInteger,
				// the fader is not here (it acts per note, see noteLevel); fade: a lane's level that acts at once on
				// sounding notes (a crossfade between layers): a state bus (symbol) or a number
				\level, (ln[\fade] ? st[\fade]) !? { |x| if(x.isKindOf(Symbol)) { self.stateMap(x) } { x } } ? 1,
				// master: a CC; a track without a master fader (global.master nil, e.g. 016: its column 8 fader is Wumms) = 1
				\master, (st[\master] ? track.global.master) !? { |m| self.ccMap(m) } ? 1,
				// room / echo amount of a lab column: a state bus (symbol) or a fixed number
				\rDirect, (ln[\roomR] ? st[\roomR]) !? { |x| if(x.isKindOf(Symbol)) { self.stateMap(x) } { x } } ? -1,
				\dDirect, (ln[\echoSend] ? st[\echoSend]) !? { |x| if(x.isKindOf(Symbol)) { self.stateMap(x) } { x } } ? -1,
				\tEchoOn, ((ln[\tensionEcho] ? st[\tensionEcho]) != false).asInteger,
				\trim, val.(st.trim ? 1),
				\thinF, ("c" ++ self.thinBus).asSymbol,
				// space: a CC, or a fixed number when given as (fixed: 0.3)
				\space, if(space.isKindOf(Event)) { space.fixed } { if(space.isNil) { 0 } { self.ccMap(space) } },
				\tension, if(st[\tension] == false) { 0 } { self.ccMap(track.global.tension) },
				\roomOut, self.orbitBus[orbit] ? 0, \roomOn, (self.orbitBus[orbit].notNil).asInteger,
				\delayOut, self.stemDelayBus[st.name] ? self.orbitDelayBus[orbit] ? 0,
				\delayOn, (((ln[\echo] ? st[\echo]).notNil or: { (ln[\echoSend] ? st[\echoSend]).notNil })
					and: { (self.stemDelayBus[st.name] ? self.orbitDelayBus[orbit]).notNil }).asInteger,
				\echo, val.(ln[\echo] ? st[\echo] ? 0)]);
		};
	};
	msgs.add([\s_new, \ce_master, node.(), 0, self.groups.master, \in, self.masterIn, \out, self.mainOut ? 0, \trimDb, self.trimDb, \limit, self.limit]);
	msgs.asArray
};

// The fader of a stem's lane now (0..1), read when a note starts: as Strudel's postgain, a fader change is heard from
// the next note on, sounding notes keep their level. nil: no fader (level 1).
~ce.noteLevel = { |self, stem, lane|
	var src = self.levelSrc !? { |l| l[stem] !? { |s| s[lane ? \main] ?? { s[\main] } } };
	case
	{ src.isNil } { 1 }
	{ src.isKindOf(Symbol) } { self.stateVal[src] ? 0 }
	{ src.isKindOf(Float) } { src }
	{ self.val(src) }
};

// Live: send the set-up messages in three steps (files and SynthDefs load asynchronously, wavetables and reverb
// spectra are computed from loaded buffers, then the synths start). Call inside a Routine (s.sync).
~ce.sendInit = { |self, msgs|
	var s = self.server, first = [\d_recv, \b_alloc, \b_allocRead, \b_allocReadChannel], second = [\b_gen];
	msgs.select { |m| first.includes(m[0]) }.do { |m| s.sendMsg(*m) };
	s.sync;
	msgs.select { |m| second.includes(m[0]) }.do { |m| s.sendMsg(*m) };
	s.sync;
	s.sendBundle(nil, *msgs.reject { |m| first.includes(m[0]) or: { second.includes(m[0]) } });
	s.sync;
};

// Language side of the track (latches, buttons) and its stem patterns, as one Ppar.
~ce.patterns = { |self|
	var track = self.track;
	track.build(self);
	Ppar(track.stems.collect { |st|
		self.stepPattern(st.name, st[\notes], self.stemBus[st.name], self.groups.src)
	})
};
)
