// Web UI link (sc/ui/bridge.mjs, see sc/ui/README.md). The controllers never go through it: MIDI goes straight to
// SuperCollider; if the browser or the bridge stops, the music and the controllers go on.
// SC → bridge (UDP 57130): /ce/layout json · /ce/cc cc value · /ce/state json · /ce/beat bar beat chord · /ce/midi json
// bridge → SC: /ce/hello (send everything again) · /ce/cc cc value (a click in the UI: the same as a MIDI message)
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

// Layout tags from the track file: // @mode, @col, @ctl lines (same format as the Strudel tracks and the layout sheets)
~ce.uiTags = { |self|
	var tags = ();
	if(self.trackFile.notNil) {
		File.readAllString(self.trackFile).split($\n).do { |line|
			var m = line.findRegexp("^// @(layout|mode|col|ctl) ([^ ]+) (.*)$");
			if(m.notEmpty) { tags[m[2][1]] = m[3][1] };
		}
	};
	tags
};
~ce.uiLayout = { |self| self.uiSend('/ce/layout', self.toJSON((name: self.track.name, bpm: self.track.bpm, tags: self.uiTags))) };

// State: what each pattern button has chosen (now, next) per column, plus the track's head line (chapter, chords,
// break). ce.change registers the column rows; the track adds its head with uiHead.
~ce.uiRows = ();
~ce.uiState = { |self|
	var rows = (), head = self.track[\uiHead] !? { |f| f.(self.track, self) } ? [];
	self.uiRows.keysValuesDo { |key, r|
		var show = { |i| r.names !? { r.names[i] } ? (i + 1).asString };
		rows[key] = [show.(r.latch.now), show.(r.latch.pending)]
	};
	// cols: what a lab column really uses (its start values until a control moves), button texts: track.uiCols
	(rows: rows, head: head, global: self.track[\uiGlobal] !? { |f| f.(self.track, self) })
		++ (self.track[\uiCols] !? { |f| f.(self.track, self) } ? ())
};
~ce.uiPush = { |self| if(self.uiOn) { self.uiSend('/ce/state', self.toJSON(self.uiState)) } };
~ce.uiPorts = { |self| self.uiSend('/ce/midi', self.toJSON(self.midiPorts.values.asArray.collect { |p| [p.name, p.kind] })) };

~ce.startUI = { |self|
	self.uiOn = true;
	OSCdef(\ce_ui_cc, { |msg| self.setCC(msg[1].asInteger, msg[2].asFloat.clip(0, 1), { |m| self.server.sendMsg(*m) }) }, '/ce/cc').permanent_(true);
	OSCdef(\ce_ui_hello, { self.uiHello }, '/ce/hello').permanent_(true);
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
	self.uiPush;
	self.uiPorts;
};
~ce.stopUI = { |self| self.uiOn = false; self.uiBeat !? (_.stop); OSCdef(\ce_ui_cc).free; OSCdef(\ce_ui_hello).free };
);
