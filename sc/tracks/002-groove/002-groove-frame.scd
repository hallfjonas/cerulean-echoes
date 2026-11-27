// Frame of the 002 groove stem track (002-groove.track): the three moods (Chapter), the six progressions (Chords, column
// 2:1 button 1) and their rhythms (button 2), the orbits, the global column 8 texts and the Launchkey, the same as
// sc/tracks/002-groove/002-groove.scd. Format: sc/lib/stemtrack.scd.
// Column 8's fader is Master in name but not a volume: kick and bass read it per note (more low end, punch, drive), so
// the frame is masterless. Chapter = the mood, all on D: Boogie (dorian), Italo (minor), Sunrise (mixolydian); it switches at
// the next bar. Every column plays degrees of the chord root (progressions) in the mood's scale: frame.degMidi, rootAt,
// tonesAt.
// @col 16:8 8 Global
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Thin | full ↔ thin (all high-passes up).
// @ctl g.k3 Tension | density: pad in, echo, reverb; the end adds a snare roll.
// @ctl g.fader Master | more low end, punch and drive.
// @ctl g.b1 Chapter | mood: boogie → Italo → sunrise, at the next bar.
// @ctl g.b2 Break | kick and bass out; press again: back on the one.
// @lk level Keys Level | mod wheel: volume of the keys.
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
var bpm = 124, beat = 60 / bpm, fogCC = 20, tensionCC = 36;
var moods = [(name: "Boogie", steps: [0, 2, 3, 5, 7, 9, 10]), (name: "Italo", steps: [0, 2, 3, 5, 7, 8, 10]),
	(name: "Sunrise", steps: [0, 2, 4, 5, 7, 9, 10])];
