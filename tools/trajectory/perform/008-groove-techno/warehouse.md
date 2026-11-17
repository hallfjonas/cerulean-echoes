# Warehouse

Design for `perform/008-groove-techno/warehouse.json`. Status: design approved (Loop 1 / Round 2); Loop 2 changes
applied through round 4 (see `feedback.md`). The rows below match the script. A second performance for 008 beside the
approved `techno-night`.

## Meta
- Track: 008-groove-techno
- Length: 208 bars = 5 min 57 s at 140 BPM (1 bar = 4 beats = 1.714 s; 208 x 240 / 140 = 357 s)
- Mood: dark from the first bar, curious, then driving and hypnotic
- Story: No kick at the start: a curious melody (Answer, Sequence, Pads) over a soft sub, in a dark chapter. Open
  hats enter alone, then get busier in small steps (more 16ths, then the driving pattern) while the bassline joins. A short build releases into a drop that brings in the full beat
  at once. The groove runs in three blocks with their own bass, percussion and stab patterns and a bass break into
  double time in two of them; the bassline opens and closes in long sweeps. A drift lets the energy sink: kick and clap
  leave first. The peak drops in on the one, the rhythm first and the melody half a beat later, in two blocks of its
  own. A second drift with the beat alive, a warm twist and a beat that leaves only in the last 4 bars closes it. No
  drum pads and no keys.
- References: Yanamaste live set at KHIDI Tbilisi (layering over a slot), Marie Montexier at Nation of Gondwana 2025
  (hypnotic loop, slow filter moves). The references file has no notes for these; the "listen for" is not heard.
- Basis: `@ctl` / `@col` tags of the track. Mode 1 (Jojo): Kick 1, Rumble 2, Sub 3, Bassline 4, Clap 5, Hats 6,
  Percussion 7, fader CC 5-11, knob rows 13-19 / 21-27 / 29-35, buttons 37-43 / 45-51. Mode 2 (Jonas), CC + 48: Pads,
  Strings, Sequence, Stab, Answer, Dark perc, FX. Column 8: Wumms fader 12, Fog 20, Thin 28, Tension 36, Chapter 44,
  Break 52. Chapter cycles Dark, tense, warm: it starts on Dark and is not pressed until the twist in the last drift.
  Strings stay out. A press lands at the next bar line, so "pattern at 89" is pressed in bar 88. A Break pair (press at
  N-1 and N) takes the low end out for exactly bar N, and everything is back on the one at bar N+1.
- The drift: the colour of both drifts is one shape, start bar S, 24 bars: Stab and Sequence out over 8 from S; Thin
  0 -> 0.4 and Fog 0 -> 0.3 over 16 from S; Pads 0.5 -> 0.35 and Dark perc 0.3 -> 0.2 over 16 from S; Bassline and Rumble
  out over 12 from S+4; Wumms 0.95 -> 0.5 over 16 from S; Sub out over 8 from S+8. The beat is handled per place:
  Drift 1 takes Kick and Clap out over 4 bars from S and Percussion over 6 bars from S+4 (Hats stay); Drift 2 keeps the
  whole beat, adds the warm Chapter twist (presses at S+10 and S+11) and Answer Space up at S+14, and takes Kick, Clap,
  Percussion and Hats out together over the last 4 bars.
- Bassline Brightness (CC 16, filter 350 Hz at 0 to 2500 Hz at 1): moves use the real range, slow ramps and held
  plateaus, one big move per block.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Curious | 1-24 | Pads Level at 1, Answer Level at 5, Sequence Level at 9 over 4, Answer Pattern press at 13, Sub Level at 17 over 4; Fog 0.5 -> 0 over 18 | - | A curious melody and sequence over a soft sub, no hats, no kick, no Dark perc |
