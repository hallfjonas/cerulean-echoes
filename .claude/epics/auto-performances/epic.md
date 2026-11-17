---
name: auto-performances
status: completed
created: 2026-11-16T16:13:34Z
updated: 2026-11-17T09:00:00Z
progress: 100%
prd: .claude/prds/auto-performances.md
github: https://github.com/hallfjonas/cerulean-echoes/pull/26 (single PR, no per-task issues)
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
- [x] 001.md - Script format v2: meta, sections, Launchkey steps (user confirmed real Launchkey works while a script plays)
- [x] 002.md - Player shows title and current section (done)
- [x] 003.md - Design template and feedback log format (done)
- [x] 004.md - Pilot: 010 ambient house performance (approved, re-confirmed after the timing fix; clipping unmeasured)
- [x] 005.md - 007 ambient performance, "drift" (approved; the wind cue on "air" was dropped, time unknown)
- [x] 006.md - 008 groove techno performance, "techno-night" (approved)
- [x] 007.md - 009 house performance, "dance-floor" (approved)
- [x] 008.md - Skill auto-perform from what we learned (`.claude/skills/auto-perform/SKILL.md`; dry run on 009 reached a design proposal unaided)

Delivered together in PR #26. `[x]` done.

## Progress notes
- **Pilot findings that changed the plan:** a performance starts from an existing script when there is one (010 needed
  one design round); the length in minutes goes into the design and is checked once with a stopwatch against the top
  bar; the built-in browser pane cannot play (no Web MIDI), so the user listens in Chrome, with the player started from
  the working tree on its own port.
- **Timing bug found in loop 2:** in the player every script started one bar early and each step came about a tenth of a
  bar late (start bar rounded down from a clock just below 0; steps read the current time, not the scheduler's query
  position). Fixed in `autoperform.mjs` / `engine-strudel.mjs`. The Node scenario counts bars directly and could not
  show it, so a script is only proven by a listen in the player.
- **Launchkey in scripts:** the real and the virtual Launchkey both feed the track (shared key queue, last moved wins
  for knobs and mod wheel). Keys sound only while the mod wheel is above 0, and knobs read 0 until set (Brightness,
  Length): scripts set them before the first keys. Pads are one-shots and are used sparingly, on the beat grid.
- **Per-track findings:** 007 needs a transcript or the user's timestamp to cue sounds to David's words (no speech to
  text installed); music must already fade in under the voice. 008 needs a lively intro, one quiet bram before a drop
  and a long, gradual drift-out. 009 keys need explicit Brightness and Length steps.
- **Working method:** designs were drafted by one agent per track in parallel, scripts by the same agent after approval;
  heavy runs (scenario, audibility) take a lock directory so one runs at a time on the 16 GB machine; worktrees share
  one `tools/node_modules` through a symlink.
- **Loop 2 result (2026-11-16):** the user approved all four performances ("ALL PERFECT NOW"); the timing fix stays
  (the performances were approved with it in place). The real Launchkey works while a script plays; the Launchkey knobs
  (CC 31-38) work.
- **Not measured:** clipping for any script (`npm run audibility` measures the default state and crashes on 007) and
  CPU at the densest section; both stay open until a measured or listened pass.

Total tasks: 8
Parallel tasks: 5
Sequential tasks: 3
Estimated total effort: 33 hours
