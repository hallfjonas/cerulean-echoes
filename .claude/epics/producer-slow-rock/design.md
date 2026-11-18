# 015 Slow Rock — design (gate 1)

Status: draft, waiting for the user's answers to the open questions and "approved" (logged in the track's `feedback.md`
once the track exists). Nothing is built before that.
Source: `tracks/rock/015-slow-rock/gp-slow-rock.mid` (Guitar Pro export), read byte by byte for this design.

## Meta

| | |
|---|---|
| Key | D minor (verse Dm – Am – B♭ – F, chorus Dm – F – C – B♭) |
| Tempo | 100 BPM, then **115 BPM from bar 100** (tempo change in the file, see question 1) |
| Metre | 1/4 pickup bar (bar 0), then 4/4 |
| Length | pickup + 124 bars ≈ 4:50 (bars 1-99 ≈ 3:58 at 100, bars 100-124 ≈ 0:52 at 115) |
| Notes | 5,223 (guitar 1: 1,593, drums: 1,525, guitar 2: 556, lead: 482, taiko: 480, bass: 365, vocal: 222) |
| Mood | dark, steady slow rock ballad that ends in a fast, heavy finale |

Differences to the PRD table: the file has **8 markers** (Refrain twice), not 12; the tempo is **not constant**; the
'taiko' track (program 116) plays two open-string strums per bar (E A D G B E on beat 1 and 1-and), i.e. a percussive
boom, not a melody.

## Parts in the file

| MIDI track | Program | Role | Plays in bars |
|---|---|---|---|
| Spur 1 | 29 overdriven guitar | Guitar 1: arpeggio (chord tones, 8ths); power-chord riff with dead notes in the finale | 0-91, 99-124 |
| Spur 2 | 33 bass | Bass: half notes on chord roots; D pedal in the outro; 16th riff in the finale | 0-124 |
| Schlaginstrumente | drums (ch 10) | Kick 35/36, side stick 37, snare 38, hats 42/46, crash 49, toms 41/43/47 | 1-124 |
| Spur 4 | 29 overdriven guitar | Guitar 2: octave counter-line (D3 + D4) | 17-41, 50-66, 83-91, 101-107 |
| Spur 5 | 116 taiko | Taiko: two open-string strums per bar = a boom | 83-98, 100-124 |
| Spur 6 | 29 overdriven guitar | Lead: solo, then lead over the finale | 66-91, 104-124 |
| Gesang | 26 jazz guitar | Vocal line (the melody, played by a guitar patch) | 9-33, 42-66 |

## Sections (from the markers; bar 1 = first full bar after the pickup)

| # | Section | Marker | Bars | Who plays (as written) |
|---|---|---|---|---|
| 1 | Intro | Intro | 1-8 (pickup bar 0) | guitar 1, bass, drums |
| 2 | Verse 1 | Vers 1 | 9-24 | + vocal; guitar 2 from 17 |
| 3 | Chorus 1 | Refrain | 25-33 (8 + 1 turnaround bar) | full band + vocal |
| 4 | Interlude | Zwischenspiel | 34-41 | guitar 1 + 2, bass, drums (no vocal) |
| 5 | Verse 2 | Vers 2 | 42-57 | as verse 1, guitar 2 from 50 |
| 6 | Chorus 2 | Refrain | 58-66 | as chorus 1; lead enters on bar 66 |
| 7 | Solo | Solo | 67-90 | lead (sparse in 67-82, busy in 83-90); guitar 2 and taiko join at 83 |
| 8 | Outro | Outro | 91-99 | bass D pedal, drums, taiko; bar 99 almost silent (a pause before the finale) |
| 9 | Finale | (no marker) | 100-124 at 115 BPM | heavy riff: double kick, bass 16ths, taiko, lead from 104; bar 124 = last chord |

Section names in the track and the live view are English (Verse, Chorus, Interlude); the German marker names stay in
the map file so the converter finds them.

## Columns (Mode 1 = Jojo, foundation · Mode 2 = Jonas, colour · column 8 global)

All parts play note for note; the fader gates each stem. With all knobs at 0 the song sounds as written.

