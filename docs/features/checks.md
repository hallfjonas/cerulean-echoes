# Checks

## What it is
A set of command line tools in `tools/` that test a track without a browser, a speaker or a controller. Each answers
one question. Run all commands from the `tools/` folder (run `npm install` there once).

## When to use it
Before you open a pull request, after you edit a track, and whenever something sounds wrong: too quiet, clipping,
dropouts, a sound that does not load.

## How to use it
| Question | Command |
|---|---|
| Is the edited track still fine overall? | `npm run verify -- <track>` |
| Is every stem loud enough, and does anything clip? | `npm run audibility -- <track>` |
| Did my edit change the sound? | `npm run compare -- <old.strudel> <new.strudel>` |
| What happens when I move a knob or press a pad? | `npm run scenario -- <track> --cc 13=0.5@1` |
| Do all sounds load? | `node strudel-sim/check-sounds.mjs <track>` |

- `verify` checks the syntax, compares with the last commit, checks the sounds, regenerates the layout sheet and `.syx`
  files, and checks the auto-perform scripts. With no arguments it checks every changed track. Add `--online` to
  check the sounds over the network.
- `audibility` renders the mix, every stem, the Launchkey keys and the pads at the default state and flags
  `SILENT`, `LOW` or `CLIPS`. Clipping is a level so high that the sound distorts.
- `compare` lists the differences event by event. A difference is "changed", not a failure: your edit may be meant to
  change the sound.
- `scenario` simulates controller moves and prints what plays. `--view` shows the LC view as text.
- `check-sounds` plays the track in a simulator, fetches each sound file and updates `samples/sounds.json`.

## Good to know
- These checks work on event data and a simulated renderer, not on a speaker: they find silence, clipping and drift,
  not taste.
- A bad sound is reported as broken or unchecked; sounds from your own samples load only after a push to `main`.
- Run one heavy check at a time; the laptop is shared.
- Skills that drive these tools: `strudel-optimize` (same sound, less CPU), `strudel-mix` (levels).

## Related
- [Claude skills](claude-skills.md)
- [Layout sheets](layout-sheets.md)
- [Samples and sounds](samples-and-sounds.md)
- [Live tracks](live-tracks.md)
