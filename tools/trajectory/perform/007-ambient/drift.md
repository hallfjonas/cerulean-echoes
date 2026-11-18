# Drift

Design for `perform/007-ambient/drift.json`. Status: approved by the user with one amendment (Loop 1 / Round 2): David's voice shimmers through once
mid-track (bars 81-87). Open questions resolved to the proposed defaults. Not scripted yet. The scenario view was not run (no `node_modules` in this worktree); the plan
rests on the `@ctl` tags and the track code.

## Meta
- Track: 007-ambient
- Length: 160 bars = 9 min 9 s (548.6 s) at 70 BPM (`setcpm(70 / 4)`, 1 bar = 1 cycle = 3.43 s)
- Voice: `samples/voice/david.mp3` is 552.9 s (9 min 13 s) = 161.3 bars. The performance is 160 bars, so it spans the
  whole recording (4 s short at the very end).
- Mid-track voice: bars 81-87 in the Break, recording 4:34-4:58 (bar x 3.43 s), a low pass (Level 0.35, Space 0.9)
  that drifts in and out over the keys and the drone.
- Mood: slow, dreamy, spacious, a little strange in the middle
- Story: David's voice opens the piece over fading-in sea and wind, then steps back as a pad and drone grow. Pulse and
  bass, colour and small percussion follow. A break leaves the keys alone over the drone. The peak turns the key colour
  twice and builds tension. It calms back to floating, thins out, and David's voice returns for the last minute while
  the master fades.
- References: no ambient-genre links in `docs/reference/listening-list.md` yet. Closest: Kiasmos live on KEXP (long, slow build, calm
  dynamics); the track's own `feedback.md` favourites (shimmer, choir, glitter, pad) lead the colour parts.

## How the voice plays
The Voice stem (Mode 2 column 7) is not triggered by a pad or a key. The recording runs with the clock: the place in it
is bar x 3.43 s, like a radio left on. The Voice fader (CC 59) only brings it in where it is now. So with Play at bar 1:
- Bars 1-16 (0:00-0:55 of the recording): the opening, heard at the beginning.
- Bars 17-80 and 88-144: fader at 0, the recording runs unheard.
- Bars 81-87 (4:34-4:58 of the recording): one brief shimmer through the Break, see the table.
- Bars 145-160 (8:17-9:09 of the recording): the closing minute, heard at the end.
This is one continuous recording heard in three places, not separate files. Voice settings: Distortion (CC 83) 0.3
(radio), Space (CC 75) 0.5, Brightness (CC 67) 0.5. Tension does not touch the voice; Fog darkens it.
Needs Play to start the performance at bar 1 (bar 0 of the player's clock); a restart mid-way shifts what is heard.

## Sections
Bars are 1-based. CCs: Mode 1 fader CC 5-11, Mode 2 = +48 (Pad 53, Eno / Shimmer 54, Marimba 55, Toms 56, Choir 57,
Glitter 58, Voice 59); column 8 global: Master 12, Fog 20, Room 28, Tension 36, Chapter 44, Break 52.

| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Voice in | 1-16 | Master 0 -> 0.8 ramp 8; Voice Level 0 -> 0.5 ramp 2 at 1, Distortion 0.3, Space 0.5; Sea / Wind Level 0 -> 0.4 ramp 10, Space 0.6; Pad Level 0 -> 0.6 ramp 16 at 5; Drone Level 0 -> 0.3 ramp 16 at 9; Voice Level 0 ramp 4 at 13 | - | David opens over waves, pad and drone already fading in under him |
| Pad | 17-28 | Pad and Drone keep growing (set in Voice in; Pad Space 0.5) | - | Chords and low fifths grow |
| Heartbeat | 29-40 | Pulse Level 0 -> 0.35 ramp 4 (Punch 0); Bass Level 0 -> 0.3 ramp 4; Drone Pattern press at 33 | - | The floor arrives, soft |
| Colour | 41-60 | Eno / Shimmer Level 0 -> 0.5 ramp 4, Layer press at 41; Choir Level 0.4 at 49; Glitter Level 0.3 at 53, Complexity 0.2 | - | Bowed shimmer, choir, first sparkles |
| Motion | 61-76 | Rim Level 0.3 at 61; Shaker Level 0.3 at 65; Marimba Level 0.4 at 69, Complexity 0.3; Chapter press at 69 (melancholic) | - | Small percussion, darker colour |
| Break | 77-92 | Break press at 77; Fog 0 -> 0.5 ramp 4; Sea / Wind Level 0.4 ramp 4; Voice Level 0 -> 0.35 ramp 4 at 81, Space 0.9, Level 0 ramp 3 at 85, Space 0.5 at 88; Break press at 89 (back on the one); Fog 0.5 -> 0 ramp 2 at 89 | keys d3 a3 e4 at 79, f#3 a3 c#4 at 85; mod wheel 0 -> 0.6 ramp 2 at 77 | Beat out, keys over the drone, David shimmers through, return |
| Peak | 93-120 | Tension 0 -> 0.7 ramp 24; Toms Level 0.5 at 97; Choir Complexity 0.5; Glitter Complexity 0.6 at 101; Chapter press at 109 (strange); Pad Brightness 0.7 | pad Glockenspiel (44) at 101 and 113; keys b2 d3 a3 at 105 | Fullest, strangest, builds |
| Release | 121-136 | Tension 0.7 -> 0 ramp 8; Chapter press at 121 (floating); Toms Level 0 ramp 4 at 125; Marimba Level 0 ramp 4 at 129; Glitter Complexity 0.2 | pad Wind (48) at 129; LK knob 8 (CC 38) 0 -> 0.4 ramp 8 | Calm down, back to floating |
| Voice out | 137-160 | Sea / Wind Level 0.4 and Pad Level 0.7 ramp 8 at 137 (the bed stays); Shaker, Rim Level 0 ramp 6 at 137; Pulse, Bass Level 0 ramp 6 at 141; Voice Level 0 -> 0.5 ramp 6 at 141, Distortion 0.3; Choir, Glitter Level 0 ramp 6 at 143; Fog 0 -> 0.4 ramp 12 at 145; Master 0.8 -> 0 ramp 8 at 153 | mod wheel 0 ramp 4 at 141 | Thin out, David closes, fade |

## Risks
- CPU peak: Peak (93-120): 12+ stems (Jojo beat stems, pad, bowed, marimba, toms, choir, glitter, keys) plus Tension
  echo and reverb. Check in the player on the M2 Air; toms and marimba carry the most events. The voice plays beat by
  beat slices: it is only queried while its fader is up.
- Clipping: Peak (all Levels up, Tension 0.7, keys and pads on top) and the Break return at 89 (beat back at once).
  The voice is +6 dB already (fader range 0-2): check 0.5 against the drone and sea at bars 1-16. Measure per section
  with `npm run audibility` once scripted. Drone and Bass stay at or below 0.3 (heavy in the lows per feedback).
- Silent stretches: bars 1-2 are quiet while the master fades in (intended). Bars 17-28 hold the pad, drone and sea.
  The Break keeps drone, sea and Jonas' colour, so it is not silent.
- Voice timing: the recording opens and closes with whatever David says there; content at bars 1-16 and 145-160 was
  not listened to. The recording's last 4 s are not heard.

## Open questions
Resolved by the user's approval to the proposed defaults: 160 bars, Launchkey keys and pads kept, ending on floating.
