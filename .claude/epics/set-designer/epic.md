---
name: set-designer
status: backlog
created: 2026-11-21T14:00:00Z
updated: 2026-11-21T16:30:00Z
progress: 20%
prd: .claude/prds/set-designer.md
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: set-designer

## Overview

Second of two sequential work packages (split from `track-set-designer`); starts when `track-designer` is done and
merged. The **Set Designer** orders stem tracks into a set file; the **set engine** plays it as one session, the next
track picked live with Mode 2, column 8, button 1 (Next track) and taking over column by column at bar lines.

## Architecture Decisions (user, 2026-11-21)

- **SC only, stem tracks only.** A set holds stem tracks; `.scd` tracks join after a port (later epic).
- **Transition column by column.** The picked track's stems swap in slot by slot at bar lines (default slot order by
  role: pad / texture → sub / bass → drums → lead / keys / chords), built on `~ce.swapSlot`. Frame (chords,
  chapters) and rig switch at one bar in the middle; tempo glides over the transition. Not a dual-load crossfade.
- **Next track = Mode 2, column 8, button 1 (CC 92), MIDI mode.** Decided after the 001 spike: the LC XL 3 Track
  ◄ ► and Page ▲ ▼ buttons send nothing in standalone (MIDI) mode and Components cannot assign them; they report only
  in DAW mode, which this epic does not use (separate proposal: PR #75, `docs/reference/lcxl3-daw-mode.md`). In a set
  CC 92 cycles the pending next track, applied at the next phrase like Chapter; Mode 1 column 8 button 1 (CC 44)
  stays Chapter, so in a set these two no longer alias (every other column 8 control still does).
- **Sets are results, not projects:** `sc/sets/<id>/<id>.set`, edited by the Set Designer with Save / Save as.
- **Strip mismatch in a set** gets a new strip node next to the old one and a one-bar crossfade, no reload (a reload
  gap is not acceptable on stage). The stem swap's reload fallback stays for the designers.
- **Non-destructive everywhere.** Save as writes new files.

## Technical Approach

### SC (`sc/lib/`)
- `stemset.scd`: set file → one session: all tracks' frames and rigs loaded, the playing track's columns live,
  preload on pick, the transition scheduler (slot order, bar per step, frame and rig switch, tempo glide), live strip
  replacement, the Next track latch.
- `engine.scd`, `render.scd`: load `.set`.

### Player (`tools/trajectory/`)
- Set Designer: pick and order stem tracks, transition length, Save / Save as; sets in the catalogue under Live.
- LC view and SC panel: set head (playing, next, transition progress).

### Tools
- Schema `sc/sets/set.schema.json`; check in `check-stems`.
- Skill `/set-designer`, CLI `npm run set-lab`.

## Implementation Strategy

001 (spike) is done. 002 (set engine) needs the rig from `track-designer`; 003 (live pick) needs 002; 004 (Set
Designer UI) needs 002; 005 (skill and docs) closes. One branch and PR per task group, `epic/set-designer-<group>`,
off `origin/main`.

Risks:
- Strip replacement while playing (new node, crossfade, free the old) is new in the mixer; test it alone first.
- CPU during a transition (two tracks' sounds, preload): gate finished slots, measure on the M2 Air.
- The set needs several stem tracks to be tested in earnest: made with the Track Designer.
- Tempo glide: stems with own echo times in beats and the step engine's 16th grid during a changing tempo.

## Task Breakdown Preview

| # | Task | Parallel |
|---|---|---|
| 001 | Spike: LC XL 3 Track / Page buttons (done, result in the task) | done |
| 002 | Set format and SC set engine (preload, column-by-column transition, frame/rig switch, tempo glide, strip crossfade) | after track-designer |
| 003 | Live next track: CC 92 latch, LC view and SC panel set head | after 002 |
| 004 | Set Designer in the player, sets in the catalogue | after 002, parallel to 003 |
| 005 | `/set-designer` skill and docs | last |

## Dependencies

- Epic `track-designer`: rig loader (the set switches rigs between tracks) and the tracks made with the Track Designer.
- Epic `sound-lab` (PR #73): `~ce.swapSlot` / `swapProblem`, stem track loader.
- The user and an LC XL 3 for the live try in 003.

## Success Criteria (Technical)

- `check-stems` green on sets; `npm test` covers set load, a full transition (every slot of the new track plays, no
  slot silent more than one bar unless empty in the new track), the Next track latch.
- A 3-track set plays on the M2 Air without dropouts through a transition (measured).
- `npm run path-lint` shows no new missing paths.

## Estimated Effort

5 tasks (1 done), about 37 hours of agent work plus listening and device time. Biggest: 002 (set engine).

## Tasks Created
- [x] 001.md - Spike: LC XL 3 Track buttons (parallel: true)
- [ ] 002.md - Set format and SC set engine (parallel: false)
- [ ] 003.md - Live next track (parallel: true)
- [ ] 004.md - Set Designer in the player (parallel: true)
- [ ] 005.md - /set-designer skill and docs (parallel: false)

Total tasks: 5
Parallel tasks: 3
Sequential tasks: 2
Estimated total effort: 37 hours
