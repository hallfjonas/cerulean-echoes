# Samples and sounds

## What it is
A track plays sounds from three places: synths built into Strudel, sound banks (drum machines, soundfonts, VCSL
instruments) and our own samples in `samples/`. A sample is a short audio file, such as a voice line or a one-shot
hit. Own samples are played from the Launchkey drum pads.

## When to use it
- You want to put your own recording on a pad.
- A sound is silent in the player or on strudel.cc and you want to know why.

## How to use it
Add a sample with the Claude skill `add-sample` ([Claude skills](claude-skills.md)). It does the steps:
1. The file goes into a folder under `samples/` (`samples/voice/` for spoken lines, `samples/pads/` for other pad
   material). Use a short lowercase name with hyphens, no spaces or commas, and a small mono mp3.
2. The file is registered in the track's sample list and put on a pad. Pads are named like the Launchkey names them:
   C1 is note 36, E1 is note 40 ([controllers](controllers.md)).
3. The level is measured and set, so the new pad is as loud as the others.
4. Check that every sound loads: `cd tools && node strudel-sim/check-sounds.mjs <track>`.

## Good to know
- Own samples load from the `main` branch on GitHub. A file that is not on `main` yet stays silent, with no error.
  This is the usual reason for "the sample is silent". Push or merge to `main` first.
- `samples/sounds.json` lists every sound a track uses: `ok` (loads, and from where) and `broken` (does not load, and
  why). The check updates it.
- Some bank sounds do not load in a browser, for example when the file path has a comma. A copy goes into
  `samples/mirror/` with `node strudel-sim/mirror-sound.mjs <sound>` and then plays under the same name once pushed.
- Use only sounds you may use: own recordings, or CC0 and CC BY files with the credit in the folder's `README.md`.
- No file over 10 MB goes into git. Keep samples small.

## Related
- [Controllers](controllers.md)
- [Live tracks](live-tracks.md)
- [Checks](checks.md)
- [Player](player.md)
