# 009 house performance - feedback

## Loop 1 / Round 1 - dance-floor.md (2026-11-16)
- User: "008 and 009 sound good"
- Changed: nothing; design kept as proposed. The user's words covered 008 and 009 together; the open questions are
  resolved to the proposed defaults (192 bars, Launchkey stabs, chords and pads and the voice pads in the breaks,
  Brass and Strings in Peak with Strings as the CPU fallback).
- Decision: approved
- Approval: Design approved by the user on 2026-11-16 ("008 and 009 sound good"; given for 008 and 009 together).

## Loop 2 / Round 1 - dance-floor.json (2026-11-16)
- User: "I personally don't have control over the Launchkey (neither keys nor pads); autoperform does use them; some
  are not working" / "The drum pads are used mostly weirdly by the autoperfomer"
- Changed: dance-floor.json only. Pads redone on the beat grid: snare rolls at the end of Build and Break 2, short
  snare fills (3 hits) in the last bar of a phrase, crash reverse before each drop, open hat off-beats in 2 bars of
  Groove and Peak, rim echo twice in Groove; voice pads (Evening, Voice ooh, Vast) only in the breaks; pad Clap
  removed (the Clap stem plays 2 and 4). Launchkey knobs fixed: Brightness (31) set (untouched it was 0 = 250 Hz
  low-pass, muffled keys), Length (35) short in grooves and long in breaks (untouched, chords never held), Piano ->
  Rhodes 0.8 -> 0.667 (0.8 is in the fade-out third, 10 dB quieter). The user's own Launchkey not controlling the track
  is an engine matter (handled separately).
- Decision: again

## Loop 2 / Round 2 - dance-floor.json (2026-11-16)
- User: "Listen in the player: 007, 008, 009, and 010 after the timing fix --> ALL PERFECT NOW; Timing fix not needed"
- Changed: nothing. The user also reports: real Launchkey while the script plays "WORKS AS WELL! Only knobs broken".
- Decision: approved
- Approval: Performance approved by the user on 2026-11-16 ("ALL PERFECT NOW").
