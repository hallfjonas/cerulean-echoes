# Checks

## What it is
Command line tools in `tools/` that test the project without a speaker or a controller. Each answers one question.
Run all commands from the `tools/` folder (run `npm install` there once). The SuperCollider parts need SuperCollider
installed (`sclang`); without it they are skipped.

## When to use it
Before you open a pull request, after you edit a track or an auto-perform script, and when something does not load.

## How to use it
| Question | Command |
|---|---|
| Does every feature still work (player, takes, recording, launcher, producer, stems, sound lab, SuperCollider tracks)? | `npm test` |
| Is my edited SuperCollider track still fine? | `npm run verify-sc -- <track.scd>` |
| Are the auto-perform scripts still valid? | `node trajectory/check-perform.mjs` |
| Is the stem library valid? | `npm run check-stems` |
| Where is what in a long track? | `npm run track-map -- <track.scd>` |
| Do the paths named in the docs exist? | `npm run path-lint` |

- `npm test` runs the feature tests. It plays every SuperCollider track headless (no sound) and checks that it plays
  notes with the faders up, that Launchkey knob 1 arrives, that every sample file exists and that the Pattern button
  changes what plays. GitHub runs the Node part on every pull request.
- `verify-sc` checks one track (or, with no argument, every changed one): the `@ctl` tags parse, its auto-perform
  scripts are valid, and it loads and plays headless in SuperCollider. A stem file or a Sample Designer project in the
  change also gets its check.
- `check-perform` checks every script against the controls of its track: a step that moves a control the track does
  not have, a bad bar or a bad value is reported.

## Good to know
- The checks are feature tests: something plays, a value arrives, a file is written. They do not measure the sound
  and do not judge taste: listen in the [player](player.md).
- Run one heavy check at a time (`npm test` starts SuperCollider); the laptop is shared.

## Related
- [Claude skills](claude-skills.md)
- [Samples and sounds](samples-and-sounds.md)
- [Live tracks](live-tracks.md)
