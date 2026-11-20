// TRACK 008 GROOVE TECHNO — SuperCollider port of tracks/008-groove-techno/008-groove-techno.strudel (groove techno on F,
// 140 BPM). Same controller layout as the Strudel track: Mode 1 = Jojo (foundation, plain CCs), Mode 2 = Jonas
// (colour, CC + 48), column 8 global on both (Jojo's column 8, the ride, is off as in Strudel), the Launchkey MK4 25
// optional. Ported 1:1 (see sc/PORTING.md). Level (faders, mod wheel) acts from the next note, as in Strudel; Space,
// echo and the global column act at once, also on sounding notes; Brightness (and Sound on the strings) acts at once on the long sounds (pads, strings, breath, Launchkey keys),
// on the short ones from the next note; pattern buttons switch at the next bar.
// The @ tags below are read by the web UI (sc/ui): column names, and each control's name | what it does.
// @layout Track 008 — groove techno (SuperCollider)
// @mode 16 Mode 1 — Jojo: Foundation (beat + bass) · same CCs as Mode 16
// @col 16:1 1 Kick
// @col 16:2 2 Rumble
// @col 16:3 3 Sub
// @col 16:4 4 Bassline
// @col 16:5 5 Clap
// @col 16:6 6 Hats
// @col 16:7 7 Percussion
// @col 16:8 8 Global
// @mode 2 Mode 2 — Jonas: Colour (chords + melodies) · CC + 48
// @col 2:1 1 Pads
// @col 2:2 2 Strings
// @col 2:3 3 Sequence
// @col 2:4 4 Stab
// @col 2:5 5 Answer
// @col 2:6 6 Dark Perc
// @col 2:7 7 FX / Breath
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | build-up: echo, reverb, open filters; the end adds a snare roll.
// @ctl g.fader Master | volume of everything.
// @ctl g.b1 Chapter | mood: dark → tense → warm, at the next bar.
// @ctl g.b2 Break | 1st: low end out. 2nd: all back on the one.
// @ctl 16:1.k1 Brightness | dull ↔ bright.
// @ctl 16:1.k2 Space | dry ↔ room.
// @ctl 16:1.k3 Punch | 0 = really soft thump, middle = round kick, 1 = hard and punchy.
// @ctl 16:1.fader Level | 0 = gone. Kick on every beat, tuned to C (fifth of F).
// @ctl 16:1.b1 Double time | 8 kicks per bar instead of 4 while held.
// @ctl 16:1.b2 Drop out | kick pauses while held.
// @ctl 16:2.k1 Brightness | dull ↔ bright.
// @ctl 16:2.k2 Space | dry ↔ room.
// @ctl 16:2.k3 Motion | still ↔ the filter breathes and the rumble echoes in 16ths.
// @ctl 16:2.fader Level | rumble under the kick, same pitch (C).
// @ctl 16:2.b1 Pattern | 3rd + 4th 16th → 2nd–4th → only the 3rd.
// @ctl 16:2.b2 Riser | a noise sweep rises over 2 bars while held.
// @ctl 16:3.k1 Brightness | dull ↔ bright.
// @ctl 16:3.k2 Space | dry ↔ room.
// @ctl 16:3.k3 Length | long, pumping notes ↔ short, bouncing ones.
// @ctl 16:3.fader Level | pumping sub, follows Jonas' chords.
// @ctl 16:3.b1 Pattern | pump → fifth on beat 4 → syncopated.
// @ctl 16:3.b2 Octave | one octave up while held.
// @ctl 16:4.k1 Brightness | dull ↔ bright.
// @ctl 16:4.k2 Space | dry ↔ room.
// @ctl 16:4.k3 Complexity | the line as written ↔ quiet ghost 16ths roll in the gaps.
// @ctl 16:4.fader Level | dark rolling bass, follows Jonas' chords.
// @ctl 16:4.b1 Pattern | 3-3-2 → rolling → acid → stomp.
// @ctl 16:4.b2 Octave | one octave up while held.
// @ctl 16:5.k1 Brightness | dull ↔ bright.
// @ctl 16:5.k2 Space | dry ↔ room.
// @ctl 16:5.k3 Complexity | plain ↔ a quiet clap before beat 3 ↔ + small double taps.
// @ctl 16:5.fader Level | clap on 2 and 4. Also the level of Tension's snare roll.
// @ctl 16:5.b1 Pattern | short clap → with pickup → full drop clap (tail + double).
// @ctl 16:5.b2 Swell | snare swell over 4 bars while held.
// @ctl 16:6.k1 Brightness | dull ↔ bright.
// @ctl 16:6.k2 Space | dry ↔ room.
// @ctl 16:6.k3 Complexity | the pattern as it is ↔ + quiet 16ths ↔ + little 32nd rolls.
// @ctl 16:6.fader Level | open hats. Keep playing in the break.
// @ctl 16:6.b1 Pattern | open off-beat → + closed 16ths → driving.
// @ctl 16:6.b2 Long | the open hats ring longer, on every 8th, while held.
// @ctl 16:7.k1 Brightness | dull ↔ bright.
// @ctl 16:7.k2 Space | dry ↔ room.
// @ctl 16:7.k3 Complexity | steady pattern ↔ + fingertip ghost notes ↔ + little rolls.
// @ctl 16:7.fader Level | bongos and rimshot. Keep playing in the break.
// @ctl 16:7.b1 Pattern | pillow → gallop → 3-3-2.
// @ctl 16:7.b2 Fill | a bongo run down over the bar while held.
// @ctl 2:1.k1 Brightness | dull ↔ bright.
// @ctl 2:1.k2 Space | dry ↔ echo + room.
// @ctl 2:1.k3 Pump | 0 = held chords ↔ the kick pumps the chords on every beat.
// @ctl 2:1.fader Level | the pads (pad + techno pad).
// @ctl 2:1.b1 Pattern | next of 8 chord progressions, for all.
// @ctl 2:1.b2 Colour | 7 → 9 → fourths → fifths, at the next bar.
// @ctl 2:2.k1 Brightness | dull ↔ bright.
// @ctl 2:2.k2 Space | dry ↔ echo + room.
// @ctl 2:2.k3 Sound | JX-10 strings ↔ analogue strings (pulse + saw).
// @ctl 2:2.fader Level | background strings on F minor.
// @ctl 2:2.b1 Pattern | next move: to D♭ · to A♭ · line up · line down · chain, at the next bar.
// @ctl 2:2.b2 Echo throw | long echo on the strings while held.
// @ctl 2:3.k1 Brightness | dull ↔ bright.
// @ctl 2:3.k2 Space | dry ↔ echo + room.
// @ctl 2:3.k3 Complexity | few notes ↔ loop fills in.
// @ctl 2:3.fader Level | hypnotic loop on the chord.
// @ctl 2:3.b1 Pattern | next of 8 loops (3, 5 or 7 steps).
// @ctl 2:3.b2 Octave | one octave up while held.
// @ctl 2:4.k1 Brightness | dull ↔ bright.
// @ctl 2:4.k2 Space | dry ↔ echo + room.
// @ctl 2:4.k3 Variation | as written ↔ quick 16ths, octave jumps.
// @ctl 2:4.fader Level | hypnotic stab on the chord root.
// @ctl 2:4.b1 Pattern | next of 8 stab figures.
// @ctl 2:4.b2 Echo throw | long echo on the stab while held.
// @ctl 2:5.k1 Brightness | dull ↔ bright.
// @ctl 2:5.k2 Space | dry ↔ echo + room.
// @ctl 2:5.k3 Complexity | one voice → + third → + fifth → + 7th, strummed.
// @ctl 2:5.fader Level | counter blips, a short phrase every second bar.
// @ctl 2:5.b1 Pattern | next of 8 phrase rhythms (new notes too).
// @ctl 2:5.b2 Answer | random extra answers while held.
// @ctl 2:6.k1 Brightness | dull ↔ bright.
// @ctl 2:6.k2 Space | dry ↔ echo + room.
// @ctl 2:6.k3 Complexity | claves → + ticks → + zaps → 32nds.
// @ctl 2:6.fader Level | dark fast percussion.
// @ctl 2:6.b1 Pattern | next of 8 clave figures.
// @ctl 2:6.b2 Roll | shaker and metal roll in 32nds, fuller and louder the longer it is held.
// @ctl 2:7.k1 Brightness | dull ↔ bright.
// @ctl 2:7.k2 Space | dry ↔ echo + room.
// @ctl 2:7.k3 Complexity | breath only ↔ chord pulses in 8ths.
// @ctl 2:7.fader Level | slow, uneven breathing.
// @ctl 2:7.b1 Pattern | one breath per 2 → 4 → 8 → 1 bar(s).
// @ctl 2:7.b2 Open | the breath opens fully while held.
// @lk level Keys Level | mod wheel: volume of the keys.
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
var bpm = 140, beat = 60 / bpm;
// ---------------------------------------------------------------------------------------------------------
// CC numbers of column n (1-8): row 1-3 knobs, fader, buttons. Jojo = plain, Jonas = + 48.
var col = { |n, plus = 0| (bright: 12 + n + plus, space: 20 + n + plus, char: 28 + n + plus, level: 4 + n + plus,
	btn: 36 + n + plus, btn2: 44 + n + plus) };
