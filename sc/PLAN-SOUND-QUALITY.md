# Sound quality: the best free samples and effects for SuperCollider

> Plan, nothing built yet. Related: `sc/PLAN-STEM-LIBRARY.md` (machine table), `docs/features/sound-lab.md` (ideas
> for playing the new plugin sounds), `docs/features/sample-designer.md`, `sc/samples/CREDITS.md`.

## Summary

**Goal:** every stem sounds as good as possible **on its own**, because the stems are randomized, swapped and
modulated live. To get there, replace the weak samples and effects with the best **free** sources for SuperCollider.

1. **Engine fixes (no downloads):** a fixed 48 kHz sample rate in the player, less harshness on bright notes, levels
   evened out on import (section 2).
2. **Better samples:** drums with several variations per hit, a better free piano, keep the good orchestral sets
   (section 3).
3. **Better effects:** install two free plugin packs (sc3-plugins, mi-UGens), then a better reverb, tape and filters
   (sections 2.3 and 4).
4. **Judge by ear, twice:** first each sample on its own, old and new back to back at the same loudness; then in the
   mix, with the Stem Designer against one track (009). Only a winner in both goes into every track.

## 1. Where we stand (2026-11-22)

Most of the material came over from Strudel 1:1, so it carries Strudel's limits:

| Area | Now | Problem |
|---|---|---|
| Drum machines | `tr909/808/707/727`: one 16-bit / 44.1 kHz one-shot per sound (tidal-drum-machines) | one sample per hit = machine-gun effect; no velocity, no round robin; some unknown sources |
| GM sounds | `gm/*`: WebAudioFont soundfont zones | the weakest sources in the repo (small, old General MIDI sets) |
| Piano | `houseKeys`: VCSL Steinway, one velocity layer (vl3), one round robin, zones only F#3–E4 | far stretched outside that range; same timbre at every velocity |
| Reverb | `ir/orbit-*.wav`: measured superdough noise reverbs (the measuring script is retired, the files stay) | a generic noise tail, no real room; fixed, so Space can only blend it |
| Synth code | `.fold2` / `.tanh` / `Latch.ar` without oversampling, `LFTri.ar` at audio rate | aliasing (harsh, inharmonic fizz) on bright or high notes |
| Engine | `sc/live.scd` (IDE start) is fixed at 48 kHz; `sc/engine.scd` (the player) still has `sampleRate = nil` (follows the audio device) | in the player, 44.1 kHz files get resampled when the device runs at 48 kHz; results can differ per machine |

The orchestral (VSCO 2, SSO), Rhodes, vibraphone and Strat sets are fine as a base.

## 2. Quick wins (engine and existing sounds)

1. **Fix the sample rate** at 48 kHz in `sc/engine.scd` too (`sc/live.scd` already is), and convert new samples to
   48 kHz on import (one step in `/add-sample`).
2. **Anti-aliasing for drive and folding:** run the nonlinear part at a higher rate, or use band-limited versions:
   - `.tanh` / `.fold2` in the `drive` block and in `bassPluck`, `softTom`, …: oversample the shaper (which
     oversampling plugin to use is still to be checked) or at least low-pass before and after it;
   - `LFTri.ar` as an audio oscillator → `VarSaw.ar(freq, 0, 0.5)` or a band-limited triangle.
3. **Better reverb:** the noise IRs stay for now. Direction: high-quality algorithmic SC reverbs (e.g. `Greyhole` /
   `JPverb`, 4.1), so Space can move the room live (size, decay, damping), not only blend a fixed tail. Needs
   sc3-plugins (6.3); candidates researched with sources first, then compared by ear against the current IRs on one
   track (009). Measured real rooms (free sets: OpenAIR, Voxengo IR pack; both CC/free) stay the alternative: they would
   keep the partitioned convolution in `sc/lib/mixer.scd` and change only the files. Shared sound: decide with Jonas.
4. **Round robins and velocity layers** wherever a sample set has them: sdSample picks a file per note at random
   from a list instead of one file. The cheapest gain for drums and keys.
5. **Level per stem:** loudness-normalize samples on import (LUFS per one-shot or phrase), so that `gain` only has to
   correct taste, not source differences.
6. **Gentle bus processing:** the master limiter already exists. A soft saturation/glue stage on the drum and the
   music buses before it makes randomized stems sit together better.

## 3. Better sources per role (free only)

| Role | Replace / add | Free sources |
|---|---|---|
| Drum machines | one-shots with many hits per sound (velocity + variations) | still to find (documented license) |
| Acoustic drums, percussion | multisampled kits | VCSL (CC0, we already use it), Freesound (check license per file) |
| Piano | several velocity layers, full range | Salamander Grand (CC-BY), Pianobook |
| Orchestral | — | VSCO 2 CE (have it), more articulations from it |
| Synth sounds | synthesis in SC instead of samples | plugin packs in 4.1–4.2 |

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
How they would appear on the controller (Sample Designer blocks, stem columns, randomizing) is in
`docs/features/sound-lab.md`, "Ideas: plugin blocks (not built)".

## 5. How to compare

- **Sample by sample:** old and new back to back, at the same loudness. No tool for this yet: it needs a small one
  (e.g. a page in Labs with old / new per sample).
- **In the mix:** the Stem Designer, the new version against the current one, played against 009.

## 6. Order (proposal)

1. Quick wins 2.1, 2.2, 2.4 (no new dependencies).
2. The sample-by-sample comparison (5).
3. Install sc3-plugins + mi-UGens on both machines; a check in `verify-sc` for missing UGens.
4. Better reverb (2.3), drum and piano sample upgrade (3).
5. New synth voices from the mi-UGens in the Sound Lab; one Stem Designer round against 009 with Plaits candidates.

## Open questions
- Which machines do we play on (both Macs?), and are we fine with installing plugins on each?
- Which algorithmic reverb replaces the Strudel-measured IRs (kept for now, 2.3), and does it pass by ear on every track?
