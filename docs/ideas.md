# Ideas for later

## Make the custom mode file (.syx) from the Strudel file (skill)
**Done:** `tools/lcxl-layout/make-syx.mjs` (runs in the hook). Name format: `<0x60 + length> <id> <text>`,
mode name `20 <length> <text>`. Not yet confirmed on the device.

Goal: the OLED of the Launch Control XL 3 shows for each control the name from the track (e.g. "Kick Softness"),
not just the CC number. A skill/tool reads a track's `@col`/`@ctl` tags (dual and single) and writes one `.syx` per
controller and mode, to load in Novation Components.

What we can already read from `midi-layouts/setup0.syx` (an empty custom mode from Components):
- Two SysEx messages (pages), each `F0 00 20 29 02 15 05 00 45 <page> 7F 20 10 <name, 16 chars> …  F7`.
- Per control one block `49 <control-id> 02 <type/channel> 00 01 <40|50> 00 <CC> 7F 00`
  (ids 0x10–0x27 = knobs, 0x28–0x2F = faders, 0x30–0x3F = buttons).
- Then per control `60 <control-id>` – probably the place for the name (empty in the file).
Open: exact name format (length, character set), meaning of the other bytes. Best: give a control a name in
Components, export, and compare with this file.
