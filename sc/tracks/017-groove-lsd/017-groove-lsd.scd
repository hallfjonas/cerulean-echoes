// TRACK 017 GROOVE TECHNO (LSD) — a SuperCollider-only track built on 016 (groove techno on F, 134 BPM), with no
// Strudel original. Kick, rumble, sub, bass, hats, pads, global column and Launchkey are 016's; new here: the wood
// (016's Rave, brighter, and two more Rave figures), real bongos and a conga (modal voice, hand strokes), living
// strings (bowed rhythm, following the chords), an acid stab (dub minor-9 chord, accents, slides, a wandering
// filter), the answer a little apart from 016's, wider accents and FX. Same controller layout as 016: Mode 1 =
// foundation (plain CCs), Mode 2 = colour (CC + 48), column 8 global on both, the Launchkey MK4 25 optional.
// Column 8's fader is Wumms (more low end, punch and drive on kick, rumble, sub, bass), not a master: there is no
// master volume (the strips' master is 1). Level (faders, mod wheel) and Wumms act from the next note; Space, echo,
// Fog, Thin and Tension act at once, also on sounding notes (Tension also brings the pads and strings in live);
// Brightness acts at once on the long sounds (pads, strings, Launchkey keys), on the short ones from the next note;
// pattern buttons switch at the next bar.
// The @ tags below are read by the web UI (sc/ui): column names, and each control's name | what it does.
// @layout Track 017 — groove techno (LSD)
// @mode 16 Mode 1 — Foundation (beat + bass) · same CCs as Mode 16
// @col 16:8 8 Global
// @col 16:1 1 Kick
// @col 16:2 2 Rumble
// @col 16:3 3 Sub
// @col 16:4 4 Bass
// @col 16:5 5 Wood
// @col 16:6 6 Hats
// @col 16:7 7 Perc
// @mode 2 Mode 2 — Colour (stab + answer)
// @col 2:1 1 Pads
// @col 2:2 2 Strings
// @col 2:3 3 Shape
// @col 2:4 4 Stab
// @col 2:5 5 Answer
// @col 2:6 6 Accents
// @col 2:7 7 FX
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | density: pads and strings up, echo, reverb; the end adds a wood roll.
// @ctl g.fader Wumms | more low end, punch and drive.
// @ctl g.b1 Chapter | mood: dark → tense → warm, at the next bar.
// @ctl g.b2 Break | 1st: low end out. 2nd: all back on the one.
// @ctl 16:1.k1 Brightness | dull ↔ bright.
// @ctl 16:1.k2 Space | dry ↔ room.
// @ctl 16:1.k3 Punch | 0 = soft thump, 1 = round kick with a light click.
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
// @ctl 16:4.k3 Complexity | the figure as written ↔ + a few ghost notes.
// @ctl 16:4.fader Level | sparse bass figure, follows the chords.
// @ctl 16:4.b1 Pattern | sparse → call → roll.
// @ctl 16:4.b2 Octave | one octave up while held.
// @ctl 16:5.k1 Brightness | bright ↔ brighter.
// @ctl 16:5.k2 Space | dry ↔ room.
// @ctl 16:5.k3 Bounce | light swing ↔ heavy swing.
// @ctl 16:5.fader Level | wooden rhythm. Also the level of Tension's wood roll.
// @ctl 16:5.b1 Pattern | rave → spin (3 against 4) → tumble.
// @ctl 16:5.b2 Roll | a wood roll fills in over 2 bars while held.
// @ctl 16:6.k1 Brightness | dull ↔ bright.
// @ctl 16:6.k2 Space | dry ↔ room.
// @ctl 16:6.k3 Complexity | the pattern as it is ↔ + quiet 32nd skips.
// @ctl 16:6.fader Level | closed and open hats. Keep playing in the break.
// @ctl 16:6.b1 Pattern | groove → open → fast.
// @ctl 16:6.b2 Long | open hats ring longer, on every off-beat, while held.
// @ctl 16:7.k1 Brightness | dull ↔ bright.
// @ctl 16:7.k2 Space | dry ↔ room.
// @ctl 16:7.k3 Complexity | steady ↔ + fingertips and thumbs ↔ + flams and rolls.
// @ctl 16:7.fader Level | bongos and a conga, by hand. Keep playing in the break.
// @ctl 16:7.b1 Pattern | pillow → gallop → 3-3-2.
// @ctl 16:7.b2 Fill | a run across bongos and conga while held.
// @ctl 2:1.k1 Brightness | dull ↔ bright.
// @ctl 2:1.k2 Space | dry ↔ room.
// @ctl 2:1.k3 Pump | 0 = held chords ↔ the kick pumps the chords on every beat.
// @ctl 2:1.fader Level | the pad; Tension brings it in.
// @ctl 2:1.b1 Chords | next of 8 chord progressions, for all.
// @ctl 2:1.b2 Colour | 7 → 9 → fourths → fifths, at the next bar.
// @ctl 2:2.k1 Brightness | dull ↔ bright.
// @ctl 2:2.k2 Space | dry ↔ room.
// @ctl 2:2.k3 Bow | short bowed pulses ↔ long swells.
// @ctl 2:2.fader Level | strings on the chords; Tension brings them up.
// @ctl 2:2.b1 Pattern | next move: lift · sink · line up · line down · chain.
// @ctl 2:2.b2 Echo throw | long echo on the strings while held.
// @ctl 2:3.k1 Snap | soft pluck ↔ the filter snaps wide open on every hit.
// @ctl 2:3.k2 Length | short stab ↔ long, ringing stab.
// @ctl 2:3.k3 Resonance | round ↔ squelchy.
// @ctl 2:3.fader Drive | clean ↔ driven.
// @ctl 2:3.b1 Vanish | stab out at the next bar; press again: back on the one.
// @ctl 2:3.b2 Ratchet | the stab repeats in quick 16ths while held.
// @ctl 2:4.k1 Brightness | dull ↔ bright.
// @ctl 2:4.k2 Space | dry ↔ room.
// @ctl 2:4.k3 Vanish | every bar ↔ leaves bars at random; the answer fills them.
// @ctl 2:4.fader Level | the acid chord stab, the theme of the track.
// @ctl 2:4.b1 Pattern | next of 8 stab figures.
// @ctl 2:4.b2 Echo throw | long echo on the stab while held.
// @ctl 2:5.k1 Brightness | dull ↔ bright.
// @ctl 2:5.k2 Space | dry ↔ echo + room.
// @ctl 2:5.k3 Complexity | one voice → + third → + fifth → + 7th, strummed.
// @ctl 2:5.fader Level | counter blips, every second bar and where the stab leaves.
// @ctl 2:5.b1 Pattern | next of 8 phrase rhythms (new notes too).
// @ctl 2:5.b2 Answer | random extra answers while held.
// @ctl 2:6.k1 Brightness | dull ↔ bright.
// @ctl 2:6.k2 Space | some echo ↔ room and long echo.
// @ctl 2:6.k3 Rate | one hit in about 2 bars ↔ about 2 per bar.
// @ctl 2:6.fader Level | rare high accents with their own echo.
// @ctl 2:6.b1 Pattern | next of 8 random series.
// @ctl 2:6.b2 Burst | a quick scatter of accents while held.
// @ctl 2:7.k1 Brightness | dull ↔ bright.
// @ctl 2:7.k2 Space | some echo ↔ room and long echo.
// @ctl 2:7.k3 Complexity | riser + tail ↔ + saw ↔ + mid sweep ↔ + dub siren.
// @ctl 2:7.fader Level | risers and tails at the phrase changes.
// @ctl 2:7.b1 Pattern | phrase of 8 → 16 → 4 bars.
// @ctl 2:7.b2 Riser | a riser by hand, over 4 bars while held.
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
// the Launchkey's keys: the shared keys of 008 / 009 / 010 / 016 / 017 (sc/lib/lkkeys.scd)
var lkKeysLib = (~ce.root +/+ "lib/lkkeys.scd").load;
var bpm = 134, beat = 60 / bpm;
// ---------------------------------------------------------------------------------------------------------
// CC numbers of column n (1-8): row 1-3 knobs, fader, buttons. Mode 1 = plain, Mode 2 = + 48.
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
// HARMONY — chord roots as scale degrees (0 = F), one chord per 2 bars, 4 chords = 8 bars (pad button 1)
var progs = [[0, 0, 0, 0], [0, 0, -2, -2], [0, 3, 0, 3], [0, -2, -3, -2], [0, 2, 3, 2], [0, 0, 4, 3], [3, 3, 0, 0], [0, 5, 3, 4]];
var progNames = ["1", "1–6", "1–4", "1–6–5–6", "1–3–4–3", "1–5–4", "4–1", "1–6–4–5"];
// a step line as Strudel writes it ("~ 0 ~ 7 …") → [degree or nil per step]
var line = { |str| str.split($ ).reject(_.isEmpty).collect { |x| if(x == "~") { nil } { x.asFloat } } };
// a hit line ("~ x ~ …") → [true / false per step]
var hits = { |str| str.split($ ).reject(_.isEmpty).collect(_ == "x") };
var ramp = { |v, from, to| ((v - from) / (to - from)).clip(0, 1) };
var dB = { |x| 10 ** (x / 20) };

