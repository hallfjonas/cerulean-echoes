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
	if(self.isKnobCC(c)) { self.knobOut(c, v) };
	if(self.isFaderCC(c) and: { v != was }) { self.releasePickup(("c" ++ c).asSymbol) };
	if(v > 0.5 and: { was <= 0.5 }) { (self.pressFns[c] ? []).do(_.value); self.uiPush };
};
// fn(value, send) on every message of a CC (send: as in setCC, for state buses)
~ce.ccHooks = ();
~ce.onCC = { |self, cc, fn| var c = self.ccAlias[cc] ? cc; self.ccHooks[c] = (self.ccHooks[c] ? []).add(fn); self.own(\ccHooks, c, fn) };
// State bus: a control bus the language sets (a lab column's level, room, echo …): synths and strips map it
~ce.setState = { |self, name, v, send| self.stateVal[name] = v; send.([\c_set, self.stateBus[name], v]) };
~ce.onPress = { |self, cc, fn| var c = self.ccAlias[cc] ? cc; self.pressFns[c] = (self.pressFns[c] ? []).add(fn); self.own(\pressFns, c, fn) };
// Hooks and latches made inside ~ce.owning(owner, fn) belong to owner (a stem column) and leave with ~ce.dropHooks(owner),
// so a column swapped out of its slot stops reacting to the controls
~ce.own = { |self, where, key, item| self[\hookOwner] !? { |o| o[\hooks].add([where, key, item]) } };
~ce.owning = { |self, owner, fn| var was = self[\hookOwner];
	owner[\hooks] = owner[\hooks] ? List[]; self[\hookOwner] = owner; protect { fn.value } { self[\hookOwner] = was } };
~ce.dropHooks = { |self, owner|
	(owner[\hooks] ? []).do { |h| if(h[0] == \latches) { self.latches.remove(h[2]) } {
		self[h[0]][h[1]] = (self[h[0]][h[1]] ? []).reject { |f| f === h[2] } } };
	owner[\hooks] = List[] };
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
	self.own(\latches, nil, l);
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
// both ends are always reachable and nothing jumps; where device and shared value agree it is 1:1, and a step never
// moves less than 1:1 (user, 2026-11-21: far apart, the short side felt dead for many steps). A device's first
// message for a knob only sets its reference (no change). Faders stay absolute (physical position).
// Knob feedback (user test 2026-11-22, sc/tools/lc-feedback-test.scd: an LC XL 3 in a custom mode takes a CC sent to
// its MIDI In as the knob's new value): every knob change, from any source (an LC, the web view, a script, a load), is
// sent to every Launch Control, so each device always holds the shared value and every turn is 1:1; the value scaling
// above only acts if a device missed a message.
~ce.lcRaw = ();   // uid → (cc → the last raw value 0..127 this Launch Control sent or was sent)
~ce.lcOuts = ();  // uid → the Launch Control's MIDI In (a MIDIOut; tests: anything that answers control(chan, cc, value))
~ce.lcChan = ();  // cc → the MIDI channel (0-based) the Launch Controls send it on (learned; unknown: all 16)
~ce.knobOut = { |self, c, v|
	var b = (v * 127).round.asInteger.clip(0, 127), nums = [c] ++ self.ccAlias.keys.asArray.select { |k| self.ccAlias[k] == c };
	self.lcOuts.keysValuesDo { |uid, out|
		var raw = self.lcRaw[uid] ?? { var e = (); self.lcRaw[uid] = e; e };
		nums.do { |num|
			if(raw[num] != b) {
				raw[num] = b;
				{ var ch = self.lcChan[num]; if(ch.notNil) { out.control(ch, num, b) } { 16.do { |k| out.control(k, num, b) } } }
					.try { |e| "Launch Control feedback: %".format(e.errorString).warn } } } } };
