# 008 space plan: how to build it in Strudel

This is the technical plan for the 008 space plan (`008-space-plan.html`). It says which code changes, where, and how
we check each step. Line numbers refer to `008-groove-techno.strudel` as of round 9.

The lab board `lab/bass/low-end-width.strudel` decides one open point first: how wide kick, sub and bassline may be.

**Status:** built as `008-groove-techno-space.strudel` (rounds 1-2), then merged into `008-groove-techno.strudel`;
the space file is gone. Tools: `tools/strudel-sim/space.mjs` and
`compare.mjs --stem`. Measuring changed some values below (bass top = Haas copies, higher pad/stab high-passes, pads'
Space floor): the actual values and KPI numbers are in `FEEDBACK.md`, section "SPACE VERSION".

## 0. Ground rules

- **New file.** Copy `008-groove-techno.strudel` to `008-groove-techno-space.strudel` and change only the copy.
  The current track stays playable as it is.
- **One change, one check.** Each step below is small. After each step: transpile check, then listen.
- **The set (011) is not touched.** It is built from the frozen `old/008-groove-techno-multi.strudel`.
- **The hook still runs.** After every edit it regenerates the layout PDF and the `.syx` modes of the new file.
  The controller layout does not change, only some `@ctl` texts (filter ranges).
- **Untouched sounds stay identical.** Kick, sub, clap, bongos, sequence and answer must produce the same events as
  before (proved in step 4).

## 1. Build the space meter

New tool: `tools/strudel-sim/space.mjs`. It works like `measure.mjs` + `render.mjs`, but measures space instead of
loudness.

What it does, per stem (rendered alone, stereo, 8 bars, all knobs 0, fader 1, master 1):

| Output | How | Used for |
|---|---|---|
| energy per octave band (31 Hz … 16 kHz) | 10 band-pass filters on the render | K2, K3 |
| side ÷ middle energy per band | middle = (L+R)/2, side = (L−R)/2 | K1, K4 |
| mono loss in dB | energy of (L+R)/2 ÷ mean energy of L and R | K1 |
| average pan | energy right ÷ (left + right) | K7 |
| reverb share | render twice: as is, and with `room` forced to 0; wet = difference | K8 |

Notes:
- Rendering: copy the offline render from `render.mjs` (OfflineAudioContext, 2 channels, superdough). The band filters
  can be the same RBJ biquads that `render.mjs` already uses for its 2 kHz high-pass.
- 008 finds no Launch Control in Node, so the harness's plain `midin()` stands in (already supported).
- Stem names and fader CCs for 008: `stemJ1_kick=5`, `stemJ2_rumble=6`, `stemJ3_sub=7`, `stemJ4_bass=8`,
  `stemJ5_clap=9`, `stemJ6_hats=10`, `stemJ7_perc=11`, `stemN1_pad=53` … `stemN7_fx=59`; master = CC 12 and 60.
- Heavy job (many renders): run it alone on the M2, one stem at a time.

Check: the kick shows mono loss 0 dB and side ÷ middle 0. The answer (ping-pong 0.2 / 0.8) shows a clear side share.

```bash
cd tools && node strudel-sim/space.mjs ../tracks/008-groove-techno/008-groove-techno.strudel stemJ1_kick=5 stemN5_ans=57
```

## 2. Measure the baseline

Run `space.mjs` on all stems of the **current** 008. Write the numbers into the KPI cards of the space plan and into
`FEEDBACK.md` (section "Space baseline"). Also run `measure.mjs` for kick and bassline loudness (K5).

## 3. The lab round decides the low end

Play `lab/bass/low-end-width.strudel` (kick, sub, bassline; width, method, crossover, mono check). First numbers from
Node, mono sum vs. stereo below 120 Hz, full width:

| Setting | Loss in mono | Width (side ÷ middle) |
|---|---|---|
| sub, detune 25 cents | −0.5 dB | 0.13 (little) |
| sub, Haas 10 ms | −8.9 dB (worst beat −13.6 dB) | 6.8 (very wide) |
| sub, auto-pan | −1.3 dB | 0.35 |
| sub, detune 25 cents, mono below 300 Hz | 0 dB | 0 below 120 Hz |
| bassline, detune 12 cents, mono below 300 Hz | 0 dB | 0 below 120 Hz |
| kick, Haas 10 ms | −3.6 dB | 1.3 |

So: a really wide sub only comes from Haas, and Haas is what cancels in mono. The result of the lab round goes into
`lab/bass/feedback.md` and picks one of these for step 5f:
- **A** sub stays mono (plan default),
- **B** sub overtones wide (triangle layer only),
- **C** something wider, if it survives the mono check by ear.

## 4. Changes in the new file

Each change: where, before, after. Do them in this order and check after each one.

### 4a. Clear the bass lane: pad, techno pad, Launchkey pad

