---
name: llm-support
status: backlog
created: 2026-11-17T10:59:43Z
updated: 2026-11-20T18:11:25Z
progress: 0%
prd: (none, scoped from the player vision draft, ideas 1 and 2, in git history)
github: (will be set on sync)
---

# Epic: llm-support

## Overview

Today Claude works on this repo only from outside the player: in a terminal session, through skills (`/strudel-mix`,
`/strudel-optimize`, `/lab-board`, `/auto-perform` …). The player knows nothing about it. This epic puts Claude into
the player, with one bridge and a few modes on it. The headline use case is the iteration loop on a track.

### Primary use case: select an element, ask Claude to change it

You are producing a track. It plays in the player. Something in the LC view is not right: a knob that does too little,
a fader that is harsh at the top, a Pattern button with one pattern too many. The loop:

1. Click the element (first target: a control in the LC view, Launchkey knobs and pads included).
2. Say what you want ("make Brightness darker", "this pattern is too busy, thin it out").
3. Claude changes the track's code for that element in a working copy next to the track and shows the diff.
4. A gate runs (`npm run verify`). If it fails, the output goes back to Claude, not to you.
5. You press Play on the working copy and listen. The controllers keep their state.
6. Next round on the same copy, or "reset" to start from the original again.

This happens while the track plays, so it looks like performing, but it is producing: you decide when to reload, a gap
at reload is fine, and the original file is never touched. It is the use case the player vision draft (idea 1) describes,
and it is the first one this epic delivers end to end.

### What else the same bridge carries

The click-and-modify loop needs a selection, a chat panel, a server-side agent run and a gate before anything plays.
Two more modes need exactly the same pieces:

| Mode | You ask | Claude produces | Gate before it plays |
|---|---|---|---|
| **Modify** (primary) | click a control: "make the hats darker when Brightness is low" | working copy `NNN-<name>-v2.strudel` | `npm run verify`, then the user listens |
| **Explain** | click a control: "what does this do", "why is it silent" | text, read-only | none (no write) |
| **Produce: script** | "build for 2 minutes, then a breakdown" | auto-perform script (JSON) in `perform/<track>/` | `check-perform` |

Modes, not free chat: one text box hides what the agent may touch. Each mode has its own prompt, allowed tools and
allowed output paths, which is safer and teaches what to ask.

Two limits that shape the plan:
- **The agent cannot hear.** It reads code and tool output (`scenario`, `audibility`, `compare`). The user's ear
  decides, as in the `/auto-perform` skill. The player never says "better".
- **A Modify round is slow.** An agent run that edits Strudel code and passes `verify` takes much longer than moving a
  knob (not measured yet; task 1 measures it). Fine for iterating, not for a set.

Out of this epic, on purpose:
- **Compose** ("play Rudolph", a Guitar Pro file) is the producer mode (`npm run producer`, `/producer`: Guitar
  Pro MIDI → live track) and later epics. The bridge is built to carry it.
- **Live use during a set**: an agent steering controls or swapping code while the audience listens, and a gapless
  `swap(code)`. Iterating on a track that plays is in scope; acting on stage is not.

### Production and performance

The player and the repo mix two kinds of work. Performance: Live tracks, controllers, set 011, auto-perform playback.
Production: lab boards, `verify`, loudness, `compare`, layout sheets, check-sounds, auto-perform design. The Tools page
and the catalogue already show both side by side, and the iteration loop is a production feature that runs inside the
performance view.

Why that matters for this epic:
- An agent run and its gates are heavy. On the M2 with 16 GB a dense track can already drop out (`CLAUDE.md`, CPU
  rules); a run during a set could break the music. Task 1 measures this.
- A server that can write files should not be switched on by default in a performance setup.

What this epic does about it, and nothing more: the Claude drawer is opt-in through one Settings toggle (off by
default). A real split (a Produce workspace and a Perform workspace in the player, the repo's folders and tools sorted
by which one they serve) is a bigger question and gets its own epic, scoped after this one has shown which features
belong where. See Open Questions.

## Alignment with sound-lab (2026-11-20)

The `sound-lab` epic makes stems JSON files and adds Sample Designer, Stem Designer and stem swap with two skills
(`/sample-designer`, `/stem-designer`). Since then SC is the engine and ported `.strudel` tracks are frozen
(sc-migration D1), so this epic needs a rescope before task 1:
- Drawer modes call the sound-lab skills instead of repeating their rules: "Design stem" (`/stem-designer`), "Design
  sample" (`/sample-designer`).
- Modify on a stem track writes a new stem version (or a Stem Designer project), not `NNN-<name>-v2.strudel`;
  Modify on SC code tracks targets the `.scd`.
