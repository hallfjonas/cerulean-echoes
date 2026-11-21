---
name: stem-designer
description: Set up and iterate a Stem Designer project (sc/lab/stems/<name>.stemlab.json) to compare versions of one stem against a running track; promote a winner into the stem library and swap it into a new track file. Use for 'redesign the piano stem of the house track', 'the flute is boring and repetitive, explore a replacement', 'candidates for the bass of 009', 'next round', 'promote this stem', 'put it into a copy of 009'.
---

# Stem Designer: a sentence becomes a project of candidate stems

A project puts up to 14 stem versions side by side on the Launch Control XL 3 slots (Mode 1 columns 1-7 = `1:n`,
Mode 2 = `2:n`) and plays them against a context track (its tempo, chords, chapters, global column, and the backing
stems you name). The user listens and turns knobs; column 8 button 1 = A/B (the column moved last swaps between its
candidate and the context track's stem), button 2 = Promote. What the user does: `docs/features/sound-lab.md`.
Your job: find the stem, write the project, prove it loads. Node cannot hear: never say a candidate is "better",
"warmer" or "less boring". Say what you built and what to listen for. The user's ear decides.

## Read first (do not work from memory)
- `docs/features/stems.md` (stem format, naming, metadata), `sc/stems/stem.schema.json`, `sc/lab/stems/stemlab.schema.json`
  and `sc/lab/stems/flute-explore.stemlab.json`.
- `sc/lib/stemlab.scd` (head comment): what the controls do.
- `npm run stems -- --role <role> [--genre <g>] [--used-by]` in `tools/`: the library by role, with lineage and users.
- `ls sc/lab/stems`; `git status`, `gh pr list`: a name that exists is taken, nobody else on this stem.

## 1. Find the stem
From "the piano of the house track": open `sc/tracks/<id>/<id>.track`; `slots` names the version on each slot, the
stem's `meta.role` says what it is. Say the slot and the file back to the user. No match ("the piano" but the track has
keys and vibraphone): ask which.

## 2. Plan (three lines before writing, the user can correct them)
Which slot, which candidates and why, which context stems stay as backing. Candidates:
- **Column of the stem itself**: the current version on its own slot, so A/B and the ear have a reference.
- **Other library stems of the role** (`npm run stems -- --role <role> --genre <genre>`): put them on the free
  slots of the same mode. A candidate with another mixer strip than the context stem is refused by A/B (the LC says
  why): fine for listening, mention it.
- **New drafts**: only when the sentence asks for something the library lacks ("sparser", "more answer phrases").
  Start from a copy of the current stem's JSON, change the least: patterns, a knob range, the sample preset. A draft
  lives in `drafts` of the project and a column says `draft:<id>`. Keep `parent` = the stem it came from; code files
  (`*.scd`) are found next to the parent, a draft cannot bring its own. Controls keep the labels of the house
  (CLAUDE.md "Labels"); the stem name follows the naming rule when promoted (the tool names it).
- Context: `context.track` (the track the stem lives in), `context.backing` = slots whose stems play along (kick,
  sub, bass for a lead; the drums for a bass), `context.chapter` start chapter. Never put the candidate's own slot
  in `backing` (it plays twice).

## 3. Write, check, load (the gate)
New project: `sc/lab/stems/<name>.stemlab.json` (name: lowercase words joined by `-`, `parent: null`, `about` one line,
`select` = the column the user hears first). Next round = copy, never overwrite:
`cd tools && npm run stem-lab -- save-as <name> <new-name>`, then edit the copy: say what changes ("drop column 2:6,
add the vibraphone, answer phrase sparser in draft airy").
Before you say "ready", paste the last lines of:
1. `cd tools && npm run stem-lab -- check <file>` and `npm run check-stems` (schema, references, drafts as stems).
2. `/Applications/SuperCollider.app/Contents/MacOS/sclang tools/sc-test/stem-designer.scd` from the repo root (or
   `$SCLANG`; every project loads, plays, shows labels, A/B and Promote work). Run it alone, not beside another SC job.
   No sclang: say so, the project is checked but not loaded.
Report: the file, the plan in a few words, what to listen for, the columns as the LC shows them, that it loads in SC
but has not been heard. Tell the user to start the player (`cd tools && node trajectory/server.mjs`, localhost:8766),
pick Lab, `Stems: <name>`.

## 4. Promote and swap (only on request)
"Promote", "this one wins", "put it into a copy of 009":
1. `cd tools && npm run stem-lab -- promote <name> <slot>`: the draft becomes `sc/stems/<sample>/<name>.stem`
   (new version, `parent` set, `check-stems` run, never overwrites). A library stem needs no promote.
2. `npm run stem-lab -- track-with <track> <new-track> <slot>=<ref>`: a new track file (`009-house-v2`), the
   original stays. Then `npm run check-stems`. Levels are the user's call: a new version may need a gain trim, say it
   instead of changing it.
Replacing the stem in the original track file: ask first.

## Limits (say them instead of working around them)
- Drafts are pure JSON on the stem format: no own code files, no new add-ons or sounds (that is `/sample-designer`).
- One project plays up to 14 candidates; live CPU on the M2 Air with 14 columns plus backing is not measured yet.
- Do not edit `stemlab.scd`, schemas or the frame for one project. Ask.

## Don'ts
- Do not claim "better". "Candidate 2:5 is the strings stem, same role, lift add-on" is a fact.
- Do not promote, swap into a track, push or open a PR unasked.
- Do not edit a played stem version; a change is a new version (a draft, then Promote).
