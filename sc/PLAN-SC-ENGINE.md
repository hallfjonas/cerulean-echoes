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
- Merge PR #42 into `main` (done 2026-11-20).
- Agree on this plan; decisions D1-D4 below (taken 2026-11-20).
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

## Decisions (2026-11-20)

- **D1 Source of truth: the SC version, once a track is ported** (today 007, 008, 009, 010). Its `.strudel` file is
  frozen from then on: no more edits, kept only while the Strudel engine still plays it. Tracks not ported yet stay
  Strudel-only until they are.
- **D2 Strudel engine: kept only while it costs no maintenance.** No new features for it; the first time it needs
  real work (a Strudel update breaks it, a player feature would need a Strudel-side copy), it is removed instead.
- **D3 Remote / phone access: not for now.** The player keeps answering only its own pages on this machine.
- **D4 Tools:** see "Tools after the switch" below.

Retired on 2026-11-20 (git history keeps them): the rock, EDM and classical tracks (012, 013, 015) and
016-grroove-sonnet. The producer stays; 012 and 013 are its test fixtures in `tools/producer/fixtures/`.

## Tools after the switch (D4)

Every Node tool today reads `.strudel` files through `tools/strudel-sim` (Strudel in Node). Under D1 a ported track's
`.strudel` is frozen, so these tools stop protecting the tracks we actually edit. Per tool:

| Tool | Job | After the switch |
|---|---|---|
| layout sheets (PDF), per-track `.syx` | printable sheets, control names on the LC display | **retired 2026-11-20.** The `@ctl` texts stay (LC view, MIDI panel, SC UI, `check-perform`); every LC gets the same two modes once (`midi-layouts/lcxl3-mode1.syx` / `-mode2.syx`). |
| `npm run verify` | after an edit: transpile, compare with HEAD, sounds, tags, perform scripts | **SC counterpart `verify-sc`**, small: the track loads headless in `sclang` without errors (a missing sample file counts as an error), `@ctl` tags parse, perform scripts only use controls the track has. No comparison with HEAD. |
| `compare` (old vs new, event by event) | prove a refactor is inaudible | **drop for SC**: tracks may change; we do not prove they stay identical. |
| `audibility`, `measure` (levels) | loudness per stem, SILENT / LOW / CLIPS | **drop for now**: measuring sound is too much burden for how we work; levels are set by ear. |
| `scenario` | controller scenario → events / stems / LC view as text | **later, only if we miss it**: `render.scd` already takes the scenario JSON. |
| `check-sounds`, `samples/sounds.json`, `mirror-sound` | does every sound load in a browser | **drop for SC** (SC loads local files). |
| CPU gating rules, `@shared` blocks, `npm run shared` | Strudel-specific cost and code sharing | **drop for SC**: SC shares code through `sc/lib/`. |
| `tools/sc-port` (Strudel ↔ SC comparison) | proves a port is faithful | **keep only for porting** further tracks, if wanted; a ported track is never compared with its frozen Strudel file again. |
| `set` / `continuum` (011) | the frozen Strudel set | **unchanged, frozen** (low priority); falls away with D2. |
| `producer` | Guitar Pro → Strudel track | **unchanged for now**: writes Strudel. An SC output is a separate decision when the next song comes. |
| `track-map`, `path-lint`, `session-digest`, `lang-scan` | engine-independent | **keep**; `track-map` learns `.scd`. |
| player checks (`check-perform`, `check-replay`, `check-recording`) | auto-perform, takes, recording | **follow the SC engine** (Phases 3 and 4) and become feature tests (below). |

Skills follow their tools: `/strudel-mix`, `/strudel-optimize`, `/lab-board`, `/lab-to-track`, `/add-sample` and
`/auto-perform` each get an SC path when their tool does; until then they say "Strudel tracks only".

## Tests: yes, now — features, not tracks

**Goal: every feature of the software keeps working.** Not a goal: that a track stays exactly the same (tracks are
meant to change), nor measuring sound (too much burden for how we work).

Now is the right time: Phase 1 rewires the player, and what "works" means is easiest to pin down before the second
engine exists. Today `npm test` runs only `trajectory/*.test.mjs` (the producer tests are not in it) and there is no CI.

A feature test asks "does it still do its job", with loose checks (something plays, a value arrives, a file is
written), never "is the output identical". Each runs in seconds; the whole suite in a few minutes.

| Feature | Test (passes when …) |
|---|---|
| Track list | every live track (Strudel and SC) shows up in the catalogue with its engine; a broken file is reported, not hidden |
| Load / play / stop / switch | each engine loads every live track without errors, plays notes once the master fader is up, stops, and switching tracks leaves nothing playing |
| Controllers | a CC from one LC reaches the track; with two LCs the one moved last wins; Launchkey keys and pads play; the mod wheel moves the keys level |
| Pattern buttons, Chapter, Break | a press changes what plays, on the next bar, not before |
| MIDI panel / LC view | a moved control shows its new value and its `@ctl` name |
| Visualization | the engine's notes become trajectory lines (per stem, pan and pitch in range) |
| Auto-perform | every script in `perform/` passes `check-perform` and plays to its end on the engine without errors |
| Takes | a captured take saves as a valid script v2 and replays (`check-replay`, loose bar-by-bar check) |
| Recording | Record writes a WAV with sound in it and a sidecar that matches the take (`check-recording`) |
| Producer | the two fixtures still turn into a track that loads and plays (no exact comparison needed) |
| SC core | the building blocks in `sc/lib/` (mini-notation, latches, last-moved-wins) do their job: a few `UnitTest` cases run headless by one `sclang` script |

How it runs:

- **One command:** `npm test` runs all Node tests plus the `sclang` script; `verify-sc` runs the checks for one
  changed track.
- **Cheap CI:** a GitHub Actions job for the Node tests on every PR; SC in CI later, if at all.
- **Grows with the plan:** each phase adds the tests for what it builds (Phase 1: track list, load/play/stop,
  controllers, MIDI panel; Phase 2: visualization; Phase 3: auto-perform, takes; Phase 4: recording).

Not tests: audio null tests, loudness comparisons, event-by-event track comparisons.

## Risks

- Two clocks: the page's bar counter must follow SC's clock, not its own; otherwise scripted steps drift.
- Note messages for the visuals add OSC traffic per note; keep them out of the audio thread (language side only).
- Recording in SC means the WAV no longer passes through the browser; the sidecar must still line up with the take.
