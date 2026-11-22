---
name: auto-perform-steering
description: Auto-perform beyond the script player - measure what plays per bar, steer it along a target energy curve, open loop and closed loop; pilot 010 Journey
status: backlog
created: 2026-11-18T05:50:44Z
---

# PRD: auto-perform-steering

Source: the player vision draft (`git show 1bd1438:docs/player-future.md`), idea 2 (levels 1 and 2). Level 3 (an LLM agent per phrase) is out of scope.

## Executive Summary

The script player (`tools/trajectory/autoperform.mjs`) plays control moves bar by bar into the virtual controller
`LCXL3 Auto`. It is open loop and hand-written: every move is a step, and nobody knows whether the arc the script
was written for ("quiet intro, slow build, peak, breakdown") is the arc that sounds.

This epic adds three things on one measurement layer:

1. **Measure.** One series per bar of what the player plays: energy, density, brightness, width, build, section. Live
   in the player and offline from a file. Drawn as curves, with the target curve over them.
2. **Open loop.** A target curve in the perform script (`curve`, bar → energy) is turned into control steps through a
   per-track control map, measured once by a sweep tool.
3. **Closed loop.** A Steer switch in the player: each bar it compares measured energy with the curve and nudges the
   continuous controls until they match. A human who grabs a control always wins.

Pilot: `010-ambient-house` with the `journey` script. Second track for the "one curve, any track" check: `009-house`.

## Problem Statement

- **No number for the arc.** A performance is judged only by ear, start to end. `journey.json` (130 bars, 11 sections)
  has an `intent` per section, but nothing shows whether "Build" builds or "Peak" is louder than "Groove".
- **Scripts are written move by move.** A new performance means deciding every CC value and ramp by hand. Saying
  "build from bar 28 to 36" is not possible.
- **A script fits one track only.** CC numbers and values that make 010 lift do not make 009 lift. A shape cannot be
  reused.
- **Knob effects are not known as numbers.** How much Tension raises energy, or Fog lowers brightness, on a given
  track is only known by ear. Steering needs this.
- **The analysis exists but does not speak in bars.** `analyse.mjs` gives five bands at 30 frames per second plus a
  pulse; nothing turns this into one value per bar on one scale for every track.

## User Stories

**US1 — See the arc.** As the user, I play `journey` in the player and see energy, density, brightness and width as
curves per bar, with the sections as bands behind them.
- Acceptance: a curve view in the player (toggle key and Settings entry) draws one point per bar while the track
  plays, live from the audio output; it works for every catalogue entry, with or without a script.
- Acceptance: the same series comes out offline (`npm run meta -- <audio or script>`) as JSONL, one line per bar.

**US2 — Compare with the intent.** As the user, I write a target curve into a perform script and see it drawn over
the measured energy, with the gap per section.
- Acceptance: `curve` in the script (points `[bar, energy]`, linear between them) is drawn as a second line; after the
  run the view lists per section the mean gap (target − measured).
- Acceptance: `check-perform` checks the `curve` field (bars inside `bars`, values 0..1, rising bar order).

**US3 — Know what a control does.** As the user, I run one command and learn, per track, what each continuous
control does to energy, brightness, density and width.
- Acceptance: `npm run sweep -- <track>` writes `tools/trajectory/perform/<track>/control-map.json`: for each swept
  control, the measured series at control values 0, 0.25, 0.5, 0.75, 1 around a base state, plus a `steer` flag.
- Acceptance: a readable summary is printed (one line per control: Δenergy, Δbrightness 0 → 1).

**US4 — Curve to script (open loop).** As the user, I write sections and a curve, run one command and get a script
that plays in the player.
- Acceptance: `npm run curve -- <script.json>` writes a new script beside it (`<name>-curve.json`, never overwrites),
  keeping the source's sections and its structural steps (Chapter, Break, Pattern presses, keys, pads) and replacing
  the continuous-control steps by ones derived from the curve and the control map.
- Acceptance: the new script passes `check-perform` and plays in the player.

**US5 — Steer (closed loop).** As the user, I switch Steer on during auto-perform (or alone, on a track with a
curve-only script) and the player keeps the measured energy on the curve.
- Acceptance: Steer moves only controls marked `steer` in the control map, through `LCXL3 Auto`, at most one bar
  ramp per move, with a limit per bar on how far a control moves.
- Acceptance: the status box shows Steer on/off, target vs measured energy of the current bar, and which control it
  moved last.
- Acceptance: when I move a control on a real Launch Control, Steer leaves that control alone for 8 bars after my last
  move of it and steers with the others.

**US6 — One curve, two tracks.** As the user, I run the same curve on 009 after a sweep of 009, and the arc follows it
without writing any 009 steps by hand.

## Functional Requirements

- **FR1 Per-bar series** (`meta.mjs`, same code in the browser and in Node), from `analyse.mjs` frames and the bar
  clock (1 cycle = 1 bar in every live track):

  | Quantity | Definition (first version, tuned in the epic) |
  |---|---|
  | energy | smoothed short-term loudness of the mix on one fixed scale for every track, weighted with density; 0..1 |
  | density | onsets per bar, total and per band |
  | brightness | spectral centroid and the share of presence + air bands; 0..1 |
  | width | L/R decorrelation and pan spread; 0..1 |
  | build | slope of energy and brightness over the last 4 bars; "building" = rising for at least 2 bars |
  | section | Chapter and Break state, read from the controller state (`midi.mjs`), not from audio |

- **FR2 Live tap.** The player reads the master output of the Strudel engine (stereo) without changing the sound.
  Measurement can be switched off; off means no analysis runs.