var jojo = { |n| col.(n) }, jonas = { |n| col.(n, 48) };
var glob = col.(8);   // column 8 (global) answers on its Mode 1 and Mode 2 CCs: aliases below

// ---------------------------------------------------------------------------------------------------------
// MOODS (Chapter, global button 1) — all on F, so a switch keeps the root and only the colour changes
var moods = [(name: "Dark", steps: [0, 2, 3, 5, 7, 8, 10]),    // F minor
	(name: "Tight", steps: [0, 1, 3, 5, 7, 8, 10]),             // F phrygian
	(name: "Warm", steps: [0, 2, 3, 5, 7, 9, 10])];             // F dorian
// Strudel's n(deg).scale('F<oct>:<mood>'): the degree (rounded up) in the mood's scale from F<oct>, octaves wrap
var degMidi = { |deg, oct, mood| var st = deg.ceil.asInteger;
	(12 * (oct + 1)) + 5 + moods[mood].steps[st % 7] + (12 * (st / 7).floor) };
// HARMONY — chord roots as scale degrees (0 = F), one chord per 2 bars, 4 chords = 8 bars (Jonas' pad button 1)
var progs = [[0, 0, 0, 0], [0, 0, -2, -2], [0, 3, 0, 3], [0, -2, -3, -2], [0, 2, 3, 2], [0, 0, 4, 3], [3, 3, 0, 0], [0, 5, 3, 4]];
var progNames = ["1", "1–6", "1–4", "1–6–5–6", "1–3–4–3", "1–5–4", "4–1", "1–6–4–5"];
// a step line as Strudel writes it ("~ 0 ~ 7 …") → [degree or nil per step]
var line = { |str| str.split($ ).reject(_.isEmpty).collect { |x| if(x == "~") { nil } { x.asFloat } } };
var ramp = { |v, from, to| ((v - from) / (to - from)).clip(0, 1) };
// Punch (kick row 3): soft at 0, round at 0.5, hard at 1, straight lines in between
var punch3 = { |p, soft, round, hard| if(p < 0.5) { soft + ((round - soft) * 2 * p) } { round + ((hard - round) * ((2 * p) - 1)) } };

