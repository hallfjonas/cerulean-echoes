---
name: strudel-mix
description: Levels and audibility of a Strudel track, measured offline instead of guessed - every stem, the Launchkey keys and every drum pad / voice sample rendered with superdough, loudness (LUFS), peak, flags SILENT / LOW / CLIPS, then fader and gain ranges set so everything sits in balance. Use when something is too quiet or too loud, can't be heard, clips, or a track needs leveling ("louder", "quieter", "too quiet", "can't hear", "level", "leiser", "lauter", "clips", "balance", "Pegel").
---

# Strudel mix (levels and audibility)

Never leave a level to the user's ears alone: measure first, then change, then measure again.

## 1. Audibility check (start here)
```sh
cd tools && npm install            # once
node strudel-sim/audibility.mjs ../tracks/<genre>/NNN-<name>/<track>.strudel
```
Default state: every LC fader (CC 5-12, Mode 2 CC 53-60) at 1, every knob and button at 0, plus the track's
`KNOB_DEFAULTS` / `LK_DEFAULTS`. Options: `--cc '<json>'` overrides controls (Launchkey as `lk<cc>`, `lk1` = mod wheel;
e.g. a Launchkey sound knob to hear another keys sound), `--keys '<mini-notation>'` the test chords for the keys.
It renders one process after another (~1 min for 30 layers): the whole mix, every stem of the master solo, the Launchkey
keys (`stemLK`, mod wheel 1), every `LK_SHOTS` pad once (dry, no room/delay). BPM is read from `const bpm`.

| column / flag | meaning |
|---|---|
| LUFS | integrated loudness (BS.1770, gated) |
| LUFS-M | loudest 400 ms block: the level that is compared (fair for sparse hits and one-shots) |
| Δmed | LUFS-M minus the median of the stems |
| SILENT | nothing sounds at the default state (a gate, a control that is never read, a sound that does not load) |
| LOW | more than 12 dB below the stems' median: will be lost in the mix |
| CLIPS | sample peak above 1 (the MIX row is worst case: every fader up at once) |

Every SILENT and LOW row needs an answer before the track is called done: intended (say why) or fixed.
"All knobs at 0 must already sound good" (CLAUDE.md): a SILENT stem at the default state breaks that rule.

## 2. Stems in detail (knob sweeps)
```sh
node strudel-sim/measure.mjs <track> --base '{"12":1,"60":1}' stemJ1_kick=5,29 stemN2_keys=54,78
```
`stem=faderCC[,charCC]`: the stem variable, its fader CC, optionally a knob swept over 0 / 0.5 / 1. Pass `--base` for
the one-file tracks: the default base (CC 12, 60, 21-28 = 1) is the old 006 layout, where 21-28 was the lpf row; in the
one-file layout that is Space, and CC 28 is the global Thin. Tempo: `BPM=<n>` in the environment (default 140).

## 3. Launchkey keys, pads and voice samples
- Keys: `stemLK` with the mod wheel (`lk1`) at 1 is the loudest the player can make them. Level them with the sound
  gains (`LK_SRC`, `LK_KEYS_GAIN`), not with the wheel: at wheel 1 they should sit about at the melodic stems (Δmed 0 …
  +6). The sound knobs (`lk31`…) switch sounds (piano, Rhodes, organ, vibes, marimba …): check each sound the track
  offers with `--cc`, e.g. a weak marimba is not visible at the default sound.
- Pads (`LK_SHOTS`): each shot's `gain` levels the hit to about −15 LUFS-M dry. New gain = old × 10^((−15 − LUFS-M) / 20).
  gm_* shots are rendered from the soundfont as strudel.cc plays it (`render.mjs`; `pad-levels.mjs` skips them).
- Voice samples (own recordings in `samples/voice/`) load from main on GitHub: an unpushed sample is SILENT.
  `pad-levels.mjs` (`OWN=<url>`) measures them from elsewhere.

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
- Ask before changing sound or levels unless that is the task (CLAUDE.md). One-file tracks (007-010) are edited in
  place; other tracks get a new file. Change only `range(0, max)` of the faders, shot `gain`s or the keys' sound gains,
  with a comment giving the old value and the reason. Update the `@ctl … fader` tag text (layout sheet).
- Run the audibility check again and show before/after.
- Report, don't fix silently: peaks > 1 (clipping), big jumps across a knob's travel (e.g. an extra layer +9 dB).

## Limits (tell the user)
- LUFS underestimates bright, transient sounds (hats, claps) and small speakers lose the low end: final balance by ear.
- superdough version in Node (1.3.0) may differ from strudel.cc; reverb tails are not measured; pads are measured dry.
