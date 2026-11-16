---
name: player-hub
status: backlog
created: 2026-11-15T18:58:29Z
updated: 2026-11-16T15:00:00Z
progress: 0%
prd: .claude/prds/player-hub.md
github: (will be set on sync)
---

# Epic: player-hub

## Overview

Turn `tools/trajectory/player.html` into the repo's main tool: served at `http://localhost:8766`, the one interface
through which tracks (and lab boards) are played, with the visual settings in a closed panel and the Node checks on a
Tools page. The analysis page stays as an extra tool on the Tools page. Each track file is the single source of
truth: the player taps it in memory when it loads it, no tapped copies on disk, and the same file still plays when
pasted into strudel.cc. Keep the Strudel engine behind one module so a SuperCollider engine can replace it later. An
open-loop script player (auto-perform) feeds a virtual controller so tracks and player features can be tried without
MIDI hardware. Moving from the playing track to another one on the Fog knob is the separate epic `track-transitions`;
where the player may go next (LLM edits, producer mode, closed-loop auto-perform) is `player-vision`.

## Architecture Decisions

- **Stay build-free.** Plain HTML pages + ES modules served by `server.mjs`, as today. Shared look and nav in one
  small `ui.css` + `nav.mjs`; no framework.
- **One source per track, tapped in memory.** `make-tapped.mjs` becomes a pure `tapSource(src, name) → code`; the
  server returns the tapped code for a catalogue id on each request, built from the track file as it is now. No
  `tapped/` folder, no `refreshTapped` in the hook or `npm run watch`. A CLI wrapper still prints the tapped code
  to the clipboard for strudel.cc + visuals. Track files never depend on the player: anything the player adds
  (tap, `midin` / `midikeys` shims, banks) lives in the player, so each track keeps playing on strudel.cc.
- **Engine seam, not engine swap.** New `engine-strudel.mjs` exports `{ ready, load(code), stop(), cycle(), onEvent }`
  and owns everything Strudel: `initStrudel`, banks/soundfonts, `evaluate`, `hush`, the `midin` / `midikeys` shims and
  the `strudelMirror` / `WebMidi` globals. `cycle()` reads the current cycle for the auto-perform scheduler. `midi.mjs`
  owns Web MIDI (ports map, last-moved per CC, key queue) and is handed to the engine. A future `engine-sc.mjs` (OSC to
  scsynth via a local bridge) takes the same `midi.mjs` input. Latency-critical path (keys) stays: MIDI message →
  ports map → scheduler query, no server hop.
- **Settings are data.** One `settings.mjs` describes every visual setting (id, kind, default, key, apply fn);
  the panel and the keyboard shortcuts are generated from it and persisted in `localStorage` (try/catch).
- **Server owns the catalogue.** `GET /catalogue` returns live tracks and lab boards with ids and kinds; `GET
  /track/<id>` returns the tapped code. The Tools page and the player both pick from this list, so no page ever
  sends a free path.
- **Local routes are guarded.** The server checks `Origin` and `Host` on `POST /run`, `DELETE /run` and `/perform`,
  and sends no wildcard CORS on them: binding to 127.0.0.1 alone does not stop a web page in the user's browser from
  calling localhost.
- **Tools are a whitelist.** `tools.mjs` maps command ids → `{ script, args(kind), label }`. `POST /run/<id>` with a
  catalogue entry id spawns `node <script>` in `tools/`, streams stdout/stderr over SSE, one job at a time
  (409 while busy), `DELETE /run` kills it. Page tools (the analysis page) are listed as links next to them.
- **Virtual controller = a port in the map.** `midi.mjs` keeps the ports map; auto-perform adds `LCXL3 Auto` to it
  (the name contains `LCXL3`, so every one-file track gives it the full single layout and its Launchkey lookup fails
  as without a Launchkey). Values live per CC with a last-moved stamp, so the existing last-moved-wins rule lets a real
  controller take over; no change in the tracks and none in the engine seam beyond `cycle()`. `autoperform.mjs` holds
  the script player: JSON steps in bars (`{ bar, cc, value, ramp? }`, `{ bar, press }`), scheduled against the
  engine's cycle clock, not `setTimeout`, so tempo changes do not drift; a press is held for two scheduler ticks.
  Scripts sit in `tools/trajectory/perform/<track>/*.json`, listed by `/catalogue`. The port is also what
  `track-transitions` uses to drive the Fog knob. Spike findings: `.claude/epics/player-hub/auto-perform-spike.md`.
