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
The old Strudel lab boards were retired ([Lab boards](lab-boards.md)); new sound work goes here.

## When to use it
- A column is boring or too repetitive and you want to hear replacements (Stem Designer).
- You want to try one other stem in a track right now, without a project (stem swap).
- You need a sound the library does not have (Sample Designer, then a stem that uses it).
- Claude can set a round up for you: `/stem-designer`, `/sample-designer` (see [Claude skills](claude-skills.md)).

## How to use it

### Stem swap
1. Start the player (`cd tools && node trajectory/server.mjs`, then http://localhost:8766) and play a stem track, for
   example `009-house (stems)` under Live.
2. Click the name of a column on the Live page. The stem drawer lists the library stems of its role; filter by role
   (set it to any to swap in a stem of another role, e.g. a bass for a lead), genre, energy or tag. Stems that do not
   fit the track are greyed out with the reason (for example "the frame has no tonesAt": the stem needs something
   only its own track has). The check starts when the track loads and takes a few seconds the first time; until
   it is done the drawer shows "Checking which stems fit this track …".
3. Pick one. It takes over at the next bar. If the new stem needs another mixer strip than the old one, the track is
   loaded again with it (a short gap).
4. **Revert** puts the file's stems back. **Save as** writes the swaps as a new track (`009-house-v2`); the original
   file never changes.

### Stem Designer (Labs / Stems)
1. On the **Labs** page, tab **Stems**, pick `Stems: flute-explore` and press **Load**. The columns of the project play on their slots; the
   backing stems of the context track (`009-house`: kick, sub, bass) play along without a controller.
2. Turn the knobs of any column. The column you moved last is the selection (the panel header names it). The global
   fader sets a volume: button 1 of column 8 (the same in both modes) cycles it between **Stems** (the columns)
   and **Context** (the backing). Each keeps its own level.
3. Every free slot shows **+ Add** where the stem's title would be: click it, pick a stem in the drawer (the one of
   the Live page), it goes on that slot. Above a stem's title are two small symbols: **export** (see Promote) and
   **trash** (the slot is free again and shows + Add). **Replace**: a click on the stem's title opens the
   drawer for that stem. Each change writes the project file (**Save as** first keeps the old state).
   Add, trash and knob changes load the project again (a short gap); Replace plays from the next bar when the stem
   fits the column's mixer strip, else the project loads again.
   Slots are explicit: a trashed column leaves its slot free and the others stay where they are.
4. **Save** (sidebar) writes the selection into the project; **Save as** copies the project (the copy's `parent` is the
   old one), the way to start the next round.
