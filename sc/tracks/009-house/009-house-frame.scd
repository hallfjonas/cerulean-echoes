// Frame of the 009 stem track (009-house.track): harmony, chapters, the global column 8 texts, the orbits and the
// Launchkey, the same as the former sc/tracks/009-house/009-house.scd. Format: sc/lib/stemtrack.scd.
// Vamp = Am9 throughout; Progression = the progression button 1 of the chords column picks (next of 10, at the next
// 8 bars). A stem that brings its own chords (the keys' riffs, col.riffAt) sets them for the whole track while its
// fader is up. Every chord carries the scale of its bar: A dorian (F♯) in Vamp and in Am9 D9, A aeolian (F) else.
// @col 16:8 8 Global
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | build-up: echo, reverb, open filters; past half also a snare roll.
// @ctl g.fader Master | volume of everything.
// @ctl g.b1 Chapter | Vamp (Am9) ↔ Progression (Chords, column 1).
// @ctl g.b2 Break | 1st: kick, pump, sub, bass out. 2nd: all back on the one.
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
var lkKeysLib = (~ce.root +/+ "lib/lkkeys.scd").load;
var bpm = 124, fogCC = 20, tensionCC = 36;
var aeol = "a b c d e f g";
var chords = [
	["Am9", "a1", "c4 e4 g4 b4", "a b c d e f# g"], ["D9", "d2", "c4 e4 f#4 a4", "d e f# g a b c"],
	["Am7", "a1", "c4 e4 g4 a4", aeol], ["Cmaj7", "c2", "c4 e4 g4 b4", aeol], ["Em7", "e1", "d4 e4 g4 b4", aeol],
	["Fmaj7", "f1", "c4 e4 f4 a4", aeol], ["Fadd9", "f1", "c4 f4 g4 a4", aeol], ["Gadd9", "g1", "d4 g4 a4 b4", aeol],
	["G11", "g1", "c4 d4 f4 g4", aeol], ["Dm7", "d2", "c4 d4 f4 a4", aeol], ["Gm", "g1", "d4 f4 g4 bb4", "g a bb c d e f"],
	["Em/G", "g1", "d4 e4 g4 b4", aeol], ["Dm9", "d2", "c4 e4 f4 a4", aeol], ["Gm9", "g1", "d4 f4 a4 bb4", "g a bb c d e f"],
	["Bm", "b1", "d4 f#4 b4", "b c# d e f# g a"],
].collect { |c| ~ce.chordOf(*c) };
var cid = { |name| chords.detectIndex { |c| c[\name] == name } };
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
// the scale of a bar, from A: dorian in Vamp and in Am9 D9, aeolian in the others
var modes = (dorian: [9, 11, 0, 2, 4, 6, 7], aeolian: [9, 11, 0, 2, 4, 5, 7]);
var withMode = Dictionary[];
var inMode = { |c, mode| var key = [c[\name], mode];
	withMode[key] ?? { var x = c.copy; x[\scale] = modes[mode]; withMode[key] = x; x } };
var modeAt = { |track, b| if(track.chapterAt(b) == 0 or: { track.prog.atBar(b) == 0 }) { \dorian } { \aeolian } };
var riffAt = { |track, b| var col = track.columns.values.detect { |c| c[\riffAt].notNil }; col !? { col.riffAt(b) } };
var chordIdAt = { |track, b| var r = riffAt.(track, b);
	if(r.notNil) { cid.(r.names[r.seq[(16 * b) % r.seq.size].asSymbol]) } {
		if(track.chapterAt(b) == 0) { cid.("Am9") } { progs[track.prog.atBar(b)].ids[b % 8] } } };
(
chapterBars: 4,
chordAt: { |frame, track, bar| inMode.(chords[chordIdAt.(track, bar)], modeAt.(track, bar)) },
// the chord at 16th k: under a riff exactly its letter at that 16th, else the bar's chord (push: two 16ths early)
chordAtK: { |frame, track, k, push| var b = (k / 16).floor, r = riffAt.(track, b), c;
	c = if(r.notNil) { chords[cid.(r.names[r.seq[k % r.seq.size].asSymbol])] } {
		chords[chordIdAt.(track, ((k + if(push) { 2 } { 0 }) / 16).floor)] };
	inMode.(c, modeAt.(track, b)) },
nextChords: { |frame, track| var l = track.prog;
	l.pending = (l.pending + 1) % progs.size; track.ce.status("Chords (next)", progs[l.pending].name) },
build: { |frame, track, ce|
	track.prog = ce.latch(8, 0, { |i| ce.status("Chords", progs[i].name); ce.uiPush });
	ce.uiRows['jonas:1'] = (latch: track.prog, names: progs.collect(_.name));
},
// Orbit 1 = drums and bass: a very small room, a short dotted-8th slap. Orbit 2 = the noise riser and the Launchkey
// keys: a small studio room. Orbit 3 = the colour columns: room size 2 (each column brings its own echo).
orbits: (1: (ir: "ir/orbit-0.6.wav", delay: [0.75 * 60 / bpm, 0.2]), 2: (ir: "ir/orbit-1.2.wav", delay: [0.75 * 60 / bpm, 0.3]),
	3: (ir: "ir/orbit-2.0.wav", delay: [30 / bpm, 0.15])),
states: (lkLevel: 0, lkBright: 0, lkRoom: 0.9 * 0.1, lkEcho: 0),
// Launchkey pads: the spoken samples (repo samples/voice) and more drum-machine one-shots; keys: lib/lkkeys.scd
samples: ["voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac",
	"voice/the_evening_progresses.flac", "voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac",
	"voice/the_evening_does_not_end.flac", "voice/in_the_vast.flac", "tr909/cp-00.wav", "tr909/oh-00.wav",
	"tr909/rim-00.wav", "tr909/lt-00.wav", "tr909/cr-00.wav", "tr909/sd-00.wav"]
	++ ~ce.fontFiles("0530_Aspirin_sf2_file") ++ ~ce.fontFiles("0110_JCLive_sf2_file") ++ ~ce.lkKeysFiles,
// LAUNCHKEY MK4 25 — keys: piano / Rhodes, B3 / M1, vibraphone / marimba (orbit 2, mod wheel = level); drum pads: 16
// one-shots (orbit 1, at master level, their own room). No Tension echo. Thin per note.
stems: [(name: \lk, sounds: ~ce.lkKeysSounds ++ [\sdSampleMod, \sdFont], level: \lkLevel, tensionEcho: false, thin: false,
	lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
		(name: \shots, orbit: 1, level: 1.0, roomR: 0.3), (name: \rim, orbit: 1, level: 1.0, roomR: 0.3, echoSend: 0.3),
		(name: \oohs, orbit: 1, level: 1.0, roomR: 0.6), (name: \vib, orbit: 1, level: 1.0, roomR: 0.5)])],
