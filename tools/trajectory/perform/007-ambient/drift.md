# Drift

Design for `perform/007-ambient/drift.json`. Status: proposal, waiting for the user's approval (Loop 1 / Round 1).
Not scripted yet. The scenario view was not run (no `node_modules` in this worktree); the plan rests on the `@ctl` tags
and the track code.

## Meta
- Track: 007-ambient
- Length: 175 bars = 10 min at 70 BPM (`setcpm(70 / 4)` = 17.5 cycles per minute, 1 bar = 1 cycle = 3.43 s)
- Mood: slow, dreamy, spacious, a little strange in the middle
- Story: Sea and wind fade in, a pad and a drone grow out of it, then a soft heartbeat and bass. Colour (bowed shimmer,
  choir, sparkles) floats on top, small percussion comes in. A break pulls the beat away and the keys play alone over the
  drone. The peak turns the key colour twice (melancholic, strange) and builds tension, the beat returns and the
  chapter goes back to floating. Everything then thins out in reverse and the master fades.
- References: no ambient-genre links in `docs/references.md` yet. Closest: Kiasmos live on KEXP (long, slow build, calm
  dynamics); the track's own `feedback.md` favourites (shimmer, choir, glitter, pad) lead the colour parts.

## Sections
Bars are 1-based. CCs: Mode 1 fader CC 5-11, Mode 2 = +48 (Pad 53, Eno / Shimmer 54, Marimba 55, Toms 56, Choir 57,
Glitter 58, Voice 59); column 8 global: Master 12, Fog 20, Room 28, Tension 36, Chapter 44, Break 52.

| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Dawn | 1-12 | Master 0 -> 0.8 ramp 8; Sea / Wind Level 0 -> 0.3 ramp 8, Space 0.6 | - | Waves fade in alone |
| Pad | 13-28 | Pad Level 0 -> 0.6 ramp 8, Space 0.5; Drone Level 0 -> 0.3 ramp 8 | - | Chords and low fifths grow |
| Heartbeat | 29-44 | Pulse Level 0 -> 0.35 ramp 4 (Punch 0); Bass Level 0 -> 0.3 ramp 4; Drone Pattern press at 37 | - | The floor arrives, soft |
| Colour | 45-64 | Eno / Shimmer Level 0 -> 0.5 ramp 4, Layer press at 45; Choir Level 0.4 at 53; Glitter Level 0.3 at 57, Complexity 0.2 | - | Bowed shimmer, choir, first sparkles |
| Motion | 65-84 | Rim Level 0.3 at 65; Shaker Level 0.3 at 69; Marimba Level 0.4 at 73, Complexity 0.3; Chapter press at 73 (melancholic) | pad Evening (39) at 81 | Small percussion, darker colour |
| Break | 85-100 | Break press at 85; Fog 0 -> 0.5 ramp 4; Sea / Wind Level 0.4 ramp 4; Break press at 97 (back on the one); Fog 0.5 -> 0 ramp 2 at 97 | keys d3 a3 e4 at 87, f#3 a3 c#4 at 93, mod wheel 0 -> 0.6 ramp 2 at 85 | Beat out, keys alone over the drone, return |
| Peak | 101-132 | Tension 0 -> 0.7 ramp 24; Toms Level 0.5 at 105; Choir Complexity 0.5; Glitter Complexity 0.6 at 109; Chapter press at 117 (strange); Pad Brightness 0.7 | pad Glockenspiel (44) at 109 and 125; keys b2 d3 a3 at 113, mod wheel 0.6 | Fullest, strangest, builds |
| Release | 133-152 | Tension 0.7 -> 0 ramp 8; Chapter press at 133 (floating); Toms Level 0 ramp 4 at 137; Marimba Level 0 ramp 4 at 141; Glitter Complexity 0.2 | pad Wind (48) at 141; LK knob 8 (CC 38) 0 -> 0.4 ramp 8 | Calm down, back to floating |
| Dusk | 153-175 | Shaker, Rim Level 0 ramp 4 at 153; Pulse, Bass Level 0 ramp 4 at 157; Choir, Glitter Level 0 ramp 4 at 161; Fog 0 -> 0.6 ramp 12 at 161; Master 0.8 -> 0 ramp 12 at 164 | mod wheel 0 ramp 4 at 157 | Thin out, last pad and sea, fade |

Pad note: pad numbers are drum notes 36-51 (C1 = 36). Evening is pad 4 = note 39, Glockenspiel 44, Wind 48.
Motion uses pad 39 (Evening, a spoken one-shot of about 9 s) at bar 81.

## Risks
- CPU peak: Peak (101-132): 12+ stems (all Jojo beat stems, pad, bowed, marimba, toms, choir, glitter, keys) plus
  Tension echo and reverb. Check in the player on the M2 Air; toms and marimba carry the most events.
- Clipping: Peak (all Levels up, Tension 0.7, keys and pads on top) and the Break return at 97 (beat back at once).
  Measure per section with `npm run audibility` once scripted. Drone and Bass stay at or below 0.3 (the feedback says
  they were heavy in the lows).
- Silent stretches: none planned. Bars 1-4 are quiet while Master and Sea / Wind fade in (intended). The Break keeps
  drone, sea and all of Jonas' colour playing, so it is not silent.

## Open questions
- Length: 10 min fits an ambient slot (slow moves need room). Shorter (about 6 min, 105 bars) with fewer steps, or
  longer?
- Voice (David's spoken recording): leave it out (the design does), or let it enter quietly in Release (Level 0.25,
  Distortion 0, bars 141-152)?
- Launchkey: this design uses sparse keys chords and four one-shot pads. Fine, or controller-only like 010?
  Which pads do you like (Evening, Glockenspiel, Wind, others)?
- Chapter order: it is a fixed cycle floating -> melancholic -> strange. The design ends back on floating. OK?
