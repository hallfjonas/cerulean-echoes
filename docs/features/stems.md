# Stems

## What it is
A **stem** is one fully set-up column of the Launch Control XL 3, kept as a file: a sound, its patterns (button 1),
three knobs, the fader and an add-on on button 2. A stem does not know which column or track it sits in. Stems live in a
library, `sc/stems/`, one folder per sample, one JSON file per version.

A **stem track** puts stem versions on the 14 stem slots of the two LC modes and adds the track-wide frame: tempo,
harmony, chapters, the global column 8 and the Launchkey. A **set** is an ordered list of tracks.

Stems play on SuperCollider only (`sc/`). The Strudel tracks are not converted.

## When to use it
- You want to reuse a column of one track in another track.
- You want to compare versions of a column side by side (Stem Designer) or swap a column in the player.
- You write a new column for an SC track and want it in the library.

## How to use it
1. Pick the sample: a sound in `sc/sounds/` (the Sample Designer makes new ones). The stem goes into
   `sc/stems/<sample>/`, the folder named exactly like the sound, for example `sc/stems/kick909/`.
2. Write the stem as JSON (format below). Start from an example:
   `sc/stems/kick909/kick909-brightness-space-punch-pattern-drop-out.stem` (drum) or
   `sc/stems/bassWarm/bass-warm-brightness-space-length-pattern-octave.stem` (melodic).
3. Name the file after the sample and the labels (naming rule below).
4. Check it: `cd tools && npm run check-stems` (the whole library) or `node stems/check-stems.mjs <file.stem>`.
   `npm run verify` and `npm test` run the same check.

## Words
- **Sample**: a playable sound in `sc/sounds/<name>.scd` (a synth or audio files with named parameters). The repo calls
  these "sounds"; "sample" is the same thing.
- **Stem**: sample + patterns + knobs 1-3 + fader + button 2 add-on, column-agnostic.
- **Stem version**: one file of a stem. All versions of a stem share its sample. A version with another sample is
  another stem.
- **Parent**: the version a version was made from.
- **Add-on**: what button 2 does (Echo throw, Octave, Roll …), from a shared add-on library.
- **Frame**: everything of a track that is not a stem: harmony, chapters, global column 8, Launchkey.

## The file name
`<sample>-<k1>-<k2>-<k3>-<b1>-<b2>.stem`, every part lowercase kebab-case ASCII made from the sample name and the five
control labels: camelCase splits (`bassWarm` → `bass-warm`), everything that is not a letter or digit becomes `-`
(`Hats ↔ Shaker` → `hats-shaker`, `Echo throw` → `echo-throw`).

Example: sample `flute`, labels Brightness, Space, Complexity, Pattern, Echo throw →
`flute-brightness-space-complexity-pattern-echo-throw.stem`.

A second version with the same labels gets `-2`, then `-3`. The `name` field is the file name without `.stem`.
`check-stems` builds the name from the file and refuses a mismatch.

## Versions
- A version is a new file, never an edit of a played one. A track pins exact versions, so a new version never changes a
  track silently; a track takes a new version by a swap.
- `parent` is the path of the version it came from, relative to `sc/stems/` (`"kick909/kick909-…-drop-out.stem"`), or
  `null` for a first version. The parent is in the same folder (same sample).
- Which tracks use a version is computed from the track files (`npm run stems`, task 004), never stored in the stem.

## The stem file (format 1)
Schema: `sc/stems/stem.schema.json`. All fields:

