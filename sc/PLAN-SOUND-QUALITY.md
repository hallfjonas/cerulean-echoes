# Sound quality: what to improve, and which plugins to bring into the Sound Lab

> Plan, nothing built yet. Related: `sc/PLAN-STEM-LIBRARY.md` (machine table), `docs/features/sound-lab.md`,
> `docs/features/sample-designer.md`, `sc/samples/CREDITS.md`.

Goal: every stem should sound as good as possible **on its own**, because the stems are randomized, swapped and
modulated live. A stem that only works in one mix is a weak stem.

## 1. Where we stand (2026-11-22)

Most of the material came over from Strudel 1:1, so it carries Strudel's limits:

| Area | Now | Problem |
|---|---|---|
| Drum machines | `tr909/808/707/727`: one 16-bit / 44.1 kHz one-shot per sound (tidal-drum-machines) | one sample per hit = machine-gun effect; no velocity, no round robin; some unknown sources |
| GM sounds | `gm/*`: WebAudioFont soundfont zones | the weakest sources in the repo (small, old General MIDI sets) |
| Piano | `houseKeys`: VCSL Steinway, one velocity layer (vl3), one round robin, zones only F#3–E4 | far stretched outside that range; same timbre at every velocity |
| Reverb | `ir/orbit-*.wav`: measured superdough noise reverbs | a generic noise tail, no real room |
| Synth code | `.fold2` / `.tanh` / `Latch.ar` without oversampling, `LFTri.ar` at audio rate | aliasing (harsh, inharmonic fizz) on bright or high notes |
| Engine | `s.options.sampleRate = nil` (follows the audio device) | 44.1 kHz files get resampled when the device runs at 48 kHz; results can differ per machine |

The orchestral (VSCO 2, SSO), Rhodes, vibraphone and Strat sets are fine as a base.

## 2. Quick wins (engine and existing sounds)

1. **Fix the sample rate** at 48 kHz in `sc/engine.scd` / `sc/live.scd`, and convert new samples to 48 kHz on import
   (one step in `/add-sample`).
2. **Anti-aliasing for drive and folding:** run the nonlinear part at a higher rate, or use band-limited versions:
   - `.tanh` / `.fold2` in the `drive` block and in `bassPluck`, `softTom`, …: oversample the shaper (which
     oversampling plugin to use is still to be checked) or at least low-pass before and after it;
   - `LFTri.ar` as an audio oscillator → `VarSaw.ar(freq, 0, 0.5)` or a band-limited triangle.
3. **Real rooms:** replace the noise IRs with measured spaces (free sets: OpenAIR, Voxengo IR pack; both CC/free). Keep the
   orbit sizes as names, change only the files. The partitioned convolution in `sc/lib/mixer.scd` stays.
4. **Round robins and velocity layers** wherever a sample set has them: sdSample picks a file per note at random
   from a list instead of one file. The cheapest gain for drums and keys.
5. **Level per stem:** loudness-normalize samples on import (LUFS per one-shot or phrase), so that `gain` only has to
   correct taste, not source differences.
6. **Gentle bus processing:** the master limiter already exists. A soft saturation/glue stage on the drum and the
   music buses before it makes randomized stems sit together better.

## 3. Better sources per role

| Role | Replace / add | Free | Paid (worth it) |
|---|---|---|---|
| Drum machines | one-shots with many hits per sound (velocity + variations) | — | Goldbaby, Samples From Mars (909/808/707 at 24-bit, recorded from the hardware) |
| Acoustic drums, percussion | multisampled kits | VCSL (CC0, we already use it), Freesound (check license per file) | — |
| Piano | several velocity layers, full range | Salamander Grand (CC-BY), Pianobook | Pianoteq (via VSTPlugin, see 4.3) |
| Orchestral | — | VSCO 2 CE (have it), more articulations from it | — |
| Synth sounds | synthesis in SC instead of samples | plugin packs in 4.1–4.2 | — |

Rule (as for riffs): find, don't invent. Prefer documented sources with a license we can write into `CREDITS.md`.

## 4. Plugins to bring in

All are server plugins (UGens): install once on every machine that plays (download the macOS build, put it into
`Platform.userExtensionDir`, recompile). `npm test` / `verify-sc` should skip a sound whose UGen is missing, with a
clear message, so a machine without the plugin still loads the other tracks.

### 4.1 sc3-plugins (community collection)
Useful parts: `DFM1` (analog-style filter with drive), `MoogLadder` / `RLPFD`, `Greyhole` / `JPverb` (good
algorithmic reverbs, an alternative to the IRs), `AnalogTape` / `AnalogVintageDistortion` (in the `AnalogTapeModel`
set of sc3-plugins), `Decimator`.

### 4.2 mi-UGens (Volker Böhm, ports of Mutable Instruments modules)
Not Tidal; plain UGens. The ones that matter for us:

