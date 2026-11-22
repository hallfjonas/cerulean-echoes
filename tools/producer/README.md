# producer — a Guitar Pro song (MIDI) → a live track with a performance

One command turns a Guitar Pro song into a one-file live track (layout of 007-010, every controller optional), a song
design stub, a perform script and its design stub. Every part plays its notes as written, stored per section,
re-voiced with the project's sounds; song bar 1 = cycle 0, one bar = one cycle. The workflow around it (design gate,
listening loop, feeding lessons back) is the project skill `/producer` (`.claude/skills/producer/SKILL.md`).

Built from the pilot `fixtures/012-edm-snippet/` (hand-built, the producer reproduces its events) and proven on
`fixtures/013-hope-for-niklas/` (generated, the map regenerates the track and its script exactly). The two songs were
removed from `tracks/` on 2026-11-20; their `.mid`, map, track (`.strudel-fixture`) and perform script stay here as test
fixtures.

## Export from Guitar Pro
1. File → Export → MIDI. One `.mid` per song.
2. Name it `gp-<song>.mid` (lowercase, dashes) and put it in the track folder `tracks/<genre>/NNN-<name>/`; the
   producer copies it there otherwise.
3. What the reader handles: format 0/1, running status, any number of tracks, Guitar Pro's two channels per track
   (merged), program changes inside a track (a voice change at that bar), markers (become sections), GM drums on
   channel 10, grids down to 1/1024 of a bar.
4. What it does not handle yet (see `.claude/prds/producer-slow-rock.md`): tempo changes (the first tempo is used, with
   a warning), time signatures other than 4/4 and pickup bars (counted as 4/4, with a warning: everything after
   shifts), triplets and other non-power-of-two grids (the producer stops with "no power-of-two grid up to 1/1024
   fits"), lyrics, bends (plain notes).

Check a file before producing: `node producer/midi-read.mjs <file.mid>` prints tempo, bars, markers and per track the
channels, programs, note count, grid and range, plus warnings. `--dump [--track n] [--bars a-b]` prints a part as
mini-notation per bar, `--json` the whole song.

## Commands (in `tools/`)
```
npm run producer -- <file.mid> [--map <map.json>] [--name <NNN-name>] [--genre <genre>] [--out <dir>] [--force]
npm run producer -- <file.mid> --map <map.json> --perform
node --test producer/*.test.mjs
```
- Without `--map` every decision gets a default and the map is written beside the track
  (`<track>-map.json`); edit it, then re-run with `--map … --force`.
- `--name` track id (default: the map's `track`, else the next free number + the file name); `--genre` `edm` or
  `classical` pick voices, Mode 2 extras and pads (any other genre gets the EDM ones).
- `--out <dir>` writes every file into one folder (a dry run); without it the track goes to `tracks/<genre>/<id>/` and
  the performance to `trajectory/perform/<id>/`.
- Nothing is overwritten without `--force`, so filled-in designs survive a re-run.
- `--perform` writes only `perform/<id>/<name>.json` from the map's `performance` (overwriting it); the track and both
  designs are left alone.

Files written: `<id>.strudel`, `<id>-design.md` (stub), `<id>-map.json` (only without `--map`), the `.mid` (copied),
`perform/<id>/<name>.json` and `<name>.md` (stub).

After generating: `node strudel-sim/transpile-check.mjs <track>` (syntax as strudel.cc reads it) and
`node trajectory/check-perform.mjs <track>`; then listen in the player. The Strudel level and sound checks
(`verify`, `audibility`, `check-sounds`) were removed with sc-migration 010.

## The map (`<track>-map.json`)
Every decision the user made; a re-run keeps them. Bars are song bars (1-based).

| Key | What |
|---|---|
| `track`, `title`, `genre`, `source` | id, title, genre folder, the `.mid` file name |
| `template` | `song` (the only template: `producer/song.strudel-template`, the pilot with slots) |
| `bpm`, `key` | tempo; key `{ name, root, scale }` (root 0-11, `minor` / `major`) |
| `harmony` | one chord per bar of a loop `{ name, pad }` (pad = mini-notation chord), for the pad and keys |
| `sections` | `{ name, from, to }`, contiguous from bar 1 to the last bar |
| `stopBars` | bars with one hit then silence (Mode 2 extras rest there) |
| `grid` | Chapter switches at the next `grid`-bar phrase; chapters must start and end on it |
| `chapters` | `{ name, from, to }`, first = `Song` (the whole song); others loop a stretch that starts and ends on sections |
| `master` | Master fader default |
| `columns` | see below |
| `mode2` | the Mode 2 page name (default `Extras`) |
| `launchkey` | `keysGain`, `pads` (8 one-shots after the 8 voice pads: `{ name, s, note?, gain?, layers?, about? }`) |
| `performance` | `{ name, title, bars, mood, sections, moves }`, see below |
| `unassigned` | parts without a column (listed in the design stub) |

A column: `{ page, col, id, name, part, partName, voices, patterns, what?, plays? }`.
- `page` 1 (Mode 1) or 2 (Mode 2), `col` 1-7, `id` camelCase, `part` the MIDI track index (from `midi-read`).
- `voices`: `{ part?, fromBar, program, voice }` from its bar on. A program change is another entry of the same part;
  an entry with another `part` is stacked on top (grouping two parts in one column). Voices in one column must share
  their controls. Voice names: `producer/voices.mjs` (EDM from the pilot, Classical on the Sonatina Symphonic
  Orchestra samples).
- `patterns` (button 1, at most 3): the first is the song as written (a name only); then `bars: [n…]` loops those
  song bars, one per bar; `mini: [...]` own figures, one bar each in turn; `transpose: 12`; `phrase: <section>` plays
  that section at the end of every `grid`-bar phrase; `off: true`; `figure: true` (extras) the figure in every bar.
- Mode 2 extras have no `part`: `plays: [<section>…]` names where their figure plays.
- `what` overrides the fader's `@ctl` text.

The performance: `sections` in script bars (0-based `[from, to)`, script bar = song bar − 1 + song length × run);
`moves` by control name, turned into CCs by the producer: `{ bar, set: '<@ctl name>', to, ramp? }`,
`{ bar, press: 'Chapter' }`, `{ bar, pad: '<pad name>' }`, `{ bar, lk: 'Brightness', to }`, `{ bar, keys: … }`.
Unknown names fail with the list of valid ones.