// every knob to its current value on every Launch Control (after a load: the new track's values)
~ce.syncKnobs = { |self| ((13..36) ++ (61..84)).do { |c| if(self.ccAlias[c].isNil) { self.knobOut(c, self.cc[c]) } } };
// Faders and the Launchkey mod wheel have a physical position SC cannot set (no motor). Pickup ("soft takeover", user
// 2026-11-22): a device's fader changes nothing until it meets the current value (within 2 steps, or passing it between
// two messages); from then on 1:1. A value set from anywhere else (the other LC, the web view, a script, a load: the
// values start at 0) releases it again. The web view shows where an uncaught fader sits (/ce/phys key value; -1 = caught).
~ce.isFaderCC = { |self, cc| (cc >= 5 and: { cc <= 12 }) or: { cc >= 53 and: { cc <= 60 } } };
~ce.pickRaw = ();   // uid → (key → the device's last position 0..1)   key: \c<cc> (LC fader, after aliasing) or \lk1
~ce.caught = ();    // uid → (key → true once the device's fader has met the value)
~ce.releasePickup = { |self, key|
	self.caught.keysValuesDo { |uid, cg| if(uid != self.pickFrom and: { cg[key] == true }) { cg[key] = false;
		self.pickRaw[uid] !? { |r| r[key] !? { |p| self.uiSend('/ce/phys', key, p) } } } } };
~ce.pickup = { |self, uid, key, v, cur, set|
	var raw = self.pickRaw[uid] ?? { var e = (); self.pickRaw[uid] = e; e }, last = raw[key];
	var cg = self.caught[uid] ?? { var e = (); self.caught[uid] = e; e };
	raw[key] = v;
	if(cg[key] != true and: { ((v - cur).abs <= (2 / 127)) or: { last.notNil and: { (last - cur).sign != (v - cur).sign } } }) {
		cg[key] = true };
	if(cg[key] == true) { self.pickFrom = uid; set.value; self.pickFrom = nil; self.uiSend('/ce/phys', key, -1) }
		{ self.uiSend('/ce/phys', key, v) } };
~ce.isKnobCC = { |self, cc| (cc >= 13 and: { cc <= 36 }) or: { cc >= 61 and: { cc <= 84 } } };
// Mode switch (user 2026-11-22): the physical faders stay where they are, but now send the other mode's CCs; while
// in the other mode a fader may have moved, so a "caught" state of the new mode's faders is stale. The first CC of a
// Launch Control from the other mode (CC 5-52 = Mode 1, 53-100 = Mode 2) releases that device's faders of the new
// mode and forgets their last positions (no "passing" from a stale spot); column 8 (aliased: one fader for both modes)
// stays caught.
~ce.lcMode = ();   // uid → 1 or 2, the mode the Launch Control sent its last CC from
~ce.lcModeSwitch = { |self, uid, num|
	var m = case { num >= 5 and: { num <= 52 } } { 1 } { num >= 53 and: { num <= 100 } } { 2 } { nil }, was = self.lcMode[uid];
	if(m.notNil) {
		self.lcMode[uid] = m;
		if(was.notNil and: { was != m }) {
			var cg = self.caught[uid], raw = self.pickRaw[uid];
			((5..12) + (48 * (m - 1))).do { |f|
				if(self.ccAlias[f].isNil and: { self.ccAlias.includes(f).not }) {
					var key = ("c" ++ f).asSymbol;
					cg !? { cg[key] = false }; raw !? { raw[key] = nil } } } } } };
