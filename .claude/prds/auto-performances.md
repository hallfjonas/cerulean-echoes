---
name: auto-performances
description: One well-done auto-performance per live track (007-010), designed with the user in two feedback loops, then turned into a skill
status: backlog
created: 2026-11-16T16:13:34Z
---

# PRD: auto-performances

## Executive Summary

Auto-perform (`tools/trajectory/autoperform.mjs`, scripts in `tools/trajectory/perform/<track>/*.json`) can play any
live track without hardware. Today each track only has `every-button.json` (a test sweep) and 010 has `spike-run.json`
(a first sketch). This epic produces one musical, well-done performance per track — 007 ambient, 008 groove techno,
009 house, 010 ambient house — that plays like a real live slot. The agent first proposes a design per track (arc,
sections, meta info), the user approves it (loop 1), the agent writes the script, the user listens and gives feedback
(loop 2). What we learn becomes a project skill, so the next performance follows the same path without re-learning it.

## Problem Statement

- No track has a performance that shows what it can do. `every-button.json` tests controls, it does not make music;
  `spike-run.json` was written without a design or review.
- Scripts are bare step lists: no title, no sections, no intent. Feedback like "the second build comes too early" has
  nothing to point at, and the player cannot show where in the arc it is.
- Launchkey keys, drum pads and knobs cannot be scripted, so half of what a live player does is missing.
- There is no agreed process for designing a performance, so every attempt starts from zero.

## User Stories

**US1 — Review a design before any script exists.** As the user, I read a short design per track (length, mood,
sections with bar ranges, which controls move in each, why it fits the genre) and approve or correct it.
- Acceptance: each track has `perform/<track>/<name>.md` with the meta info and a section table; nothing is scripted
  until the user has said "approved" for that design; every round of comments is logged in `perform/<track>/feedback.md`.

**US2 — Listen and give feedback by section.** As the user, I start the performance in the player, see which section
is playing, and give feedback like "Break 1, bar 48: too long".
- Acceptance: the player shows the script's title and the current section name while it plays; feedback rounds are
  logged in `feedback.md` with what changed; the loop ends when the user approves the performance.

**US3 — Performances use the Launchkey too.** As the user, I hear keys, drum pads and Launchkey knobs in a performance
where the design calls for them.
- Acceptance: a script can play keys (notes / chords), pads (drum C1 … = note 36 …) and LK knobs CC 31-38 / mod wheel
  CC 1; the track hears them as it hears the real Launchkey; `check-perform` validates them.

**US4 — Do it again without re-learning.** As the user (or a later agent), I run one skill to design, script and
review a new performance for any live track.
- Acceptance: a project skill in `.claude/skills/` describes the two loops, the design template, the script format and
  the checks, with the lessons from the four performances; a dry run on one track follows it end to end.

## Functional Requirements

1. **Script meta info** (optional fields, old scripts stay valid): `title`, `bars` (length), `mood` (one line),
   `sections: [{ name, from, to, intent }]` (bars). `check-perform` checks sections are ordered, inside the script and
   cover its steps.
2. **Launchkey steps:** `{ bar, keys, velocity?, length? }` (mini-notation note names, e.g. `'c3 e3 g3'` = chord),
   `{ bar, pad }` (note number 36-51), `{ bar, lk, value, ramp? }` (CC 1, 31-38). Fed through a virtual Launchkey port
   in `midi.mjs`, beside `LCXL3 Auto`, so `midikeys()` and the LK knobs read it.
3. **Player display:** the drawer and the top bar show title and current section (name, bars left) while a script
   plays.
4. **Node path:** `npm run scenario -- <track> --script <file>` plays Launchkey steps too, so levels per section can be
   measured without a browser.
5. **Design doc** per performance, `perform/<track>/<name>.md`, from one template: meta (title, length in bars and
   minutes at the track's BPM, mood, story in two lines, reference tracks from `docs/references.md`), section table
   (name, bars, controls that move, Launchkey use, intent), risks (CPU peaks, clipping, silent stretches).
6. **Feedback log** per track, `perform/<track>/feedback.md`: rounds of loop 1 (design) and loop 2 (sound), each with
   the user's words, what changed, and the decision.
7. **Four performances**, one per live track; length chosen per track in its design and approved by the user.
8. **Skill** `auto-perform` (project skill) written after the four are approved.

## Non-Functional Requirements

- Every performance passes `npm run verify` (includes `check-perform`), sounds load (`check-sounds`), no section clips
  or goes unintentionally silent (`npm run audibility` / scenario per section).
- CPU: the performance plays in the player on the M2 Air without dropouts at its densest section.
- Labels stay English and short (CLAUDE.md "Labels"); section names are one or two words.
- `every-button.json` stays; existing scripts keep working unchanged.

## Success Criteria

- 4 of 4 designs approved by the user in loop 1 (logged in `feedback.md`).
- 4 of 4 performances approved by the user in loop 2 (logged in `feedback.md`).
- 0 `check-perform` errors; 0 CLIPS and no unplanned SILENT section in the measured run of each performance.
- The skill exists and a dry run of it on one track reaches a design proposal without the agent asking how the process
  works.

## Constraints & Assumptions

- Open loop: scripts do not listen to the sound; a performance is fixed in bars.
- One heavy job at a time on the M2 Air: render and measure one track at a time.
- The user reviews by listening in the player (`node trajectory/server.mjs`, localhost:8766); the agent cannot hear,
  so its own checks are the measured levels, event counts and the LC view (`--view`).
- `midikeys` has no note-off (fixed note length): scripted keys get a length per step, not a release.
- Pilot first: 010 (has `spike-run.json` to start from) goes through both loops before the other three, so the
  template and format are corrected once, not four times.

## Out of Scope

- Closed-loop or generative performances (scripts reacting to audio, randomness per run).
- Changing the tracks' sound, controls or layout to suit a performance (raise it as feedback instead; CLAUDE.md asks
  before changing sound).
- Set 011 and lab boards.
- Recording or exporting audio/video of the performances.

## Dependencies

- Player hub and auto-perform (merged, PR #24).
- `tools/strudel-sim/scenario.mjs` (`--script`), `npm run audibility`, `check-perform.mjs`.
- `docs/references.md` for reference tracks per genre.
- The user's time for both review loops on four tracks.
