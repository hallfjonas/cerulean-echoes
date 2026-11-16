- far too many harmonic lines; piano + Rhodes unnecessary; rather one slider for the changed sound;
- piano line and Rhodes and some of the other lines really weak; rhythmically above all; can't you pick out good house samples? that is much more iconic, not just so simple on the beat
- we need more playful top voices; randomization can matter for those too, so it does not get boring


## Done in 009 dry (2026-11-05)
- Piano, piano riff, organ, Rhodes → one column **Keys** (Jonas 1), row 3 = sound: M1 piano → grand → Rhodes → organ
- Keys rhythms syncopated: 3-3-2, push into the next bar, gospel with ghost chords, call
- House samples (Dirt-Samples): trumpet stabs (horns), tenor sax, sung "ah" (vocal), rave shouts (vocal, knob 2)
- Top voices horns / sax / vocal / pluck / marimba from one improviser: the riff repeats (Play = 0), Play up = random variants; knob 1 = next riff
- Orch hit out, pad to column 7; bass ghosts (Jojo 4, row 3) now random


- no change across the 8 bars! consistency is super important in house / techno! and some of the variations are bad, so I can hardly say what I like, because often a variation is then weird... can you adjust that first?
- good:

## 009 house (2026-11-06) — new base after the keys lab
- New file 009-house-dual.strudel; cool, happy and dry versions moved to old/. Rhythm section (Jojo) as in 009 dry.
- Jonas 1 Keys = the keys lab result (lab/keys round 19): Steinway ↔ Rhodes Mark I (row 3), Kerri voicing (Am9 G B C E,
  D9 F♯ A C E), 8 stab rhythms with push, accent before rests with brighter accents (overtones at half), brightness
  per sound over its own range (knob 0 = warm, not muffled), button 2 echo. −21 LUFS at fader 1 (kick −14, clap −23.5).
- Jonas 2-7 empty for now (horns, sax, vocal, pluck, marimba, pad removed with their samples).
- Note: kick + keys both at fader 1 peak at 1.16 (offline): leave headroom on the faders.
- Transfer fixed (user: a lab column goes 1:1 onto a track column): Jonas 1 now has exactly lab 19 column 2's controls
  (Brightness, Space, Length, Level, button 1 = 8 rhythms, button 2 = shift: knobs = sound mix piano → Rhodes, B3 →
  M1, vibes → marimba, fader = overtones), its swing (56 %), space mapping and start values. Track additions: chords
  from Chapter (D9 voicing F♯ A C E), global Fog / Room / Tension. −21 LUFS at the lab's settings. New skill:
  .claude/skills/lab-to-track.

## Vibraphone → Jonas 3 (2026-11-07)
- From lab/melody/melody-2 column 1, 1:1 (Bright, Soft, Complex, Level, button 1 phrase, button 2 echo throw); 40 % louder
  than in the lab (user: 30–50 %). Chords from the chapter (Am9 / D9) instead of the lab progressions; own orbit 3.
- Jonas 2 stays free for the harmony (harmony-4). Open: switch the track to the 16 chord progressions.
- Set 011 not rebuilt: make-set fails since the keys port on `await samples(…)` in 009 (not caused by this change).

## 2026-11-08 — harmony column + chord progressions (from lab/harmony/harmony-4, column 2)
- Jonas 1 = harmony (JX-10 strings ↔ B3 16'+8' on row 3, held chords, echo throw), button 1 = next of
  10 chord progressions (next 8-bar phrase). Keys moved to Jonas 2 (unchanged).
- Chapter (Jonas 8): vamp = all Am9; change = the progression of Jonas 1 (start: Am9 D9 = as before).
- Keys stay monotonous on Am9 (user: the keys are not there for chord progressions); only in "Am9 D9" do they go to D9.
  Sub, bass, harmony and vibraphone follow the progression; vibraphone scale Dorian/aeolian per progression.
- Only progressions that do not clash under Am9 (no F♯ except Am9 D9). Not listened to; harmony −27.8 LUFS at fader 1.
- Set 011 rebuilt (make-set: track functions now async, because 009 loads samples with await). check-set: 009 shows
  deviations only in the very first moment (first harmony hit at 0 or keys at 0.07: the order in which the
  control states are set on the first query), otherwise identical.

## 2026-11-08 (night) — call echo without clash
- Vibraphone (Jonas 3) "call echo": F♯ → F when the progression is aeolian (`vibModeFix`, `modeAt`); vamp and "Am9 D9"
  unchanged. Set 011 rebuilt; check-set unchanged from before (start deviations, for "ride" in bars 0–1).

