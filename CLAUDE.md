# cerulean-echoes

Live-performed tracks on SuperCollider (SC), played with Novation Launch Control XL 3s and a Launchkey MK4 25
(devices: `midi-layouts/devices.md`) through the player (`tools/trajectory/`). The Strudel tracks are removed (git history).
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
- `sc/tracks/<id>/<id>.scd` — the live tracks (source of truth), `<id>.track` = a stem track (stem versions on the
  14 slots, frame `<id>-frame.scd`); `sc/lib/` the engine core (`ce.scd`), `sc/engine.scd` what the player starts,
  `sc/live.scd` the IDE start; `sc/sounds/` one sound per file (`sc/sounds/README.md`); `sc/samples/` samples and
  reverb IRs (`CREDITS.md`); porting notes `sc/PORTING.md`
- `tracks/` — removed 2026-11-22: every Strudel track (001/002, 007-010, 016, historic, set 011) is in git history;
  the tracks live in `sc/tracks/`
- `midi-layouts/` — device list and the two custom modes (`lcxl3-mode1.syx` / `-mode2.syx`)
- `docs/reference/genres.md` — what each genre is (tempo, must-have / must-not-have, groove techno stem by stem); use it
  to pick a track's genre and to judge a stem
- `docs/reference/listening-list.md` — links to tracks and sets to listen to, by genre, optional note on what to listen for
- `sc/stems/` — the stem library (`<sample>/<name>.stem`, one LC column as JSON; schema, add-ons); `sc/lab/samples/` (Sample Designer projects), `sc/lab/stems/` (Stem Designer projects);
  docs: `docs/features/stems.md`, `docs/features/sound-lab.md`
- `samples/` — audio recordings
- `recordings/<track>/` — WAV recordings (+ `.json` sidecar) of the player's output, written by the player, outside git
- `tools/` — Node tools (run `npm install` in `tools/` once): the player, `npm test`, checks, sound lab, launcher,
  Guitar Pro MIDI → live track (`producer/`)

## Rules
- **Non-destructive:** a new version of a track goes into a new file; never overwrite an existing track unless asked.
- Ask before changing sound, effects, orbits, reverb/delay, naming or the controller layout, unless that is the task.
- Boards and stems need rhythm, not just held notes.

## Git
- Never push to main or force-push it; branch from a fresh `origin/main`, one PR per feature.
- Before a multi-file edit: `git status`, and look for sibling branches/PRs and other sessions working on the same
  track (`gh pr list`), so nothing is built twice or overwritten.
- Generated files (a producer song track) are never merged by hand: on a conflict take either side and regenerate
  (`npm run producer`).
- No file over 10 MB in git (a PreToolUse hook refuses the commit); recordings stay small or outside the repo.

## Live tracks (SuperCollider)
All live tracks play on SC (`sc/tracks/<id>/<id>.scd`: 001, 002, 007, 008, 009, 010, 016, 017; stem tracks 009-house-2/3, 017-lsd-fx(-2/-3)),
every controller optional. Edit the `.scd`; a new version goes into a new folder (e.g. `009-house-2`).
- Rows and columns: Mode 1 = Jojo's foundation, Mode 2 = Jonas' colour (CC + 48) on columns 1-7, column 8 global on
  both. Same row meaning everywhere; Jojo's button 1 has at most 3 patterns; all knobs at 0 must already sound good.
- Knobs act at once, also on sounding notes (control buses); faders from the next note, with pickup (a device's fader
  changes nothing until it meets the value); pattern buttons switch at the next bar, Chapter at the next bar or phrase.
- Every connected LC XL 3 (port name contains `LCXL3`, not `DAW`) gets the full layout; several LCs share every value
  (SC sends each knob change back to every LC). Launchkey MK4 25 (optional): keys = a pad, drum pads (channel 10) = 16
  one-shots (`lkNote`, names in `lkPadNames`), mod wheel CC 1 = keys level × master, knobs CC 21-28 = sound.
- A Guitar Pro song: the producer still writes Strudel (`tools/producer/`, `/producer`); the decisions live in
  `<track>-map.json`, change the map and re-run `npm run producer`, never the track. Reference songs 012/013 are test
  fixtures in `tools/producer/fixtures/`. An SC output is decided when the next song comes.

