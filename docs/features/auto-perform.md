# Auto-perform

## What it is
Auto-perform plays a track for you. A script of control moves and button presses (a "performance") is sent to the
track (to SuperCollider), so the track sounds as if
someone turned the knobs. It does not listen to the sound: it only
plays what the script says, bar by bar.

## When to use it
- You have no Launch Control XL 3 or Launchkey at hand and want to hear what a track can do.
- You want to try the [player](player.md) or a new track quickly.
- You want to hear a planned journey (intro, build-up, drop) the same way every time.

## How to use it
1. Start the player (`cd tools && node trajectory/server.mjs`) and open http://localhost:8766.
2. Pick a live track. Find the **Auto-perform** section in the sidebar (key **S** shows it).
3. Pick a script from the list and press **Start** (or key **P**). The track reloads, so the script begins from
   silence at bar 0. The top bar shows the current section and the bars left in it.
4. Press **Stop** (or **P**) to end it. The controls keep their values; held keys are released.
5. To take over, move a control on a real controller. The control you move last wins, so your move replaces the
   script's value until the script sets that control again.
6. To start a performance at a later bar, or to edit it and hear the change first, open it in the
   [Tracks lab](tracks-lab.md) and use Play there.

Scripts are JSON files in `tools/trajectory/perform/<track>/`. Every live track has `every-button.json`, a script that
tries each control once. Some tracks have longer performances with a short description next to them, for example
`tools/trajectory/perform/010-ambient-house/journey.md`. A script counts in bars (1 bar = 1 cycle); values run from 0
to 1. The full format is in `tools/trajectory/perform/script-format-v2.md`.

## Good to know
- A SuperCollider track takes the script's moves like moves of the real devices ([controllers](controllers.md)).
- A real Launchkey plays along with the script. Its keys only sound while the mod wheel is up.
- The player also keeps a take of everything you play, and can save it as a new script (setting **Save take on record stop**). Details are in
  the Auto-perform and Takes sections of `tools/trajectory/README.md`.
- Check scripts with `cd tools && node trajectory/check-perform.mjs`; `npm run verify-sc` runs it too. A new control or a
  changed `@ctl` text means the scripts need a check.
- Design and write a new performance with the Claude skill `auto-perform` ([Claude skills](claude-skills.md)). Claude
  cannot hear, so you listen and say what to change.
- A button switches at the next bar line (Chapter at the next 4-bar line): press it half a bar before the bar where it
  should take over (`7.5` for bar 8). The Tracks lab does this for its Press and Break moves.
- Started at a later bar (Tracks lab), a script's values at that bar and its presses before it go with the load, so
  the track's patterns and chapters are where the script put them; keys and pads before it are not played.
- Keep the player window visible while a script plays: a hidden browser tab slows its timers and spoils the timing.

## Related
- [Player](player.md)
- [Tracks lab](tracks-lab.md)
- [Live tracks](live-tracks.md)
- [Controllers](controllers.md)
- [Glossary](../reference/glossary.md)
