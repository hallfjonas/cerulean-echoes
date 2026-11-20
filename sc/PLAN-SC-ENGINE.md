# Plan: SuperCollider as the player's second engine

> Status: **plan, nothing built yet** (2026-11-20). Assumes the `sc` branch (PR #42) is merged into `main`.
> Related: `SC-MIGRATION.md` (why SC), `sc/PLAN-UI.md`, `sc/PLAN-STEM-LIBRARY.md`.

## Decision

The player (`tools/trajectory/`) stays the one front end for everybody. SuperCollider becomes a second engine behind
it, next to the Strudel engine. We neither rebuild the player's features in SC nor run Strudel inside SC.

Why this works: the player is already split along this seam.

- `engine-strudel.mjs`: the page talks to the engine only through `{ ready, load, stop, cycle, cps, output }`.
- `midi.mjs`: controller input is separate "so another engine can take the same input".
- `render.mjs` draws trajectory lines and does not care where they come from; `strudel-source.mjs` is one adapter.
- Recording (`recorder.mjs`), takes (`take.mjs`) and auto-perform (`autoperform.mjs`) use only the engine interface.
- SC already talks OSC to a browser (`sc/ui/bridge.mjs`, `sc/lib/ui.scd`): `/ce/cc`, `/ce/lkcc`, `/ce/lknote` in,
  `/ce/beat`, `/ce/state`, `/ce/layout`, `/ce/ccs` out.

Goal for players: one launcher starts SC (headless) and the player, the browser opens on the MIDI panel. Nobody sees
the SC IDE.

## Rules during the transition

- One engine per track: a track with an `.scd` version plays on SC, otherwise on Strudel. The catalogue says which.
- Controllers always go straight to SC when SC plays (no browser in the sound path). If the browser or Node crashes,
  music and controllers keep running.
- Every phase ends with something playable; nothing on `main` breaks for the Strudel tracks.

## Phases

### Phase 0: merge and agree (both)
- Merge PR #42 into `main`.
- Agree on this plan, and on the open decisions below (at least D1).
- Done when: `sc/` is on `main`, the Strudel player works unchanged.

### Phase 1: SC engine, load / stop / clock (track 009)
- `sc/lib/ui.scd`: new OSC messages `/ce/load <trackId>`, `/ce/stop`; `/ce/beat` already gives the clock.
- Fold `sc/ui/bridge.mjs` into `tools/trajectory/server.mjs` (one Node process, one port; OSC ⇄ WebSocket).
- `tools/trajectory/engine-sc.mjs` with the same interface: `load` / `stop` over OSC, `cycle()` and `cps()` from the
  beat messages, `output()` = none (see Phase 4).
- `catalogue.mjs`: lists SC tracks (`sc/tracks/*/*.scd`) with `engine: 'sc'`; the page picks the engine per entry.
- MIDI panel: fed from SC's `/ce/state` and `/ce/ccs` (SC owns the controller state), so it shows what SC hears.
- Done when: pick 009 (SC) in the sidebar, Play, the LC moves the sound, the MIDI panel follows; Stop stops;
  switching to a Strudel track and back works.

### Phase 2: visualization from SC
- SC sends one OSC message per note when it sounds: stem, pitch (Hz), pan, level, reverb share, length
  (`/ce/note`, from the step engine `sc/lib/steps.scd`, timestamped with the server latency).
- `tools/trajectory/sc-source.mjs`: turns them into trajectory lines like `strudel-source.mjs` does.
- Done when: the Visualization view of 009 on SC looks like 009 on Strudel at the same controller states
  (side by side check).

### Phase 3: auto-perform and takes
- Auto-perform: the virtual controller sends its steps to SC as `/ce/cc`, `/ce/lkcc`, `/ce/lknote` (all exist) instead
  of into Strudel. The scripts in `perform/<track>/` stay as they are.
- Takes: capture keeps listening to the hardware in the browser (macOS lets several apps read one device); the bar
  comes from SC's clock. Replay = auto-perform.
- `check-perform.mjs` / `check-replay.mjs`: run against the SC engine too.
- Done when: `perform/009/dance-floor.json` plays on SC from bar 0 to the end; a saved take replays bar by bar.

### Phase 4: recording in SC
- SC records its master output itself (`DiskOut`), started and stopped over OSC; `recording.mjs` keeps the folder,
  file names and the `.json` sidecar (same format, `engine: 'sc'`).
- The recording level meter in the sidebar comes from SC (peak per tenth of a second over OSC).
- Done when: Record during a human set and during auto-perform each writes a valid WAV + sidecar in
  `recordings/009-house/`; `check-recording.mjs` passes.

### Phase 5: launcher
- One double-click start on macOS: starts `sclang` headless with `sc/live.scd`, the player server, opens the browser.
  Bundling SC into the app is allowed (GPL); first version may require an installed SC.
- Clean shutdown: closing the launcher stops SC and Node (no leftover processes).
- Done when: someone who never used SC starts a set from a fresh Mac with the README's three steps.

### Phase 6: the other tracks
- Repeat Phase 2/3 checks for 007, 008, 010 (already ported to SC).
- Then decide per new track (001, 002, 016…) whether it gets ported (D1).

## Open decisions

- **D1 Source of truth for tracks.** While both engines exist, a track lives twice (`.strudel`, `.scd`). Options:
  (a) new tracks are written for SC only from Phase 1 on; (b) Strudel stays the authoring place and tracks are ported
  when they are "finished"; (c) date when Strudel copies stop being maintained. Needs both players.
- **D2 Strudel engine long term.** Keep it as the no-install "try it" mode (browser only), or remove it once all
  tracks run on SC.
- **D3 Remote / phone access.** The player already serves its pages; SC's bridge already served phones. Decide whether
  the player listens on the local network in Phase 1 or later (security: today it only answers its own pages).
- **D4 Tools that test Strudel only** (`npm run verify`, audibility, compare, strudel-sim): which get an SC counterpart
  (`tools/sc-port/` already renders and compares both sides offline).

## Risks

- Two clocks: the page's bar counter must follow SC's clock, not its own; otherwise scripted steps drift.
- Note messages for the visuals add OSC traffic per note; keep them out of the audio thread (language side only).
- Recording in SC means the WAV no longer passes through the browser; the sidecar must still line up with the take.
