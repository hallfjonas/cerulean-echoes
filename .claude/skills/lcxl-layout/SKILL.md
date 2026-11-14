---
name: lcxl-layout
description: Create or update the Launch Control XL 3 layout sheet (Typst → PDF) of a Strudel track from @ctl comments in the track. Use when a track's controller mapping is new or changed, or the user asks for a layout/cheat sheet.
---

# LC XL 3 layout sheets

The sheet is generated from comments in the `.strudel` file; CC numbers are computed from the position, so they
cannot drift from the code. A PostToolUse hook regenerates `<track>-layout.pdf` after every Edit/Write of a
`.strudel` file (`tools/lcxl-layout/hook.mjs`); for hand edits: `cd tools && npm run watch`; all at once: `npm run layouts`.
For tracks the hook also writes the custom modes (`.syx`, control names from the @ctl tags): `make-syx.mjs`,
all at once: `npm run syx`.

## Tags
```js
// @layout Track 006 (lean, mix)
// @note Paragraph of intro text (plain text)
// @mode 16 Mode 16 — Stems             a page per mode, in this order
// @mode 2 Mode 2 — Melodien (CC + 48)
// @col 16:1 1 Kick                     column heading
// @row 16:k1 Reihe 1 \ HPF             row label (" \ " = line break)
// @ctl 16:1.k1 HPF | 20–2000 Hz. Ganz offen: nur noch der Klick.
// @ctl 2:1-7.k1 Wobble | …             range: text on column 1, "wie <heading>" on the others
// @ctl g.fader Master Level | …        global column 8, on every page, CC n / n + 48
```
Rows: `k1 k2 k3` (knob rows), `fader`, `b1 b2` (button rows). Mode 16: fader 5-12, knobs 13-36, buttons 37-52; Mode 2 = +48.

## Rules
- Put each `@ctl` right above the code that reads that control, so code and sheet change together.
- Describe what the control does musically and its range (from the code: `range`, `expRange`, crossfade points).
  English text, short.
- After changing a mapping, check the hook output; a broken tag is reported and the PDF is not updated.
- Look at the result: `pdftoppm -r 80 -png <pdf> <scratch>/pg` and read the PNGs.
- **No text may run past its cell** (this kept happening). Button cells are short: at most ~3 lines (~50 characters
  of description); knob and fader cells at most ~7 lines (~150 characters). Check every cell in the PNG (render at
  -r 110 to see the edges), and shorten the `@ctl` text until it fits. The template
  (`lcxl3.typ`) shrinks overflowing text automatically (down to 55 %), so overflow no longer breaks the sheet, but a
  cell set in small print is hard to read on stage: treat smaller text in the PNG as a sign to shorten.

Files: `tools/lcxl-layout/gen-layout.mjs` (parser + compile), `lcxl3.typ` (template, reads JSON via `sys.inputs.data`).