~ce.midiCC = { |self, val, num, uid, chan|
	switch(self.midiPorts[uid] !? { |p| p.kind },
		\lc, {
			chan !? { self.lcChan[num] = chan };
			self.lcModeSwitch(uid, num);
			if(self.isKnobCC(num)) {
				var raw = self.lcRaw[uid] ?? { var e = (); self.lcRaw[uid] = e; e }, last = raw[num];
				raw[num] = val;
				if(last.notNil and: { val != last }) {
					// at least 1:1 per step (the short side never feels dead), faster where the shared value must catch up
					var cur = self.val(num), next = if(val > last) {
						cur + ((val - last) * max((1 - cur) / (127 - last), 1 / 127))
					} { cur - ((last - val) * max(cur / last, 1 / 127)) };
					self.setCC(num, next.clip(0, 1), { |msg| self.server.sendMsg(*msg) }) }
			} {
				if(self.isFaderCC(num)) {
					var c = self.ccAlias[num] ? num;
					self.pickup(uid, ("c" ++ c).asSymbol, val / 127, self.cc[c], { self.setCC(num, val / 127, { |msg| self.server.sendMsg(*msg) }) })
				} { self.setCC(num, val / 127, { |msg| self.server.sendMsg(*msg) }) } }
		},
		\launchkey, {
			if(num == 1) { self.pickup(uid, \lk1, val / 127, self.lkCC[1], { self.setLkCC(num, val / 127, { |msg| self.server.sendMsg(*msg) }) }) }
				{ self.setLkCC(num, val / 127, { |msg| self.server.sendMsg(*msg) }) } }
	)
};
// A Launchkey control: kept in lkCC; the track may turn it into state buses (lkCtl: level, room, echo)
~ce.setLkCC = { |self, num, v, send|
	if(num == 1 and: { v != self.lkCC[num] }) { self.releasePickup(\lk1) };
	self.lkCC[num] = v;
	self.track !? { |t|
		t[\lkKeys] !? { |k| if(k[\cc] == num) { self.lkColumnSelect(v) } };
		t[\lkCtl] !? { |f| f.(self, num, v, send) } };
	self.uiSend('/ce/lkcc', num, v) };
