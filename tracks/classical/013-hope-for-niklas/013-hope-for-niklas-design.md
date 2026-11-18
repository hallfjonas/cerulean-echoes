# 013 A Hope for Niklas — song design (gate 1, draft)

Draft for the user's approval, made from the stub `npm run producer` generated from `gp-classical.mid` and
`013-hope-for-niklas-map.json`. Nothing is polished by hand before "approved" is logged in `feedback.md` (this
folder); every decision goes into the map, then the producer is re-run. The performance is designed after this gate
(`tools/trajectory/perform/013-hope-for-niklas/`). Decisions marked **(choose)** have options; my pick comes first.

A first version is already generated from this draft and passes the checks (verify, audibility, sounds), so it can be
heard in the player before deciding: Live → 013.

## The song

- Source: `gp-classical.mid` (Guitar Pro export), 110 BPM, 4/4, 56 bars ≈ 2 minutes, no pickup, no tempo change.
- Key: A minor. Part 1 Am – G – F – G, Part 2 Am with a D / C turn every 4th bar and an A major bar (46), Part 3 E – D
  / G – D (E mixolydian, a march), bar 55 silent but for the violin's E, bar 56 two final hits.
- The file has dynamics (velocity 15-127). They now play as written: one loudness per bar, or note by note where a bar
  changes (the cymbal crescendo in bar 30, the piano accents in Part 3).
- One bar = one cycle; song bar 1 = cycle 0; the song loops every 56 bars.

### The 9 parts, as written

| Part (GM program) | Notes | Plays in bars | What it does |
|---|---|---|---|
| Spur 1 (0, piano) | 800 | 1-56 | Repeated A3 (1-2, 11-12), an A minor arpeggio riff (3-10), the Am-G-F-G riff (13-30), 8th-note chords (31-46), chord stabs (47-54), final chord (56). |
| Spur 2 (42 cello → 35 fretless bass at 13 → 40 violin at 31 → 43 contrabass at 47) | 296 | 1-56 | Held A2 over 2-4 bars (cello), the bass line A-G / F / G (fretless), 8th-note double stops A-C (violin), half notes E-D / G-D (contrabass). |
| Spur 3 (40, violin) | 430 | 7-55 | Soft A5 16ths (7-10), a short 8th-note figure (13-30), a C-B-G-E 16th arpeggio (31-45), long notes E-F♯ / G-F♯ (47-55). |
| Spur 4 (45, pizzicato strings) | 484 | 7-56 | Root-fifth 8ths, then double stops (31-46), off-beat chords (47-54). |
| Spur 5 (14, tubular bells) | 204 | 47-56 | Six-note chords in quarters, Part 3 only. |
| Spur 6 (116, taiko) | 1,346 | 13-56 | Strummed six-string chords (E A D G B E, open strings) as a rhythm: 3-3-2 8ths, 16ths, a 32nd tremolo (43-45). |
| Spur 7 (61, brass section) | 360 | 19-56 | Sustained chords, the same as Spur 8 from bar 19. |
| Spur 8 (49 strings → 55 orchestra hit at 56) | 416 | 13-56 | Sustained chords; two orchestra hits in bar 56. |
| Percussion (35 bass drum, 49 / 57 crash) | 71 (+87 duplicates) | 30-54 | A cymbal crescendo (bar 30), a cymbal on each bar of Part 2, bass drum and cymbals alternating in Part 3. |

### Sections (the file's markers at bars 1, 31 and 47)

| Section | Song bars | Script bars | What plays |
|---|---|---|---|
| Part 1 | 1-30 (30) | 0-29 | Cello pedal and piano (1-12), violin and pizzicato join (7), the groove Am-G-F-G with fretless bass, taiko, strings (13), brass (19); cymbal crescendo in bar 30. |
| Part 2 | 31-46 (16) | 30-45 | Everything, driving 8ths and 16ths; a cymbal every bar; bar 46 A major. |
| Part 3 | 47-56 (10) | 46-55 | The march: bass drum + cymbals, bells, contrabass; bar 55 silent but the violin; bar 56 the end. |