## Controller mapping (LC XL 3)
- Custom Mode 16 (channel 16): columns 1-7 = stems. Fader CC 5-11, knob rows CC 13-19 / 21-27 / 29-35, buttons CC 37-43 / 45-51.
- Mode 2 = same layout, every CC + 48 (melodies). Column 8 is global in both modes: its Mode 2 CCs are aliases of
  Mode 1's (an SC track's `aliases`), so the last move wins.
- In an SC track: `col.(n, plus)` → `(bright, space, char, level, btn, btn2)` CCs, `jojo.(n)` / `jonas.(n)` (+ 48),
  `glob` = column 8 (see any `sc/tracks/<id>/<id>.scd`).

## Skills and tools
Use them instead of redoing the steps by hand:
- A new sound on the SC machine ("sample designer", "a soft tom", export to `sc/sounds/`): `/sample-designer`.
- Compare versions of a stem against a track, promote a winner, swap it into a new track ("redesign the piano stem of
  the house track", "explore a replacement"): `/stem-designer`.
- A new sample (file into `sc/samples/`, a Launchkey pad, level): `/add-sample`.
- Design, script and review an auto-performance for a live track ("auto-performance", "perform script", "new
  performance"): `/auto-perform`.
- A Guitar Pro song (MIDI export) into a live track with a performance ("producer", "next song"): `/producer`.
- Start the player on a port or branch: `/player`. Review past sessions ("workflow review", "retro"): `/workflow-review`.

Hooks: a commit with a staged file over 10 MB is refused; a fresh worktree gets `npm ci` in `tools/` at session start.

Tools (run in `tools/`):
- Does every feature still work? `npm test` (player, takes, recording, launcher, producer, stems, sound lab, and SC:
  building blocks + every `sc/tracks` track loads, plays and reacts to its Pattern button; `tools/sc-test/run.scd`).
  Runs in CI on every PR; the SC part skips without `sclang`. Feature tests only: loose checks, never "is the output
  identical", no sound measuring.
- After editing an SC track or its perform scripts: `npm run verify-sc -- [<track.scd | .track> …]` (tags parse,
  perform scripts valid, the track loads and plays headless in `sclang`; stems and Sample Designer projects too; no
  args = every changed SC track). Scripts alone: `node trajectory/check-perform.mjs [<track file>]`.
- Outline a long track before reading it: `npm run track-map -- <track.scd | track.strudel>`, then `sed -n` ranges
- Stem library (`sc/stems/`, `docs/features/stems.md`): `npm run check-stems [-- <file…>]`, `npm run stems` (list,
  filter, used-by); designers from the terminal: `npm run sample-lab`, `npm run stem-lab`
- Offline render: `sclang sc/tools/render.scd <track.scd|.track> <scenario.json> <out-prefix>`; scenarios,
  stem comparison and asset generators: `tools/sc-port/`
- Guitar Pro MIDI → track, design stub, perform script: `npm run producer -- <file.mid> [--map <map.json>]
  [--out <dir>] [--force]`; `--perform` writes only the script; notes per bar: `node producer/midi-read.mjs <file.mid>
  --dump` (`tools/producer/README.md`); Strudel syntax as strudel.cc sees it: `node strudel-sim/transpile-check.mjs <file…>`
- Session digests: `node session-digest/digest.mjs [--since YYYY-MM-DD] [--until YYYY-MM-DD] [--only <id>]`
- Paths cited in docs, skills and epics exist? `npm run path-lint` (planned files in epics show up too)
- Removed Strudel tools and skills are in git history (list: `DEPRECATION.md`). `tools/strudel-sim/` keeps only the
  harness the producer test uses and the producer's syntax check.

## The player (tools/trajectory)
The player is the main tool: `cd tools && node trajectory/server.mjs`, then http://localhost:8766 (README:
`tools/trajectory/README.md`). It plays every live track (Live) and the sound lab projects (Labs) with the visuals.
- Launcher for people without a Terminal: `Cerulean Echoes.app` (repo root, committed; source and `launch.sh` in
  `tools/launcher/`, rebuild with `npm run launcher`) starts the server, shows the player in its own window (Swift/WKWebView, no Web MIDI: SC tracks only for controllers), quitting stops server + SC.
- SuperCollider tracks (`sc/tracks/`, catalogue `engine: 'sc'`, plain id): the server starts `sclang sc/engine.scd` on the first SC load and ends it with itself (own ports:
  OSC 57131, server 57140, so an IDE session with `live.scd` can run beside it; `CE_SC_PORT`, `CE_SC_SERVER_PORT`);
  `tools/trajectory/sc-link.mjs`, `engine-sc.mjs`. Controllers go straight to SC; the page mirrors SC's state.
  Agents' and tests' runs set `CE_SC_MUTE=1` (master to a silent bus).
- Single source: the track file, read again on every load, so Play plays the current edit.
- Landing page: Live (the track's LC view) full size; pages Live | Labs (Samples, Stems, Space, Sets) | Visuals;
  the sidebar (key S) shows only the sections of the page: Live = live tracks, Play-Pause/Stop/Record, auto-perform;
  Labs = Sample / Stem Designer, Space (frequency × time map of a stem track, `docs/features/space-analyzer.md`); the handle on its edge holds the sidebar toggle, the gear (opens Settings: Theme, Visuals, MIDI panel,
  Recording, keyboard shortcuts) and **?** (opens the help), three equal buttons that stay when the sidebar is hidden.
- Auto-perform (sidebar, key P) plays a script (`tools/trajectory/perform/<track>/*.json`, in bars; script format v2:
  controls, buttons, keys, pads, Launchkey CCs); on an SC track the steps go to SC over OSC (`sc-auto.mjs`), on a
  Strudel one into the virtual controllers `LCXL3 Auto` and `Launchkey MK4 25 Auto`. A new control or a changed `@ctl`
  needs the script checked (`node trajectory/check-perform.mjs`, part of `npm run verify-sc`). Every load restarts the
  clock (bar 0 = cycle 0).
- Record (key R) writes the master output to `recordings/<track>/` as a WAV (SC records itself); human set, or
  auto-perform with Record audio ticked; `node trajectory/check-recording.mjs` tests the endpoints.
- Takes: every load captures all MIDI input; the setting Save take on record stop writes it as a script v2 to `perform/<track>/takes/`
  (gitignored, with the play's tapped events) when a recording ends. Start on a take replays it; `node trajectory/check-replay.mjs <track>`
  compares a replayed take with its original bar by bar. Details: `tools/trajectory/README.md`.
- Without Web MIDI the player still plays ("No MIDI").

## Shared code in the Strudel tracks
Blocks the Strudel tracks share are marked `// @shared <name> begin` / `end`; the canonical copy is
`tools/shared/<name>.strudel-part` (the producer copies it into the tracks it writes). `npm run shared -- --check`
shows drift; `npm run shared -- --from <track> <name>` syncs a changed block. SC tracks share code through `sc/lib/`.

## Samples and sounds (SC)
An SC track loads its files from disk: `sc/samples/<folder>/<file>` or `repo:<path>` (the repo's own `samples/`),
listed in the track's `samples:`; credits in `sc/samples/CREDITS.md`. Sounds (SynthDefs) are `sc/sounds/<name>.scd`,
checked when loaded. A missing file is silent without an error: `npm run verify-sc` and `npm test` list missing files.
SC cannot read m4a; use wav or flac.

## Control texts (`@ctl`)
The `// @ctl` comments in a track (`.scd` or `.strudel`; a stem track's come from its stems and frame,
`tools/stems/stem-tags.mjs`) describe every control; the player's Live page, the SC UI (`sc/ui/index.html`) and
`check-perform` read them (`tools/lcxl-layout/ctl.mjs`). Layout sheets (PDF) and per-track `.syx` modes were retired on
2026-11-20. Every LC XL 3 gets the same two custom modes once, with Novation Components: `midi-layouts/lcxl3-mode1.syx` / `-mode2.syx` in slots 1
and 2 (same CCs for every track).

## CCPM epics and PRDs
Optional: use CCPM only when the user asks. The rules are in `CONTRIBUTING.md` ("Planning larger work (optional)").
The CCPM skill is vendored in `.claude/skills/ccpm/` (`SOURCE.md`); where it differs from CONTRIBUTING.md (plan PR,
no GitHub issue sync by default, removal PR when done), CONTRIBUTING.md wins.

## Machine
M2 Air, 16 GB, shared with other agents: the global resource rules apply (one heavy job at a time, test small first).
