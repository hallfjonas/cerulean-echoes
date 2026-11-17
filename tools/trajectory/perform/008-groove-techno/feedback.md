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

## Loop 2 / Round 4 - warehouse.json (2026-11-17)
- User: "Something sounded weird in the second drop (as if the melodies came in slightly before the rhythm; but could be
  a CPU mistake because I open UI in external window there); please check. Keep the beat alive during the outro; only
  take it out in the last. Remove the dark perc from the intro; only bring it in later. Bring in open hat first and
  wait with fast hats a bit; bring in sub first, rumble only once kick is there; bring in sequence earlier --> good
  compliment to answer. Bassline brightness shift barely noticable. Needs more variety across the different sections (a
  bit too monotonous now over time; constance in each section is good tho). The kick needs to be removed much earlier in
  the middle drift."
- Reading: "second drop" = the Peak drop-in at bar 153. "In the last" = the last 4 bars (2 bars would also fit).
- Findings on the second drop: the scenario shows no melody ahead of the rhythm (kick on 152.000 and every Level step on
  the same bar line, in one scheduler tick); the script cannot explain it alone. Candidates: (1) the Drop out hold and the
  Level steps are sampled in the same tick, but nine stems un-gate at once (CPU spike, a UI window makes it worse); (2) the
  pad chord change lands on the bar line while the kick came back through a gate; (3) sustained melodic notes already
  sounding while the kick was out for the bar before.
- Changed (bars 1-based):
  - Peak drop-in: no Drop out hold any more (the kick is already gone). Rhythm (Kick, Clap, Percussion, Sub, Rumble)
    at 153; Pads, Dark perc, Bassline, Sequence, Stab half a beat later (153.125, no ramp, never earlier).
  - Outro (Drift 2, 185-208): the whole beat stays; Kick, Clap, Percussion and Hats out together over the last 4 bars
    (205-208), was the last 8 bars. Twist and Answer echo unchanged.
  - Dark perc (CC 58): removed from Curious and Hats; in at 73 (Groove, after the drop).
  - Intro: Hats at 3 (open off-beat, Pattern 1) with Complexity 0.25 from 25; fast hats later (Hats Pattern pressed at 33
    and 41, Complexity 0.6 at 33). Sub at 17 (Level 0.5, before any kick). Rumble no longer in the intro: from 63 only,
    for the Riser (it lives in the Rumble stem), then on with the drop. Sequence at 9 (Answer's companion; Answer Pattern
    press at 13). Bassline at 37, as before.
  - Bassline Brightness (CC 16): 0.1 -> 0.95 over 16 from 73; 0.05 over 8 from 97; 0.6 from 105; 0.1 over 4 from 113,
    0.95 over 8 from 117, 0.3 at 125; 0.5 at 129; 0.9 at 153, 0.1 over 8 from 161; 0.95 over 16 from 169. Bass filter
    median per scenario: 489 Hz (0.05) to 2335 Hz (0.95), about 4.8 times (before: 0.3 to 0.85 over 12 bars).
  - Variety: three Drop blocks (Groove 65-88, Bounce 89-112, Roll 113-128) and two Peak blocks (153-168, 169-184), each
    with its own Pattern presses (Bassline, Percussion, Sequence, Stab, Answer, Clap, Dark perc, Sub), Hats Complexity,
    Stab on from 89; no Chapter press before the twist.
  - Middle drift (Drift 1, 129-152): Kick and Clap out over 4 bars from 129, Percussion over 6 bars from 133, the rest of
    the shape as before.
  - Length stays 208 bars = 5 min 57 s.
- Decision: again

## Loop 2 / Round 5 - warehouse.json (2026-11-17)
- User: "You directly start with open high hat now; what I meant: when hi-hat comes in (as in prev version) start only
  with open hi-hat; then eventuall slowly add fast one"