## Layout

One file `013-hope-for-niklas.strudel`, tagged `// @mode 16 Mode 1`, after `midi-layouts/templates/dual-lc.strudel`
and 007-010 (every controller optional, column 8 global, `@shared` blocks as in 007-010), built by the producer from
the same template as 012. Rows: 1 Brightness, 2 Space, 3 Length (Damp on Percussion), fader Level, button 1 Pattern,
button 2 Lift (Drop out on Percussion). All faders start down; all knobs at 0 = the song as written.

### 9 parts into 7 columns **(choose)**

- **B (pick): Percussion = drums + taiko; Brass & Bells = Spur 7 + Spur 5.** The two rhythm parts share a column
  (both go out with Break); the bells join the brass, as both only add colour late (bells: Part 3 only). Strings and
  brass keep their own faders, so the two chord sections can be played against each other.
- **A: as B, but the bells join the strings** (the producer's default: the smallest part joins the nearest chord part).
- **C: 7 parts on Mode 1, the two smallest (drums, bells) on Mode 2.** No grouping, but the song is spread over two
  pages; Part 3 then needs Mode 2 to sound complete.
- **D: Strings + Brass in one column (they double each other from bar 19), bells on their own.** One fader for the
  whole chord pad; the strings-only bars 13-18 then cannot be told apart from strings + brass.

### Mode 1 — the song (layout B)

| Col | Name | Part(s) | Voice (SSO = Sonatina Symphonic Orchestra samples) **(choose: pick / alternative)** |
|---|---|---|---|
| 1 | Percussion | Drums + Spur 6 | Bass drum (SSO concert bass drum) and clash cymbals (SSO piatti) for kick and both crashes; the taiko chords as **timpani** on their lowest note (E), full chords loud, the 2-3 note ones soft (ghost notes) / the taiko as concert bass drum (unpitched, closer to a taiko) |
| 2 | Bass | Spur 2 | SSO cello section (sustained) 1-12 → **fretless bass as a synth** (soft triangle sliding into each note) 13-30 → SSO 1st violins 31-46 → SSO double basses 47-56 / fretless as SSO double basses pizzicato (stays orchestral) |
| 3 | Pizzicato | Spur 4 | SSO pizzicato: cellos below G3, violins above / violins only |
| 4 | Piano | Spur 1 | SSO concert grand (mezzo-forte samples) / the Steinway samples of the Launchkey keys (only F♯3-E4 sampled, so darker low notes) |
| 5 | Strings | Spur 8 | SSO string section, sustained, by register: cellos < G3, violas < G4, violins above; bar 56 an orchestra hit (strings + brass short) / strings staccato for the hit only |
| 6 | Brass & Bells | Spur 7 + Spur 5 | SSO brass, sustained, by register: trombones < E3, horns < E4, trumpets above; tubular bells = SSO chimes / bells as SSO glockenspiel (brighter, an octave up) |
| 7 | Violin | Spur 3 | SSO 1st violins, sustained / SSO solo violin (one player, more intimate) |

Row 3 Length: as written ↔ every note up to 4× longer (legato). Button 2 Lift: brighter and louder while held.
Percussion: row 3 Damp (let ring ↔ short), button 2 Drop out (pauses while held). Long notes tied over the bar line
(cello 1-12, a piano A2 in bar 10) ring their full length.

### Pattern (button 1)

For now every column has one pattern, **Written** (the part as in the song), so button 1 does nothing yet.
**(choose)** for each column up to two more, e.g.:
- **Octave up / down** (Violin, Pizzicato, Brass & Bells): the part transposed.
- **Always**: the part's main figure in every bar, also where the song rests (e.g. Pizzicato's root-fifth 8ths under
  the intro, Percussion's Part 3 march anywhere).
- **Every Part**: a section's figure in every bar of the song (e.g. Violin's Part 2 arpeggio).
- or keep Written only for round 1.

### Mode 2 **(choose)**

