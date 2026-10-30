// Launch Control XL 3 layout for tracks/007-kicks.strudel
// Compile: typst compile 007-kicks-layout.typ

#set page(paper: "a4", flipped: true, margin: 12mm)
#set text(font: "Helvetica", size: 7.5pt, lang: "de")

#let c-knob   = rgb("#dbe7f5")
#let c-fader  = rgb("#e3f1df")
#let c-button = rgb("#f6ead6")
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

#let board(heads, rows) = grid(
  columns: (18mm,) + (1fr,) * 8,
  rows: (auto, 19mm, 19mm, 24mm, 17mm, 15mm, 15mm),
  gutter: 3pt,
  [], ..heads.map(h => align(center, text(weight: "bold", size: 8pt, h))),
  ..rows.flatten(),
)
#let lbl(t) = align(horizon, text(weight: "bold", size: 7pt, t))

= Launch Control XL 3 — Drum Board (007)

// *Ein Custom Mode auf MIDI-Kanal 16* (Speicherplatz egal, z.B. 15). Jede Spalte ist eine Drum-Machine, alle laufen gleichzeitig bei 125 BPM: Mit den Fadern wählst du aus oder schichtest.
// Alles startet stumm (Fader auf 0). Beim Laden stellt der Code die Knöpfe ein: Hall ganz links (trocken), Decay ganz offen, Weich ↔ Hart in die Mitte (= Original).

#v(3pt)

#board(
  ("1 · 808", "2 · 909", "3 · 707", "4 · LinnDrum", "5 · DMX", "6 · SP-1200", "7 · Synth", "8 · Rumble"),
  (
    (lbl[Reihe 1 \ Hall],
      ..range(0, 8).map(i => ctl(13 + i, "Hall", if i == 7 [Links = trocken. Nur auf die 909, das Rumble hat seinen eigenen Hall.] else [Links = trocken. Nach rechts mehr Hall in einem größer werdenden Raum.]))),
    (lbl[Reihe 2 \ Decay],
      ..range(0, 8).map(i => ctl(21 + i, "Decay (Ausklingen)", if i == 7 [Rechts = volle Länge, links kürzer. Nur die 909, Rumble bleibt.] else [Rechts = volle Länge, nach links immer kürzer und knackiger.]))),
    (lbl[Reihe 3 \ Weich ↔ Hart],
      ..range(0, 8).map(i => ctl(29 + i, "Weich ↔ Hart", [Mitte = Original. Links = Attack + Tiefpass: weich, rund, kein Klick. Rechts = Sättigung: rauer, druckvoller.]))),
    (lbl[Fader \ Level],
      ..range(0, 8).map(i => ctl(5 + i, "Level", [0–1, etwas leiser mit Sättigung], fill: c-fader))),
    (lbl[Buttons 1 \ Variante],
      ..(
        [Decay kurz → lang (Tone 25)],
        [4 Samples],
        [2 Samples],
        [nur 1 Sample],
        [3 Samples],
        [Samples 1, 5, 9, 13 von 14],
        [Pitch-Drop 24/36/48/12],
        [Rumble-Ton E/G/D/A],
      ).enumerate().map(((i, d)) => ctl(37 + i, "Variante", d, fill: c-button))),
    (lbl[Buttons 2 \ Instrument],
      ..range(0, 6).map(i => ctl(45 + i, "Instrument", [Kick → Snare → Clap → Closed Hat → Open Hat], fill: c-button)),
      off(51), off(52)),
  ),
)

#v(2pt)
#text(size: 6.5pt)[Beide Button-Reihen in Components auf *Momentary* stellen: jeder Druck schaltet einen Schritt weiter, am Ende wieder von vorn. Nach Neu-Evaluieren startet alles bei Kick, Variante 1.
Rhythmen: Kick auf allen Vierteln, Snare und Clap auf 2 und 4, Closed Hat in 16teln, Open Hat auf den Offbeats.]

== Die Maschinen (Kicks)

#set par(spacing: 5pt)
#let kick(name, tags, desc) = [*#name* #h(3pt) #text(fill: luma(90), size: 6.5pt)[#tags] \ #desc]

