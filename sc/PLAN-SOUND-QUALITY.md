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
   - `.tanh` / `.fold2` in the `drive` block and in `bassPluck`, `softTom`, …: oversample the shaper (candidates
     in 4.3) or at least low-pass before and after it;
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
7. **Club output (safety, one PR, listened to together):** standard protection for a club sound system, all in
   `sc/lib/mixer.scd` unless noted. Changes every track slightly.
   - Low cut (~150 Hz) on the reverb and delay inputs: kick, sub and bass are mono, but their Space send puts stereo
     energy into the sub range today. One filter per return (`~ce.hpf`), the stems stay as they are.
   - Master: a deep high-pass (~25 Hz) and `LeakDC` (removes DC offset, a constant shift that wastes headroom and
     clicks at starts and stops).
   - Master: mono below ~100 Hz, by high-passing only the side (stereo difference) signal.
   - Master: a blow-up guard before the limiter (`Sanitize`, if our SC version has it): replaces invalid values from
     an exploding filter with silence.
   - The limiter stays (ceiling -1 dBFS; it should hardly act, if it does the track is too loud).
   - With 2.1 (48 kHz in the player) and a choice of the audio output in the player settings (today: the Mac's
     default output).
   Later, as the library grows: `~ce.checkSound` measures a sound's side energy below ~120 Hz and warns (the `mono:`
   key is only declared today, not enforced).

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

### 4.3 Researched 2026-11-27: reverbs, anti-aliasing, Faust
What the sources say; nothing tested here yet. "Not confirmed" = the search found no source.

**Reverbs (for 2.3).** No head-to-head comparison found, so the ear test decides.
- `NHHall` (sc3-plugins, NHUGens): algorithmic, modulated allpass loop, adjustable stereo spread, infinite hold
  ([source](https://sources.debian.org/src/supercollider-sc3-plugins/3.13.0~repack-1/source/NHUGens/nh_hall.hpp)).
- `JPverb` (sc3-plugins, DEINDUGens): modelled on the chorused sound of vintage Lexicon and Alesis units, made for
  synthetic sources rather than realistic rooms; `Greyhole` is its sibling
  ([JPverb docs](https://javadoc.io/static/de.sciss/scalacolliderugens-plugins_2.11/1.19.0/de/sciss/synth/ugen/JPverb.html)).
- `GVerb` (built into SC): room size, reverb time, damping, spread
  ([docs](https://docs.supercollider.online/Classes/GVerb.html)).
- Faust's reverb library lists JPverb, Greyhole, Freeverb, Dattorro and zita-rev1 (a free FDN reverb by Fons
  Adriaensen) ([reverbs.lib](https://faustlibraries.grame.fr/libs/reverbs/),
  [zita-rev1](https://dsprelated.com/freebooks/pasp/Zita_Rev1.html)).
- Candidates for the ear test: NHHall, JPverb, Greyhole; zita-rev1 (via Faust) only if none of them passes.

**Anti-aliasing (for 2.2).**
- SC core has no oversampling, and many core oscillators are not band-limited
  ([Tour of UGens](https://depts.washington.edu/dxscdoc/Help/Guides/Tour_of_UGens.html)).
- `portedplugins` (Mads Kjeldgaard, GPL-3, install `Plugins.installPlugin("portedplugins")` or a release):
  `AnalogVintageDistortion` (oversampling up to ×16), `AnalogTape` (oversampling), `LockhartWavefolder` (anti-aliased
  folder), `VAKorg35` (virtual-analog Korg35 filter)
  ([repo](https://github.com/madskjeldgaard/portedplugins),
  [AnalogVintageDistortion](https://doc.sccode.org/Classes/AnalogVintageDistortion.html)).
- `DADAA` (Robbie Lyman): anti-derivative anti-aliased distortions ([repo](https://github.com/robbielyman/DADAA)).
- Background: oversampling is the standard baseline against aliasing in waveshaping; 8× at 44.1 kHz was generally
  enough for distortion in the tests of Kahles et al. 2019
  ([paper](https://acris.aalto.fi/ws/portalfiles/portal/34665796/ELEC_Kahles2019_Oversampling_JAES.pdf)).

**Faust (a language for audio DSP).**
- `faust2supercollider` ships with Faust and compiles a `.dsp` file into an SC plugin (`.scx` plus a class file); it
  needs SC's plugin headers ([CCRMA](https://ccrma.stanford.edu/realsimple/faust/Using_FAUST_SuperCollider.html)).
- Its virtual-analog library `vaeffects.lib` has `moog_vcf` (self-oscillating at the top of its range) and
  `diodeLadder`; the Faust examples include Korg35 filters and a Sallen-Key one-pole low-pass
  ([vaeffects](https://faustlibraries.grame.fr/libs/vaeffects/), [examples](https://faustdoc.grame.fr/examples/filtering)).
- Apple Silicon: found only a 2021 workaround that forces an x86 build
  ([gist](https://gist.github.com/madskjeldgaard/8e484b88ee16df3d9ab9b180480a043c)); a native build is not confirmed.
  Test once before relying on it.
- Use it only for a block no SC plugin covers (e.g. an analog filter for `018-alt` if `DFM1`, `MoogLadder` and
  `VAKorg35` are not close enough). Each Faust plugin is a build step and an install on every machine.
- **When to check Faust again:** only for one of SC's two limits, and only if no ready plugin covers it:
  - feedback patched in SC (`LocalIn` / `LocalOut`, buses) is delayed by one block (64 samples, about 1.3 ms at
    48 kHz): audio-rate self-modulation, cross-modulation with feedback, a filter feedback path built from separate
    UGens. Feedback inside one UGen (e.g. `MoogLadder`'s resonance) is not affected. A server block size of 1 fixes it
    but costs a lot of CPU.
  - hard nonlinearities (saturation, folding) alias, and SC core has no oversampling (portedplugins above first).
  Slow modulation (LFOs, envelopes, the 018-alt pin matrix) is not affected by either.

## 5. How to compare

- **Sample by sample:** old and new back to back, at the same loudness. No tool for this yet: it needs a small one
  (e.g. a page in Labs with old / new per sample).
- **In the mix:** the Stem Designer, the new version against the current one, played against 009.

## 6. Order (proposal)

1. Quick wins 2.1, 2.2, 2.4 (no new dependencies).
2. The sample-by-sample comparison (5).
3. Install sc3-plugins, mi-UGens and portedplugins on both machines; a check in `verify-sc` for missing UGens.
4. Better reverb (2.3), drum and piano sample upgrade (3).
5. New synth voices from the mi-UGens in the Sound Lab; one Stem Designer round against 009 with Plaits candidates.

## Open questions
- Which machines do we play on (both Macs?), and are we fine with installing plugins on each?
- Which algorithmic reverb replaces the Strudel-measured IRs (kept for now, 2.3), and does it pass by ear on every track?