| Col | Mode 1 (foundation) | Mode 2 (colour) |
|---|---|---|
| 1 | Kick (35/36) | Guitar 1 — arpeggio / finale riff (Spur 1) |
| 2 | Taiko (Spur 5) | Guitar 2 — octave line (Spur 4) |
| 3 | Bass (Spur 2) | Lead (Spur 6) |
| 4 | Snare (38 + side stick 37) | Vocal (Gesang) |
| 5 | Hats (42/46) | empty |
| 6 | Cymbals / Toms (49, 41/43/47) | empty |
| 7 | empty | empty |
| 8 | Global | Global |

The drum track is split into four stems (kick, snare, hats, cymbals/toms) so Jojo can shape the kit like in 007-010;
together with the six pitched parts that is 10 stems, 8 of them from the song's 8 MIDI tracks (incl. vocal).

### Rows per column

| Col | Row 1 Brightness | Row 2 Space | Row 3 | Fader | Button 1 Pattern | Button 2 |
|---|---|---|---|---|---|---|
| M1 1 Kick | dull thump ↔ click | dry ↔ room | Softness | Level | as written ↔ only on the one | Drop out (while held) |
| M1 2 Taiko | dull ↔ hard skin | dry ↔ big hall | Length | Level | as written ↔ one boom per bar | Lift (pitch rise while held) |
| M1 3 Bass | round ↔ growl | dry ↔ room | Length | Level | as written ↔ roots only | Octave (up, while held) |
| M1 4 Snare | soft ↔ crack | dry ↔ plate | Length | Level | as written ↔ backbeat only (2 and 4) | Roll (while held) |
| M1 5 Hats | soft ↔ crisp | dry ↔ room | Length | Level | as written ↔ quarters only | Open (while held) |
| M1 6 Cymbals | dark ↔ sizzle | dry ↔ hall | Length | Level | as written ↔ crash only | Crash (one hit now) |
| M2 1 Guitar 1 | dark ↔ bright | dry ↔ echo + room | Drive (clean ↔ crunch) | Level | Chords: as written ↔ held chords (one per half bar) | Echo throw |
| M2 2 Guitar 2 | dark ↔ bright | dry ↔ echo + room | Drive | Level | as written ↔ upper octave only | Echo throw |
| M2 3 Lead | dark ↔ bright | dry ↔ long echo | Drive | Level | as written ↔ one octave up | Echo throw |
| M2 4 Vocal | dark ↔ bright | dry ↔ hall | Length (legato ↔ short) | Level | as written ↔ doubled an octave below | Echo throw |

Button 1 never adds notes the song does not have: the second pattern is a thinned or doubled version of the written
part, so the song stays recognisable.

### Column 8 (global, both modes)

| Control | Name | What it does in this track |
|---|---|---|
| Knob 1 | Fog | clear ↔ muffled (all low-passes down) |
| Knob 2 | Thin | full ↔ thin (all high-passes up) |
| Knob 3 | Tension | build-up: echo, reverb, open filters; past half a snare roll |
| Fader | Master | volume of everything; 0 = silent at start |
| Button 1 | Chapter | **Loop ↔ Play on**: Loop repeats the current section at its end; Play on continues the song (see question 2) |
| Button 2 | Break | 1st: kick, taiko, bass out. 2nd: all back on the one |

The song position runs on by itself (cycle count, looped at the end); Chapter is the only way to bend the form, so a
live player can stretch the solo or the interlude without leaving the written notes.

## Voices (genre-fit, no gm_* soundfonts; every sound checked with `check-sounds` in epic task 003)

Two options where the choice is not obvious:

| Part | Option A — real guitars (recommended) | Option B — synth rock |
|---|---|---|
| Guitar 1 | Strat samples (`strat1-3`, nyanshell, already whitelisted) + `shape` crunch | sawtooth through `lpf` + `distort`, short decay |
| Guitar 2 | Strat samples, lower strings, a little chorus/phaser | square + `distort`, detuned |
| Lead | Strat samples + more drive + long echo | supersaw lead, `distort`, long echo |
| Vocal | soft voice-like synth (triangle + slow attack + vibrato), so it does not fight the guitars | same, or a soft organ-like sine stack |

