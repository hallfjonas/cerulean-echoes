# Journey

Design for `perform/010-ambient-house/journey.json`. Starting point: `spike-run.json` (same moves, now with sections).
Status: proposal, waiting for the user's approval (Loop 1 / Round 1).

## Meta
- Track: 010-ambient-house
- Length: 130 bars = 4 min 20 s at 120 BPM
- Mood: warm, floating, slowly lifting
- Story: A pad fades in alone, the beat and bass join one stem at a time. A first build drops into the chords, a
  break pulls the low end out and brings it back, then fog and a new chapter carry it to a second peak with
  percussion. The master fades the whole thing out.
- References: Kiasmos live on KEXP (slow build, long pad intro), Harmon at Bachstelzen 2 (steady groove under moving
  colour), David August Boiler Room Berlin (break and return)

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Pad | 1-4 | Master 0.8; Mode 2 col 1 Level 0.7 ramp 4, Space 0.5 | - | Fade in the pad alone |
| Layers | 5-20 | Level up one by one: kick (5), sub (9), hats (13), clap and congas (17) | - | Beat and bass join, one stem at a time |
| Chords | 21-28 | Mode 2 col 2 Level 0.6 | - | Deep chords colour the groove |
| Build | 29-36 | Tension 0 -> 0.9 ramp 8; noise Level 0.5 | - | Lift into the drop |
| Drop | 37-44 | Tension 0; Chapter press | - | New chords, release |
| Break | 45-60 | Break press at 45 (low end out), Break press at 53 (all back on the one) | - | Pull the bottom away, bring it back |
| Groove | 61-68 | Kick Pattern press; hat Complexity 0.6 | - | Busier rhythm |
| Fog | 69-85 | Fog 0 -> 0.7 ramp 4 at 69, back to 0 ramp 4 at 77 | - | Muffled dip, then clear |
| Chapter 2 | 86-100 | Chapter press at 86; bass Level 0.7 ramp 2 | - | Rolling bass under new chords |
| Peak | 101-120 | Conga Pattern press; conga Complexity 0.6 | - | Percussion on top |
| Fade | 121-130 | Master 0.8 -> 0 ramp 10 | - | Out |

## Risks
- CPU peak: Peak (101-120), all stems, two chord layers and percussion at once. Check in the player on the M2 Air.
- Clipping: Build and Peak, where Tension and every Level are high. Measure per section with the scenario table and
  `npm run audibility`.
- Silent stretches: none planned. The Break removes the low end, not the sound.

## Open questions
- Length: 4 min 20 s is a short slot. Longer (about 8 min, 250 bars) by repeating the Build-Drop-Break arc once more?
- Launchkey: the spike has none. Add slow keys chords in Chords and Chapter 2, and a pad hit on each Drop? Or keep this
  one controller-only?
- Section names are working titles. Rename any you like.
- Bar numbers above are rounded from the spike's bars (0-based) to 1-based sections; the JSON will keep the spike's
  step bars.
