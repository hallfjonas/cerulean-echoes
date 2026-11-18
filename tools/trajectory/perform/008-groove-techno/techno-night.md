# Techno night

Design for `perform/008-groove-techno/techno-night.json`. Status: design approved (Loop 1); the script is in
Loop 2, round 1 changes applied (see `feedback.md`). The rows below match the script after round 1.

## Meta
- Track: 008-groove-techno
- Length: 336 bars = 9 min 36 s at 140 BPM (1 bar = 4 beats = 1.71 s; 336 x 240 / 140 = 576 s)
- Mood: dark, hypnotic, driving
- Story: A kick and hats alone, then rumble, bass and clap join in 16-bar steps and the pads colour the groove. A
  long build drops into the first peak, a break pulls the low end out and brings it back on the one, a muffled dip
  and a second, bigger build lead to the two full peaks. The colour then drifts out slowly, stem by stem over long ramps, the rhythm layers next and the kick last.
- References: Yanamaste live set at KHIDI Tbilisi (layering over a long slot), Marie Montexier at Nation of Gondwana
  2025 (hypnotic loop, slow filter moves). The genre section of `docs/reference/listening-list.md` has no notes; the "listen for"
  here is the agent's guess, not heard.
- Basis: `@ctl` tags of the track. Mode 1 (Jojo): Kick 1 .. Percussion 7 (fader CC 5-11, knobs 13-19 / 21-27 /
  29-35, buttons 37-43 / 45-51). Mode 2 (Jonas), CC + 48: Pads, Strings, Sequence, Stab, Answer, Dark perc, FX
  (fader 53-59, buttons 85-91 / 93-99). Column 8: Wumms fader 12, Fog 20, Thin 28, Tension 36, Chapter 44, Break 52.
  Stem Level 0.7 is a placeholder until `npm run audibility` sets real levels. Ride (Jojo column 8) is off in this
  track and stays unused. A press lands at the next bar, so "press at 64" sounds at bar 65.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Kick | 1-16 | Kick Level 0.7 at 1; Hats Level 0.5 at 3, Hats Brightness 0 -> 0.7 ramp 14, Hats Pattern press at 7; Percussion Level 0.45 at 5, Percussion Brightness 0 -> 0.7 ramp 12; Clap Level 0.55 and Rumble Level 0.5 at 9; Sub Level 0.55 at 13 | - | Rhythm layers arrive within the first bars, brighter over time |
