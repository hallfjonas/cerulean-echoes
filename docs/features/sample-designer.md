# Sample Designer

## What it is
A new sound (a library "sample", `sc/sounds/<name>.scd`) built on the whole Launch Control XL 3, played by
SuperCollider in the player. Two fixed setups: a **drum machine** (one drum voice) and a **synthesizer**. A design is a
project file, `sc/lab/samples/<name>.sample.json`: save it, copy it, export it as a library sound plus a WAV.

## When to use it
- You want a new kick, snare, bass or lead sound that no library sound gives you.
- You want to try a variation of a sound you designed before (Save as, then change it).
- Claude arranges a free sound for you (`/sample-designer`): the project file has the same format.

## How to use it
1. Start the player (`cd tools && node trajectory/server.mjs`, then http://localhost:8766).
2. Under **Lab** pick `Sample: kick-round` (drum machine) or `Sample: bass-pluck` (synthesizer) and press **Load**
   (or Play). The audition pattern plays at once; the MIDI panel shows the machine.
3. Turn knobs, move faders, press buttons (on the LC or in the MIDI panel). Every knob acts at once, also on sounding
   notes.
4. **Save** (sidebar, or the LC: column 8, button 2) writes the values into the project file.
   **Save as** copies the project under a new name (its `parent` is the old one) and picks the copy.
5. **Export** asks for a sound name (camelCase, e.g. `kickRound`) and writes `sc/sounds/<sound>.scd` and
   `samples/sound-lab/<sound>.wav` (two bars of the audition). Existing files are never overwritten.
6. **Shape** renders one hit of the sound (the first note of the picked audition pattern, full velocity, no room, the
   knob values that play now) and opens a panel with four pictures and the numbers under them:
   - **Waveform**: the hit over time.
   - **Envelope**: loudness in dB over time. The orange band is the attack (10 → 90 % of the peak), the blue band the
     decay down to -20 dB.
   - **Spectrum**: which frequencies the hit has, low on the left. The dashed line is the centroid: the higher it is,
     the brighter the sound.
   - **Spectrogram**: how those frequencies change over time; bright = loud. A pluck's top fades first, a drop slides
     down.
   Numbers: Peak (dB), Attack, Decay, Length (to -60 dB), Strongest frequency (with its note name), Centroid. Turn a
   knob and press Shape again to compare. They are measurements, not a verdict.

From the terminal (in `tools/`): `npm run sample-lab -- check`, `npm run sample-lab -- save-as kick-round kick-deep`,
`npm run sample-lab -- export kick-deep [--as kickDeep] [--no-wav]`.

## The LC: machine schema (Mode 1)
| Control | Columns 1-7: one block each, in signal order | Column 8 |
|---|---|---|
| Knob row 1 | the block's main parameter (Pitch, Cutoff, Amount …) | Accent: even hits ↔ strong accents |
| Knob row 2 | shape and time (Bend, Decay, Resonance …) | Space: dry ↔ room |
| Knob row 3 | fine and modulation (Bend time, Detune, Env amount …) | Length of the audition notes |
| Fader | block level (sources, envelope), Mix (effects), Depth (LFO) | Master |
| Button 1 | block on / off | Pattern: next audition pattern at the next bar |
| Button 2 | block type (Sine → Triangle → …) | Save |

Each control's name and what it does show in the MIDI panel. Mode 2 is not used.

| Setup | Columns |
|---|---|
| Drum machine | 1 Tone (oscillator with pitch drop), 2 Noise, 3 Click, 4 Envelope, 5 Filter, 6 Drive |
| Synthesizer | 1 Osc 1, 2 Osc 2, 3 Filter, 4 Envelope, 5 LFO (type Envelope = a second, one-shot envelope), 6 Chorus, 7 Drive |

The blocks, their knobs and types: `sc/lab/samples/blocks.json`; their sound: `sc/lab/samples/machine.scd`.

## The project file (format 1)
Schema: `sc/lab/samples/sample.schema.json`. Check: `npm run sample-lab -- check` (also in `npm run verify` and
`npm test`).

| Field | What it is |
|---|---|
| `format` | `1` |
| `name` | the file name without `.sample.json`, lowercase words joined by `-` |
| `parent` | the project it was copied from, or `null` |
| `about` | one line, at most 60 characters (becomes the sound's `about`) |
| `setup` | `drum`, `synth` (the fixed block lists above) or `free` (any blocks, at most 7) |
| `role` | the stem role of the exported sound (`kick`, `bass`, `lead` …, the stem list) |
| `sources` | source blocks (`tone`, `noise`, `click`, `osc`), summed |
| `chain` | the blocks after them in signal order: effects (`filter`, `drive`, `chorus`) and modulators (`env`, `lfo`, at most one each) |
| `audition` | `bpm`, `pattern` (index), `accent`, `space`, `length`, `master` (0..1), `patterns` |

A block: `{ "id", "kind", "on", "type", "k1", "k2", "k3", "level" }`; `k1`-`k3` and `level` are the knob and fader
values 0..1, `type` one of the kind's types. Columns are `sources` then `chain`, left to right.

An audition pattern: `label`, `rhythm` (mini-notation, `x` = hit), optional `notes` (MIDI numbers, read at each hit;
the drum voice ignores them) and `velocity` (0..1, how much Accent lowers a hit). One cycle is one bar.

## The exported sound
`sc/sounds/<sound>.scd` is in the library format (`~ce.checkSound` passes when it loads): every block value is a named
parameter (`tonePitch`, `filterCutoff`, `osc1Type` …, the project values as defaults) and stays live in a stem, plus
`bright` (a final low-pass, 1 = open) and `tone` (Fog / Tension). The file carries a copy of the machine, so a later
change of the machine never changes an exported sound.
