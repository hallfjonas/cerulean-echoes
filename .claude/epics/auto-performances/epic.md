---
name: auto-performances
status: backlog
created: 2026-11-16T16:13:34Z
updated: 2026-11-16T16:13:34Z
progress: 0%
prd: .claude/prds/auto-performances.md
github: (will be set on sync)
---

# Epic: auto-performances

## Overview

Extend the auto-perform script format (meta info, sections, Launchkey steps), then design, script and review one
performance per live track in two user loops — design approval, then listening feedback — with 010 as pilot. Close by
distilling the process into a project skill `auto-perform`.

## Architecture Decisions

- **Extend, don't replace, the script format.** New fields are optional; `every-button.json` and `spike-run.json` stay
  valid. One format for player (`autoperform.mjs`) and Node (`scenario.mjs` via `valueChanges`).
- **Virtual Launchkey port** in `midi.mjs` next to `LCXL3 Auto`, named so the tracks' `midikeys()` / LK knob lookup
  match it, the same way `LCXL3 Auto` matches the LC lookup. No track changes.
- **Design and feedback as Markdown beside the script** (`perform/<track>/<name>.md`, `perform/<track>/feedback.md`),
  like the lab boards' `feedback.md`. The catalogue keeps listing only `*.json`.
- **Approval gates are explicit**: a task does not move from design to script, or from script to done, without the
  user's "approved" logged in `feedback.md`.
- **Pilot first**: 010 runs both loops before 007/008/009 start, so template and format are fixed once.

## Technical Approach

### Frontend Components
- `autoperform.mjs`: compile key / pad / LK steps; expose current section; drawer shows title, section, bars left.
- `player.html` / `render.mjs` top bar: current section name while a script plays.

### Backend Services
- `midi.mjs`: virtual Launchkey input (`setAutoKeys`, LK CCs), reset on stop.
- `check-perform.mjs`: validate meta, sections, key / pad / LK steps (pads 36-51, LK CC 1 and 31-38, parseable notes).
- `strudel-sim/scenario.mjs --script`: feed Launchkey steps; add a per-section level summary (reuse audibility).

### Infrastructure
- `perform/<track>/<name>.json` + `<name>.md` + `feedback.md` per track.
- `perform/design-template.md`: the design doc template.
- `.claude/skills/auto-perform/SKILL.md`: the final skill.
- README "Auto-perform" section updated; `npm run path-lint` clean.

## Implementation Strategy

1. Format + engine (001) and the design template (003) in parallel; player display (002) after 001.
2. Pilot 010 (004): loop 1 design → approval → script → loop 2 rounds → approval. Fix template / format from what hurts.
3. 007, 008, 009 (005-007) in parallel, each with both loops; the user reviews one at a time.
4. Skill (008) from the four `feedback.md` logs; dry run on one track.

Each performance: `npm run verify -- <track>`, scenario per section (no CLIPS, no unplanned SILENT), then the user
listens in the player.

## Task Breakdown Preview

- 001 Script format v2: meta, sections, Launchkey steps (engine, Node, checks)
- 002 Player shows title and current section
- 003 Design template and feedback log format
- 004 Pilot: 010 ambient-house performance (both loops)
- 005 007 ambient performance (both loops)
- 006 008 groove-techno performance (both loops)
- 007 009 house performance (both loops)
- 008 Skill `auto-perform` from what we learned

## Dependencies

- Merged player hub / auto-perform (PR #24).
- User availability for 8 review gates (2 per track).
- Untracked `vis-live-mapping` epic touches `render.mjs` / `strudel-source.mjs`: coordinate before 002 edits the top bar.

## Success Criteria (Technical)

- `check-perform` passes for all scripts; old scripts unchanged and still pass.
- Scenario run of each performance: 0 CLIPS, no unplanned SILENT section.
- Player plays Launchkey steps (keys audible on `stemLK`, pads fire) — verified in the browser pane.
- 8 approvals logged across four `feedback.md` files.
- Skill dry run reaches a design proposal unaided.

## Estimated Effort

About 33 agent hours plus the user's listening time; the review loops set the calendar time, not the code.

## Tasks Created
- [ ] 001.md - Script format v2: meta, sections, Launchkey steps (parallel: true)
- [ ] 002.md - Player shows title and current section (parallel: false, after 001)
- [ ] 003.md - Design template and feedback log format (parallel: true)
- [ ] 004.md - Pilot: 010 ambient house performance (parallel: false, after 001 + 003)
- [ ] 005.md - 007 ambient performance (parallel: true, after 004)
- [ ] 006.md - 008 groove techno performance (parallel: true, after 004)
- [ ] 007.md - 009 house performance (parallel: true, after 004)
- [ ] 008.md - Skill auto-perform from what we learned (parallel: false, after 005-007)

Total tasks: 8
Parallel tasks: 5
Sequential tasks: 3
Estimated total effort: 33 hours
