---
name: alt-rebuild
description: Track 018-alt, a SuperCollider rebuild of the Cyma Forma ALT, played with one Launch Control XL 3 (DAW mode, own custom mode, 14-bit faders) and a Launchpad MK3 as the pin matrix
status: backlog
created: 2026-11-24T14:49:50Z
---

# PRD: alt-rebuild

## Executive Summary
A new live track `sc/tracks/018-alt/` that rebuilds the idea of the Cyma Forma ALT (an analog drone and soundscape
synth, manual: https://www.cymaforma.com/pages/alt-manual, firmware v2.0) on the SC engine: five oscillators and
noise, two filters in series and a stereo delay ("Alter"), four modulation sources ("Movement") and a pin matrix that
routes the sources to destinations. One LC XL 3 plays the sound and the movement; a Launchpad MK3 lying next to it is
the pin matrix. It is an instrument more than a song: it plays itself once pins are set, the player guides it.

## Problem Statement
Our tracks are songs with fixed patterns. The ALT shows a different way to play: few sources, slow modulation, the
routing itself is the composition ("help it find its way"). We have the controllers (LC, Launchpad) but no instrument
built this way, and the LC has neither enough resolution for fine pitch (128 steps = about 14 cents over 1.5 octaves,
audible as beating between drones) nor enough controls without a second layer.

## User Stories
- **As a player,** I set five voices to pitches with the faders and hear them drift and beat against each other.
  Accept: fader moves on col 1-5 change pitch smoothly, no audible steps on a slow move (14-bit).
- **As a player,** I press a Launchpad pad and a source starts moving a destination; I press it again and it stops.
  Accept: pad lit in the source's colour, pulsing with the source; the destination moves within one control period.
- **As a player,** I hold Shift and the same knobs reach the second layer (filter 2, Random, Outline).
  Accept: knob LEDs show the shifted values while Shift is held and return on release; shifted faders use pickup.
- **As a player,** I step tonic and scale with dedicated buttons and see the choice in the status box.
  Accept: quantized voices move to the new scale at once; OSC1 is never quantized.
- **As a player,** I patch a source into Arp and OSC2-5 start playing a melody in turn.
  Accept: with amplitudes low and Arp pinned, the voices trigger in an order set by the source.
- **As a listener on the Live page,** I see the LC and the Launchpad side by side.
  Accept: the pins and the Shift state are visible; labels are the ALT names.

## Functional Requirements

### Sound (ALT names)
- **OSC1:** sine, free pitch (never quantized): Frequency (fine, 1.5 octaves) and Coarse (8 octaves), Amplitude,
  Angle (pan; the ALT pans only OSC2-5, ours pans OSC1 too so col 1 matches cols 2-5), Push (gate).
- **OSC2-5:** triangle or saw (Shape), Frequency over 2 octaves, quantized to the scale or free (Scale on/off per
  voice), Amplitude, Angle, Push. Octave offsets as on the ALT: OSC2 one octave below OSC3/OSC4, OSC5 one above.
- **Noise:** white noise with its own level; also the source of filter 1's Ripples.
- **Scales:** the 15 ALT presets (chromatic, minor 7th, minor pentatonic, minor diminished, minor natural, major 7th,
  major pentatonic, major, whole tone, just-intonation major, sanza, anchi hoye, hijaz, balinese pelog, insen); tonic
  in 12 steps. Microtonal tunings need sources for their cent values (see Constraints).
- **Alter:** filter 1 and filter 2 in series, each Cut, Resonance (self-oscillates at max), Lo/hi (low-pass → mid
  scoop → high-pass), Ripples (momentary cutoff wobble: filter 1 from noise, filter 2 from Outline). Stereo delay:
  Echo level, Echo feedback (one repeat to infinite), Echo time (clock steps, see Layout), More (momentary extra send).
  No reverb (the ALT has none).
- **Movement:** LFO 1, LFO 2 (Amplitude, Frequency, Shape square → triangle, Range low 0.01-11 Hz / high 0.7-1190 Hz
  for FM/AM, Sync to the player clock on/off); Random, a sample & hold (Amplitude, Frequency, Offset, Slew on/off;
  synced: clock multiples 1/8 … 8 as on the ALT); Outline, an envelope follower on the voice gates (Amplitude,
  Release, Invert). Mic input later.

### Pin matrix (Launchpad MK3)
- 4 sources (pad rows: LFO 1, LFO 2, Random, Outline) × 16 destinations = 64 pads, one page.
  Upper half (rows 1-4) destinations: Amp 1-5, Noise, Cut 1, Cut 2. Lower half (rows 5-8): Freq 1-5, Echo time,
  Random rate, Arp. Pad columns 1-5 line up with LC columns 1-5.
- Dropped from the ALT's 19: master volume, LFO 1 rate, LFO 2 rate.
- A pin is on/off; depth is the source's Amplitude (as on the ALT). Pins on one destination add up.
- **Arp:** the pinned source triggers OSC2-5 in turn; order follows the source's shape and amplitude.
- LEDs: a set pin lights in its source's colour and pulses with the source (the ALT's matrix lights).
- The right column: spare for now (Shift lives on the LC).