## Chord progressions (user, 2026-11-08)
- Progressive house progressions (audiblegenius article: vi IV V I etc.) no: rather classic house.

## Reference Sarah Wild (Fusion 2025, user 2026-11-08) — what 009 still needs
- Lots of house piano: not only monotonous, partly 8-bar chord progressions, but always with a good, groovy rhythm.
- House basslines with lots of groove: still needed there (Jojo side).
- Higher melodies, towards flute: playful, but less complex than the vibraphone solo. The vibraphone stays.
- Acid: great, but not a must.

## 2026-11-08 (night) — flute → Jonas 4
- From lab/melody/melody-4 column 6 ("flute higher"), 1:1 (Bright, Space, Playful, Level, button 1 motif, button 2 echo throw),
  real flute notes from the juskiddink phrases (begin/end/speed), motifs on the chord tones from G4, orbit 3 (with vibraphone).
- Only difference: chords from the track (chapter + progression, push 2/16). Level: user "too quiet" → gain 0.6 → 2.0;
  offline in the track at fader 1 −23.9 LUFS = vibraphone (−23.8). Not listened to.
- make-single, make-syx (009 + set), layouts (generated in the cloud, typst is missing on the device), set 011 rebuilt;
  check-set: 009 as before only start deviations (first harmony hit), otherwise identical.

## 2026-11-08 evening — new bass (Jojo 4) from lab/bass/house-bass-4
- User: sounds FM and M1 good, Warm (hard) best; Round bad → row 3 = sound FM → M1 → Warm (equal power).
  Ratings of the lines: 1 → 2, 2 → 4, 3 → 3, 4 → 2, 5 → 3, 6 → 2, 7 → 2, 8 → 2, 9 → 2 (like 8), 10 → 2+, 11 → 2+ (like 10),
  12 → 4, 13 → 2, 14 → 2+, 15 → 3−, 16 → 3. More than 3 options on button 1 are ok if different and good.
- In the track: button 1 = 6 lines (lab 14, 10, 1, 4, 7, 13), button 2 octave, row 1 Bright (own range per sound), row 2
  Space; the old ghost improviser (groove) is out. Length fixed at the lab start value. Level: like the old Jojo 4 (−24.2
  LUFS at fader 1, knobs 0). Single, syx, layouts, set rebuilt; check-set as before. Not listened to.

## 2026-11-08 — variant "riffs" (009-house-riffs-dual.strudel, new file; 009-house-dual and set unchanged)
- Keys (Jonas 2) button 1: the 8 monotonous rhythms as before, then 6 riffs from keys lab 23 with their own chords and
  their own rhythm (Kerri video, Checkmate, Turn Off, Atmosphere, Chicago, retro disco), 1:1 from the lab. A riff starts
  at its first bar when it is selected. Kerri riff (monotonous) still in.
- Not coupled (user: test it like this first): for a riff put Chapter on vamp → bass and harmony on A as a pedal point.
  Over A only Checkmate's Gm is rough (minor ninth A–B♭). Next step, if needed: harmony falls back to Am9 automatically under a riff.
- Node: transpile ok (dual + single), riffs from bar 1 and return to monotonous checked, ~1.2 ms/tick for the keys. Not listened to.

## 2026-11-08 night — brass → Jonas 5 (from lab/brass/disco-brass-3)
- User: "On the A" and "swell + fall" out, the remaining six figures into the track as they are.
- Jonas 5 = full section (SSO trumpets, horns, trombones), row 3 complexity, button 2 held = intensify as in the lab.
  Only differences (a column has only two buttons): button 1 = the six figures (in the lab: one column each; button 1 was
  solo ↔ ensemble) → in the track only ensemble; chords from the track (chapter + progression, push 2/16); orbit 3 with vibraphone and
  flute (room size 2 instead of 2.5).
- Level: lab gain 0.9 = −14.6 LUFS at fader 1 (rendered offline in the cloud) → BRASS_LEVEL 0.42 = −21 LUFS (= keys);
  flute −23.9 for comparison. Not listened to.
- Complexity is currently being reworked in its own lab (user: only adds hits, too little intensification).
- single, syx, layouts (cloud), set 011 rebuilt. check-set: 009 as before only deviations in the very first moment
  (the order in which the control states are set on the first query; now also one brass hit each), otherwise identical.

