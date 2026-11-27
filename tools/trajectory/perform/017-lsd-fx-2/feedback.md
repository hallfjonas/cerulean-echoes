# 017 LSD FX 2 performance - feedback

## Loop 1 / Round 1 - meta-story.md (2026-11-26)
- User: "my latest take it is. follow that pattern. pitch it if you like" (the melody of the keys section; the take is
  `takes/2026-11-26-213155-human`).
- Changed: the Melody section lists the 14 bars of the take (three notes per bar, order as played; the time inside a
  bar was not recorded, so the cells play in a 3-3-2 pulse); the melody runs 16 bars, so Keys is 65-80 and every later
  section moves 8 bars (144 bars = 4 min 18 s).
- Decision: again (the design is not approved yet)

## Loop 1 / Round 2 - meta-story.md (2026-11-26)
- User: "Approved"
- Changed: nothing; the open questions resolve to the design's defaults (Final drop without chords and pads, 144 bars,
  no congas in Down, melody in a 3-3-2 pulse with the second statement's last 8 bars an octave up).
- Decision: approved
- Approval: Design approved by the user on 2026-11-26 ("Approved").

## Loop 1 / Round 1 - metal-mix.md (2026-11-26)
- User: "Create a new performance being a strong mix between the latest auto performance and the latest human
  performances. Human performed better: the LK keys performance (provided as a separate clean recording); DOES NOT USE
  THE DRUM PADS!; build up is better (simpler, no tension knob). Auto performed better: kick, sub sub bass handling; the
  percussion and groove is a tie, leaning towards auto performance; drop is better (cleaner, accomplishing)"
- Changed: new design `metal-mix.md` from `meta-story.md`: melody from the clean keys take `takes/2026-11-26-220344-human`
  with the timing read from its recording (dotted-eighth arpeggio from beat 2) and its sound (Metal Brightness 0,
  Space 0, Weight 0.6); no drum pads; Build and Rebuild without Tension and Thin; kick, sub, bass, percussion, groove
  and both drops as in Metal Story.
- Decision: again (the design is not approved yet)

## Loop 1 / Round 2 - metal-mix.md (2026-11-26)
- User: "I don't like how tension sounds here. Don't use more than 10% ever, only towards peak, not downwards."
- Changed: Tension rises only: 0 -> 0.05 over Build 33-40 (first peak), stays 0.05 through Drop, Strip, Down, Keys;
  0.05 -> 0.1 over Rebuild 89-96 (final peak), stays 0.1 to the end. Never above 0.1, never down. The open question on
  Tension is closed.
- Decision: again

## Loop 1 / Round 3 - metal-mix.md (2026-11-26)
- User: "The expected duration of the track should be around 7 minutes"
- Changed: 144 -> 232 bars (6 min 55 s). The story's opening keeps its bars (Foundation, Metal, Hats, Congas: 4 each).
  New: Groove 17-32 (the metal over the full groove). Longer: Chords 16, Drop 32, Strip 8, Down 8, Rebuild 32 (the
  melody twice more), Final drop 32, Fade 24. Tension keeps its rule (0.05 into the first peak, 0.1 into the final one).
- Decision: again

## Loop 1 / Round 4 - metal-mix.md (2026-11-26)
- User: "Approved"
- Changed: nothing; the open questions resolve to the design's defaults (the build as designed, keys mod wheel 0.6,
  cells from beat 2 with notes 3 sixteenths apart).
- Decision: approved
- Approval: Design approved by the user on 2026-11-26 ("Approved").

## Loop 2 / Round 1 - metal-mix.json (2026-11-26)
- User: "Very nie! feedback metal-mix: down -> keys (here also briefly kick and sub out / or thin); final drop -> don't
  actually trow everything in. only: all kick subs bass groovey percussions (claps quieter) PLUS metal radio accents and
  risers all on full and played with; end is prime"
- Mapping (1-based): "down -> keys" = bars 112-113 (the last bar of Down, the first keys cell); "final drop" = Final
  drop 165-196; "end" = Last and The end 221-232.
- Changed: Kick, Rumble (the kick in its reverb) and Sub Level 0 at 112, back at 114 (a cut, not Thin; set a tenth of
  a bar early so the first kick of 112 does not slip through). Final drop: Kick, Rumble, Sub, Bass, Hats,
  Congas, Claps 0.3 (was 0.5), Metal, Radio, Accents, Risers at Level 1 from 165 (Radio and Risers were 0.4 from 181,
  Accents 0.4, Metal 0.6); played with: Accents Burst (CC 98) and Rate (CC 82), Radio Tune (CC 97) and Static (CC 81),
  Metal Rewind (CC 96), Pattern (CC 88) and Weight (CC 80), Risers Riser (CC 99), see the design row. End unchanged.