(
name: "017-groove-lsd",
bpm: bpm,
// no master fader: column 8's fader is Wumms (read per note by kick, rumble, sub, bass)
global: (fog: glob.bright, thin: glob.space, tension: glob.char),
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
// Effect buses (Strudel orbits), as in 008. Orbit 1 = drums and bass: small room (size 1.6), short dotted-8th slap.
// Orbit 2 = all of the colour: dub room (size 4), dotted-8th echo with long feedback.
// Orbit 3 = rumble only: the reverb is the sound (size 2.6), a 16th echo. Impulse responses measured from superdough.
orbits: (1: (ir: "ir/orbit-1.6.wav", delay: [0.75 * beat, 0.3]), 2: (ir: "ir/orbit-4.wav", delay: [0.75 * beat, 0.58]),
	3: (ir: "ir/orbit-2.6.wav", delay: [0.25 * beat, 0.45])),
// state buses: room and echo amounts the language derives from knobs (columns whose Space is scaled, echo throws)
states: (rumRoom: 0.9 * 0.35, rumEcho: 0, padRoom: 0.9 * 0.3, strRoom: 0.9 * 0.3, strEcho: 0, stabRoom: 0.9 * 0.25, stabEcho: 0,
	ansRoom: 0.9 * 0.35, ansEcho: 0.55 * 2 * 0.35, accRoom: 0.9 * 0.3, accEcho: 0.3, fxRoom: 0.9 * 0.4, fxEcho: 0.2,
	lkLevel: 0, lkBright: 0, lkRoom: 0.9 * 0.1, lkEcho: 0),
// map buses (server side, follow the knob at once): Tension brings the pads (30 % → full over its first half) and the
// strings (45 % → full at 0.6) in; each × the column's level range (1.2 / 0.7)
maps: (padIn: (ccs: [glob.char], fn: { |t| 1.2 * (0.3 + (0.7 * (t / 0.5).clip(0, 1))) }),
	strIn: (ccs: [glob.char], fn: { |t| 0.7 * (0.45 + (0.55 * (t / 0.6).clip(0, 1))) })),
// samples the drum stems play (the files Strudel plays: tidal-drum-machines, see sc/samples/CREDITS.md)
samples: ["tr909/bd-01.wav", "tr909/oh-00.wav", "tr909/hh-00.wav",
	// the Launchkey's drum pads (as 008): drum-machine one-shots, Dirt-Samples (strudel.cc's default samples), the spoken samples
	"voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac", "voice/plaenterwald.flac",
	"voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac", "voice/the_evening_does_not_end.flac", "voice/in_the_vast.flac",
	"tr909/lt-00.wav", "tr909/rim-00.wav", "tr909/cr-00.wav", "tr808/sh-00.wav", "dirt/space-00.wav", "dirt/wind-00.wav"] ++ ~ce.lkKeysFiles,

stems: [
	// MODE 1 / 1 KICK — a soft, round sine kick on C2 with a pitch drop, a sub thump on C1 under it, a light 909 click
	// from Punch; Wumms: louder, longer, deeper thump, driven. Double time / drop out while held. No echo.
	(name: \kick, sounds: [\sdSynthMod, \sdSampleMod], level: jojo.(1).level, space: jojo.(1).space, orbit: 1, thin: false),
	// MODE 1 / 2 RUMBLE — 008's rumble: the kick's sound low-passed into a dark reverb (own orbit), on the 3rd and 4th
	// 16th of every beat; Motion breathes the filter and adds a 16th echo. Riser on button 2 (its own lane: orbit 2, space 0.3).
	(name: \rumble, sounds: [\sdSynthMod, \sdSampleMod, \sdNoise], level: jojo.(2).level, trim: 0.68, thin: false,
		lanes: [(name: \pump, orbit: 3, roomR: \rumRoom, echoSend: \rumEcho),
			(name: \riser, orbit: 2, roomR: 0.9 * 0.3, echoSend: 0)]),
	// MODE 1 / 3 SUB — 008's pumping sine (+ a triangle for brightness) on the chord root, a 16th after every kick
	(name: \sub, sounds: [\sdSynthMod], level: jojo.(3).level, space: jojo.(3).space, orbit: 1, trim: 0.65, thin: false),
	// MODE 1 / 4 BASS — a short, sparse figure on the chord root: saw + triangle through a resonant low-pass that opens
	// on every note, a wide top layer above 200 Hz (left, and right 12 ms later), ghost notes on row 3
	(name: \bass, sounds: [\sdSynthMod], level: jojo.(4).level, space: jojo.(4).space, orbit: 1, trim: 0.6, thin: false),
	// MODE 1 / 5 WOOD — two FM wood blocks, a wooden log and a triangle mallet, swung by Bounce; roll on button 2,
	// Tension's roll
	(name: \wood, sounds: [\sdSynthMod, \modalPerc], level: jojo.(5).level, space: jojo.(5).space, orbit: 1, trim: 0.9, thin: false),
	// MODE 1 / 6 HATS — a fast, swung closed 909 hat (right) and an open hat on the off-beat
	(name: \hats, sounds: [\sdSample], level: jojo.(6).level, space: jojo.(6).space, orbit: 1, trim: 0.105, thin: false),
	// MODE 1 / 7 PERCUSSION — bongos and a conga played by hand (modal skins: open tones, slaps, fingertips, thumbs)
	(name: \perc, sounds: [\modalPerc], level: jojo.(7).level, space: jojo.(7).space, orbit: 1, trim: 0.85, thin: false),
	// MODE 2 / 1 PADS — one pad (two detuned saws + a triangle), held chords ↔ pumped on every beat; Tension brings it
	// in (30 % → full: the map padIn on the strip, at once); button 1 = the progression for all, button 2 = chord colour
	(name: \pad, sounds: [\sdSynthMod], level: jonas.(1).level, roomR: \padRoom, orbit: 2, trim: \padIn, thin: false),
	// MODE 2 / 2 STRINGS — 008's JX strings (supersaws) on the chords, bowed in a 3-3-2 pulse or swelling (Bow);
	// audible from Tension 0, Tension brings them up (the map strIn, at once); echo throw on button 2
	(name: \strings, sounds: [\sdSupersawWide], level: jonas.(2).level, orbit: 2, trim: \strIn, thin: false,
		roomR: \strRoom, echoSend: \strEcho, tensionEcho: false),
	// MODE 2 / 3 STAB SHAPE has no sound of its own: its knobs, fader and buttons shape the stab (column 4)
	// MODE 2 / 4 STAB — an acid dub chord: root, third, seventh, ninth on detuned saws (+ a square an octave below)
	// through a resonant low-pass that snaps shut; every third hit an accent, slides between near notes, the filter
	// wandering on two slow cycles; Vanish leaves bars out at random (the answer takes them); echo throw on button 2
	(name: \stab, sounds: [\sdSynthMod], level: jonas.(4).level, roomR: \stabRoom, echoSend: \stabEcho, tensionEcho: false,
		orbit: 2, trim: 0.62, thin: false),
	// MODE 2 / 5 ANSWER — 016's square blips (rubbery, a glassy octave above) at the end of every second bar, wide left
	// and right, long echo; also in the bars the stab leaves
	(name: \answer, sounds: [\sdSynthMod], level: jonas.(5).level, roomR: \ansRoom, echoSend: \ansEcho, orbit: 2, trim: 0.79, thin: false),
	// MODE 2 / 6 ACCENTS — rare, short, high one-shots (glass, metal, chirp, drop, pluck, zap, bleep run, squelch,
	// wooden bell) on the 16th grid, with their own echo
	(name: \acc, sounds: [\sdSynthMod, \modalPerc], level: jonas.(6).level, roomR: \accRoom, echoSend: \accEcho, orbit: 2, trim: 1.6, thin: false),
	// MODE 2 / 7 FX — a swirling noise riser in the last bar of each phrase, one of three tails on the one after it
	(name: \fx, sounds: [\sdNoise, \sdSynthMod, \modalPerc], level: jonas.(7).level, roomR: \fxRoom, echoSend: \fxEcho, orbit: 2, trim: 0.4, thin: false),
	// LAUNCHKEY MK4 25 — as 008: keys = Jonas' keys of 009 (orbit 2, mod wheel = level); drum pads: 16 one-shots
	// (orbit 1, each lane a shot's own room / echo). No Tension echo (Strudel gives none), no master (as Strudel).
	(name: \lk, sounds: ~ce.lkKeysSounds ++ [\sdSampleMod, \sdSynthMod], level: \lkLevel, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \shots, orbit: 1, level: 1.0, roomR: 0.3), (name: \lt, orbit: 1, level: 1.0, roomR: 0.5),
			(name: \rim, orbit: 1, level: 1.0, roomR: 0.3, echoSend: 0.4), (name: \braaam, orbit: 1, level: 1.0, roomR: 0.9),
			(name: \space, orbit: 1, level: 1.0, roomR: 0.9), (name: \wind, orbit: 1, level: 1.0, roomR: 0.8)]),
],

// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these), the same as 008's. Mod wheel (CC 1) = keys level,
// knobs CC 21-28: 1 brightness, 2-4 the keys' sound pairs, 5 length, 6 space, 7 echo, 8 one-shot darkness.
lkCtl: { |ce, num, v, send|
	if(num == 22) { ce.lkTurned2 = true };   // knob 2 keeps its start value 0.5 (piano + Rhodes) until it is turned
	switch(num,
		1, { ce.setState(\lkLevel, v, send) },
		21, { ce.setState(\lkBright, v, send) },
		26, { ce.setState(\lkRoom, 0.9 * (0.1 + (0.7 * v)), send) },   // roomOf(0.1 … 0.8)
		27, { ce.setState(\lkEcho, 0.6 * v, send) })
},
lkNote: { |ce, note, vel, chan|
	var k = { |n| ce.lkCC[20 + n] }, nl = 0.25 + (1.75 * k.(5));   // note length in bars
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
lkPadNames: ["Brace", "Paper", "Wine", "Forest", "Meadow", "Creatures", "No end", "Vast", "Low tom", "Rim echo",
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
	// a noise note (sdNoise): colour 0 pink, 1 white
	var noise = { |color, g, args| ce.note(\sdNoise, (color: color, amp: g, thinF: thin, tag: ["pink", "white"][color], g: g)
		++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	// the FM modulator's start phase: offline as superdough's render has it (started at time 0), live random
	var modPhase = { |k, at, freq| if(ce.webaudioPhase == true) { (2pi * freq * ((k + at) / 4 / (bpm / 60))) % 2pi } { -1 } };
	// Wumms (column 8 fader), read per note as Strudel's withWumms does
	var wumms = { ce.val(glob.level) };
	// 0 → 1 over `bars` while a button is held, in steps per bar (Strudel heldRamp reads the button per bar)
	var heldRamp = { |cc, bars| var st = ();
		{ |t| if(ce.held(cc)) { st[\from] = st[\from] ? t.floor; ((t.floor - st[\from]) / bars).clip(0, 1) } { st[\from] = nil; nil } } };

	// Knob defaults of the Strudel track (live only, as there: Web MIDI): the pad Space 0.5 until the knob is moved.
	// Offline renders (comparisons) start from the scenario's values, as the Node tools do.
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

	// HARMONY: the pad's button 1 picks the progression (next bar); everybody follows its root
	self.padVar = ce.change(jonas.(1).btn, progs.size, "Pads", progNames);
	self.rootAt = { |self, b| progs[self.padVar.atBar(b)][(b / 2).floor % 4] };
	self.moodAt = { |self, b| self.mood.atBar(b) };
	// Pad colour (pad button 2): chord shapes in scale degrees above the root, at the next bar
	self.padColours = [["7", [0, 2, 4, 6]], ["9", [0, 2, 4, 6, 8]], ["Fourths", [0, 3, 6, 9]], ["Fifths", [0, 4, 8]]];
	self.colour = ce.latch(1, 0, { |i| ce.status("Colour", self.padColours[i][0]); ce.uiPush });
	ce.cycleButton(jonas.(1).btn2, self.padColours.size, { |s| self.colour.pending = s });

	// MODE 1 / 1 KICK — Strudel row: 4/4 (button 1 held: 8/4), so the UI shows the same fixed row
	{
		var kc = jojo.(1);
		// Punch (row 3): soft thump at 0 → round kick at 1, a straight line between (Strudel punch2)
		var punch2 = { |p, soft, round| soft + ((round - soft) * p) };
		ce.uiRows['jojo:1'] = (latch: (now: 0, pending: 0), names: ["4/4 (held: 8/4)"]);
		stem.(\kick).notes = { |k|
			var b = bar.(k), step = if(ce.held(kc.btn)) { 2 } { 4 }, p, w, gw, lp;
			if(self.beatOn(b).not or: { ce.held(kc.btn2) } or: { k % step != 0 }) { [] } {
				p = ce.val(kc.char); w = wumms.(); gw = 0.85 * dB.(1.5 * w);
				// the whole kick: low-pass from Brightness × Fog / Tension, Wumms drives it (shape)
				lp = (lpOn: 1, bright: ce.val(kc.bright), lo: 600, hi: 6000, tone: tone, shape: 0.25 * w, hold: step);
				[
					syn.(\sine, 36, gw, lp ++ (penv: punch2.(p, 10, 20) + (6 * w), pd: punch2.(p, 0.1, 0.06))
						++ adsr.(punch2.(p, 0.014, 0.005), punch2.(p, 0.6, 0.45) * (1 + (0.4 * w)), 0, 0.06)),
					smp.("tr909/bd-01.wav", "RolandTR909_bd:0", punch2.(p, 0, 0.15) * gw, lp ++ (hold: -1), \sdSampleMod),
					// the sub thump under it (C1), louder with Wumms
					syn.(\sine, 24, (0.3 + (0.25 * w)) * gw, lp ++ adsr.(0.01, 0.35, 0, 0.1))
				].reject { |n| n.amp <= 0 }
			}
		};
	}.value;

	// MODE 1 / 2 RUMBLE (008's, × Wumms)
	{
		var rc = jojo.(2), hitsOf = [[2, 3], [1, 2, 3], [2]];
		var sp = { |s| 0.35 + (0.45 * s) };   // the rumble's space: 0.35 .. 0.8
		var upd = { |send| var s = sp.(ce.val(rc.space)), m = ce.val(rc.char);
			ce.setState(\rumRoom, 0.9 * s, send); ce.setState(\rumEcho, (0.4 * m * 2 * s).min(0.9), send) };
		var rise = heldRamp.(rc.btn2, 2);
		[rc.space, rc.char].do { |cc| ce.onCC(cc, { |v, send| upd.(send) }) };
		self.rumbleVar = ce.change(rc.btn, 3, "Rumble", ["3+4", "2+3+4", "3"]);
		stem.(\rumble).notes = { |k|
			var b = bar.(k), t = t16.(k), out = List[], m, w, gw, lp, r;
			r = rise.(t);   // riser: 0 → 1 over 2 bars while button 2 is held
			if(self.beatOn(b) and: { hitsOf[self.rumbleVar.atBar(b)].includes(k % 4) }) {
				m = ce.val(rc.char); w = ce.sine(b / 2);   // Motion's sine is read at the bar start
				gw = 0.67 * dB.(3 * wumms.());
				lp = (lpOn: 1, bright: ce.val(rc.bright), lo: 100, hi: 500, tone: tone, cutMul: 1 - (0.6 * m * w), lane: \pump);
				out.add(syn.(\sine, 36, 0.5 * gw, (hold: 1, penv: 12, pd: 0.05) ++ adsr.(nil, 0.3, 0, nil) ++ lp));
				// (sdSampleMod: its low-pass multiplies Motion after the 80 Hz … 18 kHz clamp, as Strudel does)
				out.add(smp.("tr909/bd-01.wav", "RolandTR909_bd:0", 0.2 * gw, lp, \sdSampleMod));
			};
			if(r.notNil and: { r > 0 }) { out.add(ce.note(\sdNoise, (color: 0, amp: r * 1.4, hold: 1, lane: \riser, thinF: thin,
				bp: 300 * (20 ** r), bpq: 4, pan: ce.sine(t * 2), tag: "pink", g: r * 1.4) ++ adsr.(0.03, nil, 0.8, 0.15, synthDef))) };
			out
		};
	}.value;

	// MODE 1 / 3 SUB — Pump: a 16th after every kick for three 16ths; Fifth: beat 4 on the fifth; Syncopated: beat 4 split
	{
		var sc = jojo.(3);
		// [16th in the bar → [degree, length in 16ths]]
		var pats = [
			Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [0, 3]],
			Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [4, 3]],
			Dictionary[1 -> [0, 3], 5 -> [0, 3], 9 -> [0, 3], 13 -> [0, 1], 15 -> [0, 1]]];
		self.subVar = ce.change(sc.btn, 3, "Sub", ["Pump", "Fifth", "Syncopated"]);
		stem.(\sub).notes = { |k|
			var b = bar.(k), x, m, clip, env, w, gw;
			x = if(self.beatOn(b)) { pats[self.subVar.atBar(b)][k % 16] };
			if(x.isNil) { [] } {
				m = degMidi.(x[0] + self.rootAt(b), 1, self.moodAt(b)) + if(ce.held(sc.btn2)) { 12 } { 0 };
				clip = 1 - (0.65 * ce.val(sc.char));
				env = adsr.(0.015, nil, 1, 0.04) ++ (hold: x[1] * clip, len16: x[1] * clip);
				w = wumms.(); gw = dB.(4 * w);
				[syn.(\sine, m, 0.9 * gw, env), syn.(\triangle, m, (0.18 + (0.3 * ce.val(sc.bright)) + (0.15 * w)) * gw, env)]
			}
		};
	}.value;

	// MODE 1 / 4 BASS — [figure (2 bars, alternating), ghost notes], scale degrees above the chord root (7 = octave,
	// -1 = ♭7 below)
	{
		var bc = jojo.(4);
		var lines = [
			[["~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ 7 ~ ~"], "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0"],
			[["~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ 0 0", "~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~"], "~ ~ ~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~"],
			[["~ ~ 0 ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ 7 ~ ~", "~ ~ 0 ~ ~ ~ ~ ~ ~ ~ 0 ~ ~ -1 ~ ~"], "~ ~ ~ ~ ~ 0 ~ ~ ~ ~ ~ ~ ~ ~ ~ 0"],
		].collect { |l| [l[0].collect(line), line.(l[1])] };
		// the filter envelope per 16th (Strudel lpenv "[1.5 1.8 2.6 1.6]*4"): the 3rd 16th of each beat opens furthest
		var envs = [1.5, 1.8, 2.6, 1.6];
		var topLate = 0.012 * (bpm / 60) * 4;   // the right copy of the top layer: 12 ms later (in 16ths)
		self.bassVar = ce.change(bc.btn, 3, "Bass", ["Sparse", "Call", "Roll"]);
		stem.(\bass).notes = { |k|
			var b = bar.(k), s16 = k % 16, out = List[], l, deg, c, w, gw, f, lp, oct, note;
			if(self.beatOn(b).not) { [] } {
				l = lines[self.bassVar.atBar(b)];
				c = ce.val(bc.char); oct = if(ce.held(bc.btn2)) { 12 } { 0 }; w = wumms.(); gw = dB.(w);
				// the low-pass: Brightness 350 … 2500 Hz, at least 350 + 150 × Wumms, × a slow sine (one cycle in 16 bars,
				// read at the bar start); then × Fog / Tension, kept within 80 Hz … 18 kHz
				f = (350 * ((2500 / 350) ** ce.val(bc.bright))).max(350 + (150 * w)) * (0.8 + (0.45 * ce.sine(b / 16)));
				lp = (lpOn: 1, bright: 0, lo: f, hi: f, tone: tone, lpq: 4, lpenv: envs[s16 % 4], la: 0.003, ld: 0.12, ls: 0, lr: 0.01,
					shape: 0.15 + (0.2 * w)) ++ adsr.(0.004, 0.14, 0.1, 0.08);
				// a note at `at` (16ths after this 16th), length 1
				note = { |wave, deg, at, g, args| var m = degMidi.(deg + self.rootAt(b), 2, self.moodAt(b)) + oct;
					syn.(wave, m, g * gw, lp ++ (hold: 1, at: at) ++ (args ? ())) };
				deg = l[0][b % 2][s16];
				deg !? {
					out.add(note.(\sawtooth, deg, 0, 0.75 * 0.3));
					out.add(note.(\triangle, deg, 0, 0.6 * 0.3));
					out.add(note.(\sawtooth, deg, 0, 0.3 * 1.2, (pan: 0, hp: 200)));   // 0.3 × 1.2 as in Strudel (same float)
					out.add(note.(\sawtooth, deg, topLate, 0.3 * 1.2, (pan: 1, hp: 200)));
				};
				if(c > 0) { l[1][s16] !? { |d|
					out.add(note.(\sawtooth, d, 0, 0.75 * (c * 0.16)));
					out.add(note.(\triangle, d, 0, 0.6 * (c * 0.16)));
				} };
				out
			}
		};
	}.value;

	// MODE 1 / 5 WOOD — keeps playing in the break; Tension's roll (last fifth of the knob) builds the drop there
	{
		var wc = jojo.(5);
		// layers per pattern: [block / mallet / log, hits (16 steps, or a function of the 16th number), note per bar,
		// gain, pan, offset in 16ths]. All three are 016's Rave at heart: Rave as it was, Spin = its high block every
		// third 16th (three against four: it turns around the bar and comes home every 3 bars), Tumble = Rave with flams
		// before the off-beats and a mallet line over 8 bars. The log (a hollow wooden body) doubles the low block.
		var lines = { |l| l.collect { |x| [x[0], if(x[1].isString) { var h = hits.(x[1]); { |k| h[k % 16] } } { x[1] }] ++ x[2..] } };
		var woods = [
			[[\block, "~ x ~ x ~ x x ~ ~ x ~ x x ~ x x", [79], 0.34, 0.3], [\block, "~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ x ~ ~", [72], 0.45, 0.22],
				[\log, "~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ x ~ ~", [60], 0.3, 0.4], [\mallet, "~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~", [65, 72, 68, 72], 0.33, 0.38]],
			[[\block, { |k| k % 3 == 1 }, [79, 79, 80, 79], 0.32, 0.3], [\block, "~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ x ~ ~", [72], 0.45, 0.22],
				[\log, "~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ x ~ ~", [60], 0.3, 0.4],
				[\mallet, "~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~", [65, 72, 68, 72, 65, 75, 72, 68], 0.33, 0.38]],
			[[\block, "~ x ~ x ~ x x ~ ~ x ~ x x ~ x x", [79], 0.34, 0.3], [\block, "~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~", [79], 0.16, 0.34, 0.5],
				[\block, "~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~ x", [72], 0.45, 0.22], [\log, "~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~ x", [60], 0.3, 0.4],
				[\mallet, "~ ~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~", [65, 72, 68, 72, 65, 72, 75, 77], 0.3, 0.62]],
		].collect(lines);
		var vels = [1, 0.62, 0.85, 0.7];   // accents by the 16th in the beat
		var rise = heldRamp.(wc.btn2, 2);
		self.woodVar = ce.change(wc.btn, 3, "Wood", ["Rave", "Spin", "Tumble"]);
		stem.(\wood).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, out = List[], v = self.woodVar.atBar(b), c = ce.val(wc.char), lp, r, tr;
			// the wood block: a short sine with inharmonic FM (ratio 3.47); the mallet: a short triangle; the log: a
			// hollow wooden body (modal), an octave under the low block
			var block = { |m, g, pan, at = 0, len = 1, vel = 1| syn.(\sine, m, (g * 1.4) * vel, lp ++ (fmi: 1.2, fmh: 3.47, modPhase: modPhase.(k, at, m.midicps * 3.47),
				pan: pan, at: at, hold: len) ++ adsr.(0.001, 0.045, 0, 0.03)) };
			var mallet = { |m, g, pan, at = 0, vel = 1| syn.(\triangle, m, (g * 1.4) * vel, lp ++ (pan: pan, at: at, hold: 1) ++ adsr.(0.002, 0.11, 0, 0.06)) };
			var log = { |m, g, pan, at = 0, vel = 1| ce.note(\modalPerc, lp ++ (kind: 1, freq: m.midicps, decay: 0.11, glide: 0, hard: 0.75,
				skin: 0, amp: g * vel, pan: pan, at: at, hold: 1, thinF: thin, tag: "log", g: g * vel, midi: m)) };
			// the low-pass: Brightness 4000 … 16000 Hz × Fog only (Tension does not open it): bright from 0 on
			lp = (lpOn: 1, bright: ce.val(wc.bright), lo: 4000, hi: 16000, tone: fog);
			// the pattern, swung by Bounce (the odd 16ths come 0.1 … 0.5 of a 16th later), each hit a little uneven
			woods[v].do { |x| if(x[1].(k)) {
				var at = (x[5] ? 0) + if(k.odd) { 0.1 + (0.4 * c) } { 0 }, m = x[2][b % x[2].size];
				var vel = vels[s16 % 4] * (0.9 + (0.2 * ce.rand(t + (0.37 * x[2][0]))));
				out.add(switch(x[0], \block, { block.(m, x[3], x[4], at, 1, vel) }, \log, { log.(m, x[3], x[4], at, vel) },
					{ mallet.(m, x[3], x[4], at, vel) })) } };
			// roll (button 2): 32nds on C5 / G5 (alternate bars), filling in and getting louder over 2 bars
			r = rise.(t);
			r !? { 2.do { |j| if(ce.rand((k + (j / 2)) / 16) >= (0.85 - (0.75 * r))) {
				out.add(block.([72, 79][b % 2], 0.12 + (0.3 * r), 0.3, j / 2, 0.5)) } } };
			// Tension's roll (last fifth of the knob), also in the break: loose 16ths → all, swelling on a curve
			tr = ramp.(ce.val(self.tension), 0.8, 1);
			if(tr > 0 and: { ce.rand(t) >= (0.8 * ((1 - tr) ** 1.5)) }) { out.add(block.(72, 0.05 + (0.4 * tr * tr), 0.25)) };
			out
		};
	}.value;

	// MODE 1 / 6 HATS
	{
		var hc = jojo.(6);
		self.hatVar = ce.change(hc.btn, 3, "Hats", ["Groove", "Open", "Fast"]);
		stem.(\hats).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, q = k % 4, out = List[], v = self.hatVar.atBar(b), c = ce.val(hc.char), lp, hit, closed, open;
			lp = (lpOn: 1, bright: ce.val(hc.bright), lo: 9000, hi: 18000, tone: fog, hp: 1800);
			hit = { |rel, tag, g, args| smp.(rel, tag, g * 3.2, lp ++ (args ? ())) };
			// closed: short, right; open: a little right of centre
			closed = { |g, at = 0, len = 1| hit.("tr909/hh-00.wav", "RolandTR909_hh:0", g, (pan: 0.72, at: at, hold: len) ++ adsr.(nil, 0.035, 0, 0.02)) };
			open = { |g, len = 1, dec = 0.2, rel = 0.06| hit.("tr909/oh-00.wav", "RolandTR909_oh:0", g, (pan: 0.56, hold: len) ++ adsr.(nil, dec, 0, rel)) };
			if(ce.held(hc.btn2).not) {
				switch(v,
					// Groove: closed x x ~ x per beat (swung 0.12), open on the off-beat 16th
					0, { [0.22, 0.12, nil, 0.16][q] !? { |g| out.add(closed.(g, if(k.odd) { 0.12 } { 0 })) };
						if(q == 2) { out.add(open.(0.3)) } },
					// Open: the open hat louder, a quiet closed hat on the beat
					1, { if(q == 2) { out.add(open.(0.36)) }; if(q == 0) { out.add(closed.(0.1)) } },
					// Fast: closed swung 0.2, a 32nd double at the end of every half bar, open on 3 and 11
					2, { [0.2, 0.15, nil, 0.18][q] !? { |g| out.add(closed.(g, if(k.odd) { 0.2 } { 0 })) };
						if(k % 8 == 7) { [0, 0.5].do { |at| out.add(closed.(0.1, at, 0.5)) } };
						if([2, 10].includes(s16)) { out.add(open.(0.32)) } });
			} {
				// Long: closed x x ~ x, the open hat on every off-beat 8th, ringing longer
				[0.14, 0.14, nil, 0.14][q] !? { |g| out.add(closed.(g)) };
				if(q == 2) { out.add(open.(0.34, 2, 0.45, 0.1)) };
			};
			// Complexity: quiet 32nd skips, three in four left out at random
			if(c > 0) { 2.do { |j| if(ce.rand((k + (j / 2)) / 16) >= 0.75) { out.add(closed.(c * 0.12, j / 2, 0.5)) } } };
			out.reject { |n| n.amp <= 0 }
		};
	}.value;

	// MODE 1 / 7 PERCUSSION — a pair of bongos (macho C5, hembra F4) and a conga (C4) played by hand: open tones,
	// slaps, fingertips and the thumb; each drum in its place in the stereo field, a little uneven in time and strength
	{
		var pc7 = jojo.(7);
		// a stroke line per drum: O open tone, S slap, f fingertip (muffled), T thumb / heel (muffled, soft), ~ rest
		var strokes = { |str| str.split($ ).reject(_.isEmpty).collect { |x| if(x == "~") { nil } { x.asSymbol } } };
		// per pattern: [macho, hembra, conga]
		var pats = [
			// Pillow: the hembra's open tones, the macho answering, a slap on each half, a conga slap on the 7th 8th
			["~ ~ O ~ ~ ~ ~ f ~ ~ S ~ ~ ~ O ~", "O ~ ~ ~ ~ ~ O ~ ~ ~ ~ O ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ S ~ ~ ~"],
			// Gallop: macho and hembra in gallop pairs
			["~ ~ O f ~ ~ ~ f S ~ ~ ~ O f O ~", "O ~ ~ ~ O ~ ~ ~ ~ ~ O ~ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ S ~ ~ ~"],
			// 3-3-2: hembra, hembra, conga on the 3-3-2, the macho between
			["~ ~ O ~ ~ ~ ~ S ~ ~ O ~ ~ ~ S ~", "O ~ ~ ~ ~ ~ O ~ ~ ~ ~ ~ ~ ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ O ~ ~ ~"],
		].collect { |p| p.collect(strokes) };
		// Fill (button 2): open tones across the drums, macho → hembra → conga, getting stronger
		var fill = strokes.("M H M H M M H H M H C H C ~ C ~");
		// [MIDI note, pan, ring of an open tone (× the macho's), strength]
		var drums = (M: [72, 0.62, 1, 1], H: [65, 0.4, 1.38, 1], C: [60, 0.28, 2, 0.6]);
		// per stroke: [decay (s), glide, hardness, skin noise, strength]
		var kinds = (O: [0.16, 0.07, 0.45, 0.12, 0.8], S: [0.05, 0.12, 0.95, 0.85, 0.7], f: [0.035, 0.02, 0.6, 0.25, 0.3],
			T: [0.05, 0.03, 0.2, 0.05, 0.35]);
		var lp;
		var hit = { |drum, st, at, vel| var d = drums[drum], s = kinds[st], v = s[4] * d[3] * vel;
			ce.note(\modalPerc, lp ++ (kind: 0, freq: d[0].midicps, decay: s[0] * if(st == \O) { d[2] } { 1 }, glide: s[1],
				hard: s[2] * (0.7 + (0.3 * v)), skin: s[3], amp: 1.35 * v, pan: d[1], at: at, hold: 1, thinF: thin,
				tag: drum.asString ++ st, g: 1.35 * v, midi: d[0])) };
		self.percVar = ce.change(pc7.btn, 3, "Percussion", ["Pillow", "Gallop", "3-3-2"]);
		stem.(\perc).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, out = List[], p = pats[self.percVar.atBar(b)], c = ce.val(pc7.char), main;
			// a hand's timing: the off 16ths a little late, the hembra later still, and a few ms either way
			var feel = { |j, drum| ((if(k.odd) { 0.06 } { 0 }) + (if(drum == \H) { 0.04 } { 0 }) + (0.05 * (ce.rand(t + (0.13 * j)) - 0.5))).max(0) };
			var human = { |j| 0.88 + (0.24 * ce.rand(t + 0.5 + (0.29 * j))) };
			lp = (lpOn: 1, bright: ce.val(pc7.bright), lo: 2500, hi: 14000, tone: tone);
			main = [[\M, p[0][s16]], [\H, p[1][s16]], [\C, p[2][s16]]].select { |x| x[1].notNil };
			main.do { |x, j| out.add(hit.(x[0], x[1], feel.(j, x[0]), human.(j))) };
			// Complexity 0 … 0.5: the gaps fill with the martillo's fingertips (macho) and thumbs (hembra)
			if(main.isEmpty and: { ce.rand(t + 0.71) < ramp.(c, 0, 0.5) }) {
				out.add(if(k.even) { hit.(\M, \f, feel.(3, \M), human.(3)) } { hit.(\H, \T, feel.(3, \H), human.(3)) }) };
			// 0.5 … 1: a flam before open tones, then little 32nd rolls on the macho at the end of the bar
			if(c > 0.5) { [[\M, p[0][(s16 + 1) % 16]], [\H, p[1][(s16 + 1) % 16]]].do { |x|
				if(x[1] == \O and: { ce.rand(t + 0.9) < ramp.(c, 0.5, 1) }) { out.add(hit.(x[0], \f, 0.65, 0.7)) } } };
			if(c > 0.75 and: { s16 >= 13 }) { 2.do { |j|
				if(ce.rand(t + (0.5 * j) + 0.33) < ramp.(c, 0.75, 1)) { out.add(hit.(\M, \f, 0.5 * j, 0.6 + (0.2 * j))) } } };
			if(ce.held(pc7.btn2)) { fill[s16] !? { |d| out.add(hit.(d, \O, 0, 0.5 + (0.5 * (s16 / 15)))) } };
			out
		};
	}.value;

	// ---- Mode 2: room / echo amounts of the columns whose Space is scaled (Strudel bus / dryBus with a scaled space),
	// set from the knob the moment it moves (state buses the strips read) ----
	self.spaceState = { |self, cc, name, fn| ce.onCC(cc, { |v, send| ce.setState(name, fn.(v), send) }) };
	// echo throw (button 2 held): a long echo (0.85) on a dry column
	self.throwState = { |self, cc, name| ce.onCC(cc, { |v, send| ce.setState(name, if(v > 0.5) { 0.85 } { 0 }, send) }) };

	// MODE 2 / 1 PADS — held chords (Pump 0 … 1) and chords pumped on every beat (Pump 0.5 … 1); Tension's share is on
	// the strip (padIn), the log has it in g as Strudel's gain does
	{
		var pc = jonas.(1);
		self.spaceState(pc.space, \padRoom, { |s| 0.9 * (0.3 + (0.7 * s)) });
		stem.(\pad).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, out = List[], p = ce.val(pc.char), fm = ramp.(p, 1, 0.5), fx = ramp.(p, 0, 0.5);
			var pin = 0.3 + (0.7 * ramp.(ce.val(self.tension), 0, 0.5)), notes, lp, layer, sp, tp;
			if((s16 % 4) != 0) { [] } {
				notes = self.padColours[self.colour.atBar(b)][1].collect { |d| degMidi.(d + self.rootAt(b), 3, self.moodAt(b)) };
				// Brightness acts at once (long notes)
				lp = (lpOn: 1, bright: ce.ccMap(pc.bright), lo: 250, hi: 6000, tone: tone);
				// the pans wander slowly (one sweep in 5 bars), saws and triangle on opposite sides
				sp = 0.15 + (0.7 * ce.sine(t / 5)); tp = 0.85 - (0.7 * ce.sine(t / 5));
				// one chord: two saws 0.1 semitone apart + a triangle (amp without padIn: the strip has it)
				layer = { |m, g, env| [0, 0.1].collect { |dm| syn.(\sawtooth, m + dm, 0.045 * g, lp ++ (pan: sp) ++ env) ++ (g: 0.045 * g * pin) }
					++ [syn.(\triangle, m, 0.08 * g, lp ++ (pan: tp) ++ env) ++ (g: 0.08 * g * pin)] };
				// held chords: struck once per bar, long attack and release
				if(fm > 0 and: { s16 == 0 }) { notes.do { |m| out.addAll(layer.(m, fm, (hold: 16) ++ adsr.(0.9, nil, 0.8, 2))) } };
				// pumped chords: struck on every beat, the attack grows with Pump
				if(fx > 0) { notes.do { |m| out.addAll(layer.(m, fx, (hold: 4) ++ adsr.(0.06 + (0.14 * p), nil, 1, 0.04))) } };
				out
			}
		};
	}.value;

	// MODE 2 / 2 STRINGS — four voices on the chord (root, fifth, octave, tenth above the chord root, F4 upwards), bowed
	// in a 3-3-2 pulse or swelling over 2 bars (Bow); each move walks one voice through the 8 bars. Their filter and
	// their spread breathe on two slow cycles, so no two bars sound the same.
	{
		var sc = jonas.(2);
		// voice → scale degree above the chord root per 2-bar unit (4 units = 8 bars)
		var moves = [
			["Lift", [[0, 0, 0, 0], [4, 4, 4, 5], [7, 7, 7, 7], [9, 9, 9, 9]]],
			["Sink", [[0, 0, 0, -1], [4, 4, 4, 4], [7, 7, 7, 6], [9, 9, 9, 9]]],
			["Line up", [[0, 0, 0, 0], [4, 5, 6, 5], [7, 7, 7, 7], [9, 9, 9, 9]]],
			["Line down", [[0, 0, 0, 0], [4, 4, 4, 4], [7, 6, 5, 6], [9, 9, 9, 9]]],
			["Chain", [[0, 0, 0, 0], [4, 5, 5, 4], [7, 7, 7, 7], [9, 9, 10, 9]]],
		];
		// the bowed pulse: [16th, length in 16ths, strength]
		var pulse = [[0, 5, 1], [6, 5, 0.8], [12, 3, 0.9]];
		self.spaceState(sc.space, \strRoom, { |s| 0.9 * (0.3 + (0.7 * s)) });
		self.throwState(sc.btn2, \strEcho);
		self.strVar = ce.change(sc.btn, moves.size, "Strings", moves.collect(_[0]));
		stem.(\strings).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, out = List[], bow = ce.val(sc.char), unit = (b % 8 / 2).floor, mv, play;
			// one chord: two supersaw layers per voice (amp without strIn: the strip has it), Brightness at once, the
			// cutoff × a slow wander (7 and 3 bars), the detune on its own slow cycle
			play = { |len, g, env| var lp = (lpOn: 1, bright: ce.ccMap(sc.bright), lo: 500, hi: 7000, tone: tone, hold: len,
				cutMul: 0.65 + (0.35 * ce.sine(t / 7)) + (0.25 * ce.sine(t / 3)));
				mv[1].do { |voice, i| var m = degMidi.(voice[unit] + self.rootAt(b), 4, self.moodAt(b));
					[[0, 0.06 + (0.1 * ce.sine((t / 5) + (0.25 * i))), 0.6, 0.5], [0.1, 0.05, 0.9, 0.3]].do { |x|
						out.add(ce.note(\sdSupersawWide, (freq: (m + x[0]).midicps, unison: 2, dtn: x[1], spread: x[2], amp: x[3] * 0.55 * g,
							thinF: thin, tag: "supersaw", g: x[3] * 0.55 * g, midi: m + x[0]) ++ lp ++ env)) } } };
			mv = moves[self.strVar.atBar(b)];
			if(bow < 0.5) {
				// Bow 0 … 0.5: short bowed pulses, getting longer and softer at the attack
				pulse.do { |p| if(p[0] == s16) { var len = p[1] * (0.55 + (0.9 * bow));
					play.(len, p[2], adsr.(0.02 + (0.12 * bow), 0.25, 0.65, 0.3)) } }
			} {
				// 0.5 … 1: one long swell every 2 bars, slower with the knob
				if(k % 32 == 0) { play.(32, 0.85, adsr.(0.35 + (4.4 * (bow - 0.5)), 0.1, 1, 0.8)) }
			};
			out
		};
	}.value;

	// MODE 2 / 3 STAB SHAPE + 4 STAB
	{
		var sh = jonas.(3), lc = jonas.(4);
		// figures: scale degrees of the chord root (the whole chord moves with it, in the mood's scale)
		var stabs = [
			["~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~"],
			["~ ~ 0 ~ ~ ~ 0 ~ ~ ~ 2 ~ ~ 0 ~ ~", "~ ~ 0 ~ ~ ~ 0 ~ ~ ~ -1 ~ ~ 0 ~ ~"],
			["~ ~ 0 ~ ~ 0 ~ ~ 4 ~ ~ 0 ~ ~ 2 ~"],
			["~ 0 ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ 0 ~ ~ ~", "~ 0 ~ 0 ~ ~ 2 ~ ~ 0 ~ ~ -1 ~ ~ ~"],
			["~ ~ 0 ~ 0 ~ ~ ~ ~ ~ 7 ~ ~ ~ ~ ~", "~ ~ 0 ~ 0 ~ ~ ~ ~ ~ 6 ~ ~ 4 ~ ~"],
			["~ ~ ~ 0 ~ ~ 0 ~ ~ ~ ~ 0 ~ ~ 0 ~"],
			["~ 0 0 ~ 2 ~ 0 ~ ~ 4 ~ 0 ~ 2 0 ~"],
			["~ ~ 0 0 ~ ~ 0 ~ ~ ~ 0 ~ ~ 0 ~ ~", "~ ~ 0 0 ~ ~ -1 ~ ~ ~ -3 ~ ~ -1 ~ ~"],
		].collect { |p| p.collect(line) };
		// the chord above the root, in scale degrees: root (twice, detuned, wide), third, seventh, ninth, a square below
		var voices = [[\sawtooth, 0, 0, 0.2], [\sawtooth, 0, 0.12, 0.8], [\sawtooth, 2, 0, 0.42], [\sawtooth, 6, 0, 0.58],
			[\square, 8, 0, 0.5], [\square, -7, 0, 0.5]];
		// Stab Shape button 1: the stab out at the next bar (and back)
		self.stabOut = ce.change(sh.btn, 2, "Stab Shape", ["Stab in", "Stab out"]);
		// per bar: the stab plays unless Vanish left this bar out (rand at the bar start, up to 85 % of the bars) or it
		// is out by hand; the answer reads this too
		self.stabHere = { |self, b| (self.stabOut.atBar(b) == 0) and: { ce.rand(b) >= (0.85 * ce.val(lc.char)) } };
		self.spaceState(lc.space, \stabRoom, { |s| 0.9 * (0.25 + (0.75 * s)) });
		self.throwState(lc.btn2, \stabEcho);
		self.stabVar = ce.change(lc.btn, 8, "Stab");
		stem.(\stab).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, l = stabs[self.stabVar.atBar(b)], row = l[b % l.size], d = row[s16];
			var snap, len, reso, drive, parts, w, lp, out = List[], count, acc, prev, slide, mood = self.moodAt(b), root = self.rootAt(b);
			if(d.isNil or: { self.stabHere(b).not }) { [] } {
				// the shape (Stab Shape column): Snap = filter envelope 3 … 7 octaves, Length = decay 0.17 … 0.67 s (the
				// filter decays in 0.47 of it), Resonance = Q 8 … 18 dB, Drive (its fader) = shape 0.25 … 0.7, the gain
				// down by as much as Drive adds (−8 dB at the top)
				snap = 3 + (4 * ce.val(sh.bright)); len = 0.17 + (0.5 * ce.val(sh.space));
				reso = 8 + (10 * ce.val(sh.char)); drive = ce.val(sh.level);
				// acid accents: every third hit, counted on through the bars (so the accent wanders over the figure),
				// opens the filter further, rings longer, louder and squelchier
				count = row.select(_.notNil).size;
				acc = (((0..15).count { |i| (i < s16) and: { row[i].notNil } } + (b * count)) % 3) == 0;
				// a slide: a hit up to three 16ths after one on another degree glides in from that note
				prev = [1, 2, 3].collect { |o| s16 - o }.detect { |i| (i >= 0) and: { row[i].notNil } };
				slide = if(prev.notNil and: { row[prev] != d }) { degMidi.(row[prev] + root, 3, mood) - degMidi.(d + root, 3, mood) } { 0 };
				// Ratchet (Stab Shape button 2 held): every stab twice in its own 16th
				parts = if(ce.held(sh.btn2)) { [[0, 0.5], [0.5, 0.5]] } { [[0, 1]] };
				// the low-pass wanders on two slow cycles against each other (7 and 3 bars), read at the hit
				w = 0.55 + (0.6 * ce.sine(t / 7)) + (0.35 * ce.sine(t / 3));
				lp = (lpOn: 1, bright: ce.val(lc.bright), lo: 400 * w, hi: 4000 * w, tone: tone, hp: 300,
					lpq: reso + if(acc) { 5 } { 0 }, lpenv: snap + if(acc) { 1.5 } { 0 }, la: 0.002, ld: len * if(acc) { 0.7 } { 0.47 },
					ls: 0, lr: 0.01, shape: 0.25 + (0.45 * drive))
					++ adsr.(0.002, len * if(acc) { 1.4 } { 1 }, 0, 0.08);
				parts.do { |pt, j|
					// the pitch: a slide from the last note, else a small drip down from a quarter tone above
					var bend = if(slide != 0 and: { j == 0 }) { (penv: slide, pd: 0.07, ps: 0.001) } { (penv: 0.5, pd: 0.05, ps: 0.001) };
					voices.do { |x| var m = degMidi.(d + x[1] + root, 3, mood) + x[2];
						out.add(syn.(x[0], m, 0.22 * dB.(-8 * drive) * if(acc) { 1.35 } { 1 },
							lp ++ bend ++ (at: pt[0], hold: pt[1], pan: x[3] + (0.1 * if(k.odd) { 1 } { -1 })))) }
				};
				out
			}
		};
	}.value;

	// MODE 2 / 5 ANSWER — 016's answer, a little apart: half of its phrase rhythms (the others new), a rubbery blip (a
	// square that drips down a quarter tone, with a glassy sine an octave up), wider left and right
	{
		var ac = jonas.(5), lc = jonas.(4);
		var rhythms = ["~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ x ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x x ~",
			"~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ x ~ x", "~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ x ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ x ~ x ~ ~ ~ ~ ~",
			"~ ~ ~ ~ ~ ~ ~ ~ ~ ~ x x ~ ~ x ~", "~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~ x x"].collect(hits);
		var tones = [0, 2, 4, 6, 7];   // root, 3rd, 5th, 7th, octave
		self.spaceState(ac.space, \ansRoom, { |s| 0.9 * (0.35 + (0.65 * s)) });
		self.spaceState(ac.space, \ansEcho, { |s| (0.55 * 2 * (0.35 + (0.65 * s))).min(0.9) });
		self.ansVar = ce.change(ac.btn, 8, "Answer");
		stem.(\answer).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, v = self.ansVar.atBar(b), vo = ce.val(ac.char), wild = ramp.(vo, 0.75, 1);
			var r = ce.rand(t), n = 0, tn, lp, out = List[];
			// the written phrase every second bar; in the bars between: from Voices 0.75 some of its notes spill over at
			// random, while button 2 is held a random answer on the back ten 16ths instead; and where the stab leaves a
			// bar (and its fader is up), the phrase there too. These layers add up: a note can play twice.
			if((b % 2) == 1) { if(rhythms[v][s16]) { n = 1 } } {
				if(ce.held(ac.btn2)) { if(s16 >= 6 and: { r >= 0.7 }) { n = n + 1 } }
					{ if(wild > 0 and: { rhythms[v][s16] } and: { r >= (1 - (0.6 * wild)) }) { n = n + 1 } };
				if(rhythms[v][s16] and: { self.stabHere(b).not } and: { ce.val(lc.level) > 0 }) { n = n + 1 };
			};
			if(n == 0) { [] } {
				// the note: a chord tone at random, new ones per change (the random numbers 1024 bars on)
				tn = tones[(5 * ce.rand(t + (1024 * v))).trunc.asInteger];
				lp = (lpOn: 1, bright: ce.val(ac.bright), lo: 2000, hi: 12000, tone: tone, hold: 1, pan: [0.12, 0.88][s16 % 2],
					penv: 0.5, pd: 0.03, ps: 0.001) ++ adsr.(nil, 0.085, 0, 0.06);
				// Voices: + the third (0 … 0.375), + the fifth (0.375 … 0.75), top quarter + the 7th; they strum apart
				n.do { [[0, 0.54, 0], [2, ramp.(vo, 0, 0.375) * 0.42, 1], [4, ramp.(vo, 0.375, 0.75) * 0.36, 2], [6, wild * 0.3, 3]].do { |x|
					if(x[1] > 0) { var m = degMidi.(tn + x[0] + self.rootAt(b), 5, self.moodAt(b));
						out.add(syn.(\square, m, x[1], lp ++ (at: x[2] * wild / 4)));
						out.add(syn.(\sine, m + 12, 0.35 * x[1], lp ++ (at: x[2] * wild / 4) ++ adsr.(nil, 0.06, 0, 0.04))) } } };
				out
			}
		};
	}.value;

	// MODE 2 / 6 ACCENTS — about one hit in two bars (Rate 0) up to two per bar (Rate 1) on the 16th grid, each a shot
	// and a pitch at random (F minor pentatonic, F6 – A♭7), with their own echo. Nine shots: glass and metal (real FM
	// now), chirp, drop, pluck, a laser zap, a bleep run, an acid squelch, a ringing wooden bell. One hit in six jumps an
	// octave; the sines drift a little in pitch as they ring.
	{
		var ac = jonas.(6);
		var accNotes = [89, 92, 94, 96, 99, 101, 104];
		// [kind, wave, fm index, fm ratio, pitch envelope, its decay, decay, shift]; kind: \syn, \run (three blips
		// rising inside the 16th), \squelch (resonant filter snap), \bell (modal wood, long ring)
		var shots = [[\syn, \sine, 3, 3.5, 0, 0, 0.05, 0], [\syn, \sine, 0, 1, 12, 0.03, 0.06, 0], [\syn, \sine, 0, 1, -24, 0.04, 0.07, -12],
			[\syn, \triangle, 0, 1, 0, 0, 0.09, -12], [\syn, \sine, 6, 1.414, 0, 0, 0.03, 0], [\syn, \sawtooth, 0, 1, -36, 0.12, 0.15, -12],
			[\run, \square, 0, 1, 0, 0, 0.03, -12], [\squelch, \square, 0, 1, 0, 0, 0.12, -24], [\bell, \sine, 0, 1, 0, 0, 0.9, -12]];
		self.spaceState(ac.space, \accRoom, { |s| 0.9 * (0.3 + (0.7 * s)) });
		self.spaceState(ac.space, \accEcho, { |s| 0.3 + (0.5 * s) });
		self.accVar = ce.change(ac.btn, 8, "Accents");
		stem.(\acc).notes = { |k|
			var b = bar.(k), t = t16.(k), v = self.accVar.atBar(b), rate = ce.val(ac.char), out = List[], lp;
			// a hit of the random series at time u: its own random numbers for shot, pitch, octave jump, pan and drift
			var hit = { |u, g, at, len| var rr = { |o| ce.rand(u + (1024 * v) + o) };
				var sh = shots[(rr.(0.11) * shots.size).trunc.asInteger];
				var m = accNotes[(rr.(0.23) * 7).trunc.asInteger] + sh[7] + if(rr.(0.37) < (1 / 6)) { [-12, 12][(rr.(0.41) * 2).trunc.asInteger] } { 0 };
				var args = lp ++ (pan: 0.05 + (0.9 * rr.(0.53)), at: at, hold: len) ++ adsr.(0.001, sh[6], 0, 0.04);
				if(sh[2] > 0) { args = args ++ (fmi: sh[2], fmh: sh[3]) };
				args = args ++ if(sh[4] != 0) { (penv: sh[4], pd: sh[5], ps: 0.001) } { (penv: 0.6 * (rr.(0.67) - 0.5), pd: 0.3, ps: 0.001) };
				switch(sh[0],
					\run, { 3.collect { |i| syn.(sh[1], m + [0, 7, 12][i], g * 0.7, args ++ (at: at + (len * i / 3), hold: len / 3)) } },
					\squelch, { [syn.(sh[1], m, g, args ++ (lo: 300, hi: 300, bright: 0, lpq: 16, lpenv: 5, la: 0.002, ld: 0.09, ls: 0, lr: 0.02))] },
					\bell, { [ce.note(\modalPerc, args ++ (kind: 1, freq: m.midicps, decay: sh[6], glide: 0, hard: 0.9, skin: 0, amp: g,
						thinF: thin, tag: "bell", g: g, midi: m))] },
					{ [syn.(sh[1], m, g, args)] }) };
			var r0 = ce.rand(t + (1024 * v));   // the series (1024 bars on per change)
			lp = (lpOn: 1, bright: ce.val(ac.bright), lo: 5000, hi: 18000, tone: tone);
			// share of the 16ths that play: 1/32 at Rate 0 up to 1/8 at Rate 1; the level swells slowly (perlin, 7 bars)
			if(r0 >= (1 - ((4 ** rate) / 32))) { out.addAll(hit.(t, 0.12 + (0.18 * ce.perlin(t / 7)), 0, 1)) };
			// Burst (button 2 held): the series twice as fast, half of it, in 32nds
			if(ce.held(ac.btn2)) { 2.do { |j| var u = t + (j / 32);
				if(ce.rand(u) >= 0.5) { out.addAll(hit.(2 * u, 0.2, j / 2, 0.5)) } } };
			out
		};
	}.value;

	// MODE 2 / 7 FX — the phrase (button 1: 8, 16 or 4 bars): a swirling riser in its last bar, a tail on its first
	// (one of three, picked anew each phrase), Complexity adds a rising saw (from 0), a small riser in the middle (from
	// 0.5) and a dub siren in the last half of the phrase (from 0.75); button 2 = a riser by hand
	{
		var fc = jonas.(7), lens = [8, 16, 4];
		var rise = heldRamp.(fc.btn2, 4);
		self.spaceState(fc.space, \fxRoom, { |s| 0.9 * (0.4 + (0.6 * s)) });
		self.spaceState(fc.space, \fxEcho, { |s| 0.2 + (0.6 * s) });
		self.fxVar = ce.change(fc.btn, 3, "FX", ["8 bars", "16 bars", "4 bars"]);
		stem.(\fx).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, x = s16 / 16, len = lens[self.fxVar.atBar(b)], c = ce.val(fc.char);
			var lp = (lpOn: 1, bright: ce.val(fc.bright), lo: 2000, hi: 16000, tone: tone), out = List[], r, pos = b % len;
			var tail = (ce.rand((b - pos) + 0.77) * 3).trunc.asInteger;
			// riser: pink noise in 16ths through a wide band-pass climbing from 300 Hz (pos 0) to 7.5 kHz (pos 1), and a
			// narrow, ringing band falling against it (the swirl), circling faster as it climbs
			var riser = { |p, g| [noise.(0, g * (0.1 + (0.9 * p * p)), lp ++ (hold: 1, bp: 300 * (25 ** p), bpq: 1.5,
					pan: 0.5 + ((0.2 + (0.25 * p)) * sin(2pi * t * (2 + (6 * p))))) ++ adsr.(0.03, nil, 1, 0.12)),
				noise.(0, g * 0.5 * p, lp ++ (hold: 1, bp: 6000 * ((1 / 12) ** p), bpq: 7, pan: 0.5 - (0.3 * sin(2pi * t * 3))) ++ adsr.(0.03, nil, 1, 0.12))] };
			if(pos == (len - 1)) {
				out.addAll(riser.(x, 1));
				if(c > 0) { out.add(syn.(\sawtooth, 53 + (12 * x), ramp.(c, 0, 0.5) * 0.06, lp ++ (hold: 1) ++ adsr.(0.01, nil, 1, 0.05))) };
			};
			if(pos == 0) {
				switch(tail,
					// the noise falling from 6 kHz, fading; a sine boom on F2 that drops an octave
					0, { out.add(noise.(0, 0.6 * ((1 - x) ** 2), lp ++ (hold: 1, bp: 6000 * ((1 / 20) ** x), bpq: 1) ++ adsr.(0.005, nil, 1, 0.2)));
						if(s16 == 0) { out.add(syn.(\sine, 41, 0.45, lp ++ (hold: 16, penv: 12, pd: 0.25) ++ adsr.(0.005, 1.2, 0, 0.3))) } },
					// a laser fall: a saw diving three octaves through a ringing low-pass, and the boom
					1, { if(s16 == 0) { out.add(syn.(\sawtooth, 41, 0.14, lp ++ (hold: 8, penv: 36, pd: 1.4, ps: 0.001, lpq: 14, lo: 900, hi: 900,
							bright: 0) ++ adsr.(0.002, 1.6, 0, 0.3)));
						out.add(syn.(\sine, 41, 0.45, lp ++ (hold: 16, penv: 12, pd: 0.25) ++ adsr.(0.005, 1.2, 0, 0.3))) } },
					// a ringing wooden bell on F and C, struck twice, over the falling noise
					2, { out.add(noise.(0, 0.35 * ((1 - x) ** 2), lp ++ (hold: 1, bp: 4000 * ((1 / 10) ** x), bpq: 2) ++ adsr.(0.005, nil, 1, 0.2)));
						if([0, 6].includes(s16)) { [65, 72].do { |m, i| out.add(ce.note(\modalPerc, lp ++ (kind: 1, freq: (m + (12 * (s16 / 6))).midicps,
							decay: 1.8, glide: 0, hard: 0.8, skin: 0, amp: 0.5 - (0.15 * i), pan: 0.3 + (0.4 * i), hold: 1, thinF: thin,
							tag: "bell", g: 0.5 - (0.15 * i), midi: m))) } } });
			};
			if(pos == ((len / 2) - 1) and: { c > 0.5 }) { var g = 0.5 * ramp.(c, 0.5, 1);
				out.addAll(riser.(x, 1).collect { |n| n ++ (amp: n.amp * g, g: n.g * g) }) };
			// the dub siren: a sine wobbling on a slow vibrato, sliding up over each half bar, into the echo
			if(c > 0.75 and: { pos >= (len / 2) } and: { (s16 % 8) == 0 } and: { ce.rand(b + 0.19) < 0.5 }) {
				out.add(syn.(\sine, 77 + (5 * (s16 / 8)), 0.12 * ramp.(c, 0.75, 1), lp ++ (hold: 7, vib: 5.5, vibmod: 0.6, penv: -5, pd: 0.5,
					ps: 0.001, pan: 0.3 + (0.4 * (s16 / 8))) ++ adsr.(0.05, nil, 1, 0.4))) };
			r = rise.(t);
			r !? { out.addAll(riser.(r, 1.2)) };
			out.reject { |n| n.amp <= 0 }
		};
	}.value;
}
)
)