| Bass | 17-32 | Bassline Level 0.55 at 17; Pads Level 0 -> 0.4 ramp 8 at 17; Strings Level 0 -> 0.3 ramp 8 at 21; Pads Level 0.5 ramp 4 at 25 | - | Bass and pads join early |
| Colour | 33-48 | Pads Brightness 0 -> 0.6 ramp 16; Hats Complexity 0.3 at 33; Percussion Complexity 0.3 at 37; Dark perc Level 0.3 at 41 | - | Brighter, busier groove before the build |
| Build 1 | 49-64 | Tension 0 -> 1 ramp 16; Thin 0 -> 0.5 ramp 8; Percussion Level 0.5, Percussion Complexity 0 at 49; Hats, Percussion, Pads Brightness back to 0 ramp 16; Rumble Riser hold 63-64; Clap Swell hold 61-64; Clap Pattern press x2 at 64; Chapter press at 64 | pad 48 (Crash reverse) at 63.5; pad 46 (Braaam) at 64.5, quiet through Pad Fog (Launchkey knob 8) 0.85 from 64.25 | Lift into the first drop; crash then quiet bram right before the drop |
| Drop 1 | 65-96 | Tension 0, Thin 0 at 65; Wumms 0.5; Pads Level 0.4; Hats Complexity 0, Dark perc 0 at 65; Stab Level 0.5 at 73; Sequence Level 0.4 at 81; Bassline Pattern press at 89 | Pad Fog back to 0 at 66 | Release: full clap, tense chapter, stab and loop |
| Break 1 | 97-112 | Break press at 96; Fog 0 -> 0.5 ramp 8 at 97; Pads Level 0.7, Pads Pattern press, Strings Level 0.5, FX Level 0.4 at 97; Tension 0 -> 0.6 ramp 8 at 105; Break press at 112 | keys: F minor chords, mod wheel 0.6; pad 51 (Wind) at 97 | Low end out, hats and percussion keep going, back on the one |
| Drop 2 | 113-144 | Fog 0, Tension 0 at 113; Wumms 0.7; Hats Complexity 0.5, Bassline Complexity 0.5 at 121; Answer Level 0.35 at 129; Sequence Pattern press at 137 (no Chapter press: stays tense) | pad 46 (Braaam) at 113 | Second drop, same chapter, more rhythm |
| Dip | 145-160 | Fog 0 -> 0.5 ramp 12 at 145, back to 0 ramp 8 at 155; Bassline Level 0.55 -> 0.45 ramp 8 at 145; Sequence Level 0.6 ramp 8 at 149; FX Level 0.5 ramp 8 at 153 | - | Gentle muffled breather, changes staggered |
| Build 2 | 161-176 | Tension 0 -> 1 ramp 16; Thin 0 -> 0.6 ramp 12; Bassline Level 0.7 ramp 4 at 161; Kick Double time hold 173-176; Rumble Riser hold 175-176; Chapter press x2 at 175 (tense -> warm -> dark, lands at 176); no Clap Swell | pad 48 (Crash reverse) at 175.5 | Strong lift, thinner than before |
| Peak 1 | 177-208 | Tension 0, Thin 0 at 177; Wumms 0.9; Stab Level 0.6 at 185; Dark perc Level 0.5 at 193; Hats Pattern press at 193; Stab Variation 0.5 at 201 | - (no bram) | Full dark groove, most stems on |
| Break 2 | 209-224 | Break press at 208; Hats and Percussion Level 0.4; Pads Level 0.7, Strings Level 0.6, FX Level 0.6, FX Open hold 217-220; Fog 0 -> 0.4 ramp 8 at 209; Break press at 224; Chapter press at 224 (tense) | keys: slow chords, mod wheel 0.6; pad 43 (Vast) at 209 | Long, airy pause before the last run |
| Peak 2 | 225-256 | Fog 0 at 225; Wumms 0.9; Hats Level 0.5, Percussion Level 0.5; Answer Level 0.4 at 233; Pads Pattern press at 245; Sequence Complexity 0.6 at 249 | pad 46 (Braaam) at 225 | Last peak, new chords at the halfway mark |
| Strip | 257-304 | Wumms 0.9 -> 0.5 ramp 32 at 257, then 0 ramp 24 at 289; Level 0 ramp 12: Answer 257, Stab 263, Dark perc 269, Sequence 275; ramp 16: FX 281, Strings 287, Pads 293, Bassline 299 | - | The colour leaves slowly, the beat stays |
| Out | 305-336 | Level 0 ramp 8: Clap 307, Sub 313, Rumble and Percussion 319, Hats 325; Kick Level 0.7 -> 0 ramp 8 at 329 | - | Rhythm layers fade, kick last, then silence |

## Risks
- CPU peak: Peak 2 (225-272) and the end of Build 2 (173-176): around 12 stems, Tension at 1 (echo and reverb on all
  three orbits), Double time and the swell. Check in the player on the M2 Air; if it drops out, thin the peak by
  one colour stem (Dark perc or Answer).
- Clipping: Peak 1 and Peak 2 (Wumms 0.9 drives kick, rumble, sub and bassline) and the Build tops (Tension 1 opens
  every filter up to 2.5x). Measure per section with the scenario table and `npm run audibility`; the 0.7 levels
  are guesses. The Break returns (113, 225) bring the low end back at once.
- Silent stretches: none planned. Breaks and the Dip remove the low end or darken, but hats, percussion and pads
  keep playing. Only the last bar of Out is silent, on purpose.
- Launchkey: the performance format may have no keys, pad and mod wheel steps yet (the 010 pilot was
  controller-only); keys have a fixed note length. If unsupported, the Launchkey column stays a note for a later round.
- Not measured: `npm run scenario -- <track> --view` did not run here (no `node_modules` in the worktree), so the
  default-state view was not read and section loudness is unchecked.

## Open questions
- Length: 9 min 9 s (320 bars), or a longer slot of about 11 min (384 bars, add a third Break-Drop arc), or shorter,
  about 6 min (210 bars, drop the Dip and Break 2)? The first pilot was 4 min 20 s.
- Launchkey: keep it (keys in both breaks, pad hits on every drop and build) or controller-only like 010? The
  script format needs to support keys, pads and the mod wheel for this.
- Chapter order: Chapter cycles Dark -> Tight (Drop 1) -> Warm (Drop 2) -> Dark (Peak 1) -> Tight (Peak 2). Do you
  want the warm chapter at the end instead, or no chapter change after Drop 2?
- Section names are working titles; rename any you like.
