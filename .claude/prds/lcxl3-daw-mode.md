---
name: lcxl3-daw-mode
description: The SC engine runs every Launch Control XL 3 in DAW mode (all buttons, LEDs and the screen reach the app); first a 1:1 switch, the new buttons get jobs later
status: backlog
created: 2026-11-24T00:00:00Z
---

# PRD: lcxl3-daw-mode

## Executive Summary

The SuperCollider engine switches every connected Launch Control XL 3 into its DAW mode and reads it on the DAW port
instead of through the two custom modes. Device tests on 2026-11-23 showed that on the LC's DAW pages every control
reaches the app (the 16 bottom buttons, Page, Track, Solo/Arm, Mute/Select, Record, Play, Shift, knobs, faders), every
LED takes a colour from the app, and the app can write on the screen. In the custom modes Page, Track, Solo/Arm and
Mute/Select send nothing, and the app cannot colour the custom-mode buttons.

This PRD is the **switch only**: after it, every track plays and feels exactly as today, with Mode 1 / Mode 2 done by
the app. What the new buttons, LEDs and the screen are used for is a separate PRD afterwards (agreed with Jonas,
2026-11-24).

## Problem Statement

- In the custom modes (`midi-layouts/lcxl3-mode1.syx` / `-mode2.syx`) the LC keeps Page ▲▼, Track ◀▶, Solo/Arm and
  Mute/Select to itself; Components cannot assign them, and DAW mode does not change that while a custom mode is
  active (measured, see `docs/reference/lcxl3-daw-mode.md`).
- The button LEDs show the colours stored in the custom mode; the app cannot show a state on them.
- The Sound Lab machines (whole LC per machine, Track = machine, Page = preset, a Shift layer) and later live-track
  ideas need those buttons, the LEDs and the screen.

## User Stories

1. **As a player, I plug in the LC and play as today.** The engine switches the LC into DAW mode by itself; knobs,
   faders and buttons do what they do now, in every SC track, with one or two LCs.
   - No Components work and no mode press needed before playing.
   - Knob feedback (every LC holds the shared value), fader pickup and the Mode 1 / Mode 2 fader handover behave as
     today.
2. **As a player, I switch between Mode 1 (Jojo) and Mode 2 (Jonas) on the LC** with one button, and see on the LC
   which mode is active.
   - The screen shows the mode; column 8 stays the same control in both modes (today's aliases).
3. **As a player, I see the same button colours as today.**
   - The bottom buttons show the colours of today's custom modes, per mode.
4. **As a player on stage, an accidental press of Mode does not break the track.**
   - If the LC leaves the DAW page (Mode + a bottom button), the engine either brings it back or keeps reading the
     custom mode it went to; the track keeps reacting either way.
5. **As a player, quitting the app leaves the LC usable.**
   - On quit the engine switches DAW mode off; the LC is back in Custom Mode 1 (measured). After a crash a power
     cycle does the same.

## Functional Requirements

- FR1 **Enable and leave.** On connecting an LC (also plugged in later, the 2 s scan): send `9F 0C 7F` to its DAW In,
  then select a DAW page (ch 7 CC 30 = 1 or 2; which one is decided in the first task, both behaved the same). On
  engine exit and on a disconnect-free shutdown (`ShutDown`): `9F 0C 00`. Off for test runs that mute feedback
  (`lcFeedback == false`, `CE_SC_MUTE`), so agents never move a user's device.
- FR2 **Input.** The LC's DAW Out port becomes an `lc` port (today it is ignored, `~ce.midiKinds`). Knobs ch 16 CC
  13-36, faders ch 16 CC 5-12, bottom buttons ch 1 CC 37-52: in Mode 1 they are passed on unchanged, in Mode 2 + 48
  (column 8 through the existing `ccAlias`), into the existing `~ce.midiCC` path (knob value scaling, pickup, presses).
- FR3 **Mode per device.** Each LC has its own mode (two LCs: one can be on Jojo, the other on Jonas). One button
  switches it; proposal: Page ▲ = Mode 1, Page ▼ = Mode 2 (to confirm in the first task). A switch runs today's
  `lcModeSwitch` fader handover and resends that device's knob values for the new mode (knob feedback).
- FR4 **Knob feedback** goes to the DAW In on ch 16 (encoders take a position from the host, guide p. 10) with the
  numbers of the device's current mode (Mode 2: − 48). Never on ch 1: there CC 13-36 sets knob LED colours.
- FR5 **LEDs.** On enable and on every mode switch the engine colours the 16 bottom buttons and the knob LEDs like
  today's custom modes (colours read from the `.syx` files or measured once; ch 1 CC <index> <palette colour>, or RGB
  sysex `F0 00 20 29 02 15 01 53 <index> R G B F7`). No new LED meanings in this PRD.
- FR6 **Screen.** The stationary display shows the mode (`jojo` / `jonas`) and the track name; lower-case labels.
  Configure `F0 00 20 29 02 15 04 35 <config> F7`, text `… 06 35 <field> <ascii> F7` (measured 2026-11-23).
- FR7 **Mode press on stage.** The Mode button cannot be locked (no feature control for it, guide pp. 16-17), so the
  engine defends in layers:
  - **Auto-return:** the engine keeps the page each LC should be on; a mode report (DAW Out, ch 7 CC 30) of anything
    else is answered at once with CC 30 = that page, then a full repaint (LEDs, screen, knob positions).
  - **Fallback while away:** the custom-mode port (MIDI Out) stays connected as today, so in Custom Mode 1 or 2 the
    track keeps reacting through the old path.
  - **Watchdog:** the 2 s scan queries each LC's mode (ch 8 CC 30, p. 16) and corrects it, if the LC answers in DAW
    mode (measured in the spike; without an answer the watchdog is dropped).
  - **Setup:** the docs tell the player to load the two `.syx` modes into every custom slot (odd = Mode 1, even =
    Mode 2) and to cover the Mode button for gigs.
