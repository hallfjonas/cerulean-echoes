# Player

## What it is

A web page on your own computer that plays any live track or lab project. It has three pages. **Live** (the start page) shows both Launch
Control pages and the Launchkey row with every control's name and value, and lets you pick a live track and
auto-perform it. **Labs** holds the Sample Designer and Stem Designer (Tracks and Sets are placeholders).
**Visuals** draws the music: every part of the track is a moving shape with its name. It also holds a recorder.

## When to use it

- To play a track without opening strudel.cc.
- To rehearse, or to try a track with no controller (auto-perform).
- To see what the parts of a track do, for example on a projector.
- To record what you play as a WAV file.

## How

1. Start it: double-click `Cerulean Echoes.app` in the repo folder, or `cd tools && node trajectory/server.mjs`, then
   open http://localhost:8766 in Chrome. Steps in [getting started](../getting-started.md).
2. Pick a track in the sidebar on the left. **Live** = the live tracks, **Lab** = the ear-training tutorials ([lab boards](lab-boards.md) are retired). Boards
   without a master `stack(` are greyed out.
3. Press **Play**. Press **Stop** to end. Picking another track stops the current one.
   A SuperCollider track (most live tracks; the old Strudel version is listed as "(Strudel)") starts SuperCollider
   in the background the first time, which takes a few seconds. SuperCollider must be installed. Record,
   auto-perform and the visuals do not work for SuperCollider tracks yet.
4. Play with the [controllers](controllers.md). A control you have not moved reads 0.

The sidebar shows only what the page needs. **Live**: the live track list, Play / Pause, Stop, Record and
Auto-perform. **Labs** (Samples, Stems & Tracks): the project list, Play / Pause, Stop and the designer buttons; the waveform
analysis shows under the controllers on Samples only. **Visuals**: Stop. Switching pages keeps the sound playing; a page
has its own address (`#live`, `#labs/samples`, `#labs/stems`, `#labs/sets`, `#visuals`). The gear next to
the pages opens **Settings** on top of the current page: Theme, Visuals, MIDI panel, Recording and a list of the keyboard
shortcuts, with a list of sections on the left to jump between them.

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
