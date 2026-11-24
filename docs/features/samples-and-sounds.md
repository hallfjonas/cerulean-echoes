# Samples and sounds

## What it is
A SuperCollider track plays two kinds of sound: synths (`sc/sounds/<name>.scd`, one sound per file) and samples. A
sample is a short audio file, such as a voice line, a drum hit or one note of a piano. Samples live in `sc/samples/`
(drum machines, instruments, the spoken lines in `sc/samples/voice/`, credits in `sc/samples/CREDITS.md`) or in the
repo's own `samples/` folder. Own samples are played from the Launchkey drum pads.

## When to use it
- You want to put your own recording on a pad.
- A sound is silent in the player and you want to know why.

## How to use it
Add a sample with the Claude skill `add-sample` ([Claude skills](claude-skills.md)). It does the steps:
1. The file goes into a folder under `sc/samples/` (`sc/samples/voice/` for spoken lines). Use a short lowercase name
   with hyphens, no spaces or commas, as wav or flac (SuperCollider cannot read m4a).
2. The track lists the file in its `samples:` and puts it on a pad (its `lkNote` one-shots and the pad name in
   `lkPadNames`). Pads are named like the Launchkey names them: C1 is note 36, E1 is note 40
   ([controllers](controllers.md)).
3. The level is set by ear in the player, so the new pad sits with the others.
4. Check that the track still loads and finds every file: `cd tools && npm run verify-sc -- <track.scd>`.

## Good to know
- A file that is not on disk stays silent, with no error. `verify-sc` and `npm test` list missing files.
- SuperCollider reads the files from your checkout: a new sample plays at once, no push needed.
- New synth sounds and whole drum sounds come from the [sound lab](sound-lab.md) (Sample Designer).
- Use only sounds you may use: own recordings, or CC0 and CC BY files with the credit in `sc/samples/CREDITS.md`.
- No file over 10 MB goes into git. Keep samples small (trim silence, mono for voices). The 007 voice
  (`sc/samples/voice/david.flac`, 44 MB) is the one exception and lives outside git.

## Related
- [Controllers](controllers.md)
- [Live tracks](live-tracks.md)
- [Checks](checks.md)
- [Sound lab](sound-lab.md)
