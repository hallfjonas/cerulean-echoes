# 012 EDM Snippet — feedback

## Round 1: design

Draft: `012-edm-snippet-design.md` (2026-11-17). Waiting for the user's answers and approval.

Open questions:
- Where the parts go: all 7 on Mode 1 (A) or split foundation / colour like 007-010 (B)?
- Mode 2: four extras (Clap, Hats, Pad, Noise Pump) or empty for round 1?
- Chapter: Song → Rise → Drop, or Song ↔ Hold?
- Voices with two options: Kick, Sub Bass, Bass, Chords, Lead, Arp, Riser.
- Chords: guitar character (Strat samples, driven) or full EDM (supersaw)?
- Pattern variants per column (third option): fine, or other wishes?
- Pads: the 8 EDM shots (Clap, Snare, Open hat, Crash, Crash reverse, Drop hit, Zap, Sweep down) fine?

Approved 2026-11-17: user said "Looks good" to the design draft; its recommended picks apply (layout A, Mode 2 extras, Chapter Song → Rise → Drop, first voice option per part, pad shots as listed).

## Song start in a performance (decided: a)

The track plays song bar 1 on cycle 0 (Song chapter: bar = cycle mod 24 + 1). Auto-perform starts a script on the
player's current cycle (`startBarOf(engine.cycle())`), so a script started mid-play would begin anywhere in the song.

Recommendation: **(a) restart playback at cycle 0 when a performance starts.**
- It is one line in the player, not in `autoperform.mjs`: `startScript` (player.html) already re-evaluates the track
  through `play()`, so every button state and latch is new; only `engine.stop()` before it is missing. Strudel's
  scheduler restarts at cycle 0 after a stop, `startBarOf` then gives 0, and script bar 0 = song bar 1.
- The Node tools already work this way: `npm run scenario -- <track> --script <file>` runs a script from cycle 0, so
  the player and the offline check would agree.
- (b) a song offset set by auto-perform needs every song-form track to read it (song position, the 8-bar chapter
  grid, the LC view's bar), a contract between player and track that strudel.cc never sets, and more code in every
  track the converter (005) generates.

Effect on 007-010 scripts: they would also always start on cycle 0 instead of wherever the player happened to be.
That makes them repeatable: 008's 8-bar chord progressions and the 4-bar chapter phrases of 009 and 010 then fall on the
same script bars every run (today it depends on when Start is pressed). Audible change: a script started while a track
plays cuts the sound for a moment; every script begins with all controls at 0 (faders down), so its first bar is
silent anyway. No script file needs changing.

Decision 2026-11-17: the user chose (a). Done in `startScript` (player.html: `engine.stop()` before `play()`);
`autoperform.mjs` needed no change. Checked in the player: started at cycle 21.5 of a running 012, the clock went back
to 0 and `auto bar N` matched the cycle; 007-010 scripts pass `check-perform` and their scenarios.

## For the converter
- Song form is absolute: in the Song chapter song bar = cycle mod 24 + 1, so a performance works in script bars that
  are song bars. Section tables of a generated track should give both (song bar and script bar = song bar − 1 + 24 ×
  run) so the performance can be written without arithmetic.
- Chapters that loop a part of the song (Rise = bars 1-8, Drop = 9-16) plus Song at absolute position make returns
  predictable only on the song's own grid: leaving Drop for Song at script bar 72 lands on song bar 1 because 72 is a
  multiple of 24. A converter that picks section lengths should keep every section start on the chapter grid (8 bars
  here), and the song length a multiple of it, so every chapter return lands on a section start.
- Parts that play "drops only" on their first pattern (Clap, Hats, Noise Pump) also follow the chapter: in Rise they
  are silent, so a build that loops needs its own percussion (Tension's snare roll, Hats Complexity), not the drop
  extras.
- Tension's snare roll lives in the Clap stem: with the Clap fader at 0 Tension has no roll. Say so in the generated
  `@ctl` text, or put the roll on its own path, so a performance does not lose it.
- Event gains per stem differ by voice far more than by fader (Noise Pump at fader 0.4 is the loudest event, Arp at
  0.35 sits above Chords at 0.6): the converter should level stems so a fader at the same value sounds about equally
  loud, measured with `npm run audibility`, before a performance is written.
- Stop bars (8, 16, 24) are a natural place for one-shots (Sweep down) and fills: the generated layout could name them
  in the section table so the performance knows where the gaps are.
