# Dance Floor

Design for `perform/002-groove/dance-floor.json`. Status: approved by the user on 2026-11-19 (Loop 1 / Round 2); rows updated in Loop 2 / Round 2 (hook as theme, more movement, Peak unchanged).

## Meta
- Track: 002-groove
- Length: 192 bars = 6 min 12 s at 124 BPM (1 bar = 1.94 s; bar N starts at (N-1) x 1.94 s)
- Mood: warm, rolling disco-house groove; sunny peak, long groove, no showing off
- Story: A DJ-friendly drum intro opens out of the fog, bass and snare lock the groove, the chords and the hook arrive.
  A first break (the part that worked in the sound tour: acid roll, fog sweep, Rhodes) drops back on the one with a new
  progression and the arp. A second, deeper break in the Italo chapter builds into the Sunrise peak with the organ stab.
  Then home to the boogie chapter and a long mix-out on drums.
- References: Sarah Wild, Fusion 2025 Bachstelzen opening (long steady grooves, piano-like chords, drops on the one);
  Vera, "Take Me To The Bridge" (octave bass, off-beat chords, strings)
- Why 192 bars: a club track of about 6 min in 16-bar blocks (12 of them); the FX riser falls on every 16th bar, so
  breaks end and drops start on those lines. Few stems change at a time; at most 11 stems play at once (Peak).

Rule from the sound-tour feedback: nothing dirty. Acid Squelch stays at or below 0.3 and only in Break 1; no
Ratchet, Stutter or Drive moves; Tension never above 0.8 and only in the builds.

## Sections
Bars are 1-based. Mode 1: Kick 1, Rumble 2, Bass 3, Acid 4, Snare 5, Hats 6, Percussion 7. Mode 2: Chords 1, Pad 2,
Arp 3, Hook 4, Strings 5, Organ Stab 6, FX 7. Global column 8: Fog, Thin, Tension, Master, Chapter, Break. Levels are
fader values. Pattern, Chords, Chapter and Break all switch at the next bar: the script presses half a bar early.

| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Intro | 1-16 | Master 0.85; Fog 0.45 -> 0 ramp 16; Kick Level 0.75, Ghosts 0.3; Hats Level 0.5 (Roll); Rumble Level 0.5 at 9; Percussion Level 0.35 at 13 (Congas); Hook Level 0.45 at 9 (hook 1, Vibrato 0.3) | - | Drums open out of the fog, the hook (theme) appears |
| Groove | 17-32 | Hook Level -> 0 ramp 4 at 17; Bass Level 0.55 at 17 (Octaves, Length 0.2); Snare Level 0.45 at 25 (Gated, Gate 0.3); Ghosts 0.3 -> 0.55 ramp 8 at 25; Bass Octave held 31-32; Kick Drop out held 32 | - | Space for bass and backbeat |
| Chords | 33-48 | Chords Level 0.5 at 33 (Off-beat), Length 0.3 -> 0.65 ramp 8 and back at 41, Brightness 0.3 -> 0.6 ramp 16; Rhythm Boogie and Chords i–ii from 41; Pad Level 0.35 at 41, Tension 0.2; Fog dip 0.35 at 47-48 | - | The harmony arrives and moves |
| Hook | 49-64 | Hook Level 0.5 at 49 (hook 1), hook 2 from 57; Tension 0.2 -> 0.7 ramp 8 at 57; Thin 0 -> 0.4 ramp 4 at 61; Snare Roll held 63-64; FX Level 0.5 at 57 (riser on bar 64) | pad Crash reverse at 64 | The theme returns, then the first lift |
| Break 1 | 65-80 | Break press (kick, rumble, bass out from 65); Thin 0; Tension -> 0.2 ramp 4; Hook Level -> 0 ramp 4; Fog 0 -> 0.5 ramp 2 at 65, back to 0 ramp 2 at 67; Acid Level 0.4 at 65 (Roll, Squelch 0.3); Strings Level 0.4 at 73 (Held); Thin 0 -> 0.5 ramp 4 at 77; Break press (all back on 81) | Rhodes chords Dm7, G7 (2 bars each) 65-80, on beat 1 and the "and" of 3; mod wheel 0.5, Brightness 0.6, Length 0.6, Piano -> Rhodes 0.66; pad Crash reverse at 80 | The break that worked: acid roll, fog, Rhodes |
| Drop 1 | 81-96 | Thin -> 0; Chords i–VII–VI and Rhythm Off-beat from 81; Acid Level -> 0 ramp 8; Arp Level 0.4 at 81 (Italo, Length 0.3); Strings Pattern Stabs at 89; Thin 0 -> 0.35 ramp 4 at 93; Kick Drop out held 96 | mod wheel -> 0 ramp 1 at 80; pad Orch hit on bar 81 beat 1 | Back on the one with a new progression and the arp |
| Groove 2 | 97-112 | Thin -> 0; Hats Disco, Percussion + Cowbell, Bass Boogie, Chords i–VI–VII at 97; Ghosts 0.55 -> 0.8 ramp 8; Arp Level -> 0.3, Arp Up at 105; Strings Level -> 0 ramp 8 at 105; Hats Open held 103-104; Snare Roll held 111-112; Chords back to i–ii in bar 112 | - | A busier groove with its own progression |
| Break 2 | 113-128 | Chapter: Italo (113); Break press (beat out from 113); Hook and Arp Level -> 0 ramp 4; Chords Rhythm Held at 113; Pad Level 0.55; Strings Level 0.4 (Held), Swipe 0.3; Tension 0.2 -> 0.8 ramp 8 at 121; Snare Roll held 127-128; Chapter: Sunrise and Break press (all back on 129) | Rhodes chords Dm7, Em7♭5 (2 bars each) 113-120; mod wheel 0.45; pad Crash reverse at 128 | A deeper, darker break that builds to the peak |
| Peak | 129-160 | Tension -> 0.15; Master 0.9; Chords Rhythm Off-beat at 129; Organ Stab Level 0.45 at 129 (Stab, Decay 0.2); Hook Level 0.5 (hook 3) at 129, hook 4 at 145; Rumble Roll at 129; Kick Skip at 137; Strings Pattern Octave at 145; Bass Gallop at 145; Chords: progression i–VI–VII from 145; Kick Drop out held 160 | mod wheel -> 0 at 128; pad Orch hit on bar 129 beat 1 | The Sunrise peak, the organ stab on top |
| Home | 161-176 | Chapter: Boogie (161); Kick 4/4 at 161; Organ Stab and Hook Level -> 0 ramp 8 at 161; Strings and Pad Level -> 0 ramp 8 at 169; Tension -> 0 | - | Back to the boogie colour, the top thins out |
| Outro | 177-192 | Hook Level 0.45 at 177 (hook 1, the theme once more); Chords Level -> 0 ramp 8 at 177; Bass and Snare Level -> 0 ramp 4 at 181; Rumble Level -> 0 ramp 4 at 185; Master 0.9 -> 0 ramp 12 at 181 | - | The theme once more, mix-out on drums |

## Risks
- CPU peak: Peak (129-160): 11 stems, with pad and strings both supersaw. Fallback: strings out in the Peak.
- Clipping: Peak with Master 0.9 and the organ stab on top of chords and hook. Levels stay at 0.35-0.55. The scenario
  table shows event gains only: listen.
- Silent stretches: none. Breaks remove kick, rumble and bass; hats, snare, percussion, chords and pad keep going.
- Dirt: the second half of the sound tour got dirty. Here acid only in Break 1 (Squelch 0.3), no Drive / Ratchet /
  Stutter, Tension only in two builds and only up to 0.8.

## Open questions
- Length: 6 min 12 s, or longer (about 8 min, a third groove block before the Peak)?
- Launchkey: Rhodes in both breaks, Orch hit on the two drops, Crash reverse into them. More, less?
- Chapters: Italo only for Break 2, Sunrise for the Peak, Boogie elsewhere. OK?
