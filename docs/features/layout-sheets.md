# Layout sheets

## What it is
Every live track has a printable sheet (a PDF) that lists what each knob, fader and button of the Launch Control XL 3
does in that track. The same information also becomes two custom mode files (`.syx`) that put the control names on the
controller's display. You never write these by hand: they are generated from `// @ctl` comments in the track file.

## When to use it
- You want a cheat sheet next to the controller on stage.
- You changed what a control does and want the sheet and the display names to match.
- You got a new controller, or reset it, and need to load the modes again.

## How to use it
1. Find the files next to the track, for example `tracks/ambient/007-ambient-soundscape/`:
   `007-ambient-layout.pdf`, `007-ambient-mode1.syx`, `007-ambient-mode2.syx`.
2. Print the PDF. It has one page per mode: Mode 1 is the foundation, Mode 2 the colour.
3. Load the `.syx` files with Novation Components: Mode 1 into slot 1, Mode 2 into slot 2, on every Launch Control.
   Load them again after a reset.
4. To change a label, edit the `// @ctl` line right above the code that reads the control. The PDF and the `.syx` files
   are regenerated after every edit by a hook. To do it by hand, run in `tools/`:
   `npm run layouts` (sheets), `npm run syx` (custom modes), or `npm run watch` (regenerate on save).

## Good to know
- Never edit the PDF or a `.syx` file by hand; the next edit overwrites them. On a merge conflict take either side and
  regenerate.
- A `@ctl` text is one short line (about 50 characters): what the control does. Text that is too long is shrunk on the
  sheet, which is hard to read on stage, so shorten it instead.
- Controller numbers (CC) are computed from the position in the grid, so the sheet cannot drift from the code.
- Lab boards keep their own hand-made sheets on purpose.
- Rules for the tags: the `lcxl-layout` skill (`.claude/skills/lcxl-layout/SKILL.md`).

## Related
- [Controllers](controllers.md)
- [Live tracks](live-tracks.md)
- [Checks](checks.md): `npm run verify` also tests the sheet and the `.syx` files
- [Claude skills](claude-skills.md)
