# Warehouse

Design for `perform/008-groove-techno/warehouse.json`. Status: design approved (Loop 1 / Round 2); Loop 2 changes
applied through round 7 (see `feedback.md`). The rows below match the script. A second performance for 008 beside the
approved `techno-night`.

## Meta
- Track: 008-groove-techno
- Length: 208 bars = 5 min 57 s at 140 BPM (1 bar = 4 beats = 1.714 s; 208 x 240 / 140 = 357 s)
- Mood: dark from the first bar, curious, then driving and hypnotic
- Story: No kick at the start: a sparse, curious melody (Answer, Sequence, a Pads bed) over a soft sub, in a dark
  chapter. Open hats enter alone, then get busier in small steps while the bassline joins. A short build releases into
  a drop with the full beat; the clap follows three bars later. The groove runs in three blocks, each with one or two
  melodic voices in front (Answer; Stab and Sequence; Answer and Stab), its own bass and percussion patterns and one
  bass break. A drift lets the energy sink and ends in a quiet end scene; the peak drops in on the one with rhythm and
  bass only, then brings the melody back one stem at a time. A second bass break leads into a double time. The second
  drift ends in the same scene, with a warm twist, and the beat leaves in the last 4 bars. No drum pads and no keys.
- References: Yanamaste live set at KHIDI Tbilisi (layering over a slot), Marie Montexier at Nation of Gondwana 2025
  (hypnotic loop, slow filter moves). The references file has no notes for these; the "listen for" is not heard.
- Basis: `@ctl` / `@col` tags of the track. Mode 1 (Jojo): Kick 1, Rumble 2, Sub 3, Bassline 4, Clap 5, Hats 6,
  Percussion 7, fader CC 5-11, knob rows 13-19 / 21-27 / 29-35, buttons 37-43 / 45-51. Mode 2 (Jonas), CC + 48: Pads,
  Strings, Sequence, Stab, Answer, Dark perc, FX. Column 8: Wumms fader 12, Fog 20, Thin 28, Tension 36, Chapter 44,
  Break 52. Chapter cycles Dark, tense, warm: it starts on Dark and is not pressed until the twist in the last drift.
  Strings stay out. A press lands at the next bar line, so "pattern at 89" is pressed in bar 88. A Break pair (press at
  N-1 and N) takes the low end out for exactly bar N, and everything is back on the one at bar N+1.
- Sparse melodies: Pads are a low bed (0.3-0.4); Answer 0.35, Sequence 0.3, Stab 0.4-0.45, Dark perc 0.15-0.2. At most
  two of Answer, Sequence and Stab are in front at once; they never all three stack.
- The drift: the colour of both drifts is one shape, start bar S, 24 bars: Stab and Sequence out over 8 from S; Thin
  0 -> 0.4 and Fog 0 -> 0.3 over 16 from S; Pads 0.4 -> 0.3 and Dark perc 0.2 -> 0.15 over 16 from S; Bassline and Rumble
  out over 12 from S+4; Wumms 0.95 -> 0.5 over 16 from S; Sub out over 8 from S+8. The beat is handled per place:
  Drift 1 takes Kick and Clap out over 4 bars from S and Percussion over 6 bars from S+4, Hats stay; Drift 2 keeps the
  whole beat and adds the warm Chapter twist (presses at S+10 and S+11). The end scene is one function used by both,
  starting at S+20 for the last 4 bars: Answer Space up to 0.9 over 2 bars and Kick, Clap, Percussion and Hats out
  over 4 bars (in Drift 1 only the Hats are still playing, so only they leave). The only differences between the two
  end scenes: Drift 2 is in the warm chapter and its beat is leaving, Drift 1 is dark with the beat already gone.
- Bassline Brightness (CC 16, filter 350 Hz at 0 to 2500 Hz at 1): moves use the real range, slow ramps and held
  plateaus, one big move per block.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Curious | 1-24 | Pads Level 0.4 at 1, Answer Level 0.35 at 5, Sequence Level 0.3 at 9 over 4, Answer Pattern press at 13, Sub Level at 17 over 4; Fog 0.5 -> 0 over 18 | - | A sparse, curious melody over a soft sub, no hats, no kick, no Dark perc |
