# cerulean-echoes

Live-performed Strudel tracks (strudel.cc), played with a Novation Launch Control XL 3 via `midin()`.
Talk to the user in German; code comments stay in English. Explain audio basics plainly.

## Layout
- `tracks/` — tracks (`NNN.strudel`, variants as `NNN-<name>.strudel`)
- `sound-samples/` — boards for trying sounds (drum board, bass board); not tracks
- `snippets/` — small helpers and tests (`midi-test.strudel`)
- `tools/` — Node tools (run `npm install` in `tools/` once): equivalence/CPU check, per-stem loudness, layout sheets

## Rules
- **Non-destructive:** a new version of a track goes into a new file; never overwrite an existing track unless asked.
- Ask before changing sound, effects, orbits, reverb/delay, naming or the controller layout, unless that is the task.
- Single quotes for plain text in Strudel (double quotes are parsed as mini-notation).
- Boards and stems need rhythm, not just held notes.

## Controller mapping (LC XL 3)
- Custom Mode 16 (channel 16): columns 1-7 = stems. Fader CC 5-11, knob rows CC 13-19 / 21-27 / 29-35, buttons CC 37-43 / 45-51.
- Mode 2 = same layout, every CC + 48 (melodies). Column 8 is global in both modes:
  fader via `lastMoved` (last moved wins), knobs via `coupled` (endless encoders, relative deltas).
- In code: `col(n)` / `col2(n)` → `{ hpf, lpf, char, level, btn }` (see `tracks/006-lean.strudel`).

## Writing efficient Strudel (CPU)
Strudel computes every event of every layer even when it is silent; dense tracks then drop out.
- Gate silent parts so they are not queried at all: `gate(cond, pat) = cond.fmap(on => on ? pat : silence).innerJoin()`.
  Gate stems on fader/global level > 0 (`strip()`), crossfade layers where `fadeMain`/`fadeExtra` reach 0,
  overtone layers on mode and density. Only gate where the gain is exactly 0, so the sound stays identical.
- Stateful closures (`cycleButton`, `coupled`, `lastMoved`): create each once per control, never inside a gated
  pattern only; query them every tick via a `stateTaps` stack in the master (`.filterValues(() => false)`),
  otherwise button presses are lost while the stem is gated.
- Keep the safety net at the end of the master: `.filterValues(v => (v.gain ?? 1) * (v.postgain ?? 1) > 0)`.
- Prove a restructuring is inaudible with `/strudel-optimize` (compares old and new event by event).

## Layout sheets
Each tagged track has a generated `<track>-layout.pdf` (Typst). The source of truth is the `// @ctl` comments in
the track; a hook regenerates the PDF after every edit. See `/lcxl-layout`. Hand-written `*-layout.typ` files are older sheets.

## Machine
M2 Air, 16 GB, shared with other agents: the global resource rules apply (one heavy job at a time, test small first).
