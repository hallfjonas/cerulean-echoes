# Warehouse

Design for `perform/008-groove-techno/warehouse.json`. Status: design approved (Loop 1 / Round 2); Loop 2 changes
applied through round 3 (see `feedback.md`). The rows below match the script. A second performance for 008 beside the
approved `techno-night`.

## Meta
- Track: 008-groove-techno
- Length: 208 bars = 5 min 57 s at 140 BPM (1 bar = 4 beats = 1.714 s; 208 x 240 / 140 = 357 s)
- Mood: dark from the first bar, curious, then driving and hypnotic
- Story: No kick at the start: a curious melody (Answer, Pads) and Dark perc in a dark chapter. Fast hats arrive
  quickly, then a rumble, bass and sequence. A short build releases into a drop that brings in the full beat at once.
  The groove runs a good while, the bass brightness sweeping slowly, with a one-bar bass break that returns straight
  into a one-bar double time. A drift lets the energy sink with the beat alive and the kick out for the last bar, then
  the peak drops in with everything at once. A second drift, the same shape with a warm twist, fades the beat last.
  No drum pads and no keys.
- References: Yanamaste live set at KHIDI Tbilisi (layering over a slot), Marie Montexier at Nation of Gondwana 2025
  (hypnotic loop, slow filter moves). The references file has no notes for these; the "listen for" is not heard.
- Basis: `@ctl` / `@col` tags of the track. Mode 1 (Jojo): Kick 1, Rumble 2, Sub 3, Bassline 4, Clap 5, Hats 6,
  Percussion 7, fader CC 5-11, knob rows 13-19 / 21-27 / 29-35, buttons 37-43 / 45-51. Mode 2 (Jonas), CC + 48: Pads,
  Strings, Sequence, Stab, Answer, Dark perc, FX. Column 8: Wumms fader 12, Fog 20, Thin 28, Tension 36, Chapter 44,
  Break 52. Chapter cycles Dark, tense, warm: it starts on Dark and is not pressed until the twist in the last drift.
  Strings stay out. A press lands at the next bar line, so "press at 63" sounds at bar 64. A Break pair (press at N-1
  and N) takes the low end out for exactly bar N, and everything is back on the one at bar N+1.
- The drift: one shape, used twice (Drift 1 and Drift 2), start bar S, 24 bars, the beat plays: Stab and Sequence out
  over 8 from S; Thin 0 -> 0.4 and Fog 0 -> 0.3 over 16 from S; Pads 0.5 -> 0.35 and Dark perc 0.3 -> 0.2 over 16 from
  S; Bassline and Rumble out over 12 from S+4; Wumms 0.95 -> 0.5 over 16 from S; Sub out over 8 from S+8; Kick, Clap,
  Percussion, Hats and Answer stay. Drift 2 alone adds the warm Chapter twist (two presses at S+10 and S+11), Answer
  Space up at S+14 and, from S+16, Kick, Clap, Percussion and Hats fading together over the last 8 bars. Drift 1 leaves
  those three out (they belong to the end) and ends with a one-bar kick Drop out.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Curious | 1-24 | Pads Level at 1, Answer Level at 4 (Answer Pattern press at 13), Dark perc Level at 7; Fog 0.5 -> 0 over 18 | - | A dark, curious melody over a ticking percussion, no kick |
| Hats | 25-48 | Hats Level at 25, Hats Pattern pressed twice (driving) and Complexity up over 18; Rumble Level 0 -> 0.5 over 12 from 31; Bassline Level at 37 and Sequence Level at 43, ramps of 6 | - | Fast hats first, then rumble, bass and sequence quickly, still no kick |
| Build | 49-64 | Tension 0 -> 0.9 over 15; Thin 0 -> 0.5 over 12; Riser hold in the last 2 bars | - | Short build into the drop |
| Drop | 65-128 | Tension and Thin to 0 at 65 (one bar after the ramp end); Kick, Clap, Sub, Percussion Level all up at 65 (the full beat in at once); Wumms 0.85; Bassline Brightness 0.3 -> 0.8 over 12 from 69, back to 0.3 over 8 from 85, up to 0.85 over 12 from 101, to 0.4 over 8 from 117; Bass break (1 bar) at 96 then Double time hold (1 bar) at 97; same at 120 and 121 | - | Enjoy the full groove; the bass brightness breathes |
| Drift 1 | 129-152 | The drift shape from S = 129 (no twist, no beat fade); Bassline Brightness to 0.3 over 8; Drop out hold on bar 152 | - | The energy sinks, the beat stays, kick out for one bar |
| Peak | 153-184 | Everything back at once at 153: Thin, Fog 0; Wumms 0.95; Pads, Dark perc, Rumble, Bassline, Sequence, Sub, Kick, Clap, Percussion Level up; Stab Level; Bassline Brightness 0.5, up to 0.9 over 12 from 157, to 0.4 over 8 from 173; Percussion Fill hold at 160, 176, 184; Bass break (1 bar) at 168 then Double time hold (1 bar) at 169 | - | High energy, a surprising drop-in |
| Drift 2 | 185-208 | The drift shape from S = 185, plus Chapter pressed twice at 195 and 196 to warm, Answer Space (echo) up at 199, Kick, Clap, Percussion and Hats fading together over 8 from 201 | - | The same sinking, the beat stays, warm twist, the beat fades last |

## Risks
- CPU peak: Peak (153-184), every stem at once; Strings stays out of the performance to keep it lighter.
- Clipping: Drop and Peak (Wumms 0.85-0.95, the full beat and every stem arriving at once, bass brightness near its
  top). `npm run audibility` measures the default state only, so this stays unmeasured until the user listens.
- Silent stretches: none planned; the drifts keep the beat, the last bars of Drift 2 fade out on purpose.
