# 010 ambient house performance - feedback

## Loop 1 / Round 1 - journey.md (2026-11-16)
- User: "Approved"
- Changed: nothing; design kept as proposed (130 bars, controller-only, section names as proposed).
- Decision: approved
- Approval: Design approved by the user on 2026-11-16 ("Approved").

## Loop 2 / Round 1 - journey.json (2026-11-16)
- User: "It is def way longer than 4min 20s. Your math must be off here." / "It works well for a smooth background
  journey track" / "Human take-over works as well"
- Changed: nothing yet. Open: the length. By the track (setcpm(30), 1 bar = 1 cycle = 2 s) 130 bars = 260 s; to be
  measured against a stopwatch in the user's player.
- Decision: again

## Loop 2 / Round 2 - journey.json (2026-11-16)
- User: "Roughly 32 -- actually seems to check out. Now move on."
- Changed: nothing. Stopwatch check: bar 32 at 60 s, so 1 bar = 2 s and 130 bars = 4 min 20 s as designed.
- Decision: approved
- Approval: Performance taken as approved by the user on 2026-11-16 ("Now move on"; after "It works well for a smooth
  background journey track", "Human take-over works as well"). Not measured: clipping (`npm run audibility`), CPU peak.

## Lessons
- Starting from an existing spike script (`spike-run.json`) made the design a one-round loop: describe the moves in
  sections, keep the steps.
- Write the length in minutes in the design and check it once with a stopwatch against the top bar (1 bar = 2 s at
  120 BPM); a doubt about length costs a round.
- Section bars are 0-based `[from, to)`; the design table is 1-based. Convert once, then check every step lands in
  its section (`check-perform`).
- `npm run scenario` and `npm run verify` take the track file path, `check-perform` the track id.
- The built-in browser pane cannot play (no Web MIDI, Play hangs): the user listens in Chrome. Start the player from
  the working tree on its own port (`node trajectory/server.mjs 8767`) when the main checkout's server is running.
- The controller-only performance was accepted without Launchkey steps; keys and pads stay untested in a real run.
