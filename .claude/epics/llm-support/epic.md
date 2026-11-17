---
name: llm-support
status: backlog
created: 2026-11-17T10:59:43Z
updated: 2026-11-17T11:30:00Z
progress: 0%
prd: (none, scoped from docs/player-future.md ideas 1 and 2)
github: (will be set on sync)
---

# Epic: llm-support

## Overview

Today Claude works on this repo only from outside the player: in a terminal session, through skills (`/strudel-mix`,
`/strudel-optimize`, `/lab-board`, `/auto-perform` …). The player knows nothing about it. `docs/player-future.md`
idea 1 proposes one way in: click a control, chat, Claude writes a new track file. This epic asks the bigger question
first: what should the player ask Claude to do, and what is the smallest bridge that carries all of it?

### Scope review: is "click a control, chat, new track file" too narrow?

It is a good first slice of the plumbing and a poor frame for the whole feature. Reasons:

- **It is the slowest and riskiest use case.** An agent run that edits Strudel code and then passes `npm run verify`
  takes much longer than a knob move (not measured yet; task 1 measures it). The edit must keep the house rules
  (knobs at 0 sound good, CPU gates, `@shared` blocks) and the track cannot swap without a gap. That is fine for
  producing: the agent works on a new file next to the track and the user decides when to load it. Live use (steering
  or swapping while a set plays) is out of scope here; a later epic scopes how producing and performing meet.
- **Cheaper use cases need the same plumbing.** A question ("what does Thin do here?", "why is Pad silent?") and a
  request for a designed performance ("a two-minute build, then a breakdown") need the same pieces as an edit: a
  selection, a chat panel, a server-side agent run, a gate before anything plays. Only the output differs.
- **The agent cannot hear.** It reads code and tool output (`scenario`, `audibility`, `compare`). The user's ear
  decides, as in the `/auto-perform` skill. Any use case that claims "sounds better" is wrong by design; the epic
  keeps the player from ever saying so.
- **Free chat is the wrong first interface.** One text box hides what the agent may touch. Modes (Explain,
  Produce), each with its own prompt, allowed tools and allowed output paths, are safer and teach the user what to ask.

So the epic builds one bridge and two modes on it, aimed at producing: making and changing material offline, with
gaps and waiting allowed. Using the agent while a set plays is a separate scoping step, later.

### Modes

| Mode | You ask | Claude produces | Gate before it plays |
|---|---|---|---|
| **Explain** | "what does this knob do", "why is it silent" | text, read-only | none (no write) |
| **Produce: script** | "build for 2 minutes, then a breakdown" | auto-perform script (JSON) in `perform/<track>/` | `check-perform` |
| **Produce: track** | "make the hats darker when Brightness is low" | new track file `NNN-<name>-v2.strudel` | `npm run verify`, then the user listens |

Out of this epic, on purpose:
- **Compose** ("play Rudolph", a Guitar Pro file) belongs to `producer-mode-guitar-pro` and later epics. The bridge is
  built to carry it.
- **Live use**: an agent steering controls or swapping code while a set plays, and a gapless `swap(code)`. Producing
  can wait for an answer; a set cannot. How producing and performing meet is scoped in its own epic later.

## Architecture Decisions

- **The Claude Code CLI, not the API.** The server spawns `claude -p --output-format stream-json` (flags checked:
  `--allowedTools`, `--add-dir`, `--include-partial-messages`, `--resume`). It uses the user's own login, loads
  `CLAUDE.md` and every project skill without a copy, and puts no key in the repo. Cost: Claude Code must be installed
  on the machine that runs the player. Task 1 confirms this on a real call.
- **Same shape as the Tools page.** `agent.mjs` copies the guard rules of `tools.mjs`: own-page Origin / Host check, no
  CORS, one run at a time (409 while busy), `DELETE` stops the whole process group, events stream as SSE. Paths never
  come from the request; the track is a catalogue id and the server looks up the file.
- **Modes, not chat.** Each mode is a server-side record: prompt template, allowed tools, allowed output paths. A run
  ends with a path check on `git status` before and after: a change outside the mode's paths fails the run and shows
  the paths. Nothing is deleted or reverted automatically.
- **Context is a contract.** The page sends `{ track, mode, selection, state }`: selection = what was clicked (kind,
  label, CC), state = current CC values, chapter, bar. The server adds code lines from the `@ctl` comment and the track
  text. One selection registry on the page (`selection.mjs`); the LC view control is the first target, a stem dot, a
  script section or a bar can register later.
- **The agent only writes new files.** A script under `perform/<track>/` or a track variant next to the track, never
  an overwrite. The player loads them as it loads any script or track: scripts play through the virtual `LCXL3 Auto`
  port (a human still wins by moving a control last), `-v2` files show up in the catalogue without a change
  (`catalogue.mjs` already lists every tagged `NNN-name.strudel` in a track folder). The agent does not touch the
  virtual port itself.
- **Approval is by ear.** After the gate passes the player offers the result ("Play v2", "Play script"); it never rates
  it. Gate failures are shown with the tool output, and the user can send the failure back to the agent.
- **Loading is Stop → load → Play.** A gap is fine while producing.
- **Measured state comes later.** When `meta.mjs` (player-future idea 2) exists, `state` gets energy and density per
  bar. This epic leaves a slot for it, nothing more.

## Technical Approach

