// TRACK 002 GROOVE — SuperCollider port of tracks/house/80s/002-groove/002-groove.strudel (80s groove house on D,
// 124 BPM, the second version of 001-groove: bass, chords, pad, arp, hook, strings, gated snare and the Launchkey as
// in 001; a groovier rhythm section with ghost kicks, a rolling rumble, swung hats and TR-727 congas; a clean acid,
// a house organ stab, softer FX, less Tension reverb and echo, and a bright mixolydian Sunrise as the third chapter). Same controller layout as the Strudel track: Mode 1 = foundation (plain CCs), Mode 2 =
// colour (CC + 48), column 8 global on both, the Launchkey MK4 25 optional. Ported 1:1 (see sc/PORTING.md, 001 / 002).
// Column 8's fader is Master in name but not a volume: more low end, punch and drive on kick and bass (as 016's Wumms),
// so there is no master volume (the strips' master is 1). Level (faders, mod wheel) and Master act from the next note,
// as in Strudel; Space, echo, Fog, Thin and Tension act at once, also on sounding notes (Tension also brings the pad in
// live); Brightness acts at once on the long sounds (pad, strings, Launchkey keys), on the short ones from the next
// note; pattern buttons switch at the next bar.
// The @ tags below are read by the web UI (sc/ui): column names, and each control's name | what it does.
// @layout Track 002 — 80s groove house
// @mode 16 Mode 1 — Foundation (beat + bass) · same CCs as Mode 16
// @col 16:8 8 Global
// @col 16:1 1 Kick
// @col 16:2 2 Rumble
// @col 16:3 3 Bass
// @col 16:4 4 Acid
// @col 16:5 5 Snare
// @col 16:6 6 Hats
// @col 16:7 7 Perc
// @mode 2 Mode 2 — Colour (chords + hooks)
// @col 2:1 1 Chords
// @col 2:2 2 Pad
// @col 2:3 3 Arp
// @col 2:4 4 Hook
// @col 2:5 5 Strings
// @col 2:6 6 Organ
// @col 2:7 7 FX
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | density: pad in, echo, reverb; the end adds a snare roll.
// @ctl g.fader Master | more low end, punch and drive.
// @ctl g.b1 Chapter | mood: boogie → Italo → sunrise, at the next bar.
// @ctl g.b2 Break | kick and bass out; press again: back on the one.
// @ctl 16:1.k1 Brightness | dull ↔ bright.
// @ctl 16:1.k2 Space | dry ↔ room.
// @ctl 16:1.k3 Ghosts | none ↔ soft ghost kicks between the beats.
// @ctl 16:1.fader Level | the kick, on every beat.
// @ctl 16:1.b1 Pattern | four on the floor → skip into the one → half time.
// @ctl 16:1.b2 Drop out | kick pauses while held.
// @ctl 16:2.k1 Brightness | dark ↔ a little brighter.
// @ctl 16:2.k2 Space | tight ↔ long room.
// @ctl 16:2.k3 Motion | still ↔ the filter breathes over 2 bars.
// @ctl 16:2.fader Level | rolling low end under the kick.
// @ctl 16:2.b1 Pattern | pulse → roll → bounce.
// @ctl 16:2.b2 Swell | the rumble grows longer and louder while held.
// @ctl 16:3.k1 Brightness | dull ↔ bright.
// @ctl 16:3.k2 Space | dry ↔ room.
// @ctl 16:3.k3 Length | short plucks ↔ long, legato notes.
// @ctl 16:3.fader Level | octave bass, follows the chords.
// @ctl 16:3.b1 Pattern | octaves → boogie → gallop.
// @ctl 16:3.b2 Octave | one octave up while held.
// @ctl 16:4.k1 Brightness | closed filter ↔ open.
// @ctl 16:4.k2 Space | dry ↔ echo + room.
// @ctl 16:4.k3 Squelch | round ↔ a little resonance on the accents.
// @ctl 16:4.fader Level | acid line, follows the chords.
// @ctl 16:4.b1 Pattern | roll → sparse → climb.
// @ctl 16:4.b2 Open | the filter opens while held.
// @ctl 16:5.k1 Brightness | dull ↔ bright.
// @ctl 16:5.k2 Space | dry ↔ gated room.
// @ctl 16:5.k3 Gate | short tail ↔ long gated tail.
// @ctl 16:5.fader Level | backbeat on 2 and 4. Also the level of Tension's roll.
// @ctl 16:5.b1 Pattern | gated snare → snare + clap → clap.
// @ctl 16:5.b2 Roll | a snare roll fills in over 2 bars while held.
// @ctl 16:6.k1 Brightness | dull ↔ bright.
// @ctl 16:6.k2 Space | dry ↔ room.
// @ctl 16:6.k3 Swing | light swing ↔ heavy swing.
// @ctl 16:6.fader Level | closed and open hats. Keep playing in the break.
// @ctl 16:6.b1 Pattern | roll → disco → off-beat.
// @ctl 16:6.b2 Open | open hats ring long on every off-beat while held.
// @ctl 16:7.k1 Brightness | woody ↔ crisp.
// @ctl 16:7.k2 Space | dry ↔ room.
// @ctl 16:7.k3 Complexity | as written ↔ + quiet ghost notes.
// @ctl 16:7.fader Level | congas and bongos. Keep playing in the break.
// @ctl 16:7.b1 Pattern | congas → + cowbell → + shaker.
// @ctl 16:7.b2 Fill | a synth-tom run down over the bar while held.
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
// @ctl 2:6.k3 Decay | short stab ↔ ringing organ.
// @ctl 2:6.fader Level | organ stab, follows the chords.
// @ctl 2:6.b1 Pattern | stab → call → off-beat.
// @ctl 2:6.b2 Echo throw | long echo on the stab while held.
// @ctl 2:7.k1 Brightness | dull ↔ bright.
// @ctl 2:7.k2 Space | dry ↔ room.
// @ctl 2:7.k3 Complexity | riser + tail ↔ + a soft rising tone.
// @ctl 2:7.fader Level | risers and tails at the phrase changes.
// @ctl 2:7.b1 Pattern | phrase of 16 → 8 → 4 bars.
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
	(name: "Sunrise", steps: [0, 2, 4, 5, 7, 9, 10])];           // D mixolydian: bright, the house-anthem peak
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
name: "002-groove",
bpm: bpm,
// no master volume: column 8's fader (Master) drives kick and bass, read per note
global: (fog: glob.bright, thin: glob.space, tension: glob.char),
// Tension's echo: up to 0.2 over the first half of the knob (Strudel tensionEcho); Tension raises every reverb send by
// at most a third of the way to full (0.35, Strudel roomOf), so it never washes the mix out (not the drum pads: their
// own room formula opens all the way, as in Strudel)
tensionEchoAmt: 0.2,
tensionRoomAmt: 0.35,
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
// Orbit 4 = the rumble's dark room (2.2), a short 16th echo (unused: the rumble is dry).
// Impulse responses measured from superdough (tools/sc-port/reverb-ir.mjs).
orbits: (1: (ir: "ir/orbit-1.4.wav", delay: [0.75 * beat, 0.3]), 2: (ir: "ir/orbit-3.5.wav", delay: [0.75 * beat, 0.4]),
	3: (ir: "ir/orbit-0.9.wav", delay: [0.25 * beat, 0.2]), 4: (ir: "ir/orbit-2.2.wav", delay: [0.25 * beat, 0.2])),
