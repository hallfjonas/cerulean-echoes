---
name: recording-replay
status: backlog
created: 2026-11-17T20:30:00Z
updated: 2026-11-17T20:30:00Z
progress: 0%
prd: (none, scoped from the request "recording in the player, for human and auto sets, and replay of a human set")
github: (will be set on sync)
---

# Epic: recording-replay

## Overview

The player plays a track and lets a human (Launch Control XL 3s, Launchkey) or an auto-perform script drive it. Nothing
is kept afterwards: the sound is gone, and so is what the hands did. This epic adds two kinds of recording that share
one Record control:

| Recording | What is kept | Source | Use |
|---|---|---|---|
| **Audio** | the master output as a WAV file | human set or auto-perform, no difference | listen back, share, measure |
| **Performance** | every control move, button press, key and pad, in bars | the human (and the auto input) | **replay it with the auto-performer** |

The second one is the point of the epic. A live set you played is turned into an auto-perform script, so you can:
play the set again without hands, change the track (`-v2` copy, a new pattern, a new level) and hear the same
performance on it, trim or loop a section, and play live on top of it (last moved wins, as today).

### Where it stands today (what the code does)

- `autoperform.mjs` plays `perform/<track>/*.json`: steps `{ bar, cc, value, ramp? }` and `{ bar, press }`, into the
  virtual input `LCXL3 Auto`. **Launch Control only.** Nothing can play Launchkey keys, drum pads, knobs (CC 31-38) or
  the mod wheel.
- `midi.mjs` keeps the last value of every CC per input, and the keys pressed since the last query. It keeps no
  history, and keys keep no time.
- `analyse.html` records, but that is the audio analysis (JSONL of an input), not the player's output.
- The engine (`engine-strudel.mjs`) never hands out its audio output.
- Nothing in the player writes files except the Tools page jobs. `recordings/` does not exist.

## Spike findings

Task 1, 2026-11-17. Read against the bundle the player loads (`@strudel/web@1.2.6/dist/index.mjs` from unpkg) and
measured in the player (port 8777, lab-kick-kick-lab and 010-ambient-house, no controllers, virtual inputs driven
from the console).

**Correction to "Where it stands".** Launchkey replay already exists on main: `autoperform.mjs` plays `keys`, `pad`
and `lk` steps into the virtual input `Launchkey MK4 25 Auto` (`midi.LK_AUTO_PORT`, also in the wrapped Web MIDI);
`compile`, `valueChanges` and `check-perform` know them. Task 5 shrinks to the v2 additions below.

**(a) Audio tap point.** Every sound superdough makes runs orbit → `connectToDestination` → one `ChannelMergerNode` →
one `GainNode` (`destinationGain`) → `ctx.destination`. The controller that owns it (`getSuperdoughAudioController`)
is not exported in 1.2.6, so the node cannot be fetched. Measured: during play exactly one node connects to
`ctx.destination` (a `GainNode`, gain 1), and it survives Stop and a new Play (`resetGlobalEffects` would rebuild it,
but nothing in the player calls it). Decision: the wrap is the method, not the fallback. `engine-strudel.mjs` wraps
`AudioNode.prototype.connect` before `initStrudel`: a connect to an `AudioDestinationNode` goes to a `masterBus`
GainNode instead, which feeds `ctx.destination` and the recorder worklet. This also catches a rebuilt
`destinationGain` and the `dough` worklet, which connects to the destination directly. Context: 48 kHz, stereo.

**(b) Clock reset.** `evaluate` does not reset the clock: it only swaps the pattern while the scheduler runs.
Measured: Play on a playing board went on at cycle 7.25; Stop then Play restarted at cycle 0 (`Cyclist.stop` sets
`lastEnd = 0`, `start` zeroes the cps anchor). The player's Play and auto-perform Start call `engine.load` without
`hush`, so today a script starts at whatever cycle the track was on (`startBarOf` rounds to the nearest bar) and
`<a b>` alternations and slow patterns start in a random phase. **Change to the plan:** `engine.load` gets a fresh
start (`hush()` before `evaluate`) for every load the capture or a replay starts from; with it, bar 0 = cycle 0, the
query grid is the same on every run, and no phase wait is needed. A small task, done with task 5. Values set before
the load survive it (`midi.mjs` port maps), hence the bar-0 snapshot in the take.

