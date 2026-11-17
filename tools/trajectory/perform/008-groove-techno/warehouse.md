# Warehouse

Design for `perform/008-groove-techno/warehouse.json`. Status: proposal, revised after Loop 1 / Round 1 (see
`feedback.md`), waiting for the user's approval. A second performance for 008 beside the approved `techno-night`.

## Meta
- Track: 008-groove-techno
- Length: 256 bars = 7 min 19 s at 140 BPM (1 bar = 4 beats = 1.714 s; 256 x 240 / 140 = 439 s), eight 32-bar blocks
- Mood: dark from the first bar, curious, then driving and hypnotic
- Story: No kick at the start: a curious melody (Answer, Pads) and Dark perc in a dark chapter. Fast hats arrive, then
  a slow rumble, bass and sequence. A short build releases into a drop that brings in the full beat at once. The groove
  runs a good while, with short bass breaks and occasional double times. A slow-down leads to a proper, longer build,
  a high-energy peak, and a drift-out that retraces the way in, with a twist at the very end.
- References: Yanamaste live set at KHIDI Tbilisi (layering over a slot), Marie Montexier at Nation of Gondwana 2025
  (hypnotic loop, slow filter moves). The references file has no notes for these; the "listen for" is not heard.
- Basis: `@ctl` / `@col` tags of the track. Mode 1 (Jojo): Kick 1, Rumble 2, Sub 3, Bassline 4, Clap 5, Hats 6,
  Percussion 7, fader CC 5-11, knob rows 13-19 / 21-27 / 29-35, buttons 37-43 / 45-51. Mode 2 (Jonas), CC + 48: Pads,
  Strings, Sequence, Stab, Answer, Dark perc, FX. Column 8: Wumms fader 12, Fog 20, Thin 28, Tension 36, Chapter 44,
  Break 52. Chapter cycles Dark, tense, warm: it starts on Dark and is not pressed until the twist. Launchkey: mod wheel
  CC 1, knobs CC 31-38, pads 36-51 (Low tom 44, Rim echo 45, Braaam 46, Open hat 47, Crash reverse 48, Shaker 49).
  A press lands at the next bar, so "press at 63" sounds at bar 64.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Curious | 1-32 | Pads Level at 1, Answer Level at 5 (Answer Pattern press at 17), Dark perc Level at 9; Fog 0.5 -> 0 over 24 | - | A dark, curious melody over a ticking percussion, no kick |
| Hats | 33-64 | Hats Level at 33, Hats Pattern pressed twice (driving) and Complexity up over 24; Rumble Level 0 -> 0.5 over 16 from 41; Bassline Level at 49 and Sequence Level at 57, ramps of 8 | - | Fast hats first, then rumble, bass and sequence slowly, still no kick |
| Build | 65-80 | Tension 0 -> 0.9 over 14; Thin 0 -> 0.5 over 12; Riser hold in the last 2 bars | Crash reverse at 78.5; quiet Braaam at 80.5 (Pad Fog 0.85) | Short build, bram quiet just before the drop |
| Drop | 81-144 | Tension to 0 at 80 ramp end, snap at 81; Kick, Clap, Sub, Percussion Level all up at 81 (the full beat in at once); Wumms 0.85; Bass breaks: Break press at 104 and 107 (3 bars), 128 and 131; Double time hold on 2 bars at 113 and 137 | Rim echo on the grid in bars 97 and 121 | Enjoy the full groove for a good while, short bass breaks, rare double times |
| Slow down | 145-160 | Kick, Clap and Percussion Level down over 12, Wumms 0.9 -> 0.5; Thin 0 -> 0.4, Fog 0 -> 0.3 | - | Let the energy sink back to melody and hats |
| Proper build | 161-192 | Kick, Clap, Percussion Level back up from 177; Tension 0 -> 1 over 28; Thin up; Clap Swell hold 4 bars at 185; Riser hold at 189; Double time hold at 189; Drop out hold on bar 192 | Crash reverse at 190.5 | A real, longer build, kick out for one bar before the peak |
| Peak | 193-224 | Tension to 0 at 193; Wumms 0.95, all stems up; Stab Level; Percussion Fill hold at phrase ends; Double time hold 2 bars at 209 | Braaam at 193; Open hat and Shaker accents on the grid | High energy |
| Drift | 225-256 | The way in, backwards: Stab, Sequence out over 8 from 225; Bassline, Rumble over 12 from 233; Kick, Clap, Sub, Percussion out over 8 from 241; Hats out from 249; Wumms 0.95 -> 0.3 over 24; leaves Answer, Pads, Dark perc; twist: Chapter pressed twice at 244 and 245 to warm, Answer Echo throw held at 249 | - | Retrace the opening, with the chords turning warm at the end |

## Risks
- CPU peak: Peak (193-224), every stem and Tension at its end; Strings stays out of the performance to keep it lighter.
- Clipping: Drop and Peak (Wumms 0.85-0.95, the full beat arriving at once) and the Braaam hits; `npm run audibility`
  measures the default state only, so this stays unmeasured until the user listens.
- Silent stretches: none planned; the first bars have Pads and Answer, the break bars keep hats and melody.
- Timing: the Tension snap is written one bar after its ramp end (in `techno-night` it is unconfirmed which wins).

## Open questions
- "Slow down": read here as a sinking of energy (kick and clap out, Thin and Fog up) because the track's tempo cannot be
  changed from the controllers. Is that what you mean?
- The twist at the end: chords turn warm (Chapter pressed to warm) plus an echo throw on the Answer. Other options: end on
  a held Wind pad, or Strings enter alone.
- Length: 7 min 19 s as proposed, or longer / shorter?
- Keys: none in this design; pads only as accents. Add a keys chord in the slow-down?
- Should it sit beside `techno-night` (two scripts for 008) or replace it once approved?
