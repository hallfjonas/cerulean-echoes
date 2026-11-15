---
name: player-hub
status: backlog
created: 2026-11-15T18:58:29Z
updated: 2026-11-15T20:30:00Z
progress: 0%
prd: .claude/prds/player-hub.md
github: (will be set on sync)
---

# Epic: player-hub

## Overview

Turn `tools/trajectory/player.html` into the repo's main tool: served at `http://localhost:8766`, the one interface
through which tracks (and lab boards) are played, with the visual settings in a closed panel and the Node checks on a
Tools page. Remove the unused landing page and its analysis code. Keep the Strudel engine behind one module so a
SuperCollider engine can replace it later. Finish with a written scope and evaluation of three future ideas (LLM edits
from the UI, smooth transitions between tracks, auto-perform).

## Architecture Decisions

- **Stay build-free.** Plain HTML pages + ES modules served by `server.mjs`, as today. Shared look and nav in one
  small `ui.css` + `nav.mjs`; no framework.
- **Engine seam, not engine swap.** New `engine-strudel.mjs` exports `{ ready, load(code), stop(), onEvent }` and
  owns everything Strudel: `initStrudel`, banks/soundfonts, `evaluate`, `hush`, the `midin` / `midikeys` shims and
  the `strudelMirror` / `WebMidi` globals. `midi.mjs` owns Web MIDI (ports map, last-moved per CC, key queue) and is
  handed to the engine. A future `engine-sc.mjs` (OSC to scsynth via a local bridge) takes the same `midi.mjs`
  input. Latency-critical path (keys) stays: MIDI message → ports map → scheduler query, no server hop.
- **Settings are data.** One `settings.mjs` describes every visual setting (id, kind, default, key, apply fn);
  the panel and the keyboard shortcuts are generated from it and persisted in `localStorage` (try/catch).
- **Server owns the catalogue.** `GET /catalogue` returns live tracks and lab boards with paths and kinds; it taps
  stale or missing copies on the way (`makeTapped`). The Tools page and the player both pick from this list, so no
  page ever sends a free path.
- **Tools are a whitelist.** `tools.mjs` maps command ids → `{ script, args(kind), label }`. `POST /run/<id>` with a
  catalogue entry id spawns `node <script>` in `tools/`, streams stdout/stderr over SSE, one job at a time
  (409 while busy), `DELETE /run` kills it.
- **Relay stays for now.** The visuals read `/stream`, fed by the tapped track's `POST /events`. An in-page shortcut
  (tap → renderer directly) is noted for later, not done here: it changes `make-tapped.mjs` output, which the hook
  and the set also touch.

## Technical Approach

### Frontend Components
- `player.html` (served at `/`): top bar = track list (optgroups Live / Lab), Play, Stop, status, ⚙ Settings, Tools
  link. Auto-hide kept.
- Settings panel: slide-in drawer, closed on load, key S; generated from `settings.mjs`; holds Hard ↔ Soft,
  Raw ↔ Smooth, Axes, Labels, Beat rings, LC frame, Look, Pan width.
- `tools.html`: pick a command, pick a track/board (from `/catalogue`, filtered by kind), Run / Stop, live log.
- Shared `nav.mjs` + `ui.css` for both pages.

### Backend Services
- `server.mjs`: `/` → `player.html`; `/catalogue`; `/run/<id>` (POST, SSE output), `/run` (DELETE); existing
  `/events`, `/stream`; drop `/tapped/` once the player uses `/catalogue`.
- `catalogue.mjs`: scans `tracks/<genre>/NNN-<name>/NNN-<name>.strudel` (one-file live tracks: has
  `// @mode 16 Mode 1`) and `lab/**/*.strudel` at any depth (not `old/`, not `archive/`); taps on demand.
- `tools.mjs`: whitelist: check-sounds, measure (loudness), layouts + syx, stem-lab sync, stem-lab check,
  set build (`npm run set`).

### Infrastructure
- `.claude/launch.json` unchanged (already starts `server.mjs` on 8766); README, `CLAUDE.md` updated.
- Removed: `index.html`, `analyse.mjs`, `analyse-file.mjs` (nothing imports them; `render.mjs` and
  `strudel-source.mjs` mention `analyse.mjs` in comments, update those).

## Implementation Strategy

1. Cleanup + engine seam first (one task, touches `player.html` hardest), proving with a before/after event
   comparison on 008 that nothing audible moved.