- **Play never waits on Web MIDI.** `midi.mjs` races `requestMIDIAccess()` against a 2 s timeout and continues with
  no hardware ports ("No MIDI" in the status line).
- **Analysis kept as a tool.** `index.html` moves to `analyse.html` with `analyse.mjs` / `analyse-file.mjs`
  unchanged; the Tools page links to it. Not developed further in this epic.
- **Relay stays for now.** The visuals read `/stream`, fed by the tapped track's `POST /events`. An in-page shortcut
  (tap → renderer directly) is noted for later.

## Technical Approach

### Frontend Components
- `player.html` (served at `/`): top bar = track list (optgroups Live / Lab), Play, Stop, status, ⚙ Settings, Tools
  link. Auto-hide kept. Picking another track while one plays stops it and loads the new one (a gapless transition is
  `track-transitions`).
- Settings panel: slide-in drawer, closed on load, key S; generated from `settings.mjs`; holds Hard ↔ Soft,
  Raw ↔ Smooth, Axes, Labels, Beat rings, LC frame, Look, Pan width, and an Auto-perform section (script select,
  Start / Stop, key P) so the top bar stays at six controls.
- `tools.html`: pick a command, pick a track/board (from `/catalogue`, filtered by kind), Run / Stop, live log;
  links to page tools (Analysis).
- Shared `nav.mjs` + `ui.css` for player, tools and analysis pages.

### Backend Services
- `server.mjs`: `/` → `player.html`; `/analyse.html`; `/catalogue`; `/track/<id>` (tapped on request); `/run/<id>`
  (POST, SSE output), `/run` (DELETE); existing `/events`, `/stream`; `/perform/<track>/<script>` (script JSON);
  `/tapped/` removed. Every id in a path must be a catalogue entry (or a listed script of one), else 404.
- `catalogue.mjs`: scans `tracks/<genre>/NNN-<name>/NNN-<name>.strudel` (one-file live tracks: has
  `// @mode 16 Mode 1`) and `lab/**/*.strudel` at any depth (not `archive/`); marks which ones tap (master
  `stack(` found) and lists each track's auto-perform scripts. Set 011 is not listed (it carries no `Mode 1` tag).
- `tools.mjs`: whitelist: check-sounds, measure (loudness), layouts + syx, stem-lab sync, stem-lab check,
  set build (`npm run set`).

### Infrastructure
- `.claude/launch.json` unchanged (already starts `server.mjs` on 8766); README, `CLAUDE.md` updated.
- Removed: `tools/trajectory/tapped/`, its `.gitignore` line, `refreshTapped` in `lcxl-layout/hook.mjs` and
  `watch.mjs`.
