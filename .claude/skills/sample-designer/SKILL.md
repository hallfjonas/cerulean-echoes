---
name: sample-designer
description: Arrange a free sound as a Sample Designer project (sc/lab/samples/<name>.sample.json) from a sentence, or copy an existing project and change it; check it, load it in SuperCollider, export it as a library sound on request. Use for 'design a sound', 'sample designer', 'a soft tom with a noise tail', 'layer a felt piano with a breath', 'make a variation of kick-round', 'copy bass-pluck and make it darker', 'export this sound', 'new drum machine / synth sound'.
---

# Sample Designer: a sentence becomes a project file

A sound is a project file `sc/lab/samples/<name>.sample.json` on the machine schema: source blocks, effect and modulator
blocks, the values of every control, an audition pattern. The player plays it on the Launch Control XL 3 (Lab →
`Sample: <name>`); the user turns knobs, the ear decides, Save writes the values back. What the user does:
`docs/features/sample-designer.md`. Your job: write the first version, or a changed copy, and prove it loads.
Node cannot hear: never say a sound is "better", "warmer" or "right". Say what you built and what to listen for.

## Read first (do not work from memory)
- `sc/lab/samples/blocks.json`: every block kind with its knobs, fader and types (the labels the user sees).
- `sc/lab/samples/sample.schema.json` and one existing project (`kick-round` drum, `bass-pluck` synth).
- `sc/lab/samples/machine.scd`: what each knob does in numbers (below). The machine is the truth, not the labels.
- `ls sc/lab/samples sc/sounds`: a name that exists is taken. `git status`, `gh pr list`: nobody else on this sound.

## 1. From the sentence to a plan
Say the plan in three lines before writing (assumptions the user can correct): drum or melodic, which blocks and
why, what the audition plays. Ask only when the sentence leaves the kind open ("a bass" = pluck or sub?); otherwise
build the simplest reading and name it.
- **Setup `drum`**: one voice, no notes. Blocks fixed: `tone`, `noise`, `click`, `env`, `filter`, `drive` (ids as
  written). Turn off what the sentence does not ask for (`"on": false`), never delete.
- **Setup `synth`**: a played note. Blocks fixed: `osc1`, `osc2`, `filter`, `env`, `lfo`, `chorus`, `drive`.
- **Setup `free`**: any blocks, at most 7 (the LC has 7 block columns). Use it when a fixed list does not fit
  (three sources, no filter, a drum with a note-driven oscillator). Sources first, then the chain; at most one `env`
  and one `lfo`; unique ids (lowercase, at most 12 characters, `breath` and `osc1` are fine). A source id may be any
  name, the kind decides what it is.
- `role`: kick, perc, hats, clap, sub, bass, keys, chords, pad, lead, texture, fx.
- Pitched notes need an `osc` source. `tone`, `noise` and `click` do not follow the played note.

## 2. Values (all 0..1, kinds and types: blocks.json)
Per block `k1`, `k2`, `k3` are the three knobs, `level` the fader, `on` the first button, `type` the second.
Numbers from the machine (use them to turn words into values):
| Block | k1 | k2 | k3 |
|---|---|---|---|
| tone | pitch 25 Hz x 64^k1 (0.2 = 57 Hz, 0.4 = 130 Hz, 0.6 = 300 Hz) | drop 48 semitones x k2 | drop time 5 ms x 80^k3 |
| noise | colour 100 Hz x 120^k1 | own decay 5 ms x 200^k2 | width (0 narrow, 1 airy) |
| click | tone | length | repeat 1..4 |
| osc | tune, 0.5 = the note, +-24 semitones over 0..1 (0.75 = octave up) | fold | detune 0..30 cents |
| env | attack 1 ms x 2000^k1 (0.5 = 45 ms, 0.62 = 110 ms) | decay 10 ms x 400^k2 (0.5 = 0.2 s, 0.7 = 0.66 s) | sustain |
| filter | cutoff 30 Hz x 600^k1 (0.5 = 730 Hz, 0.75 = 3 kHz) | resonance | env amount (opens with each note) |
| drive | amount | tone | bias |
| lfo | rate | pitch | cutoff |
| chorus | rate | depth | width |
Fader `level`: source level, `env` level of the whole voice, `lfo` depth, effects Mix (0 = dry). A block with `on:
false` is bypassed. Envelope types: One-shot (falls on its own, drums) and Gate (holds for the note length, with
sustain). The attack must be shorter than the note (the note length is set by the rhythm step and the Length knob).
- Every knob at 0 must still sound like something; start in the middle, not at the ends.
- Keep the sum calm: sources add up. Several sources at level 0.8 clip; `kick-round` and `bass-pluck` are the scale.
- "soft", "felt", "round": low cutoff (0.5-0.65), slow attack, no drive. "hard", "tight": short decay, click on.

