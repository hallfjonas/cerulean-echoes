// TRACK 010 AMBIENT HOUSE — SuperCollider port of tracks/ambient-house/010-ambient-house/010-ambient-house.strudel
// (ambient house in D minor, 120 BPM, a sunrise mood). Same controller layout as the Strudel track: Mode 1 = Jojo
// (foundation, plain CCs), Mode 2 = Jonas (colour, CC + 48), column 8 global on both (Jojo's column 8, shaker / ride,
// is off as in Strudel), the Launchkey MK4 25 optional (its keys: sc/lib/lkkeys.scd, shared with 008). Ported 1:1
// (see sc/PORTING.md). Level (faders, mod wheel) acts from the next note, as in Strudel; Space, echo and the global
// column act at once, also on sounding notes; Brightness acts
// at once on the long sounds (noise pump, pad, lead, Launchkey keys), on the short ones from the next note; pattern
// buttons switch at the next bar, Chapter at the next 4-bar phrase.
// The @ tags below are read by the web UI (sc/ui): column names, and each control's name | what it does.
// @layout Track 010 — ambient house (SuperCollider)
// @mode 16 Mode 1 — Jojo: Foundation (beat + bass) · same CCs as Mode 16
// @col 16:1 1 Kick
// @col 16:2 2 Pump
// @col 16:3 3 Sub
// @col 16:4 4 Bass
// @col 16:5 5 Clap
// @col 16:6 6 Hats
// @col 16:7 7 Congas
// @col 16:8 8 Global
// @mode 2 Mode 2 — Jonas: Colour (chords + melodies) · CC + 48
// @col 2:1 1 Pad
// @col 2:2 2 Chords
// @col 2:3 3 Arp
// @col 2:4 4 Lead
// @col 2:5 5 Marimba
// @col 2:6 6 Glock
// @col 2:7 7 Birds
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | build-up: echo, reverb, open filters; the end adds a snare roll.
// @ctl g.fader Master | volume of everything.
// @ctl g.b1 Chapter | next chord progression for all, at the next 4-bar phrase.
// @ctl g.b2 Break | 1st: low end out. 2nd: all back on the one.
// @ctl 16:1.k1 Brightness | dull ↔ bright.
// @ctl 16:1.k2 Space | dry ↔ room.
// @ctl 16:1.k3 Softness | 0 = firm 909 kick ↔ 1 = deep, soft thump without click.
// @ctl 16:1.fader Level | 0 = gone. Four-on-the-floor kick, tuned to D.
// @ctl 16:1.b1 Pattern | straight → pickup before the 1 → gap every 4th bar.
// @ctl 16:1.b2 Drop out | kick pauses while held.
// @ctl 16:2.k1 Brightness | dull ↔ bright.
// @ctl 16:2.k2 Space | dry ↔ room.
// @ctl 16:2.k3 Motion | still ↔ the filter breathes and the noise wanders left and right.
// @ctl 16:2.fader Level | noise that pumps with the kick.
// @ctl 16:2.b1 Pattern | pump → off-beat breath → slow waves.
// @ctl 16:2.b2 Riser | a noise sweep rises over 2 bars while held.
// @ctl 16:3.k1 Brightness | dull ↔ bright.
// @ctl 16:3.k2 Space | dry ↔ room.
// @ctl 16:3.k3 Length | long, pumping notes ↔ short, bouncing ones.
// @ctl 16:3.fader Level | sub on the chord root, follows the chapter.
// @ctl 16:3.b1 Pattern | pump → off-beat → one long note per bar.
// @ctl 16:3.b2 Octave | one octave up while held.
// @ctl 16:4.k1 Brightness | dull ↔ bright.
// @ctl 16:4.k2 Space | dry ↔ room.
// @ctl 16:4.k3 Complexity | the line as it is ↔ extra 16th notes rolling in between.
// @ctl 16:4.fader Level | rolling bass, follows the chapter.
// @ctl 16:4.b1 Pattern | rolling → off-beat → melodic.
// @ctl 16:4.b2 Octave | one octave up while held.
// @ctl 16:5.k1 Brightness | dull ↔ bright.
// @ctl 16:5.k2 Space | dry ↔ room.
// @ctl 16:5.k3 Complexity | plain ↔ a quiet rim before beat 3 ↔ + small double taps.
// @ctl 16:5.fader Level | clap / rim on 2 and 4. Also the level of Tension's snare roll.
// @ctl 16:5.b1 Pattern | clap → rim with a pickup → clap + rim.
// @ctl 16:5.b2 Roll | snare roll, growing over the bar, while held.
// @ctl 16:6.k1 Brightness | dull ↔ bright.
// @ctl 16:6.k2 Space | dry ↔ room.
// @ctl 16:6.k3 Complexity | the pattern as it is ↔ + quiet 16ths ↔ + little 32nd rolls.
// @ctl 16:6.fader Level | off-beat hat. Keeps playing in the break.
// @ctl 16:6.b1 Pattern | off-beat → + 16ths → shuffled 16ths.
// @ctl 16:6.b2 Open | long open hats on every 8th while held.
// @ctl 16:7.k1 Brightness | dull ↔ bright.
// @ctl 16:7.k2 Space | dry ↔ room.
// @ctl 16:7.k3 Complexity | steady pattern ↔ + fingertip ghost notes ↔ + agogo bells.
// @ctl 16:7.fader Level | congas and bongos. Keep playing in the break.
// @ctl 16:7.b1 Pattern | pillow → rolling → latin.
// @ctl 16:7.b2 Fill | a conga run over the bar while held.
// @ctl 2:1.k1 Brightness | dull ↔ bright.
// @ctl 2:1.k2 Space | dry ↔ echo + room.
// @ctl 2:1.k3 Swell | still ↔ slowly breathing in and out (every 2 bars).
// @ctl 2:1.fader Level | warm pad on the chapter's chords.
// @ctl 2:1.b1 Pattern | voicing: warm → open (9th) → wide.
// @ctl 2:1.b2 Freeze | holds the current chord while held, for everybody.
// @ctl 2:2.k1 Brightness | dull ↔ bright.
// @ctl 2:2.k2 Space | dry ↔ echo + room.
// @ctl 2:2.k3 Length | long ringing chords ↔ short, choppy stabs.
// @ctl 2:2.fader Level | chord stabs on the chapter's chords.
// @ctl 2:2.b1 Pattern | next of 8 deep-house rhythms.
// @ctl 2:2.b2 Stab | a chord on every off-beat while held.
// @ctl 2:3.k1 Brightness | dull ↔ bright.
// @ctl 2:3.k2 Space | dry ↔ echo + room.
// @ctl 2:3.k3 Complexity | some notes left out ↔ every 16th, plus passing notes (9th, 6th).
// @ctl 2:3.fader Level | pluck arp on the chord.
// @ctl 2:3.b1 Pattern | next of 8 arp shapes.
// @ctl 2:3.b2 Octave | one octave up while held.
// @ctl 2:4.k1 Brightness | dull ↔ bright.
// @ctl 2:4.k2 Space | dry ↔ echo + room.
// @ctl 2:4.k3 Complexity | line → + 3rd voice → + octave echo.
// @ctl 2:4.fader Level | slow lead on the chord.
// @ctl 2:4.b1 Pattern | next of 8 melodies.
// @ctl 2:4.b2 Echo throw | long echo on the lead while held.
// @ctl 2:5.k1 Brightness | dull ↔ bright.
// @ctl 2:5.k2 Space | dry ↔ echo + room.
// @ctl 2:5.k3 Complexity | 0 = one voice, 0.5 = + a third above, 1 = + a fifth: three-part marimba.
// @ctl 2:5.fader Level | marimba phrase, every second bar.
// @ctl 2:5.b1 Pattern | next of 8 phrase rhythms (new notes too).
// @ctl 2:5.b2 Answer | the phrase plays in every bar while held.
// @ctl 2:6.k1 Brightness | dull ↔ bright.
// @ctl 2:6.k2 Space | dry ↔ echo + room.
// @ctl 2:6.k3 Complexity | a few notes per bar ↔ a busy pattern (~60 % of the 16ths).
// @ctl 2:6.fader Level | glockenspiel on the chord.
// @ctl 2:6.b1 Pattern | next of 8 random patterns.
// @ctl 2:6.b2 Run | chord runs, denser while held.
// @ctl 2:7.k1 Brightness | dull ↔ bright.
// @ctl 2:7.k2 Space | dry ↔ echo + room.
// @ctl 2:7.k3 Complexity | a few calls ↔ a busy dawn chorus, an octave higher too.
// @ctl 2:7.fader Level | bird chirps on the chord.
// @ctl 2:7.b1 Pattern | next of 8 call rhythms (new notes too).
// @ctl 2:7.b2 Flock | a whole flock calls while held.
// @lk level Keys Level | mod wheel: volume of the keys (× master).
// @lk k1 Brightness | dull ↔ bright; harder keys brighter.
// @lk k2 Piano → Rhodes | off → piano → Rhodes → off.
// @lk k3 B3 → M1 | off → organ B3 → M1 → off.
// @lk k4 Vibes → Marimba | off → vibraphone → marimba → off.
// @lk k5 Length | short notes ↔ long.
// @lk k6 Space | a little air ↔ room.
// @lk k7 Echo | dry ↔ long echo.
// @lk k8 Pad Fog | drum pads: clear ↔ muffled, like the global Fog.
(
// the Launchkey's keys: the shared keys of 008 / 009 / 010 (sc/lib/lkkeys.scd)
var lkKeysLib = (~ce.root +/+ "lib/lkkeys.scd").load;
var bpm = 120, beat = 60 / bpm;
// ---------------------------------------------------------------------------------------------------------
// CC numbers of column n (1-8): row 1-3 knobs, fader, buttons. Jojo = plain, Jonas = + 48.
var col = { |n, plus = 0| (bright: 12 + n + plus, space: 20 + n + plus, char: 28 + n + plus, level: 4 + n + plus,
	btn: 36 + n + plus, btn2: 44 + n + plus) };
var jojo = { |n| col.(n) }, jonas = { |n| col.(n, 48) };
var glob = col.(8);   // column 8 (global): Fog, Thin, Tension, Master, Chapter, Break; its Mode 2 CCs are aliases

// ---------------------------------------------------------------------------------------------------------
// CHAPTERS — progressions in D minor, one chord root (scale degree) per bar, 4 bars = a phrase (Chapter, next phrase)
var chapters = [
	(name: "Dusk", roots: [0, 5, 2, 6], chords: "Dm9 – B♭maj7 – Fmaj7 – C"),
	(name: "Sunrise", roots: [5, 6, 0, 0], chords: "B♭maj7 – C – Dm9 – Dm9"),
	(name: "Floating", roots: [0, 3, 0, 3], chords: "Dm9 – Gm9 – Dm9 – Gm9"),
	(name: "Warmth", roots: [2, 5, 3, 0], chords: "Fmaj7 – B♭maj7 – Gm9 – Dm9")];
var minor = [0, 2, 3, 5, 7, 8, 10];
// Strudel's n(deg).scale('D<oct>:minor'): the degree (rounded up) in D minor from D<oct>, octaves wrap
var degMidi = { |deg, oct| var st = deg.ceil.asInteger; (12 * (oct + 1)) + 2 + minor[st % 7] + (12 * (st / 7).floor) };
var ramp = { |v, from, to| ((v - from) / (to - from)).clip(0, 1) };
// a step line as Strudel writes it ("~ 0 ~ 7 …", brackets of a 16-step bar removed) → [value or nil per step]
var line = { |str| str.replace("[", " ").replace("]", " ").split($ ).reject(_.isEmpty).collect { |x| if(x == "~") { nil } { x.asFloat } } };
// a line with "_" (elongation) → [16th → [degree, length in 16ths]]
var longLine = { |str| var t = str.split($ ).reject(_.isEmpty), d = Dictionary.new;
	t.do { |x, i| if(x != "~" and: { x != "_" }) { var n = 1; while { (i + n) < t.size and: { t[i + n] == "_" } } { n = n + 1 }; d[i] = [x.asFloat, n] } };
	d };

// room / echo of each layer (Strudel bus / dryBus): name → [echo, space function or nil (dry)]
var fxList = (kick: [nil], noise: [0.15], riser: [0, { 0.3 }], sub: [nil], bass: [nil], clap: [0.2], hats: [0.2], perc: [0.3],
	pad: [0.15], keys: [0.4], keys2: [0.3], arp: [0.35, { |s| 0.3 + (0.7 * s) }], lead: [0.3, { |s| 0.25 + (0.75 * s) }],
	ans: [0.45, { |s| 0.35 + (0.65 * s) }], bells: [0.5], run: [0.4], birds: [0.3, { |s| 0.3 + (0.7 * s) }],
	birds2: [0.5, { |s| 0.3 + (0.7 * s) }], birds3: [0.4, { |s| 0.3 + (0.7 * s) }]);
var fxStates = ().putPairs(fxList.keys.asArray.collect { |k| var e = fxList[k][0], f = fxList[k][1] ? { |s| s }, s0 = f.(0);
	[(k ++ "Room").asSymbol, 0.9 * s0] ++ if(e.notNil) { [(k ++ "Echo").asSymbol, (e * 2 * s0).min(0.9)] } { [] } }.flatten);

(
name: "010-ambient-house",
bpm: bpm,
// Fog and Thin as the library has them; Tension's own curves (tone × (1 + 1.5 t²), echo up to 0.4 over 0..0.7, the
// rooms raised by 0.5 t) through the tone map and the state buses below: the strips' own Tension input stays off (127).
global: (fog: glob.bright, thin: glob.space, tension: 127, master: glob.level),
aliases: [\bright, \space, \char, \level, \btn, \btn2].collect { |r| (glob[r] + 48) -> glob[r] }.asDict,
maps: (
	tone: (ccs: [glob.bright, glob.char], fn: { |f, t| (0.06 ** f) * (1 + (1.5 * t * t)) }),
),
uiHead: { |self, ce|
	var pend = { |now, next| if(now == next) { [now] } { [now, next] } };
	[["Chapter"] ++ pend.(chapters[self.chapter.now].name, chapters[self.chapter.pending].name),
	 ["Chords", chapters[self.chapter.now].chords],
	 ["Break"] ++ pend.(["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending])]
},
uiGlobal: { |self, ce| (b1: [chapters[self.chapter.now].name, chapters[self.chapter.pending].name],
	b2: [["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending]], b2on: self.breakL.pending == 1) },
// Effect buses (Strudel BUSES). Orbit 1 = drums and bass: small dry room (size 1.2), short dotted-8th slap.
// Orbit 2 = Jonas' colour and the riser: open-air hall (size 5), long dotted-8th echo. IRs measured from superdough.
orbits: (1: (ir: "ir/orbit-1.2.wav", delay: [0.75 * beat, 0.25]), 2: (ir: "ir/orbit-5.wav", delay: [0.75 * beat, 0.55])),
states: fxStates ++ (lkLevel: 0, lkBright: 0, lkRoom: 0.9 * 0.1, lkEcho: 0, lk03: 0.3, lk06: 0.6, lk07: 0.7),
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
	// JOJO 1 KICK — a sine body on D2 with a pitch drop + the 909 kick; Softness: firm ↔ deep soft thump. Room, no echo.
	(name: \kick, sounds: [\sdSynthMod, \sdSampleMod], level: jojo.(1).level, roomR: \kickRoom, orbit: 1, thin: false),
	// JOJO 2 NOISE PUMP — pink noise glued to the kick (orbit 1), the riser on button 2 (orbit 2, space 0.3)
	(name: \noise, sounds: [\sdNoise], level: jojo.(2).level, trim: 0.6, thin: false, tensionEcho: false,
		lanes: [(name: \pump, orbit: 1, roomR: \noiseRoom, echoSend: \noiseEcho), (name: \riser, orbit: 2, roomR: \riserRoom, echoSend: \riserEcho)]),
	// JOJO 3 SUB — sine + triangle on the low chord root, a 16th after the kick. Room, no echo.
	(name: \sub, sounds: [\sdSynthMod], level: jojo.(3).level, roomR: \subRoom, orbit: 1, thin: false),
	// JOJO 4 BASSLINE — triangle + a quiet saw, a soft filter pluck, a little drive. Room, no echo.
	(name: \bass, sounds: [\sdSynthMod], level: jojo.(4).level, roomR: \bassRoom, orbit: 1, thin: false),
	// JOJO 5 CLAP / RIM — 909 clap / rimshot, ghosts, snare roll (button 2, Tension)
	(name: \clap, sounds: [\sdSampleMod], level: jojo.(5).level, roomR: \clapRoom, echoSend: \clapEcho, orbit: 1, trim: 0.5,
		thin: false, tensionEcho: false),
	// JOJO 6 HATS — 909 open hat on the off-beat, closed 16ths
	(name: \hats, sounds: [\sdSampleMod], level: jojo.(6).level, roomR: \hatsRoom, echoSend: \hatsEcho, orbit: 1, trim: 0.6,
		thin: false, tensionEcho: false),
	// JOJO 7 CONGAS — TR-727 conga / bongos / agogo
	(name: \perc, sounds: [\sdSampleMod], level: jojo.(7).level, roomR: \percRoom, echoSend: \percEcho, orbit: 1, thin: false,
		tensionEcho: false),
	// JONAS 1 PAD — detuned saws + a triangle on the chapter's 7th / 9th chords
	(name: \pad, sounds: [\sdSynthMod], level: jonas.(1).level, roomR: \padRoom, echoSend: \padEcho, orbit: 2, thin: false,
		tensionEcho: false),
	// JONAS 2 DEEP CHORDS — rootless minor-9 / maj-7 stabs, FM e-piano (+ triangle); button 2 = off-beat stabs (own echo)
	(name: \keys, sounds: [\sdSynthMod], level: jonas.(2).level, orbit: 2, thin: false, tensionEcho: false,
		lanes: [(name: \main, roomR: \keysRoom, echoSend: \keysEcho), (name: \off, roomR: \keys2Room, echoSend: \keys2Echo)]),
	// JONAS 3 PLUCK ARP — triangle + saw pluck on the chord tones, echo
	(name: \arp, sounds: [\sdSynthMod], level: jonas.(3).level, roomR: \arpRoom, echoSend: \arpEcho, orbit: 2, thin: false,
		tensionEcho: false),
	// JONAS 4 LEAD — triangle + saw through an "o" vowel, vibrato; Complexity: a third below, a canon an octave up
	(name: \lead, sounds: [\sdSynthMod, \sdSynthFx], level: jonas.(4).level, roomR: \leadRoom, echoSend: \leadEcho, orbit: 2,
		thin: false, tensionEcho: false),
	// JONAS 5 MARIMBA — sine + a partial two octaves up, a phrase at the end of every second bar
	(name: \ans, sounds: [\sdSynthMod], level: jonas.(5).level, roomR: \ansRoom, echoSend: \ansEcho, orbit: 2, thin: false,
		tensionEcho: false),
	// JONAS 6 GLOCKENSPIEL — VCSL glockenspiel on chord tones; button 2 = runs (own echo)
	(name: \bells, sounds: [\sdSampleMod], level: jonas.(6).level, orbit: 2, trim: 4, thin: false, tensionEcho: false,
		lanes: [(name: \main, roomR: \bellsRoom, echoSend: \bellsEcho), (name: \run, roomR: \runRoom, echoSend: \runEcho)]),
	// JONAS 7 BIRDS — sine chirps with a quick pitch sweep (three layers, each its own echo)
	(name: \birds, sounds: [\sdSynthMod], level: jonas.(7).level, orbit: 2, thin: false, tensionEcho: false,
		lanes: [(name: \main, roomR: \birdsRoom, echoSend: \birdsEcho), (name: \more, roomR: \birds2Room, echoSend: \birds2Echo),
			(name: \held, roomR: \birds3Room, echoSend: \birds3Echo)]),
	// LAUNCHKEY MK4 25 — keys: Jonas' keys (orbit 2, mod wheel = level × master); pads: 16 one-shots (orbit 1, master)
	(name: \lk, sounds: ~ce.lkKeysSounds ++ [\sdSampleMod, \sdFont], level: \lkLevel, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \r03, orbit: 1, level: 1.0, roomR: \lk03), (name: \rim, orbit: 1, level: 1.0, roomR: \lk03, echoSend: 0.3),
			(name: \r06, orbit: 1, level: 1.0, roomR: \lk06), (name: \r07, orbit: 1, level: 1.0, roomR: \lk07)]),
],

// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these). Mod wheel (CC 1) = keys level, knobs CC 21-28:
// 1 brightness, 2-4 the keys' sound pairs, 5 length, 6 space, 7 echo, 8 one-shot darkness. Every key plays a note of
// fixed length (Strudel's midikeys has no note-off: the length is knob 5). Brightness, Space and Echo act at once.
lkCtl: { |ce, num, v, send|
	if(num == 22) { ce.lkTurned2 = true };   // knob 2 keeps its start value 0.5 (piano + Rhodes) until it is turned
	switch(num,
		1, { ce.setState(\lkLevel, v, send) },
		21, { ce.setState(\lkBright, v, send) },
		26, { ce.track[\lkRoomUpd].(ce, send) },
		27, { ce.setState(\lkEcho, 0.6 * v, send) })
},
// the keys' room: roomOf(0.1 … 0.8), raised by Tension × 0.5 (also called when Tension moves)
lkRoomUpd: { |ce, send| var r = 0.9 * (0.1 + (0.7 * ce.lkCC[26])); ce.setState(\lkRoom, r + ((0.95 - r) * 0.5 * ce.val(36)), send) },
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
		var i = (note - 36) % 16, sh = shots[i], g = (sh[\gain] ? 0.8) * vel, gl = (sh[\gain] ? 1) * vel, now = thisThread.seconds;
		// the low-pass: knob 8 (18 kHz → 800 Hz) × Fog / Tension at the hit
		var t = ce.val(glob.char), tv = (0.06 ** ce.val(glob.bright)) * (1 + (1.5 * t * t));
		var cut = ((18000 * ((800 / 18000) ** k.(8))) * tv).clip(80, 18000);
		var base = (lpOn: 1, lo: cut, hi: cut, tone: 1, thinF: thin, lane: sh[\lane] ? \r03, tag: sh[\tag], g: gl);
		ce.lkOnce = ce.lkOnce ? ();
		if(sh[\once].notNil and: { (ce.lkOnce[i] ? -1) > now }) { [] } {
			sh[\once] !? { ce.lkOnce[i] = now + sh[\once] };
			if(sh[\font].notNil) { var f = ce.fontNote(sh[\font], sh[\midi]), v = ce.sdADSR(sh[\a], nil, nil, sh[\r]);
				[ce.note(\sdFont, f ++ base ++ (amp: g, hold: nl * 16, midi: sh[\midi], a: v[0], d: v[1], s: v[2], r: v[3]))] } {
				// no clip or release: the whole sample
				[ce.note(\sdSampleMod, base ++ (buf: ce.sampleBuffers[sh[\file]], stereoIn: (ce.sampleMono[sh[\file]] != true).asInteger,
					rate: sh[\rate] ? 1, hold: -1, amp: g, a: 0.001, d: 0.001, s: 1, r: 0.01))] }
		}
	}
},
lkPadNames: ["Brace", "Paper", "Wine", "Evening", "Meadow", "Creatures", "No end", "Vast", "Rim echo", "Marimba D",
	"Glockenspiel", "Shaker", "Vibraphone", "Wind", "Crash reverse", "Voice ooh"],

// Language side: buttons, latches, and each stem's notes (k = 16th number)
build: { |self, ce|
	var stem = { |name| self.stems.detect { |s| s.name == name } ? () };   // a stem left out (solo render): a dummy
	var bar = { |k| (k / 16).floor }, t16 = { |k| k / 16 };
	var tone = ("c" ++ ce.mapBus[\tone]).asSymbol, fog = ("c" ++ ce.fogBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var adsr = { |a, d, s, r, def| var v = ce.sdADSR(a, d, s, r, def); (a: v[0], d: v[1], s: v[2], r: v[3]) };
	var padsr = { |a, d, s, r| var v = ce.sdADSR(a, d, s, r, [0.2, 0.001, 1, 0.001]); (pa: v[0], pd: v[1], ps: v[2], pr: v[3]) };
	var synthDef = [0.001, 0.05, 0.6, 0.01];
	var waves = (sine: 0, triangle: 1, sawtooth: 2, square: 3);
	var syn = { |wave, m, g, args, sound = \sdSynthMod| ce.note(sound, (wave: waves[wave], freq: m.midicps, amp: g, thinF: thin,
		tag: wave.asString, g: g, midi: m) ++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	var smp = { |rel, tag, g, args| ce.note(\sdSampleMod, (buf: ce.sampleBuffers[rel], stereoIn: (ce.sampleMono[rel] != true).asInteger,
		amp: g, hold: -1, thinF: thin, tag: tag, g: g) ++ adsr.(nil, nil, nil, nil) ++ (args ? ())) };
	var noise = { |g, args| ce.note(\sdNoise, (color: 0, amp: g, thinF: thin, tag: "pink", g: g) ++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	var modPhase = { |k, at, freq| if(ce.webaudioPhase == true) { (2pi * freq * ((k + at) / 4 / (bpm / 60))) % 2pi } { -1 } };
	var seed = { |latch, b| 1024 * latch.atBar(b) };
	var tensionCC = glob.char;
	// VCSL glockenspiel (strudel.cc's map, its key order): nearest key, the first on a tie
	var glockKeys = [[72, "glock_soft_C5_02"], [84, "glock_soft_C6_01"], [96, "glock_soft_C7_03"], [92, "glock_loud_G#6_01"],
		[67, "glock_soft_G4_01"], [79, "glock_soft_G5_01"], [91, "glock_soft_G6_01"]];
	var glock = { |m, g, args| var best = glockKeys.inject(nil, { |b, x| if(b.isNil or: { (x[0] - m).abs < (b[0] - m).abs }) { x } { b } });
		smp.("vcsl/glockenspiel/" ++ best[1] ++ ".flac", "glockenspiel", g, (rate: 2 ** ((m - best[0]) / 12), midi: m, hold: 1)
			++ adsr.(nil, nil, nil, 1.2) ++ args) };

	// GLOBAL: Chapter (progression, next 4-bar phrase), Break (next bar)
	self.chapter = ce.latch(4, 0, { |i| ce.status("Chapter", chapters[i].name); ce.uiPush });
	ce.cycleButton(glob.btn, chapters.size, { |s| self.chapter.pending = s; ce.status("Chapter (next)", chapters[s].name) });
	self.breakL = ce.latch(1, 0, { |i| ce.status("Break", i); ce.uiPush });
	ce.cycleButton(glob.btn2, 2, { |s| self.breakL.pending = s });
	self.beatOn = { |self, b| self.breakL.atBar(b) == 0 };
	// HARMONY: the chapter's root of the bar; Jonas' pad button 2 freezes it for all while held
	// (asked by every harmonic stem on every 16th, as Strudel queries the root on every tick: the freeze keeps the root
	// of the moment the button went down)
	self.rootAt = { |self, b| var r = chapters[self.chapter.atBar(b)].roots[b % 4];
		if(ce.held(jonas.(1).btn2)) { self.kept = self.kept ? r; self.kept } { self.kept = nil; r } };
	self.lowAt = { |self, b| var r = self.rootAt(b); if(r >= 4) { r - 7 } { r } };   // A, B♭, C an octave down

	// Room / echo of every layer (Strudel roomOf / bus): room = 0.9 × space raised by Tension × 0.5 towards 0.95; echo =
	// max(min(0.9, echo × 2 × space), Tension's echo 0 → 0.4 over 0..0.7); the lead's echo throw: 0.85 while held.
	// Set the moment a control moves (state buses the strips read).
	self.fx = { |self, name, spaceCC, throwCC|
		var e = fxList[name][0], f = fxList[name][1] ? { |s| s };
		var upd = { |send| var s = f.(if(spaceCC.isNil) { 0 } { ce.val(spaceCC) }), t = ce.val(tensionCC), r = 0.9 * s;
			ce.setState((name ++ "Room").asSymbol, r + ((0.95 - r) * 0.5 * t), send);
			e !? { var d = (e * 2 * s).min(0.9).max(ramp.(t, 0, 0.7) * 0.4);
				if(throwCC.notNil and: { ce.held(throwCC) }) { d = 0.85 };
				ce.setState((name ++ "Echo").asSymbol, d, send) } };
		([spaceCC, throwCC, tensionCC]).reject(_.isNil).do { |cc| ce.onCC(cc, { |v, send| upd.(send) }) };
	};
	// the Launchkey's rooms follow Tension too
	ce.onCC(tensionCC, { |v, send| [[\lk03, 0.3], [\lk06, 0.6], [\lk07, 0.7]].do { |x| ce.setState(x[0], x[1] + ((0.95 - x[1]) * 0.5 * v), send) };
		self[\lkRoomUpd].(ce, send) });

	// JOJO 1 KICK — [16th → [gain, length]] per pattern: straight, pickup before the 1, gap (no 4th kick every 4th bar)
	{
		var kc = jojo.(1), four = Dictionary[0 -> [1, 4], 4 -> [1, 4], 8 -> [1, 4], 12 -> [1, 4]];
		var pats = [{ four }, { Dictionary[0 -> [1, 4], 4 -> [1, 4], 8 -> [1, 4], 12 -> [1, 1], 15 -> [0.4, 1]] },
			{ |b| if((b % 4) == 3) { Dictionary[0 -> [1, 4], 4 -> [1, 4], 8 -> [1, 4]] } { four } }];
		self.fx(\kick, kc.space);
		self.kickVar = ce.change(kc.btn, 3, "Kick", ["Straight", "Pickup", "Gap"]);
		stem.(\kick).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), x = pats[self.kickVar.atBar(b)].(b)[k % 16], s, g, lp;
			if(self.beatOn(b).not or: { ce.held(kc.btn2) } or: { x.isNil }) { [] } {
				s = ce.val(kc.char); g = x[0] * 0.8;
				lp = (lpOn: 1, bright: ce.val(kc.bright), lo: 1500, hi: 10000, tone: tone, hold: x[1]);
				[syn.(\sine, 38, g, lp ++ (penv: 24 - (12 * s)) ++ padsr.(nil, 0.035 + (0.045 * s)) ++ adsr.(0.002 + (0.012 * s), 0.4 + (0.2 * s), 0, 0.05)),
				 smp.("tr909/bd-01.wav", "RolandTR909_bd:0", g * 0.75 * (1 - s), lp)].reject { |n| n.amp <= 0 }
			}
		};
	}.value;

	// JOJO 2 NOISE PUMP — Pump: 3 16ths after every kick; Off-beat: the 8th off-beats; Waves: one swell every 2 bars
	{
		var nc = jojo.(2);
		var pats = [[1, 3, 4, (a: 0.14, s: 0.7, r: 0.03, hp: 900, g: 2)], [2, 2, 4, (a: 0.08, s: 0.5, r: 0.06, hp: 1800, g: 2)],
			[0, 32, 32, (a: 1.8, s: 1, r: 1.8, hp: 400, g: 1.4)]];   // [first 16th, length, every n 16ths, sound]
		self.fx(\noise, nc.space); self.fx(\riser, nil);
		self.noiseVar = ce.change(nc.btn, 3, "Noise Pump", ["Pump", "Off-beat", "Waves"]);
		self.riserStart = nil;
		stem.(\noise).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), t = t16.(k), p = pats[self.noiseVar.atBar(b)], m = ce.val(nc.char), out = List[], rr;
			if(self.beatOn(b) and: { (k % p[2]) == p[0] }) {
				// low-pass (live): Brightness × Fog / Tension, breathing with Motion (sine over 2 bars, read at the note)
				out.add(noise.(p[3].g * 0.4, (hold: p[1], hp: p[3].hp, lane: \pump, lpOn: 1, bright: ce.ccMap(nc.bright), lo: 1500,
					hi: 12000, tone: tone, cutMul: 1 - (0.7 * m * ce.sine(t / 2)), pan: 0.5 + (m * (ce.sine(t / 3) - 0.5)))
					++ adsr.(p[3][\a], nil, p[3][\s], p[3][\r])))
			};
			// riser (button 2): 16th noise bursts, a band-pass climbing 300 Hz → 6 kHz over 2 bars (in steps per bar)
			if(ce.held(nc.btn2)) { self.riserStart = self.riserStart ? t.floor } { self.riserStart = nil };
			if(self.riserStart.notNil) {
				rr = ((t.floor - self.riserStart) / 2).clip(0, 1);
				if(rr > 0) { out.add(noise.(rr * 0.35, (bp: 300 * (20 ** rr), bpq: 4, pan: ce.sine(t * 2), hold: 1, lane: \riser)
					++ adsr.(0.03, nil, 0.8, 0.15))) }
			};
			out
		};
	}.value;

	// JOJO 3 SUB — [16th of the beat / bar, length]: Pump (a 16th after each kick), Off-beat, Long (one note per bar)
	{
		var sc = jojo.(3);
		self.fx(\sub, sc.space);
		self.subVar = ce.change(sc.btn, 3, "Sub", ["Pump", "Off-beat", "Long"]);
		stem.(\sub).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), v = self.subVar.atBar(b), s16 = k % 16, len, m, clip, env;
			len = switch(v, 0, { if((s16 % 4) == 1) { 3 } }, 1, { if((s16 % 4) == 2) { 2 } }, 2, { if(s16 == 1) { 15 } });
			if(self.beatOn(b).not or: { len.isNil }) { [] } {
				m = degMidi.(self.lowAt(b), 2) + if(ce.held(sc.btn2)) { 12 } { 0 };
				clip = 1 - (0.65 * ce.val(sc.char));
				env = (hold: len * clip) ++ adsr.(0.015, nil, 1, 0.04);
				[syn.(\sine, m, 0.5, env), syn.(\triangle, m, 0.1 + (0.17 * ce.val(sc.bright)), env)]
			}
		};
	}.value;

	// JOJO 4 BASSLINE — [main line, extra 16ths] in scale degrees above the low root; triangle + a saw 0.07 below
	{
		var bc = jojo.(4);
		var lines = [["[~ 0 0 ~] [~ 0 0 ~] [~ 0 0 ~] [~ 0 4 ~]", "[~ ~ ~ 0]*4"], ["[~ 0]*4", "[~ ~ ~ 0]*4"],
			["[0 ~ ~ 0] [~ ~ 4 ~] [~ 0 ~ ~] [2 ~ 4 ~]", "[~ 0 ~ ~]*4"]].collect { |l| l.collect { |x|
				var v = if(x.endsWith("*4")) { (line.(x.drop(-2)) ! 4).flatten } { line.(x) };
				// 8 steps (8ths) → 16ths of length 2
				if(v.size == 8) { v.collect { |y| [y !? { [y, 2] }, nil] }.flatten } { v.collect { |y| y !? { [y, 1] } } } } };
		self.fx(\bass, bc.space);
		self.bassVar = ce.change(bc.btn, 3, "Bassline", ["Rolling", "Off-beat", "Melodic"]);
		stem.(\bass).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), l = lines[self.bassVar.atBar(b)], s16 = k % 16, c = ce.val(bc.char), out = List[], lp, note, fe;
			if(self.beatOn(b).not) { [] } {
				// a soft filter pluck (lpenv 1.5 octaves, lpdecay 0.15, lpsustain 0) and a little drive (shape 0.2)
				fe = ce.sdADSR(nil, 0.15, 0, nil, [0.005, 0.14, 0, 0.1]);
				lp = (lpOn: 1, bright: ce.val(bc.bright), lo: 250, hi: 2000, tone: tone, lpq: 3, lpenv: 1.5, la: fe[0], ld: fe[1], ls: fe[2],
					lr: fe[3], shape: 0.2) ++ adsr.(0.004, 0.2, 0.35, 0.07);
				note = { |x, g| var m = degMidi.(x[0] + self.lowAt(b), 2) + if(ce.held(bc.btn2)) { 12 } { 0 };
					[syn.(\triangle, m, g, lp ++ (hold: x[1])), syn.(\sawtooth, m - 0.07, g * 0.35, lp ++ (hold: x[1]))] };
				l[0][s16] !? { |x| out.addAll(note.(x, 0.5)) };
				if(c > 0) { l[1][s16] !? { |x| out.addAll(note.(x, 0.35 * c)) } };
				out
			}
		};
	}.value;

	// JOJO 5 CLAP / RIM
	{
		var cc = jojo.(5);
		var pats = [[Dictionary[4 -> 0.7, 12 -> 0.7], Dictionary[]], [Dictionary[], Dictionary[4 -> 0.6, 12 -> 0.6, 15 -> 0.3]],
			[Dictionary[4 -> 0.6, 12 -> 0.6], Dictionary[3 -> 0.35, 10 -> 0.3]]];   // [clap, rim]
		self.fx(\clap, cc.space);
		self.clapVar = ce.change(cc.btn, 3, "Clap / Rim", ["Clap", "Rim", "Both"]);
		stem.(\clap).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), t = t16.(k), s16 = k % 16, p = pats[self.clapVar.atBar(b)], c = ce.val(cc.char), tr, out = List[], lp, hit;
			if(self.beatOn(b).not) { [] } {
				// low-pass × Fog only (Tension does not open it), high-pass 300, a little left
				lp = (lpOn: 1, bright: ce.val(cc.bright), lo: 3500, hi: 14000, tone: fog, hp: 300, pan: 0.47);
				hit = { |file, tag, g| out.add(smp.(file, tag, g * 0.9, lp)) };
				p[0][s16] !? { |g| hit.("tr909/cp-00.wav", "RolandTR909_cp:0", g) };
				p[1][s16] !? { |g| hit.("tr909/rim-00.wav", "RolandTR909_rim:0", g) };
				if(c > 0 and: { s16 == 8 }) { hit.("tr909/rim-00.wav", "RolandTR909_rim:0", 0.25 * ramp.(c, 0, 0.5)) };
				if(c > 0.5) { Dictionary[6 -> 0.18, 14 -> 0.15][s16] !? { |g| hit.("tr909/rim-00.wav", "RolandTR909_rim:0", g * ramp.(c, 0.5, 1)) } };
				if(ce.held(cc.btn2)) { hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.1 + (0.4 * (t % 1))) };
				// Tension's roll: 16ths filling in over the last quarter of the knob
				tr = ramp.(ce.val(tensionCC), 0.75, 1);
				if(tr > 0 and: { ce.rand(t) >= (0.75 * (1 - tr)) }) { hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.06 + (0.29 * tr)) };
				out
			}
		};
	}.value;

	// JOJO 6 HATS
	{
		var hc = jojo.(6);
		var closed = [nil, [0.2, 0.1, 0, 0.12], [0.22, 0.08, 0.14, 0.1]];
		self.fx(\hats, hc.space);
		self.hatVar = ce.change(hc.btn, 3, "Hats", ["Off-beat", "16ths", "Shuffle"]);
		stem.(\hats).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), t = t16.(k), v = self.hatVar.atBar(b), d = ce.val(hc.char), out = List[], g;
			var lp = (lpOn: 1, bright: ce.val(hc.bright), lo: 3000, hi: 16000, tone: fog, pan: 0.56);
			var hh = { |gain, args| out.add(smp.("tr909/hh-00.wav", "RolandTR909_hh:0", gain * 1.2, lp ++ (args ? ()))) };
			// the open hat on the 8th off-beats, short
			if((k % 4) == 2) { out.add(smp.("tr909/oh-00.wav", "RolandTR909_oh:0", 0.4 * 1.2, lp ++ adsr.(nil, 0.12, 0, nil))) };
			// closed 16ths; Shuffle: swung (Strudel swingBy 0.4: the second 16th of each 8th 0.4 of a 16th later)
			closed[v] !? { |c| g = c[k % 4]; if(g > 0) { hh.(g, if(v == 2 and: { k.odd }) { (at: 0.4) } { () }) } };
			// Density: random 16ths, then random 32nds
			if(d > 0 and: { ce.rand(t) >= 0.4 }) { hh.(ramp.(d, 0, 0.5) * 0.12) };
			if(d > 0.5) { 2.do { |j| if(ce.rand(t + (j / 32)) >= 0.8) { hh.(ramp.(d, 0.5, 1) * 0.18, (at: j / 2)) } } };
			if(ce.held(hc.btn2) and: { k.even }) { out.add(smp.("tr909/oh-00.wav", "RolandTR909_oh:0", 0.3 * 1.2, lp)) };
			out
		};
	}.value;

	// JOJO 7 CONGAS — TR-727 perc: n 4 conga low, 2 / 3 bongo high / low, 0 / 1 agogo high / low
	{
		var pc = jojo.(7);
		var pats = ["4 ~ ~ 2 ~ ~ 3 ~ 4 ~ ~ 2 ~ 3 ~ ~", "~ ~ 4 2 ~ ~ 4 ~ ~ 3 ~ 2 ~ ~ 4 ~", "3 ~ 2 ~ 4 ~ 2 3 ~ 2 ~ 4 ~ ~ 2 ~"].collect(line);
		var agogo = line.("~ 0 ~ ~ 1 ~ ~ 0 ~ ~ 1 ~ 0 ~ ~ ~"), fill = line.("2 2 3 3 2 3 4 4 2 2 3 3 4 3 4 4");
		self.fx(\perc, pc.space);
		self.percVar = ce.change(pc.btn, 3, "Congas", ["Pillow", "Rolling", "Latin"]);
		stem.(\perc).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), t = t16.(k), s16 = k % 16, d = ce.val(pc.char), r = ce.rand(t), out = List[];
			var lp = (lpOn: 1, bright: ce.val(pc.bright), lo: 600, hi: 12000, tone: tone, pan: 0.35 + (0.3 * ce.sine(t / 4)));
			var hit = { |n, g| out.add(smp.("tr727/perc-0" ++ n.asInteger ++ ".wav", "RolandTR727_perc:" ++ n.asInteger, g, lp)) };
			pats[self.percVar.atBar(b)][s16] !? { |n| hit.(n, 0.2 + (0.1 * ce.perlin(t))) };
			if(d > 0 and: { r >= 0.55 }) { hit.(2 + (2 * r).trunc, ramp.(d, 0, 0.5) * 0.09) };
			if(d > 0.5) { agogo[s16] !? { |n| hit.(n, ramp.(d, 0.5, 1) * 0.13) } };
			if(ce.held(pc.btn2)) { hit.(fill[s16], 0.25) };
			out
		};
	}.value;

	// JONAS 1 PAD — voicings above the root: seventh chord, upper tones with the 9th, spread; struck every bar
	{
		var pc = jonas.(1), voicings = [[0, 2, 4, 6], [2, 4, 6, 8], [-7, 4, 6, 9]];
		self.fx(\pad, pc.space);
		self.padVar = ce.change(pc.btn, 3, "Pad", ["Warm", "Open", "Wide"]);
		stem.(\pad).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), t = t16.(k), out = List[], sw, lp, pan;
			if((k % 16) != 0) { [] } {
				// Swell: the chord's level dips with a slow sine (2 bars), read at the bar start
				sw = 1 - (0.75 * ce.val(pc.char) * ce.sine(t / 2));
				lp = (lpOn: 1, bright: ce.ccMap(pc.bright), lo: 300, hi: 5000, tone: tone, hold: 16, pan: 0.3 + (0.4 * ce.sine(t / 5)));
				voicings[self.padVar.atBar(b)].do { |d| var m = degMidi.(d + self.rootAt(b), 3);
					out.add(syn.(\sawtooth, m, 0.2 * sw, lp ++ adsr.(0.8, nil, 0.8, 1.8)));
					out.add(syn.(\sawtooth, m + 0.14, 0.2 * sw, lp ++ adsr.(0.8, nil, 0.8, 1.8)));
					out.add(syn.(\triangle, m, 0.25 * sw, lp ++ adsr.(0.8, nil, 0.8, 1.8))) };
				out
			}
		};
	}.value;

	// JONAS 2 DEEP CHORDS — rootless 3rd, 5th, 7th, 9th above the root (D3), stabs on the pattern's 16ths
	{
		var kc = jonas.(2);
		var rh = ["~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ ~", "x ~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~", "~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ x ~",
			"x ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~", "~ ~ ~ x ~ ~ ~ x ~ ~ ~ ~ ~ ~ x ~", ["x ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~"],
			"~ x ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~ ~", "x ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~ ~ ~"].collect { |r| (if(r.isString) { [r] } { r }).collect { |x| x.split($ ).collect(_ == "x") } };
		self.fx(\keys, kc.space); self.fx(\keys2, kc.space);
		self.keysVar = ce.change(kc.btn, 8, "Deep Chords");
		stem.(\keys).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), s16 = k % 16, r = rh[self.keysVar.atBar(b)], len = 1.2 * (0.1 ** ce.val(kc.char)), out = List[];
			var chord = { |lane, hold = 1| [2, 4, 6, 8].do { |d| var m = degMidi.(d + self.rootAt(b), 3), env = adsr.(0.005, len, 0.05, 0.6 * len);
				var lp = (lpOn: 1, bright: ce.val(kc.bright), lo: 600, hi: 8000, tone: tone, hold: hold, shape: 0.1, pan: 0.45, lane: lane);
				out.add(syn.(\sine, m, 0.32, lp ++ env ++ (fmi: 0.7, fmh: 1, modPhase: modPhase.(k, 0, m.midicps))));
				out.add(syn.(\triangle, m, 0.14, lp ++ env)) } };
			if(r[b % r.size][s16]) { chord.(\main) };
			if(ce.held(kc.btn2) and: { (s16 % 4) == 2 }) { chord.(\off, 2) };
			out
		};
	}.value;

	// JONAS 3 PLUCK ARP — degrees above the root (D4), thinned below full Range, passing notes (9th / 6th) by chance
	{
		var ac = jonas.(3);
		var arps = [[0, 2, 4, 2], [0, 2, 4, 6], [4, 2, 0, 2], [2, 4, 6, 8, 6, 4, 2, 4], [0, nil, 2, 4, nil, 2, 4, nil], \poly,
			[6, 4, 2, 4], \alt];
		self.fx(\arp, ac.space);
		self.arpVar = ce.change(ac.btn, 8, "Pluck Arp");
		stem.(\arp).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), t = t16.(k), a = arps[self.arpVar.atBar(b)], rg = ce.val(ac.char), r = ce.rand(t), d, m, g, lp;
			d = case { a == \poly } { [0, 2, 4, 6, 4][k % 5] } { a == \alt } { [[0, 2, 4, 6], [2, 4, 6, 8]][b % 2][k % 4] } { a[k % a.size] };
			if(d.isNil or: { r < (0.35 * (1 - rg)) }) { [] } {
				if(r < (0.25 * rg)) { d = d + [1, 5][b % 2] };
				m = degMidi.(d + self.rootAt(b), 4) + if(ce.held(ac.btn2)) { 12 } { 0 };
				g = 0.45 + (0.2 * ce.perlin(t));
				lp = (lpOn: 1, bright: ce.val(ac.bright), lo: 900, hi: 8000, tone: tone, hold: 1, pan: 0.3 + (0.4 * ce.sine(t / 3)))
					++ adsr.(0.003, 0.16, 0, 0.1);
				[syn.(\triangle, m, g, lp), syn.(\sawtooth, m, g, lp)]
			}
		};
	}.value;

	// JONAS 4 LEAD — lines with held notes ("_"), degrees above the root (D4); triangle + a saw through "o", vibrato
	{
		var lc = jonas.(4);
		var leads = ["4 _ _ _ ~ ~ 2 _ 0 _ _ _ ~ ~ ~ ~", "~ ~ 7 _ _ _ 6 _ 4 _ _ _ ~ ~ ~ ~", "0 _ _ 2 _ _ 4 _ _ _ _ _ ~ ~ ~ ~",
			["4 _ _ _ 5 _ 4 _ 2 _ _ _ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ 0 _ _ _ _ _ ~ ~"], "~ ~ ~ ~ 2 _ _ _ 4 _ _ _ 6 _ _ _",
			"7 _ _ _ _ _ ~ ~ 4 _ _ _ _ _ ~ ~", "~ ~ 4 _ 2 _ 0 _ _ _ _ _ ~ ~ ~ ~", ["0 _ 2 _ 4 _ _ _ _ _ _ _ ~ ~ ~ ~", "~ ~ ~ ~ 6 _ _ _ 4 _ _ _ _ _ ~ ~"]]
			.collect { |l| (if(l.isString) { [l] } { l }).collect(longLine) };
		self.fx(\lead, lc.space, lc.btn2);
		self.leadVar = ce.change(lc.btn, 8, "Lead");
		stem.(\lead).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), s16 = k % 16, c = ce.val(lc.char), out = List[], l = leads[self.leadVar.atBar(b)];
			var lp = (lpOn: 1, bright: ce.ccMap(lc.bright), lo: 600, hi: 5000, tone: tone, vib: 4.5, vibmod: 0.07) ++ adsr.(0.08, 0.3, 0.7, 0.4);
			var voice = { |deg, len, g, args| var m = degMidi.(deg + self.rootAt(b), 4);
				out.add(syn.(\triangle, m, 0.35 * g, lp ++ (hold: len) ++ (args ? ())));
				out.add(syn.(\sawtooth, m, 0.1 * g, lp ++ (hold: len, vowel: 3) ++ (args ? ()), \sdSynthFx)) };
			l[b % l.size][s16] !? { |x|
				voice.(x[0], x[1], 1);
				if(c > 0) { voice.(x[0] - 2, x[1], 0.55 * ramp.(c, 0, 0.5)) } };
			// the canon: the line half a bar later, an octave up (the line of half a bar ago, on this bar's root)
			if(c > 0.5) { var u = k - 8, bb = (u / 16).floor; l = leads[self.leadVar.atBar(bb)];
				l[bb % l.size][u % 16] !? { |x| voice.(x[0] + 7, x[1], 0.4 * ramp.(c, 0.5, 1), (pan: 0.65)) } };
			out
		};
	}.value;

	// JONAS 5 MARIMBA — a phrase at the end of every second bar (every bar while button 2 is held), random chord tones
	{
		var mc = jonas.(5), tones = [0, 2, 4, 6, 7];
		var rh = ["~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x x ~",
			"~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~ x", "~ ~ ~ ~ ~ ~ x ~ ~ ~ x ~ ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ ~ ~ ~ ~",
			"~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x ~ x ~ ~", "~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~ ~ ~ x x"].collect { |r| r.split($ ).collect(_ == "x") };
		self.fx(\ans, mc.space);
		self.ansVar = ce.change(mc.btn, 8, "Marimba");
		stem.(\ans).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), t = t16.(k), s16 = k % 16, v = self.ansVar.atBar(b), c = ce.val(mc.char), out = List[], tn;
			if(rh[v][s16].not or: { ce.held(mc.btn2).not and: { (b % 2) == 0 } }) { [] } {
				tn = tones[(5 * ce.rand(t + seed.(self.ansVar, b))).trunc];
				[[0, 0.6], [2, if(c > 0) { 0.5 * ramp.(c, 0, 0.5) } { 0 }], [4, if(c > 0.5) { 0.42 * ramp.(c, 0.5, 1) } { 0 }]].do { |x|
					if(x[1] > 0) { var m = degMidi.(tn + x[0] + self.rootAt(b), 4);
						var lp = (lpOn: 1, bright: ce.val(mc.bright), lo: 1200, hi: 9000, tone: tone, hold: 1, pan: [0.3, 0.7][s16 % 2])
							++ adsr.(0.002, 0.22, 0, 0.1);
						out.add(syn.(\sine, m, x[1], lp)); out.add(syn.(\sine, m + 24, x[1] * 0.15, lp)) } };
				out
			}
		};
	}.value;

	// JONAS 6 GLOCKENSPIEL — chord tones above the root (D5) on random 16ths, struck as by hand; Run on button 2
	{
		var gc = jonas.(6), tones = [0, 2, 4, 6, 7, 9, 11], run = [0, 2, 4, 6, 7, 9, 11, 13, 14, 13, 11, 9, 7, 6, 4, 2];
		self.fx(\bells, gc.space); self.fx(\run, gc.space);
		self.bellVar = ce.change(gc.btn, 8, "Glockenspiel");
		self.bellStart = nil;
		stem.(\bells).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), t = t16.(k), out = List[], r = ce.rand(t + seed.(self.bellVar, b)), keep = 0.1 + (0.5 * ce.val(gc.char)), rr;
			var lp = (lpOn: 1, bright: ce.val(gc.bright), lo: 3000, hi: 16000, tone: tone);
			// one random number decides: kept?, tone, gain, pan (reseeded)
			if(r >= (1 - keep)) { out.add(glock.(degMidi.(tones[(7 * r).trunc] + self.rootAt(b), 5), 0.45 + (0.4 * r), lp ++ (pan: 0.25 + (0.5 * r)))) };
			if(ce.held(gc.btn2)) { self.bellStart = self.bellStart ? t.floor } { self.bellStart = nil };
			if(self.bellStart.notNil) {
				rr = ((t.floor - self.bellStart) / 2).clip(0, 1);
				2.do { |j| var u = t + (j / 32);
					if(ce.rand(u) >= (0.85 - (0.75 * rr))) {
						out.add(glock.(degMidi.(run[((k * 2) + j) % 16] + self.rootAt(b), 5), (0.35 + (0.55 * rr)) * (0.7 + (0.3 * ce.rand(t.floor))),
							lp ++ (at: j / 2, hold: 0.5, pan: 0.3 + (0.4 * ce.sine(u * 2)), lane: \run))) } }
			};
			out
		};
	}.value;

	// JONAS 7 BIRDS — chirps (a quick sweep onto the note from up to 10 semitones off) on chord tones, D6 / D7
	{
		var bc = jonas.(7), tones = [0, 2, 4, 7];
		// the rhythms: [16th → [offsets within it]], one or two bars
		var h = [[0, 0.5], [0.5, 0.5]], one = [[0, 1]];
		var rh = [[Dictionary[10 -> h]], [Dictionary[3 -> one, 13 -> one]], [Dictionary[6 -> [[0, 1/3], [1/3, 1/3], [2/3, 1/3]]]],
			[Dictionary[12 -> h, 14 -> one], Dictionary[]], [Dictionary[1 -> h]], [Dictionary[5 -> one, 14 -> one]],
			[Dictionary[], Dictionary[8 -> [[0, 0.25], [0.25, 0.25], [0.5, 0.25], [0.75, 0.25]]]], [Dictionary[14 -> h, 15 -> one]]];
		self.fx(\birds, bc.space); self.fx(\birds2, bc.space); self.fx(\birds3, bc.space);
		self.birdVar = ce.change(bc.btn, 8, "Birds");
		stem.(\birds).notes = { |k|
			var b = bar.(k), rt0 = self.rootAt(b), t = t16.(k), s16 = k % 16, v = self.birdVar.atBar(b), a = ce.val(bc.char), out = List[];
			// the note of a 32nd (reseeded): a chord tone
			var noteAt = { |u| tones[(4 * ce.rand(((u + seed.(self.birdVar, b)) * 32).floor / 32)).trunc] };
			var lp = (lpOn: 1, bright: ce.val(bc.bright), lo: 2000, hi: 14000, tone: tone);
			var chirp = { |u, oct, g, len, lane, pan| var r = ce.rand(u), m = degMidi.(noteAt.(u) + self.rootAt(b), oct);
				out.add(syn.(\sine, m, g, lp ++ (at: (u - t) * 16, hold: len, pan: pan, lane: lane, penv: -8 + (18 * r))
					++ padsr.(nil, 0.05) ++ adsr.(0.003, 0.05 + (0.05 * r), 0, 0.03))) };
			var r = rh[v];
			r[b % r.size][s16] !? { |offs| offs.do { |o| var u = t + (o[0] / 16); chirp.(u, 6, 0.22, o[1], \main, 0.25 + (0.5 * ce.rand(u))) } };
			// more birds (row 3): random 32nds an octave higher; button 2: random 32nds
			2.do { |j| var u = t + (j / 32);
				if(a > 0 and: { ce.rand(u) >= (1 - (0.18 * a)) }) { chirp.(u, 7, 0.15 * a, 0.5, \more, ce.rand(u)) };
				if(ce.held(bc.btn2) and: { ce.rand(u) >= 0.4 }) { chirp.(u, 6, 0.2, 0.5, \held, ce.rand(u)) } };
			out
		};
	}.value;
}
,
)
)