### Server (`tools/trajectory/`)
- `agent.mjs`: routes `POST /agent/<mode>` (SSE), `DELETE /agent`, `GET /agent/modes`. Spawns the CLI with the mode's
  prompt and tool list; parses stream-json into `text`, `tool`, `file`, `gate`, `done` events; keeps the session id per
  chat for `--resume`.
- `agent-modes.mjs`: the mode table (prompt, allowed tools, allowed paths, gate command). Prompts point at the existing
  skills and docs instead of repeating them (`/auto-perform` rules, README "Auto-perform", `CLAUDE.md` house rules).
- Gate runner reuses `tools.mjs` steps (`check-perform`, `verify`).

### Page
- `selection.mjs`: registry and click handling; LC view controls register first.
- Chat drawer (key C, same pattern as the Settings drawer): mode picker, selection chip, streamed text, tool lines, gate
  result, Stop, Approve / Play buttons. Help panel entry.

### Safety
- Server on 127.0.0.1 only (already true); run log under `tools/trajectory/agent-log/` (git-ignored); hard timeout per
  run; max turns per mode; the allowed-paths check above.

## Implementation Strategy

1. Spike the bridge with Explain: smallest real end-to-end run, measure startup and answer time.
2. Add Produce: script before Produce: track: its output is bounded JSON and it already has a checker and a player.
3. Add Produce: track last, once the gates and the path check have proven themselves on the two safer modes.

## Task Breakdown Preview

1. **Agent bridge + Explain spike** — `agent.mjs`, one mode (Explain, read-only tools), SSE, Origin / Host guard, one
   run at a time, stop; curl test for 409 / 403 / 404; record startup and answer time. (sequential, first)
2. **Selection and context** — `selection.mjs`, LC view controls register; server builds the context from catalogue id,
   `@ctl` name and track text. (parallel with 1)
3. **Chat drawer** — key C, mode picker, selection chip, streaming, session continue, stop. (after 1 and 2)
4. **Explain mode, finished** — prompts, allowed tools (read, grep, `scenario`), answers cite control names and code
   lines; user tries five real questions on 008 and 010. (after 3)
5. **Produce: script** — prompt from the `/auto-perform` rules, output `perform/<track>/<name>.json`, gate
   `check-perform`, player lists it and plays it through the virtual port; real controller still wins. (after 3)
6. **Produce: track** — output `NNN-<name>-v2.strudel` in the track folder, path check, gate `npm run verify`, diff
   view, catalogue offers it, Play via Stop / Play. (after 5)
7. **Guardrails** — path-check tests (agent told to write elsewhere fails the run), timeout, max turns, run log, cost
   shown in the drawer. (after 5; before 6 is merged)
8. **Docs** — README section, `CLAUDE.md` line, Help panel entry, a short "what to ask" list per mode. (last)

## Dependencies

- Internal: player hub (merged), auto-perform script format and the `/auto-perform` skill (PR 26),
  `check-perform.mjs`, `npm run verify`, `tools.mjs` guard pattern, `catalogue.mjs`.
- External: the `claude` CLI on the machine that runs the player.
- Other epics: `vis-live-mapping`, `drop-buildup` and `launchkey-knob-target` also change the player or the LC view;
  merge one at a time. `producer-mode-guitar-pro` is the first Compose input and will use the bridge once it exists.

## Risks

- **Latency.** A Produce: track run may take minutes. Mitigation: the epic is for producing, where waiting is fine; the
  drawer streams progress and the old track keeps playing meanwhile.
- **Broken tracks.** An edit can pass verify and still sound wrong or load the CPU. Mitigation: new file only, user
  listens, the old track keeps playing.
- **A server that runs an agent.** Mitigation: localhost, Origin / Host check, path check, allowed tools per mode, one
  run at a time. No mode gets network tools.
- **Cost and login.** Every run uses the user's Claude account. Mitigation: show usage per run; Jojo needs his own
  login on his machine.
- **Pile of `-v2`, `-v3` files.** Follows the repo rule: superseded variants are deleted once the winner is committed.

## Open Questions

1. Is Explain useful on its own, or too basic once the user knows the tracks? If too basic, tasks 4 and 5 swap order.
2. Does Jojo use it too (own login, own machine)?
3. Should free chat exist at all later, or only the modes?
4. Should the page-side selection also cover stems (dots) and script sections in this epic, or only controls?
5. Live use is left for a later epic. Name it when producing works (candidates: agent-steered controls, gapless swap,
   a "next section" request during a set).

## Success Criteria (Technical)

- `POST /agent/explain` with a foreign `Origin` gets 403; an unknown mode or track id gets 404; a second run while one
  runs gets 409; `DELETE /agent` stops the run and its child processes.
- Clicking a control in the LC view and asking "what does this do" returns an answer that names the `@ctl` text and the
  code lines, with no file changed.
- A Produce: script request writes a script that passes `check-perform` and plays in the player; moving a real control
  during playback wins until the script moves it again.
- A Produce: track request writes `NNN-<name>-v2.strudel` that passes `npm run verify`; the original file is
  byte-identical; the catalogue lists the new file; the diff is shown before Play.
- A run that writes outside the mode's allowed paths fails and names the paths (tested by a prompt that asks for it).
- Every run has a log entry and ends within the mode's timeout.

## Estimated Effort

8 tasks, about 3-4 working sessions. Order: 1 and 2, then 3, then 4 and 5, then 7, then 6, then 8. Critical path: 1 → 3
→ 5 → 6. The first useful result (Explain on a clicked control) lands after task 4.