**(c) Key timing.** The scheduler queries in bursts every 100 ms (two queries of 50 ms each), about 0.2 s ahead.
A key is placed at the start of the next query, which is `engine.cycle()` (`lastEnd`) at the moment it arrives.
Measured on 010 (cps 0.5): 8 keys landed on cycles 14.1, 14.6, 15.05 … 16.85, all on the 0.05-cycle burst grid,
0.08-0.12 cycles after `getTime()` at the press. So the take stores `engine.cycle()` at arrival, and the performer
fires a key on the first tick where that bar has been reached: the next query starts at the same cycle, the key lands
in the same place. Not measured end to end (no take writer yet): a burst of three queries (a late timer) can skip
the recorded boundary and put a key one query (25 ms at cps 0.5) late; `check-replay` (task 7) will show it.
CC moves follow the same rule (`midin` signals read the value at query time).

**Format.** The script format v2 is fixed in `step-format-v2.md`: the existing steps, `velocity` on pads, the `take`
meta field, a 1e-6 bar tolerance in the performer, take and recording file names and the audio sidecar.

**Plan changes.** Task 5 is small (pad velocity, `take` meta in `check-perform`, bar tolerance, fresh-start load).
Tasks 2, 4 and 5 can start now. The risk "replay waits for the recorded phase" is gone once loads hush first.

## Architecture Decisions

- **Two recordings, one control.** A Record button (key R) in the top bar and a "Recording" section in the drawer. The
  audio part is armed explicitly; the performance part is not (next point).
- **Performance is always captured, saved on request.** Every play of a track starts a new in-memory capture
  (control values over time, in bars; a few KB per minute). "Save take" writes it. No arming, so a good set is never
  lost because Record was not pressed. The capture must start at the track load: the tracks keep state
  (`cycleButton` counts presses, `lastMoved`), so a replay is only faithful from a fresh load, never from the middle.
- **Replay = the existing auto-performer, extended.** A take is a normal script with a few more step kinds, played by
  `createPerformer`. Auto-perform, take replay and edited takes are one mechanism, one drawer list.
- **The script format grows, old scripts stay valid.** Launchkey steps are new kinds (`key`, `pad`, and CC steps tagged
  with the input); an old script reads exactly as before. `valueChanges` and `compile` keep their meaning, so the Node
  scenario tool and `check-perform` still work.
- **A second virtual input for the Launchkey.** `midin('Launchkey')` / `midikeys('Launchkey')` match by name and the
  no-name case leaves out every port with "Launchkey" in it (`midi.mjs`, `matching`). So the take needs
  `Launchkey Auto` next to `LCXL3 Auto`, also in the wrapped `requestMIDIAccess` the tracks' LC view uses.
- **Bars, not seconds.** The performance clock is the engine's cycle clock, like auto-perform: steps stay on the bar.
  Valid while the track's tempo is fixed (it is in every live track). Takes store the bar as a float; no snap to a grid.
- **Thin the knob streams.** A knob sweep arrives at about 100 messages per second. The take keeps the shape as
  `ramp` steps (Ramer-Douglas-Peucker, tolerance 1 MIDI step), so a take stays small and a human can read and edit it.
- **Audio goes to disk through the server, outside git.** `recordings/<track>/<date>-<time>-<human|auto>.wav` plus a
  `.json` sidecar (track id, track file hash, source, script id, start cycle, sample rate). `recordings/` is
  gitignored (CLAUDE.md: no file over 10 MB; 10 min stereo 16-bit is about 100 MB). Chunks stream to the server while
  recording, so a crash or a closed tab loses seconds, not the set.
- **Takes go to `perform/<track>/takes/`, uncommitted.** They are listed in the drawer with the scripts. A take worth
  keeping is moved up to `perform/<track>/` and committed by hand. `check-perform` validates takes too.
- **Same origin, same guard.** The new `POST`/`PUT` endpoints accept only this server's own pages (`fromOwnPage`),
  like `/perform/*`; the file name never comes from the page, only the track id from the catalogue.

## Technical Approach

### Audio recorder (page)
- Tap point: the Strudel master output. Task 1 finds it (`getAudioContext()` is on `window` through
  `strudel-globals.mjs`; the output node of superdough is the candidate). Fallback: wrap `AudioNode.connect` to a
  `ctx.destination` target.
- Capture with an `AudioWorklet` (PCM, 16-bit, 48 kHz as the context runs) and post chunks of about 1 s to the server.
  Not `MediaRecorder`: its WebM/Opus is lossy and the analysis tools want WAV.
- Auto-perform: "Record audio" checkbox next to Start; recording starts with the script and stops at its end plus a tail
  of 4 s (reverb and delay ring out). Human: Record starts now, Stop ends it.
