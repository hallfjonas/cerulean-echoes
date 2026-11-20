# UI redesign: controller mirror (brief for the implementing agent)

Status: design decided in conversation on 2026-11-20 from sketches. **Implemented 2026-11-20** in `sc/ui/index.html`
(see "Implementation notes" at the end).
Belongs to the SuperCollider move (`SC-MIGRATION.md`, `sc/PLAN-UI.md`). The UI lives in `sc/ui/`.

## Goal

The live view mirrors the hardware: every control is drawn where it sits on the device, in a calm, flat,
minimalist style. The current look is felt as "2010". Only the **look** changes.

Out of scope, do not change without asking:
- MIDI mapping, CC numbers, OSC messages, what a control does
- which controllers are shown and in what arrangement (see "What is on screen")
- labels' wording rules from `CLAUDE.md` (English, short, one name per job)

Before you start: read `sc/ui/` and find out how the current view is built and fed (OSC bridge, data model).
Keep that data flow. If the current view lacks data this brief needs (e.g. pattern names), add it as a fallback
and list it as an open point; do not invent a new protocol on your own.

## What is on screen

The current view shows **two Launch Control XL 3 panels and one Launchkey (LK) row**. Keep all three.

- **Two LC panels** side by side: Mode 1 (Jojo's foundation) and Mode 2 (Jonas' colour), as in the current LC
  view (`CLAUDE.md` "Live tracks"). Keep the existing "moved last" frame: the page the player touched last is
  framed (see theme tokens: `frame`). Check in `sc/ui/` that the SC UI follows the same model.
- Each LC panel: 8 columns. Columns 1–7 are stems, column 8 is global (separated by a 1 px vertical line in
  `track` colour).
- **LK row** below the two panels, same visual language (see "Launchkey row").
- **Status strip** at the bottom (tempo, harmony state, chapter, phrase position). Keep what exists, restyle it.

## One LC column, top to bottom

| Element | Content | Notes |
|---|---|---|
| Column name | stem name, e.g. `kick` | 13 px, weight 500 |
| Knob row 1 | Brightness | knob component |
| Knob row 2 | Space | knob component |
| Knob row 3 | per-track name (Length, Complexity …) | knob component |
| Fader | Level | fader component |
| Button 1 | **name of the active pattern**, e.g. `16th` | text only, 11 px |
| Button 2 | name of its function, e.g. `lift`, `open` | text only, 11 px |

Global column 8: knobs Fog / Thin / Tension, fader Master, button 1 Chapter (shows the chapter name, e.g.
`groove`), button 2 Break.

Pattern names: each pattern needs a short name (one word, at most 6 characters, see "Rules"). If the track or stem does not provide one
yet, fall back to `pat 1`, `pat 2` … and report which tracks need names.

## Two themes

Both themes share the layout above; only tokens and the knob component differ. Theme is a setting in the
existing settings drawer (`Black` default, `TE`). Persist the choice in `localStorage`, wrapped in try/catch.

### Theme "Black" (Torso-like)

| Token | Value |
|---|---|
| `bg` | `#0b0b0b` |
| `text` (names, active button text, arcs, fader handle) | `#F1EFE8` |
| `off` (button text of a column that is off) | `#5F5E5A` |
| `track` (knob track, fader track, column 8 divider) | `#2C2C2A` |
| `accent` (button 2 active) | `#F1EFE8` |
| `frame` (panel moved last) | 1 px `#F1EFE8` |
| font | monospace |

