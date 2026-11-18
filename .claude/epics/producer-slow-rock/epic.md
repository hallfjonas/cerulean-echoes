---
name: producer-slow-rock
status: backlog
created: 2026-11-18T12:00:00Z
updated: 2026-11-18T12:00:00Z
progress: 0%
prd: .claude/prds/producer-slow-rock.md
design: .claude/epics/producer-slow-rock/design.md
github: (will be set on sync)
---

# Epic: producer-slow-rock

## Overview

Build 015 Slow Rock (`tracks/rock/015-slow-rock/gp-slow-rock.mid`) with the producer, as 012 and 013 were built.
The PRD (`.claude/prds/producer-slow-rock.md`) lists the hard cases the producer does not handle yet: pickup bar,
tempo change, triplets, markers, clean/overdrive switches, rock voices. The draft song design is in
`design.md`; it waits for the user's answers to its open questions and for "approved".

## Gates

1. **Song design** (`design.md`): approved by the user in chat, quoted in the track's `feedback.md`. Nothing is built before.
2. **Performance** (script v2 from the approved design): approved the same way.

## Tasks

| # | Task | Done when |
|---|---|---|
| 001 | Reader: time signature changes, pickup bar as bar 0, tempo map, triplet grid | `node --test producer/*.test.mjs` covers each with a small MIDI fixture |
| 002 | Markers: drop trailing `:`, number repeated names (Refrain 1, Refrain 2) | fixture test passes; Slow Rock markers read as 8 named sections |
| 003 | Rock voices: Strat guitar samples with crunch, acoustic-style kit, taiko, bass, vocal synth; program 26 → 29 switch | `check-sounds` passes for 015; sounds recorded in `samples/sounds.json` |
| 004 | Gate 1: user answers design questions 1-4 and approves | `Decision: approved` line exists in the track's `feedback.md` |
| 005 | Map `015-slow-rock-map.json` and generate `015-slow-rock.strudel` with `npm run producer` | `npm run verify -- 015-slow-rock` passes; notes match the MIDI event by event |
| 006 | Gate 2: performance script from the approved design, listened to in the player | Loop 2 `Decision: approved` in `feedback.md` |
| 007 | Acceptance: audibility 0 CLIPS, 0 unplanned SILENT; CPU on the M2 Air; 012 and 013 regenerate unchanged | PRD success criteria met |

## Notes

- Track number 015 is taken from `main` (the PRD and the MIDI folder). The draft design used 012, which is the EDM
  snippet on `main`.
- Epic and PRD come off `main` once this is merged (CLAUDE.md, "CCPM epics and PRDs").