- Meter and elapsed time in the top bar; a red state while recording, so it is not forgotten.

### Performance capture (`midi.mjs` + a new `take.mjs`)
- `midi.mjs` gets `onMessage(cb)`: every message of every non-DAW input and of both virtual inputs, with port name,
  status, data and `performance.now()`. The keys queue is left alone, so `takeKeys` keeps its meaning.
- `take.mjs` (pure, runs in the browser and in Node): collects messages with their bar (`engine.cycle()` at the
  moment of arrival), and converts to script steps:
  - snapshot of every CC at load (the controllers already have positions) as bar-0 steps;
  - CC on a button (known from the track's `@ctl` tags through `controlsOf`, or from the fixed Launchkey list) →
    `press` steps; CC on a knob or fader → thinned `ramp` steps;
  - Launchkey note-on → `key` steps (note, velocity, channel); drum pads (channel 10) → `pad` steps; the
    Launchkey has no note-off in `midikeys`, so none is kept;
  - mod wheel and knobs CC 31-38 → CC steps tagged `input: 'lk'`.
- A held press is shorter than two scheduler ticks sometimes; the take keeps the press, the performer holds it for two
  ticks as today.

### Replay (`autoperform.mjs`)
- `compile` learns the new step kinds; the tick loop writes keys and pads into the Launchkey virtual port (`setAutoKey`)
  the way it writes CCs into the LC port.
- `midi.addAuto()` also adds `Launchkey Auto` when the script has Launchkey steps, so a track without a Launchkey
  still plays a take that has none, and a take with keys plays on a track that listens.
- Overdub for free: a real controller moved during replay wins per CC (last moved), a key played during replay adds to
  the take's keys. Saving during a replay records both (the auto input is captured too, so the saved take is the
  union).
- Start from a fresh load, as Start does today. The start phase must match the original (task 1: does a reload reset
  `scheduler.now()`, or do `<a b>` alternations and slow patterns start from another phase?).

### Server (`server.mjs`)
- `PUT /recording/<track>/<name>` appends a chunk, `POST /recording/<track>/<name>/finish` closes the WAV header and
  writes the sidecar; `POST /take/<track>` writes a take JSON. Track ids are checked against the catalogue; names are
  generated by the server. Disk guard: refuse below 2 GB free.
- `GET /perform/<track>/<script>` also serves `takes/<name>`.

### Check and fidelity
- `check-perform.mjs`: validate the new step kinds (Launchkey CC and note ranges, pads are channel 10 notes 36-51).
- Fidelity: a replayed take must play what the human played. `check-replay` runs in the player (and as a Tools
  command): replay a take while recording the tapped Strudel events (the player already receives them,
  `strudel-source.mjs`) and compare with the events of the original play, which the take's sidecar keeps. Differences
  are listed per bar; a take the player cannot reproduce is reported, not hidden.

## Implementation Strategy

1. Spike first (task 1): the three things that decide the design are unknown: the audio tap point, whether a reload
   resets the cycle clock, and whether Launchkey keys replay with the same timing as played.
2. Audio recording and performance capture are independent until the Record UI. They run in parallel after task 1.
3. Replay of Launchkey steps (task 5) can start as soon as the step format is agreed in task 1; the converter (task 6)
   needs both capture and the format.
4. Fidelity check last: it needs a take and a replay.

## Task Breakdown Preview

1. **Spike** — tap point for the master output; does `evaluate` reset the cycle clock; do keys replayed through a
   virtual port land in the same bar and place as played; write findings and the step format into this epic. Gate:
   the format is agreed. (first)
2. **Audio recorder** — worklet, WAV streaming, server endpoints, `recordings/` (gitignore), sidecar, disk guard.
   (after 1; parallel with 4 and 5)
3. **Record UI** — top-bar button, key R, timer, meter, drawer section, auto-perform "Record audio" option, stop with
   tail. (after 2)
4. **Performance capture** — `midi.onMessage`, `take.mjs` collector, per-play session buffer, Node tests with a
   hand-made message list. (after 1; parallel with 2 and 5)
5. **Launchkey in auto-perform** — step kinds `key` / `pad` / tagged CC, `Launchkey Auto` virtual port (also in the
   wrapped Web MIDI for the LC view), `compile` and `valueChanges`, `check-perform`. (after 1; parallel with 2 and 4)
6. **Take to script** — thinning, button/knob split, snapshot, "Save take" button, `POST /take`, takes listed in the
   drawer, promote note in the Help panel. (after 4 and 5)
