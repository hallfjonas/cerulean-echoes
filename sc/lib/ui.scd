// Web UI link (sc/ui/bridge.mjs, see sc/ui/README.md). The controllers never go through it: MIDI goes straight to
// SuperCollider; if the browser or the bridge stops, the music and the controllers go on.
// SC → bridge (UDP 57130): /ce/layout json · /ce/cc cc value · /ce/state json · /ce/beat bar beat chord · /ce/midi json
//                  /ce/lkcc num value · /ce/lkccs json · /ce/lknote note chan (Launchkey: controls, a key / pad played)
//                  /ce/spectrum 48 floats (the master output, 20 Hz-20 kHz log, 0..1 = -60..0 dB, ~20 times a second)
//                  /ce/setsample energy punch tension b1..b64 (every 10 s, for the set view: energy in dB, punch and
//                  tension 0..1, 64 bands 20 Hz-20 kHz log, 0..1 = -60..0 dB; see uiSetFrame)
//                  /ce/level peak (the master's peak 0..1 of the last 100 ms, 10 times a second: the recording meter)
// bridge → SC: /ce/hello (send everything again) · /ce/cc cc value (a click in the UI: the same as a MIDI message)
//              /ce/lkcc num value · /ce/lknote note velocity chan (the Launchkey row: as the device would send)
(
~ce.uiAddr = NetAddr("127.0.0.1", 57130);
~ce.uiOn = false;
~ce.uiSend = { |self ... msg| if(self.uiOn) { try { self.uiAddr.sendMsg(*msg) } } };

// Tiny JSON writer (Events/Dictionaries, Arrays, Strings/Symbols, numbers, booleans, nil)
~ce.toJSON = { |self, x|
	case
	{ x.isNil } { "null" }
	{ x == true } { "true" } { x == false } { "false" }
	{ x.isKindOf(Symbol) or: { x.isString } } {
		"\"" ++ x.asString.collectAs({ |c| switch(c, $", { "\\\"" }, $\\, { "\\\\" }, $\n, { "\\n" }, $\t, { "\\t" }, { c.asString }) }, Array).join ++ "\"" }
	{ x.isNumber } { if(x.isNaN or: { x.abs == inf }) { "null" } { if(x.isInteger) { x.asString } { x.asFloat.round(1e-5).asString } } }
	{ x.isKindOf(Dictionary) } { "{" ++ x.keys.asArray.sort.collect { |k| self.toJSON(k.asString) ++ ":" ++ self.toJSON(x[k]) }.join(",") ++ "}" }
	{ x.isKindOf(SequenceableCollection) } { "[" ++ x.collect { |e| self.toJSON(e) }.join(",") ++ "]" }
	{ self.toJSON(x.asString) }
};

// Layout tags from the track file: // @mode, @col, @ctl lines (same format as the Strudel tracks); a stem track
// brings them as tagLines (made from its stems and frame, see stemtrack.scd)
~ce.uiTags = { |self|
	var tags = (self.track !? { |t| t[\tags] } ? ()).copy;   // a track without a file of its own (Sample Designer)
	var lines = self.track !? { |t| t[\tagLines] } ?? {
		if(self.trackFile.notNil) { File.readAllString(self.trackFile).split($\n) } { [] } };
	lines.do { |line|
		var m = line.findRegexp("^// @(layout|mode|col|ctl|lk) ([^ ]+) (.*)$");
		// @lk lines (the Launchkey row) as lk.<key>, as the Strudel view reads them
		if(m.notEmpty) { tags[if(m[1][1] == "lk") { "lk." ++ m[2][1] } { m[2][1] }] = m[3][1] };
	};
	tags
};
~ce.uiLayout = { |self| self.uiSend('/ce/layout', self.toJSON((name: self.track.name, bpm: self.track.bpm, tags: self.uiTags,
	lkPads: self.track[\lkPadNames]))) };

// State: what each pattern button has chosen (now, next) per column, plus the track's head line (chapter, chords,
// break). ce.change registers the column rows; the track adds its head with uiHead.
~ce.uiRows = ();
~ce.uiState = { |self|
	var rows = (), head = self.track[\uiHead] !? { |f| f.(self.track, self) } ? [];
	self.uiRows.keysValuesDo { |key, r|
		var show = { |i| r.names !? { r.names[i] } ? (i + 1).asString };
		rows[key] = [show.(r.latch.now), show.(r.latch.pending)]
	};
	// cols: what a lab column really uses (its start values until a control moves), button texts: track.uiCols;
	// keys: the column the Launchkey keys play (a stem track's lkKeys) and the knob that picks it
	(rows: rows, head: head, global: self.track[\uiGlobal] !? { |f| f.(self.track, self) })
		++ (self.track[\uiCols] !? { |f| f.(self.track, self) } ? ())
		++ (self.track[\lkKeys] !? { |k| (keys: (slot: self.track[\lkKeysSlot].asString, label: self.lkColumnLabel,
			cc: k[\cc])) } ? ())
};
~ce.uiPush = { |self| if(self.uiOn) { self.uiSend('/ce/state', self.toJSON(self.uiState)) } };
~ce.uiPorts = { |self| self.uiSend('/ce/midi', self.toJSON(self.midiPorts.values.asArray.collect { |p| [p.name, p.kind] })) };