- `selection.mjs` is built by sound-lab task 009 (column click, kind `column`); this epic adds control-level targets.
- Order: after sound-lab 008 for the stem modes.

## Architecture Decisions

- **The Claude Code CLI, not the API.** The server spawns `claude -p --output-format stream-json` (flags checked:
  `--allowedTools`, `--add-dir`, `--include-partial-messages`, `--resume`). It uses the user's own login, loads
  `CLAUDE.md` and every project skill without a copy, and puts no key in the repo. Cost: Claude Code must be installed
  on the machine that runs the player. Task 1 confirms this on a real call.
- **Same shape as the Tools page.** `agent.mjs` copies the guard rules of `tools.mjs`: own-page Origin / Host check, no
  CORS, one run at a time (409 while busy), `DELETE` stops the whole process group, events stream as SSE. Paths never
  come from the request; the track is a catalogue id and the server looks up the file.
- **Modes are server-side records.** Prompt template, allowed tools, allowed output paths, gate. A run ends with a path
  check on `git status` before and after: a change outside the mode's paths fails the run and shows the paths. Nothing
  is deleted or reverted automatically.
- **Context is a contract.** The page sends `{ track, mode, selection, state }`: selection = what was clicked (kind,
  label, CC), state = current CC values, chapter, bar. The server adds the code lines of the control (found through its
  `@ctl` comment) and the track text. One selection registry on the page (`selection.mjs`); LC view controls are the
  first target, a stem dot or a script section can register later.
- **Modify works on one working copy per chat.** The first round copies the playing track to `NNN-<name>-v2.strudel`;
  later rounds of the same chat rewrite that file, so versions do not pile up. The original is never written. The drawer
  shows the diff of each round and offers one step of undo. `catalogue.mjs` already lists every tagged
  `NNN-name.strudel` in a track folder, so the copy appears in the player without a change.
- **Scope of a Modify round.** The agent changes what the selected control does or how it sounds. Moving CC numbers,
  adding or removing controls, or changing the layout needs an explicit ask in the request (`CLAUDE.md`: ask before
  changing the controller layout); the edit hook then regenerates the sheet and `.syx` as for any edit. Lines changed
  outside the selected control are listed in the drawer.
- **Approval is by ear.** After the gate passes the player offers the result ("Play v2", "Play script"); it never rates
  it. Gate failures are fed back to the agent for a retry (at most two) and then shown to the user.
- **Loading is Stop → load → Play.** A gap is fine while producing. The controllers' last values are kept in `midi.mjs`
  so a reload should not reset knobs; task 5 checks it.
- **The agent only writes new files.** The Modify working copy and scripts under `perform/<track>/`. Scripts play
  through the virtual `LCXL3 Auto` port (a human still wins by moving a control last). The agent never touches the port.
- **Measured state comes later.** When `meta.mjs` (player vision idea 2) exists, `state` gets energy and density per
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
- Claude drawer (key C, same pattern as the Settings drawer, shown only when the Settings toggle is on): mode picker,
  selection chip, streamed text, tool lines, diff, gate result, Stop, Play / Undo / Reset buttons. Help panel entry.

### Safety
- Server on 127.0.0.1 only (already true); run log under `tools/trajectory/agent-log/` (git-ignored); hard timeout per
  run; max turns per mode; the allowed-paths check above.

## Implementation Strategy

1. Spike the bridge with Explain: smallest real end-to-end run, and measure startup, answer time and the effect on a
   playing track.
2. Selection, drawer and guardrails before any mode that writes.
3. Modify next: it is the headline and the first mode that writes. Then finish Explain and add Produce: script.

## Task Breakdown Preview

1. **Agent bridge + Explain spike** — `agent.mjs`, one mode (Explain, read-only tools), SSE, Origin / Host guard, one
   run at a time, stop; curl test for 409 / 403 / 404; record startup time, answer time and whether a run makes a
   playing 008 or 010 drop out. (sequential, first)
2. **Selection and context** — `selection.mjs`, LC view controls register; server builds the context from catalogue id,
   `@ctl` name and track text. (parallel with 1)
3. **Claude drawer** — key C, Settings toggle (off by default), mode picker, selection chip, streaming, session
   continue, stop. (after 1 and 2)
4. **Guardrails** — path-check tests (agent told to write elsewhere fails the run), timeout, max turns, run log, cost
   shown in the drawer. (after 3; before any write mode is merged)