| UGen | Module | What it gives us | Machine in `PLAN-STEM-LIBRARY.md` |
|---|---|---|---|
| `MiPlaits` | Plaits | 16 synthesis models in one voice (VA, waveshaping, FM, grains, additive, wavetable, chords, speech, string, modal, bass/snare/hat drums) | Texture, FM, Wavetable, Drum Voice, Kick, Würfel (one engine knob = a new idea) |
| `MiRings` | Rings | resonator (modal, string, FM bell) driven by any input | Texture, plucks, bells, metallic percussion |
| `MiClouds` | Clouds | granular freeze / texture | FX: granular freeze; Sampler (vocal pads) |
| `MiElements` | Elements | bowed / blown / struck physical model | Texture, Balsam voices |
| `MiBraids` | Braids | older macro oscillator, many raw shapes | Mono-Bass, Lead |
| `MiRipples`, `MiWarps`, `MiVerb` | Ripples filter, Warps cross-mod, Clouds/Rings reverb | analog-sounding LP, cross modulation, a reverb with character | Poly, FX |

These cover a large part of the machine table with tested, musical sounds, instead of building each one from scratch.

### 4.3 VSTPlugin (Christof Ressi)
Hosts VST2/VST3 plugins inside the server: a plugin is a node like any synth, its parameters can be set from code
and mapped to buses. Use it only for a few flagship sounds we cannot reach otherwise (a real piano model, one
analog-modelled poly). Costs: CPU on the M2 Air (test one plugin at a time, see the machine rules), and every player
machine needs the same plugin and licence. Free candidates to start: Surge XT, Vital (VST3), Dexed (DX7).

## 5. Mapping into our LC layout

### 5.1 As Sample Designer blocks (`sc/lab/samples/blocks.json`)
New block kinds, same schema as now (row 1 main, row 2 shape/time, row 3 fine/mod, fader level or mix, button 1
on/off, button 2 type):

| Block | part | Row 1 | Row 2 | Row 3 | Fader | Button 2 (type) |
|---|---|---|---|---|---|---|
| Plaits | source | Timbre | Morph | Harmonics | Level | engine (16 models; cycles) |
| Rings | fx (resonator) | Brightness | Damping | Structure | Mix | Modal / String / FM bell |
| Clouds | fx | Position | Size | Density | Mix | Granular / Stretch / Loop / Spectral |
| Ladder filter (DFM1 / MiRipples) | fx | Cutoff | Resonance | Env amount | Mix | LP / BP / HP |
| Tape | fx | Drive | Wow/flutter | Tone | Mix | Tape / Tube |
| Real reverb | fx | Size (IR pick) | Damping | Pre-delay | Mix | Room / Hall / Plate |

New setups to try, e.g. **Texture** (Plaits → Rings → Clouds → Envelope → LFO → Tape) and **Drum voice (Plaits)**
(Plaits drum models → Envelope → Ladder filter → Drive). Mode 2 is unused in the Sample Designer: it could hold the
second page of a block that needs more than three knobs (Plaits' LPG decay/colour, Clouds' feedback/texture/spread).

### 5.2 In a stem (the live column)
The stem keeps the fixed row meanings, so the player never has to relearn a column:

| Control | Plaits stem | Rings stem | Clouds stem |
|---|---|---|---|
| Row 1 Brightness | Timbre (+ LPG colour) | Brightness | texture/filter |
| Row 2 Space | Space | Space | Space (+ Clouds' own reverb) |
| Row 3 (named) | Morph | Structure | Density |
| Fader Level | Level | Level | Level |
| Button 1 Pattern | Pattern | Pattern | Pattern / Freeze |
| Button 2 (named) | Engine (next model, at the next bar) | Model | Freeze |

All knobs at 0 must already sound good (track rule): set every mapping's bounds so the 0 end is a usable sound,
not silence or a raw extreme.

### 5.3 Randomizing (Würfel mode)
Plaits and Rings are well suited: their parameters are 0..1, and the musical range is wide. Still store a tested
range per parameter in the block definition (as planned for the Würfel mode), plus a list of allowed engines per role
(e.g. a bass stem: VA, waveshaping, FM, bass drum model only).

## 6. Order (proposal)

1. Quick wins 2.1, 2.2, 2.4 (no new dependencies).
2. Install sc3-plugins + mi-UGens on both machines; a check in `verify-sc` for missing UGens.
3. Plaits block + Texture setup in the Sample Designer; one Stem Designer round against 009 with Plaits candidates.
4. Real IRs and a drum-machine sample upgrade (decide free vs. paid together with Jonas).
5. VSTPlugin only if a role still has no good sound after 1–4.

## Open questions
- Which machines do we play on (both Macs?), and are we fine with installing plugins on each?
- Paid samples/plugins: yes or no, and do the licences allow sharing the files in a private repo between the two of us?
- Keep the Strudel-measured reverbs for compatibility with old recordings, or replace them?
