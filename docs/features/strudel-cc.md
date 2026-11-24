# strudel.cc

## What it is
[strudel.cc](https://strudel.cc) is the web editor for Strudel, the live coding language the tracks were first
written in. Strudel is deprecated ([DEPRECATION.md](../../DEPRECATION.md)): the live tracks play on SuperCollider now,
and their Strudel files in `tracks/` are frozen. Each frozen file still plays on strudel.cc exactly as it is.

## When to use it
When you do not have the repo running, you want to play at a friend's place, or you want the plain Strudel experience.

## How to use it
1. Open strudel.cc in Chrome (it needs Web MIDI for the controllers).
2. Copy the whole track file, for example `tracks/techno/008-groove-techno/008-groove-techno.strudel`, and paste it
   into the editor.
3. Connect the Launch Control XL 3 and the Launchkey, allow MIDI access, and press play.
4. To get the visuals as well, run in `tools/`:
   `node trajectory/make-tapped.mjs <track.strudel>` (copies the code to the clipboard on macOS), paste that into
   strudel.cc, and keep the player open next to it.

## Good to know
- The player offers more: auto-perform, recording, checks and the LC view. strudel.cc has none of these.
- Your own samples load from `main` on GitHub. A new sample plays on strudel.cc only after it is pushed to `main`.
- The player loads the same sound banks as strudel.cc, so a sound that works in one works in the other.
- Without a controller you can still play; unmoved controls read 0.

## Related
- [Player](player.md)
- [Live tracks](live-tracks.md)
- [Samples and sounds](samples-and-sounds.md)
- [Controllers](controllers.md)
