---
name: docs-overhaul
description: User-facing feature docs, CONTRIBUTING.md, cleaner docs/ folder, and retirement of player-future.md
status: backlog
created: 2026-11-18T06:24:40Z
---

# PRD: docs-overhaul

## Executive Summary

The repo has many features (player, live tracks, controllers, auto-perform, lab boards, sets, checks, producer mode)
but no text that explains them to a person who is not Claude. `CLAUDE.md` is written for the agent, `docs/` is a mix of
old notes, and `docs/player-future.md` is a draft vision whose parts are now spread over epics. This PRD adds a
user-facing `docs/features/` folder in simple English, a `CONTRIBUTING.md`, a cleaned `docs/` structure, and removes
`player-future.md` after moving what is not planned elsewhere.

## Problem Statement

- A new user (a musician, a friend like Jojo, a contributor) cannot learn what the player or a live track does
  without reading code or `CLAUDE.md`.
- `docs/` holds stale or one-off files (`ideas.md`, `workflow-review.md`, an HTML duplicate of a Markdown file) next
  to living ones; there is no index.
- `docs/player-future.md` overlaps four epics (`llm-support`, `recording-replay`, `producer-mode-guitar-pro`,
  `vis-live-mapping`). Ideas that no epic covers are only recorded there.
- Contribution rules (branches, non-destructive tracks, generated files, `npm run verify`) exist only inside
  `CLAUDE.md`.

## User Stories

1. **As a musician**, I want one page per feature in plain English, so I can use the player and the controllers
   without reading code.
   - Each page states: what it is, when to use it, how, what to know. No jargon without a glossary link.
2. **As a new contributor**, I want `CONTRIBUTING.md`, so I know the branch flow, the rules and the checks before my
   first PR.
   - It names the checks to run, the files never edited by hand, and where epics and PRDs live.
3. **As the maintainer**, I want `player-future.md` gone without losing unplanned ideas.
   - Every idea in it is either covered by a named epic or recorded in `TODO.md`; no link points to the deleted file.
4. **As any reader**, I want `docs/` to have an index and a clear split (features, reference, dev).
   - `docs/README.md` lists every file with one line; no file in `docs/` is unlisted.

## Functional Requirements

### FR1: Retire `player-future.md`
- Extract what no epic covers into a `TODO.md` section "Player ideas (not yet planned)": meta-steering (`meta.mjs`,
  curve view, control-map sweep, closed-loop and agent steering); producer inputs beyond Guitar Pro (song form, note
  sheet, song name) with song model, generator and timeline; trajectory score, crowd tap, emotions and
  picture-to-controls link; SuperCollider engine seam; direction (beginner day one, expert one level up) and the
  shared principles (measure → map → steer, one virtual port, one song model, one file per track).
- Fix links to the file in `tools/trajectory/README.md` and `.claude/epics/llm-support/epic.md`.
- Delete `docs/player-future.md`. Remove the matching action item from `TODO.md`.

### FR2: `docs/` structure
```
docs/
  README.md            index
  getting-started.md   hardware, start player, first play
  features/            one page per feature (FR3)
  reference/           glossary.md, devices.md, casio-gp310-midi.md, listening-list.md
  dev/                 skills overview (typ + pdf)
```
- Delete `ideas.md` (done item, stale) and `casio-gp310-midi.html` (if it is a generated duplicate).
- Decide `workflow-review.md`: delete (git history keeps it) unless it is still referenced.
- Move `glossary.md` and `references.md` (renamed `listening-list.md`) into `reference/`; `skills.typ` and
  `skills.pdf` into `dev/`. `midi-layouts/devices.md` stays where it is and is linked, not copied.
- Update every inbound path (CLAUDE.md, skills, tools, epics).

### FR3: `docs/features/`
Pages (simple English, audience: users): `README.md` (list), `player`, `live-tracks`, `controllers`, `auto-perform`,
`lab-boards`, `sets`, `samples-and-sounds`, `layout-sheets`, `checks`, `visuals`, `producer-mode`, `claude-skills`,
`strudel-cc`.
- Fixed shape per page: what it is, when to use it, how to use it, good to know, related pages.
- Use the project vocabulary (Brightness, Space, Level, Pattern, Fog, Thin, Tension, Master, Chapter, Break).
- Explain audio basics plainly when a term is needed.
- Only shipped features get a page. Planned ones (`llm-support`, `recording-replay`) get none until they ship.

