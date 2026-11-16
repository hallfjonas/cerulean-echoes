---
name: vis-live-mapping
status: backlog
created: 2026-11-16T16:05:25Z
updated: 2026-11-16T16:05:25Z
progress: 0%
prd: .claude/prds/vis-live-mapping.md
github: (will be set on sync)
---

# Epic: vis-live-mapping

## Overview

Make the player's dots follow the live sound: y = pitch shifted by the filter (Brightness moves dots), size and glow =
absolute loudness in the mix (fader and Master included, fader 0 hides the dot), hue = role with a tint from
brightness, space and drive. Proven by a Node check that plays a track with scripted knob moves.

## Architecture Decisions

- **Mapping becomes a pure function.** `strudel-source.mjs` today mixes EventSource, timers and mapping. Extract
  `mapEvent(value, stemState) → { x, y, z, e, tint }` (new `mapping.mjs`) so the Node check and the browser use the
  same code.
- **Line format extended, not changed.** New optional fields on stem lines: `b` brightness 0…1, `s` space 0…1,
  `d` drive 0…1, `gone` 1 when hidden. `x/y/z/e/on` keep their meaning (e now absolute). The audio path ignores the
  new fields; the renderer falls back to today's colour when they are missing.
- **Loudness scale.** e = clamp((20·log10(gain·postgain·velocity) + 36) / 42): −36 dB → 0, +6 dB → 1 (to be tuned
  against `npm run audibility` levels). Level 0 → e = 0 → hidden; no per-stem peak.
- **Filter on y.** `yHz = base`; if `lpf < base·2` pull down towards `lpf`; if `hpf > base/2` push up towards `hpf`
  (geometric blend), so a closed low-pass on hats sinks them and opening it lifts them.
- **Layers.** Per stem keep the last events of a ~50 ms window; position from the loudest one, so octave layers do not
  flicker.
- **Colour.** Hue from role (unchanged `DECK_ROLES`); lightness += brightness, saturation −= space (washed out = wet),
  hue shift towards warm/red with drive (± 25°). One helper used by deck, ocean and clean.

## Technical Approach

### Frontend Components
- `mapping.mjs` (new): `frequencyOf`, filter-shifted y, absolute e, tint inputs, layer window.
- `strudel-source.mjs`: uses `mapping.mjs`; emits `gone` and tint fields; no per-stem peak.
- `render.mjs`: no glow floor; skip comets with `gone` or e below threshold (all three looks); radius and glow from
  absolute e; `tint()` helper; legend in labels mode.
- `make-tapped.mjs`: `trajectoryKeys` gains `delay`, `delaytime`, `size`, `shape`, `distort`, `crush`, `coarse`,
  `orbit`.

### Backend Services
- None. `server.mjs` relays lines unchanged.

### Infrastructure
- Node check `tools/trajectory/check-mapping.mjs`: runs a live track through `strudel-sim` (scenario harness) with CC
  moves, feeds the haps through the tapped `trajectoryTap` path into `mapping.mjs`, asserts directions. Added to
  `npm run verify`.
- Auto-perform script `perform/<track>/knob-sweep.json` per live track: Brightness, Space, fader sweeps per column.

## Implementation Strategy

1. Audit first: confirm what Brightness, Space and Level write into the events in 007–010 (`npm run scenario --
   --events`). If Space is on a bus, decide how the tap reads it (bus value tagged on the stem, or orbit lookup).
2. Extract the mapper and build the check against today's behaviour (it fails on Brightness/fader → the target).
3. Change mapping (y, e, layers), then the renderer (hide, size, colour) — the two can run in parallel once the line
   fields are fixed.
4. Sweep scripts, README, Help text; Jonas checks it in the player.

## Task Breakdown Preview

| # | Task | Depends | Parallel |
|---|---|---|---|
| 1 | Audit: what Brightness / Space / Level / Drive set in the events of 007–010; decide tap source for Space; fix line fields | — | — |
| 2 | Extract `mapping.mjs` + `check-mapping.mjs` (Node, scenario-driven), wired into `npm run verify` | 1 | — |
| 3 | Tap more keys in `make-tapped.mjs` (and Space source from task 1) | 1 | with 2 |
| 4 | Mapping: y = pitch shifted by filter, absolute e, layer window, `gone`, tint inputs | 2, 3 | — |
| 5 | Renderer: hide at 0, size + glow from absolute e (deck, ocean, clean) | 4 (fields) | with 6 (same file, separate functions; sequence if conflict) |
| 6 | Renderer: role hue + tint from brightness/space/drive, legend in labels mode | 4 (fields) | with 5 |
| 7 | `knob-sweep.json` per live track, README "Trajectory" mapping table, Help text; frame-time and sound-unchanged checks; Jonas review | 5, 6 | — |

## Dependencies

- `tools/strudel-sim/scenario.mjs` / `harness.mjs` for the Node check.
- Shared `strip()` in `tools/shared/` (Brightness = `lpf`, Level = `postgain`).
- `perform/` + `check-perform.mjs` for the sweep scripts.

## Success Criteria (Technical)

- `check-mapping.mjs` passes on 007–010: Brightness 0→1 on hats raises y ≥ 0.05; fader 0 → `gone` within 1 s;
  fader 0.3 vs 1 → e differs by the dB scale; Space 0→1 raises the space input; layers do not flip y within a stem.
- Tapped vs untapped track identical event by event (`npm run compare`).
- Frame time in fullscreen +≤ 1 ms; audio-analysis path still renders.

## Estimated Effort

7 tasks, ~2–3 sessions. Task 1 is short but gates the rest; 5 and 6 share `render.mjs`.
