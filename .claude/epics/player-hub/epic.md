---
name: player-hub
status: backlog
created: 2026-11-15T18:58:29Z
updated: 2026-11-15T21:50:00Z
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
pasted into strudel.cc. The player can switch from the playing track to any other track with a transition on the
Fog knob (set mode, as in 011). Keep the Strudel engine behind one module so a SuperCollider engine can replace it
later. Finish with a written scope and evaluation of three future ideas (LLM edits from the UI, auto-perform,
producer mode).

## Architecture Decisions

- **Stay build-free.** Plain HTML pages + ES modules served by `server.mjs`, as today. Shared look and nav in one
  small `ui.css` + `nav.mjs`; no framework.
- **One source per track, tapped in memory.** `make-tapped.mjs` becomes a pure `tapSource(src, name) → code`; the
  server returns the tapped code for a catalogue id on each request, built from the track file as it is now. No
  `tapped/` folder, no `refreshTapped` in the hook or `npm run watch`. A CLI wrapper still prints the tapped code
  to the clipboard for strudel.cc + visuals. Track files never depend on the player: anything the player adds
  (tap, `midin` / `midikeys` shims, banks) lives in the player, so each track keeps playing on strudel.cc.
- **Engine seam, not engine swap.** New `engine-strudel.mjs` exports `{ ready, load(code), stop(), onEvent }` and
  owns everything Strudel: `initStrudel`, banks/soundfonts, `evaluate`, `hush`, the `midin` / `midikeys` shims and
  the `strudelMirror` / `WebMidi` globals. `midi.mjs` owns Web MIDI (ports map, last-moved per CC, key queue) and is
  handed to the engine. A future `engine-sc.mjs` (OSC to scsynth via a local bridge) takes the same `midi.mjs`
  input. Latency-critical path (keys) stays: MIDI message → ports map → scheduler query, no server hop.
- **Settings are data.** One `settings.mjs` describes every visual setting (id, kind, default, key, apply fn);
  the panel and the keyboard shortcuts are generated from it and persisted in `localStorage` (try/catch).
- **Server owns the catalogue.** `GET /catalogue` returns live tracks and lab boards with ids and kinds; `GET
  /track/<id>` returns the tapped code. The Tools page and the player both pick from this list, so no page ever
  sends a free path.
- **Transitions reuse the set.** `make-set.mjs` gets a second entry point: build a two-track set (A → B) in memory
  from one-file tracks, same frame (`set-frame.strudel`), same Fog-knob set mode and chapter latches the players
  know from 011. Per-track set parameters (grid BPM, slow, phrase, orbit offset, transpose) move out of
  `make-set.mjs` into a tag in each track (`// @set grid 140 slow 1 phrase 4 …`), so any pair can be built. The
  set 011 build stays as it is.
- **Tools are a whitelist.** `tools.mjs` maps command ids → `{ script, args(kind), label }`. `POST /run/<id>` with a
  catalogue entry id spawns `node <script>` in `tools/`, streams stdout/stderr over SSE, one job at a time
  (409 while busy), `DELETE /run` kills it. Page tools (the analysis page) are listed as links next to them.
- **Analysis kept as a tool.** `index.html` moves to `analyse.html` with `analyse.mjs` / `analyse-file.mjs`
  unchanged; the Tools page links to it. Not developed further in this epic.
- **Relay stays for now.** The visuals read `/stream`, fed by the tapped track's `POST /events`. An in-page shortcut
  (tap → renderer directly) is noted for later.

## Technical Approach

### Frontend Components
- `player.html` (served at `/`): top bar = track list (optgroups Live / Lab), Play, Stop, status, ⚙ Settings, Tools
  link. Auto-hide kept. While a track plays, picking another track offers Switch (stop + load) or Transition
  (two-track set, Fog knob in set mode starts at A).
- Settings panel: slide-in drawer, closed on load, key S; generated from `settings.mjs`; holds Hard ↔ Soft,
  Raw ↔ Smooth, Axes, Labels, Beat rings, LC frame, Look, Pan width.
- `tools.html`: pick a command, pick a track/board (from `/catalogue`, filtered by kind), Run / Stop, live log;
  links to page tools (Analysis).
- Shared `nav.mjs` + `ui.css` for player, tools and analysis pages.

### Backend Services
- `server.mjs`: `/` → `player.html`; `/analyse.html`; `/catalogue`; `/track/<id>` (tapped on request);
  `/transition/<from>/<to>` (tapped two-track set); `/run/<id>` (POST, SSE output), `/run` (DELETE); existing
  `/events`, `/stream`; `/tapped/` removed.
- `catalogue.mjs`: scans `tracks/<genre>/NNN-<name>/NNN-<name>.strudel` (one-file live tracks: has
  `// @mode 16 Mode 1`) and `lab/**/*.strudel` at any depth (not `archive/`); marks which ones tap (master
  `stack(` found) and which can transition (`// @set` tag).
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
2. Then three streams in parallel on separate files: settings panel (`player.html` bar + `settings.mjs`), catalogue
   (`server.mjs`, `catalogue.mjs`), Tools page (`tools.html`, `tools.mjs`, server route).
3. Lab boards and transitions once catalogue exists (transitions also need `make-set.mjs`; one at a time with any
   change to set 011).
4. Future-ideas evaluation can run any time (doc only).
5. Docs last.

