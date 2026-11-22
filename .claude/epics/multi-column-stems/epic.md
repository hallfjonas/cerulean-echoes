---
name: multi-column-stems
status: backlog
created: 2026-11-22T12:00:00Z
updated: 2026-11-22T12:00:00Z
progress: 0%
prd: .claude/prds/multi-column-stems.md
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: multi-column-stems

## Overview
Make the stem format and the SC loader carry a stem that spans two LC columns and a stem that reads another stem's
state, so the last hand-written tracks that use such designs (016, then 017 that is 016 plus modal percussion) can be
translated into stem tracks without dropping controls. Specification and proof stay in the existing stem docs and the
translation log.

## Architecture Decisions (proposed, to confirm in 001)
- **`span: 2` on the stem, not two files.** One stem file is one instrument: one sound, one strip, one `notes`. The
  extra column is only more controls on the same stem, read by its column code (`col.knob2(\k1)`, `col.held2(\b2)`).
- **Slots.** The `.track` names the stem on the first slot only; the loader reserves the next slot of the same mode
  (error when the file also fills it). `~ce.stemSlots` keeps its 14 entries; a spanned slot has the stem but no strip.
- **Controls.** `controls` (first column, free names) and `controls2` (second column, normal rules). In 016 the shape
  column is the first (2:3) and the stab the second (2:4), so the notes belong to the second column: the strip level
  and the gate read `controls2.fader`, and the file name comes from sample + the labels of `controls2`, so the existing
  naming checks and the library index stay.
- **Shared state** is a small registry on the track: a stem `publishes` named values per bar (`track.shared`), a
  stem `reads` them with a default; no stem needs another stem to exist.
- **Everything else unchanged:** format 1 and 2 stems, the add-on library, the swap rules for single stems.

## Technical Approach

### SC (`sc/lib/`)
- `stems.scd`: `stemColumn` for a spanned stem: both CC sets, `col.knob2`, `col.held2`, `col.press2`; the strip level and
  gate from the second column's fader; hooks for both columns' knobs and buttons.
- `stemtrack.scd`: slot reservation, `@ctl` tags for both columns (`stemTrackTags`), swap of a pair as a unit
  (`swapSlot`, `swapProblem`), `track.shared` registry.
- `stemkit.scd`: helper for column code to read the shape.

### Tools
- `sc/stems/stem.schema.json` and `track.schema.json`: `span`, `controls2`, `publishes`, `reads`; label rules for the
  first column of a spanned stem.
- `tools/stems/check-stems.mjs`, `stem-tags.mjs`, `stem-index.mjs`: the pair rules, the tags, the index (a pair is
  listed once, with its two slots).
- Player: Live page column drawer and swap list show a pair as one stem over two columns.

### Docs
`docs/features/stems.md` (format, "Stems over two columns"), the translation log.

## Implementation Strategy
Spec first (001), then loader and engine (002), then shared state (003), then tools and player (004), then 016's
pair as the pilot with the event-by-event proof (005). One branch and PR per task: `epic/multi-column-stems-<nnn>`
off `origin/main`. 005 needs 002 to 004 merged and the 016 translation (`claude/scd-to-track-016-017`) in.

Risks:
- The strip and the gate read one level CC per stem; a spanned stem must not leave the first column's fader acting
  as a level anywhere (mixer, UI, perform scripts).
- Control hooks per column are made in `stemtrack.scd`'s build for 14 slots; a pair adds two sets on one stem.
- Stem swap: a pair needs both slots free of other stems; the Live page must not offer half a pair.
- `check-perform` and the auto-perform scripts address controls by CC and by the `@ctl` lines: both must see the
  pair's six + six controls.

## Task Breakdown Preview

| # | Task | Parallel |
|---|---|---|
| 001 | Spec: the format for a pair and for shared state (decisions above), a written example for 016 | no |
| 002 | Loader and engine for `span: 2` | after 001 |
| 003 | Shared state: `publishes` / `reads` | after 001, parallel to 002 |
| 004 | Schema, `check-stems`, tags, index, player swap list and drawer | after 002 |
| 005 | 016 Stab Shape + Stab + Answer as a pair; event-by-event proof; docs and log | after 002, 003, 004 |

## Dependencies
- The translation work: PRs #96 (001, 002), #97 (008) and the 016/017 branch; `~ce.grooveKit`, `stem-compare.mjs`.
- `sc/lib/stems.scd` / `stemtrack.scd` as of `main`; nobody else changes the slot model meanwhile (check
  `gh pr list` before 002).

## Success Criteria (Technical)
- 016's Stab Shape and Stab play as one stem; Snap, Length, Resonance, Drive, Vanish and Ratchet act on it exactly as
  in the hand-written track (event for event, audio null per stem).
- The answer plays in the bars the stab leaves, with that stab or any other stem that publishes the same state, and
  plays plain without one.
- All existing `.stem` / `.track` files, tests and comparisons are unchanged (`npm test`, `check-stems`).
- A swap on the Live page moves a pair as a unit.

## Estimated Effort
About five short branches; 002 and 004 are the larger ones.
