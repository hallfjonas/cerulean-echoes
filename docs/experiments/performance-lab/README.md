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

Two phases, no phase-per-PR split:

- [plan-now.md](plan-now.md): one PR (this one), seven steps after the prototype: core, shell and routes, levels UI, save,
  import, play, then docs. Launch Control only; no Launchkey support, no LLM help, no tempo write, no stem editing.
- [plan-later.md](plan-later.md): what comes after, by function: Launchkey moves, drafting, LLM support, workflow
  records, tempo write, stem editing.
