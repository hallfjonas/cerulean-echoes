# 008-groove-techno performance - feedback

## Loop 1 / Round 1 - techno-night.md (2026-11-16)
- User: "008 and 009 sound good" (given for 008 and 009 together)
- Changed: nothing. The open questions resolve to the proposed defaults: 320 bars, Launchkey keys and pads kept,
  chapter order as written.
- Decision: approved
- Approval: Design approved by the user on 2026-11-16 ("008 and 009 sound good"; given for 008 and 009 together, open
  questions resolved to the proposed defaults).

## Loop 2 / Round 1 - techno-night.json (2026-11-16)
- User: "The intro is way too lame. The first main part post intro is quite nice. The first bram is too much and maybe
  misplaced (should maybe come before a drop --> bram quiet --> drop). The second bram is on point. The change in
  mood after the second bram is too much. Third bram is unnecessary. Build up to third bram is maybe biiiit too much
  going on. The crash reverse is also slightly misplaced. Build 2 is super strong and well done with a surprising
  drop-in + Peak. Should then enjoy peak + slowly start drifting out; should be sooner but more gradual and slower
  fade out"
- Mapping: first bram = Braaam (pad 46) at bar 65 (Drop 1), second = bar 113 (Drop 2), third = bar 177 (Peak 1); the
  fourth, at bar 225 (Peak 2), was not mentioned and stays. Crash reverse (pad 48) was at bars 63 (Build 1) and 175
  (Build 2).
- Changed (bars 1-based):
  - Intro 1-48: hats at 3 (was 9), percussion at 5, clap and rumble at 9, sub at 13, bassline at 17, pads from 17
    (was 33), strings from 21; Hats and Percussion Brightness (CC 18, 19) 0 -> 0.7 over 14 and 12 bars, Pads
    Brightness (CC 61) 0 -> 0.6 over 16 bars from 33, Hats Complexity 0.3 at 33, Percussion Complexity 0.3 at 37, Dark
    perc 0.3 at 41; all of it reset in Build 1 / at the first drop so bars 49+ sound as before.
  - First bram: moved from 65 to 64.5 (last half bar before Drop 1), quiet through Launchkey knob 8 (Pad Fog, CC 38)
    0.85 from 64.25 to 66.
  - Crash reverse: from bars 63 and 175 to 63.5 and 175.5.
  - Mood: no Chapter press at 112 (Drop 2 to Build 2 stay tense instead of warm); Peak 1 keeps dark through two
    Chapter presses at 175 and 175.5. Dip: Fog 0.5 over 12 bars (was 0.7 over 8), Bassline 0.45 (was 0.3), Sequence
    and FX changes staggered at 149 and 153 over 8-bar ramps.
  - Third bram at 177 removed. Build 2: Clap Swell hold removed (Riser and Double time stay).
  - Ending: Peak 2 is 225-256 (was 225-272). Strip 257-304 with 12- and 16-bar ramps from 257 (was 273, 2-bar
    ramps), Wumms 0.9 -> 0.5 over 32 bars, then 0 over 24. Out 305-336: 8-bar fades, kick last. Length 336 bars =
    9 min 36 s (was 320 bars, 9 min 9 s).
- Decision: again

## Loop 2 / Round 2 - techno-night.json (2026-11-16)
- User: "Listen in the player: 007, 008, 009, and 010 after the timing fix --> ALL PERFECT NOW; Timing fix not needed"
- Changed: nothing.
- Decision: approved
- Approval: Performance approved by the user on 2026-11-16 ("ALL PERFECT NOW").

## Loop 1 / Round 1 - warehouse.md (2026-11-17)
- User: "chapter dark from the get go; begin with some curious melodic elements: answer, pads; dark perc --> eventually
  bring in some fast hats, slowly a rumble and bass and sequence; build-up tension (not too long) and release with a
  drop that inserts the full beat; then enjoy that for a good while; play with short bass breaks and double times
  (nothing too crazy, but occasionally); eventually slow down and proper build up; high energy peak and then drift out
  (the same way you came in, but with a twist)"
- Changed: design rebuilt around that arc: no kick until the drop, Chapter stays Dark until the twist, intro with
  Answer, Pads and Dark perc, fast hats then rumble, bass and sequence, a short build, a drop that brings the full beat
  in at once, a long groove with short bass breaks and occasional double times, a slow-down, a longer build, a peak and a
  drift-out that retraces the intro with a warm-chapter twist. Length 224 -> 256 bars (7 min 19 s). Open: how "slow down"
  is meant, which twist, length.
- Decision: again

## Loop 1 / Round 2 - warehouse.md (2026-11-17)
- User: "Yes, approved" (answering whether "slow down" means the energy sinks with the tempo unchanged)
- Changed: nothing. The open questions resolve to the proposals in the design: warm-chapter twist plus Answer echo,
  256 bars, no keys, pads as accents only, the script sits beside techno-night.
- Decision: approved
- Approval: Design approved by the user on 2026-11-17 ("Yes, approved").

## Loop 2 / Round 1 - warehouse.json (2026-11-17)
- User: "Bring it all in a bit quicker; remove all drum pad usages --> they don't work so well; when using double time
  or a simple bass break use 4 beats instead of 8; use them in direct combination;"
- Mapping: "quicker" = the way in; "4 beats" = every Double time hold and every Break one bar long; "direct
  combination" = a one-bar Break, then a one-bar Double time on the return.
