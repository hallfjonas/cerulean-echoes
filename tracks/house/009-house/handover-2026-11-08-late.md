# Handover 009 (as of 2026-11-08, after midnight) — CONTINUE HERE

Language with the user: German, code comments English. Read first: `CLAUDE.md`, `stem-ideas.md` (rejected list),
this file, the previous handover `handover-2026-11-08-evening.md` (open harmony proposals A–C).

## User decisions (this session)
- Bass has priority; equally: how the 4 free columns Jonas 4–7 get filled.
- Column plan (proposed by me, user: "go ahead"): Jonas 4 high flute · 5 brass with build-up · 6 acid (user:
  "great in principle, not convinced here yet, there is groove techno too — try it out") · 7 vocal hook only with
  iconic samples, otherwise free. House piano with 4/8-bar progressions NOT as its own column, but through the keys.
- "Add the Kerri" = the riff from the Kerri video (Am9 Dm9 Gm9).
- "Pay attention to good modulations" (chord transitions): done in all new labs (see below).

## Newly built (all NOT listened to; checked in Node: notes per bar, transpile ok, ≤ 3.6 ms/tick with all columns)
1. `lab/bass/house-bass-1.strudel` (+ PDF) — 8 bass styles for Jojo 4, engine 3 (all 21 progressions): M1 organ, Juno,
   disco octaves, root rhythm, Daft Punk (FM), chord-tone themes (8 bars), Jojo 4 as in the track, deep sub ostinato.
   Approach notes into every change (A = semitone below, B = scale tone above, B A = enclosure), push 2/16.
   Level offline all −25 LUFS (= Jojo 4). Research + sources: `research-bass.md`.
2. `lab/keys/house-keys-lab-22.strudel` (+ PDF; lab 21 → old/, via mv) — 1 Am D, 2 Kerri video riff (own rhythm
   first on button 1), 3–8 piano progressions over 4/8 bars in the keys groove, voicings by hand with a top-voice line.
3. `lab/melody/melody-4.strudel` (+ PDF; melody-3 → old/) — brass phrases with a build-up fader (row 3, 4 steps),
   one column per instrument + trumpet↔sax; flute melody from real flute notes (from the juskiddink phrases via
   begin/end/speed, no new files). Level NOT measured (samples cannot be rendered offline here).
4. `lab/acid/acid-1.strudel` (+ PDF, new folder) — 303 lines (notes/accent/slide), row 3 = acid, 6 candidates,
   all −21 LUFS offline.
Feedback entries: `lab/{bass,keys,melody,acid}/feedback.md`.

## Open
- NOTHING committed/pushed: the device shell has no network (no push), and git needs delete rights (lock files).
  Including the files from the previous handover (harmony-5, keys-21, references.md …). Renames via `mv`, not `git mv`.
- Harmony proposals A–C from the previous handover: done in keys-22 (voicings by hand, C♯m7, "Mommy" parallel progression);
  harmony-5 / engine 3 itself unchanged (progression 13 there still D9) → harmony-6 only after OK.
- The Sarah Wild tracklist is now in `docs/references.md`.
- After listening: winners via `lab-to-track` into Jojo 4 / Jonas 4–6; vocal hook (Jonas 7) only with good samples.
- Tool note: `typst` is missing on the device; layout PDFs were generated in the cloud environment (gen-layout.mjs unchanged).
  `tools/render-offline.tmp.mjs` = render.mjs without network samples (synths only), for level measurements of boards:
  `BPM=124 node render-offline.tmp.mjs <board> "(S.val[5+i]=1, column(i))" '{}'`.

## Addendum (after 00:30) — second round
- Feedback entered (lab/{melody,acid,keys,bass}/feedback.md). Brass: too jazzy, happy house → open (needs fitting
  samples). Keys: the rhythm belongs to the chords; open question whether the keys get coupled to the harmony column by a knob.
- New: lab/bass/house-bass-4 (columns = 8 sounds, button 1 = the same 18 lines; bass 1–3 in old/), lab/keys/house-keys-lab-23
  (riffs with their own rhythm: Checkmate, Turn Off The Lights, Atmosphere, Chicago Spread, retro disco), lab/acid/acid-2 (tame).
- Track 009: flute (melody-4 column 6) as Jonas 4, level = vibraphone; single, syx, layouts, set 011 rebuilt.
- Tool: levels with samples can be measured in the cloud environment (npm ci in tools/, render.mjs + sample registration
  + querying in 0.05-cycle steps, otherwise stateful controls see nothing).