Pad (`stemN1_pad`, line 707): high-pass the whole stack, widen its pan sweep (lines 701 and 705).

```js
// before
padChord.s("sawtooth")...gain(0.035).pan(sine.slow(5).range(0.3, 0.7))
const stemN1_pad = strip(dryBus(stack(
  ...
), 2, pad.space), {
// after
padChord.s("sawtooth")...gain(0.035).pan(sine.slow(5).range(0.15, 0.85))
const stemN1_pad = strip(dryBus(stack(
  ...
).hpf(250), 2, pad.space), {
```

Same pan change in `padBreath` (line 705).

Techno pad (`tpadSaws`, line 733): each saw gets its own fixed place instead of all three moving together. Then
high-pass it in `stemN2_tpad` (line 739).

```js
// before
const tpadSaws = pat => stack(pat, pat.add(note(0.12)), pat.add(note(-0.11))).s('sawtooth').gain(0.028)
  .pan(sine.slow(7).range(0.3, 0.7))
// after
const tpadSaws = pat => stack(pat.pan(0.5), pat.add(note(0.12)).pan(0.25), pat.add(note(-0.11)).pan(0.75))
  .s('sawtooth').gain(0.028)
```

```js
// stemN2_tpad: before
), 2, tpad.space), tpad.btn2), {
// after
).hpf(220), 2, tpad.space), tpad.btn2), {
```

Launchkey pad (`lkPad`, line 1179): `.hpf(140)` → `.hpf(220)`.

Check: transpile, then K3 with `space.mjs` (pad, techno pad and LK pad have little energy in 125–350 Hz).
Note: the global Thin knob multiplies each stem's own high-pass, so these stems thin out sooner. Thin is capped at
5 kHz, so they never go silent.

### 4b. Stab: no square an octave down

`stemN4_stab` (line 831) plays a square one octave below the stab, on F2: exactly the bass note. Two options, try both:

```js
// option 1: remove this line
  stabNotes.add(note(-12)).s('square').gain(0.12)
// option 2: keep it, high-pass the whole stack
).attack(0.002)...shape(0.25)
  .gain(0.3).hpf(280), 2, lead.space.fmap(s => 0.25 + 0.75 * s)), lead.btn2), {
```

Option 1 also saves one voice per stab. Pick by ear; if the stab gets too thin, use option 2.

### 4c. Rumble under the bass

`stemJ2_rumble` (lines 493 and 494):

```js
// before
.lpf(toned(expRange(rumble.bright, 250, 1800))...
...3, rumble.space.fmap(s => 0.5 + 0.5 * s))),
// after
.lpf(toned(expRange(rumble.bright, 150, 700))...
...3, rumble.space.fmap(s => 0.35 + 0.45 * s))),
```

Update the tag text: `@ctl 16:2.k1 ... (lpf 150–700 Hz)`.

Check: K1 (mono low end) and K6. Listen with the bassline: each bass note has a clear start.

### 4d. Bassline: front and louder

`stemJ4_bass` (lines 557 and 558):

```js
// before
lpf: expRange(bassCol.bright, 200, 2000).mul(sine.slow(16).range(0.8, 1.25)),
level: bassCol.level.range(0, 0.5),
// after
lpf: expRange(bassCol.bright, 350, 2500).mul(sine.slow(16).range(0.8, 1.25)),
level: bassCol.level.range(0, 0.7),
```

Update the tag text: `@ctl 16:4.k1 ... (lpf 350–2500 Hz ...)`. Then measure K5: bassline loudness 3 to 6 LU under the
kick. If it is louder, lower 0.7.

### 4e. Bassline: wide top layer

Split `bassSound` (line 548) so the top layer can reuse the tone without the built-in detuned copy (saves voices):

```js
// before
const bassSound = pat => pat.scale(scaleIn(2)).add(note(bassOct)).s("sawtooth").superimpose(x => x.add(note(0.1)))
  .velocity("[0.7 0.8 1 0.75]*4")
  .attack(0.003).decay(0.16).sustain(0.15).release(0.06)
  .lpq(7).lpenv("[1.8 2.2 3.2 2]*4").lpattack(0.002).lpdecay(0.11).lpsustain(0).shape(0.35)
// after
const bassTone = pat => pat.scale(scaleIn(2)).add(note(bassOct)).s("sawtooth")
  .velocity("[0.7 0.8 1 0.75]*4")
  .attack(0.003).decay(0.16).sustain(0.15).release(0.06)
  .lpq(7).lpenv("[1.8 2.2 3.2 2]*4").lpattack(0.002).lpdecay(0.11).lpsustain(0).shape(0.35)
const bassSound = pat => bassTone(pat).superimpose(x => x.add(note(0.1)))
// Top layer: the same line high-passed, one copy a little lower on the left, one a little higher on the right.
// The part below BASS_TOP_HZ stays in the mono core.
const BASS_TOP_HZ   = 300
const BASS_TOP_GAIN = 0.5
const bassTop = pat => stack(
  bassTone(pat).add(note(-0.08)).pan(0.3),
  bassTone(pat).add(note(0.08)).pan(0.7)
).hpf(BASS_TOP_HZ)
```