#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  kick("1 · Roland TR-808 (1980)", [weich · tief · lang],
    [Analoger Sinus-Boom mit Pitch-Abfall, fast kein Klick, langer Ausklang. Deep House, Hip-Hop, Electro, Trap. Klingt auf Bass-Kopfhörern riesig, auf kleinen Boxen fast unsichtbar.]),
  kick("2 · Roland TR-909 (1983)", [mittel-hart · Punch · Klick],
    [*Der* Techno- und House-Standard: kurzer Klick vorne, kräftiger Bauch, mittlerer Ausklang. Chicago/Detroit, Berlin-Techno, Tech House. Verträgt viel Sättigung.]),
  kick("3 · Roland TR-707 (1985)", [mittel · trocken · kurz],
    [Digitale Samples, knackig und kurz, wenig Tiefe. Frühes Chicago House und Italo, 80er-Feeling. Gut zum Schichten über eine 808.]),
  kick("4 · LinnDrum (1982)", [weich-mittel · akustisch · kurz],
    [Gesampelte echte Bassdrum, dumpf und trocken. 80er-Pop, Synthpop, frühe House-Tracks. Eher „Schlagzeug“ als „Maschine“.]),
  kick("5 · Oberheim DMX (1981)", [mittel-hart · punchig · trocken],
    [Kurzer, harter Schlag mit wenig Ausklang. Electro, früher Hip-Hop (Run-DMC), Detroit-Electro.]),
  kick("6 · E-mu SP-1200 (1987)", [warm · körnig · rau],
    [Kein eigenes Kick-Instrument, sondern ein Sampler: 12 Bit geben dem Sound eine warme, leicht staubige Körnung. Golden-Age-Hip-Hop, New-York-House, Garage.]),
  kick("7 · Synth-Kick (Strudel, eigener Sound)", [sauber · tief · weich bis hart],
    [Sinus mit schnellem Pitch-Abfall plus winziger Rausch-Klick, so wie 808/909 im Kern gebaut sind. Minimal, Deep House. Variante = wie tief der Pitch fällt: mehr Fall = mehr „Punch“.]),
  kick("8 · Rumble-Kick (Strudel, eigener Sound)", [hart · dunkel · Techno],
    [909 plus ein tiefes, verhalltes Brummen auf den 16teln zwischen den Kicks. Typisch für Berlin-/Warehouse-Techno und Hardgroove. Variante = Tonhöhe des Rumbles (an die Tonart anpassen).]),
)

== Varianten (Button-Reihe 1), bei Kick

Jeder Druck schaltet eine Variante weiter: 1 → 2 → 3 → 4 → 1. Bei Snare, Clap und Hats sind die Varianten einfach Sample 1–4 der Maschine (weniger Samples wiederholen sich).

#table(
  columns: (22mm, 1fr, 1fr, 1fr, 1fr),
  inset: 3pt, stroke: 0.4pt + luma(170),
  table.header([*Spalte*], [*1*], [*2*], [*3*], [*4*]),
  [1 · 808], [Decay 00: kurzer Thump], [Decay 25], [Decay 50], [Decay 75: langer Boom],
  [], table.cell(colspan: 4)[Die 808-Samples sind mit den zwei Reglern des Originals aufgenommen: Tone (Klick-Anteil) und Decay (Länge). Hier ist Tone fest auf 25.],
  [2 · 909], [Sample 1], [Sample 2], [Sample 3], [Sample 4],
  [], table.cell(colspan: 4)[Vier Aufnahmen der 909-Kick mit unterschiedlichen Einstellungen (Tune, Attack, Decay); welche genau, ist in der Sample-Sammlung nicht beschriftet.],
  [3 · 707], [Bassdrum 1], [Bassdrum 2], [wie 1], [wie 2],
  [4 · LinnDrum], table.cell(colspan: 4)[nur ein Sample, der Button ändert nichts],
  [5 · DMX], [Bassdrum 1], [Bassdrum 2], [Bassdrum 3], [wie 1],
  [6 · SP-1200], [Sample 1], [Sample 5], [Sample 9], [Sample 13],
  [], table.cell(colspan: 4)[Library-Kicks des Samplers, sehr unterschiedlich; gemeinsam ist ihnen die 12-Bit-Körnung.],
  [7 · Synth], [Pitch-Drop 24 HT: rund], [36 HT: mehr Punch], [48 HT: harter Klick-Anschlag], [12 HT: fast reiner Sinus, sehr weich],
  [8 · Rumble], [Rumble auf E], [auf G], [auf D], [auf A],
  [], table.cell(colspan: 4)[Den Rumble-Ton auf den Grundton des Tracks stellen, sonst brummt er schief gegen die Bassline.],
)