// state buses: room and echo amounts the language derives from knobs (columns whose Space is scaled, echo throws)
states: (rumRoom: 0.9 * 0.35, snRoom: 0.9 * 0.15, padRoom: 0.9 * 0.3, padEcho: 0, hookEcho: 0, strRoom: 0.9 * 0.25,
	organEcho: 0, fxRoom: 0.9 * 0.3,
	lkLevel: 0, lkBright: 0, lkRoom: 0.9 * 0.1, lkEcho: 0),
// map buses (server side, follow the knob at once): Tension brings the pad in (30 % → full over its first half)
maps: (padIn: (ccs: [glob.char], fn: { |t| 0.3 + (0.7 * (t / 0.5).clip(0, 1)) })),
// samples the drum stems play (the files Strudel plays: tidal-drum-machines, see sc/samples/CREDITS.md)
samples: ["tr909/bd-01.wav", "tr909/sd-00.wav", "tr909/cp-00.wav", "tr909/rim-00.wav", "tr909/hh-00.wav", "tr909/oh-00.wav",
	"tr808/cb-00.wav", "tr727/perc-02.wav", "tr727/perc-03.wav", "tr727/perc-04.wav", "tr727/sh-00.wav",
	// the Launchkey's drum pads (as 016): the spoken samples, drum-machine one-shots, Dirt-Samples
	"voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac", "voice/plaenterwald.flac",
	"voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac", "voice/the_evening_does_not_end.flac", "voice/in_the_vast.flac",
	"tr909/lt-00.wav", "tr909/cr-00.wav", "tr808/sh-00.wav", "dirt/space-00.wav", "dirt/wind-00.wav"] ++ ~ce.lkKeysFiles,

