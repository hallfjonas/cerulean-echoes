# Plan: later

What the Tracks lab will do after [plan-now.md](plan-now.md). Described by function, not by task; each item becomes its
own plan when it is picked up. Order is a suggestion.

## Launchkey support

- Moves for keys (stabs and held chords with a chord picker), drum pads (roll, off-beats, single hit, with pad names
  from the track's `lkPadNames`) and Launchkey knobs and mod wheel (named from the `@lk` tags), with a "Keys on" setup
  move (mod wheel, Brightness, Length).
- Lanes for keys (note blocks) and pads (hits by pad row); a chord shown by note names.
- Existing Hand-made Launchkey steps are recognised as these moves by the importer (round-trip rule unchanged).
- Checks: keys sound only while the mod wheel is up, no keys or pads at bar 0, pads on the beat grid.

## Drafting

- Arc presets (Slow rise, One drop, Two drops, Plateau, Journey) that replace the sections, snapped to phrase lines.
- Recipes per section type (Intro, Layers, Groove, Build, Drop, Break, Peak, Strip, Outro) that draft moves for a
  section. Deterministic, no LLM. Energy only describes a section; recipes may read it later if the user decides so.

## LLM support

- "Say what to change": words like "hats enter more smoothly" or "less going on here" become adjust operations on the
  selected move or section (Smoother, Later, Spread out, Thin out). Shown as a proposed change the user accepts or
  rejects, never applied silently.
- Draft from the story text: story, mood and references become sections and moves, using the `/auto-perform` skill's
  rules and the track's own controls.
- Feedback by section and bar maps to the right moves, with the mapping stated.

## Workflow records

- Design and sound rounds written to `perform/<track>/feedback.md` in the existing format; the status chips (draft,
  design approved, sound approved) enforce the two gates of the skill.
- Design `.md` generated from the sections (1-based bars, as design tables are today) and kept in sync on save.

## Tracks lab

- Tempo written to the track (the `tempo` of its `.track` file, which the engine reads) instead of a what-if, with
  the length and every bar-based label updated and a warning for performances written at another tempo.
- Stem editing: the lab grows from performances into the main place for a track, with its stems (list, swap, levels,
  knob names) next to its performances. This is its own plan; the existing Stem Designer and `docs/features/stems.md`
  are the starting point.
- Track metadata (genre, bpm, length, listening references) shown beside the performances.

## Smaller ideas

- New moves as the user hears the need (drifting percussion levels, a one-bar break before an entrance, chords changed
  while the stem is silent).
- Take to performance in one click (a take is imported like any script, then tidied into moves).
- Compare two performances of a track side by side (sections and energy).
- Offline render of a performance through `sc/tools/render.scd` for a quick level and clipping look.
