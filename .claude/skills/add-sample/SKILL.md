---
name: add-sample
description: Add an audio file (own recording, voice line, freesound one-shot) to the repo and play it in a SuperCollider track - file into sc/samples/<folder>/, list it in the track's samples, put it on a Launchkey drum pad, level it, check it loads. Use when the user says "put this sample on pad E1", "add a sample", "new one-shot", "voice sample", "new recording for the pads", "replace pad X", or "the shaker/sample is silent".
---

# Add a sample (SuperCollider)

An SC track (`sc/tracks/<id>/<id>.scd`) reads its samples from disk: a path relative to `sc/samples/`
(`"voice/brace.wav"`) or `"repo:<path>"` for the repo's own `samples/` folder. A file that is not listed in the
track's `samples:` or not on disk is silent without an error; that is the usual cause of "the sample is silent".
No push is needed: SC plays the checkout. The frozen Strudel tracks are not changed (`DEPRECATION.md`).

## 1. The file
- Folder by kind: `sc/samples/voice/` (own spoken lines), a drum machine or instrument folder for one-shots
  (`tr909/`, `tr727/`, …); a new kind gets a new folder. Credit every external file in `sc/samples/CREDITS.md` (what,
  source, licence, edit); the licence must allow it (CC0 / CC BY).
- Name: lowercase, `_` or `-`, no spaces, commas or `#`.
- Format: wav or flac (SuperCollider cannot read m4a; convert with ffmpeg). Mono for voices. Keep it small: trim
  silence, one phrase. Above 1 MB ask; never commit a file over 10 MB (a hook refuses it; `voice/david.flac`, 44 MB,
  is the one file kept outside git).
- ffmpeg is installed: `ffmpeg -i in.m4a -ss 0.12 -to 3.5 -af 'afade=t=out:st=3.3:d=0.2' -ac 1 out.flac`;
  length for `once`: `ffprobe -v error -show_entries format=duration -of csv=p=0 out.flac`.

## 2. Register it (every SC track that should play it; ask which)
- Add the path to the track's `samples:` list (the Launchkey pads' files are at its end), so it loads with the track.
- A stem track (`<id>.track`) takes its pads from its frame `<id>-frame.scd`: register it there.

## 3. Map it to a pad
Drum pads (Drum mode) send notes 36-51 on channel 10; the track's `lkNote` plays `shots[(note - 36) % 16]`.
Novation names notes with middle C = C3, so 36 = C1. Pad grid, as the panel draws it:

| row    | left half (voices)          | right half                       |
|--------|-----------------------------|----------------------------------|
| top    | 40 E1, 41 F1, 42 F#1, 43 G1 | 48 C2, 49 C#2, 50 D2, 51 D#2     |
| bottom | 36 C1, 37 C#1, 38 D1, 39 D#1 | 44 G#1, 45 A1, 46 A#1, 47 B1    |

So "pad E1" = note 40 = `shots[4]`. Replace that entry, e.g. `(file: "voice/<file>.flac", tag: "<short>", gain: 1,
once: <seconds>)` (`once` for samples longer than about 3 s: hits while it plays are ignored; `rate` for pitch), and
the same position in `lkPadNames` (English, short). Keep 16 entries; ask before moving others. If the user plays pads
by position, confirm the pad when the note name and the position disagree.

## 4. Level
Set `gain` so the shot sits with the other pads (the existing ones were levelled to about −15 LUFS-M, dry). There is
no level meter any more: start from a similar pad's gain, then the user listens in the player (`/player`; the pad on
the Launchkey, or a perform step `{ "bar": 1, "pad": 40 }`) and says louder or quieter.

## 5. Check and report
- `cd tools && npm run verify-sc -- ../sc/tracks/<id>/<id>.scd`: the track loads and plays headless and every sample
  file exists (a missing one prints `missing: …`). Heavy step (sclang): one at a time.
- Update the pad list in `midi-layouts/devices.md` if names changed.
- Tell the user: which pad (note name and position), the file and its size, the gain, and that it plays as soon as the
  track is loaded again (not committed by you unless asked).
