---
name: add-sample
description: Add an audio file (own recording, voice line, freesound one-shot) to the repo and play it in a track - file into samples/<folder>/, register it in the track's sample map, put it on a Launchkey drum pad, level it, check it loads, and say that it plays on strudel.cc only once pushed to main. Use when the user says "put this sample on pad E1", "add a sample", "new one-shot", "voice sample", "new recording for the pads", "replace pad X", or "the shaker/sample is silent" (also a sample that loads locally but not on strudel.cc).
---

# Add a sample

Tracks load this repo's samples from `https://raw.githubusercontent.com/hallfjonas/cerulean-echoes/main/samples/`
(`OWN_SAMPLES` in each track and in `tools/trajectory/banks.mjs`). A file that is not on `main` is silent on
strudel.cc and in the player, without an error. That is the usual cause of "the sample is silent".

## 1. The file
- Folder by kind: `samples/voice/` (own spoken lines), `samples/pads/` (pad material from elsewhere, credits in its
  `README.md`), `samples/mirror/` (only via `tools/strudel-sim/mirror-sound.mjs`, for bank sounds browsers cannot load).
  New kind: new folder with a `README.md` (what, source, licence, edit).
- Name: lowercase, hyphens, no spaces, commas or `#` (a comma breaks raw.githubusercontent in Chrome; spaces and `#`
  need `%20` / `%23` in the map). Older voice files have spaces: leave them.
- Format: mono mp3 (128k) for voice and one-shots, wav/flac only when short. Keep it small: trim silence, one phrase.
  Existing one-shots are 50-250 KB; above 1 MB ask; never commit a file over 10 MB.
- ffmpeg is installed: `ffmpeg -i in.wav -ss 0.12 -to 3.5 -af 'afade=t=out:st=3.3:d=0.2' -ac 1 -b:a 128k out.mp3`;
  length for `once`: `ffprobe -v error -show_entries format=duration -of csv=p=0 out.mp3`.
- External sounds: licence must allow it (CC0 / CC BY); add the credit to the folder README.

## 2. Register it (every one-file track that should play it: 007, 008, 009, 010)
- Voice lines: add `name: 'voice/<file>'` to `VOICE_SAMPLES` (loaded with `samples(VOICE_SAMPLES, OWN_SAMPLES)`).
  Keep the map identical in all four tracks. Pads whose `s` is in `VOICE_SAMPLES` get the voice colour in the LC view.
- Other own files: a map of the same shape next to it, loaded with `samples(map, OWN_SAMPLES)`.
- Short lowercase keys; a key must not shadow a bank sound name. Never edit `011-set-*` (generated, frozen sources).

## 3. Map it to a pad
Drum pads (Drum mode) send notes 36-51 on channel 10; `shotOf` plays `LK_SHOTS[note - 36]`. Novation names notes with
middle C = C3, so 36 = C1 (Strudel would call it c2). Pad grid, as the LC view draws it:

| row    | left half (voices)          | right half                       |
|--------|-----------------------------|----------------------------------|
| top    | 40 E1, 41 F1, 42 F#1, 43 G1 | 48 C2, 49 C#2, 50 D2, 51 D#2     |
| bottom | 36 C1, 37 C#1, 38 D1, 39 D#1 | 44 G#1, 45 A1, 46 A#1, 47 B1    |

So "pad E1" = note 40 = `LK_SHOTS[4]` (top row, first pad). Replace that entry:
`{ name: 'Short Name', s: '<key>', gain: 1, once: <seconds> }` (`name` shows in the LC view, English, short;
`once` for samples longer than about 3 s: hits while it plays are ignored). Keep 16 entries; ask before moving others.
If the user plays pads by position, confirm the pad when the note name and the position disagree.

## 4. Level
`cd tools && OWN=<url> SEC=16 node strudel-sim/pad-levels.mjs <track>` measures each pad dry (loudest 400 ms, LUFS-M).
It has its own copy of the voice map: add the new key there too. Set `gain` so the new shot sits at about
-15 LUFS-M like the others (the comment above `LK_SHOTS` says so). Before the push, serve the repo root locally
(the `static` entry in `.claude/launch.json`, or `python3 -m http.server 8770` in the repo root) and pass
`OWN=http://localhost:8770/samples/`.

## 5. Check and report
- `cd tools && node strudel-sim/check-sounds.mjs <track>` (online): updates `samples/sounds.json`; a file not on
  `origin/main` yet prints `warning: … plays only after push to main` (run `git fetch` first for a current answer).
- Update the pad list in `midi-layouts/devices.md` if names changed.
- Tell the user: which pad (note name and position), the file and its size, the level, and that it plays on
  strudel.cc only after the file is pushed to `main` (commit + push / merge; not committed by you unless asked).
- Test before merging: push the branch and point `OWN_SAMPLES` temporarily at
  `https://raw.githubusercontent.com/hallfjonas/cerulean-echoes/<branch>/samples/` in a scratch copy pasted into
  strudel.cc (never commit that URL); or measure locally as in step 4.
