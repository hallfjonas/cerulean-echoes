# 012 EDM Snippet — song design (gate 1, draft)

Draft for the user's approval. Nothing is built before "approved" is logged in `feedback.md` (this folder).
The performance itself is designed later (task 004, `tools/trajectory/perform/012-edm-snippet/`); this file only
sketches its arc. Decisions marked **(choose)** have two options; my pick comes first.

## The song

- Source: `gp-edm-snippet.mid` (Guitar Pro export), 120 BPM, 4/4, 24 bars = 48 seconds, no pickup, no markers.
- Key: G♯ minor. Two chords, one per bar: **G♯m** (odd bars) and **F♯** (even bars), all through.
- Every note has the same velocity (127): the file carries no dynamics, so loudness comes from our levels.
- One bar = one cycle (`setcps(120 / 60 / 4)`); song bar 1 = cycle 0, the song loops every 24 cycles.

### The 7 parts, as written

| Part (GM program) | Notes | Plays in bars | What it does |
|---|---|---|---|
| Spur 1 (30, distortion guitar) | 198 | 1-24 | Power chords (root, fifth, octave: G♯2-D♯3-G♯3 / F♯2-C♯3-F♯3). Bars 1-8 held a whole bar; from bar 9 a rhythm: hits on 16th 1, 7 and 11, plus a B power chord on the last 8th. |
| Spur 2 (30, distortion guitar) | 140 | 1-24 | Lead riff: the chord's root (G♯4 / F♯4) three times (dotted 8th, dotted 8th, quarter), then A♯4-B4 as a pickup. Notes get shorter from bar 8. |
| Drums (kick 36 only) | 87 hits | 5-24 | Bars 5-6 four on the floor; bar 7 a roll that speeds up (8ths → 16ths → 32nds → 64ths); from bar 9 four on the floor. |
| Spur 4 (38, Synth Bass 1) | 13 | 5-8 | Quarter notes on G♯1 / F♯1, the build only. |
| Spur 5 (120, GM "fret noise") | 64 | 5-7 | A chromatic run from A♯2 up to A♯6 that speeds up (8ths → 16ths → 32nds), then falls back in 64ths: a riser. |
| Spur 6 (34, picked bass) | 58 | 9-24 | Bass in the chord rhythm (G♯1 / F♯1, B1 on the last 8th), the drops only. |
| Spur 7 (29, overdriven guitar) | 139 | 5-24 | Arp in 8ths: G♯ A♯ B, G♯ A♯ B, A♯ B (3-3-2 grouping); on F♯ bars F♯ A♯ B. |

Bars 8, 16 and 24 are **stop bars**: every part plays one hit on the one, then silence, except the lead's pickup into
the next bar. Bar 24 leads straight back into bar 1, so the loop is seamless.

### Sections (no markers: 4- and 8-bar phrases)

| Section | Song bars | Script bars | What plays |
|---|---|---|---|
| Intro | 1-4 | 0-3 | Held chords + lead riff. No beat. |
| Build | 5-8 | 4-7 | + kick, synth bass, arp, riser; bar 7 kick roll; bar 8 stop bar. |
| Drop 1 | 9-16 | 8-15 | Kick, picked bass, chord rhythm, lead, arp; bar 16 stop bar. |
| Drop 2 | 17-24 | 16-23 | Identical to Drop 1; bar 24 stop bar → back to Intro. |

Intro + Build together are one 8-bar phrase (**Rise**, bars 1-8), so the song is 8 bars Rise + 16 bars Drop, and every
section boundary falls on an 8-bar line. That makes the switches below clean.

## Layout

One file `012-edm-snippet.strudel`, tagged `// @mode 16 Mode 1`, after `midi-layouts/templates/dual-lc.strudel` and
007-010: every controller optional, every LC XL 3 gets Mode 1 and Mode 2, column 8 global on both, `@shared` blocks as
in 007-010. Same row meaning everywhere: row 1 Brightness, row 2 Space, row 3 per column, fader Level, button 1
Pattern, button 2 a moment while held. All faders start down; all knobs at 0 = the song as written, dry and clear.

### Where the 7 parts go **(choose)**

- **A (pick): all 7 parts on Mode 1, columns 1-7**, low/long left → high/short right. One page plays the whole song;
  matches the PRD ("columns 1-7 = parts") and keeps the converter simple. Mode 2 holds extras (below).
- **B: split by role like 007-010.** Mode 1 (foundation): 1 Kick, 2 Riser, 3 Sub Bass, 4 Bass, 5-7 extras (Clap,
  Hats, Perc). Mode 2 (colour): 2 Chords, 3 Arp, 4 Lead, rest extras. Same column jobs as the other tracks (bass on
  Jojo's 4, lead on Jonas' 4), two players split the song; but the song is spread over two pages.

