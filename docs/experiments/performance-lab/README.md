# Tracks lab, Performances (design notes for the prototype)

Prototype: `tools/trajectory/perform-lab-prototype.html` (open it in Chrome; it uses `tools/trajectory/ui.css`).
Nothing is saved or played; the demo data is 009 Dance Floor and 010 Journey rewritten as sections and moves.

## What exists today

14 scripts in `tools/trajectory/perform/` (7 tracks): 8 hand-written with a design `.md` (001, 002, 007, 008 x2, 009,
010, 017 x2), 4 generated `every-button.json`, 1 ancestor (`010 spike-run`). Takes land in `takes/` (gitignored).
Across the hand-written ones, 1315 steps: about 28 % `cc` (mostly Level), 247 keys stabs, 11 pad bursts, 13 build-and-release
Tension ramps, 13 Fog dips, 24 Master moves. The same gestures come back in every design table: a stem enters, layers
join one by one, a build lifts, a break pulls the low end out and returns on the one, a snare roll before a drop, keys
stabs on the off-beat, a staggered strip at the end.

Humans work in two loops (`/auto-perform`): design table (section, bars, controls, Launchkey, intent) approved first, then
a script that is tuned by listening, with feedback given by section and bar ("hats enter more smoothly").

## The ladder

One model, five zoom levels. The selection survives a level change.

| Level | What you edit | Written by |
|---|---|---|
| Story | title, length, mood, story text, references, arc shape | the user |
| Sections | name, bar range, type, intent, energy | arc preset, drag |
| Moves | musical gestures with parameters (Enter, Layers, Build, Fog dip, Break, Roll, Keys...) | recipe per section type, palette |
| Lanes | one automation lane per control; drag a dot for value and time | direct |
| Steps | the exact script v2 rows | direct |

Direction of travel is down (story to steps), editing is allowed anywhere. A hand edit at a lower level is stored as an
override on the move that produced the step (`move.edits[stepIndex]`), so changing the move later keeps the edit.
A step the lab cannot explain becomes a "Hand-made" move.

## Data

```
lab file  <name>.lab.json   { story, refs, status, sections[{id,name,type,from,to,intent,energy}],
                              moves[{id,kind,bar,p:{...},edits:{i:{bar?,value?,ramp?,del?}}}], rounds[] }
script    <name>.json        plain script v2, compiled from the lab file; check-perform stays the judge
```

The `.json` keeps its current shape (check-perform allows no extra step fields), so existing tooling, takes and the player
need no change. The sidecar is what makes the high levels editable; a script without one is imported (seam 3).

## Seams (numbered in the prototype, switch "seams" on top)

1. Library: list scripts per track with sections, step counts, design `.md`, takes.
2. Controls: control names and CCs from `controlsOf(tagSource(...))`, plus `@lk` names and pad names (`lkPadNames`).
3. Import: recognise a script or a take as sections and moves; leftovers become Hand-made.
4. Compile: moves and edits to script v2 steps (pure function, unit-testable).
5. Check: run `check-perform` on the result; add lab warnings (silent stretch, too many moves at once).
6. Save: `.json`, `.lab.json`, design `.md` from the sections, and the `feedback.md` round.
7. Play: start in the player at a bar, jump to a section, play / pause (TODO.md "auto-perform playback control").
8. Feedback: "hats enter more smoothly" becomes adjust operations (Smoother, Later, Spread out...) on moves.
9. Draft: arc to sections to moves with recipes; later the `/auto-perform` skill fills it from the story text.
10. Page: the Labs sub-tab "Tracks" (`pages.mjs`, its sidebar sections, URL hash `#labs/tracks`).
11. Tempo: write the track's `bpm` (frame) once the tracks lab can edit tracks.

## Decisions

- Home: a Labs sub-tab called **Tracks** (seam 10), which may grow into the main tracks lab. The sidebar picks a track
  and then one of its performances (two dropdowns). Performances is the only facet built now; **stem editing is a goal
  tracked in `TODO.md` and out of scope for this phase** (the disabled "Stems · later" button marks the place).
- Bars: 0-based everywhere in the lab, as in the script, and a range `from→to` ends before `to`. The ruler says
  "bar (from 0)". The design `.md` generated on save (seam 6) is the only 1-based place, as design tables are today.
- Energy only describes a section; recipes ignore it.
- Length: header and Story show bars and minutes (`bars x 240 / BPM`), sections show their own length. Tempo is
  editable as a what-if (seam 11): it lives in the track, so the lab only recomputes the length until the tracks lab
  can write it.
- Moves: no missing gestures found so far; add them as the user hears them.

## Plan

One PR per phase, each branched from a fresh `origin/main`. Every phase ends with `npm test` and `npm run verify-sc`
green and a listen or look in the player where it touches sound or UI.

1. **This PR: prototype and notes.** Static HTML, demo data, no server. Review the UI and the model, answer what is left.
2. **Core module (seam 4).** Move the move catalogue, `compile()` and the edit overrides out of the prototype into
   `tools/trajectory/perform-lab/` as pure functions with feature tests: every move compiles to valid steps, an
   override survives a move edit, `check-perform` accepts the result.
3. **Tracks page shell (seams 1, 2, 10).** Labs sub-tab "Tracks" in `pages.mjs` and the player, server routes that list
   a track's performances and its controls (`controlsOf`, `@lk`, pad names). Read-only: open a performance, see the
   controls and the existing steps at the Steps level.
4. **Save (seams 5, 6).** Write `<name>.json` and the `<name>.lab.json` sidecar, run `check-perform` on save, show its
   errors in the footer. A new performance goes into a new file; an existing script is never overwritten without a
   "save as".
5. **Import (seam 3).** Recognise the 14 existing scripts as sections and moves. Acceptance: importing and compiling
   gives back the original steps for every script (what is not recognised stays a Hand-made move), so no script can
   change by being opened. Takes use the same importer.
6. **Play (seam 7).** Start at a bar or section through the existing auto-perform path, play / pause, click a section
   to jump (the TODO.md item "auto-perform playback control"). Needs a listen on the real player.
7. **Feedback and draft (seams 8, 9).** Adjust operations from words, feedback rounds written to `feedback.md`,
   design `.md` export (1-based bars), draft moves from the story through the `/auto-perform` skill. Energy stays
   descriptive unless the user decides otherwise.
8. **Later, separate plan.** Tempo written to the track (seam 11) and stem editing, which turns Tracks into the main
   tracks lab. Out of scope until phases 2 to 7 are in use.

Risks: the importer is the hard part (recognition ambiguity), so phase 5 keeps the round-trip rule as its test; the
player page is large, so the lab gets its own module files rather than growing `player.html`.
