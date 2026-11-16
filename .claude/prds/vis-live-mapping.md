---
name: vis-live-mapping
description: Make the player's visuals follow the live sound - knobs, fader and loudness move the dots, colour carries music
status: backlog
created: 2026-11-16T16:05:25Z
---

# PRD: vis-live-mapping

## Executive Summary

The player's visuals (`tools/trajectory`, Strudel path) draw every stem as a dot: x = pan, y = pitch, glow = energy.
Playing the controllers barely changes the picture: Brightness does not move a dot, a fader at 0 leaves the dot on
screen, loudness is divided out, and colour is fixed by the stem's name. This epic makes every dot a truthful,
readable picture of what that stem sounds like right now.

## Problem Statement

What the code does today (checked in `strudel-source.mjs`, `make-tapped.mjs`, `render.mjs`):

| Dimension | Today | Why it fails |
|---|---|---|
| y (low-high) | `frequencyOf`: note pitch; drums a fixed Hz (kick 60, snare 1800, hats 8000), raised only by `hpf`; `lpf` used only for sounds with no note and no drum name | Brightness (row 1 = `lpf` in `strip()`) does not move notes or drums: higher brightness on hats leaves them where they are |
| x (left-right) | event `pan` 0…1 → −1…1; no `pan` = 0 | Correct where a stem pans; most stems never set `pan`, so they sit in the centre (W widens what is used) |
| Glow, size | amplitude = gain × postgain × velocity, divided by the stem's own running peak (decays 0.995 per event), square root | The fader and Master are divided out: a stem at fader 0.2 looks as loud as at 1 after a few bars |
| Fader at 0 | `strip()` gates the stem: no events; the dot decays but is drawn with glow ≥ 0.2 and stays until 10 s without events | The dot does not hide |
| Colour | fixed per role by stem name (kick orange, bass cerulean, hats near-white, pads indigo, leads teal) | Carries no musical information |
| z (depth) | event `room` | Used only by the "clean" look; Space knobs may act on a bus, not on the event (to verify) |
| Layers | one stem = several layers (e.g. bass with an octave below); every event overwrites x/y | y flickers between layers of one stem |

## User Stories

1. **Performer (Jojo / Jonas) turning a knob.** As a performer I want to see my move.
   - Acceptance: turning Brightness up on the hats stem moves its dot up visibly (≥ 5 % of screen height from knob 0
     to 1) within one bar; Brightness on a synth or bass moves its dot too.
2. **Performer pulling a fader.** As a performer I want a muted stem to disappear.
   - Acceptance: fader at 0 → the dot is gone within one second (all three looks); fader up → it comes back.
3. **Audience watching the projection.** As a viewer I want louder to look bigger and brighter.
   - Acceptance: the same stem at fader 1 is drawn larger and brighter than at fader 0.3; Master scales all dots.
     A stem that is quiet in the mix looks smaller than a loud one.
4. **Viewer reading colour.** As a viewer I want colour to tell me something about the sound, while still knowing
   which dot is which.
   - Acceptance: hue stays the stem's role family; tint (saturation / lightness / a second channel) follows
     brightness, space (reverb/delay share) and drive. Turning Space up on a stem changes its tint visibly.
5. **Us checking the mapping.** As developers we want proof that the axes show the live values.
   - Acceptance: a Node check plays a track with scripted knob moves and asserts the lines (x, y, e, colour inputs)
     change in the expected direction.

## Functional Requirements

- FR1 **y = pitch shifted by filter.** y is where the stem's energy sits: base = note pitch or drum base, pulled down
  by `lpf`/`cutoff` below it and pushed up by `hpf` above it (log scale 20 Hz–20 kHz as today).
- FR2 **Loudness absolute.** `e` = the event's level in the mix (gain × postgain × velocity, including fader and
  Master), on one fixed scale for all stems (dB-like), no per-stem normalisation.
- FR3 **Hide at 0.** A stem whose last level is 0, or that sends no events for its hold time, is not drawn (no glow
  floor); label hidden with it.
- FR4 **Size and brightness from loudness.** Radius and glow alpha/lightness grow with `e` in deck, ocean and clean.
- FR5 **Colour.** Hue = role (as today, so stems stay recognisable); tint from three sound values: brightness
  (filter), space (room / delay share), drive (shape / distort / crush). Exact mapping decided in the epic; labels
  mode (L) shows a small legend.
- FR6 **Tap carries what the mapping needs.** `make-tapped.mjs` sends the event keys FR1–FR5 read (e.g. `delay`,
  `shape`, `distort`, `crush`, `size`); if Space acts on a bus rather than the event, the value is obtained another
  way (documented).
- FR7 **One position per stem.** Layers of one stem do not make the dot flicker: x/y per stem from the loudest (or
  level-weighted) layer within a short window.
- FR8 **x-axis honest.** Pan stays the event `pan`; README states which stems pan and that W widens the used range.
- FR9 **Verified.** A Node check (in `npm run verify` or the player's tests) proves FR1–FR3 and FR5 on a live track
  with scripted controller moves.

## Non-Functional Requirements

- Sound unchanged: the tap reads events only; `/strudel-optimize` comparison of a tapped vs untapped track stays
  identical.
- Frame time in fullscreen does not grow by more than 1 ms ("clean" was 1–3 ms per frame).
- The trajectory line format stays backward compatible: the audio-analysis path (`analyse.mjs`) still renders; new
  fields are optional.
- Settings Hard↔Soft and Raw↔Smooth keep working on the new values.

## Success Criteria

- The Node check passes: Brightness 0 → 1 on hats moves y by ≥ 0.05; fader 0 → no line with e > 0 after 1 s;
  fader 0.3 vs 1 gives e ratio matching the gain ratio on the chosen scale; Space 0 → 1 changes the space colour input.
- Manual run in the player with auto-perform (`every-button.json` plus a new knob sweep script) shows each effect
  on 007–010; Jonas confirms it reads right.
- No change in sound (event-by-event compare) and frame time within budget.

## Constraints & Assumptions

- Strudel path only (player and strudel.cc tap); the audio-analysis path keeps its band logic.
- Brightness = `lpf` in every live track's `strip()` (to confirm per track); Space = reverb/delay send, possibly on a
  bus (to confirm).
- M2 Air shared with other agents: one heavy job at a time.

## Out of Scope

- New looks, camera work or redesign of deck/ocean/clean beyond size, brightness, colour and hiding.
- Audience feedback, KPI display, video export (README "Open" list).
- Changing tracks' sound, controller layout or `@ctl` names.
- The audio-analysis path (`analyse.mjs`, Scarlett input).

## Dependencies

- `tools/trajectory/strudel-source.mjs`, `make-tapped.mjs`, `render.mjs`, `settings.mjs`, `autoperform.mjs` and
  `perform/` scripts.
- `tools/strudel-sim` (scenario runner) for the Node check.
- Shared `strip()` block in 007–010 (`tools/shared/`) as the source of Brightness and Level.
