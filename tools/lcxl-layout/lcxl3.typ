// Launch Control XL 3 layout sheet. Filled by gen-layout.mjs from the @-tags of a .strudel file:
// typst compile lcxl3.typ out.pdf --input data='<json>'

#let data = json(bytes(sys.inputs.data))

#set page(paper: "a4", flipped: true, margin: 12mm, footer: align(right, text(size: 6pt, fill: luma(130))[
  Generated from #raw(data.source) — edit the `@ctl` comments in the track, not this sheet.
]))
#set text(font: "Helvetica", size: 7.5pt, lang: "en")

#let c-knob   = rgb("#dbe7f5")
#let c-fader  = rgb("#e3f1df")
#let c-button = rgb("#f6ead6")
#let c-global = rgb("#f3dfe8")
#let c-unused = luma(240)
#let fills = (knob: c-knob, fader: c-fader, button: c-button, global: c-global)

// One control: CC number, name, short description
#let ctl(cc, name, desc, fill) = block(
  width: 100%, height: 100%, inset: 4pt, radius: 3pt, fill: fill,
  stroke: 0.4pt + luma(170),
)[
  #text(size: 6pt, fill: luma(90))[CC #cc] \
  #text(weight: "bold")[#name] \
  #text(size: 6.5pt)[#desc]
]
#let cell(c) = if c.at("off", default: false) {
  ctl(c.cc, text(fill: luma(150))[—], [], c-unused)
} else {
  ctl(c.cc, c.name, c.desc, fills.at(c.kind))
}
#let lbl(t) = align(horizon, text(weight: "bold", size: 7pt, t.split(" \\ ").join(linebreak())))

// Knob and fader rows are tall; a button row only when something sits in it
#let used(row) = row.cells.any(c => not c.at("off", default: false))
#let height(row) = if row.row.starts-with("b") { if used(row) { 15mm } else { 9mm } } else { 26mm }

#let board(page) = grid(
  columns: (18mm,) + (1fr,) * 8,
  rows: (auto,) + page.rows.map(height),
  gutter: 3pt,
  [], ..page.heads.map(h => align(center, text(weight: "bold", size: 8pt, h))),
  ..page.rows.map(r => (lbl(r.label), ..r.cells.map(cell))).flatten(),
)

= Launch Control XL 3 — #data.title

#for n in data.notes [#n #parbreak()]

#text(size: 6.5pt)[
  #box(fill: c-knob, inset: 2pt)[Knob]
  #box(fill: c-fader, inset: 2pt)[Fader]
  #box(fill: c-button, inset: 2pt)[Button]
  #if data.global [#box(fill: c-global, inset: 2pt)[global (all modes)]]
  #box(fill: c-unused, inset: 2pt)[unused]
]

#for (i, page) in data.pages.enumerate() [
  #if i > 0 { pagebreak() }
  == #page.title
  #v(2pt)
  #board(page)
]
