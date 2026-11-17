---
name: producer-mode-guitar-pro
description: Turn Guitar Pro songs (exported as MIDI) into live tracks with an auto-performance — EDM Snippet by hand first, then a converter tool built from that, applied to Classical
status: backlog
created: 2026-11-16T16:21:01Z
---

# PRD: producer-mode-guitar-pro

## Executive Summary

The user writes songs in Guitar Pro. Producer mode turns such a song into a live track of this project: a one-file
Strudel track with the LC XL 3 layout (every controller optional) whose stems play the song's parts note for note,
re-voiced with the project's own synths, plus an auto-perform script that plays it through in the player.
Simple songs first: the pilot is `GP EDM Snippet.mid` (24 bars, 7 parts, constant tempo, no pickup), built by hand
with the user's feedback; what that teaches becomes a converter tool (MIDI → track + performance); the tool then
builds `GP Classical.mid` ('A Hope for Niklas'), and the user's feedback on it shapes the tool further.
`GP Slow Rock.mid` waits for a follow-up epic (see Out of Scope).

## Problem Statement

- Songs written in Guitar Pro cannot be played live with the controllers: today every track is composed in Strudel
  from scratch.
- A Guitar Pro song is a fixed form with many parts; the live tracks are loop-based. There is no agreed way to map a
  song's parts and sections onto columns, Chapter and the performance arc.
- Hundreds to thousands of notes per song cannot be typed into mini-notation by hand; a tool must read MIDI.

## Source material

Measured from the files (format 1, 480 ticks per quarter, 4/4 throughout, constant tempo, no pickup, no triplets).
Program numbers are the MIDI bytes (0-based GM).

| File | Tempo | Bars | Parts (program, notes) | Markers |
|---|---|---|---|---|
| `GP EDM Snippet.mid` | 120 | 24 | Spur 1 (30, 198), Spur 2 (30, 140), drums (kick 36 only, 522, 64th rolls), Spur 4 (38, 13), Spur 5 (120, 64, 64th grid), Spur 6 (34, 58), Spur 7 (29, 139) | none |
| `GP Classical.mid` | 110 | 55 | Spur 1 (0, 800), Spur 2 (42 → 35 at bar 13 → 40 at 31 → 43 at 47, 296), Spur 3 (40, 430), Spur 4 (45, 484), Spur 5 (14, 204), Spur 6 (116, 1346), Spur 7 (61, 360), Spur 8 (49 → 55 at bar 56, 416), percussion (kick 35, crashes 49 / 57, 158) | 3 empty text markers: bars 1, 31, 47 |

- Most Guitar Pro tracks carry two MIDI channels (string effects / let-ring); the reader merges them per track.
- A part can change program mid-song (Classical Spur 2 and Spur 8); the reader reports each change with its bar, so a
  part can change voice by section.

## User Stories

**US1 — Design before build.** As the user, I read a short design for a song (which part goes to which column and
voice, sections and what Chapter does) and approve or correct it.
- Acceptance: `<track>-design.md` beside the track; nothing is built before "approved" is logged in the track's
  `feedback.md`.

**US2 — Play a Guitar Pro song live.** As the user, I load the track in the player or strudel.cc, and with all knobs at 0
it plays the song as written, re-voiced; faders, rows and buttons shape it like in 007-010.
- Acceptance: one-file track tagged `// @mode 16 Mode 1`, layout after `midi-layouts/templates/dual-lc.strudel`, same
  row meanings and labels as 007-010; `npm run verify` passes; `npm run audibility` shows no SILENT / CLIPS stem.

**US3 — Watch it perform itself.** As the user, I press Auto-perform in the player and hear the song played through
from its first bar with a musical arc, and can give feedback by section.
- Acceptance: a perform script in `tools/trajectory/perform/<track>/` (script v2: title, bars, mood, sections) with
  its design and feedback after `tools/trajectory/perform/design-template.md`; `check-perform` passes; the script's
  bar 0 is the song's bar 1; the user's approval is logged in `perform/<track>/feedback.md`.

