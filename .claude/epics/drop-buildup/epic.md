---
name: drop-buildup
status: backlog
created: 2026-11-15T16:35:35Z
updated: 2026-11-15T20:30:00Z
progress: 0%
prd: (none, written directly from the user's notes)
github: (will be set on sync)
---

# Epic: drop-buildup

## Overview

Today the global **Break** button (column 8, button 2) is a plain toggle in every live track (007, 008, 009, 010):
first press takes the low end out at the next bar, second press brings everything back on the one. The build-up
before the return is manual: Tension knob (echo, reverb, open filters, snare roll) plus a held riser on Jojo's side.
Every drop sounds the same and needs three hands to sound good.

This epic makes the drop part of the instrument: the button itself picks a break length and a build-up figure, so a
single press (or two) produces a drop that varies and grows in tension over a set. Two interaction models are on the
table and are compared by ear on a lab board before one goes into the tracks.

### Variant 1: rotating behaviour (like the Pattern buttons on other columns)

Each press runs a complete, self-timed drop and then returns on its own. Every press advances to the next, longer and
richer recipe:

| Press | Low end out | Build-up | Return |
|---|---|---|---|
| 1st | 1 cycle | none | back on the one |
| 2nd | 2 cycles | none | crash on the one |
| 3rd | 4 cycles | a sound swells over the last 2 cycles | back on the one (crash) |
| 4th+ | open: 8 cycles, snare roll, filter sweep, ... | | |

After the last recipe it wraps (or holds the last one; see Open Questions).

### Variant 2: duration-driven build-up

Keeps today's two-press toggle (press = low end out, press = back in). The time the break has run when the second
press lands picks the build-up: the longer the break, the more complex and tense the build-up that plays between the
second press and the drop. A short break returns almost dry; a long break gets riser + roll + crash.

Consequence: in Variant 2 the second press no longer returns on the next bar but starts a build-up of N bars, and the
drop lands after it. The live view must show this countdown.

## Architecture Decisions

- **One shared drop engine, two front-ends.** Both variants need the same parts: a break of a given length, a set of
  build-up layers with a start offset relative to the drop, a crash on the one. Build that once as a `dropPlan`
  (`{ breakBars, buildBars, layers, crash }`), and write the two variants only as different ways of choosing the plan.
  This keeps the lab comparison fair and the winner cheap to port.
- **Bar-aligned scheduling stays on `barLatch`.** Breaks already switch at the next bar line via `barLatch`; the drop
  engine extends it with a scheduled end bar (`dropAt`) instead of adding a new timing mechanism.
- **State in closures created once, queried via `stateTaps`.** Press count (Variant 1) and break start bar
  (Variant 2) live in closures created once per control and tapped every tick, per the CPU rules in `CLAUDE.md`, so
  presses are not lost while stems are gated.
- **Build-up layers are gated.** Every build-up layer is wrapped in `gate()` on "build-up active", so it costs no CPU
  outside a drop.
- **Tension knob stays.** The manual Tension knob keeps working on top; the automatic build-up adds to it, it does not
  replace it.
- **Sounds per track.** The engine is shared; the crash and swell sounds are chosen per track (909 crash in 008,
  softer cymbal/noise swell in 007/010) and must pass check-sounds.mjs.
- **Labels.** The button keeps the name `Break`; its `@ctl` text is one short line describing the new behaviour. The
  status box and the LC view show the recipe / build-up level and the bars left to the drop.

## Technical Approach

### Engine (shared helper code, copied into each track)
- `dropPlan` recipes: an ordered list of plans from short/dry to long/rich.
- Drop scheduler: on trigger, set break start at the next bar, compute drop bar = start + breakBars (Variant 1) or
  second-press bar + buildBars (Variant 2), expose patterns `breakOn`, `buildPhase` (0 → 1 across the build-up) and
  `dropHit` (true on the first bar after the drop).
- Build-up layers: swell (noise or pad through an opening filter, gain ramp on `buildPhase`), snare roll (reuse
  Tension's roll, driven by `buildPhase`), crash on `dropHit`. 007 has no `tensionRoll`: its roll layer is new
  (a soft roll that fits the ambient track) or 007 gets swell + crash only.

### Front-ends
- Variant 1: `cycleButton`-style press counter → recipe index; each press schedules a self-ending break.
- Variant 2: toggle as today; on the second press, map elapsed break bars → recipe (e.g. < 2 bars: dry,
  2-7: crash, 8-15: swell + crash, 16+: swell + roll + crash) → schedule build-up, then drop.

### Live view and status box
- Break row shows: `Beat off · 3 bars` / `Build 2/4 → drop` / `Next: 4 bars + swell` (Variant 1).

### Infrastructure
- Lab board in `lab/tools/drop-lab/`: one simple groove (kick, bass, hats, pad) with both variants on two buttons,
  plus `feedback.md` for the rounds.
- Layout sheets and `.syx` regenerate via the existing hook once `@ctl` texts change.

## Implementation Strategy

1. Build the engine and both variants on a lab board, not in a track. Play them in rounds, record the verdict in the
   board's `feedback.md`.
2. Port the winner (or a hybrid) into one track first (008, the clearest drop), verify with `/strudel-optimize`
   that nothing else changes when the button is not pressed, and with check-sounds.mjs.
3. Roll out to 009, 010, 007 with per-track sounds; these are independent of each other and can run in parallel.
4. The set (011) is generated from frozen dual versions and is out of scope here.

Risks: the self-ending break of Variant 1 takes control away from the player (cannot hold a break longer than the
recipe); Variant 2 delays the drop after the second press, which can feel late. Both are what the lab round should
judge.

## Task Breakdown Preview

1. **Drop engine on a lab board**: `dropPlan`, scheduler on `barLatch`, `breakOn` / `buildPhase` / `dropHit`
   patterns, a minimal groove to test against.
2. **Build-up layers**: swell, snare roll on `buildPhase`, crash on `dropHit`; gated; sounds checked. (depends on 1)
3. **Variant 1 front-end**: rotating press counter and recipe table. (depends on 1; parallel with 4)
4. **Variant 2 front-end**: toggle with elapsed-time → build-up mapping. (depends on 1; parallel with 3)
5. **Status box and LC view**: break row with bars left, build-up level, next recipe. (depends on 3, 4)
6. **Lab round and decision**: play both, write `feedback.md`, pick the winner or a hybrid. (depends on 2-5)
7. **Port to 008**: engine + winning front-end + `@ctl` text; `/strudel-optimize` and check-sounds.mjs. (depends on 6)
8. **Port to 009, 010, 007**: per-track crash/swell sounds, guides updated. (depends on 7; the three in parallel)

## Dependencies

- `barLatch`, `cycleButton`, `gate`, `stateTaps` helpers already in each one-file track.
- Tension knob's snare roll (`tensionRoll`) in 008/009/010 as the base for the roll layer; 007 has none.
- Crash / noise samples that load on strudel.cc (samples/sounds.json, removed 2026-11-22 with sc-migration 010), e.g. `rolandtr909_cr` already used in 008.
- `tools/strudel-sim` (/strudel-optimize, check-sounds.mjs: both removed 2026-11-22 with sc-migration 010) for verification.
- Layout hook (`lcxl-layout`) to regenerate PDFs and `.syx` after `@ctl` changes.

## Success Criteria (Technical)

- One press of Break (Variant 1) or two presses (Variant 2) produce a complete drop with no other hand on the
  controller: break, build-up, return exactly on bar 1.
- Drops are audibly different from press to press / from short to long breaks; at least 3 distinct recipes.
- With Break never pressed, `/strudel-optimize` shows the track event-identical to its current version.
- No dropouts: build-up layers are gated, CPU check in `tools/strudel-sim` no worse than today.
- Every new sound passes check-sounds.mjs.
- Status box and LC view show what the button will do next and how many bars remain to the drop.
- Tension knob still works and stacks on the automatic build-up.

## Open Questions

- Variant 1: after the last recipe, wrap to the first or stay on the longest? Can a long-press cancel / reset?
- Variant 2: should the build-up start on the second press (drop later) or be pre-rolled so the drop still lands on
  the next bar (only possible if the build-up is decided in advance, which Variant 2 cannot know)?
- Hybrid: Variant 2 timing with Variant 1's recipe table as the mapping?
- Who triggers in a duo set: still Jonas' column 8, or also Jojo's?

## Estimated Effort

- Lab board, engine, both variants, live view: 2-3 sessions.
- Lab round and decision: 1 session with both players.
- Port to 008: 1 session; 009/010/007: 1 session each, parallelisable.
- Total: about 6-8 sessions.

## Order with other epics

- `lk-pad-knobs` also changes the live tracks / LC view: merge one at a time.
