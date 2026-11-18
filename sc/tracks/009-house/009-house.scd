// TRACK 009 HOUSE — SuperCollider port of tracks/009-house/009-house.strudel (happy, jazzy, dry house, A minor,
// 124 BPM). Same controller layout as the Strudel track: Mode 1 = Jojo (foundation, plain CCs), Mode 2 = Jonas
// (colour, CC + 48), column 8 global on both, the Launchkey MK4 25 optional. All stems ported 1:1 (see sc/PORTING.md).
// Knobs and faders act at once, also on sounding notes (control buses); pattern buttons switch at the next bar.
// The @ tags below are read by the web UI (sc/ui): column names, and each ported control's name | what it does.
// @layout Track 009 — house (SuperCollider)
// @mode 16 Mode 1 — Jojo: Foundation (beat + bass) · same CCs as Mode 16
// @col 16:1 1 Kick
// @col 16:2 2 Noise Pump
// @col 16:3 3 Sub
// @col 16:4 4 Bass
// @col 16:5 5 Clap
// @col 16:6 6 Hats / Shaker
// @col 16:7 7 Congas
// @col 16:8 8 Global
// @mode 2 Mode 2 — Jonas: Colour (chords + melodies) · CC + 48
// @col 2:1 1 Harmony
// @col 2:2 2 Keys
// @col 2:3 3 Vibraphone
// @col 2:4 4 Flute
// @col 2:5 5 Brass
// @col 2:6 6 Strings
// @col 2:7 7 Guitar
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | build-up: echo, reverb, open filters; past half also a snare roll.
// @ctl g.fader Master | volume of everything.
// @ctl g.b1 Chapter | Vamp (Am9) ↔ Progression (Chords, column 1).
// @ctl g.b2 Break | 1st: kick, pump, sub, bass out. 2nd: all back on the one.
// @ctl 16:1.k1 Brightness | dull ↔ bright.
// @ctl 16:1.k2 Space | dry ↔ room.
// @ctl 16:1.k3 Punch | tight ↔ hard.
// @ctl 16:1.fader Level | four on the floor.
// @ctl 16:1.b1 Pattern | 4/4 → gap every 4th bar → every 8th bar.
// @ctl 16:1.b2 Drop | kick out while held.
// @ctl 16:2.k1 Brightness | dull ↔ bright.
// @ctl 16:2.k2 Space | dry ↔ room.
// @ctl 16:2.k3 Motion | still ↔ moving.
// @ctl 16:2.fader Level | noise that pumps with the kick.
// @ctl 16:2.b1 Pattern | pump → off-beat → 16ths.
// @ctl 16:2.b2 Riser | rising sweep while held.
// @ctl 16:3.k1 Brightness | sine ↔ full.
// @ctl 16:3.k2 Space | dry ↔ room.
// @ctl 16:3.k3 Length | long ↔ short.
// @ctl 16:3.fader Level | sub on the chord's root.
// @ctl 16:3.b1 Pattern | pump → off-beat → half bars.
// @ctl 16:3.b2 Octave | up while held.
// @ctl 16:4.k1 Brightness | dull ↔ bright.
// @ctl 16:4.k2 Space | dry ↔ room.
// @ctl 16:4.k3 Sound | FM → M1 organ → analog.
// @ctl 16:4.fader Level | bass line on the chords.
// @ctl 16:4.b1 Pattern | 7 lines, 3-3-2 first.
// @ctl 16:4.b2 Octave | up while held.
// @ctl 16:5.k1 Brightness | soft ↔ sharp.
// @ctl 16:5.k2 Space | dry ↔ room.
// @ctl 16:5.k3 Complexity | plain → rim → double taps.
// @ctl 16:5.fader Level | clap on 2 and 4.
// @ctl 16:5.b1 Pattern | 2 + 4 → pickup → fill every 4th bar.
// @ctl 16:5.b2 Roll | snare roll while held.
// @ctl 16:6.k1 Brightness | soft ↔ crisp.
// @ctl 16:6.k2 Space | dry ↔ room.
// @ctl 16:6.k3 Hats ↔ Shaker | hats → both → shaker.
// @ctl 16:6.fader Level | off-beat hat + 16ths.
// @ctl 16:6.b1 Pattern | off-beat → + 16ths → driving.
// @ctl 16:6.b2 Open | open hats while held.
// @ctl 16:7.k1 Brightness | woody ↔ crisp.
// @ctl 16:7.k2 Space | dry ↔ room.
// @ctl 16:7.k3 Complexity | steady → + ghost notes.
// @ctl 16:7.fader Level | congas and bongos.
// @ctl 16:7.b1 Pattern | pillow → rolling → latin.
// @ctl 16:7.b2 Fill | conga run while held.
// @ctl 2:1.k1 Brightness | dull ↔ bright.
// @ctl 2:1.k2 Space | dry ↔ echo + room.
// @ctl 2:1.k3 Strings ↔ B3 | strings → both → B3.
// @ctl 2:1.fader Level | held chords.
// @ctl 2:1.b1 Chords | next of 10 (at the next 8 bars).
// @ctl 2:1.b2 Echo throw | long echo while held.
// @ctl 2:2.k1 Brightness | dull ↔ bright.
// @ctl 2:2.k2 Space | dry ↔ echo + room.
// @ctl 2:2.k3 Length | short ↔ long.
// @ctl 2:2.fader Level | piano, Rhodes, organs, mallets.
// @ctl 2:2.b1 Pattern | 6 rhythms on Am9 → 5 riffs with own chords.
// @ctl 2:2.b2 Sound | on: knobs = sound mix, fader = overtones.
// @ctl 2:3.k1 Brightness | dull ↔ bright.
// @ctl 2:3.k2 Space | dry ↔ echo + room.
// @ctl 2:3.k3 Complexity | core → figure → fills → doubles.
// @ctl 2:3.fader Level | vibraphone.
// @ctl 2:3.b1 Pattern | off-beat → tresillo → call echo.
// @ctl 2:3.b2 Echo throw | long echo while held.
// @ctl 2:4.k1 Brightness | dull ↔ bright.
// @ctl 2:4.k2 Space | dry ↔ echo + room.
// @ctl 2:4.k3 Complexity | core → + neighbours → + trill.
// @ctl 2:4.fader Level | flute.
// @ctl 2:4.b1 Pattern | 3-3-2 → call + answer → steady 8ths.
// @ctl 2:4.b2 Echo throw | long echo while held.
// @ctl 2:5.k1 Brightness | dull ↔ bright.
// @ctl 2:5.k2 Space | dry ↔ echo + room.
// @ctl 2:5.k3 Complexity | core → + pickups → + extra hits.
// @ctl 2:5.fader Level | brass section.
// @ctl 2:5.b1 Pattern | 9 figures, the sparse ones last.
// @ctl 2:5.b2 Lift | section grows while held.
// @ctl 2:6.k1 Brightness | dull ↔ bright.
// @ctl 2:6.k2 Space | dry ↔ echo + room.
// @ctl 2:6.k3 Complexity | unison → octave → thirds → celli.
// @ctl 2:6.fader Level | string section.
// @ctl 2:6.b1 Pattern | 5 figures.
// @ctl 2:6.b2 Lift | section grows while held.
// @ctl 2:7.k1 Brightness | dull ↔ bright.
// @ctl 2:7.k2 Space | dry ↔ echo + room.
// @ctl 2:7.k3 Complexity | line → dead notes → variation → motor + fill.
// @ctl 2:7.fader Level | plucked guitar.
// @ctl 2:7.b1 Pattern | 8 lines.
// @ctl 2:7.b2 Lift | phaser, brighter while held.
// @lk level Keys Level | mod wheel: volume of the keys Rhodes (× master). 0 = keys silent, pads still play.
// @lk k1 Brightness | dark ↔ open (lpf 300–6000 Hz, × fog/tension).
// @lk k2 Resonance | flat ↔ whistling filter peak.
// @lk k3 Attack | hammer (5 ms) ↔ soft swell (0.5 s).
// @lk k4 Length | short notes (¼ bar) ↔ long (2 bars).
// @lk k5 Detune | one clean voice ↔ wide and wobbly (two detuned voices around it).
// @lk k6 Space | dry ↔ a little reverb (house stays fairly dry).
// @lk k7 Echo | dry ↔ long echo.
// @lk k8 Pad Fog | drum pads: clear ↔ muffled, like the global Fog (lpf 18 kHz → 800 Hz).
(
var bpm = 124;
// ---------------------------------------------------------------------------------------------------------
// CC numbers of column n (1-8): row 1-3 knobs, fader, buttons. Jojo = plain, Jonas = + 48.
var col = { |n, plus = 0| (bright: 12 + n + plus, space: 20 + n + plus, char: 28 + n + plus, level: 4 + n + plus,
	btn: 36 + n + plus, btn2: 44 + n + plus) };
var jojo = { |n| col.(n) }, jonas = { |n| col.(n, 48) };
var glob = col.(8);   // column 8 (global) answers on its Mode 1 and Mode 2 CCs: aliases below

// ---------------------------------------------------------------------------------------------------------
// HARMONY — chords, progressions, Chapter (Vamp ↔ Progression) — same data as the Strudel track
var midi = { |name| var m = name.findRegexp("^([a-g])(#|b)?([0-9])$");
	12 * (m[3][1].asInteger + 1) + (c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11)[m[1][1].asSymbol]
	+ (m[2][1] == "#").binaryValue - (m[2][1] == "b").binaryValue };
var pc = { |m| m % 12 };
var chord = { |name, bassName, toneNames, scaleNames|
	var bass = midi.(bassName), tones = toneNames.split($ ).collect(midi), low = tones.minItem;
	(name: name, bass: bass, root: low - 12 + pc.(bass - low), tones: tones,
		scale: scaleNames.split($ ).collect { |s| pc.(midi.(s ++ "4")) })
};
var aeol = "a b c d e f g";
var chords = [
	chord.("Am9", "a1", "c4 e4 g4 b4", "a b c d e f# g"),
	chord.("D9", "d2", "c4 e4 f#4 a4", "d e f# g a b c"),
	chord.("Am7", "a1", "c4 e4 g4 a4", aeol),
	chord.("Cmaj7", "c2", "c4 e4 g4 b4", aeol),
	chord.("Em7", "e1", "d4 e4 g4 b4", aeol),
	chord.("Fmaj7", "f1", "c4 e4 f4 a4", aeol),
	chord.("Fadd9", "f1", "c4 f4 g4 a4", aeol),
	chord.("Gadd9", "g1", "d4 g4 a4 b4", aeol),
	chord.("G11", "g1", "c4 d4 f4 g4", aeol),
	chord.("Dm7", "d2", "c4 d4 f4 a4", aeol),
	chord.("Gm", "g1", "d4 f4 g4 bb4", "g a bb c d e f"),
	chord.("Em/G", "g1", "d4 e4 g4 b4", aeol),
	chord.("Dm9", "d2", "c4 e4 f4 a4", aeol),
	chord.("Gm9", "g1", "d4 f4 a4 bb4", "g a bb c d e f"),
	chord.("Bm", "b1", "d4 f#4 b4", "b c# d e f# g a"),
];
var cid = { |name| chords.detectIndex { |c| c.name == name } };
var x2 = { |bars| bars ++ bars };
var progs = [
	["Am9 D9", x2.(["Am9", "Am9", "D9", "D9"])],
	["Am7 C Em7", x2.(["Am7", "Am7", "Cmaj7", "Em7"])],
	["Am F G", x2.(["Am9", "Am9", "Fmaj7", "Gadd9"])],
	["F G Am", x2.(["Fadd9", "G11", "Am9", "Am9"])],
	["Em7 Fmaj7", ["Em7", "Fmaj7", "Em7", "Fmaj7", "Em7", "Fmaj7", "Em7", "Am7"]],
	["Fmaj7 G", x2.(["Fmaj7", "Fmaj7", "Gadd9", "Gadd9"])],
	["F Am C Dm", ["Fmaj7", "Fmaj7", "Am7", "Am7", "Cmaj7", "Cmaj7", "Dm7", "Dm7"]],
	["Am7 Dm7", x2.(["Am7", "Am7", "Dm7", "Dm7"])],
	["C F Am Em", x2.(["Cmaj7", "Fadd9", "Am7", "Em7"])],
	["F Em Am", x2.(["Fmaj7", "Em7", "Am7", "Am7"])],
].collect { |p| (name: p[0], ids: p[1].collect(cid)) };
var chapterNames = ["Vamp", "Progression"];

// ---------------------------------------------------------------------------------------------------------
// BASS — the lab's line engine (lab/bass/house-bass-4 → Strudel track): tokens per 16th: R root, r root short,
// O / o octave long / short, 3 5 7 scale steps above (diatonic in the bar's mode), F fifth below, g dead note,
// A approach the next note (a semitone below it), - hold, . rest. Lines after analyses of real records
// (tracks/009-house/recherche-bass.md).
var bassLines = [
	["3-3-2", ["R..R..R.R..R..R.", "R..R..R.R..R.5.A"]],
	["Around 1 + dead", [".R.5g.7.O.gR.5.F", ".R.5g.7.O.7g5.3A"]],
	["Dead notes", ["RgRgO.RgRg5.RgO7", "RgRgO.RgRg5.R.7A"]],
	["Around 1", [".R.5..7.O..R.5.F", ".R.5..7.O.7.5.3A"]],
	["Beat 4 open", ["r.ro.r5.r7.o....", "r.ro.r5.o7.5...."]],
	["Pluck", ["R.R.O.R.RgROg7R5", "R-------....O.7A"]],
	["Alright", ["R.O.R.O.R.O.R.O.", "R.3.R.3.R.5.O.7A"]],
].collect { |l| (name: l[0], line: l[1].join) };
// The three sounds of row 3 (FM → M1 organ → warm analog) with the lab's column gains (−25 LUFS each)
var bassSounds = [[\bassFM, 0.77], [\bassM1, 0.71], [\bassWarm, 0.69]];
// Row 3: 0 → 0.5 FM → M1, 0.5 → 1 M1 → warm, equal power; a side at exactly 0 plays no notes
var bassBlend = [
	{ |v| if(v < 0.5) { cos(v * pi) * (v < 0.499).binaryValue } { 0 } },
	{ |v| if(v < 0.5) { sin(v * pi) * (v > 0.001).binaryValue } { cos((v - 0.5) * pi) * (v < 0.999).binaryValue } },
	{ |v| if(v > 0.5) { sin((v - 0.5) * pi) * (v > 0.501).binaryValue } { 0 } },
];
var bmd = { |k, n| k % n };
// Brass samples (Sonatina Symphonic Orchestra): [Strudel sound, folder, file prefix, notes, suffix], in the maps' order
var brassMaps = [
	[\sso_tp, "Trumpets", "trumpets-stc-rr1-", "e3 g3 a#3 c#4 e4 g4 a#4 c#5 e5 g5 a#5", ""],
	[\sso_tb, "Trombones", "trombones-stc-rr1-", "e2 g2 a#2 c#3 e3 g3 a#3 c#4 e4", ""],
	[\sso_hn, "Horns", "horns-stc-rr1-", "e2 g2 a#2 c#3 e3 g3 a#3 c#4 e4 g4 a#4", ""],
	[\sso_tp_sus, "Trumpets", "trumpets-sus-", "e3 g3 a#3 c#4 e4 g4 a#4 c#5 e5 g5", ""],
	[\sso_tb_sus, "Trombones", "trombones-sus-", "e2 g2 a#2 c#3 e3 g3 a#3 c#4 e4", ""],
	[\sso_hn_sus, "Horns", "horns-sus-mp-", "e2 g2 a#2 c#3 e3 g3 a#3 c#4 e4 g4 a#4", "-PB-loop"],
].collect { |m| [m[0], m[3].split($ ).collect { |n| [midi.(n), "sso/" ++ m[1] ++ "/" ++ m[2] ++ n ++ m[4] ++ ".flac"] }] };
// String samples: SSO as the brass; VSCO sounds an octave above its file name (Strudel: vscoUp8)
var stringMaps = [
	[\sso_vn, "1st Violins", "1st-violins-stc-rr1-", "g3 c#4 e4 g4 a#4 c#5 e5 g5 a#5 c#6 e6 g6"],
	[\sso_vn2, "2nd Violins", "2nd-violins-stc-rr1-", "g3 a#3 c#4 e4 g4 a#4 c#5 e5 g5 a#5"],
	[\sso_va, "Violas", "violas-stc-rr1-", "c3 d#3 f#3 a3 c4 d#4 f#4 a4 c5"],
	[\sso_vc, "Celli", "celli-stc-rr1-", "c2 d#2 f#2 a2 c3 d#3 f#3 a3 c4"],
	[\sso_vn_sus, "1st Violins", "1st-violins-sus-", "g3 a#3 c#4 e4 g4 a#4 c#5 e5 g5 a#5 c#6"],
	[\sso_va_sus, "Violas", "violas-sus-", "c3 d#3 f#3 a3 c4 d#4 f#4 a4 c5"],
	[\sso_vn_piz, "1st Violins", "1st-violins-piz-rr1-", "g3 a#3 c#4 e4 g4 a#4 c#5 e5 a#5 c#6"],
].collect { |m| [m[0], m[3].split($ ).collect { |n| [midi.(n), "sso/" ++ m[1] ++ "/" ++ m[2] ++ n ++ ".flac"] }] }
++ [
	[\vs_vn, "Violin Section/Spic/VlnEns_Spic_", "G2 A2 B2 D3 F#3 A3 C4 E4 G4 B4 D5"],
	[\vs_va, "Viola Section/spic/Violas_spic_", "C2 E2 G2 B2 D3 F3 A3 C4 E4 G4"],
].collect { |m| [m[0], m[2].split($ ).collect { |n| [midi.(n.toLower) + 12, "vsco/" ++ m[1] ++ n ++ "_v2_rr1.flac"] }] };
// General MIDI presets the track plays (keys: vibraphone, marimba; Launchkey pads: organ, brass, voices, vibraphone)
var gmPresets = ["0110_JCLive_sf2_file", "0120_JCLive_sf2_file", "0160_JCLive_sf2_file", "0610_JCLive_sf2_file", "0530_Aspirin_sf2_file"];
// Stratocaster: three takes, every note 52..86 (E3..D6); low notes from the D string, then G, then high E
var stratMaps = (1..3).collect { |take| [("strat" ++ take).asSymbol, (52..86).collect { |m|
	var n = ["C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B"][m % 12] ++ ((m / 12).floor.asInteger - 1);
	var dp = if(m < 62) { ["d_mp", "D"] } { if(m < 65) { ["g_mp", "G"] } { ["e4_mp", "E4"] } };
	[m, "strat/" ++ dp[0] ++ "/" ++ dp[1] ++ "_" ++ n ++ "_mp_" ++ take ++ ".flac"] }] };   // SuperCollider % is already non-negative for positive n

(
name: "009-house",
bpm: bpm,
global: (fog: glob.bright, thin: glob.space, tension: glob.char, master: glob.level),
// column 8 works on both pages: its Mode 2 CCs (+ 48) write the same buses as its Mode 1 CCs (last moved wins)
aliases: [\bright, \space, \char, \level, \btn, \btn2].collect { |r| (glob[r] + 48) -> glob[r] }.asDict,
chords: chords, progs: progs,
// web UI: the head line, column 8's buttons, the chord of a bar
uiHead: { |self, ce|
	var pend = { |now, next| if(now == next) { [now] } { [now, next] } };
	[["Chapter"] ++ pend.(chapterNames[self.chapter.now], chapterNames[self.chapter.pending]),
	 ["Chords"] ++ pend.(if(self.chapter.now == 0) { "Am9" } { progs[self.prog.now].name },
		if(self.chapter.pending == 0) { "Am9" } { progs[self.prog.pending].name }),
	 ["Break"] ++ pend.(["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending])]
},
uiGlobal: { |self, ce| (b1: [chapterNames[self.chapter.now], chapterNames[self.chapter.pending]],
	b2: [["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending]], b2on: self.breakL.pending == 1) },
uiChordAt: { |self, bar| chords[self.chordIdAt(bar)].name },
// web UI: Jonas' lab columns show their state (start values until moved; keys: the sound mix with Sound on),
// button 2 shows Sound on / Lift NN %
uiCols: { |self, ce|
	var shown = Dictionary[], labels = Dictionary[], on = Dictionary[], names = Dictionary[], texts = Dictionary[], dim = Dictionary[];
	// keys with Sound on: the knobs mix the sound (as the Strudel view: Piano 60 %, Piano → Rhodes 40 %, Rhodes 20 %)
	var mixNames = [["Piano", "Rhodes"], ["B3", "M1"], ["Vibes", "Marimba"]];
	var mixText = { |r, v| var a = mixNames[r][0], b = mixNames[r][1], pct = { |x| (x * 100).round.asInteger.asString ++ " %" };
		case { v <= 0 } { "off" } { v < (1 / 3) } { a + pct.(3 * v) } { v > (2 / 3) } { b + pct.(3 - (3 * v)) }
		{ a + "→" + b + pct.((3 * v) - 1) } };
	[[1, \hs], [2, \ks], [3, \vs], [4, \fs], [5, \bs], [6, \ss], [7, \gs]].do { |x|
		var c = jonas.(x[0]), st = self[x[1]];
		st !? {
			var vals = if(x[0] == 2 and: { st[\shift] == 1 }) { st[\mix] ++ [st[\e]] } { st[\val] };
			[c.bright, c.space, c.char, c.level].do { |cc, i| shown[cc] = vals[i] };
			if(x[0] == 2) { labels[c.btn2] = if(st[\shift] == 1) { "Sound on" } { "Sound" }; on[c.btn2] = st[\shift] == 1;
				if(st[\shift] == 1) {
					[c.bright, c.space, c.char].do { |cc, i| names[cc] = mixNames[i].join(" → "); texts[cc] = mixText.(i, st[\mix][i]) };
					names[c.level] = "Overtones"; dim[c.btn] = true;
				}
			};
			st[\lift] !? { |l| labels[c.btn2] = "Lift " ++ (l * 100).round.asInteger ++ " %" };
		}
	};
	(shown: shown, labels: labels, on: on, names: names, texts: texts, dim: dim)
},
// orbit reverbs (Strudel orbits 1 and 2: room sizes 0.6 and 1.2), impulse responses measured from superdough
// Orbit 1 = drums and bass: a very small room, a short dotted-8th slap. Orbit 2 = melodies (and the noise riser):
// a small studio room, a dotted-8th echo that dies after two or three repeats. [delay time s, feedback]
orbits: (1: (ir: "ir/orbit-0.6.wav", delay: [0.75 * 60 / bpm, 0.2]), 2: (ir: "ir/orbit-1.2.wav", delay: [0.75 * 60 / bpm, 0.3]),
	// orbit 3 = Jonas' lab columns (room size 2; each note sets the echo time / feedback, as in superdough)
	3: (ir: "ir/orbit-2.0.wav", delay: [30 / bpm, 0.15]),
	// orbit 4 = the keys: in Strudel they sit on orbit 2 but bring room size 2 and their own echo; SuperCollider gives
	// them their own orbit so the noise riser keeps orbit 2's small room
	4: (ir: "ir/orbit-2.0.wav", delay: [30 / bpm, 0.15])),
// state buses of the lab columns (Jonas): level (fader × gain × brightness ±2 dB), room amount, echo send
states: (harmLevel: 0, harmRoom: 0, harmEcho: 0, harmCut: 1000, harmJx: 0, harmB3: 0, keysLevel: 0, keysRoom: 0, keysEcho: 0, vibLevel: 0, vibRoom: 0, vibEcho: 0, fluLevel: 0, fluRoom: 0, fluEcho: 0, brsLevel: 0, brsRoom: 0, brsEcho: 0,
	strLevel: 0, strRoom: 0, strEcho0: 0, strEcho3: 0, strEcho5: 0, gtrLevel: 0, gtrRoom: 0, gtrEcho: 0,
	lkLevel: 0, lkRoom: 0, lkEcho: 0),
// samples the drum stems play (the files Strudel plays: tidal-drum-machines, see sc/samples/CREDITS.md)
samples: ["repo:vcsl-keys/JHPiano_Sus_Close_F#3_vl3_rr1.flac", "repo:vcsl-keys/JHPiano_Sus_Close_G#3_vl3_rr1.flac",
	"repo:vcsl-keys/JHPiano_Sus_Close_A#3_vl3_rr1.flac", "repo:vcsl-keys/JHPiano_Sus_Close_C4_vl3_rr1.flac",
	"repo:vcsl-keys/JHPiano_Sus_Close_D4_vl3_rr1.flac", "repo:vcsl-keys/JHPiano_Sus_Close_E4_vl3_rr1.flac",
	"jrhodes/A_055__G3_3.flac", "jrhodes/A_059__B3_3.flac", "jrhodes/A_062__D4_3.flac", "jrhodes/A_065__F4_3.flac",
	"tr909/cp-00.wav", "tr909/rim-00.wav", "tr909/sd-00.wav", "tr909/oh-00.wav", "tr909/hh-00.wav",
	"tr727/sh-00.wav", "tr727/sh-01.wav", "tr727/perc-02.wav", "tr727/perc-03.wav", "tr727/perc-04.wav"]
	// the VCSL vibraphone (strudel.cc's built-in 'vibraphone', CC0), in the order of its sample map
	++ ["A2", "A4", "B3", "C3", "C5", "D4", "E3", "E5", "F2", "F4", "G3"].collect { |n| "vibraphone/Vibes_hard_" ++ n ++ "_v3_rr1_Main.flac" }
	// the recorded flute phrases (juskiddink "Flute2", Freesound, CC BY 4.0; repo samples/horn-phrases)
	++ ["0003", "0068", "0133"].collect { |n| "repo:horn-phrases/flute-65509-" ++ n ++ ".flac" }
	// Sonatina Symphonic Orchestra brass (CC Sampling Plus 1.0), staccato and sustain
	++ brassMaps.collect { |m| m[1].collect(_[1]) }.flatten
	// SSO strings (CC Sampling Plus 1.0) and VSCO 2 CE string sections (CC0)
	++ stringMaps.collect { |m| m[1].collect(_[1]) }.flatten
	// the Stratocaster (nyanshell.strat, MIT; cut to 1.5 s, the guitar's notes are short)
	++ stratMaps.collect { |m| m[1].collect(_[1]) }.flatten
	// General MIDI soundfont zones (WebAudioFont presets, as Strudel's gm_* sounds; tools/sc-port/soundfont-extract.py)
	++ gmPresets.collect { |p| ~ce.fontFiles(p) }.flatten
	// Launchkey pads: the spoken samples (repo samples/voice, decoded from m4a) and more drum-machine one-shots
	++ ["voice/brace.wav", "voice/lw.wav", "tr909/lt-00.wav", "tr909/cr-00.wav", "tr909/rd-00.wav", "tr808/cb-00.wav", "tr707/tb-00.wav"],

stems: [
	// JOJO 1 KICK — a short, tight 909 kick, four on the floor, with a short sine body on A1 (tuned to the key)
	// Brightness | dull ↔ bright · Space | dry ↔ room · Punch | tight ↔ hard · Level | four on the floor
	// Pattern | 4/4 → gap every 4th bar → every 8th bar · Drop | kick, pump, sub out while held
	(name: \kick, sounds: [\kick909], level: jojo.(1).level, space: jojo.(1).space, orbit: 1),
	// JOJO 2 NOISE PUMP — a short breath of noise glued to the kick: it swells in after every kick and stops before the
	// next one (the pump of a sidechain, without a compressor). Riser on button 2 (its own lane: orbit 2, space 0.3).
	(name: \noise, sounds: [\sdNoise], level: jojo.(2).level, thin: false,
		lanes: [(name: \pump, orbit: 1, space: jojo.(2).space, echo: 0.15), (name: \riser, orbit: 2, space: (fixed: 0.3), echo: 0)]),
	// JOJO 3 SUB — a sine on the chord's root, each note a 16th after the kick (dry, no low-pass)
	(name: \sub, sounds: [\sdSynth], level: jojo.(3).level, space: jojo.(3).space, orbit: 1, thin: false),
	// JOJO 4 BASS — seven lines from the bass lab on button 1; row 3 fades FM → M1 organ → warm analog; every line
	// follows the chord (Chapter + progression of Jonas 1, the change two 16ths early) and walks into each change.
	// Brightness | dull ↔ bright · Space | dry ↔ room · Sound | FM → M1 organ → analog · Level | bass line on the chords
	// Pattern | 7 lines, 3-3-2 first · Octave | up while held
	// Level: fader × 1.55 (as loud as the old bass) × brightness ±2 dB (the lab's postgain): map bassTrim
	(name: \bass, sounds: [\bassFM, \bassM1, \bassWarm], level: jojo.(4).level, space: jojo.(4).space, orbit: 1,
		trim: \bassTrim),
	// JOJO 5 CLAP — the 909 clap on 2 and 4 (with its own tail), rim ghosts on row 3, rolls
	(name: \clap, sounds: [\sdSample], level: jojo.(5).level, space: jojo.(5).space, orbit: 1, echo: 0.2, thin: false),
	// JOJO 6 HATS / SHAKER — the house off-beat (short open 909 hat) and closed 16ths, swung; row 3 trades for shakers
	(name: \hats, sounds: [\sdSample], level: jojo.(6).level, space: jojo.(6).space, orbit: 1, echo: 0.2, thin: false),
	// JOJO 7 CONGAS — TR-727 latin percussion, quiet: conga low, bongo high / low
	(name: \perc, sounds: [\sdSample], level: jojo.(7).level, space: jojo.(7).space, orbit: 1, echo: 0.3, thin: false),
	// JONAS 1 HARMONY — 1:1 from the harmony lab (lab/harmonie/harmonie-4.strudel, column 2): held chords (struck
	// again after 4 bars), JX-10 strings (supersaws) ↔ soft Hammond B3 (sines, slow Leslie) on row 3
	(name: \harm, sounds: [\sdSupersaw, \sdSynth], level: \harmLevel, roomR: \harmRoom, echoSend: \harmEcho, orbit: 3, ownDelay: [30 / bpm, 0.15], thin: false),
	// JONAS 2 KEYS — 1:1 from the keys lab (round 19: Steinway + Rhodes, organs, mallets): short stabs in Kerri
	// Chandler's voicing; 6 rhythms on Am9, 5 riffs with their own chords (bass, sub, harmony, melodies follow them)
	(name: \keys, sounds: [\sdSample, \sdSynth, \sdFont], level: \keysLevel, roomR: \keysRoom, echoSend: \keysEcho, orbit: 4, thin: false),
	// JONAS 3 VIBRAPHONE — 1:1 from the melody lab (lab/melodie/melodie-2): three phrases on the chord (off-beat arp,
	// tresillo in the mode, the Escravos call two octaves lower); Complexity adds layers, fills and doubles
	(name: \vibes, sounds: [\sdSample], level: \vibLevel, roomR: \vibRoom, echoSend: \vibEcho, orbit: 3, ownDelay: [30 / bpm, 0.15], thin: false),
	// JONAS 4 FLUTE — 1:1 from the melody lab (lab/melodie/melodie-4, column 6): single notes cut from a recorded
	// flute, motifs on the chord tones from G4 up (A A B A A A B D); Complexity adds neighbours, then trills
	(name: \flute, sounds: [\sdSample], level: \fluLevel, roomR: \fluRoom, echoSend: \fluEcho, orbit: 3, ownDelay: [0.75 * 60 / bpm, 0.55], thin: false),
	// JONAS 5 BRASS — from the brass lab (lab/blaeser/disco-blaeser-3): a full section (SSO trumpets, horns, trombones),
	// nine figures with chance rests and drops (a hash: the same every time), Complexity adds pickups, Lift on button 2
	(name: \brass, sounds: [\sdSample], level: \brsLevel, roomR: \brsRoom, echoSend: \brsEcho, orbit: 3, ownDelay: [0.75 * 60 / bpm, 0.55], thin: false),
	// JONAS 6 STRINGS — from the strings lab (lab/streicher/disco-streicher-4): SSO + VSCO string sections, five
	// figures (stabs, runs onto the one, a swell); a note's own echo (0, 0.3, 0.5 × Space) picks its lane
	(name: \strings, sounds: [\sdSample], level: \strLevel, roomR: \strRoom, orbit: 3, ownDelay: [0.75 * 60 / bpm, 0.55], thin: false,
		lanes: [(name: \main, echoSend: \strEcho0), (name: \echo3, echoSend: \strEcho3), (name: \echo5, echoSend: \strEcho5)]),
	// JONAS 7 GUITAR — from the guitar lab (lab/gitarre/disco-gitarre-3): plucked Stratocaster notes (nyanshell.strat,
	// MIT), eight lines on the chord tones; Complexity adds dead notes, a variation, a 16th motor; Lift = phaser
	(name: \guitar, sounds: [\sdSample, \sdSamplePh], level: \gtrLevel, roomR: \gtrRoom, echoSend: \gtrEcho, orbit: 3, ownDelay: [30 / bpm, 0.15], thin: false),
	// LAUNCHKEY MK4 25 — keys: the Rhodes with two detuned copies (orbit 2, mod wheel = level); drum pads: 16 one-shots
	// (orbit 1, at master level, their own room). No Tension echo (the Strudel track gives these notes none).
	(name: \lk, sounds: [\sdSample, \sdFont], level: \lkLevel, tensionEcho: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \shots, orbit: 1, level: 1.0, roomR: 0.3), (name: \rim, orbit: 1, level: 1.0, roomR: 0.3, echoSend: 0.3),
			(name: \oohs, orbit: 1, level: 1.0, roomR: 0.6), (name: \vib, orbit: 1, level: 1.0, roomR: 0.5)]),
],

// Values derived on the server from knobs (they follow the knob at once)
maps: (
	bassTrim: (ccs: [jojo.(4).bright], fn: { |b| 1.55 * (4 * (b - 0.5)).dbamp }),
	bassBlend0: (ccs: [jojo.(4).char], fn: { |v| (v < 0.5) * cos(v * pi) * (v < 0.499) }),
	bassBlend1: (ccs: [jojo.(4).char], fn: { |v| ((v < 0.5) * sin(v * pi) * (v > 0.001)) + ((v >= 0.5) * cos((v - 0.5) * pi) * (v < 0.999)) }),
	bassBlend2: (ccs: [jojo.(4).char], fn: { |v| (v > 0.5) * sin((v - 0.5) * pi) * (v > 0.501) }),
),

// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these). Mod wheel (CC 1) = keys level (× master),
// knob 1 cutoff, 2 resonance, 3 attack, 4 note length, 5 detune, 6 reverb, 7 echo, 8 one-shot darkness. Every key
// plays a note of fixed length (Strudel's midikeys has no note-off: the length is knob 4).
lkCtl: { |ce, num, v, send|
	switch(num,
		1, { ce.setState(\lkLevel, v, send) },
		26, { ce.setState(\lkRoom, 0.9 * 0.8 * v, send) },   // roomOf(knob 6 × 0.8)
		27, { ce.setState(\lkEcho, 0.6 * v, send) })
},
// the pads' names in the web UI (pad 1 = note 36)
lkPadNames: ["brace", "Clap", "Open hat", "Rim", "lw", "Bongo", "Cowbell", "Tom", "Organ", "Brass", "Ooh", "Crash rev",
	"Ride", "Tamb", "Vibes", "Snare"],
lkNote: { |ce, note, vel, chan|
	var k = { |n| ce.lkCC[20 + n] }, nl = 0.25 + (1.75 * k.(4));   // note length in bars
	var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	if(chan != 9) {
		// keys: the Rhodes (jRhodes3d, the keys' samples) and two copies detuned up / down
		var det = 0.04 + (0.26 * k.(5)), cut = 300 * (20 ** k.(1));
		var adsr = ce.sdADSR(0.005 + (0.495 * k.(3)), 1.2, 0.5, 0.8);
		var keysList = [[55, "jrhodes/A_055__G3_3.flac"], [59, "jrhodes/A_059__B3_3.flac"], [62, "jrhodes/A_062__D4_3.flac"], [65, "jrhodes/A_065__F4_3.flac"]];
		[[0, 0.35], [det, 0.15], [det.neg, 0.15]].collect { |x|
			var m = note + x[0], key = keysList[keysList.minIndex { |kk, i| (kk[0] - m).abs + (i * 1e-6) }];
			ce.note(\sdSample, (buf: ce.sampleBuffers[key[1]], stereoIn: 0, rate: 2 ** ((m - key[0]) / 12), amp: x[1] * vel,
				a: adsr[0], d: adsr[1], s: adsr[2], r: adsr[3], hold: nl * 16, lpOn: 1, lo: cut, hi: cut, tone: tone,
				lpq: 12 * k.(2), thinF: thin, lane: \keys, tag: "jrh", g: x[1] * vel, midi: m))
		}
	} {
		// drum pads 36-51 (Drum mode): one-shots; pads 1 and 5 = the spoken samples; pitched shots have their note
		var shots = [
			(file: "voice/brace.wav", tag: "brace"), (file: "tr909/cp-00.wav", tag: "rolandtr909_cp"),
			(file: "tr909/oh-00.wav", tag: "rolandtr909_oh", rate: 0.95), (file: "tr909/rim-00.wav", tag: "rolandtr909_rim", lane: \rim),
			(file: "voice/lw.wav", tag: "lw"), (file: "tr727/perc-02.wav", tag: "rolandtr727_perc"),
			(file: "tr808/cb-00.wav", tag: "rolandtr808_cb", rate: 0.9), (file: "tr909/lt-00.wav", tag: "rolandtr909_lt", rate: 0.9),
			(font: "0160_JCLive_sf2_file", tag: "gm_drawbar_organ", note: 57, adsr: [nil, 0.3, 0, 0.2]),
			(font: "0610_JCLive_sf2_file", tag: "gm_brass_section", note: 69, adsr: [nil, 0.25, 0, 0.2]),
			(font: "0530_Aspirin_sf2_file", tag: "gm_voice_oohs", note: 64, adsr: [0.1, nil, nil, 1], lane: \oohs),
			(file: "tr909/cr-00.wav", tag: "rolandtr909_cr", rate: -0.6), (file: "tr909/rd-00.wav", tag: "rolandtr909_rd"),
			(file: "tr707/tb-00.wav", tag: "rolandtr707_tb"),
			(font: "0110_JCLive_sf2_file", tag: "gm_vibraphone", note: 76, lane: \vib),
			(file: "tr909/sd-00.wav", tag: "rolandtr909_sd", rate: 0.8),
		];
		var sh = shots[(note - 36) % 16], cut = 18000 * ((800 / 18000) ** k.(8));
		var base = (amp: 0.8 * vel, lpOn: 1, lo: cut, hi: cut, tone: tone, thinF: thin, lane: sh[\lane] ? \shots, tag: sh[\tag], g: vel);
		if(sh[\font].notNil) {
			var z = ce.fontNote(sh[\font], sh[\note]), adsr = ce.sdADSR(*(sh[\adsr] ? [nil, nil, nil, nil]));
			z !? { [ce.note(\sdFont, base ++ z ++ (hold: nl * 16, a: adsr[0], d: adsr[1], s: adsr[2], r: adsr[3], midi: sh[\note]))] } ? []
		} {
			// no clip or release: the whole sample
			[ce.note(\sdSample, base ++ (buf: ce.sampleBuffers[sh[\file]], stereoIn: (ce.sampleMono[sh[\file]] != true).asInteger,
				rate: sh[\rate] ? 1, hold: -1))]
		}
	}
},

// Language side: buttons, latches, and each stem's notes (k = 16th number)
build: { |self, ce|
	var stem = { |name| self.stems.detect { |s| s.name == name } ? () };   // a stem left out (solo render): a dummy
	var kick = jojo.(1);
	var bar = { |k| (k / 16).floor };
	// Chapter (4-bar phrase) and Break (next bar)
	self.chapter = ce.latch(4, 0, { |i| ce.status("Chapter", chapterNames[i]); ce.uiPush });
	ce.cycleButton(glob.btn, 2, { |s| self.chapter.pending = s; ce.status("Chapter (next)", chapterNames[s]) });
	self.breakL = ce.latch(1, 0, { |i| ce.status("Break", i); ce.uiPush });
	ce.cycleButton(glob.btn2, 2, { |s| self.breakL.pending = s });
	self.beatOn = { |self, b| self.breakL.atBar(b) == 0 };
	self.tension = glob.char;
	// kick button 2 (held) takes out kick, noise pump and sub at once
	self.lowEnd = { |self, b| self.beatOn(b) and: { ce.held(kick.btn2).not } };

	// HARMONY: Jonas 1 button 1 = the next progression, taking over at the next 8-bar phrase. The chord of a bar:
	// Vamp = Am9, Progression = the chosen progression (keys riffs bring their own chords: not ported yet).
	self.prog = ce.latch(8, 0, { |i| ce.status("Chords", progs[i].name); ce.uiPush });
	ce.uiRows['jonas:1'] = (latch: self.prog, names: progs.collect(_.name));
	ce.cycleButton(jonas.(1).btn, progs.size, { |s| self.prog.pending = s; ce.status("Chords (next)", progs[s].name) });
	// A keys riff (Jonas 2 button 1, entries 7-11) brings its own chords while the keys fader is up: bass, sub,
	// harmony and the melodies follow it (the riff's letter at that 16th; its pushes are in the letters)
	self.riffAt = { |self, b| if(self.ks.isNil or: { self.ks.val[3] <= 0 }) { nil } { self.keyPats[self.keysVar.atBar(b)][2] } };
	self.chordIdAt = { |self, b| var r = self.riffAt(b);
		if(r.notNil) { cid.(r.names[r.seq[(16 * b) % r.seq.size].asSymbol]) } {
			if(self.chapter.atBar(b) == 0) { cid.("Am9") } { progs[self.prog.atBar(b)].ids[b % 8] } } };
	// the chord at 16th k: under a riff exactly its letter at that 16th, else the bar's chord (push: two 16ths early)
	self.chordAtK = { |self, k, push| var r = self.riffAt((k / 16).floor);
		if(r.notNil) { chords[cid.(r.names[r.seq[k % r.seq.size].asSymbol])] } {
			chords[self.chordIdAt(((k + if(push) { 2 } { 0 }) / 16).floor)] } };
	// the keys stay on Am9 unless the progression is Am9 D9 (the old Wechsel)
	self.keysIdAt = { |self, b| if(self.chapter.atBar(b) == 0 or: { self.prog.atBar(b) != 0 }) { cid.("Am9") } { progs[0].ids[b % 8] } };
	// mode of the bar for melodies and bass: dorian (F♯) in Vamp and in Am9 D9, aeolian (F) in the others
	self.modeAt = { |self, b| if(self.chapter.atBar(b) == 0 or: { self.prog.atBar(b) == 0 }) { \dorian } { \aeolian } };

	// KICK
	self.kickVar = ce.change(kick.btn, 3, "Kick", ["4/4", "Gap 4", "Gap 8"]);
	stem.(\kick).notes = { |k|
		var b = bar.(k), v = self.kickVar.atBar(b), beat = (k % 16) / 4;
		var on = (k % 4 == 0) and: { self.lowEnd(b) } and: {
			switch(v,
				0, { true },
				1, { (b % 4 != 3) or: { beat < 3 } },
				2, { (b % 8 != 7) or: { beat < 2 } })
		};
		if(on) { [ce.note(\kick909, (amp: 1, hold: 4, punch: ce.ccMap(kick.char), bright: ce.ccMap(kick.bright),
			tone: ("c" ++ ce.toneBus).asSymbol))] } { [] }
	};

	// BASS
	{
		var bc = jojo.(4);
		var scales = (dorian: [9, 11, 0, 2, 4, 6, 7], aeolian: [9, 11, 0, 2, 4, 5, 7]);
		var steps = ($R: 0, $r: 0, $g: 0, $o: 7, $2: 1, $3: 2, $4: 3, $5: 4, $6: 5, $7: 6, $O: 7, $9: 8, $F: -3);
		var noteToks = "Rr234567Oo9F";
		var tone = { |k, tok|
			var c = self.chordAtK(k, true), sc = scales[self.modeAt((k / 16).floor)], rp = pc.(c.bass);
			var r = 41 + bmd.(rp - 5, 12), j = steps[tok] ? 0, onBass = "RrgOoF".includes(tok);
			var d0 = if(onBass) { sc.indexOf(rp) ? 0 } { "ABCDEFG".indexOf(c.name[0]) };
			var iv = bmd.(sc[bmd.(d0 + j, 7)] - rp, 12);
			r + if(iv == 0 and: { onBass.not }) { 12 } { iv } + (12 * (j / 7).floor)
		};
		var approach = { |line, k|
			var t = 1, n = line.size, tok;
			while { t < 16 and: { noteToks.includes(line[bmd.(k + t, n)]).not } } { t = t + 1 };
			tok = line[bmd.(k + t, n)];
			if(noteToks.includes(tok).not) { tok = $R };
			tone.(k + t, tok) - 1
		};
		self.bassVar = ce.change(bc.btn, bassLines.size, "Bass", bassLines.collect(_.name));
		stem.(\bass).notes = { |k|
			var b = bar.(k), line, n, tok, dur = 1, short, nxt, m, vel, clip, v;
			if(self.beatOn(b).not) { [] } {
				line = bassLines[self.bassVar.atBar(b)].line; n = line.size; tok = line[bmd.(k, n)];
				if(tok == $. or: { tok == $- }) { [] } {
					while { dur < n and: { line[bmd.(k + dur, n)] == $- } } { dur = dur + 1 };
					short = (tok == $r) or: { tok == $o };
					nxt = line[bmd.(k + dur, n)];
					m = if(tok == $A) { approach.(line, k) } { tone.(k, tok) } + if(ce.held(bc.btn2)) { 12 } { 0 };
					// touch as the lab: off-beat 8ths full, the rest a little softer, dead notes quiet, short, duller
					vel = if(tok == $g) { 0.3 } { if(bmd.(k, 4) == 2) { 1 } { if(bmd.(k, 2) == 1) { 0.8 } { 0.9 } } };
					clip = 0.933 * if(tok == $g) { 0.35 } { if(short) { 0.4 } { if(nxt == $.) { 0.85 } { 1.02 } } };
					v = ce.val(bc.char);
					bassSounds.collect { |sg, i|
						if(bassBlend[i].(v) > 0) {
							ce.note(sg[0], (freq: m.midicps, amp: sg[1] * vel, hold: dur * clip,
								at: if(k.odd) { 0.12 } { 0 },   // swing 56 %: the off 16ths a little late
								bright: ce.ccMap(bc.bright), tone: ("c" ++ ce.toneBus).asSymbol,
								dark: (tok == $g).binaryValue, level: ("c" ++ ce.mapBus[("bassBlend" ++ i).asSymbol]).asSymbol,
								midi: m, len16: dur * clip, vel: vel,
								// comparisons only: the modulator phase superdough has offline (started at time 0)
								modPhase: if(ce.webaudioPhase == true) { (2pi * m.midicps * ((k + if(k.odd) { 0.12 } { 0 }) / 4 / (bpm / 60))) % 2pi } { -1 }))
						}
					}.reject(_.isNil)
				}
			}
		};
	}.value;

	// ---- helpers for the drum and synth voices (superdough semantics, see sounds/sd*.scd) ----
	{
		var tone = ("c" ++ ce.toneBus).asSymbol, fog = ("c" ++ ce.fogBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
		var adsr = { |a, d, s, r, def| var v = ce.sdADSR(a, d, s, r, def); (a: v[0], d: v[1], s: v[2], r: v[3]) };
		var synthDef = [0.001, 0.05, 0.6, 0.01];
		// a sample note: tag = Strudel's bank_s:n (for the comparison), g = Strudel's gain
		var smp = { |rel, tag, g, args| ce.note(\sdSample, (buf: ce.sampleBuffers[rel], stereoIn: (ce.sampleMono[rel] != true).asInteger,
			amp: g, hold: -1, thinF: thin, tag: tag, g: g) ++ adsr.(nil, nil, nil, nil) ++ (args ? ())) };
		var ramp = { |v, from, to| ((v - from) / (to - from)).clip(0, 1) };
		var t16 = { |k| k / 16 };   // cycle time of 16th k

		// JOJO 2 NOISE PUMP
		var nc = jojo.(2);
		self.noiseVar = ce.change(nc.btn, 3, "Noise Pump", ["Pump", "Off-beat", "16ths"]);
		self.riserStart = nil;
		stem.(\noise).notes = { |k|
			var b = bar.(k), t = t16.(k), out = List[], v, m, w, p, r;
			// riser: 0 → 1 over 2 bars while button 2 is held. Strudel reads knobs and buttons per bar (midin's ref is a
			// pattern with one event per cycle), so signals combined with them are read at the bar start: the ramp rises
			// in steps per bar, and Motion's sines are read at the bar start too.
			if(ce.held(nc.btn2)) { self.riserStart = self.riserStart ? t.floor } { self.riserStart = nil };
			if(self.lowEnd(b)) {
				v = self.noiseVar.atBar(b); m = ce.val(nc.char);
				w = ce.sine(t.floor / 2); p = ce.sine(t.floor / 3);
				[
					{ if(k % 4 == 1) { [3, 1.4, adsr.(0.1, nil, 0.5, 0.02, synthDef), 2000] } },
					{ if(k % 4 == 2) { [2, 1.4, adsr.(0.04, nil, 0.4, 0.04, synthDef), 3000] } },
					{ if(k % 4 != 0) { [1, [0.6, 1, 0.7][k % 4 - 1] * 1.4, adsr.(0.01, 0.05, 0, nil, synthDef), 4000] } }
				][v].value !? { |n|
					out.add(ce.note(\sdNoise, (color: 0, amp: n[1], hold: n[0], lane: \pump, hp: n[3], thinF: thin,
						lpOn: 1, bright: ce.ccMap(nc.bright), lo: 2000, hi: 14000, tone: tone, cutMul: 1 - (0.7 * m * w),
						pan: 0.5 + (m * (p - 0.5)), tag: "pink", g: n[1]) ++ n[2]))
				}
			};
			if(self.riserStart.notNil) {
				r = ((t.floor - self.riserStart) / 2).clip(0, 1);
				if(r > 0) { out.add(ce.note(\sdNoise, (color: 0, amp: r * 0.35, hold: 1, lane: \riser, thinF: thin,
					bp: 300 * (20 ** r), bpq: 4, pan: ce.sine(t * 2), tag: "pink", g: r * 0.35) ++ adsr.(0.03, nil, 0.8, 0.15, synthDef))) }
			};
			out
		};

		// JOJO 3 SUB — on the chord's root (per 16th: under a keys riff the chord may change inside a bar)
		{
			var sc = jojo.(3);
			self.subVar = ce.change(sc.btn, 3, "Sub", ["Pump", "Off-beat", "Half"]);
			stem.(\sub).notes = { |k|
				var b = bar.(k), v, dur, m, clip, env;
				if(self.lowEnd(b).not) { [] } {
					v = self.subVar.atBar(b);
					dur = switch(v, 0, { if(k % 4 == 1) { 3 } }, 1, { if(k % 4 == 2) { 2 } }, 2, { if(k % 8 == 1) { 7 } });
					if(dur.isNil) { [] } {
						m = self.chordAtK(k, false).bass + if(ce.held(sc.btn2)) { 12 } { 0 };
						clip = 1 - (0.65 * ce.val(sc.char));
						env = adsr.(0.015, nil, 1, 0.04, synthDef);
						[
							ce.note(\sdSynth, (wave: 0, freq: m.midicps, amp: 0.5, hold: dur * clip, thinF: thin, tag: "sine", g: 0.5, midi: m) ++ env),
							ce.note(\sdSynth, (wave: 1, freq: m.midicps, amp: 0.1 + (0.17 * ce.val(sc.bright)), hold: dur * clip, thinF: thin,
								tag: "triangle", g: 0.1 + (0.17 * ce.val(sc.bright)), midi: m) ++ env)
						]
					}
				}
			};
		}.value;

		// JOJO 5 CLAP
		{
			var cc = jojo.(5);
			var lp = { (lpOn: 1, bright: ce.ccMap(cc.bright), lo: 3500, hi: 14000, tone: fog, hp: 300, pan: 0.48) };
			var hit = { |rel, tag, g| smp.(rel, tag, g * 0.8, lp.()) };
			self.clapVar = ce.change(cc.btn, 3, "Clap", ["2 + 4", "Pickup", "Fill 4"]);
			stem.(\clap).notes = { |k|
				var b = bar.(k), s16 = k % 16, out = List[], c = ce.val(cc.char), g, tr;
				g = switch(self.clapVar.atBar(b),
					0, { Dictionary[4 -> 0.8, 12 -> 0.8][s16] },
					1, { Dictionary[4 -> 0.8, 12 -> 0.8, 15 -> 0.35][s16] },
					2, { if(b % 4 == 3) { Dictionary[4 -> 0.8, 12 -> 0.8, 14 -> 0.5][s16] } { Dictionary[4 -> 0.8, 12 -> 0.8][s16] } });
				g !? { out.add(hit.("tr909/cp-00.wav", "RolandTR909_cp:0", g)) };
				if(c > 0 and: { s16 == 8 }) { out.add(hit.("tr909/rim-00.wav", "RolandTR909_rim:0", 0.25 * ramp.(c, 0, 0.5))) };
				if(c > 0.5) { Dictionary[6 -> 0.18, 14 -> 0.15][s16] !? { |x| out.add(hit.("tr909/rim-00.wav", "RolandTR909_rim:0", x * ramp.(c, 0.5, 1))) } };
				if(ce.held(cc.btn2)) { out.add(hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.1 + (0.4 * (t16.(k) % 1)))) };
				tr = ramp.(ce.val(self.tension), 0.5, 1);
				if(tr > 0 and: { ce.rand(t16.(k)) >= (0.5 * (1 - tr)) }) { out.add(hit.("tr909/sd-00.wav", "RolandTR909_sd:0", 0.1 + (0.35 * tr))) };
				out.reject { |n| n.amp <= 0 }
			};
		}.value;

		// JOJO 6 HATS / SHAKER
		{
			var hc = jojo.(6);
			var lp = { (lpOn: 1, bright: ce.ccMap(hc.bright), lo: 4000, hi: 16000, tone: fog, pan: 0.56) };
			var open = [0.5, 0.5, 0.45];
			var closed = [Dictionary[3 -> 0.12], Dictionary[0 -> 0.2, 1 -> 0.1, 3 -> 0.15], Dictionary[0 -> 0.26, 1 -> 0.13, 3 -> 0.2]];
			self.hatVar = ce.change(hc.btn, 3, "Hats / Shaker", ["Off-beat", "+ 16ths", "Driving"]);
			stem.(\hats).notes = { |k|
				var b = bar.(k), v = self.hatVar.atBar(b), mix = ce.val(hc.char), out = List[], fm, fx, g;
				fm = ramp.(mix, 1, 0.5); fx = ramp.(mix, 0, 0.5) * 2.5;
				if(k % 4 == 2) {
					out.add(smp.("tr909/oh-00.wav", "RolandTR909_oh:0", open[v] * fm * 0.9, lp.() ++ adsr.(nil, 0.15, 0, nil)));
					out.add(smp.("tr727/sh-00.wav", "RolandTR727_sh:0", open[v] * fx * 0.9, lp.()));
				};
				closed[v][k % 4] !? { |c|
					var sw = if(k.odd) { 0.2 } { 0 };   // swing 0.2: the off 16ths a little late
					out.add(smp.("tr909/hh-00.wav", "RolandTR909_hh:0", c * fm * 0.9, lp.() ++ (at: sw)));
					out.add(smp.("tr727/sh-01.wav", "RolandTR727_sh:1", c * fx * 0.9, lp.() ++ (at: sw)));
				};
				if(ce.held(hc.btn2) and: { k.even }) { out.add(smp.("tr909/oh-00.wav", "RolandTR909_oh:0", 0.3 * 0.9, lp.() ++ adsr.(nil, 0.22, 0, nil))) };
				out.reject { |n| n.amp <= 0 }
			};
		}.value;

		// JOJO 7 CONGAS
		{
			var pc7 = jojo.(7);
			var files = Dictionary[2 -> "tr727/perc-02.wav", 3 -> "tr727/perc-03.wav", 4 -> "tr727/perc-04.wav"];
			var lines = ["4 ~ ~ 2 ~ ~ 3 ~ 4 ~ ~ 2 ~ 3 ~ ~", "~ ~ 4 2 ~ ~ 4 ~ ~ 3 ~ 2 ~ ~ 4 ~", "3 ~ 2 ~ 4 ~ 2 3 ~ 2 ~ 4 ~ ~ 2 ~"]
				.collect { |l| l.split($ ).collect { |x| if(x == "~") { nil } { x.asInteger } } };
			var fill = "2 2 3 3 2 3 4 4 2 2 3 3 4 3 4 4".split($ ).collect(_.asInteger);
			var hit = { |n, g, t| smp.(files[n], "RolandTR727_perc:" ++ n, g,
				(lpOn: 1, bright: ce.ccMap(pc7.bright), lo: 1000, hi: 12000, tone: tone, pan: 0.35 + (0.3 * ce.sine(t / 4)))) };
			self.percVar = ce.change(pc7.btn, 3, "Congas", ["Pillow", "Rolling", "Latin"]);
			stem.(\perc).notes = { |k|
				var b = bar.(k), t = t16.(k), s16 = k % 16, out = List[], c = ce.val(pc7.char), r;
				lines[self.percVar.atBar(b)][s16] !? { |n| out.add(hit.(n, 0.18 + (0.08 * ce.perlin(t)), t)) };
				r = ce.rand(t);
				if(c > 0 and: { r >= 0.55 }) { out.add(hit.((r * 2).trunc.asInteger + 2, c * 0.08, t)) };
				if(ce.held(pc7.btn2)) { out.add(hit.(fill[s16], 0.22, t)) };
				out.reject { |n| n.amp <= 0 }
			};
		}.value;

	// Strudel's swingBy(0.12, 8) for any onset p (in 16ths): an onset in the first half of an 8th stays; one in the second
	// half comes 0.12 of a 16th later, and is lost if that pushes it past the 8th. An onset just before the middle
	// (within 0.12) plays twice: as it is, and pushed into the second half (both are what Strudel's swing yields).
	self.swingAt = { |self, p| var u = p % 2;
		if(u < 1) { if((u + 0.12) >= 1) { [0, 0.12] } { [0] } } { if((u + 0.12) < 2) { [0.12] } { [] } } };
	// ---- Jonas' lab columns: the column's state as in the labs. Knobs and fader start at the lab's values and keep
	// them until they are moved (Strudel: the first query ignores a control at 0); button 2 = echo throw while held.
	// update: (state, send) → the state buses (level, room, echo)
	self.labCol = { |self, n, start, update|
		var c = jonas.(n), st = (val: start.copy, held: false);
		[c.bright, c.space, c.char, c.level].do { |cc, i| ce.onCC(cc, { |v, send| st.val[i] = v; update.(st, send); ce.uiPush }) };
		ce.onCC(c.btn2, { |v, send| var h = v > 0.5; if(h != st.held) { st.held = h; update.(st, send); ce.uiPush } });
		st
	};
	// the labs' channel strip: room from 0.35 of Space, the 1/8 echo first (full at half the knob)
	self.labRoom = { |self, sp| 0.8 * ((sp - 0.35) / 0.65).max(0) };
	self.labEcho = { |self, sp| if(sp > 0) { (0.4 + (1.2 * sp)).min(1) } { 0 } };
	self.tensionEcho = { |self| (ce.val(glob.char) / 0.5).clip(0, 1) * 0.45 };
	// the echo of orbit 3 as a note sets it (superdough: every note with an echo sets the orbit's time and feedback)
	// each lab column has its own echo (ownDelay): the notes set its time / feedback, as superdough's orbit echo
	self.labEchoMsg = { |self, st, at = 0, stem = \harm|
		var ev = self.labEcho(st.val[1]), d = (if(st.held) { 0.65 } { 0.6 * ev }).max(self.tensionEcho);
		if(d > 0) {
			var tf = if(st.held) { [0.75 * 60 / bpm, 0.62] } { [30 / bpm, 0.15 + (0.35 * ev)] };
			[(msg: [\n_set, ce.stemDelayNode[stem], \time, tf[0], \feedback, tf[1]], at: at)]
		} { [] }
	};

	// JONAS 1 HARMONY
	{
		var voicing = (Am9: [55, 59, 60, 64], D9: [54, 57, 60, 64], Am7: [55, 57, 60, 64], Cmaj7: [55, 59, 60, 64],
			Em7: [55, 59, 62, 64], Fmaj7: [53, 57, 60, 64], Fadd9: [53, 55, 57, 60], Gadd9: [55, 57, 59, 62], G11: [53, 55, 60, 62],
			Dm7: [53, 57, 60, 62], Gm: [55, 58, 62, 65], 'Em/G': [55, 59, 62, 64], Dm9: [52, 53, 57, 60], Gm9: [53, 57, 58, 62],
			Bm: [59, 62, 66, 71]);
		// four notes from E3 (52) up with the voicing's pitch classes
		var harmNotes = { |name| var pcs = voicing[name.asSymbol].collect(pc); (52..76).select { |m| pcs.includes(pc.(m)) }.keep(4) };
		var nameAt = { |k| self.chordAtK(k, true).name };
		var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
		var hs = self.labCol(1, [0.6, 0, 0.3, 0], { |st, send|
			ce.setState(\harmLevel, st.val[3] * (4 * (st.val[0] - 0.5)).dbamp, send);
			ce.setState(\harmRoom, self.labRoom(st.val[1]), send);
			ce.setState(\harmEcho, if(st.held) { 0.65 } { 0.6 * self.labEcho(st.val[1]) }, send);
			// long chords: the low-pass (row 1) and the strings ↔ organ blend (row 3) act on the sounding chord
			ce.setState(\harmCut, (400 * (15 ** st.val[0])).min(18000), send);
			ce.setState(\harmJx, cos(st.val[2] * 0.5pi) * (st.val[2] < 0.999).binaryValue, send);
			ce.setState(\harmB3, sin(st.val[2] * 0.5pi) * (st.val[2] > 0.001).binaryValue, send);
		});
		self.hs = hs;
		stem.(\harm).notes = { |k|
			var name = nameAt.(k), c = k, start, e, out = List[], t = k / 16, v, jx, b3, vel, at, cut, env;
			// held chords (lab padPat): a chord starts where it changes, and again every 4 bars (64 16ths)
			while { c > (k - 64) and: { nameAt.(c - 1) == name } } { c = c - 1 };
			if(c == (k - 64)) { c = 64 * (k / 64).floor };
			start = c + (64 * ((k - c) / 64).floor);
			if(start != k) { [] } {
				e = k + 1;
				while { (e - k) < 64 and: { nameAt.(e) == name } } { e = e + 1 };
				v = hs.val[2]; jx = cos(v * 0.5pi) * (v < 0.999).binaryValue; b3 = sin(v * 0.5pi) * (v > 0.001).binaryValue;
				vel = 0.85 + (0.15 * ce.perlin(t)); at = if(k.odd) { 0.12 } { 0 };
				// both layers always: their blend (row 3) and the low-pass follow the knobs while the chord sounds
				cut = ce.stateMap(\harmCut);
				harmNotes.(name).do { |m|
					var lp = (lpOn: 1, lo: cut, hi: cut, tone: tone, thinF: thin, at: at, hold: e - k);
					env = (a: 0.35, d: 0.1, s: 1, r: 0.8);
					[[m, 0.08, 0.6, 0.5], [m + 0.1, 0.05, 0.9, 0.3]].do { |x|
						out.add(ce.note(\sdSupersaw, (freq: x[0].midicps, unison: 2, detune: x[1], spread: x[2], amp: x[3] * 0.24 * vel,
							mix: ce.stateMap(\harmJx), nolog: jx <= 0, tag: "supersaw", g: x[3] * 0.24 * jx * vel, midi: x[0]) ++ lp ++ env))
					};
					env = (a: 0.06, d: 0.001, s: 1, r: 0.25);
					[[0, 0.14], [12, 0.11]].do { |dg| [[-0.04, 0.3], [0.04, 0.7]].do { |dp|
						var mm = m + dg[0] + dp[0], g = dg[1] * 0.47 * vel;
						out.add(ce.note(\sdSynth, (wave: 0, freq: mm.midicps, vib: 0.8, vibmod: 0.08, pan: dp[1], amp: g,
							mix: ce.stateMap(\harmB3), nolog: b3 <= 0, tag: "sine", g: g * b3, midi: mm) ++ lp ++ env))
					} };
				};
				out ++ self.labEchoMsg(hs, at, \harm)
			}
		};
	}.value;

	// JONAS 2 KEYS
	{
		var kc = jonas.(2);
		var rb = { |...bars| bars.join };
		var riff = { |name, rhythm, seq, voic, names| [name, rhythm, (seq: seq, voic: voic, names: names)] };
		var keyPats = [
			["Chain", ".x..x..x.x..x..x", nil], ["Shifted chain", "...x..x..x.x..x.", nil], ["Pairs", ".x.x..x..x.x..x.", nil],
			["3-3-2", "x..x..x...x..x..", nil], ["Kerri syncopation", "..x..x...x.x..x.", nil], ["Kerri-Riff", "x..x..x..x..x.x.", nil],
			riff.("Kerri video", "x..x..x..x..x.x.", "AAAAAADDDDDDDDGG",
				(A: [55, 59, 60, 64], D: [48, 52, 53, 57], G: [53, 57, 58, 62]), (A: "Am9", D: "Dm9", G: "Gm9")),
			riff.("Checkmate", rb.("..x..x..x.x..x.x", "..x..x..x.x..x.x"), rb.("AAAAAAAAAAAAAAAG", "GGGGGGGGGGGGGGGA"),
				(A: [57, 60, 64], G: [58, 62, 67]), (A: "Am7", G: "Gm")),
			riff.("Atmosphere", rb.("..x...x...x...x.", "..x...x...x..x.."), rb.("MMMMMMMMMMfMMMMM", "qqqqqqqqqqqqqqqq"),
				(M: [55, 57, 60, 64], f: [55, 57, 62, 64], q: [55, 59, 64]), (M: "Am7", f: "Am7", q: "Em/G")),
			riff.("Turn Off", rb.("x..x..x..x..x.x.", "..x..x..x...x..x"), rb.("AAAAAADDDDDDEEEE", "bbbbbvvvvvvvbbbA"),
				(A: [57, 60, 64], D: [57, 62, 65], E: [59, 64, 67], b: [59, 62, 66], v: [54, 59, 62]), (A: "Am7", D: "Dm7", E: "Em7", b: "Bm", v: "Bm")),
			riff.("Chicago", rb.("x...x...x-.x..x.", "..x..x.....x....", "x...x...x-.x..x.", "..x..x.....x...."),
				rb.("AAAAAAAAAAAAAACC", "CCCCCCCCCCCCCCCC", "FFFFFFFFFFFFFFDD", "DDDDDDDDDDDDDDDD"),
				(A: [55, 59, 60, 64], C: [55, 59, 62, 64], F: [57, 60, 64, 65], D: [54, 57, 60, 64]), (A: "Am9", C: "Cmaj7", F: "Fmaj7", D: "D9")),
		];
		var isHit = { |c| c != $. and: { c != $- } };
		var gapT = { |p, i| var d = 1; while { d < p.size and: { isHit.(p[(i + d) % p.size]).not } } { d = d + 1 }; (0.2 + (0.2 * d)).min(0.9) };
		// touch (lab round 11): a hit before a longer rest harder; the loop's level normalised to plain velocity
		var touch = keyPats.collect { |kp|
			var p = kp[1], hits = (0..p.size - 1).select { |i| isHit.(p[i]) }, mean = hits.collect { |i| gapT.(p, i) }.sum / hits.size;
			var t = (0..p.size - 1).collect { |i| if(isHit.(p[i])) { (0.5 + ((gapT.(p, i) - mean) * 4 * 0.25)).clip(0, 1) } { 0 } };
			var w = p.as(Array).collect { |c| if(c == $x) { 0.64 } { 0 } }.sum;
			var d = (0..p.size - 1).collect { |i| if(isHit.(p[i])) { (0.8 * (0.6 + (0.8 * t[i]))).squared } { 0 } }.sum;
			(touch: t, norm: (w / d).sqrt)
		};
		var voicing = (Am9: [55, 59, 60, 64], D9: [54, 57, 60, 64]);
		var m1k = 0.42, keyLevel = 0.88;
		// piano: the Steinway samples (closest key, transposed); Rhodes: jRhodes3d
		var steinKeys = [[54, "F#3"], [56, "G#3"], [58, "A#3"], [60, "C4"], [62, "D4"], [64, "E4"]].collect { |x| [x[0], "repo:vcsl-keys/JHPiano_Sus_Close_" ++ x[1] ++ "_vl3_rr1.flac"] };
		var rhodesKeys = [[55, "jrhodes/A_055__G3_3.flac"], [59, "jrhodes/A_059__B3_3.flac"], [62, "jrhodes/A_062__D4_3.flac"], [65, "jrhodes/A_065__F4_3.flac"]];
		var closest = { |keysList, n| var best = keysList[0]; keysList.do { |x| if((x[0] - n).abs < (best[0] - n).abs) { best = x } }; best };
		var range = (piano: [250, 8100], rhodes: [250, 2000], b3: [250, 2000], m1: [250, 5000], vibes: [250, 4000], marimba: [250, 3000]);
		var sweep = { |v| if(v < (1/3)) { [3 * v, 0] } { if(v > (2/3)) { [3 - (3 * v), 1] } { [1, (3 * v) - 1] } } };
		var xfade = { |c| [cos(c * 0.5pi), sin(c * 0.5pi)].collect { |x| if(x < 1e-6) { 0 } { x } } };
		var pairLevels = { |v, dip = 0| var lc = sweep.(v), ab = xfade.(lc[1]), d = (dip.neg * sin(pi * lc[1])).dbamp; [lc[0] * ab[0] * d, lc[0] * ab[1] * d] };
		var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
		var ks = (val: [0.6, 0, 0, 0], mix: [0.5, 0, 0], e: 0.5, shift: 0);
		var update = { |send|
			ce.setState(\keysLevel, ks.val[3], send);
			ce.setState(\keysRoom, self.labRoom(ks.val[1]), send);
			ce.setState(\keysEcho, 0.6 * self.labEcho(ks.val[1]), send);
		};
		self.keyPats = keyPats; self.ks = ks;
		self.keysVar = ce.change(kc.btn, keyPats.size, "Keys", keyPats.collect(_[0]));
		// Sound (button 2): every press on / off; with it on the knobs mix the sound, the fader sets the overtones
		ce.cycleButton(kc.btn2, 2, { |sh| ks.shift = sh; ce.status("Keys", if(sh == 1) { "SOUND" } { "normal" }); ce.uiPush });
		[kc.bright, kc.space, kc.char, kc.level].do { |cc, i| ce.onCC(cc, { |v, send|
			if(ks.shift == 1) { if(i < 3) { ks.mix[i] = v } { ks.e = v } } { ks.val[i] = v };
			update.(send); ce.uiPush }) };
		stem.(\keys).notes = { |k|
			var b = bar.(k), step = k % 16, pix = self.keysVar.atBar(b), kp = keyPats[pix], pat = kp[1], rf = kp[2];
			var pos = if(rf.notNil) { k % pat.size } { step }, sym = pat[pos], ties = 0, notes, out = List[];
			var br, sp, len, kt, hitT, hitGain, hitCut, res, tGain, tAtk, ev, dur, layers, at, tEcho;
			if(isHit.(sym).not) { [] } {
				while { (pos + ties + 1) < pat.size and: { pat[pos + ties + 1] == $- } } { ties = ties + 1 };
				notes = if(rf.notNil) { rf.voic[rf.seq[pos].asSymbol] } {
					var ch = chords[self.keysIdAt(if(step >= 14) { b + 1 } { b })]; voicing[ch.name.asSymbol] ? ch.tones };
				#br, sp, len = ks.val;
				kt = touch[pix]; hitT = kt.touch[pos];
				hitGain = (0.6 + (0.8 * hitT)) * kt.norm * 0.8;
				hitCut = 2 ** (8 * ks.e * (hitT - 0.5));
				res = 4 + (8 * ((br - (2/3)) * 3).max(0)); tGain = (4 * (br - 0.5)).dbamp; tAtk = if(br < 0.3) { 0.02 * (1 - (br / 0.3)) } { 0 };
				ev = self.labEcho(sp); tEcho = self.tensionEcho;
				dur = (1 + ties) * (4 ** len);   // 16ths
				at = if(k.odd) { 0.12 } { 0 };
				layers = [[\piano, pairLevels.(ks.mix[0], -1.3)[0]], [\rhodes, pairLevels.(ks.mix[0], -1.3)[1]],
					[\b3, pairLevels.(ks.mix[1], 1.3)[0]], [\m1, pairLevels.(ks.mix[1], 1.3)[1]],
					[\vibes, pairLevels.(ks.mix[2])[0]], [\marimba, pairLevels.(ks.mix[2])[1]]].select { |l| l[1] > 0 };
				layers.do { |l|
					var src = l[0], cut = range[src][0] * ((range[src][1] / range[src][0]) ** br) * hitCut;
					var base = (lpOn: 1, lo: cut, hi: cut, tone: tone, lpq: res, thinF: thin, hold: dur, at: at, pan: 0.47);
					var gainOf = { |g| keyLevel * g * 0.955 * hitGain * tGain * l[1] };
					notes.do { |n|
						switch(src,
							\piano, { var key = closest.(steinKeys, n), g = gainOf.(0.6 * 0.49 / 0.955 * 0.99);
								out.add(ce.note(\sdSample, base ++ (buf: ce.sampleBuffers[key[1]], stereoIn: 1, rate: 2 ** ((n - key[0]) / 12),
									amp: g, a: tAtk.max(0.001), d: 0.001, s: 1, r: 0.15, tag: "stein", g: g, midi: n))) },
							\rhodes, { var key = closest.(rhodesKeys, n), g = gainOf.(0.6 * 0.292 / 0.955 * 0.902);
								out.add(ce.note(\sdSample, base ++ (buf: ce.sampleBuffers[key[1]], stereoIn: 0, rate: 2 ** ((n - key[0]) / 12),
									amp: g, a: tAtk.max(0.001), d: 0.001, s: 1, r: 0.15, tag: "jrh", g: g, midi: n))) },
							\b3, { [0, 19, 12].do { |d, j| [-0.04, 0.04].do { |dt, side|
								var g = gainOf.([0.12, 0.07, 0.1][j] * 1.82 * 0.85), m = n + d + dt;
								out.add(ce.note(\sdSynth, base ++ (wave: 0, freq: m.midicps, vib: 0.8, vibmod: 0.08, pan: [0.3, 0.7][side],
									amp: g, a: 0.004.max(tAtk), d: 0.001, s: 1, r: 0.15, tag: "sine", g: g, midi: m))) } } },
							\m1, { [[3, 12, 0.22, 0.002, 0.25, 0.7], [0, 24, 0.18, 0.002, 0.25, 0.7], [0, 31, 0.25, 0.001, 0.08, 0]].do { |x|
								var g = gainOf.(x[2] * m1k * 1.85), m = n + x[1];
								out.add(ce.note(\sdSynth, base ++ (wave: x[0], freq: m.midicps, amp: g, a: x[3].max(tAtk), d: x[4], s: x[5], r: 0.15,
									tag: if(x[0] == 3) { "square" } { "sine" }, g: g, midi: m))) } },
							// General MIDI soundfonts (Strudel gm_vibraphone, gm_marimba: their first preset)
							\vibes, { var g = gainOf.(0.65 * 0.91), z = ce.fontNote("0110_JCLive_sf2_file", n - 12);
								z !? { out.add(ce.note(\sdFont, base ++ z ++ (amp: g, a: tAtk.max(0.001), d: 0.001, s: 1, r: 0.15,
									tag: "gm_vibraphone", g: g, midi: n - 12))) } },
							\marimba, { var g = gainOf.(0.7 * 1.38), z = ce.fontNote("0120_JCLive_sf2_file", n);
								z !? { out.add(ce.note(\sdFont, base ++ z ++ (amp: g, a: tAtk.max(0.001), d: 0.001, s: 1, r: 0.15,
									tag: "gm_marimba", g: g, midi: n))) } }
						)
					}
				};
				if((0.6 * ev).max(tEcho) > 0) { out.add((msg: [\n_set, ce.orbitDelayNode[4], \time, 30 / bpm, \feedback, 0.15 + (0.35 * ev)], at: at)) };
				out
			}
		};
	}.value;

	// JONAS 3 VIBRAPHONE — the Strudel phrases in mini-notation (~ce.mini), the random choices with Strudel's rand at
	// the same times: Complexity 0 = the core → from 15 % the written figure → from 45 % random fills → from 75 %
	// random doubles (ply 2) and neighbour notes (+1). Space = the lab's echo + room and longer notes (×4 … ×16).
	{
		var vc = jonas.(3), level = 0.7;
		var vs = self.labCol(3, [0.6, 0, 0.3, 0], { |st, send|
			ce.setState(\vibLevel, st.val[3] * level * (4 * (st.val[0] - 0.5)).dbamp, send);
			ce.setState(\vibRoom, self.labRoom(st.val[1]), send);
			ce.setState(\vibEcho, if(st.held) { 0.65 } { 0.6 * self.labEcho(st.val[1]) }, send);
		});
		// a mini string as a table: 16th of the period → [[offset in the 16th, length in 16ths, value]]
		var table = { |str| var m = ce.mini(str), t = Dictionary[];
			m.events.do { |e| var p = e[0] * 16, k = p.floor.asInteger; t[k] = (t[k] ? []).add([p - k, e[1] * 16, e[2]]) };
			(period: m.period * 16, steps: t) };
		// the Escravos call (Strudel: g5 … d5, b4 …), two octaves lower as the track plays it (vibLower −2)
		var call = ["[g3@3 ~ f#3 e3@2 d3@7 ~ d3]", "[c3@2 b2 c3@2 e3@2 d3@5 ~@4]"];
		var phrases = [
			[\offbeat, "[~ ~ ~ 1 ~@5 3 ~@6]", "<[~ 0 ~ ~ ~@2 2 ~@5 2 ~ 1 ~]!7 [~ 0 ~ ~ ~@2 2 ~@5 3 ~ 4 ~]>",
				"[~ ~ 4 ~ 3 1 ~ 5 2 ~ 4 0 ~ 3 ~ 5]"],
			[\tresillo, "[0 ~ ~ 4 ~ ~ 0 ~@9]", "<[~@10 -1 ~ 2 ~@3]!3 [~@10 2 ~ [4 4] ~@3]>", "[~ 2 ~ ~ 1 ~ ~ 4 ~ 3 ~ 4 ~ 5 4 ~]"],
			[\call, "<~ ~ ~ ~ ~ ~ " ++ call.join(" ") ++ ">", nil, nil],
		].collect { |p| (kind: p[0], layers: p[1..].collect { |s| s !? { table.(s) } }) };
		var names = ["Off-beat", "Tresillo", "Call echo"];
		var degOf = (9: 0, 11: 1, 0: 2, 2: 3, 4: 4, 5: 5, 7: 6);
		var modeSteps = (dorian: [0, 2, 3, 5, 7, 9, 10], aeolian: [0, 2, 3, 5, 7, 8, 10]);
		var pool = ();
		var voicingOf = { |c| (Am9: [55, 59, 60, 64], D9: [54, 57, 60, 64])[c.name.asSymbol] ? c.tones };
		var chordNotes = { |c| pool[c.name.asSymbol] ?? { var pcs = (voicingOf.(c)).collect(pc);
			pool[c.name.asSymbol] = (52..76).select { |m| pcs.includes(pc.(m)) }.keep(8); pool[c.name.asSymbol] } };
		// the sample of a note: the closest key of the map (first one in the map's order on a tie), transposed
		var keys = [45, 69, 59, 48, 72, 62, 52, 76, 41, 65, 55];
		var files = ["A2", "A4", "B3", "C3", "C5", "D4", "E3", "E5", "F2", "F4", "G3"].collect { |n| "vibraphone/Vibes_hard_" ++ n ++ "_v3_rr1_Main.flac" };
		var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
		// the events of one phrase that start in 16th k, after Complexity's layers and doubles: [begin (16ths), length, value, plus]
		var eventsAt = { |ph, k|
			var cx = vs.val[2], out = List[];
			var x1 = if(cx < 0.75) { 0 } { 0.35 * (cx - 0.75) / 0.25 }, x2 = if(cx < 0.75) { 0 } { 0.2 * (cx - 0.75) / 0.25 };
			var xRest = if(cx > 0.15) { 0 } { 1 }, xFill = if(cx < 0.45) { 1 } { 1 - (0.7 * (cx - 0.45) / 0.55) };
			// a double's second half can start up to half a note later: look back over the longest note
			(k - 8 .. k).do { |j|
				ph.layers.do { |lay, li|
					if(lay.notNil) {
						(lay.steps[j % lay.period] ? []).do { |e|
							var p = j + e[0], r = ce.rand(p / 16);
							// degradeBy: keep when rand > amount (core: always)
							if(li == 0 or: { r > [0, xRest, xFill][li] }) {
								// sometimesBy(x1, ply 2): rand > x1 as it is, 1 − rand > 1 − x1 doubled
								var parts = if(r > x1) { [[p, e[1]]] } { if((1 - r) > (1 - x1)) { [[p, e[1] / 2], [p + (e[1] / 2), e[1] / 2]] } { [] } };
								parts.do { |q| if(q[0].floor == k) {
									var r2 = ce.rand(q[0] / 16);
									// sometimesBy(x2, add 1)
									if(r2 > x2) { out.add([q[0], q[1], e[2], 0]) } { if((1 - r2) > (1 - x2)) { out.add([q[0], q[1], e[2], 1]) } }
								} }
							}
						}
					}
				}
			};
			out
		};
		self.vs = vs;
		self.vibVar = ce.change(vc.btn, phrases.size, "Vibraphone", names);
		stem.(\vibes).notes = { |k|
			var ph = phrases[self.vibVar.atBar(bar.(k))], br = vs.val[0], clip = 4 * (4 ** vs.val[1]);
			var cut = (600 * (20 ** br)).min(18000), out = List[];
			eventsAt.(ph, k).do { |e|
				var p = e[0], t = p / 16, m, key, vel;
				m = switch(ph[\kind],
					// arp: the chord's notes from E3 up (the chord two 16ths early), index = the value
					\offbeat, { var ns = chordNotes.(self.chordAtK((p + 0.5).floor.asInteger, true)); ns.wrapAt(e[2] + e[3]) },
					// a degree of the bar's mode above the chord's root (A3 = 57)
					\tresillo, { var d = e[2] + e[3] + (degOf[pc.(self.chordAtK(p.floor.asInteger, false).bass)] ? 0);
						57 + (12 * (d / 7).floor) + modeSteps[self.modeAt((t).floor)][d % 7] },
					// the call: F♯ becomes F in the aeolian progressions; +1 does nothing on a note name (Strudel: a warning)
					\call, { var s = e[2]; if(s.beginsWith("f#") and: { self.modeAt(t.floor) == \aeolian }) { s = "f" ++ s[2..] }; midi.(s) });
				key = keys.minIndex { |kk, i| (kk - m).abs + (i * 1e-6) };
				vel = 0.6 + (0.4 * ce.perlin(t));
				// swing 56 %: the off 16ths 0.12 of a 16th late
				self.swingAt(p).do { |sw| out.add(ce.note(\sdSample, (buf: ce.sampleBuffers[files[key]], stereoIn: 1,
					rate: 2 ** ((m - keys[key]) / 12), amp: 0.8 * vel, a: 0.001, d: 0.001, s: 1, r: 0.1, hold: e[1] * clip,
					at: p - k + sw, pan: 0.4 + (0.2 * ce.sine(t / 3)),
					lpOn: 1, lo: cut, hi: cut, tone: tone, thinF: thin, tag: "vibraphone", g: vel, midi: m))) }
			};
			if(out.notEmpty) { out ++ self.labEchoMsg(vs, out[0][\at], \vibes) } { out }
		};
	}.value;

	// JONAS 4 FLUTE — motifs in mini-notation, A A B A A A B D over 8 bars; Complexity from a third: two extra notes
	// in the gaps (random, more towards 1), from three quarters: a trill into a note (each of its four notes random)
	{
		var fc = jonas.(4), level = 2.0;
		var fs = self.labCol(4, [0.6, 0, 0.3, 0], { |st, send|
			var s2 = 0.2 + (0.8 * st.val[1]);
			ce.setState(\fluLevel, st.val[3] * level * (4 * (st.val[0] - 0.5)).dbamp, send);
			ce.setState(\fluRoom, 0.9 * s2, send);   // the lab's bus: a little room even at 0
			ce.setState(\fluEcho, if(st.held) { 0.65 } { 0 }, send);
		});
		var table = { |str| var m = ce.mini(str), t = Dictionary[];
			m.events.do { |e| var p = e[0] * 16, k = p.floor.asInteger; t[k] = (t[k] ? []).add([p - k, e[1] * 16, e[2]]) };
			(period: m.period * 16, steps: t) };
		var motifs = [
			["3-3-2", ["[2 ~ ~ 3 ~ ~ 2 ~ 1 ~ ~ 2 ~ ~ 3 ~]", "[2 ~ ~ 3 ~ ~ 4 ~ 3 ~ ~ 2 ~ ~ 1 ~]", "[2 ~ ~ 3 ~ ~ 2 ~ 1 ~ ~ 0 ~ ~ ~ ~]"],
				"[~ ~ ~ ~ ~ 4 ~ ~ ~ ~ 4 ~ ~ ~ ~ ~]", "[~@14 2 ~]"],
			["Call + answer", ["[3@3 ~ 2 ~ 3@4 ~@6]", "[~ ~ 1 ~ 2 ~ ~ 1@3 ~ 0@3 ~@3]", "[3@3 ~ 4 ~ 3@3 2 ~ ~ ~@4]"],
				"[~@8 2 ~@4 3 ~ ~]", "[~ ~ ~ 2 ~@12]"],
			["Steady 8ths", ["[2 ~ 3 ~ 2 ~ 1 ~ 2 ~ 3 ~ 4 ~ 3 ~]", "[2 ~ 3 ~ 4 ~ 3 ~ 2 ~ 1 ~ 2 ~ ~ ~]", "[2 ~ 3 ~ 2 ~ 1 ~ 0 ~ ~ ~ ~ ~ ~ ~]"],
				"[~ ~ 3 ~ ~ ~ 2 ~ ~ ~ 3 ~ ~ ~ 4 ~]", "[~@12 2 ~@3]"],
		];
		var phrases = motifs.collect { |m| var a = m[1][0], b = m[1][1], d = m[1][2];
			[table.("<" ++ [a, a, b, a, a, a, b, d].join(" ") ++ ">"), table.(m[2]), table.(m[3])] };
		// the single notes in the phrases: [phrase, from s, to s, MIDI] (the lab's YIN analysis), phrase lengths
		var notesIn = [[2, 1.86, 4.46, 61.97], [0, 3.87, 4.53, 64.07], [2, 0.45, 0.71, 65.12], [1, 2.02, 2.61, 67.11],
			[1, 0.11, 1.63, 68.94], [1, 2.67, 3.14, 70.98], [0, 0.77, 2.39, 72.03]];
		var lens = [6.45, 6.11, 7.12];
		var files = ["0003", "0068", "0133"].collect { |n| "repo:horn-phrases/flute-65509-" ++ n ++ ".flac" };
		var voicingOf = { |c| (Am9: [55, 59, 60, 64], D9: [54, 57, 60, 64])[c.name.asSymbol] ? c.tones };
		var pool = ();
		var chordNotes = { |c| pool[c.name.asSymbol] ?? { var pcs = (voicingOf.(c)).collect(pc);
			pool[c.name.asSymbol] = (67..91).select { |m| pcs.includes(pc.(m)) }.keep(8); pool[c.name.asSymbol] } };
		var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
		// the events that start in 16th k: [begin (16ths), length, value]
		var eventsAt = { |ph, k|
			var cx = fs.val[2], out = List[], xNb = if(cx < 0.33) { 1 } { 1 - ((cx - 0.33) / 0.67) };
			// core: as written
			(ph[0].steps[k % ph[0].period] ? []).do { |e| out.add([k + e[0], e[1], e[2]]) };
			// extra notes: degradeBy (keep when rand > amount)
			(ph[1].steps[k % ph[1].period] ? []).do { |e| var p = k + e[0]; if(ce.rand(p / 16) > xNb) { out.add([p, e[1], e[2]]) } };
			// trill: the note squeezed into x x+1 x x+1, each from three quarters (degradeBy 1 / 0) and then degradeBy 0.4
			if(cx >= 0.75) {
				(ph[2].steps[k % ph[2].period] ? []).do { |e| 4.do { |i| var p = k + e[0] + (i * e[1] / 4);
					if(ce.rand(p / 16) > 0.4) { out.add([p, e[1] / 4, e[2] + (i % 2)]) } } }
			};
			out
		};
		self.fs = fs;
		self.fluVar = ce.change(fc.btn, phrases.size, "Flute", motifs.collect(_[0]));
		stem.(\flute).notes = { |k|
			var ph = phrases[self.fluVar.atBar(bar.(k))], br = fs.val[0], out = List[];
			var cut = (900 * ((14000 / 900) ** br)).min(18000);
			var adsr = ce.sdADSR(0.02, nil, nil, 0.09);
			eventsAt.(ph, k).do { |e|
				var p = e[0], t = p / 16, m, x, vel;
				// arp: the chord's notes from G4 up (the chord two 16ths early); above F5 an octave down
				m = chordNotes.(self.chordAtK((p + 0.5).floor.asInteger, true)).wrapAt(e[2]);
				while { m > 77 } { m = m - 12 };
				x = notesIn[notesIn.minIndex { |n, i| (n[3] - m).abs + (i * 1e-9) }];
				vel = 0.75 + (0.25 * ce.perlin(t));
				self.swingAt(p).do { |sw| out.add(ce.note(\sdSample, (buf: ce.sampleBuffers[files[x[0]]], stereoIn: 0,
					begin: x[1] / lens[x[0]], rate: 2 ** ((m - x[3]) / 12), amp: 0.8 * vel, a: adsr[0], d: adsr[1], s: adsr[2],
					r: adsr[3], hold: e[1], at: p - k + sw, pan: 0.55,
					lpOn: 1, lo: cut, hi: cut, tone: tone, thinF: thin, tag: "m4_fl", g: vel))) }
			};
			// the echo of orbit 3 as a note sets it: throw (held) or Tension's echo, dotted 8th
			if(out.notEmpty and: { fs.held or: { self.tensionEcho > 0 } }) {
				out.add((msg: [\n_set, ce.stemDelayNode[\flute], \time, 0.75 * 60 / bpm, \feedback, if(fs.held) { 0.62 } { 0.55 }], at: out[0][\at]))
			};
			out
		};
	}.value;

	// JONAS 5 BRASS — the lab's figures: [16th, length, complexity level, kind]; each repetition of a short figure rests
	// with 30 % (every 4th always plays), every hit but the one is left out with 25 % (hash of the repetition: the same
	// on every pass). Lift (button 2 held): up over two bars, down over one; doubling, harmony, brighter, up to +3 dB.
	{
		var bc = jonas.(5), level = 0.42;
		var bs = self.labCol(5, [0.6, 0, 0.3, 0], { |st, send|
			ce.setState(\brsLevel, st.val[3] * level * (4 * (st.val[0] - 0.5)).dbamp, send);
			ce.setState(\brsRoom, 0.9 * (0.3 + (0.7 * st.val[1])), send);   // the lab's bus: never below 0.3 × 0.9
			ce.setState(\brsEcho, 0, send);
		});
		var bn = { |p, len, lv = 0, kind = \hit| (p: p, len: len, lv: lv, kind: kind) };
		var figs = [
			["Push", 32, [bn.(14, 1), bn.(16, 3), bn.(30, 1), bn.(0, 3), bn.(13, 1, 1), bn.(29, 1, 1), bn.(22, 1, 2), bn.(8, 1, 2)]],
			["3-3-2 + answer", 32, [bn.(0, 1), bn.(3, 1), bn.(6, 2), bn.(24, 1), bn.(27, 3), bn.(10, 1, 1), bn.(23, 1, 1), bn.(31, 1, 2), bn.(14, 1, 2)]],
			["Shout", 16, [bn.(0, 1), bn.(3, 1), bn.(6, 1), bn.(10, 2), bn.(12, 1), bn.(14, 1, 1), bn.(15, 1, 2), bn.(8, 1, 2)]],
			["Double push", 32, [bn.(13, 1), bn.(14, 1), bn.(16, 2), bn.(29, 1), bn.(30, 1), bn.(0, 2), bn.(6, 1, 1), bn.(22, 1, 1), bn.(23, 1, 2), bn.(10, 1, 2)]],
			["3-3-2 long", 32, [bn.(0, 1), bn.(3, 1), bn.(6, 1), bn.(16, 1), bn.(19, 1), bn.(22, 2), bn.(28, 1, 1), bn.(30, 1, 1), bn.(12, 1, 2), bn.(27, 1, 2)]],
			["Only the one", 32, [bn.(0, 3), bn.(14, 1, 1), bn.(22, 1, 1), bn.(8, 1, 2)]],
			["Rare (4 bars)", 64, [bn.(62, 1), bn.(0, 3), bn.(30, 1, 1), bn.(46, 1, 1), bn.(38, 1, 2), bn.(54, 1, 2)]],
			["Rare swell", 64, [bn.(56, 6, 0, \swell), bn.(0, 2), bn.(30, 1, 1), bn.(46, 1, 2)]],
			["Swell + push", 32, [bn.(24, 6, 0, \swell), bn.(30, 1), bn.(0, 2), bn.(3, 1, 1), bn.(6, 1, 1), bn.(10, 1, 2), bn.(14, 1, 2)]],
		];
		var bms = 16 / (240 / bpm * 1000);   // 16ths per millisecond
		var pcsOf = { |c| ([pc.(c.bass)] ++ c.tones.collect(pc)).asSet.asArray };
		var leadOf = { |c| var p = pcsOf.(c), best = 67; (67..76).do { |m| if(p.includes(pc.(m)) and: { (m - 72).abs < (best - 72).abs }) { best = m } }; best };
		var below = { |c, top, n| var p = pcsOf.(c), o = List[]; (top - 1, top - 2 .. top - 12).do { |m| if(o.size < n and: { p.includes(pc.(m)) }) { o.add(m) } }; o };
		// ensemble: [sound, gain, ms late, pan]
		var ens = (lead: [[\sso_tp, 0.45, 0, 0.45], [\sso_hn, 0.45, 6, 0.55]], dbl: [[\sso_tp, 0.32, 9, 0.6]],
			harm: [[\sso_hn, 0.4, 8, 0.5], [\sso_tp, 0.25, 4, 0.6]], low: [[\sso_tb, 0.5, 11, 0.6]]);
		var sus = (sso_tp: [\sso_tp_sus, 0.8], sso_hn: [\sso_hn_sus, 0.45], sso_tb: [\sso_tb_sus, 0.6]);
		var maps = brassMaps.collect { |m| m[0] -> m[1] }.asDict;
		var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
		var lift = 0;
		bs[\lift] = 0; bs[\lastHeld] = false;
		self.bs = bs;
		self.brsVar = ce.change(bc.btn, figs.size, "Brass", figs.collect(_[0]));
		stem.(\brass).notes = { |k|
			var fig, len, p, out = List[], cx, lvl, lg, rd, cut;
			lift = self.liftStep(bs, k);   // Lift (button 2): see liftStep
			fig = figs[self.brsVar.atBar(bar.(k))]; len = fig[1]; p = k % len;
			cx = bs[\val][2]; lvl = if(cx < 0.33) { 0 } { if(cx < 0.66) { 1 } { 2 } }; lg = (3 * lift).dbamp;
			rd = (k / len).floor.asInteger + if(p >= (len - 2)) { 1 } { 0 };
			cut = 900 * ((8000 / 900) ** bs[\val][0]);
			if((len <= 32 and: { rd % 4 != 0 } and: { ce.hash3(rd, len, 41) < 0.3 }).not) {
				fig[2].do { |n|
					if(n[\p] == p and: { n[\lv] <= lvl } and: { (n[\p] != 0 and: { n[\kind] != \swell } and: { ce.hash3(rd, n[\p], 43) < 0.25 }).not }) {
						var c = self.chordAtK(k, true), lead = leadOf.(c), held = n[\kind] == \swell, soft = if(n[\lv] > 0) { 0.7 } { 1 };
						var bright = 0.75 + (0.6 * lift), adsr = ce.sdADSR(if(held) { 0.6 * n[\len] / 16 * 240 / bpm } { 0.003 }, nil, nil,
							if(held) { 0.35 } { if(n[\len] >= 3) { 0.2 } { 0.12 } });
						var dur = if(n[\len] == 1) { 0.9 } { n[\len] - 0.3 };
						var close = below.(c, lead, 3), harm = if(held) { [close[1], close[2], close[0] !? { |x| x - 12 }] } { close.keep(2) };
						var voices = ens[\lead].collect { |x| [x, lead, 1] } ++ ens[\low].collect { |x| [x, lead - 12, 1] }
							++ ens[\dbl].collect { |x| [x, lead, 0.6 + (0.4 * lift)] }
							++ harm.collect { |m| ens[\harm].collect { |x| [x, m, 0.7 + (0.3 * lift)] } }.flatten(1)
							++ if(lift > 0.5) { [[ens[\lead][0], lead + 12, 0.5 * (lift - 0.5) * 2]] } { [] };
						voices.do { |v| var x = v[0], note = v[1], f = v[2];
							if(note.notNil) {
								var sn = if(held) { sus[x[0]][0] } { x[0] }, g2 = if(held) { sus[x[0]][1] } { 1 };
								var keysOf = maps[sn], key = keysOf[keysOf.minIndex { |kk, i| (kk[0] - note).abs + (i * 1e-6) }];
								var at = (x[2] + (8 * ce.hash3(k, note, sn.asString.size))) * bms;   // never early
								var g = x[1] * g2 * soft * f * lg;
								self.swingAt(k + at).do { |sw| out.add(ce.note(\sdSample, (buf: ce.sampleBuffers[key[1]], stereoIn: 1,
									rate: 2 ** ((note - key[0]) / 12), amp: g, a: adsr[0], d: adsr[1], s: adsr[2], r: adsr[3], hold: dur,
									at: at + sw, pan: x[3], lpOn: 1, lo: cut * bright, hi: cut * bright, tone: tone, thinF: thin,
									tag: sn.asString, g: g, midi: note))) }
							}
						}
					}
				}
			};
			// Tension's echo on orbit 3 (dotted 8th)
			if(out.notEmpty and: { self.tensionEcho > 0 }) {
				out.add((msg: [\n_set, ce.stemDelayNode[\brass], \time, 0.75 * 60 / bpm, \feedback, 0.55], at: out[0][\at]))
			};
			out
		};
	}.value;

	// ---- helpers of the Strudel track's newer lab columns (strings, guitar): chord tones, scale steps, sample maps
	self.labPcs = { |self, c| ([pc.(c.bass)] ++ c.tones.collect(pc)).asSet.asArray };
	self.labScale = { |self, k| (dorian: [9, 11, 0, 2, 4, 6, 7], aeolian: [9, 11, 0, 2, 4, 5, 7])[self.modeAt((k / 16).floor)] };
	self.labSteps = { |self, m, sc, n| var x = m, d = n.sign; n.abs.do { x = x + d; while { sc.includes(pc.(x)).not } { x = x + d } }; x };
	self.labBelow = { |self, c, top, n| var p = self.labPcs(c), o = List[];
		(top - 1, top - 2 .. top - 12).do { |m| if(o.size < n and: { p.includes(pc.(m)) }) { o.add(m) } }; o };
	self.labNear = { |self, c, lo, hi, target| var p = self.labPcs(c), best = lo;
		(lo..hi).do { |m| if(p.includes(pc.(m)) and: { (m - target).abs < (best - target).abs }) { best = m } }; best };
	// a sample map's closest key (the first in the map's order on a tie): [key MIDI, file]
	self.closestKey = { |self, keys, note| keys[keys.minIndex { |kk, i| (kk[0] - note).abs + (i * 1e-6) }] };
	// the lift of a column's button 2: up over 2 bars while held, down over 1 bar after; the notes of 16th k hear
	// the lift up to 16th k − 1 (Strudel: the tap that moves it is queried after the stems, ± one 16th)
	self.liftStep = { |self, st, k| var was = st[\lift];
		if(st[\lastK].notNil) {
			st[\lift] = if(st[\lastHeld]) { (st[\lift] + (1 / 32)).min(1) } { (st[\lift] - (1 / 16)).max(0) } };
		st[\lastK] = k; st[\lastHeld] = st[\held];
		if(st[\lift] != was and: { k % 4 == 0 or: { st[\lift] == 0 } or: { st[\lift] == 1 } }) { ce.uiPush };   // the UI's Lift %
		st[\lift] };

	// JONAS 6 STRINGS — the lab's figures [16th, kind, length, scale steps off the top note, chord lookahead];
	// Complexity (or the lift) in stages: unison → + octave → + a third under runs → + celli two octaves down
	{
		var sc6 = jonas.(6), level = 0.59;
		var ss = self.labCol(6, [0.6, 0, 0.3, 0], { |st, send| var s2 = 0.3 + (0.7 * st.val[1]);
			ce.setState(\strLevel, st.val[3] * level * (4 * (st.val[0] - 0.5)).dbamp, send);
			ce.setState(\strRoom, 0.9 * s2, send);
			// a note's own echo × 2 × Space (bus style, never above 0.9): three lanes for echo 0, 0.3, 0.5
			ce.setState(\strEcho0, 0, send);
			ce.setState(\strEcho3, (0.3 * 2 * s2).min(0.9), send);
			ce.setState(\strEcho5, (0.5 * 2 * s2).min(0.9), send);
		});
		var sn = { |p, kind, len, off = 0, at = 0, more| (p: p, kind: kind, len: len, off: off, at: at, acc: 1) ++ (more ? ()) };
		var top = (acc: 1.5, hard: true, echo: 0.3);
		var runTo = { |end, n, l| (0..n - 1).collect { |i| sn.((end - n + i) % l, \line, 1, i - n, n - i) } ++ [sn.(end % l, \stab, 2, 0, 0, top)] };
		var figs = [
			["Echo stab", 32, [sn.(0, \stab, 2, 0, 0, (echo: 0.5, hard: true))]],
			["Run up", 32, runTo.(32, 4, 32)],
			["Long run", 64, runTo.(64, 8, 64)],
			["Stab + swell", 64, [sn.(0, \stab, 2, 0, 0, (echo: 0.5, hard: true)), sn.(32, \swell, 30)]],
			["16th figure", 64, [0, -1, 0, 1, 0, -1, -2, -1].collect { |o, i| sn.(56 + i, \line, 1, o, 8 - i) } ++ [sn.(0, \stab, 2, 0, 0, top)]],
		];
		var line = [[\sso_vn, 0.55, 0.42], [\vs_vn, 1.6, 0.52], [\sso_vn2, 0.5, 0.58]];
		var fill = [[\sso_va, 0.45, 0.6], [\vs_va, 1.25, 0.45]];
		var maps = stringMaps.collect { |m| m[0] -> m[1] }.asDict;
		var lms = 16 / (240 / bpm * 1000);
		var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
		ss[\lift] = 0; ss[\lastHeld] = false;
		self.ss = ss;
		self.strVar = ce.change(sc6.btn, figs.size, "Strings", figs.collect(_[0]));
		stem.(\strings).notes = { |k|
			var lift = self.liftStep(ss, k), fig = figs[self.strVar.atBar(bar.(k))], len = fig[1], p = k % len;
			var hits = fig[2].select { |n| n[\p] == p }, out = List[], echoOn = false;
			var v3 = ss[\val][2], stage = max(if(v3 < 0.25) { 0 } { if(v3 < 0.5) { 1 } { if(v3 < 0.75) { 2 } { 3 } } }, (lift * 3).floor);
			var lg = (3 * lift).dbamp, rr = (k + 5) % 3, cut = 1200 * (10 ** ss[\val][0]);
			hits.do { |n|
				var c = self.chordAtK(k + n[\at], true), sc = self.labScale(k + n[\at]);
				var m = self.labSteps(self.labNear(c, 72, 81, 76), sc, n[\off]), swell = n[\kind] == \swell;
				var base = if(swell) { (dur: n[\len], a: 0.9, r: 0.8) } { (dur: 6, a: 0.002, r: 0.4) };
				var adsr = ce.sdADSR(base[\a], nil, nil, base[\r]), echo = n[\echo] ? 0;
				var bright = 0.8 + (0.5 * lift) + if(n[\hard] == true) { 0.3 } { 0 };
				var voice = { |sname, note, gain, ms, pan|
					var key = self.closestKey(maps[sname], note), g = gain * n[\acc] * lg, dt = (ms + (4 * ce.hash3(k, note, sname.asString.size))) * lms;
					self.swingAt(k + dt).do { |sw| out.add(ce.note(\sdSample, (buf: ce.sampleBuffers[key[1]], stereoIn: 1,
						rate: 2 ** ((note - key[0]) / 12), amp: g, a: adsr[0], d: adsr[1], s: adsr[2], r: adsr[3], hold: base[\dur],
						at: dt + sw, pan: pan, lpOn: 1, lo: (cut * bright).min(18000), hi: (cut * bright).min(18000), tone: tone, thinF: thin,
						lane: [\main, \echo3, \echo5][[0, 0.3, 0.5].indexOf(echo)], tag: sname.asString, g: g, midi: note))) };
					if(echo > 0) { echoOn = true }
				};
				if(swell) {
					voice.(\sso_vn_sus, m, 0.35, 0, 0.45);
					if(stage >= 1) { voice.(\sso_va_sus, m - 12, 0.3, 6, 0.6) };
					self.labBelow(c, m, 2).do { |x| voice.(\sso_va_sus, x, 0.28, 9, 0.55) };
				} {
					var l1 = line[rr], l2 = line[(rr + 1) % 3];
					voice.(l1[0], m, l1[1], 0, l1[2]);
					if(stage >= 1) { voice.(l2[0], m + 12, l2[1] * 0.6, 12, l2[2]) };
					if(n[\kind] == \stab) {
						self.labBelow(c, m, 2).do { |x, j| var f = fill[(rr + j) % 2]; voice.(f[0], x, f[1], 8, f[2]) };
						voice.(\sso_vc, c.bass + 12, 0.5, 4, 0.65);
						if(n[\hard] == true) { voice.(\sso_vn_piz, m, 0.55, 0, 0.5) };
					} {
						if(stage >= 2) { var f = fill[rr % 2]; voice.(f[0], self.labSteps(m, sc, -2), f[1] * 0.8, 8, 0.6) };
						if(stage >= 3) { voice.(\sso_vc, m - 24, 0.4, 5, 0.65) };
					}
				}
			};
			// a note with echo (or Tension's echo) sets orbit 3's echo: dotted 8th, feedback 0.55
			if(out.notEmpty and: { echoOn or: { self.tensionEcho > 0 } }) {
				out.add((msg: [\n_set, ce.stemDelayNode[\strings], \time, 0.75 * 60 / bpm, \feedback, 0.55], at: out[0][\at]))
			};
			out
		};
	}.value;

	// JONAS 7 GUITAR — the lab's lines [16th, length, what (top / ch / pen / strum, step), accent]; Complexity in four
	// steps: line → + dead notes on the e's → + a variation (one chord tone up) in bars 4 and 8 → + 16th motor of dead
	// notes and a pentatonic fill at the end of bar 8. Lift (button 2 held): phaser, brighter, echo, +3 dB.
	{
		var gc = jonas.(7), level = 0.76;
		var gs = self.labCol(7, [0.6, 0, 0.3, 0], { |st, send| var sp = st.val[1];
			ce.setState(\gtrLevel, st.val[3] * level * (4 * (st.val[0] - 0.5)).dbamp, send);
			ce.setState(\gtrRoom, 0.8 * ((sp - 0.35) / 0.65).max(0), send);   // the lab engine's 'echo' style
		});
		var gn = { |p, len, what, acc = 1| (p: p, len: len, what: what, acc: acc) };
		var lines = [
			["Stardust", 16, [gn.(2, 2, [\top, 0]), gn.(6, 1, [\ch, 0]), gn.(8, 2, [\top, 12]), gn.(11, 1, [\strum]), gn.(15, 1, [\strum])]],
			["e & a 4", 16, [gn.(9, 1, [\ch, 2]), gn.(10, 1, [\ch, 1]), gn.(11, 1, [\ch, 0]), gn.(12, 3, [\top, 0], 1.1)]],
			["Call + answer", 32, [gn.(4, 1, [\ch, 1]), gn.(6, 1, [\ch, 0]), gn.(7, 2, [\top, 0]), gn.(20, 1, [\top, -1]), gn.(22, 1, [\ch, 0]), gn.(24, 2, [\ch, 1])]],
			["Repeated note", 16, [gn.(0, 2, [\top, 0], 1.1), gn.(3, 2, [\top, 0]), gn.(6, 2, [\top, 0]), gn.(10, 1, [\top, 0], 0.8)]],
			["Lick", 64, [gn.(56, 1, [\pen, 4]), gn.(57, 1, [\pen, 3]), gn.(58, 2, [\pen, 2]), gn.(60, 1, [\pen, 1]), gn.(61, 3, [\pen, 0]), gn.(0, 2, [\top, 0])]],
			["Dead-note groove", 16, [gn.(3, 1, [\top, 0]), gn.(6, 1, [\top, 0]), gn.(7, 1, [\ch, 0]), gn.(11, 1, [\top, 0]), gn.(14, 2, [\top, -1])]],
			["Off-beat pairs", 16, [gn.(1, 1, [\top, 0]), gn.(2, 1, [\ch, 0]), gn.(5, 1, [\top, 0]), gn.(6, 1, [\ch, 0]), gn.(9, 1, [\top, 0]), gn.(10, 1, [\ch, 1]), gn.(13, 2, [\top, 0])]],
			["Pickup", 16, [gn.(13, 1, [\ch, 1]), gn.(14, 1, [\ch, 0]), gn.(15, 1, [\top, -1]), gn.(0, 2, [\top, 0], 1.25), gn.(6, 1, [\top, 0], 0.8)]],
		];
		var penta = [9, 0, 2, 4, 7];
		var maps = stratMaps.collect { |m| m[0] -> m[1] }.asDict;
		var lms = 16 / (240 / bpm * 1000);
		// begin 0.0032 of the original 4.01 s files (176912 frames), the cut files are 1.5 s (66150 frames)
		var begin = 0.0032 * 176912 / 66150;
		var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
		var chordUp = { |c, m| var p = self.labPcs(c), x = m + 1; while { p.includes(pc.(x)).not } { x = x + 1 }; x };
		var pitch = { |what, c, sc, up|
			var t0 = self.labNear(c, 67, 79, 72), top = if(up) { chordUp.(c, t0) } { t0 }, w = what[0], r = what[1];
			switch(w,
				\top, { [if(r == 12) { top + 12 } { self.labSteps(top, sc, r) }] },
				\ch, { [self.labBelow(c, top, 3)[r]] },
				\pen, { [57 + 12 + penta[r] - 9 + (if(penta[r] < 9) { 12 } { 0 }) + (if(up) { 2 } { 0 })] },
				\strum, { self.labBelow(c, top + 1, 2) },
				{ [] })
		};
		gs[\lift] = 0; gs[\lastHeld] = false;
		self.gs = gs;
		self.gtrVar = ce.change(gc.btn, lines.size, "Guitar", lines.collect(_[0]));
		stem.(\guitar).notes = { |k|
			var lift = self.liftStep(gs, k), li = self.gtrVar.atBar(bar.(k)), ln = lines[li], len = ln[1], notes = ln[2];
			var p = k % len, s16 = k % 16, p128 = k % 128, bar8 = (p128 / 16).floor;
			var v3 = gs[\val][2], lvl = if(v3 < 0.25) { 0 } { if(v3 < 0.5) { 1 } { if(v3 < 0.75) { 2 } { 3 } } }, lg = (3 * lift).dbamp;
			var c = self.chordAtK(k, true), sc = self.labScale(k), out = List[];
			var inFill = lvl >= 3 and: { p128 >= 120 };
			var hits = if(inFill) { [gn.(p, 1, [\pen, 4 - (4.min(((p128 - 120) * 5 / 8).floor))], if(p128 == 120) { 1.1 } { 0.9 })] } {
				notes.select { |n| n[\p] == p } };
			var up = lvl >= 2 and: { bar8 == 3 or: { bar8 == 7 } };
			var bright = 0.85 + (0.5 * lift), sp = gs[\val][1], e = if(sp > 0) { (0.4 + (1.2 * sp)).min(1) } { 0 };
			var cut = 800 * ((7000 / 800) ** gs[\val][0]) * bright;
			var tSec = { |dt| (k + dt) / 16 * 240 / bpm };   // the note's time in seconds (the phaser LFO's phase)
			var play = { |take, m, dur, a, r, g, dt, lpCut|
				var key = self.closestKey(maps[take], m);
				// the phaser only while lifted (superdough: no phaser without phaserrate)
				self.swingAt(k + dt).do { |sw| out.add(ce.note(if(lift > 0) { \sdSamplePh } { \sdSample }, (buf: ce.sampleBuffers[key[1]], stereoIn: 1, begin: begin,
					rate: 2 ** ((m - key[0]) / 12), amp: g, a: a, d: 0.001, s: 1, r: r, hold: dur, at: dt + sw, pan: 0.4,
					lpOn: 1, lo: lpCut.min(18000), hi: lpCut.min(18000), tone: tone, thinF: thin,
					phRate: 0.4, phDepth: 0.75 * lift, phCenter: 1200, phSweep: 900 * (lift > 0).binaryValue,
					phPhase: (tSec.(dt + sw) * 0.4).frac, tag: take.asString, g: g, midi: m))) }
			};
			hits.do { |n|
				pitch.(n[\what], c, sc, up).reject(_.isNil).do { |m, j|
					var strum = n[\what][0] == \strum, take = ("strat" ++ (1 + (ce.hash3(p, m, li) * 3).floor.asInteger)).asSymbol;
					var adsr = ce.sdADSR(0.002, nil, nil, if(strum) { 0.03 } { 0.12 });
					play.(take, m, if(strum) { 0.6 } { n[\len] * 0.9 }, adsr[0], adsr[3],
						5 * n[\acc] * lg * (if(strum) { 0.7 } { 1 }), ((j * 4) + (3 * ce.hash3(k, m, j))) * lms, cut)
				}
			};
			// dead notes: on the e's from step 1, every free 16th from step 3, not right after a long note
			if(hits.isEmpty and: { lvl >= 3 or: { lvl >= 1 and: { [1, 5, 9, 13].includes(s16) } } }
				and: { notes.any { |n| n[\p] == ((p - 1) % len) and: { n[\len] >= 2 } }.not }) {
				var adsr = ce.sdADSR(0.001, nil, nil, 0.02);
				play.(("strat" ++ (1 + (k % 3))).asSymbol, self.labBelow(c, self.labNear(c, 67, 79, 72), 3)[2] ? 60, 0.35,
					adsr[0], adsr[3], (if(s16.odd) { 2.2 } { 1.6 }) * lg, 2 * lms, cut.min(900))
			};
			if(out.notEmpty) {
				// the lab's 'echo' style: Space's 1/8 echo; at Space 0 the lift's echo (dotted 8th); Tension's on top
				var d = if(e > 0) { 0.6 * e } { 0.25 * lift }, at = out[0][\at];
				out.add((msg: [\c_set, ce.stateBus[\gtrEcho], d], at: at));
				if(d.max(self.tensionEcho) > 0) {
					out.add((msg: [\n_set, ce.stemDelayNode[\guitar], \time, if(e > 0) { 30 / bpm } { 0.75 * 60 / bpm },
						\feedback, if(e > 0) { 0.15 + (0.35 * e) } { 0.55 }], at: at))
				}
			};
			out
		};
	}.value;
}.value;
},
)
)
