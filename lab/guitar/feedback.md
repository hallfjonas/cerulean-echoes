# Guitar — feedback

## disco-guitar-1 (built 2026-11-08, for 009 Jonas 5–7) — NOT heard
- Brief (user): disco guitar, warm and organic, really leaning on house; earlier guitar loops were “messy
  and not in time” (lab/samples).
- Approach: single strokes cut from real recordings (onsets via spectral flux, sharpened on the waveform,
  chord checked via chroma) and played on our 16th grid with the track swing → sound from the player, timing from us.
  Chords: one recorded chord shape shifted by playback speed (like a sampler stab, max. ±6 semitones);
  major / add9 chords via the minor shape on the third (Am7 over F = Fmaj9, Em7 over C = Cmaj9, Em7 over G = G6/9),
  G11/G7 with Dm7, D9/D6 with the D strokes of the Tele (A C D E, without F♯).
- Sources (Freesound HQ preview, straight from cdn.freesound.org):
  Tele = [Funk_Tele_Am@110_bpm](https://freesound.org/s/167390/) by guitarelement, **CC BY 3.0** (credits needed);
  palm mute = [120_Dm_PMVibesRhythmGtr_01](https://freesound.org/s/716617/) by oceansonmars, CC0.
- Rhythms (button 1, the same in all columns): offbeat accents on “and” and on “e”, “every three 16ths” = Premier Guitar,
  [Rhythm Rules: 16th-Note Accents](https://www.premierguitar.com/articles/Rhythm_Rules_16th_Note_Accents) Fig. 3 / 4 / 8;
  Get Lucky = counting “1 & 2 e & a 3 & a 4 &” from [Modern Guitar Tuition](https://modernguitartuition.squarespace.com/all-posts/how-to-play-get-lucky-by-daft-punk).
  Row 3 = density of the muted ghost strokes (“steady motor”, [Cory Wong on Nile Rodgers](https://www.guitarworld.com/lessons/artist-lessons/cory-wong-on-what-he-learned-from-nile-rodgers)).
- Columns: 1 Tele ringing, 2 Tele short (Chic “chank”), 3 palm mute, 4 double (Tele left, palm mute right).
- Checked: in Node (notes / strokes per 16th, ≤ 3 ms/tick), all samples load and decode in the browser.
  Levels NOT measured (the previews cannot be rendered offline here): strokes brought to equal loudness, column levels guessed.
- Rejected while building: wah “chicka” (669643) — the ghosts have a clear pitch (wah resonance) and would clash;
  whole loops on our own grid — the Tele recording does not sit cleanly on 110 BPM (grid error ⅓ 16th).
- Feedback (user, 2026-11-08 evening): all bad. In house songs the guitar is rather plucked, with melody.
  Looked up (afterwards): Stardust “Music Sounds Better With You” = guitar riff from Chaka Khan “Fate” (Loopcloud remake:
  plucked high notes in call / answer with the e-piano, per bar two 16th strokes at the end of beats 3 and 4 + octave note,
  phaser, overdrive); Modjo “Lady” = guitar sample from Chic “Soup for One” (rhythm guitar, chord order rearranged).
  → Round 2 only after OK: plucked single notes / licks from real recordings (like the flute) instead of chord chanks.

## disco-guitar-2 (built 2026-11-08 night) — NOT heard
- Plucked single notes of a real Stratocaster ([nyanshell.strat](https://github.com/nyanshell/nyanshell.strat), MIT:
  every note F2–D6 recorded on its own, 3 takes, alternating), like a sampler on the chord tones of the progression.
- Figures: 1 Stardust / “Fate” (Loopcloud remake), 2 octaves in threes (Claydes Charles Smith), 3 thirds (Al McKay),
  4 “e & a 4” (Claydes Charles Smith) — all [Guitar World, 70s funk guitar masterclass](https://www.guitarworld.com/lessons/artist-lessons/70s-funk-guitar-masterclass);
  5–8 (call + answer, repeated note on 3-3-2, broken chord, pentatonic lick) in their spirit, notes MINE.
- Row 3 = complexity, button 1 = solo ↔ double (second guitar an octave higher), button 2 held = lift
  with phaser (over 2 bars, back over 1 bar).
- Feedback disco-guitar-2 (user, school grades, 1 = best): Stardust 2, octaves 4, thirds 4, e & a 4 2, call 3–4, repeated
  note 2, chord 4, lick 3; groovier lines. “Double” out — rather something a little duller plucked. Complexity must go much
  further up on all of them. Sound not good yet → show different sounds on a lab of their own.

## disco-guitar-3 + guitar-sounds-1 (built 2026-11-08 night) — NOT heard
- disco-guitar-3: Stardust, e & a 4, call + answer (tighter), repeated note, lick + new dead-note groove,
  off-16th pairs, pickup (MINE, in the spirit of the favourites). Row 3 in four steps: line → + dead notes → + slides and
  variation in bar 4/8 → + 16th motor of dead notes and pentatonic fill in bar 8. Button 1 = open ↔ muted.
- guitar-sounds-1: the same lines (Stardust, repeated note, e & a 4), eight sounds from the Strat: high string,
  lower strings, jazz, crunch, phaser, palm-muted, auto-wah, dub echo. Next option if none works: FreePats FSBS
  Clean (CC0) — would first have to go into the repo.
