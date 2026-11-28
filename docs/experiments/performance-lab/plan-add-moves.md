# Plan: add and move moves where you point

Adding a move in the Tracks lab today goes through the sidebar palette: the move lands at the cursor on the track's
first fader (Kick) and has to be re-pointed in the inspector. Moves drag only sideways. This plan adds moves where the
pointer is (Moves and Lanes levels) and lets a move be dragged to another voice. One PR. Builds on the Tracks lab
([tracks-lab.md](../../features/tracks-lab.md)) and its section bar.

## One rule for "what fits where"
`perform-lab-core.mjs`: `movesFor(target, controls)` → `[{ kind, p }]`, the moves that make sense on a target, each
with its preset parameters. A target is a voice (a Moves row) or a control (a lane).

| Target | Moves offered (in this order) |
|---|---|
| Global row | Build (Tension), Fog dip (Fog), Break (Break), Press (Chapter), Move control (Master, Thin, Fog, Tension) |
| A column's row | Enter (its Level), Leave (its Level), Move control (its Brightness, Space, row 3, Level), Build (its knobs), Press (its button 1 and 2) |
| Layers row | Layers (in, out), with the stems that have a Level |
| A Level lane | Enter, Leave, Move control |
| A knob lane | Move control, Build; Fog dip on Global Fog |
| A button lane | Press; Break on Global Break |
| Keys, pads, LK lanes | nothing yet (Launchkey moves are in plan-later.md); the popup says so |

A column's controls come from its CCs (`columnOf` in perform-lab-ui.mjs and the track's `controls`), so a column's
row 3 and button 2 appear under their own names (Punch, Octave, Echo throw …).

## Moves level: a + where you hover
- Every voice of the track gets a row, empty ones too: Global, each column with controls (Mode 1 then Mode 2, by
  `keyRank`), Layers, Hand-made only when there is one. Today only rows with a move are drawn.
- Hovering a row's empty space shows a faint **+** at the bar under the pointer (snapped to 1 bar; to the phrase
  line when a Press of Chapter is the only fit). Over a move the + hides.
- Click → a small popup at the pointer: the row's `movesFor` list, one line each with the control's name
  ("Enter · Bass Level", "Move control · Bass Brightness"). Click a line → the move is added at that bar with the
  preset, selected, inspector open. Escape or a click outside closes the popup. One undo step.

## Lanes level: double-click a lane
- Double-click on a lane → the same popup, filtered to the lane's control; the bar from x (¼ bar snap), and for
  Move control / Enter the value from y. Single click keeps selecting.
- A last row **+ lane**: a picker of the track's controls without a lane; picking one adds an empty lane (view only,
  until a move lands on it).

## Moves level: drag to another row
- A move drag follows the pointer vertically too. The row under the pointer is the target; the move keeps its bar
  snap rules (button moves on whole bars).
- Re-targeting keeps the control's place in the column: the same row of the LC (row 1, row 2, row 3, fader,
  button 1, button 2), i.e. the CC moved by the column distance (`cc + (to.col - from.col)`, ± 48 across modes).
  Layers moves stay in the Layers row.
- Allowed when the target column has that control and `movesFor(target)` lists the move's kind. The drop hint under
  the pointer names the new control ("→ Bass Brightness"); when the role has another name there (row 3, button 2),
  the hint shows both ("Kick Punch → Fx Motion").
- Not allowed (Fog dip onto a column, Break onto a column, a Hand-made move, Layers out of its row, a column without
  that control): the target row tints red, the hint gives the reason ("Fog dip works on Global Fog only"); on drop
  the move snaps back and nothing changes (no undo step).
- One undo step per drag. Hand-edited steps of a moved move keep their edits (they are by index, the CC changes).

## The sidebar palette
Stays, as the keyboard-free way: adds at the cursor, but now on the voice of the selected move or the scoped section's
busiest voice instead of always the first fader.

## Files
- `tools/trajectory/perform-lab-core.mjs` (+ test): `movesFor`, `retarget(move, toVoice, controls)` →
  `{ move } | { reason }`.
- `tools/trajectory/perform-lab-ui.mjs` (+ test): all rows, hover +, popup, lane double-click, + lane, vertical drag.
- `tools/trajectory/ui.css`: popup, + marker, red target row.
- Docs: `docs/features/tracks-lab.md` (how to add and move moves).

## Checks
- `perform-lab-core.test.mjs`: `movesFor` for each target type on 009-house's controls; `retarget` keeps the LC row
  across columns and modes, refuses Fog dip on a column, keeps edits; every move added from the popup passes
  `check-perform`.
- In the player: on 009-house, hover the Bass row (no moves yet) → + → Enter → it lands on Bass Level at that bar;
  double-click the Master lane at bar 8, y = 0.7 → Move control Master → 0.7 at 8; drag Kick Enter onto the Clap row
  → Clap Level; drag a Fog dip onto Kick → red row, snaps back. Screenshots in the PR.
- `npm test`.
