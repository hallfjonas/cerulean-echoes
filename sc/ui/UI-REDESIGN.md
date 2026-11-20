# UI redesign: controller mirror (brief for the implementing agent)

Status: design decided in conversation on 2026-11-20 from sketches and a rendered mockup. Not implemented.
Belongs to the SuperCollider move (`SC-MIGRATION.md`, `sc/PLAN-UI.md`). The UI lives in `sc/ui/`.

**Reference mockup:** `sc/ui/reference/layout-mockup.html` (open it in a browser). It is the agreed look and
scaling, with demo data. Query parameters: `?theme=black|te`, `?spec=dots|segments|bars|line|area`, `?nolk`.
Where this brief and the mockup disagree, ask.

## Goal

The live view mirrors the hardware: every control is drawn where it sits on the device, in a calm, flat,
minimalist style. The current look is felt as "2010". Only the **look** changes, plus a spectrum display.

Out of scope, do not change without asking:
- MIDI mapping, CC numbers, OSC messages, what a control does
- which controllers are shown (see "What is on screen")
- labels' wording rules from `CLAUDE.md` (English, short, one name per job)

Before you start: read `sc/ui/` and find out how the current view is built and fed (OSC bridge, data model).
Keep that data flow. If the current view lacks data this brief needs (e.g. pattern names, spectrum), add it as a
fallback and list it as an open point; do not invent a new protocol on your own.

## What is on screen

```
 mode 1 · foundation              mode 2 · colour
 ┌ LC panel (8 columns) ┐         ┌ LC panel (8 columns) ┐
 └──────────────────────┘         └──────────────────────┘
 launchkey                         spectrum
 mod │ 8 knobs over 2 × 8 pads     energy over frequency
```

- **Two LC panels** side by side: Mode 1 (Jojo's foundation) and Mode 2 (Jonas' colour), as in the current LC
  view (`CLAUDE.md` "Live tracks"). Keep the existing "moved last" frame: the page the player touched last is
  framed. A small label above each panel (`mode 1 · foundation`, `mode 2 · colour`).
- Each LC panel: 8 columns. Columns 1–7 are stems, column 8 is global (separated by a 1 px vertical line in
  `track` colour).
- **Bottom row**, same two-column grid as the panels:
  - left, under Mode 1: the **Launchkey strip** (optional device, see below), on the same 8-column grid as the
    panel above, mod wheel to its left
  - right, under Mode 2: the **spectrum** (see below)
- Without a Launchkey, its place stays empty (the spectrum stays where it is).
- **Status strip** (tempo, harmony state, chapter, phrase position): not in the mockup. Keep what exists, as one
  line under the board, restyled with the tokens, and inside the scaled board (see "Scaling").

Physical reference: the LC XL 3 is 250 × 239 mm (almost square), the Launchkey 25 MK4 461 × 251 mm. The panels
are deliberately **wider than the device (about 1.6 : 1)**, so two panels plus the bottom row fit a 16:9 or 16:10
screen. Do not copy the physical ratio.

## One LC column, top to bottom

| Element | Content | Notes |
|---|---|---|
| Column name | stem name, e.g. `kick` | `--fs-name`, weight 500 |
| Knob row 1 | Brightness | knob component |
| Knob row 2 | Space | knob component |
| Knob row 3 | per-track name (Length, Complexity …) | knob component |
| Fader | Level | fader component |
| Button 1 | **name of the active pattern**, e.g. `16th` | text only, `--fs-btn` |
| Button 2 | name of its function, e.g. `lift`, `open` | text only, `--fs-btn` |

Global column 8: knobs Fog / Thin / Tension, fader Master, button 1 Chapter (shows the chapter name, e.g.
`groove`), button 2 Break.

Pattern names: each pattern needs a short name (one word, at most 6 characters, see "Rules"). If the track or
stem does not provide one yet, fall back to `pat 1`, `pat 2` … and report which tracks need names.

## Scaling

The whole board is laid out on a fixed **design board of 1600 × 900 units** and scaled as one piece, so it always
fits the window in both directions and never scrolls:

```
--px: min(96vw / 1600, 94vh / 900)      /* one design unit in CSS px */
```

Every size below is in design units (`n × --px`). Proportions therefore stay identical on every screen. Only text
has a floor and a ceiling:

| Variable | Use | Value |
|---|---|---|
| `--fs-name` | column names | `clamp(13px, 20 × --px, 32px)` |
| `--fs-btn` | button labels, `mod` | `clamp(11px, 18 × --px, 28px)` |
| `--fs-lab` | panel labels, spectrum frequencies | `clamp(11px, 16 × --px, 24px)` |

Line height 1.4, no uppercase, no letter-spacing changes. Checked in the mockup at 1280×800 (@2x), 1920×1080,
2560×1440 and 3840×2160: no overflow, same proportions.

Design-unit sizes:

| Element | Size (units) |
|---|---|
| Gap between the two panels / between the two bottom boxes | 40 |
| Gap between panel row and bottom row | 32 |
| Panel padding | 14 vertical, 12 horizontal; frame radius 10 |
| Gap between columns | 4 |
| Gap between elements in a column | 14 |
| Knob | 48 (TE disc: 52) |
| Fader | 28 wide, 150 high; track `max(2px, 4)` wide; handle 28 × 12, radius 1 |
| Launchkey: mod wheel fader | 28 × 130 |
| Launchkey: pad | 36 |
| Spectrum canvas | full box width, 190 high |

