# Handover: harmony column + chord progressions in track 009 (as of 2026-11-08, ongoing)

For another agent, in case this session breaks off. Language with the user: German; code comments English.

## Task (confirmed by the user)
- `lab/harmony/harmony-4.strudel`, column 2 "Held, B3 soft" 1:1 onto **Jonas column 1** of
  `tracks/009-house/009-house-dual.strudel` (skill `lab-to-track`).
- The previous **keys** (Jonas 1) move to **Jonas column 2** (code unchanged, only column/CCs/tags/COLVIEW).
- **Chord progressions**: button 1 of the harmony column steps through 10 progressions (change at the next 8-bar phrase).
  The Chapter knob (Jonas 8, button 1) stays: **vamp** = all on Am9; **change** = the progression chosen on Jonas 1.
- **The keys stay monotonous** (user: the keys are not there for chord progressions): Am9, only in progression 1 "Am9 D9"
  (= the previous change) do they go to D9 as before. Harmony column, sub, bass (+ ghosts) and vibraphone
  (Jonas 3) follow the progression.
- Only progressions that do not clash under the keys' Am9 (G B C E) (no F♯ except progression 1):
  1 Am9 D9 (keys follow) · 2 Am7 C Em7 · 3 Am F G · 4 F G Am · 5 Em7 Fmaj7 · 6 Fmaj7 G · 7 F Am C Dm ·
  8 Am7 Dm7 · 9 C F Am Em · 10 F Em Am. Chord orders from Hooktheory (research-harmony.md), bar lengths
  from the lab (engine3 HARMONIES). Progression 1 Dorian, 2–10 aeolian (the vibraphone scale follows).

## Plan / status
1. ☑ Track read, backup: scratchpad `009-before.strudel` (not in the repo).
2. ☑ Rework in `009-house-dual.strudel`:
   - CHORDS = list of all chord objects (Am9, D9 + Am7 Cmaj7 Em7 Fmaj7 Fadd9 Gadd9 G11 Dm7; basses E1–D2 around A1),
     PROGS (10 progressions of 8 bars), `progLatch = barLatch(8)`, `chordIdAt(bar)`; `harmId` = progression (for sub, bass,
     ghosts, vibraphone, harmony), `keysHarm` = Am9 or progression 1 (for the keys).
   - Harmony column (Jonas 1): JX-10 ↔ B3 16'+8' on row 3 (equal power, gate at 0), held chords
     (lab `padPat`, push 2 sixteenths), lab channel strip (Bright 400–6000 Hz ±2 dB, Space: 1/8 echo then reverb, echo throw
     on button 2), orbit 3 (like the vibraphone), COLVIEW 'jonas:1', status line 0 = "Chords".
   - Keys: `colJonas(1)` → `colJonas(2)`, `@ctl 16:1.*` → `16:2.*`, COLVIEW 'jonas:2', `stemN2_keys`, `keysHarm`.
   - Vibraphone: root degree for all chords, scale Dorian/aeolian per progression.
   - Status box / LC view: "Chords" shows the progression, cycle 8 bars.
3. ☑ Check (transpiler dual + single ok; harness: vamp/progressions 1,3,5,7 bar by bar ok, keys stay Am9; after optimisation
   ~5 ms per tick (before 2 ms without harmony); harmony offline −27.8 LUFS at fader 1 = as in the lab, 6–7 dB below the
   keys): `node strudel-sim/transpile-check.mjs`, Node harness (chords per bar in vamp / each progression, keys
   stay Am9), compute time per tick (`tcpu` script: harness `run` over 8 bars), level of the harmony column offline
   (`BPM=124 node strudel-sim/render.mjs <file> stemN1_harm '{"5":1,"12":1}'`) against the keys.
4. ☑ `node lcxl-layout/make-single.mjs`, `gen-layout.mjs` (dual + single), `make-syx.mjs`; check the layout PNG.
5. ☑ Rebuild set 011 (make-set.mjs: track wrapper async because of `await samples` in 009; check-set: only start
   deviations, see feedback.md): `npm run set` in `tools/` (builds + `check-set.mjs`).
6. ☑ feedback.md + stem-ideas.md updated; reported to the user. **Done** — open: listen in the browser.

## Known points
- The vibraphone's Escravos call (phrase 3) contains F♯: clashes in the aeolian progressions (as in the lab).
- Other sessions also worked on 009 today (vibraphone on Jonas 3): re-read the file before writing.
