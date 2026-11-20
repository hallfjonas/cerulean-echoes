# cerulean-echoes

Live-performed Strudel tracks (strudel.cc), played with Novation Launch Control XL 3s via `midin()` and a
Launchkey MK4 25 via `midikeys()` (devices: `midi-layouts/devices.md`).
Talk to the user in English; code comments are English too. Explain audio basics plainly.
Docs for people: `docs/README.md`; contribution rules: `CONTRIBUTING.md`.
Deprecated features: `DEPRECATION.md`. Read it before building any feature; never extend a deprecated feature (Strudel is deprecated, new work goes to SuperCollider).

## Labels
Everything the player reads is English and short: `@ctl` texts, control and option names, the live view (`▣ LC big`), the status box.
One name per job in every track: row 1 Brightness, row 2 Space, fader Level, button 1 Pattern (Chords on a harmony column),
global column Fog / Thin / Tension / Master / Chapter / Break. Row 3 and button 2 are named for what they do (Length, Complexity,
Octave, Echo throw, Lift). A `@ctl` text is one short line (about 50 characters): what the control does, no ranges or history.
No pattern strings (x..x) in the live view.
User vocabulary: "Density" = Tension, "build-up button" = Chapter, "global Wumms" = Master fader, "LK" = Launchkey,
"keys" = the Launchkey keys, "drum C1 / E1" = Launchkey pad by Novation note name (C1 = note 36, E1 = 40).

## Layout
- `tracks/<genre>/NNN-<name>/` — one folder per track, grouped by genre (`ambient`, `ambient-house`, `house`,
  `techno`; `sets/` for 011, `historic/` for 000-006): the track (`NNN-<name>.strudel`),
  its feedback notes; a Guitar Pro song also its `.mid`, `<track>-map.json`
  and `<track>-design.md`. No `old/` folders: superseded variants are deleted once committed, git history keeps them.
- `midi-layouts/` — device list and the two-controller template (`templates/dual-lc.strudel`)
- `lab/` — boards, not tracks, one folder per instrument or per track role: `keys/`, `kick/`, `bass/`, `drums/`, `synth/`,
  `harmony/`, `melody/`, `stab/`, `brass/`, `guitar/`, `strings/`, `samples/`, `tools/`
  (instrument-independent, e.g. `variation-lab`), `tutorials/` (ear training with live sliders + English handbook PDF).
  A board is either one sound optimised on its own or a comparison of candidate columns (each built like a track
  column), worked in rounds: the current round in the folder, older rounds deleted (git history), each round's result in
  the folder's `feedback.md`. Winners go into the tracks. Rejected board series: `lab/archive/`.
- `docs/reference/genres.md` — what each genre is (tempo, must-have / must-not-have, groove techno stem by stem); use it
  to pick a track's genre and to judge a stem
- `docs/reference/listening-list.md` — links to tracks and sets to listen to, by genre, optional note on what to listen for
- `samples/` — audio recordings
- `recordings/<track>/` — WAV recordings with a `.json` sidecar of the player's output, written by the player, not in git
- `recordings/<track>/` — WAV recordings (+ `.json` sidecar) of the player's output, written by the player, outside git
- `snippets/` — small helpers and tests (`midi-test.strudel`)
- `tools/` — Node tools (run `npm install` in `tools/` once): equivalence/CPU check, per-stem loudness,
  Guitar Pro MIDI → live track (`producer/`)

## Rules
- **Non-destructive:** a new version of a track goes into a new file; never overwrite an existing track unless asked.
- Ask before changing sound, effects, orbits, reverb/delay, naming or the controller layout, unless that is the task.
- Single quotes for plain text in Strudel (double quotes are parsed as mini-notation).
- Boards and stems need rhythm, not just held notes.

## Git
- Never push to main or force-push it; branch from a fresh `origin/main`, one PR per feature.
- Before a multi-file edit: `git status`, and look for sibling branches/PRs and other sessions working on the same
  track (`gh pr list`), so nothing is built twice or overwritten.
- Generated files (`-single`, `011-set-dual.strudel`) are never merged by hand: on a conflict take either side and
  regenerate (hook, `npm run set`).
- No file over 10 MB in git (a PreToolUse hook refuses the commit); recordings stay small or outside the repo.

