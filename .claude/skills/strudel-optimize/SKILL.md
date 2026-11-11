---
name: strudel-optimize
description: Make a dense Strudel track cheaper to compute without changing its sound (gate silent stems/layers, mapping as data), and prove it with an event-by-event comparison in Node. Use when a track drops out, the CPU is high, or a track should be restructured "without audible changes".
---

# Strudel optimize

Goal: only audible events get computed. The sound and every MIDI control must stay identical.

## Steps
1. Write the result into a **new file** (`tracks/NNN/NNN-lean.strudel`); never touch the original.
2. Mapping as data: `col(n)` / `col2(n)` → `{ hpf, lpf, char, level, btn }` instead of scattered `cc(n)`.
3. Gate what is silent, using the helpers from `tracks/006/old/006-lean.strudel`:
   ```js
   const gate  = (cond, pat) => cond.fmap(on => on ? pat : silence).innerJoin()
   const above = (sig, x) => sig.fmap(v => v > x)
   const below = (sig, x) => sig.fmap(v => v < x)
   const and   = (a, b) => a.fmap(x => y => x && y).appLeft(b)
   ```
   - Stems: `strip(stem, { hpf, lpf, level, trim, withGlobalHpf, levelCtl })`. Keep each stem's exact chain
     (gain vs postgain, which filters it has); different control order is fine because each control writes its own key.
   - Crossfades: `fadeMain` > 0 iff knob < 1, `fadeExtra` > 0 iff knob > 0, `ramp(d, from, to)` > 0 iff d > from.
   - Only gate where the gain is exactly 0. Anything else (e.g. lpf 0 Hz) is "practically silent": list it.
4. Stateful closures (`cycleButton`, `coupled`, `lastMoved`): create once per control outside gated code and add them
   to a `stateTaps` stack in the master: `stack(...).filterValues(() => false)`.
5. Safety net at the end of the master: `.filterValues(v => (v.gain ?? 1) * (v.postgain ?? 1) > 0)`.

## Verify (required)
```sh
cd tools && npm install            # once
node strudel-sim/compare.mjs ../tracks/NNN/NNN.strudel ../tracks/NNN/NNN-lean.strudel [--ignore-cutoff0]
```
Runs fixed positions (all 0 / 0.5 / 1, random snapshots) and two "rides" (all controls moving, buttons tapped)
and prints events per cycle, query time per cycle, and `identical: true|false` for the audible events.
Exit code 0 = identical. Any difference: explain it or fix it. Report the before/after table to the user.

## Notes
- `innerJoin` queries the inner pattern over the outer hap's part (the scheduler span), so structure and timing come
  from the stem; no double triggers (the compare counts duplicate onsets on both sides).
- The harness evaluates the master = last top-level `stack(` in the file. Mocked: `midin`, `slider`, `setcpm`.
- The remaining cost at full density is per-event control evaluation (many patterned controls, e.g. `wobble`).
