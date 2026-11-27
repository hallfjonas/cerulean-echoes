---
name: lk-pad-knobs
status: backlog
created: 2026-11-20T18:44:03Z
updated: 2026-11-20T18:44:03Z
progress: 0%
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: lk-pad-knobs

## Overview

Two knob improvements for the SuperCollider live tracks (`sc/tracks/`: 007, 008, 009, 010, 016):

1. **Pad knobs.** The Launchkey MK4 25 has a button that changes the CC numbers its 8 knobs send. Bank A (CC 21-28)
   keeps today's jobs for the keys. Bank B (CC 31-38) gets new jobs: knob *n* modulates the two drum pads in the
   column below it (the 16 pads sit as 2 × 8 under the 8 knobs).
2. **Relative knobs toggle.** A player setting makes every knob, on both Launch Control XL 3 and the Launchkey,
   work relative instead of absolute: turning changes the value from where it is, never jumps.

## Architecture Decisions

- **The device switches the bank, the software does not.** No Keys/Pads toggle in code. Which Launchkey button
  does this and which CCs it sends is measured first (task 001); the plan assumes bank A = CC 21-28, bank B = CC 31-38.
  This replaces the software Keys/Pads toggle of the removed epic `launchkey-knob-target` for the SC tracks.
- **One pad-to-knob map.** Pads are notes 36-51 on channel 10. In the factory layout (confirmed in task 001)
  columns 1-4 = notes 36-39 (bottom) and 40-43 (top), columns 5-8 = 44-47 (bottom) and 48-51 (top).
  `ce.lkPadColumn(note)` in `sc/lib` is the only place that knows it.
- **A bank B knob's job applies to all 16 pads** (decided 2026-11-27, not per column): the same eight jobs on every
  track, each neutral at 0. `ce.lkPadMods(i)` and `ce.lkPad(n)` in `sc/lib/controls.scd` are the only place that
  knows them. Done so far: 1 pitch down, 2 brightness (the former Pad Fog), 3 thin, 4 drive, 5 pad spread (pad 1
  left … pad 16 right), 6 boost. Knobs 7 and 8 are free (room and echo are lane sends, they need state buses).
- **Key pan on knob 8 (CC 28).** Spreads the keys across the stereo field: 0 = all in the middle, 1 = the lowest key
  of the keyboard window hard left, the highest hard right (`ce.lkKeyPan`; the window follows the octave buttons the
  way the player's keyboard does). Pad Fog moved from CC 28 to CC 32.
- **Pad modulation reads the knob at the hit** (as the Pad Fog knob does today in `lkNote`) unless the parameter can
  act on a sounding shot; then it goes through a state bus.
- **Relative is applied only on the hardware path** (`ce.midiCC`). The web UI, auto-perform and takes send
  absolute values through `/ce/cc` and `/ce/lkcc` and stay untouched.
- **Software relative.** Knobs keep sending absolute 0-127. In relative mode the stored value changes by the
  difference to the knob's previous raw value. Hardware-relative encoders (endless knobs) are out of scope until
  measured; see Open Questions.
- **The setting reaches SC through the player server.** Browser settings live in `localStorage`; SC reads the hardware
  itself, so the toggle is sent as `/ce/relative` (0/1) on change and on every load, and SC starts absolute.

## Technical Approach

### Backend (SC)
- `sc/lib/controls.scd`: `lkCtl` handles CC 31-38; `ce.lkPadColumn`, `ce.lkPadKnob(note, job)` helpers;
  `ce.relative` flag and a per-CC `lastRaw` in `midiCC` for knobs (LC knob CCs 13-35, +48 for Mode 2, Launchkey 21-28
  and 31-38; faders and buttons stay absolute).
- Tracks: `lkNote` pad branch reads the column's knob; `@lk pad.kN` tags name the jobs.
- `sc/lib/ui.scd`: `/ce/lkccs` also carries CC 31-38; new inbound `/ce/relative`.

### Frontend (player)
- `tools/trajectory/settings.mjs`: toggle `relativeKnobs`; `apply` posts to the server.
- `tools/trajectory/sc-link.mjs` and `server.mjs`: route the setting to `/ce/relative`.
- `sc/ui/index.html`: the Launchkey strip shows the pad knob names and values (CC 31-38) under the knobs of bank B,
  the bank last moved framed.

### Tools
- `tools/lcxl-layout/ctl.mjs`: parse `@lk pad.kN` tags (`// @lk pad.k1 Name | text`, as the frames write them).
- `tools/sc-test/run.scd` and Node tests: feature tests for both parts.

## Implementation Strategy

Measure first (001), then the engine and pad routing in 016 (002), the pad jobs by ear (003) and the view (004) on
top of it. The relative toggle (005) is independent and can run in parallel; it touches `setCC` / `midiCC` like 002
touches `setLkCC` / `lkCtl`, so merge one after the other. One branch and PR per task group
(`epic/lk-pad-knobs-<group>`); task and epic status updated in the same PR.

## Task Breakdown Preview

1. Measure the Launchkey knob banks and pad layout; fix the stale CC 31-38 notes in the docs.
2. SC engine: CC 31-38, `lkPadColumn`, pad modulation hook, proven in 016.
3. The 8 pad jobs: choose by ear in a lab round, port to 007-010, 016.
4. MIDI panel: pad knob names and values on the Launchkey strip.
5. Relative knobs: player setting, `/ce/relative`, accumulator in SC.

## Dependencies

- Physical Launchkey for task 001 (the player presses the button and turns knobs, Claude reads the console).
- `sc-migration` (008 port of 016 in progress): rebase on it; do not start 003 on a track still moving.
- UI work on `sc/ui/index.html` (branch `ui/sc-themes`): merge one at a time with task 004.

## Success Criteria (Technical)

- Bank B knob *n* does its job on every pad (feature test: `sc/tools` `run.scd`); bank A behaves as before, except knob 8.
- Knobs at 0 in bank B: pads sound as today.
- Relative on: moving a knob never jumps the value; first message after the switch only records the raw value;
  UI, auto-perform and takes still set absolute values.
- `npm test` passes, including the SC part; the toggle value survives a reload and reaches SC after a restart.

## Estimated Effort

About 2 days: measuring 1 h, engine 3 h, pad jobs half a day with listening, view 3 h, relative toggle 4 h, tests
and docs 3 h.

## Open Questions

- Which Launchkey button changes the knob CCs, and does bank B really send CC 31-38? (task 001)
- Pad jobs 7 and 8 (candidates: room, echo throw); jobs 1-6 are in and still to be tuned by ear.
- Relative mode: software relative is planned. If the player means endless hardware encoders, that needs
  Novation Components modes and a measurement first; it would become its own task.
- Step size: a full sweep of the knob = full range of the value, or finer? Start with 1:1.