| Field | Required | What it is |
|---|---|---|
| `format` | yes | `1` |
| `name` | yes | the file name without `.stem` |
| `parent` | yes | path of the parent version under `sc/stems/`, or `null` |
| `about` | yes | one line (at most 60 characters): what the stem is |
| `meta` | yes | `role`, `genres`, `energy`, `tags`, `harmony` (see Metadata) |
| `sample` | yes | `name` of the sound in `sc/sounds/`, optional `preset` (parameter → number, only the sound's parameters) |
| `gain` | no | loudness trim (linear, default 1) that brings the stem to the common target level |
| `pitch` | yes | how `notes` are read: `none`, `midi`, `root`, `chord`, `scale` (see Patterns) |
| `code` | no | SC file next to the stem that makes the stem's events (escape hatch) |
| `frame` | no | how the stem follows the global column (see Stem contract) |
| `patterns` | yes | the patterns button 1 steps through, at least one |
| `controls` | yes | `k1`, `k2`, `k3`, `fader`, `b1`, `b2` |

### Patterns
Each pattern has a `label` (short, shown in the live view, at most 20 characters) and mini-notation strings, the part
of Strudel's mini-notation that `sc/lib/mini.scd` reads: steps, `~` rests, `@n` weights, `!n` repeats, `[ ]`
sub-sequences, `< >` one item per bar. One cycle is one bar.

- `rhythm`: when it plays; `x` is a hit, `~` a rest.
- `notes` (optional): which note each hit plays. A hit takes the value of `notes` at its start time (like Strudel's
  `struct`), so `notes` can be shorter or longer than `rhythm`.
- `velocity` (optional): 0..1 per hit, read the same way, multiplied into the sound's `amp`.

`pitch` says what a note number means:

| `pitch` | Note number | For |
|---|---|---|
| `none` | ignored | drums, noise |
| `midi` | absolute MIDI note | fixed lines that do not follow the harmony |
| `root` | semitones above the current chord's bass note | sub, bass |
| `chord` | index into the current chord's tones (0 = lowest, past the last = next octave) | chords, pads, stabs |
| `scale` | steps of the current scale, 0 = the chord's root | leads, melodies |

Button 1 steps to the next pattern at the next bar. On a Mode 1 slot a stem has at most 3 patterns (the track check
refuses more).

### Controls
Every control has a `label` (at most 20 characters) and an `about` (one short line, at most 60 characters: what the
control does, no ranges or history), the same texts as a track's `@ctl` lines.

| Control | Label | What it maps |
|---|---|---|
| `k1` | `Brightness` | a parameter, usually the sound's `bright` |
| `k2` | `Space` | usually `space` (room send), or `targets` for room + echo |
| `k3` | named for what it does (Length, Complexity, Punch …) | a parameter, several, or code |
| `fader` | `Level` | the stem's level, from the next note on (× `gain` × master) |
| `b1` | `Pattern` (`Chords` on a chords stem) | the next pattern at the next bar, or `code` |
| `b2` | named for its add-on | an add-on from `sc/stems/addons.json` (`addon`) or `code` |

A knob maps its value 0..1 in exactly one way:
- `param` + `range` (+ `curve`: `lin` default or `exp`): one parameter from `range[0]` (knob at 0) to `range[1]`.
- `targets`: a list of `{ param, range, curve }` moved together.
- `code`: an SC file next to the stem.

A parameter is one of the sound's parameters or SynthDef inputs (not `out`, `post`, `freq`), or a stem parameter:
`space` (room send), `echo` (echo send), `pan`. Knobs act at once, also on sounding notes.

Button 2 has a `mode`: `hold` (on while held), `toggle` (press on, press off) or `step` (each press steps to the next
state at the next bar), and optional `args` for the add-on. With `addon`, the label is the add-on's label (one name per
job) and the mode one of the add-on's modes.

