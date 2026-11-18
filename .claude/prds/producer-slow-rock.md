---
name: producer-slow-rock
description: Teach the producer the hard cases of the Slow Rock song (pickup, tempo change, triplets, named markers, clean / overdrive switches) and build 015 Slow Rock with it
status: backlog
created: 2026-11-18T12:00:00Z
---

# PRD: producer-slow-rock

## Executive Summary

The producer (`tools/producer/`, skill `/producer`) turns a Guitar Pro MIDI export into a live track with a
performance; it built 012 EDM Snippet (pilot) and 013 A Hope for Niklas. The third song, Slow Rock
(`tracks/rock/015-slow-rock/gp-slow-rock.mid`), was left out of that epic because it breaks the producer's
assumptions: a pickup bar, a tempo change, triplets, markers with names, guitars switching sound. This PRD makes the
producer handle them and builds 015 Slow Rock through the same two user gates.

## Problem Statement

Measured with `node producer/midi-read.mjs ../tracks/rock/015-slow-rock/gp-slow-rock.mid` (2026-11-18; bar numbers as
the reader counts them today, the pickup counted as bar 1):

| Case | What the file has | What the producer does today |
|---|---|---|
| Pickup | a 1/4 bar before bar 1 (time signature 1/4, then 4/4) | counts it as a 4/4 bar with a warning: every bar after it is shifted by three beats, 126 bars instead of 125 |
| Tempo change | 100 BPM, 115 BPM from bar 100 | uses the first tempo with a warning: the last 26 bars play too slow; Strudel has one tempo per track |
| Triplets | Spur 1, 2, 4 and 6: "grid finer than 1/1024 (triplets?)" | stops: "no power-of-two grid up to 1/1024 fits" (dry run 2026-11-18) |
| Markers | 8, with a trailing `:` ('Intro:', 'Vers 1:', 'Refrain:' …), 'Refrain:' twice | section names taken from the text as is: the colon stays and two sections share a name |
| Clean / overdrive | guitars switch program 26 (jazz / clean) → 29 (overdrive) at bars 104 and 108 | a voice change per entry works (013 Spur 2), but there is no rock voice library |
| Genre | `rock` | no rock voices, Mode 2 extras or pads: falls back to the EDM ones |
| Size | 7 parts incl. a vocal line ('Gesang', 222 notes), 125 bars, ~5,250 notes (drums 1,528, three exact duplicates) | densest song yet: CPU on the M2 Air untested |

Open from 013 (`tracks/classical/013-hope-for-niklas/feedback.md`, "For the converter"): chapters that restart at
their first bar (a song with a repeated Refrain wants them), `audibility --from <bar>` for mid-song levels, the
first-pass script setting (not ramping) parts that start at bar 0.

## User Stories

**US1 — Slow Rock plays as written.** As the user, I load 015 in the player and hear the song from its pickup, with
the tempo change at bar 100, triplets in time, guitars switching to overdrive where the song does.
- Acceptance: one-file track from `npm run producer`; `npm run verify` and `check-sounds` pass; every part's notes
  match the MIDI (onsets and pitches, triplets included) at the right times in seconds.

**US2 — Design and performance approved.** As the user, I approve a song design and a performance as for 012 and 013.
- Acceptance: both approvals quoted in the two `feedback.md` files.

**US3 — The next rock song is one command.** As the user, I export another rock song and get a playable first pass.
- Acceptance: the producer's tests cover pickup, tempo change and triplets with small MIDI fixtures; 012 and 013 still
  regenerate as before (`node --test producer/*.test.mjs`).

## Functional Requirements

1. **Reader:** time signature changes and a pickup bar; bars counted from the first full bar (song bar 1), the pickup
   as bar 0. Tempo map in bars. Triplets: a grid that fits thirds (e.g. 1/12, 1/24, 1/48 of a bar).
2. **Pickup:** the pickup plays before song bar 1 (cycle 0 = pickup bar, or song bar 1 = cycle 0 and the pickup as the
   end of the last bar on repeat); decided in the design with the user, and the performance's bar 0 follows it.
3. **Tempo change:** one tempo per track, so either the parts after bar 100 are time-scaled into cycles at the first
   tempo (bars stay cycles, notes speed up), or the track switches `setcps` with a chapter; decided in the design.
4. **Markers:** names cleaned (trailing `:` dropped), repeated names numbered ('Refrain 1', 'Refrain 2').
5. **Rock voices:** clean and overdriven guitar, bass, rock kit, a voice for the vocal line, from the project's
   synths and banks (no gm_* soundfonts); a program change 26 → 29 switches clean → overdrive at that bar; Mode 2
   extras and pads for rock.
6. **Restart chapters:** a map option so a chapter starts at its first bar instead of keeping the song's place.

## Non-Functional Requirements

- No drop-outs in the player on the M2 Air (~5,250 notes, 7 parts); gate silent stems (CLAUDE.md "Writing efficient
  Strudel").
- Plays pasted into strudel.cc; sounds load.
- Generated track stays readable: patterns per section.

## Success Criteria

- 015 Slow Rock in the player catalogue with an approved performance; verify clean, audibility 0 CLIPS, 0 unplanned
  SILENT.
- Producer tests for pickup, tempo change and triplets; 012 / 013 unchanged.

## Constraints & Assumptions

- Builds on the merged producer mode (epic `producer-mode-guitar-pro`, removed; see git history): map format, `--perform`, the `/producer` skill.
- Ask before sound, naming or layout choices beyond the approved design (CLAUDE.md rules).

## Out of Scope

- Reading `.gp5` / MusicXML directly.
- Lyrics, bends as pitch curves (plain notes).
- Adding 015 to the set (011).
- Gradual tempo changes (accelerando).

## Dependencies

- Producer epic merged (tools/producer, 012, 013).
- User time for two gates (song design, performance).
