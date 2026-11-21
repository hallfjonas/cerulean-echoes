---
name: sound-lab
status: backlog
created: 2026-11-20T18:11:25Z
updated: 2026-11-21T00:40:00Z
progress: 73%
prd: .claude/prds/sound-lab.md
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: sound-lab

## Overview

Turn the LC column into a file. A **stem** (one fully set-up column: sample, patterns, three knobs, fader, two
buttons) becomes a JSON `.stem` file in a library with versions and metadata; a **track** becomes a JSON assignment of
stem versions to the 14 stem slots; a **set** a list of tracks (defined only). On that base the player gets the sound
lab: **Sample Designer** (new sounds on the whole LC, fixed drum machine / synthesizer or free via Claude), **Stem
Designer** (14 stem versions side by side, promote the winner), and a **stem swap** in the MIDI panel. 009-house is the
pilot: rebuilt from 14 extracted stems and proven to play the same.

Takes over sc-migration task 009 (machine lab, options lab, promote); 009 keeps the Strudel lab archive and depends on
this epic. Supersedes the stem and lab parts of `sc/PLAN-STEM-LIBRARY.md` (its machine list and Algo-Sequencer draft
stay there as ideas).

## Architecture Decisions

- **SC only.** Stems, stem tracks and both designers play on SC (`sc/lib/`). No Strudel stems.
- **Stem = column-agnostic JSON.** It names a sample, carries patterns as mini-notation (`sc/lib/mini.scd`), maps
  each control to parameters with ranges, and names its button-2 add-on from a shared add-on library. Placement
  (mode, column) belongs to the track.