// A Launchkey key or pad (chan 0-based: 9 = MIDI channel 10, the drum pads): the track's notes, played at once —
// sent without a time stamp, so the server starts them on arrival (a few ms: audio buffer + MIDI), not with the
// patterns' look-ahead (s.latency). Offline renders play them as \ceLk events.
~ce.midiNote = { |self, note, vel, chan, uid|
	if(self.midiPorts[uid] !? { |p| p.kind } == \launchkey and: { vel > 0 }) { self.lkPlay(note, vel / 127, chan) } { [] }
};
// A Launchkey key / pad from the device or the web UI: the track's notes at once; the UI lights the key / pad
~ce.lkPlay = { |self, note, vel, chan|
	var r = self.lkRoute(note, vel, chan);
	self.uiSend('/ce/lknote', note, chan);
	self.playNow(r[\notes], r[\lanes], self.groups.src, r[\stem])
};
// What a key / pad plays: (notes, lanes, stem). The keys of a stem track with lkKeys play its chosen column into
// that column's strip (~ce.lkColumnNotes); the pads, and the keys of every other track, play the track's lkNote on
// the \lk stem.
~ce.lkRoute = { |self, note, vel, chan|
	var t = self.track;
	if((chan != 9) and: { t.notNil } and: { t[\lkKeys].notNil }) {
		(notes: self.lkColumnNotes(note, vel), stem: \lkKeys,
			lanes: t[\columns][t[\lkKeysSlot]] !? { |c| self.stemBus[c[\stemName]] })
	} { (notes: t !? { t[\lkNote] !? { |f| f.(self, note, vel, chan) } } ? [], lanes: self.stemBus[\lk], stem: \lk) }
};
// Knob 8 (CC 28) spreads the keys across the stereo field (0 = all in the middle, 1 = the lowest key of the keyboard window
// hard left, the highest hard right); the window follows the octave buttons: it moves to the octave of a key outside it
// (the player's keyboard does the same). A pan as Strudel has it, 0..1.
~ce.lkBase = 48;
~ce.lkKeyPan = { |self, note|
	if(note < self.lkBase or: { note > (self.lkBase + 24) }) { self.lkBase = 12 * (note / 12).floor };
	0.5 + (0.5 * self.lkCC[28] * ((2 * ((note - self.lkBase) / 24)) - 1))
};
// the pan for a key as a note arg: nothing at spread 0 (the voice keeps its own sound), else (pan: …)
~ce.lkKeyPanArgs = { |self, note| var p = self.lkKeyPan(note); if(self.lkCC[28] > 0) { (pan: p) } { () } };
// The drum pad bank of the Launchkey (knobs 1-8 send CC 31-38 there): what a pad hit takes from the knobs, all neutral at 0.
// Knob 1 pitch down (up to an octave), 2 brightness (the low-pass, read by the track), 3 thin (high-pass up), 4 drive,
// 5 pad spread (pad 1 left … pad 16 right), 6 boost (gain up to × 1.5). Returns (rate: factor, hp: Hz, gain: factor, base: the
// note's own args: shape, hp and pan).
~ce.lkPad = { |self, n| self.lkCC[30 + n] };
~ce.lkPadMods = { |self, i|
	var drive = 0.9 * self.lkPad(4), spread = self.lkPad(5);
	(rate: 2 ** self.lkPad(1).neg, hp: if(self.lkPad(3) > 0) { 40 * (50 ** self.lkPad(3)) } { 0 }, gain: 1 + (0.5 * self.lkPad(6)),
		base: (shape: drive, hp: if(self.lkPad(3) > 0) { 40 * (50 ** self.lkPad(3)) } { 0 }) ++ if(spread > 0) { (pan: 0.5 + (0.5 * spread * ((2 * (i / 15)) - 1))) } { () })
};
// Notes as the tracks make them (ce.note …, \lane, \hold and \at in 16ths, \msg entries), started at once (\at: later)
~ce.playNow = { |self, notes, lanes, group, stem|
	var bps = TempoClock.default.tempo, srv = self.server;
	// returns the node ids of the started synths; the fader at this moment (noteLevel), a note at level 0 is not played
	notes.collect { |n|
		var lv = self.noteLevel(stem, n[\lane]);
		if(n[\msg].notNil) { srv.sendMsg(*n[\msg]); nil } { if(lv <= 0) { nil } {
			var desc = SynthDescLib.global[n[\instrument]], args = List[], id = srv.nextNodeID;
			var e = n.copy.putAll((out: lanes[n[\lane] ? \main], hold: (n[\hold] ? 1) / 4 / bps, post: (n[\post] ? 1) * lv));
			desc !? { desc.controlNames.do { |k| e[k] !? { |v| args.add(k).add(v) } } };
			if((n[\at] ? 0) > 0) { srv.sendBundle(n[\at] / 4 / bps, [\s_new, n[\instrument], id, 0, group.asNodeID] ++ args.asArray) }
				{ srv.sendMsg(\s_new, n[\instrument], id, 0, group.asNodeID, *args) };
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
			if(kind == \lc) { self.lcOuts[e.uid] = self.lcOutFor(e) };
			found.add(name -> kind);
		}
	};
	found.do { |f| "MIDI connected: %  → %".format(f.key, f.value ? "ignored (unknown controller)").postln };
	if(found.notEmpty) { self.uiPorts };
	self.midiPorts.keys.copy.do { |uid| if(now[uid].isNil) {
		"MIDI gone: %".format(self.midiPorts[uid].name).postln; self.midiPorts.removeAt(uid); self.lcOuts.removeAt(uid);
		self.lcRaw.removeAt(uid); self.uiPorts } };
	if(found.notEmpty and: { self.midiPorts.values.any { |p| p.kind == \lc }.not }) {
		"No Launch Control XL 3 yet: plug one in, it is picked up within 2 s".warn };
};
// the MIDI In of a Launch Control source (same device; not DAW, not the DIN outs), or nil (also with lcFeedback false:
// a muted test run never moves the user's knobs)
~ce.lcOutFor = { |self, src|
	var d = if(self.lcFeedback == false) { nil } { MIDIClient.destinations.detect { |d| d.device == src.device and: { d.name.containsi("DAW").not }
		and: { d.name.containsi("DIN").not } } };
	d !? { { var o = MIDIOut.newByName(d.device, d.name); o.latency = 0; o }.try { nil } } };
~ce.connectMidi = { |self|
	MIDIClient.initialized.not.if { MIDIClient.init(verbose: false) };
	MIDIdef.cc(\ce_midi, { |val, num, chan, src| self.midiCC(val, num, src, chan) }).permanent_(true);
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
		var r = ce.lkRoute(~key, ~vel, ~chan), notes = r[\notes];
		if(notes.notEmpty) {
			var e = (type: \ceMulti, notes: notes.reject { |n| n[\msg].notNil }, msgs: notes.select { |n| n[\msg].notNil },
				lanes: r[\lanes], group: ce.groups.src, stem: r[\stem]);
			[\server, \latency, \schedBundleArray, \schedBundle].do { |k| e[k] = parent[k] };
			e.play
		}
	}
});
)