| Part | Voice |
|---|---|
| Kick / snare / hats / cymbals / toms | an acoustic-sounding drum-machine bank (candidates to compare in epic task 003: LinnDrum, Linn9000, AkaiXR10); fallback RolandTR909 already in use |
| Taiko | low tuned tom from the same bank, pitched down + long room; fallback a sine drop (kick-style synth) |
| Bass | sawtooth + low-pass (round finger bass), `shape` for growl on row 1 |

## Launchkey (stem `stemLK`, same knob meaning as 009)

- Keys: a pad in D minor — warm organ (B3-style) as default, for rock-ballad glue under the choruses.
- Mod wheel: keys level × Master.
- Knobs 31-38: k1 Brightness, k2 Organ → Rhodes, k3 Strings, k4 Piano, k5 Length, k6 Space, k7 Echo, k8 Pad Fog.
- Drum pads (16 one-shots): crash, ride bell, china, floor tom, tom fill, snare flam, reverse cymbal, taiko hit,
  power chords D5 / B♭5 / C5 / F5 (Strat, crunch), pick slide, feedback squeal, gong, clap.

## Performance arc (auto-perform, script v2, sections = the 9 above, one pass ≈ 5 min)

| Section | Mood | Moves |
|---|---|---|
| Intro 1-8 | dark, opening | Master 0 → up over 4 bars; Fog high → clear by bar 8; Guitar 1 Space high |
| Verse 1 9-24 | calm | Vocal fader up at 9; Guitar 2 fader up at 17; Guitar 1 Space back to half |
| Chorus 1 25-33 | open | Guitar 1 Brightness up; Tension small push in 31-32, back to 0 on 33 |
| Interlude 34-41 | air | Break at 34, back at 38; Echo throw on Guitar 1 at 41 |
| Verse 2 42-57 | calm, a little thinner | Thin up a quarter, back down by 56 |
| Chorus 2 58-66 | lift | Tension rising 63-66 into the solo; Lead fader up at 66 |
| Solo 67-90 | the peak of the ballad | Chapter = Loop once on 67-82 (solo stretched by 16 bars), then Play on; Lead Brightness rises 83-90 |
| Outro 91-99 | darkening | Fog closes slowly; Tension peak 97-98, released on the pause bar 99 |
| Finale 100-124 | heavy, fast | Fog clear, Thin 0 at 100; Drive up on Guitar 1 and Lead; all Space up on the last chord (124) |

## Why it fits the genre

- Slow rock lives on the song form: verse / chorus / solo stay as written, the live controls shape sound and space,
  not the notes.
- The sparse-to-dense arc (intro alone, vocal, second guitar, solo, heavy finale) is already in the song; the
  performance only adds what a mixing engineer would ride: fader entries, a darker outro, an echo throw.
- Real guitar samples with crunch keep it rock; drums stay acoustic-sounding; the taiko boom marks the big sections.

## Mapping decisions for epic task 005 (`015-slow-rock-map.json`)

part → column / mode / voice (table above), drum notes → four stems, sections with bar ranges and English names,
pickup bar = bar 0 (played at the end of the loop before bar 1), tempo 100 with section 9 at 115, Chapter = Loop ↔
Play on, Break = kick, taiko and bass out.

## Open questions

1. Finale tempo: play bars 100-124 at **115 BPM as written** (bars there are shorter than one cycle) or keep **100 BPM**
   throughout (simpler, every bar = one cycle, finale less fast)?
2. Chapter: **Loop ↔ Play on** (stretch a section) — or something else, e.g. jump to the next chorus?
3. Guitar voices: **Option A (Strat samples + crunch)** or **Option B (synth rock)**? And the vocal line: soft synth
   voice, or a real-sounding instrument (e.g. a sampled organ / flute)?
4. Mode 1 column 7 and Mode 2 columns 5-7 stay empty — fine, or add extra layers (e.g. a pad doubling the chords)?
