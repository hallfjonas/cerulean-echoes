---
name: track-designer
description: Track Designer - build a stem track in the player (stems onto the LC columns, Launchkey keys, pads and knobs as a rig file); first of two work packages, followed by set-designer
status: backlog
created: 2026-11-21T14:00:00Z
---

# PRD: track-designer

## Executive Summary

The sound lab (epic `sound-lab`) made the stem a file, the track a JSON assignment of stems to the 14 LC slots, and
gave the player a Sample Designer and a Stem Designer. The next step towards a performance is the **Track Designer**:
build a new stem track in the player: pick stems for the columns of both LC modes, set tempo, swing, genre and the
harmony frame, and set up the Launchkey: keys sound, the 8 knobs and the 16 drum pads.

First of two sequential work packages (split from `track-set-designer`). The second, `set-designer`, starts when this
one is done and merged.

SuperCollider only (Strudel is deprecated, `DEPRECATION.md`). Builds on `epic/sound-lab`.

## Problem Statement

- A new stem track is written by hand (JSON slots plus a copied SC frame) or by "Save as" after swaps on an existing
  track. There is no place to start a track from empty columns.
- The Launchkey is SC code inside each track's frame (`lkNote`, `lkCtl`, a pad list). It cannot be chosen, swapped or
  edited like a stem; changing a pad means editing code.

## Definitions

- **Stem track**: `sc/tracks/<id>/<id>.track` (docs/features/stems.md), 14 slots plus a frame SC file.
- **Launchkey rig** (new): the Launchkey of a track as a JSON file: keys sound and blend, mod wheel, knob 1-8 targets,
  16 pads (one-shot file or font note, gain, rate, lane, play-once, name). A track names its rig; the frame no longer
  needs Launchkey code.
- **Track Designer project**: a working file in `sc/lab/tracks/`, published as a stem track.

## User Stories

1. **As a producer** I start a new track in the player from a template frame (e.g. 009's harmony), click a column,
   pick a stem from the library, and hear it at the next bar; I fill as many of the 14 slots as I want.
   - Acceptance: a Track Designer project with 3 filled slots plays; adding a stem to an empty slot plays it (from
     the next bar or after a short reload); Publish writes `sc/tracks/<id>/<id>.track`, its frame and its rig, and
     `check-stems` passes.
2. **As a producer** I set the Launchkey for the track: choose the keys sound, assign the 8 knobs, swap single drum
   pads for other one-shots.
   - Acceptance: changing pad 5 to another sample plays the new sample on the next hit; Save writes the change into
     the project's rig; no frame code is edited.
3. **As a maintainer** the 009 stem track's Launchkey becomes a rig file and plays the same as its frame code.
   - Acceptance: the 009 Launchkey scenario (keys, every pad, every knob) gives the same events with the rig as with
     the frame code (`tools/sc-port` comparison).
4. **As Claude** I build a track ("a dark techno track from the techno stems") through a skill, writing a
   project file the player loads.

## Functional Requirements

### Launchkey rig
1. JSON format with schema and check (in `check-stems`): keys (sounds from `sc/lib/lkkeys.scd`, which knobs blend
   them), mod wheel target, knobs 1-8 (label, about, target parameter and range), 16 pads (name, sound, gain, rate,
   lane, once, optional font note and envelope), lanes (orbit, room, echo).
2. SC loader makes `lkNote`, `lkCtl`, `lkPadNames`, the Launchkey stem entry, states and samples from a rig; a track
   names it (`"launchkey": "<rig ref>"`); a frame with Launchkey code still works (old stem tracks).
3. 009's Launchkey extracted into a rig, proven equal.

### Track Designer
4. Project file `sc/lab/tracks/<name>.tracklab.json` (schema): name, about, tempo, swing, genre, frame source (a
   frame copied from a stem track), chapters, slots (library stems or empty), rig (library rig or a draft rig).
5. Player: projects listed under Lab; New (from a template frame), Load, Save, Save as, Publish (new stem track, never
   over an existing one).
6. Columns: the stem drawer works on empty slots too; a filled slot swaps at the bar line when the strip fits, else
   the project reloads with a short gap (as in the stem swap).
7. Launchkey panel: keys sound, knob targets, per-pad sample picker (from `samples/` and the fonts), level per pad.
8. Track settings: tempo, swing, genre (`docs/reference/genres.md`), chapters, about.
9. Skill `/track-designer`.

## Non-Functional Requirements

- Non-destructive: the designer never overwrites a track, stem or rig; Publish and Save as write new files.
- Labels English and short; one name per job; `@ctl` texts for the rig knobs and pads.
- Feature tests in `npm test` (loose checks): rig load, rig equivalence, project load and publish.

## Success Criteria

- A track built in the Track Designer from empty columns plays in the player and passes `check-stems`.
- 009's Launchkey plays from a rig, equal to the frame code.
- `npm run path-lint` shows no new missing paths.

## Constraints & Assumptions

- Frames stay SC code (harmony, chapters, progressions); the Track Designer copies a frame from a template track.
  Harmony as data is a later epic.
- Only 009 and 090 are stem tracks today; the Track Designer produces more, which `set-designer` needs.

## Out of Scope

- Harmony / chord progressions as JSON, a chord editor.
- Porting the `.scd` tracks to stem tracks.
- Sets and the set engine (`set-designer`).
- Strudel.

## Dependencies

- Epic `sound-lab` (stems format 2, stem track loader, stem swap and drawer, Stem Designer): on `epic/sound-lab`,
  PR #73.
- `sc/lib/lkkeys.scd` (Launchkey keys), `tools/sc-port/` (comparison), `sc/tools/render.scd` (event log).
