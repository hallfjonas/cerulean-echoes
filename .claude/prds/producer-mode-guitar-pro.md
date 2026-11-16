---
name: producer-mode-guitar-pro
description: Turn Guitar Pro songs (exported as MIDI) into live tracks with an auto-performance — one by hand first, then a converter tool built from that, applied to the other two
status: backlog
created: 2026-11-16T16:21:01Z
---

# PRD: producer-mode-guitar-pro

## Executive Summary

The user writes songs in Guitar Pro. Producer mode turns such a song into a live track of this project: a one-file
Strudel track with the LC XL 3 layout (every controller optional) whose stems play the song's parts note for note,
re-voiced with the project's own synths, plus an auto-perform script that plays it through in the player. Three songs
are exported as MIDI: `GP Slow Rock.mid`, `GP Classical.mid` ('A Hope for Niklas'), `GP EDM Snippet.mid`.
The first is built by hand with the user's feedback; what that teaches becomes a converter tool (MIDI → track +
performance); the tool then builds the other two, and the user's feedback on those shapes the tool further.

## Problem Statement

- Songs written in Guitar Pro cannot be played live with the controllers: today every track is composed in Strudel
  from scratch.
- A Guitar Pro song is a fixed form (intro, verse, chorus …) with many parts; the live tracks are loop-based. There is
  no agreed way to map a song's parts and sections onto columns, Chapter and the performance arc.
- 1,600-plus notes per song cannot be typed into mini-notation by hand; a tool must read MIDI.

## Source material

| File | Tempo | Bars | Parts (MIDI program) | Sections |
|---|---|---|---|---|
| `GP Slow Rock.mid` | 100 | ~124 (1/4 pickup, then 4/4) | 3 guitars (26/29), bass (33), drums, 116 (taiko-like), 'Gesang' vocal line (26) | markers: Intro, Vers 1, Refrain, Zwischenspiel, Vers 2, … (12) |
| `GP Classical.mid` | 110 | ~55 | 8 parts (0, 42/35/40/43, 40, 45, 14, 116, 61, 49/55), percussion | two empty text markers (bars 31, 47) |
| `GP EDM Snippet.mid` | 120 | 24 | 2 lead/rhythm (30), drums (kick only), 38 (synth bass), 120 (FX), 34 (bass), 29 | none |

Several Guitar Pro tracks use two MIDI channels (string effects / let-ring); the reader must merge them per track.

## User Stories

**US1 — Design before build.** As the user, I read a short design for a song (which part goes to which column and
voice, sections and what Chapter does, the performance arc) and approve or correct it.
- Acceptance: `<track>-design.md` beside the track; nothing is built before "approved" is logged in the track's
  `feedback.md`.

**US2 — Play a Guitar Pro song live.** As the user, I load the track in the player or strudel.cc, and with all knobs at 0
it plays the song as written, re-voiced; faders, rows and buttons shape it like in 007-010.
- Acceptance: one-file track tagged `// @mode 16 Mode 1`, layout after `midi-layouts/templates/dual-lc.strudel`, same
  row meanings and labels as 007-010; `npm run verify` passes; `npm run audibility` shows no SILENT / CLIPS stem.

**US3 — Watch it perform itself.** As the user, I press Auto-perform in the player and hear the song played through
with a musical arc, and can give feedback by section.
- Acceptance: a perform script in `tools/trajectory/perform/<track>/` (script v2: title, sections from the song's
  markers); `check-perform` passes; the user's approval is logged in `feedback.md`.

**US4 — Next song in minutes.** As the user, I export a new Guitar Pro song as MIDI, run one command, and get a first
playable track and performance that I then refine.
- Acceptance: `npm run producer -- <file.mid> [--map <map.json>]` writes the track, design stub and perform script;
  run on the pilot's MIDI it reproduces the hand-built pilot closely (same notes per stem, `npm run compare`); the
  other two songs come out of it and pass verify before any hand polish.

## Functional Requirements

1. **MIDI reader** (no new dependency, or one small one): tempo, time signatures (incl. pickup bars), markers, tracks
   with name, programs, channels (merged per track), notes (start, length, pitch, velocity) in bars.
2. **Verbatim parts:** each stem plays its part's notes as written; the song's position follows the cycle count from
   evaluation start and loops at the end. The performance starts at bar 1.
3. **Re-voicing:** each part gets a genre-fit voice from the project's synths and banks (not gm_* soundfonts); drums
   map GM drum notes to the project's drum sounds.
4. **Controls:** columns 1-7 = parts (grouped when a song has more than 7), column 8 global (Fog / Thin / Tension /
   Master / Chapter / Break); `@ctl` texts and labels per CLAUDE.md. What Chapter does in a song form is decided in the
   pilot design.
5. **Performance:** script v2 with the song's sections; moves controls to make an arc over the song.
6. **Converter:** MIDI + optional mapping file (part → column, voice, sections, chapter meaning) → track, design stub,
   perform script. The mapping file holds every decision the user made, so a re-run keeps them.
7. **Sources kept:** each `.mid` lives beside its track (`tracks/<genre>/NNN-<name>/`).

## Non-Functional Requirements

- CPU: a 124-bar song with ~5,000 notes must not drop out in the player on the M2 Air; gate silent stems as in
  CLAUDE.md "Writing efficient Strudel".
- Tracks play pasted into strudel.cc without the player; sounds load (`check-sounds`).
- Generated tracks are readable and hand-editable (patterns per section, not one huge string).

## Success Criteria

- Three new live tracks (012 Slow Rock, 013 Classical, 014 EDM) in the player catalogue, each with an approved
  performance.
- `npm run verify -- <track>` passes for all three; audibility: 0 CLIPS, 0 unplanned SILENT.
- Converter re-run on the pilot MIDI: every stem's notes match the hand-built 012 (`npm run compare --stem`).
- 013 and 014 come from the converter; hand polish after it is logged in `feedback.md` and fed back into the tool or
  the mapping file.

## Constraints & Assumptions

- Builds on the auto-performances epic, task 001 (script v2: title, sections, Launchkey steps). Pilot performance waits
  for it.
- Pilot = Slow Rock: it has section markers, a pickup bar and two-channel tracks, so the tool learns the hard cases
  first. Swap to EDM Snippet if a quicker first loop is preferred.
- Track numbers 012-014; genre folders `tracks/rock/`, `tracks/classical/`, `tracks/edm/` (the catalogue picks up any
  genre folder).
- Ask before sound, effects, orbits, naming or layout choices beyond the approved design (CLAUDE.md rules).

## Out of Scope

- Reading `.gp5` / MusicXML directly.
- Adding these tracks to the set (011).
- Tempo changes within a song (all three are constant tempo); odd meters beyond the pickup bar.
- Lyrics, tab fingering, bends as pitch curves (bends become plain notes).

## Dependencies

- auto-performances epic task 001 (script format v2) merged.
- Player hub / auto-perform (merged, PR #24).
- User time for the review gates: design + listening per track (6 gates), plus converter review.
