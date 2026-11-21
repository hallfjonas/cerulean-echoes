# Sound Tour

Design for `perform/001-groove/sound-tour.json`. No earlier script for this track: written from the track's `@ctl` tags.
Status: approved by the user on 2026-11-19 (Loop 1 / Round 2).

## Meta
- Track: 001-groove
- Length: 176 bars = 5 min 41 s at 124 BPM (1 bar = 1.94 s)
- Mood: sunny disco groove that turns into a night-time rave and comes home
- Story: A tour through every sound, one column at a time, each building on the last so the groove grows instead of
  restarting. Every stem gets its own 8 or 16 bars: its patterns one after another, its row-3 character swept, its
  button-2 moment once. Then a break shows the rave side (acid, breakbeat), a drop brings the Italo and Rave chapters,
  everything plays together at the peak, and the track strips back down to kick and hats.
- References: Vera, "Take Me To The Bridge" (octave bass, off-beat chords, strings); Marie Montexier (Techno section of
  the listening list: acid and breakbeat energy in the break and the peak)

Why 176 bars: 14 stems at 8-16 bars each is about 140 bars of showing; a break, a peak and an outro make the tour
a song. Every section starts on an 8-bar line, where the chord progression starts again.

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Intro | 1-8 | Master 0.65; Kick Level 0.8, Punch 0 → 1 ramp 4 then 0.4; Hats Level 0.5, Brightness 0.2 → 0.8 ramp 8 | - | Beat at once, no bare-kick intro |
| Hats | 9-16 | Hats Pattern: Disco (9), Rave (13); Swing 0 → 0.6 ramp 4 at 9, back to 0.2 at 13; Open held 15-16; Pattern back to Off-beat at 17 | - | All three hat patterns, swing, long open hats |
| Snare | 17-24 | Snare Level 0.6; Gate 0 → 1 ramp 4, back to 0.4; Pattern: Snare + clap (21); Roll held 24 | - | The gated 80s snare, its tail, the clap, a roll into the bass |
| Bass | 25-40 | Bass Level 0.6; Octaves 25-32 with Length 0 → 0.8 ramp 4 and back; Boogie (33); Gallop (37); Brightness 0.3 → 0.7 ramp 8; Octave held 39-40 | - | Disco octave bass, its three lines |
| Chords | 41-56 | Chords Level 0.55; Rhythm: Off-beat (41), Boogie (49), Held (53); Length 0 → 0.7 ramp 4 at 45; Rhythm back to Off-beat and Chords: next progression (i–ii) from 57 | - | Juno chords on the off-beat, the rhythms, a new progression |
| Hook | 57-72 | Hook Level 0.6; hook 1 (57), hook 2 (65); Vibrato 0 → 0.8 ramp 4 at 61; Echo throw held 64 and 72 (rest bars) | - | The playful top line, with and without vibrato |
| Arp | 73-88 | Hook Level → 0 ramp 2; Arp Level 0.5; Up (73), Up-down (77), Octaves (81), Italo (85); Length 0 → 0.6 ramp 8; Octave held 87-88; Kick Drop out held 88 | - | Italo arpeggio, its four shapes |
| Strings | 89-104 | Arp Level → 0.3; Strings Level 0.5; Held (89), Stabs (97); Swipe 0.3 at 89 (every 4 bars), 0.8 at 97 (every 2 bars); Swipe held 104; Chords: next progression (i–VII–VI) from 97 | - | Disco strings held, stabbed and swiped |
| Break | 105-120 | Break press (kick and bass out from 105); Acid Level 0.55, Roll (105), Sparse (109), Climb (113), Squelch 0 → 1 ramp 8 at 105, Open held 111-112; Break Level 0.5 from 109, Two-step (109), Funk (113), Chop 0 → 0.7 ramp 4 at 113, Stutter held 116; Fog 0 → 0.6 → 0 at 105-108; Thin 0 → 0.7 ramp 2 at 119; Break press (all back on 121) | keys: Rhodes chords Dm7, Cmaj7, Bm7♭5, Cmaj7 (2 bars each, the progression in the Boogie chapter) at 105-120; mod wheel 0.5, Brightness 0.6, Length 0.6, Piano 0.66 | The rave side: acid and breakbeat, Rhodes over the top |
| Drop | 121-136 | Thin → 0; Chapter: Italo (121); Bass Gallop; Electro Level 0.5: Cowbell (121), Toms (125), Both (129), Complexity 0 → 0.8 ramp 4, Fill held 128; Pad Level 0.5, Tension 0 → 0.85 ramp 8 at 129 (pad in, snare roll), Pad Pattern 9 (125), Sus (129), Echo throw held 136; FX Level 0.6 (risers on 8-bar lines) | pad Orch hit on bar 121 beat 1 | Italo night: electro toms, the pad swelling, roll into the peak |
| Peak | 137-152 | Tension → 0.3; Chapter: Rave (137); Master 0.75; Rave Stab Level 0.5: Rave (137), Call (141), Off-beat (145), Drive 0 → 0.8 ramp 4, Ratchet held 144; Hook Level 0.5, hook 3 (137), hook 4 (145); Kick Skip (137), Half (151); FX Complexity 0.8, Riser held 149-152 | pad Orch hit on bar 137 beat 1 | Everything at once in the rave chapter |
| Outro | 153-176 | Chapter: Boogie (153); Kick 4/4 (153); colour out first: Rave, Hook, Arp, Strings, Pad, FX, Chords Level → 0 ramp 8 at 153; then Acid, Break, Electro, Snare, Bass → 0 ramp 8 at 161; Master 0.75 → 0 ramp 12 at 165 | - | Home to the boogie chapter, strip to kick and hats, fade |

Not shown on purpose: the Fog / Thin knobs beyond one sweep each; Pad Movement and the Brightness / Space knobs of
most stems stay at their 0 sound (a tour of 14 stems has no room for every knob).

## Risks
- CPU peak: Peak (137-152): all 14 stems, pad and strings both supersaw. Watch for drop-outs in the player on the M2 Air.
- Clipping: Peak with Master 0.75 and every stem around 0.5. The scenario table shows event gains only; listen.
- Silent stretches: none. The Break removes kick and bass, not the groove (snare, hats, chords, acid, break stay).

## Open questions
- Length: 5 min 41 s. Shorter (drop the Hook or Arp section to 8 bars) or longer?
- Launchkey: Rhodes chords in the Break and the Orch hit on the two drops. More pads (Low tom, Open hat fills)?
- Chapters only in the second half (Italo at the Drop, Rave at the Peak, back to Boogie at the Outro). Show them earlier?
- Section names are working titles; rename any.
