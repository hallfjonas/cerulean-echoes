---
name: player-hub
description: The trajectory player becomes the one place where tracks are played, with settings tucked away and the repo's tools on their own page
status: backlog
created: 2026-11-15T18:58:29Z
---

# PRD: player-hub

## Executive Summary

`tools/trajectory/player.html` already plays every one-file track on localhost with the controllers and the
visuals behind it. It is the only part of the trajectory tool that is used. This PRD makes it the main tool of the
repo: the page that opens at `http://localhost:8766`, the single interface through which tracks are played. The
landing page becomes an extra tool, the visual settings move out of the way, and the Node tools the players reach
for (sound check, loudness, layout sheets, stem-lab boards, set build) get a page of their own in the same app.
Each track file stays the single source of truth: the player taps it on demand, and the same file plays on
strudel.cc. From the playing track the player can move to any other track through a transition on the Fog knob.
A scoped evaluation of three future directions (LLM edits from the UI, auto-perform, producer mode) is part of the
work; building them is not.

## Problem Statement

- `http://localhost:8766` opens `index.html`: audio file analysis, live input analysis, the strudel.cc relay,
  recording to JSONL. It is not used for playing, but may be useful later. The page people actually need is one
  URL further (`/player.html`) and the README has to warn about it.
- The player's top bar mixes playing (track, Play, Stop) with eight visual settings (Hard ↔ Soft, Raw ↔ Smooth,
  Axes, Labels, Beat rings, LC frame, plus keys V and W). During a set the playing controls compete with knobs that
  nobody touches mid-track.
- A track only shows up in the player after someone ran `make-tapped.mjs` once by hand, and the tapped copy is a
  second file per track that the hook has to keep in step.
- Set 011 moves through four fixed tracks. Moving from the playing track to a freely chosen one means Stop, pick,
  Play: a gap in the music.
- The repo's tools live as CLI commands spread over `tools/` (`strudel-sim/check-sounds.mjs`, `measure`,
  `lcxl-layout`, `stem-lab/sync.mjs` / `check.mjs`, `npm run set`). Using them means a terminal, the right folder
  and the right arguments. Lab boards cannot be played in the player at all.
- The audio engine is Strudel in the browser. The keys (Launchkey) suffer most from its latency; SuperCollider may
  replace it later. Today the Strudel calls are spread through `player.html`, so a later swap would touch
  everything.

## User Stories

1. **As a player (Jojo or Jonas), I open one URL and play a track.**
   - `http://localhost:8766` shows the player directly; no landing page, no second URL.
   - Every one-file live track (007, 008, 009, 009-riffs, 010) is in the track list without a manual tap step.
   - Track select, Play, Stop and the status line (track, MIDI inputs, visuals) are the only controls visible
     while playing.
2. **As a player, I find the visual settings when I want them and never by accident.**
   - All visual sliders and switches sit in one settings panel that is closed by default and opens with one click
     or one key.
   - Every keyboard shortcut that works today (F, V, A, L, B, H, W) still works.
   - Settings survive a page reload.
3. **As the track builder (Jonas), I run the repo's checks from the browser.**
   - A Tools page lists the checks the repo uses on a track or board: sound check, per-stem loudness, layout sheet
     and custom modes, stem-lab engine sync and check, set build.
   - Picking a track or board and a check runs it and shows its output on the page while it runs.
   - Only these known commands can be run; nothing else is reachable through the server.
4. **As the track builder, I play a lab board in the player** like a track, with the same controllers and visuals.
   - Lab boards appear in the track list, grouped apart from the live tracks.
5. **As the track builder, I edit only the track file.**
   - No tapped copies to update: the player plays the file as it is now.
   - The same file plays when pasted into strudel.cc.
6. **As a player, I move from the playing track to another one without a gap.**
   - While a track plays I pick any other track and choose Transition; the Fog knob in set mode (as in 011) moves
     from one to the other, chapters change on the phrase as in the set.
7. **As the team, we know which future idea to build next.**
   - A written evaluation covers LLM edits from the UI, auto-perform and producer mode: what each needs, what
     exists already, effort, risks, a recommendation and a first slice.
   - For LLM edits it covers how the player shows what is selected and how it is set now, and how a chat about a
     change keeps going over several rounds.
   - Producer mode: a track built from a song form (e.g. indie pop: 8-bar intro, verse 1, chorus, verse 2,
     chorus, outro), a note sheet, a popular song name (e.g. Rudolph the Red-Nosed Reindeer) or a Guitar Pro file.

## Functional Requirements

- FR1: The server serves the player at `/`. `index.html` becomes `analyse.html` with its analysis code unchanged, linked
  from the Tools page. The `/events` + `/stream` relay stays as long as the player's visuals use it.
- FR2: The player page shows a top bar with: track list (live tracks, then lab boards), Play, Stop, status, a
  settings button, and a link to the Tools page. The bar keeps its auto-hide after 3 s without mouse.