### Escape hatch
What JSON cannot say (009's Complexity steps, a knob that cross-fades three sounds, multi-sound keys) lives in an SC
file next to the stem: the stem's `code` (makes the events), or `code` on `k1`-`k3`, `b1`, `b2`. The SC file returns
the same event shape as the JSON parts (task 002 fixes the SC side). The JSON still carries every label, `about` and
the metadata. Prefer JSON; with a stem `code`, a pattern needs only its `label`.

## Label rules
`check-stems` enforces the project's label rules:
- row 1 `Brightness`, row 2 `Space`, fader `Level`, button 1 `Pattern` (`Chords` only on a stem with role `chords`);
- row 3 and button 2 are named for what they do, start with a capital letter and never reuse a name of another job
  (Brightness, Space, Level, Pattern, Chords, Fog, Thin, Tension, Master, Chapter, Break);
- every `about` at most 60 characters (aim for about 50), every label at most 20.

## Add-ons (button 2)
The shared add-on library is `sc/stems/addons.json`: id, label, about, modes and args. A stem names an add-on by its
id; the SC add-on library (task 002) builds each one. These are the button-2 jobs of the SC tracks 007-010 and 016,
taken from their `@ctl … .b2` lines:

| Label | Job | Tracks | In the library |
|---|---|---|---|
| Drop out | the stem pauses while held (009 calls it "Drop") | 007, 008, 009, 010, 016 | `dropOut` |
| Echo throw | long echo while held | 007, 008, 009, 010, 016 | `echoThrow` |
| Octave | one octave up while held | 007, 008, 009, 010, 016 | `octave` |
| Riser | a noise sweep rises over 2 (016: 4) bars | 007, 008, 009, 010, 016 | `riser` |
| Roll | a roll growing over the bar (snare, 16ths, wood, 32nds) | 007, 008, 009, 010, 016 | `roll` |
| Fill | a run over the bar (congas, bongos, every 16th) | 007, 008, 009, 010, 016 | `fill` (args: `rhythm`, `notes`) |
| Open | open hats (009, 010); the breath opens fully (008) | 008, 009, 010 | `open` |
| Long | open hats ring longer | 008, 016 | `long` |
| Swell | a snare swell over 4 bars | 008 | `swell` |
| Stutter | each beat's start repeats in 16ths | 007 | `stutter` |
| Ratchet | each note repeats in quick 16ths | 016 | `ratchet` |
| Burst | a quick scatter of accents | 016 | `burst` |
| Lift | the section grows (009 2:7: phaser, brighter) | 009 | `lift` |
| Freeze | holds the current chord, for everybody | 007, 010 | no: stem `code` (touches the harmony) |
| Colour | 7 → 9 → fourths → fifths, at the next bar | 008, 016 | no: stem `code` (step) |
| Answer | the answer phrase in every bar / extra answers | 008, 010, 016 | no: stem `code` |
| Run | scale or chord runs, denser while held | 007, 010 | no: stem `code` |
| Stab | a chord on every off-beat | 010 | no: stem `code` |
| Layer | Eno → Shimmer → both, at the next bar | 007 | no: stem `code` (step) |
| Full choir | all three voices while held | 007 | no: stem `code` |
| Flock | a whole flock calls | 010 | no: stem `code` |
| Sound | knobs become the sound mix | 009 | no: stem `code` |

Column 8's button 2 (Break) is part of the frame, not an add-on.

## Stem contract
Every stem in the library keeps these promises. The frame gives a stem its standard inputs; a stem never reads a CC
or the global column itself.

| Input | From | What the stem does with it | Opt out |
|---|---|---|---|
| Harmony | frame (chords, progressions, chapters) | its notes follow the current chord through `pitch` | `pitch: none` |
| Tempo | track `tempo` | one cycle is one bar; patterns never set a tempo | no |
| Swing | track `swing` | off-beat 16ths move late | `frame.swing: false` |
| Fog | column 8 knob 1 | the sound's `tone` factor lowers its low-pass | `frame.fog: false` |
| Thin | column 8 knob 2 | the sound's high-pass rises | `frame.thin: false` |
| Tension | column 8 knob 3 | more echo and room on the stem, filters open | `frame.tension: false` |
| Master | column 8 fader | multiplies the stem's level | no |
| Chapter | column 8 button 1 | reaches the stem only through the harmony | no |
| Break | column 8 button 2 | `frame.break: "out"` silences the stem in the Break (low end); default `"stay"` | `"stay"` |

And:
- Level: the fader is the level, applied from the next note; `gain` trims the stem to the common target level (the
  target is measured in the pilot, task 003).
- All knobs at 0 must already sound good (knob 0 = `range[0]`).
- Knobs move the sound smoothly, without jumps.
- The stem is column-agnostic: mode and column are the track's choice.

## Metadata
`meta` in the stem file:

| Field | What it is |
|---|---|
| `role` | required, one of: kick, perc, hats, clap, sub, bass, keys, chords, pad, lead, texture, fx. Decides which slots it fits and what the swap list shows |
| `genres` | at least one of the genres in [genres.md](../reference/genres.md): ambient, ambient-house, house, techno, groove-techno, edm, classical, rock |
| `energy` | 1 (calm) to 5 (peak), for sorting candidates for build-ups and sets |
| `tags` | free lowercase kebab-case words; moods go here (airy, warm, 909, acid …) |
| `harmony` | what harmony it fits: `static` (only a static chord), `chords` (follows any chords), `scale` (follows the scale), `none` (no pitch) |

Decided: no tree of categories (role + tags filter enough for 40-60 stems); moods are tags, not a field; "used by" is
computed from the track files, never stored.

## Stem track (format 1)
A stem track is `sc/tracks/<id>/<id>.track`, JSON, schema `sc/stems/track.schema.json`:

```json
{
  "format": 1,
  "name": "009-house",
  "about": "Happy, jazzy, dry house in A minor.",
  "tempo": 124,
  "swing": 0.1,
  "genre": "house",
  "frame": "009-house-frame.scd",
  "chapters": ["Vamp", "Progression"],
  "slots": {
    "1:1": "kick909/kick909-brightness-space-punch-pattern-drop-out.stem",
    "1:4": "bassWarm/bass-warm-brightness-space-length-pattern-octave.stem"
  }
}
```

- `slots`: `1:1`-`1:7` are Mode 1 (foundation), `2:1`-`2:7` Mode 2 (colour). Each names an exact stem version under
  `sc/stems/`. An empty slot is a silent column.
- `frame`: the SC file next to the track with everything that is not a stem: chords, progressions and chapters, the
  global column 8 (Fog, Thin, Tension, Master, Chapter, Break) and the Launchkey. `chapters` repeats the chapter names
  for the tools.
- A stem track is never overwritten by a swap or the designers: they write a new track file ("Save as").

This definition is preliminary: the 009 pilot (task 003) may change the frame part.

## Set (definition only)
A **set** is a unique, ordered list of stem tracks played as one performance: track 1 runs, then the next takes over,
column by column, with tempo and harmony moving between them, the global column 8 keeping its meaning. A set file
would name the tracks in order and the length of each change. There is no set file format or tooling yet; set 011
(`tracks/sets/011-combining-all/`) is the Strudel forerunner ([sets](sets.md)).

## Good to know
- `check-stems` checks every `.stem` under `sc/stems/` and every `.track` under `sc/tracks/`: schema, the file name
  from sample + labels, the sample, preset keys, parameters, code files, add-on, parent and the stems a track names
  exist, label rules, mini-notation brackets, at most 3 patterns on a Mode 1 slot.
- The schemas' genre list must match the `##` headings of [genres.md](../reference/genres.md); `npm test` checks it.
- Feature tests: `tools/stems/check-stems.test.mjs` (a broken copy of an example per rule).
- Not built yet: the SC loader and add-on library (task 002), `npm run stems` (task 004), Sample Designer, Stem
  Designer and the stem swap (`.claude/epics/sound-lab/epic.md`).

## Related
- [Samples and sounds](samples-and-sounds.md)
- [Controllers](controllers.md)
- [Lab boards](lab-boards.md)
- [Sets](sets.md)
- [Checks](checks.md)
