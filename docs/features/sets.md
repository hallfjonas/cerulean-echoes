# Sets

## What it is
Set 011 plays four tracks as one long journey: 007 Ambient, then 010 Ambient House, then 009 Cool House, then 008
Groove Techno. One knob moves you along. Between two tracks the sound changes slowly, column by column: pad and air
first, then the low end, then drums, then melodies last. Tempo changes slowly too.

## When to use it
- You want a continuous performance of all four tracks without stopping.
- You want to hear how the tracks fit together.

## How to use it
1. Open `tracks/sets/011-combining-all/011-set-dual.strudel` and paste it into strudel.cc
   ([strudel.cc](strudel-cc.md)). It needs two Launch Control XL 3 (one for Jojo, one for Jonas). The Launchkey
   is optional ([controllers](controllers.md)).
2. Press button 2 of column 8 on Jonas' controller (**Set mode**). Now the Fog knob is the set position.
3. Turn the Fog knob from 0 to 1. Each track has a plateau where only it plays. Between two plateaus the old sound
   turns into the new one. Even a fast turn takes at least five seconds, so there are no jumps.
4. Press the button again to get the normal Fog knob back.

## Good to know
- Fog, Thin, Tension, Master, Chapter and Break keep their meaning ([glossary](../reference/glossary.md)). In the set,
  Chapter changes on a longer phrase, Tension reaches 75 % of its range, and there is no Break.
- The set file is generated. Never edit it by hand. It is built by `tools/set/make-set.mjs` from four frozen copies
  of the tracks in `tracks/sets/011-combining-all/sources/` and the frame `tools/set/set-frame.strudel`.
- The one-file tracks 007 to 010 changed after those copies were frozen, so changes to them do not reach the set.
- After changing a frozen source or the frame, run `cd tools && npm run set`. It builds the set and checks that each
  plateau plays its track event by event.
- `011-continuum-dual.strudel` in the same folder is an experiment: one continuous sound instead of four tracks
  crossfaded. Check it with `npm run continuum`.
- The set is not in the player catalogue.

## Related
- [Live tracks](live-tracks.md)
- [Controllers](controllers.md)
- [Checks](checks.md)
