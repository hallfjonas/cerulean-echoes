---
name: sc-migration
description: Move every live track, the player's engine and the lab to SuperCollider; retire Strudel where it costs upkeep
status: backlog
created: 2026-11-20T12:13:35Z
---

# PRD: sc-migration

## Executive Summary

cerulean-echoes is a tool for collaborative live performance with MIDI controllers, playable by people without
prior knowledge. Today it runs on two engines: Strudel (browser) and a SuperCollider (SC) port of 007-010. This
project makes SC the one engine for live play: the player (track list, MIDI panel, auto-perform, takes, recording,
and the visuals as a playground) runs on SC, the remaining Strudel-only tracks are ported, sound development moves to a new SC lab, and
Strudel parts that need upkeep are retired. Background and earlier decisions: `SC-MIGRATION.md`,
`sc/PLAN-SC-ENGINE.md`, `sc/PLAN-UI.md`, `sc/PLAN-STEM-LIBRARY.md`.

## Problem Statement

- In Strudel a knob only affects the next note; players want controls that act immediately on sounding notes. SC
  does this (the main reason for the switch).
- Two codebases: every track exists twice and the two players' work diverges (SC port on one side, new Strudel
  tracks and player features on the other).
- The player's features (recording, visuals, auto-perform, takes, track switching) work only with the Strudel
  engine, so the SC versions cannot use them.
- Starting SC today needs the SC IDE ("select all, Cmd-Return"); guests cannot do that.

## User Stories

1. **As a player (Johannes or Jonas)** I pick any live track in the player, press Play and play it with one or two
   Launch Control XL 3 and the Launchkey, and every knob acts at once.
   - Acceptance: 001, 002, 007, 008, 009, 010, 016 are listed with engine SC; Play / Stop / switching works; a knob
     turn changes a held note audibly within a fraction of a second.
2. **As a guest without prior knowledge** I start a set with one double-click and play with the controller,
   reading control names in the MIDI panel.
   - Acceptance: from a Mac with the app installed, one double-click opens the player on the MIDI panel with SC
     running; no SC IDE, no terminal.
3. **As a player** I run an auto-performance, save and replay a take, and record a WAV, all on SC.
   - Acceptance: each of these works on 009 (SC) as it does on Strudel today; the existing perform scripts play
     unchanged.
   - The visuals are a playground: they draw SC tracks, low priority, need not match today's look, no tests.
4. **As a sound designer (with Claude)** I develop and compare sounds in an SC lab and promote a winner into a
   track or the library.
   - Acceptance: an SC machine lab (one instrument on the whole LC) and an options lab (columns = variants) exist,
     and one sound has gone lab → library → track.
5. **As a maintainer** I change the software and know that every feature still works.
   - Acceptance: one `npm test` runs the feature tests (player, controllers, auto-perform, takes, recording,
     producer, SC core); a GitHub Actions job runs the Node part on every PR.

## Functional Requirements

1. Player engine: `engine-sc.mjs` behind the existing engine interface (`load`, `stop`, `cycle`, `cps`, output via
   SC); SC's OSC bridge folded into `tools/trajectory/server.mjs`; the catalogue lists SC tracks with their engine.
2. Controllers go straight to SC; the browser only mirrors them (MIDI panel shows SC's state).
3. Visuals (low priority, playground): SC sends note messages and the visuals draw them; they need not match today's
   version and get no tests.
4. Auto-perform and take replay send their steps to SC (`/ce/cc`, `/ce/lkcc`, `/ce/lknote`); take capture keeps
   working; the bar clock comes from SC.
5. Recording: SC records its master output; `recording.mjs` keeps file names and the sidecar format.
6. Launcher: one macOS double-click start for SC (headless) + player + browser, clean shutdown.
7. Port 001-groove, 002-groove and 016-grroove-opus to SC (`sc/tracks/`), same controls and `@ctl` texts.
8. SC lab: moved to the `sound-lab` epic (Sample Designer, Stem Designer, promote; decided 2026-11-20); here only the
   Strudel boards in `lab/` move to git history once it exists.
9. Feature tests (`npm test`) for every feature above plus SC core (`UnitTest`, headless `sclang`); `verify-sc` for one
   changed SC track (loads without errors, tags parse, perform scripts valid).
10. Retire: set 011 (tracks/sets/) and historic 000-006 (tracks/historic/); Strudel-only checks and skills
    (`strudel-sim` checks, `verify`/`compare`/`audibility`/`measure`, samples/sounds.json tooling,
    `/strudel-mix`, `/strudel-optimize`) once nothing that stays depends on them; skills that stay (`/lab-board`,
    `/lab-to-track`, `/add-sample`, `/auto-perform`) get their SC path.
11. Source of truth (D1): a ported track's `.strudel` file is frozen; edits happen only in its `.scd`.

## Non-Functional Requirements

- Runs on one MacBook Air (M2, 16 GB) next to other apps; SC + player together stay light (no second heavy job).
- A browser or Node crash never stops sound or controllers (controllers never route through the browser).
- Controller to sound latency for knobs and pads stays as today in SC (a few ms; patterns may use `s.latency`).
- Tests are feature tests: loose checks (something plays, a value arrives, a file is written), the whole suite in a
  few minutes; no sound measuring, no event-by-event track comparisons.
- Every phase ends with something playable; Strudel tracks keep working until their SC version exists.

## Success Criteria

- All 7 live tracks play from the player on SC; 0 live tracks need the Strudel engine.
- All player features (track list, MIDI panel, auto-perform, takes, recording) pass their feature tests on SC.
- A first-time user starts a set in under 2 minutes with the launcher and the README (tried with one person).
- `npm test` green on `main`, run on every PR by CI (Node part).
- Retired parts gone from the working tree: the Tools page and the Analysis page, tracks/sets/, tracks/historic/, the Strudel lab boards, the
  Strudel-only checks and skills; CLAUDE.md and docs describe the SC workflow.

## Constraints & Assumptions

- Two players, no deadline; work ships phase by phase, one PR per task group (CONTRIBUTING.md).
- No live coding: code is written in advance (by Claude), playing happens only on controllers.
- Hardware: Launch Control XL 3 (one or two, same two custom modes `midi-layouts/lcxl3-mode1.syx` / `-mode2.syx`),
  Launchkey MK4 25.
- SC ≥ 3.13; bundling SC into the launcher is allowed (GPL); the first launcher may require an installed SC.
- The SC port of 007-010 is complete and faithful (`sc/PORTING.md`); porting tools exist in `tools/sc-port/`.

## Out of Scope

- Remote / phone access to the player (D3: not for now).
- Layout sheets and per-track `.syx` (retired 2026-11-20); the player's Tools page and Analysis page (retired
  2026-11-20, task 011).
- Visuals matching the current version, and tests for the visuals.
- Sound or loudness testing, event-by-event track comparisons, proving tracks stay identical.
- Producer (Guitar Pro → track): stays as it is, writing Strudel; an SC output is decided when the next song comes.
- Removing the player's Strudel engine: it stays while it needs no maintenance (D2); removing it is a later step.
- The ear-training tutorials in `lab/tutorials/`: not ported; they stay as they are.
- Stem banks, track switching per column and harmony state from `sc/PLAN-UI.md` beyond what the tracks need today.

## Dependencies

- `sc/` on `main` (PR #42, merged); layout retirement (PR #54) and the CCPM skill (PR #55) merged first.
- SuperCollider installed on both players' machines; Node in `tools/`.
- GitHub Actions available on the repository (for the CI job).
- Jonas' agreement on the plan (plan PR review), as the player features are largely his work.
