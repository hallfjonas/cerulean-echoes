// Frame of the 010 ambient house stem track (010-ambient-house.track): the four chapters (a progression each, one chord root
// per bar, a phrase of 4 bars; Chapter = the next progression at the next phrase), the root a column asks for (the pad's
// button 2, Freeze, holds the chord of the moment for everybody), D minor, Tension's own tone map (Fog x (1 + 1.5 t squared),
// every column takes the tone from it, not from the strips), the orbits, the global column 8 texts and the Launchkey, the
// same as sc/tracks/010-ambient-house/010-ambient-house.scd. Format: sc/lib/stemtrack.scd.
// @col 16:8 8 Global
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | build-up: echo, reverb, open filters; the end adds a snare roll.
// @ctl g.fader Master | volume of everything.
// @ctl g.b1 Chapter | next chord progression for all, at the next 4-bar phrase.
// @ctl g.b2 Break | 1st: low end out. 2nd: all back on the one.
// @lk level Keys Level | mod wheel: volume of the keys (× master).
// @lk k1 Brightness | dull ↔ bright; harder keys brighter.
// @lk k2 Piano | off → piano → Rhodes → off.
// @lk k3 Organ | off → organ B3 → M1 → off.
// @lk k4 Mallets | off → vibraphone → marimba → off.
// @lk k5 Length | short notes ↔ long.
// @lk k6 Space | a little air ↔ room.
// @lk k7 Echo | dry ↔ long echo.
// @lk k8 Key Pan | keys: all in the middle ↔ low keys left, high keys right Starts at 100 %.
// @lk pad.k1 Pitch | drum pads (bank B): natural ↔ an octave down.
// @lk pad.k2 Pad Fog | drum pads: clear ↔ muffled, like the global Fog.
// @lk pad.k3 Pad Thin | drum pads: full ↔ thin.
// @lk pad.k4 Pad Drive | drum pads: clean ↔ driven.
// @lk pad.k5 Pad Spread | drum pads: all in the middle ↔ pad 1 left, pad 16 right.
// @lk pad.k6 Pad Boost | drum pads: as played ↔ louder.
(
var lkKeysLib = (~ce.root +/+ "lib/lkkeys.scd").load;
var bpm = 120, beat = 60 / bpm, fogCC = 20, tensionCC = 36, freezeCC = 93;
var chapters = [
	(name: "Dusk", roots: [0, 5, 2, 6], chords: "Dm9 – B♭maj7 – Fmaj7 – C"),
	(name: "Sunrise", roots: [5, 6, 0, 0], chords: "B♭maj7 – C – Dm9 – Dm9"),
	(name: "Floating", roots: [0, 3, 0, 3], chords: "Dm9 – Gm9 – Dm9 – Gm9"),
	(name: "Warmth", roots: [2, 5, 3, 0], chords: "Fmaj7 – B♭maj7 – Gm9 – Dm9")];
var minor = [0, 2, 3, 5, 7, 8, 10];
var beatNames = ["Beat on", "Beat off"];
var anyChord = ~ce.chordOf("Dm9", "d2", "c4 e4 f4 a4", "d e f g a bb c");
// the keys' room: roomOf(0.1 ... 0.8), raised by Tension x 0.5 (also called when Tension moves)
var lkRoomUpd = { |ce, send| var r = 0.9 * (0.1 + (0.7 * ce.lkCC[26])); ce.setState(\lkRoom, r + ((0.95 - r) * 0.5 * ce.val(tensionCC)), send) };
(
chapterBars: 4,
// Strudel's n(deg).scale('D<oct>:minor'): the degree (rounded up) in D minor from D<oct>, octaves wrap
degMidi: { |frame, deg, oct| var st = deg.ceil.asInteger; (12 * (oct + 1)) + 2 + minor[st % 7] + (12 * (st / 7).floor) },
// the chapter's root of the bar; the pad's button 2 holds the root of the moment it went down, for everybody. Every
// harmonic column asks on every 16th, as Strudel queries the root on every tick.
rootAt: { |frame, track, b| var r = chapters[track.chapter.atBar(b)].roots[b % 4];
	if(track.ce.held(freezeCC)) { track.kept = track.kept ? r; track.kept } { track.kept = nil; r } },
lowAt: { |frame, track, b| var r = frame.rootAt(track, b); if(r >= 4) { r - 7 } { r } },
chordAt: { |frame, track, bar| anyChord },
maps: (tone: (ccs: [fogCC, tensionCC], fn: { |f, t| (0.06 ** f) * (1 + (1.5 * t * t)) })),
build: { |frame, track, ce|
	ce.onCC(tensionCC, { |v, send| [[\lk03, 0.3], [\lk06, 0.6], [\lk07, 0.7]].do { |x| ce.setState(x[0], x[1] + ((0.95 - x[1]) * 0.5 * v), send) };
		lkRoomUpd.(ce, send) });
},
uiHead: { |frame, track, ce|
	var pend = { |now, next| if(now == next) { [now] } { [now, next] } };
	[["Chapter"] ++ pend.(chapters[track.chapter.now].name, chapters[track.chapter.pending].name),
	 ["Chords", chapters[track.chapter.now].chords],
	 ["Break"] ++ pend.(beatNames[track.breakL.now], beatNames[track.breakL.pending])]
},
uiGlobal: { |frame, track, ce| (b1: [chapters[track.chapter.now].name, chapters[track.chapter.pending].name],
	b2: [beatNames[track.breakL.now], beatNames[track.breakL.pending]], b2on: track.breakL.pending == 1) },
orbits: (1: (ir: "ir/orbit-1.2.wav", delay: [0.75 * beat, 0.25]), 2: (ir: "ir/orbit-5.wav", delay: [0.75 * beat, 0.55])),
states: (lkLevel: 0, lkBright: 0, lkRoom: 0.9 * 0.1, lkEcho: 0, lk03: 0.3, lk06: 0.6, lk07: 0.7),
samples: ["tr909/bd-01.wav", "tr909/cp-00.wav", "tr909/rim-00.wav", "tr909/sd-00.wav", "tr909/oh-00.wav", "tr909/hh-00.wav",
	"tr727/perc-00.wav", "tr727/perc-01.wav", "tr727/perc-02.wav", "tr727/perc-03.wav", "tr727/perc-04.wav",
	"vcsl/glockenspiel/glock_soft_C5_02.flac", "vcsl/glockenspiel/glock_soft_C6_01.flac", "vcsl/glockenspiel/glock_soft_C7_03.flac",
	"vcsl/glockenspiel/glock_loud_G#6_01.flac", "vcsl/glockenspiel/glock_soft_G4_01.flac", "vcsl/glockenspiel/glock_soft_G5_01.flac",
	"vcsl/glockenspiel/glock_soft_G6_01.flac",
	// the Launchkey's pads
	"voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac", "voice/the_evening_progresses.flac",
	"voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac", "voice/the_evening_does_not_end.flac", "voice/in_the_vast.flac",
	"tr727/sh-01.wav", "dirt/wind-00.wav", "tr909/cr-00.wav"]
	++ ~ce.fontFiles("0090_JCLive_sf2_file") ++ ~ce.fontFiles("0530_Aspirin_sf2_file") ++ ~ce.lkKeysFiles,

stems: [
	(name: \lk, sounds: ~ce.lkKeysSounds ++ [\sdSampleMod, \sdFont], level: \lkLevel, tension: false, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \r03, orbit: 1, level: 1.0, roomR: \lk03), (name: \rim, orbit: 1, level: 1.0, roomR: \lk03, echoSend: 0.3),
			(name: \r06, orbit: 1, level: 1.0, roomR: \lk06), (name: \r07, orbit: 1, level: 1.0, roomR: \lk07)]),
],
// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these). Mod wheel (CC 1) = keys level, knobs CC 21-28:
// 1 brightness, 2-4 the keys' sound pairs, 5 length, 6 space, 7 echo, 8 key pan spread; bank B (CC 31-38) = the drum pads: 1 pitch, 2 fog, 3 thin, 4 drive, 5 spread, 6 boost. Every key plays a note of
// fixed length (Strudel's midikeys has no note-off: the length is knob 5). Brightness, Space and Echo act at once.
// key pan starts at 100 %: the low keys left, the high keys right
lkStart: (28: 1),
lkCtl: { |ce, num, v, send|
	if(num == 22) { ce.lkTurned2 = true };   // knob 2 keeps its start value 0.5 (piano + Rhodes) until it is turned
	switch(num,
		1, { ce.setState(\lkLevel, v, send) },
		21, { ce.setState(\lkBright, v, send) },
		26, { lkRoomUpd.(ce, send) },
		27, { ce.setState(\lkEcho, 0.6 * v, send) })
},
lkNote: { |ce, note, vel, chan|
	var k = { |n| ce.lkCC[20 + n] }, nl = 0.25 + (1.75 * k.(5));   // note length in bars
	var tone = ("c" ++ ce.mapBus[\tone]).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	if(chan != 9) {
		ce.lkKeysNotes(note, vel, [if(ce.lkTurned2 == true) { k.(2) } { 0.5 }, k.(3), k.(4)],
			(hold: nl * 16, lane: \keys, tone: tone, bright: ce.stateMap(\lkBright), thinF: thin))
	} {
		// drum pads 36-51 (Drum mode): the spoken samples (left half), mallets, bells, shaker, wind, voices
		var shots = [
			(file: "voice/brace.wav", tag: "brace"),
			(file: "voice/piece_of_paper.flac", tag: "paper", gain: 0.99),
			(file: "voice/plaenterwald_wine_and_cheese.flac", tag: "wine", gain: 0.98, once: 5.33),
			(file: "voice/the_evening_progresses.flac", tag: "evening", gain: 1.04, once: 9.25),
			(file: "voice/lw.wav", tag: "lw", gain: 0.56),
			(file: "voice/the_creatures_have_begun_illumination.flac", tag: "creatures", once: 4.52),
			(file: "voice/the_evening_does_not_end.flac", tag: "noend", gain: 0.76, once: 10.19),
			(file: "voice/in_the_vast.flac", tag: "vast", once: 14.6),
			(file: "tr909/rim-00.wav", tag: "rolandtr909_rim", lane: \rim, gain: 1.19),
			(font: "0120_JCLive_sf2_file", tag: "gm_marimba", midi: 62),
			(font: "0090_JCLive_sf2_file", tag: "gm_glockenspiel", midi: 86, lane: \r06),
			(file: "tr727/sh-01.wav", tag: "rolandtr727_sh", gain: 1.25),
			(font: "0110_JCLive_sf2_file", tag: "gm_vibraphone", midi: 77, lane: \r06),
			(file: "dirt/wind-00.wav", tag: "wind", rate: 0.6, lane: \r07, gain: 1.45),
			(file: "tr909/cr-00.wav", tag: "rolandtr909_cr", rate: -0.6, gain: 0.54),
			(font: "0530_Aspirin_sf2_file", tag: "gm_voice_oohs", midi: 62, a: 0.2, r: 1.5, lane: \r07),
		];
		// gain: the shot's own, else superdough's default 0.8 (the log keeps Strudel's notation: gain × velocity)
		var i = (note - 36) % 16, sh = shots[i], pm = ce.lkPadMods(i),
			g = (sh[\gain] ? 0.8) * vel * pm[\gain], gl = (sh[\gain] ? 1) * vel, now = thisThread.seconds;
		// the low-pass: pad knob 2 (CC 32, 18 kHz → 800 Hz) × Fog / Tension at the hit
		var t = ce.val(tensionCC), tv = (0.06 ** ce.val(fogCC)) * (1 + (1.5 * t * t));
		var cut = ((18000 * ((800 / 18000) ** ce.lkPad(2))) * tv).clip(80, 18000);
		var base = (lpOn: 1, lo: cut, hi: cut, tone: 1, thinF: thin, lane: sh[\lane] ? \r03, tag: sh[\tag], g: gl) ++ pm[\base];
		ce.lkOnce = ce.lkOnce ? ();
		if(sh[\once].notNil and: { (ce.lkOnce[i] ? -1) > now }) { [] } {
			sh[\once] !? { ce.lkOnce[i] = now + sh[\once] };
			if(sh[\font].notNil) { var f = ce.fontNote(sh[\font], sh[\midi]), v = ce.sdADSR(sh[\a], nil, nil, sh[\r]);
				[ce.note(\sdFont, f ++ base ++ (amp: g, hold: nl * 16, midi: sh[\midi], a: v[0], d: v[1], s: v[2], r: v[3]))] } {
				// no clip or release: the whole sample
				[ce.note(\sdSampleMod, base ++ (buf: ce.sampleBuffers[sh[\file]], stereoIn: (ce.sampleMono[sh[\file]] != true).asInteger,
					rate: (sh[\rate] ? 1) * pm[\rate], hold: -1, amp: g, a: 0.001, d: 0.001, s: 1, r: 0.01))] }
		}
	}
},
lkPadNames: ["Brace", "Paper", "Wine", "Evening", "Meadow", "Creatures", "No end", "Vast", "Rim echo", "Marimba D",
	"Glockenspiel", "Shaker", "Vibraphone", "Wind", "Crash reverse", "Voice ooh"],
)
)
