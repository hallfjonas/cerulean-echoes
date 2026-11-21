---
name: track-designer
status: backlog
created: 2026-11-21T14:00:00Z
updated: 2026-11-21T17:20:35Z
progress: 0%
prd: .claude/prds/track-designer.md
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: track-designer

## Overview

First of two sequential work packages (split from `track-set-designer`). The **Track Designer** is a player view for
editing one opened stem track: replace, remove or add stems on the 14 LC slots, change the genre, change the Launchkey
keys sound and single drum pads, then Save or Save as copy. The Launchkey becomes a **rig** file (keys, knobs 1-8, 16
pads). The follow-up epic `set-designer` starts when this one is done and merged.

## Architecture Decisions (user, 2026-11-21)

- **SC only, stem tracks only.** No Strudel.
- **Edit an existing track, not build from empty.** Open a track, change it, Save or Save as copy. A new track starts
  as a copy with stems removed.
- **Same shell as the player.** MIDI panel with the LC view, visuals and transport stay; only the side panel is
  replaced by designer sections (Track, Stems, Launchkey, Save).
- **Launchkey as data.** A rig JSON (`sc/launchkey/<name>.lk`) replaces the frame's Launchkey code; a track names its
  rig (`"launchkey": "<ref>"`). A frame with Launchkey code keeps working. Knobs load from the rig but have no editor.
- **Frames stay code.** A copy copies the frame unchanged; harmony as data is out of scope.
- **Save writes only the opened track's own files.** Save as copy refuses an existing id; git is the undo for Save.

## Technical Approach

### SC (`sc/lib/`)
- `lkrig.scd`: rig → `lkNote`, `lkCtl`, `lkPadNames`, the Launchkey stem entry (lanes), states, samples.
- `stemtrack.scd`: `launchkey` field; empty slots fillable (load with the new slot); `genre` field read and written.

### Player (`tools/trajectory/`)
- Designer view: shell as the player, side panel sections Track / Stems / Launchkey / Save.
- Reuse `stem-drawer.mjs`, `stem-swap.mjs` (Replace, plus Remove and Add on empty slots), `selection.mjs` (kind
  `column`, new kind `pad` for the Launchkey grid).
- Routes for open, save, save as copy; unsaved-change marker and leave prompt.

### Tools
- Schema `sc/launchkey/lk.schema.json`; rig checks in `check-stems`; `npm run stems` lists rigs with "used by".
- Skill `/track-designer` edits the same track files the designer writes.

## Implementation Strategy

001 (rig) first. 002 (view, stems, genre, Save) needs the rig only for Save as copy, so it follows 001. 003
(Launchkey section) needs both. 004 (skill and docs) closes. One branch and PR per task group,
`epic/track-designer-<group>`, off `epic/sound-lab` until that merges, then off `origin/main`.

Risks:
- The rig must equal 009's frame-code Launchkey event by event, or tracks sound different once they switch.
- Save in place overwrites a published track: only on explicit user action.
- Only 009 and 090 are stem tracks: tests run on those and on copies in a temp dir.

## Task Breakdown Preview

| # | Task | Parallel |
|---|---|---|
| 001 | Launchkey rig: format, schema, check, SC loader, 009's Launchkey extracted and proven equal | first |
| 002 | Track Designer view: open, stems (replace, remove, add), genre, Save, Save as copy | after 001 |
| 003 | Launchkey section: keys sound picker, pad grid with sample picker and level, knobs read-only | after 002 |
| 004 | `/track-designer` skill and docs | after 003 |

## Dependencies

- Epic `sound-lab` (PR #73): stem format 2, `stemtrack.scd`, `~ce.swapSlot` / `swapProblem`, the stem drawer.
- `sc/lib/lkkeys.scd`, `tools/sc-port/`, `sc/tools/render.scd`.

## Success Criteria (Technical)

- `check-stems` green on rigs and tracks; `npm test` covers rig load and equivalence, track open, stem
  replace/remove/add, genre save, Save as copy.
- 009 with its rig matches the frame-code Launchkey event by event (`tools/sc-port`).
- A track opened, edited (stems, genre, keys, a pad) and saved as copy plays in the player and passes `check-stems`.
- `npm run path-lint` shows no new missing paths.

## Estimated Effort

4 tasks, about 36 hours of agent work plus listening time. Biggest: 002.

## Tasks Created
- [ ] 001.md - Launchkey rig (parallel: false)
- [ ] 002.md - Track Designer view (parallel: false)
- [ ] 003.md - Launchkey section (parallel: false)
- [ ] 004.md - /track-designer skill and docs (parallel: false)

Total tasks: 4
Parallel tasks: 0
Sequential tasks: 4
Estimated total effort: 36 hours

## Next

Epic `set-designer` (`.claude/epics/set-designer/`). It starts only when this epic is done and merged.
