# Prompt for the next agent (track 009, as of 2026-11-08)

Copy the block below as the first task into the new session.

---

You are working in the repo `cerulean-echoes` (Strudel live tracks for two Novation Launch Control XL 3). Speak German with
me, code comments stay English. First read `CLAUDE.md`, then for track 009:
`tracks/009-house/stem-ideas.md` (at the top the list "✗ Rejected" – build none of it back in),
`tracks/009-house/feedback.md`, `tracks/009-house/handover-harmony-in-009.md` (what was built last) and the
`feedback.md` in `lab/harmony/`, `lab/melody/`, `lab/stab/`.

**Goal of the project:** a low-threshold MIDI mapping with which people without prior knowledge play together at a
meetup; everything has to sound good easily. Track 009 = classic house (124 BPM, A minor). Jojo = rhythm
(8 columns), Jonas = colour (columns 1–7) + global column 8.

**Status Jonas (track 009):**
- Column 1 harmony (JX-10 ↔ B3, held chords) with 10 chord progressions on button 1; Chapter (column 8) vamp = Am9,
  change = chosen progression. The keys deliberately stay monotonous on Am9 (only in "Am9 D9" D9). User: "the three
  harmony things are great" (harmony column, chord progressions, monotonous keys).
- Column 2 keys, column 3 vibraphone (from `lab/melody/melody-2`), columns 4–7 empty.

**I am away tonight and cannot listen to anything.** Work on your own on what is possible without my ears, and
present the results to me tomorrow morning (short, in German: what is built, what I should listen to, what is open).
No questions needed; where you have to decide, take the obvious option and write the decision down.
Change track 009 only for point 1; prepare everything else as a lab board, take nothing unheard into tracks.

**Tonight (in this order):**
1. **Vibraphone phrase "call echo"** (track 009, Jonas 3) contains F♯; in the aeolian progressions (all except "Am9 D9")
   that clashes. F♯ → F when `modeAt(bar) === 'aeolian'` (otherwise unchanged). Then the usual track steps
   (see working rules) incl. `npm run set`.
2. **Second melody column (Jonas 4): prepare real brass phrases as a lab.** Trumpets from
   single-note multisamples are rejected (not warm, mechanical); in the first sample lab fast, restless
   jazz phrases and 1-bar loops were bad. Plan: cut longer real recordings (e.g. Freesound 424876 / 424894
   emirdemirel "Improvisation on Dorian" trumpet / sax, CC BY; 77706–77717 sorohanro trumpet phrases, CC BY; others
   only with source and free licence) into phrases at pauses, keep only calm ones by analysis (pitch, notes per
   second) (few, long notes), transpose to A (Dorian/aeolian), note the credits. Lab
   `lab/melody/melody-3.strudel` (engine 3): one instrument/source per column, button 1 = next phrase,
   entry on phrase points (every 4 or 8 bars), row 3 = how often; leave the vibraphone from melody-2 in as a comparison.
   Sources/hints: `tracks/009-house/research-melodies.md`. Rather 10–20 good candidates than many
   mediocre ones; load/decode all in headless Chromium.
3. **Check the stab lab:** `lab/stab/stab-1.strudel` is built but never listened to. Only check it technically
   (transpiler, compute time, samples load in Chromium, roughly match levels) and note anything notable; rework
   nothing in content.
4. **Morning overview** at the top of `tracks/009-house/stem-ideas.md` ("▶ For tomorrow morning") and in the handover md:
   what is ready to listen to, with file paths, what I should pay attention to, what could not be checked.
5. Finally commit and push to branch `johannes` (commit message as usual in the repo).

**Afterwards, to be agreed with me (not today):** listen to the harmony in the browser and fine-tune (only tested in Node:
level against keys, chord changes, compute time); take winners from melody-3 and stab-1 with the skill `lab-to-track` into
Jonas 4–6; Launchkey pads later (collection in `samples/pads/`).

**Working rules (important, were often broken):**
- Before every build read the rejected list and the feedback.md; take rejected things out immediately, per round rather more
  options/complexity than small steps.
- Research with sources, invent nothing; name what is undocumented as such.
- Lab boards: `lab/<role>/<role>-N.strudel`, old rounds in `old/`; engine 3 via `node tools/stem-lab/sync.mjs`
  (runs the transpiler check automatically).
- Before every handover: `node tools/strudel-sim/transpile-check.mjs <files>` (catches e.g. double quotes,
  which Strudel reads as mini-notation), measure compute time per scheduler tick in Node (≲ 8 ms), load/decode new samples in
  headless Chromium (Playwright Chromium under `~/Library/Caches/ms-playwright`).
- Track changes: `make-single.mjs`, `gen-layout.mjs` (check the layout PNG for text overflow), `make-syx.mjs`, then
  `npm run set` in `tools/` (set 011 is built from the tracks; check-set shows known start deviations for 009,
  see feedback.md).
- Button 1 under the fader = switch (pattern or chord progression), button 2 = moment; labels without theory terms.
- Document the plan and status continuously in a handover md in the track folder (if you run out of compute time,
  another agent must be able to continue there).
- Machine: M2 Air, shared; only one heavy job at a time, leave no background processes behind.