2. Then three streams in parallel on separate files: settings panel (`player.html` bar + `settings.mjs`), catalogue
   + auto-tap (`server.mjs`, `catalogue.mjs`), Tools page (`tools.html`, `tools.mjs`, server route).
3. Lab boards in the player once catalogue exists.
4. Future-ideas evaluation can run any time (doc only).
5. Docs last.

Risks: lab boards may not all have a top-level master `stack(` that `makeTapped` needs (today `lab/bass/synth` and
the two tutorials; fallback: tap only boards it accepts, list the rest greyed); spawning tools from a page on a
shared machine (mitigated: whitelist, one job);
open epics `launchkey-knob-target` and `drop-buildup` change the LC view the player opens, coordinate merges;
`english-repo` translates `player.html` text and renames paths the catalogue scans, run it before or after, not in
parallel.

## Future Ideas: first take (input for task 007)

| Idea | What exists | Needs | First slice | Gut effort |
|---|---|---|---|---|
| LLM edit from UI | `@ctl` comments name every control; LC view knows CC → name; hook re-taps after edit | click target → `{track, ctl, code range}`; server endpoint calling `claude -p` on a new track file (non-destructive rule); hot reload without stop | Click a knob in LC view → prompt box → Claude writes `NNN-<name>-v2.strudel` → player offers it | M |
| Smooth transitions | Set 011 = generated stack of 4 frozen tracks with a position knob; `check-set.mjs` | live tracks (one-file) instead of frozen duals in the set; tempo glide between BPMs; CPU of two tracks at once | Player plays the set file from the catalogue; then generate the set from one-file tracks | M–L |
| Auto-perform | `midin` already reads from a ports map with last-moved-wins per CC | a virtual port (`ports.set('Auto', …)`) fed by a script timeline (bar-quantised CC moves) or an LLM agent per phrase; human move overrides by last-moved | Script player: JSON timeline of CC moves played into a virtual port, human can grab any control | S (script) / L (AI) |

## Task Breakdown Preview

1. **Remove landing page, serve player at `/`, extract engine + MIDI modules** — delete `index.html` and
   analysis-only code; `engine-strudel.mjs`, `midi.mjs`; event-by-event check on 008 before/after.
   (sequential, first)
2. **Settings panel** — `settings.mjs`, drawer, key S, localStorage; top bar down to play controls.
   (parallel after 1)
3. **Catalogue + auto-tap** — `catalogue.mjs`, `/catalogue`, taps stale/missing; player list grouped Live / Lab.
   (parallel after 1)
4. **Tools page** — `tools.html`, `tools.mjs` whitelist, `/run` SSE, one job at a time, stop. (after 3: uses
   catalogue; parallel with 2)
5. **Lab boards in the player** — make boards tappable/playable, grey out the ones that are not. (after 3)
6. **Shared nav + look** — `nav.mjs`, `ui.css` across player and tools. (after 2 and 4)
7. **Future ideas scope & eval** — `docs/player-future.md`: the three ideas, prerequisites, effort, risks,
   SuperCollider touchpoints, recommendation, first slice each. (parallel, any time)
8. **Docs** — README rewrite (player-first), `CLAUDE.md` (player = main tool, Tools page), remove stale notes.
   (last)

## Dependencies

- Internal: `make-tapped.mjs`, `render.mjs`, `smoothing.mjs`, `strudel-source.mjs`, the CLI tools listed in the PRD,
  the layout hook.
- External: `@strudel/web@1.2.6` (unpkg), Web MIDI in Chrome.
- Other epics: `launchkey-knob-target`, `drop-buildup` (LC / live view), `english-repo` (paths, player text).

## Success Criteria (Technical)

- `GET /` returns the player; `index.html`, `analyse*.mjs` gone; no dangling imports.
- `strudel-sim/compare.mjs` (or an in-browser event dump) shows identical events for 008 before and after task 1.
- No `@strudel` / unpkg import outside `engine-strudel.mjs` in the page code.
- Top bar ≤ 6 controls; settings persist across reload; all 7 old keys + S work.
- `/catalogue` lists all 4 live tracks without a manual tap; deleting a tapped copy and reloading recreates it.
- Each whitelisted tool runs from `tools.html` with the same output as its CLI; a second run while busy gets 409;
  an unknown id gets 404.
- At least one lab board plays with controllers in the player.
- `docs/player-future.md` exists with a recommendation per idea.

## Estimated Effort

8 tasks, about 3–4 working sessions. Critical path: 1 → 3 → 4 → 6 → 8. Task 7 and task 2 off the critical path.
