// TRACK 001 GROOVE — SuperCollider port of tracks/house/80s/001-groove/001-groove.strudel (80s groove house on D,
// 124 BPM: octave bass, 7th chords on the off-beat, string swipes, a short sung hook; acid line, breakbeat, electro
// cowbell and rave stabs). Same controller layout as the Strudel track: Mode 1 = foundation (plain CCs), Mode 2 =
// colour (CC + 48), column 8 global on both, the Launchkey MK4 25 optional. Ported 1:1 (see sc/PORTING.md, 001 / 002).
// Column 8's fader is Master in name but not a volume: more low end, punch and drive on kick and bass (as 016's Wumms),
// so there is no master volume (the strips' master is 1). Level (faders, mod wheel) and Master act from the next note,
// as in Strudel; Space, echo, Fog, Thin and Tension act at once, also on sounding notes (Tension also brings the pad in
// live); Brightness acts at once on the long sounds (pad, strings, Launchkey keys), on the short ones from the next
// note; pattern buttons switch at the next bar.
// The @ tags below are read by the web UI (sc/ui): column names, and each control's name | what it does.
// @layout Track 001 — 80s groove house
// @mode 16 Mode 1 — Foundation (beat + bass) · same CCs as Mode 16
// @col 16:8 8 Global
// @col 16:1 1 Kick
// @col 16:2 2 Snare
// @col 16:3 3 Bass
// @col 16:4 4 Acid
// @col 16:5 5 Electro
// @col 16:6 6 Hats
// @col 16:7 7 Break
// @mode 2 Mode 2 — Colour (chords + hooks)
// @col 2:1 1 Chords
// @col 2:2 2 Pad
// @col 2:3 3 Arp
// @col 2:4 4 Hook
// @col 2:5 5 Strings
// @col 2:6 6 Rave
// @col 2:7 7 FX
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | density: pad in, echo, reverb; the end adds a snare roll.
// @ctl g.fader Master | more low end, punch and drive.
// @ctl g.b1 Chapter | mood: boogie → Italo → rave, at the next bar.
// @ctl g.b2 Break | kick and bass out; press again: back on the one.
// @ctl 16:1.k1 Brightness | dull ↔ bright.
// @ctl 16:1.k2 Space | dry ↔ room.
// @ctl 16:1.k3 Punch | soft body ↔ hard 909 click.
// @ctl 16:1.fader Level | the kick, on every beat.
// @ctl 16:1.b1 Pattern | four on the floor → skip into the one → half time.
// @ctl 16:1.b2 Drop out | kick pauses while held.
// @ctl 16:2.k1 Brightness | dull ↔ bright.
// @ctl 16:2.k2 Space | dry ↔ gated room.
// @ctl 16:2.k3 Gate | short tail ↔ long gated tail.
// @ctl 16:2.fader Level | backbeat on 2 and 4. Also the level of Tension's roll.
// @ctl 16:2.b1 Pattern | gated snare → snare + clap → clap.
// @ctl 16:2.b2 Roll | a snare roll fills in over 2 bars while held.
// @ctl 16:3.k1 Brightness | dull ↔ bright.
// @ctl 16:3.k2 Space | dry ↔ room.
// @ctl 16:3.k3 Length | short plucks ↔ long, legato notes.
// @ctl 16:3.fader Level | octave bass, follows the chords.
// @ctl 16:3.b1 Pattern | octaves → boogie → gallop.
// @ctl 16:3.b2 Octave | one octave up while held.
// @ctl 16:4.k1 Brightness | closed filter ↔ open.
// @ctl 16:4.k2 Space | dry ↔ echo + room.
// @ctl 16:4.k3 Squelch | round ↔ resonant, squelchy accents.
// @ctl 16:4.fader Level | acid line, follows the chords.
// @ctl 16:4.b1 Pattern | roll → sparse → climb.
// @ctl 16:4.b2 Open | the filter opens wide while held.
// @ctl 16:5.k1 Brightness | dull ↔ bright.
// @ctl 16:5.k2 Space | dry ↔ room.
// @ctl 16:5.k3 Complexity | as written ↔ + rimshot ghosts.
// @ctl 16:5.fader Level | cowbell and electro toms.
// @ctl 16:5.b1 Pattern | cowbell → toms → both.
// @ctl 16:5.b2 Fill | a tom run down over the bar while held.
// @ctl 16:6.k1 Brightness | dull ↔ bright.
// @ctl 16:6.k2 Space | dry ↔ room.
// @ctl 16:6.k3 Swing | straight ↔ swung 16ths.
// @ctl 16:6.fader Level | closed and open hats. Keep playing in the break.
// @ctl 16:6.b1 Pattern | off-beat → disco → rave.
// @ctl 16:6.b2 Open | open hats ring long on every off-beat while held.
// @ctl 16:7.k1 Brightness | dull ↔ bright.
// @ctl 16:7.k2 Space | dry ↔ room.
// @ctl 16:7.k3 Chop | as written ↔ random 32nd stutters.
// @ctl 16:7.fader Level | breakbeat layer. Keep playing in the break.
// @ctl 16:7.b1 Pattern | two-step → funk → choppy.
// @ctl 16:7.b2 Stutter | the last beat repeats in 32nds while held.
// @ctl 2:1.k1 Brightness | dull ↔ bright.
// @ctl 2:1.k2 Space | dry ↔ room.
// @ctl 2:1.k3 Length | short stabs ↔ long chords.
// @ctl 2:1.fader Level | the chords.
// @ctl 2:1.b1 Chords | next of 6 progressions, for everybody.
// @ctl 2:1.b2 Rhythm | off-beat → boogie → held, at the next bar.
// @ctl 2:2.k1 Brightness | dull ↔ bright.
// @ctl 2:2.k2 Space | dry ↔ hall.
// @ctl 2:2.k3 Movement | still ↔ the filter sweeps slowly.
// @ctl 2:2.fader Level | the pad; Tension brings it in.
// @ctl 2:2.b1 Pattern | 7 → 9 → sus → fifths, at the next bar.
// @ctl 2:2.b2 Echo throw | long echo on the pad while held.
// @ctl 2:3.k1 Brightness | dull ↔ bright.
// @ctl 2:3.k2 Space | dry ↔ echo + room.
// @ctl 2:3.k3 Length | short plucks ↔ longer notes.
// @ctl 2:3.fader Level | arpeggio, follows the chords.
// @ctl 2:3.b1 Pattern | up → up-down → octaves → Italo.
// @ctl 2:3.b2 Octave | one octave up while held.
// @ctl 2:4.k1 Brightness | dull ↔ bright.
// @ctl 2:4.k2 Space | dry ↔ echo + room.
// @ctl 2:4.k3 Vibrato | none ↔ wide, slow vibrato.
// @ctl 2:4.fader Level | the hook.
// @ctl 2:4.b1 Pattern | next of 4 hooks.
// @ctl 2:4.b2 Echo throw | long echo on the hook while held.
// @ctl 2:5.k1 Brightness | dull ↔ bright.
// @ctl 2:5.k2 Space | dry ↔ hall.
// @ctl 2:5.k3 Swipe | none ↔ a swipe every 4 bars ↔ every 2 bars.
// @ctl 2:5.fader Level | the strings.
// @ctl 2:5.b1 Pattern | held → stabs → octave line.
// @ctl 2:5.b2 Swipe | a swipe at the end of every bar while held.
// @ctl 2:6.k1 Brightness | dull ↔ bright.
// @ctl 2:6.k2 Space | dry ↔ echo + room.
// @ctl 2:6.k3 Drive | clean ↔ driven.
// @ctl 2:6.fader Level | rave stab, follows the chords.
// @ctl 2:6.b1 Pattern | rave → call → off-beat.
// @ctl 2:6.b2 Ratchet | the stab repeats in quick 16ths while held.
// @ctl 2:7.k1 Brightness | dull ↔ bright.
// @ctl 2:7.k2 Space | dry ↔ room.
// @ctl 2:7.k3 Complexity | riser + tail ↔ + rising saw ↔ + mid-phrase sweep.
// @ctl 2:7.fader Level | risers and tails at the phrase changes.
// @ctl 2:7.b1 Pattern | phrase of 8 → 16 → 4 bars.
// @ctl 2:7.b2 Riser | a riser by hand, over 4 bars while held.
// @lk level Keys Level | mod wheel: volume of the keys.
// @lk k1 Brightness | dull ↔ bright; harder keys brighter.
// @lk k2 Piano | off → piano → Rhodes → off.
// @lk k3 Organ | off → organ B3 → M1 → off.
// @lk k4 Mallets | off → vibraphone → marimba → off.
// @lk k5 Length | short notes ↔ long.
// @lk k6 Space | a little air ↔ room.
// @lk k7 Echo | dry ↔ long echo.
// @lk k8 Pad Fog | drum pads: clear ↔ muffled, like the global Fog.
(
// the Launchkey's keys: the shared keys of 008 / 009 / 010 / 016 (sc/lib/lkkeys.scd)
var lkKeysLib = (~ce.root +/+ "lib/lkkeys.scd").load;
var bpm = 124, beat = 60 / bpm;
// ---------------------------------------------------------------------------------------------------------
// CC numbers of column n (1-8): row 1-3 knobs, fader, buttons. Mode 1 = plain, Mode 2 = + 48.
var col = { |n, plus = 0| (bright: 12 + n + plus, space: 20 + n + plus, char: 28 + n + plus, level: 4 + n + plus,
	btn: 36 + n + plus, btn2: 44 + n + plus) };
var jojo = { |n| col.(n) }, jonas = { |n| col.(n, 48) };
var glob = col.(8);   // column 8 (global) answers on its Mode 1 and Mode 2 CCs: aliases below

// ---------------------------------------------------------------------------------------------------------
// MOODS (Chapter, global button 1) — all on D, so a switch keeps the root and only the colour changes
var moods = [(name: "Boogie", steps: [0, 2, 3, 5, 7, 9, 10]),   // D dorian: Dm7 – G7, the disco / boogie colour
	(name: "Italo", steps: [0, 2, 3, 5, 7, 8, 10]),              // D minor: the Italo-disco night
	(name: "Rave", steps: [0, 1, 3, 5, 7, 8, 10])];              // D phrygian: tense, the rave peak
// Strudel's n(deg).scale('D<oct>:<mood>'): the degree in the mood's scale from D<oct>, octaves wrap (also below)
var degMidi = { |deg, oct, mood| var st = deg.ceil.asInteger;
	(12 * (oct + 1)) + 2 + moods[mood].steps[st % 7] + (12 * (st / 7).floor) };
// HARMONY — chord roots as scale degrees (0 = D), one chord per 2 bars, 4 chords = 8 bars (chords button 1)
var progs = [[0, 0, 3, 3], [0, 1, 0, 1], [0, -1, -2, -1], [0, -2, -1, 0], [3, 4, 0, 0], [0, 0, 0, 0]];
var progNames = ["i–IV", "i–ii", "i–VII–VI", "i–VI–VII", "iv–v–i", "Vamp"];
// a mini-notation string (Strudel's, 1:1) as a table: 16th of the period → [[offset in the 16th, length in 16ths, value]]
var table = { |str| var m = ~ce.mini(str), t = Dictionary[];
	m.events.do { |e| var p = e[0] * 16, k = (p + 1e-6).floor.asInteger; t[k] = (t[k] ? []).add([p - k, e[1] * 16, e[2]]) };
	(period: (m.period * 16).round.asInteger, steps: t) };
// the events of a table that start in 16th k
var eventsAt = { |tb, k| tb.steps[k % tb.period] ? [] };
var name2midi = { |nm| var m = nm.findRegexp("^([a-g])(b|#)?(-?[0-9])$");
	(12 * (m[3][1].asInteger + 1)) + (c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11)[m[1][1].asSymbol]
	+ (m[2][1] == "#").binaryValue - (m[2][1] == "b").binaryValue };
var ramp = { |v, from, to| ((v - from) / (to - from)).clip(0, 1) };
var dB = { |x| 10 ** (x / 20) };
// Strudel swingBy(x, 8): an event in the second half of its 8th comes x 16ths later (pos = its onset in 16ths)
var swingAt = { |pos, x| if(((pos / 2) % 1) >= (0.5 - 1e-6)) { x } { 0 } };
var beatNames = ["Beat on", "Beat off"];
var rhythms = [["Off-beat", "[~ x]*4"], ["Boogie", "~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~ ~"], ["Held", "x"]];

(
name: "001-groove",
bpm: bpm,
// no master volume: column 8's fader (Master) drives kick and bass, read per note
global: (fog: glob.bright, thin: glob.space, tension: glob.char),
// Tension's echo: up to 0.4 over the first half of the knob (Strudel tensionEcho)
tensionEchoAmt: 0.4,
// column 8 works on both pages: its Mode 2 CCs (+ 48) write the same buses as its Mode 1 CCs (last moved wins)
aliases: [\bright, \space, \char, \level, \btn, \btn2].collect { |r| (glob[r] + 48) -> glob[r] }.asDict,
// web UI: the head line (chapter, chord rhythm, break) and column 8's buttons
uiHead: { |self, ce|
	var pend = { |now, next| if(now == next) { [now] } { [now, next] } };
	[["Chapter"] ++ pend.("D " ++ moods[self.mood.now].name, "D " ++ moods[self.mood.pending].name),
	 ["Rhythm"] ++ pend.(rhythms[self.rhythm.now][0], rhythms[self.rhythm.pending][0]),
	 ["Break"] ++ pend.(beatNames[self.breakL.now], beatNames[self.breakL.pending])]
},
uiGlobal: { |self, ce| (b1: ["D " ++ moods[self.mood.now].name, "D " ++ moods[self.mood.pending].name],
	b2: [beatNames[self.breakL.now], beatNames[self.breakL.pending]], b2on: self.breakL.pending == 1) },
// Effect buses (Strudel orbits). Orbit 1 = drums and bass: small dry room (size 1.4), short dotted-8th slap.
// Orbit 2 = Jonas' colour: a hall (3.5), dotted-8th echo. Orbit 3 = the snare's gated room: short and dense (0.9).
// Impulse responses measured from superdough (tools/sc-port/reverb-ir.mjs).
orbits: (1: (ir: "ir/orbit-1.4.wav", delay: [0.75 * beat, 0.3]), 2: (ir: "ir/orbit-3.5.wav", delay: [0.75 * beat, 0.45]),
	3: (ir: "ir/orbit-0.9.wav", delay: [0.25 * beat, 0.2])),
// state buses: room and echo amounts the language derives from knobs (columns whose Space is scaled, echo throws)
states: (snRoom: 0.9 * 0.15, padRoom: 0.9 * 0.3, padEcho: 0, hookEcho: 0, strRoom: 0.9 * 0.25, fxRoom: 0.9 * 0.3,
	lkLevel: 0, lkBright: 0, lkRoom: 0.9 * 0.1, lkEcho: 0),
// map buses (server side, follow the knob at once): Tension brings the pad in (30 % → full over its first half)
maps: (padIn: (ccs: [glob.char], fn: { |t| 0.3 + (0.7 * (t / 0.5).clip(0, 1)) })),
// samples the drum stems play (the files Strudel plays: tidal-drum-machines, see sc/samples/CREDITS.md)
samples: ["tr909/bd-01.wav", "tr909/sd-00.wav", "tr909/cp-00.wav", "tr909/rim-00.wav", "tr909/hh-00.wav", "tr909/oh-00.wav",
	"tr808/cb-00.wav",
	// the Launchkey's drum pads (as 016): the spoken samples, drum-machine one-shots, Dirt-Samples
	"voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac", "voice/plaenterwald.flac",
	"voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac", "voice/the_evening_does_not_end.flac", "voice/in_the_vast.flac",
	"tr909/lt-00.wav", "tr909/cr-00.wav", "tr808/sh-00.wav", "dirt/space-00.wav", "dirt/wind-00.wav"] ++ ~ce.lkKeysFiles,

stems: [
	// MODE 1 / 1 KICK — a tight 909 kick with a short sine body on D, four on the floor; Master: louder, longer, driven
	(name: \kick, sounds: [\sdSynthMod, \sdSampleMod], level: jojo.(1).level, space: jojo.(1).space, orbit: 1, thin: false),
	// MODE 1 / 2 SNARE — the 80s gated snare on 2 and 4 (909 snare, a noise tail cut off hard, a triangle thump) in a
	// small dense room (orbit 3, Space scaled 0.15 … 0.85); rolls on button 2 and from Tension
	(name: \snare, sounds: [\sdSample, \sdNoise, \sdSynthMod], level: jojo.(2).level, roomR: \snRoom, orbit: 3, trim: 1.5, thin: false),
	// MODE 1 / 3 BASS — the disco octave bass: saw + square through a filter envelope, a sine an octave below
	(name: \bass, sounds: [\sdSynthMod], level: jojo.(3).level, space: jojo.(3).space, orbit: 1, trim: 0.67, thin: false),
	// MODE 1 / 4 ACID — a 303-style line: a resonant saw in 16ths, accents open the filter, no slides
	(name: \acid, sounds: [\sdSynthMod], level: jojo.(4).level, space: jojo.(4).space, orbit: 1, echo: 0.25, trim: 1.5, thin: false),
	// MODE 1 / 5 ELECTRO — 808 cowbell and Simmons-style synth toms (a sine dropping in pitch, a little skin noise)
	(name: \elec, sounds: [\sdSample, \sdSynthMod, \sdNoise], level: jojo.(5).level, space: jojo.(5).space, orbit: 1, trim: 1.95, thin: false),
	// MODE 1 / 6 HATS — 909 hats: the house off-beat open hat and closed 16ths, swung by row 3
	(name: \hats, sounds: [\sdSample], level: jojo.(6).level, space: jojo.(6).space, orbit: 1, trim: 0.35, thin: false),
	// MODE 1 / 7 BREAK — a breakbeat under the four on the floor: syncopated kick, snare with ghost notes, 8th hats
	(name: \brk, sounds: [\sdSample], level: jojo.(7).level, space: jojo.(7).space, orbit: 1, trim: 0.63, thin: false),
	// MODE 2 / 1 CHORDS — Juno-like 7th chords (two saws 0.1 apart, a square), off-beat / boogie / held (button 2)
	(name: \chords, sounds: [\sdSynthMod], level: jonas.(1).level, space: jonas.(1).space, orbit: 2, thin: false),
	// MODE 2 / 2 PAD — an 80s chorus pad (supersaw, slow attack); Tension brings it in (the map padIn on the strip, at
	// once); echo throw on button 2 (no Tension echo: Strudel's pad has none)
	(name: \pad, sounds: [\sdSupersaw], level: jonas.(2).level, roomR: \padRoom, echoSend: \padEcho, tensionEcho: false,
		orbit: 2, trim: \padIn, thin: false),
	// MODE 2 / 3 ARP — the Italo-disco arpeggio: 16ths over the chord, a plucked square and saw through the echo
	(name: \arp, sounds: [\sdSynthMod], level: jonas.(3).level, space: jonas.(3).space, orbit: 2, echo: 0.3, thin: false),
	// MODE 2 / 4 HOOK — the playful top line: square + triangle an octave up, vibrato on row 3, echo throw
	(name: \hook, sounds: [\sdSynthMod], level: jonas.(4).level, space: jonas.(4).space, echoSend: \hookEcho, orbit: 2, thin: false),
	// MODE 2 / 5 STRINGS — disco strings (supersaw + a saw an octave up): held chord, stabs or octave line, swipes
	(name: \strings, sounds: [\sdSupersaw, \sdSynthMod], level: jonas.(5).level, roomR: \strRoom, orbit: 2, trim: 0.9, thin: false),
	// MODE 2 / 6 RAVE STAB — three detuned saws and a square an octave down, filter snapping shut, Drive on row 3
	(name: \rave, sounds: [\sdSynthMod], level: jonas.(6).level, space: jonas.(6).space, orbit: 2, echo: 0.2, thin: false),
	// MODE 2 / 7 FX — 016's FX: a noise riser in the last bar of each phrase, a falling tail + low boom (on D) after it
	(name: \fx, sounds: [\sdNoise, \sdSynthMod], level: jonas.(7).level, roomR: \fxRoom, orbit: 2, trim: 0.4, thin: false),
	// LAUNCHKEY MK4 25 — as 016: keys = Jonas' keys of 009 (orbit 2, mod wheel = level); drum pads: 16 one-shots
	// (orbit 1, each lane a shot's own room / echo). No Tension echo (Strudel gives none), no master (as Strudel).
	(name: \lk, sounds: ~ce.lkKeysSounds ++ [\sdSampleMod, \sdSynthMod], level: \lkLevel, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \shots, orbit: 1, level: 1.0, roomR: 0.3), (name: \lt, orbit: 1, level: 1.0, roomR: 0.5),
			(name: \rim, orbit: 1, level: 1.0, roomR: 0.3, echoSend: 0.4), (name: \orch, orbit: 1, level: 1.0, roomR: 0.6),
			(name: \space, orbit: 1, level: 1.0, roomR: 0.9), (name: \wind, orbit: 1, level: 1.0, roomR: 0.8)]),
],

// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these), the same as 016's. Mod wheel (CC 1) = keys level,
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
		// drum pads 36-51 (Drum mode): the spoken samples (left half), drum one-shots, an 80s orchestra hit, Dirt-Samples
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
			(orch: true, lane: \orch),
			(file: "tr909/oh-00.wav", tag: "rolandtr909_oh", rate: 0.9, hp: 3000),
			(file: "tr909/cr-00.wav", tag: "rolandtr909_cr", rate: -0.6, gain: 0.54),
			(file: "tr808/sh-00.wav", tag: "rolandtr808_sh", rate: 0.8, gain: 1.58),
			(file: "dirt/space-00.wav", tag: "space", rate: 0.5, lane: \space, gain: 0.65),
			(file: "dirt/wind-00.wav", tag: "wind", rate: 0.5, lane: \wind, gain: 1.36),
		];
		// gain: the shot's own, else superdough's default 0.8 (the log keeps Strudel's notation: gain × velocity)
		var i = (note - 36) % 16, sh = shots[i], g = (sh[\gain] ? 0.8) * vel, gl = (sh[\gain] ? 1) * vel, now = thisThread.seconds;
		// the low-pass: knob 8 (18 kHz → 800 Hz) × Fog / Tension at the hit
		var tv = (0.06 ** ce.val(glob.bright)) * (1 + (1.5 * ce.val(glob.char)));
		var cut = ((18000 * ((800 / 18000) ** k.(8))) * tv).clip(80, 18000);
		var base = (lpOn: 1, lo: cut, hi: cut, tone: 1, thinF: thin, lane: sh[\lane] ? \shots, tag: sh[\tag]);
		// a shot with `once` ignores new hits until it has played out
		ce.lkOnce = ce.lkOnce ? ();
		if(sh[\once].notNil and: { (ce.lkOnce[i] ? -1) > now }) { [] } {
			sh[\once] !? { ce.lkOnce[i] = now + sh[\once] };
			if(sh[\orch] == true) {
				// 80s orchestra hit: a short, bright D minor chord (D2 to D4) of saws and a square over a sine thump on D2
				var env = ce.sdADSR(0.002, 0.35, 0, 0.3);
				var common = base ++ (hold: nl * 16, shape: 0.3, a: env[0], d: env[1], s: env[2], r: env[3]);
				[[2, 38, 0.35, -1], [2, 50.1, 0.3, 0.35], [2, 53, 0.25, 0.65], [2, 57, 0.25, 0.4], [3, 62, 0.15, -1]].collect { |x|
					ce.note(\sdSynthMod, common ++ (wave: x[0], freq: x[1].midicps, amp: x[2] * vel, pan: x[3],
						tag: ["", "", "sawtooth", "square"][x[0]], g: x[2] * vel, midi: x[1])) }
				++ [ce.note(\sdSynthMod, common ++ (wave: 0, freq: 38.midicps, amp: 0.7 * vel, penv: 12, pa: 0.001, pd: 0.05, ps: 0.001, pr: 0.01,
					d: 0.3, tag: "sine", g: 0.7 * vel, midi: 38))]
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
	"Orch hit", "Open hat", "Crash reverse", "Shaker", "Space", "Wind"],

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
	// Master (column 8 fader), read per note as Strudel's withMaster does
	var master = { ce.val(glob.level) };
	// 0 → 1 over `bars` while a button is held, in steps per bar (Strudel heldRamp reads the button per bar); nil = not held
	var heldRamp = { |cc, bars| var st = ();
		{ |t| if(ce.held(cc)) { st[\from] = st[\from] ? t.floor; ((t.floor - st[\from]) / bars).clip(0, 1) } { st[\from] = nil; nil } } };
	// room / echo amounts of the columns whose Space is scaled, set from the knob the moment it moves (state buses)
	var spaceState = { |cc, name, fn| ce.onCC(cc, { |v, send| ce.setState(name, fn.(v), send) }) };
	// echo throw (button 2 held): a long echo (0.8) on a dry column (Strudel throwEcho)
	var throwState = { |cc, name| ce.onCC(cc, { |v, send| ce.setState(name, if(v > 0.5) { 0.8 } { 0 }, send) }) };

	// GLOBAL: Chapter (mood, next bar), Break (next bar)
	self.mood = ce.latch(1, 0, { |i| ce.status("Chapter", moods[i].name); ce.uiPush });
	ce.cycleButton(glob.btn, moods.size, { |s| self.mood.pending = s; ce.status("Chapter (next)", moods[s].name) });
	self.breakL = ce.latch(1, 0, { |i| ce.status("Break", i); ce.uiPush });
	ce.cycleButton(glob.btn2, 2, { |s| self.breakL.pending = s });
	self.beatOn = { |self, b| self.breakL.atBar(b) == 0 };
	self.tension = glob.char;

	// HARMONY: the chords' button 1 picks the progression (next bar); everybody follows its root
	self.chordVar = ce.change(jonas.(1).btn, progs.size, "Chords", progNames);
	self.rootAt = { |self, b| progs[self.chordVar.atBar(b)][(b / 2).floor % 4] };
	self.moodAt = { |self, b| self.mood.atBar(b) };
	// the chord tones of a shape (scale degrees above the root) in octave oct
	self.chordAt = { |self, b, shape, oct| shape.collect { |d| degMidi.(d + self.rootAt(b), oct, self.moodAt(b)) } };
	// chords button 2: the rhythm, at the next bar
	self.rhythm = ce.latch(1, 0, { |i| ce.status("Rhythm", rhythms[i][0]); ce.uiPush });
	ce.cycleButton(jonas.(1).btn2, rhythms.size, { |s| self.rhythm.pending = s });

	// MODE 1 / 1 KICK
	{
		var kc = jojo.(1);
		var kicks = ["x*4", "<x*4 [x x x [x ~ ~ x]]>", "x ~ x ~"].collect(table);
		self.kickVar = ce.change(kc.btn, 3, "Kick", ["4/4", "Skip", "Half"]);
		stem.(\kick).notes = { |k|
			var b = bar.(k), out = List[];
			if(self.beatOn(b) and: { ce.held(kc.btn2).not }) {
				eventsAt.(kicks[self.kickVar.atBar(b)], k).do { |e|
					var p = ce.val(kc.char), w = master.(), gw = 0.9 * dB.(1.5 * w);
					// the whole kick: low-pass from Brightness × Fog / Tension, Master drives it (shape)
					var lp = (lpOn: 1, bright: ce.val(kc.bright), lo: 600, hi: 9000, tone: tone, shape: 0.25 * w, at: e[0], hold: e[1]);
					out.add(smp.("tr909/bd-01.wav", "RolandTR909_bd:0", (0.45 + (0.4 * p)) * gw, lp ++ (hold: -1) ++ adsr.(nil, 0.5, 0, nil), \sdSampleMod));
					// the body: a sine on D2 with a pitch drop; Master makes it longer and drop further
					out.add(syn.(\sine, 38, (0.75 - (0.25 * p)) * gw, lp ++ (penv: 14 + (6 * w), pd: 0.05)
						++ adsr.(0.002, 0.28 * (1 + (0.4 * w)), 0, 0.05)));
				}
			};
			out
		};
	}.value;

	// MODE 1 / 2 SNARE (keeps playing in the break)
	{
		var sc = jojo.(2);
		var gatedHits = table.("~ x ~ x"), clapHits = table.("~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ x");
		var rise = heldRamp.(sc.btn2, 2);
		spaceState.(sc.space, \snRoom, { |s| 0.9 * (0.15 + (0.7 * s)) });
		self.snareVar = ce.change(sc.btn, 3, "Snare", ["Gated", "Snare + clap", "Clap"]);
		stem.(\snare).notes = { |k|
			var b = bar.(k), t = t16.(k), v = self.snareVar.atBar(b), out = List[], r, tr;
			// the low-pass: Brightness × Fog only (Tension does not open it, Strudel high: true)
			var lp = (lpOn: 1, bright: ce.val(sc.bright), lo: 1500, hi: 12000, tone: fog);
			var gate = 0.2 + (0.45 * ce.val(sc.char));
			var roll = { |amount, g| if(ce.rand(t) >= (0.85 - (0.75 * amount))) {
				out.add(smp.("tr909/sd-00.wav", "RolandTR909_sd:0", g * (0.15 + (0.85 * amount * amount)), lp ++ adsr.(nil, 0.12, 0, nil))) } };
			if(v < 2) { eventsAt.(gatedHits, k).do { |e|
				// the 909 snare, a white-noise tail cut off by Gate (Strudel clip), a triangle thump on D3
				out.add(smp.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.8, lp ++ (at: e[0]) ++ adsr.(nil, 0.3, 0, nil)));
				out.add(noise.(1, 0.3, lp ++ (at: e[0], hold: e[1] * gate, hp: 900, bp: 3500, bpq: 0.6) ++ adsr.(0.002, 0.06, 0.4, 0.006)));
				out.add(syn.(\triangle, 50, 0.35, lp ++ (at: e[0], hold: e[1], penv: 5, pd: 0.03) ++ adsr.(nil, 0.09, 0, nil)));
				// Snare + clap: the clap 4 ms later (0.004 cycles), at gain 0.5
				if(v == 1) { out.add(smp.("tr909/cp-00.wav", "RolandTR909_cp:0", 0.5, lp ++ (at: e[0] + (0.004 * 16), pan: 0.47))) };
			} };
			if(v == 2) { eventsAt.(clapHits, k).do { |e| out.add(smp.("tr909/cp-00.wav", "RolandTR909_cp:0", 0.75, lp ++ (at: e[0], pan: 0.47))) } };
			// Roll (button 2): 16ths filling in and getting louder over 2 bars
			r = rise.(t);
			r !? { roll.(r, 0.5) };
			// Tension's roll (last fifth of the knob), also in the break
			tr = ramp.(ce.val(self.tension), 0.8, 1);
			if(tr > 0) { roll.(tr, 0.45) };
			out
		};
	}.value;

	// MODE 1 / 3 BASS
	{
		var bc = jojo.(3);
		var lines = ["[0 7]*8", "0 ~ ~ 0 7 ~ 0 ~ ~ 0 ~ 7 4 ~ 6 ~", "[0 ~ 7 7]*4"].collect(table);
		self.bassVar = ce.change(bc.btn, 3, "Bass", ["Octaves", "Boogie", "Gallop"]);
		stem.(\bass).notes = { |k|
			var b = bar.(k), out = List[];
			if(self.beatOn(b)) {
				eventsAt.(lines[self.bassVar.atBar(b)], k).do { |e|
					var m = degMidi.(e[2] + self.rootAt(b), 2, self.moodAt(b)) + if(ce.held(bc.btn2)) { 12 } { 0 };
					var len = 0.12 + (0.3 * ce.val(bc.char)), w = master.(), gw = dB.(2 * w);
					var lp = (lpOn: 1, bright: ce.val(bc.bright), lo: 300, hi: 3500, tone: tone, shape: 0.1 + (0.25 * w), at: e[0], hold: e[1]);
					var env = lp ++ (lpq: 5, lpenv: 2.5, la: 0.002, ld: 0.09, ls: 0.2, lr: 0.01) ++ adsr.(0.003, len, 0.15, 0.05);
					out.add(syn.(\sawtooth, m, 0.32 * gw, env));
					out.add(syn.(\square, m, 0.18 * gw, env));
					out.add(syn.(\sine, m - 12, 0.35 * gw, lp ++ adsr.(0.004, len, 0.3, 0.05)));
				}
			};
			out
		};
	}.value;

	// MODE 1 / 4 ACID (keeps playing in the break)
	{
		var ac = jojo.(4);
		var lines = ["0 0 7 0 ~ 0 2 0 0 ~ 7 0 4 ~ 0 2", "0 ~ ~ 0 ~ ~ 7 ~ ~ 0 ~ ~ 2 ~ 0 ~",
			"<[0 0 7 0 2 0 3 0 0 ~ 7 0 4 0 3 2] [0 0 7 0 2 0 3 0 7 ~ 8 7 4 3 2 1]>"].collect(table);
		var vels = [1, 0.55, 0.8, 0.55];   // Strudel velocity "[1 0.55 0.8 0.55]*4"
		self.acidVar = ce.change(ac.btn, 3, "Acid", ["Roll", "Sparse", "Climb"]);
		stem.(\acid).notes = { |k|
			var b = bar.(k), out = List[];
			eventsAt.(lines[self.acidVar.atBar(b)], k).do { |e|
				var m = degMidi.(e[2] + self.rootAt(b), 2, self.moodAt(b)), q = ce.val(ac.char);
				// the low-pass: Brightness 250 … 3000 Hz, × 3 while Open is held, × a slow sine (one cycle in 8 bars, read
				// at the bar start), then × Fog / Tension, kept within 80 Hz … 18 kHz
				var f = if(ce.held(ac.btn2)) { 3 } { 1 } * (0.7 + (0.7 * ce.sine(b / 8)));
				out.add(syn.(\sawtooth, m, 0.32 * vels[k % 4], (lpOn: 1, bright: ce.val(ac.bright), lo: 250 * f, hi: 3000 * f, tone: tone,
					lpq: 6 + (16 * q), lpenv: 2 + (3 * q), la: 0.002, ld: 0.12, ls: 0, lr: 0.01, shape: 0.3, hp: 140, at: e[0], hold: e[1])
					++ adsr.(0.002, 0.16, 0.2, 0.04)));
			};
			out
		};
	}.value;

	// MODE 1 / 5 ELECTRO (keeps playing in the break)
	{
		var ec = jojo.(5);
		var cow = table.("~ ~ x ~ ~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~");
		var tomsA = table.("<[~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~] [~ ~ ~ ~ ~ ~ ~ ~ ~ ~ d3 ~ a2 ~ f2 ~]>");
		var tomsB = table.("<[~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~] [~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ d3 a2 ~ f2]>");
		var rims = table.("~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~"), fill = table.("d3 ~ c3 ~ a2 ~ g2 ~ f2 ~ d2 ~ d2 ~ ~ ~");
		self.elecVar = ce.change(ec.btn, 3, "Electro", ["Cowbell", "Toms", "Both"]);
		stem.(\elec).notes = { |k|
			var b = bar.(k), v = self.elecVar.atBar(b), c = ce.val(ec.char), out = List[];
			var lp = (lpOn: 1, bright: ce.val(ec.bright), lo: 1200, hi: 10000, tone: fog);
			var cowbell = { |e| out.add(smp.("tr808/cb-00.wav", "rolandtr808_cb", 0.45, lp ++ (at: e[0], pan: 0.62) ++ adsr.(nil, 0.25, 0, nil))) };
			// a Simmons-style tom: a sine dropping 7 semitones + a click of white noise through a band-pass, left of centre
			var tom = { |e, g| var m = name2midi.(e[2]);
				out.add(syn.(\sine, m, g, lp ++ (at: e[0], hold: e[1], penv: 7, pd: 0.12, pan: 0.38) ++ adsr.(0.001, 0.28, 0, 0.05)));
				out.add(noise.(1, g * 0.15, lp ++ (at: e[0], hold: e[1], bp: 1800, pan: 0.38, midi: m) ++ adsr.(0.001, 0.02, 0, nil))) };
			if(v != 1) { eventsAt.(cow, k).do(cowbell) };
			if(v == 1) { eventsAt.(tomsA, k).do { |e| tom.(e, 0.5) } };
			if(v == 2) { eventsAt.(tomsB, k).do { |e| tom.(e, 0.45) } };
			if(c > 0) { eventsAt.(rims, k).do { |e| out.add(smp.("tr909/rim-00.wav", "RolandTR909_rim:0", c * 0.35, lp ++ (at: e[0], pan: 0.55))) } };
			if(ce.held(ec.btn2)) { eventsAt.(fill, k).do { |e| tom.(e, 0.5) } };
			out
		};
	}.value;

	// MODE 1 / 6 HATS (keep playing in the break)
	{
		var hc = jojo.(6);
		// per pattern: [kind, hits, gain (a number or per 16th of the beat)]
		var pats = [
			[[\open, "[~ x]*4", 0.32], [\closed, "[x ~ ~ x]*4", 0.12]],
			[[\open, "[~ ~ x ~]*4", 0.3], [\closed, "[x x ~ x]*4", [0.2, 0.12, 0, 0.15]]],
			[[\open, "[~ ~ x ~]*4", 0.28], [\closed, "x*16", [0.18, 0.1, 0, 0.13]], [\closed, "[~ ~ ~ ~ ~ ~ ~ [x x]]*2", 0.08]],
		].collect { |p| p.collect { |x| [x[0], table.(x[1]), x[2]] } };
		var heldClosed = table.("[x x ~ x]*4"), heldOpen = table.("[~ oh]*4");
		self.hatVar = ce.change(hc.btn, 3, "Hats", ["Off-beat", "Disco", "Rave"]);
		stem.(\hats).notes = { |k|
			var b = bar.(k), s16 = k % 16, out = List[], sw = 0.3 * ce.val(hc.char);
			// gain × 3 for all, a high-pass at 1800 Hz, the low-pass from Brightness × Fog only
			var lp = (lpOn: 1, bright: ce.val(hc.bright), lo: 8000, hi: 18000, tone: fog, hp: 1800);
			var closed = { |g, at, len| out.add(smp.("tr909/hh-00.wav", "RolandTR909_hh:0", g * 3, lp ++ (pan: 0.68, at: at, hold: len) ++ adsr.(nil, 0.035, 0, 0.02))) };
			var open = { |g, at, len, dec = 0.18, rel = 0.05| out.add(smp.("tr909/oh-00.wav", "RolandTR909_oh:0", g * 3, lp ++ (pan: 0.56, at: at, hold: len) ++ adsr.(nil, dec, 0, rel))) };
			if(ce.held(hc.btn2).not) {
				pats[self.hatVar.atBar(b)].do { |x| eventsAt.(x[1], k).do { |e|
					var g = if(x[2].isArray) { x[2][s16 % 4] } { x[2] }, at = e[0] + swingAt.(s16 + e[0], sw);
					if(g > 0) { if(x[0] == \open) { open.(g, at, e[1]) } { closed.(g, at, e[1]) } } } };
			} {
				// Open (held): closed x x ~ x, the open hat on every off-beat 8th, ringing long; not swung
				eventsAt.(heldClosed, k).do { |e| closed.(0.14, e[0], e[1]) };
				eventsAt.(heldOpen, k).do { |e| open.(0.34, e[0], e[1], 0.45, 0.1) };
			};
			out
		};
	}.value;

	// MODE 1 / 7 BREAK (keeps playing in the break)
	{
		var bk = jojo.(7);
		var kits = [
			["x ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~", "~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~", "~ ~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x"],
			["x ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ x ~ ~", "~ ~ ~ ~ x ~ ~ x ~ x ~ ~ x ~ ~ ~", "~ x ~ ~ ~ ~ x ~ ~ ~ ~ x ~ ~ ~ x"],
			["x ~ ~ x ~ ~ x ~ ~ ~ x ~ ~ ~ ~ ~", "~ ~ ~ ~ x ~ ~ ~ ~ x ~ ~ x ~ x ~", "~ ~ x ~ ~ x ~ ~ ~ ~ ~ x ~ ~ ~ ~"],
		].collect { |kit| kit.collect(table) };
		var hh = table.("[x ~]*8");
		self.brkVar = ce.change(bk.btn, 3, "Break", ["Two-step", "Funk", "Choppy"]);
		stem.(\brk).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, c = ce.val(bk.char), out = List[], kit = kits[self.brkVar.atBar(b)], hits;
			var lp = (lpOn: 1, bright: ce.val(bk.bright), lo: 1000, hi: 12000, tone: tone, pan: 0.5);
			// the kit's hits in this 16th: [file, tag, gain, decay, sustain, high-pass]
			hits = List[];
			if(eventsAt.(kit[0], k).notEmpty) { hits.add(["tr909/bd-01.wav", "RolandTR909_bd:0", 0.5, 0.18, 0, 90]) };
			if(eventsAt.(kit[1], k).notEmpty) { hits.add(["tr909/sd-00.wav", "RolandTR909_sd:0", 0.55, 0.16, 0, 0]) };
			if(eventsAt.(kit[2], k).notEmpty) { hits.add(["tr909/sd-00.wav", "RolandTR909_sd:0", 0.18, 0.06, 0, 0]) };
			if(eventsAt.(hh, k).notEmpty) { hits.add(["tr909/hh-00.wav", "RolandTR909_hh:0", [0.18, 0.1][(s16 / 2).floor % 2], 0.03, nil, 0]) };
			hits.do { |h|
				var note = { |g, at| out.add(smp.(h[0], h[1], g, lp ++ (at: at, hp: h[5]) ++ adsr.(nil, h[3], h[4], nil))) };
				// Stutter (held): the last beat in 32nds (Strudel ply(2) on that beat)
				if(ce.held(bk.btn2) and: { s16 >= 12 }) { note.(h[2], 0); note.(h[2], 0.5) } { note.(h[2], 0) };
				// Chop: half the hits (rand ≥ 0.5) split into two 32nds, each kept with rand ≥ 1 − Chop / 2, at gain 0.6
				if(c > 0 and: { ce.rand(t) >= 0.5 }) { 2.do { |j| if(ce.rand(t + (j / 32)) >= (1 - (0.5 * c))) { note.(0.6, j / 2) } } };
			};
			out
		};
	}.value;

	// MODE 2 / 1 CHORDS — button 1 = the progression for everybody (above), button 2 = the rhythm
	{
		var cc = jonas.(1);
		var tables = rhythms.collect { |r| table.(r[1]) };
		stem.(\chords).notes = { |k|
			var b = bar.(k), out = List[];
			eventsAt.(tables[self.rhythm.atBar(b)], k).do { |e|
				var len = 0.12 + (0.6 * ce.val(cc.char));
				var lp = (lpOn: 1, bright: ce.val(cc.bright), lo: 400, hi: 7000, tone: tone, lpenv: 1.5, la: 0.003, ld: 0.15, ls: 0.4, lr: 0.01,
					at: e[0], hold: e[1]) ++ adsr.(0.004, len, 0.25, 0.12);
				self.chordAt(b, [0, 2, 4, 6], 3).do { |m|
					// two saws 0.1 semitone apart (both at pan 0.3: Strudel's pan(0.3) after superimpose sets both), a square
					out.add(syn.(\sawtooth, m, 0.3, lp ++ (pan: 0.3)));
					out.add(syn.(\sawtooth, m + 0.1, 0.3, lp ++ (pan: 0.3)));
					out.add(syn.(\square, m, 0.17, lp));
				}
			};
			out
		};
	}.value;

	// MODE 2 / 2 PAD — one chord per bar; Tension's share is on the strip (padIn), the log has it in g as Strudel's gain
	{
		var pc = jonas.(2);
		var shapes = [["7", [0, 2, 4, 6]], ["9", [0, 2, 4, 6, 8]], ["Sus", [0, 3, 4, 7]], ["Fifths", [0, 4, 7]]];
		spaceState.(pc.space, \padRoom, { |s| 0.9 * (0.3 + (0.7 * s)) });
		throwState.(pc.btn2, \padEcho);
		self.padVar = ce.change(pc.btn, shapes.size, "Pad", shapes.collect(_[0]));
		stem.(\pad).notes = { |k|
			var b = bar.(k), pin = 0.3 + (0.7 * ramp.(ce.val(self.tension), 0, 0.5)), lp;
			if((k % 16) != 0) { [] } {
				// Brightness acts at once (long notes); Movement sweeps the filter (one cycle in 8 bars, read at the bar start)
				lp = (lpOn: 1, bright: ce.ccMap(pc.bright), lo: 300, hi: 6000, tone: tone,
					cutMul: 1 + (ce.val(pc.char) * 0.8 * sin(2pi * b / 8)), hold: 16) ++ adsr.(0.8, nil, 0.9, 1.6);
				self.chordAt(b, shapes[self.padVar.atBar(b)][1], 3).collect { |m|
					ce.note(\sdSupersaw, (freq: m.midicps, unison: 3, detune: 0.15, spread: 0.8, amp: 0.41, thinF: thin,
						tag: "supersaw", g: 0.41 * pin, midi: m) ++ lp) }
			}
		};
	}.value;

	// MODE 2 / 3 ARP
	{
		var ac = jonas.(3);
		var arps = [["Up", "[0 2 4 6]*4"], ["Up-down", "[0 2 4 7 4 2]*2 0 2 4 7"], ["Octaves", "[0 7]*8"], ["Italo", "[0 7 4 7 2 7 4 7]*2"]];
		var tables = arps.collect { |a| table.(a[1]) };
		self.arpVar = ce.change(ac.btn, arps.size, "Arp", arps.collect(_[0]));
		stem.(\arp).notes = { |k|
			var b = bar.(k), s16 = k % 16, out = List[];
			eventsAt.(tables[self.arpVar.atBar(b)], k).do { |e|
				var m = degMidi.(e[2] + self.rootAt(b), 4, self.moodAt(b)) + if(ce.held(ac.btn2)) { 12 } { 0 };
				// pan "[0.35 0.65]*8": left and right by the 16th the note starts in
				var lp = (lpOn: 1, bright: ce.val(ac.bright), lo: 800, hi: 9000, tone: tone, at: e[0], hold: e[1],
					pan: [0.35, 0.65][(s16 + e[0] + 1e-6).floor.asInteger % 2]) ++ adsr.(0.002, 0.08 + (0.25 * ce.val(ac.char)), 0, 0.05);
				out.add(syn.(\square, m, 0.43, lp));
				out.add(syn.(\sawtooth, m + 0.08, 0.3, lp));
			};
			out
		};
	}.value;

	// MODE 2 / 4 HOOK — on the key, not the chord root: the same tune over every progression
	{
		var hc = jonas.(4);
		var hooks = ["<[~ ~ 4 ~ 4 ~ 2 ~ 4 ~ ~ 5 ~ 4 ~ ~] ~ [~ ~ 4 ~ 4 ~ 2 ~ 4 ~ ~ 7 ~ 6 ~ 4] ~>",
			"<[7 ~ ~ 6 ~ ~ 4 ~ ~ ~ 2 ~ 4 ~ ~ ~] ~ [7 ~ ~ 6 ~ ~ 4 ~ ~ ~ 2 ~ 1 ~ 0 ~] ~>",
			"<[0 ~ 2 ~ 4 ~ ~ ~ 2 ~ 4 ~ 5 ~ 4 ~] ~>",
			"<[~ 4 4 ~ 4 ~ 5 4 ~ ~ 2 ~ ~ ~ ~ ~] [~ 4 4 ~ 4 ~ 5 7 ~ ~ 6 ~ ~ 4 ~ ~]>"].collect(table);
		// the echo: Strudel bus (0.2 × 2 × Space, at most 0.9), 0.8 while the throw is held (Tension's echo stays on top)
		var upd = { |send| ce.setState(\hookEcho, if(ce.held(hc.btn2)) { 0.8 } { (0.4 * ce.val(hc.space)).min(0.9) }, send) };
		[hc.space, hc.btn2].do { |cc| ce.onCC(cc, { |v, send| upd.(send) }) };
		self.hookVar = ce.change(hc.btn, hooks.size, "Hook");
		stem.(\hook).notes = { |k|
			var b = bar.(k), out = List[];
			eventsAt.(hooks[self.hookVar.atBar(b)], k).do { |e|
				var m = degMidi.(e[2], 4, self.moodAt(b));
				var lp = (lpOn: 1, bright: ce.val(hc.bright), lo: 900, hi: 9000, tone: tone, at: e[0], hold: e[1] * 0.9,
					vib: 4.5, vibmod: 0.35 * ce.val(hc.char)) ++ adsr.(0.01, 0.15, 0.55, 0.12);
				out.add(syn.(\square, m, 0.36, lp));
				out.add(syn.(\triangle, m + 12, 0.2, lp));
			};
			out
		};
	}.value;

	// MODE 2 / 5 STRINGS — swipe = a fast scale run (15 notes in the last beat) up to the chord root
	{
		var sc = jonas.(5);
		var stabs = table.("~ ~ x ~ ~ ~ x ~ ~ ~ x ~ ~ ~ x ~");
		var octLine = table.("<[7 ~ ~ ~ 6 ~ ~ ~ 4 ~ ~ ~ ~ ~ ~ ~] [7 ~ ~ ~ 9 ~ ~ ~ 8 ~ 7 ~ ~ ~ ~ ~]>");
		var swipe = table.("~ ~ ~ [-7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 6 7 ~]");
		spaceState.(sc.space, \strRoom, { |s| 0.9 * (0.25 + (0.75 * s)) });
		self.strVar = ce.change(sc.btn, 3, "Strings", ["Held", "Stabs", "Octave"]);
		stem.(\strings).notes = { |k|
			var b = bar.(k), s16 = k % 16, out = List[], c = ce.val(sc.char), every, n;
			// Brightness acts at once (long notes)
			var lp = (lpOn: 1, bright: ce.ccMap(sc.bright), lo: 700, hi: 9000, tone: tone);
			// one string note: a supersaw (2 voices) and a saw an octave up
			var str = { |m, args| out.add(ce.note(\sdSupersaw, (freq: m.midicps, unison: 2, detune: 0.1, spread: 0.7, amp: 0.31, thinF: thin,
				tag: "supersaw", g: 0.31, midi: m) ++ lp ++ args)); out.add(syn.(\sawtooth, m + 12, 0.09, lp ++ args)) };
			var swipeNotes = { eventsAt.(swipe, k).do { |e| str.(degMidi.(e[2] + self.rootAt(b), 4, self.moodAt(b)),
				(at: e[0], hold: e[1]) ++ adsr.(0.005, 0.05, 0.6, 0.08)) } };
			switch(self.strVar.atBar(b),
				0, { if(s16 == 0) { self.chordAt(b, [0, 2, 4], 4).do { |m| str.(m, (hold: 16) ++ adsr.(0.25, nil, 0.9, 0.6)) } } },
				1, { eventsAt.(stabs, k).do { |e| self.chordAt(b, [0, 2, 4], 4).do { |m| str.(m, (at: e[0], hold: e[1]) ++ adsr.(0.01, 0.15, 0.2, 0.15)) } } },
				2, { eventsAt.(octLine, k).do { |e| str.(degMidi.(e[2] + self.rootAt(b), 4, self.moodAt(b)), (at: e[0], hold: e[1]) ++ adsr.(0.05, nil, 0.8, 0.4)) } });
			// Swipe (row 3): every 4 bars (up to half the knob) or every 2 bars, in the last bar; button 2: every bar
			// (both together play the swipe twice, as Strudel's stack does)
			every = if(c <= 0) { 0 } { if(c < 0.5) { 4 } { 2 } };
			if(every > 0 and: { (b % every) == (every - 1) }) { swipeNotes.() };
			if(ce.held(sc.btn2)) { swipeNotes.() };
			out
		};
	}.value;

	// MODE 2 / 6 RAVE STAB — root, third, fifth, octave on three detuned saws and a square an octave down
	{
		var rc = jonas.(6);
		var raves = ["~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ ~ x ~", "<[x ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ ~] ~>", "[~ ~ x ~]*4"].collect(table);
		var ratchet = table.("x*16");
		self.raveVar = ce.change(rc.btn, 3, "Rave Stab", ["Rave", "Call", "Off-beat"]);
		stem.(\rave).notes = { |k|
			var b = bar.(k), out = List[], d = ce.val(rc.char), gd = dB.(-6 * d);
			eventsAt.(if(ce.held(rc.btn2)) { ratchet } { raves[self.raveVar.atBar(b)] }, k).do { |e|
				var lp = (lpOn: 1, bright: ce.val(rc.bright), lo: 600, hi: 8000, tone: tone, lpq: 6, lpenv: 2, la: 0.002, ld: 0.1, ls: 0, lr: 0.01,
					shape: 0.2 + (0.5 * d), at: e[0], hold: e[1]) ++ adsr.(0.002, 0.2, 0, 0.1);
				self.chordAt(b, [0, 2, 4, 7], 4).do { |m|
					[0, 0.12, -0.12].do { |dm| out.add(syn.(\sawtooth, m + dm, 0.125 * gd, lp)) };
					out.add(syn.(\square, m - 12, 0.1 * gd, lp));
				}
			};
			out
		};
	}.value;

	// MODE 2 / 7 FX — the phrase (button 1: 8, 16 or 4 bars): a riser in its last bar, a tail on its first, Complexity
	// adds a rising saw in the last bar (from 0) and a small riser in the middle (from 0.5); button 2 = a riser by hand
	{
		var fc = jonas.(7), lens = [8, 16, 4];
		var rise = heldRamp.(fc.btn2, 4);
		spaceState.(fc.space, \fxRoom, { |s| 0.9 * (0.3 + (0.7 * s)) });
		self.fxVar = ce.change(fc.btn, 3, "FX", ["8 bars", "16 bars", "4 bars"]);
		stem.(\fx).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, x = s16 / 16, len = lens[self.fxVar.atBar(b)], c = ce.val(fc.char);
			var lp = (lpOn: 1, bright: ce.val(fc.bright), lo: 2000, hi: 16000, tone: tone), out = List[], r;
			// riser: pink noise in 16ths through a wide band-pass climbing from 300 Hz (pos 0) to 7.5 kHz (pos 1), swelling
			var riser = { |pos, g| noise.(0, g * (0.1 + (0.9 * pos * pos)), lp ++ (hold: 1, bp: 300 * (25 ** pos), bpq: 1.5,
				pan: 0.3 + (0.4 * ce.sine(2 * t))) ++ adsr.(0.03, nil, 1, 0.12)) };
			if((b % len) == (len - 1)) {
				out.add(riser.(x, 1));
				// the rising saw (its own low-pass is overridden by the column's, as in Strudel)
				if(c > 0) { out.add(syn.(\sawtooth, 50 + (12 * x), ramp.(c, 0, 0.5) * 0.06, lp ++ (hold: 1) ++ adsr.(0.01, nil, 1, 0.05))) };
			};
			if((b % len) == 0) {
				// tail: the noise falling from 6 kHz, fading; a sine boom on D2 that drops an octave
				out.add(noise.(0, 0.6 * ((1 - x) ** 2), lp ++ (hold: 1, bp: 6000 * ((1 / 20) ** x), bpq: 1) ++ adsr.(0.005, nil, 1, 0.2)));
				if(s16 == 0) { out.add(syn.(\sine, 38, 0.45, lp ++ (hold: 16, penv: 12, pd: 0.25) ++ adsr.(0.005, 1.2, 0, 0.3))) };
			};
			if((b % len) == ((len / 2) - 1) and: { c > 0.5 }) { out.add(riser.(x, 0.5) ++ (amp: 0.5 * (0.1 + (0.9 * x * x)) * ramp.(c, 0.5, 1))
				++ (g: 0.5 * (0.1 + (0.9 * x * x)) * ramp.(c, 0.5, 1))) };
			r = rise.(t);
			r !? { out.add(riser.(r, 1.2)) };
			out.reject { |n| n.amp <= 0 }
		};
	}.value;

	// Knob defaults of the Strudel track (live only, as there: Web MIDI): the pad Space 0.5 until the knob is moved.
	// Offline renders (comparisons, tests) start from the scenario's values, as the Node tools do. Set after the
	// columns' control hooks, so the pad's room follows it.
	if(ce.log.isNil) { ce.setCC(70, 0.5, { |m| ce.server.sendMsg(*m) }, true) };
}
)
)
