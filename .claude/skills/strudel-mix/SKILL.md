---
name: strudel-mix
description: Pre-mix a Strudel track automatically - render every stem solo offline with superdough, measure its loudness (LUFS, peak) and set the fader ranges so the stems sit in a sensible balance. Use when stems are too loud/quiet relative to each other, something clips, or a new track needs leveling.
---

# Strudel mix (automatic pre-mixing)

## Measure
```sh
cd tools && npm install            # once
node strudel-sim/measure.mjs ../tracks/NNN/<track>.strudel stem1_kick=5,29 stem4_hats=8,32 stem_melody1=53,77 stem_baseline1=69
```
`stem=faderCC[,charCC]`: the stem variable, its fader CC, optionally a knob swept over 0 / 0.5 / 1 (density, softness …).
Default base: global faders (CC 12, 60) = 1, Mode 16 lpf row (CC 21-28) = 1, everything else 0; override with
`--base '<json>'`. Renders run one at a time (~1 s each). Output: integrated loudness (BS.1770, K-weighted, gated)
over 4 cycles and the sample peak.

## Targets (rule of thumb for techno, relative to the kick at fader 1)
| part | target |
|---|---|
| kick | 0 dB (reference) |
| sub, bass | −3 … −5 dB |
| clap / snare | −5 … −6 dB |
| melodies | −4 … −6 dB |
| hats | −9 … −11 dB |
| percussion, fx, space | −8 … −12 dB |

Use the loudest knob position of a stem. New fader maximum = old × 10^(ΔdB / 20) (−3 dB ≈ × 0.71, −6 dB ≈ × 0.5).

## Apply
- New file (`NNN-mix.strudel`); change only the `range(0, max)` of the faders, with a comment giving the old value
  and the reason. Update the `@ctl … fader` tag text (layout sheet).
- Measure again and show before/after.
- Report, don't fix silently: peaks > 1 (clipping), big jumps across a knob's travel (e.g. an extra layer +9 dB).

## Limits (tell the user)
- LUFS underestimates bright, transient sounds (hats, claps) and small speakers lose the low end: final balance by ear.
- superdough version in Node (1.3.0) may differ from strudel.cc; reverb tails are not measured.