- FR3: A settings panel holds Hard ↔ Soft, Raw ↔ Smooth, Axes, Labels, Beat rings, LC frame, Look (deck / ocean /
  clean) and Pan width. It opens and closes with a button and a key (S), is closed on load, and stores its values
  in `localStorage` (wrapped so a blocked storage still loads with defaults).
- FR4: The server taps a track or board when the player loads it, in memory, from the file as it is now. No tapped
  copies on disk; the hook and `npm run watch` no longer tap. A track file contains nothing that only the player
  provides, so it plays when pasted into strudel.cc.
- FR5: A Tools page (`tools.html`, same look and nav) runs a fixed list of commands through a server endpoint.
  Each entry names the command, the argument kind (track / board / none) and the script it calls. Output streams
  to the page; one job at a time (the machine is shared); a running job can be stopped.
- FR6: All engine-specific calls (start, load code, stop, the `midin` / `midikeys` shims, sample banks) live in one
  module behind a small interface the page uses. Controller input (Web MIDI) stays outside it, so a later
  SuperCollider engine can take the same input.
- FR7: `docs/player-future.md` holds the evaluation from story 7.
- FR9: Transitions: the server builds a two-track set (A → B) from the one-file tracks on request, with the frame
  and Fog-knob set mode of 011. Per-track set parameters (BPM grid, phrase, orbits, transpose) are read from a tag
  in each track. Set 011 stays as it is.
- FR8: README, `CLAUDE.md` and `.claude/launch.json` point at `http://localhost:8766` as the way to play tracks.

## Non-Functional Requirements

- Sound unchanged: a track played in the new player produces the same events as in the old one (the page changes,
  the evaluation of the track does not).
- No added latency between a MIDI message and the scheduler: the controller path is not moved behind the server or
  an extra async hop.
- Page labels in English and short (repo label rule); chat and the evaluation doc may stay German where the
  existing docs are.
- The server listens on 127.0.0.1 only; the Tools endpoint accepts only the listed command ids, never a free
  command line or a free path (arguments are picked from the server's own track and board list).
- One heavy job at a time on the M2 Air: a second Tools job waits or is refused while one runs.
- No build step: plain HTML + ES modules, as today.

## Success Criteria

- Opening `http://localhost:8766` and pressing Play plays 008 with controllers in two clicks; no CLI step before.
- While playing, the top bar shows at most 6 controls; the 8 visual settings are reachable in one click or key.
- Each of the 5 listed checks runs from the Tools page on a real track and shows the same output as the CLI.
- At least one lab board plays in the player with controllers and visuals.
- Editing a track and pressing Play plays the edit, with no tap step and no tapped file in the repo.
- While a track plays, picking another one and Transition moves to it on the Fog knob without a stop.
- `docs/player-future.md` exists with a recommendation for each of the three ideas, and the team picked (or
  rejected) a first slice.
- `grep` finds no Strudel import outside the engine module in the player's page code.

## Constraints & Assumptions

- Assumption: "stem-lab, …" means the Node tools under `tools/` that act on tracks and boards (stem-lab sync and
  check, check-sounds, measure, layouts / syx, set build). `phrase-cut` (Python, downloads) stays CLI-only.
- The audio-analysis path (`analyse.mjs`, `analyse-file.mjs`, live input, JSONL recording) stays as a tool that
  may be used later.
- The set 011 stays generated by `tools/set/make-set.mjs`; the player plays it as one more track if wanted.
- Strudel 1.2.6 from unpkg stays the engine for this epic.
- Machine shared with other agents: no parallel heavy jobs.

## Out of Scope

- Replacing Strudel with SuperCollider (only the seam in FR6).
- Building LLM edits, auto-perform or producer mode (only the evaluation, FR7).
- Changes to tracks, sounds, controller layouts or the visuals themselves.
- Hosting the player anywhere but localhost; accounts; mobile layout.
- Playing tracks in strudel.cc stays possible (FR4), no longer the main path.
- Developing the Analysis page further.
- Transitions between lab boards; transitions other than the set's Fog-knob crossfade.

## Dependencies

- `tools/trajectory/make-tapped.mjs` (tap on demand), `tools/set/make-set.mjs` + `set-frame.strudel` (transitions),
  `render.mjs`, `smoothing.mjs`, `strudel-source.mjs`.
- The CLI tools behind the Tools page: `strudel-sim/check-sounds.mjs`, `strudel-sim/measure.mjs`,
  `lcxl-layout/gen-layout.mjs` + `make-syx.mjs`, `stem-lab/sync.mjs` + `check.mjs`, `set/make-set.mjs` +
  `check-set.mjs`.
- The layout hook and `npm run watch` (their tap step goes).
- Open epics touching the player's view: `launchkey-knob-target` (LC view keyboard), `drop-buildup` (countdown in
  the live view). Coordinate if they run at the same time.
