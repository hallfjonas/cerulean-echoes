// Launch Control XL 3 layout for tracks/006.strudel
// Compile: typst compile 006-layout.typ

#set page(paper: "a4", flipped: true, margin: 12mm)
#set text(font: "Helvetica", size: 7.5pt, lang: "en")

#let c-knob   = rgb("#dbe7f5")
#let c-fader  = rgb("#e3f1df")
#let c-button = rgb("#f6ead6")
#let c-global = rgb("#f3dfe8")
#let c-unused = luma(240)

// One control: CC number, name, short description
#let ctl(cc, name, desc, fill: c-knob) = block(
  width: 100%, height: 100%, inset: 4pt, radius: 3pt, fill: fill,
  stroke: 0.4pt + luma(170),
)[
  #text(size: 6pt, fill: luma(90))[CC #cc] \
  #text(weight: "bold")[#name] \
  #text(size: 6.5pt)[#desc]
]
#let off(cc) = ctl(cc, text(fill: luma(150))[—], [], fill: c-unused)

// Board: row labels left, 8 columns
#let board(heads, rows) = grid(
  columns: (18mm,) + (1fr,) * 8,
  rows: (auto, 27mm, 27mm, 27mm, 30mm, 11mm, 11mm),
  gutter: 3pt,
  [], ..heads.map(h => align(center, text(weight: "bold", size: 8pt, h))),
  ..rows.flatten(),
)
#let lbl(t) = align(horizon, text(weight: "bold", size: 7pt, t))

// Global column, the same in both modes (cc = Mode 16 CC; Mode 2 sends CC + 48)
#let g(cc, name, desc, fill: c-global) = ctl([#cc / #(cc + 48)], name, desc, fill: fill)
#let global = (
  g(20, "Global HPF", [0–1000 Hz (quadratic), added to kick, sub, bass, bongos, space. Not to hats, clap, melodies.]),
  g(28, "Global LPF", [100–12800 Hz (exp.), melodies only (not baselines).]),
  g(36, "Swing", [Offbeat 8ths later: 0 straight … 1 heavy shuffle.]),
  g(12, "Master Level", [Volume of everything.]),
)

= Launch Control XL 3 — Track 006

Two custom modes: *Mode 16* (channel 16) plays the stems, *Mode 2* the melodies (all CCs + 48).
Column 8 is global in both modes and controls the same thing: the fader takes the last moved value, the knobs are coupled (every turn shifts the shared value relatively).
Filter knobs are exponential, so the whole travel is audible.

*Density* (knob row 3) is a crossfade: 0 = main layer only, 0.5 = both, 1 = extra layer only.

#v(4pt)
#text(size: 6.5pt)[
  #box(fill: c-knob, inset: 2pt)[Knob]
  #box(fill: c-fader, inset: 2pt)[Fader]
  #box(fill: c-button, inset: 2pt)[Button]
  #box(fill: c-global, inset: 2pt)[global (both modes)]
  #box(fill: c-unused, inset: 2pt)[unused]
]

== Mode 16 — Stems

