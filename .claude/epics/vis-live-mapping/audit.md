# Audit: what the controls write into the events (task 1)

Date: 2026-11-16. Tracks: 007-ambient, 008-groove-techno, 009-house, 010-ambient-house (one-file versions on main).

## Method

`npm run scenario -- <track> --stems` confirms what is audible, but `--events` prints only note, n and gain, not the
filter or send keys. The keys were read with a small harness probe (same `load()` as the scenario tool, master tagged
with `_stem`): one LC, all faders 1, all knobs 0, then for 4 cycles each: row 1 all 1, row 2 all 1, row 3 all 1,
stem faders 0.3, global fader 0.5, stem faders 0. Median value per stem and key. Fader 0 on 009's lab columns
(Jonas 4-6) was checked separately with the scenario tool:
`--faders 1 --cc 57=0@4,56=0@4,58=0@4 --before 0-4 --after 5-9 --stems` → flute, brass, strings 0 audible events after.

## Strudel key names (important for the tap)

Strudel stores controls under their canonical name, not the alias used in the track:
`.lpf()` → `cutoff`, `.hpf()` → `hcutoff`, `.size()`/`.sz()` → `roomsize`, `.lpq()` → `resonance`.
The tap's `trajectoryKeys` lists `lpf` and `hpf`, which never occur in an event; `cutoff` is tapped, `hcutoff` is not.
So `frequencyOf`'s `hpf` argument is always undefined today: drums are never raised by a high-pass.

## Findings per control

| Control | What the events carry | Exceptions |
|---|---|---|
| Brightness (row 1) | `cutoff` (`strip()`: lpf × Fog/Tension, capped 18 kHz), e.g. 010 hats 3000 → 16000, 007 bass 80 → 2000 | Sub (008/009/010): gain of the triangle layer, no filter. 007 wood: FM index, `cutoff` fixed 9000. 007 shaker, bowed, marimba, toms and 009 bass + lab columns (Jonas 1-7): also `postgain` up to +4 dB. 009 lab columns compute `cutoff` themselves (not via `strip()`) and keep the lab's start values for untouched knobs |
| Space (row 2) | Per event: `room` 0 → 0.9 (`roomOf`, raised by global Room/Tension up to 0.95) and, on `bus()` stems, `delay` = layer echo × 2 × space (Tension's echo as floor). `orbit` and `roomsize` are fixed per stem | 008 rumble, pad, strings, seq, lead, ans, fx and 010 arp, lead, ans, birds: a floor (room > 0 at space 0). 009 lab columns: echo first, room only above space 0.35. `dryBus()` stems (kicks, sub, bass, pulse): room only, no delay |
| Level (fader) | `postgain` = fader × Master (007, 009, 010); 008: `postgain` = fader only. Fader 0 → `strip()` gates the stem: no events at all | 008's global fader is Wumms, not Master: it changes `gain`/`shape`/`hcutoff` on kick, rumble, sub, bass, clap; nothing hides on it. Static level compensation is large: 007 toms `postgain` 11, rim 3.5, wind `gain` 6, 008 hats `postgain` 0.075 |
| Drive | No Drive control. `shape` sits on some stems (008 kick 0.3 → 0.7 with Punch, ↓ with Wumms; 008 bass 0.6, stab 0.25; 010 bass 0.2, keys 0.1; 007 voice 0.15). `distort` 5 and `crush` 3 only on 007 voice row 3 | `coarse` not used by any stem |

## Space tap decision

**Read the event, no orbit lookup.** Space is not a bus value: every stem writes its own `room` (and `delay` on
`bus()` stems) into each event. In superdough `room` and `delay` are per-event send levels into the orbit's shared
reverb and delay, so they are exactly the stem's wet share. The orbit only fixes room size and echo time, which no
knob changes. Space input for the mapping: `s = max(room, delay)` from the stem's last event (task 4 may tune the
blend). Tap keys needed: `room` (already), `delay`. `orbit`, `roomsize`, `delaytime` are not needed for Space.

## Line fields the mapping can read today

Stem line: `{ t, stem, x, y, z, e, on }`; pulse line: `{ t, pulse: { bpm, phase, density, swing } }`.

| Field | Source today | Usable for the epic |
|---|---|---|
| `x` | event `pan`, kept when absent | yes |
| `y` | `note` / `freq` / `n` (synth `s`); drums by name (bd 60, sd/cp/rim 1800, hh/oh/ride 8000); else `cutoff` | pitch yes; filter no: `cutoff` only for unpitched non-drums, `hcutoff` never tapped |
| `z` | event `room` | yes (Space part 1) |
| `e` | gain × postgain × velocity ÷ the stem's running peak, √ | no: fader and Master divided out |
| `on` | 1 on the frame after an event | yes |
| layers | every event overwrites x/y of its stem | no: see below |

Layers seen in 010 (4 cycles, all faders 1): kick = `sine` (with note) + `bd` at the same onset → y jumps between the
sine's pitch and 60 Hz; bass = two pitches per onset (octave layer); pad up to 12 notes, keys 8 (chords); sub, arp,
lead = two sounds on the same note (no jump). Hats, clap, perc, noise, bells, birds: one event per onset.

The stems map is never pruned: a gated stem keeps sending lines with e decaying towards 0, so `gone` can be set in
`strudel-source.mjs` from "no event for its hold time"; fader 0 never produces an event with `postgain` 0.

## Line format (fixed for tasks 2-6)

Keep `t, stem, x, y, z, e, on` (e becomes absolute in task 4). New optional fields on stem lines: `b` brightness
0…1 (from `cutoff` relative to the stem's base Hz), `s` space 0…1 (`max(room, delay)`), `d` drive 0…1 (from `shape`,
`distort`, `crush`), `gone` 1 when hidden. No code changed in task 1.

## Corrections for later tasks

- Task 3 `trajectoryKeys`: replace `lpf`, `hpf` with `hcutoff` (keep `cutoff`); add `delay`, `shape`, `distort`,
  `crush`; `size` in the epic is `roomsize` in the event (not needed); `orbit`, `delaytime`, `coarse` not needed.
- Task 4 `frequencyOf`: read `cutoff`/`hcutoff`, not `lpf`/`hpf`.
- Task 4 absolute e: the dB scale on raw gain × postgain × velocity is skewed by static compensation (toms 11 vs
  hats 0.075). Either normalise by the stem's level at fader 1 (a per-stem reference, not a running peak) or take
  per-stem offsets from `npm run audibility`.
- Brightness checks in task 2 should skip sub and 007 wood (no `cutoff` change) or test them through `gain`.
- 008 has no Master: "Master scales all dots" does not apply there; Wumms changes kick/bass/sub levels instead.
