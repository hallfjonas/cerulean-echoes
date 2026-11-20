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
| `lcxl-layout` (layout sheets, `.syx`), hook | controller sheets and custom modes from `@ctl` | **extend to `.scd`**: SC tracks already carry `// @col` / `// @ctl` in the same format (`sc/ui/README.md`). Needed: without it no `.syx` for SC tracks. Small. |
| `npm run verify` | after an edit: transpile, compare with HEAD, sounds, layout, perform scripts | **SC counterpart `verify-sc`**: the track loads headless in `sclang` without errors, every sample file exists, layout/syx regenerate, perform scripts only use controls the track has, event log equal to HEAD unless the change is meant (see tests below). |
| `compare` (old vs new, event by event) | prove a refactor is inaudible | **SC counterpart**: SC's offline render already writes an event log (`sc/tools/render.scd`); compare two `.scd` versions on the same scenario. Replaces `/strudel-optimize` for SC tracks. |
| `audibility`, `measure` (levels) | loudness per stem, SILENT / LOW / CLIPS | **SC counterpart**: offline render per stem + loudness; `tools/sc-port/batch.py` already measures LUFS and peaks. Needed for `/strudel-mix` on SC tracks. |
| `scenario` | controller scenario → events / stems / LC view as text | **SC counterpart**: `render.scd` already takes the scenario JSON; add the text outputs. |
| `check-sounds`, `samples/sounds.json`, `mirror-sound` | does every sound load in a browser | **drop for SC**: SC loads local files; replaced by the "every sample exists" check in `verify-sc`. |
| CPU gating rules, `@shared` blocks, `npm run shared` | Strudel-specific cost and code sharing | **drop for SC**: SC shares code through `sc/lib/` and has its own CPU behaviour. |
| `tools/sc-port` (Strudel ↔ SC comparison) | proves a port is faithful | **keep only for porting** further tracks; a ported track is no longer compared with its frozen Strudel file. |
| `set` / `continuum` (011) | the frozen Strudel set | **unchanged, frozen** (low priority); falls away with D2. |
| `producer` | Guitar Pro → Strudel track | **unchanged for now**: writes Strudel. An SC output is a separate decision when the next song comes. |
| `track-map`, `path-lint`, `session-digest`, `lang-scan` | engine-independent | **keep**; `track-map` learns `.scd`. |
| player checks (`check-perform`, `check-replay`, `check-recording`) | auto-perform, takes, recording | **follow the SC engine** (Phases 3 and 4). |

Skills follow their tools: `/strudel-mix`, `/strudel-optimize`, `/lcxl-layout`, `/lab-board`, `/lab-to-track`,
`/add-sample` and `/auto-perform` each get an SC path when their tool does; until then they say "Strudel tracks only".

## Tests: yes, now

Now is the right time, for three reasons: (1) under D1 the Strudel↔SC comparison stops guarding the ported tracks, so
the SC tracks need their own safety net before anyone edits them; (2) Phase 1 rewires the player, and the engine
interface is easiest to pin down with tests before the second engine exists; (3) the suite is small today
(`npm test` runs only `trajectory/*.test.mjs`; the producer tests are not in it; there is no CI).

Scope, in this order (each one fast, minutes not hours):

1. **SC core unit tests** (SC's built-in `UnitTest`, run headless by one `sclang` script): `lib/mini.scd` (mini-notation
   cases, taken from `tools/sc-port/mini-check.mjs`), `lib/strudel.scd` (rand / perlin values against stored Strudel
   numbers), latches (`controls.scd`: switch on the bar, not before), `~ce.adsr` / `~ce.rq`, last-moved-wins for
   several LCs.
2. **Golden event logs per SC track** (snapshot tests): each track on a few scenarios (all knobs 0; full mix; every
   pattern button; Chapter / Break) rendered event-only, compared with a stored log. A meant change updates the log in
   the same commit. This replaces "compare with HEAD" and the hour-long audio comparison as the everyday check.
3. **Player contract tests** (`node --test`, like `take.test.mjs`): both engines satisfy `{ ready, load, stop, cycle,
   cps, output }`; OSC encode/decode of the bridge; the catalogue lists `.scd` tracks with `engine: 'sc'`;
   `sc-source.mjs` turns note messages into the same lines as `strudel-source.mjs` for the same notes; the recording
   sidecar format.
4. **One command:** `npm test` runs all Node tests (trajectory and producer) plus the `sclang` tests; `verify-sc` runs
   it for a changed track. A GitHub Actions job for the Node tests is cheap; SC in CI later, if at all.

Not unit tests: the audio null tests and loudness comparisons stay manual (they take about an hour, see the resource
rules).

Where it goes in the phases: 1 and 2 before or with Phase 1 (they guard the tracks), 3 grows with each phase.

## Risks

- Two clocks: the page's bar counter must follow SC's clock, not its own; otherwise scripted steps drift.
- Note messages for the visuals add OSC traffic per note; keep them out of the audio thread (language side only).
- Recording in SC means the WAV no longer passes through the browser; the sidecar must still line up with the take.
