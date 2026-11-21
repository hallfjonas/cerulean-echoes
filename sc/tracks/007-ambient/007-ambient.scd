// TRACK 007 AMBIENT — SuperCollider port of tracks/ambient/007-ambient-soundscape/007-ambient.strudel (dreamy ambient
// on D, 70 BPM, three moods). Same controller layout as the Strudel track: Mode 1 = Jojo (foundation, plain CCs),
// Mode 2 = Jonas (colour, CC + 48), column 8 global on both (Jojo's column 8, the crackle, is off as in Strudel), the
// Launchkey MK4 25 optional. Ported 1:1 (see sc/PORTING.md). Level (faders, mod wheel) acts from the next note, as in
// Strudel; Space, echo and the global column act at once, also on sounding notes; Brightness and the sound crossfades act at once on the long sounds (sea / wind, drone, bass, pad,
// Eno bowed and shimmer, choir, the voice's distortion, Launchkey keys), on the short ones from the next note; pattern
// buttons switch at the next bar.
// The @ tags below are read by the web UI (sc/ui): column names, and each control's name | what it does.
// @layout Track 007 — ambient moods (SuperCollider)
// @mode 16 Mode 1 — Jojo: Foundation (beat + bass) · same CCs as Mode 16
// @col 16:1 1 Pulse
// @col 16:2 2 Sea
// @col 16:3 3 Drone
// @col 16:4 4 Bass
// @col 16:5 5 Rim
// @col 16:6 6 Shaker
// @col 16:7 7 Wood
// @col 16:8 8 Global
// @mode 2 Mode 2 — Jonas: Colour (chords + melodies) · CC + 48
// @col 2:1 1 Pad
// @col 2:2 2 Shimmer
// @col 2:3 3 Marimba
// @col 2:4 4 Toms
// @col 2:5 5 Choir
// @col 2:6 6 Glitter
// @col 2:7 7 Voice
// @col 2:8 8 Global
// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).
// @ctl g.k2 Room | 0 = each sound's own room (row 2), up = everything drowns in reverb.
// @ctl g.k3 Tension | build-up: echo, reverb, open filters; the end adds a snare roll.
// @ctl g.fader Master | volume of everything.
// @ctl g.b1 Chapter | mood: floating → melancholic → strange, at the next bar.
// @ctl g.b2 Break | 1st: low end out. 2nd: all back on the one.
// @ctl 16:1.k1 Brightness | dull ↔ bright.
// @ctl 16:1.k2 Space | dry ↔ room.
// @ctl 16:1.k3 Punch | three steps: soft sine thump → synth kick → firm kick with more click.
// @ctl 16:1.fader Level | 0 = gone. A heartbeat thump on D.
// @ctl 16:1.b1 Pattern | heartbeat → quarters → half notes.
// @ctl 16:1.b2 Drop out | pulse pauses while held.
// @ctl 16:2.k1 Brightness | dull ↔ bright.
// @ctl 16:2.k2 Space | dry ↔ room.
// @ctl 16:2.k3 Sea ↔ Wind | 0 = brown-noise waves rolling in, 0.5 = both, 1 = only whistling wind gusts.
// @ctl 16:2.fader Level | sea and wind. Keeps playing in the break.
// @ctl 16:2.b1 Pattern | next of 3 random wave / gust patterns.
// @ctl 16:2.b2 Riser | a noise sweep rises over 2 bars while held.
// @ctl 16:3.k1 Brightness | dull ↔ bright.
// @ctl 16:3.k2 Space | dry ↔ room.
// @ctl 16:3.k3 Beating | pure sines ↔ detuned saw beating.
// @ctl 16:3.fader Level | slow drone chords on D.
// @ctl 16:3.b1 Pattern | 3 drone chords per chapter: D–A → D–A–E → G–D–A.
// @ctl 16:4.k1 Brightness | dull ↔ bright.
// @ctl 16:4.k2 Space | dry ↔ room.
// @ctl 16:4.k3 Groove | 0 = a soft swell every bar. Up to 0.5 a 3-3-2 pulse fades in, at 1 only the pulse.
// @ctl 16:4.fader Level | slow bass swells.
// @ctl 16:4.b1 Pattern | next of 3 bass lines (a note every 2 bars).
// @ctl 16:4.b2 Octave | one octave up while held.
// @ctl 16:5.k1 Brightness | dull ↔ bright.
// @ctl 16:5.k2 Space | dry ↔ room.
// @ctl 16:5.k3 Complexity | plain ↔ extra quiet clicks in between.
// @ctl 16:5.fader Level | soft rim click on 2 and 4.
// @ctl 16:5.b1 Pattern | backbeat → late ghost → offset click.
// @ctl 16:5.b2 Roll | 16th roll, growing over the bar, while held.
// @ctl 16:6.k1 Brightness | dull ↔ bright.
// @ctl 16:6.k2 Space | dry ↔ room.
// @ctl 16:6.k3 Complexity | 0 = the figure ↔ + quiet 16ths, from the middle a cabasa on 4.
// @ctl 16:6.fader Level | shaker.
// @ctl 16:6.b1 Pattern | 8ths → 16ths → rocking 3-3-2.
// @ctl 16:6.b2 Echo throw | held: long dotted-8th echo.
// @ctl 16:7.k1 Brightness | dull ↔ bright.
// @ctl 16:7.k2 Space | dry ↔ room.
// @ctl 16:7.k3 Complexity | a click now and then ↔ a busy pattern.
// @ctl 16:7.fader Level | wood clicks and drops.
// @ctl 16:7.b1 Pattern | next of 3 random patterns.
// @ctl 16:7.b2 Fill | almost every 16th plays while held.
// @ctl 2:1.k1 Brightness | dull ↔ bright.
// @ctl 2:1.k2 Space | dry ↔ echo + room.
// @ctl 2:1.k3 Swell | still chords ↔ re-struck and breathing.
// @ctl 2:1.fader Level | long floating chords.
// @ctl 2:1.b1 Pattern | 3 chord progressions: calm → circling → open.
// @ctl 2:1.b2 Freeze | holds the current chord while held.
// @ctl 2:2.k1 Brightness | dull ↔ bright.
// @ctl 2:2.k2 Space | dry ↔ echo + room.
// @ctl 2:2.k3 Complexity | more loops; the shimmer adds a bell chord.
// @ctl 2:2.fader Level | bowed loops (low) and shimmer swells (high).
// @ctl 2:2.b1 Pattern | note set: calm → lydian → low; shimmer pace too.
// @ctl 2:2.b2 Layer | Eno → Shimmer → both, at the next bar.
// @ctl 2:3.k1 Brightness | dull ↔ bright.
// @ctl 2:3.k2 Space | dry ↔ echo + room.
// @ctl 2:3.k3 Complexity | one figure ↔ all layers.
// @ctl 2:3.fader Level | marimba figures laid over each other (Takada).
// @ctl 2:3.b1 Pattern | cycles → canon → cells → Euclid → build-up.
// @ctl 2:3.b2 Echo throw | held: long dotted-8th echo.
// @ctl 2:4.k1 Brightness | dull ↔ bright.
// @ctl 2:4.k2 Space | dry ↔ echo + room.
// @ctl 2:4.k3 Complexity | 0 = the figure alone ↔ fuller: rests fill up, canon voices, a drifting copy.
// @ctl 2:4.fader Level | tom figures.
// @ctl 2:4.b1 Pattern | cycles → canon → Euclid → build-up → crossing → Clapping.
// @ctl 2:4.b2 Echo throw | held: long dotted-8th echo.
// @ctl 2:5.k1 Brightness | dull ↔ bright.
// @ctl 2:5.k2 Space | dry ↔ echo + room.
// @ctl 2:5.k3 Complexity | 0 = one voice, 0.5 = + a third above, 1 = + a fifth: three-part harmony.
// @ctl 2:5.fader Level | choir voices.
// @ctl 2:5.b1 Pattern | middle → low → high register (new melody each time).
// @ctl 2:5.b2 Full choir | all three voices while held.
// @ctl 2:6.k1 Brightness | dull ↔ bright.
// @ctl 2:6.k2 Space | dry ↔ echo + room.
// @ctl 2:6.k3 Complexity | a drop now and then (~1 per bar) ↔ a sparkling rain (~70 % of the 16ths).
// @ctl 2:6.fader Level | random glockenspiel notes.
// @ctl 2:6.b1 Pattern | high → very high → middle register.
// @ctl 2:6.b2 Run | scale runs, denser while held.
// @ctl 2:7.k1 Brightness | dull ↔ bright.
// @ctl 2:7.k2 Space | dry ↔ echo + room.
// @ctl 2:7.k3 Distortion | radio → rougher → past half: crushed, broken.
// @ctl 2:7.fader Level | the spoken voice, looping.
// @ctl 2:7.b2 Stutter | held: each beat's start repeats in 16ths.
// @lk level Keys Level | mod wheel: volume of the keys pad (× master). 0 = keys silent, pads still play.
// @lk k1 Brightness | dark ↔ open (lpf 400–6000 Hz, × fog/tension).
// @lk k2 Resonance | flat ↔ whistling filter peak.
// @lk k3 Attack | instant ↔ very slow swell (4 s).
// @lk k4 Length | short notes (¼ bar) ↔ long (2 bars).
// @lk k5 Detune | one clean voice ↔ wide and wobbly (two detuned voices around it).
// @lk k6 Space | much reverb ↔ far away (it is ambient: never dry).
// @lk k7 Echo | dry ↔ long echo.
// @lk k8 Pad Fog | drum pads: clear ↔ muffled, like the global Fog (lpf 18 kHz → 800 Hz).
(
var bpm = 70, beat = 60 / bpm;
// ---------------------------------------------------------------------------------------------------------
// CC numbers of column n (1-8): row 1-3 knobs, fader, buttons. Jojo = plain, Jonas = + 48.
var col = { |n, plus = 0| (bright: 12 + n + plus, space: 20 + n + plus, char: 28 + n + plus, level: 4 + n + plus,
	btn: 36 + n + plus, btn2: 44 + n + plus) };
var jojo = { |n| col.(n) }, jonas = { |n| col.(n, 48) };
var glob = col.(8);   // column 8 (global): Fog, Room, Tension, Master, Chapter, Break; its Mode 2 CCs are aliases

// ---------------------------------------------------------------------------------------------------------
// MOODS (Chapter, global button 1) — all on D. Drone chords as MIDI notes per mood (whole tone has no fifth).
var moods = [
	(name: "Floating", steps: [0, 2, 4, 6, 7, 9, 11],    // D lydian
		drones: [[26, 33], [26, 33, 40], [19, 26, 33]], names: ["D–A", "D–A–E", "G–D–A"]),
	(name: "Melancholic", steps: [0, 2, 3, 5, 7, 9, 10],   // D dorian
		drones: [[26, 33], [26, 33, 40], [19, 26, 33]], names: ["D–A", "D–A–E", "G–D–A"]),
	(name: "Strange", steps: [0, 2, 4, 6, 8, 10],          // D whole tone
		drones: [[26, 32], [26, 34, 40], [24, 30, 38]], names: ["D–G♯", "D–A♯–E", "C–F♯–D"])];
// Strudel's n(deg).scale('D<oct>:<mood>'): the degree (rounded up) in the mood's scale from D<oct>, octaves wrap
var degMidi = { |deg, oct, mood| var st = deg.ceil.asInteger, sc = moods[mood].steps, n = sc.size;
	(12 * (oct + 1)) + 2 + sc[st % n] + (12 * (st / n).floor) };
var ramp = { |v, from, to| ((v - from) / (to - from)).clip(0, 1) };
// Row-3 crossfade: 0..0.5 brings the extra layer in, 0.5..1 fades the main layer out
var fadeMain = { |k| ramp.(k, 1, 0.5) }, fadeExtra = { |k| ramp.(k, 0, 0.5) };
// Strudel mini-notation polymeter "{a b c}%n": n steps per bar, the tokens cycling over all bars (k = step number)
var toks = { |str| str.split($ ).reject(_.isEmpty) };
var num = { |x| if(x == "~") { nil } { x.asFloat } };
// the lab's brightness level: ±2 dB over the knob (Shaker, Eno, Marimba, Toms)
var brightDb = { |b| 10 ** (4 * (b - 0.5) / 20) };
// VCSL sample maps (strudel.cc's vcsl.json, in its key order): [MIDI key, file]; nearest key, the first on a tie
var vcsl = (
	vibraphone_bowed: [[45, "A2"], [69, "A4"], [62, "D4"], [52, "E3"], [76, "E5"], [55, "G3"]],
	xylophone_soft_ff: [[60, "C4"], [72, "C5"], [84, "C6"], [96, "C7"], [55, "G3"], [67, "G4"], [79, "G5"], [91, "G6"]],
	glockenspiel: [[72, "C5"], [84, "C6"], [96, "C7"], [92, "G#6"], [67, "G4"], [79, "G5"], [91, "G6"]]);
var vcslFile = (
	vibraphone_bowed: { |k| "vcsl/vibraphone_bowed/Vibes_bowed_" ++ k ++ "_rr1_Main.flac" },
	xylophone_soft_ff: { |k| "vcsl/xylophone_soft_ff/Xylo_Soft_" ++ k ++ "_ff_01_far.flac" },
	glockenspiel: { |k| "vcsl/glockenspiel/" ++ Dictionary["C5" -> "glock_soft_C5_02", "C6" -> "glock_soft_C6_01",
		"C7" -> "glock_soft_C7_03", "G#6" -> "glock_loud_G#6_01", "G4" -> "glock_soft_G4_01", "G5" -> "glock_soft_G5_01",
		"G6" -> "glock_soft_G6_01"][k] ++ ".flac" });
var vcslPick = { |name, m| var best = vcsl[name].inject(nil, { |b, x| if(b.isNil or: { (x[0] - m).abs < (b[0] - m).abs }) { x } { b } });
	[vcslFile[name].(best[1]), 2 ** ((m - best[0]) / 12)] };
var vcslFiles = vcsl.keys.asArray.collect { |nm| vcsl[nm].collect { |x| vcslFile[nm].(x[1]) } }.flatten;
// the spoken recording (Jonas 7): its length in seconds, as the Strudel track has it
var davidSec = 552.9;

(
name: "007-ambient",
bpm: bpm,
// The strips' "tension" input raises every room towards 0.95: in 007 that is the global Room knob (Strudel roomOf).
// Fog and Tension work through the tone map below (Tension's echo and wobble through state / map buses). No Thin.
global: (fog: glob.bright, thin: 127, tension: glob.space, master: glob.level),
aliases: [\bright, \space, \char, \level, \btn, \btn2].collect { |r| (glob[r] + 48) -> glob[r] }.asDict,
// map buses (server side, follow the knobs at once): the low-pass factor of every stem (Fog × Tension's opening), the
// Tension wobble (vibrato depth on the long sounds), the drone's beating detune, the voice's distortion
maps: (
	tone: (ccs: [glob.bright, glob.char], fn: { |f, t| (0.06 ** f) * (1 + (1.5 * t)) }),
	wobble: (ccs: [glob.char], fn: { |t| ((t - 0.5) / 0.5).clip(0, 1) * 0.1 }),
	droneCents: (ccs: [jojo.(3).char], fn: { |c| 30 * c }),
	shakerTrim: (ccs: [jojo.(6).bright], fn: { |b| 0.89 * (10 ** (4 * (b - 0.5) / 20)) }),
	enoTrim: (ccs: [jonas.(2).bright], fn: { |b| 10 ** (4 * (b - 0.5) / 20) }),
	marTrim: (ccs: [jonas.(3).bright], fn: { |b| 1.3 * (10 ** (4 * (b - 0.5) / 20)) }),
	tomTrim: (ccs: [jonas.(4).bright], fn: { |b| 14 * (10 ** (4 * (b - 0.5) / 20)) }),
	// the voice (Jonas 7, row 3 = a): radio part r = min(1, 2a), break c = max(0, 2a − 1)
	vHp: (ccs: [jonas.(7).char], fn: { |a| 350 + (250 * (2 * a).min(1)) }),
	vBq: (ccs: [jonas.(7).char], fn: { |a| 0.8 + (1.7 * (2 * a).min(1)) }),
	vShape: (ccs: [jonas.(7).char], fn: { |a| 0.15 + (0.25 * (2 * a).min(1)) }),
	vPre: (ccs: [jonas.(7).char], fn: { |a| 1 - (0.45 * ((2 * a) - 1).max(0)) }),
	vDist: (ccs: [jonas.(7).char], fn: { |a| var c = ((2 * a) - 1).max(0); (c > 0) * (0.5 + (4.5 * c)) }),
	vCrush: (ccs: [jonas.(7).char], fn: { |a| var c = ((2 * a) - 1).max(0); (c > 0.35) * (10 - (7 * (c - 0.35) / 0.65)) }),
	vCoarse: (ccs: [jonas.(7).char], fn: { |a| var c = ((2 * a) - 1).max(0); Select.kr(c > 0.7, [1, (1 + (7 * (c - 0.7) / 0.3)).round]) }),
	vHiss: (ccs: [jonas.(7).char], fn: { |a| 0.015 + (0.045 * (2 * a).min(1)) }),
	vCrackle: (ccs: [jonas.(7).char], fn: { |a| 0.1 + (0.2 * (2 * a).min(1)) }),
),
// web UI: the head line (chapter, break) and column 8's buttons
uiHead: { |self, ce|
	var pend = { |now, next| if(now == next) { [now] } { [now, next] } };
	[["Chapter"] ++ pend.("D " ++ moods[self.mood.now].name, "D " ++ moods[self.mood.pending].name),
	 ["Break"] ++ pend.(["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending])]
},
uiGlobal: { |self, ce| (b1: ["D " ++ moods[self.mood.now].name, "D " ++ moods[self.mood.pending].name],
	b2: [["Beat on", "Beat off"][self.breakL.now], ["Beat on", "Beat off"][self.breakL.pending]], b2on: self.breakL.pending == 1) },
// Effect buses (Strudel BUSES). Orbit 1 = pulse, sea / wind, drone, bass, choir, voice: hall 6.5, dotted-quarter echo.
// Orbit 2 = rim, shaker, wood, pad, Eno / shimmer, marimba, toms, glitter: hall 6, dotted-8th echo. IRs measured from
// superdough (tools/sc-port/reverb-ir.mjs).
orbits: (1: (ir: "ir/orbit-6.5.wav", delay: [1.5 * beat, 0.5]), 2: (ir: "ir/orbit-6.wav", delay: [0.75 * beat, 0.6])),
// state buses (start values = every knob at 0): echo sends (Strudel bus(): max(min(0.9, echo × 2 × space), Tension's
// echo); echo throws), the lab columns' rooms (space 0.25 + 0.75 × knob), crossfade fades (the fader acts per note)
states: (windEcho: 0, droneEcho: 0, rimEcho: 0, shakerEcho: 0.1 * 0.5, shakerRoom: 0.9 * 0.25, woodEcho: 0,
	seaL: 1, gustL: 0, droneBeatL: 0,
	padEcho: 0, enoEcho: 0.3 * 0.5, enoRoom: 0.9 * 0.25, shimEcho: 0, shimFmEcho: 0, marEcho: 0.12 * 0.5, marRoom: 0.9 * 0.25,
	tomEcho: 0.12 * 0.5, tomRoom: 0.9 * 0.25, choirEcho: 0, glitEcho: 0, glitRunEcho: 0, voiceEcho: 0,
	lkLevel: 0, lkBright: 0, lkRes: 0, lkDet: 4, lkDetN: -4, lkRoom: 0.9 * 0.5, lkEcho: 0),
// samples (VCSL, the spoken recordings, Dirt-Samples, drum machines; see sc/samples/CREDITS.md)
samples: vcslFiles ++ (0..11).collect { |i| "vcsl/shaker_small/" ++ ["Mid_ShakerDouble_Down", "Mid_ShakerDouble_Up",
		"Mid_ShakerHighFaster_Down", "Mid_ShakerHighFaster_Up", "Mid_ShakerLowFaster_Down", "Mid_ShakerLowFaster_Up"][i div: 2]
		++ "_rr" ++ ((i % 2) + 1) ++ ".flac" }
	++ ["vcsl/cabasa/Cabasa1_Hit_rr1_Mid.flac", "vcsl/cabasa/Cabasa1_Hit_rr2_Mid.flac", "vcsl/tom2_mallet/TomL_HitM_v2_rr1_Mid.flac",
		"vcsl/agogo/Agogo_High_v2_rr1_Mid.flac", "voice/david.flac",
		// the Launchkey's pads
		"voice/brace.wav", "voice/piece_of_paper.flac", "voice/plaenterwald_wine_and_cheese.flac", "voice/the_evening_progresses.flac",
		"voice/lw.wav", "voice/the_creatures_have_begun_illumination.flac", "voice/the_evening_does_not_end.flac",
		"voice/in_the_vast.flac", "dirt/wind-00.wav", "dirt/space-00.wav", "tr909/cr-00.wav"]
	++ ~ce.fontFiles("0090_JCLive_sf2_file") ++ ~ce.fontFiles("0520_Aspirin_sf2_file") ++ ~ce.fontFiles("0530_Aspirin_sf2_file"),

stems: [
	// JOJO 1 PULSE — a soft kick on D, the heartbeat; Punch: soft sine thump → synth kick (sbd) → firm. Room, no echo.
	(name: \pulse, sounds: [\sdSynthMod, \sdSbd], level: jojo.(1).level, space: jojo.(1).space, orbit: 1, trim: 0.95, thin: false),
	// JOJO 2 SEA / WIND — brown-noise waves ↔ pink-noise gusts (row 3, on the lanes' fades: at once), riser on button 2
	(name: \wind, sounds: [\sdNoise], level: jojo.(2).level, space: jojo.(2).space, orbit: 1, trim: 0.4, thin: false,
		echoSend: \windEcho, tensionEcho: false, lanes: [(name: \sea, fade: \seaL), (name: \gust, fade: \gustL), (name: \riser)]),
	// JOJO 3 DRONE — low chords swelling in once per bar, an octave answer on the second half; Beating = a detuned saw
	// layer (its amount and detune at once)
	(name: \drone, sounds: [\sdSynthMod, \sdSynthFx], level: jojo.(3).level, space: jojo.(3).space, orbit: 1, trim: 0.46,
		thin: false, echoSend: \droneEcho, tensionEcho: false, lanes: [(name: \main), (name: \beat, fade: \droneBeatL)]),
	// JOJO 4 BASS — a sine sub + a quiet saw an octave up on the mood's scale, a new note every 2 bars; Groove: swells ↔
	// a 3-3-2 pulse (from the next note). Room, no echo.
	(name: \bass, sounds: [\sdSynthMod], level: jojo.(4).level, space: jojo.(4).space, orbit: 1, trim: 0.38, thin: false),
	// JOJO 5 RIM — a short triangle blip + a breath of white noise on the backbeat
	(name: \rim, sounds: [\sdSynthMod, \sdNoise], level: jojo.(5).level, space: jojo.(5).space, orbit: 2, trim: 3.5, thin: false,
		echoSend: \rimEcho, tensionEcho: false),
	// JOJO 6 SHAKER — VCSL small shaker (+ ghost 16ths, a cabasa on 4); Brightness also ±2 dB (trim map)
	(name: \shaker, sounds: [\sdSampleMod], level: jojo.(6).level, roomR: \shakerRoom, orbit: 2, trim: \shakerTrim, thin: false,
		echoSend: \shakerEcho, tensionEcho: false),
	// JOJO 7 WOOD / DROPS — FM sine clicks at random on the 16ths, some gliding up into their note
	(name: \wood, sounds: [\sdSynthMod], level: jojo.(7).level, space: jojo.(7).space, orbit: 2, trim: 1.7, thin: false,
		echoSend: \woodEcho, tensionEcho: false),
	// JONAS 1 PAD — slow chords of the mood's scale (saw + triangle, still ↔ re-struck and breathing)
	(name: \pad, sounds: [\sdSynthMod], level: jonas.(1).level, space: jonas.(1).space, orbit: 2, trim: 0.79, thin: false,
		echoSend: \padEcho, tensionEcho: false),
	// JONAS 2 ENO — VCSL bowed vibraphone, single notes on loops of different lengths that drift apart (the lab's space,
	// Brightness also ±2 dB); SHIMMER — high triangle swells, + an FM bell chord on row 3 (a lane each: their own echo)
	(name: \eno, sounds: [\sdSampleFx], level: jonas.(2).level, roomR: \enoRoom, orbit: 2, trim: \enoTrim, thin: false,
		echoSend: \enoEcho, tensionEcho: false),
	(name: \shimmer, sounds: [\sdSynthMod], level: jonas.(2).level, space: jonas.(2).space, orbit: 2, trim: 1.86, thin: false,
		tensionEcho: false, lanes: [(name: \tri, echoSend: \shimEcho), (name: \fm, echoSend: \shimFmEcho)]),
	// JONAS 3 MARIMBA / 4 TOMS — the lab's figures (Takada) on VCSL soft xylophone / low tom; the lab's space, echo throw
	(name: \marimba, sounds: [\sdSampleMod], level: jonas.(3).level, roomR: \marRoom, orbit: 2, trim: \marTrim, thin: false,
		echoSend: \marEcho, tensionEcho: false),
	(name: \toms, sounds: [\sdSampleMod], level: jonas.(4).level, roomR: \tomRoom, orbit: 2, trim: \tomTrim, thin: false,
		echoSend: \tomEcho, tensionEcho: false),
	// JONAS 5 CHOIR — saws through a vowel filter (a, o, u, e), one to three voices on half notes
	(name: \choir, sounds: [\sdSynthFx], level: jonas.(5).level, space: jonas.(5).space, orbit: 1, trim: 1.0, thin: false,
		echoSend: \choirEcho, tensionEcho: false),
	// JONAS 6 GLITTER — VCSL glockenspiel at random on the 16ths, scale runs on button 2 (a lane each: their own echo)
	(name: \glitter, sounds: [\sdSampleMod], level: jonas.(6).level, space: jonas.(6).space, orbit: 2, trim: 2.4, thin: false,
		tensionEcho: false, lanes: [(name: \main, echoSend: \glitEcho), (name: \run, echoSend: \glitRunEcho)]),
	// JONAS 7 VOICE — David's recording a beat at a time, where the clock is; row 3 = the radio / distortion (at once)
	(name: \voice, sounds: [\sdSampleFx, \sdNoise, \sdCrackle], level: jonas.(7).level, space: jonas.(7).space, orbit: 1, trim: 2,
		thin: false, echoSend: \voiceEcho, tensionEcho: false),
	// LAUNCHKEY MK4 25 — keys: a soft glass pad (orbit 2, mod wheel = level); drum pads: 16 ambient one-shots (orbit 1,
	// at master level, each lane a shot's own room, raised by the global Room). No Tension echo (Strudel gives these none).
	(name: \lk, sounds: [\sdSynthFx, \sdFont, \sdSampleMod, \sdNoise], level: \lkLevel, tensionEcho: false, thin: false,
		lanes: [(name: \keys, orbit: 2, roomR: \lkRoom, echoSend: \lkEcho),
			(name: \r03, orbit: 1, level: 1.0, roomR: 0.3), (name: \r07, orbit: 1, level: 1.0, roomR: 0.7),
			(name: \r08, orbit: 1, level: 1.0, roomR: 0.8), (name: \r09, orbit: 1, level: 1.0, roomR: 0.9)]),
],

// LAUNCHKEY MK4 25 (optional; live: sc/lib/controls.scd calls these). Mod wheel (CC 1) = keys level (× master, up to
// × 2, from the next key), knobs CC 21-28: 1 cutoff, 2 resonance, 3 attack, 4 note length, 5 detune, 6 reverb, 7 echo, 8 one-shot darkness. Every key
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
			lpq: ce.stateMap(\lkRes), a: a, d: 0.6, s: 0.8, r: 3, lane: \keys);
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
		var i = (note - 36) % 16, sh = shots[i], gl = (sh[\gain] ? 1) * vel, g = (sh[\gain] ? 0.8) * vel, now = thisThread.seconds;
		// the low-pass: knob 8 (18 kHz → 800 Hz) × Fog / Tension (read here: one-shots keep it), the shot's own at most
		var tv = (0.06 ** ce.val(20)) * (1 + (1.5 * ce.val(36)));
		var cut = ((18000 * ((800 / 18000) ** k.(8))) * tv).clip(80, 18000).min(sh[\cutoff] ? 18000);
		var lp = (lpOn: 1, lo: cut, hi: cut, tone: 1, lane: sh[\lane] ? \r03, tag: sh[\tag], g: gl);
		// a shot with `once` ignores new hits until it has played out
		ce.lkOnce = ce.lkOnce ? ();
		if(sh[\once].notNil and: { (ce.lkOnce[i] ? -1) > now }) { [] } {
			sh[\once] !? { ce.lkOnce[i] = now + sh[\once] };
			case
			{ sh[\font].notNil } { var f = ce.fontNote(sh[\font], sh[\midi]), v = ce.sdADSR(sh[\a], nil, nil, sh[\r]);
				[ce.note(\sdFont, f ++ lp ++ (amp: g, hold: nl * 16, midi: sh[\midi], a: v[0], d: v[1], s: v[2], r: v[3]))] }
			{ sh[\vcsl].notNil } { var pick = vcslPick.(sh[\vcsl], sh[\midi]);
				[ce.note(\sdSampleMod, (buf: ce.sampleBuffers[pick[0]], stereoIn: (ce.sampleMono[pick[0]] != true).asInteger, rate: pick[1],
					amp: g, hold: -1, midi: sh[\midi], a: 0.001, d: 0.001, s: 1, r: 0.01) ++ lp)] }
			{ sh[\noise].notNil } {
				[ce.note(\sdNoise, (color: 0, amp: g, hold: nl * 16, a: sh[\a], d: sh[\d], s: sh[\s], r: sh[\r]) ++ lp)] }
			{ [ce.note(\sdSampleMod, (buf: ce.sampleBuffers[sh[\file]], stereoIn: (ce.sampleMono[sh[\file]] != true).asInteger,
				rate: sh[\rate] ? 1, amp: g, hold: -1, a: 0.001, d: 0.001, s: 1, r: 0.01) ++ lp)] }
		}
	}
},
// web UI: the names of the 16 drum pads (pads 1-8 = notes 36-43, 9-16 = 44-51)
lkPadNames: ["Brace", "Paper", "Wine", "Evening", "Meadow", "Creatures", "No end", "Vast", "Glockenspiel", "Bowed vibe",
	"Choir aah", "Voice ooh", "Wind", "Space", "Noise swell", "Crash reverse"],

// Language side: buttons, latches, and each stem's notes (k = 16th number)
build: { |self, ce|
	var stem = { |name| self.stems.detect { |s| s.name == name } ? () };   // a stem left out (solo render): a dummy
	var bar = { |k| (k / 16).floor }, t16 = { |k| k / 16 };
	var tone = ("c" ++ ce.mapBus[\tone]).asSymbol, fog = ("c" ++ ce.fogBus).asSymbol;
	var wob = ("c" ++ ce.mapBus[\wobble]).asSymbol, mapped = { |name| ("c" ++ ce.mapBus[name]).asSymbol };
	var adsr = { |a, d, s, r, def| var v = ce.sdADSR(a, d, s, r, def); (a: v[0], d: v[1], s: v[2], r: v[3]) };
	// a pitch envelope's times (Strudel pattack … with superdough's defaults [0.2, 0.001, 1, 0.001])
	var padsr = { |a, d, s, r| var v = ce.sdADSR(a, d, s, r, [0.2, 0.001, 1, 0.001]); (pa: v[0], pd: v[1], ps: v[2], pr: v[3]) };
	var synthDef = [0.001, 0.05, 0.6, 0.01];
	var waves = (sine: 0, triangle: 1, sawtooth: 2, square: 3);
	// a synth note (sdSynthMod or another sd synth): wave name, MIDI note, Strudel gain, args; tag/g/midi for the comparison
	var syn = { |wave, m, g, args, sound = \sdSynthMod| ce.note(sound, (wave: waves[wave], freq: m.midicps, amp: g,
		tag: wave.asString, g: g, midi: m) ++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	// a sample note: plays to its end unless hold is given; tag = Strudel's s, g = gain × velocity
	var smp = { |rel, tag, g, args, sound = \sdSampleMod| ce.note(sound, (buf: ce.sampleBuffers[rel], stereoIn: (ce.sampleMono[rel] != true).asInteger,
		amp: g, hold: -1, tag: tag, g: g) ++ adsr.(nil, nil, nil, nil) ++ (args ? ())) };
	// a noise note (sdNoise: 0 pink, 1 white, 2 brown)
	var noise = { |color, g, args| ce.note(\sdNoise, (color: color, amp: g, tag: ["pink", "white", "brown"][color], g: g)
		++ adsr.(nil, nil, nil, nil, synthDef) ++ (args ? ())) };
	// the FM modulator's start phase: offline as superdough's render has it (started at time 0), live random
	var modPhase = { |k, at, freq| if(ce.webaudioPhase == true) { (2pi * freq * ((k + at) / 4 / (bpm / 60))) % 2pi } { -1 } };
	// Strudel reseed (button 1 of a stem): the stem's randomness read 1024 bars further per step
	var seed = { |latch, b| 1024 * latch.atBar(b) };
	var tensionCC = glob.char;

	// GLOBAL: Chapter (mood, next bar), Break (next bar)
	self.droneNames = moods[0].names.copy;
	self.mood = ce.latch(1, 0, { |i| 3.do { |j| self.droneNames[j] = moods[i].names[j] }; ce.status("Chapter", moods[i].name); ce.uiPush });
	ce.cycleButton(glob.btn, moods.size, { |s| self.mood.pending = s; ce.status("Chapter (next)", moods[s].name) });
	self.breakL = ce.latch(1, 0, { |i| ce.status("Break", i); ce.uiPush });
	ce.cycleButton(glob.btn2, 2, { |s| self.breakL.pending = s });
	self.beatOn = { |self, b| self.breakL.atBar(b) == 0 };
	self.moodAt = { |self, b| self.mood.atBar(b) };

	// Echo send of a layer (Strudel bus()): max(min(0.9, echo × 2 × space), Tension's echo 0 → 0.5 over the first half of
	// the knob), space = 0.25 + 0.75 × knob for the lab columns; 0.65 at least while an echo throw is held. Set the
	// moment a control moves (state bus the strip reads).
	self.echoState = { |self, name, echo, spaceCC, lab = false, throwCC, tEcho = true|
		var upd = { |send| var s = ce.val(spaceCC), sp = if(lab) { 0.25 + (0.75 * s) } { s };
			var d = (echo * 2 * sp).min(0.9).max(if(tEcho) { ramp.(ce.val(tensionCC), 0, 0.5) * 0.5 } { 0 });
			if(throwCC.notNil and: { ce.held(throwCC) }) { d = d.max(0.65) };
			ce.setState(name, d, send) };
		([spaceCC, throwCC] ++ if(tEcho) { [tensionCC] } { [] }).reject(_.isNil).do { |cc| ce.onCC(cc, { |v, send| upd.(send) }) };
	};
	// a lab column's room (space 0.25 + 0.75 × knob; the strip raises it with the global Room)
	self.labRoom = { |self, name, spaceCC| ce.onCC(spaceCC, { |v, send| ce.setState(name, 0.9 * (0.25 + (0.75 * v)), send) }) };

	// JOJO 1 PULSE — per rhythm: [16th → gain] and the note length in 16ths (heartbeat on 16ths, quarters, half notes)
	{
		var pc = jojo.(1);
		var rhythms = [[{ |s16| [1, 0.55, nil, nil][s16 % 4] }, 1], [{ |s16| if((s16 % 4) == 0) { 0.9 } }, 4],
			[{ |s16| if((s16 % 8) == 0) { 1 } }, 4]];
		self.pulseVar = ce.change(pc.btn, 3, "Pulse", ["Heartbeat", "Quarters", "Halves"]);
		stem.(\pulse).notes = { |k|
			var b = bar.(k), rh, g, drive, lp;
			rh = rhythms[self.pulseVar.atBar(b)]; g = rh[0].(k % 16);
			if(self.beatOn(b).not or: { ce.held(pc.btn2) } or: { g.isNil }) { [] } {
				drive = ce.val(pc.char); drive = if(drive < (1/3)) { 0 } { if(drive < (2/3)) { 1 } { 2 } };
				lp = (lpOn: 1, bright: ce.val(pc.bright), lo: 180, hi: 1500, tone: tone, hold: rh[1]);
				if(drive == 0) {
					// soft: a sine that fades in over 15 ms and glides 4 semitones down into D2
					[syn.(\sine, 38, g, lp ++ (penv: -4) ++ padsr.(0.08) ++ adsr.(0.015, 0.45, 0, 0.15))]
				} {
					// superdough's sbd, × 0.4 (as loud as the soft one): an 8- or 12-semitone drop
					[ce.note(\sdSbd, (freq: 38.midicps, amp: g * 0.4, decay: 0.45, penv: [8, 12][drive - 1], pdecay: 0.06,
						tag: "sbd", g: g * 0.4, midi: 38) ++ lp)]
				}
			}
		};
	}.value;

	// JOJO 2 SEA / WIND
	{
		var wc = jojo.(2);
		// the crossfade on the lanes' fades, at once (the gusts also × 0.22^brightness: their level compensation); the
		// fader acts per note
		var lanes = { |send| var c = ce.val(wc.char);
			ce.setState(\seaL, fadeMain.(c), send); ce.setState(\gustL, fadeExtra.(c) * (0.22 ** ce.val(wc.bright)), send) };
		[wc.char, wc.bright].do { |cc| ce.onCC(cc, { |v, send| lanes.(send) }) };
		self.echoState(\windEcho, 0, wc.space);
		self.windVar = ce.change(wc.btn, 3, "Sea / Wind");
		self.riserStart = nil;
		stem.(\wind).notes = { |k|
			var b = bar.(k), t = t16.(k), c = ce.val(wc.char), fm = fadeMain.(c), fe = fadeExtra.(c), out = List[];
			var tt = t + seed.(self.windVar, b), r = ce.rand(tt), lp = (lpOn: 1, bright: ce.ccMap(wc.bright), lo: 700, hi: 12000, tone: tone), rr;
			// waves: brown noise every half bar (a quarter skipped), its own attack / release, the low-pass breathing (sine / 3 bars)
			if((k % 8) == 0 and: { r >= 0.25 }) {
				out.add(noise.(2, 6, lp ++ (cutMul: 0.35 + (0.65 * ce.sine(tt / 3)), pan: 0.2 + (0.6 * r), hold: 8, lane: \sea,
					g: 6 * fm, nolog: fm <= 0) ++ adsr.(0.6 + r, nil, 0.8, 1.5 + (1.5 * r))))
			};
			// gusts: pink noise in 8ths through a wandering resonant band-pass
			if((k % 2) == 0) {
				var amp = 6 + (32 * ce.perlin(tt));
				out.add(noise.(0, amp, lp ++ (bp: 400 + (1800 * (ce.sine(tt / 7) + (0.15 * r))), bpq: 2 + (5 * r), pan: ce.sine(tt / 4),
					hold: 2, lane: \gust, g: amp * (0.22 ** ce.val(wc.bright)) * fe, nolog: fe <= 0) ++ adsr.(0.3, nil, 0.7, 0.8)))
			};
			// riser (button 2): 16th noise bursts, a band-pass climbing 300 Hz → 6 kHz over 2 bars (in steps per bar)
			if(ce.held(wc.btn2)) { self.riserStart = self.riserStart ? t.floor } { self.riserStart = nil };
			if(self.riserStart.notNil) {
				rr = ((t.floor - self.riserStart) / 2).clip(0, 1);
				if(rr > 0) { out.add(noise.(0, rr * 1.6, (bp: 300 * (20 ** rr), bpq: 4, pan: ce.sine(t * 2), hold: 1, lane: \riser)
					++ adsr.(0.03, nil, 0.8, 0.15))) }
			};
			out
		};
	}.value;

	// JOJO 3 DRONE
	{
		var dc = jojo.(3);
		var lanes = { |send| ce.setState(\droneBeatL, ce.val(dc.char), send) };
		[dc.char].do { |cc| ce.onCC(cc, { |v, send| lanes.(send) }) };
		self.echoState(\droneEcho, 0, dc.space);
		// the names of the 3 chords follow the chapter (the mood latch refreshes them)
		self.droneVar = ce.change(dc.btn, 3, "Drone", self.droneNames);
		stem.(\drone).notes = { |k|
			var b = bar.(k), c = ce.val(dc.char), out = List[];
			var lp = (lpOn: 1, bright: ce.ccMap(dc.bright), lo: 120, hi: 4000, tone: tone, vib: 0.15, vibmod: wob, hold: 16);
			var chord = moods[self.moodAt(b)].drones[self.droneVar.atBar(b)];
			if((k % 16) == 0) { chord.do { |m|
				out.add(syn.(\sine, m, 0.7, lp ++ adsr.(1.5, 1, 0.7, 3)));
				// beating: the chord detuned by up to 0.3 semitones, a saw (always plays: its level and detune are live)
				out.add(syn.(\sawtooth, m, 0.18, lp ++ adsr.(1.5, nil, 0.6, 3) ++ (cents: mapped.(\droneCents), lane: \beat,
					g: 0.18 * c, midi: m + (0.3 * c), nolog: c <= 0), \sdSynthFx));
			} };
			// the octave answer on the second half (the chord of this bar)
			if((k % 16) == 8) { chord.do { |m| out.add(syn.(\triangle, m + 12, 0.25, lp ++ adsr.(1, nil, 0.5, 2.5))) } };
			out
		};
	}.value;

	// JOJO 4 BASS
	{
		var bc = jojo.(4), degs = [0, 0, 0, 4, 3, 5, -2, 1];
		self.bassVar = ce.change(bc.btn, 3, "Bass");
		stem.(\bass).notes = { |k|
			var b = bar.(k), s16 = k % 16, c = ce.val(bc.char), fm = fadeMain.(c), fe = fadeExtra.(c), out = List[], deg, m1, m2, oct, lp;
			if(self.beatOn(b).not) { [] } {
				// a degree every 2 bars (Strudel irand(8).segment(1).slow(2), reseeded), on the mood of this bar
				deg = degs[(8 * ce.rand(((b + seed.(self.bassVar, b)) / 2).floor)).trunc.asInteger];
				oct = if(ce.held(bc.btn2)) { 12 } { 0 };
				m1 = degMidi.(deg, 1, self.moodAt(b)) + oct; m2 = degMidi.(deg, 2, self.moodAt(b)) + oct;
				lp = (lpOn: 1, bright: ce.ccMap(bc.bright), lo: 80, hi: 2000, tone: tone);
				// swell, re-struck every bar
				if(fm > 0 and: { s16 == 0 }) {
					out.add(syn.(\sine, m1, 0.6 * fm, lp ++ (hold: 16) ++ adsr.(0.8, nil, 0.9, 2)));
					out.add(syn.(\sawtooth, m2, 0.1 * fm, lp ++ (hold: 16) ++ adsr.(0.8, nil, 0.7, 2)));
				};
				// pulse: soft plucks, 3-3-2 on 8ths
				if(fe > 0 and: { [0, 6, 12].includes(s16) }) {
					out.add(syn.(\sine, m1, 0.6 * fe, lp ++ (hold: 2) ++ adsr.(nil, 0.4, 0.2, 0.3)));
					out.add(syn.(\sawtooth, m2, 0.1 * fe, lp ++ (hold: 2) ++ adsr.(nil, 0.25, 0, 0.2)));
				};
				out
			}
		};
	}.value;

	// JOJO 5 RIM — the patterns: [16th → [gain, length in 16ths]]
	{
		var rc = jojo.(5);
		var rims = [Dictionary[4 -> [0.5, 4], 12 -> [0.5, 4]], Dictionary[4 -> [0.5, 4], 12 -> [0.5, 1], 15 -> [0.3, 1]],
			Dictionary[6 -> [0.5, 2], 12 -> [0.5, 4]]];
		self.echoState(\rimEcho, 0.25, rc.space);
		self.rimVar = ce.change(rc.btn, 3, "Rim");
		stem.(\rim).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, c = ce.val(rc.char), hits = List[], x, r, out = List[], lp;
			if(self.beatOn(b).not) { [] } {
				x = rims[self.rimVar.atBar(b)][s16]; x !? { hits.add(x) };
				// extra quiet clicks: 16ths at random (reseeded)
				r = ce.rand(t + seed.(self.rimVar, b));
				if(c > 0 and: { r >= (1 - (0.4 * c)) }) { hits.add([0.08 + (0.1 * r), 1]) };
				// roll while held: 16ths growing over the bar
				if(ce.held(rc.btn2)) { hits.add([0.1 + (0.35 * (t % 1)), 1]) };
				lp = (lpOn: 1, bright: ce.val(rc.bright), lo: 1200, hi: 12000, tone: tone, pan: 0.45);
				hits.do { |h|
					out.add(syn.(\triangle, 81, h[0], lp ++ (hold: h[1]) ++ adsr.(nil, 0.045, 0, nil)));
					out.add(noise.(1, h[0] * 0.5, lp ++ (hold: h[1], hp: 2500) ++ adsr.(nil, 0.012, 0, nil)));
				};
				out
			}
		};
	}.value;

	// JOJO 6 SHAKER — the lab's figures: [n per step, velocity per step, steps per bar]
	{
		var sc = jojo.(6);
		var figs = [["0 2", "1 0.6", 8], ["0 6 2 6", "0.9 0.4 0.7 0.45", 16],
			["0 ~ 6 2 ~ 6 0 ~ 1 ~ 6 3 ~ 6 1 ~", "1 0 0.4 0.75 0 0.4 0.9 0 1 0 0.4 0.75 0 0.4 0.9 0", 16]].collect { |f|
			[toks.(f[0]).collect(num), toks.(f[1]).collect(_.asFloat), f[2]] };
		var file = { |n| "vcsl/shaker_small/" ++ ["Mid_ShakerDouble_Down", "Mid_ShakerDouble_Up", "Mid_ShakerHighFaster_Down",
			"Mid_ShakerHighFaster_Up", "Mid_ShakerLowFaster_Down", "Mid_ShakerLowFaster_Up"][n div: 2] ++ "_rr" ++ ((n % 2) + 1) ++ ".flac" };
		self.labRoom(\shakerRoom, sc.space);
		self.echoState(\shakerEcho, 0.1, sc.space, true, sc.btn2);
		self.shakerVar = ce.change(sc.btn, 3, "Shaker", ["8ths", "16ths", "Rocking 3-3-2"]);
		stem.(\shaker).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, kk = ce.val(sc.char), f = figs[self.shakerVar.atBar(b)], out = List[], step, n, vel, lp;
			if(self.beatOn(b).not) { [] } {
				lp = (lpOn: 1, bright: ce.val(sc.bright), lo: 1500, hi: 16000, tone: tone);
				// the figure (gain 4 × velocity; Strudel's random gain is overwritten by .gain(4))
				if(f[2] == 16 or: { k.even }) {
					step = if(f[2] == 16) { k } { k / 2 };
					n = f[0][step % f[0].size]; vel = f[1][step % f[1].size];
					if(n.notNil and: { vel > 0 }) { out.add(smp.(file.(n.asInteger), "shaker_small", 4 * vel, lp)) }
				};
				// ghost 16ths (from row 3 > 0.02): a share 0.15 → 1 of them
				if(kk > 0.02 and: { ce.rand(t) >= (1 - (0.15 + (0.85 * kk))) }) {
					out.add(smp.(file.([4, 5, 6, 7][k % 4]), "shaker_small", 4 * 0.45, lp ++ (pan: 0.6))) };
				// cabasa on beat 4 (row 3 > 0.5), the two recordings in turn per bar
				if(kk > 0.5 and: { s16 == 12 }) {
					out.add(smp.(["vcsl/cabasa/Cabasa1_Hit_rr1_Mid.flac", "vcsl/cabasa/Cabasa1_Hit_rr2_Mid.flac"][b % 2], "cabasa", 2.5,
						lp ++ (pan: 0.35))) };
				out
			}
		};
	}.value;

	// JOJO 7 WOOD / DROPS
	{
		var wc = jojo.(7);
		self.echoState(\woodEcho, 0.4, wc.space);
		self.woodVar = ce.change(wc.btn, 3, "Wood / Drops");
		stem.(\wood).notes = { |k|
			var b = bar.(k), t = t16.(k), tt, r, keep, m, f, args;
			if(self.beatOn(b).not) { [] } {
				// one random number per 16th (reseeded) decides everything: kept?, note, drop?, decay, gain, pan
				tt = t + seed.(self.woodVar, b); r = ce.rand(tt);
				keep = if(ce.held(wc.btn2)) { 0.85 } { 0.06 + (0.5 * ce.val(wc.char)) };
				if(r < (1 - keep)) { [] } {
					m = degMidi.((5 * r).trunc, 5, self.moodAt(b)); f = m.midicps;
					args = (hold: 1, fmi: 4 * ce.val(wc.bright), fmh: 2.76, modPhase: modPhase.(k, 0, f * 2.76), pan: r,
						lpOn: 1, bright: 0, lo: 9000, hi: 9000, tone: tone) ++ adsr.(nil, 0.05 + (0.09 * r), 0, nil);
					// drops: glide up 9 semitones into the note
					if(r < 0.4) { args = args ++ (penv: -9) ++ padsr.(0.04) };
					[syn.(\sine, m, 0.2 + (0.2 * r), args)]
				}
			}
		};
	}.value;

	// JONAS 1 PAD — chords as scale degrees (stacked thirds on degrees 1, 2, 3, 4, 6, 7), one per 2 bars
	{
		var pc = jonas.(1);
		var chords = [[0, 2, 4, 6], [1, 3, 5, 8], [2, 4, 6, 8], [3, 5, 7, 9], [5, 7, 9, 11], [6, 8, 10, 12]];
		var progs = [[0, 0, 3, 3], [0, 2, 3, 1], [0, 4, 3, 5]];
		self.echoState(\padEcho, 0, pc.space);
		self.padVar = ce.change(pc.btn, 3, "Pad", ["I–IV", "I–iii–IV–ii", "I–vi–IV–vii"]);
		self.padKept = nil;
		stem.(\pad).notes = { |k|
			var b = bar.(k), t = t16.(k), s16 = k % 16, c = ce.val(pc.char), fm = fadeMain.(c), fe = fadeExtra.(c), out = List[];
			var idx = progs[self.padVar.atBar(b)][(b / 2).floor % 4], lp, ms, pan;
			// Freeze (button 2): the chord that was playing when it was pressed, while held
			if(ce.held(pc.btn2)) { self.padKept = self.padKept ? idx; idx = self.padKept } { self.padKept = nil };
			ms = chords[idx].collect { |d| degMidi.(d, 3, self.moodAt(b)) };
			lp = (lpOn: 1, bright: ce.ccMap(pc.bright), lo: 300, hi: 8000, tone: tone, vib: 0.15, vibmod: wob);
			pan = 0.3 + (0.4 * ce.sine(t / 5));
			// still chords, struck every bar (Swell 0 … 1)
			if(fm > 0 and: { s16 == 0 }) { ms.do { |m|
				out.add(syn.(\sawtooth, m, 0.22 * fm, lp ++ (hold: 16, pan: pan) ++ adsr.(1.2, nil, 0.8, 3)));
				out.add(syn.(\triangle, m, 0.35 * fm, lp ++ (hold: 16) ++ adsr.(0.8, nil, 0.8, 3)));
			} };
			// breathing chords on half notes (Swell 0.5 … 1)
			if(fe > 0 and: { (s16 % 8) == 0 }) { ms.do { |m| [\sawtooth, \triangle].do { |w|
				out.add(syn.(w, m, 0.25 * fe, lp ++ (hold: 8, pan: pan) ++ adsr.(0.9, 1, 0.15, 1.2))) } } };
			out
		};
	}.value;

	// JONAS 2 ENO / SHIMMER — button 2 picks the layer (Eno → Shimmer → both) at the next bar; button 1 the note set
	// (and the shimmer's pace)
	{
		var ec = jonas.(2);
		var loops = [5.3, 6.7, 7.9, 9.1, 10.7, 12.3], offs = [0, 2.1, 4.4, 1.3, 6.2, 3.5];
		var sets = [[0, 4, 8, 7, 11, 12], [3, 6, 4, 8, 10, 13], [0, -3, 4, 2, 7, 1]], stretch = [1, 1, 1.5];
		var lens = [2, 1, 4];   // the shimmer: a new tone every 2 / 1 / 4 bars
		self.layerL = ce.latch(1, 0, { |i| ce.status("Eno / Shimmer", ["Eno", "Shimmer", "Eno + Shimmer"][i]); ce.uiPush });
		ce.cycleButton(ec.btn2, 3, { |s| self.layerL.pending = s });
		self.labRoom(\enoRoom, ec.space);
		self.echoState(\enoEcho, 0.3, ec.space, true);
		self.echoState(\shimEcho, 0, ec.space);
		self.echoState(\shimFmEcho, 0.6, ec.space);
		self.enoVar = ce.change(ec.btn, 3, "Bowed", ["Calm", "Lydian", "Low"]);
		stem.(\eno).notes = { |k|
			var b = bar.(k), t0 = t16.(k), t1 = t0 + (1/16), v = self.enoVar.atBar(b), sl = stretch[v], n, out = List[];
			if(self.layerL.atBar(b) == 1) { [] } {
				// loop i: a note at offs[i] + j × loops[i] (× stretch), a third of the loop long; row 3 = how many loops
				n = 2 + (4 * ce.val(ec.char)).round;
				6.do { |i| if(i < n) {
					var len = loops[i] * sl, j = ((t0 - (offs[i] * sl)) / len - 1e-7).ceil, tb = (offs[i] * sl) + (j * len);
					if(tb < (t1 - 1e-7)) {
						var m = degMidi.(sets[v][i], 3, self.moodAt(tb.floor)), pick = vcslPick.(\vibraphone_bowed, m);
						out.add(smp.(pick[0], "vibraphone_bowed", 6, (rate: pick[1], midi: m, at: (tb - t0) * 16, hold: len / 3 * 16,
							pan: 0.2 + (0.6 * ((i * 0.37) % 1)), lpOn: 1, bright: ce.ccMap(ec.bright), lo: 800, hi: 12000, tone: tone,
							vib: 0.15, vibmod: wob) ++ adsr.(0.6, nil, nil, 3), \sdSampleFx))
					}
				} };
				out
			}
		};
		stem.(\shimmer).notes = { |k|
			var b = bar.(k), t = t16.(k), v = self.enoVar.atBar(b), len = lens[v], a = ce.val(ec.char), out = List[], d, lp, tt;
			// a new scale degree every len bars (reseeded), triangle; row 3: + the 3rd and 5th above as FM bells
			tt = b + seed.(self.enoVar, b);
			if(self.layerL.atBar(b) == 0 or: { (k % 16) != 0 } or: { (tt % len) != 0 }) { [] } {
				d = (7 * ce.rand((tt / len).floor)).trunc;
				lp = (lpOn: 1, bright: ce.ccMap(ec.bright), lo: 1500, hi: 14000, tone: tone, vib: 0.15, vibmod: wob, hold: len * 16);
				out.add(syn.(\triangle, degMidi.(d, 5, self.moodAt(b)), 0.18, lp ++ (pan: 0.2 + (0.6 * ce.sine(t / 9)), lane: \tri)
					++ adsr.(2.5, nil, 0.7, 4)));
				if(a > 0) { [2, 4].do { |x| var m = degMidi.(d + x, 5, self.moodAt(b));
					out.add(syn.(\sine, m, 0.14 * a, lp ++ (fmi: 2 * a, fmh: 2, modPhase: modPhase.(k, 0, m.midicps * 2),
						pan: ce.sine(t / 7), lane: \fm) ++ adsr.(1.5, nil, 0.6, 4))) } };
				out
			}
		};
	}.value;

	// JONAS 3 MARIMBA / 4 TOMS — the lab's layers (lab/harmony/midori-5): a layer = a figure of scale degrees (nil = rest),
	// one per step (16 / 12 / 8 steps per bar), cycling over its own length regardless of the bar, first note accented
	{
		var mc = jonas.(3), tc = jonas.(4);
		var md = { |a, n| ((a % n) + n) % n };
		var layer = { |fig, oct = 1, pan = 0.5, g = 0.5, steps = 16|
			var t = if(fig.isString) { toks.(fig).collect(num) } { fig }, f = t.detectIndex(_.notNil);
			(fig: t, vel: t.collect { |x, j| if(j == f) { 1 } { 0.6 } }, oct: oct, pan: pan, g: g, steps: steps, late: 0) };
		var padTo = { |fig, n| var t = toks.(fig); (t ++ ("~" ! (n - t.size).max(0))).join(" ") };
		var shift = { |fig, sh| toks.(fig).collect { |x| if(x == "~") { x } { (x.asFloat + sh).asInteger.asString } }.join(" ") };
		var euclid = { |hits, n, notes, rot = 0| var j = 0;
			n.collect { |k| if(((md.(k + rot, n) * hits) % n) < hits) { var x = notes[j % notes.size]; j = j + 1; x.asString } { "~" } }.join(" ") };
		// the lab's figures
		var c5 = ["4 ~ 7 ~ 9", 1, 0.3], c7 = ["0 ~ ~ 2 ~ 4 ~", 0, 0.7], anchor = ["0 ~ ~ ~ ~ ~ ~ ~ 4 ~ ~ ~ ~ ~ ~ ~", 0, 0.5];
		var zyklen = [c5, c7, anchor, ["7 ~ 4 ~ 2 ~ 4 ~ 6 ~ 4 ~", 1, 0.5], ["9 ~ 7 ~ 4 ~ ~ 6 ~ 4 ~", 1, 0.55],
			["2 ~ 4 ~ ~ 7 ~ ~ 11 ~ 9 ~ ~", 1, 0.45]].collect { |s| layer.(*s) };
		var canon = [[0, 1, 0.3], [3, 1, 0.7], [5, 0, 0.5], [11, 2, 0.6]].collect { |x|
			layer.("7 ~ 6 4 ~ 2 4 ~ 9 ~ 7 ~", x[1], x[2], if(x[1] == 2) { 0.35 } { 0.5 }) ++ (late: x[0] / 16) };
		var sim = [[0, 1, 0.3], [2, 1, 0.7], [-3, 1, 0.5], [4, 0, 0.45]];
		var cells = [7, 8, 9, 10].collect { |n, v| layer.(padTo.(shift.("0 ~ 4 7 ~ 9", sim[v][0]), n), sim[v][1], sim[v][2]) };
		var eu = { |list| list.collect { |x| layer.(euclid.(x[0], x[1], x[2], x[5] ? 0), x[3], x[4]) } };
		var euclids = [
			eu.([[3, 8, [4, 7, 2], 1, 0.3], [2, 5, [9, 6], 1, 0.7], [3, 11, [0, 4, 2], 0, 0.5], [2, 13, [11, 9], 1, 0.5]]),
			eu.([[3, 8, [4, 7, 2], 1, 0.3], [5, 13, [0, 2, 4, 2, 7], 1, 0.7], [4, 11, [9, 7, 6, 4], 1, 0.5], [3, 16, [0, -3, 2], 0, 0.5]]),
			eu.([[5, 8, [4, 7, 9, 7, 2], 1, 0.3], [7, 13, [0, 2, 4, 7, 4, 2, 6], 1, 0.7], [7, 16, [9, 7, 4, 6, 11, 9, 7], 1, 0.5, 3],
				[4, 9, [0, 4, -3, 2], 0, 0.5]])];
		var build = [["0 ~ 4 7 ~ 4 2 ~", 1, 0.35], ["0 ~ 4 7 ~ 4 2 ~ ~", 1, 0.65], ["7 ~ ~ 9 ~ ~ 4", 1, 0.5],
			["0 ~ ~ ~ ~ ~ -3 ~ ~ ~", 0, 0.5], ["11 ~ ~ 9 ~ ~ ~ ~ ~ 7 ~", 2, 0.55, 0.35],
			["4 7 9 7 4 2 4 7 9 11", 1, 0.3, 0.35], ["7 9 11 9 7 4 7 9 11", 2, 0.7, 0.3]];
		var buildLayers = build.collect { |s| layer.(*s) };
		// Toms, Density: the figure's rests fill up, one by one in a fixed (hashed) order, each a neighbour of the note
		// before it (velocity 0.55); from level 2 every 4th filled stroke an octave up. Level 0 = the figure as written.
		var rank = { |n| if(n == 0) { [] } { (0..n - 1) }.sort { |a, b| ce.hash3(a, n, 7) <= ce.hash3(b, n, 7) } };
		var denseFig = { |fig, level| var t = toks.(fig), rests = t.selectIndices { |x| x == "~" };
			var fill = rank.(rests.size).keep((rests.size * level / 4).round.asInteger).collect { |r| rests[r] };
			var last = t.detect { |x| x != "~" }.asFloat, n = 0, first = t.detectIndex { |x| x != "~" }, d = List[], vel = List[];
			t.do { |x, j|
				if(x != "~") { last = x.asFloat; d.add(last); vel.add(if(j == first) { 1 } { 0.6 }) } {
					if(fill.includes(j).not) { d.add(nil); vel.add(0) } {
						n = n + 1; d.add(last + if(n.odd) { 1 } { -1 } + if(level >= 2 and: { (n % 4) == 0 }) { 7 } { 0 }); vel.add(0.55) } } };
			(fig: d.asArray, vel: vel.asArray, oct: 1, pan: 0.4, g: 0.5, steps: 16, late: 0) };
		var denseLv = { |fig| (0..4).collect { |l| denseFig.(fig, l) } };
		var tomCycles = denseLv.(c5[0]), tomEuclid = denseLv.(euclid.(3, 8, [4, 7, 2])), tomBuild = denseLv.(build[0][0]);
		var kfig = "0 4 ~ 7 4 ~ 2 ~";
		var tomCanon = [layer.(kfig, 1, 0.45), layer.(kfig, 1, 0.75, 0.4) ++ (late: 3/16), layer.(kfig, 1, 0.2, 0.35) ++ (late: 5/16)];
		var clapFig = { |notes| var j = 0; toks.("x x x ~ x x ~ x ~ x x ~").collect { |x| if(x == "~") { x } { var y = notes[j % notes.size]; j = j + 1; y.asString } }.join(" ") };
		var moving = { |every, n, stepLen| { |b| md.((b / every).floor, n) * stepLen } };   // offset (bars) in bar b
		var clapV1 = layer.(clapFig.([0, 4, 7, 4, 2, 4, 7, 9]), 1, 0.3, 0.5, 12);
		var clapRates = [8, 4, 2].collect { |e| var m = moving.(e, 12, 1/12);
			layer.(clapFig.([7, 9, 11, 9, 7, 4, 7, 6]), 1, 0.7, 0.5, 12) ++ (late: { |b| m.(b).neg }) };
		var crossing = layer.("4 2", 1, 0.35, 0.45, 8);
		// the notes of a layer in [t0, t1): its steps j at j / steps + late (late: bars, or a function of the bar)
		var hits = { |ly, t0, b, extra| var lt = ly[\late].value(b), ns = ly[\steps], t1 = t0 + (1/16), out = List[], j, tb;
			j = (((t0 - lt) * ns) - 1e-7).ceil;
			while { tb = (j / ns) + lt; tb < (t1 - 1e-7) } {
				var i = md.(j, ly[\fig].size), d = ly[\fig][i];
				if(d.notNil and: { ly[\vel][i] > 0 }) { out.add((deg: d, vel: ly[\vel][i], at: (tb - t0) * 16, u: tb - lt) ++ (extra ? ())) };
				j = j + 1 };
			out };
		// row 3 brings layers in one by one: layer v (of n) plays from v < 1 + round((n − 1) × knob)
		var upTo = { |list, kn| list.select { |x, v| v < (1 + ((list.size - 1) * kn).round) } };
		var marOpts = ["Cycles", "Canon", "Cells", "Euclid", "Build-up"];
		var tomOpts = ["Cycles", "Canon", "Euclid", "Build-up", "Crossing", "Clapping Music"];
		self.labRoom(\marRoom, mc.space); self.echoState(\marEcho, 0.12, mc.space, true, mc.btn2);
		self.labRoom(\tomRoom, tc.space); self.echoState(\tomEcho, 0.12, tc.space, true, tc.btn2);
		self.marVar = ce.change(mc.btn, 5, "Marimba", marOpts);
		self.tomVar = ce.change(tc.btn, 6, "Toms", tomOpts);
		self.drift = 0;
		stem.(\marimba).notes = { |k|
			var b = bar.(k), t0 = t16.(k), kn = ce.val(mc.char), ls, swell = 1, cm = 1, out = List[];
			ls = switch(self.marVar.atBar(b),
				0, { upTo.(zyklen, kn) }, 1, { upTo.(canon, kn) }, 2, { upTo.(cells, kn) },
				3, { upTo.(euclids[(3 * kn).floor.min(2)], kn) },
				// build-up: layer v enters at bar 4v of a 64-bar round; row 3 swells them (gain, brightness)
				4, { swell = 0.7 + (0.7 * kn); cm = 0.6 + (1.4 * kn); upTo.(buildLayers, kn).select { |x, v| md.(b, 64) >= (v * 4) } });
			ls.do { |ly| hits.(ly, t0, b).do { |h|
				var m = degMidi.(h[\deg], 3 + ly[\oct], self.moodAt(h[\u].floor)), pick = vcslPick.(\xylophone_soft_ff, m), g = ly[\g] * swell * h[\vel];
				out.add(smp.(pick[0], "xylophone_soft_ff", g, (rate: pick[1], midi: m, at: h[\at], pan: ly[\pan],
					lpOn: 1, bright: ce.val(mc.bright), lo: 600, hi: 6000, tone: tone, cutMul: cm)))
			} };
			out
		};
		stem.(\toms).notes = { |k|
			var b = bar.(k), t0 = t16.(k), kn = ce.val(tc.char), lvl = (4 * kn).round.min(4), ls, out = List[];
			var opt = self.tomVar.atBar(b);
			// Crossing: one copy drifts away, faster the higher row 3 (its offset integrated per 16th while it plays, as live)
			if(opt == 4 and: { kn > 0.02 }) { self.drift = self.drift + ((1/16) * 0.1 * (kn ** 2)) };
			ls = switch(opt,
				0, { [tomCycles[lvl]] },
				1, { tomCanon.select { |x, v| (v == 0) or: { kn > (v / 3) } } },
				2, { [tomEuclid[lvl]] },
				// build-up: one figure filling up by itself, a level more every 4 bars of a 32-bar round, capped by row 3
				3, { [tomBuild[(md.(b, 32) / 4).floor.min(1 + (3 * kn).round)]] },
				4, { [crossing] ++ if(kn > 0.02) { [crossing ++ (pan: 0.75, late: self.drift.neg)] } { [] } },
				// Clapping Music: the second voice moves one pulse every 8 → 4 → 2 bars
				5, { [clapV1] ++ if(kn > 0.02) { [clapRates[(3 * kn).floor.min(2)]] } { [] } });
			ls.do { |ly| hits.(ly, t0, b).do { |h|
				var m = degMidi.(h[\deg], 3 + ly[\oct], self.moodAt(h[\u].floor)) - 26, vel = 0.6 + (0.4 * (h[\vel] - 0.6));
				// VCSL low tom (unpitched: played as recorded at C2 = 36), accents softened
				out.add(smp.("vcsl/tom2_mallet/TomL_HitM_v2_rr1_Mid.flac", "tom2_mallet", ly[\g] * vel, (rate: 2 ** ((m - 36) / 12), midi: m,
					at: h[\at], pan: ly[\pan], lpOn: 1, bright: ce.val(tc.bright), lo: 600, hi: 6000, tone: tone)))
			} };
			out
		};
	}.value;

	// JONAS 5 CHOIR — one voice (+ a 0.12-semitone copy), + a third, + a fifth above; a new note every half bar
	{
		var cc = jonas.(5), octs = [4, 3, 5], vowels = [0, 3, 4, 1];   // vowel a o u e (sdSynthFx: a e i o u)
		self.echoState(\choirEcho, 0, cc.space);
		self.choirVar = ce.change(cc.btn, 3, "Choir", ["Middle", "Low", "High"]);
		stem.(\choir).notes = { |k|
			var b = bar.(k), t = t16.(k), v = self.choirVar.atBar(b), cv, d, out = List[], lp, voice;
			if((k % 8) != 0) { [] } {
				cv = if(ce.held(cc.btn2)) { 1 } { ce.val(cc.char) };
				// the degree: 2 × irand(5) (reseeded) + the voice's offset, in the register of the pattern
				d = 2 * (5 * ce.rand(t + seed.(self.choirVar, b))).trunc;
				lp = (lpOn: 1, bright: ce.ccMap(cc.bright), lo: 500, hi: 10000, tone: tone, vib: 0.15, vibmod: wob, hold: 8,
					vowel: vowels[(b / 2).floor % 4]) ++ adsr.(0.7, nil, 0.8, 1.8);
				voice = { |off, g, dm = 0| var m = degMidi.(d + off, octs[v], self.moodAt(b)) + dm; syn.(\sawtooth, m, g, lp, \sdSynthFx) };
				out.add(voice.(0, 0.2)); out.add(voice.(0, 0.2, 0.12));
				if(cv > 0) { out.add(voice.(2, ramp.(cv, 0, 0.5) * 0.21)) };
				if(cv > 0.5) { out.add(voice.(4, ramp.(cv, 0.5, 1) * 0.17)) };
				out
			}
		};
	}.value;

	// JONAS 6 GLITTER
	{
		var gc = jonas.(6), octs = [5, 6, 4], tones = [0, 1, 2, 4, 5, 7, 8, 9, 11];
		var run = [0, 1, 2, 4, 5, 7, 8, 9, 11, 9, 8, 7, 5, 4, 2, 1];
		self.echoState(\glitEcho, 0.55, gc.space);
		self.echoState(\glitRunEcho, 0.4, gc.space);
		self.glitVar = ce.change(gc.btn, 3, "Glitter", ["High", "Very high", "Middle"]);
		self.glitStart = nil;
		stem.(\glitter).notes = { |k|
			var b = bar.(k), t = t16.(k), v = self.glitVar.atBar(b), oct = octs[v], out = List[], r, keep, rr;
			var lp = (lpOn: 1, bright: ce.val(gc.bright), lo: 3000, hi: 16000, tone: tone, hold: 1) ++ adsr.(nil, nil, nil, 1.2);
			var glock = { |m, g, args| var pick = vcslPick.(\glockenspiel, m);
				smp.(pick[0], "glockenspiel", g, lp ++ (rate: pick[1], midi: m) ++ args) };
			// a glockenspiel note on a random 16th (one random number decides: kept?, tone, gain, pan; reseeded)
			r = ce.rand(t + seed.(self.glitVar, b)); keep = 0.06 + (0.64 * ce.val(gc.char));
			if(r >= (1 - keep)) { out.add(glock.(degMidi.(tones[(9 * r).trunc], oct, self.moodAt(b)), 0.15 + (0.25 * r), (pan: r))) };
			// Run (button 2): the sweep in 32nds, filling in 15 % → 90 % over 2 bars (in steps per bar), louder; the random
			// velocity is read at the bar start (Strudel appLeft on the bar-long ramp)
			if(ce.held(gc.btn2)) { self.glitStart = self.glitStart ? t.floor } { self.glitStart = nil };
			if(self.glitStart.notNil) {
				rr = ((t.floor - self.glitStart) / 2).clip(0, 1);
				2.do { |j| var u = t + (j / 32), ru = ce.rand(u);
					if(ru >= (0.85 - (0.75 * rr))) {
						out.add(glock.(degMidi.(run[((k * 2) + j) % 16], oct, self.moodAt(b)), (0.2 + (0.3 * rr)) * (0.7 + (0.3 * ce.rand(t.floor))),
							(at: j / 2, hold: 0.5, pan: 0.3 + (0.4 * ce.sine(u * 2)), lane: \run))) } }
			};
			out
		};
	}.value;

	// JONAS 7 VOICE — David's recording runs with the clock: each beat plays the beat-long slice where the clock is;
	// button 2 = each 16th replays the start of its beat. Row 3 (radio → broken) on map buses: at once.
	{
		var vc = jonas.(7);
		self.echoState(\voiceEcho, 0.15, vc.space, false, nil, false);
		stem.(\voice).notes = { |k|
			var b = bar.(k), t = t16.(k), a = ce.val(vc.char), r = (2 * a).min(1), c = ((2 * a) - 1).max(0), stut = ce.held(vc.btn2);
			var pos = (((k / 4).floor * beat) % davidSec) / davidSec, out = List[];
			var lp = (lpOn: 1, bright: ce.ccMap(vc.bright), lo: 1500, hi: 16000, tone: fog);
			if(stut or: { (k % 4) == 0 }) {
				out.add(smp.("voice/david.flac", "david", 1 - (0.45 * c), lp ++ (amp: 1, begin: pos, hold: if(stut) { 1 } { 4 },
					pre: mapped.(\vPre), hp: mapped.(\vHp), bp: 1600, bpq: mapped.(\vBq), shape: mapped.(\vShape),
					distort: mapped.(\vDist), crush: mapped.(\vCrush), coarse: mapped.(\vCoarse)), \sdSampleFx))
			};
			// the radio's hiss and crackle under it, a note per beat
			if((k % 4) == 0) {
				out.add(noise.(0, 0.015 + (0.045 * r), lp ++ (amp: mapped.(\vHiss), hp: 1200, hold: 4) ++ adsr.(0.01, nil, nil, 0.05)));
				out.add(ce.note(\sdCrackle, (amp: mapped.(\vCrackle), density: 0.03, hold: 4, tag: "crackle", g: 0.1 + (0.2 * r))
					++ lp ++ adsr.(0.01, nil, nil, 0.05)));
			};
			out
		};
	}.value;
},
)
)
