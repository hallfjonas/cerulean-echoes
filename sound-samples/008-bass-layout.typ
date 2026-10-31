// Launch Control XL 3 layout for sound-samples/008-bass.strudel
// Compile: typst compile 008-bass-layout.typ

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


= Launch Control XL 3 — Bass Board (008)

*Derselbe Custom Mode wie beim Drum Board* (MIDI-Kanal 16, Speicherplatz 15). Jede Spalte ist ein Bass-Sound, alle spielen gleichzeitig dieselbe Bassline bei 118 BPM: Mit den Fadern wählst du aus oder schichtest.
Alles startet stumm (Fader auf 0). Beim Laden stellt der Code die Knöpfe auf einen kurzen, runden Start-Sound: Tonlänge 0.25 s, Tiefpass 250 Hz, wenig Hall. Seite neu laden, wenn vorher das Drum Board lief.

#v(3pt)

#let sounds = ("1 · Sinus", "2 · Dreieck", "3 · Saw warm", "4 · Square", "5 · Supersaw", "6 · FM", "7 · Sub + Okt.", "8 · Pluck")
#board(
  sounds,
  (
    (lbl[Reihe 1 \ Länge],
      ..range(0, 8).map(i => ctl(13 + i, "Länge", [50 ms … 1 s. Links kurz und knackig, rechts lang und fließend.]))),
    (lbl[Reihe 2 \ Tiefpass],
      ..range(0, 8).map(i => ctl(21 + i, "Tiefpass", [80 Hz … 4 kHz. Links dunkel und rund, rechts hell. Wirkt nicht auf den Sinus (Spalte 1).]))),
    (lbl[Reihe 3 \ Hall],
      ..range(0, 8).map(i => ctl(29 + i, "Hall", [Links trocken, rechts mittlerer Hall.]))),
    (lbl[Fader \ Level],
      ..range(0, 8).map(i => ctl(5 + i, "Level", [0–1, Sounds grob angeglichen], fill: c-fader))),
    (lbl[Buttons 1 \ Bassline],
      ..range(0, 8).map(i => ctl(37 + i, "Bassline", [1 → 2 → 3 → 4], fill: c-button))),
    (lbl[Buttons 2 \ Oktave],
      ..range(0, 8).map(i => ctl(45 + i, "Oktave", [normal ↔ eine Oktave höher], fill: c-button))),
  ),
)

#v(2pt)
#text(size: 6.5pt)[Buttons auf *Momentary*. Die Box unten rechts auf der Strudel-Seite zeigt Bassline und Oktave jeder Spalte. Nach Neu-Evaluieren startet alles bei Bassline 1, normale Oktave.
Für Schichten alle Spalten auf derselben Bassline lassen, verschiedene Basslines gleichzeitig reiben sich.]

== Die Sounds

#set par(spacing: 5pt)
#let snd(name, tags, desc) = [*#name* #h(3pt) #text(fill: luma(90), size: 6.5pt)[#tags] \ #desc]
#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  snd("1 · Sinus", [am weichsten · rein], [Nur der Grundton, keine Obertöne. Eher gefühlt als gehört; auf kleinen Boxen fast unhörbar.]),
  snd("2 · Dreieck", [weich · warm], [Sinus plus ein paar leise Obertöne, dadurch auch auf kleinen Boxen hörbar. Das ist Beispiel B.]),
  snd("3 · Saw warm", [analog · voll], [Sägezahn, sehr obertonreich. Mit fast geschlossenem Tiefpass ein warmer Analog-Bass; aufdrehen macht ihn hell.]),
  snd("4 · Square", [hohl · holzig], [Rechteck, hohler Klang, bei offenem Tiefpass etwas wie eine Klarinette.]),
  snd("5 · Supersaw", [breit · schimmernd], [Mehrere leicht verstimmte Sägezähne: ein breiter Pad-Bass.]),
  snd("6 · FM", [glasig · leichtes Knurren], [Ein Sinus, der von einem zweiten Sinus moduliert wird.]),
  snd("7 · Sub + Okt.", [tief · überall hörbar], [Sinus für die Tiefe plus ein leises Dreieck eine Oktave höher.]),
  snd("8 · Pluck", [schmatzend · acid], [Sägezahn, dessen Filter bei jedem Ton kurz aufschnappt und wieder zugeht.]),
)

== Basslines (Button-Reihe 1), alle in a-Moll

#table(
  columns: (12mm, 40mm, 1fr),
  inset: 3pt, stroke: 0.4pt + luma(170),
  [1], [Offbeat], [Ein Ton auf jedem „und“ zwischen den Kicks, der klassische House/Techno-Bass. A, A, F, G, je ein Takt.],
  [2], [Rolling], [Drei Sechzehntel nach jedem Kick, treibt nach vorn.],
  [3], [Oktav-Achtel], [Grundton und Oktave im Wechsel.],
  [4], [Synkopiert], [Groove mit Tönen neben dem Schlag, zwei Takte.],
)
