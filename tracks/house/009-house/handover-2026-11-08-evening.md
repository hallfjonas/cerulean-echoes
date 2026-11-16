# Handover 009 (as of 2026-11-08, late evening) — CONTINUE HERE

Language with the user: German, code comments English. Read first: `CLAUDE.md`, `stem-ideas.md` (list
"✗ Rejected"), `feedback.md` (009, newest entries at the bottom), `lab/keys/feedback.md`, `lab/melody/feedback.md`,
`lab/harmony/feedback.md`, `lab/stab/feedback.md`. Previous handover: `handover-night-2026-11-08.md`.

## What this session did
- Track 009: vibraphone "call echo" F♯ → F in minor progressions (pushed, bbe18e2 / 9631f63).
- `lab/melody/melody-3.strudel` + `samples/horn-phrases/` (20 real trumpet/sax/flute phrases, CC BY 4.0) +
  `tools/phrase-cut/` (pushed).
- `lab/stab/stab-1.strudel` levels matched (pushed).
- NOT committed (please commit + push, branch `johannes`):
  - `lab/harmony/harmony-5.strudel` (+ PDF): harmony-4 + progressions 17–21 (C F Whistle Song, F Em Am G Digital Love,
    Am G/F F Dm Modjo, F C G Am Another Chance, Em Am Keep Me Inside); harmony-4 to `old/` (git mv).
    New chords/progressions appended to `tools/stem-lab/engine3.strudel-part` (CH: G7/F, G7sus2, Am/C; HARMONIES 17–21).
    Other engine-3 boards were NOT re-synced (they do not need it).
  - `lab/keys/house-keys-lab-21.strudel` (+ PDF): 8 columns = 1-bar chord riffs with the keys groove (RIFFS +
    PEDAL, the bass follows the riff of the leftmost open column); lab-20 to `old/` (git mv).
  - `docs/references.md`: Sarah Wild set as the main reference; feedback entries in the feedback.md files.

## User feedback this round (all already entered in the feedback.md files, except the last two points)
- Stabs: ALL nonsense (rejected, in stem-ideas.md). If at all: more iconic vocal samples.
- Brass (melody-3): trumpet/sax sound good, but too sparse, too long pauses = stabs instead of melodies; something
  has to build up. Proposal (not built yet): melody-4 with a build-up fader (row 3: 1 phrase/8 bars →
  call + answer → phrases right after each other; at the top also livelier phrases; merge columns per instrument).
- Chord progressions: classic house, NOT progressive house (vi IV V I …).
- Main reference: Sarah Wild, Fusion 2025 (SoundCloud link in docs/references.md). Tracklist (1001tracklists, pasted by
  the user; the site blocks bots — do not circumvent): Pink Floyd – Is There Anybody Out There · Sarah Wild – Fly With
  Me To The Moon · Maltitz – Yepiyano · Hot Since 82 & Tomaz vs. Filterheadz – Sunshine 2025 · Krystal Klear – Deathlagg ·
  Freddie Mercury – Living On My Own · Baron Von Trax – If I Only Knew · Arpeggio – The Fighter · Austher – Expectations ·
  Borai & Denham Audio – Make Me (Paul Sirrell Remix) · L.P. Rhythm ft. Gaskin – In The House · Val Verra – House Music
  Is A Spiritual Thing · Krystal Klear – Detol Samba · Sarah Wild – Disco Extase · Harry Nipples & jo.desaga – Dance Now
  (Piano House Original) · Laroze – Pure Water · Sarah Wild – Drum Extase · Austher – Memory Code · Herr Krank & Deborah
  Aime La Bagarre – Eurogenic · Miguel De Bois – Is Everything Cool? · Demi Riquísimo & Clint – Love State · JOVE – Don't
  Let Me Go · Doctr ft. Daniella – Training (French Version) · Narciss & Gerd Janson – Chicco's Chips. Genre: House, Tech House.
  → add to docs/references.md.
- What the user hears in the set and wants for 009:
  1. Lots of house piano: not only monotonous, also 8-bar progressions, but always with a groovy rhythm.
  2. House basslines with lots of groove (Jojo column 4) — "needs work, more options and better ones".
  3. A higher, playful melody towards flute, less complex than the vibraphone (the vibraphone stays).
  Acid: great, but not a must.
