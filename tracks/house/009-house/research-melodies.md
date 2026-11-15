# Research melodies (2026-11-08) — [V] verified, [S] search hits only, [U] undocumented; nothing listened to

## Escravos De Jo
- [S] Trumpet Winston Byrd, flute Talib Kibwe, guitar Stephen Ulrich, perc. Claussell (Bandcamp snippet, page 404 today).
- [V] 118.9 BPM, 5:26 (cs.uwaterloo.ca/~dtompkin/music/disc/SPBRAZIL_ELC.html). [S] rolling baião groove, Nascimento melody.
- [U] The trumpet line itself: no description found.
- [V] Folk song "Escravos de Jó" (mamalisa.com/?t=es&p=208, MIDI mamalisa.com/midi/escravos.mid), C major, 2/4:
  part 1: pickup G4 | C5 B4 A4 | G4 … G4 | F4 E4 F4 A4 | G4. Part 2: G4 E4 G4 E4 | G4 E4 G4 C5 | E5 E5 D5 | C5 …
  "Guerreiros…" G A G G | G A G G | A G A B | C5. A fifth up (G major) = exactly the notes of A Dorian;
  part 1 then lands on D (root of D9). Rights [U]: traditional/anonymous; only use the folk melody.

## How brass/vibe lines are built
- Sax over house: strict 8-bar phrases, simple rhythms, repeat the lick, fill gaps instead of competing,
  A minor pentatonic (saxschoolonline.com/articles/dj-sax-how-to-get-started/) [V].
- Afro house: deliberately simple lead line (3 notes), repeated motifs, 118–122 BPM (native-instruments.com/blogs/blog/afro-house-production-101) [V].
- Latin brass: stabs short, on the offbeat [S]; Louie Vega: "melody is key", even with a short hook [S]; fast lines sit
  badly on brass; call – pause – answer [S].
- Conclusion: a 2–4-bar motif (pentatonic/Dorian, 8ths + offbeat 16ths, long landing notes), 1–2 bars pause, answer;
  variants only change the end, the entry or the degree.

## Variation instead of randomness (Strudel, checked in the source code)
- `pick`: choose between written variants; plan e.g. "<0!2 0!2 1!2 0!2>" (A A B A, 2 bars each).
- `ribbon(offset, cycles)`: random once, then a fixed 8-bar plan (knob = offset → different but fixed plan).
- `wchooseCycles`, `lastOf(4, x => x.late(1/16))` (shift), `linger` (fragment), `.add(...)` before `.scale` (degree),
  call/answer between columns via `mask("<1 1 0 0>")` / `"<0 0 1 1>"`.

## Sound sources
- VCSL (in Strudel): sax, sax_stacc, sax_vib, saxello, vibraphone, vibraphone_soft, marimba (check the octave: maybe +1).
- VSCO 2 CE: trumpet sus / susvib / stac / straightM-sus / harmonM-sus (Harmon mute = "Miles" colour); file names an octave
  too low (D4 sounds D5).
- Karoryfer Weresax (alto), Bear Sax (baritone), CC0.
- Recorded phrases (Freesound): 77706–77717 sorohanro "Jazz Trumpet Loops in F" (CC BY, 12 real phrases, 90 BPM → as one-shots);
  424876 / 424894 emirdemirel "Improvisation on Dorian" trumpet / sax (CC BY, Bb Dorian, for cutting);
  479052 tenor phrase G Dorian (CC0); 131275 sax loop 120 BPM 8 bars (CC0); 753346 vibraphone melody (CC0).
  No real brass phrase at 120–126 BPM in A found.

## Phrase drafts (agent, not listened to) — 16 steps per bar, odd bars Am9, even D9
- T1 "Escravos call" (folk song part 1, a fifth up): b1 g5@3 ~ f#5 e5@2 d5@7 ~ d5 | b2 c5@2 b4 c5@2 e5@2 d5@5 ~@4 | b3 ~@16 | b4 ~@14 d5@2
  Variants: straight folk-song rhythm; open end on F#; one degree higher.
- T2 "Answer" (folk song part 2): b3 ~@4 d5 ~ e5 d5 ~@2 d5 ~ e5 ~ f#5@2 | b4 g5@2 f#5@6 ~@6 d5@2
- T3 "Pentatonic hook": [~@2 e5 ~ g5@2 ~ a5@3 g5 e5@2 ~@3] [~@2 d5 ~ c5@2 ~ a4@6 ~@3] (+ variants end E / entry later)
- T4 "Long notes" (Harmon mute) [U].
- V1 vibe offbeat accompaniment, V2 vibe echo of T1 an octave lower in bars 3–4, V3 tresillo 3-3-2 (vibe/marimba).