## Two themes

Both themes share the layout above; only tokens and the knob component differ. Theme is a setting in the
existing settings drawer (`Black` default, `TE`). Persist the choice in `localStorage`, wrapped in try/catch.

### Theme "Black" (Torso-like)

| Token | Value |
|---|---|
| `bg` | `#0b0b0b` |
| `text` (names, active button text, arcs, fader handle) | `#F1EFE8` |
| `off` (button text of a column that is off, labels) | `#5F5E5A` |
| `track` (knob track, fader track, dividers, frame) | `#2C2C2A` |
| `accent` (button 2 active) | `#F1EFE8` |
| font | monospace |

Knob = **arc** (SVG viewBox 24): radius 9, stroke 3, round caps. Track arc from 135° to 405° (7 to 5 o'clock) in
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
| frame | 1 px `#2C2C2A` |
| font | sans |

Knob = **disc with pointer** (SVG viewBox 26): circle radius 12, 1 px ring. Pointer is a 2.5 round-capped line from
radius 4 to radius 10 at angle 135° + 270° × value.

| Row | Fill | Ring | Pointer |
|---|---|---|---|
| 1 Brightness | `#378ADD` | `#378ADD` | `#F1EFE8` |
| 2 Space | `#1D9E75` | `#1D9E75` | `#F1EFE8` |
| 3 (and all Launchkey knobs) | `#F1EFE8` | `#888780` | `#2C2C2A` |

Known trade-off, accepted on purpose: the pointer is less precise to read than the arc. Do not "fix" it by adding
an arc; a possible later idea is to show the value briefly while a knob moves (not in this task).

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

## Launchkey strip

Same tokens and components as the active theme, on the same 8-column grid as the LC panel above it:
- Mod wheel (CC 1, keys level) as a fader, labelled `mod`, left of the grid.
- 8 knobs (CC 31–38), one per column; in TE the row-3 disc.
- 16 drum pads as 2 × 8, two per column under its knob. Black: square outline in `off`, filled `text` while hit.
  TE: round, filled `track`, `#D85A30` while hit. Hit = short flash.
- Keys: not in the mockup. Keep whatever the current view shows, restyled with the tokens.
- Show sample names under pads only if the current view already has them.

## Spectrum

Live energy over frequency of the master output, under Mode 2.

- Data: magnitudes of the master bus from SuperCollider (e.g. an FFT/analyser on the master, sent over the
  existing OSC bridge). If no such data exists yet, add it as the smallest possible addition to the bridge and
  list it as an open point. The mockup uses a fake signal (`energy()`); replace only that function.
- 48 bands, logarithmic from 20 Hz to 20 kHz. Frequency labels `60`, `250`, `1k`, `4k`, `12k` under the display in
  `off`, at `--fs-lab`.
- Draw on a **canvas sized with `devicePixelRatio`** (backing store = CSS size × dpr), redraw on resize, update in
  `requestAnimationFrame`.
- Peaks fall back slowly (about 0.6 % of full scale per frame); a slow average follows with factor 0.05.

| Theme | Default style | Look |
|---|---|---|
| Black | **LED dots** | 32 columns × 12 rows of dots; lit `text`, unlit `track` |
| TE | **Segments** | 24 columns × 12 rows of rounded bars; lit by range: below 250 Hz `#D85A30`, 250 Hz–4 kHz `#1D9E75`, above `#378ADD`; unlit `track` |

The other styles in the mockup (`bars`, `line`, `area`, TE `dots`) were alternatives; build only the defaults.

## Rules

- Flat: no gradients, shadows, glow or blur.
- Minimum text size 11 px; lower case labels as in the mockup.
- Draw knobs as SVG. Update values in a `requestAnimationFrame` loop, not on every MIDI message.
- **Every label is one line, one or two words, as short as possible.** Never wrap, never shrink the font to fit.
  Limits: column name ≤ 7 characters, pattern name ≤ 6, button 2 name ≤ 6, knob row names ≤ 10.
  A label over its limit is not truncated silently: list it in your report so a shorter name can be chosen.
- No element may overlap or overflow at any window size; check 1280×800, 1920×1080, 2560×1440, 3840×2160.
- Labels follow `CLAUDE.md` ("Labels").

## Decided and dropped

- Knob as brightness only: dropped (hard to read). Dots-only buttons: dropped. Underlines for state: dropped.
- Hybrid (colours on black): dropped. Grey-out of off columns: dropped.
- Round LED buttons were liked but lose the pattern name; text only for now.
- Scaling each element type separately (knobs and fonts on their own curves): dropped, it broke the proportions.
  The board scales as one piece; only text is clamped.
- Physical aspect ratio of the LC: dropped, see "What is on screen".

## Open points

- How button 1 works per track (see "States").
- In TE, orange now means fader handle, button 2 active, pad hit and the bass range of the spectrum. Accepted for
  now; if it gets confusing, pads light dark instead.
- Where the status strip sits exactly (not in the mockup).
- Spectrum data from SC (see "Spectrum").

## Done when

- Both themes render the two LC panels, the Launchkey strip, the spectrum and the status strip, with and without a
  Launchkey.
- Screenshots of both themes at the four sizes above, with: a column on, off, waiting on, waiting off, button 2
  active, fader at 0 and 1, knob at 0 and 1, the "moved last" frame on each panel, a pad hit.
- The view still plays a track end to end with real controllers and without them (auto-perform).
- Open points listed: tracks without pattern names, data the view was missing.