- Strudel.cc check: each one-file track and each tappable board evaluates with only what strudel.cc provides
  (`strudel-sim` run without the player's globals).

## Implementation Strategy

1. Engine seam + in-memory tap first (touches `player.html`, `make-tapped.mjs`, `server.mjs`), proving with a
   before/after event comparison on 008 that nothing audible moved.
2. Play without MIDI (task 8), a small fix to `midi.mjs`, then the settings panel (task 2), then auto-perform
   (task 9, needs `midi.mjs` and the settings drawer). From here on every later task can be tested at the desk with
   a script instead of a controller.
3. Then two streams in parallel on separate files: catalogue (`server.mjs`, `catalogue.mjs`), Tools page
   (`tools.html`, `tools.mjs`, server route). Task 9's `/perform` route and catalogue listing of scripts start as a
   fixed path next to the track and move into the catalogue when task 3 lands.
4. Lab boards once the catalogue exists.
5. Docs last.

Risks: lab boards may not all have a top-level master `stack(` that tapping needs (fallback: list the rest
greyed); spawning tools from a page on a shared machine (mitigated: whitelist, one job, Origin / Host check); open
epics `launchkey-knob-target` and `drop-buildup` change the LC view the player opens, coordinate merges.
Auto-perform: scripts name CCs, so a layout change breaks them (mitigated: a script check that every CC exists in the
track's `@ctl`, in `tools/`, run by `npm run verify`); a held button shorter than two ticks is missed by
`cycleButton`; cycle-clock scheduling needs `cycle()` on the engine seam.

## Task Breakdown Preview

1. **Serve player at `/`, analysis page as a tool, engine + MIDI modules, in-memory tap** — move `index.html` to
   `analyse.html`; `engine-strudel.mjs` (with `cycle()`), `midi.mjs`; `tapSource` + `/track/<id>`; remove `tapped/`
   and `refreshTapped`; event-by-event check on 008 before/after. (sequential, first)
2. **Settings panel** — `settings.mjs`, drawer, key S, localStorage; top bar down to play controls.
   (parallel after 1)
3. **Catalogue** — `catalogue.mjs`, `/catalogue`; player list grouped Live / Lab; strudel.cc check per entry.
   (parallel after 1)
4. **Tools page** — `tools.html`, `tools.mjs` whitelist, `/run` SSE, Origin / Host check, one job at a time, stop;
   Analysis link. (after 3: uses catalogue; parallel with 2)
5. **Lab boards in the player** — make boards playable, grey out the ones that do not tap. (after 3)
6. **Shared nav + look** — `nav.mjs`, `ui.css` across player, tools, analysis. (after 2 and 4)
7. **Docs** — README rewrite (player-first), `CLAUDE.md` (player = main tool, single source, Tools page,
   auto-perform for testing without controllers), remove stale notes. (last)
8. **Play without Web MIDI** — timeout on `requestMIDIAccess()` in `midi.mjs`, "No MIDI" status; Play works in the
   built-in browser pane. (after 1, small)
9. **Auto-perform script player** — virtual `LCXL3 Auto` port in `midi.mjs`, `autoperform.mjs`, script JSON in bars,
   `/perform` route and catalogue listing, settings section + key P; scripts: 010 spike run, press-every-button; CC
   check against `@ctl` (also in `npm run verify`); proof by `scenario` / event dump that the scripted run matches
   the spike (stems in, Tension, Chapter, Break, Fog, fade). (after 1, 2 and 8; pulled forward: runs before 3-7)

## Dependencies

- Internal: `make-tapped.mjs`, `render.mjs`, `smoothing.mjs`, `strudel-source.mjs`, the CLI tools listed in the PRD,
  the layout hook.
- External: `@strudel/web@1.2.6` (unpkg), Web MIDI in Chrome.
- Other epics: `launchkey-knob-target`, `drop-buildup` (LC / live view). `track-transitions` builds on tasks 1, 3
  and 9 of this epic.

## Success Criteria (Technical)

- `GET /` returns the player; `analyse.html` loads from the Tools page and works as before.
- No `tapped/` folder, no `refreshTapped` caller; editing a track and pressing Play plays the edit, no other step.
- Each one-file live track, pasted into strudel.cc, plays (strudel-sim run with only strudel.cc's globals).
- `strudel-sim/compare.mjs` (or an in-browser event dump) shows identical events for 008 before and after task 1.
- No `@strudel` / unpkg import outside `engine-strudel.mjs` in the page code.
- Top bar ≤ 6 controls; settings persist across reload; all 7 old keys + S work.
- `/catalogue` lists all 4 live tracks; `/track/<id>` for an unknown id gets 404.
- Each whitelisted tool runs from `tools.html` with the same output as its CLI; a second run while busy gets 409;
  an unknown id gets 404; a `POST /run` with a foreign `Origin` is refused.
- At least one lab board plays with controllers in the player.
- With no controller, Play starts 010 (also where `requestMIDIAccess()` never answers: starts after 2 s, "No MIDI"
  shown); the 010 script takes it from silence to a full mix and back to silence, heard and visible in the LC view.
- A real control moved during a script wins until the script moves it again; a script naming a CC that the track's
  `@ctl` does not have fails the check.

## Estimated Effort

9 tasks, about 4–5 working sessions. Order: 1 → 8 → 2 → 9, then 3 and 4 in parallel, then 5, 6, 7. Critical
path: 1 → 3 → 5 → 7. Task 9 goes right after 2 so that tasks 3-7 are tested at the desk without a controller.
