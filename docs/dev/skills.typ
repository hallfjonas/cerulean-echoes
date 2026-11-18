// Documentation of the Claude Code setup of this project: CLAUDE.md, skills, tools
// Compile: typst compile skills.typ

#set page(paper: "a4", margin: (x: 20mm, y: 18mm), numbering: "1")
#set text(font: "Helvetica", size: 9.5pt, lang: "en")
#set par(justify: false, leading: 0.6em)
#set heading(numbering: "1.")
#show heading.where(level: 1): set text(size: 13pt)
#show raw.where(block: true): block.with(fill: luma(245), inset: 6pt, radius: 3pt, width: 100%)
#show table: set text(size: 8.5pt)

#let box-note(body) = block(fill: rgb("#eef4fb"), inset: 7pt, radius: 3pt, width: 100%, body)

#align(center)[
  #text(size: 18pt, weight: "bold")[cerulean-echoes — Claude setup]
  #v(-4pt)
  #text(fill: luma(100))[What Claude always knows in this project, and which workflows it runs on request]
]

= Structure: global and skills

#table(
  columns: (28mm, 1fr, 1fr),
  stroke: 0.4pt + luma(180),
  inset: 5pt,
  table.header([], [*`CLAUDE.md`*], [*Skills* (`.claude/skills/…`)]),
  [When loaded], [automatically in every session], [only when the task fits, or via `/name`],
  [Content], [short fixed rules: folders, controller mapping, "new file instead of overwriting", efficiency rules],
    [detailed workflows with steps, commands, target values and scripts],
  [Length], [keep short (takes space in every session)], [may be long],
)

The skills' scripts live in `tools/` (once: `cd tools && npm install`). A hook in `.claude/settings.json`
regenerates the layout sheets after every change to a track.

#box-note[
  *Calling:* just describe the task in chat ("make track 007 more efficient", "level the stems") or type
  `/strudel-optimize`, `/strudel-mix`, `/lcxl-layout` directly.
]

= `/strudel-optimize` — less CPU, same sound

*Problem:* Strudel computes every event of every layer, even when it is silent (fader at 0, density below,
wrong overtone mode). In track 006 that was 746 events per cycle; compute time was about 0.7 s per cycle
(a cycle lasts 1.7 s) — hence the dropouts.

*Fix:* silent parts are not queried at all ("gating"):

```js
const gate = (cond, pat) => cond.fmap(on => on ? pat : silence).innerJoin()
```

- *Stems:* `strip()` applies hpf, lpf and level and switches the stem off while fader or master is at 0.
- *Layers:* main/extra layer only while its crossfade share is above 0; overtones only in the matching mode and
  above their density step.
- *Buttons and linked knobs* keep their state. They are created once and queried via `stateTaps` on
  every tick, so no button press is lost while a stem is switched off.
- *Safety net* at the end: everything with gain 0 is dropped.

*Proof:* `compare.mjs` plays the old and new version with the same control positions (fixed positions,
random positions, all controls moving, button presses) and compares every audible event.

#table(
  columns: (1fr, auto, auto, auto),
  stroke: 0.4pt + luma(180), inset: 5pt,
  table.header([*Track 006 → 006-lean*], [*Events/cycle*], [*Compute time/cycle*], [*identical*]),
  [all faders 0], [746 → 0], [≈ 700 → 65 ms], [yes],
  [typical (drums + 2 melodies)], [746 → 120], [≈ 780 → 170 ms], [yes],
  [everything at 1], [746 → 442], [≈ 900 → 800 ms], [yes],
)

= `/strudel-mix` — automatic pre-mixing

Each stem is rendered on its own offline with superdough (Strudel's audio engine) and its loudness measured
(LUFS: loudness roughly as the ear perceives it; plus the peak level). New fader maxima follow from that.

```sh
node strudel-sim/measure.mjs ../tracks/historic/006/006-lean-mix.strudel stem1_kick=5,29 stem4_hats=8,32
```

*Target values* (techno rule of thumb, relative to the kick at fader 1):

#table(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  stroke: 0.4pt + luma(180), inset: 5pt,
  [Kick], [Sub, bass], [Clap], [Melodies], [Hats], [Percussion, FX],
  [0 dB], [−3 … −5], [−5 … −6], [−4 … −6], [−9 … −11], [−8 … −12],
)

Conversion: new maximum = old × 10#super[dB/20] (−3 dB ≈ × 0.71; −6 dB ≈ × 0.5).

*Example track 006:* hats (−13 LUFS) and clap (−15 LUFS) were almost at kick level (−11 LUFS).
In `006-lean-mix` their fader maxima are lowered: hats 1 → 0.4, clap 2.5 → 1.4. Also reported: the sub
clips at density 0.5 (peak level 3.3).

#box-note[
  *Limits:* LUFS underrates bright, short sounds (hats, claps), and small speakers lose the bass.
  The measurement gives the rough setting — the ear does the final polish.
]

= `/lcxl-layout` — layout sheets that never go stale

The layout sheet (PDF) is built from comments right in the track, next to the code that reads the control.
The script works out the CC numbers from the position itself.

```js
// @col 16:4 4 Hats
// @ctl 16:4.k1 HPF | 300–8000 Hz
// @ctl 16:4.fader Level | 0–0.4
const hatsCol = col(4)
```

#table(
  columns: (32mm, 1fr),
  stroke: 0.4pt + luma(180), inset: 5pt,
  [`@layout`, `@note`], [title and intro text],
  [`@mode 16 …`], [one page per mode],
  [`@col`, `@row`], [column heading, row label (`\` = line break)],
  [`@ctl <pos> Name | Text`], [one control. `pos` = `16:1.k1` (mode:column.row); rows `k1 k2 k3 fader b1 b2`],
  [`2:1-7.k1`], [same control in several columns; from column 2 on it reads "as …"],
  [`g.fader`], [global column 8, on every page, CC n / n + 48],
)

*Always up to date:*
- When Claude changes a track, the hook regenerates the PDF at once; broken tags are reported.
- For changes by hand: `cd tools && npm run watch` runs in the background and regenerates on every save.
- All at once: `npm run layouts`.

= Files

#table(
  columns: (62mm, 1fr),
  stroke: 0.4pt + luma(180), inset: 5pt,
  [`CLAUDE.md`], [global project rules],
  [`.claude/skills/*/SKILL.md`], [the three skills],
  [`.claude/settings.json`], [hook for the layout sheets],
  [`tools/strudel-sim/`], [`harness` (evaluate a track in Node), `compare` (equality + CPU), `render` + `measure` (loudness)],
  [`tools/lcxl-layout/`], [`gen-layout` (tags → PDF), `lcxl3.typ` (template), `hook`, `watch`],
  [`docs/dev/skills.typ`], [this document],
)
