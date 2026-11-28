# Plan: human takes in the Tracks lab

A human take (a set played on the controllers and recorded) should hold what was played, and the Tracks lab should
turn it into a performance to edit. Two parts, one PR: capture (the take has steps) and draft (the lab makes moves of
them). Builds on the Tracks lab ([tracks-lab.md](../../features/tracks-lab.md)).

## Why takes are empty today
A take is built from the page's Web MIDI messages only (`tools/trajectory/take.mjs` `createRecorder`, fed by
`midi.onMessage`). The `Cerulean Echoes.app` window (WKWebView) and the built-in browser pane have no Web MIDI, so a
take recorded there has `steps: []`, `bars: 1` and `take.inputs: []`. Its `.events.jsonl` still holds SC's state per
bar (sc-auto.mjs `createScTap`).

SC already echoes every CC it applies, buttons included: `sc/lib/controls.scd` `setCC` sends `/ce/cc`, which
`sc-link.mjs` passes to the page as the SSE event `cc` (batches of 25 ms); the Launchkey comes as `lkcc` and
`lknote`. These echoes reach `player.html` through `createScEngine({ onEvent })`, today only into the SC tap.

## Part 1: capture from SC's echo

1. `take.mjs`: `createRecorder` gets a second input, `echo(type, data)`, which turns SC's echoes into the same
   messages `{ port, status, data, time, bar }` the conversion reads today:
   - `cc` `{ <cc>: value }` → control change on channel 16, port `LCXL3 Echo`, value × 127 rounded;
   - `lkcc [cc, value]` → control change, port `Launchkey MK4 25 Echo`;
   - `lknote [note, velocity, channel]` → note on / note off (velocity 0), same port.
   The `Echo` ports count as human ports in `sourceOf`.
2. Which input counts: when Web MIDI has at least one input (`midi.count() > 0`), the echo is ignored (Web MIDI has
   the exact timing, no doubles). Otherwise the echo is the take's input. `take.inputs` lists the echo ports then.
3. The script's own sends: during auto-perform, SC echoes what `scAuto` sent too. `createScAuto` already emits each
   sent message to its listeners (port `LCXL3 Auto` / `Launchkey MK4 25 Auto`); the recorder drops an echo whose
   CC and value match a message `scAuto` sent within the last 60 ms. A take of a script with no hands stays `auto`,
   with hands `mixed`.
4. Aliases: SC echoes Mode 2 global CCs as their Mode 1 alias (`ccAlias`). The conversion keeps the CC as echoed;
   both are the same control for `check-perform`.
5. `bars` of a take = the bars the play lasted (last event cycle + 1), not the end of the last step.
6. `player.html`: `onEvent` passes `cc`, `lkcc`, `lknote` to `recorder.echo` as well as to `scTap`.

Timing: an echo arrives up to 25 ms (the SSE batch) plus the OSC hop late. At 120 BPM a bar is 2 s, so the error
is under 1/64 bar; `check-replay` tolerances stay as they are, and a test states the bound.

### Rescue for takes recorded before this (optional)
`node trajectory/take-from-events.mjs <track> takes/<name>`: rebuilds steps from the `.events.jsonl` (per-bar CC
values in steps of 4 → a step per change, pattern and Chapter changes → presses one bar before). Coarse (1 bar), so
it writes a new take `<name>-rebuilt.json` and never changes the original. Only if the user wants the 2026-11-28
house take back.

## Part 2: a take as a draft

Opening a take in the lab today shows its steps as Hand-made moves (each gesture is many short ramp steps, so the
importer recognises little). New: the take opens read-only with a **Make a draft** button in the inspector. A draft
is a new unsaved lab, saved with Save as like any performance; the take file is never changed.

What the draft does (`perform-lab-core.mjs`, `draftFromTake(script, controls, events?)`):
1. **Sections from the Chapter.** Each Chapter press (or a change of the Chapter name in the events' `head` state)
   starts a section named after the chapter (`Vamp`, `Lift`, …), snapped to 4-bar lines; no Chapter change → one
   section. Energy from the mean of the Level faders and Tension in the section.
2. **Gestures become moves.** Steps of one control that `take.mjs` cut into one gesture (no pause over 100 ms)
   become one move: on a Level fader rising from 0 → Enter (`to` = the end value, `over` = the gesture's length),
   falling to 0 → Leave, anything else → Move control (`to`, `over`). A gesture is replaced by its move only when
   the move's straight ramp stays within 0.08 of every point of the gesture; otherwise it stays Hand-made.
3. Presses stay Press moves, two Break presses become a Break (the importer's rules).
4. Moves that land within ¼ bar of a bar line snap to it.
5. Title `From take <date>`, the take's name in `refs`.

The draft is a simplification: it plays close to the take, not identical. The inspector says how many gestures were
simplified and how many stayed Hand-made.

## Files
- `tools/trajectory/take.mjs` (+ `take.test.mjs`): `echo` input, echo filtering, take `bars`.
- `tools/trajectory/player.html`: route echoes to the recorder.
- `tools/trajectory/perform-lab-core.mjs` (+ test): `draftFromTake`.
- `tools/trajectory/perform-lab-ui.mjs`: read-only take view, Make a draft.
- Optional: `tools/trajectory/take-from-events.mjs`.
- Docs: `tools/trajectory/README.md` (takes without Web MIDI), `docs/features/tracks-lab.md` (takes, drafts).

## Checks
- `take.test.mjs`: an echo-only session gives the same steps as the same play through Web MIDI (within 1/64 bar);
  echoes of `scAuto` sends are dropped; with Web MIDI inputs the echo is ignored.
- `perform-lab-core.test.mjs`: `draftFromTake` on a made-up take: sections from Chapter presses, a fader rise
  becomes Enter, a wobbly gesture stays Hand-made, the draft passes `check-perform`.
- In the app: play 009-house by hand for 16 bars with Record, stop → the take has steps; Labs → Tracks → open it →
  Make a draft → Play from bar 0 sounds like the take.
- `npm test`, `node trajectory/check-recording.mjs`, `node trajectory/check-replay.mjs 009-house`.
