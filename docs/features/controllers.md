# Controllers

## What it is

The live tracks are played with MIDI controllers: faders and knobs on one or two Novation Launch Control XL 3 (LC),
and keys, drum pads, a mod wheel and knobs on a Novation Launchkey MK4 25. MIDI is the signal a controller sends when
you move something. Every control sends a number from 0 to 127.

## When to use it

- Before you play a live track: to know what is plugged in and what each device does.
- When you load the control names onto the LC so its small display shows them.

## How

**Launch Control XL 3**
- Plug in one or two. The track finds every port with `LCXL3` in its name (not `DAW`). No renaming is needed.
- Every LC gets the full layout. Mode 1 = the foundation (beat and bass), Mode 2 = the colour (chords and melodies).
  Mode 1 is custom mode slot 1 and Mode 2 is slot 2: pick the slot on the controller to switch. Column 8 is global in both modes.
- Load the control names once per track: take `NNN-<name>-mode1.syx` and `-mode2.syx` from the track folder
  (for example `tracks/house/009-house/`) into Novation Components, slot 1 and slot 2. A layout sheet PDF sits next to
  them. See [layout sheets](layout-sheets.md).

**Launchkey MK4 25** (optional)
- Keys play a sound that fits the track (a pad, a piano or a Rhodes).
- Drum pads (channel 10, notes 36 to 51) play 16 one-shot sounds: voice samples, hits, percussion.
- Mod wheel = the level of the keys, multiplied by the master. At 0 the keys are silent: move it up first.
- Knobs 1 to 8 = the sound of the keys and the one-shots. They mean the same in every track.
- If it is missing, its part stays silent.

**No controller**
- Use [auto-perform](auto-perform.md). It plays into a virtual controller named `LCXL3 Auto`. Its name contains
  `LCXL3`, so the track treats it like a real LC.

## Good to know

- **Last moved wins.** If two controllers move the same control, the one you touched last sets the value. Button
  presses count from all of them. Agree who plays which page.
- Controls not moved yet read 0, and every track must already sound good with all knobs at 0.
- The keys have no note-off: each note rings for a fixed length that a knob sets, whatever time you hold the key.
- After renaming a device in macOS or plugging in a new one, restart Chrome fully, or the browser still sees the old
  names.
- Everything stays silent if no LC is found; the console shows a warning.
- The Launchkey has two ports. Only `Launchkey MK4 25 MIDI Out` is used, not the `DAW` one.

Detail: [midi-layouts/devices.md](../../midi-layouts/devices.md).

## Related

- [Live tracks](live-tracks.md): what the rows and columns mean
- [Player](player.md), [auto-perform](auto-perform.md), [layout sheets](layout-sheets.md)
- [Glossary](../reference/glossary.md)