## Live tracks (007-010 and newer): one file each
The single layout is the source of truth: one file `NNN-<name>.strudel` (`007-ambient`, `008-groove-techno`,
`009-house`, `010-ambient-house`, …), every controller optional. Edit these
files.
- A Guitar Pro song: every part plays its notes as written (song bar 1 = cycle 0), re-voiced; the decisions live in
  `<track>-map.json` beside the `.mid`. It is generated: change the map (or `tools/producer/`) and re-run
  `npm run producer`, not the track. The reference songs 012 (hand-built pilot) and 013 live on as test fixtures in
  `tools/producer/fixtures/`. See `/producer`.
- Rows and columns after `midi-layouts/templates/dual-lc.strudel`: Mode 1 = Jojo's foundation, Mode 2 = Jonas' colour
  on columns 1-7, column 8 global. Same row meaning everywhere; Jojo's button 1 has at most 3 patterns; all knobs at 0
  must already sound good.
- Every connected LC XL 3 (port name contains `LCXL3`, not `DAW`) gets the full single layout: Mode 1 = foundation
  (same CCs as Mode 16), Mode 2 = colour (CC + 48), column 8 global on both. Several LCs: per CC the one moved last
  wins (`lcCc`, built on `lastMoved`, made once per CC). No LC found: a warning, silence. Without Web MIDI (the Node
  tools) one plain `midin()` stands in, so `/strudel-optimize` and `tools/strudel-sim` still work.
- Launchkey MK4 25 (optional, its own stem `stemLK`): keys = a pad, drum pads (channel 10) = 16 one-shots, mod wheel
  CC 1 = keys level × master, knobs CC 21-28 = sound (same meaning in every track; the sounds fit each track).
- The LC view (`▣ LC big`) shows Mode 1 and Mode 2 side by side, the page moved last framed, and the Launchkey row. `midikeys` has no note-off (fixed note length) and its queue is
  emptied by the scheduler's first query: read it through `shareQuery` when more than one layer uses it.
- The old dual/multi and generated single versions are in git history. `-dual`/`-single` files and
  `tools/lcxl-layout/make-single.mjs` (run by the hook after every edit of a dual file or the template; never edit a
  single file by hand) remain only for 011 and the template.