**US4 — Next song in minutes.** As the user, I export a new Guitar Pro song as MIDI, run one command, and get a first
playable track and performance that I then refine.
- Acceptance: `npm run producer -- <file.mid> [--map <map.json>]` writes the track, design stub and perform script;
  run on the pilot's MIDI it reproduces the hand-built pilot closely (same notes per stem, `npm run compare`); the
  Classical song comes out of it and passes verify before any hand polish.

## Functional Requirements

1. **MIDI reader** (no new dependency, or one small one): tempo, time signatures, markers, tracks with name, program
   changes with their bar, channels (merged per track), notes (start, length, pitch, velocity) in bars.
2. **Verbatim parts:** each stem plays its part's notes as written and loops at song end. Song bar 1 is the cycle the
   track starts on in the player, and the cycle an auto-performance starts on (see FR 5).
3. **Re-voicing:** each part gets a genre-fit voice from the project's synths and banks (not gm_* soundfonts); a
   program change becomes a voice change at that bar; drums map GM drum notes to the project's drum sounds.
4. **Controls:** columns 1-7 = parts (grouped when a song has more than 7), column 8 global (Fog / Thin / Tension /
   Master / Chapter / Break); `@ctl` texts and labels per CLAUDE.md. What Pattern and Chapter do in a song that plays
   verbatim is decided in the pilot design. Launchkey knobs CC 31-38 keep their meaning from 007-010; the design only
   picks the sounds for keys and pads.
5. **Performance:** script v2 with sections; sections come from markers, or from the design when a song has none
   (EDM). Starting a performance starts the song at bar 1, wherever the player was.
6. **Converter:** MIDI + optional mapping file (part → column, voice per program, sections, chapter meaning) → track,
   design stub, perform script. The mapping file holds every decision the user made, so a re-run keeps them.
7. **Sources kept:** each `.mid` lives beside its track (`tracks/<genre>/NNN-<name>/`).

## Non-Functional Requirements

- CPU: Classical (55 bars, ~4,500 notes, 9 parts) must not drop out in the player on the M2 Air; gate silent stems as
  in CLAUDE.md "Writing efficient Strudel".
- Tracks play pasted into strudel.cc without the player; sounds load (`check-sounds`).
- Generated tracks are readable and hand-editable (patterns per section, not one huge string).

## Success Criteria

- Two new live tracks (012 EDM Snippet, 013 Classical) in the player catalogue, each with an approved performance.
- `npm run verify -- <track>` passes for both; audibility: 0 CLIPS, 0 unplanned SILENT.
- Converter re-run on the pilot MIDI: every stem's notes match the hand-built 012 (`npm run compare --stem`).
- 013 comes from the converter; hand polish after it is logged in `feedback.md` and fed back into the tool or the
  mapping file.

## Constraints & Assumptions

- Script v2 (title, bars, mood, sections) is merged with the auto-performances epic (PR 26); `check-perform` checks it.
- Pilot = EDM Snippet: shortest, 7 parts for 7 columns, one kick drum, no markers. It teaches the layout, voicing,
  looping and performance; Classical then adds markers, part grouping and program changes to the converter.
- Track numbers 012-013; genre folders `tracks/edm/`, `tracks/classical/` (the catalogue picks up any genre folder).
- Ask before sound, effects, orbits, naming or layout choices beyond the approved design (CLAUDE.md rules).

## Out of Scope

- **Slow Rock** (`GP Slow Rock.mid`): a follow-up epic. Known hard cases, measured: a 1/4 pickup bar (song bar 1 then
  needs three beats of rest before it in cycle 0), a tempo change 100 → 115 BPM at bar 100 (Strudel has one tempo per
  track), 8 markers with trailing `:` and "Refrain" twice, guitars switching clean / overdrive (26 / 29), 7 parts,
  125 bars, ~5,250 notes.
- Reading `.gp5` / MusicXML directly.
- Adding these tracks to the set (011).
- Tempo changes, pickup bars, odd meters (none in EDM or Classical).
- Lyrics, tab fingering, bends as pitch curves (bends become plain notes).

## Dependencies

- Player hub / auto-perform (merged, PR 24) and script v2 (merged, PR 26).
- User time for the review gates: design + listening per track (4 gates), plus converter review.
