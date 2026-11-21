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
   `sc/stems/<sample>/`, the folder named exactly like the sound, for example `sc/stems/kick909/`. An instrument that
   plays on a generic voice (`sdSample`, `sdSynth`) gets a small named wrapper sound first (see Wrapper sounds), so
   flutes and claps do not share one `sdSample` folder.
2. Write the stem as JSON (format below). Start from an example:
   `sc/stems/kick909/kick909-brightness-space-punch-pattern-drop-out.stem` (drum, format 1),
   `sc/stems/bassWarm/bass-warm-brightness-space-length-pattern-octave.stem` (melodic, format 1), or a format 2 stem
   of the 009 pilot: `clap909/…` (kit, Complexity layers), `hats909/…` (cross-fade), `subSine/…` (length knob),
   `bassFM/…` (three sounds, register), `sdSupersaw/…` (held chords, own echo).
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
Schema: `sc/stems/stem.schema.json` (formats 1 and 2; format 2 adds fields, see Format 2). All fields:

| Field | Required | What it is |
|---|---|---|
| `format` | yes | `1` or `2` |
| `name` | yes | the file name without `.stem` |
| `parent` | yes | path of the parent version under `sc/stems/`, or `null` |
| `about` | yes | one line (at most 60 characters): what the stem is |
| `meta` | yes | `role`, `genres`, `energy`, `tags`, `harmony` (see Metadata) |
| `sample` | yes | `name` of the sound in `sc/sounds/`, optional `preset` (parameter → number, only the sound's parameters), optional `extra` (further sounds a code stem plays, e.g. `["bassM1", "bassWarm"]`) |
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

Button 1 steps to the next pattern at the next bar and cycles through any number of patterns, on Mode 1 and Mode 2.

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

## Format 2
Format 2 (`"format": 2`) says in JSON what the 009 pilot first needed code for: several files of a sample (kits),
several sounds per hit (layers), lengths relative to the note, envelopes per pattern, Complexity steps that switch
layers on, cross-fades, chances and slow waves, held chords that follow the harmony. A format 1 file stays valid; a
file that uses a format 2 field must say `"format": 2` (`check-stems` refuses it otherwise).

### New stem fields
| Field | What it is |
|---|---|
| `sample.kit` | key → file of the sample (`"cp": "tr909/cp-00.wav"`). With a kit, `pitch` is `none` and a hit's note names the key (`"notes": "cp"`, `"4 ~ 2"`); a kit hit plays its file to the end |
| `register` | the lowest note: `root` and `scale` fold the chord's bass / root into the octave from here (bass: 41 = F2), `chord` counts chord tones upwards from here (52 = E3: note 0 is the lowest chord tone from E3) |
| `push` | `true`: the chord changes two 16ths early (the frame's look-ahead) |
| `orbit` | the frame's orbit (room) the stem plays on; default 1 for kick, perc, hats, clap, sub, bass, else 2 |
| `echo` | its own echo: `{ "beats": 0.5, "feedback": 0.15 }`; knobs and the add-on move it with `echoTime` / `echoFeedback` |
| `layers` | the sounds of every hit (below); without it the patterns are the one layer |
| `frame.tensionFilter` | `false`: Tension does not open its filter (Fog still does; room and echo still follow Tension) |

### Pattern fields (also in a layer and a layer's patterns)
| Field | What it is |
|---|---|
| `velocity` | as format 1, or a wave: `{ "wave": "perlin", "range": [0.85, 1] }` |
| `length` | mini-notation: a factor on each hit's length (`"0.79 ~ 0.95"`) |
| `params` | parameter → number, mini-notation (one value per hit) or wave (`{ "wave": "sine", "range": [0.35, 0.65], "bars": 4 }`; `"at": "bar"` reads it at the bar's start); stem parameters too (`transpose` in semitones, e.g. an approach note `-1`) |
| `env` | `a`, `d`, `s`, `r` (seconds, sustain 0..1), resolved as Strudel does; without it a sound with an envelope plays its defaults |
| `voices` | note offsets every hit plays (`[0, 1, 2, 3]`: a four-note chord in `pitch: chord`) |
| `strike` | `{ "bars": 4 }` instead of a rhythm: a held chord, struck where the chord changes and again every 4 bars, held until the next change. A stem with held chords is asked at fader 0 too (its look-ahead moves on, as in the 009 `.scd`) |

A wave is `sine`, `perlin` (Strudel's smooth noise) or `rand`, from `range[0]` to `range[1]`, over `bars` (default 1).

### Layers
A layer is one sound on every hit of its own rhythm; button 1 picks the pattern of every layer at once.

| Field | What it is |
|---|---|
| `name` | required, at most 20 characters (the designers show it) |
| `sound` | the sample (default) or one of `sample.extra` |
| `rhythm`, `notes`, `velocity`, `length`, `params`, `env`, `voices` | the same for every pattern; what it leaves out comes from the stem's pattern |
| `patterns` | per-pattern fields (in the stem's pattern order): these win over the layer's own |
| `transpose` | semitones on every note (also fractions: a detuned double) |
| `swing` | its own swing amount (a fraction of a 16th) instead of the track's |
| `amount` | `{ "source", "points", "curve", "param", "zero" }`: how much the layer plays, see below |
| `chance` | a number (0..1) or an amount: the share of its hits that play (Strudel's random at the hit's time) |

`amount`: `source` is `k1`, `k2`, `k3`, `b2` (the add-on mode of button 2: 1 while on) or `tension` (column 8 knob 3).
`points` (`[[x, y], …]`, x going up; default `[[0, 0], [1, 1]]`) map the source to the amount, a line between points,
the first and last y beyond them; two points at the same x make a step. `curve: "power"` makes equal-power cross-fades
(sine up, cosine down; 0 within 0.001 of a point at 0). The amount multiplies `amp` at each note's start, and at 0 the
layer plays nothing; with `param` it goes live on that input of the sound instead (a cross-fade that acts at once on
sounding notes, e.g. `level`, `mix`), and with `"zero": "play"` the layer keeps playing at 0 (held chords that a knob
fades in). Complexity steps are layers with an amount on k3 (`[[0.5, 0], [1, 1]]`: from half the knob on); a hold
add-on of their own is a layer with `"source": "b2"` and a button 2 without `addon`.

### New stem parameters (knob targets)
`length` (factor on the note's length: a length knob relative to the note), `boost` (factor on the fader, read at each
note's start), `trim` (the strip's gain, live on the server; `range` only), `room` (room send, instead of 0.9 × `space`),
`transpose`, `echoTime`, `echoFeedback`. A knob target may give `points` instead of `range` (a curve like the labs'
room from 0.35 of Space). A knob without a mapping is allowed when a layer's amount or chance reads it. The add-on
`echoThrow` takes `echo`, `room`, `echoTime`, `echoFeedback` as `args`.

Example (the 009 clap, shortened):

```json
"sample": { "name": "clap909", "preset": { "amp": 0.8, "lpOn": 1, "lo": 3500, "hi": 14000 },
  "kit": { "cp": "tr909/cp-00.wav", "rim": "tr909/rim-00.wav", "sd": "tr909/sd-00.wav" } },
"patterns": [{ "label": "2 + 4", "rhythm": "~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~", "notes": "cp", "velocity": "0.8" }],
"layers": [
  { "name": "Clap" },
  { "name": "Rim", "rhythm": "~ ~ ~ ~ ~ ~ ~ ~ x ~ ~ ~ ~ ~ ~ ~", "notes": "rim", "velocity": "1",
    "amount": { "source": "k3", "points": [[0, 0], [0.5, 0.25]] } },
  { "name": "Roll", "rhythm": "x!16", "notes": "sd", "velocity": "0.1 0.125 … 0.475", "amount": { "source": "b2" } }
]
```

### What the Stem Designer and Track Designer can edit
Everything in a JSON stem is data: patterns, layers (sound, rhythm, notes, velocities, lengths, parameters,
envelopes), amounts and their points, chances, waves, knob targets and curves, register, push, orbit, own echo, the
kit, add-on args and the metadata. Only column code (`code` files) needs SC.

### Escape hatch
What JSON cannot say (in 009: the noise pump's knob-deep waves and its riser lane, the keys' riffs and sound mode, the
colour columns' random phrase engines and lifts) lives in an SC
file next to the stem: the stem's `code` (makes the events), or `code` on `k1`-`k3`, `b1`, `b2`. The JSON still
carries every label, `about` and the metadata. Prefer JSON; with a stem `code`, a pattern needs only its `label`.
Each file returns a Function (b2: an Event):

| File | Returns | Used |
|---|---|---|
| stem `code` | `{ \|col, k\| hits }`: Events `(at, dur, note, vel)` of 16th `k` | instead of the patterns |
| knob `code` | `{ \|v, col\| (param: value, …) }` (`v` = the knob, 0..1) | merged into every note from the next note on |
| `b1` `code` | `{ \|col\| … }` | called on each press instead of "next pattern at the next bar" |
| `b2` `code` | an add-on Event, the shape of `sc/lib/addons.scd` | as a library add-on |

`at` and `dur` are in 16ths, `note` is read through `pitch`; button 1 still steps `col[\patLatch]` for a stem `code`.

**Column code.** A stem `code` file may return an Event instead of a Function: a column JSON cannot describe at all
(the 009 pilot: 13 of 14 columns). It plays finished notes and owns its controls; the JSON keeps labels, patterns
(labels only, button 1 steps them), metadata and `gain`. With column code a knob may name no mapping and button 2 no
add-on: the code reads them (`col.knob(\k3)`, `col.held(\b2)`).

| Key | What it is |
|---|---|
| `notes` | `{ \|col, k\| notes }` (required): the notes of 16th `k` (`~ce.note` Events of the stem's sounds, `\lane`, `\hold` in 16ths, `\at`) and control messages (`(msg: …, at: …)`) |
| `start` | `{ \|col, ce\| }` after the server set-up: latches, own CC hooks; `col[\st]` holds the column's state |
| `update` | `{ \|col, send\| }` on every move of a knob, the fader or button 2: set the column's state buses |
| `b1` | `{ \|col\| }` button 1 instead of "next pattern at the next bar" |
| `gate` | `false`: asked at fader 0 too, for state that moves every 16th (lifts, the harmony's look-ahead) |
| `states` | `(name: start value)`: the column's state buses (`col.setState(\name, v, send)`, `col.stateMapOf(\name)`) |
| `maps` | `(name: (ccs: [\k1 …], fn: { \|v\| ugen }))`: values the server derives from its controls (`col.mapBusOf`); a map named `trim` is the strip trim, × `gain` |
| `strip` | `orbit`, `ownDelay` ([time in beats, feedback]), `level`, `roomR`, `echoSend`, `space`, `echo`, `trim`, `lanes`; a Symbol names one of its states, maps or controls (`\k2` = its knob 2) |

Helpers for code files: `col.chordAt(bar)`, `col.chordAtK(k, push)` (the chord at a 16th, `push` = the next bar's chord
two 16ths early; its `scale` is the scale of `k`'s bar), `col.tensionEcho`, `col.delayNode` (its own echo), and
`sc/lib/stemkit.scd` (`~ce.swingAt`, `~ce.labRoom`, `~ce.labEcho`, `~ce.miniTable`, `~ce.chordBelow`, `~ce.chordNear`,
`~ce.scaleSteps`, `~ce.closestKey`, `~ce.liftStep`). Examples: every `sc/stems/*/*.scd` of the 009 pilot.

### Wrapper sounds
A named instrument on a generic voice is a sound file that loads the voice and adds its name and files:
`sc/sounds/flute.scd` returns `~ce.loadSound(\sdSample).copy.putAll((name: \flute, role: …, about: …, files: […]))`.
`files` are loaded with the sound (the notes pick them by name), extra keys carry its sample maps (`maps`, `keys`,
`notes`). The SynthDef stays the voice's, so a note is the same note. `check-stems` reads the wrapped voice's
parameters. The pilot made `clap909`, `hats909`, `congas727`, `subSine`, `houseKeys`, `vibraphone`, `flute`,
`brassSection`, `stringSection` and `strat`; synth voices that are one instrument already (`sdNoise`, `sdSupersaw`,
`bassFM`, `kick909`) stay as they are.

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
| Drop out | the stem pauses while held (009-house.scd calls it "Drop") | 007, 008, 009, 010, 016 | `dropOut` |
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

Two labels have two meanings across tracks (not renamed): **Open** = open hats (009, 010) and the breath opens fully
(008); **Lift** = the section grows (009 brass, strings) and phaser + brighter (009 guitar). In 009 **Sound** names
two jobs: row 3 of the bass (FM → M1 → analog) and button 2 of the keys (knobs become the sound mix).

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
| Tension | column 8 knob 3 | more room, filters open; more echo on a stem with an echo send (a knob or add-on that sends to echo, or column code) | `frame.tension: false` |
| Master | column 8 fader | multiplies the stem's level | no |
| Chapter | column 8 button 1 | reaches the stem only through the harmony | no |
| Chords | button 1 of a chords stem labelled Chords | steps the frame's progressions (`nextChords`) when the frame has them, else its patterns | no |
| Break | column 8 button 2 | `frame.break: "out"` silences the stem in the Break (low end); default `"stay"` | `"stay"` |

And:
- Level: the fader is the level, applied from the next note; `gain` trims the stem to the common target level
  (Loudness, below).
- All knobs at 0 must already sound good (knob 0 = `range[0]`).
- Knobs move the sound smoothly, without jumps.
- The stem is column-agnostic: mode and column are the track's choice.

## Loudness
Stems from different tracks meet in a swap or a comparison, so each `gain` brings its stem to a common target, measured
by `cd tools && node stems/stem-loudness.mjs <file.track>`: every stem alone in SuperCollider, its fader and the
master at 1, every knob at 0, its first pattern, Vamp, 8 bars; the level is LUFS-M (the loudest 400 ms).

Target LUFS-M at fader 1 = **−13.7** (the 009 kick, gain 1) + the offset of the role (the strudel-mix targets):

| Role | Offset (dB) | Target LUFS-M |
|---|---|---|
| kick | 0 | −13.7 |
| sub, bass | −4 | −17.7 |
| clap | −5.5 | −19.2 |
| keys, chords, pad, lead | −5 | −18.7 |
| hats, perc, fx, texture | −10 | −23.7 |

New gain = old gain × 10^((target − LUFS-M) / 20). LUFS underestimates bright, short sounds (hats, claps): the final
balance is by ear.

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
  global column 8 texts and the Launchkey. `chapters` names the chapters Chapter (column 8 button 1) steps through.
  The file returns an Event: `chordAt: { |frame, track, bar| chord }` (required; `track.chapterAt(bar)` is the
  chapter, a chord is made with `~ce.chordOf("Am9", "a1", "c4 e4 g4 b4", "a b c d e f# g")`), optional
  `chapterBars` (Chapter switches at the next phrase of that many bars, default 4), `orbits`, `states`, `samples`,
  `maps`, `stems` (e.g. the Launchkey's own stem), `lkNote`, `lkCtl`, `lkPadNames`, `build: { |frame, track, ce| }`,
  `chordAtK: { |frame, track, k, push| chord }` (the chord at a 16th: chords that change inside a bar, `push` = the next
  bar's chord two 16ths early) and `nextChords: { |frame, track| }` (what Chords on a chords stem does).
  Its `// @` comment lines (`@ctl g.…`, `@col 16:8`, `@lk …`) join the `@ctl` lines made from the stems.
  Example: `sc/tracks/009-house/009-house-frame.scd` (progressions, the scale of each bar on its chords, a stem's own
  chords through `col.riffAt`).
- Fog, Thin, Tension, Master and Break are the same in every stem track (CC 20, 28, 36, 12, 52; Mode 2 + 48).
  `swing` is how far the off 16ths come late, as a fraction of a 16th.
- A stem track is never overwritten by a swap or the designers: they write a new track file ("Save as").

The 009 pilot added `chordAtK` and `nextChords` to the frame.

## The 009 pilot
`sc/tracks/009-house/009-house.track` (catalogue `009-house-stems`, beside `009-house.scd`) is 009 rebuilt from 14
stems. Proof, event by event against the `.scd` (every note with all its parameters):
`cd tools && node sc-port/stem-compare.mjs <script.json> <workdir> --cc '<start values>'` over
`trajectory/perform/009-house/dance-floor.json` (192 bars), `every-button.json` and `sc-port/scenarios/009-stem-check.json`
(every row-3 sweep, every button 2 held, riffs, Sound mode, Break, Launchkey). `--audio` renders both for a null test.
The start values `--cc '{"61":0.6,…,"67":0.6,"77":0.3,"79":0.3,…,"83":0.3}'` give both sides the knob positions the
`.scd`'s colour columns assume until a knob moves.

With format 1, 13 of 14 columns needed column code. With format 2 (task 013) 7 of 14 are JSON: kick, clap, hats,
congas, sub, bass (all seven lines) and harmony. 7 keep column code:
- noise pump: Motion moves low-pass and pan by slow sines read at the bar start, scaled by the knob; button 2 is its
  own riser on a second lane with a fixed room that plays through the Break;
- keys: riffs that bring their own chords to the whole track, the Sound mode (button 2 turns the knobs into the
  sound mix), four sounds with their own key maps;
- vibraphone, flute, brass, strings, guitar: phrase engines with Strudel's random and hash choices per note (doubles,
  neighbour notes, trills, rests per repetition), sample maps per note (closest recorded pitch), lifts that grow over
  bars while button 2 is held.

Differences of the format 2 stems to the `.scd` (comparison over the three scripts): only the bass under the keys'
Atmosphere riff (Em/G: its 3rd, 5th and 7th count from the bass G, the `.scd` counts them from E) and on approach
notes before a riff's chord change inside the bar (format 2 takes the chord of the approach note's 16th, the `.scd`
the chord of the next note). Both happen only while the keys play a riff; see task 013.

## Set (definition only)
A **set** is a unique, ordered list of stem tracks played as one performance: track 1 runs, then the next takes over,
column by column, with tempo and harmony moving between them, the global column 8 keeping its meaning. A set file
would name the tracks in order and the length of each change. There is no set file format or tooling yet; set 011
(`tracks/sets/011-combining-all/`) is the Strudel forerunner ([sets](sets.md)).

## Good to know
- `check-stems` checks every `.stem` under `sc/stems/` and every `.track` under `sc/tracks/`: schema, the file name
  from sample + labels, the sample, preset keys, parameters, code files, add-on, parent and the stems a track names
  exist, label rules, mini-notation brackets; format 2: format 2 fields only with `"format": 2`, layer sounds in the
  sample or `extra`, parameters of each layer's sound, kit files of the sample and kit keys in the notes, points going
  up, a knob or button 2 without mapping only when a layer reads it.
- The schemas' genre list must match the `##` headings of [genres.md](../reference/genres.md); `npm test` checks it.
- Feature tests: `tools/stems/check-stems.test.mjs` (a broken copy of an example per rule),
  `tools/stems/stem-tags.test.mjs` (the `@ctl` lines of a stem track), and in `tools/sc-test/run.scd`: a stem loads,
  Pattern cycles, a knob reaches its bus, every add-on fires, silent columns are gated, Break, the code hatch, the
  swap, SC makes the same `@ctl` lines as `tools/stems/stem-tags.mjs`, and the format 2 features of the 009 stems
  (kit files, Complexity layers, cross-fade, length knob, held chords on a live mix, chance layers).
- `tools/sc-port/stem-compare.mjs` compares every input a note's SynthDef reads (`<prefix>.controls.json` from
  `sc/tools/render.scd`); log labels such as `tag` and `g` are left out.
- Not built yet: `npm run stems` (task 004), Sample Designer, Stem Designer and the stem swap in the player
  (`.claude/epics/sound-lab/epic.md`).

## In SuperCollider
- `sc/lib/stems.scd` makes a column of a `.stem`, `sc/lib/addons.scd` holds the add-ons, `sc/lib/stemtrack.scd`
  loads a `.track`. `~ce.loadTrack(path)` takes a `.scd` or a `.track` (the player's engine, `sc/live.scd` and
  `sc/tools/render.scd` use it); a stem track becomes the same track Event as a hand-written one.
- The example stem tracks are `sc/tracks/090-stem-demo/` (the two example stems) and the 009 pilot; the player lists stem tracks with
  `engine: 'sc'` and `stems: true` (`<id>-stems` when an `.scd` of the same name exists).
- A column's knobs write state buses (`s<mode>_<col>_<param>`, room and echo send included), so they act at once,
  also on sounding notes; `hold` (seconds) and `amp` are read at each note's start. A column whose fader or the master
  is at 0, or that sits out the Break, makes no hits at all (gated).
- The `@ctl` lines of a stem track are made from its stems and frame (`~ce.stemTrackTags`, and the same in
  `tools/stems/stem-tags.mjs` for `check-perform`), so the MIDI panel and the auto-perform scripts work unchanged.
- Swap hook: `~ce.swapSlot(slot, ref, load)` puts the stem `ref` (path under `sc/stems/`) on `slot` (`'2:4'`) at the
  next bar line; the other columns play on. `load.(msgs, done)` sends the new sounds, samples and state buses
  (default: live, with `s.sync`) and then calls `done`. The slot must hold a stem already (an empty slot has no
  strip: load the changed track instead). The swap changes only the running track, never the file.

## Related
- [Samples and sounds](samples-and-sounds.md)
- [Controllers](controllers.md)
- [Lab boards](lab-boards.md)
- [Sets](sets.md)
- [Checks](checks.md)
