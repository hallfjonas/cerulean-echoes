# Plan: add and move moves where you point

Adding a move in the Tracks lab today goes through the sidebar palette: the move lands at the cursor on the kind's
default control (Enter, Leave and Layers on the first fader, Build on Tension, Fog dip on Fog, Press on Chapter, Break
on Break, Move control on the first knob) and has to be re-pointed in the inspector. Moves drag only sideways. This
plan adds moves where the pointer is (Moves and Lanes levels) and lets a move be dragged to another stem. One PR.
Builds on the Tracks lab ([tracks-lab.md](../../features/tracks-lab.md)): its shared head (ruler and section strip),
the scope (`state.scope`, the section selected there), one stem order on every level (`stemOf`), and stems that fold
on Moves and Lanes.

## One rule for "what fits where"
`perform-lab-core.mjs`: `movesFor(target, controls)` → `[{ kind, p }]`, the moves that make sense on a target, each
with its preset parameters. A target is a stem (a Moves row) or a control (a lane).

| Target | Moves offered (in this order) |
|---|---|
| Global row | Build (Tension), Fog dip (Fog), Break (Break), Press (Chapter), Move control (Master, Thin, Fog, Tension) |
| A column's row | Enter (its Level), Leave (its Level), Move control (its Brightness, Space, row 3, Level), Build (its knobs), Press (its button 1 and 2) |
| Layers row | Layers (in, out), with the stems that have a Level |
| A Level lane | Enter, Leave, Move control |
| A knob lane | Move control, Build; Fog dip on Global Fog |
| A button lane | Press; Break on Global Break |
| Keys, Pads, LK knobs | nothing yet (Launchkey moves are in plan-later.md); the popup says so |

- A column's controls come from its CCs (`columnOf` and the track's `controls`), so a column's row 3 and button 2
  appear under their own names (Punch, Octave, Echo throw …).
- Global uses the Mode 1 CCs only: column 8's Mode 2 CCs are aliases (009-house has Fog on 20 and 68), so each
  Global control is offered once.
- `columnOf` and `stemOf` move from `perform-lab-ui.mjs` to `perform-lab-core.mjs` (both pure), so `movesFor` and
  `retarget` can use them; the UI imports them from core.

## Names
Control names carry the column number (`4 Bass Level`, `1 Kick Punch`), and the numbers repeat across modes
(`1 Kick`, `1 Chords`; 009-house has four `Lead` columns in Mode 2). The popup and the drop hint use the full name
with its number ("Enter · 4 Bass Level"), and add the mode where two stems would read the same.

## Moves level: a + where you hover
- Every stem of the track that `movesFor` has moves for gets a row, empty ones too, in the `stemOf` order: Global,
  Layers, the Mode 1 columns, the Mode 2 columns. Keys, Pads and LK knobs rows appear only when they hold a move
  (Hand-made ones); the Hand-made row only for a Hand-made move without steps. Today only rows with a move are drawn.
- Hovering a row's empty space shows a faint **+** at the bar under the pointer (snapped to 1 bar). Over a move the
  + hides. In a folded row the empty space is the x range no move covers.
- Click → a small popup at the pointer: the row's `movesFor` list, one line each with the control's name
  ("Enter · 4 Bass Level", "Move control · 4 Bass Brightness"). Click a line → the move is added at that bar with
  the preset, selected, inspector open (a new selection, so an overlap unfolds its row as today). Escape or a click
  outside closes the popup. One undo step.

