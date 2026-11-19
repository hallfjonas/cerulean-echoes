# 001-groove performance - feedback

## Loop 1 / Round 1 - sound-tour.md (2026-11-19)
- User: "Create an auto performance for this one. It should be fun to listen to but highest priority is getting to
  know the sounds."
- Changed: first design proposed (176 bars, a tour of every stem, break, drop, peak, outro).
- Decision: again

## Loop 1 / Round 2 - sound-tour.md (2026-11-19)
- User: "Approved"
- Changed: nothing; open questions resolved to the design's defaults (176 bars, Rhodes in the Break and Orch hit on
  the two drops, chapters from the Drop on, section names as proposed).
- Decision: approved
- Approval: Design approved by the user on 2026-11-19 ("Approved").

## Loop 2 / Round 1 - sound-tour.json (2026-11-19)
- Scripted from the approved design: 148 steps, 12 sections, pattern presses half a bar before their line.
  One addition: the chord Rhythm goes back to Off-beat at bar 57 (the design left it on Held for the rest of the track).
- Checks: check-perform ok, verify ok, scenario: no silent section, 15 stems heard at the Peak. Not measured:
  rendered loudness, clipping, CPU.
- User: "Approved"
- Changed: nothing.
- Decision: approved
- Approval: Performance approved by the user on 2026-11-19 ("Approved"). Not measured: clipping, CPU peak.

## Lessons
- A "sound tour" (one column per section, each stem's patterns, row-3 sweep and button-2 moment) passed both loops in
  one round each when the stems pile up instead of restarting.
- This track's Chapter and Break switch at the next bar (barLatch(1)), not the next phrase: press half a bar early.
- check-perform's argument is a track file path; with no argument it checks every script (the id alone fails).
- A held button is two cc steps (1, then 0); a pattern press is a press step half a bar before the line.