Risks: lab boards may not all have a top-level master `stack(` that tapping needs (fallback: list the rest
greyed); `make-set.mjs` patches are written against the frozen dual sources: one-file tracks differ (single layout,
`lcCc`, Launchkey stem), so the patches need a one-file variant, and two tracks plus the crossfade cost CPU (gate the
silent one, as the set does); the generic set path must not change 011 (`check-set.mjs` before/after); spawning
tools from a page on a shared machine (mitigated: whitelist, one job); open epics `launchkey-knob-target` and
`drop-buildup` change the LC view the player opens, coordinate merges.

## Future Ideas: first take (input for task 008)

| Idea | What exists | Needs | First slice | Gut effort |
|---|---|---|---|---|
| LLM edit from UI | `@ctl` comments name every control; LC view knows CC → name; tracks reload from source on request | click target → `{track, ctl, code range, current value}`; a chat panel that shows what is selected and how it is set now, keeps the conversation, and shows each change (diff + new value) before it plays; server endpoint calling `claude -p` (session kept per chat) on a new track file (non-destructive rule); hot reload without stop | Click a knob in LC view → panel shows control name, its code and current CC value → chat → Claude writes `NNN-<name>-v2.strudel` → player offers it, chat continues on v2 | M |
| Auto-perform | `midin` reads from a ports map with last-moved-wins per CC | a virtual port (`ports.set('Auto', …)`) fed by a script timeline (bar-quantised CC moves) or an LLM agent per phrase; human move overrides by last-moved | Script player: JSON timeline of CC moves played into a virtual port, human can grab any control | S (script) / L (AI) |
| Producer mode | chapters per track, set frame for sections in sequence, Tension / Break | a song form (`intro 8 bars, verse 1, chorus, verse 2, chorus, outro`) mapped to track sections; a genre description (e.g. indie pop) → stems; a timeline that drives chapter / tension per section | Song form as JSON → timeline of chapter + Tension moves on an existing track (reuses auto-perform's virtual port) | L |

## Task Breakdown Preview

1. **Serve player at `/`, analysis page as a tool, engine + MIDI modules, in-memory tap** — move `index.html` to
   `analyse.html`; `engine-strudel.mjs`, `midi.mjs`; `tapSource` + `/track/<id>`; remove `tapped/` and
   `refreshTapped`; event-by-event check on 008 before/after. (sequential, first)
2. **Settings panel** — `settings.mjs`, drawer, key S, localStorage; top bar down to play controls.
   (parallel after 1)
3. **Catalogue** — `catalogue.mjs`, `/catalogue`; player list grouped Live / Lab; strudel.cc check per entry.
   (parallel after 1)
4. **Tools page** — `tools.html`, `tools.mjs` whitelist, `/run` SSE, one job at a time, stop; Analysis link.
   (after 3: uses catalogue; parallel with 2)
5. **Lab boards in the player** — make boards playable, grey out the ones that do not tap. (after 3)
6. **Track transitions** — `// @set` tags in 007-010, two-track set from one-file tracks in `make-set.mjs`,
   `/transition/<from>/<to>`, Switch / Transition in the player; 011 unchanged (`check-set.mjs`). (after 3)
7. **Shared nav + look** — `nav.mjs`, `ui.css` across player, tools, analysis. (after 2 and 4)
8. **Future ideas scope & eval** — `docs/player-future.md`: LLM edits (incl. selection feedback and chat), auto-
   perform, producer mode: prerequisites, effort, risks, SuperCollider touchpoints, recommendation, first slice
   each. (parallel, any time)
9. **Docs** — README rewrite (player-first), `CLAUDE.md` (player = main tool, single source, Tools page,
   transitions), remove stale notes. (last)

## Dependencies

- Internal: `make-tapped.mjs`, `render.mjs`, `smoothing.mjs`, `strudel-source.mjs`, `set/make-set.mjs`,
  `set-frame.strudel`, `check-set.mjs`, the CLI tools listed in the PRD, the layout hook.
- External: `@strudel/web@1.2.6` (unpkg), Web MIDI in Chrome.
- Other epics: `launchkey-knob-target`, `drop-buildup` (LC / live view).

## Success Criteria (Technical)

- `GET /` returns the player; `analyse.html` loads from the Tools page and works as before.
- No `tapped/` folder, no `refreshTapped` caller; editing a track and pressing Play plays the edit, no other step.
- Each one-file live track, pasted into strudel.cc, plays (strudel-sim run with only strudel.cc's globals).
- `strudel-sim/compare.mjs` (or an in-browser event dump) shows identical events for 008 before and after task 1.
- No `@strudel` / unpkg import outside `engine-strudel.mjs` in the page code.
- Top bar ≤ 6 controls; settings persist across reload; all 7 old keys + S work.
- `/catalogue` lists all 4 live tracks; `/track/<id>` for an unknown id gets 404.
- Each whitelisted tool runs from `tools.html` with the same output as its CLI; a second run while busy gets 409;
  an unknown id gets 404.
- At least one lab board plays with controllers in the player.
- While 008 plays, picking 009 → Transition: the Fog knob in set mode moves from 008 to 009 without a stop;
  `check-set.mjs` on 011 unchanged.
- `docs/player-future.md` exists with a recommendation per idea.

## Estimated Effort

9 tasks, about 4–5 working sessions. Critical path: 1 → 3 → 6 → 9. Tasks 2, 4, 5, 7, 8 off the critical path.
