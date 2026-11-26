# Contributing

Thank you for helping. This page tells you how to set up, how to open a pull request (PR) and which rules keep the
tracks safe. For what the project does, start at [docs/README.md](docs/README.md).

## Set up

1. Install [SuperCollider](https://supercollider.github.io/downloads) (3.13 or newer) and Node.js. The live tracks
   play on SuperCollider.
2. Clone the repo and run `npm install` once in `tools/`. The checks and the player need it.
3. Start the player: double-click `Cerulean Echoes.app`, or `cd tools && node trajectory/server.mjs` and open
   http://localhost:8766. It plays any track without controllers (auto-perform). See
   [getting started](docs/getting-started.md).
4. To play with hardware, see [midi-layouts/devices.md](midi-layouts/devices.md).

## Branch and PR flow

- Never push to `main` and never force-push it.
- Branch from a fresh `origin/main`. One PR per feature.
- Before you edit several files, run `git status` and `gh pr list`. Someone may already work on the same track.
- Keep a PR small enough to review in one sitting. Say in the description what you checked.

## Rules for tracks

- **Do not overwrite a track.** A new version goes into a new file. Replace an old one only when asked to.
- **One file per live track.** Each live track lives in `sc/tracks/<id>/<id>.scd` (SuperCollider). Every controller
  is optional. Edit that file, not a copy. Strudel is deprecated ([DEPRECATION.md](DEPRECATION.md)).
- **Songs from Guitar Pro are generated** from their map file `<track>-map.json`. Change the map and run
  `npm run producer`, never the track. See [producer mode](docs/features/producer-mode.md).
- **Ask before changing the sound.** Effects, reverb, delay, orbits, naming and the controller layout change how a
  track plays and feels. Discuss these first.
- **Strudel strings** (producer songs): use single quotes for plain text. Double quotes are read as
  mini-notation.
- **Boards and stems need rhythm**, not only held notes.

## Files you never edit by hand

These files are generated. On a merge conflict take either side, then regenerate.

| Generated file | Regenerate with (in `tools/`) |
|---|---|
| a Guitar Pro song track and its perform script | `npm run producer` (edit the map, not the track) |

The text of a control is the `// @ctl` comment in the track.

Code blocks that several tracks share are marked `@shared <name> begin` and `end`. Edit the block in one track, then
run `npm run shared -- --from <track> <name>`. `npm run shared -- --check` shows drift.

## Checks before you open a PR

Run these in `tools/`:

- `npm test` before every PR. It runs the feature tests: player, takes, recording, launcher, producer, stems, sound
  lab and SuperCollider (every SC track loads, plays and answers its Pattern button). CI runs the Node part on every
  PR; the SuperCollider part needs `sclang` and runs on your machine.
- `npm run verify-sc -- <track.scd>` after editing an SC track or its auto-perform scripts. It checks the `@ctl`
  tags, the scripts, and that the track loads and plays headless in SuperCollider. With no argument it checks every
  changed SC track.
- `npm run path-lint` after editing docs. It finds paths in the docs that do not exist.
- Levels are set by ear in the player; the tests do not measure sound.

## Labels and words

Everything a player reads is English and short: control names, `@ctl` texts and the live view. Use one name per job in
every track, for example Brightness, Space, Level and Pattern. The glossary lists the agreed words:
[docs/reference/glossary.md](docs/reference/glossary.md). Do not add German terms.

## Sounds and samples

- An SC track loads its samples from disk: `sc/samples/<folder>/` (credits in `sc/samples/CREDITS.md`) or the repo's
  own `samples/`. A missing file is silent; `npm run verify-sc` and `npm test` list missing files.
- Use wav or flac (SuperCollider cannot read m4a), and only sounds you may use (own, CC0, CC BY with credit).
- Keep recordings small. No file over 10 MB goes into git; a commit hook refuses it. Keep larger recordings outside the
  repo.

## Planning larger work (optional)

You do not need a PRD or an epic. A fix, a small change, a docs edit or one track tweak is a branch and a PR, nothing
more. This section is for those who plan bigger work with CCPM or a similar PRD-then-epic flow. It is the only place
that describes the flow; other docs point here.

- **Where files live.** A PRD is `.claude/prds/<name>.md`. An epic is the folder `.claude/epics/<name>/` with
  `epic.md` and numbered task files (`001.md`, `002.md`). Use a kebab-case `<name>`.
- **Plan PR.** Branch `plan/<name>`, planning files only. Merge it before the work starts.
- **Build PRs.** Branch `epic/<name>`, or one branch per task group. One PR per epic or group. Update the task status
  and the epic `status` and `progress` in the same PR.
- **Closing.** When the epic is done and merged, open a removal PR `chore/remove-<name>-epic`. It deletes the epic
  folder and the PRD. Move anything worth keeping, such as a spec or a decision, to `docs/` or the tool's README first.
  Git history keeps the rest.
- **GitHub issue sync** is optional and off by default.
- **Agents** use CCPM only when the user asks for it. When they do, they follow the rules above.