- FR11 **Driver layer.** Each device kind gets a driver in `sc/lib/` that turns its MIDI into the engine's controls
  and the engine's output (knob positions, LED colours, screen text) into its MIDI: `lcxl3-daw`, `lcxl3-custom` (the
  fallback, today's path), `launchkey-mk4` (today's path, unchanged). The engine's control ids stay today's CC numbers
  (5-100) for knobs, faders and bottom buttons, so takes, auto-perform scripts, the web view and `@ctl` texts do not
  change. The DAW-only buttons get named ids (`page-up`, `page-down`, `track-left`, `track-right`, `solo`, `mute`,
  `record`, `play`, `shift`, `small`), passed to the UI as presses (FR9). A new controller later = a new driver.
- FR12 **Screen parity.** In custom mode the LC shows the name and value of a control while it moves; in DAW mode
  the host must draw that. On every knob or fader move the engine writes the control's `@ctl` name and value on the
  temporary display (timeout ch 7 CC 113).
- FR13 **Persistent settings.** The encoder curve (ch 7 CC 121) and the global MIDI channel (CC 100) persist across
  power cycles and can be changed from the device's menus. If the spike shows a menu reachable in DAW mode, the engine
  sets both on connect to the values the tracks expect.
- FR8 **Fallback.** The custom modes and their `.syx` files stay; a device without the app (strudel.cc, another
  program) uses them as today. If DAW mode cannot be enabled (no DAW port, no mode report within a second), the engine
  logs it and uses the custom-mode path.
- FR9 **The other buttons** (Page ▼/▲ beyond FR3, Track, Solo/Arm, Mute/Select, Record, Play, Shift, the small
  button, CC 104) are read and passed to the UI as presses, but do nothing yet. Their jobs come with the next PRD.
- FR10 **Player.** The MIDI panel lists the LC once (not two ports); the Live view shows the mode per device. The
  auto-perform path (OSC, `sc-auto.mjs`) is unchanged.

## Non-Functional Requirements

- No audible or felt change in any track: same values, same pickup, same latency (both ports are USB MIDI).
- Every message to the device goes to its DAW In; nothing is sent to the DIN outs.
- Messages per knob turn stay as today (one feedback CC per changed value and device).
- English, lower-case labels on the screen and in the panel.

## Success Criteria

- Every SC track (`sc/tracks/`) loads and reacts to knobs, faders and its Pattern buttons with one and with two LCs in
  DAW mode, in both modes (manual check with the device + `npm test` with simulated DAW ports).
- `tools/sc-test/run.scd` covers: DAW port detected as `lc`, Mode 2 offset, knob feedback channel and numbers, mode
  switch fader handover, fallback when no DAW port answers, auto-return after a simulated mode report. Feature tests,
  no device needed.
- An accidental Mode + bottom button press during a track costs at most that one button press: the LC is back on its
  DAW page with its LEDs, screen and knob positions before the next bar (manual check with the device).
- Quit the app: the LC is in Custom Mode 1 and strudel.cc works with it.
- One rehearsal with both LCs (Jojo + Jonas) without a mode or pickup surprise.
- `docs/reference/lcxl3-daw-mode.md`, `midi-layouts/devices.md`, `docs/features/controllers.md` and `CLAUDE.md`
  (Controller mapping) describe the new setup.

## Constraints & Assumptions

- Measured on one device (LCXL3 Jojo, firmware as of 2026-11-23); the second LC is assumed to behave the same, checked
  in the rehearsal.
- DAW Out sends ch 7 CC 31 next to CC 30 on mode changes; meaning unknown, ignored.
- The "DAW Fader Pickup" feature (ch 7 CC 70) must not delay faders, because the engine does its own pickup; its
  default is measured in the first task and switched off if needed.
- The engine stays the only thing that talks to the LCs; the player page does not open the DAW port (the app window
  has no Web MIDI anyway).

## Out of Scope

- Jobs for Page (beyond the mode switch), Track, Solo/Arm, Mute/Select, Record, Play, Shift and CC 104; new LED
  meanings; screen content beyond mode and track: next PRD (live tracks and Sound Lab together).
- Relative encoder mode (could replace the knob value scaling): only if the next PRD needs it.
- The Strudel player engine and the producer (deprecated, `DEPRECATION.md`).
- The Launchkey (unchanged).
- Removing the custom modes or their `.syx` files. They stay as the fallback; once DAW mode is approved after the
  rehearsal, they get an entry in `DEPRECATION.md` (fallback only, no new features; user decision 2026-11-28).
- Shift layers, pages beyond Mode 1 / 2, set mode, automations: later phases of the set-mode plan, each with its own
  PRD after this epic is merged.

## Dependencies

- Novation, *Launch Control XL 3 Programmer's Reference Guide* v1.0 (link and pages in
  `docs/reference/lcxl3-daw-mode.md`).
- `sc/lib/controls.scd` (MIDI input, knob feedback, pickup, mode switch), `sc/lib/ui.scd` (UI messages),
  `tools/sc-test/run.scd`, the player's MIDI panel.
- Device time with both LCs for the first task and the rehearsal.
