// Controls: every CC (0..127) has a control bus and a language-side value. Knobs and faders go to the bus the
// moment the message arrives (no scheduling latency); synths read the buses continuously (Lag against zipper noise).
// Buttons: the press (rising edge) counts. Pattern switches wait for the bar: latches (port of the Strudel barLatch).
// Several Launch Controls: every message simply writes the bus, so the control moved last wins.
(
// Bus of a CC (after aliasing): first allocated by ~ce.init
~ce.ccIndex = { |self, cc| var c = self.ccAlias[cc] ? cc; self.ccBase + c };
~ce.ccMap = { |self, cc| ("c" ++ self.ccIndex(cc)).asSymbol };   // for synth args: reads the bus continuously

// Set a CC to v (0..1): language copy, presses, and the bus. send: a function taking one OSC message
// (live: sends now; score: puts it into the score at the current time).
~ce.setCC = { |self, cc, v, send, force = false|
	var c = self.ccAlias[cc] ? cc, was = self.cc[c];
	self.cc[c] = v;
	send.([\c_set, self.ccBase + c, v]);
	self.uiSend('/ce/cc', c, v);
	// column state (lab columns keep their start values until a control moves; as Strudel, only a change counts)
	if(force or: { v != was }) { (self.ccHooks[c] ? []).do { |f| f.(v, send) } };
	if(v > 0.5 and: { was <= 0.5 }) { (self.pressFns[c] ? []).do(_.value); self.uiPush };
};
// fn(value, send) on every message of a CC (send: as in setCC, for state buses)
~ce.ccHooks = ();
~ce.onCC = { |self, cc, fn| var c = self.ccAlias[cc] ? cc; self.ccHooks[c] = (self.ccHooks[c] ? []).add(fn) };
// State bus: a control bus the language sets (a lab column's level, room, echo …): synths and strips map it
~ce.setState = { |self, name, v, send| self.stateVal[name] = v; send.([\c_set, self.stateBus[name], v]) };
~ce.onPress = { |self, cc, fn| var c = self.ccAlias[cc] ? cc; self.pressFns[c] = (self.pressFns[c] ? []).add(fn) };
~ce.held = { |self, cc| self.cc[self.ccAlias[cc] ? cc] > 0.5 };
~ce.val = { |self, cc| self.cc[self.ccAlias[cc] ? cc] };

// Momentary button that steps through n states, one step per press (Strudel cycleButton)
~ce.cycleButton = { |self, cc, n, onChange|
	var b = (state: 0);
	self.onPress(cc, { b.state = (b.state + 1) % n; onChange.(b.state) });
	b
};

// A value that a button sets now but that takes over only at the next bar (len = 1) or next len-bar phrase.
// atBar(bar) is asked with the bar of the note being made; it remembers the previous value for notes that still
// belong to the old bar (port of barLatch in the Strudel tracks).
// Every latch is asked once per 16th by the step engine (~ce.tickLatches), whether a stem needs it or not, so it
// switches at its own bar line even while nobody reads it (the Strudel tracks query them via stateTaps).
~ce.latches = List[];
~ce.tickLatches = { |self, bar| self.latches.do { |l| l.atBar(bar) } };
~ce.latch = { |self, len = 1, start = 0, onSwitch|
	var l = (pending: start, now: start, prev: start, bar: -inf, len: len);
	self.latches.add(l);
	l.atBar = { |l, bar|
		var b = (bar / l.len).floor;
		if(b > l.bar) {
			if(l.pending != l.now) { l.prev = l.now; l.now = l.pending; onSwitch.(l.now) } { l.prev = l.now };
			l.bar = b;
		};
		if(b >= l.bar) { l.now } { l.prev }
	};
	l
};
// Button → latch: each press picks the next of n patterns, taking over at the next bar (Strudel `change`)
~ce.change = { |self, cc, n, label, names, len = 1|
	var l = self.latch(len, 0, { |i| self.status(label, names !? { names[i] } ? i); self.uiPush });
	self.cycleButton(cc, n, { |s| l.pending = s; self.status(label ++ " (next)", names !? { names[s] } ? s) });
	// the UI shows the choice on button 1 of its column (Mode 1: CC 37-43, Mode 2: CC 85-91)
	self.uiRows[(if(cc > 52) { "jonas:" ++ (cc - 84) } { "jojo:" ++ (cc - 36) }).asSymbol] = (latch: l, names: names);
	l
};
~ce.status = { |self, label, value| if(self.quiet != true) { "▣ %: %".format(label, value).postln } };

// Live MIDI: controllers are found automatically, also when they are plugged in later (checked every 2 s).
// What a controller does is decided by its port name (midiKinds, first match wins):
//   lc        every Launch Control XL 3 gets the full layout (Mode 1 + Mode 2 + column 8); with several, the control
//             moved last wins (every message writes the bus). Its DAW port is ignored.
//   launchkey the Launchkey MK4 25: its own stem as in the Strudel tracks: keys and drum pads (channel 10) play at
//             once (the track's lkNote), its mod wheel and knobs (CC 1, 21-28) go to ~ce.lkCC and the track's lkCtl
//             (its own controls, apart from the LC's: its knobs would collide with the LC knobs).
//   (none)    any other controller: listed in the post window, ignored, so it cannot change the track by accident.
~ce.midiKinds = [
	[\lc, { |n| n.contains("LCXL3") and: { n.contains("DAW").not } }],
	[\launchkey, { |n| n.contains("Launchkey") and: { n.contains("DAW").not } }],
];
~ce.midiKindOf = { |self, portName| var hit = self.midiKinds.detect { |k| k[1].(portName) }; hit !? { hit[0] } };
~ce.midiPorts = ();    // uid → (name, kind)
~ce.lkCC = 0 ! 128;
// One CC message from a port (also usable without hardware, for tests)
// The LC XL 3 knobs are endless but each device keeps its own value and sends it absolutely: with two Launch Controls
// (or a knob moved in the web view), turning a knob on the other device would jump the value to that device's own
// number. So a knob message counts as a MOVE, scaled to what is left ("value scaling"): turning up, the device's
// remaining travel to 127 is spread over the shared value's remaining range to 1 (turning down: to 0 over to 0), so
// both ends are always reachable and nothing jumps; where device and shared value agree it is 1:1. A device's first
// message for a knob only sets its reference (no change). Faders stay absolute (physical position).
~ce.lcRaw = ();   // uid → (cc → the last raw value 0..127 this Launch Control sent)
~ce.isKnobCC = { |self, cc| (cc >= 13 and: { cc <= 36 }) or: { cc >= 61 and: { cc <= 84 } } };
~ce.midiCC = { |self, val, num, uid|
	switch(self.midiPorts[uid] !? { |p| p.kind },
		\lc, {
			if(self.isKnobCC(num)) {
				var raw = self.lcRaw[uid] ?? { var e = (); self.lcRaw[uid] = e; e }, last = raw[num];
				raw[num] = val;
				if(last.notNil and: { val != last }) {
					var cur = self.val(num), next = if(val > last) {
						cur + ((val - last) * (1 - cur) / (127 - last))
					} { cur - ((last - val) * cur / last) };
					self.setCC(num, next.clip(0, 1), { |msg| self.server.sendMsg(*msg) }) }
			} { self.setCC(num, val / 127, { |msg| self.server.sendMsg(*msg) }) }
		},
		\launchkey, { self.setLkCC(num, val / 127, { |msg| self.server.sendMsg(*msg) }) }
	)
};
// A Launchkey control: kept in lkCC; the track may turn it into state buses (lkCtl: level, room, echo)
~ce.setLkCC = { |self, num, v, send| self.lkCC[num] = v; self.track !? { |t| t[\lkCtl] !? { |f| f.(self, num, v, send) } };
	self.uiSend('/ce/lkcc', num, v) };
// A Launchkey key or pad (chan 0-based: 9 = MIDI channel 10, the drum pads): the track's notes, played at once —
// sent without a time stamp, so the server starts them on arrival (a few ms: audio buffer + MIDI), not with the
// patterns' look-ahead (s.latency). Offline renders play them as \ceLk events.
~ce.midiNote = { |self, note, vel, chan, uid|
	if(self.midiPorts[uid] !? { |p| p.kind } == \launchkey and: { vel > 0 }) { self.lkPlay(note, vel / 127, chan) } { [] }
};
// A Launchkey key / pad from the device or the web UI: the track's notes at once; the UI lights the key / pad
~ce.lkPlay = { |self, note, vel, chan|
	var notes = self.track !? { |t| t[\lkNote] !? { |f| f.(self, note, vel, chan) } } ? [];
	self.uiSend('/ce/lknote', note, chan);
	self.playNow(notes, self.stemBus[\lk], self.groups.src, \lk)
};
// Notes as the tracks make them (ce.note …, \lane, \hold in 16ths, \msg entries), started immediately
~ce.playNow = { |self, notes, lanes, group, stem|
	var bps = TempoClock.default.tempo, srv = self.server;
	// returns the node ids of the started synths; the fader at this moment (noteLevel), a note at level 0 is not played
	notes.collect { |n|
		var lv = self.noteLevel(stem, n[\lane]);
		if(n[\msg].notNil) { srv.sendMsg(*n[\msg]); nil } { if(lv <= 0) { nil } {
			var desc = SynthDescLib.global[n[\instrument]], args = List[], id = srv.nextNodeID;
			var e = n.copy.putAll((out: lanes[n[\lane] ? \main], hold: (n[\hold] ? 1) / 4 / bps, post: (n[\post] ? 1) * lv));
			desc !? { desc.controlNames.do { |k| e[k] !? { |v| args.add(k).add(v) } } };
			srv.sendMsg(\s_new, n[\instrument], id, 0, group.asNodeID, *args);
			id
		} }
	}.reject(_.isNil)
};
// Connect every port not yet connected; report what is new or gone
~ce.scanMidi = { |self|
	var now = (), found = List[];
	MIDIClient.list;   // re-read the ports (new plug-ins)
	MIDIClient.sources.do { |e|
		var name = e.device ++ " / " ++ e.name;
		now[e.uid] = name;
		if(self.midiPorts[e.uid].isNil) {
			var kind = self.midiKindOf(name);
			MIDIIn.connect(0, e);
			self.midiPorts[e.uid] = (name: name, kind: kind);
			found.add(name -> kind);
		}
	};
	found.do { |f| "MIDI connected: %  → %".format(f.key, f.value ? "ignored (unknown controller)").postln };
	if(found.notEmpty) { self.uiPorts };
	self.midiPorts.keys.copy.do { |uid| if(now[uid].isNil) {
		"MIDI gone: %".format(self.midiPorts[uid].name).postln; self.midiPorts.removeAt(uid); self.uiPorts } };
	if(found.notEmpty and: { self.midiPorts.values.any { |p| p.kind == \lc }.not }) {
		"No Launch Control XL 3 yet: plug one in, it is picked up within 2 s".warn };
};
~ce.connectMidi = { |self|
	MIDIClient.initialized.not.if { MIDIClient.init(verbose: false) };
	MIDIdef.cc(\ce_midi, { |val, num, chan, src| self.midiCC(val, num, src) }).permanent_(true);
	MIDIdef.noteOn(\ce_midi_notes, { |vel, note, chan, src| self.midiNote(note, vel, chan, src) }).permanent_(true);
	self.scanMidi;
	if(self.midiPorts.values.any { |p| p.kind == \lc }.not) {
		"No Launch Control XL 3 found: plug one in, it is picked up within 2 s".warn };
	self.midiWatch.stop;
	self.midiWatch = SkipJack({ self.scanMidi }, 2, name: "ce_midi_watch");
};
);

