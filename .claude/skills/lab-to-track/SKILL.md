---
name: lab-to-track
description: Move a finished lab column (lab/<instrument>/<board>.strudel) into a track column 1:1 - same controls, sounds, rhythms, touch, levels. Use when the user says a lab result should go into a track ("put our keys into 009", "take column N of the board into the track").
---

# Lab column → track column, 1:1

The lab column is the spec. The player must find exactly the controls the lab had, in the same places, doing the
same thing. Do not "adapt" it to the track's row convention (row 3 = character, button 2 = moment) unless the user
asks: a lab column with Length on row 3 and Shift on button 2 keeps them.

## Steps
1. **Pin the source**: the board file and column the user means (ask if unclear). Read its whole column path: the
   column function, its sources, levels, ranges, rhythm list, touch, shift handling, start values (`S.val[...] ??=`).
2. **List every control** of that column, plain and shifted (knobs 1-3, fader, button 1, button 2, shift + knobs,
   shift + fader) with what it does and its start value. This list is the contract; show it to the user if any
   control cannot be carried over.
3. **Port the code, not a rewrite**: the lab boards build events in a custom `grid` / `new Pattern(...)` from a state
   object; keep that. In the track, read the column's controls with `valAt(pattern, t)` from `colJonas(n)` /
   `colJojo(n)` (works for the dual and the single file), and keep stateful parts (shift toggle, routing knob moves to
   shifted controls) in one state object updated by a signal pushed to `taps` (queried every tick via `stateTaps`).
   Use the track's `change()` for button 1 (bar latch + status box) and `strip()` for level and master gating.
4. **Labels 1:1 too**: the board's dashboard is part of the column. Register the column in the track's `COLVIEW`
   (`'page:column'` → `(row, { esc, pending }) => html`) with the board's cell code: its labels (English, short: Brightness, Space,
   Length, Level …; see CLAUDE.md "Labels"), the values from the column's state (not raw CCs, when shift routes them), the pattern name under button 1 (no x/./- string),
   the shift view. Copy the board's `@ctl` texts for the layout sheet; only shorten a
   button text that would overflow.
5. **Keep what the lab decided**: voicing, rhythms, touch, swing, brightness ranges, per-sound gains, effects
   (the lab's own space mapping), start values for controls that have not been moved. Track-wide things stay on top:
   global Fog / Tension (multiply the cutoff by `globalTone`), global Room, Tension echo, break gating if the stem is
   rhythm.
6. **Only what the track needs extra**: harmony from the track (`harmId`, `CHORDS`) instead of the lab's one chord,
   voicing extended to the track's chords (say how). Nothing else changes; name every deviation to the user.
7. **Level**: render the stem offline with the lab's start settings (`tools/strudel-sim/render.mjs`, with
   `globalThis.samples = sd.samples` so the board's samples load) and set one stem level constant; compare with a few
   other stems (kick, clap). Check the dual master for peaks.
8. **Outputs**: `node --check` on a copy, `make-single.mjs`, `gen-layout.mjs` (dual + single), `make-syx.mjs`; look
   at the layout PNG (no overflow, button text ≤ 3 lines). Log it in the track's `feedback.md`.

## Don'ts
- No new controls, no renamed controls, no merged knobs, no changed ranges "to fit the track".
- No new samples or hosting in the transfer; use exactly the lab's sources.