(
name: "008-groove-techno",
bpm: bpm,
global: (fog: glob.bright, thin: glob.space, tension: glob.char, master: glob.level),
// column 8 works on both pages: its Mode 2 CCs (+ 48) write the same buses as its Mode 1 CCs (last moved wins)
aliases: [\bright, \space, \char, \level, \btn, \btn2].collect { |r| (glob[r] + 48) -> glob[r] }.asDict,
// web UI: the head line (chapter, chord colour, break) and column 8's buttons
uiHead: { |self, ce|
	var pend = { |now, next| if(now == next) { [now] } { [now, next] } };
	[["Chapter"] ++ pend.("F " ++ moods[self.mood.now].name, "F " ++ moods[self.mood.pending].name),
	 ["Colour"] ++ pend.(self.padColours[self.colour.now][0], self.padColours[self.colour.pending][0]),
	 ["Break"] ++ pend.(["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending])]
},
uiGlobal: { |self, ce| (b1: ["F " ++ moods[self.mood.now].name, "F " ++ moods[self.mood.pending].name],
	b2: [["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending]], b2on: self.breakL.pending == 1) },
// Effect buses (Strudel orbits). Orbit 1 = drums and bass: small room (size 1.6), short dotted-8th slap.
// Orbit 2 = all of Jonas' colour: dub room (size 4), dotted-8th echo with long feedback.
// Orbit 3 = rumble only: the reverb is the sound (size 2.6), a 16th echo. Impulse responses measured from superdough.
orbits: (1: (ir: "ir/orbit-1.6.wav", delay: [0.75 * beat, 0.3]), 2: (ir: "ir/orbit-4.wav", delay: [0.75 * beat, 0.58]),
	3: (ir: "ir/orbit-2.6.wav", delay: [0.25 * beat, 0.45])),
// state buses: room and echo amounts the language derives from knobs (columns whose Space is scaled, echo throws)
states: (rumRoom: 0.9 * 0.35, rumEcho: 0, padRoom: 0.9 * 0.3, strRoom: 0.9 * 0.3, strEcho: 0, strJx: 1, strAn: 0,
	seqRoom: 0.9 * 0.3, seqEcho: 0.4 * 2 * 0.3, stabRoom: 0.9 * 0.25, stabEcho: 0, ansRoom: 0.9 * 0.35, ansEcho: 0.55 * 2 * 0.35,
	fxRoom: 0.9 * 0.08, lkLevel: 0, lkBright: 0, lkRoom: 0.9 * 0.1, lkEcho: 0),
// samples the drum stems play (the files Strudel plays: tidal-drum-machines, see sc/samples/CREDITS.md)
samples: ["tr909/bd-01.wav", "tr909/cp-00.wav", "tr909/sd-00.wav", "tr909/oh-00.wav", "tr909/hh-00.wav", "tr909/rim-00.wav",
	// the Launchkey's drum pads: more drum-machine one-shots, Dirt-Samples (strudel.cc's default samples), the spoken samples
	"voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac", "voice/plaenterwald.flac",
	"voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac", "voice/the_evening_does_not_end.flac", "voice/in_the_vast.flac",
	"tr909/lt-00.wav", "tr909/cr-00.wav", "tr808/sh-00.wav", "dirt/space-00.wav", "dirt/wind-00.wav"] ++ ~ce.lkKeysFiles,

stems: [
	// JOJO 1 KICK — a sine kick tuned to C2 (the fifth of F) with a pitch drop, a little 909 click on top; Punch
	// soft → round → hard (attack, decay, pitch drop, click, drive). Double time / drop out while held. No echo.
	(name: \kick, sounds: [\sdSynthMod, \sdSampleMod], level: jojo.(1).level, space: jojo.(1).space, orbit: 1, thin: false),
	// JOJO 2 RUMBLE — the kick's sound low-passed into a dark reverb (own orbit), on the 3rd and 4th 16th of every
	// beat; Motion breathes the filter and adds a 16th echo. Riser on button 2 (its own lane: orbit 2, space 0.3).
	(name: \rumble, sounds: [\sdSynthMod, \sdSampleMod, \sdNoise], level: jojo.(2).level, trim: 0.68, thin: false,
		lanes: [(name: \pump, orbit: 3, roomR: \rumRoom, echoSend: \rumEcho),
			(name: \riser, orbit: 2, roomR: 0.9 * 0.3, echoSend: 0)]),
	// JOJO 3 SUB — a pumping sine (+ a triangle for brightness) on the chord root, each note a 16th after the kick
	(name: \sub, sounds: [\sdSynthMod], level: jojo.(3).level, space: jojo.(3).space, orbit: 1, trim: 0.65, thin: false),
	// JOJO 4 BASSLINE — a dark rolling line: saws through a resonant low-pass that snaps open on every note, a wide
	// top layer above 200 Hz (left, and right 12 ms later), ghost 16ths on row 3; follows Jonas' chords
	(name: \bass, sounds: [\sdSynthMod], level: jojo.(4).level, space: jojo.(4).space, orbit: 1, trim: 0.6, thin: false),
	// JOJO 5 CLAP — a short 909 clap on 2 and 4 (the full one for the drop), ghost claps, snare swell, Tension's roll
	(name: \clap, sounds: [\sdSample], level: jojo.(5).level, space: jojo.(5).space, orbit: 1, trim: 0.4, thin: false),
	// JOJO 6 HATS — open 909 hats on the off-beats, crisp; closed 16ths around them
	(name: \hats, sounds: [\sdSample], level: jojo.(6).level, space: jojo.(6).space, orbit: 1, trim: 0.075, thin: false),
	// JOJO 7 PERCUSSION — soft tuned sine bongos (F, C, E♭, A♭) and a 909 rimshot, panning slowly
	(name: \perc, sounds: [\sdSynthMod, \sdSample], level: jojo.(7).level, space: jojo.(7).space, orbit: 1, trim: 0.85, thin: false),
	// JONAS 1 PADS — pad (two detuned saws + triangle, slow attack) and techno pad (three saws left / middle / right)
	// together; Pump fades to chords struck on every beat; button 1 = the progression for all, button 2 = chord colour
	(name: \pad, sounds: [\sdSynthMod], level: jonas.(1).level, roomR: \padRoom, orbit: 2, trim: 1.2, thin: false),
	// JONAS 2 STRINGS — background strings on an open F minor, one voice moving now and then; Sound fades JX-10 strings
	// (supersaws) ↔ analogue strings (squares, saw, triangle): a lane each, the crossfade on their fades (at once)
	(name: \strings, sounds: [\sdSupersawWide, \sdSynthMod], level: jonas.(2).level, orbit: 2, trim: 0.7, thin: false,
		roomR: \strRoom, echoSend: \strEcho, tensionEcho: false, lanes: [(name: \jx, fade: \strJx), (name: \analog, fade: \strAn)]),
	// JONAS 3 SEQUENCE — a hypnotic FM mallet loop (3, 5 or 7 steps against the 4/4) on the chord, echo
	(name: \seq, sounds: [\sdSynthMod], level: jonas.(3).level, roomR: \seqRoom, echoSend: \seqEcho, orbit: 2, trim: 0.8, thin: false),
	// JONAS 4 STAB — root + fifth on detuned saws (+ a square below) through a resonant low-pass that snaps shut
	(name: \stab, sounds: [\sdSynthMod], level: jonas.(4).level, roomR: \stabRoom, echoSend: \stabEcho, tensionEcho: false,
		orbit: 2, trim: 0.62, thin: false),
	// JONAS 5 ANSWER — short square blips at the end of every second bar, left and right, long echo
	(name: \answer, sounds: [\sdSynthMod], level: jonas.(5).level, roomR: \ansRoom, echoSend: \ansEcho, orbit: 2, trim: 0.79, thin: false),
	// JONAS 6 DARK PERC — FM claves, a white-noise shaker, metal ticks, falling zaps, a 32nd roll on button 2
	(name: \darkperc, sounds: [\sdSynthMod, \sdNoise], level: jonas.(6).level, space: jonas.(6).space, orbit: 2, trim: 0.8, thin: false),
	// JONAS 7 FX / BREATH — pink-noise grains whose level and band-pass breathe slowly; Complexity adds chord pulses
	(name: \fx, sounds: [\sdNoise, \sdSynthMod], level: jonas.(7).level, roomR: \fxRoom, orbit: 2, trim: 0.17, thin: false),
	// LAUNCHKEY MK4 25 — keys: Jonas' keys of 009 (piano / Rhodes, B3 / M1, vibraphone / marimba; orbit 2, mod wheel =
	// level); drum pads: 16 one-shots (orbit 1, each lane a shot's own room / echo). No Tension echo (Strudel gives none).
	(name: \lk, sounds: ~ce.lkKeysSounds ++ [\sdSampleMod, \sdSynthMod], level: \lkLevel, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \shots, orbit: 1, level: 1.0, roomR: 0.3), (name: \lt, orbit: 1, level: 1.0, roomR: 0.5),
			(name: \rim, orbit: 1, level: 1.0, roomR: 0.3, echoSend: 0.4), (name: \braaam, orbit: 1, level: 1.0, roomR: 0.9),
			(name: \space, orbit: 1, level: 1.0, roomR: 0.9), (name: \wind, orbit: 1, level: 1.0, roomR: 0.8)]),
],

// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these). Mod wheel (CC 1) = keys level, knobs CC 31-38:
// 1 brightness, 2-4 the keys' sound pairs, 5 length, 6 space, 7 echo, 8 one-shot darkness. Every key plays a note of
// fixed length (Strudel's midikeys has no note-off: the length is knob 5). Brightness, Space and Echo act at once.
lkCtl: { |ce, num, v, send|
	if(num == 32) { ce.lkTurned2 = true };   // knob 2 keeps its start value 0.5 (piano + Rhodes) until it is turned
	switch(num,
		1, { ce.setState(\lkLevel, v, send) },
		31, { ce.setState(\lkBright, v, send) },
		36, { ce.setState(\lkRoom, 0.9 * (0.1 + (0.7 * v)), send) },   // roomOf(0.1 … 0.8)
		37, { ce.setState(\lkEcho, 0.6 * v, send) })
},
lkNote: { |ce, note, vel, chan|
	var k = { |n| ce.lkCC[30 + n] }, nl = 0.25 + (1.75 * k.(5));   // note length in bars
	var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	if(chan != 9) {
		ce.lkKeysNotes(note, vel, [if(ce.lkTurned2 == true) { k.(2) } { 0.5 }, k.(3), k.(4)],
			(hold: nl * 16, lane: \keys, tone: tone, bright: ce.stateMap(\lkBright), thinF: thin))
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
		var i = (note - 36) % 16, sh = shots[i], g = (sh[\gain] ? 0.8) * vel, gl = (sh[\gain] ? 1) * vel, now = thisThread.seconds;
		// the low-pass: knob 8 (18 kHz → 800 Hz) × Fog / Tension at the hit, the shot's own at most
		var tv = (0.06 ** ce.val(glob.bright)) * (1 + (1.5 * ce.val(glob.char)));
		var cut = ((18000 * ((800 / 18000) ** k.(8))) * tv).clip(80, 18000).min(sh[\cutoff] ? 18000);
		var base = (lpOn: 1, lo: cut, hi: cut, tone: 1, thinF: thin, lane: sh[\lane] ? \shots, tag: sh[\tag]);
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
					rate: sh[\rate] ? 1, hold: -1, amp: g, g: gl, hp: sh[\hp] ? 0, a: 0.001, d: 0.001, s: 1, r: 0.01))]
			}
		}
	}
},
// web UI: the names of the 16 drum pads (pads 1-8 = notes 36-43, 9-16 = 44-51)
lkPadNames: ["Brace", "Paper", "Wine", "Plaenterwald", "Wiese", "Creatures", "No end", "Vast", "Low tom", "Rim echo",
	"Braaam", "Open hat", "Crash reverse", "Shaker", "Space", "Wind"],

// Language side: buttons, latches, and each stem's notes (k = 16th number)
build: { |self, ce|
	var stem = { |name| self.stems.detect { |s| s.name == name } ? () };   // a stem left out (solo render): a dummy
	var bar = { |k| (k / 16).floor }, t16 = { |k| k / 16 };
	var tone = ("c" ++ ce.toneBus).asSymbol, fog = ("c" ++ ce.fogBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	var adsr = { |a, d, s, r, def| var v = ce.sdADSR(a, d, s, r, def); (a: v[0], d: v[1], s: v[2], r: v[3]) };
	var synthDef = [0.001, 0.05, 0.6, 0.01];
	var waves = (sine: 0, triangle: 1, sawtooth: 2, square: 3);
	// a synth note (sdSynthMod): wave name, MIDI note, Strudel gain (× velocity), args; tag/g/midi for the comparison
	var syn = { |wave, m, g, args| ce.note(\sdSynthMod, (wave: waves[wave], freq: m.midicps, amp: g, thinF: thin,
		tag: wave.asString, g: g, midi: m) ++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	// a sample note: tag = Strudel's bank_s:n, g = Strudel's gain; plays to its end unless hold is given
	var smp = { |rel, tag, g, args, sound = \sdSample| ce.note(sound, (buf: ce.sampleBuffers[rel], stereoIn: (ce.sampleMono[rel] != true).asInteger,
		amp: g, hold: -1, thinF: thin, tag: tag, g: g) ++ adsr.(nil, nil, nil, nil) ++ (args ? ())) };
	// the FM modulator's start phase: offline as superdough's render has it (started at time 0), live random
	var modPhase = { |k, at, freq| if(ce.webaudioPhase == true) { (2pi * freq * ((k + at) / 4 / (bpm / 60))) % 2pi } { -1 } };

	// Knob defaults of the Strudel track (live only, as there: Web MIDI): Jonas' pad Space 0.5,
	// until the knob is moved. Offline renders (comparisons) start from the scenario's values, as the Node tools do.
	if(ce.log.isNil) {
		var send = { |m| ce.server.sendMsg(*m) };
		ce.setCC(69, 0.5, send, true);
	};

	// GLOBAL: Chapter (mood, next bar), Break (next bar)
	self.mood = ce.latch(1, 0, { |i| ce.status("Chapter", moods[i].name); ce.uiPush });
	ce.cycleButton(glob.btn, moods.size, { |s| self.mood.pending = s; ce.status("Chapter (next)", moods[s].name) });
	self.breakL = ce.latch(1, 0, { |i| ce.status("Break", i); ce.uiPush });
	ce.cycleButton(glob.btn2, 2, { |s| self.breakL.pending = s });
	self.beatOn = { |self, b| self.breakL.atBar(b) == 0 };
	self.tension = glob.char;

	// HARMONY: Jonas' pad button 1 picks the progression (next bar); everybody follows its root
	self.padVar = ce.change(jonas.(1).btn, progs.size, "Pads", progNames);
	self.rootAt = { |self, b| progs[self.padVar.atBar(b)][(b / 2).floor % 4] };
	self.moodAt = { |self, b| self.mood.atBar(b) };
	// Pad colour (Jonas pad button 2): chord shapes in scale degrees above the root, at the next bar
	self.padColours = [["7", [0, 2, 4, 6]], ["9", [0, 2, 4, 6, 8]], ["Quarten", [0, 3, 6, 9]], ["Quinten", [0, 4, 8]]];
	self.colour = ce.latch(1, 0, { |i| ce.status("Colour", self.padColours[i][0]); ce.uiPush });
	ce.cycleButton(jonas.(1).btn2, self.padColours.size, { |s| self.colour.pending = s });

	// JOJO 1 KICK — Strudel row: 4/4 (button 1 held: 8/4), so the UI shows the same fixed row
	{
		var kc = jojo.(1);
		ce.uiRows['jojo:1'] = (latch: (now: 0, pending: 0), names: ["4/4 (held: 8/4)"]);
		stem.(\kick).notes = { |k|
			var b = bar.(k), dbl = ce.held(kc.btn), step = if(dbl) { 2 } { 4 }, p, vel, sh, lp;
			if(self.beatOn(b).not or: { ce.held(kc.btn2) } or: { k % step != 0 }) { [] } {
				p = ce.val(kc.char); vel = punch3.(p, 1, 1, 0.56); sh = punch3.(p, 0, 0, 0.4);
				lp = (lpOn: 1, bright: ce.val(kc.bright), lo: 900, hi: 9000, tone: tone, shape: sh);
				[
					syn.(\sine, 36, 0.8 * vel, (hold: step, penv: punch3.(p, 12, 24, 36), pd: punch3.(p, 0.09, 0.05, 0.03))
						++ adsr.(punch3.(p, 0.016, 0.004, 0.001), punch3.(p, 0.55, 0.4, 0.3), 0, 0.05) ++ lp),
					smp.("tr909/bd-01.wav", "RolandTR909_bd:0", punch3.(p, 0, 0.3, 0.7) * 0.8 * vel, lp, \sdSampleMod)
				].reject { |n| n.amp <= 0 }
			}
		};
	}.value;

	// JOJO 2 RUMBLE
	{
		var rc = jojo.(2), hits = [[2, 3], [1, 2, 3], [2]];
		var sp = { |s| 0.35 + (0.45 * s) };   // the rumble's space: 0.35 .. 0.8
		var upd = { |send| var s = sp.(ce.val(rc.space)), m = ce.val(rc.char);
			ce.setState(\rumRoom, 0.9 * s, send); ce.setState(\rumEcho, (0.4 * m * 2 * s).min(0.9), send) };
		[rc.space, rc.char].do { |cc| ce.onCC(cc, { |v, send| upd.(send) }) };
		self.rumbleVar = ce.change(rc.btn, 3, "Rumble", ["3+4", "2+3+4", "3"]);
		self.riserStart = nil;
		stem.(\rumble).notes = { |k|
			var b = bar.(k), t = t16.(k), out = List[], m, w, lp, r;
			// riser: 0 → 1 over 2 bars while button 2 is held, in steps per bar (Strudel reads buttons per bar)
			if(ce.held(rc.btn2)) { self.riserStart = self.riserStart ? t.floor } { self.riserStart = nil };
			if(self.beatOn(b) and: { hits[self.rumbleVar.atBar(b)].includes(k % 4) }) {
				m = ce.val(rc.char); w = ce.sine(b / 2);   // Motion's sine is read at the bar start
				lp = (lpOn: 1, bright: ce.val(rc.bright), lo: 100, hi: 500, tone: tone, cutMul: 1 - (0.6 * m * w), lane: \pump);
				out.add(syn.(\sine, 36, 0.5 * 0.67, (hold: 1, penv: 12, pd: 0.05) ++ adsr.(nil, 0.3, 0, nil) ++ lp));
				// (sdSampleMod: its low-pass multiplies Motion after the 80 Hz … 18 kHz clamp, as Strudel does)
				out.add(smp.("tr909/bd-01.wav", "RolandTR909_bd:0", 0.2 * 0.67, lp, \sdSampleMod));
			};
			if(self.riserStart.notNil) {
				r = ((t.floor - self.riserStart) / 2).clip(0, 1);
				if(r > 0) { out.add(ce.note(\sdNoise, (color: 0, amp: r * 1.4, hold: 1, lane: \riser, thinF: thin,
					bp: 300 * (20 ** r), bpq: 4, pan: ce.sine(t * 2), tag: "pink", g: r * 1.4) ++ adsr.(0.03, nil, 0.8, 0.15, synthDef))) }
			};
			out
		};
	}.value;

	// JOJO 3 SUB — Pump: a 16th after every kick for three 16ths; Fifth: beat 4 on the fifth; Syncopated: beat 4 split
	{
		var sc = jojo.(3);
		// [16th in the bar → [degree, length in 16ths]]
		var pats = [
			Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [0, 3]],
			Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [4, 3]],
			Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [0, 1], 15 -> [0, 1]]];
		self.subVar = ce.change(sc.btn, 3, "Sub", ["Pump", "Fifth", "Syncopated"]);
		stem.(\sub).notes = { |k|
			var b = bar.(k), x, m, clip, env, tg;
			x = if(self.beatOn(b)) { pats[self.subVar.atBar(b)][k % 16] };
			if(x.isNil) { [] } {
				m = degMidi.(x[0] + self.rootAt(b), 1, self.moodAt(b)) + if(ce.held(sc.btn2)) { 12 } { 0 };
				clip = 1 - (0.65 * ce.val(sc.char));
				env = adsr.(0.015, nil, 1, 0.04) ++ (hold: x[1] * clip, len16: x[1] * clip);
				tg = 0.18 + (0.3 * ce.val(sc.bright));
				[syn.(\sine, m, 0.9, env), syn.(\triangle, m, tg, env)]
			}
		};
	}.value;

	// JOJO 4 BASSLINE
	{
		var bc = jojo.(4);
		// [main line per bar (alternating bars), ghost 16ths], scale degrees above the chord root; ghost lines with
		// 32 steps play 32nds
		var lines = [
			[["0 ~ ~ 0 ~ ~ 0 ~ 0 ~ ~ 0 ~ ~ 0 ~"], "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0"],
			[["~ 0 0 7 ~ 0 0 0 ~ 0 0 7 ~ 0 2 0", "~ 0 0 7 ~ 0 0 0 ~ 0 -1 0 ~ 4 2 -1"], "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0"],
			[["~ ~ 0 ~ 7 ~ 0 2 ~ ~ 0 ~ 6 ~ 0 ~", "~ ~ 0 ~ 7 ~ 0 2 ~ ~ 0 ~ -2 ~ -1 ~"], "~ 0 ~ 0 ~ 0 ~ ~ ~ 0 ~ 0 ~ 0 ~ 7"],
			[["~ ~ 0 ~ ~ ~ 0 0 ~ ~ 0 ~ ~ 7 0 ~", "~ ~ 0 ~ ~ ~ 0 0 ~ ~ 0 ~ ~ 2 -2 ~"], "~ 0 ~ 7 ~ 0 ~ ~ ~ 0 ~ 7 ~ ~ ~ ~"],
		].collect { |l| [l[0].collect(line), line.(l[1])] };
		// accents per 16th: the 3rd 16th of each beat is loudest and opens the filter furthest
		var vels = [0.7, 0.8, 1, 0.75], envs = [1.8, 2.2, 3.2, 2];
		var topLate = 0.012 * (bpm / 60) * 4;   // the right copy of the top layer: 12 ms later (in 16ths)
		self.bassVar = ce.change(bc.btn, 4, "Bassline", ["3-3-2", "Rolling", "Acid", "Stomp"]);
		stem.(\bass).notes = { |k|
			var b = bar.(k), s16 = k % 16, out = List[], l, deg, c, w, lp, oct, note;
			if(self.beatOn(b).not) { [] } {
				l = lines[self.bassVar.atBar(b)];
				c = ce.val(bc.char); oct = if(ce.held(bc.btn2)) { 12 } { 0 };
				// the low-pass drifts with a slow sine (one cycle in 16 bars), read at the bar start
				w = 0.8 + (0.45 * ce.sine(b / 16));
				lp = (lpOn: 1, bright: ce.val(bc.bright), lo: 350 * w, hi: 2500 * w, tone: tone,
					lpq: 7, la: 0.002, ld: 0.11, ls: 0, lr: 0.01, shape: 0.35) ++ adsr.(0.003, 0.16, 0.15, 0.06);
				// a note of the line at `at` (16ths after this 16th), length len (16ths), accent from its 16th
				note = { |deg, at, len, g, args, dm = 0| var i = (s16 + at).floor % 4, m = degMidi.(deg + self.rootAt(b), 2, self.moodAt(b)) + oct + dm;
					syn.(\sawtooth, m, g * vels[i], lp ++ (lpenv: envs[i], hold: len, at: at, len16: len, vel: vels[i]) ++ (args ? ())) };
				deg = l[0][b % l[0].size][s16];
				deg !? {
					out.add(note.(deg, 0, 1, 0.3));
					out.add(note.(deg, 0, 1, 0.3 * 1.5, (pan: 0, hp: 200)));   // 0.3 × 1.5 as in Strudel (same float)
					out.add(note.(deg, topLate, 1, 0.3 * 1.5, (pan: 1, hp: 200)));
				};
				if(c > 0) {
					var g = l[1], n = g.size / 16;   // 1 = 16ths, 2 = 32nds
					n.asInteger.do { |j| g[(s16 * n) + j] !? { |d|
						var at = j / n, len = 1 / n;
						// two copies, the second 0.1 semitone up (Strudel superimpose)
						out.add(note.(d, at, len, c * 0.16));
						out.add(note.(d, at, len, c * 0.16, nil, 0.1));
					} }
				};
				out
			}
		};
	}.value;

	// JOJO 5 CLAP
	{
		var cc = jojo.(5);
		// [16th → [gain, length in 16ths]] per pattern and bar parity (Drop: the 2nd bar doubles beat 4)
		var claps = [
			[Dictionary[4 -> [0.8, 4], 12 -> [0.8, 4]]],
			[Dictionary[4 -> [0.8, 4], 12 -> [0.8, 1], 15 -> [0.35, 1]]],
			[Dictionary[4 -> [0.8, 4], 12 -> [0.8, 4]], Dictionary[4 -> [0.8, 4], 12 -> [0.8, 2], 14 -> [0.5, 2]]]];
		self.clapVar = ce.change(cc.btn, 3, "Clap", ["Simple", "Pickup", "Drop"]);
		self.swellStart = nil;
		stem.(\clap).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, out = List[], c = ce.val(cc.char), v, tr, r, lp, hit;
			// low-pass: knob 0 = 90 % (fog only, Tension does not open it), high-pass 400, a little right
			lp = (lpOn: 1, bright: ce.val(cc.bright), lo: 1500 * (8 ** 0.9), hi: 12000, tone: fog, hp: 400, pan: 0.48);
			hit = { |rel, tag, g, args| smp.(rel, tag, g * 1.75, lp ++ (args ? ())) };
			if(ce.held(cc.btn2)) { self.swellStart = self.swellStart ? t.floor } { self.swellStart = nil };
			if(self.beatOn(b)) {
				v = self.clapVar.atBar(b);
				claps[v][b % claps[v].size][s16] !? { |x|
					out.add(hit.("tr909/cp-00.wav", "RolandTR909_cp:0", x[0], (hold: x[1]) ++
						if(v == 2) { adsr.(0.001, 0.12, 0, 0.06) } { adsr.(0.001, 0.05, 0, 0.03) })) };
				if(c > 0 and: { s16 == 8 }) { out.add(hit.("tr909/cp-00.wav", "RolandTR909_cp:0", 0.22 * ramp.(c, 0, 0.5), (hold: 4) ++ adsr.(0.001, 0.05, 0, 0.03))) };
				if(c > 0.5 and: { s16 == 6 }) { out.add(hit.("tr909/cp-00.wav", "RolandTR909_cp:0", 0.15 * ramp.(c, 0.5, 1), (hold: 2) ++ adsr.(0.001, 0.05, 0, 0.03))) };
				// snare swell (button 2): 0 → 1 over 4 bars, in steps per bar; hits left out at random, fewer and fewer
				if(self.swellStart.notNil) {
					r = ((t.floor - self.swellStart) / 4).clip(0, 1);
					if(ce.rand(t) > (0.85 * ((1 - r) ** 1.5))) {
						out.add(hit.("tr909/sd-00.wav", "RolandTR909_sd:0", (0.05 + (0.45 * r * r)) * (0.7 + (0.3 * ce.rand(t.floor))),
							(rate: 0.9 + (0.3 * r * r)))) }
				};
			};
			// Tension's roll (last fifth of the knob), also in the break: loose hits → 16ths, swelling on a curve
			tr = ramp.(ce.val(self.tension), 0.8, 1);
			if(tr > 0 and: { ce.rand(t) > (0.8 * ((1 - tr) ** 1.5)) }) {
				out.add(hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.05 + (0.4 * tr * tr))) };
			out.reject { |n| n.amp <= 0 }
		};
	}.value;

	// JOJO 6 HATS
	{
		var hc = jojo.(6);
		self.hatVar = ce.change(hc.btn, 3, "Hats", ["Open", "Open + 16ths", "Driving"]);
		stem.(\hats).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, out = List[], v = self.hatVar.atBar(b), c = ce.val(hc.char), lp, hit, open;
			lp = (lpOn: 1, bright: ce.val(hc.bright), lo: 9000, hi: 18000, tone: fog, hp: 1800, pan: 0.62);
			hit = { |rel, tag, g, args| smp.(rel, tag, g * 3.2, lp ++ (args ? ())) };
			open = { |g, dec, rel, len| hit.("tr909/oh-00.wav", "RolandTR909_oh:0", g, (hold: len) ++ adsr.(nil, dec, 0, rel)) };
			if(ce.held(hc.btn2).not) {
				if(k % 4 == 2) { out.add(open.([0.42, 0.36, 0.34][v], 0.18, 0.05, 2)) };
				switch(v,
					1, { [0.2, 0.12, nil, 0.14][k % 4] !? { |g| out.add(hit.("tr909/hh-00.wav", "RolandTR909_hh:0", g)) } },
					2, { out.add(hit.("tr909/hh-00.wav", "RolandTR909_hh:0", 0.1 + (0.2 * ce.sine(2 * t)))) });
			} {
				// Long: the open hats ring longer, on every 8th
				if(k.even) { out.add(open.([0.26, 0.4][(k / 2) % 2], 0.4, 0.1, 2)) }
			};
			// Complexity: quiet 16ths (from 0), then little 32nd rolls (from 0.5), left out at random
			if(c > 0 and: { ce.rand(t) > 0.4 }) { out.add(hit.("tr909/hh-00.wav", "RolandTR909_hh:0", ramp.(c, 0, 0.5) * 0.12)) };
			if(c > 0.5) { 2.do { |j| var tj = (k + (j / 2)) / 16;
				if(ce.rand(tj) > 0.8) { out.add(hit.("tr909/hh-00.wav", "RolandTR909_hh:0", ramp.(c, 0.5, 1) * 0.18, (at: j / 2))) } } };
			out.reject { |n| n.amp <= 0 }
		};
	}.value;

	// JOJO 7 PERCUSSION
	{
		var pc7 = jojo.(7);
		// [16th → [note, length in 16ths]]: low bongos (decay 0.085), high bongos (0.045), per pattern
		var steps = { |str, len| var l = str.split($ ).reject(_.isEmpty), d = Dictionary[], n = 16 / l.size;
			l.do { |x, i| if(x != "~") { d[(i * n).asInteger] = [x, len ? n] } }; d };
		var low = ["f4 ~ ~ f4 ~ c5 ~ ~", "f4 ~ f4 ~ ~ f4 ~ c5", "f4 ~ ~ f4 ~ ~ f4 ~"].collect { |x| steps.(x) };
		var high = ["~ c6 ~ f5 ~ ~ c6 ~", "~ f5 ~ ~ c6 ~ f5 ~", "~ ~ c6 ~ ~ ~ ~ f5 ~ ~ c6 ~ ~ ~ f5 ~"].collect { |x| steps.(x) };
		var ghost1 = steps.("~ ~ eb5 ~ ~ ab5 ~ c5"), ghost2 = steps.("~ c6 ~ ab5 c6 ~ eb5 ~ c5 ~ ~ eb5 ~ c5 ab5 ~");
		var fill = steps.("f5 eb5 c5 ab4 f5 eb5 c5 ab4 c5 ab4 f4 eb4 f4 ~ f4 ~");
		var name2midi = { |nm| var m = nm.findRegexp("^([a-g])(b|#)?([0-9])$");
			(12 * (m[3][1].asInteger + 1)) + (c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11)[m[1][1].asSymbol]
			+ (m[2][1] == "#").binaryValue - (m[2][1] == "b").binaryValue };
		self.percVar = ce.change(pc7.btn, 3, "Percussion", ["Pillow", "Gallop", "3-3-2"]);
		stem.(\perc).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, out = List[], v = self.percVar.atBar(b), c = ce.val(pc7.char), lp, bongo;
			// all of it pans slowly (one sweep in 13.3 bars), the low-pass from Brightness
			lp = (lpOn: 1, bright: ce.val(pc7.bright), lo: 700, hi: 5000, tone: tone, pan: 0.15 + (0.7 * ce.sine(t / 13.3)));
			bongo = { |x, dec, g| syn.(\sine, name2midi.(x[0]), g * 1.6, lp ++ (hold: x[1]) ++ adsr.(nil, dec, 0, dec / 2)) };
			low[v][s16] !? { |x| out.add(bongo.(x, 0.085, 0.55)) };
			high[v][s16] !? { |x| out.add(bongo.(x, 0.045, 0.7)) };
			if(s16 == 12) { out.add(smp.("tr909/rim-00.wav", "RolandTR909_rim:0", 0.28 * 1.6, lp)) };
			if(c > 0) { ghost1[s16] !? { |x| out.add(bongo.(x, 0.035, ramp.(c, 0, 0.5) * 0.5)) } };
			if(c > 0.5) { ghost2[s16] !? { |x| out.add(bongo.(x, 0.025, ramp.(c, 0.5, 1) * 0.45)) } };
			if(ce.held(pc7.btn2)) { fill[s16] !? { |x| out.add(bongo.(x, 0.05, 0.6)) } };
			out.reject { |n| n.amp <= 0 }
		};
	}.value;

	// ---- Jonas: room / echo amounts of the columns whose Space is scaled (Strudel bus / dryBus with a scaled space),
	// set from the knob the moment it moves (state buses the strips read) ----
	self.spaceState = { |self, cc, name, fn| ce.onCC(cc, { |v, send| ce.setState(name, fn.(v), send) }) };
	// echo throw (button 2 held): a long echo (0.85) on a dry column
	self.throwState = { |self, cc, name| ce.onCC(cc, { |v, send| ce.setState(name, if(v > 0.5) { 0.85 } { 0 }, send) }) };

	// JONAS 1 PADS
	{
		var pc = jonas.(1);
		self.spaceState(pc.space, \padRoom, { |s| 0.9 * (0.3 + (0.7 * s)) });
		stem.(\pad).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, out = List[], p = ce.val(pc.char), fm = ramp.(p, 1, 0.5), fx = ramp.(p, 0, 0.5);
			var notes, lp, saws3;
			if((s16 % 4) != 0) { [] } {
				notes = self.padColours[self.colour.atBar(b)][1].collect { |d| degMidi.(d + self.rootAt(b), 3, self.moodAt(b)) };
				// Brightness acts at once (long notes)
				lp = (lpOn: 1, bright: ce.ccMap(pc.bright), lo: 250, hi: 6000, tone: tone);
				// the techno pad: three saws, left / middle / right, slightly detuned
				saws3 = { |m, g, args| [[0, 0.5], [0.12, 0.1], [-0.11, 0.9]].collect { |x| syn.(\sawtooth, m + x[0], g, lp ++ (pan: x[1]) ++ args) } };
				// held chords (Pump 0 … 1): struck once per bar, long attack and release; the pans wander slowly
				if(fm > 0 and: { s16 == 0 }) {
					var sp = 0.15 + (0.7 * ce.sine(t / 5)), tp = 0.85 - (0.7 * ce.sine(t / 5));
					notes.do { |m|
						[0, 0.1].do { |dm| out.add(syn.(\sawtooth, m + dm, 0.028 * fm, lp ++ (hold: 16, pan: sp) ++ adsr.(0.9, nil, 0.8, 2))) };
						out.add(syn.(\triangle, m, 0.056 * fm, lp ++ (hold: 16, pan: tp) ++ adsr.(0.6, nil, 0.8, 2)));
						out.addAll(saws3.(m, 0.0224 * fm, (hold: 16) ++ adsr.(0.5, nil, 1, 1.5)));
					}
				};
				// pumped chords (Pump 0.5 … 1): struck on every beat, the attack grows with Pump
				if(fx > 0) {
					var env = adsr.(0.06 + (0.14 * p), nil, 1, 0.04) ++ (hold: 4);
					notes.do { |m|
						out.addAll(saws3.(m, 0.0224 * fx, env));
						out.add(syn.(\triangle, m, 0.056 * fx, lp ++ env));
					}
				};
				out
			}
		};
	}.value;

	// JONAS 2 STRINGS — F4 C5 F5 A♭5, a new note every 2 bars; each move changes one voice (8 bars, 4 units of 2 bars)
	{
		var sc = jonas.(2);
		var hold = { |m| [[m, 4]] };
		var moves = [
			["Fm → D♭", [hold.(65), [[72, 3], [73, 1]], hold.(77), hold.(80)]],
			["Fm → A♭", [[[65, 3], [63, 1]], hold.(72), [[77, 3], [75, 1]], hold.(80)]],
			["Line up", [hold.(65), [[72, 1], [73, 1], [74, 1], [73, 1]], hold.(77), hold.(80)]],
			["Line down", [hold.(65), hold.(72), [[77, 1], [76, 1], [75, 1], [74, 1]], hold.(80)]],
			["Chain", [hold.(65), [[72, 1], [73, 2], [72, 1]], hold.(77), [[80, 2], [82, 1], [80, 1]]]],
		].collect { |mv| [mv[0], mv[1].collect { |v| v.collect { |x| x[0] ! x[1] }.flatten }] };   // voice → note per unit
		// Sound: JX ↔ analogue, equal power, on the two lanes' fades (cos / sin): it acts at once; the fader per note
		var lanes = { |send| var v = ce.val(sc.char);
			ce.setState(\strJx, cos(v * pi / 2) * (v < 0.999).binaryValue, send);
			ce.setState(\strAn, sin(v * pi / 2) * (v > 0.001).binaryValue, send) };
		[sc.char].do { |cc| ce.onCC(cc, { |v, send| lanes.(send) }) };
		self.spaceState(sc.space, \strRoom, { |s| 0.9 * (0.3 + (0.7 * s)) });
		self.throwState(sc.btn2, \strEcho);
		self.strVar = ce.change(sc.btn, moves.size, "Strings", moves.collect(_[0]));
		stem.(\strings).notes = { |k|
			var b = bar.(k), out = List[], v = ce.val(sc.char), cv = cos(v * pi / 2), sv = sin(v * pi / 2), lp, env, an;
			if(k % 32 != 0) { [] } {
				lp = (lpOn: 1, bright: ce.ccMap(sc.bright), lo: 500, hi: 7000, tone: tone, hold: 32);
				moves[self.strVar.atBar(b)][1].do { |voice|
					var m = voice[(b % 8 / 2).floor];
					// JX-10 strings: two saws ~4 cents apart, and a layer 0.1 semitone up (amp without the fade: the lane has it)
					if(v < 0.999) {
						env = adsr.(0.35, 0.1, 1, 0.8) ++ (lane: \jx);
						[[0, 0.08, 0.6, 0.5], [0.1, 0.05, 0.9, 0.3]].do { |x|
							out.add(ce.note(\sdSupersawWide, (freq: (m + x[0]).midicps, unison: 2, dtn: x[1], spread: x[2], amp: x[3] * 0.24,
								thinF: thin, tag: "supersaw", g: x[3] * 0.24 * cv, midi: m + x[0]) ++ lp ++ env)) } };
					// analogue strings: two detuned squares, a saw an octave up, a triangle an octave down, a little vibrato
					if(v > 0.001) {
						an = lp ++ adsr.(0.45, 0.1, 1, 1) ++ (vib: 5, vibmod: 0.04, lpq: 2, lane: \analog);
						[[\square, 0, 0.045, 0.4], [\square, 0.09, 0.045, 0.6], [\sawtooth, 12.06, 0.025, -1], [\triangle, -12, 0.035, -1]].do { |x|
							out.add(syn.(x[0], m + x[1], x[2], an ++ (pan: x[3])) ++ (g: x[2] * sv)) } };
				};
				out
			}
		};
	}.value;

	// JONAS 3 SEQUENCE
	{
		var qc = jonas.(3);
		var seqs = ["0 ~ 0 4 ~", "0 ~ 6 ~ 4 ~ 0", "0 4 ~", "0 ~ ~ 2 ~ 4 ~", "4 ~ 0 ~ 0", "0 ~ 3 ~ 0 4 ~", "6 ~ 4 ~ ~", "0 0 ~ 4 ~ 2 ~"].collect(line);
		// Complexity's extra notes per loop, joining one by one: [threshold, degree, 16th]. Made in the Strudel track by a
		// seeded shuffle (Array.sort with a random comparator, V8's order): the table it gives, copied here.
		var extras = [
			[[0.12, 0, 11], [0.245, 0, 4], [0.37, 2, 9], [0.495, 6, 15], [0.62, -3, 3], [0.745, -3, 2], [0.87, -7, 1], [0.995, 11, 5]],
			[[0.12, 2, 14], [0.245, 2, 8], [0.37, 0, 0], [0.495, -3, 4], [0.62, 6, 13], [0.745, 7, 7], [0.87, 7, 5], [0.995, 11, 10]],
			[[0.12, 2, 14], [0.245, 4, 0], [0.37, 2, 1], [0.495, 4, 15], [0.62, 4, 10], [0.745, 6, 2], [0.87, 7, 3], [0.995, 11, 13]],
			[[0.12, 0, 0], [0.245, 2, 10], [0.37, 4, 1], [0.495, 4, 2], [0.62, -3, 3], [0.745, 4, 9], [0.87, -7, 14], [0.995, 7, 12]],
			[[0.12, 2, 13], [0.245, 0, 14], [0.37, 2, 15], [0.495, 6, 11], [0.62, 6, 7], [0.745, -3, 3], [0.87, -4, 8], [0.995, -4, 1]],
			[[0.12, 4, 4], [0.245, 0, 3], [0.37, 2, 2], [0.495, 4, 9], [0.62, -3, 10], [0.745, 4, 1], [0.87, 7, 13], [0.995, -4, 7]],
			[[0.12, 2, 11], [0.245, 0, 3], [0.37, 2, 0], [0.495, 6, 10], [0.62, 7, 15], [0.745, 7, 5], [0.87, -7, 13], [0.995, 7, 4]],
			[[0.12, 4, 0], [0.245, 4, 11], [0.37, 2, 12], [0.495, 4, 1], [0.62, 6, 7], [0.745, 6, 6], [0.87, 7, 4], [0.995, 7, 8]]];
		self.spaceState(qc.space, \seqRoom, { |s| 0.9 * (0.3 + (0.7 * s)) });
		self.spaceState(qc.space, \seqEcho, { |s| (0.4 * 2 * (0.3 + (0.7 * s))).min(0.9) });
		self.seqVar = ce.change(qc.btn, 8, "Sequence");
		stem.(\seq).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, v = self.seqVar.atBar(b), rg = ce.val(qc.char), r = ce.rand(t), degs = List[], l, d, note;
			// the loop (polymeter: step k of the loop, whatever the bar), thinned at random below full Complexity; a
			// quarter × Complexity of its notes become passing notes (9th in even bars, 7th in odd ones)
			l = seqs[v]; d = l[k % l.size];
			if(d.notNil and: { r > (0.5 * (1 - rg)) }) { degs.add([d + if(r < (0.25 * rg)) { [1, -1][b % 2] } { 0 }, 1]) };
			extras[v].do { |x| if(rg > x[0] and: { s16 == x[2] }) { degs.add([x[1], 0.85]) } };
			degs.collect { |x|
				var m = degMidi.(x[0] + self.rootAt(b), 4, self.moodAt(b)) + if(ce.held(qc.btn2)) { 12 } { 0 } + (-0.06 + (0.12 * r));
				var g = (0.47 + (0.27 * ce.perlin(t))) * x[1], f = m.midicps;
				syn.(\sine, m, g, (fmi: 0.4 + (1.6 * ce.val(qc.bright)), fmh: 2, modPhase: modPhase.(k, 0, f * 2), hold: 1,
					pan: 0.35 + (0.3 * ce.sine(t / 3)), lpOn: 1, bright: ce.val(qc.bright), lo: 1500, hi: 12000, tone: tone)
					++ adsr.(0.003, 0.28, 0, 0.25))
			}
		};
	}.value;

	// JONAS 4 STAB
	{
		var lc = jonas.(4);
		var stabs = [
			["~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~"],
			["~ ~ 0 ~ ~ ~ 0 ~ ~ ~ 0 ~ ~ 0 ~ ~"],
			["~ ~ 0 ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~", "~ ~ 0 ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ 7 ~ ~"],
			["~ 0 ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ ~"],
			["~ ~ 0 ~ 0 ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~", "~ ~ 0 ~ 0 ~ ~ ~ ~ ~ -1 ~ ~ ~ ~ ~"],
			["~ ~ ~ 0 ~ ~ 0 ~ ~ ~ ~ 0 ~ ~ 0 ~"],
			["~ ~ 0 ~ ~ 0 ~ ~ ~ ~ 0 ~ ~ ~ ~ ~", "~ ~ 0 ~ ~ 0 ~ ~ ~ ~ 0 ~ ~ ~ -1 ~"],
			["~ ~ 0 0 ~ ~ 0 ~ ~ ~ 0 ~ ~ 0 ~ ~"],
		].collect { |p| p.collect(line) };
		self.spaceState(lc.space, \stabRoom, { |s| 0.9 * (0.25 + (0.75 * s)) });
		self.throwState(lc.btn2, \stabEcho);
		self.stabVar = ce.change(lc.btn, 8, "Stab");
		stem.(\stab).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, l = stabs[self.stabVar.atBar(b)], d = l[b % l.size][s16];
			var vary = ce.val(lc.char), x1 = 0.35 * vary, x2 = 0.2 * vary, r = ce.rand(t), parts, w, lp, out = List[];
			if(d.isNil) { [] } {
				// Variation: a ratchet (the stab twice in 32nds), then an octave jump, each by chance (Strudel sometimesBy)
				parts = if(r < x1) { [[0, 0.5], [0.5, 0.5]] } { if(r > x1) { [[0, 1]] } { [] } };
				// the low-pass drifts with a slow sine (one cycle in 12 bars), read at the bar start
				w = 0.75 + (0.6 * ce.sine(b / 12));
				lp = (lpOn: 1, bright: ce.val(lc.bright), lo: 400 * w, hi: 4000 * w, tone: tone, hp: 400,
					lpq: 8, lpenv: 3, la: 0.002, ld: 0.08, ls: 0, lr: 0.01, shape: 0.25) ++ adsr.(0.002, 0.17, 0, 0.08);
				parts.do { |pt|
					var ru = ce.rand(t + (pt[0] / 16)), dd = d + if(ru < x2) { 7 } { 0 }, m;
					if(ru != x2) {
						m = degMidi.(dd + self.rootAt(b), 3, self.moodAt(b));
						// root on two saws 0.15 apart, the fifth on a saw, a square an octave below: all at gain 0.3
						[[\sawtooth, 0], [\sawtooth, 0.15], [\sawtooth, 7], [\square, -12]].do { |x|
							out.add(syn.(x[0], m + x[1], 0.3, lp ++ (at: pt[0], hold: pt[1]))) }
					}
				};
				out
			}
		};
	}.value;

	// JONAS 5 ANSWER
	{
		var ac = jonas.(5);
		var rhythms = ["~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x x ~",
			"~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~ x", "~ ~ ~ ~ ~ ~ x ~ ~ ~ x ~ ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ ~ ~ ~ ~",
			"~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x ~ x ~ ~", "~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~ ~ ~ x x"].collect { |r| r.split($ ).collect(_ == "x") };
		var tones = [0, 2, 4, 6, 7];   // root, 3rd, 5th, 7th, octave
		self.spaceState(ac.space, \ansRoom, { |s| 0.9 * (0.35 + (0.65 * s)) });
		self.spaceState(ac.space, \ansEcho, { |s| (0.55 * 2 * (0.35 + (0.65 * s))).min(0.9) });
		self.ansVar = ce.change(ac.btn, 8, "Answer");
		stem.(\answer).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, v = self.ansVar.atBar(b), vo = ce.val(ac.char), wild = ramp.(vo, 0.75, 1);
			var r = ce.rand(t), on, tn, lp, out = List[];
			// the written phrase every second bar; in the bars between: from Voices 0.75 some of its notes spill over at
			// random, while button 2 is held a random answer on the back ten 16ths instead
			on = if((b % 2) == 1) { rhythms[v][s16] } {
				if(ce.held(ac.btn2)) { s16 >= 6 and: { r > 0.7 } } { wild > 0 and: { rhythms[v][s16] } and: { r > (1 - (0.6 * wild)) } } };
			if(on.not) { [] } {
				// the note: a chord tone at random, new ones per change (Strudel reseed: the random numbers 1024 bars on)
				tn = tones[(5 * ce.rand(t + (1024 * v))).trunc.asInteger];
				lp = (lpOn: 1, bright: ce.val(ac.bright), lo: 2000, hi: 12000, tone: tone, hold: 1, pan: [0.2, 0.8][s16 % 2])
					++ adsr.(nil, 0.07, 0, 0.05);
				// Voices: + the third (0 … 0.375), + the fifth (0.375 … 0.75), top quarter + the 7th; they strum apart
				[[0, 0.54, 0], [2, ramp.(vo, 0, 0.375) * 0.42, 1], [4, ramp.(vo, 0.375, 0.75) * 0.36, 2], [6, wild * 0.3, 3]].do { |x|
					if(x[1] > 0) { out.add(syn.(\square, degMidi.(tn + x[0] + self.rootAt(b), 5, self.moodAt(b)), x[1],
						lp ++ (at: x[2] * wild / 4))) } };
				out
			}
		};
	}.value;

	// JONAS 6 DARK PERC
	{
		var pc6 = jonas.(6);
		var rhythms = ["x ~ ~ x ~ ~ x ~ ~ x ~ ~ x ~ x ~", "~ ~ x ~ ~ x ~ ~ x ~ ~ ~ x ~ ~ ~", "x ~ x ~ ~ ~ x ~ x ~ ~ ~ x ~ ~ ~",
			"~ x ~ ~ x ~ ~ x ~ ~ x ~ ~ x ~ ~", "x ~ ~ ~ ~ x ~ ~ ~ ~ x ~ ~ ~ x ~", "~ ~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~",
			"x ~ ~ x ~ ~ ~ x ~ ~ x ~ ~ ~ x ~", "~ x ~ x ~ ~ x ~ ~ x ~ x ~ ~ x ~"].collect { |r| r.split($ ).collect(_ == "x") };
		self.pingVar = ce.change(pc6.btn, 8, "Dark Perc");
		self.rollStart = nil;
		stem.(\darkperc).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, v = self.pingVar.atBar(b), dn = ce.val(pc6.char), r = ce.rand(t), rr, x;
			var lp = (lpOn: 1, bright: ce.val(pc6.bright), lo: 5000, hi: 18000, tone: tone), evs = List[], out = List[];
			var fmNote = { |m, fmi, fmh, g, at, len, args| syn.(\sine, m, g, lp ++ (fmi: fmi, fmh: fmh, at: at, hold: len,
				modPhase: modPhase.(k, at, m.midicps * fmh)) ++ args) };
			var noise = { |color, g, hp, at, len, env, args| ce.note(\sdNoise, (color: color, amp: g, hold: len, at: at, hp: hp, thinF: thin,
				tag: ["pink", "white"][color], g: g) ++ lp ++ env ++ (args ? ())) };
			// the roll (button 2): 0 → 1 over 2 bars while held, in steps per bar
			if(ce.held(pc6.btn2)) { self.rollStart = self.rollStart ? t.floor } { self.rollStart = nil };
			// claves on the figure (c7 c7 g6 c7 in every beat), the shaker on every 16th
			if(rhythms[v][s16]) { evs.add(fmNote.([96, 96, 91, 96][s16 % 4], 0.4, 1, 0.32, 0, 1, adsr.(0.001, 0.035, 0, 0.02) ++ (pan: 0.7))) };
			evs.add(noise.(1, [0.16, 0.09, 0.13, 0.09][s16 % 4], 7000, 0, 1, adsr.(0.008, 0.035, 0, 0.02), (pan: 0.3)));
			// Complexity: metal ticks in the figure's gaps (from 0), falling zaps (from 0.4)
			if(dn > 0 and: { rhythms[v][s16].not } and: { r > (1 - (0.7 * ramp.(dn, 0, 0.4))) }) {
				evs.add(fmNote.(77, 5, 1.414, 0.16, 0, 1, adsr.(0.001, 0.04, 0, 0.03) ++ (pan: 0.3 + (0.4 * ce.perlin(t / 2))))) };
			if(dn > 0.4 and: { r > (1 - (0.3 * ramp.(dn, 0.4, 0.75))) }) {
				evs.add(syn.(\sine, 72, 0.2, lp ++ (hold: 1, penv: -24, pd: 0.05, pan: 0.25 + (0.5 * r)) ++ adsr.(0.001, 0.06, 0, 0.03))) };
			// roll: scattered 32nds (shaker + metal) that fill in and get louder
			if(self.rollStart.notNil) {
				rr = ((t.floor - self.rollStart) / 2).clip(0, 1);
				2.do { |j| var u = t + (j / 32), vel = 0.4 + (0.6 * rr);
					if(ce.rand(u) > (0.85 - (0.75 * rr))) {
						evs.add(noise.(1, 0.14 * vel, 6000, j / 2, 0.5, adsr.(0.004, 0.025, 0, 0.015)));
						evs.add(fmNote.(77, 5, 1.414, 0.1 * vel, j / 2, 0.5, adsr.(0.001, 0.04, 0, 0.03) ++ (pan: 0.3 + (0.4 * ce.perlin(u / 2)))));
					} }
			};
			// top quarter of Complexity: by chance, an event plays twice in its own time (Strudel ply(2))
			x = ramp.(dn, 0.75, 1) * 0.35;
			evs.do { |e|
				var at = e[\at] ? 0, ru = ce.rand(t + (at / 16)), len = e[\hold];
				case
				{ ru < x } { [0, len / 2].do { |o| var e2 = e.copy; e2[\at] = at + o; e2[\hold] = len / 2;
					e2[\modPhase] !? { if(ce.webaudioPhase == true) { e2[\modPhase] = modPhase.(k, at + o, e2[\freq] * e2[\fmh]) } };
					out.add(e2) } }
				{ ru > x } { out.add(e) }
			};
			out
		};
	}.value;

	// JONAS 7 FX / BREATH
	{
		var fc = jonas.(7), lens = [2, 4, 8, 1];
		self.spaceState(fc.space, \fxRoom, { |s| 0.9 * (0.08 + (0.92 * s)) });
		self.fxVar = ce.change(fc.btn, 4, "FX / Breath", ["2 bars", "4 bars", "8 bars", "1 bar"]);
		stem.(\fx).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, len = lens[self.fxVar.atBar(b)], a = ce.val(fc.char), r = ce.rand(t), out = List[];
			// breath 0..1: a slow sine × a depth that changes from breath to breath, eased (long quiet part, short peak);
			// button 2 held = fully open
			var br = if(ce.held(fc.btn2)) { 1 } { ((ce.sine(t / len) * (0.3 + (0.7 * ce.perlin(t / (2 * len))))) ** 1.6) };
			var lp = (lpOn: 1, bright: ce.ccMap(fc.bright), lo: 1500, hi: 14000, tone: tone);
			var chord;
			// noise grains at random (about half the 16ths), random length, level and side; the band-pass wanders
			if(r > 0.5) { out.add(ce.note(\sdNoise, (color: 0, amp: (1 + (6 * br)) * (0.5 + (0.5 * r)), hold: 1, thinF: thin,
				bp: 400 * (6 ** br) * (0.6 + (1.1 * ce.perlin(t / 11))), bpq: 0.8, pan: 0.1 + (0.8 * r),
				tag: "pink", g: (1 + (6 * br)) * (0.5 + (0.5 * r))) ++ lp ++ adsr.(0.08, nil, 0.8, 0.12 + (0.28 * r)))) };
			// Complexity: the chord (root, fifth, octave) pulses in 8ths (a quarter left out), from half also 16ths an octave up
			if(a > 0) {
				chord = [0, 4, 7].collect { |d| degMidi.(d + self.rootAt(b), 4, self.moodAt(b)) };
				if(k.even and: { r > 0.25 }) { chord.do { |m| out.add(syn.(\triangle, m, 0.15 * br * (a / 0.5).clip(0, 1),
					lp ++ (hold: 2) ++ adsr.(0.02, nil, 0.8, 0.1))) } };
				if(a > 0.5) { chord.do { |m| out.add(syn.(\sine, m + 12, 0.09 * br * ((a - 0.5) / 0.5).clip(0, 1),
					lp ++ (hold: 1) ++ adsr.(0.01, nil, 0.6, 0.08))) } };
			};
			out.reject { |n| n.amp <= 0 }
		};
	}.value;
}
)
)