- Changed (bars 1-based): the hats no longer start at bar 3. Curious (1-24) has no hats again. Hats Level 0.5 (CC 10)
  at 25 with Pattern 1 (open off-beat) and Hats Complexity (CC 34) 0, then Complexity 0.1 at 29, 0.2 at 33, 0.3 at 37,
  0.4 at 45, 0.5 at 53, 0.6 at 61; Hats Pattern presses (CC 42) landing on 41 (adds closed 16ths) and 57 (driving). The
  earlier presses at 33 and 41 and the Complexity 0.25 / 0.6 steps are gone. Everything else from Round 4 stays.
- Decision: again

## Loop 2 / Round 6 - warehouse.json (2026-11-17)
- User: "Almost perfect. Just a tiny modification: the change from groove to bounce is too harsh/sudden"
- Changed (bars 1-based): the five changes that all flipped on bar 89 are staggered over the last 12 bars of Groove.
  Hats Complexity (CC 34) 0.65 at 77, 0.7 at 86, 0.8 over 4 from 89 (was 0.8 over 4 at 89 only); Percussion Pattern
  (CC 43, gallop) lands at 79 (was 89); Sequence Pattern (CC 87) lands at 83 (was 89); Stab (CC 56) fades in 0 -> 0.5
  over 4 from 85 (was a step to 0.5 at 89); Bassline Pattern (CC 40, rolling) stays at 89, now the last change. The
  Bounce block, the bass break at 96 and the Double time at 97 are unchanged.
- Decision: again

## Loop 2 / Round 7 - warehouse.json (2026-11-17)
- User: "1. the melodies are too overloaded; they should be more sparse across the whole song. 2. first four beat drop
  --> remove the double time afterwads. 3. only use two of these short beat drops (the second one should have the double
  time); 4. The drift before the drop should play exactly the scene at the very end of the track for a 4 cycles; then
  come in with the whole beat and all. 5. The clap should come in 2-4 cycle after the first drop. 6. The second drop is
  not clean enough"
- Reading: "four beat drop" = the one-bar bass break (4 beats). "Second drop" = the Peak drop-in at 153.
- Changed (bars 1-based):
  - 1: Levels down (Pads bed 0.5 -> 0.4, Answer 0.45 -> 0.35, Sequence 0.4 -> 0.3, Stab 0.5/0.6 -> 0.4/0.45, Dark perc
    0.3 -> 0.2; drift ends Pads 0.3, Dark perc 0.15). At most two of Answer, Sequence, Stab in front: Groove Answer;
    Bounce Stab and Sequence (Sequence out at 65, back at 83 over 4, Answer out over 4 from 81); Roll Answer and Stab
    (Sequence out, Answer back over 4 from 113); Peak 1 Stab; Peak 2 Sequence and Answer. Stab and Dark perc pattern
    presses at 113 and 153/169 removed.
  - 2/3: two bass breaks: 96 with no double time, 168 with Double time at 169. The pair at 120/121 is gone.
  - 4: the last 4 bars of Drift 1 (149-152) and Drift 2 (205-208) run the same end-scene function (Answer Space 0.9
    over 2, Kick, Clap, Percussion, Hats out over 4). Differences: Drift 2 is warm and its beat is still leaving; Drift 1
    is dark and only the Hats are left to leave. The Answer Space step moved from 199 to 205.
  - 5: Clap Level (CC 9) moved from 65 to 68.
  - 6: Peak 1 at 153: only rhythm and bass (Kick, Clap, Percussion, Sub, Rumble, Bassline, Hats) plus Thin, Fog 0, Wumms
    0.95; Answer, Pads, Dark perc cut. No half-beat tail, no pattern, riser or fill on the bar. Then one at a time:
    Bassline Pattern 157 with Pads over 4, Clap Pattern 161 with Stab over 4, Sub Pattern 165 with Dark perc over 4.
    Peak 2 start (169): only the break and Double time; Stab out, bass pattern and Hats at 173, Sequence at 177, Answer
    at 181.
- Decision: again

## Lessons