// Spectrum of the master output for the UI: an analyser at the tail of the server's root group (after every track
// synth) reads the output bus (mono sum), 48 band-passes, logarithmic 20 Hz-20 kHz, each band's level as 0..1
// (-60..0 dB, 0 dB = a full-scale sine in the band), sent 20 times a second. Bands above 0.45 x the sample rate read 0.
// Made by startUI, freed by stopUI (the engine frees all nodes on every load and calls startUI again).
~ce.uiSpecStart = { |self|
	var srv = self.server, n = 48, ratio = 1000 ** (1 / n);
	var freqs = n.collect { |i| 20 * (1000 ** ((i + 0.5) / n)) }, rq = ratio.sqrt - ratio.sqrt.reciprocal;
	var def = SynthDef(\ceSpectrum, {
		var out = In.ar(0, 2), sig = out.sum * 0.5, top = SampleRate.ir * 0.45, tick = Impulse.kr(10);
		var levels = freqs.collect { |f|
			Amplitude.kr(BPF.ar(sig, f.min(top), rq), 0.01, 0.15).ampdb.linlin(-60, 0, 0, 1) * (f < top) };
		// for the set view, 10 times a second: the loudness power (both channels, roughly K-weighted: +4 dB shelf above
		// 1.5 kHz, high-pass 40 Hz; ~100 ms window), and peak and RMS of the mono sum over the last 100 ms (crest factor)
		var kw = HPF.ar(BHiShelf.ar(out, 1500, 1, 4), 40).squared.sum;
		var power = A2K.kr(Lag.ar(kw, 0.7)), rms = A2K.kr(Lag.ar(sig.squared, 0.7)).sqrt;
		var peak = Peak.kr(sig, Delay1.kr(tick));   // reset one block after each send
		SendReply.kr(Impulse.kr(20), '/ce/spec', levels);
		SendReply.kr(tick, '/ce/lvl', [power, peak, rms]);
	});
	self.uiSpecStop;
	self.uiSpec = srv.nextNodeID;
	OSCdef(\ce_ui_spec, { |msg| if(msg[1] == self.uiSpec) {
		self.uiSend('/ce/spectrum', *msg.drop(3));
		self.uiSetFrame(\spec, msg.drop(3));
	} }, '/ce/spec').permanent_(true);
	OSCdef(\ce_ui_lvl, { |msg| if(msg[1] == self.uiSpec) { self.uiSetFrame(\lvl, msg.drop(3)); self.uiSend('/ce/level', msg[4]) } }, '/ce/lvl').permanent_(true);
	def.send(srv, ['/s_new', \ceSpectrum, self.uiSpec, 1, 0]);   // add to the tail of the root group (node 0)
};
~ce.uiSpecStop = { |self|
	OSCdef(\ce_ui_spec).free; OSCdef(\ce_ui_lvl).free;
	self.uiSpec !? { |id| if(self.server.serverRunning) { self.server.sendMsg('/n_free', id) } };
	self.uiSpec = nil;
};

