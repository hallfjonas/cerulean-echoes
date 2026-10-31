// Launch Control XL 3 layout for sounds/lab/drum-machines-comparison.strudel
// Compile: typst compile drum-machines-comparison-layout.typ

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
  rows: (auto, 19mm, 19mm, 27mm, 17mm, 15mm, 15mm),
  gutter: 3pt,
  [], ..heads.map(h => align(center, text(weight: "bold", size: 8pt, h))),
  ..rows.flatten(),
)
#let lbl(t) = align(horizon, text(weight: "bold", size: 7pt, t))

= Launch Control XL 3 — Drum Machines Comparison

// *One custom mode on MIDI channel 16* (any memory slot, e.g. 15). Each column is one drum machine; all run together at 125 BPM. Use the faders to choose or layer them.
// Everything starts silent (faders at 0). On load, the code sets the knobs: reverb fully left (dry), decay fully open, soft ↔ hard in the middle (= original).

#v(3pt)

#board(
  ("1 · 808", "2 · 909", "3 · 707", "4 · LinnDrum", "5 · DMX", "6 · SP-1200", "7 · Synth", "8 · Rumble"),
  (
    (lbl[Row 1 \ Reverb],
      ..range(0, 8).map(i => ctl(13 + i, "Reverb", if i == 7 [Left = dry. Only on the 909; the rumble has its own reverb.] else [Left = dry. Turning right adds more reverb in a growing room.]))),
    (lbl[Row 2 \ Decay],
      ..range(0, 8).map(i => ctl(21 + i, "Decay", if i == 7 [Right = full length, left = shorter. Only the 909; the rumble stays.] else [Right = full length, turning left makes it shorter and tighter.]))),
    (lbl[Row 3 \ Soft ↔ Hard],
      ..range(0, 8).map(i => ctl(29 + i, "Soft ↔ Hard", [Middle = original. Left = attack + lowpass: soft, round, no click. Right = saturation: rougher, more punch.]))),
    (lbl[Fader \ Level],
      ..range(0, 8).map(i => ctl(5 + i, "Level", [0–1, slightly quieter with saturation], fill: c-fader))),
    (lbl[Buttons 1 \ Variant],
      ..(
        [Decay short → long (Tone 25)],
        [4 samples],
        [2 samples],
        [only 1 sample],
        [3 samples],
        [Samples 1, 5, 9, 13 of 14],
        [Pitch drop 24/36/48/12],
        [Rumble pitch E/G/D/A],
      ).enumerate().map(((i, d)) => ctl(37 + i, "Variant", d, fill: c-button))),
    (lbl[Buttons 2 \ Instrument],
      ..range(0, 6).map(i => ctl(45 + i, "Instrument", [Kick → Snare → Clap → Closed Hat → Open Hat], fill: c-button)),
      off(51), off(52)),
  ),
)

#v(2pt)
#text(size: 6.5pt)[Set both button rows to *Momentary* in Components: each press steps one position forward, and it wraps around at the end. After re-evaluating, everything starts at Kick, variant 1.
Rhythms: kick on every quarter note, snare and clap on beats 2 and 4, closed hat on sixteenths, open hat on the offbeats.]

== The machines (kicks)

#set par(spacing: 5pt)
#let kick(name, tags, desc) = [*#name* #h(3pt) #text(fill: luma(90), size: 6.5pt)[#tags] \ #desc]

#grid(
  columns: (1fr, 1fr),
  gutter: 8pt,
  kick("1 · Roland TR-808 (1980)", [soft · deep · long],
    [Analog sine boom with a pitch drop, almost no click, long decay. Deep house, hip-hop, electro, trap. Sounds huge on bass-heavy headphones, almost invisible on small speakers.]),
  kick("2 · Roland TR-909 (1983)", [medium-hard · punch · click],
    [*The* techno and house standard: a short click at the front, a strong body, medium decay. Chicago/Detroit, Berlin techno, tech house. Takes a lot of saturation.]),
  kick("3 · Roland TR-707 (1985)", [medium · dry · short],
    [Digital samples, tight and short, little depth. Early Chicago house and Italo, 80s feel. Good for layering over an 808.]),
  kick("4 · LinnDrum (1982)", [soft-medium · acoustic · short],
    [Sampled real bass drum, dull and dry. 80s pop, synthpop, early house tracks. More "drum kit" than "machine".]),
  kick("5 · Oberheim DMX (1981)", [medium-hard · punchy · dry],
    [Short, hard hit with little decay. Electro, early hip-hop (Run-DMC), Detroit electro.]),
  kick("6 · E-mu SP-1200 (1987)", [warm · grainy · rough],
    [No kick instrument of its own, but a sampler: 12-bit gives the sound a warm, slightly dusty grain. Golden-age hip-hop, New York house, garage.]),
  kick("7 · Synth kick (Strudel, own sound)", [clean · deep · soft to hard],
    [Sine with a fast pitch drop plus a tiny noise click, the way 808 and 909 are built at their core. Minimal, deep house. Variant = how far the pitch drops: more drop = more "punch".]),
  kick("8 · Rumble kick (Strudel, own sound)", [hard · dark · techno],
    [909 plus a low, reverb-smeared rumble on the sixteenths between the kicks. Typical of Berlin/warehouse techno and hard groove. Variant = pitch of the rumble (match it to the key).]),
)

== Variants (button row 1), for kick

Each press steps to the next variant: 1 → 2 → 3 → 4 → 1. For snare, clap and hats, the variants are simply samples 1–4 of the machine (fewer samples repeat).

#table(
  columns: (22mm, 1fr, 1fr, 1fr, 1fr),
  inset: 3pt, stroke: 0.4pt + luma(170),
  table.header([*Column*], [*1*], [*2*], [*3*], [*4*]),
  [1 · 808], [Decay 00: short thump], [Decay 25], [Decay 50], [Decay 75: long boom],
  [], table.cell(colspan: 4)[The 808 samples were recorded with the original's two controls: Tone (click content) and Decay (length). Here Tone is fixed at 25.],
  [2 · 909], [Sample 1], [Sample 2], [Sample 3], [Sample 4],
  [], table.cell(colspan: 4)[Four recordings of the 909 kick with different settings (tune, attack, decay); which exactly is not labeled in the sample collection.],
  [3 · 707], [Bass drum 1], [Bass drum 2], [like 1], [like 2],
  [4 · LinnDrum], table.cell(colspan: 4)[only one sample, the button changes nothing],
  [5 · DMX], [Bass drum 1], [Bass drum 2], [Bass drum 3], [like 1],
  [6 · SP-1200], [Sample 1], [Sample 5], [Sample 9], [Sample 13],
  [], table.cell(colspan: 4)[Library kicks from the sampler, very different from each other; what they share is the 12-bit grain.],
  [7 · Synth], [Pitch drop 24 st: round], [36 st: more punch], [48 st: hard click attack], [12 st: nearly pure sine, very soft],
  [8 · Rumble], [Rumble on E], [on G], [on D], [on A],
  [], table.cell(colspan: 4)[Set the rumble's pitch to the track's root note, otherwise it hums out of tune against the bassline.],
)