`bassSound` sounds exactly as before (the same events, only built in two parts). In `stemJ4_bass` (line 553) add the top
layer next to the main line:

```js
const stemJ4_bass = beatOnly(strip(dryBus(stack(
  bassSound(pick(bassVar, BASS_LINES.map(l => l[0]))).gain(0.3),
  bassTop(pick(bassVar, BASS_LINES.map(l => l[0]))).gain(0.3 * BASS_TOP_GAIN),
  gate(above(bassCol.char, 0), ...)   // ghost notes: unchanged, mono
), 1, bassCol.space), {
```

Why not a real crossover (low-pass the core at 300 Hz) as in the lab board: `strip()` sets the bassline's low-pass
from the brightness knob, and an event has only one low-pass. So the core stays full and mono, and the top copies are
high-passed. Their part below 300 Hz is about 20 dB down at the bass notes; K4 checks that the low end stays mono.

Tune `BASS_TOP_GAIN` with K4 (side ÷ middle above 300 Hz between 0.3 and 0.6) and by ear.

Cost: 2 more saw voices per bass note (up to 12 notes per bar). Check CPU in step 5.

### 4f. Sub (after the lab round)

- **A (default):** no change.
- **B:** the triangle layer (line 520) becomes two high-passed copies, the sine stays mono:

```js
// before
  subNotes.s("triangle").gain(sub.bright.fmap(b => 0.18 + 0.3 * b))
// after
  stack(subNotes.add(note(-0.08)).pan(0.3), subNotes.add(note(0.08)).pan(0.7)).s("triangle").hpf(120)
    .gain(sub.bright.fmap(b => 0.71 * (0.18 + 0.3 * b)))
```

The sub was "good" in the rehearsal feedback: only change it if the lab round clearly wants B or C.

### 4g. Pan only: hats, dark percussion, FX

| Stem | Line | Before | After |
|---|---|---|---|
| hats | 633 | `.pan(0.56)` | `.pan(0.62)` |
| claves | 905 | `.pan(0.62)` | `.pan(0.7)` |
| shaker | 907 | `.pan(0.4)` | `.pan(0.3)` |
| FX noise | 956 | `.pan(rand.range(0.25, 0.75))` | `.pan(rand.range(0.1, 0.9))` |

No change to kick, clap, bongos, sequence, answer.

## 5. Check the whole new file

1. Transpile check:
   ```bash
   cd tools && node strudel-sim/transpile-check.mjs ../tracks/008-groove-techno/008-groove-techno-space.strudel
   ```
2. Events and CPU against the old file. The changed stems differ on purpose; the query time must not rise much
   (the bass top layer is the only new voice load):
   ```bash
   cd tools && node strudel-sim/compare.mjs ../tracks/008-groove-techno/008-groove-techno.strudel ../tracks/008-groove-techno/008-groove-techno-space.strudel
   ```
3. Unchanged stems identical: `compare.mjs` compares the whole master. Add a `--stem <name>` option (load that stem
   with the harness's `expr` argument in both files), then run it for `stemJ1_kick`, `stemJ3_sub` (if A),
   `stemJ5_clap`, `stemJ7_perc`, `stemN3_seq`, `stemN5_ans`: all must say identical. Or use `/strudel-optimize`.
4. Run `space.mjs` on the new file and compare with the baseline. Every KPI should reach its goal:

| KPI | Goal |
|---|---|
| K1 mono low end | side ÷ middle below 120 Hz ≤ 0.1 (whole mix) |
| K2 bass lane ownership | bassline ≥ 40 % of the energy in 125–350 Hz |
| K3 crowding | ≤ 2 other stems whose 125–350 Hz energy comes within 10 dB of the bassline's |
| K4 bass width | above 300 Hz: 0.3–0.6; below 300 Hz: ≈ 0 |
| K5 bass presence | bassline 3–6 LU under the kick |
| K6 bass–rumble overlap | ≤ 4 of 12 notes, or split by pitch (K3 met) |
| K7 use of the sides | ≥ 7 of 16 stems off-centre or wide |
| K8 front ↔ back | reverb share: kick, sub, bass, clap ≤ 0.15; pads, FX ≥ 0.4 |

5. Rehearsal: headphones, phone speaker, mono. All knobs at 0 must still sound good.

## 6. Done when

- `008-groove-techno-space.strudel` plays with all changes, its layout PDF and `.syx` modes are generated.
- All 8 KPIs reach their goal, numbers in `FEEDBACK.md`.
- Jojo and Jonas played it and said the bass has more room. Only then decide whether it replaces the current file.