// Set view (UI-REDESIGN.md "Set view"): one sample of the master output every 10 s, from the analyser above (no
// extra synth). The running sums live in topEnvironment (~ceSetAcc), so a track load (a fresh ~ce, all nodes freed,
// startUI again) does not lose the 10 s in progress; after a pause of more than 5 s (stopped) it starts afresh.
// Every 100 level frames (10 s): energy = mean loudness power in dB (-0.691 offset as in LUFS; floor -70), punch =
// mean crest factor (peak / RMS of each 100 ms, frames above -60 dB) mapped 3..18 dB -> 0..1, tension = the Tension
// control (column 8 knob row 3, CC 36) averaged, and the 48 spectrum bands averaged and resampled to 64 (same log
// range). The history itself is kept by the player's link (sc-link.mjs) / bridge.mjs, not here.
~ce.uiSetFrame = { |self, kind, vals|
	var acc = topEnvironment[\ceSetAcc], now = Main.elapsedTime, fast = topEnvironment[\ceFastAcc];
	// every second as well (10 level frames): /ce/setfast energy (dB, as below) and 12 band groups (4 of the 48 each),
	// for the set view's fine views (last minute at 1-2 s, spectrogram in 12 rows)
	if(fast.isNil or: { now - fast[\lastAt] > 5 }) { fast = (lastAt: now, frames: 0, powSum: 0, bandSum: 0 ! 48, bandN: 0); topEnvironment[\ceFastAcc] = fast };
	fast[\lastAt] = now;
	if(kind == \spec) { fast[\bandSum] = fast[\bandSum] + vals.keep(48); fast[\bandN] = fast[\bandN] + 1 } {
		fast[\frames] = fast[\frames] + 1; fast[\powSum] = fast[\powSum] + vals[0];
		if(fast[\frames] >= 10) {
			var mean = fast[\powSum] / fast[\frames], avg = fast[\bandSum] / fast[\bandN].max(1);
			self.uiSend('/ce/setfast', if(mean > 0) { (10 * mean.log10 - 0.691).max(-70) } { -70 },
				*12.collect { |g| avg.copyRange(g * 4, g * 4 + 3).sum / 4 });
			topEnvironment[\ceFastAcc] = nil;
		};
	};
	if(acc.isNil or: { now - acc[\lastAt] > 5 }) {
		acc = (lastAt: now, frames: 0, powSum: 0, crestSum: 0, crestN: 0, tensSum: 0, bandSum: 0 ! 48, bandN: 0);
		topEnvironment[\ceSetAcc] = acc };
	acc[\lastAt] = now;
	if(kind == \spec) { acc[\bandSum] = acc[\bandSum] + vals.keep(48); acc[\bandN] = acc[\bandN] + 1 } {
		var power = vals[0], peak = vals[1], rms = vals[2];
		acc[\frames] = acc[\frames] + 1;
		acc[\powSum] = acc[\powSum] + power;
		acc[\tensSum] = acc[\tensSum] + (self.cc[36] ? 0);
		if(rms > 0.001) { acc[\crestSum] = acc[\crestSum] + (peak / rms).ampdb; acc[\crestN] = acc[\crestN] + 1 };
		if(acc[\frames] >= 100) {
			var mean = acc[\powSum] / acc[\frames], avg = acc[\bandSum] / acc[\bandN].max(1);
			var energy = if(mean > 0) { (10 * mean.log10 - 0.691).max(-70) } { -70 };
			var punch = if(acc[\crestN] > 0) { (acc[\crestSum] / acc[\crestN]).linlin(3, 18, 0, 1) } { 0 };
			var bands = 64.collect { |j| var p = ((j + 0.5) * 48 / 64 - 0.5).clip(0, 47), i = p.floor.asInteger.min(46);
				avg[i] + ((avg[i + 1] - avg[i]) * (p - i)) };
			self.uiSend('/ce/setsample', energy, punch, acc[\tensSum] / acc[\frames], *bands);
			topEnvironment[\ceSetAcc] = nil;
		};
	};
};

~ce.startUI = { |self|
	self.uiOn = true;
	self.uiSpecStart;
	OSCdef(\ce_ui_cc, { |msg| self.setCC(msg[1].asInteger, msg[2].asFloat.clip(0, 1), { |m| self.server.sendMsg(*m) }) }, '/ce/cc').permanent_(true);
	OSCdef(\ce_ui_hello, { self.uiHello }, '/ce/hello').permanent_(true);
	// the Launchkey row: a knob / the mod wheel, a key or pad (velocity 0-127, chan 0-based: 9 = pads)
	OSCdef(\ce_ui_lkcc, { |msg| self.setLkCC(msg[1].asInteger, msg[2].asFloat.clip(0, 1), { |m| self.server.sendMsg(*m) }) }, '/ce/lkcc').permanent_(true);
	OSCdef(\ce_ui_lknote, { |msg| self.lkPlay(msg[1].asInteger, msg[2].asInteger.clip(1, 127) / 127, msg[3].asInteger) }, '/ce/lknote').permanent_(true);
	self.uiHello;
	// bar and beat, sent when they sound (the patterns run s.latency ahead)
	self.uiBeat !? (_.stop);
	self.uiBeat = Routine { loop {
		var beat = thisThread.beats.round.asInteger, bar = (beat / 4).floor, chord = self.track[\uiChordAt] !? { |f| f.(self.track, bar) } ? "";
		SystemClock.sched(self.server.latency ? 0, { self.uiSend('/ce/beat', bar, beat % 4, chord); nil });
		1.wait
	} }.play(TempoClock.default, quant: 1);
};
~ce.uiHello = { |self|
	self.uiLayout;
	self.uiSend('/ce/ccs', self.toJSON(self.cc));
	self.uiSend('/ce/lkccs', self.toJSON(([1] ++ (21..28) ++ (31..38)).collect { |n| n -> self.lkCC[n] }.asDict));
	self.uiPush;
	self.uiPorts;
};
~ce.stopUI = { |self| self.uiOn = false; self.uiBeat !? (_.stop); self.uiSpecStop;
	[\ce_ui_cc, \ce_ui_hello, \ce_ui_lkcc, \ce_ui_lknote].do { |k| OSCdef(k).free } };
);
