// Launch Control XL 3 layout for tracks/006.strudel
// Compile: typst compile 006-layout.typ

#set page(paper: "a4", flipped: true, margin: 12mm)
#set text(font: "Helvetica", size: 7.5pt, lang: "de")

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
  g(20, "Global HPF", [0–1000 Hz (quadratisch), addiert auf Kick, Sub, Bass, Bongos, Space. Nicht auf Hats, Clap, Melodien.]),
  g(28, "Global LPF", [100–12800 Hz (exp.), nur Melodien (nicht Baselines).]),
  g(36, "Swing", [Offbeat-8tel später: 0 gerade … 1 schwerer Shuffle.]),
  g(12, "Master Level", [Lautstärke von allem.]),
)

= Launch Control XL 3 — Track 006

Zwei Custom Modes: *Mode 16* (Kanal 16) spielt die Stems, *Mode 2* die Melodien (alle CCs + 48).
Spalte 8 ist in beiden Modes global und steuert dasselbe: Der Fader nimmt den zuletzt bewegten Wert, die Knöpfe sind gekoppelt (jeder Dreh verschiebt den gemeinsamen Wert relativ).
Filter-Knöpfe laufen exponentiell, damit der ganze Weg hörbar ist.

*Density* (Knopfreihe 3) ist ein Crossfade: 0 = nur Hauptlayer, 0.5 = beide, 1 = nur Extra-Layer.

#v(4pt)
#text(size: 6.5pt)[
  #box(fill: c-knob, inset: 2pt)[Knopf]
  #box(fill: c-fader, inset: 2pt)[Fader]
  #box(fill: c-button, inset: 2pt)[Button]
  #box(fill: c-global, inset: 2pt)[global (beide Modes)]
  #box(fill: c-unused, inset: 2pt)[frei]
]

== Mode 16 — Stems

#board(
  ("1 Kick", "2 Sub", "3 Bass", "4 Hats", "5 Clap", "6 Bongos", "7 Space", "8 Global"),
  (
    (lbl[Reihe 1 \ HPF],
      ctl(13, "HPF", [20–2000 Hz. Ganz offen: nur noch der Klick.]),
      ctl(14, "HPF", [20–300 Hz]),
      ctl(15, "HPF", [20–600 Hz]),
      ctl(16, "HPF", [300–8000 Hz]),
      ctl(17, "HPF", [150–3000 Hz]),
      ctl(18, "HPF", [60–600 Hz]),
      ctl(19, "HPF", [80–1200 Hz]),
      global.at(0)),
    (lbl[Reihe 2 \ LPF],
      ctl(21, "LPF", [100–12800 Hz (+1.5 kHz mit Softness)]),
      ctl(22, "LPF", [80–2000 Hz]),
      ctl(23, "LPF / Cutoff", [150–4000 Hz. Mit Acid zusammen der 303-Cutoff.]),
      ctl(24, "LPF", [2–16 kHz]),
      ctl(25, "LPF", [1.5–15 kHz]),
      ctl(26, "LPF", [1–10 kHz]),
      ctl(27, "LPF-Sweep", [Obergrenze des langsamen Filter-Sweeps, 0.8–12 kHz]),
      global.at(1)),
    (lbl[Reihe 3 \ Charakter],
      ctl(29, "Softness", [0 = 909. 1 = weicher Sinus-Kick + 808, leicht angezerrt.]),
      ctl(30, "Density", [Viertel-Saw + Sinus-Sub → pulsierende 8tel]),
      ctl(31, "Acid", [0 = warme Saw. 1 = 303: Resonanz, Filterhüllkurve, Akzente, Drive.]),
      ctl(32, "Density", [Open Hats → 16tel Hats]),
      ctl(33, "Density", [Backbeat → Ghosts + Double Taps]),
      ctl(34, "Density", [Low/High Taps → Ghosts, Rolls, Fingers]),
      ctl(35, "Feedback", [Delay-Feedback 0.23–1.14. Über ~0.9 schaukelt es sich auf!]),
      global.at(2)),
    (lbl[Fader \ Level],
      ctl(5,  "Level", [0–1], fill: c-fader),
      ctl(6,  "Level", [0–2], fill: c-fader),
      ctl(7,  "Level", [0–2, sinkt leicht mit Acid], fill: c-fader),
      ctl(8,  "Level", [0–1], fill: c-fader),
      ctl(9,  "Level", [0–2.5], fill: c-fader),
      ctl(10, "Level", [0–0.8], fill: c-fader),
      ctl(11, "Level", [0–0.7], fill: c-fader),
      global.at(3)),
    (lbl[Buttons 1],
      off(37), off(38), off(39), off(40),
      ctl(41, "Clap Room", [aus / 0.5], fill: c-button),
      off(42), off(43), off(44)),
    (lbl[Buttons 2],
      ..range(45, 53).map(off)),
  ),
)

#pagebreak()

== Mode 2 — Melodien (CC + 48)

Spalte _N_ = Melodie _N_ mit ihrer Baseline. Der Charakter-Knopf (Reihe 1) wirkt auf Melodie *und* Baseline.

#board(
  ("Melodie 1", "Melodie 2", "Melodie 3", "Melodie 4", "Melodie 5", "Melodie 6", "Melodie 7", "8 Global"),
  (
    (lbl[Reihe 1 \ Charakter],
      ..range(1, 8).map(i => ctl(60 + i, "Wobble",
        if i == 1 [0 = trocken. 0.5 = organisch: Drift + Vibrato. 1 = Acid: 303-Hüllkurve, Akzente, Drive.]
        else [wie Melodie 1])),
      global.at(0)),
    (lbl[Reihe 2 \ Baseline],
      ..range(1, 8).map(i => ctl(68 + i, "Baseline LPF",
        if i == 1 [0–800 Hz. Bei 0 ist die Baseline stumm; aufdrehen blendet sie ein.]
        else [wie Melodie 1])),
      global.at(1)),
    (lbl[Reihe 3 \ Density],
      ..range(1, 8).map(i => ctl(76 + i, "Obertöne",
        if i == 1 [Blendet in 3 Stufen Stimmen ein (0–0.3, 0.3–0.6, 0.6–0.9). Welche, bestimmt der Button darunter.]
        else [wie Melodie 1])),
      global.at(2)),
    (lbl[Fader \ Level],
      ..(
        [E F G A in Oktaven],
        [D E C F B G A],
        [16 Töne, halbes Tempo],
        [C♯ F♯ A G / E],
        [D♭ F B E],
        [C♯ F A/G E],
        [D♭ E♭ B F],
      ).enumerate().map(((i, d)) => ctl(53 + i, "Level", [Melodie + Obertöne (nicht Baseline). #d], fill: c-fader)),
      global.at(3)),
    (lbl[Buttons 1],
      ..range(1, 8).map(i => ctl(84 + i, "Moll",
        if i == 1 [große / kleine Terz]
        else [wie Melodie 1], fill: c-button)),
      off(92)),
    (lbl[Buttons 2], ..range(93, 101).map(off)),
  ),
)
