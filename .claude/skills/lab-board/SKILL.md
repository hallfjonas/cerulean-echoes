---
name: lab-board
description: Create or run a new round of a lab board (lab/<instrument or role>/<name>-N.strudel) - candidate columns on the stem-lab engine, layout sheet, feedback.md, old/ rotation. Use when the user wants candidates for an instrument or track role ("build a board for X", "next round", "new lab for 008 chords").
---

# Lab board: candidate columns, played on the LC XL 3

A board is NOT a track with columns swapped. It is a comparison of candidates (or one sound tuned on its own),
each column built like a track column, played live; the user picks by ear and the next round narrows down. The winners
go into the tracks (see `lab-to-track`). Folder names say what the board is (`lab/harmonie/`, `lab/drums/`), file names
`<name>-N.strudel` without a redundant "-lab".

## Before building (order matters)
1. Read the folder's `feedback.md` and, for house, the "✗ Verworfen" list in `tracks/009-house/stems-ideen.md`.
   Nothing rejected comes back. After new feedback, update the reject list FIRST.
2. Find out which track/column the board serves and read that track's `feedback.md`.
3. **Research before sound ideas**: how producers make this sound (Attack Magazine, MusicRadar, Sound on Sound,
   shared Strudel/Tidal code, real sample packs). Bring back CONCRETE material (note patterns, recipes, sample
   sources) and name the source in the file head; if it is my own guess, say so. No invented effect columns, no
   self-made riffs on a grid when something exists. GM soundfonts sound cheap: prefer recorded samples.
4. Only the simplest variant with existing sounds first. New sample sources or hosting = say what it costs and offer
   the cheap variant. Do not rewrite or extend what was not asked; ask first.

## Structure of a board file
- Head comment: what the board is for, one line per column with its source, what is a guess, "Not heard".
- `// @engine <x>` picks the engine part appended by `tools/stem-lab/sync.mjs`:
  no marker + `BOARD`/`COLS` = engine 1; `makeCols` = engine 2; `// @engine 3` = + chord progressions, fire buttons;
  `// @engine techno` = 008 (F dorian, 140 BPM, techno context). A track whose key/tempo differs (house, ambient):
  an adapted engine copy WITHOUT `@engine`, and say so in the head (then do not run sync.mjs on it).
- Above the engine: `@layout/@note/@guide/@mode/@col/@row/@ctl` comments (English, source of the layout sheet),
  `const BOARD = { id, title }`, `const bpm`, `const makeCols = h => { ... }` returning the 8 columns.
- Mode 16 = candidate columns (all 8 may hold candidates); Mode 2 = the track's context (a few faders: drums, bass,
  pad, progression button) so the candidate is judged in place.
- Each column like a track column: k1 brightness, k2 space, k3 character, fader level, b1 change between max. 3
  patterns at the next bar, b2 moment (echo throw). All knobs at 0 must already sound good.
- Rhythm, not just held notes. Loops stay constant (no written 4/8-bar variations, no randomness in keys/stabs);
  randomness only for melodies. Row-3 knobs that add variation over time are liked; never glide/pitch bend; rolls =
  one slow swell. Same effect on the same control in every column (echo on Space), no per-pattern special effects.
- Single quotes for plain text in Strudel (double quotes are mini-notation); labels without theory terms.
- Labels (control names, `@ctl`, option names, the live view, the status box): English and short, as in CLAUDE.md "Labels".

## Rounds
- Current round in the folder, older rounds in `old/` (move the .strudel and its layout pdf), the result of each round
  in the folder's `feedback.md`, rejected whole series in `lab/archive/`.
- Per round: keep only columns graded good (≈2 or better), replace the rest with NEW proposals instead of tweaking
  weak ones; offer clearly more options/complexity per round. An explicit "remove X" applies to every board that has X
  (grep them all). Re-read the user's earlier requests of the session before handing over.

## Checks before handing over (Node cannot hear: say so)
1. `cd tools && node stem-lab/sync.mjs <board>` (appends the engine, runs the transpiler check) or, for an adapted
   engine, `node strudel-sim/transpile-check.mjs <board>`. The Node harness has no transpiler; browser errors from
   double-quoted labels come from here.
2. `node stem-lab/check.mjs <board> '{"5":1}' [pattern idx]`: what each column plays over 8 bars.
3. Cost per scheduler tick in the Node harness (`strudel-sim/harness.mjs`), aim ≲ 8 ms; gate silent columns/layers.
4. New samples: fetch/decode in headless Chrome, read levels (VCSL is not normalized), do not renormalize on my own.
5. Layout sheet: the hook writes `<board>-layout.pdf` after each edit; look at the PNG, no text overflow.
6. Live view: when in doubt give the board the big "▣ LC groß" window like the tracks (copy from harmonie-5).
7. Log the build in `feedback.md` (date, columns, sources, "not heard", open questions).

## Don'ts
- No shared-code change (engine, layer function, voicing) that alters other sounds without asking.
- No re-introducing rejected sounds, no proactive rewrites, no hidden deviations from the user's wording.
- Do not hand-edit the generated layout pdfs.