## 3. The audition
`audition`: `bpm`, `pattern` (index), `accent`, `space`, `length`, `master` (0..1) and one to three `patterns`:
`label` (at most 20 characters, plain words, no pattern strings), `rhythm` (mini-notation, `x` = hit, `~` = rest,
`@` = longer, one cycle = one bar), optional `notes` (MIDI numbers) and `velocity` (0..1).
- `notes` and `velocity` are read at the moment of each hit: write them on the same grid as the rhythm (8 steps of
  rhythm, 8 values), not as one value per hit. Rests in `velocity` count as 1.
- The audition needs rhythm, not one held note: pulse, a fill, a single hit for the tail. A drum voice ignores `notes`.
- `about`: one line, at most 60 characters, English, what the sound is ("Soft tom: sine with a gentle drop").

## 4. Write, check, load (the gate)
New project: write `sc/lab/samples/<name>.sample.json` (name: lowercase words joined by `-`, `parent: null`).
Changing an existing project: never overwrite it, copy first:
`cd tools && npm run sample-lab -- save-as <name> <new-name>` (sets `parent`), then edit the copy.
Order of work for a copy: say what changes ("darker = filter cutoff 0.62 -> 0.45"), change only that.

Before you say "ready", all of these pass; paste the last lines of the output:
1. `cd tools && npm run sample-lab -- check <file>` (schema, block order, types, mini-notation, `about` length).
2. `sclang tools/sc-test/sample-designer.scd` from the repo root (every project in the folder loads, its machine passes
   `~ce.checkSound`, the audition plays with rhythm, labels, buttons, Pattern and Save work). sclang is not always on
   PATH: `/Applications/SuperCollider.app/Contents/MacOS/sclang` (or `$SCLANG`). Takes a few seconds; run it alone, not
   beside another SC job. No sclang: say so, the project is then checked but not loaded.
3. Optional sanity render, when you want to see that the sound is not silent or clipping (a measurement, not a
   verdict): `sclang sc/tools/render.scd sc/lab/samples/<name>.sample.json <scenario.json> <out-prefix>` with
   `{"cycles": 2}`, output outside the repo. Report peak and where the energy falls, not taste.

Then report: the file, the plan in a few words, what to listen for, which knobs to try first (name them as the LC
shows them: Pitch, Bend, Decay ...), and that it loads in SuperCollider but has not been heard. Tell the user to
start the player (`cd tools && node trajectory/server.mjs`, localhost:8766), pick Lab, `Sample: <name>`.

## 5. Export (only when asked)
"Export", "put it in the library", "make it a sound": ask for or propose a camelCase sound name that is not in
`sc/sounds/` (`softTom`), then `cd tools && npm run sample-lab -- export <name> --as <sound>` (writes
`sc/sounds/<sound>.scd` and a two-bar WAV in `samples/sound-lab/`; never overwrites; `--no-wav` without sclang).
Gate again with the export: `sclang tools/sc-test/sample-designer.scd <sound> sc/lab/samples/<name>.sample.json`.
Putting the sound into a track or a stem is another job (ask first: sound, orbits and layout are the user's call).

## Limits (say them instead of working around them)
- Free arrangements use machine blocks only: Tone, Noise, Click, Osc, Env, LFO, Filter, Drive, Chorus. No samples, no
  FM, no reverb or delay as a block (Space on column 8 is the room), no second envelope except an LFO of type
  Envelope, no more than 7 blocks. If the sentence needs more, build the nearest thing and name what is missing.
- Only the three knobs, the fader and the two buttons of a block exist; do not invent JSON fields (the schema refuses
  them).
- The audition notes have a fixed length (the Length knob), no note-off; a drum voice has one pitch per project.
- Mode 2 of the LC is not used; do not describe it.
- Labels the user reads (pattern labels, `about`) follow CLAUDE.md "Labels": English, short, no pattern strings.

## Don'ts
- Do not edit `machine.scd`, `blocks.json` or the schema for one sound; that changes every project and every
  exported sound that references them. Ask.
- Do not claim the result sounds like a real tom or piano. "Built for a soft tom: sine at 130 Hz with a 12 semitone
  drop" is a fact; "sounds like one" needs the user's ear.
- Do not export, push or change a track unasked.