| Hats | 25-48 | Hats Level at 25 with Pattern 1 (open off-beat only) and Complexity 0, then Complexity 0.1 at 29, 0.2 at 33, 0.3 at 37, 0.4 at 45; Hats Pattern press at 41 (adds closed 16ths); Bassline Level at 37 over 6 | - | Open hats alone, then slowly busier; the bassline joins, still no kick |
| Build | 49-64 | Tension 0 -> 0.9 over 15; Thin 0 -> 0.5 over 12; Rumble Level 0.5 and Riser hold in the last 2 bars; Hats Complexity 0.5 at 53, Hats Pattern press at 57 (driving), Complexity 0.6 at 61 | - | Short build into the drop, the fast hats fully there |
| Groove | 65-88 | Tension and Thin to 0 at 65 (one bar after the ramp end); Kick, Clap, Percussion Level and Wumms 0.85 at 65 (the full beat in at once), Rumble stays; Dark perc Level at 73; Bassline Brightness 0.1 at 65, up to 0.95 over 16 from 73; the way into Bounce is staggered: Hats Complexity 0.65 at 77, Percussion Pattern (gallop) lands 79, Sequence Pattern lands 83, Stab fades in 0 -> 0.5 over 4 from 85, Hats Complexity 0.7 at 86 | - | The full beat, the bass opens slowly, Bounce arrives gradually |
| Bounce | 89-112 | Bassline Pattern (rolling) lands at 89, the last of the changes; Hats Complexity 0.8 over 4 from 89; Bassline Brightness down to 0.05 over 8 from 97, up to 0.6 over 8 from 105; Bass break (1 bar) at 96 then Double time (1 bar) at 97 | - | Rolling bass, gallop percussion, a stab and a new loop |
| Roll | 113-128 | Bassline (acid), Clap (pickup), Stab, Answer, Percussion, Dark perc Pattern presses; Hats Complexity 0.4; Bassline Brightness 0.1 over 4 from 113, 0.95 over 8 from 117, 0.3 over 4 from 125; Bass break at 120 then Double time at 121 | - | Acid bass, new stab and answer, lighter hats |
| Drift 1 | 129-152 | The drift shape from S = 129: Kick and Clap out over 4 from 129, Percussion out over 6 from 133, Hats stay; Bassline Brightness 0.5 | - | Kick and clap leave early, the colour thins, the energy sinks |
| Peak 1 | 153-168 | Patterns first (pressed in 152): Bassline (stomp), Clap (full), Stab, Sequence, Sub; Thin, Fog 0; Wumms 0.95; Kick, Clap, Percussion, Sub, Rumble Level up at 153; Pads, Dark perc, Bassline, Sequence, Stab Level up half a beat later (153.125); Hats Complexity 0.9, Percussion Complexity 0.5; Bassline Brightness 0.9, down to 0.1 over 8 from 161; Percussion Fill hold at 160 | - | The rhythm drops in on the one, the melody a half beat later |
| Peak 2 | 169-184 | Bassline (two presses: 3-3-2 under the break, then rolling at 169), Sequence, Stab, Answer, Percussion Pattern presses; Hats Complexity 0.6; Bassline Brightness up to 0.95 over 16 from 169; Bass break (1 bar) at 168 then Double time (1 bar) at 169; Percussion Fill hold at 176, 184 | - | Rolling bass again, new stab, loop and answer |
| Drift 2 | 185-208 | The drift shape from S = 185 with the beat alive, Chapter pressed twice at 195 and 196 to warm, Answer Space (echo) up at 199, Kick, Clap, Percussion and Hats out together over the last 4 bars from 205 | - | The same colour sinking, the beat stays until the last 4 bars |

## Risks
- CPU peak: Peak 1 and Peak 2, every stem at once; Strings stays out. The peak un-gates every stem at the same moment,
  so the rhythm group and the melody group are staggered by half a beat.
- Clipping: Groove and the Peak (Wumms 0.85-0.95, the full beat arriving at once, the bass filter at 0.95). `npm run
  audibility` measures the default state only, so this stays unmeasured until the user listens.
- Silent stretches: none planned; the last bars of Drift 2 fade out on purpose.
- Rumble: the Riser lives in the Rumble stem, so Rumble Level comes up for the last 2 bars of the Build; the pulses of
  the rumble itself start there, one bar pair before the kick.
