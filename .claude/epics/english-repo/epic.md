---
name: english-repo
status: in-progress
created: 2026-11-15T16:40:00Z
updated: 2026-11-15T19:50:30Z
progress: 0%
prd: .claude/prds/english-repo.md
github: (will be set on sync)
---

# Epic: english-repo

## Overview
Make the whole repository English: paths, file contents, identifiers, labels and generated documents, and remove
every instruction to use German. Sound and controller layout stay bit-for-bit the same; existing equivalence and set
checks prove it.

## Architecture Decisions
- **Rename first, translate second.** One task does all `git mv` renames and reference fixes up front, so later
  translation tasks work on final paths and never conflict on moves.
- **Fixed glossary.** A short `docs/glossary.md` (German → English) is written in the rename task and used by every
  translation task, so one concept gets one English name (`Harmonie` → harmony, `Einwurf` → stab/throw, `LC groß` →
  `LC big`, `Bläser` → brass, `Streicher` → strings).
- **Regenerate, never hand-edit.** PDFs, `.syx`, single files and the set are rebuilt by their generators after the
  sources are translated.
- **Proof by existing tools.** `/strudel-optimize` (event-by-event equivalence), `npm run set` + `check-set.mjs`,
  `check-sounds.mjs`, plus a German-word scan script that becomes the final acceptance check.
- **External names untouched.** Sample/bank/soundfont names and quoted external titles are whitelisted in the scan.

## Technical Approach
### Frontend Components
- Strudel tracks and boards: translate comments and German identifiers. Live-track labels are already English
  (`@ctl` texts, `▣ LC big`, status box); only a few German comment lines remain there. Covers live tracks, frozen
  set sources (`sets/011-combining-all/sources/`), `lab/` boards and `lab/archive/`, `snippets/`,
  `midi-layouts/templates/`.
- `tools/trajectory/player.html`, `docs/casio-gp310-midi.html`: translate visible text.

### Backend Services
- Node tools (`tools/lcxl-layout`, `tools/set`, `tools/strudel-sim`, `tools/stem-lab`, `tools/phrase-cut`,
  `tools/trajectory`): update hardcoded German paths, translate messages, comments and READMEs.
- `tools/set/make-set.mjs` and `set-frame.strudel`: update paths to frozen sources, rebuild set.

### Infrastructure
- `CLAUDE.md`, `VISION.md`, `TECH-STACK.md`, `TODO.md`, `.claude/skills/*`: remove German-chat rule, translate,
  update paths.
- Project memory (`~/.claude/projects/.../memory/`): remove any German-language rule.
- New `tools/lang-scan.mjs` (or shell script): scans tracked text files for umlauts/ß, a German stop-word list and old
  path names, with a whitelist file; exits non-zero on hits.

## Implementation Strategy
1. Branch `epic/english-repo` from a clean `main`.
2. Foundation (serial): glossary + scan script + all renames with reference fixes. Verify `npm run set` and a
   simulator run still pass after renames.
3. Translation (parallel, disjoint folders): tracks, lab boards, tools, docs/meta/skills.
4. Regeneration + verification (serial): rebuild all derived files, run equivalence, set and sound checks, scan = 0.

## Task Breakdown Preview
1. **Glossary, scan script, rename German paths** — `git mv` all German paths, fix every reference, write
   `docs/glossary.md` and the scan script. Serial, blocks all others.
2. **Translate rules, docs and skills** — `CLAUDE.md` (drop German-chat rule), `VISION.md`, `TECH-STACK.md`, `TODO.md`,
   `docs/`, `midi-layouts/`, `.claude/skills/`, project memory. Parallel.
3. **Translate live tracks** — `tracks/**` current files (007, 008, 009, 010, `historic/`), their notes and
   feedback; prove each live track with `/strudel-optimize`. Small for the `.strudel` files (labels already
   English), larger for German `feedback.md` notes. Parallel.
4. **Translate set 011 sources** — `sets/011-combining-all/sources/` and `tools/set/set-frame.strudel`; rerun
   `npm run set`. Parallel with 3 (disjoint files), conflicts only on set rebuild → run set last.
5. **Translate lab boards** — `lab/**` incl. `lab/archive/` (delete the tracked `lab/*/old/` folders first, per the
   no-`old/` rule; ask before deleting), `lab/tutorials/*.typ` handbooks, board feedback, layout
   `.typ` sheets. Parallel.
6. **Translate tools, snippets, samples notes** — `tools/**` (non-generated, incl. `tools/trajectory/player.html`),
   `snippets/`, `samples/**/README.md`. Parallel.
7. **Regenerate and verify** — rebuild layout PDFs/`.syx`, single files, tutorial and skills PDFs, set; run
   `check-set.mjs`, `check-sounds.mjs`, `/strudel-optimize` on live tracks, scan = 0. Depends on 2–6.

## Dependencies
- Clean `main`.
- Other epics: `drop-buildup`, `launchkey-knob-target`, `player-hub` edit the same tracks, tools and paths. Run this
  epic alone, before or after them, never in parallel.
- Typst, Node tools installed (`npm install` in `tools/`).
- Task 1 blocks 2–6; 2–6 block 7.

## Success Criteria (Technical)
- Scan script exits 0 over all tracked text files (whitelist only for external names).
- No German path segment in `git ls-files`.
- `/strudel-optimize` equivalent for 007, 008, 009, 010 (before vs after).
- `npm run set` builds, `check-set.mjs` passes; `check-sounds.mjs` adds no broken sound.
- All derived files regenerated from translated sources; no German in `.syx` control names.
- No instruction to use German in `CLAUDE.md`, skills or memory.

## Estimated Effort
- 7 tasks; task 1 ~2 h, tasks 2–6 ~1–3 h each in parallel (task 5 largest: many boards and two handbooks), task 7
  ~1–2 h (PDF and simulator runs, one heavy job at a time). Total ~1–1.5 days of agent time.

## Tasks Created
- [ ] 001.md - Glossary, scan script, rename German paths (parallel: false)
- [ ] 002.md - Translate rules, docs and skills (parallel: true)
- [ ] 003.md - Translate live tracks and their notes (parallel: true)
- [ ] 004.md - Translate set 011 sources and frame (parallel: true)
- [ ] 005.md - Translate lab boards and handbooks (parallel: true)
- [ ] 006.md - Translate tools, snippets and sample notes (parallel: true)
- [ ] 007.md - Regenerate and verify (parallel: false)

Total tasks: 7
Parallel tasks: 5
Sequential tasks: 2
Estimated total effort: 12 hours
