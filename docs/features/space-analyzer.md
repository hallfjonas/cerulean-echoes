# Space analyzer

## What it is
A page in the [player](player.md) (Labs, Space) that shows where the sound space of a stem track is free and where it
is crowded. Time runs left to right, frequency bottom to top, and every cell of the map shows which stems sound there.
Each stem of the track is rendered alone in SuperCollider, measured in 64 frequency bands from 30 Hz to 16 kHz, and
the map is built from those measurements.

## When to use it
- A mix sounds muddy or thin and you want to see which frequencies are busy, and when.
- You want to know where a new stem could go: look for the free space.
- You want to know whether two stems fight: switch one off and watch the crowding.

## How to use it
1. Open the player (`cd tools && node trajectory/server.mjs`), go to Labs, then Space.
2. Pick a stem track and how many bars to render (4, 8, 16 or 32), then press Analyse. The first run renders every
   stem (a few seconds each, one at a time); the map fills in as they finish.
3. Per stem, in the sidebar:
   - the tick box includes it in the map, the colour swatch sets its colour (kept per track in the browser);
   - the pattern list and Settings (three knobs, level, the second button) set how it plays; its dot turns hollow
     ("needs a render") and Analyse renders just that stem again.
4. On the map:
   - Stems colours each cell with its loudest stem; Crowding counts the stems per cell; Free space shows only the gaps.
   - Cell size goes from 1/32 of a bar (thirty-second notes) to 1/1 (a whole note, one bar). Bars shown and From bar
     choose the window: one bar in 1/32 cells, or eight bars in whole notes.
   - Active within sets how far below the loudest sound a stem still counts as there. A smaller number shows more
     gaps.
   - The strip on the right shows how much of the time each band is used (green under 20%, red over 80%); the strip
     below shows how much of the spectrum each cell uses. Hover the map for the stems in a cell.
5. Render again ignores the saved renders and measures every stem anew.

## Good to know
- A render of a stem is saved in `recordings/space/` (outside git). A stem whose file, track frame, tempo, setting
  and length did not change is not rendered again.
- The setting is fixed for the whole run: the knobs and the pattern you choose are held from bar 1. Chords follow the
  track's frame (the first progression), and nothing moves during the render.
- Each cell shows the loudest part of a band, not an average. Notes below about 100 Hz are smeared over roughly
  85 ms, longer than one 1/32 cell: use 1/16 or coarser to judge the bass.
- The map adds left and right as power. The renders keep both channels, so pan can be shown later.
- Needs SuperCollider (`sclang`) installed.

## Related
- [Player](player.md)
- [Sound lab](sound-lab.md)
- [Stems](stems.md)
