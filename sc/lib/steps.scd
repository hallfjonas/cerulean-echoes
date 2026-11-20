// Step engine: a stem is a function k → notes, asked once per 16th (k = the 16th number since bar 0; one bar = 4
// beats = 16 steps). Notes are Events (instrument + args); \at = offset within the step in 16ths (swing), \hold =
// note length in 16ths. All notes of a step are played by one \ceMulti event, so a stem can play several sounds at once.
(
Event.addEventType(\ceMulti, { |server|
	var parent = currentEnvironment, bps = thisThread.clock.tempo, beats = thisThread.beats;
	// control messages that belong to the step: (msg: [\c_set, bus, v] or [\n_set, node, …], at: 16ths)
	(~msgs ? []).do { |m| ~schedBundleArray.(~lag ? 0, (m[\at] ? 0) / 4, ~server, [m[\msg]], ~latency) };
	~notes.do { |n|
		var e = n.copy, at = (n[\at] ? 0) / 4;   // 16ths → beats
		// the fader at the note's start (Strudel postgain); at 0 the note is not played (Strudel gates the stem)
		var lv = topEnvironment[\ce].noteLevel(parent[\stem], n[\lane]);
		if(lv > 0) {
		e.removeAt(\at);
		e[\type] = \note;
		e[\group] = parent[\group];
		e[\out] = parent[\lanes][n[\lane] ? \main];
		e.removeAt(\lane);
		e[\hold] = (n[\hold] ? 1) / 4 / bps;         // seconds, the sound ends by itself
		e[\timingOffset] = at;
		e[\server] = parent[\server];
		e[\latency] = parent[\latency];
		e[\schedBundleArray] = parent[\schedBundleArray];
		e[\schedBundle] = parent[\schedBundle];
		e[\dur] = 0; e[\delta] = 0;
		e[\post] = (e[\post] ? 1) * lv;
		// nolog: a layer that is silent right now (live mix at 0, Strudel would not play it): not in the event log
		if(e.removeAt(\nolog) != true) { topEnvironment[\ce].log !? { |log| log.add([beats + at, parent[\stem], e]) } };
		e.play;
		};
	};
});

// The pattern of a stem: one \ceMulti event per 16th, from the 16th the stream starts on.
~ce.stepPattern = { |self, stem, fn, lanes, group|
	Pchain(Pbind(\lanes, Pfunc { lanes }, \group, group), Prout({ |ev|
		var k = (thisThread.beats * 4).round.asInteger;
		loop {
			var notes;
			self.tickLatches((k / 16).floor);
			notes = fn.(k) ? [];
			// a note function may also return control messages: entries with \msg
			ev = (type: if(notes.isEmpty) { \rest } { \ceMulti }, notes: notes.reject { |n| n[\msg].notNil },
				msgs: notes.select { |n| n[\msg].notNil }, stem: stem, dur: 0.25).yield;
			k = k + 1;
		}
	}))
};
)
