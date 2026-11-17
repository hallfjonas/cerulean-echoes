---
name: launchkey-knob-target
status: backlog
created: 2026-11-15T16:46:30Z
updated: 2026-11-15T20:30:00Z
progress: 0%
prd: .claude/prds/launchkey-knob-target.md
github: (will be set on sync)
---

# Epic: launchkey-knob-target

## Overview

Two improvements for the Launchkey MK4 25 in the one-file live tracks (007, 008, 009, 010):

1. **Knob target switch.** A Launchkey button toggles the 8 knobs (CC 31-38) between **Keys** (today's jobs) and
   **Pads** (jobs for the 16 drum pads, defined later in a lab round). Each target keeps its own knob values.
2. **Realistic keyboard in the LC view.** White keys touch, black keys are short, sit at the top and overlap both
   white neighbours.

## Architecture Decisions

- **Measure first.** Which Launchkey button sends a CC on the MIDI port in the factory setting, and whether the
  encoders send absolute (0-127) or relative values, is unknown. Today's code reads them as absolute
  (`lkCc(31..38)` as 0..1; 008/009/010 hold a start value per knob with `lkSticky` until it moves, 007 reads
  `lkKnob` directly without `lkSticky`). Task 1 measures with `snippets/midi-test.strudel`
  and writes the result into `midi-layouts/devices.md`. The takeover design follows from it:
  - relative → one accumulator per knob and target; no jumps by design.
  - absolute → pickup per knob and target: the stored value holds until the knob passes it.
- **One routing helper.** `lkKnob(n)` stays the single access point. It becomes `lkKnob(target, n)` (or two
  helpers `lkKeyKnob` / `lkPadKnob`) built on one shared `lkTarget` state; every existing `lkKnob(n)` call becomes
  the Keys form, `lkShotTone` moves to the Pads target (knob 8, Pad Fog). Nothing else in the sound changes.
- **Toggle is a stateful closure** created once (like `cycleButton`) and queried every tick through `stateTaps`, so
  presses are not lost while `stemLK` is gated.
- **`@lk` tags per target.** `// @lk k1 ...` stays for Keys; Pads get `// @lk pad.k1 ...`. The LC view and the
  layout generator (`tools/lcxl-layout`) read both; the layout sheet shows both knob rows.
- **Keyboard drawing in CSS only.** The `.lkkeys` grid of 25 equal cells becomes: a flex row of white keys without
  gap, black keys absolutely positioned on the border between two white keys (about 60 % width of a white key,
  60 % height). Classes `in` / `on` and the octave-following window (`lcView.base`) stay.

## Technical Approach

### Frontend Components (LC view, in each track)
- `lkPlay()`: render white keys in a row, black keys as overlays positioned by white-key index.
- CSS: replace `.lkkeys` grid rules; keep colours (green in scale, red off key, bright when pressed).
- `lkHtml()`: label the knob row with the active target (`Keys` / `Pads`) and show that target's names and values
  (`lcView.cc.lk` becomes per target).

### Backend Services (Strudel patterns, in each track)
- `lkTarget`: toggle closure on the measured button CC, created once, tapped in `stateTaps`.
- Per-target knob values (accumulator or pickup, per task 1).
- `lkKnob` routed through the target; `lkShotTone` reads the Pads target.
- Pads target knobs 1-7: placeholders named in `@lk pad.kN` tags, no sound effect yet (lab round decides).

### Infrastructure (tools)
- `tools/lcxl-layout`: parse `@lk pad.kN` tags, print the Pads knob row on the layout sheet.
- `tools/strudel-sim` / harness: simulate the target button so `check-sounds` and the optimize check still cover the
  pad path.

## Implementation Strategy

Build and prove in 009-house, then port the same code block to 007, 008, 010 (their Launchkey blocks are the same
structure; 007's knob jobs differ and it has no `lkSticky`, so its start values need checking in the port).
Keyboard drawing is independent of the knob work and can run in parallel.

## Task Breakdown Preview

1. Measure the Launchkey: button CCs and encoder mode in factory setting; note in `midi-layouts/devices.md`.
2. Knob target switch in 009 (toggle, per-target values, routing, `stateTaps`), proven with `/strudel-optimize`
   (Keys target, knobs untouched = identical). Depends on 1.
3. LC view: target label and per-target knob row in 009. Depends on 2.
4. Realistic keyboard drawing in the LC view (009). Parallel to 1-3.
5. `@lk pad.kN` tags in the layout generator and the simulator harness. Parallel to 2-4 once the tag format is set.
6. Port 2-4 to 007, 008, 010; run `check-sounds` and `/strudel-optimize` per track. Depends on 2-5.

Parallel: 4 and 5 alongside 1-3. Conflicts: 2, 3, 4 all edit 009-house.strudel (different blocks: patterns vs view
code) — run 3 and 4 one after another or merge carefully.

## Dependencies

- Physical access to the Launchkey for task 1 (the player measures, Claude reads the console).
- Lab round for the Pads knob jobs (separate, after this epic).
- Other epics: `drop-buildup` also changes the LC view. Merge one at a time.

## Success Criteria (Technical)

- `/strudel-optimize` shows 007-010 event-identical to before with target Keys and knobs untouched.
- Simulator test: switch to Pads, turn knobs, switch back: Keys values unchanged; 10 rapid presses all counted while
  `stemLK` is gated.
- Screenshot of the LC view: white keys without gaps, each black key overlapping both neighbours, target label visible.
- Layout sheet shows both knob rows; hook still regenerates PDF and `.syx` without errors.

## Estimated Effort

About 1.5 days: measuring 0.5 h, switch + view in 009 half a day, keyboard drawing 1-2 h, tools 2 h, port to three
tracks half a day.

## Open Questions

- Which Launchkey button (task 1 result). If no button sends a CC in the factory setting: Shift + a pad, a custom
  mode, or a click in the view as fallback.
- Pads target knob jobs (lab round).
