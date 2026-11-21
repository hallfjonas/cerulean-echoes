---
name: track-designer
status: backlog
created: 2026-11-21T14:00:00Z
updated: 2026-11-21T16:30:00Z
progress: 0%
prd: .claude/prds/track-designer.md
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: track-designer

## Overview

First of two sequential work packages (split from `track-set-designer`). The **Track Designer** builds a stem track in
the player: stems onto the 14 LC slots, tempo, swing, genre, a frame from a template track, and the Launchkey as a
**rig** file (keys, knobs 1-8, 16 pads). The follow-up epic `set-designer` starts when this one is done and merged.

## Architecture Decisions (user, 2026-11-21)

- **SC only, stem tracks only.** No Strudel.
- **Launchkey as data.** A rig JSON (`sc/launchkey/<name>.lk`, versions as files like stems) replaces the frame's
  Launchkey code for new tracks; a frame with Launchkey code keeps working. A track names its rig
  (`"launchkey": "<ref>"`).
- **Frames stay code.** The Track Designer copies a frame from a template stem track; harmony as data is out of scope.
- **Designer projects are files** (as in sound-lab): `sc/lab/tracks/<name>.tracklab.json`, published to
  `sc/tracks/<id>/`.
- **Non-destructive everywhere.** Publish and Save as write new files.
- **Standalone LC mode.** The LC XL 3 stays in standalone (MIDI) mode (decision of the spike, now task 001 of
  `set-designer`).

## Technical Approach

### SC (`sc/lib/`)
- `lkrig.scd`: rig → `lkNote`, `lkCtl`, `lkPadNames`, the Launchkey stem entry (lanes), states, samples.
- `stemtrack.scd`: `launchkey` field; empty slots fillable from the designer (load with the new slot).
- `tracklab.scd`: Track Designer project → track Event (like `stemlab.scd`).
- `engine.scd`, `render.scd`: load `.tracklab.json`.

### Player (`tools/trajectory/`)
- Catalogue Lab entries, New / Load / Save / Save as / Publish, track settings, the stem drawer on empty slots, a
  Launchkey panel (keys, knobs, pads with a sample picker).

### Tools
- Schemas `sc/launchkey/lk.schema.json`, `sc/lab/tracks/tracklab.schema.json`; checks in `check-stems` (rigs) and the
  project check; `npm run stems` lists rigs with "used by".
- Skill `/track-designer`, CLI `npm run track-lab`.

## Implementation Strategy

001 (rig) first. 002 (Track Designer) needs the rig. 003 (skill and docs) closes. One branch and PR per task group,
`epic/track-designer-<group>`, off `epic/sound-lab` until that merges, then off `origin/main`.

Risks:
- The rig must equal 009's frame-code Launchkey event by event, or tracks sound different once they switch.
- Few stem tracks exist (009, 090): the Track Designer is also how more get made, which the next epic needs.

## Task Breakdown Preview

| # | Task | Parallel |
|---|---|---|
| 001 | Launchkey rig: format, schema, check, SC loader, 009's Launchkey extracted and proven equal | first |
| 002 | Track Designer: project format, SC loader, player (slots, settings, Launchkey panel), Publish | after 001 |
| 003 | `/track-designer` skill and docs | after 002 |

## Dependencies

- Epic `sound-lab` (PR #73): stem format 2, `stemtrack.scd`, `~ce.swapSlot` / `swapProblem`, the stem drawer,
  `stemlab.scd` as the model for project loading.

## Success Criteria (Technical)

- `check-stems` green on rigs and tracks; `npm test` covers rig load and equivalence, project load and publish.
- 009 with its rig matches the frame-code Launchkey event by event (`tools/sc-port`).
- A track built from empty columns plays in the player and passes `check-stems`.
- `npm run path-lint` shows no new missing paths.

## Estimated Effort

3 tasks, about 33 hours of agent work plus listening time. Biggest: 002 (Track Designer).

## Tasks Created
- [ ] 001.md - Launchkey rig (parallel: false)
- [ ] 002.md - Track Designer (parallel: false)
- [ ] 003.md - /track-designer skill and docs (parallel: false)

Total tasks: 3
Parallel tasks: 0
Sequential tasks: 3
Estimated total effort: 33 hours

## Next

Epic `set-designer` (`.claude/epics/set-designer/`). It starts only when this epic is done and merged.