lkCtl: { |ce, num, v, send|
	if(num == 22) { ce.lkTurned2 = true };
	switch(num,
		1, { ce.setState(\lkLevel, v, send) },
		21, { ce.setState(\lkBright, v, send) },
		26, { ce.setState(\lkRoom, 0.9 * (0.1 + (0.7 * v)), send) },
		27, { ce.setState(\lkEcho, 0.6 * v, send) })
},
lkNote: { |ce, note, vel, chan|
	var k = { |n| ce.lkCC[20 + n] }, nl = 0.25 + (1.75 * k.(5));
	var tone = ("c" ++ ce.toneBus).asSymbol, thin = ("c" ++ ce.thinBus).asSymbol;
	if(chan != 9) {
		ce.lkKeysNotes(note, vel, [if(ce.lkTurned2 == true) { k.(2) } { 0.5 }, k.(3), k.(4)],
			(hold: nl * 16, lane: \keys, tone: tone, bright: ce.stateMap(\lkBright), thinF: thin))
	} {
		var shots = [
			(file: "voice/brace.wav", tag: "brace"),
			(file: "voice/piece_of_paper.flac", tag: "paper", gain: 0.99),
			(file: "voice/plaenterwald_wine_and_cheese.flac", tag: "wine", gain: 0.98, once: 5.33),
			(file: "voice/the_evening_progresses.flac", tag: "evening", gain: 1.04, once: 9.25),
			(file: "voice/lw.wav", tag: "lw", gain: 0.56),
			(file: "voice/the_creatures_have_begun_illumination.flac", tag: "creatures", once: 4.52),
			(file: "voice/the_evening_does_not_end.flac", tag: "noend", gain: 0.76, once: 10.19),
			(file: "voice/in_the_vast.flac", tag: "vast", once: 14.6),
			(file: "tr909/cp-00.wav", tag: "rolandtr909_cp", gain: 1.2),
			(file: "tr909/oh-00.wav", tag: "rolandtr909_oh", rate: 0.95, gain: 1.14),
			(file: "tr909/rim-00.wav", tag: "rolandtr909_rim", lane: \rim, gain: 1.19),
			(file: "tr909/lt-00.wav", tag: "rolandtr909_lt", rate: 0.9, gain: 0.76),
			(font: "0530_Aspirin_sf2_file", tag: "gm_voice_oohs", note: 64, adsr: [0.1, nil, nil, 1], lane: \oohs),
			(file: "tr909/cr-00.wav", tag: "rolandtr909_cr", rate: -0.6, gain: 0.54),
			(font: "0110_JCLive_sf2_file", tag: "gm_vibraphone", note: 76, lane: \vib),
			(file: "tr909/sd-00.wav", tag: "rolandtr909_sd", rate: 0.8, gain: 1.28),
		];
		var i = (note - 36) % 16, sh = shots[i], g = (sh[\gain] ? 0.8) * vel, gl = (sh[\gain] ? 1) * vel, now = thisThread.seconds;
		var tv = (0.06 ** ce.val(fogCC)) * (1 + (1.5 * ce.val(tensionCC)));
		var cut = ((18000 * ((800 / 18000) ** k.(8))) * tv).clip(80, 18000);
		var base = (lpOn: 1, lo: cut, hi: cut, tone: 1, thinF: thin, lane: sh[\lane] ? \shots, tag: sh[\tag]);
		ce.lkOnce = ce.lkOnce ? ();
		if(sh[\once].notNil and: { (ce.lkOnce[i] ? -1) > now }) { [] } {
			sh[\once] !? { ce.lkOnce[i] = now + sh[\once] };
			if(sh[\font].notNil) {
				var z = ce.fontNote(sh[\font], sh[\note]), adsr = ce.sdADSR(*(sh[\adsr] ? [nil, nil, nil, nil]));
				z !? { [ce.note(\sdFont, base ++ z ++ (amp: g, g: gl, hold: nl * 16, a: adsr[0], d: adsr[1], s: adsr[2],
					r: adsr[3], midi: sh[\note]))] } ? []
			} {
				[ce.note(\sdSampleMod, base ++ (buf: ce.sampleBuffers[sh[\file]],
					stereoIn: (ce.sampleMono[sh[\file]] != true).asInteger, rate: sh[\rate] ? 1, hold: -1, amp: g, g: gl,
					a: 0.001, d: 0.001, s: 1, r: 0.01))]
			}
		}
	}
},
lkPadNames: ["Brace", "Paper", "Wine", "Evening", "Wiese", "Creatures", "No end", "Vast", "Clap", "Open hat", "Rim echo",
	"Low tom", "Voice ooh", "Crash reverse", "Vibraphone", "Snare"]
)
)
