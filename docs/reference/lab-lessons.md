# Lab lessons (Strudel boards, retired 2026-11-21)

The Strudel lab boards (`lab/<instrument>/`, `lab/archive/`) were removed from the working tree; only `lab/tutorials/`
stays. Git history keeps every board and its `feedback.md`: restore with
`git checkout a69f511 -- lab/<folder>` (a69f511 = last commit that still has them; the boards' sources and research
links are in those `feedback.md` files). New sound work goes to the sound-lab epic (Stem Designer / Sample Designer).
The grades below are the user's, 2026-11-05 to 2026-11-12.

## Working rules that came out of the boards
- One thing changes per round: either the sound or the lines, never both (bass 1).
- Columns differ in one thing only; the buttons mean the same in every column (bass 2/3, strings 2, brass 2).
- Find real material (records, analyses, recordings) before inventing; made-up effects on GM sounds lead nowhere (keys 14).
- Simplest path first: no custom multisample setups for a small gain (keys 17).
- Fewer options per knob rather than many options per pattern; one knob raises the complexity (midori 5, melody).
- Constancy matters in house and techno: a pattern repeats unchanged, bar 4/8 variations only if clearly good.
- Brightness and the overtone effect must be tuned per sound; dull sounds barely react (keys 18).
- No high-pass on pads (techno pads); chord progression labels are the chords, not artist names.
- Comb filtering: several sections playing the same note a few ms apart sounds thin and phasey (strings 4).
- Single-note multisamples for brass sound mechanical; real phrases or sections are needed (melody 1).

## Keys (009, rounds 1-26)
- Liked: grand, Rhodes, organ stab, vibraphone; B3 and M1 organs; Steinway (crisper than the Salamander grand);
  Rhodes Mark I (jRhodes3d); layered sounds. Final keys = Steinway + Rhodes Mark I plus the overtone slider
  (overtones follow the accent, liked). Out: Kawai (octave bug), upright, TX81Z, felt piano, tube, body, vowel filter.
- Rhythms: chain, shifted chain, pairs, 3-3-2, "before gaps" accent, second rhythm soft; the accent only as timbre,
  not loudness. Out: random micro-timing ("small random deviations do not make a stab sound played"), ghost notes,
  question-answer, every-third, off-beat + push, held patterns, overlays that were too intense.
- Per button 3 patterns live (4-5 if changed while keys are off). Riffs with their own chords (Kerri video, Checkmate,
  Turn Off The Lights, Atmosphere, Chicago spread, Retro disco) went into 009; riff column = one fixed riff, button
  under the fader tries bass/harmony options (follow / pedal / no pad).
- Technical: VCSL files with a comma in the path fail on raw.githubusercontent and some on jsDelivr; the sounds are in
  `samples/vcsl-keys` (see CLAUDE.md "Sounds that load"). Several VCSL banks sound an octave above their file names.
  Normalised sample sets (jRhodes3d, VCSL Steinway) have loudness only from velocity tracking.

## Harmony (009 chords, 007 ambient, 008 techno)
- 009: JX-10 strings and B3 stay (strings + B3 fade on row 3); string machine, real section, M1 organ out.
  Progressions step through on button 1 ("Change"); several classic progressions needed, not only the basic ones.
- 007 ambient (Midori Takada "Crossing" idea): Eno bowed and choir good; Budd piano, strings too solemn, carpet mushy.
  Marimba and toms both wanted (toms: one layer, density knob must be audible, drift only on the same figure);
  keep cycles, canon, cells, Euclid, build-up, bell pulse, railway crossing, Clapping Music; out: phase, polytempo,
  accents, additive, fast drift. One "Complexity" knob everywhere. Went into 007 (Jonas 2-4).
- 008 techno chords/pads: not convinced by the chord pulse; dub chords boring; no high-pass; the beat of the board
  context was far too weak to judge pads. Unresolved: ideas listed in techno-chords-1 and techno-pads-1.

## Bass (009 Jojo 4, 008 width)
- Sounds: Daft Punk FM quite nice, Juno good as the very different alternative. Lines liked: Voyager plucking,
  disco syncope (around the 1, short), Alright, beat 4 open (short), dead-note funk. Out: Instant Crush, Something About Us.
- Low-end width (008): sub with Haas 10 ms loses 9-14 dB mono, detune 12-25 ct is harmless but gives little width;
  keep the low end mono below ~120-300 Hz.

## Brass, strings, guitar (009 Jonas 5-7)
- Brass: full section (SSO + VSCO), warm, house not jazz. Liked: push, 3-3-2 + answer, shout, swell; boring: offbeat,
  riff, held push, cascade; falls everywhere far too much. Button 1 = ensemble / solo, button 2 held = lift. Complexity
  must add more than hits (complexity-1 tried 8 alternatives, never heard).
- Strings: liked echo stab, run up and long run (land on the one with a hard attack), stab + swell, 16th figure;
  out: offbeat, falling figures, pizzicato, countermelody, tremolo, scoop. "Cheap and crackly" = see comb filtering.
  techno-strings-1 (iconic background strings, Fm -> Db) was never heard.
- Guitar: chord chanks from loops were rejected ("rather plucked with melody" in house). Plucked Strat notes
  (nyanshell.strat, MIT): Stardust 2, e & a 4 2, repeated note 2; octaves, thirds, chord 4. Sound never good enough;
  guitar-sounds-1 and disco-guitar-3 never heard. Credits needed for the Freesound CC BY sample.

## Melody, stabs, samples, drums, acid
- Melody: vibraphone good (needs complexity knob); trumpets and sax good as phrases but too sparse; brass melodies too
  jazzy (house = classic / happy); flutes good, "Playful" knob great, higher column went into 009.
- Stabs / FX: FX nearly inaudible; stabs from shouts, crowd, flutes, zither, trombone, cuica: nonsense; at most more
  iconic vocal samples. Samples: horn stabs, alto sax, Rhodes/organ loops, vinyl out; flute trill (427560) and
  janie_joelle "yeah yeah yeah" (529175) liked.
- Drums (007): shaker picked, went into 007 Jojo 6.
- Acid (009 Jonas 6): too strong and scratchy; swing acid and squelch stabs were good; acid-2 (tamer) never heard.

## Archived stem labs for 009 (rounds 1-2, 2026-11-06/07)
- Own 16th grids, GM sounds, self-written riffs: "really bad, too tame". Horns, lead, mallets, organ, pad, vocal,
  playful: all rejected (organ is covered by keys; vocals on hold; "playful" carried over from 008/010 was too techno).
  Classic house needs sampled phrases. The engines (`tools/stem-lab`) were removed with the boards.
