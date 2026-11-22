# Translating hand-written SC tracks into stem tracks: what differs

The hand-written SuperCollider tracks (`sc/tracks/<id>/<id>.scd`) are translated one by one into stem tracks
(`<id>.track` + `<id>-frame.scd` + stems in `sc/stems/`, see [stems](../features/stems.md)). A translation is accepted at
95 % of the old track's events or better; every difference found is listed here, one section per track.

How a track is proven (in `tools/`; both versions play the same controller moves and every note is compared with all the
parameters its SynthDef reads):

```bash
node sc-port/stem-compare.mjs <script.json> <workdir> --track <id> --cc '<start values>' --map '<old stem name -> slot>'
```

The scripts are the track's own (`trajectory/perform/<id>/`) and `sc-port/scenarios/<id>-stem-check.json` (every pattern
button, every knob row, every button 2 held, global knobs, Chapter, Break, faders at 0, Launchkey). The mixer is proven with
an audio null test: each stem alone is rendered from the old and the new track (`CE_TRACK=<id>/<id>` and
`<id>/<id>.track`, `sc-port/sc-render.sh <scenario> <prefix> <stem>`) and the two WAVs are subtracted.

The old `.scd` of a translated track is deleted in the commit that adds the proof. It lives in git history:
`git show 7444173:sc/tracks/<id>/<id>.scd > sc/tracks/<id>/<id>.scd` puts it back next to the `.track` for a new proof.

## Overview

| Track | Scripts compared | Events equal | Stems below 100 % | Audio null test |
|---|---|---|---|---|
| 001-groove | sound-tour (176 bars, 26,082 events), stem-check (162 bars, 40,543 events) | 100 % | none | every stem −∞ dB, except the two supersaw columns (see below) |
| 002-groove | dance-floor (192 bars, 26,771 events), stem-check (162 bars) | 100 % | none | as 001 |

The audio null test also ran a global-column scenario (Tension, Fog, Thin and Master sweeps, Chapter, Break; 24 bars) on
every stem of both tracks.

## 001-groove, 002-groove

| What | Difference | Why |
|---|---|---|
| Column names in the layout (`@col`) | Kick, Perc, Bass, Lead, Hats, Chords, Pad, Fx … (the stem's role) instead of Snare, Acid, Electro, Break, Arp, Hook, Rave … | The stem-track tags make `@col` from the role. The six `@ctl` lines of every column are the same text as before |
| Layout and mode headings | `001-groove (stem track)`, `Mode 1 — Foundation` instead of `Track 001 — 80s groove house`, `Mode 1 — Foundation (beat + bass) · same CCs as Mode 16` | The same |
| Hook pattern names | `Hook 1` … `Hook 4` in the status line instead of `0` … `3` | A stem's patterns have labels |
| Knob start values | Pad Space 0.5 (both tracks), kick Ghosts 0.3 (002) are knob defaults of the stems, so offline renders start from them too; before, they were set only when playing live | `default` on the knob. The comparison passes the same values with `--cc '{"70":0.5}'` (001) and `--cc '{"29":0.3,"70":0.5}'` (002) |
| State bus names | `snRoom` → `s1_2_room`, `padEcho` → `s2_2_echo` … | Column code owns its states; names are not audible |
| Pad and strings audio | Two renders of the old track already differ from each other by the same amount (−31 dB against the stem at −34 dB) | `sdSupersaw` starts every voice at a random phase; the events (frequency, gain, filter, …) are equal |

Not changed: loudness (each stem's `gain` is the old `trim`), orbits, Tension's echo and room amounts (001: 0.4; 002: 0.2 and
0.35), the Launchkey, the Break, the 14 slots of both modes. The rumble, congas and organ of 002 and the variants of the
001 columns for 002 are stems of their own (`parent` points at the 001 stem they come from).
