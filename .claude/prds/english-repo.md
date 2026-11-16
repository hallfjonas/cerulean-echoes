---
name: english-repo
description: Translate the whole repository to English and drop the rule that German is used
status: backlog
created: 2026-11-15T16:40:00Z
---

# PRD: english-repo

## Executive Summary
The repository mixes German and English: German folder and file names (`lab/harmonie`, `midi-layouts/geraete.md`,
`recherche-*.md`, `uebergabe-*.md`), German notes, feedback, handbooks, comments and some live-view labels, plus a
standing rule in `CLAUDE.md` that chat with the user is German. This work makes every file, path, identifier and
generated document English and removes the German-language rule, without changing how any track sounds or how any
controller is laid out.

## Problem Statement
- Collaborators and agents who do not read German cannot use notes, feedback, research and handbooks.
- Two languages for one concept (`harmonie`/harmony, `melodie`/melody, `LC groß`/`LC big`) cause inconsistent names
  and broken references.
- `CLAUDE.md`, skills and agent memory force German chat, which is no longer wanted.

## User Stories
- **As the performer**, I read every `@ctl` text, layout sheet, LC custom-mode display name and live-view label in
  English.
  - Acceptance: no German word in any `@ctl` comment, generated layout PDF, `.syx` control name or live view.
- **As a collaborator or agent**, I find folders and files by English names and read notes in English.
  - Acceptance: `git ls-files` lists no German path segment; every `.md`, `.typ`, `.strudel`, `.mjs`, `.str` and
    `.html` file is English, including `lab/archive/`, the frozen set sources and feedback/handover notes (`old/` folders were removed on
    2026-11-15; their content lives in git history only and is not translated).
- **As the user**, the agent talks to me in English.
  - Acceptance: `CLAUDE.md`, `.claude/skills/*`, `VISION.md`, `TECH-STACK.md` and project memory contain no instruction
    to use German.
- **As the performer**, tracks and the set play exactly as before.
  - Acceptance: `/strudel-optimize` reports each translated live track equivalent to its pre-translation version;
    `npm run set` in `tools/` builds and `check-set.mjs` passes; `check-sounds.mjs` reports no newly broken sound.

## Functional Requirements
1. Remove the German-chat rule from `CLAUDE.md` (`Talk to the user in German`, `Chat with the user stays German`),
   from skills and from project memory; state English as the language everywhere.
2. Rename German paths to English (e.g. `lab/harmonie` → `lab/harmony`, `lab/melodie` → `lab/melody`,
   `lab/einwurf` → `lab/stab` or agreed equivalent, `lab/blaeser` → `lab/brass`, `lab/gitarre` → `lab/guitar`,
   `lab/streicher` → `lab/strings`, `midi-layouts/geraete.md` → `midi-layouts/devices.md`, `recherche-*` →
   `research-*`, `uebergabe-*` → `handover-*`, `hoerliste.md` → `listening-list.md`) with `git mv`, and update every
   reference (tools, set generator and frame, tapped trajectory files, skills, `CLAUDE.md`, tracks, boards).
3. Translate file contents: Markdown notes, feedback, research, handovers, docs, READMEs, Typst sources (layout and
   tutorial handbooks), comments and `@ctl` texts in `.strudel`/`.str` files, tool messages in `.mjs`.
4. Rename German identifiers and labels in code (e.g. `LC groß` → `LC big`) where they are not sound or bank names
   that must match an external source.
5. Regenerate derived files from the translated sources: layout PDFs and `.syx` (lcxl-layout hook / tools), tutorial
   handbook PDFs, `docs/skills.pdf`, the set `011-set-dual.strudel` (`npm run set`), generated single files
   (`make-single.mjs`).

## Non-Functional Requirements
- Sound-neutral: no change to any sound, effect, orbit, gain, pattern or controller CC.
- Non-destructive history: renames via `git mv` so history follows the files.
- Translation keeps meaning and the house style in `CLAUDE.md` (short English labels, one name per job).
- Machine rule: one heavy job at a time (PDF builds, simulator runs) on the shared M2 Air.

## Success Criteria
- A German-word scan (umlauts/ß plus a list of common German words and the old path names) over all tracked text
  files returns 0 hits, except whitelisted proper names, sample/bank names and quoted external titles.
- 0 German path segments in `git ls-files`.
- `npm run set` passes; every one-file live track (007, 008, 009, 009-riffs, 010) proven equivalent by
  `/strudel-optimize`.
- All layout PDFs, `.syx` files and tutorial PDFs rebuilt with a newer timestamp than their sources.

## Constraints & Assumptions
- The working tree currently holds a large uncommitted reorganisation (tracks moved into genre folders, deleted
  recordings and workshop files). It must be committed before this epic branches off, or the epic will conflict.
- External sound and bank names (VCSL file names, `gm_*` soundfonts, sample names in `samples/sounds.json`) stay as
  they are, even when German, because they must match their source.
- Voice samples and recorded audio are not re-recorded.
- Generated files are never edited by hand; their generators are rerun.

## Out of Scope
- Re-recording or renaming audio files whose names come from external sample banks.
- Changing sounds, mixes, controller layouts or track structure.
- Restructuring folders beyond the language renames.
- Translating third-party content in `node_modules` or vendored samples metadata.

## Dependencies
- Pending reorganisation committed to `main` first.
- Tools: `tools/lcxl-layout` (PDF/.syx), Typst, `tools/set` (`npm run set`, `check-set.mjs`),
  `tools/strudel-sim/check-sounds.mjs`, `/strudel-optimize`, `make-single.mjs`.
- Hooks that regenerate layout files after edits (expect many regenerations during the work).
