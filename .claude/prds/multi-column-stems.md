---
name: multi-column-stems
description: Stems that span two LC columns (a shape column that has no sound plus the instrument column it shapes) and stems that read another stem's state; first user 016's Stab Shape + Stab + Answer
status: backlog
created: 2026-11-22T12:00:00Z
---

# PRD: multi-column-stems

Source: the translation of the hand-written SC tracks into stem tracks ([scd-translation-differences](../../docs/reference/scd-translation-differences.md)).
016-grroove-opus could not be translated as it is, because two things of its design do not fit the stem format.

## Executive Summary

A stem is one LC column: three knobs, a fader, two buttons, one sound. 016 has more:

1. **Stab Shape (Mode 2, column 3) + Stab (column 4)** are one instrument on two columns. Column 3 makes no sound.
   Its three knobs (Snap, Length, Resonance), its fader (**Drive**, not a level) and its buttons (**Vanish**: the stab
   out at the next bar, **Ratchet**: twice in its 16th) shape the stab that plays on column 4; column 4 has the stab's
   own Brightness, Space, Vanish (random bars), Level, pattern and echo throw.
2. **Answer (column 5) reads the stab.** It also plays in the bars the stab left out (Vanish, or "out by hand"), so
   a stem has to see a state another stem makes.

The stem format and the loader only know "one stem, one slot, labels Brightness / Space / Level / Pattern", so today
016 can only be translated by dropping the shape controls. Other planned work shares the need (a hi-hat column with a
"shape" companion, a drum stem with a second page of controls).

## Requirements

1. **A stem may span two columns** of one mode: `span: 2` in the stem file, slot of the first column in the `.track`,
   the next slot (same mode) is taken by the same stem and must be empty in the file. One sound, one strip, one set of
   notes; two sets of six controls (`controls` for the first column, `controls2` for the second).
2. **Free control names on the first column.** The shape column's six controls may be named freely (no Brightness /
   Space / Level / Pattern rule): Snap, Length, Resonance, Drive, Vanish, Ratchet. The second column keeps the normal
   rules; its fader is the stem's Level, the first column's fader is a control like any other.
3. **A stem can publish and read states.** A stem names states it makes (`publishes: ["here"]`: on this bar, does the
   stab play) and another stem names the ones it reads (`reads: ["stab.here"]`), by role or slot, so the answer follows
   whatever stab sits on the track, and plays plain when nothing publishes.
4. **Tags, LC view, swap and designers know pairs.** `@ctl` lines for both columns, the Live page shows both, a swap
   replaces the pair as a unit (the second slot is not offered alone), `check-stems` checks the pair rules.
5. **No change for existing stems and tracks.** Format 1 and 2 files, the 009 pilot and every translated track play
   and compare as before.
6. **Pilot: 016.** Stab Shape + Stab and the answer translate as a pair with its published state, proven event by
   event against the hand-written `.scd` (the proof tools of the translation work).

## Out of scope

- More than two columns per stem, stems across the two modes, stems that move between slots live.
- A Stem Designer UI that builds pairs from nothing (the designer shows and plays them; making one is by file).
- Changing any control's meaning or position on the LC XL 3.

## Open questions (answer in task 001)

- Is the first column's `controls` the right place for the free-named set, or a `shape` block next to `controls`?
- Slot naming in the `.track` for the second slot (absent, or `"2:4": "@2:3"`)?
- Published state: by name per stem, or a small registry on the track (`track.shared`)?
