# Warehouse

Design for `perform/008-groove-techno/warehouse.json`. Status: design approved (Loop 1 / Round 2); Loop 2 / Round 1
changes applied (see `feedback.md`). The rows below match the script after round 1. A second performance for 008
beside the approved `techno-night`.

## Meta
- Track: 008-groove-techno
- Length: 240 bars = 6 min 51 s at 140 BPM (1 bar = 4 beats = 1.714 s; 240 x 240 / 140 = 411 s)
- Mood: dark from the first bar, curious, then driving and hypnotic
- Story: No kick at the start: a curious melody (Answer, Pads) and Dark perc in a dark chapter. Fast hats arrive
  quickly, then a rumble, bass and sequence. A short build releases into a drop that brings in the full beat at once.
  The groove runs a good while, with one-bar bass breaks that return straight into a double-time bar. A slow-down
  leads to a proper, longer build, a high-energy peak, and a drift-out that retraces the way in, with a twist at the
  very end. No drum pads and no keys.
- References: Yanamaste live set at KHIDI Tbilisi (layering over a slot), Marie Montexier at Nation of Gondwana 2025
  (hypnotic loop, slow filter moves). The references file has no notes for these; the "listen for" is not heard.
- Basis: `@ctl` / `@col` tags of the track. Mode 1 (Jojo): Kick 1, Rumble 2, Sub 3, Bassline 4, Clap 5, Hats 6,
  Percussion 7, fader CC 5-11, knob rows 13-19 / 21-27 / 29-35, buttons 37-43 / 45-51. Mode 2 (Jonas), CC + 48: Pads,
  Strings, Sequence, Stab, Answer, Dark perc, FX. Column 8: Wumms fader 12, Fog 20, Thin 28, Tension 36, Chapter 44,
  Break 52. Chapter cycles Dark, tense, warm: it starts on Dark and is not pressed until the twist. Strings stay out.
  A press lands at the next bar line, so "press at 63" sounds at bar 64. A Break pair (press at N-1 and N) takes the
  low end out for exactly bar N, and everything is back on the one at bar N+1.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Curious | 1-24 | Pads Level at 1, Answer Level at 4 (Answer Pattern press at 13), Dark perc Level at 7; Fog 0.5 -> 0 over 18 | - | A dark, curious melody over a ticking percussion, no kick |
| Hats | 25-48 | Hats Level at 25, Hats Pattern pressed twice (driving) and Complexity up over 18; Rumble Level 0 -> 0.5 over 12 from 31; Bassline Level at 37 and Sequence Level at 43, ramps of 6 | - | Fast hats first, then rumble, bass and sequence quickly, still no kick |
| Build | 49-64 | Tension 0 -> 0.9 over 15; Thin 0 -> 0.5 over 12; Riser hold in the last 2 bars | - | Short build into the drop |
| Drop | 65-128 | Tension and Thin to 0 at 65 (one bar after the ramp end); Kick, Clap, Sub, Percussion Level all up at 65 (the full beat in at once); Wumms 0.85; Bass break (1 bar) at 96 then Double time hold (1 bar) at 97; same at 120 and 121 | - | Enjoy the full groove for a good while; break into double time |
| Slow down | 129-144 | Kick, Clap and Percussion Level down over 12, Wumms 0.85 -> 0.5; Thin 0 -> 0.4, Fog 0 -> 0.3 | - | Let the energy sink back to melody and hats |
| Proper build | 145-176 | Kick, Clap, Percussion Level back up from 161; Tension 0 -> 1 over 31; Thin up; Clap Swell hold 4 bars at 169; Riser hold at 173-174; Double time hold 1 bar at 175; Drop out hold on bar 176 | - | A real, longer build, kick out for one bar before the peak |
| Peak | 177-208 | Tension to 0 at 177; Wumms 0.95, all stems up; Stab Level; Percussion Fill hold at 184, 200, 208; Bass break (1 bar) at 192 then Double time hold (1 bar) at 193 | - | High energy |
| Drift | 209-240 | The way in, backwards: Stab, Sequence out over 8 from 209; Bassline, Rumble over 12 from 217; Kick, Clap, Sub, Percussion out over 8 from 225; Hats out from 233; Wumms 0.95 -> 0.3 over 24; leaves Answer, Pads, Dark perc; twist: Chapter pressed twice at 228 and 229 to warm, Answer Space (echo) up at 233 | - | Retrace the opening, with the chords turning warm at the end |

## Risks
- CPU peak: Peak (177-208), every stem and Tension at its end; Strings stays out of the performance to keep it lighter.
- Clipping: Drop and Peak (Wumms 0.85-0.95, the full beat arriving at once). `npm run audibility` measures the default
  state only, so this stays unmeasured until the user listens.
- Silent stretches: none planned; the first bars have Pads and Answer, the break bars keep hats and melody.
- Timing: the Tension snap is written one bar after its ramp end.
