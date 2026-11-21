---
name: track-set-designer
description: Two more designers on the sound lab - Track Designer (stems onto the LC columns, Launchkey keys, pads and knobs) and Set Designer (stem tracks into a playable set, next track picked live)
status: backlog
created: 2026-11-21T14:00:00Z
---

# PRD: track-set-designer

## Executive Summary

The sound lab (epic `sound-lab`) made the stem a file, the track a JSON assignment of stems to the 14 LC slots, and
gave the player a Sample Designer and a Stem Designer. Two steps are missing to go from sounds to a performance:

- **Track Designer**: build a new stem track in the player: pick stems for the columns of both LC modes, set tempo,
  swing, genre and the harmony frame, and set up the Launchkey: keys sound, the 8 knobs and the 16 drum pads.
- **Set Designer**: choose stem tracks, order them, and play them as one set. Between two tracks the next track's
  stems take over column by column at bar lines, tempo and harmony move with them. The next track is picked live
  with column 8 button 1 on Mode 2 (Next track).

SuperCollider only (Strudel is deprecated, `DEPRECATION.md`). Builds on `epic/sound-lab`.

## Problem Statement

- A new stem track is written by hand (JSON slots plus a copied SC frame) or by "Save as" after swaps on an existing
  track. There is no place to start a track from empty columns.
- The Launchkey is SC code inside each track's frame (`lkNote`, `lkCtl`, a pad list). It cannot be chosen, swapped or
  edited like a stem; changing a pad means editing code.
- A set exists only as the Strudel set 011: generated, four fixed tracks, moved by the Fog knob. SC has no set at all.
- In a live set the order is fixed in advance; the player cannot decide on stage which track comes next.

## Definitions

- **Stem track**: `sc/tracks/<id>/<id>.track` (docs/features/stems.md), 14 slots plus a frame SC file.
- **Launchkey rig** (new): the Launchkey of a track as a JSON file: keys sound and blend, mod wheel, knob 1-8 targets,
  16 pads (one-shot file or font note, gain, rate, lane, play-once, name). A track names its rig; the frame no longer
  needs Launchkey code.
- **Track Designer project**: a working file in `sc/lab/tracks/`, published as a stem track.
- **Set**: `sc/sets/<id>/<id>.set`, an ordered, unique list of stem tracks with transition settings. Played as one
  performance; the start track is the first one, every later track is picked live.
- **Transition**: the change from the playing track to the picked one, slot by slot over a number of bars.

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
4. **As a performer** I build a set from stem tracks in the player's Set Designer, save it, and play it.
   - Acceptance: a set of 2+ tracks saves to `sc/sets/<id>/<id>.set`, loads in the player and plays its first track.
5. **As a performer** I press Next track (Mode 2, column 8, button 1) during the set to pick the next track; the LC view shows it; at the next
   phrase the transition starts and the new track takes over column by column, no gap, tempo gliding.
   - Acceptance: in a set of 3 tracks, picking track 3 from track 1 starts the transition at the next phrase; every
     slot of track 3 plays after the transition; no slot falls silent for more than one bar unless the new track
     leaves it empty; the tempo moves without a jump.
6. **As Claude** I build a track ("a dark techno track from the techno stems") or a set from a sentence through a
   skill, writing project files the player loads.

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

### Set Designer and set engine
10. Set file `sc/sets/<id>/<id>.set` (schema, check): unique stem tracks in order, start track, transition length in
    bars, phrase length for picks, optional slot order of the transition (default by role: pad and texture, then sub
    and bass, then drums, then leads, keys and chords).
11. SC set engine: one set plays as one track session. Picking a next track preloads its sounds and samples; the
    transition swaps slot by slot at bar lines, switches the frame (chords, chapters) and the rig at one bar, glides
    the tempo. A slot whose strip differs gets a new strip and crossfades over one bar, no reload.
12. Global column 8 keeps its meaning in the set (Fog, Thin, Tension, Master, Chapter, Break of the playing track).
13. Live pick: Next track (Mode 2, column 8, button 1, CC 92) cycles the pending next track in set order
    (wraps; landing on the playing track again = stay, no transition). The pick applies at the next phrase, like
    Chapter. Mode 1 column 8 button 1 (CC 44) stays Chapter; in a set the two no longer alias.
14. LC view and SC panel: playing track, pending next track, transition progress.
15. Player: Set Designer under Lab (pick, order, save, Save as); sets listed in the catalogue and played under Live.
16. Skill `/set-designer`.

## Non-Functional Requirements

- M2 Air: during a transition two tracks' sounds are on the server; only the slots still playing are asked (gating
  as in tracks). Measured in the player.
- Non-destructive: designers never overwrite a track, stem, rig or set; Publish and Save as write new files.
- Labels English and short; one name per job; `@ctl` texts for the rig knobs and pads.
- Feature tests in `npm test` (loose checks): rig load, rig equivalence, project load and publish, set load, a
  transition that ends with every slot of the new track playing.

## Success Criteria

- A track built in the Track Designer from empty columns plays in the player and passes `check-stems`.
- 009's Launchkey plays from a rig, equal to the frame code.
- A set of 3 stem tracks plays live; Next track picks the next one; the transition has no gap.
- `npm run path-lint` shows no new missing paths.

## Constraints & Assumptions

- Stem tracks only in a set. Hand-written `.scd` tracks (007, 008, 010, 016) join only after they are ported to stem
  tracks (not in this epic).
- Today only 009 and 090 are stem tracks; a meaningful set needs more. The Track Designer produces them; the epic
  tests the set engine with 009, 090 and tracks made in the Track Designer.
- Frames stay SC code (harmony, chapters, progressions); the Track Designer copies a frame from a template track.
  Harmony as data is a later epic.
- The LC XL 3 stays in standalone (MIDI) mode. Its Track ◄ ► and Page ▲ ▼ buttons send nothing there (measured in
  001); DAW mode is a separate proposal (PR #75), not used by this epic.

## Out of Scope

- Harmony / chord progressions as JSON, a chord editor.
- Porting the `.scd` tracks to stem tracks.
- Auto-performance scripts for sets (`/auto-perform` on a set).
- Recording a set as a take with replay (works only if it falls out of the track take).
- Strudel: no Strudel set, no changes to set 011.

## Dependencies

- Epic `sound-lab` (stems format 2, stem track loader, stem swap and drawer, Stem Designer): on `epic/sound-lab`,
  PR #73.
- `sc/lib/lkkeys.scd` (Launchkey keys), `tools/sc-port/` (comparison), `sc/tools/render.scd` (event log).
