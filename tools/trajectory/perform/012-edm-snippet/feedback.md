# 012 EDM Snippet performance - feedback

## Loop 1 / Round 1 - rise-and-drop.md (2026-11-17)
- User: (no answer yet)
- Changed: first draft after the arc sketch in `tracks/edm/012-edm-snippet/012-edm-snippet-design.md`: 120 bars =
  4 min, five runs of the 24-bar song (Sketch, Riff, Build, Drop 1, Drop 2, Rise, Drop, Breakdown, Peak, Outro). The
  script was written in the same step, so the first listen can answer the design and the sound together.
- Open questions: length (Drop chapter 8 or 16 bars), Rise twice or once, Breakdown back to song bar 1 or straight into
  Drop 1, Rhodes keys in Peak only or also in the Drop.
- Decision: open, waiting for the user

## Loop 2 / Round 1 - rise-and-drop.json (2026-11-17)
- How to listen: player, pick 012-edm-snippet, P, choose `rise-and-drop`, Start. Start now restarts the song at bar 1
  even while the track plays (top bar: `auto bar N / 120 · <section> · n bars left`).
- Listen for:
  - Sketch / Riff (bars 1-24): chords and lead alone carry the song; is the Arp teaser at bar 17 too loud next to them
    (its event gain is about 4-7 dB above Chords and Lead)?
  - Build (25-32): kick, sub bass and riser arrive together on song bar 5 (bar 29); Bass, Clap and Hats on the drop at
    33.
  - Drop 2 (41-48): Arp brightens; the Sweep down pad on the stop bar 48 leads into the Rise.
  - Rise (49-64): two rounds of song bars 1-8, Tension up to the top, snare roll from about bar 61; bars 63-64 without
    low end, Crash reverse into the drop. Does the double build hold, or is it too long?
  - Drop (65-72): Drop hit + Crash on the one, Tension snaps back to 0, Noise Pump in (its event gain is the loudest of
    all stems; too much?).
  - Breakdown (73-80): back to song bar 1 under Fog, snare 16ths in the second half of 80.
  - Peak (81-96): Rhodes stabs, one per bar, then 3-3-2 stabs from 89; snare fill at the end of 88. CPU: both supersaw
    layers plus keys play here; listen for dropouts.
  - Outro (97-120): stems leave one by one, Master fades from 109 to 0 at the last stop bar.
- Checked: `check-perform` ok; scenario per section: every section audible, 3-10 stems, no SILENT; Break takes kick and
  sub out in bars 63-64 and brings them back on 65; Chapter is Rise on 49, Drop on 65, Song (bar 1) on 73. Not
  checked: clipping and CPU (the scenario counts event gains, not rendered audio).
- Decision: open, waiting for the user's listen

## Approved

2026-11-17: user said "Approved" after listening (gate 2): performance design and script rise-and-drop, as written; open design questions stay as drafted.
