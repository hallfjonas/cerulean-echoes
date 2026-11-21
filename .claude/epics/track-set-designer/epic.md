---
name: track-set-designer
status: backlog
created: 2026-11-21T14:00:00Z
updated: 2026-11-21T14:00:00Z
progress: 12%
prd: .claude/prds/track-set-designer.md
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: track-set-designer

## Overview

Two designers on top of the sound lab. The **Track Designer** builds a stem track in the player: stems onto the 14
LC slots, tempo, swing, genre, a frame from a template track, and the Launchkey as a **rig** file (keys, knobs 1-8,
16 pads). The **Set Designer** orders stem tracks into a set file; the **set engine** plays it as one session, the next
track picked live with Next track (Mode 2, column 8, button 1) and taking over column by column at bar lines.

## Architecture Decisions (user, 2026-11-21)

- **SC only, stem tracks only.** No Strudel. A set holds stem tracks; `.scd` tracks join after a port (later epic).
- **Transition column by column.** The picked track's stems swap in slot by slot at bar lines (default slot order by
  role: pad / texture → sub / bass → drums → lead / keys / chords), built on `~ce.swapSlot`. Frame (chords,
  chapters) and rig switch at one bar in the middle; tempo glides over the transition. Not a dual-load crossfade.
- **Next track = Mode 2, column 8, button 1 (CC 92), MIDI mode.** Decided after the 001 spike: the LC XL 3 Track
  ◄ ► and Page ▲ ▼ buttons send nothing in standalone (MIDI) mode and Components cannot assign them; they report only
  in DAW mode, which this epic does not use (separate proposal: PR #75, `docs/reference/lcxl3-daw-mode.md`). In a set
  CC 92 cycles the pending next track, applied at the next phrase like Chapter; Mode 1 column 8 button 1 (CC 44)
  stays Chapter, so in a set these two no longer alias (every other column 8 control still does).
- **Launchkey as data.** A rig JSON (`sc/launchkey/<name>.lk`, versions as files like stems) replaces the frame's
  Launchkey code for new tracks; a frame with Launchkey code keeps working. A track names its rig
  (`"launchkey": "<ref>"`).
- **Frames stay code.** The Track Designer copies a frame from a template stem track; harmony as data is out of scope.
- **Designer projects are files** (as in sound-lab): `sc/lab/tracks/<name>.tracklab.json`, published to
  `sc/tracks/<id>/`; sets are results, not projects: `sc/sets/<id>/<id>.set`, edited by the Set Designer with Save /
  Save as.
- **Strip mismatch in a set** gets a new strip node next to the old one and a one-bar crossfade, no reload (a reload
  gap is not acceptable on stage). The stem swap's reload fallback stays for the designers.
- **Non-destructive everywhere.** Publish and Save as write new files.

## Technical Approach

### SC (`sc/lib/`)
- `lkrig.scd`: rig → `lkNote`, `lkCtl`, `lkPadNames`, the Launchkey stem entry (lanes), states, samples.
- `stemtrack.scd`: `launchkey` field; empty slots fillable from the designer (load with the new slot).
- `tracklab.scd`: Track Designer project → track Event (like `stemlab.scd`).
- `stemset.scd`: set file → one session: all tracks' frames and rigs loaded, the playing track's columns live,
  preload on pick, the transition scheduler (slot order, bar per step, frame and rig switch, tempo glide), live strip
  replacement, the Next track latch on CC 92.
- `engine.scd`, `render.scd`: load `.tracklab.json` and `.set`.

### Player (`tools/trajectory/`)
- Track Designer: catalogue Lab entries, New / Load / Save / Save as / Publish, track settings, the stem drawer on
  empty slots, a Launchkey panel (keys, knobs, pads with a sample picker).
- Set Designer: pick and order stem tracks, transition length, Save / Save as; sets in the catalogue under Live.
- LC view and SC panel: set head (playing, next, transition progress).

### Tools
- Schemas `sc/launchkey/lk.schema.json`, `sc/lab/tracks/tracklab.schema.json`, `sc/sets/set.schema.json`; checks in
  `check-stems` (rigs, sets) and the project check; `npm run stems` lists rigs and "used by" for rigs.
- Skills `/track-designer`, `/set-designer`.

## Implementation Strategy

001 (spike) and 002 (rig) start in parallel. 003 (Track Designer) needs the rig. The set engine (005) needs the rig
(it switches rigs) and runs parallel to 003; the live pick (006) needs 001 and 005; the Set Designer UI (007) needs
005. Skills and docs close (008). One branch and PR per task group, `epic/track-set-designer-<group>`, off
`epic/sound-lab` until that merges, then off `origin/main`.

Risks:
- Strip replacement while playing (new node, crossfade, free the old) is new in the mixer; test it alone first.
- CPU during a transition (two tracks' sounds, preload): gate finished slots, measure on the M2 Air.
- Few stem tracks exist (009, 090): the set needs tracks from the Track Designer to be tested in earnest.
- Tempo glide: stems with own echo times in beats and the step engine's 16th grid during a changing tempo.

## Task Breakdown Preview

| # | Task | Parallel |
|---|---|---|
| 001 | Spike: what the LC XL 3 Track ◄ ► (and Page) buttons send in custom mode (done: nothing) | first, with the user's device |
| 002 | Launchkey rig: format, schema, check, SC loader, 009's Launchkey extracted and proven equal | first |
| 003 | Track Designer: project format, SC loader, player (slots, settings, Launchkey panel), Publish | after 002 |
| 004 | `/track-designer` skill | after 003 |
| 005 | Set format and SC set engine (preload, column-by-column transition, frame/rig switch, tempo glide, strip crossfade) | after 002, parallel to 003 |
| 006 | Live next track: Next track latch (CC 92), LC view and SC panel set head | after 001, 005 |
| 007 | Set Designer in the player, sets in the catalogue | after 005 |
| 008 | `/set-designer` skill, docs (sets, stems, devices, sound-lab), CLAUDE.md pointers | last |

## Dependencies

- Epic `sound-lab` (PR #73): stem format 2, `stemtrack.scd`, `~ce.swapSlot` / `swapProblem`, the stem drawer,
  `stemlab.scd` as the model for project loading.
- The user and an LC XL 3 for task 001.

## Success Criteria (Technical)

- `check-stems` green on rigs, tracks and sets; `npm test` covers rig load and equivalence, project load and publish,
  set load, a full transition (every slot of the new track plays, no slot silent more than one bar unless empty in the
  new track), the Next track latch.
- 009 with its rig matches the frame-code Launchkey event by event (`tools/sc-port`).
- A 3-track set plays on the M2 Air without dropouts through a transition (measured).
- `npm run path-lint` shows no new missing paths.

## Estimated Effort

8 tasks, about 70 hours of agent work plus listening and device time. Biggest: 005 (set engine), 003 (Track
Designer).

## Tasks Created
- [x] 001.md - Spike: LC XL 3 Track ◄ ► buttons (parallel: true)
- [ ] 002.md - Launchkey rig (parallel: true)
- [ ] 003.md - Track Designer (parallel: false)
- [ ] 004.md - /track-designer skill (parallel: true)
- [ ] 005.md - Set format and SC set engine (parallel: true)
- [ ] 006.md - Live next track (parallel: false)
- [ ] 007.md - Set Designer in the player (parallel: true)
- [ ] 008.md - /set-designer skill and docs (parallel: false)

Total tasks: 8
Parallel tasks: 5
Sequential tasks: 3
Estimated total effort: 70 hours
