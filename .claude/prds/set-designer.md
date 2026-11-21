---
name: set-designer
description: Set Designer and SC set engine - order stem tracks into a set, play it as one session, pick the next track live with Next track; second of two work packages, after track-designer
status: backlog
created: 2026-11-21T14:00:00Z
---

# PRD: set-designer

## Executive Summary

Second of two sequential work packages (split from `track-set-designer`); starts when `track-designer` is done and
merged, so stem tracks with rigs exist to build sets from.

- **Set Designer**: choose stem tracks, order them, and play them as one set. Between two tracks the next track's
  stems take over column by column at bar lines, tempo and harmony move with them. The next track is picked live
  with column 8 button 1 on Mode 2 (Next track).

SuperCollider only (Strudel is deprecated, `DEPRECATION.md`).

## Problem Statement

- A set exists only as the Strudel set 011: generated, four fixed tracks, moved by the Fog knob. SC has no set at all.
- In a live set the order is fixed in advance; the player cannot decide on stage which track comes next.

## Definitions

- **Stem track**: `sc/tracks/<id>/<id>.track` (docs/features/stems.md), 14 slots plus a frame SC file, optionally a
  Launchkey rig (epic `track-designer`).
- **Set**: `sc/sets/<id>/<id>.set`, an ordered, unique list of stem tracks with transition settings. Played as one
  performance; the start track is the first one, every later track is picked live.
- **Transition**: the change from the playing track to the picked one, slot by slot over a number of bars.

## User Stories

1. **As a performer** I build a set from stem tracks in the player's Set Designer, save it, and play it.
   - Acceptance: a set of 2+ tracks saves to `sc/sets/<id>/<id>.set`, loads in the player and plays its first track.
2. **As a performer** I press Next track (Mode 2, column 8, button 1) during the set to pick the next track; the LC view shows it; at the next
   phrase the transition starts and the new track takes over column by column, no gap, tempo gliding.
   - Acceptance: in a set of 3 tracks, picking track 3 from track 1 starts the transition at the next phrase; every
     slot of track 3 plays after the transition; no slot falls silent for more than one bar unless the new track
     leaves it empty; the tempo moves without a jump.
3. **As Claude** I build a set ("from ambient to techno with the stem tracks") through a skill, writing a set
   file the player loads.

## Functional Requirements

1. Set file `sc/sets/<id>/<id>.set` (schema, check): unique stem tracks in order, start track, transition length in
    bars, phrase length for picks, optional slot order of the transition (default by role: pad and texture, then sub
    and bass, then drums, then leads, keys and chords).
2. SC set engine: one set plays as one track session. Picking a next track preloads its sounds and samples; the
    transition swaps slot by slot at bar lines, switches the frame (chords, chapters) and the rig at one bar, glides
    the tempo. A slot whose strip differs gets a new strip and crossfades over one bar, no reload.
3. Global column 8 keeps its meaning in the set (Fog, Thin, Tension, Master, Chapter, Break of the playing track).
4. Live pick: Next track (Mode 2, column 8, button 1, CC 92) cycles the pending next track in set order
    (wraps; landing on the playing track again = stay, no transition). The pick applies at the next phrase, like
    Chapter. Mode 1 column 8 button 1 (CC 44) stays Chapter; in a set the two no longer alias.
5. LC view and SC panel: playing track, pending next track, transition progress.
6. Player: Set Designer under Lab (pick, order, save, Save as); sets listed in the catalogue and played under Live.
7. Skill `/set-designer`.

## Non-Functional Requirements

- M2 Air: during a transition two tracks' sounds are on the server; only the slots still playing are asked (gating
  as in tracks). Measured in the player.
- Non-destructive: Save as never overwrites a set.
- Labels English and short; one name per job.
- Feature tests in `npm test` (loose checks): set load, a transition that ends with every slot of the new track
  playing, the Next track latch.

## Success Criteria

- A set of 3 stem tracks plays live; Next track picks the next one; the transition has no gap.
- `npm run path-lint` shows no new missing paths.

## Constraints & Assumptions

- Stem tracks only in a set. Hand-written `.scd` tracks (007, 008, 010, 016) join only after they are ported to stem
  tracks (not in this epic).
- The set engine is tested with 009, 090 and tracks made in the Track Designer.
- The LC XL 3 stays in standalone (MIDI) mode. Its Track ◄ ► and Page ▲ ▼ buttons send nothing there (measured in
  the spike, task 001); DAW mode is a separate proposal (PR #75), not used by this epic.

## Out of Scope

- Auto-performance scripts for sets (`/auto-perform` on a set).
- Recording a set as a take with replay (works only if it falls out of the track take).
- Strudel: no Strudel set, no changes to set 011.

## Dependencies

- Epic `track-designer` (rig loader, tracks to build sets from).
- Epic `sound-lab` (stem track loader, stem swap).
- `tools/sc-port/`, `sc/tools/render.scd` (event log).
