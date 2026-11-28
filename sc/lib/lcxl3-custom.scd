// Driver lcxl3-custom: every Launch Control XL 3 in Custom Mode 1 / 2 (the .syx modes in midi-layouts/) gets the full
// layout; with several, the control moved last wins. Its DAW port is ignored. Knobs move by value scaling
// (~ce.knobTurn), faders by pickup (~ce.pickup), a CC from the other mode hands the faders over (~ce.lcModeSwitch);
// every knob change goes back to the device's MIDI In (knob feedback). No LEDs or screen: the custom modes draw them.
(
~ce.addDriver((name: 'lcxl3-custom', kind: \lc,
	portMatch: { |d, n| n.contains("LCXL3") and: { n.contains("DAW").not } },
	// the MIDI In of the same device (not DAW, not the DIN outs), or nil (also with lcFeedback false: a muted test run
	// never moves the user's knobs)
	opened: { |d, ce, src|
		var to = if(ce.lcFeedback == false) { nil } { MIDIClient.destinations.detect { |m| m.device == src.device
			and: { m.name.containsi("DAW").not } and: { m.name.containsi("DIN").not } } };
		ce.lcOuts[src.uid] = to !? { { var o = MIDIOut.newByName(to.device, to.name); o.latency = 0; o }.try { nil } } },
	inCC: { |d, ce, uid, val, num, chan|
		chan !? { ce.lcChan[num] = chan };
		ce.lcModeSwitch(uid, num);
		case
		{ ce.isKnobCC(num) } { ce.knobTurn(uid, num, val) }
		{ ce.isFaderCC(num) } { var c = ce.ccAlias[num] ? num;
			ce.pickup(uid, ("c" ++ c).asSymbol, val / 127, ce.cc[c],
				{ ce.setCC(num, val / 127, { |msg| ce.server.sendMsg(*msg) }) }) }
		{ ce.setCC(num, val / 127, { |msg| ce.server.sendMsg(*msg) }) } },
	// the knob and its aliases (column 8 in Mode 2) to the shared value, on the learned channel (unknown: all 16)
	outKnob: { |d, ce, uid, c, v|
		var out = ce.lcOuts[uid], b = (v * 127).round.asInteger.clip(0, 127);
		var nums = [c] ++ ce.ccAlias.keys.asArray.select { |k| ce.ccAlias[k] == c };
		out !? { var raw = ce.lcRaw[uid] ?? { var e = (); ce.lcRaw[uid] = e; e };
			nums.do { |num|
				if(raw[num] != b) {
					raw[num] = b;
					{ var ch = ce.lcChan[num]; if(ch.notNil) { out.control(ch, num, b) } { 16.do { |k| out.control(k, num, b) } } }
						.try { |e| "Launch Control feedback: %".format(e.errorString).warn } } } } }
));
)
