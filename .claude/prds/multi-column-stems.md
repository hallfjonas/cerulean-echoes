---
name: multi-column-stems
description: Stems that span several LC columns of one mode (a synthesizer layout, a shape column plus its instrument) and that tracks can take like any other stem; stems that read another stem's state
status: design
created: 2026-11-22T12:00:00Z
updated: 2026-11-22T14:00:00Z
---

# PRD: multi-column-stems

Feature design. Nothing in this document is decided: the needs are written down, every way to meet them is an open
question with options. No epic and no tasks until the questions are answered.

Sources: the translation of the hand-written SC tracks into stem tracks
([scd-translation-differences](../../docs/reference/scd-translation-differences.md)) and the Sample Designer's synthesizer
([sample-designer](../../docs/features/sample-designer.md)).

## Problem

A stem today is one LC column: three knobs, a fader, two buttons, one sound ([stems](../../docs/features/stems.md)).
Two designs in the repo are bigger, and a third need sits beside them.

1. **A full synthesizer layout.** The Sample Designer's synthesizer is one sound on up to 7 columns, one block per
   column (Osc 1, Osc 2, Filter, Envelope, LFO, Chorus, Drive). Per column: knob rows 1-3 = the block's parameters,
   fader = block level, button 1 = block on / off, button 2 = block type. The designer exports the sound with every block
   value as a named parameter (`osc1Tune`, `filterCutoff` …, see `sc/sounds/bassPluck.scd`), but the layout stays in the
   designer. A track gets the sound on one column with Brightness and Space only.
2. **016's Stab Shape (Mode 2, column 3) + Stab (column 4).** Column 3 makes no sound: its knobs (Snap, Length,
   Resonance), its fader (**Drive**, not a level) and its buttons (**Vanish**, **Ratchet**) shape the stab that plays on
   column 4. The same idea with two columns.
3. **016's Answer (column 5) reads the stab.** It also plays in the bars the stab left out, so a stem has to see a state
   another stem makes.

Today's format and loader know "one stem, one slot, labels Brightness / Space / Level / Pattern".

## Needs

What the feature has to achieve, without saying how.

1. A stem can carry the controls of several columns of one mode and play one sound with them.
2. A control on such a column can be named for what it does (Pitch, Cutoff, Depth, Snap, Drive …).
3. A track can take a multi-column stem like any other stem: in its file, in a swap, in the designers.
4. The stem's loudness and its patterns stay controllable on the LC.
5. A stem can read a state another stem makes, and plays plain when no stem makes it.
6. Existing stems, tracks, the 009 pilot and the translated tracks play and compare as before.
7. Proof: a synthesizer stem plays like the Sample Designer's audition; 016's Stab Shape + Stab + Answer play like the
   hand-written `.scd`, event by event.

## Out of scope (proposed, to confirm)

- A stem across the two modes; stems that move between slots live.
- A Stem Designer UI that builds a multi-column stem from nothing.
- Changing any control's meaning or position on the LC XL 3; column 8 stays the frame's.

## What is fixed today (constraints)