| Hats | 25-48 | Hats Level at 25 with Pattern 1 (open off-beat only) and Complexity 0, then Complexity 0.1 at 29, 0.2 at 33, 0.3 at 37, 0.4 at 45; Hats Pattern press at 41 (adds closed 16ths); Bassline Level at 37 over 6 | - | Open hats alone, then slowly busier; the bassline joins, still no kick |
| Build | 49-64 | Tension 0 -> 0.9 over 15; Thin 0 -> 0.5 over 12; Rumble Level 0.5 and Riser hold in the last 2 bars; Hats Complexity 0.5 at 53, Hats Pattern press at 57 (driving), Complexity 0.6 at 61 | - | Short build into the drop, the fast hats fully there |
| Groove | 65-88 | Tension and Thin to 0 and Sequence out at 65; Kick, Percussion Level and Wumms 0.85 at 65 (the beat drops in at once), Rumble stays; Clap Level at 68 (three bars after the drop); Dark perc Level 0.2 at 73; Bassline Brightness 0.1 at 65, up to 0.95 over 16 from 73; staggered way into Bounce: Hats Complexity 0.65 at 77, Percussion Pattern (gallop) lands 79, Answer out over 4 from 81, Sequence Pattern lands 83 with Sequence Level 0.3 over 4, Stab fades in 0 -> 0.4 over 4 from 85, Hats Complexity 0.7 at 86 | - | The beat, the clap a little later; the answer carries the melody, then hands over |
| Bounce | 89-112 | Bassline Pattern (rolling) lands at 89; Hats Complexity 0.8 over 4 from 89; Bassline Brightness down to 0.05 over 8 from 97, up to 0.6 over 8 from 105; Bass break (1 bar) at 96, no double time | - | Rolling bass, gallop percussion, stab and sequence in front |
| Roll | 113-128 | Bassline (acid), Clap (pickup), Percussion, Answer Pattern presses; Sequence out and Answer back (0.35) over 4 from 113; Hats Complexity 0.4; Bassline Brightness 0.1 over 4 from 113, 0.95 over 8 from 117, 0.3 over 4 from 125; no break | - | Acid bass, answer and stab in front |
| Drift 1 | 129-152 | The drift shape from S = 129: Kick and Clap out over 4 from 129, Percussion out over 6 from 133, Hats stay; Bassline Brightness 0.5; end scene from 149: Answer Space up, Hats out over 4 | - | Kick and clap leave early, the colour thins, the last 4 bars are the quiet end scene |
| Peak 1 | 153-168 | At 153 only rhythm and bass: Thin, Fog 0; Wumms 0.95; Kick, Clap, Percussion, Sub, Rumble, Bassline, Hats Level up; Answer, Pads, Dark perc and Answer Space out; Bassline Brightness 0.9. Then one at a time: Bassline Pattern (stomp) lands 157, Pads 0.4 over 4 from 157, Hats Complexity 0.8 at 157; Clap Pattern (full) lands 161, Stab 0.45 over 4 from 161, Percussion Complexity 0.5, Bassline Brightness 0.1 over 8 from 161; Sub Pattern lands 165, Dark perc 0.2 over 4 from 165; Percussion Fill hold at 160 | - | A clean drop on the one, the melody comes back slowly |
| Peak 2 | 169-184 | Bass break (1 bar) at 168 then Double time (1 bar) at 169; Bassline Brightness up to 0.95 over 16 from 169; Stab out over 4, Bassline Pattern press and Hats Complexity 0.6 at 173; Sequence Pattern and Sequence 0.3 over 4 at 177; Answer 0.35 over 4 at 181; Percussion Fill hold at 176, 184 | - | A break into double time, then the melody changes hands |
| Drift 2 | 185-208 | The drift shape from S = 185 with the beat alive, Chapter pressed twice at 195 and 196 to warm; end scene from 205: Answer Space up, Kick, Clap, Percussion and Hats out together over 4 | - | The same colour sinking, the beat stays until the last 4 bars |

## Risks
- CPU peak: Peak 1 and Peak 2, every rhythm stem at once; Strings stays out. The peak drop-in now brings only rhythm
  and bass on the one and the melody later, one stem at a time.
- Clipping: Groove and the Peak (Wumms 0.85-0.95, the bass filter at 0.95). `npm run audibility` measures the default
  state only, so this stays unmeasured until the user listens.
- Silent stretches: none planned; the last bars of Drift 2 fade out on purpose. Bars 153-156 have no melodic stem on
  purpose.
- Rumble: the Riser lives in the Rumble stem, so Rumble Level comes up for the last 2 bars of the Build; the pulses of
  the rumble itself start there, before the kick.