var progs = [[0, 0, 3, 3], [0, 1, 0, 1], [0, -1, -2, -1], [0, -2, -1, 0], [3, 4, 0, 0], [0, 0, 0, 0]];
var progNames = ["i–IV", "i–ii", "i–VII–VI", "i–VI–VII", "iv–v–i", "Vamp"];
var rhythms = [["Off-beat", "[~ x]*4"], ["Boogie", "~ ~ x ~ ~ x ~ ~ ~ ~ x ~ ~ x ~ ~"], ["Held", "x"]];
var beatNames = ["Beat on", "Beat off"];
var anyChord = ~ce.chordOf("Dm7", "d2", "c4 d4 f4 a4", "d e f g a b c");
(
chapterBars: 1,
masterless: true,
tensionEchoAmt: 0.2,
tensionRoomAmt: 0.35,
rhythms: rhythms,
// the degree in the mood's scale from D<oct>; octaves wrap, also below
degMidi: { |frame, deg, oct, mood| var st = deg.ceil.asInteger;
	(12 * (oct + 1)) + 2 + moods[mood].steps[st % 7] + (12 * (st / 7).floor) },
rootAt: { |frame, track, b| progs[track.prog.atBar(b)][(b / 2).floor % 4] },
tonesAt: { |frame, track, b, shape, oct|
	shape.collect { |d| frame.degMidi(d + frame.rootAt(track, b), oct, track.chapterAt(b)) } },
chordAt: { |frame, track, bar| anyChord },
nextChords: { |frame, track| var l = track.prog;
	l.pending = (l.pending + 1) % progs.size; track.ce.status("Chords (next)", progNames[l.pending]) },
build: { |frame, track, ce|
	track.prog = ce.latch(1, 0, { |i| ce.status("Chords", progNames[i]); ce.uiPush });
	ce.uiRows['jonas:1'] = (latch: track.prog, names: progNames);
	track.rhythm = ce.latch(1, 0, { |i| ce.status("Rhythm", rhythms[i][0]); ce.uiPush });
	ce.cycleButton(93, rhythms.size, { |s| track.rhythm.pending = s });
},
uiHead: { |frame, track, ce|
	var pend = { |now, next| if(now == next) { [now] } { [now, next] } };
	[["Chapter"] ++ pend.("D " ++ moods[track.chapter.now].name, "D " ++ moods[track.chapter.pending].name),
	 ["Rhythm"] ++ pend.(rhythms[track.rhythm.now][0], rhythms[track.rhythm.pending][0]),
	 ["Break"] ++ pend.(beatNames[track.breakL.now], beatNames[track.breakL.pending])]
},
uiGlobal: { |frame, track, ce| (b1: ["D " ++ moods[track.chapter.now].name, "D " ++ moods[track.chapter.pending].name],
	b2: [beatNames[track.breakL.now], beatNames[track.breakL.pending]], b2on: track.breakL.pending == 1) },
// Effect buses (Strudel orbits). Orbit 1 = drums and bass: small dry room (size 1.4), short dotted-8th slap.
// Orbit 2 = Jonas' colour: a hall (3.5), dotted-8th echo. Orbit 3 = the snare's gated room: short and dense (0.9).
// Impulse responses measured from superdough (tools/sc-port/reverb-ir.mjs).
orbits: (1: (ir: "ir/orbit-1.4.wav", delay: [0.75 * beat, 0.3]), 2: (ir: "ir/orbit-3.5.wav", delay: [0.75 * beat, 0.4]),
	3: (ir: "ir/orbit-0.9.wav", delay: [0.25 * beat, 0.2]), 4: (ir: "ir/orbit-2.2.wav", delay: [0.25 * beat, 0.2])),
// state buses: room and echo amounts the language derives from knobs (columns whose Space is scaled, echo throws)
states: (lkLevel: 0, lkBright: 0, lkRoom: 0.9 * 0.1, lkEcho: 0),
// samples the drum stems play (the files Strudel plays: tidal-drum-machines, see sc/samples/CREDITS.md)
samples: ["tr909/bd-01.wav", "tr909/sd-00.wav", "tr909/cp-00.wav", "tr909/rim-00.wav", "tr909/hh-00.wav", "tr909/oh-00.wav",
	"tr808/cb-00.wav", "tr727/perc-02.wav", "tr727/perc-03.wav", "tr727/perc-04.wav", "tr727/sh-00.wav",
	// the Launchkey's drum pads (as 016): the spoken samples, drum-machine one-shots, Dirt-Samples
	"voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac", "voice/plaenterwald.flac",
	"voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac", "voice/the_evening_does_not_end.flac", "voice/in_the_vast.flac",
	"tr909/lt-00.wav", "tr909/cr-00.wav", "tr808/sh-00.wav", "dirt/space-00.wav", "dirt/wind-00.wav"] ++ ~ce.lkKeysFiles,

stems: [
	(name: \lk, sounds: ~ce.lkKeysSounds ++ [\sdSampleMod, \sdSynthMod], level: \lkLevel, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \shots, orbit: 1, level: 1.0, roomR: 0.3, tensionRoomAmt: 1), (name: \lt, orbit: 1, level: 1.0, roomR: 0.5, tensionRoomAmt: 1),
			(name: \rim, orbit: 1, level: 1.0, roomR: 0.3, echoSend: 0.4, tensionRoomAmt: 1), (name: \orch, orbit: 1, level: 1.0, roomR: 0.6, tensionRoomAmt: 1),
			(name: \space, orbit: 1, level: 1.0, roomR: 0.9, tensionRoomAmt: 1), (name: \wind, orbit: 1, level: 1.0, roomR: 0.8, tensionRoomAmt: 1)]),
],
// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these), the same as 016's. Mod wheel (CC 1) = keys level,
// knobs CC 21-28: 1 brightness, 2-4 the keys' sound pairs, 5 length, 6 space, 7 echo, 8 key pan spread; bank B (CC 31-38) = the drum pads: 1 pitch, 2 fog, 3 thin, 4 drive, 5 spread, 6 boost.
// key pan starts at 100 %: the low keys left, the high keys right
lkStart: (28: 1),
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
		var i = (note - 36) % 16, sh = shots[i], pm = ce.lkPadMods(i),
			g = (sh[\gain] ? 0.8) * vel * pm[\gain], gl = (sh[\gain] ? 1) * vel, now = thisThread.seconds;
		// the low-pass: pad knob 2 (CC 32, 18 kHz → 800 Hz) × Fog / Tension at the hit
		var tv = (0.06 ** ce.val(fogCC)) * (1 + (1.5 * ce.val(tensionCC)));
		var cut = ((18000 * ((800 / 18000) ** ce.lkPad(2))) * tv).clip(80, 18000);
		var base = (lpOn: 1, lo: cut, hi: cut, tone: 1, thinF: thin, lane: sh[\lane] ? \shots, tag: sh[\tag]) ++ pm[\base];
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
					rate: (sh[\rate] ? 1) * pm[\rate], hold: -1, amp: g, g: gl, hp: max(sh[\hp] ? 0, pm[\hp]), a: 0.001, d: 0.001, s: 1, r: 0.01))]
			}
		}
	}
},
// web UI: the names of the 16 drum pads (pads 1-8 = notes 36-43, 9-16 = 44-51)
lkPadNames: ["Brace", "Paper", "Wine", "Forest", "Meadow", "Creatures", "No end", "Vast", "Low tom", "Rim echo",
	"Orch hit", "Open hat", "Crash reverse", "Shaker", "Space", "Wind"],
)
)
