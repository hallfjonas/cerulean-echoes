# Sound Lab

## What it is
The sound lab is three tools in the player for making and choosing sounds on SuperCollider. They all work on files, so
every result can be saved, copied and put into a track:

- **Sample Designer**: a new sound on the whole Launch Control XL 3 (a drum machine or a synthesizer). Result: a
  library sound in `sc/sounds/`. See [Sample Designer](sample-designer.md).
- **Stem Designer**: up to 14 versions of a stem side by side on the LC, played against a running track. Result: a
  new stem version in `sc/stems/`.
- **Stem swap**: another library stem on one column of a track that plays, from the next bar.

A stem is one finished LC column as a file (sample, patterns, three knobs, fader, two buttons); see [Stems](stems.md).
The old Strudel lab boards stay as they are ([Lab boards](lab-boards.md)); new sound work goes here.

## When to use it
- A column is boring or too repetitive and you want to hear replacements (Stem Designer).
- You want to try one other stem in a track right now, without a project (stem swap).
- You need a sound the library does not have (Sample Designer, then a stem that uses it).
- Claude can set a round up for you: `/stem-designer`, `/sample-designer` (see [Claude skills](claude-skills.md)).

## How to use it

### Stem swap
1. Start the player (`cd tools && node trajectory/server.mjs`, then http://localhost:8766) and play a stem track, for
   example `009-house (stems)` under Live.
2. Click the name of a column in the MIDI panel. The stem drawer lists the library stems that fit its role; filter by
   genre, energy or tag.
3. Pick one. It takes over at the next bar. If the new stem needs another mixer strip than the old one, the track is
   loaded again with it (a short gap).
4. **Revert** puts the file's stems back. **Save as** writes the swaps as a new track (`009-house-v2`); the original
   file never changes.

### Stem Designer
1. Under **Lab** pick `Stems: flute-explore` and press **Load**. The columns of the project play on their slots; the
   backing stems of the context track (`009-house`: kick, sub, bass) play along without a controller.
2. Turn the knobs of any column. The column you moved last is the selection (the MIDI panel header names it).
3. **A/B** (LC column 8, button 1): the selected column swaps at the next bar between its candidate and the context
   track's stem of the same slot. Press again to go back. If the two need different mixer strips, the player says so
   and nothing changes.
4. **Save** (sidebar) writes the selection into the project; **Save as** copies the project (the copy's `parent` is the
   old one), the way to start the next round.
5. **Promote** (sidebar, or LC column 8, button 2) writes the draft on the selected column into the library as a new
   stem version (`parent` set, checked, never overwrites). A stem that is in the library already has nothing to
   promote.
6. To use the winner, make a new track with it: `cd tools && npm run stem-lab -- track-with 009-house 009-house-v2
   2:4=<sample>/<name>.stem`.

From the terminal (in `tools/`): `npm run stem-lab -- check`, `save-as <name> <new>`, `promote <name> <slot>`,
`track-with <track> <new-track> <slot>=<ref> …`. Library overview: `npm run stems`.

## The project file (format 1)
`sc/lab/stems/<name>.stemlab.json`, schema `sc/lab/stems/stemlab.schema.json`:

| Field | Meaning |
|---|---|
| `name`, `parent`, `about` | file name without the extension, the project it was copied from, one line |
| `context` | `track` (tempo, chords, chapters and global column come from it), `chapter` (start chapter), `backing` (slots whose stems of that track play along) |
| `columns` | slot (`1:1`-`1:7` Mode 1, `2:1`-`2:7` Mode 2) → a library stem (`flute/….stem`) or `draft:<id>` |
| `drafts` | `<id>` → a stem (the format of [Stems](stems.md)); its code files are looked up next to its `parent` |
| `select` | the column that is selected at the start |

Projects are working files; the library holds the results. A played stem version is never edited: a change is a new
version (a draft, then Promote).

## Good to know
- Claude cannot hear. It builds the project and proves that it loads; you decide by ear.
- Stems from different tracks are brought to a common level by each stem's `gain`; a new version may still need a trim.
- Fourteen columns plus backing load and play in the offline test; the live load on the laptop has not been measured
  yet. If it drops out, rest columns (fader 0) cost nothing, and fewer candidates per round help.
- Column 8 in the Stem Designer has no Chapter or Break button (their places are A/B and Promote); the project's
  `context.chapter` sets the chapter.