- Decision: again

## Loop 2 / Round 2 - metal-mix.json (2026-11-26)
- User: "also let me play the LK keys performance my self while playing the auto performance (keep them but turn their
  volume to 0 / comment them out)."
- Changed: every scripted keys step (Keys 113-128, Rebuild 129-160, Keys alone 161-164) stays, at velocity 0.01 (MIDI
  1). A script cannot hold comments or velocity 0 (check-perform refuses unknown fields; sc-auto sends at least 1).
  The mod wheel steps stay so the user's keys sound.
- Decision: again

## Loop 1 / Round 1 - metal-space.md (2026-11-27)
- User: "The LKs are played by human -- don't auto-perform it." Notes on Metal Mix:
  - "increase variability of percussion elements (congas, hats, clap); let their levels slowly drift up and down over
    time, giving each other a bit space here and there; this should be noticable to the active listener but not really
    to the passive listener"
  - "end is taken down well, especially the radio is nice; but the melody at the end is cringe (the four gongs+metal or
    whatever it is)"
  - "generally a tad overloaded throughout the song (too much going on)"
  - "there is a looong phase with focus on chords (stop where clap comes in) --> this should be reduced; instead, give
    the fx more space; this offers an oppertunity to avoid overloading them too much (spread their appearance out more)"
  - "change of chords via btn1 shuold not happen while it is playing; change it while it is not playing, so that it
    will be slightly different the next time it comes back; same for lead; choose pads to fit the chords / lead resp."
  - "the hats and congas should enter more smoothly; I'm thinking a 1-bar break in which some metal sounds still play
    after that break have the hats enter at a solid level; --> same for the congas coming in during/after the keys
    focused part (maybe a 2-bar break)"
  - "clap is too present in section around chords / lead"
- Mapping (Metal Mix bars, 1-based): the melody at the end = Last 221-228 (Metal 0.7 with Rewind held 225-228, the
  figure every bar); the chord phase = Chords 33-48 and Build 49-56 (clap at 57); the hats entry = 9-12; the congas
  after the keys = Rebuild 133; the clap around chords and leads = Build, Drop 65-96 (Claps 0.5).
- Changed: new design `metal-space.md` from `metal-mix.md`. No Launchkey steps at all. Chord phase 24 -> 8 bars
  (33-40), the stab returns at 81-88 with Stab 2, pressed while silent at 44; leads Duo pressed while silent at 70;
  pads get a move per partner (Sink, Line up, Line down), pressed while silent. The fx take turns (table "Where the fx
  play"); only the Final drop has all four, two at 157 and two at 165. Hats land at a solid 0.45 after a 1-bar break
  (bar 8, the metal's Rewind alone); congas in the Rebuild land at 127 after a 2-bar break (125-126). Percussion drift
  (levels, Complexity, 2-bar rests) from 17 to 188. Claps 0.2-0.3 (were 0.5). No Metal Rewind in Groove; the end is
  the radio alone. 232 -> 224 bars (6 min 41 s).
- Decision: again (the design is not approved yet)

## Loop 1 / Round 2 - metal-space.md (2026-11-27)
- User: "Approved"
- Changed: nothing; the open questions resolve to the design's defaults (Final drop: the four fx at Level 1, as written;
  hats in the 2-bar break out, as written; leads once; the end is the radio alone, no metal hit at 213).
- Decision: approved
- Approval: Design approved by the user on 2026-11-27 ("Approved").

## Loop 2 / Round 1 - metal-space.json (2026-11-27)
- Script written from the approved design: 329 steps, 224 bars. Checks: check-perform ok, verify-sc ok (load, 5 checks).
- Not checked by any tool: levels, clipping, CPU, and how the drift sounds. Only the listen decides.
- Launchkey: no steps (keys by hand). Mod wheel is the user's: up in Down (about bar 97), down at the Final drop (bar 157).
- Assumptions to confirm by ear: pattern presses assume the default is the first pattern (Pads Lift, Leads Loop, Chords
  Stab 1); "held" button steps are a press on each bar of the hold; Hats at 0.5 in the Final drop (the design said
  "Groove" without a level); Metal space and brightness reset to 0.6 / 0.5 at 157 after the keys' 0.9.
- Decision: pending (listen in the player)
