---
name: sound-lab
description: Stems as files (JSON), tracks as stem assignments, and a sound lab in the player (Sample Designer, Stem Designer, stem swap)
status: backlog
created: 2026-11-20T18:11:25Z
---

# PRD: sound-lab

## Executive Summary

Today a live track is one long code file: its 14 columns, patterns and add-ons are written into it and cannot be
reused, compared or swapped. This project introduces the **stem** as a file: one fully set-up LC XL 3 column (sound,
patterns, three knobs, fader, two buttons) in a JSON format, kept in a stem library with versions and metadata. A
**track** becomes an assignment of stems to the LC columns, a **set** a collection of tracks. On top, the player gets a
**sound lab** with two designers, each driven from the LCs and from Claude skills:

- **Sample Designer**: build a new sound from one or more sources with filters, patterns and add-ons on the whole LC,
  save it as a project file, export it as a library sound (and a WAV).
- **Stem Designer**: the 14 stem columns of the LCs (7 per mode, column 8 global) hold 14 versions of a stem to
  compare side by side; save the winner into the library.

And a **stem swap** in the player: click a column, pick a stem from the library, it plays.

Engine: SuperCollider (SC), in line with the `sc-migration` epic. This epic takes over sc-migration task 009 (the SC
lab: machine lab, options lab, promote); 009 keeps only the archive of the Strudel lab boards. Background and earlier
ideas: `sc/PLAN-STEM-LIBRARY.md`, `sc/sounds/README.md`.

## Problem Statement

- A column cannot leave its track. A good flute line in 009 cannot be tried in 010 without copying code.
- Trying an alternative ("the flute is too repetitive") means editing a 1,300-line track by hand or by Claude, then
  listening to one candidate at a time. There is no side-by-side comparison of candidates in the running track.
- Similar columns (same sound, one knob different) exist as unrelated code; nothing says they are related.
- Lab boards (Strudel, `lab/`) are one-off files with no shared format; winners are copied into tracks by hand.
- There is no way to design a new sound on the controller and keep it as a reusable library sound.

## Definitions (preliminary)

