---
name: producer
description: Turn a Guitar Pro song (MIDI export) into a live track with an auto-performance - export, generate with `npm run producer`, song design gate, listening loop, lessons back into the tool. Use for 'producer', 'next song', 'new Guitar Pro song', 'Guitar Pro to track', 'MIDI to track', 'make a track from this .mid'.
---

# Producer: a Guitar Pro song → a live track + performance

The producer still writes Strudel (deprecated, `DEPRECATION.md`; an SC output is decided when the next song comes:
ask the user before generating). The producer (`tools/producer/`, README there: export, map format, commands) writes a
one-file live track whose stems
play the song's parts as written, re-voiced, plus design stubs and a perform script. Decisions live in
`<track>-map.json`; the track is regenerated from it, never patched by hand. Two user gates, both logged:
the song design (track folder `feedback.md`) and the performance (`tools/trajectory/perform/<track>/feedback.md`).
The agent cannot hear: the user's words decide. Examples to match: `tools/producer/fixtures/012-edm-snippet/` (hand-built pilot)
and `tools/producer/fixtures/013-hope-for-niklas/` (generated), each with its map and perform script.

## 1. Export and read
1. The user exports from Guitar Pro: File → Export → MIDI. Pick the number (next free `NNN` over `tracks/*/`) and
   genre (pick it by the definitions in `docs/reference/genres.md`); put the file at `tracks/<genre>/NNN-<name>/gp-<name>.mid`. `git status`, `gh pr list` first (CLAUDE.md Git).
2. `cd tools && node producer/midi-read.mjs <file.mid>`: tempo, bars, markers, per part channels, programs (with the
   bar of each change), notes, grid, range, warnings. Stop and tell the user on a tempo change, a pickup or non-4/4
   bar, or "grid finer than 1/1024 (triplets?)": the producer does not handle them yet
   (`.claude/prds/producer-slow-rock.md`). `--dump --track n --bars a-b` shows a part as mini-notation.

## 2. Generate (dry run first)
1. `npm run producer -- <file.mid> --name NNN-<name> --genre <genre> --out <scratchpad dir>`: writes the track, the map
   with every default, both design stubs and a first-pass script into one folder. Read the map and the design stub;
   `node strudel-sim/transpile-check.mjs <track>`.
2. Then for real (same command without `--out`): `tracks/<genre>/NNN-<name>/` and `trajectory/perform/NNN-<name>/`.
3. Checks before showing anything: `node strudel-sim/transpile-check.mjs <track>`,
   `node trajectory/check-perform.mjs <track>`, `npm run shared -- --check`. The Strudel level and sound checks were
   removed (sc-migration 010): levels are set by ear in the player.

## 3. Gate 1: the song design
Fill `<track>-design.md` from the stub: the song (sections with song bars and script bars), layout table (column,
name, MIDI part, voice, patterns), Mode 2, Chapter, Launchkey pads, open questions. Give options with a recommended
pick for each question (grouping when a song has more than 7 parts, voices with two options, Chapter meaning, Mode 2,
patterns), so "looks good" settles them; say in the log that unanswered questions take the picks. Log
`## Round N: design` in the track's `feedback.md`; nothing is built further before the user's own "approved" is quoted
there. Decisions go into the map, then regenerate: run into `--out <scratchpad dir>` and copy only the `.strudel` over
(`--force` would overwrite the filled designs). Labels and `@ctl` texts follow CLAUDE.md Labels.

## 4. Gate 2: the performance
Follow `/auto-perform` (design after `tools/trajectory/perform/design-template.md`, then script, check, listen), with
two differences:
- The script comes from the map's `performance` (`moves` by `@ctl` name): edit the map, then
  `npm run producer -- <file.mid> --map <map.json> --perform` (writes only the `.json`).
- Starting a performance restarts the song at bar 1; script bar = song bar − 1 + song length × run.
Checks: `node trajectory/check-perform.mjs <track>`. The user listens in the player (`/player`, in Chrome) and
answers by section and bar; log `## Loop N / Round M` until approved.

## 5. Feed back into the tool
Every hand change goes into the map, `producer/voices.mjs` or `producer/make-track.mjs` (with a test), or is listed
as a known gap under `## For the converter` in the track's `feedback.md`. After a tool change:
`node --test producer/*.test.mjs` (012 still plays its hand-built events, 013 regenerates exactly), and
`npm run shared -- --check`. Add new lessons below.

## Lessons from 012 and 013
- Song form is absolute (song bar = cycle mod length + 1): give every section table song bars and script bars, so the
  performance is written without arithmetic.
- Section starts on the chapter grid and a song length that is a multiple of it make every chapter return land on a
  section start (012: grid 8, 24 bars). A chapter that keeps the song's place cannot repeat a section: after a held
  chapter the song resumes mid-section (013). A repeat needs chapters that restart at their first bar (no map option
  yet).
- Mode 2 extras that play only in the drop sections are silent in a looping build chapter: a build needs its own
  percussion (Tension's snare roll, Hats Complexity). In the EDM template Tension's snare roll lives in the Clap stem:
  Clap fader 0 = no roll.
- Event gains differ by voice far more than by fader (012: Noise Pump at 0.4 loudest, Arp at 0.35 above Chords at
  0.6): level the stems before the performance is written.
- The first-pass script ramps every fader from 0 over 2 bars: a part whose first note is at bar 0 starts nearly
  silent (a note keeps the level it starts with). Set those levels, do not ramp them. A song with a written ending
  wants one run plus a ring-out bar, not two runs.
- Stop bars (one hit, then silence) are the place for one-shots and fills; name them in the design.
- The user approves with a word ("Looks good", "Approve", "Approved"): quote it, then the recommended picks apply.
