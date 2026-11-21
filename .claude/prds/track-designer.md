---
name: track-designer
description: Track Designer - open and edit a stem track in a player-like view (stems, genre, Launchkey keys and drum pads as a rig file); first of two work packages, followed by set-designer
status: backlog
created: 2026-11-21T14:00:00Z
updated: 2026-11-21T15:00:00Z
---

# PRD: track-designer

## Executive Summary

The sound lab (epic `sound-lab`) made the stem a file, the track a JSON assignment of stems to the 14 LC slots, and
gave the player a Sample Designer and a Stem Designer. The next step towards a performance is the **Track Designer**:
open an existing stem track, change which stems sit on its columns, change its genre, change the Launchkey keys sound
and drum pads, and save it or save it as a copy.

The Track Designer looks like the player (same shell: MIDI panel with the LC view, visuals, transport) but its side
panel holds designer functions instead of the player's.

First of two sequential work packages (split from `track-set-designer`). The second, `set-designer`, starts when this
one is done and merged.

SuperCollider only (Strudel is deprecated, `DEPRECATION.md`). Builds on `epic/sound-lab`.

## Problem Statement

- Changing a stem track means editing JSON slots by hand or "Save as" after swaps in the player. There is no place to
  see and edit the whole track at once.
- The Launchkey is SC code inside each track's frame (`lkNote`, `lkCtl`, a pad list). It cannot be chosen, swapped or
  edited like a stem; changing a pad means editing code.

## Definitions

- **Stem track**: `sc/tracks/<id>/<id>.track` (docs/features/stems.md), 14 slots plus a frame SC file.
- **Launchkey rig** (new): the Launchkey of a track as a JSON file: keys sound and blend, mod wheel, knob 1-8 targets,
  16 pads (one-shot file or font note, gain, rate, lane, play-once, name). A track names its rig; the frame no longer
  needs Launchkey code.
- **Track Designer**: the player view for editing one opened stem track.

## User Stories

1. **As a producer** I open a stem track in the Track Designer and hear it play as in the player.
   - Acceptance: every stem track in `sc/tracks/` opens and plays; the 14 slots show their stems.
2. **As a producer** I replace, remove or add a stem on a column and hear it at the next bar.
   - Acceptance: picking a stem from the library for a filled slot swaps it; Remove empties the slot; the drawer on an
     empty slot adds a stem; each plays from the next bar, or after a short reload when the strip does not fit.
3. **As a producer** I change the track's genre.
   - Acceptance: genre is picked from the list in `docs/reference/genres.md`; Save writes it into the track file.
4. **As a producer** I replace the Launchkey keys sound and single drum pads.
   - Acceptance: changing the keys sound plays it on the next key press; changing pad 5 to another one-shot or font
     note plays it on the next hit; Save writes both into the track's rig; no frame code is edited. Knobs are shown,
     not editable.
5. **As a producer** I Save the track, or Save as copy under a new id.
   - Acceptance: Save writes the opened track in place; Save as copy writes a new `sc/tracks/<new-id>/` (track, frame,
     rig) and never overwrites an existing track; `check-stems` passes on both.
6. **As a maintainer** the 009 stem track's Launchkey becomes a rig file and plays the same as its frame code.
   - Acceptance: the 009 Launchkey scenario (keys, every pad, every knob) gives the same events with the rig as with
     the frame code (`tools/sc-port` comparison).
7. **As Claude** I edit a track ("swap the techno kick, set genre to house") through a skill, writing the same track
   files the designer writes.

## Functional Requirements

### Launchkey rig
1. JSON format with schema and check (in `check-stems`): keys (sounds from `sc/lib/lkkeys.scd`, which knobs blend
   them), mod wheel target, knobs 1-8 (label, about, target parameter and range), 16 pads (name, sound, gain, rate,
   lane, once, optional font note and envelope), lanes (orbit, room, echo).
2. SC loader makes `lkNote`, `lkCtl`, `lkPadNames`, the Launchkey stem entry, states and samples from a rig; a track
   names it (`"launchkey": "<rig ref>"`); a frame with Launchkey code still works (old stem tracks).
3. 009's Launchkey extracted into a rig, proven equal.
4. Knobs are loaded from the rig but have no editor in this work package.

### Track Designer view
5. Same shell as the player (MIDI panel with the LC view, visuals, transport). The side panel is replaced by designer
   sections: Track, Stems, Launchkey, Save.
6. **Track** section: open a stem track (list of `sc/tracks/`), show id, genre (picker from
   `docs/reference/genres.md`), tempo and about as read-only context.
7. **Stems** section and columns: click a column (14 slots, both LC modes) to open the stem drawer; Replace, Remove and
   Add (empty slot). A change swaps at the bar line when the strip fits, else the track reloads with a short gap (as in
   the stem swap).
8. **Launchkey** section: keys sound picker (from `lkkeys.scd`); 16-pad grid with a per-pad sample picker (from
   `samples/` and the fonts) and a level per pad; knobs listed read-only.
9. **Save**: Save (writes track, genre, slots and rig in place), Save as copy (new id, copies frame and rig, never over
   an existing track). Unsaved changes marked; leaving with unsaved changes asks.
10. Skill `/track-designer`.

## Non-Functional Requirements

- Save writes only the opened track's own files; Save as copy refuses an existing id.
- Labels English and short; one name per job; `@ctl` texts for the rig knobs and pads.
- Feature tests in `npm test` (loose checks): rig load, rig equivalence, track open, stem replace/remove/add, genre
  save, Save as copy.

## Success Criteria

- A stem track opened in the Track Designer, edited (stems, genre, keys, a pad) and saved as copy plays in the player
  and passes `check-stems`.
- 009's Launchkey plays from a rig, equal to the frame code.
- `npm run path-lint` shows no new missing paths.

## Constraints & Assumptions

- Frames stay SC code (harmony, chapters, progressions); a copy copies the frame unchanged. Harmony as data is a later
  epic.
- Only 009 and 090 are stem tracks today; copies made here give `set-designer` more.
- Save in place overwrites a published track on explicit user action; git is the undo.

## Out of Scope

- Creating a track from empty columns or a template frame (open a track, Save as copy, remove stems instead).
- Tempo, swing, chapters editing; knob editing in the rig.
- Harmony / chord progressions as JSON, a chord editor.
- Porting the `.scd` tracks to stem tracks.
- Sets and the set engine (`set-designer`).
- Strudel.

## Dependencies

- Epic `sound-lab` (stems format 2, stem track loader, stem swap and drawer, Stem Designer): on `epic/sound-lab`,
  PR #73.
- `sc/lib/lkkeys.scd` (Launchkey keys), `tools/sc-port/` (comparison), `sc/tools/render.scd` (event log).
