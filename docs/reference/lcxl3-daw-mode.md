# Launch Control XL 3: standalone mode and DAW mode

What the LC XL 3 sends in its two operating modes, what we measured, and what switching our setup to DAW mode would
mean. Source: Novation, *Launch Control XL 3 Programmer's Reference Guide* v1.0
([PDF](https://fael-downloads-prod.focusrite.com/customer/prod/downloads/launch_control_xl_3_programmer_s_reference_guide-pdf_en.pdf)),
page numbers below refer to it.

## Summary
- Today every track uses the LC XL 3 in **standalone (MIDI) mode** with two custom modes. In this mode the **Track ◄ ►,
  Page ▲ ▼, Record, Play, Solo/Arm and Mute/Select buttons send nothing**. Measured on 2026-11-21, and confirmed by the
  guide (p. 7). Novation Components cannot assign them in a custom mode.
- In **DAW mode** those buttons report as CCs on the `DAW Out` port. The custom modes keep working on `MIDI Out`
  (p. 9, not yet measured). The host also gets control of the screen and LEDs.
- Switching is possible without touching the custom modes or the tracks. Open risks are a stray press of Mode
  (into DAW Mixer / DAW Control) and the device staying in DAW mode after a crash. Both have fixes (below).
- Not done yet: two short device tests (see "Open tests"). Until they pass, the live tracks stay in standalone mode.

## Measured in standalone mode (2026-11-21)
Monitor: `sc/tools/midi-trace.scd` (every message from every MIDI input, with its port).
Device `LCXL3 Jonas`, ports `MIDI Out` and `DAW Out`.

| Action | Seen |
|---|---|
| Knob, Mode 1 (row 2, columns 1 and 2) | CC 21 / CC 22, channel 1, `MIDI Out` |
| Knob, Mode 2 (row 1, column 1) | CC 61 (13 + 48), channel 1, `MIDI Out` |
| Track ◄ ►, Page ▲ ▼ in Mode 1 and Mode 2 | nothing, on either port; no change on the device |
| Components connecting | identity request / reply (sysex), no button data |

Novation Components: Track and Page cannot be selected in the custom mode editor.

## Standalone mode (what the guide says)
- The device powers up in standalone mode. The `DAW` interface is unused (p. 7).
- *"The Page, Track, Record, Play, Solo/Arm and Mute/Select buttons are unused in this mode. Shift and Mode provide
  access to menus and extended functionality, the rest of the surface output is configurable in … Components"* (p. 7).

## DAW mode (what the guide says)
| Topic | Detail | Page |
|---|---|---|
| Enable | note `9F 0C 7F` or sysex `F0 00 20 29 02 15 02 7F F7`, sent to the device's DAW port | 8 |
| Disable | note `9F 0C 00` or sysex `F0 00 20 29 02 15 02 00 F7` | 8 |
| On exit | the host should disable DAW mode to return the device to standalone | 9 |
| Spare buttons | *"all buttons, and surface elements not belonging to performance features (such as the Custom Modes) … report on the DAW In/Out interface only"*; buttons as CCs on channel 1, encoders and faders on channel 16, Shift on channel 7 | 9 |
| Modes | DAW Mixer and DAW Control are added next to Custom Modes 1-16 | 9 |
| Mode report / select | channel 7, CC 30: 1 = DAW Mixer, 2 = DAW Control, 6-9 = Custom 1-4, 18-29 = Custom 5-16; reported when the mode changes on the device, and settable by the host | 10, 17 |
| Encoders | absolute by default; each row can be relative (CC 69 / 72 / 73 on channel 7) | 10 |
| Faders | "DAW Fader Pickup" feature control (CC 70) | 17 |
| LEDs | colour per control (CC to the control's index, or RGB sysex) | 11-12 |
| Screen | configurable displays, text fields, a 128 × 64 bitmap | 13-15 |
| DIN out | no MIDI from the DIN outputs in DAW mode (we use USB only) | 8 |

The table with the exact CC numbers of each button in DAW mode is an image in the PDF and could not be read as text.
A web search snippet says Track 103 / 102 and Page 106 / 107; that needs the device test.

## What switching would mean for us
| Part | Effect |
|---|---|
| Custom mode files (`midi-layouts/lcxl3-mode1.syx`, `-mode2.syx`) | unchanged, no Components work |
| Strudel tracks on strudel.cc | unaffected: they never open the DAW port, so the device stays in standalone |
| SC tracks in the player | unaffected while DAW mode is off; the engine would enable it only where a feature needs it |
| Two LCs | each device is switched on its own DAW port |
| New controls | Track ◄ ►, Page ▲ ▼ and Record, Play, Solo/Arm, Mute/Select become usable (e.g. next track in a set) |
| Device screen and LEDs | the engine could show the next track or a chapter name on the device |

## Risks and fixes
| Risk | Live impact | Fix |
|---|---|---|
| A press of Mode lands in DAW Mixer / DAW Control: faders and knobs report on the DAW port, the track no longer hears them | high, on stage | the engine reads CC 30 and sets the custom mode back (or maps the DAW controls too) |
| Player or engine crashes without disabling: the device stays in DAW mode | low: custom modes keep working; the next power-up is standalone | disable on every exit; power cycle as manual reset |
| Fader pickup in DAW mode changes how faders report after a jump | unknown | measure; switch pickup off (CC 70) if it delays faders |
| Custom-mode controls do not keep sending on `MIDI Out` in DAW mode (guide implies they do) | would break every track | open test 1 decides; if it fails, DAW mode is dropped |

## Open tests (with the device and `midi-trace.scd`)
1. Enable DAW mode (`9F 0C 7F` to the DAW port). Move knobs and faders in Mode 1 and Mode 2: still the same CCs on
   `MIDI Out`, values without jumps?
2. In DAW mode, press Track ◄ ►, Page ▲ ▼, Record, Play, Solo/Arm, Mute/Select: which CC on `DAW Out`, values on press
   and release?
3. Press Mode: is CC 30 reported, and does sending CC 30 = 6 put the device back into Custom Mode 1?
4. Disable (`9F 0C 00`): back to the standalone behaviour measured above?
