# Player

## What it is

A web page on your own computer that plays any live track or lab board. It opens on the MIDI panel: both Launch
Control pages and the Launchkey row with every control's name and value. Its second view draws the music: every part
of the track is a moving shape with its name. It also holds a recorder.

## When to use it

- To play a track without opening strudel.cc.
- To rehearse, or to try a track with no controller (auto-perform).
- To see what the parts of a track do, for example on a projector.
- To record what you play as a WAV file.

## How

1. Start it: `cd tools && node trajectory/server.mjs`, then open http://localhost:8766 in Chrome. Steps in
   [getting started](../getting-started.md).
2. Pick a track in the sidebar on the left. **Live** = the live tracks, **Lab** = the [lab boards](lab-boards.md). Boards
   without a master `stack(` are greyed out.
3. Press **Play**. Press **Stop** to end. Picking another track stops the current one.
   A SuperCollider track (most live tracks; the old Strudel version is listed as "(Strudel)") starts SuperCollider
   in the background the first time, which takes a few seconds. SuperCollider must be installed. Record,
   auto-perform and the visuals do not work for SuperCollider tracks yet.
4. Play with the [controllers](controllers.md). A control you have not moved reads 0.

The sidebar holds the views (MIDI panel, Visuals), the track list, Play / Pause, Stop,
Record and Auto-perform. The gear next to the views opens **Settings**: Theme, Visuals, MIDI panel, Recording and a list
of the keyboard shortcuts, with a list of sections on the left to jump between them. Switching views keeps the sound playing. The top bar holds the
status line and **?** for help about the page.

Keys:

| Key | What it does |
|---|---|
| S | hide or show the sidebar |
| P | start or stop auto-perform |
| R | record the sound to a WAV file |
| F | fullscreen |
| ? | help for the page you are on |
| A, L, B, H, V, W | axes, labels, beat rings, controller frame, look (deck, ocean, clean), pan width |

## Good to know

- The player reads the track file again on every load. Edit a track, press Play, and you hear the edit. There is no
  extra step and no copy of the track on disk.
- A track never needs the player. The same file plays pasted into [strudel.cc](strudel-cc.md).
- The picture is for looking only. The Hard / Soft and Raw / Smooth sliders in Settings (Visuals) change the visuals, never the
  sound.
- Recordings go to `recordings/<track>/` in the repo root and are not part of git.
- A tab in the background slows its timers down. Keep the player tab visible while a script or a replay runs.
- Without Web MIDI the player still plays.

Detail: [tools/trajectory/README.md](../../tools/trajectory/README.md).

## Related

- [Getting started](../getting-started.md)
- [Controllers](controllers.md), [live tracks](live-tracks.md)
- [Auto-perform](auto-perform.md), [visuals](visuals.md), [checks](checks.md)
