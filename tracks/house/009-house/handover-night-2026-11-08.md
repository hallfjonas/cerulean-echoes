# Handover: night shift 2026-11-08 (user was away, nothing listened to)

Task: `prompt-next-agent.md` (points 1–5). Language with the user German, code comments English.

## Status
1. ☑ **Vibraphone "call echo" (009, Jonas 3): F♯ → F in the aeolian progressions.** `vibModeFix` in
   `009-house-dual.strudel` (before `vibPhrases`): F♯ notes of the phrase become F when `modeAt(bar) === 'aeolian'`.
   Checked in Node: vamp and "Am9 D9" → g f♯ e d …, progressions 3 and 6 → g f e d …. Single, layout (unchanged, no
   @ctl change), .syx regenerated; `npm run set` built. check-set: for 009 exactly the same deviations as before the
   change (compared by temporarily reverting): "all 0.5/1" only events at t = 0; "ride A/B" deviations in
   bars 0–1 (not only in the very first moment, as feedback.md says, but unchanged from before).
2. ☑ **`lab/melody/melody-3.strudel`** (engine 3) — real brass phrases. Column 1 vibraphone (melody-2, unchanged),
   2 trumpet A, 3 trumpet B, 4 trumpet C, 5 tenor sax, 6 flute. 20 phrases in `samples/horn-phrases/` (table,
   sources, credits: README there). Method: long Freesound improvisations (emirdemirel series, trumpet Hikmet
   Altunbaşlıer, sax Toprak Barut; flute juskiddink 65509; all CC BY 4.0) → pitch (YIN), cut at pauses or at the end
   of long notes, only calm ones kept (≤ 3.2 notes/s, one note ≥ 0.5 s, no scale runs, no notes
   outside A Dorian/aeolian), varispeed to A (−3 … +2 semitones), matched to −20 dBFS. Scripts:
   `tools/phrase-cut/`. Cross-check: all 20 files are in A (analysis of the finished files).
   Playing: entry on the 1 every 16 / 8 / 4 bars (row 3, start 8), the phrase plays to the end, button 1 =
   next phrase (always the same phrase repeated), button 2 echo throw. Phrases with F♯ only play in progressions with F♯,
   with F only in the minor progressions; otherwise the next fitting one of the column.
   Checked: transpiler ok; Node: entries, "How often" and the F♯/F swap correct; compute time 3.2 ms/tick (p95
   5.4 ms); level offline: each phrase ≈ −23.5 LUFS at fader 1 (±1 dB) = about the vibraphone in the track; Chromium: files
   decode (locally; after the push from GitHub, see below). Layout PDF without overflow.
3. ☑ **`lab/stab/stab-1.strudel` checked technically:** transpiler ok; compute time 3.0 ms/tick (p95 4.6 ms); all 26
   samples (Freesound, VCSL, VSCO) load and decode in headless Chrome. **Notable: far too loud** — at fader 1
   −13.7 … −19.3 LUFS (kick in 009 ≈ −14), cheer / trombone / cuíca with peaks > 1 (clipping). Matched
   via column gain (`GAIN` in makeCols) to ≈ −19 LUFS, peaks ≤ 0.9; cheer stays at −22 (very peaky signal).
   Content otherwise unchanged.
4. ☑ Morning overview in `stem-ideas.md` (top) and here.
5. ☑ Commit + push to `johannes` (bbe18e2); all 20 phrases load and decode from raw.githubusercontent.com in headless Chrome.

## Decisions (without asking, obvious)
- Flute added as 6th column: real, calm recording, already in A minor; the VCSL flute (multisample) had been rejected, the
  flute trills (real) were liked → as a comparison.
- Sax: of 6 sax recordings in the series only 3 passages passed the calm filter (the player plays densely) → only 3.
- Source previews (128 kb/s MP3) instead of originals (login required). Quiet recordings were raised by up to +14 dB →
  possibly audible noise (tpm-424905-0737/-0838, tpx-430268-0470).
- Phrase labels = the first notes (like the chord progressions: "the chords themselves").
- Brass level = vibraphone in the track (there +40 % over the lab), so in the lab a bit louder than column 1.

## Not checkable without ears
- Do the phrases sound warm/alive or like a "practice recording"? Do they fit rhythmically, although they are played
  freely (without a bar grid)? Does the varispeed transposition (up to −3 semitones = 19 % slower) sound natural?
- Pitch analysis can have octave errors on trumpet (melody column in the README); the key tags F♯/F are
  set cautiously.
