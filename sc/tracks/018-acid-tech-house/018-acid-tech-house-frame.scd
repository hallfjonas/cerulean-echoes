// Frame of the 018 acid tech house stem track (018-acid-tech-house.track): 017-lsd-fx-2's frame at 129 BPM. Mode 1 is
// 017's foundation with shakers (1:2) in place of the rumble and a funky bass (1:4); Mode 2 the strings, synth keys (2:2,
// in place of the stab), the leads, then four sparse fx columns: metal (2:4), drops (2:5), accents (2:6), whoosh (2:7). The
// Launchkey keys play the synth keys' sound (2:2). The root stays on F (no progressions, no chord colours; the keys move
// their own chords in the mood's scale). The three moods (Chapter), the orbits, the global column 8 texts and the
// Launchkey pads are 017-lsd-fx-2's. Format: sc/lib/stemtrack.scd.
// Column 8's fader is Wumms (more low end, punch and drive), not a volume: kick, sub and bass read it per note, so
// the frame is masterless. Chapter = the mood, all on F: Dark (minor), Tight (phrygian), Warm (dorian); it switches at the next bar. Every column
// plays degrees of the root (F) in the mood's scale: frame.degMidi, rootAt.
// @col 16:8 8 Global
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | density: strings up, echo, reverb, a snare roll.
// @ctl g.fader Wumms | more low end, punch and drive.
// @ctl g.b1 Chapter | mood: dark → tense → warm, at the next bar.
// @ctl g.b2 Break | 1st: low end out. 2nd: all back on the one.
// @lk level Keys Level | mod wheel: keys volume, apart from 2:2's fader.
// @lk k1 Key Tone | keys: darker ↔ brighter, on top of 2:2's Brightness.
// @lk k8 Key Pan | keys: all in the middle ↔ low keys left, high keys right Starts at 100 %.
// @lk pad.k1 Pitch | drum pads (bank B): natural ↔ an octave down.
// @lk pad.k2 Pad Fog | drum pads: clear ↔ muffled, like the global Fog.
// @lk pad.k3 Pad Thin | drum pads: full ↔ thin.
// @lk pad.k4 Pad Drive | drum pads: clean ↔ driven.
// @lk pad.k5 Pad Spread | drum pads: all in the middle ↔ pad 1 left, pad 16 right.
// @lk pad.k6 Pad Boost | drum pads: as played ↔ louder.
(
var bpm = 129, beat = 60 / bpm, fogCC = 20, tensionCC = 36;
var moods = [(name: "Dark", steps: [0, 2, 3, 5, 7, 8, 10]), (name: "Tight", steps: [0, 1, 3, 5, 7, 8, 10]),
	(name: "Warm", steps: [0, 2, 3, 5, 7, 9, 10])];
var beatNames = ["Beat on", "Beat off"];
var anyChord = ~ce.chordOf("Fm7", "f1", "c4 eb4 f4 ab4", "f g ab bb c db eb");
(
chapterBars: 1,
masterless: true,
// the degree in the mood's scale from F<oct>; octaves wrap, also below
degMidi: { |frame, deg, oct, mood| var st = deg.ceil.asInteger;
	(12 * (oct + 1)) + 5 + moods[mood].steps[st % 7] + (12 * (st / 7).floor) },
// the 017 stab, swapped into a slot from the stem drawer, plays every bar (the frame has no Vanish column)
stabHere: { |frame, track, b| true },
rootAt: { |frame, track, b| 0 },
chordAt: { |frame, track, bar| anyChord },
uiHead: { |frame, track, ce|
	var pend = { |now, next| if(now == next) { [now] } { [now, next] } };
	[["Chapter"] ++ pend.("F " ++ moods[track.chapter.now].name, "F " ++ moods[track.chapter.pending].name),
	 ["Break"] ++ pend.(beatNames[track.breakL.now], beatNames[track.breakL.pending])]
},
uiGlobal: { |frame, track, ce| (b1: ["F " ++ moods[track.chapter.now].name, "F " ++ moods[track.chapter.pending].name],
	b2: [beatNames[track.breakL.now], beatNames[track.breakL.pending]], b2on: track.breakL.pending == 1) },
orbits: (1: (ir: "ir/orbit-1.6.wav", delay: [0.75 * beat, 0.3]), 2: (ir: "ir/orbit-4.wav", delay: [0.75 * beat, 0.58]),
	3: (ir: "ir/orbit-2.6.wav", delay: [0.25 * beat, 0.45])),
// state buses: room and echo amounts the language derives from knobs (columns whose Space is scaled, echo throws)
states: (lkLevel: 0, lkBright: 0.5,
	// the room and echo of the keys column (2:2), which the keys' lane follows (the column's own values replace these)
	s2_2_room: 0.9 * 0.3, s2_2_echo: 0.1),
samples: ["tr909/bd-01.wav", "tr909/oh-00.wav", "tr909/hh-00.wav",
	// the metal fx column (2:4)
	"dirt/metal-00.wav",
	// the shakers (1:2)
	"vcsl/shaker_small/Mid_ShakerDouble_Down_rr1.flac", "vcsl/shaker_small/Mid_ShakerDouble_Down_rr2.flac",
	"vcsl/shaker_small/Mid_ShakerDouble_Up_rr1.flac", "vcsl/shaker_small/Mid_ShakerDouble_Up_rr2.flac",
	"vcsl/shaker_small/Mid_ShakerHighFaster_Down_rr1.flac", "vcsl/shaker_small/Mid_ShakerHighFaster_Down_rr2.flac",
	"vcsl/shaker_small/Mid_ShakerHighFaster_Up_rr1.flac", "vcsl/shaker_small/Mid_ShakerHighFaster_Up_rr2.flac",
	"vcsl/shaker_small/Mid_ShakerLowFaster_Up_rr1.flac", "vcsl/shaker_small/Mid_ShakerLowFaster_Up_rr2.flac",
	"vcsl/cabasa/Cabasa1_Hit_rr1_Mid.flac", "vcsl/cabasa/Cabasa1_Hit_rr2_Mid.flac",
	// the Launchkey's drum pads (as 008): drum-machine one-shots, Dirt-Samples (strudel.cc's default samples), the spoken samples
	"voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac", "voice/plaenterwald.flac",
	"voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac", "voice/the_evening_does_not_end.flac", "voice/in_the_vast.flac",
	"tr909/lt-00.wav", "tr909/rim-00.wav", "tr909/cr-00.wav", "tr808/sh-00.wav", "dirt/space-00.wav", "dirt/wind-00.wav"],

stems: [
	(name: \lk, sounds: [\sdSampleMod, \sdSynthMod], level: \lkLevel, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \s2_2_room, echoSend: \s2_2_echo),
			(name: \shots, orbit: 1, level: 1.0, roomR: 0.3), (name: \lt, orbit: 1, level: 1.0, roomR: 0.5),
			(name: \rim, orbit: 1, level: 1.0, roomR: 0.3, echoSend: 0.4), (name: \braaam, orbit: 1, level: 1.0, roomR: 0.9),
			(name: \space, orbit: 1, level: 1.0, roomR: 0.9), (name: \wind, orbit: 1, level: 1.0, roomR: 0.8)]),
],
// the Launchkey's start values: the mod wheel at a third, the key tone neutral
lkStart: (1: 0.34, 21: 0.5, 28: 1),
// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these). The keys play the synth keys' sound (2:2): a second
// player on the keys, the first one shaping the keys column on the Launch Control. Its Brightness, Length and Space reach
// the keys, its fader does not (it keeps playing its own chords; Pattern Keys only = silent). The mod wheel (CC 1) is the keys'
// level, knob 1 (CC 21) their tone (the filter range × 0.25 … 4, neutral at half), knob 8 (CC 28) the key pan spread; bank B
// (CC 31-38) = the drum pads: 1 pitch, 2 fog, 3 thin, 4 drive, 5 spread, 6 boost.
lkCtl: { |ce, num, v, send|
	switch(num,
		1, { ce.setState(\lkLevel, v, send) },
		21, { ce.setState(\lkBright, v, send) })
},
lkNote: { |ce, note, vel, chan|
	var k = { |n| ce.lkCC[20 + n] }, nl = 0.25 + (1.75 * k.(5));   // the Braaam's length in bars (knob 5)
	var thin = ("c" ++ ce.thinBus).asSymbol;
	if(chan != 9) {
		var col = ce.track.columns['2:2'], tone = 2 ** (4 * (ce.stateVal[\lkBright] - 0.5));
		var panArgs = ce.lkKeyPanArgs(note);
		(col !? { |c| c[\colCode] !? { |code| code[\keys] !? { |f| f.(c, note, vel) } } } ? []).collect { |n|
			n.put(\lo, n[\lo] * tone).put(\hi, n[\hi] * tone).putAll(panArgs) }
	} {
		// drum pads 36-51 (Drum mode): the spoken samples (left half), drum one-shots, a synth drop hit, Dirt-Samples
		var shots = [
			(file: "voice/brace.wav", tag: "brace"),
			(file: "voice/piece_of_paper.flac", tag: "paper", gain: 0.99),
			(file: "voice/plaenterwald_wine_and_cheese.flac", tag: "wine", gain: 0.98, once: 5.33),
			(file: "voice/plaenterwald.flac", tag: "plaenterwald", gain: 1.45),
			(file: "voice/lw.wav", tag: "lw", gain: 0.56),
			(file: "voice/the_creatures_have_begun_illumination.flac", tag: "creatures", once: 4.52),
			(file: "voice/the_evening_does_not_end.flac", tag: "noend", gain: 0.76, once: 10.19),
			(file: "voice/in_the_vast.flac", tag: "vast", once: 14.6),
			(file: "tr909/lt-00.wav", tag: "rolandtr909_lt", rate: 0.7, lane: \lt, gain: 0.71),
			(file: "tr909/rim-00.wav", tag: "rolandtr909_rim", rate: 0.8, lane: \rim, gain: 1.19),
			(braaam: true, once: 3.5, lane: \braaam, cutoff: 1400),
			(file: "tr909/oh-00.wav", tag: "rolandtr909_oh", rate: 0.9, hp: 3000),
			(file: "tr909/cr-00.wav", tag: "rolandtr909_cr", rate: -0.6, gain: 0.54),
			(file: "tr808/sh-00.wav", tag: "rolandtr808_sh", rate: 0.8, gain: 1.58),
			(file: "dirt/space-00.wav", tag: "space", rate: 0.5, lane: \space, gain: 0.65),
			(file: "dirt/wind-00.wav", tag: "wind", rate: 0.5, lane: \wind, gain: 1.36),
		];
		// gain: the shot's own, else superdough's default 0.8 (the log keeps Strudel's notation: gain × velocity)
		var i = (note - 36) % 16, sh = shots[i], pm = ce.lkPadMods(i),
			g = (sh[\gain] ? 0.8) * vel * pm[\gain], gl = (sh[\gain] ? 1) * vel, now = thisThread.seconds;
		// the low-pass: pad knob 2 (CC 32, 18 kHz → 800 Hz) × Fog / Tension at the hit, the shot's own at most
		var tv = (0.06 ** ce.val(fogCC)) * (1 + (1.5 * ce.val(tensionCC)));
		var cut = ((18000 * ((800 / 18000) ** ce.lkPad(2))) * tv).clip(80, 18000).min(sh[\cutoff] ? 18000);
		var base = (lpOn: 1, lo: cut, hi: cut, tone: 1, thinF: thin, lane: sh[\lane] ? \shots, tag: sh[\tag]) ++ pm[\base];
		// a shot with `once` ignores new hits until it has played out
		ce.lkOnce = ce.lkOnce ? ();
		if(sh[\once].notNil and: { (ce.lkOnce[i] ? -1) > now }) { [] } {
			sh[\once] !? { ce.lkOnce[i] = now + sh[\once] };
			if(sh[\braaam] == true) {
				// Braaam: a huge dark chord on F (F1, F2 detuned, C3, the tritone B2), the filter opening slowly (2 octaves),
				// driven (shape 0.5), over a sine boom that falls onto F1
				var env = ce.sdADSR(0.08, 1.2, 0.6, 2.5), fe = ce.sdADSR(0.3, 1.5, nil, nil, [0.005, 0.14, 0, 0.1]);
				var common = base ++ (hold: nl * 16, lpenv: 2, la: fe[0], ld: fe[1], ls: fe[2], lr: fe[3], shape: 0.5);
				[[2, 29, 0.5, -1], [2, 41.15, 0.4, 0.3], [2, 40.85, 0.4, 0.7], [3, 48, 0.18, -1], [2, 47, 0.2, -1]].collect { |x|
					ce.note(\sdSynthMod, common ++ (wave: x[0], freq: x[1].midicps, amp: x[2] * vel, pan: x[3],
						a: env[0], d: env[1], s: env[2], r: env[3], tag: ["", "", "sawtooth", "square"][x[0]], g: x[2] * vel, midi: x[1])) }
				++ [ce.note(\sdSynthMod, common ++ (wave: 0, freq: 29.midicps, amp: 0.9 * vel, penv: 12, pa: 0.001, pd: 0.4, ps: 0.001, pr: 0.01,
					a: 0.005, d: 1.5, s: 0, r: 2.5, tag: "sine", g: 0.9 * vel, midi: 29))]
			} {
				// no clip or release: the whole sample
				[ce.note(\sdSampleMod, base ++ (buf: ce.sampleBuffers[sh[\file]], stereoIn: (ce.sampleMono[sh[\file]] != true).asInteger,
					rate: (sh[\rate] ? 1) * pm[\rate], hold: -1, amp: g, g: gl, hp: max(sh[\hp] ? 0, pm[\hp]), a: 0.001, d: 0.001, s: 1, r: 0.01))]
			}
		}
	}
},
// web UI: the names of the 16 drum pads (pads 1-8 = notes 36-43, 9-16 = 44-51)
lkPadNames: ["Brace", "Paper", "Wine", "Forest", "Meadow", "Creatures", "No end", "Vast", "Low tom", "Rim echo",
	"Braaam", "Open hat", "Crash reverse", "Shaker", "Space", "Wind"],
)
)