5. **Modify** — working copy `NNN-<name>-v2.strudel`, prompt with the selected control's code, path check, gate
   `npm run verify` with retry, diff view, undo / reset, Play via Stop / Play, check that the controllers' state
   survives a reload. Try it on five real changes on 008 and 010. (after 4)
6. **Explain, finished** — prompts, allowed tools (read, grep, `scenario`), answers cite control names and code lines.
   (after 3; parallel with 5)
7. **Produce: script** — prompt from the `/auto-perform` rules, output `perform/<track>/<name>.json`, gate
   `check-perform`, player lists it and plays it through the virtual port; real controller still wins. (after 4)
8. **Docs** — README section, `CLAUDE.md` line, Help panel entry, a short "what to ask" list per mode. (last)

## Dependencies

- Internal: player hub (merged), auto-perform script format and the `/auto-perform` skill (PR 26),
  `check-perform.mjs`, `npm run verify`, `tools.mjs` guard pattern, `catalogue.mjs`, the Settings drawer.
- External: the `claude` CLI on the machine that runs the player.
- Other epics: `vis-live-mapping`, `drop-buildup` and `launchkey-knob-target` also change the player or the LC view;
  merge one at a time. The producer mode (merged) is the first Compose input and can use the bridge once it exists.

## Risks

- **Latency.** A Modify round may take minutes. Mitigation: the drawer streams progress, the old track keeps playing
  while the agent works, and the user picks the moment to reload.
- **Dropouts while the agent runs.** The run and `verify` share the CPU with the music. Mitigation: task 1 measures it;
  if it is bad, the drawer warns while a track plays, or gates run only when the user presses Run.
- **Broken tracks.** An edit can pass verify and still sound wrong or load the CPU. Mitigation: working copy only, user
  listens, the original keeps playing.
- **A server that runs an agent.** Mitigation: localhost, Origin / Host check, path check, allowed tools per mode, one
  run at a time, off by default. No mode gets network tools.
- **Cost and login.** Every run uses the user's Claude account. Mitigation: show usage per run; Jojo needs his own
  login on his machine.
- **Winner adoption.** The working copy has to become the track somehow. The repo rule (never overwrite a track unless
  asked) means an explicit step; see Open Questions.

## Open Questions

1. How does a winning working copy become the track? Candidates: a "Keep as new track" button that renames it to the
   next free `NNN-<name>`, or "replace original" with a confirm (the click is the ask), or the user does it in the
   terminal.
2. One working copy per chat with one step of undo (the plan above), or one file per round (`-v2`, `-v3`, …) so every
   round can be compared by ear?
3. Which selection targets after LC controls: stem dots (visuals), script sections, the status box? And does "UI
   element" ever mean the player's own UI (a panel, a button) rather than the track? This epic assumes the track.
4. Is Explain useful on its own, or too basic once the user knows the tracks? If too basic, task 6 moves last.
5. Does Jojo use it too (own login, own machine)?
6. Production and performance: should the player get a Produce and a Perform workspace, and the repo and Tools page a
   matching split? Scope this as its own epic once this one runs; the Settings toggle is the only separation here.
7. Live use during a set stays out. Name that epic when the iteration loop works (candidates: agent-steered controls,
   gapless swap, a "next section" request during a set).

## Success Criteria (Technical)

- `POST /agent/explain` with a foreign `Origin` gets 403; an unknown mode or track id gets 404; a second run while one
  runs gets 409; `DELETE /agent` stops the run and its child processes.
- With the Settings toggle off, the drawer and key C do nothing and `/agent/*` is not reachable from the page.
- Clicking a control in the LC view and asking "what does this do" returns an answer that names the `@ctl` text and the
  code lines, with no file changed.
- Clicking a control and asking for a change writes `NNN-<name>-v2.strudel` that passes `npm run verify`; the original
  file is byte-identical; the catalogue lists the copy; the diff is shown before Play; lines changed outside the
  selected control are listed.
- A second round in the same chat rewrites the same copy; Undo restores the previous round; Reset starts from the
  original again.
- After Play on the copy the controllers' last values are unchanged (checked with a scenario that sets CCs, reloads
  and reads them back).
- A Produce: script request writes a script that passes `check-perform` and plays in the player; moving a real control
  during playback wins until the script moves it again.
- A run that writes outside the mode's allowed paths fails and names the paths (tested by a prompt that asks for it).
- Every run has a log entry and ends within the mode's timeout.

## Estimated Effort

8 tasks, about 3-4 working sessions. Order: 1 and 2, then 3, then 4, then 5 with 6 in parallel, then 7, then 8.
Critical path: 1 → 3 → 4 → 5. The first useful result (click a control, ask for a change, hear it) lands after task 5.
