# Contributing

Thank you for helping. This page tells you how to set up, how to open a pull request (PR) and which rules keep the
tracks safe. For what the project does, start at [docs/README.md](docs/README.md).

## Set up

1. Clone the repo and run `npm install` once in `tools/`. The checks and the player need it.
2. Start the player with `cd tools && node trajectory/server.mjs`, then open http://localhost:8766. It plays any track
   or lab board without controllers.
3. To play with hardware, see [midi-layouts/devices.md](midi-layouts/devices.md).

## Branch and PR flow

- Never push to `main` and never force-push it.
- Branch from a fresh `origin/main`. One PR per feature.
- Before you edit several files, run `git status` and `gh pr list`. Someone may already work on the same track.
- Keep a PR small enough to review in one sitting. Say in the description what you checked.

## Rules for tracks

- **Do not overwrite a track.** A new version goes into a new file. Replace an old one only when asked to.
- **One file per live track.** Each live track (007 to 010, 012, 013) lives in one `NNN-<name>.strudel` file. Every
  controller is optional. Edit that file, not a copy.
- **Songs from Guitar Pro are generated.** 013 comes from its map file `<track>-map.json`. Change the map and run
  `npm run producer`, never the track. See [producer mode](docs/features/producer-mode.md).
- **Ask before changing the sound.** Effects, reverb, delay, orbits, naming and the controller layout change how a
  track plays and feels. Discuss these first.
- **Strudel strings:** use single quotes for plain text. Double quotes are read as mini-notation.
- **Boards and stems need rhythm**, not only held notes.

## Files you never edit by hand

These files are generated. On a merge conflict take either side, then regenerate.

| Generated file | Regenerate with (in `tools/`) |
|---|---|
| Layout sheets `<track>-layout.pdf` | `npm run layouts` |
| Controller modes `*.syx` | `npm run syx` |
| `tracks/sets/011-combining-all/011-set-dual.strudel` | `npm run set` |
| `013-hope-for-niklas.strudel` and its perform script | `npm run producer` (edit the map, not the track) |

An editor hook regenerates sheets and `.syx` files after every save when you work with Claude Code. Without it, run
`npm run watch` to do the same on save. The text of a control is the `// @ctl` comment in the track, so change it
there and never in the PDF.

Code blocks that several tracks share are marked `@shared <name> begin` and `end`. Edit the block in one track, then
run `npm run shared -- --from <track> <name>`. `npm run shared -- --check` shows drift.

## Checks before you open a PR

Run these in `tools/`:

- `npm run verify -- <track>` after editing a track. It checks syntax, compares against `HEAD`, checks that sounds
  load, checks the layout and the auto-perform scripts. With no argument it checks every changed track.
- `npm run path-lint` after editing docs. It finds paths in the docs that do not exist.
- `npm run audibility -- <track>` when you change levels. Levels are measured, not guessed.

## Labels and words

Everything a player reads is English and short: control names, `@ctl` texts and the live view. Use one name per job in
every track, for example Brightness, Space, Level and Pattern. The glossary lists the agreed words:
[docs/reference/glossary.md](docs/reference/glossary.md). Do not add German terms.

## Sounds and samples

- Every sound a track plays must load in a browser, on strudel.cc and in the player. The list of sounds that load is
  `samples/sounds.json`.
- After adding or changing a sound, run `node strudel-sim/check-sounds.mjs <track>` in `tools/`.
- Your own samples load from the `main` branch on GitHub, so they play only after your PR is merged.
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
