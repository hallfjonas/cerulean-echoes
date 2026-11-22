---
name: auto-perform
description: Design, script and review an auto-performance (a script that plays a live track in the player without hardware) for a live track (SuperCollider, `sc/tracks/`). Use for 'auto-performance', 'perform script', 'new performance', 'performance for 008', 'make the track play itself', 'autoperform design'.
---

# Auto-performance: design, script, review

An auto-performance is a JSON script (`tools/trajectory/perform/<track>/<name>.json`) that the player sends to
SuperCollider, in bars (`sc-auto.mjs`: LC CCs as `/ce/cc`, Launchkey CCs, keys and pads as `/ce/lkcc` / `/ce/lknote`;
bar 0 goes with the load; the bar clock is SC's). A frozen Strudel copy (`<id> (Strudel)`) plays the same scripts
through the virtual `LCXL3 Auto` and `Launchkey MK4 25 Auto`. It does not listen to the sound. The agent
cannot hear either: the user listens in the player and the user's words decide. Two loops, each with an explicit gate:

1. **Loop 1, design**: you propose, the user corrects, the user says approved. No script before that.
2. **Loop 2, sound**: you script and check, the user listens in the player and gives feedback by section and bar, until
   the user says approved.

Everything is logged in `perform/<track>/feedback.md`. Formats and the design skeleton are in
`tools/trajectory/perform/design-template.md`; the script format (meta, sections, steps, Launchkey steps, limits) is in
`tools/trajectory/README.md` section "Auto-perform". Do not copy them here, read them.

## 1. Prepare (read, do not guess)
1. The track file: `ls sc/tracks/*/*.scd`, then `cd tools && npm run track-map -- <track.scd>` and `sed -n` ranges
   (if the tools cannot run: `grep -n '@ctl\|@col\|@mode\|@lk\|bpm' <track file>`). Controls are named by their
   `@ctl` names, stems by the `@col` tags (a stem track `<id>.track`: from its stems and frame,
   `node stems/stem-tags.mjs`). BPM is the `bpm` variable; it gives the minutes (1 bar = 240 / BPM seconds).
2. CC numbers: `CLAUDE.md` "Controller mapping" (Mode 1 fader CC 5-11, knob rows 13-19 / 21-27 / 29-35, buttons
   37-43 / 45-51; Mode 2 = CC + 48). Column 8 is global in every track: Master fader 12 (Mode 2 copy 60), Fog 20, Thin
   28, Tension 36, Chapter 44, Break 52. Launchkey: keys, mod wheel CC 1, knobs CC 21-28 (the `@lk` tags name them),
   pads 36-51; which sound each pad plays is in the track code (`shots` in `lkNote`, names in `lkPadNames`), not in
   the tags. The `@ctl` tags win
   over a header comment that says a column is empty.
3. `docs/reference/genres.md` (what the genre is, per stem for groove techno) and `docs/reference/listening-list.md` for the genre, the track folder's `feedback.md`, existing scripts in `perform/<track>/` (an
   existing script, like 010's spike, is the best starting point: describe it in sections instead of starting over).
4. Finished examples to match in style: `perform/010-ambient-house/journey.md` + `journey.json` + `feedback.md`.
5. What a track needs from the script, read from its code: knobs read 0 until set (Launchkey Brightness, Length), keys
   sound only while the mod wheel is above 0, `Chapter` switches at the next phrase (see the track's latch) and pattern
   buttons at the next bar (press one bar early to land on the line). Knobs act at once on sounding notes; faders from
   the next note.

## 2. Loop 1: the design
Copy the template to `perform/<track>/<name>.md` and fill it: meta (title, bars = minutes at the real BPM, mood,
two-line story, references), section table (name, 1-based bars, controls by `@ctl` name, Launchkey use, intent), risks
(CPU peak, clipping, silent stretches), open questions. Give a length with a reason and say the minutes; align section lengths to the phrase lines (Chapter switches every
4 bars, a harmony button every 8). If the folder already has a design, pick another file name. Show the user the file path and a five-line summary (length, mood, sections, Launchkey use, open questions). Several
tracks can be designed in parallel (one agent each); the user reviews them in any order or all at once. The user may
answer in the chat or in a `<name>-feedback.md` file next to the design: read it, merge it into `feedback.md`, delete
the loose file.

Log each round in `feedback.md` (`## Loop 1 / Round N`: the user's words, what changed, decision). Approval is the
user's own word ("approved", "sounds good"); quote it. Answers that leave open questions unanswered resolve them to
the defaults in the design: say so in the log.

## 3. Loop 2: script, check, listen
1. Write `<name>.json` from the approved design: title, `bars`, `mood`, `sections` (0-based `[from, to)`, the design
   table is 1-based, convert once: a table row "Drop 49-56" is `from` 48, `to` 56; a Chapter press meant to land on bar 49 is written at
   bar 47 or 48 because it switches at the next phrase), steps with real CCs. Every step starts inside a section. Ramps for fades and
   builds; the first step of a section on its own bar; levels where the design says (stems around 0.4-0.7 keep the mix
   clear). No keys or pads at bar 0. Set the mod wheel and the Launchkey Brightness / Length knobs before the first keys.
   Pads are one-shots: a few gestures on the beat grid (snare roll into a drop, crash reverse in the last bars before
   it, open hat on off-beats), never scattered single hits.
2. Checks: `cd tools && node trajectory/check-perform.mjs <track file>` (every step a control of the track, bars,
   values) and `npm run verify-sc -- <track.scd>` (also loads and plays the track headless in sclang: a heavy step, one
   at a time on the 16 GB machine; several agents: take a lock directory around it). A new worktree has no
   `tools/node_modules`: symlink one from another worktree.
3. Honest limits: no check renders the script or measures levels, clipping or CPU; never claim them. The listen in the
   player is the only proof.
4. Start the player from the working tree on its own ports (`/player`, or `cd tools && CE_SC_PORT=<osc>
   CE_SC_SERVER_PORT=<server> node trajectory/server.mjs 8767`; the user's player runs on 8766 / 57131 / 57140), open
   `http://localhost:8767/` in the user's Chrome. Tell the user: pick the track, press P, choose the script, Start;
   reload the page after every edit. Your own trial runs without the user: `CE_SC_MUTE=1` (nothing on the speakers).
5. Feedback comes by section and bar. Map each comment to bars yourself and state the mapping. Change only steps (and
   the matching design rows), re-run the checks, log `## Loop 2 / Round N`, decision again, until the user approves.
   The user's praise marks what must not change.

## 4. Done
Both approval lines in `feedback.md`, a Lessons section at the end, the task's boxes ticked, `check-perform` and
`verify-sc` green, a PR. A performance is only proven by a listen in the player.

## Lessons from 007-010
- The length in minutes goes into the design; one stopwatch check against the top bar settles any doubt.
- Ambient with a recording (007, David's voice, `sc/samples/voice/david.flac`, not in git): the recording is clock-locked (time in
  it = bar x seconds per bar), the Voice fader only reveals it. Size the piece to the recording, bring the music in
  already under the voice, keep a bed under it at the end. There is no transcript or speech-to-text: to cue a sound to a
  word, ask the user for the recording time.
- Techno (008): a bare kick intro reads as lame, bring rhythm layers in quickly with Brightness ramps. A Braaam pad is
  strongest quiet just before a drop; change Chapter sparingly, a big mood change after a drop was too much; end with a
  long, gradual strip (12-16 bar ramps) and a slow master fade, starting early.
- House (009, first Launchkey script): keys sound dull until Brightness is set and chord notes only ring as long as the
  Length knob says; drum pads belong on the beat grid in fills, voice pads sparse in the breaks.
- Ambient house (010, pilot): starting from an existing script made the design one round.
- The real controllers play along with the script (the control moved last wins; faders use pickup on SC); the
  user's keys need the mod wheel up.
- Timing: trust a listen in the player; the bar follows SC's beat (`engine-sc.mjs`).
- Section names are one or two words, English; the user's praise or complaint refers to sections, so name them well.
