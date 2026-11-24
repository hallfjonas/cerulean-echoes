---
name: alt-rebuild
status: backlog
created: 2026-11-24T14:49:50Z
updated: 2026-11-24T14:49:50Z
progress: 0%
prd: .claude/prds/alt-rebuild.md
github: (not synced; issue sync is off, see CONTRIBUTING.md)
---

# Epic: alt-rebuild

## Overview
Build track `sc/tracks/018-alt/`: an ALT-style instrument (5 oscillators + noise, Alter, Movement, 4 × 16 pin matrix)
on the SC engine, played with one LC XL 3 in DAW mode with its own 14-bit custom mode and a Launchpad MK3 as the pin
matrix. Device facts come first, because two design choices (Shift on the LC, 14-bit faders) depend on them.

## Architecture Decisions
- **Track, not a stem track.** One hand-written `.scd` like 007-010; the ALT's routing does not fit one-column stems.
- **Modulation on control buses.** Each source writes a bus; each destination reads `base + Σ(pin × source)`. A pin
  matrix is a 4 × 16 array of 0/1 in the track state, so a pin toggle is a `set`, no synth rebuild. FM/AM (LFO high
  range) needs audio-rate paths for Freq and Amp; the rest stays control rate.
- **Shift as a layer in the control code**, not a second custom mode: knobs read `layer` and SC sends the layer's
  values to the encoders on Shift press / release; shifted faders use the existing pickup.
- **DAW mode from the `lcxl3-daw-mode` epic** (PRD in PR #112, test results in PR #111): this epic reuses its
  lifecycle and guard, it does not build its own. Route A (DAW pages: all buttons, 7-bit faders) or B (own custom mode
  in slot 3 with 14-bit NRPN faders, only Shift / Record / Play / one small button) is chosen in 001.
- **14-bit faders as NRPN** (route B): SC assembles NRPN (CC 99/98/6/38) into one value per fader. Modes 1 and 2 and
  the other tracks stay 7-bit.
- **Launchpad as a new device kind** in the device table of `sc/lib/controls.scd` (programmer mode, notes → pins,
  LED out with a rate cap). Generic enough for a later track, but no generic "grid framework".
- **Scales as data** (cents per step, 15 presets) in the track; quantizer shared by OSC2-5.
- **Exception list:** ALT labels instead of Brightness / Space / Level / Pattern; column 8 not global; no Pattern
  button (test skip). Recorded in CLAUDE.md "Labels" when the track lands.

## Technical Approach

### SC engine (`sc/lib/`)
- `controls.scd`: Launchpad row in the device table; NRPN assembler; DAW-mode enable/disable/guard and the DAW-port
  buttons as named controls; layer-aware encoder feedback.
- `sc/sounds/`: alt-osc (sine VCO / tri-saw DCO), alt-noise, alt-alter (2 filters in series + ripples), alt-delay
  (stereo, BBD-like, more), alt-movement (LFO, S&H, envelope follower).

### Track (`sc/tracks/018-alt/`)
- `018-alt.scd`: layout, `@ctl` texts (ALT names), shift layers, pin state, arp, scales, start state.
- Clock: LFO sync and Random multiples from the engine's tempo clock.

### Player (`tools/trajectory/`)
- Live view: LC and Launchpad side by side; pins grid with source colours; Shift state; status box shows tonic,
  scale, echo time.

### Devices and docs
- `midi-layouts/lcxl3-mode3-alt.syx` (Components export), `midi-layouts/devices.md` (Launchpad, slot 3, DAW mode),
  `docs/reference/lcxl3-daw-mode.md` (test results), `docs/features/alt.md` (how to play).

## Implementation Strategy
1. Measure (001), then decide the fallbacks with the user. Nothing else starts before 001.
2. Engine pieces in parallel: LC input (002), Launchpad (003), sounds (004).
3. Movement + matrix (005), scales (006), then the track (007) that wires everything.
4. Live view (008) and docs/tests (009) at the end.

## Task Breakdown Preview
- 001 Device tests: DAW mode, NRPN faders, Launchpad MK3 (blocking)
- 002 LC input: DAW mode, NRPN 14-bit, Shift layer
- 003 Launchpad: device, pins, LEDs
- 004 Sounds: oscillators, noise, Alter
- 005 Movement and the pin matrix (incl. Arp)
- 006 Scales and tonic (data + quantizer)
- 007 Track 018-alt: layout, start state, `@ctl`
- 008 Player: LC + Launchpad live view
- 009 Docs and feature tests

## Dependencies
- The `lcxl3-daw-mode` epic (1:1 switch, PR #112) before 002.
- 001 → all. 002, 003, 004 parallel after 001. 005 needs 004. 006 parallel to 005. 007 needs 002-006.
  008 needs 003 and 007. 009 last.
- Hardware access for 001, 002, 003 and the final check (the user plays).

## Success Criteria (Technical)
- `npm run verify-sc -- sc/tracks/018-alt/018-alt.scd` and `npm test` pass.
- NRPN fader → one value 0-16383, no jumps when coarse and fine halves arrive.
- DAW mode is off after track change, player stop and SC kill (tested by hand, recorded in 009).
- Every pin toggle audible within one control period; Launchpad LED rate ≤ 20/s.
- Without LC and Launchpad the track loads and sounds (start state).

## Estimated Effort
About 9 working sessions: 001 short but needs the user at the devices; 004 + 005 the biggest (sound design and the
modulation graph); 008 medium (new grid view).
