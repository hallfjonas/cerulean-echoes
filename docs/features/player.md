# Player

## What it is

A web page on your own computer that plays any live track or lab board and draws the music: every part of the track
is a moving shape with its name. It also holds a Tools page for the checks and a recorder.

## When to use it

- To play a track without opening strudel.cc.
- To rehearse, or to try a track with no controller (auto-perform).
- To see what the parts of a track do, for example on a projector.
- To record what you play as a WAV file.

## How

1. Start it: `cd tools && node trajectory/server.mjs`, then open http://localhost:8766 in Chrome. Steps in
   [getting started](../getting-started.md).
2. Pick a track in the top list. **Live** = the live tracks, **Lab** = the [lab boards](lab-boards.md). Boards
   without a master `stack(` are greyed out.
3. Press **Play**. Press **Stop** to end. Picking another track stops the current one.
4. Play with the [controllers](controllers.md). A control you have not moved reads 0.

The top bar holds the track list, Play, Stop, Record, the status line, Settings and the page links (Player, Tools,
Analysis). It hides after 3 seconds without the mouse.

Keys:

| Key | What it does |
|---|---|
| S | Settings drawer |
| P | start or stop auto-perform |
| R | record the sound to a WAV file |
| F | fullscreen |
| ? | help for the page you are on |
| A, L, B, H, V, W | axes, labels, beat rings, controller frame, look (deck, ocean, clean), pan width |

## Good to know

- The player reads the track file again on every load. Edit a track, press Play, and you hear the edit. There is no
  extra step and no copy of the track on disk.
- A track never needs the player. The same file plays pasted into [strudel.cc](strudel-cc.md).
- The picture is for looking only. The Hard / Soft and Raw / Smooth sliders in Settings change the visuals, never the
  sound.
- Recordings go to `recordings/<track>/` in the repo root and are not part of git.
- The Tools page (http://localhost:8766/tools.html) runs the Node checks from the browser, one job at a time.
- A tab in the background slows its timers down. Keep the player tab visible while a script or a replay runs.
- Without Web MIDI the player still plays.

Detail: [tools/trajectory/README.md](../../tools/trajectory/README.md).

## Related

- [Getting started](../getting-started.md)
- [Controllers](controllers.md), [live tracks](live-tracks.md)
- [Auto-perform](auto-perform.md), [visuals](visuals.md), [checks](checks.md)
