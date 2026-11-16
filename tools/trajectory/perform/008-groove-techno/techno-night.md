# Techno night

Design for `perform/008-groove-techno/techno-night.json`. Status: proposal, waiting for the user's approval
(Loop 1 / Round 1). No script yet.

## Meta
- Track: 008-groove-techno
- Length: 320 bars = 9 min 9 s at 140 BPM (1 bar = 4 beats = 1.71 s; 320 x 240 / 140 = 549 s)
- Mood: dark, hypnotic, driving; warm only for the second drop
- Story: A kick and hats alone, then rumble, bass and clap join in 16-bar steps and the pads colour the groove. A
  long build drops into the first peak, a break pulls the low end out and brings it back on the one, a muffled dip
  and a second, bigger build lead to the two full peaks. The colour then leaves one stem at a time, the kick last.
- References: Yanamaste live set at KHIDI Tbilisi (layering over a long slot), Marie Montexier at Nation of Gondwana
  2025 (hypnotic loop, slow filter moves). The genre section of `docs/references.md` has no notes; the "listen for"
  here is the agent's guess, not heard.
- Basis: `@ctl` tags of the track. Mode 1 (Jojo): Kick 1 .. Percussion 7 (fader CC 5-11, knobs 13-19 / 21-27 /
  29-35, buttons 37-43 / 45-51). Mode 2 (Jonas), CC + 48: Pads, Strings, Sequence, Stab, Answer, Dark perc, FX
  (fader 53-59, buttons 85-91 / 93-99). Column 8: Wumms fader 12, Fog 20, Thin 28, Tension 36, Chapter 44, Break 52.
  Stem Level 0.7 is a placeholder until `npm run audibility` sets real levels. Ride (Jojo column 8) is off in this
  track and stays unused. A press lands at the next bar, so "press at 64" sounds at bar 65.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Kick | 1-16 | Kick Level 0.7 at 1; Hats Level 0.5 at 9 | - | Kick alone, hats on the off-beat |
| Bass | 17-32 | Rumble Level 0.6 at 17; Sub Level 0.6 at 21; Clap Level 0.6 at 25; Bassline Level 0.55 at 29 | - | Foundation joins, one stem per 4 bars |
| Colour | 33-48 | Pads Level 0 -> 0.5 ramp 8 at 33; Percussion Level 0.5 at 41; Hats Pattern press at 41; Strings Level 0.3 at 45 | - | Pads and percussion colour the groove |
| Build 1 | 49-64 | Tension 0 -> 1 ramp 16; Thin 0 -> 0.5 ramp 8 at 49; Rumble Riser hold 63-64; Clap Swell hold 61-64; Clap Pattern press x2 at 64; Chapter press at 64 | pad 48 (Crash reverse) at 63 | Lift into the first drop |
| Drop 1 | 65-96 | Tension 0, Thin 0 at 65; Wumms 0.5; Pads Level 0.4; Stab Level 0.5 at 73; Sequence Level 0.4 at 81; Bassline Pattern press at 89 | pad 46 (Braaam) at 65 | Release: full clap, tense chapter, stab and loop |
| Break 1 | 97-112 | Break press at 96; Fog 0 -> 0.5 ramp 8 at 97; Pads Level 0.7, Pads Pattern press, Strings Level 0.5, FX Level 0.4 at 97; Tension 0 -> 0.6 ramp 8 at 105; Break press at 112 | keys: F minor chords, mod wheel 0.6; pad 51 (Wind) at 97 | Low end out, hats and percussion keep going, back on the one |
| Drop 2 | 113-144 | Chapter press at 112 (warm); Fog 0, Tension 0 at 113; Wumms 0.7; Hats Complexity 0.5, Bassline Complexity 0.5 at 121; Answer Level 0.35 at 129; Sequence Pattern press at 137 | pad 46 (Braaam) at 113 | Warm second drop, more rhythm |
| Dip | 145-160 | Fog 0 -> 0.7 ramp 8 at 145, back to 0 ramp 4 at 157; Bassline Level 0.55 -> 0.3 ramp 4 at 145; Sequence Level 0.6; FX Level 0.5 | - | Muffled breather, beat keeps going |
| Build 2 | 161-176 | Tension 0 -> 1 ramp 16; Thin 0 -> 0.6 ramp 12; Bassline Level 0.7 at 161; Kick Double time hold 173-176; Rumble Riser hold 175-176; Clap Swell hold 173-176; Chapter press at 176 (dark) | pad 48 (Crash reverse) at 175 | Bigger lift, double-time kick at the end |
| Peak 1 | 177-208 | Tension 0, Thin 0 at 177; Wumms 0.9; Stab Level 0.6 at 185; Dark perc Level 0.5 at 193; Hats Pattern press at 193; Stab Variation 0.5 at 201 | pad 46 (Braaam) at 177 | Full dark groove, most stems on |
| Break 2 | 209-224 | Break press at 208; Hats and Percussion Level 0.4; Pads Level 0.7, Strings Level 0.6, FX Level 0.6, FX Open hold 217-220; Fog 0 -> 0.4 ramp 8 at 209; Break press at 224 | keys: slow chords, mod wheel 0.6; pad 43 (Vast) at 209 | Long, airy pause before the last run |
| Peak 2 | 225-272 | Chapter press at 224 (tense); Fog 0 at 225; Wumms 0.9; Hats Level 0.5, Percussion Level 0.5; Answer Level 0.4 at 233; Dark perc Level 0.5 at 241; Pads Pattern press at 249; Sequence Complexity 0.6 at 257 | pad 46 (Braaam) at 225 | Last peak, new chords at the halfway mark |
| Strip | 273-304 | Wumms 0.9 -> 0.5 ramp 16; Level 0 ramp 2, one stem per 4 bars: Answer 273, Stab 277, Dark perc 281, Sequence 285, FX 289, Strings 293, Pads 297, Bassline 301 | - | The colour leaves, the beat stays |
| Out | 305-320 | Wumms 0; Clap Level 0 at 305; Sub Level 0 at 309; Rumble and Percussion Level 0 at 313; Hats Level 0 at 315; Kick Level 0.7 -> 0 ramp 4 at 317 | - | Kick and hats last, then silence |

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