### Layout (LC XL 3; "a / b" = normal / with Shift)
|              | Col 1: OSC1 | Cols 2-5: OSC2-5 | Col 6: Alter | Col 7: LFO 1 / Random | Col 8: LFO 2 / Outline |
|--------------|-------------|------------------|--------------|-----------------------|------------------------|
| **Row 1**    | Amplitude | Amplitude | Echo level / Echo feedback | Amplitude / Amplitude | Amplitude / Amplitude |
| **Row 2**    | Angle | Angle | Lo/hi 1 / Lo/hi 2 | Shape / Offset | Shape / – |
| **Row 3**    | Coarse / Noise | – | Resonance 1 / Resonance 2 | – | – |
| **Fader**    | Frequency | Frequency | Cut 1 / Cut 2 | Frequency / Frequency | Frequency / Release |
| **Button 1** | Push | Push | Ripples 1 / Ripples 2 | Range / Slew | Range / Invert |
| **Button 2** | – | Shape / Scale on/off | More | Sync / Sync | Sync / – |

- Every fader is a frequency (pitch, cut, rate); faders are 14-bit. Faders on col 1-5 have no Shift layer.
- DAW-mode buttons: Shift = the layer above; Tonic down/up, Scale up/down and Echo time step on the extra buttons.
  Which buttons depends on the route chosen in task 001 (see Constraints): on the DAW pages Track ◄ ► = Tonic,
  Page ▲ ▼ = Scale; with a custom mode only Record, Play and the small button next to Solo/Arm reach SC, so Tonic and
  Scale go to the Launchpad's right column instead.
- Column 8 is not the global column in this track (no Fog / Thin / Tension / Master / Chapter / Break); there is no
  master control (the ALT has none on the surface).

## Non-Functional Requirements
- Every controller optional: no LC or no Launchpad = the track still loads and sounds with its start state.
- DAW mode is switched on only by this track and switched off on track change, player stop and SC exit; a stray Mode
  press is caught and the custom mode is set back.
- The other tracks and the shared custom modes 1 and 2 stay unchanged (7-bit).
- LED traffic to the Launchpad capped (about 20 updates per second) so MIDI stays responsive.
- Runs on the M2 Air with the other tracks' budget: one SC server, control-rate modulation where audio rate is not
  needed (FM/AM at high LFO range is audio rate).

## Success Criteria
- `npm run verify-sc -- sc/tracks/018-alt/018-alt.scd` and `npm test` pass (with the track-specific test exception,
  see Constraints).
- On the device: fader sweep on OSC1 over 1.5 octaves without audible steps; Shift layer and the DAW-mode buttons work
  as in the layout table; pins toggle and pulse; unplugging either device does not stop the sound.
- The user plays a 10-minute session that runs itself between moves (pins set, no hands) and calls it "ALT-like".

## Constraints & Assumptions
- **DAW mode is measured already** (device tests 2026-11-23, PR #111; the 1:1 switch of all tracks is its own plan,
  PRD `lcxl3-daw-mode`, PR #112). Two routes, decided in task 001:
  - **A. DAW pages** (CC 30 = 1 or 2): every button, LED and the screen reach SC; knobs and faders arrive on `DAW Out`
    channel 16 as 7-bit CCs. Whether faders can be 14-bit there is unknown (measure). Follows the 1:1 switch epic.
  - **B. Own custom mode (slot 3) + DAW mode on:** 14-bit NRPN faders possible (set in Components, measure); only
    Shift (ch 7 CC 63), Record (CC 118), Play (CC 116) and the small button next to Solo/Arm (CC 104) reach SC;
    Track, Page, Solo/Arm, Mute/Select send nothing; only Record/Play LEDs colourable. SC must send ch 7 CC 30 = the
    custom mode after DAW mode on.
  - If fine pitch matters more than buttons, B; if 14-bit works on the DAW pages, A wins.
- **Still to measure:** NRPN 14-bit faders in a custom mode; any 14-bit option on the DAW pages; the Launchpad MK3
  model (Mini or X), programmer-mode notes and LED messages.
- **14-bit as NRPN, not 14-bit CC:** a 14-bit CC sends its fine half on CC + 32, and our faders CC 5-11 would collide
  with the button CCs 37-43. The track gets its own custom mode (LC slot 3), so modes 1 and 2 stay as they are.
- **Labels:** this track uses the ALT's names (Amplitude, Angle, Frequency, Shape, Push …), an agreed exception to
  "one name per job" (Brightness / Space / Level / Pattern). The track has no Pattern button: the SC test "every track
  reacts to its Pattern button" needs a skip for it, as for the one-pattern stems.
- **"All knobs at 0 must sound good":** Amplitude knobs at 0 are silent here. The track sets a start state on load and
  sends it to the LC (encoders take SC's values); to be confirmed with the user in task 001.
- **Microtonal scales:** the manual lists the names, not the cent values. Values come from cited sources (or the
  user tunes them by ear); unverified tunings are left out, not guessed.
- Rebuild of an idea, not a product copy: no Cyma Forma branding, logos or panel art in the player.

## Out of Scope
- Launchkey (no device yet; later: keys as the ALT's MIDI channel 1, gates into Outline).
- Mic / audio input into Outline (later), pre/post routing, Outline mix, Leon light sensors.
- ADSR and portamento CCs, MIDI modes 2-4, per-note microtuning editor on the device.
- Auto-perform scripts and takes for this track (later, once the controls are stable).
- Reverb, master volume, a second Launchpad page.
- Changes to the shared custom modes 1 and 2 or to other tracks.

## Dependencies
- Hardware: one LC XL 3, one Launchpad MK3 (Mini or X), Novation Components for the slot-3 custom mode.
- `docs/reference/lcxl3-daw-mode.md` (open tests 1-4), `sc/tools/midi-trace.scd`.
- Engine: `sc/lib/controls.scd` (device table, pickup, feedback), the player's Live view (`tools/trajectory/`).