## 2026-11-08 late — strings → Jonas 6, guitar → Jonas 7 (current state, NOT listened to)
- User: "put the current state into the track". Jonas 6 = lab/strings/disco-strings-4 (all five figures on
  button 1, row 3 build-up, button 2 held intensify), Jonas 7 = lab/guitar/disco-guitar-3 (all eight lines on
  button 1, row 3 complexity in 4 steps, button 2 held intensify with phaser, sound "open", high string).
- Differences as with the brass: button 1 = figures instead of ensemble/solo or open/muted (only ensemble / open);
  chords from the track; orbit 3, room size 2; guitar with the dotted 1/8 echo of orbit 3 instead of 1/8.
- Level offline (cloud): strings lab gain 0.9 = −17.3 LUFS → 0.59 (−21 LUFS = keys, brass); guitar 1 = −15.3 LUFS →
  0.38 (−23.8 LUFS = vibraphone, flute); brass −21.3.
- Open: guitar sound (lab/guitar/guitar-sounds-1), brass complexity (lab/brass/complexity-1), check the strings sound
  (cheap/clicky fixed?).
- single, syx, layouts (cloud), set 011 rebuilt; check-set: 009 only deviations in the very first moment, otherwise identical.
- Note: 009-house-riffs-dual.strudel (+ single, syx, layouts, 22:24) comes from another session; not touched.

## 2026-11-12 — keys riffs from lab round 26 (NOT heard)
- User: the Kerri video progressions sounded odd (its Dm9/Gm9 chords were my invention, the video riff is Am9 only → not taken over; the Kerri rhythm stays as "Kerri riff" on Am9); the Checkmate progressions sounded good; wants the non-monotone riffs in the track.
- Keys button 1: 8 rhythms (Am9) + 4 riffs with their own chords: Checkmate, Atmosphere, Chicago Spread, Retro disco (16 bars). While a riff is selected and the keys fader is up, bass, sub, harmony, vibraphone, flute follow the riff's chords (chord of the bar's first 16th); Jonas 1's progression is overridden meanwhile.
- Not taken over: Turn Off The Lights (changes chord mid-bar; the bar-wise bass cannot follow), the lab's pedal-point/no-pad options.
- Added chords Gm and Em/G (keys riffs only). Checked with the Node harness (notes per bar) and transpile check only.

## 2026-11-12 — brass with chance (NOT heard)
- User: the brass play the same every bar. Now every short figure (1–2 bars) rests for a repetition with 30 % (every 4th repetition always plays) and every hit but the downbeat is left out with 25 % (`BRASS_REST`, `BRASS_DROP`; hash of the repetition number, so it differs every time but is stable per query). The 4-bar "rare" figures and swells keep their own sparseness. Checked in the Node harness: in 24 bars 7 are silent, the others differ in hit count.

## 2026-11-12 — Break keeps the percussion (NOT heard)
- User: "Beat off" should not hide all percussion, only the low parts. Now only kick, noise pump, sub and bass pause in the break; clap, hats, congas and tambourine keep playing (their `beatOnly` removed). Checked by transpile only.

## 2026-11-12 — overlay rhythms out of the keys
- User: the overlaid riffs (chain + offset, chain + pairs) out. Button 1 now has 6 rhythms + 4 riffs. Transpile check only.

## 2026-11-12 — Retro disco riff out of the keys
- User: the last riff (Retro disco) out. Button 1 now has 6 rhythms + 3 riffs (Checkmate, Atmosphere, Chicago). Transpile check only.

## 2026-11-12 — Kerri video and Turn Off riffs in the keys (NOT heard)
- User: the Kerri video riff was not odd in the lab, I had set it up wrong; both riffs in. The track now knows the chord per 16th under a riff (chordAtK): bass, sub, pad, vibraphone, flute, brass, strings, guitar change chords inside the bar with the riff (Kerri: Am9 6 / Dm9 8 / Gm9 2 16ths; Turn Off). New chords Dm9, Gm9, Bm. Retro disco stays out. Node harness: keys, pad change at the right 16ths.

## 2026-11-12 — labels unified (English, shorter) (NOT heard)
- User: simplify and unify all labels, shorten when in doubt; language agreed: everything English (sheets, LC view, status box, option names). All @ctl texts rewritten short (button 1 = "Pattern", "Chords" on harmony, "Chapter" global; knob 2 "Space"; fader "Level"); German labels in the LC view/status box/option names translated; the former German chapter name for "change" -> Progression; the rhythm string under the keys button in the LC view removed. Backup before: scratchpad 009-before-labels.strudel. Checked: transpile, harness (events play), layout sheet.