- Changed (bars 1-based):
  - Way in compressed by a third: Curious 1-24 (was 1-32): Answer at 4, Dark perc at 7, Answer Pattern press at 13,
    Fog ramp 18. Hats 25-48 (was 33-64): Rumble from 31 over 12, Bassline at 37, Sequence at 43, ramps of 6, Hats
    Complexity over 18. Everything after shifts 16 bars earlier. Length 240 bars = 6 min 51 s (was 256 bars, 7 min
    19 s).
  - All drum pads removed (crash reverse, both Braaams, Rim echo, Open hat, Shaker) and the Pad Fog steps (CC 38); the
    script has no Launchkey steps.
  - Breaks and Double times are one bar each. Drop: Break pair (CC 52) at 95 and 96 (low end out in bar 96), Double
    time (CC 37) held in bar 97; same at 119 / 120 and 121. Peak: Break pair at 191 / 192, Double time in bar 193.
    Proper build: Double time one bar at 175 (was 3 bars), before the Drop out bar 176.
  - Percussion Fill holds at 184, 200, 208 (the middle one moved off the break bar).
- Decision: again

## Loop 2 / Round 2 - warehouse.json (2026-11-17)
- User: "Play with the bassline's brightness during the main part. Replace the build up + drop with a drift + drop -->
  exactly the drift you use in the outro; let the drift in the outro be a bit faster; keep the beat alive there but
  still take out some energy"
- Mapping: Bassline Brightness = Mode 1 column 4 row 1 (CC 16), swept slowly in Drop and Peak. "Build up + drop" = the
  first Build (49-64), now Drift 1 followed by the same drop. The drift is one shape used in both places (written
  once for the outro, then reused for the first). The outro drift is 24 bars (was 32), the beat stays alive and
  fades together in the last 8 bars, because Wumms is not a master fader (0 = plain mix) and cannot fade the beat.
- Changed (bars 1-based):
  - Bassline Brightness (CC 16): Drop 0.3 at 73, 0.8 over 12 from 77, 0.3 over 8 from 93, 0.85 over 12 from 109, 0.4
    over 8 from 125, 0.3 over 8 from 137; Peak 0.5 at 185, 0.9 over 12 from 189, 0.4 over 8 from 205. Breaks and double
    times unchanged in pairing, moved 8 bars later with the rest (104/105, 128/129, Peak 200/201).
  - Drift 1 (49-72, 24 bars, replaces Build 49-64, 16 bars): no Tension, no Riser. Stab and Sequence out over 8; Thin up
    to 0.4 and Fog to 0.3 over 16; Pads to 0.35 and Dark perc to 0.2 over 16; Bassline and Rumble out over 12 from 53;
    Hats and Answer stay. The drop at 73 sets Thin and Fog to 0 and brings Pads, Dark perc, Rumble, Bassline, Sequence
    and the whole beat in at once.
  - Drift 2 (217-240, 24 bars, was 209-240 with a stem-by-stem beat exit): the same shape plus Wumms 0.95 -> 0.5 over
    16, Sub out over 8 from 225, the warm Chapter twist (presses at 227 and 228), Answer Space up at 231, then Kick,
    Clap, Percussion and Hats fade together over 8 from 233. The twist and Answer echo are kept: they do not clash with the
    beat.
  - Everything after the first drift shifts 8 bars later; length stays 240 bars = 6 min 51 s.
- Decision: again

## Loop 2 / Round 3 - warehouse.json (2026-11-17)
- User: "You repalced the wrong build up. The first one was perfect before. You should replace the second one by the
  drift."
- Mapping: my Round 2 reading was wrong (I replaced the first build). The first Build (49-64) and the drop at 65 are
  restored step for step from the Round 1 version; the second build (Slow down plus Proper build) is replaced by the
  drift.
- Changed (bars 1-based):
  - Build 49-64 restored (Tension 0 -> 0.9 over 15, Thin 0 -> 0.5 over 12, Riser hold 63-64, drop at 65 with the full
    beat at once); the quicker intro (Curious 1-24, Hats 25-48) stays. No pre-drop drift.
  - Kept from Round 2: Bassline Brightness (CC 16) sweeps in the Drop (now 0.3 at 65, 0.8 over 12 from 69, 0.3 over 8
    from 85, 0.85 over 12 from 101, 0.4 over 8 from 117) and in the Peak (0.5 at 153, 0.9 over 12 from 157, 0.4 over 8
    from 173); the 24-bar outro drift (Drift 2, 185-208) with the warm twist.
  - Slow down (was 129-144) and Proper build (145-176) replaced by Drift 1 (129-152, 24 bars): the same drift function as
    the outro, beat alive (Stab, Sequence, Bassline, Rumble, Sub out in turn, Wumms 0.85 -> 0.5, Thin and Fog up, Pads and
    Dark perc thinning, Kick, Clap, Percussion, Hats stay). Left out of it: the warm Chapter twist, the Answer echo and
    the final beat fade (end only). No Tension rise, Riser, Clap Swell or double-time build.
  - Peak (153-184): a one-bar Kick Drop out (CC 45) on bar 152, then everything in at once on 153: Thin and Fog 0, Wumms
    0.95, Pads, Dark perc, Rumble, Bassline, Sequence, Sub, Kick, Clap, Percussion, Stab up. Bass break at 168 then
    Double time at 169 (1 bar each), Percussion Fill at 160, 176, 184.
  - Length 208 bars = 5 min 57 s (was 240 bars, 6 min 51 s).
- Decision: again

## Lessons