- **Escape hatch.** Behaviour JSON cannot express (009's Complexity steps, multi-sound keys) lives in an SC file next
  to the stem (`"code": "<file>.scd"`), returning the same event shape; the JSON keeps labels and metadata. Prefer
  JSON; the pilot shows how often the hatch is needed.
- **Naming.** `<sample>-<k1>-<k2>-<k3>-<b1>-<b2>.stem`, lowercase kebab-case ASCII from the control labels; `-2`,
  `-3` on collision. Long but self-describing (decided 2026-11-20).
- **Versions.** Folder per sample: `sc/stems/<sample>/<name>.stem`. A version is a new file, never an edit of a played
  one; `parent` records lineage. A version with a different sample is a different stem.
- **Tracks pin versions.** A stem track references exact version files, so a new version never changes a track
  silently; a track takes a new version by a swap. (Shared-stem update policy: later epic.)
- **Metadata.** `role` (flat fixed list, required), `genres` (from `docs/reference/genres.md`), `energy` 1-5,
  `tags` (free, moods included), `harmony`, `about`. No hierarchical categories. "Used by" is computed from track
  files, never stored.
- **Global column stays in the frame.** Fog, Thin, Tension, Master, Chapter, Break and the harmony live in the stem
  track / engine; stems read them through standard inputs (stem contract).
- **Designer projects are files too.** `sc/lab/samples/<name>.sample.json` and `sc/lab/stems/<name>.stemlab.json`;
  copy = "Save as" in the player or a file copy by the skill. Projects are working files, the library holds results.
- **Non-destructive everywhere.** Swap, promote and export write new files; originals stay.

### Stem file (format 1, finalised in 001)

Full reference: `docs/features/stems.md`; schemas `sc/stems/stem.schema.json`, `sc/stems/track.schema.json`; add-on
library `sc/stems/addons.json`; check `tools/stems/check-stems.mjs`.

```json
{
  "format": 1,
  "name": "flute-brightness-space-complexity-pattern-echo-throw",
  "parent": null,
  "about": "Flute line on the chords; ornaments grow with Complexity.",
  "meta": { "role": "lead", "genres": ["house"], "energy": 2, "tags": ["airy"], "harmony": "chords" },
  "sample": { "name": "flute", "preset": { "breath": 0.3 } },
  "gain": 1,
  "pitch": "scale",
  "frame": { "break": "stay" },
  "patterns": [
    { "label": "core", "notes": "<0 2 4 2>", "rhythm": "~ x ~ x" },
    { "label": "answer", "notes": "<4 2 0 ~>", "rhythm": "x ~ ~ x ~ x ~ ~", "velocity": "1 0.8" }
  ],
  "controls": {
    "k1": { "label": "Brightness", "about": "dull ↔ bright.", "param": "bright", "range": [0.2, 1] },
    "k2": { "label": "Space", "about": "dry ↔ echo + room.",
      "targets": [{ "param": "space", "range": [0, 0.6] }, { "param": "echo", "range": [0, 0.3] }] },
    "k3": { "label": "Complexity", "about": "core → + neighbours → + trill.", "code": "flute-complexity.scd" },
    "fader": { "label": "Level", "about": "flute." },
    "b1": { "label": "Pattern", "about": "core → answer." },
    "b2": { "label": "Echo throw", "about": "long echo while held.", "addon": "echoThrow", "mode": "hold" }
  }
}
```

Changes from the first sketch: `gain` (loudness trim), `frame` (opt-outs from the global column, Break out / stay),
`velocity` on patterns, `targets` for a knob that moves several parameters, an optional stem-level `code`; the
add-on ids live in `sc/stems/addons.json`.

### Stem track file (format 1)

```json
{
  "format": 1,
  "name": "009-house",
  "about": "Happy, jazzy, dry house in A minor.",
  "tempo": 124,
  "swing": 0.1,
  "genre": "house",
  "frame": "009-house-frame.scd",
  "chapters": ["Vamp", "Progression"],
  "slots": { "1:1": "kick909/kick909-brightness-space-punch-pattern-drop-out.stem", "2:4": "flute/flute-….stem" }
}
```

A stem track is `sc/tracks/<id>/<id>.track`. The sketch's `harmony` and `global` became one `frame` SC file next to the
track (chords, progressions, chapters, global column 8, Launchkey); `chapters` repeats the chapter names for the tools.

### Alignment with llm-support (decided 2026-11-20)

`llm-support` (backlog) puts Claude into the player: selection registry, Claude drawer, modes, guardrails. Aligned,
not absorbed (absorbing would double this epic):
- **Skills are the contract.** `/sample-designer` and `/stem-designer` work from the terminal first; llm-support later
  adds drawer modes ("Design stem", "Design sample") that run the same skills. No second prompt or rule set.
- **One selection registry.** The column click of the stem swap (009) is built as llm-support's `selection.mjs`
  (kind `column`: track, slot, stem version), so the drawer can reuse it.
- **Modify on stem tracks** writes a new stem version or a Stem Designer project, not a copy of the track code
  (`.strudel` tracks are frozen once ported, sc-migration D1). Noted in llm-support's epic.

## Technical Approach

### Frontend Components (player, `tools/trajectory/`)
- MIDI panel: clickable column → stem drawer (library list filtered by role, genre, energy, tags) → swap; "Save as".
- Lab entries in the catalogue: Sample Designer and Stem Designer projects (`kind: 'lab'`, `engine: 'sc'`), Save /
  Save as / Promote / Export buttons.

### Backend Services
- SC: `sc/lib/stems.scd` (load a `.stem`, build its column: sample, pattern cycle, control buses, add-on),
  `sc/lib/stemtrack.scd` (slots + frame), `sc/lib/addons.scd` (Echo throw, Octave, Lift, Roll, Riser, Fill, Drop,
  Open, …), `sc/lib/designer.scd` (machine schema for the Sample Designer, 14-column Stem Designer).
- Node: `server.mjs` endpoints for stem list, swap, save as, promote, export; `catalogue.mjs` lists stem tracks and
  designer projects.

### Infrastructure
- `sc/stems/stem.schema.json`, `tools/stems/check-stems.mjs` (schema, naming rule, references, contract fields),
  `npm run stems` (list, filter, used-by); both in `npm test` and `npm run verify`.
- Skills: `/sample-designer`, `/stem-designer` (new); `/lab-board`, `/lab-to-track` point to them.
- Docs: `docs/features/stems.md` (stem, track, set definitions, file format, naming, metadata),
  `docs/features/sound-lab.md`.

## Implementation Strategy

Format first (001), then the SC loader (002) and the library index (004) in parallel. The 009 pilot (003) proves the
format against a real track before the designers build on it. Sample Designer (005, 006) only needs the SC side and can
run parallel to the pilot. Stem Designer (007, 008) and swap (009) come after the pilot. Docs and the skill hand-over close the
epic (010).

Each task group is its own branch and PR (`epic/sound-lab-<group>`), ends playable, and updates its task status in
the same PR.

Risks:
- JSON too weak for real columns: 009's columns may need the code hatch often. The pilot (003) measures it; if most
  columns need code, revise the format before 007.
- CPU: 14 candidate columns plus the context track on the M2 Air. Gate silent columns; measure in 007.
- Next-bar swap in SC (replace one column's pattern and buses while others play); fallback is a reload with a short gap.
- Loudness: stems from different tracks need a common target level, else swap and comparison mislead.

## Task Breakdown Preview

| # | Task | Parallel |
|---|---|---|
| 001 | Stem architecture: format, schema, naming, metadata, check-stems, track/set definitions (docs) | first |
| 002 | SC stem loader, add-on library, stem track loader | after 001 |
| 003 | Pilot: 009-house as 14 stems + stem track, equivalence proof | after 002 |
| 004 | Library index: `npm run stems`, used-by, server endpoint | after 001, parallel to 002 |
| 005 | Sample Designer: drum machine + synthesizer, project file, save/copy, export (sound + WAV) | after 001, parallel |
| 006 | `/sample-designer` skill (free arrangement, copy and change) | after 005 |
| 007 | Stem Designer: 14 columns, context track, A/B, save/copy, promote | after 003, 004 |
| 008 | `/stem-designer` skill ("re-design the piano stem of the house track") | after 007 |
| 009 | Stem swap in the player's MIDI panel, Save as | after 003, 004 |
| 013 | Stem format 2 (kits, layers, envelopes, Complexity layers; decided after the 003 pilot) | after 003, before 007 |
| 010 | Docs, skills hand-over, `PLAN-STEM-LIBRARY.md` trimmed | last |

## Dependencies

- sc-migration 002 (SC engine in the player): done.
- `sc/sounds/` format, `sc/lib/mini.scd`, `sc/tools/render.scd` (render + event log), `tools/sc-port/` (compare).
- sc-migration 009 depends on this epic for the lab parts (changed in this plan PR).

## Success Criteria (Technical)

- `check-stems` green on the whole library; `npm test` covers load, swap, save as, promote, export, project check.
- 009-house stem track matches `009-house.scd` event by event over the auto-perform script (`tools/sc-port` compare).
- Flute story end to end: `/stem-designer` → project → promote → swap into a copy of 009 → saved track file.
- One sound: Sample Designer → `sc/sounds/` → stem → track.
- A 14-column Stem Designer project plays without dropouts on the M2 Air.
- `npm run path-lint` shows no new missing paths.

## Estimated Effort

10 tasks, about 80 hours of agent work plus listening time. Biggest: 002 (loader), 003 (pilot), 005 (Sample
Designer), 007 (Stem Designer).

## Tasks Created
- [x] 001.md - Stem architecture and file format (parallel: false)
- [x] 002.md - SC stem loader and add-on library (parallel: false)
- [x] 003.md - Pilot: 009-house as a stem track (parallel: false; in review: differences to accept)
- [x] 004.md - Stem library index (parallel: true)
- [x] 005.md - Sample Designer (parallel: true)
- [x] 006.md - /sample-designer skill (parallel: true)
- [x] 007.md - Stem Designer (parallel: false; in review; live CPU measurement open)
- [x] 008.md - /stem-designer skill (parallel: true; in review)
- [x] 009.md - Stem swap in the player (parallel: true; verified by the user 2026-11-21)
- [x] 013.md - Stem format 2 (parallel: false)
- [ ] 010.md - Docs, skills hand-over, sound-lab wrap-up (parallel: false)

Total tasks: 11
Parallel tasks: 5
Sequential tasks: 6
Estimated total effort: 80 hours