// Scenario control change while rendering: sets the CC like a MIDI message would, at the event's time
(
Event.addEventType(\ceCtl, {
	var sb = ~schedBundleArray, srv = ~server, ce = topEnvironment[\ce];
	ce.setCC(~cc, ~v, { |msg| sb.(0, 0, srv, [msg]) }, ~force ? false);
});
// Scenario Launchkey control (lkCc, v) or key / pad (key, vel, chan) while rendering (not \note: Events have one)
Event.addEventType(\ceLk, {
	var sb = ~schedBundleArray, srv = ~server, ce = topEnvironment[\ce], parent = currentEnvironment;
	if(~key.isNil) { ce.setLkCC(~lkCc, ~v, { |msg| sb.(0, 0, srv, [msg]) }) } {
		var notes = ce.track[\lkNote].(ce, ~key, ~vel, ~chan) ? [];
		if(notes.notEmpty) {
			var e = (type: \ceMulti, notes: notes.reject { |n| n[\msg].notNil }, msgs: notes.select { |n| n[\msg].notNil },
				lanes: ce.stemBus[\lk], group: ce.groups.src, stem: \lk);
			[\server, \latency, \schedBundleArray, \schedBundle].do { |k| e[k] = parent[k] };
			e.play
		}
	}
});
)
