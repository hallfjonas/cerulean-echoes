# Device list

Our MIDI controllers. Out of the box both Launch Control XL 3 have the same name (`LCXL3 1 MIDI Out`).
That is why they are renamed in macOS (Audio MIDI Setup → Window → Show MIDI Studio → double-click the device).

| Name      | Device                       | Role (old two-controller versions)       | Custom modes            |
|-----------|------------------------------|---------------------------------|-------------------------|
| Jonas     | Novation Launch Control XL 3 | Colour (columns 1–7) + global (column 8) | Mode 16, Mode 2, Mode 1 |
| Jojo      | Novation Launch Control XL 3 | Foundation (beat + bass, all 8 columns) | Mode 16 |
| Launchkey | Novation Launchkey MK4 25    | Third player: keys + drum pads (one-file tracks 007–010) | Factory setting |

- All buttons and faders of the Launch Control XL 3 send absolute values (0–127), no endless relative values.
- Both controllers have the same CC layout (see `CLAUDE.md`, section "Controller mapping").
- The names live only in macOS, not on the controller. On another computer the devices are called `LCXL3 1` again.
  Plugged into a different USB port, the names can move with them: check briefly in MIDI Studio.
- After renaming, restart Chrome fully, otherwise it still sees the old names.
- `setup0.syx`: custom mode file from Novation Components (called "New Custom Mode" on the device).
- One controller alone (every live track today, or Jojo's device missing): Mode 1 = Jojo, Mode 2 = Jonas.
  Mode 1 must get the same CCs as Mode 16 in Components (faders 5–12, knobs 13–36, buttons 37–52).

## One-file tracks (007, 008, 009, 010)

One file for every combination of controllers, all optional:

- Every connected Launch Control XL 3 is found, whatever its name (port with `LCXL3` in the name, without `DAW`).
  No renaming needed for this. Each one gets the full layout: Mode 1 = foundation, Mode 2 = colour.
  Every device gets the two custom modes once (`midi-layouts/lcxl3-mode1.syx` / `-mode2.syx`, slots 1 and 2); they are the same for every track.
- Two LCs control the same sounds: per control, the controller moved last wins. Button presses count
  from both. Agree beforehand who plays which page.
- No LC found: a warning in the console, everything stays silent.
- Track ◄ ►, Page ▲ ▼, Record, Play, Solo/Arm and Mute/Select send nothing in the custom modes, on either port
  (`MIDI Out`, `DAW Out`), and Components cannot assign them (measured 2026-11-21 with `sc/tools/midi-trace.scd`).
  They report only in the device's DAW mode, which no track uses.

### Launchkey MK4 25

macOS shows two ports: `Launchkey MK4 25 MIDI Out` (keys, pads, knobs) and `Launchkey MK4 25 DAW Out` (not
used). If the device is missing, its part stays silent.

| Control | Message | Effect |
|---|---|---|
| Keys (25) | Notes, channel 1 | Sound per track: 007 glass pad, 008/009/010 piano → Rhodes, organ B3 → M1, vibraphone → marimba (knobs 2–4 blend) |
| Mod wheel | CC 1 | Keys level (008: without master, there the column 8 fader drives low end and punch); silent at 0 |
| Pitch bend | not measured | read by no track |
| Knobs 1–8 | CC 21–28, channel 1, absolute (0–127, not endless-relative) | 007: 1 cutoff, 2 resonance, 3 attack, 4 note length, 5 detune, 6 reverb, 7 echo, 8 key pan; 008/009/010: 1 brightness, 2 piano → Rhodes, 3 B3 → M1, 4 vibes → marimba, 5 length, 6 reverb, 7 echo, 8 key pan (0 = middle, 1 = low keys left, high keys right) |
| Knobs 1–8, bank B | CC 31–38 (assumed, not measured: which button switches the bank on the device) | SC tracks, drum pads: 1 pitch down, 2 pad fog (one-shots darker), 3 thin, 4 drive, 5 pad spread, 6 boost |
| Drum pads (drum mode) | Notes 36–51, channel 10 | 16 one-shots per track, order as in the factory layout (C1 = 36 bottom left): bottom left 36–39, top left 40–43, bottom right 44–47, top right 48–51 (C1 to D#2). "Drum E1" = note 40 = top pad, far left. Left half, pads 1–8 (36–43) = the voice samples, own colour in the LC view; Wine, Evening, Creatures, No end, Vast play through once, new hits while they play do not count); 008: dark (909, 808, Braaam for the drop, Space, Wind; voice Plaenterwald instead of Evening), 007: bells, choir, wind, noise, 009: house kit (909, 727, organ and brass stab), 010: congas, marimba, shaker |
| Buttons above/below the pads, transport, scale, arp, faders | not measured | read by no track, CCs unknown |

- The keys have no note-off: Strudel plays every note with a fixed length (knob 4), holding does not lengthen it.
- Pads on channel 10: the pads trigger the one-shots (confirmed in use, lit up in the LC view). If they play the pad
  sound instead, they send on another channel: adjust `LK_PAD_CHAN` in the track.
- Knob CCs: the tracks read CC 31–38 for a while (back then CC 21–28 seemed to do nothing). On 2026-11-20 the
  player found the knobs sending CC 21–28, the Launchkey's default, and every track moved back to 21–28. If the knobs
  do nothing, check in a MIDI monitor which CC the device sends (a Launchkey mode or setting may change it).