## Lanes level: every control has a lane
- Every stem `movesFor` has moves for shows its main lane (a column's Level, Global Master), empty ones too, in the
  `stemOf` order. Today only controls with a step have a lane.
- The caret unfolds every control of the stem, empty lanes dimmed; **+n** still counts the folded lanes that hold
  steps. This replaces a separate "+ lane" picker.
- The same + as on Moves follows the pointer over a lane's empty space; a click → the same popup, filtered to the
  lane's control; the bar from x (¼ bar snap; whole bars on a button lane, the 4-bar line on Chapter), and for Move
  control / Enter the value from y. A click on a dot keeps selecting it.
- Keys, Pads and LK knobs lanes stay as today (only with steps); a click there says nothing fits yet.

## Moves level: drag to another row
- A move drag follows the pointer vertically too. The row under the pointer is the target: the stem, never a sub-lane
  of an unfolded row. Rows vary in height and every render replaces them, so the target is found per pointer move
  (`data-stem` on each `.tl-row`, the row whose rectangle holds the pointer), not from the rectangle taken at
  pointer-down. The move
  keeps its bar snap rules (button moves on whole bars).
- Re-targeting keeps the control's place in the column: the same row of the LC (row 1, row 2, row 3, fader,
  button 1, button 2), i.e. the CC moved by the column distance (`cc + (to.col - from.col)`, ± 48 across modes;
  into Global always the Mode 1 CC). Layers moves stay in the Layers row.
- Allowed when the target column has that control and `movesFor(target)` lists the move's kind. The drop hint under
  the pointer names the new control ("→ 4 Bass Brightness"); when the role has another name there (row 3, button 2),
  the hint shows both ("1 Kick Punch → 2 Fx Motion").
- Not allowed (Fog dip onto a column, Break onto a column, a Hand-made move, Layers out of its row, a column without
  that control): the target row tints red, the hint gives the reason ("Fog dip works on Global Fog only"); on drop
  the move snaps back and nothing changes (no undo step).
- After a drop the moved move counts as newly selected (`state.revealed` reset): if it overlaps a move in its new row,
  that row unfolds, so it never hides under another move.
- One undo step per drag. Hand-edited steps of a moved move keep their edits (they are by index, the CC changes).

## Ramp cuts
A move added from the popup or dragged to another row may start inside a running ramp on the same control. That is
allowed, as with a sideways move drag today: the lane shows the cut and the footer warns (`cutRamps`). Only a lane
dot drag stays between its neighbours (`laneRoom`).

## The sidebar palette
Stays, as the keyboard-free way: adds at the cursor, on the stem of the selected move, or else the busiest stem of
the scope (`state.scope`, the most moves in that section; new helper beside `busiestBar`). When `movesFor` of that
stem does not list the kind (Fog dip with a Kick move selected), the kind's default control as today.

## Files
- `tools/trajectory/perform-lab-core.mjs` (+ test): `columnOf` and `stemOf` (moved from the UI), `movesFor`,
  `retarget(move, toStem, controls)` → `{ move } | { reason }`, the busiest stem of a section.
- `tools/trajectory/perform-lab-ui.mjs` (+ test): every row and main lane, unfolded stems with all their controls,
  hover + and click on rows and lanes, popup, vertical drag.
- `tools/trajectory/ui.css`: popup, + marker, red target row, dimmed empty lane.
- Docs: `docs/features/tracks-lab.md` (how to add and move moves: step 5 of "How to use it", and the Lanes fold in
  "Good to know").

## Checks
- `perform-lab-core.test.mjs`: `movesFor` for each target type on 009-house's controls, Global once (no Mode 2
  aliases); `retarget` keeps the LC row across columns and modes, lands on the Mode 1 CC in Global, refuses Fog dip
  on a column, keeps edits; every move added from the popup passes `check-perform`.
- `perform-lab-ui.test.mjs`: the `stemOf` tests follow it to core; every stem gets a row on a lab without moves.
- In the player: on 009-house, hover the 4 Bass row (no moves yet) → + → Enter → it lands on 4 Bass Level at that
  bar; click the Master lane at bar 8, y = 0.7 → Move control Master → 0.7 at 8; drag 1 Kick Enter onto the
  5 Clap row → 5 Clap Level; drag a Fog dip onto 1 Kick → red row, snaps back; drag a move onto one it overlaps →
  the row unfolds. Screenshots in the PR.
- `npm test`.