The table below is layout A.

### Mode 1 — the song (columns 1-7)

| Col | Name | Part | Voice **(choose: pick / alternative)** | Row 3 | Button 1 Pattern (≤ 3) | Button 2 |
|---|---|---|---|---|---|---|
| 1 | Kick | Drums | 909 kick (`RolandTR909` `bd`) / 909 kick + a sine body tuned to G♯1, deeper | Punch: tight ↔ hard | Written → Always → Half | Drop: kick out while held |
| 2 | Sub Bass | Spur 4 | sawtooth through a low-pass (~300 Hz), the "Synth Bass 1" growl / pure `sine` sub | Length: short ↔ long | Written → Always → Off-beat | Octave: up while held |
| 3 | Bass | Spur 6 | two detuned saws, low-passed ("reese" bass, EDM standard) / `sawtooth` pluck with a short filter envelope | Length: short ↔ long | Written → Always → Roots | Octave: up while held |
| 4 | Chords | Spur 1 | `supersaw` stabs (wide, the classic EDM chord) / real guitar: Stratocaster samples (`strat1-3`, lab/guitar) with drive | Length: stabs ↔ held | Written → Held → Stabs | Lift: wider, brighter while held |
| 5 | Lead | Spur 2 | two detuned `sawtooth`s, low-pass, a little glide / `square` lead (hollow, cuts through) | Glide: plain ↔ notes slide | Written → Octave up → Sparse | Echo throw: long echo while held |
| 6 | Arp | Spur 7 | `sawtooth` pluck (fast filter envelope) / `triangle` + `glockenspiel` layer (bell pluck, softer) | Length: short pluck ↔ long | Written → Always → 16ths | Octave: up while held |
| 7 | Riser | Spur 5 | the run on `sawtooth`, filter opening with it, + `white` noise sweep underneath / the run on `supersaw` only | Noise: notes ↔ notes + noise | Written → Every 8 bars → Off | Rise: noise sweep rises while held |

Pattern, in a song that plays verbatim:
- **Written** (always the first, the default): the part exactly as in the song, including where it rests.
- **Always**: the part's main figure in every bar, also where the song rests (kick under the intro, bass under the
  build). The notes follow the song's chord of that bar (G♯m / F♯), so it always fits.
- The third is a simpler or denser variant, named per column: Half (kick on 1 and 3), Off-beat (sub between the kicks,
  the EDM "pump"), Roots (one note per bar), Held (chords held a whole bar everywhere), Stabs (the drop rhythm
  everywhere), Octave up, Sparse (the lead's first note per bar only), 16ths (arp doubled), Every 8 bars (the riser
  into every 8-bar phrase, not only bars 5-7), Off (riser never).
- A press switches at the next bar (as in 007-010).

Voice notes:
- Sub Bass / Bass sit at G♯1 = 52 Hz: a pure sine there is felt more than heard and vanishes on laptop speakers; the
  sawtooth pick keeps overtones you can hear.
- Two `supersaw` voices (chords + lead) would blur into one wall; that is why the lead pick is plain saws.
- The Stratocaster samples start at E3: the power chords (G♯2-D♯3) would be pitched down from E3 or played an octave up.
- GM program 120 is "guitar fret noise", useless as a sound; the notes are a classic riser, so they get a riser voice.

### Mode 2 — extras **(choose)**

The song has no clap, hats or pad; EDM without them sounds thin. Faders start down, so the song stays verbatim until
someone brings an extra in.
- **A (pick): 4 extras**, following the sections when on Written (Clap and Hats only in the drops):
  1 Clap (`RolandTR909` `cp`, 2 and 4), 2 Hats (909 `hh` off-beat + `oh`), 3 Pad (`supersaw`, G♯m / F♯ held, slow
  attack), 4 Noise Pump (`pink` noise pumping with the kick). Columns 5-7 empty (no sound, label "–").
- **B: Mode 2 empty** in round 1; add extras only after the first listen.

### Column 8 — global (both modes)

| Control | Name | Does |
|---|---|---|
| Row 1 | Fog | clear ↔ muffled (all low-passes down). |
| Row 2 | Thin | full ↔ thin (all high-passes up). |
| Row 3 | Tension | build-up: echo, reverb, open filters; the end adds a snare roll. |
| Fader | Master | volume of everything (both LCs and the Launchkey). |
| Button 1 | Chapter | see below. |
| Button 2 | Break | 1st: low end out (kick, Sub Bass, Bass) at the next bar. 2nd: all back on the one. |

### Chapter in a verbatim song **(choose)**

- **A (pick): Song → Rise → Drop**, at the next 8-bar phrase. Song = the 24 bars as written, looping. Rise = bars 1-8
  (Intro + Build) loop, to stay in the build as long as you like. Drop = bars 9-16 loop. Because every section starts on
  an 8-bar line, this needs no memory beyond the button: the bar inside the section is the cycle mod 8.
