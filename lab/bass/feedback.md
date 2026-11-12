# Bass lab — feedback

## House Bass 1 — house-bass-1.strudel (2026-11-08), for 009 Jojo 4
- Research: tracks/009-house/recherche-bass.md. Eight columns = style + sound, Engine 3 (follows all 21 progressions,
  Kerri push 2 16ths): 1 M1 organ bass, 2 Juno, 3 disco octaves, 4 root rhythm, 5 Daft Punk (FM), 6 chord-tone themes
  (8-bar theme), 7 Jojo 4 as in the track (no ghost improviser), 8 deep sub ostinato. Three lines each (button 1),
  button 2 = octave up while held.
- Transitions: approach notes into every change (A = semitone below, B = scale step above, B A = enclosure); chord tones
  diatonic in the progression's mode; slash chords (G7/F) keep the bass note, the other tones come from the chord's root.
- Checked in Node (notes per bar for every column over progression 19 „Am G/F F Dm“, transpile ok, ~3.5 ms/tick with
  one column). Levels offline (Brightness 0.6, first line): all −25 LUFS = column 7 (Jojo 4). Not heard. Feedback: open.
- Feedback (user, 2026-11-08 night): work on the LINES rather than the sound. The columns changed everything at once;
  change one thing at a time (either sound or lines). Overall still too tame, must be groovier: new lines. Sound: Daft
  Punk (FM) quite nice, Juno good as a very different alternative.

## House Bass 2 — house-bass-2.strudel (2026-11-08 night)
- One sound everywhere, row 3 = FM bass (Daft Punk) → Juno; columns differ only in the line: line families after what
  analyses describe of real records (Voyager, Instant Crush, Get Lucky / Around the World, Tensnake “Coma Cat”, Chains /
  Alright octaves, Something About Us, 52nd Street beat 4 open, Da Funk dead notes); notes mine within those rules.
  New: short plucky notes (r / o), slides between any notes (~), lengths part of the line. Approach notes as round 1.
- Node: notes per bar ok (progression 19), ~3.6 ms/tick. Levels offline: FM −24.3 / −25.9, Juno and middle within ±1 dB.
- Feedback round 2 (user): the bass sounds quite good in principle, but the principle: the COLUMNS should only differ in
  sound and the lines on the buttons should be the same everywhere. (Too many lines, but fine: he can choose.)

## House Bass 3 — house-bass-3.strudel (2026-11-08 night)
- Columns = the 8 sounds of round 1 (FM, Juno, M1, disco, round, warm, Jojo 4, deep sub), button 1 = the same 24 lines of
  round 2 in every column; row 3 = length again. Re-levelled with line 1: all −25 LUFS offline. Not heard.
- Feedback round 2 lines (user, heard in bass-2/3): Voyager „Zupfen“ all good; Instant Crush not so good; Disco syncope
  all good, especially „um die 1“, also „kurz“; Alright quite good; Beat 4 open good, especially the short version;
  Something About Us not so; Dead-note funk quite good.

## House Bass 4 — house-bass-4.strudel (2026-11-08 night)
- Columns and sounds as round 3. Button 1 = 18 lines: the liked ones (disco syncope 3, beat 4 open 3, Voyager 3, dead-note
  funk 3, Alright) + 5 new ones in their style (syncope around the 1 + dead notes, short + beat 4 open + pickup, plucking +
  syncope, Alright short, dead notes around the 1). Not heard.

## Low-End Width 1 — low-end-width.strudel (2026-11-11), for 008 (space plan)
- Question: may 008's low end be wide, or must it stay mono? Columns 1-3 = 008's kick (Punch 0.5), sub ("Pumpe") and
  bassline ("rollend", lpf floor 350 Hz as in the space plan), chords 1–6, no reverb. Per column: width, method
  (detune / Haas / auto-pan), amount, crossover (mono below 40–300 Hz). Column 8: mono check (all pans to the middle,
  copies kept) and bypass (all mono, reference).
- Node (transpile ok; offline render, 8 bars, below 120 Hz, mono sum vs. stereo; full width each):
  sub detune 12 ct −0.2 dB, 25 ct −0.5 dB (side/mid 0.13: little width, the short notes restart in step);
  sub Haas 10 ms −8.9 dB, worst beat −13.6 dB (side/mid 6.8: nearly cancels); sub auto-pan −1.3 dB;
  sub detune 25 ct with crossover 300 Hz 0 dB; bassline detune 12 ct −0.1 dB, with crossover 0 dB;
  kick Haas 10 ms −3.6 dB. Not heard. Feedback: open.