- **Empty for round 1 (pick)**, as generated: the song is complete on Mode 1.
- Extras for the second player: a choir pad on the chords (`gm_choir_aahs`, already loads), a timpani roll that swells
  while held, a harp arpeggio on the chords, a solo cello doubling the bass.

### Global column 8

Fog / Thin / Tension / Master / Chapter / Break as in 007-012. Tension: echo, reverb, filters open (there is no clap
roll here). Break: the low end goes out (percussion, cello, fretless, double basses), Break again brings it back on
the one.

### Chapter (global button 1) **(choose)**

Chapters switch at the next **2-bar phrase**: the sections are 30, 16 and 10 bars long, so 2 bars is the largest
phrase every section boundary falls on (with 4 or 8 bars Part 2 would start mid-phrase).

- **Song → Part 1 → Part 2 → Part 3 (pick)**, each part looped as long as the chapter stays. A chapter plays the bar
  the song itself is at in its first run: pressed during bar 37 of the song, Part 2 continues at bar 38 and then loops
  31-46, so the music does not jump. Back to Song, the song continues at its own place (the cycle count), which can be
  anywhere.
- **Each chapter starts at its first bar** when it takes over: Part 2 always begins at bar 31 (a clean restart, but
  it cuts in at a 2-bar line, wherever the song was). Needs a small change in the template (a chapter start that
  the scheduler remembers).
- **Part 3 without the ending** **(choose, either way)**: split Part 3 into Part 3 (47-54, the march, 8 bars) and
  Ending (55-56), and let the Part 3 chapter loop only the march; as it is, a looped Part 3 plays the silent bar and the
  final hits every 10 bars.

## Launchkey

Keys and knobs as in 008-012. Drum pads: left half the 8 spoken voice samples (as in 012), right half orchestral
one-shots: Timpani roll (crescendo on E), Bass drum, Cymbals, Cymbal roll, Tam-tam, Snare roll, Triangle, Orchestra
hit (E minor, strings + brass short). **(choose)** fine, or other shots?

## Measured (the generated first version, before any hand polish)

- `npm run verify`: transpile, sounds, layout/syx, tap (8 stems) ok; no performance script yet (on purpose).
- `npm run audibility` (all faders at 1): bars 47-50: no CLIPS, no SILENT, every stem within −2.4 / +2.1 dB of the
  median, mix peak 0.83; bars 31-34: violin −5.7 dB (its quiet arpeggio), mix peak 0.74; bars 13-16: brass SILENT
  (the song has no brass before bar 19, planned). Master fader range 0-0.4 (was 0.6, the mix clipped at 1.41).
- Sounds: 29 sounds, 0 broken (`check-sounds`), all 185 SSO sample files exist; 13 new names in
  `samples/sounds.json`.
- CPU: 3,667 events in 56 bars (the taiko's 1,346 notes become one hit per chord), at most 129 in one bar; querying
  costs 40 ms per bar (2.2 s), like 012 (44 ms), a fifth of 009 (198 ms). Every stem and every voice of a column is
  gated where its fader or the master is 0. Still to check: no drop-outs in the player on the M2 Air (many sustained
  samples ring at once in Part 2).

## Open questions

1. Grouping: B (pick), A, C or D?
2. Voices: the picks above, or an alternative for Percussion (timpani vs bass drum for the taiko), the fretless
   bass (synth vs orchestral), Piano, Brass & Bells (chimes vs glockenspiel), Violin (section vs solo)?
3. Timpani pitch: SSO names its timpani samples C1-C2, which may be an octave off; listen whether the E sits right.
4. Both crash cymbals (49, 57) play the same clash cymbals; the 16th crescendo in bar 30 is cymbals cut short. Fine, or
   a suspended-cymbal roll sample for that bar?
5. Pattern: Written only for round 1, or which extra patterns per column?
6. Mode 2: empty, or which extras?
7. Chapter: song's place (pick) or restart at the first bar; split off the Ending?
8. Pads: the eight orchestral shots fine?
9. Column names: "Bass" for Spur 2 (it plays violins in Part 2) fine, or another name?