- **Keys-21 (latest answer):** of the riffs only "Am D" (column 6: Am9 3/8 + D9 5/8 in one bar) is okay. User:
  "please add the Kerri there again, you know what I mean?" → UNCLEAR, ask. Guesses: (a) Am D with the
  Kerri riff rhythm `x..x..x..x..x.x.` or the Kerri push; (b) the Kerri video riff (Am Dm Gm) with Am/D chords only.
  Also: "and please do say, the ones over 4 or 8 bars" → probably: riffs/piano running over 4 or 8 bars
  (fits point 1: 8-bar progressions with groove). Also get this confirmed briefly.

## Harmony check (user question "did you pay attention to good modulation?", 2026-11-08) — NOTHING changed, answer open
Analysis of the 21 progressions in `harmony-5.strudel` / engine 3 (script: voices = `stabOf(CH[name], 52, 4)` per change):
- Good: voice leading is tight — shared notes stay, jumps mostly 1–2, max. 4 semitones. Changes between the progressions
  at the 8-bar start (with push) stay in A minor/C major, only Dorian↔aeolian (F♯/F) — soft, no real modulation.
- Problem 1: the Kerri voicings written in `CH` (seventh at the bottom, without root) do NOT sound — `stabOf` re-sorts from
  E3: almost always E3 at the bottom, Em7 in root position, Fmaj7 = E3 F3 A3 C4 (minor second at 165 Hz = muddy, especially with
  supersaws); Fadd9 / G11 / G7sus2 tight clusters around F3/G3.
- Problem 2: top voice almost always C4/D4 — no line on top (Attack: "highest and lowest notes … give context and melody").
- Problem 3: progression 13 "Attack example": bar 8 must be C♯m7 (surprise chord, as in research-harmony.md R4),
  the board has D9. Modjo "Lady": Bm7♭5/D is missing.
- Research (Attack Magazine: kerri-chandler-chords, …-part2, parallel-chords, passing-notes-deep-house-chords,
  lessons-from-disco-chords/2; Soundfly open-voiced sevenths; NI voice-leading): KC stabs without root/fifth, seventh
  at the bottom, hold shared notes + add on top, back 1/16 early; borrowed passing chord (A7 between A♯m and G♯m,
  "Rain" ii–V chains); parallel chords = same voicing shifted (Mommy What's a Record Cm7 → Gm7 → Am7) = softest
  key change; pedal-point bass underneath; two-chord vamps carry a lot of classic house.
- Proposals to the user (await answer): A) play voicings as written, inversion per change by shortest
  paths, no seconds below G3 (changes ALL progressions → only with OK); B) progression 13 to C♯m7; C) append new progressions:
  "Mommy" (Am7 → Em7 → F♯m7 parallel over an E pedal point) + one progression with a passing chord.

## Next steps (proposal, agree with the user)
1. Ask briefly: what "add the Kerri" means; whether 4/8-bar piano progressions are meant.
2. **Bass (priority according to the user):** research first (note sources in a `research-bass.md`): how classic
   house/piano-house basslines are built (syncopation, octave jumps, ghost notes, slides, sounds: M1/Juno/organ bass,
   sub + mids), ideally from tracks in the tracklist (descriptions, analyses). Check what exists: `lab/bass/`
   (folder + feedback.md) and Jojo 4 in `009-house-dual.strudel` (3 lines, sine + octave + square, ghost improviser).
   Then a bass lab with many candidate columns (engine 3, follows the chord progressions; context: drums, keys).
3. Keys-22: "Am D" as the basis + Kerri variant(s) + piano with 4/8-bar progressions in the keys groove (the 8 rhythms on button 1).
   Idea: the keys column in the track gets the riffs through the free button in sound mode (round 20 open) instead of its own column.
4. melody-4 (brass with build-up) and a flute melody column (playful, simple motifs, higher).
5. Column plan Jonas 4–7 (draft): piano/progression · high flute · brass · open (vocal hook only with good samples).

## Working rules (short version)
Do not rework labs unasked; respect the rejected list; research with sources; before the handover
`node tools/strudel-sim/transpile-check.mjs`, compute time ≲ 8 ms/tick, decode samples in headless Chrome
(`tools/phrase-cut/chrome-decode.mjs`); lab rounds: new file, old one to `old/`; track changes: make-single,
gen-layout, make-syx, `npm run set`. M2 Air shared: one heavy job, no background processes.
