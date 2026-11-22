---
name: sc-migration
status: in-progress
created: 2026-11-20T12:13:35Z
updated: 2026-11-22T03:14:19Z
progress: 82%
prd: .claude/prds/sc-migration.md
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: sc-migration

## Overview

Make SuperCollider the engine for every live track and every player feature, port the three Strudel-only tracks,
start an SC lab, and retire the Strudel parts that cost upkeep. The player (`tools/trajectory/`) stays the one front
end; SC becomes a second engine behind its existing engine interface. Supersedes the phase list in
`sc/PLAN-SC-ENGINE.md` (its decisions, tool table and test scope stay valid; the file is removed with this epic).

## Architecture Decisions

- **Player stays, SC is a second engine.** `engine-sc.mjs` implements `{ ready, load, stop, cycle, cps, output }` like
  `engine-strudel.mjs`; nothing in the page needs to know which engine plays.
- **One Node process.** `sc/ui/bridge.mjs` (OSC ⇄ HTTP) folds into `tools/trajectory/server.mjs`; SC already speaks
  `/ce/cc`, `/ce/lkcc`, `/ce/lknote` in and `/ce/beat`, `/ce/state`, `/ce/layout`, `/ce/ccs` out (`sc/lib/ui.scd`).
- **Controllers go to SC directly.** The browser listens to the same hardware only to show values and capture takes.
- **SC records itself** (`DiskOut`); the WAV no longer passes through the browser.
- **D1:** a ported track's `.scd` is the source of truth, its `.strudel` is frozen. **D2:** the Strudel engine stays
  while it needs no work. **D3:** no remote access.
- **Tests check features, not tracks** (no golden logs, no sound measuring). The visuals are a playground: no tests.
- **Tools page and Analysis page retired** (not needed any more).

## Technical Approach

### Frontend Components
- `tools/trajectory/engine-sc.mjs` (new); `sc-source.mjs` (new, note messages → visuals; playground).
- `player.html`: picks the engine per catalogue entry; MIDI panel fed from SC state when SC plays.
- `autoperform.mjs` / `take.mjs`: send steps to the engine (OSC for SC) instead of the virtual Web MIDI port.

### Backend Services
- `server.mjs`: OSC socket + WebSocket relay (from `bridge.mjs`); recording endpoints start/stop SC's recorder.
- `catalogue.mjs`: lists `sc/tracks/*/*.scd` with `engine: 'sc'`.
- SC (`sc/lib/ui.scd`, `steps.scd`, `setup.scd`): `/ce/load`, `/ce/stop`, `/ce/note` per sounding note, `/ce/record`.
- Launcher: `Cerulean Echoes.app` (stay-open AppleScript applet, `tools/launcher/`) starts the server and the browser;
  the server starts `sclang sc/engine.scd` on the first SC load, quitting the app ends both.

### Infrastructure
- `npm test` runs all Node tests and one headless `sclang` test script; GitHub Actions runs the Node part per PR.
- `verify-sc` (small): track loads headless, tags parse, perform scripts valid.

## Implementation Strategy

Foundation first (tests + engine), then the player features in parallel, while the track ports and the SC lab run
alongside. Retirement comes last, when nothing that stays depends on the Strudel tools. Each task group is its own
branch and PR (`epic/sc-migration-<group>`), ends playable, and updates its task status in the same PR.

Risks: two clocks drifting (the page must follow SC's beat); OSC traffic per note for visuals (send from the language,
not the audio thread); the take ↔ WAV alignment once SC records.

## Task Breakdown Preview

| # | Task | Parallel |
|---|---|---|
| 001 | Feature-test harness: one `npm test`, SC core `UnitTest`, CI for Node | first |
| 002 | SC engine in the player: load / stop / clock / catalogue / MIDI panel | after 001 |
| 003 | Visuals from SC (playground, low priority, no tests) | after 002, any time |
| 004 | Auto-perform and takes on SC | after 002 |
| 005 | Recording in SC | after 002 |
| 006 | Launcher (one double-click start) | after 002 (005 nice to have) |
| 007 | Port 001-groove and 002-groove | after 001, parallel to everything |
| 008 | Port 016-grroove-opus | after 001, parallel to everything |
| 009 | Archive the Strudel lab (SC lab moved to the `sound-lab` epic) | after sound-lab 005, 007 |
| 011 | Retire the Tools page and the Analysis page | now, parallel to everything |
| 010 | Tools, skills and docs for SC; retire set 011, historic, Strudel checks and skills | last |

## Dependencies

- PRs #54 (layout retirement) and #55 (CCPM skill) merged.
- SuperCollider ≥ 3.13 on both machines; `tools/` Node setup.
- Existing: `tools/sc-port/` (porting and comparison), `sc/tools/render.scd` (offline render with event log).

## Success Criteria (Technical)

- `npm test` green: feature tests for track list, load/play/stop/switch, controllers, pattern/Chapter/Break, MIDI
  panel, auto-perform, takes, recording, producer, SC core.
- 7 live tracks load on SC from the player; perform scripts in `tools/trajectory/perform/` play on SC to the end.
- Launcher starts and stops everything with no leftover processes.
- `tracks/sets/`, `tracks/historic/`, Strudel lab boards and Strudel-only checks/skills removed; `npm run path-lint`
  shows no new missing paths.

## Estimated Effort

About 10 task groups, roughly 107 hours of agent work plus listening/approval time by the players; no deadline.
Biggest items: 002 (engine) and the ports (007, 008).

## Tasks Created
- [x] 001.md - Feature-test harness and SC core tests (parallel: false)
- [x] 002.md - SC engine in the player (parallel: false)
- [x] 003.md - Visuals from SC, playground (parallel: true)
- [x] 004.md - Auto-perform and takes on SC (parallel: true)
- [x] 005.md - Recording in SC (parallel: true)
- [ ] 006.md - Launcher (parallel: true) — built (#83); open: tried once with one person (under 2 minutes)
- [ ] 007.md - Port 001-groove and 002-groove to SC (parallel: true) — ported (#85); open: the players' ear approval
- [ ] 008.md - Port 016-grroove-opus to SC (parallel: true) — ported (#64), live check done; open: the players' ear approval
- [x] 009.md - Archive of the Strudel lab; SC lab moved to `sound-lab` (parallel: true)
- [ ] 010.md - Tools, skills, docs for SC; retire Strudel parts (parallel: false)
- [x] 011.md - Retire the Tools page and the Analysis page (parallel: true)

Total tasks: 11
Parallel tasks: 8
Sequential tasks: 3
Estimated total effort: 107 hours

## Status (2026-11-22)
- Closed: 001, 002, 003, 004, 005, 009, 011.
- Built, waiting for people: 006 (one first-time user tries the launcher), 007 and 008 (the players approve 001, 002
  and 016 by ear; five Strudel quirks kept 1:1 in 001/002 are listed in `sc/PORTING.md` for a decision).
- Open: 010 (retire the Strudel parts, SC docs and skills), last; it can start now.
- Branch: everything is on `epic/sc-migration-next`, merged with `main` (sound lab, player pages) on 2026-11-22;
  one PR into main, #91 (replaces #77-#81, contains #82, #83, #85). `npm test` 113/113, muted.
- Known: two LC XL 3s can still make knobs jump (each device keeps its own values); `sc/tools/lc-feedback-test.scd`
  decides whether SC can keep both devices in step. `sc/samples/voice/david.flac` is not in git (007's sample check
  fails on a fresh clone). The auto-perform test at 24 bars/s was flaky under load.
- Tests and trial runs start SC with `CE_SC_MUTE=1` (master to a silent bus).
