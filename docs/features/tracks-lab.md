# Tracks lab

## What it is
A page in the [player](player.md) (Labs, Tracks) for [auto-performances](auto-perform.md): pick a live track and one of
its performances, or start a new one, edit it at five levels, check it, save it as a new script and play it from any
bar. It works with the Launch Control XL 3; Launchkey steps in existing scripts are kept as they are.

The five levels show the same performance at different zoom:

| Level | What you edit |
|---|---|
| Story | title, length, mood, story text, references; the energy curve of the sections |
| Sections | name, bar range, type, intent, energy |
| Moves | musical gestures with parameters (below) |
| Lanes | one automation lane per control; drag a dot for value and time, a square for where a ramp starts |
| Steps | the exact rows of the script |

The moves: **Enter** and **Leave** (a stem's fader comes in or goes out), **Layers** (stems one by one, in or out),
**Build** (a control rises, then drops to 0), **Fog dip** (muffle, hold, clear), **Move control** (any knob or fader),
**Break** (out, then back), **Press** (Chapter, Pattern, any button) and **Hand-made** (steps the lab does not
explain, Launchkey steps among them).

## When to use it
- You want to write a new performance for a track, section by section, without typing JSON.
- You want to change an existing performance and hear the change before you save it.
- You want to hear one part of a performance again without waiting from bar 0.

## How to use it
1. Open the player (`cd tools && node trajectory/server.mjs`), go to Labs, then Tracks.
2. Pick a track, then a performance (scripts and takes), or press **New performance** (one 64-bar section). The list
   is read again each time you open the page, so a take you just recorded is there.
3. Change the level with the buttons on top or the keys **1**-**5**. Click a section, a move or a step to select it:
   the panel on the right edits it, and the selection stays when you change the level.
4. Story, Sections, Moves and Lanes share one head that stays on top while you scroll: the ruler and the sections.
   Click a section to work on it: the panel edits it and the timelines mark it; drag its edge to resize it. Steps
   has a Section dropdown instead: it lists only that section's steps, or all of them.
5. Click the ruler to set the cursor; the sidebar adds sections, moves or steps there. Drag moves, section edges,
   energy dots and lane dots. **Cmd-Z** undoes, **Escape** clears the selection, **Backspace** deletes the selected
   move or step.
6. **Play** in the sidebar plays the performance as it is now, saved or not, from the bar in "From bar". While it plays,
   click a section or the ruler to go there; **Stop** ends it.
7. **Save as** writes a new script under a name you give; **Save** writes over a performance the lab saved before.

## Good to know
- Bars count from 0, as in the script, and a range ends before its last number: a section 16→32 holds bars 16 to 31.
- A lane shows what the performer plays: a step starts from the value the control holds at its bar, so a step that
  starts inside the ramp before it cuts that ramp (a warning in the footer). Dragging keeps a step between its
  neighbours on the lane, so a drag never makes such a cut.
- A take recorded in the app window holds no steps (the window has no Web MIDI); the sidebar says so.
- The tempo on top is a what-if: it changes the minutes shown, not the track (`tempo` in the `.track` file).
- A button switches at the next bar line, Chapter at the next 4-bar line. So a Press or Break move sits on the bar where
  the button takes over and presses half a bar before it; button moves snap to whole bars. An existing script that
  presses on a whole bar opens with that move on bar x.5: it takes over one bar later than the bar it is on.
- Play starts on a 4-bar line (Chapter counts its 4-bar phrases from the load). The values the script holds at that
  bar and the presses before it go with the load, so patterns, Chapter and Break are where the script put them; keys
  and pads before it are not played. Every start and jump loads the track again: a short gap.
- Opening a script never changes it: the lab recognises its steps as moves only where they compile back to exactly
  the same steps, and the rest stays Hand-made. `npm test` checks this for every script in `perform/`.
- Save writes `perform/<track>/<name>.json` (the script, checked by `check-perform` like every other) and
  `<name>.lab.json` beside it (the sections and moves, with a fingerprint of the script). It never overwrites a script
  the lab did not write, nor one that was changed outside the lab since; a script with `check-perform` errors is not
  written. The footer shows the errors as you edit.
- A script changed outside the lab opens from its steps, with a note.
- What comes later (Launchkey moves, drafting from an arc, help from Claude, tempo written to the track, stem editing)
  is in the roadmap `docs/experiments/performance-lab/plan-later.md`.

## Related
- [Auto-perform](auto-perform.md)
- [Player](player.md)
- [Controllers](controllers.md)
- Script format: `tools/trajectory/perform/script-format-v2.md`
