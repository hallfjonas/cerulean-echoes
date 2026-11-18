# Auto-perform

## What it is
Auto-perform plays a track for you. A script of control moves and button presses (a "performance") is sent into a
virtual controller, so the track sounds as if someone turned the knobs. It does not listen to the sound: it only
plays what the script says, bar by bar.

## When to use it
- You have no Launch Control XL 3 or Launchkey at hand and want to hear what a track can do.
- You want to try the [player](player.md) or a new track quickly.
- You want to hear a planned journey (intro, build-up, drop) the same way every time.

## How to use it
1. Start the player (`cd tools && node trajectory/server.mjs`) and open http://localhost:8766.
2. Pick a live track. Open **Settings** (key **S**) and find the **Auto-perform** section.
3. Pick a script from the list and press **Start** (or key **P**). The track reloads, so the script begins from
   silence at bar 0. The top bar shows the current section and the bars left in it.
4. Press **Stop** (or **P**) to end it. The controls keep their values; held keys are released.
5. To take over, move a control on a real controller. The control you move last wins, so your move replaces the
   script's value until the script sets that control again.

Scripts are JSON files in `tools/trajectory/perform/<track>/`. Every live track has `every-button.json`, a script that
tries each control once. Some tracks have longer performances with a short description next to them, for example
`tools/trajectory/perform/010-ambient-house/journey.md`. A script counts in bars (1 bar = 1 cycle); values run from 0
to 1. The full format is in `tools/trajectory/perform/script-format-v2.md`.

## Good to know
- The virtual controllers are called `LCXL3 Auto` and `Launchkey MK4 25 Auto`. A track treats them like the real
  devices ([controllers](controllers.md)).
- A real Launchkey plays along with the script. Its keys only sound while the mod wheel is up.
- The player also keeps a take of everything you play, and can save it as a new script (**Save take**). Details are in
  the Auto-perform and Takes sections of `tools/trajectory/README.md`.
- Check scripts with `cd tools && node trajectory/check-perform.mjs`; `npm run verify` runs it too. A new control or a
  changed `@ctl` text means the scripts need a check.
- Design and write a new performance with the Claude skill `auto-perform` ([Claude skills](claude-skills.md)). Claude
  cannot hear, so you listen and say what to change.
- Keep the player window visible while a script plays: a hidden browser tab slows its timers and spoils the timing.

## Related
- [Player](player.md)
- [Live tracks](live-tracks.md)
- [Controllers](controllers.md)
- [Glossary](../reference/glossary.md)
