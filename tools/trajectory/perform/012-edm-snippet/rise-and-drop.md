# Rise and Drop

Design for `perform/012-edm-snippet/rise-and-drop.json`. Starting point: the arc sketch in
`tracks/edm/012-edm-snippet/012-edm-snippet-design.md` ("How the 24-bar loop builds over repeats").
Status: proposal, waiting for the user's approval (Loop 1 / Round 1). The script was written alongside it, so the
first listen can answer both.

## Meta
- Track: 012-edm-snippet
- Length: 120 bars = 4 min 0 s at 120 BPM (5 runs of the 24-bar song; 1 bar = 2 s)
- Mood: bright, driving, festival EDM in G♯ minor, one big drop
- Story: The song starts as a guitar sketch (chords and lead riff only). On the second run the beat, bass and
  percussion come in for its drops; then Chapter holds the build for two rounds while Tension rises into one hard drop.
  A breakdown back to bar 1 leads into a full peak with Launchkey stabs, and the last run strips it down to a fade.
- References: none for EDM in `docs/references.md` yet; listen for the classic big-room arc (build with snare roll,
  low end pulled out for two bars, drop on the one)

Script bar = 1-based bar − 1. Song bar 1 = script bar 0, 24, 48 (Song chapter: song bar = script bar mod 24 + 1).
Chapter switches at the next 8-bar line, Break at the next bar: presses are written a few bars (Chapter) or half a
bar (Break) early.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Sketch | 1-8 | Master 0.9; Chords Level 0 -> 0.6 ramp 4, Space 0.25; Lead Level 0 -> 0.5 ramp 2 at 5, Space 0.3 | - | Song bars 1-8: guitar sketch, no beat |
| Riff | 9-24 | Arp Level 0 -> 0.35 ramp 4 at 17 | - | Song drops on chords and lead only; arp teases in |
| Build | 25-32 | at 28 (song bar 4): Kick 0.6, Sub Bass 0.55, Riser 0.5 + Noise 0.5, Arp 0.5; at 32: Bass 0.6, Clap 0.55, Hats 0.5 | - | Second run: the build arrives with beat, sub and riser |
| Drop 1 | 33-40 | (levels from Build) | - | First real drop: kick, bass, clap, hats |
| Drop 2 | 41-48 | Arp Brightness 0 -> 0.6 ramp 8; Hats Complexity 0.4; Chapter press at 47 (-> Rise at 49) | pad Sweep down at 48 | Brighter, then into the held build |
| Rise | 49-64 | Pad Level 0 -> 0.45 ramp 4, Space 0.5; Tension 0 -> 1 ramp 16; Riser Noise 0.8 at 57; Chapter press at 63 (-> Drop at 65); Break press at 62.5 and 64.5 | pad Crash reverse at 63.5 | Song bars 1-8 twice; snare roll grows from 61; bars 63-64 low end out |
| Drop | 65-72 | Tension 0; Noise Pump 0.4 (set at 64); Chapter press at 71 (-> Song at 73) | pads Drop hit + Crash at 65 | Hard drop on the one, Drop chapter (song bars 9-16) |
| Breakdown | 73-80 | Fog 0 -> 0.5 ramp 4, back to 0 ramp 4 at 77 | knobs set (Brightness 0.5, Rhodes 0.667, Length 0.1, Space 0.3); mod wheel 0.5 at 80; snare 16ths in the second half of 80, Crash at 81 | Song bar 1 again: no beat, muffled, then the build |
| Peak | 81-96 | Hats Complexity 0.6; Clap Complexity 0.3 at 89 | keys: Rhodes G♯m / F♯ one stab per bar in 81-87, 3-3-2 stabs in 89-95; snare fill at the end of 88; Sweep down at 96 | Full song, keys on top |
| Outro | 97-120 | mod wheel 0; out one by one: Riser, Pump, Hats (97), Clap, Arp (105), Kick, Bass, Sub (109); Fog 0 -> 0.6 ramp 12 and Master 0.9 -> 0 ramp 12 at 109 | - | Last run: chords, lead and pad fade into the final stop bar |

## Risks
- CPU peak: Peak (81-96): every stem of both pages plus Rhodes keys (two supersaw layers: Chords and Pad). Check in the
  player on the M2 Air.
- Clipping: Rise bars 61-64 (Tension near 1 opens every filter and adds echo and the snare roll) and the drop at 65
  (Drop hit pad on top of the full mix). The scenario table shows event gains only.
- Silent stretches: none. Song stop bars (8, 16, 24 of each run) are one hit then silence by design; bars 63-64 have no
  low end on purpose.

## Open questions
- Length: 4 minutes. Longer by holding the Drop chapter for 16 bars instead of 8?
- Rise twice (16 bars) before the drop: right, or once is enough?
- Breakdown goes back to song bar 1 (no beat) after the drop. Or straight into the full song's Drop 1 instead?
- Keys: Rhodes stabs in Peak only. Also in the Drop?
- Section names are working titles.