stems: [
	// MODE 1 / 1 KICK — a tight 909 kick with a short sine body on D, four on the floor; Master: louder, longer, driven;
	// soft ghost kicks between the beats on row 3
	(name: \kick, sounds: [\sdSynthMod, \sdSampleMod], level: jojo.(1).level, space: jojo.(1).space, orbit: 1, thin: false),
	// MODE 1 / 2 RUMBLE — a low sine thump on D just after each kick, low-passed into its own dark room (orbit 4, Space
	// scaled 0.35 … 0.85): the rolling low end
	(name: \rumble, sounds: [\sdSynthMod], level: jojo.(2).level, roomR: \rumRoom, orbit: 4, thin: false),
	// MODE 1 / 3 BASS — the disco octave bass: saw + square through a filter envelope, a sine an octave below
	(name: \bass, sounds: [\sdSynthMod], level: jojo.(3).level, space: jojo.(3).space, orbit: 1, trim: 0.67, thin: false),
	// MODE 1 / 4 ACID — a 303-style line kept clean: a saw in 16ths, accents open the filter a little, no slides, no drive
	(name: \acid, sounds: [\sdSynthMod], level: jojo.(4).level, space: jojo.(4).space, orbit: 1, echo: 0.2, trim: 2.8, thin: false),
	// MODE 1 / 5 SNARE — the 80s gated snare on 2 and 4 (909 snare, a noise tail cut off hard, a triangle thump) in a
	// small dense room (orbit 3, Space scaled 0.15 … 0.85); rolls on button 2 and from Tension
	(name: \snare, sounds: [\sdSample, \sdNoise, \sdSynthMod], level: jojo.(5).level, roomR: \snRoom, orbit: 3, trim: 1.5, thin: false),
	// MODE 1 / 6 HATS — 909 hats with a rolling, swung closed hat and the open hat on the off-beat (a little swing always)
	(name: \hats, sounds: [\sdSample], level: jojo.(6).level, space: jojo.(6).space, orbit: 1, trim: 0.35, thin: false),
	// MODE 1 / 7 PERCUSSION — TR-727 congas and bongos in a syncopated pattern, 808 cowbell or a shaker, a synth-tom fill
	(name: \perc, sounds: [\sdSample, \sdSynthMod, \sdNoise], level: jojo.(7).level, space: jojo.(7).space, orbit: 1, trim: 0.48, thin: false),
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
	// MODE 2 / 6 ORGAN STAB — the house organ stab (M1 style): root, third, fifth, each a sine, a quiet square an octave
	// up and a high sine; echo throw on button 2 (Tension's echo stays on top)
	(name: \organ, sounds: [\sdSynthMod], level: jonas.(6).level, space: jonas.(6).space, echoSend: \organEcho, orbit: 2, thin: false),
	// MODE 2 / 7 FX — soft cues: a filtered noise riser in the last bar of each phrase, a falling tail + low boom after it
	(name: \fx, sounds: [\sdNoise, \sdSynthMod], level: jonas.(7).level, roomR: \fxRoom, orbit: 2, trim: 0.4, thin: false),
	// LAUNCHKEY MK4 25 — as 016: keys = Jonas' keys of 009 (orbit 2, mod wheel = level); drum pads: 16 one-shots
	// (orbit 1, each lane a shot's own room / echo, Tension opens it all the way). No Tension echo (Strudel gives none),
	// no master (as Strudel).
	(name: \lk, sounds: ~ce.lkKeysSounds ++ [\sdSampleMod, \sdSynthMod], level: \lkLevel, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \shots, orbit: 1, level: 1.0, roomR: 0.3, tensionRoomAmt: 1), (name: \lt, orbit: 1, level: 1.0, roomR: 0.5, tensionRoomAmt: 1),
			(name: \rim, orbit: 1, level: 1.0, roomR: 0.3, echoSend: 0.4, tensionRoomAmt: 1), (name: \orch, orbit: 1, level: 1.0, roomR: 0.6, tensionRoomAmt: 1),
			(name: \space, orbit: 1, level: 1.0, roomR: 0.9, tensionRoomAmt: 1), (name: \wind, orbit: 1, level: 1.0, roomR: 0.8, tensionRoomAmt: 1)]),
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

	// MODE 1 / 1 KICK — Ghosts (row 3): soft sine thumps without the 909 click on syncopated 16ths that change every bar;
	// the first half of the knob brings in one layer, the second half a busier one
	{
		var kc = jojo.(1);
		var kicks = ["x*4", "<x*4 [x x x [x ~ ~ x]]>", "x ~ x ~"].collect(table);
		var ghosts = ["<[~ ~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~] [~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ x ~ ~ ~ ~]>",
			"<[~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ x ~] [~ ~ x ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x]>"].collect(table);
		self.kickVar = ce.change(kc.btn, 3, "Kick", ["4/4", "Skip", "Half"]);
		stem.(\kick).notes = { |k|
			var b = bar.(k), out = List[], c = ce.val(kc.char);
			// a ghost kick: its own low-pass (380 Hz) is overridden by the column's, as in Strudel (strip sets lpf after)
			var ghost = { |e, g| out.add(syn.(\sine, 38, g, (lpOn: 1, bright: ce.val(kc.bright), lo: 600, hi: 9000, tone: tone,
				penv: 8, pd: 0.03, at: e[0], hold: e[1]) ++ adsr.(0.004, 0.11, 0, 0.03))) };
			if(self.beatOn(b) and: { ce.held(kc.btn2).not }) {
				eventsAt.(kicks[self.kickVar.atBar(b)], k).do { |e|
					var w = master.(), gw = 0.9 * dB.(1.5 * w);
					// the whole kick: low-pass from Brightness × Fog / Tension, Master drives it (shape)
					var lp = (lpOn: 1, bright: ce.val(kc.bright), lo: 600, hi: 9000, tone: tone, shape: 0.2 * w, at: e[0], hold: e[1]);
					out.add(smp.("tr909/bd-01.wav", "RolandTR909_bd:0", 0.6 * gw, lp ++ (hold: -1) ++ adsr.(nil, 0.5, 0, nil), \sdSampleMod));
					// the body: a sine on D2 with a pitch drop; Master makes it longer and drop further
					out.add(syn.(\sine, 38, 0.65 * gw, lp ++ (penv: 14 + (6 * w), pd: 0.05)
						++ adsr.(0.002, 0.28 * (1 + (0.4 * w)), 0, 0.05)));
				};
				if(c > 0) { eventsAt.(ghosts[0], k).do { |e| ghost.(e, ramp.(c, 0, 0.5) * 0.4) } };
				if(c > 0.5) { eventsAt.(ghosts[1], k).do { |e| ghost.(e, ramp.(c, 0.5, 1) * 0.32) } };
			};
			out
		};
	}.value;

	// MODE 1 / 2 RUMBLE — not the kick's tail but its echo in the room: a sine that drops a little in pitch, through a
	// dark reverb (orbit 4); Swell (button 2 held) makes it longer and louder
	{
		var rc = jojo.(2);
		var pats = ["[~ ~ x ~]*4", "[~ x ~ x]*4", "<[~ ~ x ~]*4 [~ x ~ x]*4>"].collect(table);
		spaceState.(rc.space, \rumRoom, { |s| 0.9 * (0.35 + (0.5 * s)) });
		self.rumbleVar = ce.change(rc.btn, 3, "Rumble", ["Pulse", "Roll", "Bounce"]);
		stem.(\rumble).notes = { |k|
			var b = bar.(k), out = List[], held = ce.held(rc.btn2);
			if(self.beatOn(b)) {
				eventsAt.(pats[self.rumbleVar.atBar(b)], k).do { |e|
					// Motion: 1 − 0.55 × Motion × (0.5 + 0.5 sin(π t)), Strudel reads t at the bar start, where sin(π t) = 0:
					// so the filter does not breathe, it is a steady 0 … 27.5 % darker (1:1, see sc/PORTING.md)
					var mv = 1 - (0.55 * ce.val(rc.char) * (0.5 + (0.5 * sin(pi * b))));
					out.add(syn.(\sine, 38, if(held) { 1.35 } { 1 }, (lpOn: 1, bright: ce.val(rc.bright), lo: 120 * mv, hi: 600 * mv, tone: tone,
						penv: 5, pd: 0.04, at: e[0], hold: e[1]) ++ adsr.(0.006, if(held) { 0.4 } { 0.18 }, 0, 0.06)));
				}
			};
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
					var lp = (lpOn: 1, bright: ce.val(bc.bright), lo: 300, hi: 3500, tone: tone, shape: 0.1 + (0.15 * w), at: e[0], hold: e[1]);
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
				// the low-pass: Brightness 250 … 2200 Hz, × 2 while Open is held, × a slow sine (0.85 … 1.15, one cycle in 8
				// bars, read at the bar start), then × Fog / Tension, kept within 80 Hz … 18 kHz; little resonance, no drive
				var f = if(ce.held(ac.btn2)) { 2 } { 1 } * (0.85 + (0.3 * ce.sine(b / 8)));
				out.add(syn.(\sawtooth, m, 0.32 * vels[k % 4], (lpOn: 1, bright: ce.val(ac.bright), lo: 250 * f, hi: 2200 * f, tone: tone,
					lpq: 4 + (7 * q), lpenv: 1.5 + (2 * q), la: 0.002, ld: 0.1, ls: 0, lr: 0.01, hp: 140, at: e[0], hold: e[1])
					++ adsr.(0.002, 0.14, 0.15, 0.04)));
			};
			out
		};
	}.value;

	// MODE 1 / 5 SNARE (keeps playing in the break)
	{
		var sc = jojo.(5);
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
			if(tr > 0) { roll.(tr, 0.4) };
			out
		};
	}.value;

	// MODE 1 / 6 HATS (keep playing in the break)
	{
		var hc = jojo.(6);
		// per pattern: [kind, hits, gain (a number or per 16th of the beat)]
		// the closed hat leaves out the off-beat 16th where the open hat plays; gains per 16th of the beat, or per bar
		// (Roll: "<[0.2 0.1 0 0.15]*4 [0.2 0.12 0 0.17]*4>")
		var pats = [
			[[\open, "[~ ~ x ~]*4", 0.28], [\closed, "[x x ~ x]*4", [[0.2, 0.1, 0, 0.15], [0.2, 0.12, 0, 0.17]]],
				[\closed, "<[~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~] [~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ [x x] ~ ~]>", 0.07]],
			[[\open, "[~ ~ x ~]*4", 0.3], [\closed, "[x ~ ~ x]*4", [0.18, 0, 0, 0.12]]],
			[[\open, "[~ x]*4", 0.32], [\closed, "[x ~ ~ ~]*4", 0.1]],
		].collect { |p| p.collect { |x| [x[0], table.(x[1]), x[2]] } };
		var heldClosed = table.("[x x ~ x]*4"), heldOpen = table.("[~ oh]*4");
		self.hatVar = ce.change(hc.btn, 3, "Hats", ["Roll", "Disco", "Off-beat"]);
		stem.(\hats).notes = { |k|
			var b = bar.(k), s16 = k % 16, out = List[], sw = 0.08 + (0.3 * ce.val(hc.char));
			// gain × 3 for all, a high-pass at 1800 Hz, the low-pass from Brightness × Fog only
			var lp = (lpOn: 1, bright: ce.val(hc.bright), lo: 8000, hi: 18000, tone: fog, hp: 1800);
			var closed = { |g, at, len| out.add(smp.("tr909/hh-00.wav", "RolandTR909_hh:0", g * 3, lp ++ (pan: 0.68, at: at, hold: len) ++ adsr.(nil, 0.035, 0, 0.02))) };
			var open = { |g, at, len, dec = 0.18, rel = 0.05| out.add(smp.("tr909/oh-00.wav", "RolandTR909_oh:0", g * 3, lp ++ (pan: 0.56, at: at, hold: len) ++ adsr.(nil, dec, 0, rel))) };
			if(ce.held(hc.btn2).not) {
				pats[self.hatVar.atBar(b)].do { |x| eventsAt.(x[1], k).do { |e|
					var g = if(x[2].isArray) { if(x[2][0].isArray) { x[2][b % 2][s16 % 4] } { x[2][s16 % 4] } } { x[2] }, at = e[0] + swingAt.(s16 + e[0], sw);
					if(g > 0) { if(x[0] == \open) { open.(g, at, e[1]) } { closed.(g, at, e[1]) } } } };
			} {
				// Open (held): closed x x ~ x, the open hat on every off-beat 8th, ringing long; not swung
				eventsAt.(heldClosed, k).do { |e| closed.(0.14, e[0], e[1]) };
				eventsAt.(heldOpen, k).do { |e| open.(0.34, e[0], e[1], 0.45, 0.1) };
			};
			out
		};
	}.value;

	// MODE 1 / 7 PERCUSSION (keeps playing in the break) — conga low (n 4), bongo high / low (n 2 / 3); button 2 plays an
	// 80s synth-tom run (a sine dropping in pitch)
	{
		var pc7 = jojo.(7);
		// [hits, sample n, gain]
		var congas = [["~ ~ ~ x ~ ~ x ~ ~ ~ ~ x ~ x ~ ~", 4, 0.5], ["~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x", 2, 0.4],
			["<[~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~] [~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ x ~]>", 3, 0.4]].collect { |x| [table.(x[0]), x[1], x[2]] };
		var cow = table.("~ ~ x ~ ~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~"), shaker = table.("x*16"), ghosts = table.("~ ~ x ~ ~ ~ ~ x ~ ~ x ~ ~ ~ ~ ~");
		var fill = table.("d3 ~ c3 ~ a2 ~ g2 ~ f2 ~ d2 ~ d2 ~ ~ ~");
		self.percVar = ce.change(pc7.btn, 3, "Percussion", ["Congas", "+ Cowbell", "+ Shaker"]);
		stem.(\perc).notes = { |k|
			var b = bar.(k), s16 = k % 16, v = self.percVar.atBar(b), c = ce.val(pc7.char), out = List[];
			// everything pans slowly (Strudel pan(sine.slow(11)) after the stack: it sets every pan, also the cowbell's
			// and the shaker's own), read at each note's start; the low-pass from Brightness × Fog only
			var lp = { |e| (lpOn: 1, bright: ce.val(pc7.bright), lo: 1200, hi: 9000, tone: fog, at: e[0],
				pan: 0.3 + (0.4 * ce.sine((k + e[0]) / 16 / 11))) };
			var conga = { |e, n, g| out.add(smp.("tr727/perc-0" ++ n ++ ".wav", "RolandTR727_perc:" ++ n, g, lp.(e))) };
			var tom = { |e| var m = name2midi.(e[2]);
				out.add(syn.(\sine, m, 0.5, lp.(e) ++ (hold: e[1], penv: 7, pd: 0.12) ++ adsr.(0.001, 0.28, 0, 0.05)));
				out.add(noise.(1, 0.07, lp.(e) ++ (hold: e[1], bp: 1800, midi: m) ++ adsr.(0.001, 0.02, 0, nil))) };
			congas.do { |x| eventsAt.(x[0], k).do { |e| conga.(e, x[1], x[2]) } };
			if(v == 1) { eventsAt.(cow, k).do { |e| out.add(smp.("tr808/cb-00.wav", "rolandtr808_cb", 0.3, lp.(e) ++ adsr.(nil, 0.25, 0, nil))) } };
			if(v == 2) { eventsAt.(shaker, k).do { |e| out.add(smp.("tr727/sh-00.wav", "RolandTR727_sh:0", [0.25, 0.12, 0.18, 0.12][s16 % 4], lp.(e))) } };
			if(c > 0) { eventsAt.(ghosts, k).do { |e| conga.(e, 2, c * 0.22) } };
			if(ce.held(pc7.btn2)) { eventsAt.(fill, k).do(tom) };
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

	// MODE 2 / 6 ORGAN STAB — root, third, fifth; each note a sine, a square an octave up (quiet) and a high sine
	{
		var oc = jonas.(6);
		var stabs = ["~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ ~ x ~", "<[x ~ ~ x ~ ~ x ~ ~ ~ ~ ~ ~ ~ ~ ~] ~>", "[~ ~ x ~]*4"].collect(table);
		// the echo: Strudel bus (0.15 × 2 × Space, at most 0.9), 0.8 while the throw is held (Tension's echo stays on top)
		var upd = { |send| ce.setState(\organEcho, if(ce.held(oc.btn2)) { 0.8 } { (0.3 * ce.val(oc.space)).min(0.9) }, send) };
		[oc.space, oc.btn2].do { |cc| ce.onCC(cc, { |v, send| upd.(send) }) };
		self.organVar = ce.change(oc.btn, 3, "Organ Stab", ["Stab", "Call", "Off-beat"]);
		stem.(\organ).notes = { |k|
			var b = bar.(k), out = List[];
			eventsAt.(stabs[self.organVar.atBar(b)], k).do { |e|
				// Decay (row 3) for all three layers: the high sine's own short decay (0.05) is overridden by the stack's
				// decay, as in Strudel
				var lp = (lpOn: 1, bright: ce.val(oc.bright), lo: 1200, hi: 9000, tone: tone, at: e[0], hold: e[1])
					++ adsr.(0.002, 0.12 + (0.5 * ce.val(oc.char)), 0, 0.08);
				self.chordAt(b, [0, 2, 4], 4).do { |m|
					out.add(syn.(\sine, m, 0.5, lp));
					out.add(syn.(\square, m + 12, 0.11, lp));
					out.add(syn.(\sine, m + 19, 0.18, lp));
				}
			};
			out
		};
	}.value;

	// MODE 2 / 7 FX — soft cues, kept clean: the riser stops at 4.5 kHz, the noise is quiet, the default phrase is 16 bars.
	// The phrase (button 1: 16, 8 or 4 bars): a riser in its last bar, a tail on its first; Complexity adds a soft rising
	// tone in the last bar; button 2 = a riser by hand
	{
		var fc = jonas.(7), lens = [16, 8, 4];
		var rise = heldRamp.(fc.btn2, 4);
		spaceState.(fc.space, \fxRoom, { |s| 0.9 * (0.3 + (0.6 * s)) });
		self.fxVar = ce.change(fc.btn, 3, "FX", ["16 bars", "8 bars", "4 bars"]);
		stem.(\fx).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, x = s16 / 16, len = lens[self.fxVar.atBar(b)], c = ce.val(fc.char);
			var lp = (lpOn: 1, bright: ce.val(fc.bright), lo: 2000, hi: 12000, tone: tone), out = List[], r;
			// riser: pink noise in 16ths through a band-pass climbing from 300 Hz (pos 0) to 4.5 kHz (pos 1), swelling
			var riser = { |pos, g| noise.(0, g * (0.08 + (0.6 * pos * pos)), lp ++ (hold: 1, bp: 300 * (15 ** pos), bpq: 2.5,
				pan: 0.35 + (0.3 * ce.sine(2 * t))) ++ adsr.(0.03, nil, 1, 0.12)) };
			if((b % len) == (len - 1)) {
				out.add(riser.(x, 1));
				// the soft rising tone: a triangle in 8ths from D4 up an octave
				if(c > 0 and: { s16.even }) { out.add(syn.(\triangle, 62 + (12 * x), ramp.(c, 0, 1) * 0.08, lp ++ (hold: 2) ++ adsr.(0.02, nil, 1, 0.08))) };
			};
			if((b % len) == 0) {
				// tail: the noise falling from 4 kHz, fading; a sine boom on D2 that drops an octave
				out.add(noise.(0, 0.35 * ((1 - x) ** 2), lp ++ (hold: 1, bp: 4000 * ((1 / 15) ** x), bpq: 2) ++ adsr.(0.005, nil, 1, 0.2)));
				if(s16 == 0) { out.add(syn.(\sine, 38, 0.4, lp ++ (hold: 16, penv: 12, pd: 0.25) ++ adsr.(0.005, 1.2, 0, 0.3))) };
			};
			r = rise.(t);
			r !? { out.add(riser.(r, 1)) };
			out.reject { |n| n.amp <= 0 }
		};
	}.value;

	// Knob defaults of the Strudel track (live only, as there: Web MIDI): the pad Space 0.5, the kick's Ghosts 0.3 until moved.
	// Offline renders (comparisons, tests) start from the scenario's values, as the Node tools do. Set after the
	// columns' control hooks, so the pad's room follows it.
	if(ce.log.isNil) { [[70, 0.5], [29, 0.3]].do { |x| ce.setCC(x[0], x[1], { |m| ce.server.sendMsg(*m) }, true) } };
}
)
)