- **Sample**: a playable sound in the library (`sc/sounds/<name>.scd`): a synth or an audio file with named
  parameters. The Sample Designer makes new ones. (In the repo today these are called "sounds"; "sample" is the
  user's word for the same thing.)
- **Stem**: one fixed, fully set-up LC XL 3 column: a sample, its patterns (button 1 = Pattern), three knobs (row 1
  Brightness, row 2 Space, row 3 named for what it does), the fader (Level) and button 2 (an add-on named for what it
  does). A stem knows nothing about which column or track it sits in.
- **Stem version**: one concrete file of a stem. All versions of a stem share its sample; they differ in patterns,
  ranges or which knob 3 / button 2 they carry. A version names its parent version.
- **Track** (preliminary): a unique assignment of stem versions to the LC slots (Mode 1 and Mode 2, columns 1-7),
  plus the track-wide settings (tempo, harmony / chapters, the global column 8). Launchkey stays track-level for now.
- **Set** (preliminary): a unique, ordered collection of tracks played as one performance.

## User Stories

1. **As a player** I click a column in the player's MIDI panel, see the library stems that fit (same role), pick one
   and hear it in place of the old one.
   - Acceptance: on the 009 stem track, swapping the flute column for another lead stem plays the new stem from the
     next bar on; the other columns keep playing; the original track file is unchanged; "Save as" writes a new track
     file with the swap.
2. **As a sound designer** I say "the flute in the house track is boring and too repetitive, I want to explore a
   replacement", and Claude sets up a Stem Designer project with the current flute and several candidates on the
   LC columns, ready to play against the running house track.
   - Acceptance: `/stem-designer` with that sentence produces a project file with the current version in column 1 and
     at least 4 candidates; the project loads in the player, each column plays with 009's harmony and tempo.
3. **As a sound designer** I compare up to 14 stem versions on the two LC modes, keep the best one and promote it into
   the library as a new version of the stem.
   - Acceptance: promote writes a new `.stem` file whose name follows the naming rule and whose `parent` points to the
     version it came from; `check-stems` passes.
4. **As a sound designer** I build a new sound on the controller with a fixed setup (drum machine or synthesizer),
   save it, copy the project and change it, and export it.
   - Acceptance: a Sample Designer project saves to a file, "Save as" copies it; export writes a library sound that
     loads in a stem and a WAV render.
5. **As a sound designer** I ask Claude to arrange a free sound ("layer a felt piano with a soft noise breath, slow
   attack") and get a Sample Designer project file I can play, copy and change.
   - Acceptance: `/sample-designer` writes a project file that loads in the player and passes the project check.
6. **As a maintainer** I find stems by role, genre, energy, tags, and see which tracks use a stem.
   - Acceptance: `npm run stems` lists and filters the library and shows "used by" for each version.

## Functional Requirements

### Stems
1. Stem file format: JSON, one file per version, extension `.stem`, with a format version, a JSON schema and a
   validator (`check-stems`), documented for people in `docs/`.
2. Naming: `<sample-name>-<knob-1>-<knob-2>-<knob-3>-<btn1>-<btn2>.stem`, all lowercase kebab-case ASCII (e.g.
   `flute-brightness-space-complexity-pattern-echo-throw.stem`). A second version with the same name gets `-2`, `-3`.
   The validator checks that the name matches the file's sample and control labels.
3. Versions: all versions of a stem live in one folder per sample; each version records its `parent`.
4. Metadata (decided, see "Metadata decisions"): `role` (required, one of a fixed list), `genres` (from
   `docs/reference/genres.md`), `energy` (1-5), `tags` (free, moods go here), `harmony` (how it follows the chords),
   `about` (one line). Which tracks use a stem is computed, not stored.
5. A stem follows the stem contract: pitch relative to the global harmony, tempo and swing global, loudness normalised
   to a common target, fader = Level, all knobs at 0 sound good, reacts to the global column (Fog, Thin, Tension,
   Break).
6. Escape hatch: a stem may reference an SC code file next to it for behaviour JSON cannot express; the JSON still
   carries all labels and metadata.

### Tracks and sets
7. Stem track file (JSON): slots `1:1`-`1:7` (Mode 1) and `2:1`-`2:7` (Mode 2) → stem version, plus tempo, harmony /
   chapters and the global column. Loaded by SC; listed in the player's catalogue like any live track.
8. Pilot: 009-house is rebuilt as a stem track from 14 extracted stems, next to the current `009-house.scd` (which
   stays until the stem version is accepted), and proven to play the same.
9. Set file: preliminary definition only (documented, no tooling in this epic).

### Sound lab: Sample Designer
10. Two fixed setups on the full LC: drum machine and synthesizer, each after the machine-lab schema (columns =
    blocks in the signal path, rows = main / shape and time / fine and modulation, fader = block level, button 1 =
    block on/off, button 2 = block type), with an audition pattern.
11. Project file (JSON) for both fixed and free arrangements; Save, Save as (copy), Load in the player.
12. Export: a library sound `sc/sounds/<name>.scd` (parameters stay live) plus a WAV render in `samples/`.
13. Skill `/sample-designer`: Claude arranges a free sound (sources, blocks, control map) into a project file, or
    copies and changes an existing one.

### Sound lab: Stem Designer
14. Project file (JSON): up to 14 stem versions on the 14 stem columns (Mode 1 and Mode 2), optional context track
    (harmony, tempo, the other stems to play along), column 8 global (A/B with the context track's stem, promote).
15. Save, Save as (copy), Load in the player; promote a column into the library as a new stem version.
16. Skill `/stem-designer`: from a sentence ("re-design the piano stem of the house track") Claude finds the stem in
    the track, writes a project with the current version and candidates, and promotes the chosen one on request.

### Stem swap in the player
17. Click a column in the MIDI panel → list of library stems filtered by the column's role (filter by genre, energy,
    tags) → pick → the stem plays from the next bar; "Save as" writes a new track file.

## Metadata decisions

| Field | Decision | Why |
|---|---|---|
| Role | Yes, required, flat fixed list (kick, perc, hats, clap, sub, bass, keys, chords, pad, lead, texture, fx) | Decides which column a stem fits and what the swap list shows |
| Hierarchical categories | No | 40-60 stems expected; role + tags filter enough, a tree forces one parent per stem |
| Genres | Yes, list from `docs/reference/genres.md` | Same words as the genre guide; filter in swap and `npm run stems` |
| Energy | Yes, 1-5 | Sorting candidates for build-ups and sets |
| Moods | As tags, not a field | Free words, no fixed list worth keeping yet |
| Tags | Yes, free list | Everything else (airy, acid, 909, …) |
| Tracks | Not stored; computed from the track files | One source of truth; a stored list goes stale |
| Harmony | Yes (static, chords, scale, none) | Whether a stem fits a track's chapters |

## Non-Functional Requirements

- Runs on the M2 Air next to other apps: a 14-column Stem Designer project must play without dropouts.
- Non-destructive: designers and swap never overwrite a track, stem version or sample; new versions are new files.
- Every stem, sample project and stem project is plain JSON that Claude and people can read and diff.
- Labels follow the project rules (English, short, one name per job).
- Feature tests in `npm test` (format check, load, swap, save/copy, promote, export), loose checks only.

## Success Criteria

- 009-house plays as a stem track (14 stems) and passes the equivalence check against `009-house.scd`.
- The flute replacement story (user story 2) runs end to end: skill → project → listen → promote → swap into a copy of
  009 → save.
- One sound has gone Sample Designer → library sound → stem → track.
- `check-stems` passes for every file in the library; `npm run stems` lists them with "used by".
- sc-migration task 009 is reduced to the Strudel lab archive.

## Constraints & Assumptions

- SC is the engine (sc-migration task 002 done: the player plays SC tracks). Strudel tracks are not converted.
- The global column 8 (Fog, Thin, Tension, Master, Chapter, Break) and the harmony stay in the track / engine frame.
- Stems are column-agnostic; Mode 1 / Mode 2 placement is the track's choice.
- One person (or Claude) edits a stem at a time; no merge tooling.

## Out of Scope

- Converting tracks other than 009 to stems (later epic, one track at a time).
- Shared stems across tracks in practice (several tracks referencing one stem, update policy, freezing before a gig):
  long-term goal; this epic only makes it possible (stems are referenced by file name, tracks pin a version).
- Set tooling (set files are defined, not built).
- Launchkey stems (keys, pads, LK knobs stay per track).
- Dice/RND mode, Algo-Sequencer (Torso T-1) and the other machines in `sc/PLAN-STEM-LIBRARY.md` beyond drum machine
  and synthesizer.
- Hot-swapping a stem during a public set (swap is for producing; a short gap is acceptable if next-bar swap fails).

## Dependencies

- sc-migration 002 (SC engine in the player), done.
- `sc/sounds/` library format, `sc/lib/mini.scd` (mini-notation in SC), `sc/tools/render.scd` (offline render and
  event log), `tools/sc-port/` (comparison).
- sc-migration 009 is changed to depend on this epic for the lab parts.
