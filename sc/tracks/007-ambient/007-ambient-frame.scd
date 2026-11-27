// Frame of the 007 ambient stem track (007-ambient.track): three moods on D (Chapter, global button 1, steps through
// lydian, dorian and whole tone at the next bar), the scale of the mood a column asks for, Tension's own tone map and
// wobble, the strips' Tension is the Room knob (CC 28, there is no Thin), the orbits, the global column 8 texts and the
// Launchkey, the same as sc/tracks/007-ambient/007-ambient.scd. Format: sc/lib/stemtrack.scd.
// @col 16:8 8 Global
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Room | 0 = each sound's own room (row 2), up = everything drowns in reverb.
// @ctl g.k3 Tension | build-up: echo, reverb, open filters; the end adds a snare roll.
// @ctl g.fader Master | volume of everything.
// @ctl g.b1 Chapter | mood: floating → melancholic → strange, at the next bar.
// @ctl g.b2 Break | 1st: low end out. 2nd: all back on the one.
// @lk level Keys Level | mod wheel: volume of the keys pad (× master). 0 = keys silent, pads still play.
// @lk k1 Brightness | dark ↔ open (lpf 400–6000 Hz, × fog/tension).
// @lk k2 Resonance | flat ↔ whistling filter peak.
// @lk k3 Attack | instant ↔ very slow swell (4 s).
// @lk k4 Length | short notes (¼ bar) ↔ long (2 bars).
// @lk k5 Detune | one clean voice ↔ wide and wobbly (two detuned voices around it).
// @lk k6 Space | much reverb ↔ far away (it is ambient: never dry).
// @lk k7 Echo | dry ↔ long echo.
// @lk k8 Key Pan | keys: all in the middle ↔ low keys left, high keys right.
// @lk pad.k1 Pitch | drum pads (bank B): natural ↔ an octave down.
// @lk pad.k2 Pad Fog | drum pads: clear ↔ muffled, like the global Fog.
// @lk pad.k3 Pad Thin | drum pads: full ↔ thin.
// @lk pad.k4 Pad Drive | drum pads: clean ↔ driven.
// @lk pad.k5 Pad Spread | drum pads: all in the middle ↔ pad 1 left, pad 16 right.
// @lk pad.k6 Pad Boost | drum pads: as played ↔ louder.
(
var bpm = 70, beat = 60 / bpm;
var moods = [
	(name: "Floating", steps: [0, 2, 4, 6, 7, 9, 11],
		drones: [[26, 33], [26, 33, 40], [19, 26, 33]]),
	(name: "Melancholic", steps: [0, 2, 3, 5, 7, 9, 10],
		drones: [[26, 33], [26, 33, 40], [19, 26, 33]]),
	(name: "Strange", steps: [0, 2, 4, 6, 8, 10],
		drones: [[26, 32], [26, 34, 40], [24, 30, 38]])];
var beatNames = ["Beat on", "Beat off"];
var anyChord = ~ce.chordOf("Dm", "d2", "d3 f3 a3", "d e f g a bb c");
(
global: (fog: 20, thin: 127, tension: 28, master: 12),
chapterBars: 1,
moods: moods,
// Strudel's n(deg).scale('D<oct>:<mood>'): the degree (rounded up) in the mood's scale from D<oct>, octaves wrap
degMidi: { |frame, deg, oct, mood| var st = deg.ceil.asInteger, sc = moods[mood][\steps], n = sc.size;
	(12 * (oct + 1)) + 2 + sc[st % n] + (12 * (st / n).floor) },
moodAt: { |frame, track, b| track.chapter.atBar(b) },
chordAt: { |frame, track, bar| anyChord },
maps: (
	tone: (ccs: [20, 36], fn: { |f, t| (0.06 ** f) * (1 + (1.5 * t)) }),
	wobble: (ccs: [36], fn: { |t| ((t - 0.5) / 0.5).clip(0, 1) * 0.1 })),
uiHead: { |frame, track, ce|
	var pend = { |now, next| if(now == next) { [now] } { [now, next] } };
	[["Chapter"] ++ pend.("D " ++ moods[track.chapter.now][\name], "D " ++ moods[track.chapter.pending][\name]),
	 ["Break"] ++ pend.(beatNames[track.breakL.now], beatNames[track.breakL.pending])]
},
uiGlobal: { |frame, track, ce| (b1: ["D " ++ moods[track.chapter.now][\name], "D " ++ moods[track.chapter.pending][\name]],
	b2: [beatNames[track.breakL.now], beatNames[track.breakL.pending]], b2on: track.breakL.pending == 1) },
// Orbit 1 = pulse, sea / wind, drone, bass, choir, voice: hall 6.5, dotted-quarter echo. Orbit 2 = rim, shaker, wood, pad,
// Eno / shimmer, marimba, toms, glitter: hall 6, dotted-8th echo (IRs measured from superdough, tools/sc-port/reverb-ir.mjs).
orbits: (1: (ir: "ir/orbit-6.5.wav", delay: [1.5 * beat, 0.5]), 2: (ir: "ir/orbit-6.wav", delay: [0.75 * beat, 0.6])),
states: (lkLevel: 0, lkBright: 0, lkRes: 0, lkDet: 4, lkDetN: -4, lkRoom: 0.9 * 0.5, lkEcho: 0),
samples: ~ce.vcslFiles ++ (0..11).collect { |i| "vcsl/shaker_small/" ++ ["Mid_ShakerDouble_Down", "Mid_ShakerDouble_Up",
		"Mid_ShakerHighFaster_Down", "Mid_ShakerHighFaster_Up", "Mid_ShakerLowFaster_Down", "Mid_ShakerLowFaster_Up"][i div: 2]
		++ "_rr" ++ ((i % 2) + 1) ++ ".flac" }
	++ ["vcsl/cabasa/Cabasa1_Hit_rr1_Mid.flac", "vcsl/cabasa/Cabasa1_Hit_rr2_Mid.flac", "vcsl/tom2_mallet/TomL_HitM_v2_rr1_Mid.flac",
		"vcsl/agogo/Agogo_High_v2_rr1_Mid.flac",
		// the Launchkey's pads
		"voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac", "voice/the_evening_progresses.flac",
		"voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac", "voice/the_evening_does_not_end.flac",
		"voice/in_the_vast.flac", "dirt/wind-00.wav", "dirt/space-00.wav", "tr909/cr-00.wav"]
	++ ~ce.fontFiles("0090_JCLive_sf2_file") ++ ~ce.fontFiles("0520_Aspirin_sf2_file") ++ ~ce.fontFiles("0530_Aspirin_sf2_file"),
stems: [
	(name: \lk, sounds: [\sdSynthFx, \sdFont, \sdSampleMod, \sdNoise], level: \lkLevel, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \r03, orbit: 1, level: 1.0, roomR: 0.3), (name: \r07, orbit: 1, level: 1.0, roomR: 0.7),
			(name: \r08, orbit: 1, level: 1.0, roomR: 0.8), (name: \r09, orbit: 1, level: 1.0, roomR: 0.9)]),
],
// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these). Mod wheel (CC 1) = keys level (× master, up to
// × 2, from the next key), knobs CC 21-28: 1 cutoff, 2 resonance, 3 attack, 4 note length, 5 detune, 6 reverb, 7 echo, 8 key pan spread; bank B (CC 31-38) = the drum pads: 1 pitch, 2 fog, 3 thin, 4 drive, 5 spread, 6 boost. Every key
// plays a note of fixed length (Strudel's midikeys has no note-off: the length is knob 4). Brightness, Resonance and
// Detune act at once on sounding keys (state buses), the rest from the next key.
lkCtl: { |ce, num, v, send|
	switch(num,
		1, { ce.setState(\lkLevel, 2 * v, send) },
		21, { ce.setState(\lkBright, v, send) },
		22, { ce.setState(\lkRes, 12 * v, send) },
		25, { ce.setState(\lkDet, 100 * (0.04 + (0.26 * v)), send); ce.setState(\lkDetN, -100 * (0.04 + (0.26 * v)), send) },
		26, { ce.setState(\lkRoom, 0.9 * (0.5 + (0.5 * v)), send) },   // roomOf(0.5 … 1)
		27, { ce.setState(\lkEcho, 0.6 * v, send) })
},
lkNote: { |ce, note, vel, chan|
	var k = { |n| ce.lkCC[20 + n] }, nl = 0.25 + (1.75 * k.(4));   // note length in bars
	var tone = ("c" ++ ce.mapBus[\tone]).asSymbol;
	if(chan != 9) {
		// keys: a soft glass pad, a triangle with two quiet saws detuned up and down (sdSynthFx: the detune is live)
		var a = 0.01 * (400 ** k.(3)), base = (hold: nl * 16, lpOn: 1, bright: ce.stateMap(\lkBright), lo: 400, hi: 6000, tone: tone,
			lpq: ce.stateMap(\lkRes), a: a, d: 0.6, s: 0.8, r: 3, lane: \keys) ++ ce.lkKeyPanArgs(note);
		[[1, 0.45, 0], [2, 0.12, 1], [2, 0.12, -1]].collect { |x|
			ce.note(\sdSynthFx, base ++ (wave: x[0], freq: note.midicps, amp: x[1] * vel,
				cents: if(x[2] == 0) { 0 } { if(x[2] > 0) { ce.stateMap(\lkDet) } { ce.stateMap(\lkDetN) } },
				tag: ["", "triangle", "sawtooth"][x[0]], g: x[1] * vel, midi: note + (x[2] * ce.stateVal[\lkDet] / 100))) }
	} {
		// drum pads 36-51: the spoken samples (left half), bells, voices, wind (right half); each shot's room on its lane
		var shots = [
			(file: "voice/brace.wav", tag: "brace"),
			(file: "voice/piece_of_paper.flac", tag: "paper", gain: 0.99),
			(file: "voice/plaenterwald_wine_and_cheese.flac", tag: "wine", gain: 0.98, once: 5.33),
			(file: "voice/the_evening_progresses.flac", tag: "evening", gain: 1.04, once: 9.25),
			(file: "voice/lw.wav", tag: "lw", gain: 0.56),
			(file: "voice/the_creatures_have_begun_illumination.flac", tag: "creatures", once: 4.52),
			(file: "voice/the_evening_does_not_end.flac", tag: "noend", gain: 0.76, once: 10.19),
			(file: "voice/in_the_vast.flac", tag: "vast", once: 14.6),
			(font: "0090_JCLive_sf2_file", tag: "gm_glockenspiel", midi: 86, lane: \r07),
			(vcsl: \vibraphone_bowed, tag: "vibraphone_bowed", midi: 62, lane: \r07, gain: 6.5),
			(font: "0520_Aspirin_sf2_file", tag: "gm_choir_aahs", midi: 62, a: 0.3, r: 2, lane: \r08),
			(font: "0530_Aspirin_sf2_file", tag: "gm_voice_oohs", midi: 69, a: 0.2, r: 2, lane: \r08),
			(file: "dirt/wind-00.wav", tag: "wind", rate: 0.5, lane: \r08, gain: 1.36),
			(file: "dirt/space-00.wav", tag: "space", rate: 0.5, lane: \r09, gain: 0.65),
			(noise: 0, tag: "pink", a: 0.4, d: 1.6, s: 0, r: 1.5, cutoff: 1500, gain: 4.4, lane: \r08),
			(file: "tr909/cr-00.wav", tag: "rolandtr909_cr", rate: -0.5, lane: \r07, gain: 0.54),
		];
		// gain: the shot's own, else superdough's default 0.8 (the log keeps Strudel's notation: gain × velocity, missing = 1)
		var i = (note - 36) % 16, sh = shots[i], pm = ce.lkPadMods(i), gl = (sh[\gain] ? 1) * vel,
			g = (sh[\gain] ? 0.8) * vel * pm[\gain], now = thisThread.seconds;
		// the low-pass: pad knob 2 (CC 32, 18 kHz → 800 Hz) × Fog / Tension (read here: one-shots keep it), the shot's own at most
		var tv = (0.06 ** ce.val(20)) * (1 + (1.5 * ce.val(36)));
		var cut = ((18000 * ((800 / 18000) ** ce.lkPad(2))) * tv).clip(80, 18000).min(sh[\cutoff] ? 18000);
		var lp = (lpOn: 1, lo: cut, hi: cut, tone: 1, lane: sh[\lane] ? \r03, tag: sh[\tag], g: gl) ++ pm[\base];
		// a shot with `once` ignores new hits until it has played out
		ce.lkOnce = ce.lkOnce ? ();
		if(sh[\once].notNil and: { (ce.lkOnce[i] ? -1) > now }) { [] } {
			sh[\once] !? { ce.lkOnce[i] = now + sh[\once] };
			case
			{ sh[\font].notNil } { var f = ce.fontNote(sh[\font], sh[\midi]), v = ce.sdADSR(sh[\a], nil, nil, sh[\r]);
				[ce.note(\sdFont, f ++ lp ++ (amp: g, hold: nl * 16, midi: sh[\midi], a: v[0], d: v[1], s: v[2], r: v[3]))] }
			{ sh[\vcsl].notNil } { var pick = ce.vcslPickOf(sh[\vcsl], sh[\midi]);
				[ce.note(\sdSampleMod, (buf: ce.sampleBuffers[pick[0]], stereoIn: (ce.sampleMono[pick[0]] != true).asInteger, rate: pick[1],
					amp: g, hold: -1, midi: sh[\midi], a: 0.001, d: 0.001, s: 1, r: 0.01) ++ lp)] }
			{ sh[\noise].notNil } {
				[ce.note(\sdNoise, (color: 0, amp: g, hold: nl * 16, a: sh[\a], d: sh[\d], s: sh[\s], r: sh[\r]) ++ lp)] }
			{ [ce.note(\sdSampleMod, (buf: ce.sampleBuffers[sh[\file]], stereoIn: (ce.sampleMono[sh[\file]] != true).asInteger,
				rate: (sh[\rate] ? 1) * pm[\rate], amp: g, hold: -1, a: 0.001, d: 0.001, s: 1, r: 0.01) ++ lp)] }
		}
	}
},
// web UI: the names of the 16 drum pads (pads 1-8 = notes 36-43, 9-16 = 44-51)
lkPadNames: ["Brace", "Paper", "Wine", "Evening", "Meadow", "Creatures", "No end", "Vast", "Glockenspiel", "Bowed vibe",
	"Choir aah", "Voice ooh", "Wind", "Space", "Noise swell", "Crash reverse"],
)
)