Knob = **arc**: 24 px box, radius 9, stroke 3, round caps. Track arc from 135° to 405° (7 to 5 o'clock) in
`track`; value arc from 135° to 135° + 270° × value in `text`. Value 0 draws no value arc.

### Theme "TE" (Teenage Engineering-like)

| Token | Value |
|---|---|
| `bg` | `#D3D1C7` |
| `text` | `#2C2C2A` |
| `off` | `#888780` |
| `track` | `#B4B2A9` |
| fader handle | `#D85A30` |
| `accent` (button 2 active) | `#D85A30` |
| `frame` | 1 px `#2C2C2A` |
| font | sans |

Knob = **disc with pointer**: 26 px box, circle radius 12, 1 px ring. Pointer is a 2.5 px round-capped line from
radius 4 to radius 10 at angle 135° + 270° × value.

| Row | Fill | Ring | Pointer |
|---|---|---|---|
| 1 Brightness | `#378ADD` | `#378ADD` | `#F1EFE8` |
| 2 Space | `#1D9E75` | `#1D9E75` | `#F1EFE8` |
| 3 | `#F1EFE8` | `#888780` | `#2C2C2A` |

Known trade-off, accepted on purpose: the pointer is less precise to read than the arc. Do not "fix" it by adding
an arc; a possible later idea is to show the value briefly while a knob moves (not in this task).

## Fader (both themes)

Vertical, 14 px wide: a 2 px track (`track`) centred, a 14 × 6 px handle (radius 1) whose bottom sits at
value × (height − 6). Black: handle `text`; TE: handle `#D85A30`.

## States

Decided rule: **nothing dims except button text.** No grey-out of names, knobs or faders for columns that are off;
the faders already show what plays, and dimming caused visual jumping.

| State | How it shows |
|---|---|
| Column on | button 1 text in `text` |
| Column off | button 1 text in `off` |
| Waiting for the phrase boundary (on → off or off → on) | button 1 text blinks: 1 s period, hard steps, 100 % / 25 % opacity |
| Button 2 active (held or toggled) | button 2 text in `accent` |
| Button 2 inactive | button 2 text in `off` |

No underlines, no boxes, no extra icons.

Open point, check before building: in the current tracks button 1 usually **cycles patterns** (`cycleButton`)
and has no "off" state. Then button 1 text is always in `text`, the fader alone shows whether a column plays, and
the "column off" row above never applies. Find out per track how button 1 works and report it; do not invent an
off state.

## Launchkey row

Same tokens and components as the active theme:
- 8 knobs (CC 31–38) with the theme's knob component; in TE use the row-3 disc for all eight.
- Mod wheel (CC 1, keys level) as a fader.
- 16 drum pads as a 2 × 8 grid of 12 px circles: filled in `text` while hit (short flash), otherwise `track`.
  Show the sample name under each pad only if the current view already has it.
- Keys: keep whatever the current view shows, restyled with the tokens.

## Rules

- Flat: no gradients, shadows, glow or blur.
- Minimum text size 11 px; sentence case or lower case for labels as in the sketches.
- Draw knobs as SVG. Update values in a `requestAnimationFrame` loop, not on every MIDI message.
- **Every label is one line, one or two words, as short as possible.** Never wrap, never shrink the font to fit.
  Limits: column name ≤ 7 characters, pattern name ≤ 6, button 2 name ≤ 6, knob row names ≤ 10.
  A label over its limit is not truncated silently: list it in your report so a shorter name can be chosen.
- No element may overlap at the smallest window size you support.
- Labels follow `CLAUDE.md` ("Labels").

## Decided and dropped

- Knob as brightness only: dropped (hard to read). Dots-only buttons: dropped. Underlines for state: dropped.
- Hybrid (colours on black): dropped. Grey-out of off columns: dropped.
- Round LED buttons were liked but lose the pattern name; text only for now.

## Done when

- Both themes render the two LC panels, the LK row and the status strip.
- Screenshots of both themes with: a column on, off, waiting on, waiting off, button 2 active, fader at 0 and 1,
  knob at 0 and 1, the "moved last" frame on each panel.
- The view still plays a track end to end with real controllers and without them (auto-perform).
- Open points listed: tracks without pattern names, data the view was missing.

## Implementation notes (2026-11-20)

- Theme switch: the player's Visual settings ("Panel theme", key T) and a `Black / TE` switch in the view's status
  strip (for `live.scd` without the player). One browser setting, `localStorage` key `ce.panelTheme`.
- Button 1 cycles patterns in every SC track (`ce.change`), so it has no off state: its text is always `text`. While
  a switch waits for the bar / phrase, it shows the **next** pattern's name, blinking.
- No value numbers under knobs and faders (the sketches have none); the track's "dim" hint is ignored (rule: nothing
  dims except button text).
- Launchkey knobs are on CC 21–28 (not 31–38 as above; changed on 2026-11-20).
- Labels over the limits (009, shown in full where they fit, cut where they do not; shorter names needed):
  column names over 7: `Noise Pump`, `Hats / Shaker`, `Vibraphone`; row-3 names over 10: `Hats ↔ Shaker`,
  `Strings ↔ B3`; button 2 over 6: `Echo throw`, `Lift 0 %`; pad names that do not fit: `Crash reverse`.
  Other tracks not checked yet.