## The set (011)
- `tracks/sets/011-combining-all/011-set-dual.strudel` plays 007 → 010 → 009 → 008 as one set (Fog knob in set mode =
  position, Jonas' column 8 button 2 toggles it). It is GENERATED by `tools/set/make-set.mjs` from the frozen dual
  versions in `tracks/sets/011-combining-all/sources/`
  (`007-ambient-dual`, `010-ambient-house-dual`, `009-house-dual`, `008-groove-techno-multi`) and
  `tools/set/set-frame.strudel`: never edit it by hand. Changes to the one-file tracks do not reach the set; run
  `npm run set` in `tools/` after changing a frozen source or the frame (builds, then `check-set.mjs` proves each
  plateau plays its track event by event).

## Controller mapping (LC XL 3)
- Custom Mode 16 (channel 16): columns 1-7 = stems. Fader CC 5-11, knob rows CC 13-19 / 21-27 / 29-35, buttons CC 37-43 / 45-51.
- Mode 2 = same layout, every CC + 48 (melodies). Column 8 is global in both modes:
  fader and knobs read from both modes' CCs via `lastMoved` (last moved wins).
- In code: `col(n)` / `col2(n)` → `{ hpf, lpf, char, level, btn }` (see `tracks/historic/006/006-arp.strudel`).

## Skills and tools
Use them instead of redoing the steps by hand:
- Same sound, less CPU, "drops out", "compare old/new", "event by event": `/strudel-optimize`.
- Levels, "louder/quieter", "can't hear", clipping, balance of stems, pads, keys and voices: `/strudel-mix`.
- New board, "candidates", "next round": `/lab-board`; a board winner "into the track": `/lab-to-track`.
- A new sample (file, sample map, Launchkey pad, level, push): `/add-sample`.
- Review past sessions for a date or range, pain points, "workflow review", "retro": `/workflow-review`.
- Design, script and review an auto-performance for a live track ("auto-performance", "perform script", "new
  performance"): `/auto-perform`.
- A Guitar Pro song (MIDI export) into a live track with a performance ("producer", "next song", "new Guitar Pro
  song"): `/producer`.

Hooks: after every Edit/Write and every Bash call, the `.strudel` files changed since the last run get their
`@`-tags checked and their single version regenerated (`tools/lcxl-layout/hook.mjs`, `bash-hook.mjs`). A commit
with a staged file over 10 MB is refused; a fresh worktree gets `npm ci` in `tools/` at session start.

Tools (run in `tools/`):
- Does every feature still work? `npm test` (player, takes, producer, and SuperCollider: building blocks + every
  `sc/tracks` track loads, plays and reacts to its Pattern button; `tools/sc-test/run.scd`). Runs in CI on every PR;
  the SC part skips without `sclang`. Feature tests only: loose checks, never "is the output identical".
- After editing a track: `npm run verify -- <track…>` (transpile, compare vs HEAD, sounds, layout/syx, tap, auto-perform scripts;
  no args = all changed tracks; `--online` checks sounds online)
- Old vs new, event by event: `npm run compare -- <old.strudel> <new.strudel> [--stem <name>]`
- Levels are measured, not guessed: `npm run audibility -- <track>` (mix, every stem, Launchkey keys and pads at the
  default state, from cycle `--from <n>` on for a song whose parts rest at its start; flags SILENT / LOW / CLIPS);
  per-stem fader ranges: `npm run measure -- <track> stem=faderCC[,charCC] …`
  (for 007-010 pass `--base '{"12":1,"60":1}'`)
- Sounds load? `node strudel-sim/check-sounds.mjs [--offline] <track…>`; broken bank sound:
  `node strudel-sim/mirror-sound.mjs <sound>`
- Controller scenario without a throwaway script: `npm run scenario -- <track> --cc 13=0.5@1 --press 37@2 --pad 36@1
  --lk 21=0.7 --keys '<c3 e3>' --lc 2 --cc2 … [--before 0-4 --after 4-8] [--stems|--events|--view]` (`--view` = LC view
  as text)
- Syntax as strudel.cc sees it: `node strudel-sim/transpile-check.mjs <file…>`
- Guitar Pro MIDI → track, design stub, perform script: `npm run producer -- <file.mid> [--map <map.json>]
  [--out <dir>] [--force]`; `--perform` writes only the script from the map's `performance`; notes per bar:
  `node producer/midi-read.mjs <file.mid> --dump` (`tools/producer/README.md`)
- Set 011: `npm run set` (build + check); continuum: `npm run continuum`
- The player (`node trajectory/server.mjs [port]`, then localhost:8766): see "The player" below;
  `node trajectory/make-tapped.mjs <track>` puts the tapped code on the clipboard for strudel.cc
- Session digests: `node session-digest/digest.mjs [--since YYYY-MM-DD] [--until YYYY-MM-DD] [--only <id>]`
- Outline a long track before reading it: `npm run track-map -- <track>`, then `sed -n` ranges
- Paths cited in docs, skills and epics exist? `npm run path-lint` (planned files in epics show up too)

## The player (tools/trajectory)
The player is the main tool: `cd tools && node trajectory/server.mjs`, then http://localhost:8766 (README:
`tools/trajectory/README.md`). It plays any live track (Live) or lab board (Lab) from the catalogue with the visuals.
- Single source: the track file. The player taps it in memory on every load (`/track/<id>`), so Play plays the
  current edit; there are no tapped copies on disk. A track never depends on the player and still plays pasted into
  strudel.cc.
- Landing page: the MIDI panel (the track's LC view) full size; the sidebar (key S) holds the views (MIDI panel,
  Visualization), the page links, track, Play/Stop/Record/Save take, auto-perform and the visual settings; **?** opens
  the help.
- Auto-perform (sidebar, key P) plays a script (`tools/trajectory/perform/<track>/*.json`, in bars; script format v2:
  controls, buttons, keys, pads, Launchkey CCs) into the virtual controllers `LCXL3 Auto` and `Launchkey MK4 25 Auto`:
  use it to try a track or the player without controllers. A new control or a changed `@ctl` needs the script checked
  (`node trajectory/check-perform.mjs`, part of `npm run verify`). Every load restarts the clock (bar 0 = cycle 0).
- Record (key R) writes the master output to `recordings/<track>/` as a WAV (human set, or auto-perform with Record
  audio ticked); `node trajectory/check-recording.mjs` tests the endpoints.
- Takes: every load captures all MIDI input; Save take writes it as a script v2 to `perform/<track>/takes/` (gitignored,
  with the play's tapped events). Start on a take replays it; `node trajectory/check-replay.mjs <track>` (Tools: Check
  replay fidelity) compares a replayed take with its original bar by bar. Details: `tools/trajectory/README.md`.
- Without Web MIDI the player still plays ("No MIDI").
- SuperCollider tracks (`sc/tracks/`, catalogue `engine: 'sc'`, plain id; a ported track's Strudel file is
  `<id>-strudel`): the server starts `sclang sc/engine.scd` on the first SC load and ends it with itself (own ports:
  OSC 57131, server 57140, so an IDE session with `live.scd` can run beside it); `tools/trajectory/sc-link.mjs`,
  `engine-sc.mjs`. Record, auto-perform and visuals for SC tracks: sc-migration tasks 003-005.

## Writing efficient Strudel (CPU)
Strudel computes every event of every layer even when it is silent; dense tracks then drop out.
- Gate silent parts so they are not queried at all: `gate(cond, pat) = cond.fmap(on => on ? pat : silence).innerJoin()`.
  Gate stems on fader/global level > 0 (`strip()`), crossfade layers where `fadeMain`/`fadeExtra` reach 0,
  overtone layers on mode and density. Only gate where the gain is exactly 0, so the sound stays identical.
- Stateful closures (`cycleButton`, `lastMoved`): create each once per control, never inside a gated
  pattern only; query them every tick via a `stateTaps` stack in the master (`.filterValues(() => false)`),
  otherwise button presses are lost while the stem is gated.
- Keep the safety net at the end of the master: `.filterValues(v => (v.gain ?? 1) * (v.postgain ?? 1) > 0)`.
- Prove a restructuring is inaudible with `/strudel-optimize` (compares old and new event by event).

## Shared code in the live tracks
Blocks the live tracks share are marked `// @shared <name> begin` / `end`; the canonical copy is
`tools/shared/<name>.strudel-part` (the producer copies it into the tracks it writes). Edit the block in one track,
then `npm run shared -- --from <track> <name>` (in `tools/`); never hand-patch the copies. `npm run shared -- --check`
shows drift.

## Sounds that load (samples/sounds.json)
Every sound a track plays must load in a browser, on strudel.cc and in the player (`tools/trajectory/player.html`
loads the same banks as strudel.cc, `banks.mjs`, plus the gm_* soundfonts). `samples/sounds.json` is the list:
`ok` (whitelist, where it loads from) and `broken` (blacklist, why).
- Own samples load from raw.githubusercontent `main`: check-sounds warns "plays only after push to main" until the
  file is on `origin/main`.
- After adding or changing a sound: `cd tools && node strudel-sim/check-sounds.mjs <track>` (plays the track in the
  simulator with every control and pad, fetches each sound's file, updates the list). The hook compares every edited
  track with the list offline and reports broken or unchecked sounds.
- A broken bank sound (e.g. a VCSL file whose path has a comma: raw.githubusercontent then sends a header Chrome
  refuses) is copied into `samples/mirror/` with `node strudel-sim/mirror-sound.mjs <sound>`; every track loads
  `samples/mirror/mirror.json`, so the copy plays under the same name once pushed to main.

## Control texts (`@ctl`)
The `// @ctl` comments in a track describe every control; the LC view, the player's MIDI panel, the SC UI and
`check-perform` read them (`tools/lcxl-layout/ctl.mjs`). Layout sheets (PDF) and per-track `.syx` modes were retired on
2026-11-20. Every LC XL 3 gets the same two custom modes once, with Novation Components: `midi-layouts/lcxl3-mode1.syx` / `-mode2.syx` in slots 1
and 2 (same CCs for every track).

## CCPM epics and PRDs
Optional: use CCPM only when the user asks. The rules are in `CONTRIBUTING.md` ("Planning larger work (optional)").
The CCPM skill is vendored in `.claude/skills/ccpm/` (`SOURCE.md`); where it differs from CONTRIBUTING.md (plan PR,
no GitHub issue sync by default, removal PR when done), CONTRIBUTING.md wins.

## Machine
M2 Air, 16 GB, shared with other agents: the global resource rules apply (one heavy job at a time, test small first).
