// Offline rendering: play a pattern into a Score with a proper tempo (beats → seconds), then render it with scsynth
// in non-realtime mode. The score server allocates node, bus and buffer numbers like a real server.
(
~ce.makeScore = { |self, stream, durBeats, bps, initMsgs|
	var player = self.server, beats = 0, list = List[], proto, ev, add;
	add = { |t, bundle| list.add([t.max(0)] ++ bundle) };
	proto = (
		server: player,
		latency: 0,
		schedBundle: { |lag, offset, server ... bundle|
			if(offset.isArray) { offset.do { |o, i| add.((o + beats) / bps + lag.wrapAt(i), [bundle.wrapAt(i)]) } }
			{ add.((offset + beats) / bps + lag, bundle) }
		},
		schedBundleArray: { |lag, offset, server, bundle|
			if(offset.isArray) { offset.do { |o, i| add.((o + beats) / bps + lag.asArray.wrapAt(i), [bundle.wrapAt(i)]) } }
			{ add.((offset + beats) / bps + lag, bundle) }
		}
	);
	player.tempo = bps;   // read by events through thisThread.clock
	Routine {
		thisThread.clock = player;
		while {
			thisThread.beats = beats;
			ev = stream.next(proto.copy);
			(beats < durBeats) and: { ev.notNil }
		} {
			ev.putAll(proto);
			ev.play;
			beats = beats + ev.delta;
		}
	}.next;
	// the set-up messages in several bundles at time 0 (in order): one bundle would overflow with many samples
	Score(self.clumpMsgs(initMsgs).collect { |c| [0] ++ c } ++ list.asArray.sort { |a, b| a[0] <= b[0] }
		++ [[durBeats / bps + 2.5, [\c_set, 0, 0]]])
};
// messages in groups of at most ~16 kB of OSC (sclang builds a bundle in a 64 kB buffer)
~ce.clumpMsgs = { |self, msgs|
	var out = List[], cur = List[], size = 0;
	msgs.do { |m| var n = m.asRawOSC.size;
		if(cur.notEmpty and: { size + n > 16000 }) { out.add(cur.asArray); cur = List[]; size = 0 };
		cur.add(m); size = size + n };
	if(cur.notEmpty) { out.add(cur.asArray) };
	out.asArray
};
)