- **FR3 Offline.** `npm run meta -- <file>`: an audio file (via `analyse-file.mjs`'s decoder) or a perform script
  (rendered offline through the strudel-sim harness, optional bar window) → per-bar JSONL and a printed table per
  section.
- **FR4 Curve view** in the player: energy, density, brightness, width per bar; target curve; section bands;
  current bar marker; per-section gap after a run. Lines are drawn from the series, not re-measured.
- **FR5 Curve in the script.** Optional field `curve: { energy: [[bar, value], …] }` in script v2; `check-perform`
  validates it. Other quantities in `curve` are allowed later but not used now.
- **FR6 Sweep tool.** Offline, one control at a time, five values, around a base state (default: faders and Master
  up, the rest at 0; `--base` like `npm run measure`). Controls swept: the global column (Fog, Thin, Tension, Master)
  and row 1 / row 2 per column by default; `--controls` to choose. Writes `control-map.json`, marks as `steer` the
  continuous controls whose energy effect is monotonic and larger than a threshold.
- **FR7 Curve → script.** For each bar, choose values of the steerable controls whose predicted energy (from the
  map) is nearest the curve, with ramps between changes; structural steps of the source script stay as they are.
- **FR8 Steer loop.** Once per bar: smoothed measured energy vs curve; inside a dead band nothing moves; outside it,
  the steerable control with the largest effect that is free (not human-held) moves toward the target by a step
  limited per bar, with a one-bar ramp. Script steps on a steered control are skipped while Steer is on; all other
  script steps play.
- **FR9 Human wins.** `midi.mjs` tells, per CC, whether a real port moved it after the auto port; Steer treats such a
  control as held for 8 bars after the last human move.

## Non-Functional Requirements

- **No dropouts.** With measurement on, 010 `journey` plays through in the player on the M2 with no audible dropout;
  the analysis cost per bar is measured and reported in the status box (debug) and stays below 5 % of a bar's time.
- **Stable numbers.** The per-bar series of the same offline render twice is identical; live vs offline of the same
  script differ by at most 0.05 in energy per bar (median over the run).
- **Bars, not seconds.** Every series, curve and move is in bars of the engine clock, so tempo changes do not shift
  anything.
- **Engine seam.** Steering writes only into `midi.mjs`; measurement reads one audio tap. Neither touches the track
  file. A track still plays pasted into strudel.cc.
- **Offline jobs are heavy.** Sweep and script renders run one at a time (machine rule), print progress, and accept a
  bar window so a test run is short.
- English, short labels in the view and status box (house rules).

## Success Criteria

1. Curve view on 010 `journey`: the user agrees in `perform/010-ambient-house/feedback.md` that the energy curve
   ranks the sections as they feel (Pad lowest, Peak among the highest, Break and Fog dips visible).
2. Offline vs live energy per bar: median absolute difference ≤ 0.05 on `journey`.
3. Open loop: `journey-curve.json` from a hand-written curve, rendered offline: measured energy within ±0.10 of the
   curve in ≥ 80 % of bars (the two bars after each curve corner excluded).
4. Closed loop on 010 with that curve: after settling (2 bars after a curve corner), ≥ 90 % of bars within ±0.08;
   no steered control reverses direction more than once per 4 bars.
5. Human wins: in a test where a real CC is moved at bar N, Steer sends no value for that CC in bars N..N+8.
6. One curve, two tracks: the same curve on 009 after `npm run sweep -- 009-house`, closed loop: ≥ 80 % of bars within
   ±0.10, no hand-written 009 steps.
7. `npm run verify` passes (perform scripts and curves checked).

## Constraints & Assumptions

- M2 Air, 16 GB, shared with other agents: one heavy job at a time; offline renders and sweeps are heavy.
- Assumption: the Strudel master output can be tapped in the player (the `recording-replay` epic needs the same tap;
  whichever epic lands first builds it, the other reuses it).
- Assumption: offline rendering of a whole mix with time-varying controls works in Node with the existing harness
  (`render.mjs` renders static controls today); a short spike proves it before the sweep and curve tools rely on it.
- Assumption: one control's effect measured around one base state is good enough to steer energy; interactions
  between controls are absorbed by the closed loop.
- "Energy" may not feel the same across tracks at the same number; the user's ear is the judge (success 1, 6).

## Out of Scope

- Level 3: an LLM agent that plans moves per phrase (follow-up epic; `llm-support` will read the per-bar state).
- Structural moves by the loop: Chapter, Break, Pattern buttons, keys and pads stay in the script.
- Drawing or editing the curve in the player; the curve is JSON in the script.
- Steering density, brightness or width to their own curves (measured and drawn only).
- The trajectory "good architecture" score and the crowd tap (idea 4), though they can reuse `meta.mjs`.
- A SuperCollider engine; set 011.
- Changing the sound, layout or `@ctl` names of any track.

## Dependencies

- `tools/trajectory/analyse.mjs`, `analyse-file.mjs` (bands, onsets, decorrelation; ffmpeg decoder).
- `tools/trajectory/autoperform.mjs` (`compile`, `valueChanges`, `createPerformer`), `check-perform.mjs`, script v2
  format and `perform/design-template.md`.
- `tools/trajectory/midi.mjs` (virtual port `LCXL3 Auto`, `setAuto`, last-moved-wins via `time`).
- `tools/strudel-sim/harness.mjs`, `render.mjs`, measure.mjs (`--base`), audibility.mjs (both removed 2026-11-22, sc-migration 010; LUFS reference for
  calibrating the energy scale).
- `recording-replay` epic (shared master tap; its WAV takes are valid offline input for `npm run meta`).
- `/auto-perform` skill: learns the `curve` field and the `curve` / `sweep` commands.