#board(
  ("1 Kick", "2 Sub", "3 Bass", "4 Hats", "5 Clap", "6 Bongos", "7 Space", "8 Global"),
  (
    (lbl[Row 1 \ HPF],
      ctl(13, "HPF", [20–2000 Hz. Fully open: only the click is left.]),
      ctl(14, "HPF", [20–300 Hz]),
      ctl(15, "HPF", [20–600 Hz]),
      ctl(16, "HPF", [300–8000 Hz]),
      ctl(17, "HPF", [150–3000 Hz]),
      ctl(18, "HPF", [60–600 Hz]),
      ctl(19, "HPF", [80–1200 Hz]),
      global.at(0)),
    (lbl[Row 2 \ LPF],
      ctl(21, "LPF", [100–12800 Hz (+1.5 kHz with softness)]),
      ctl(22, "LPF", [80–2000 Hz]),
      ctl(23, "LPF / Cutoff", [150–4000 Hz. Together with acid the 303 cutoff.]),
      ctl(24, "LPF", [2–16 kHz]),
      ctl(25, "LPF", [1.5–15 kHz]),
      ctl(26, "LPF", [1–10 kHz]),
      ctl(27, "LPF sweep", [Upper limit of the slow filter sweep, 0.8–12 kHz]),
      global.at(1)),
    (lbl[Row 3 \ Character],
      ctl(29, "Softness", [0 = 909. 1 = soft sine kick + 808, slightly driven.]),
      ctl(30, "Density", [Quarter-note saw + sine sub → pulsing 8ths]),
      ctl(31, "Acid", [0 = warm saw. 1 = 303: resonance, filter envelope, accents, drive.]),
      ctl(32, "Density", [Open hats → 16th hats]),
      ctl(33, "Density", [Backbeat → ghosts + double taps]),
      ctl(34, "Density", [Low/high taps → ghosts, rolls, fingers]),
      ctl(35, "Feedback", [Delay feedback 0.23–1.14. Above ~0.9 it builds up!]),
      global.at(2)),
    (lbl[Fader \ Level],
      ctl(5,  "Level", [0–1], fill: c-fader),
      ctl(6,  "Level", [0–2], fill: c-fader),
      ctl(7,  "Level", [0–2, drops slightly with acid], fill: c-fader),
      ctl(8,  "Level", [0–1], fill: c-fader),
      ctl(9,  "Level", [0–2.5], fill: c-fader),
      ctl(10, "Level", [0–0.8], fill: c-fader),
      ctl(11, "Level", [0–0.7], fill: c-fader),
      global.at(3)),
    (lbl[Buttons 1],
      off(37), off(38), off(39), off(40),
      ctl(41, "Clap Room", [off / 0.5], fill: c-button),
      off(42), off(43), off(44)),
    (lbl[Buttons 2],
      ..range(45, 53).map(off)),
  ),
)

#pagebreak()

== Mode 2 — Melodies (CC + 48)

Column _N_ = melody _N_ with its baseline. The character knob (row 1) affects melody *and* baseline.

#board(
  ("Melody 1", "Melody 2", "Melody 3", "Melody 4", "Melody 5", "Melody 6", "Melody 7", "8 Global"),
  (
    (lbl[Row 1 \ Character],
      ..range(1, 8).map(i => ctl(60 + i, "Wobble",
        if i == 1 [0 = dry. 0.5 = organic: drift + vibrato. 1 = acid: 303 envelope, accents, drive.]
        else [as Melody 1])),
      global.at(0)),
    (lbl[Row 2 \ Baseline],
      ..range(1, 8).map(i => ctl(68 + i, "Baseline LPF",
        if i == 1 [0–800 Hz. At 0 the baseline is silent; turning up fades it in.]
        else [as Melody 1])),
      global.at(1)),
    (lbl[Row 3 \ Density],
      ..range(1, 8).map(i => ctl(76 + i, "Overtones",
        if i == 1 [Fades voices in, in 3 stages (0–0.3, 0.3–0.6, 0.6–0.9). Which ones is set by the button below.]
        else [as Melody 1])),
      global.at(2)),
    (lbl[Fader \ Level],
      ..(
        [E F G A in octaves],
        [D E C F B G A],
        [16 notes, half tempo],
        [C♯ F♯ A G / E],
        [D♭ F B E],
        [C♯ F A/G E],
        [D♭ E♭ B F],
      ).enumerate().map(((i, d)) => ctl(53 + i, "Level", [Melody + overtones (not baseline). #d], fill: c-fader)),
      global.at(3)),
    (lbl[Buttons 1],
      ..range(1, 8).map(i => ctl(84 + i, "Minor",
        if i == 1 [major / minor third]
        else [as Melody 1], fill: c-button)),
      off(92)),
    (lbl[Buttons 2], ..range(93, 101).map(off)),
  ),
)