7. **Replay fidelity** — `check-replay`: replay a take, compare tapped events with the original, per-bar report,
   Tools command. (after 3 and 6)
8. **Docs** — `tools/trajectory/README.md` (Recording, takes, script format v2), `CLAUDE.md` player paragraph and
   layout (`recordings/`, `perform/<track>/takes/`), Help panel text. (after 7)
9. **Take editing (optional)** — trim start / end bars, loop a section, mute one control; play a take as a base while
   live. Only if the first replays show it is needed. (after 6)

## Dependencies

- Internal: the player and `midi.mjs`, `engine-strudel.mjs`, auto-perform (merged), the catalogue, `strudel-source.mjs`
  taps, `check-perform.mjs`, `controlsOf` (reads `@ctl`).
- `produce-perform-split`: recording and "Save take" write files, and its Perform workspace refuses writing work.
  Recording is a Perform activity, so the two endpoints must stay allowed there. Decide when both are scheduled.
- `llm-support`: Claude changes the track in a working copy (`-v2`); a saved take replayed on that copy is the
  listening loop it needs. The take's sidecar names the track file hash it was played on.
- Other epics that touch the player page (`vis-live-mapping`, `drop-buildup`, `launchkey-knob-target`): merge one at a
  time; this epic adds a top-bar control, a drawer section and a `midi.mjs` hook.

## Risks

- **Not every track is deterministic from a reload.** Phase of `<a b>` alternations, slow patterns and any `rand`
  seeded by time can differ. Mitigation: task 1 measures it; if the clock cannot be reset, replay waits for the
  recorded phase (cycle mod 8); the sidecar keeps the start cycle; the fidelity check reports what differs.
- **Key timing.** `midikeys` puts a note at the start of the scheduler query, not at the moment of the press, so a key is
  placed up to one tick (50 ms) off. The replay uses the same path, so it lands the same way; the take keeps the bar
  to the precision the clock gives.
- **Audio tap loads the CPU.** A worklet and chunk posts on a 16 GB machine with a dense track. Mitigation: measure in
  task 2 on 008 and 010 (the densest), with and without recording; chunk size is a constant.
- **Disk.** WAV is big. Mitigation: outside git, free-space guard, 16-bit, a visible size counter.
- **Two LCs and the take.** Several controllers write the same CC; last moved wins. The take records the merged
  stream in time order, so replay gives the same winner. A take is not per controller.
- **A track changes after the take.** A moved or renamed control makes steps point at nothing. `check-perform` reports
  it; the sidecar's track hash tells the take is old.
- **Scope drift into editing.** Mitigation: editing is task 9, optional.

## Open Questions

1. Is "always capture the performance, save on request" right, or should Record arm both audio and performance
   together (simpler to explain, loses an unarmed good set)?
2. Audio format: 16-bit WAV is the plan. Is 24-bit or float needed (for mastering)? MP3/Opus export is left out.
3. Should the audio recording be post-master (what the room hears, with the global Master fader) or per stem? Plan:
   master only; stems stay the job of `/strudel-mix` tools.
4. Where do takes live long-term: `perform/<track>/takes/` uncommitted, or a committed folder with small files?
5. Is the recorded take also the base for a "second player" (Jojo plays his half, Jonas records over it)?
6. Do Jojo and Jonas record on one machine at the same time? Then two LCs feed one take; is that wanted?

## Success Criteria (Technical)

- Pressing Record on a playing track (human) and stopping gives a WAV in `recordings/<track>/` that plays in a normal
  audio player, with a sidecar; the same during an auto-perform run, ending 4 s after the script's last bar.
- No dropout caused by the recorder on 008 and 010 on the M2 Air (task 2 measures, in the epic's findings).
- After a human play of 3 minutes with LC knobs, buttons, Launchkey keys and pads, "Save take" writes a take under
  `perform/<track>/takes/` that `check-perform` passes and the drawer lists.
- Replaying that take yields the same tapped events as the original play for every bar, or `check-replay` names the
  bars and the reason (state before load, phase, randomness).
- Replaying on a track copy with a changed pattern plays the same control moves (the recorded steps, not the sound).
- Old scripts (`every-button.json`, `spike-run.json`) play exactly as before; `npm run verify` stays green.
- `recordings/` and `takes/` are not in git; `CLAUDE.md` and the README describe both.

## Estimated Effort

9 tasks (the last optional), about 3-4 working sessions. Critical path: 1 → 4 and 5 → 6 → 7 → 8. Audio (2 → 3) runs
beside it. Task 1 decides whether the replay needs a clock fix, which is the main schedule risk.
