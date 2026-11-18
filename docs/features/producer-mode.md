# Producer mode

## What it is
Producer mode turns a Guitar Pro song (exported as a MIDI file) into a live track plus an auto-performance. Every part
plays its notes as written, re-voiced with this project's sounds, in the usual live track layout.

## When to use it
When you have a song written in Guitar Pro and want to play it with the controllers like any other live track.

## How to use it
Not merged yet. At the time of writing, the converter tool (`tools/producer/`), the tracks 012 and 013 and the
`producer` skill are not on this branch. Only the source MIDI files exist, in
`.claude/epics/producer-mode-guitar-pro/`. This page will be filled in when the work is merged.

## Good to know
- The planned result is a normal live track, so it works with [controllers](controllers.md), the [player](player.md)
  and [auto-perform](auto-perform.md).
- The song's decisions (which part goes to which column, which voice) are meant to live in a map file beside the track.

## Related
- [Live tracks](live-tracks.md)
- [Auto-perform](auto-perform.md)
- [Claude skills](claude-skills.md)
