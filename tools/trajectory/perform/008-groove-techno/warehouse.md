# Warehouse

Design for `perform/008-groove-techno/warehouse.json`. Status: proposal, waiting for the user's approval
(Loop 1 / Round 1). A second performance for 008 beside the approved `techno-night`; it keeps what the user praised
there and tries a shorter, more constant peak-time shape.

## Meta
- Track: 008-groove-techno
- Length: 224 bars = 6 min 24 s at 140 BPM (1 bar = 4 beats = 1.714 s; 224 x 240 / 140 = 384 s), seven 32-bar blocks
- Mood: dark, hypnotic, relentless; one tense second half
- Story: The rhythm arrives fast, no bare kick: hats and percussion within the first bars, bass and clap by bar 17.
  A first lift drops into a long, steady groove, one short break takes the low end out and puts it back on the one, and
  a second, stronger lift with a surprising drop-in leads to the peak. The drift-out starts early and takes a whole
  block, stem by stem, the kick last.
- Difference to `techno-night` (9 min 36 s, two breaks, a dip, two builds): shorter, one break only, no mood change
  (the chapter stays Dark), the pads of the Launchkey are used as grid accents instead of atmosphere.
- References: Yanamaste live set at KHIDI Tbilisi (layering over a slot), Marie Montexier at Nation of Gondwana 2025
  (hypnotic loop, slow filter moves). The references file has no notes for these; the "listen for" is not heard.
- Basis: `@ctl` / `@col` tags of the track. Mode 1 (Jojo): Kick 1 .. Percussion 7, fader CC 5-11, knob rows 13-19 /
  21-27 / 29-35, buttons 37-43 / 45-51. Mode 2 (Jonas), CC + 48: Pads, Strings, Sequence, Stab, Answer, Dark perc, FX.
  Column 8: Wumms fader 12, Fog 20, Thin 28, Tension 36, Chapter 44, Break 52. Launchkey: mod wheel CC 1, knobs
  CC 31-38 (Brightness 31, Length 35, Space 36, Echo 37, Pad Fog 38), pads 36-51 (Low tom 44, Rim echo 45, Braaam 46,
  Open hat 47, Crash reverse 48, Shaker 49). A press lands at the next bar, so "press at 63" sounds at bar 64.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Arrive | 1-16 | Kick Level at 1; Hats Level at 3, Percussion Level at 5, Clap and Rumble Level at 9, Sub Level at 13; Hats and Percussion Brightness rise | - | Rhythm at once, brighter over time |
| Groove | 17-48 | Bassline Level at 17; Pads Level at 25, Strings Level at 33; Hats, Percussion, Bassline Pattern presses on phrase lines; Percussion Complexity up | - | Settle into the groove, one layer per phrase |
| Lift | 49-64 | Tension 0 -> 0.8 over 12; Thin 0 -> 0.5 over 8, back down; Riser hold in the last 2 bars; Sequence Level at 49 | Crash reverse at 62.5; quiet Braaam at 64.5 (Pad Fog 0.85) | Build into the drop, bram quiet just before it |
| Warehouse | 65-96 | Tension to 0 at 66; Wumms 0.8; Stab Level, Answer Level; Bassline Octave hold at 81 | Rim echo and Low tom on the grid in bars 73 and 89 | First peak, steady and driving |
| Break | 97-104 | Break press at 96 (low end out); Strings and Pads keep playing; Break press at 103 (all back on the one) | keys chord f3 ab3 c4 (mod wheel 0.6) | Short pull-back, return on the one |
| Return | 105-144 | Tension 0 -> 1 over 24 from bar 121; Thin up; Double time hold in the last 4 bars; Drop out hold on bar 144 | Crash reverse at 142.5 | Second lift, kick drops out for one bar for the surprise |
| Peak | 145-192 | Wumms 0.9; all stems up; Percussion Fill hold at phrase ends; Chapter stays Dark | Braaam at 145; Open hat and Shaker accents on the grid | Full groove, enjoy it |
| Drift | 193-224 | Strip: Answer, Stab, Sequence out over 12-bar ramps from 193; Pads, Strings, Bassline over 16-bar ramps from 205; Wumms 0.9 -> 0 over 32; Hats and Percussion out last, kick last | - | Early, slow, gradual fade |

## Risks
- CPU peak: Peak (145-192) with every stem and Tension at its end; Strings is the first one to drop if it stutters.
- Clipping: Warehouse and Peak (Wumms 0.8-0.9, stems around 0.7) and the Braaam hits; `npm run audibility` measures the
  default state only, so this stays unmeasured until the user listens.
- Silent stretches: none planned; bar 144 has no kick on purpose (one bar).
- Tension ramps end on the same bar as the snap to 0 in `techno-night` (unconfirmed which wins): here the snap is
  written one bar after the ramp end.

## Open questions
- Length: 6 min 24 s as proposed, or about 8 min (a third 32-bar block of Warehouse)?
- Keys: keep the one keys chord in the Break, or play controller-only plus pads?
- Should it sit beside `techno-night` (two scripts for 008) or replace it once approved?
- Section names are working titles.
