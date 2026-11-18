---
name: docs-overhaul
status: completed
created: 2026-11-18T06:24:40Z
updated: 2026-11-18T12:00:00Z
progress: 100%
prd: .claude/prds/docs-overhaul.md
github: (will be set on sync)
---

# Epic: docs-overhaul

## Overview

Write user-facing feature docs, add `CONTRIBUTING.md`, give `docs/` an index and a clear structure, and retire
`docs/player-future.md` after moving its unplanned ideas into `TODO.md`. Docs only: no code, sound or layout change.

## Architecture Decisions

- **Three folders by reader.** `docs/features/` (users), `docs/reference/` (lookup: glossary, devices, Casio,
  listening list), `docs/dev/` (maintainer material). One `docs/README.md` index lists every file.
- **Unplanned ideas go to `TODO.md`,** one short entry each, not into new PRDs. A PRD is written when one is picked up.
  The long text stays in git history (`git show <commit>:docs/player-future.md`; the commit is named in the TODO entry).
- **Pages stay thin and link out.** Feature pages explain use; `tools/**/README.md`, `midi-layouts/devices.md` and
  skills hold the detail and are linked, never copied.
- **One page shape:** What it is · When to use it · How · Good to know · Related.
- **Facts from the repo.** Each page is checked against the code or a tool run before it is written down.
- **Method-agnostic docs.** PRDs and epics are optional. `CONTRIBUTING.md` says so and holds the CCPM how in one
  section ("Planning larger work (optional)"); `CLAUDE.md` keeps a pointer plus "only when the user asks", so agents
  that use CCPM follow the same rules as people. No other page describes the flow.
- **Only shipped features.** No page for `llm-support`, `recording-replay`, `drop-buildup`, `produce-perform-split`.
- **Moves keep history:** `git mv`, then fix inbound paths with `npm run path-lint`.

## Technical Approach

### Docs
- Target tree as in the PRD (FR2). Feature page list: `player`, `live-tracks`, `controllers`, `auto-perform`,
  `lab-boards`, `sets`, `samples-and-sounds`, `layout-sheets`, `checks`, `visuals`, `producer-mode`,
  `claude-skills`, `strudel-cc`, plus `features/README.md`.
- Sources per page: `tools/trajectory/README.md` (player, visuals, auto-perform), `CLAUDE.md` and
  `midi-layouts/templates/dual-lc.strudel` (live tracks, controllers), `lab/*/feedback.md` (lab boards),
  `tools/set/` (sets), `samples/sounds.json` (sounds), `.claude/skills/*/SKILL.md` (skills, checks, layout sheets),
  `tools/producer/` and epic `producer-mode-guitar-pro` (producer mode).
- Inbound paths to update: `CLAUDE.md`, `.claude/skills/*`, `.claude/epics/*`, `tools/**/README.md`, `TODO.md`.

### Tooling
- `npm run path-lint` (in `tools/`) for cited paths.
- `grep -r` for the old file names across the repo excluding `.claude/worktrees/` and `node_modules/`.

## Implementation Strategy

Task 1 and 2 first and in order (they move files and set the tree). Then 3 to 6 run in parallel (disjoint files). Task 6 (`CONTRIBUTING.md`) is independent of 3 to 5 and can start after 2. Task 7 closes.

Pre-work: `git status` and `gh pr list` for open work on `docs/`, `TODO.md`, `tools/trajectory/README.md`. Branch from
a fresh `origin/main`, one PR. This epic lives on its feature branch while open and is removed from main after merge.

## Task Breakdown Preview

1. **Extract and retire `player-future.md`.** Write the `TODO.md` section "Player ideas (not yet planned)"; build the
   idea → epic/TODO checklist (all four covered ideas map to an epic name); fix links in
   `tools/trajectory/README.md` and `llm-support/epic.md`; delete the file; remove the TODO action item.
   Depends on: none.
2. **Restructure `docs/`.** Create `README.md`, `reference/`, `dev/`; delete `ideas.md` and the HTML duplicate (verify
   generated first); decide `workflow-review.md`; move glossary, references (→ `listening-list.md`), skills files;
   fix inbound paths. Depends on: 1.
3. **`getting-started.md` + feature pages: player, controllers, live-tracks.** Depends on: 2. Parallel.
4. **Feature pages: auto-perform, lab-boards, sets, samples-and-sounds.** Depends on: 2. Parallel.
5. **Feature pages: layout-sheets, checks, visuals, producer-mode, claude-skills, strudel-cc, `features/README.md`.**
   Depends on: 2. Parallel.
6. **`CONTRIBUTING.md`** (with the optional CCPM section) plus pointer lines in `CLAUDE.md`. Depends on: 2. Parallel.
7. **Review pass.** Read all pages as a newcomer: vocabulary, English, 1 to 2 screens, five headings, glossary
   links; fix dead links; `docs/README.md` lists every file; `npm run path-lint`; remove the Documentation block
   from `TODO.md`. Depends on: 3, 4, 5, 6.

(Seven tasks; 3 to 6 run in parallel.)

## Dependencies

- Open PRs or sessions editing `docs/`, `TODO.md` or the trajectory README (check first).
- Epics `llm-support`, `recording-replay`, `producer-mode-guitar-pro`, `vis-live-mapping` stay as they are; only a
  link in `llm-support` changes.
- Producer mode and its tools are still in flight on this branch (`tools/producer/`, 012, 013): the
  `producer-mode` page is written last in its group and reflects what is merged.

## Success Criteria (Technical)

- `docs/player-future.md` removed; `grep -rn player-future . --exclude-dir=node_modules --exclude-dir=worktrees`
  returns no hits outside `.git`.
- 14 feature pages with the five headings (`grep -L '^## Good to know' docs/features/*.md` empty).
- Every file under `docs/` appears in `docs/README.md`.
- `cd tools && npm run path-lint` passes.
- `CONTRIBUTING.md` at the root, linked from `docs/README.md` and `CLAUDE.md`.
- `git diff --stat` shows only Markdown, `.typ`/`.pdf` moves and removed files; no code change.

## Estimated Effort

About 7 tasks, roughly 1.5 to 2 days of Claude work with user review of the feature pages (the main review cost).
Task 1: small. Task 2: small. Tasks 3 to 5: medium each. Task 6: small. Task 7: small to medium.

## Tasks Created
- [ ] 001.md - Extract ideas and retire player-future.md (parallel: false)
- [ ] 002.md - Restructure docs/ folder (parallel: false)
- [ ] 003.md - Getting started and feature pages: player, controllers, live tracks (parallel: true)
- [ ] 004.md - Feature pages: auto-perform, lab boards, sets, samples and sounds (parallel: true)
- [ ] 005.md - Feature pages: layout sheets, checks, visuals, producer mode, Claude skills, strudel.cc (parallel: true)
- [ ] 006.md - Write CONTRIBUTING.md (parallel: true)
- [ ] 007.md - Review pass and close-out (parallel: false)

Total tasks: 7
Parallel tasks: 4
Sequential tasks: 3
Estimated total effort: 23 hours
