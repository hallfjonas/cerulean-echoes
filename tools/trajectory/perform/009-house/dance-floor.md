# Dance Floor

Design for `perform/009-house/dance-floor.json`. Status: proposal, waiting for the user's approval (Loop 1 / Round 1).

## Meta
- Track: 009-house
- Length: 192 bars = 6 min 12 s at 124 BPM (`setcpm(31)`: 1 bar = 1 cycle = 1.94 s; bar N starts at (N-1) x 1.94 s)
- Mood: happy, jazzy, dry, steady groove with a warm top
- Story: A lone kick, then hats and clap, then sub and bass: the floor fills layer by layer. The keys come in by hand
  from the Launchkey, a build runs into a break, and the whole beat lands on the one with the chord progression
  (first drop). A busier groove with flute and vibraphone leads to a second, deeper break in Vamp, then the peak with
  everything on. The colour leaves first, the bass goes next, the master fades the kick out.
- References (docs/reference/listening-list.md): Sarah Wild, Fusion 2025 Bachstelzen opening (the user's main reference: long steady
  grooves, piano chords, bass groove, playful top voice); Zombies in Miami, Nation of Gondwana 2023 (patient builds,
  drops that return on the one)
- Why 192 bars: house is played in 8-bar phrases (the Chords button changes at 8 bars, Chapter at 4), and a club
  track runs 6-8 min. 192 = 24 phrases, long enough for two breaks and a peak, short enough to review in one sitting.
  Section lengths are multiples of 4 (Build and Break 1 are 12).

## Sections
Bars are 1-based. Mode 2 columns: Harmony 1, Keys 2, Vibraphone 3, Flute 4, Brass 5, Strings 6, Guitar 7 (CC = Mode 1
CC + 48). Mode 1 columns: Kick 1, Noise Pump 2, Sub 3, Bass 4, Clap 5, Hats / Shaker 6, Congas 7. Global column 8:
Fog (CC 20), Thin (28), Tension (36), Master (12), Chapter (button, 44), Break (button, 52). Levels are fader values.
Chapter switches at the next 4-bar phrase, Chords (Harmony button 1) at the next 8 bars, Pattern buttons at the next
bar: the script presses one bar early where the change must land on a boundary.

| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Beat | 1-16 | Master 0.8 at 1; Kick Level 0.7 at 1; Hats Level 0.6 at 9; Clap Level 0.5 at 13 | - | Kick alone, then hats and clap |
| Bass | 17-32 | Sub Level 0.6 at 17; Bass Level 0.6 at 25; Noise Pump Level 0.4 at 29; Kick Pattern press at 29 | - | Low end joins the floor |
| Keys | 33-48 | Keys Level 0.6 at 33; Keys Brightness 0.3 -> 0.6 ramp 16; Harmony Level 0.4 at 41 (Mode 2) | mod wheel 0.7 and knob 2 (Piano -> Rhodes) 0.4 at 33; keys Am9 stabs (c4 e4 g4 b4) at 43.5, 45.5, 47.5 | First Launchkey keys over the groove |
| Build | 49-60 | Tension 0 -> 0.9 ramp 12; Thin 0 -> 0.5 ramp 8 from 53; Clap Pattern press at 49 | keys Am9 chord, length 2, at 49 and 53; pads Snare (51) on 59, 59.5, 60, 60.5; Crash reverse (49) at 59 | Lift into the break |
| Break 1 | 61-72 | Break press at 61; Tension 0.9 -> 0 ramp 8 from 65; Thin back to 0 at 69; Chapter press at 71; Break press at 72 (all back on 73) | keys Am9 chord, length 4, at 61 and 65; knob 7 (Echo) 0.6 at 61; pad Evening (39) at 63; Voice ooh (48) at 69 | Beat out, chords float, everything returns on the one |
| Drop 1 | 73-96 | Harmony Level 0.5 at 73; Vibraphone Level 0.5 at 81; Harmony Chords press at 88 (new progression at 89) | knob 7 Echo 0.2 at 73; keys Am9 / D9 stabs at 77.5, 85.5, 93.5 (two bars of Am9 chord, then D9) | Progression arrives, keys answer the chords |
| Groove | 97-128 | Hats Pattern press at 97; Congas Level 0.5 at 97; Bass Pattern press at 105; Clap Complexity 0.5 at 113; Flute Level 0.4 at 113; Harmony Chords press at 120 | pads Rim echo (46) on 117, 121, 125; keys Rhodes stabs (knob 2 -> 0.8 at 105) at 109.5, 125.5 | Busier rhythm, playful top voice |
| Break 2 | 129-144 | Chapter press at 125 (back to Vamp); Break press at 129; Fog 0 -> 0.6 ramp 4 at 129, back to 0 ramp 4 at 137; Tension 0 -> 0.9 ramp 8 from 137; Chapter press at 141; Break press at 144 | keys Am9 chord, length 4, at 129 and 133; pad Vast (43) at 131; knob 7 Echo 0.7 at 129; knob 8 (Pad Fog) 0.5 at 129 | Deeper break in Vamp, build back up |
| Peak | 145-176 | Tension 0 at 145; Harmony Level 0.5; Brass Level 0.4 at 153; Harmony Chords press at 152; Strings Level 0.4 at 161; Brass Lift press at 169 | knob 7 Echo 0.2 at 145; keys D9 / Am9 stabs every 8 bars from 149.5; pads Clap (44) on 161, 165, 169, 173; Open hat (45) at 175.5 | Everything on, one more progression |
| Outro | 177-192 | Brass, Strings, Flute, Vibraphone Level 0 at 177 (one by one); Keys, Harmony Level 0 at 181; Sub and Bass Level 0 at 185; Master 0.8 -> 0 ramp 8 from 185 | mod wheel 0.7 -> 0 ramp 4 from 181 | Colour leaves, bass leaves, kick fades out |

## Risks
- CPU peak: Peak (145-176): rhythm, Harmony, Keys, Vibraphone, Flute, Brass, Strings and Launchkey keys at once. Check
  in the player on the M2 Air. Fallback: drop Strings from Peak. Groove (97-128) has four colour stems and is the
  second densest.
- Clipping: Drop 1 and Peak. The track notes say kick + keys together at fader 1 peak at 1.16, so Levels stay at 0.4-0.7
  and the Launchkey keys (mod wheel 0.7) sit on top. Measure per section with `npm run scenario` and
  `npm run audibility`; lower Keys Level first if a section clips.
- Silent stretches: none planned. Breaks remove kick, pump, sub and bass but keep clap, hats, congas, Harmony and Keys.
  Bars 1-8 are kick only (sparse, intended).
- Launchkey: keys or pads at bar 0 are dropped, so the first key is at bar 33 (step bar 32). Keys are silent while the
  mod wheel (CC 1) is 0: it is set to 0.7 at bar 33, before the first note. Pads ignore knobs 1-7 (only knob 8,
  Pad Fog); `midikeys` has no note-off, so the notes sound as long as Length (knob 5) says; the step `length` only moves
  the note-off in the LC view. Voice pads run 4.5-14.6 s: Vast at 131 lasts until about bar 138.
- Timing: the Pattern, Chords and Chapter changes happen at their boundary, not at the press. A press one bar late
  moves a change by a whole phrase.

## Open questions
- Length: 6 min 12 s (192 bars) as a club-track length, or shorter (about 4 min, like 010) or longer (about 8 min,
  256 bars, third break)?
- Launchkey: hand-played-style stabs and chords over the groove (as above), plus pad hits in the builds. Too much, or
  should the keys only play in the two breaks? The spoken-voice pads (Evening, Vast, Voice ooh) in the breaks: wanted?
- Peak colour: Brass, Strings and Flute are untested in house (the keys lab favours piano; flute and vibraphone were
  the playful voices). Keep Brass and Strings in the Peak, or use only Harmony, Keys, Vibraphone and Flute?