- **B: Song ↔ Hold.** Hold repeats the 8-bar phrase playing now; pressing again continues with the phrase after it.
  More natural ("stay here"), but the track must remember where it held (a song offset).

Break stays as in 007-010 (low end out, then back on the one); in the Drop loop it gives the classic "break, then drop".

## How the 24-bar loop builds over repeats (arc sketch for 004)

Each repeat of the song is identical, so the build comes from the faders, Chapter and Tension, not from the notes.

1. Repeat 1 (bars 1-24): Chords and Lead only, Master up. The song is a quiet guitar sketch; the drops are just rhythm.
2. Repeat 2: + Kick, Bass, Arp in the drops; Sub Bass and Riser in the build; Clap + Hats (Mode 2) at Drop 1.
3. Repeat 3: Chapter → Rise: the build loops twice while Tension goes up; Chapter → Song at the top lands in Drop 1
   with Break pressed and released for a hard drop. Pad and Noise Pump in.
4. Repeat 4: Fog / Thin down to the intro only, faders out one by one; the song ends on a stop bar.

## Launchkey

- **Keys**: as in 008-010, so the knobs keep their meaning: mod wheel = Keys Level, k1 Brightness, k2 Piano → Rhodes,
  k3 B3 → M1, k4 Vibes → Marimba, k5 Length, k6 Space, k7 Echo, k8 Pad Fog. The song is in G♯ minor: G♯ A♯ B C♯ D♯ E
  F♯ (mostly black keys).
- **Pads** (16 one-shots, channel 10): left half (pads C1-G1) = the 8 spoken voice samples, as in 008-010. Right half
  (G♯1-D♯2) = EDM shots, all in `samples/sounds.json`:

| Pad | Name | Sound |
|---|---|---|
| G♯1 (44) | Clap | `rolandtr909_cp` |
| A1 (45) | Snare | `rolandtr909_sd` |
| A♯1 (46) | Open hat | `rolandtr909_oh` |
| B1 (47) | Crash | `rolandtr909_cr` |
| C2 (48) | Crash reverse | `rolandtr909_cr`, played backwards |
| C♯2 (49) | Drop hit | the 008 "Braaam" (`sawtooth` + `square` + `sine` layers) retuned to G♯ |
| D2 (50) | Zap | `sine` with a fast falling pitch (laser) |
| D♯2 (51) | Sweep down | `white` noise, filter falling |

## Voices checked

Every sound named above loads (`samples/sounds.json` `ok`, or a built-in synth): `RolandTR909_bd`, `RolandTR909_cp`,
`RolandTR909_hh`, `RolandTR909_oh`, `rolandtr909_cp/sd/oh/cr`, `sawtooth`, `square`, `sine`, `triangle`, `supersaw`,
`white`, `pink`, `glockenspiel`, `strat1-3` (Stratocaster, loaded with the track's own `samples()` as in lab/guitar).
No gm_* soundfonts in the stems.

## Mapping decisions (for 005, `012-edm-snippet-map.json`)

- Part → column: Drums 1, Spur 4 2, Spur 6 3, Spur 1 4, Spur 2 5, Spur 7 6, Spur 5 7 (layout A).
- Program → voice: 30 power chords → supersaw stabs; 30 single-note line → saw lead; 29 → saw pluck arp; 38 → saw
  sub bass; 34 → reese bass; 120 → riser (saw + noise); drum 36 → 909 kick.
- Chords per bar: odd G♯m, even F♯ (for Always / Held / Pad).
- Sections: Intro 1-4, Build 5-8, Drop 1 9-16, Drop 2 17-24; Chapter states Song / Rise (1-8) / Drop (9-16).
- The drum part writes every kick 6 times on top of itself (522 note-ons = 87 hits): the reader keeps one per hit.

## Open questions

1. Where the parts go: layout A (all 7 on Mode 1) or B (split foundation / colour like 007-010)?
2. Mode 2: four extras (Clap, Hats, Pad, Noise Pump) or empty for round 1?
3. Chapter: Song → Rise → Drop, or Song ↔ Hold?
4. Voices where I gave two: Kick (909 / 909 + tuned body), Sub Bass (saw / sine), Bass (reese / saw pluck), Chords
   (supersaw / real Stratocaster), Lead (saws / square), Arp (saw pluck / bell pluck), Riser (saw + noise / supersaw).
5. Chords: keep the guitar character of the song (Strat samples, driven) or go full EDM (supersaw)?
6. Pattern variants per column (third option): fine, or other wishes?
7. Pads: the 8 EDM shots above fine (Drop hit, Zap, Sweep down are new)?
8. Song start in a performance (bar 1 when Auto-perform starts) is decided in task 003; nothing to choose here.
