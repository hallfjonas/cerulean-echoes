---
name: lcxl3-daw-mode
status: in-progress
created: 2026-11-28T12:00:00Z
updated: 2026-11-28T18:00:00Z
progress: 17%
prd: .claude/prds/lcxl3-daw-mode.md
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: lcxl3-daw-mode

## Overview

Phase 1 of the set-mode plan: the SC engine runs every Launch Control XL 3 in DAW mode, and every track plays and
feels as today. Mode 1 / Mode 2 move from the device's custom modes into the engine; the engine draws the LEDs and
the screen. The new buttons are read but get no jobs (later phases: shift layers, pages, automations, set mode).
The custom modes stay as the fallback.

## Architecture Decisions

- **Drivers, not one big MIDI handler** (user, 2026-11-28). `sc/lib/` gets one driver per device kind:
  `lcxl3-daw`, `lcxl3-custom` (today's path), `launchkey-mk4` (today's path). A driver turns MIDI into the
  engine's controls and the engine's output (knob positions, LEDs, screen) into MIDI. Today's `~ce.midiKinds`
  picks the driver by port name. A future controller is a new driver.
- **Control ids stay today's CC numbers** (5-100) for knobs, faders and bottom buttons: takes, auto-perform scripts,
  the web view and `@ctl` texts do not change. DAW-only buttons get named ids (`page-up`, `track-left`, …).
- **Knob value scaling, fader pickup and the Mode 1 / 2 fader handover stay as they are**, moved behind the driver
  interface unchanged (`~ce.midiCC`, `~ce.pickup`, `~ce.lcModeSwitch`). Relative encoders: not in this epic.
- **Mode per device, set by the engine:** Page ▲ = Mode 1, Page ▼ = Mode 2 (to confirm in 001). Mode 2 = CC + 48 in
  the driver, column 8 through the existing `ccAlias`.
- **The Mode button cannot be locked** (guide pp. 16-17). Defence in layers: auto-return on the mode report, the
  custom-mode port read as fallback, a watchdog query, all custom slots loaded with the two modes, a cover for gigs.
- **The engine is the only thing that talks to the LCs.** Muted runs (`CE_SC_MUTE`, `lcFeedback == false`) never
  enable DAW mode or send anything to a device.
- **Fallback first, deprecation later** (user, 2026-11-28): the custom modes and `.syx` files stay; a
  `DEPRECATION.md` entry follows the approved rehearsal, not this epic.

## Technical Approach

### SC (`sc/lib/`)
- `controls.scd`: keeps the shared parts (setCC, latches, pickup, knob scaling); the port handling moves into the
  drivers.
- New driver files (names decided in 002): LC DAW (enable / leave, input, mode per device, knob feedback on ch 16,
  LEDs, screen, auto-return, watchdog), LC custom (today), Launchkey (today).
- `engine.scd`: disable DAW mode on exit (`ShutDown`, quit).
- `ui.scd`: `/ce/midi` lists an LC once with its mode; DAW-only presses go to the UI.

### Player (`tools/trajectory/`)
- MIDI panel and Live view: one row per LC, its mode.

### Tools and docs
- `sc/tools/lcxl3-daw-test.scd`: new phases for the spike (001).
- `tools/sc-test/run.scd`: simulated DAW ports.
- `docs/reference/lcxl3-daw-mode.md`, `midi-layouts/devices.md`, `docs/features/controllers.md`, `CLAUDE.md`.

## Implementation Strategy

001 (device spike) and 002 (driver refactor, no behaviour change) run in parallel: 001 needs the device, 002 does not.
003 (DAW input and knob feedback) needs both. 004 (LEDs and screen) and then 005 (Mode-press defence, which repaints
with 004's code) follow. 006 (player, docs, rehearsal) closes. Branches `epic/lcxl3-daw-mode-<task>` off
`origin/main`, one PR each.

Risks:
- Knob feedback on a DAW page and the device's own fader pickup are not measured: 001 decides, before 003 is built.
- Auto-return may not be possible or may lose more than one press: then FR7 falls back to layers 2-4 (001 decides).
- A refactor of the MIDI path can change the feel without failing a test: 002 is checked by playing, not only by
  `npm test`.

## Task Breakdown Preview

| # | Task | Parallel |
|---|---|---|
| 001 | Device spike: open DAW-mode questions, Mode press, Launchkey survey | yes, with 002 |
| 002 | Driver layer: today's LC and Launchkey paths behind drivers, no behaviour change | yes, with 001 |
| 003 | DAW driver: enable / leave, input, mode per device, knob feedback | after 001, 002 |
| 004 | LEDs and screen: today's colours, mode and track, name + value on move | after 003 |
| 005 | Mode-press defence: auto-return, fallback, watchdog, persistent settings | after 004 |
| 006 | Player panel, docs, two-LC rehearsal | last |

## Dependencies

- `docs/reference/lcxl3-daw-mode.md` (measured 2026-11-23) and the programmer's guide v1.0.
- Device time: both LCs and the Launchkey for 001 and the rehearsal in 006.
- Epic `lk-pad-knobs` (relative knobs toggle) touches `~ce.midiCC`: whichever lands second rebases on the driver
  layer.

## Success Criteria (Technical)

- Every SC track loads and reacts to knobs, faders and Pattern buttons with one and two LCs in DAW mode, both modes.
- `npm test` covers the DAW port, Mode 2 offset, knob feedback channel and numbers, mode handover, fallback,
  auto-return (simulated ports, no device).
- An accidental Mode + bottom button press costs at most that one press (device check).
- Quit: the LC is back in Custom Mode 1.
- `npm run path-lint` shows no new missing paths.

## Estimated Effort

6 tasks, about 30 hours of agent work plus two device sessions. Biggest: 003.

## Tasks Created
- [ ] 001.md - Device spike (parallel: true)
- [x] 002.md - Driver layer (parallel: true)
- [ ] 003.md - DAW driver: input and knob feedback (parallel: false)
- [ ] 004.md - LEDs and screen (parallel: false)
- [ ] 005.md - Mode-press defence (parallel: false)
- [ ] 006.md - Player panel, docs, rehearsal (parallel: false)

Total tasks: 6
Parallel tasks: 2
Sequential tasks: 4
Estimated total effort: 30 hours
