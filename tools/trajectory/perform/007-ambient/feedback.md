# 007 ambient performance - feedback

## Loop 1 / Round 1 - drift.md (2026-11-16)
- User: "david's voice should be in there at the beginning at at the end" / "match the duration of the track with
  david's voice snippet"
- Changed: length 175 -> 160 bars (9 min 9 s, matches the 9 min 13 s recording of 161.3 bars). Voice stem
  (Mode 2 column 7) added at bars 1-16 and 145-160 (the recording follows the clock, so the opening and the closing
  minute are heard); Voice section "How the voice plays" and risks added; sections re-cut to multiples of 4; the
  Evening pad one-shot dropped so David stays the only spoken voice. Interpretation of "match the duration" put to the
  user as an open question.
- Decision: again

## Loop 1 / Round 2 - drift.md (2026-11-16)
- User: "Sounds good for 007, but let david's Text shimmer through one more time during the track at an appropriate
  time"
- Changed: one more brief voice pass in the Break, bars 81-87 (recording 4:34-4:58): Voice Level 0 -> 0.35, Space 0.9,
  out again over 3 bars. Open questions 1-5 resolved to the proposed defaults (160 bars, Launchkey keys and pads kept,
  end on floating). Script `drift.json` written from the design.
- Decision: approved
- Approval: Design approved by the user on 2026-11-16 ("Sounds good for 007, but let david's Text shimmer through one
  more time during the track at an appropriate time"). Approval with one amendment, applied in drift.md.

## Loop 2 / Round 1 - drift.json (2026-11-16)
- User: "There is too long of a gap between the voice ending and the music starting. The music should already slowly
  fade in as he speaks. Same in outro. Otherwise excellent"
- Changed: Intro: Pad (CC 53) 0 -> 0.6 ramp 16 from bar 5 and Drone (CC 7) 0 -> 0.3 ramp 16 from bar 9 (were bar 17,
  ramp 8), so they grow under David; Sea / Wind (CC 6) 0.4 over 10 bars (was 0.3 over 8). Outro: Sea / Wind 0.4 and
  Pad 0.7 ramp 8 at bar 137 keep a bed; Shaker / Rim ramp 6 at 137, Pulse / Bass ramp 6 at 141 (were 4); Voice
  (CC 59) enters at 141 over 6 bars (was 145 over 2) and Choir / Glitter go out at 143 over 6 (were 145 over 4).
  Scenario: pad and drone sound in bars 1-8 already; bars 145-160 keep sawtooth, sine, triangle and brown noise.
- Decision: again