### FR4: `CONTRIBUTING.md` (repo root)
Branch and PR flow (never push to main, fresh `origin/main`, one PR per feature), non-destructive track rule, one file
per live track, generated files and the regenerate commands, `npm run verify` before a PR, label and glossary rules,
sample and sound rules, link to `docs/README.md`. Written for humans, not a copy of `CLAUDE.md`.

The docs are method-agnostic: a contributor needs no PRD or epic. `CONTRIBUTING.md` has one section, "Planning larger
work (optional)", that says so and holds the how for those who plan with CCPM (or a similar PRD → epic flow). It is the
single place for those rules; `CLAUDE.md` and the feature pages only point to it. Content of the section:
- When not to: a fix, a small change, a docs edit, one track tweak → branch and PR, nothing else.
- Where files live: PRD `.claude/prds/<name>.md`, epic `.claude/epics/<name>/` (`epic.md` + numbered tasks),
  kebab-case name.
- Plan PR: branch `plan/<name>`, planning files only, merged before work starts.
- Build PRs: branch `epic/<name>` (or one branch per task group), one PR per epic or group; task status and epic
  `status`/`progress` updated in the same PR.
- Closing: when the epic is done and merged, a removal PR (`chore/remove-<name>-epic`) deletes the epic folder and the
  PRD; anything worth keeping (a spec, a decision) moves first to `docs/` or the tool's README. Git history keeps the rest.
- GitHub issue sync is optional and off by default.
- Agents: use CCPM only when the user asks for it; follow these rules when they do.

### FR5: Keep docs from rotting
- `CLAUDE.md` gets a short pointer to `docs/README.md` and `CONTRIBUTING.md`; no duplicated content. Its section
  "CCPM epics and PRDs" shrinks to: optional, only when the user asks, rules in `CONTRIBUTING.md`. The link to the
  personal skill path (`/Users/.../ccpm/SKILL.md`) is dropped.
- `npm run path-lint` covers paths cited in the new docs.

## Non-Functional Requirements

- Plain English, short sentences, no German terms (see glossary).
- Feature pages are 1 to 2 screens each; details link to READMEs under `tools/`, not copied.
- Facts checked against the code or a tool run, not written from memory.
- No file over 10 MB; no generated file edited by hand.

## Success Criteria

- `docs/player-future.md` does not exist; `grep -r player-future` (outside git history and worktrees) finds nothing.
- Every idea of the old file maps to an epic name or a `TODO.md` entry (checklist in the epic's task 1).
- 14 feature pages exist, each with the five fixed headings.
- `docs/README.md` lists 100% of files under `docs/`.
- `npm run path-lint` passes.
- `CONTRIBUTING.md` exists; a reader can open a correct PR using only it and the pages it links.
- `CONTRIBUTING.md` states that PRDs and epics are optional and holds the CCPM rules once; `grep -n 'plan/<name>'`
  finds them there and nowhere else in the docs; `CLAUDE.md` has no machine-specific path.
- The Documentation block in `TODO.md` is removed.

## Constraints & Assumptions

- Repo is the only place for docs (no wiki, no site generator).
- Feature pages describe the player and tracks as they are on `main` at write time; epics in flight may change them,
  so pages mark nothing as planned.
- Assumes `casio-gp310-midi.html` is generated from the `.md`; verified before deletion.
- Machine rule: one heavy job at a time (no heavy jobs needed here).

## Out of Scope

- A root `README.md` (can follow as a small separate change).
- Docs for planned features (`llm-support`, `recording-replay`, `drop-buildup`, `produce-perform-split`).
- Translating or rewriting `CLAUDE.md`, skill files or `tools/**/README.md`.
- A docs site, PDF handbook generation, screenshots or videos.
- Rewriting the listening list content.

## Dependencies

- Epics named above (for the extraction check): `llm-support`, `recording-replay`, `producer-mode-guitar-pro`,
  `vis-live-mapping`.
- `tools/trajectory/README.md` and `midi-layouts/devices.md` as link targets.
- Open PRs touching `docs/` or `TODO.md`: check with `gh pr list` before starting.
