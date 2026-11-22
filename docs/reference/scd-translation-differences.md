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
| 008-groove-techno | every-button (67 bars), warehouse (192 bars), techno-night (bars 0-312, 59,000 events), stem-check (162 bars) | 100 % | none | every stem −∞ dB, except the JX lane of the strings (random phases; its analogue lane alone nulls) |
| 010-ambient-house | every-button (to bar 67), journey (130 bars), stem-check (162 bars) | 100 % | none | every stem −∞ dB, except the keys column (noise-level residual, as between two renders of the old track) |
| 016-grroove-opus | stem-check only (162 bars; 016 has no perform scripts), without the Stab Shape controls | 100 % of the 13 sounding stems | none | every stem −∞ dB (the quiet JX strings leave noise-level residual) |
| 017-groove-lsd | stem-check only (162 bars; 017 has no perform scripts), without the Stab Shape controls | 100 % of the 13 sounding stems | none | every stem −∞ dB, except the noise-driven `modalPerc` and supersaw sounds (their residual equals hand-vs-hand) |

The audio null test also ran a global-column scenario (Tension, Fog, Thin and Master sweeps, Chapter, Break; 24 bars) on
every stem of all three tracks.

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

## 008-groove-techno

Compared with `--cc '{"12":1,"69":0.5}'` (Master at 1: the scripts never raise it, and a stem track plays no note while Master is 0).

| What | Difference | Why |
|---|---|---|
| Master at 0 | A column makes no notes while Master is 0; the old track made the (inaudible) notes anyway. The last 24 bars of `techno-night` fade Master to 0 at bar 312, so that script is compared up to bar 312 | The stem engine gates a column on its fader and Master; the old one only multiplied the strip |
| Column names, headings, pattern labels | As for 001 and 002; the eight-pattern columns (seq, stab, answer, dark perc) have `Loop 1`…`Loop 8` style labels instead of numbers | As above |
| Button 1 of the kick | `@ctl 16:1.b1` says `Pattern | double time: 8 kicks per bar while held.` instead of `Double time | …` | The label of button 1 is `Pattern` or `Chords` in the stem format |
| Chords column | `2:1.b1` is `Chords` (was `Pattern`) | The same rule; it steps the progression as before |
| Control texts | Shortened to the 60 characters a stem allows: kick Punch and Level, clap Level, pads Pump, strings Pattern, dark perc Roll | Schema limit |
| Pad Space | Default 0.5 on the stem (was set only when playing live); passed with `--cc '{"69":0.5}'` | `default` on the knob |
| Strings | Strings JX lane: audio is not bit-identical between any two renders (random phases); the analogue lane nulls | `sdSupersawWide` starts at random phases |

## 016-grroove-opus

Compared with `--cc '{"12":1}'` and a stem-check that leaves the controls of Mode 2 column 3 alone (the old Stab Shape: CC 55, 63, 71, 79, 87, 95).

| What | Difference | Why |
|---|---|---|
| **Stab Shape (2:3) is gone** | The old column had no sound: its knobs (Snap, Length, Resonance), fader (Drive) and buttons (Vanish, Ratchet) shaped the stab on column 4. Slot 2:3 now holds the 008 sequence stem (a hypnotic FM mallet loop; the old track had nothing there, and its fader at 0 keeps it silent). The stab plays with the shape at its zero positions (snap 3 octaves, decay 0.17 s, Q 8, no drive), which is what the old track played with Stab Shape untouched; Ratchet and "stab out by hand" are gone | The stem format has one set of controls per stem and a fixed label set; a stem over two columns is planned in PR #98 (multi-column stems), after which the pair can come back |
| Answer and the stab | The answer still plays in the bars the stab leaves (Vanish); the frame computes that (`stabHere`) for both | A stem cannot read another stem's state yet (same plan) |
| Wumms | Column 8's fader stays Wumms (no master volume, `masterless`); kick, rumble, sub and bass read it per note | As in 001 and 002 |
| Texts | Kick button 1 reads `Pattern`; texts cut to 60 characters (strings Pattern, answer Level, FX Complexity, accents) | Stem format |
| Names and labels | As for the other tracks; the eight-pattern columns have `Stab 1` … `Series 1` style labels | The same |
| Strings | The JX supersaw layers start at random phases, so two renders differ at noise level (the track is quiet there) | `sdSupersawWide` |

## 010-ambient-house

Compared with `--cc '{"12":1}'` (Master at 1). Column code of the 14 stems (`amb-*.scd`); the room and echo of every layer (Strudel `roomOf` / `bus`, raised by Tension) are kept as the columns' own state buses, updated on their knobs and on Tension (`~ce.ambientFx` in `sc/lib/stemkit.scd`); Tension's tone map (Fog x (1 + 1.5 t squared)) is the frame's, and the stems turn the strip's own Tension input off (`frame.tension: false`), as the old track did with its global Tension on CC 127.

| What | Difference | Why |
|---|---|---|
| Master at 0 | A column makes no notes while Master is 0; the old track made the (inaudible) notes anyway. `every-button` fades Master to 0 at bar 67, so it is compared up to bar 67 | As in 008 |
| Pattern buttons | The eight-pattern columns have labels `Rhythm 1` ... `Calls 8` instead of numbers | A stem's patterns have labels |
| Control texts, names | Shortened to 60 characters (noise Motion, clap Level, arp Complexity, marimba Complexity); `@col` names from the role (Kick, Texture, Pad, Chords, Lead ...) | Stem format |
| Chapter and Freeze | Unchanged: Chapter picks the next progression at the next 4-bar phrase; the pad's button 2 holds the chord of the moment for every column | The frame owns the root (`rootAt`) |
| Keys audio | Two renders of the old track already differ at noise level (-43.7 dB against the stem); the new track the same (-41.6 to -45.2 dB); events are equal | FM voice noise |

## 017-groove-lsd

Built like 016 and compared the same way (`--cc '{"12":1,"69":0.5}'`, stem-check without the Mode 2 column 3 controls). Kick, rumble, sub, bass and hats are the 016 stems; the other columns are stems of their own (wood, modal percussion, strings, acid stab, answer, accents, FX), the pad is the 016 pad with its Space default 0.5.

| What | Difference | Why |
|---|---|---|
| **Stab Shape (2:3) is gone** | As in 016: slot 2:3 holds the 008 sequence stem (silent at fader 0), the acid stab plays with its shape at the zero positions, and Ratchet and "stab out by hand" are gone | Same reason; see 016 and PR #98 |
| Answer and the stab | The answer follows the stab's Vanish through the frame (`stabHere`) | As in 016 |
| Noise-driven sounds | `modalPerc` (percussion, log, bell) and the supersaw strings use random noise or phases, so two renders of either track differ at noise level; the events are equal | The sounds |
| Texts, names, labels | As for the other tracks | The same |