- A mode has 7 stem columns; column 8 is the frame's (Fog, Thin, Tension, Master, Chapter, Break).
- The strip level and the gate (a column at fader 0 makes no hits) read one fader per stem.
- Control labels have rules (row 1 Brightness, fader Level, button 1 Pattern, row 3 and button 2 named for their job, no
  reuse of another job's name) that `check-stems` enforces.
- A stem file name is built from the sample and the five labels of its column; a track pins exact stem versions by path.
- The Sample Designer's synthesizer fills all 7 columns of a mode when it has 7 blocks (`bass-pluck` does), so a
  synthesizer stem has no spare column.

## Open questions

Each with options. No pick, no ranking.

### 1. How a stem file lists its columns
- **A.** One `columns` array, one control set per column; single stems keep `controls`.
- **B.** `controls` plus `controls2` for a pair only, and a `columns` array for more than two.
- **C.** A `span: n` field and the extra control sets in named blocks.
- Also: how many columns at most (7 = a whole mode), and is a single stem the one-entry case or a separate form?

### 2. Level
Every fader of a synthesizer stem is a block level; the stem still needs a level for the mix and for the gate.
- **A. Main column.** The stem names one column whose fader is its Level (and which carries more, see Pattern). For the
  synth that would be the Envelope column (its fader is already "level of the whole voice"); for 016 the Stab column.
  Costs: the Envelope column gives up its own level.
- **B. A `level` pointer to any control.** Flexible; the checks, the Live page and `@ctl` have to follow the pointer.
- **C. No Level fader.** Loudness from `gain` and Master only. Loses the per-stem fader and the gate at 0.
- **D.** Something else (a Level added as a knob target, the first or last column's fader by rule …).
- Also: what does fader 0 gate when the stem has no Level fader?

### 3. Pattern
Button 1 steps the patterns in a normal stem, but in a synthesizer layout it is "block on / off" on every column.
- **A.** Button 1 of the main column (question 2A); that column's own on / off goes.
- **B.** A `pattern` pointer to any button.
- **C.** Button 1 of the first column; the blocks' on / off move to another place (button 2 pairs with the type?).
- **D.** No Pattern button: the stem plays one pattern, or the track's frame chooses.
- Also: does button 1 keep stepping "at the next bar" on a stem that has this role in a column beside others?

### 4. Space (room send)
A synthesizer column has no spare knob for it.
- **A.** A knob target on one of the columns (which one?).
- **B.** A fixed send from a stem default, no knob.
- **C.** The track's frame decides.
- **D.** The main column's row 2 (question 2A), displacing that column's own parameter.

### 5. Free names
- Which controls may be named freely: every control of every column, or only the columns that are not the main one?
- Do the label rules still apply to the main column?
- Are names of different columns of one stem allowed to repeat ("Level" on four block faders)?

### 6. File name
Today the name is sample + the five labels of the one column.
- **A.** The labels of the main column (question 2A).
- **B.** Sample + a column count (`<sample>-<n>-columns`).
- **C.** Sample + a free short role word.
- Must stay unique and checkable; `check-stems` builds and compares it.

### 7. Slots in a track
- How the first column is named: the stem on the first slot only, or on every slot of the run.
- How the following slots are marked: absent, or `"2:4": "@2:3"`.
- What is refused: a filled slot inside the run; a run that leaves the mode; a run that starts mid-mode.
- Where is the main column in the run: the first slot, or anywhere?

### 8. Assigning in the tools and the player
- **Swap on the Live page:** the run swaps as a unit; may a single stem replace one column of a run (breaking it)?
- **Stem drawer:** how a multi-column stem is listed and filtered (column count, role of the main column).
- **Stem Designer:** + Add, Replace, trash, Promote, Export track on a run. Does a trash free the whole run?
- **Live page and LC view:** one stem over several columns, or every column as before?
- **Auto-perform and `check-perform`:** addressing controls by column and control as today, or by stem and control?

### 9. Sample Designer bridge
- Does **Export** also write the multi-column stem, or is that another action (Make stem)?
- Where do the labels, knob targets and patterns of the stem come from (`blocks.json`, the audition patterns)?
- The designer's column 8 (Accent, Space, Length, Master, Pattern, Save) has no home in a track: which of it becomes
  stem controls, which is dropped?
- Does a drum-machine project (6 columns) get the same treatment?

### 10. Block type and on / off buttons
The lab changes a block's type at once, also on a sounding note.
- Acceptable on the LC as it is, or does the type step at the next bar like Pattern?
- On / off of a block as a toggle on button 1 (when Pattern does not take it) or as a state of the type button.

### 11. Shared state (Answer reads the stab)
- **A.** Named per stem: a stem `publishes` named values and another `reads` them.
- **B.** A registry on the track (`track.shared`), values per bar.
- **C.** Column code in the frame; no format change.
- Also: addressed by name, by role or by slot; the order in which stems make values within a 16th; the default when
  nothing publishes.

### 12. Loader and engine
- How a stem's CC sets are built per column (hooks per column in the track build), how `~ce.stemSlots` marks the
  run's other slots, and whether the run shares one mixer strip.
- Whether the gate and the Break read the main column's fader only.
- What `swapProblem` says when a run cannot take over live.

### 13. Proof and pilots
- Which stem goes first: the synthesizer stem from `bass-pluck`, the 016 pair, or both; in which track (a demo beside
  090, the 016 translation).
- How the synthesizer stem is compared with the audition (render null test, event by event) and which tolerance.
- How 016's translation (merged in PR #101) is changed: the stab, its shape column and the answer replace today's
  column code, or stay as they are until the format exists.

### 14. Size of the work
- One branch or several, and in which order (format and loader, shared state, tools and player, pilots) once the
  questions above are answered. To be planned afterwards.
