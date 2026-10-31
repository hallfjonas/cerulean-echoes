// Launch Control XL 3 layout for sounds/lab/bass-synths-comparison.strudel
// Compile: typst compile bass-synths-comparison-layout.typ

#set page(paper: "a4", flipped: true, margin: 12mm)
#set text(font: "Helvetica", size: 7.5pt, lang: "en")

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
  rows: (auto, 19mm, 24mm, 19mm, 17mm, 15mm, 15mm),
  gutter: 3pt,
  [], ..heads.map(h => align(center, text(weight: "bold", size: 8pt, h))),
  ..rows.flatten(),
)
#let lbl(t) = align(horizon, text(weight: "bold", size: 7pt, t))


= Launch Control XL 3 — Bass Synths Comparison

*Same custom mode as the drum machines comparison* (MIDI channel 16, memory slot 15). Each column is one bass sound; all play the same bassline at the same time, at 118 BPM. Use the faders to choose or layer them.
Everything starts silent (faders at 0). On load, the code sets the knobs to a short, round starting sound: note length 0.25 s, lowpass 250 Hz, a little reverb. Reload the page if the drum machines comparison was running before.

#v(3pt)

#let sounds = ("1 · Sine", "2 · Triangle", "3 · Saw warm", "4 · Square", "5 · Supersaw", "6 · FM", "7 · Sub + Oct.", "8 · Pluck")
#board(
  sounds,
  (
    (lbl[Row 1 \ Length],
      ..range(0, 8).map(i => ctl(13 + i, "Length", [50 ms … 1 s. Left = short and tight, right = long and flowing.]))),
    (lbl[Row 2 \ Lowpass],
      ..range(0, 8).map(i => ctl(21 + i, "Lowpass", [80 Hz … 4 kHz. Left = dark, right = bright. No effect on the sine.]))),
    (lbl[Row 3 \ Reverb],
      ..range(0, 8).map(i => ctl(29 + i, "Reverb", [Left = dry, right = medium reverb.]))),
    (lbl[Fader \ Level],
      ..range(0, 8).map(i => ctl(5 + i, "Level", [0–1, sounds roughly matched], fill: c-fader))),
    (lbl[Buttons 1 \ Bassline],
      ..range(0, 8).map(i => ctl(37 + i, "Bassline", [1 → 2 → 3 → 4], fill: c-button))),
    (lbl[Buttons 2 \ Octave],
      ..range(0, 8).map(i => ctl(45 + i, "Octave", [normal ↔ one octave up], fill: c-button))),
  ),
)

#v(2pt)
#text(size: 6.5pt)[Buttons on *Momentary*. The box at the bottom right of the Strudel page shows the bassline and octave of each column. After re-evaluating, everything starts at bassline 1, normal octave.
To layer, keep all columns on the same bassline; different basslines at the same time clash.]

== The sounds

#set par(spacing: 5pt)
#let snd(name, tags, desc) = [*#name* #h(3pt) #text(fill: luma(90), size: 6.5pt)[#tags] \ #desc]
#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  snd("1 · Sine", [softest · pure], [Only the fundamental, no overtones. Felt more than heard; almost inaudible on small speakers.]),
  snd("2 · Triangle", [soft · warm], [Sine plus a few quiet overtones, so it stays audible on small speakers. This is example B.]),
  snd("3 · Saw warm", [analog · full], [Sawtooth, very rich in overtones. With the lowpass nearly closed it is a warm analog bass; opening it makes it bright.]),
  snd("4 · Square", [hollow · woody], [Square wave, hollow sound; with the lowpass open, a bit like a clarinet.]),
  snd("5 · Supersaw", [wide · shimmering], [Several slightly detuned sawtooths: a wide pad bass.]),
  snd("6 · FM", [glassy · slight growl], [A sine modulated by a second sine.]),
  snd("7 · Sub + Oct.", [deep · audible everywhere], [Sine for the depth plus a quiet triangle one octave higher.]),
  snd("8 · Pluck", [squelchy · acid], [Sawtooth whose filter snaps open on each note and closes again.]),
)

== Basslines (button row 1), all in A minor

#table(
  columns: (12mm, 40mm, 1fr),
  inset: 3pt, stroke: 0.4pt + luma(170),
  [1], [Offbeat], [One note on every "and" between the kicks, the classic house/techno bass. A, A, F, G, one bar each.],
  [2], [Rolling], [Three sixteenths after each kick, drives forward.],
  [3], [Octave eighths], [Root and octave alternating.],
  [4], [Syncopated], [Groove with notes off the beat, two bars.],
)