5. **Promote** (the export symbol above a stem's title) writes the draft on the selected column into the library as a new
   stem version (`parent` set, checked, never overwrites). A stem that is in the library already has nothing to
   promote: the symbol is grayed out. A draft appears when you change a knob (next step).
6. **Knobs**: click a knob's name in the panel to open the knob editor. Pick a parameter of the stem's sound (or Space,
   Echo, Pan), the bounds the knob moves it between, the curve and the knob's default position; a preset
   (`sc/stems/knobs.json`) fills the fields. Apply writes the knob into a draft of the column (a library stem stays
   as it is). Knob 1 and 2 keep the names Brightness and Space while they drive brightness and space, else they get a name of
   their own. A stem with column code (brass, strings …) reads
   its knobs itself (knob 1 = brightness and level): the editor marks the knob `"override": true`, so the code reads
   it as its middle position and the new parameter is applied to every note the code makes (pan moves the code's own
   pan, space, echo and trim stay with the code).
7. **New from track** (sidebar, folds open): pick a stem track; every stem of it gets **Lab** (a column of the
   project), **Backing** (plays along, `context.backing`) or **Off**. **All stems in lab** (on by default) sets every
   stem to Lab, off every stem to Off. **Create** writes `sc/lab/stems/<track>-stems.stemlab.json` (`-2`, … when taken;
   the name is editable) with the track as context, and plays it.
8. **Export track** (sidebar) writes the project as a stem track `sc/tracks/<name>/` (default `<context>-2`): the
   context track's frame, tempo and chapters, its backing stems, the project's columns on their slots. A draft
   cannot go into a track: a message names the slots and offers to export those stems to the library first. The Live page lists the new track.

From the terminal (in `tools/`): `npm run stem-lab -- check`, `save-as <name> <new>`, `promote <name> <slot>`,
`track-with <track> <new-track> <slot>=<ref> …`, `from-track <track> <name> <slot>… [--backing <slot>…]`,
`export-track <name> <new-track>`. Library overview: `npm run stems`.

## The project file (format 1)
`sc/lab/stems/<name>.stemlab.json`, schema `sc/lab/stems/stemlab.schema.json`:

| Field | Meaning |
|---|---|
| `name`, `parent`, `about` | file name without the extension, the project it was copied from, one line |
| `context` | `track` (tempo, chords, chapters and global column come from it), `chapter` (start chapter), `backing` (slots whose stems of that track play along) |
| `columns` | slot (`1:1`-`1:7` Mode 1, `2:1`-`2:7` Mode 2) → a library stem (`flute/….stem`) or `draft:<id>`; a slot without a column is free |
| `drafts` | `<id>` → a stem (the format of [Stems](stems.md)); its code files are looked up next to its `parent` |
| `select` | the column that is selected at the start |

Projects are working files; the library holds the results. A played stem version is never edited: a change is a new
version (a draft, then Promote).

## Good to know
- Claude cannot hear. It builds the project and proves that it loads; you decide by ear.
- Not every stem fits every track yet: a stem's code may need something of its own track's frame. The drawer greys
  such stems out; one that gets on a slot anyway (a project file, a track file) goes quiet there, the rest plays on,
  and the player shows which slot failed and why. The known misfits are listed in
  `tools/sc-test/stem-frames-known.json` (track → stem → error), checked by `npm test`.
- Stems from different tracks are brought to a common level by each stem's `gain`; a new version may still need a trim.
- Fourteen columns plus backing load and play in the offline test; the live load on the laptop has not been measured
  yet. If it drops out, rest columns (fader 0) cost nothing, and fewer candidates per round help.
- Column 8 in the Stem Designer has no Chapter or Break button (button 1 picks the volume the fader sets); the project's
  `context.chapter` sets the chapter.

## Ideas: plugin blocks (not built)

How the free plugin packs of `sc/PLAN-SOUND-QUALITY.md` (sc3-plugins, mi-UGens, section 4 there) would appear on the
controller. Moved from that plan; nothing here is built.

### As Sample Designer blocks (`sc/lab/samples/blocks.json`)
New block kinds, same schema as now (row 1 main, row 2 shape/time, row 3 fine/mod, fader level or mix, button 1
on/off, button 2 type):

| Block | part | Row 1 | Row 2 | Row 3 | Fader | Button 2 (type) |
|---|---|---|---|---|---|---|
| Plaits | source | Timbre | Morph | Harmonics | Level | engine (16 models; cycles) |
| Rings | fx (resonator) | Brightness | Damping | Structure | Mix | Modal / String / FM bell |
| Clouds | fx | Position | Size | Density | Mix | Granular / Stretch / Loop / Spectral |
| Ladder filter (DFM1 / MiRipples) | fx | Cutoff | Resonance | Env amount | Mix | LP / BP / HP |
| Tape | fx | Drive | Wow/flutter | Tone | Mix | Tape / Tube |
| Reverb | fx | Size | Damping | Pre-delay | Mix | Room / Hall / Plate |

New setups to try, e.g. **Texture** (Plaits → Rings → Clouds → Envelope → LFO → Tape) and **Drum voice (Plaits)**
(Plaits drum models → Envelope → Ladder filter → Drive). Mode 2 is unused in the Sample Designer: it could hold the
second page of a block that needs more than three knobs (Plaits' LPG decay/colour, Clouds' feedback/texture/spread).

### In a stem (the live column)
The stem keeps the fixed row meanings, so the player never has to relearn a column:

| Control | Plaits stem | Rings stem | Clouds stem |
|---|---|---|---|
| Row 1 Brightness | Timbre (+ LPG colour) | Brightness | texture/filter |
| Row 2 Space | Space | Space | Space (+ Clouds' own reverb) |
| Row 3 (named) | Morph | Structure | Density |
| Fader Level | Level | Level | Level |
| Button 1 Pattern | Pattern | Pattern | Pattern / Freeze |
| Button 2 (named) | Engine (next model, at the next bar) | Model | Freeze |

All knobs at 0 must already sound good (track rule): set every mapping's bounds so the 0 end is a usable sound,
not silence or a raw extreme.

### Randomizing (Würfel mode)
Plaits and Rings are well suited: their parameters are 0..1, and the musical range is wide. Still store a tested
range per parameter in the block definition (as planned for the Würfel mode), plus a list of allowed engines per role
(e.g. a bass stem: VA, waveshaping, FM, bass drum model only).
