// Reads the Launch Control XL 3 @-tags in a track's comments (parse). Used by check-perform (which controls a track
// has), the hooks and verify (a broken tag is an error). The layout sheets and .syx modes built from these tags were
// retired on 2026-11-20; the tags stay as the description of every control.
//
// Tags (one per comment line, anywhere in the file):
//   // @layout <title>
//   // @note <paragraph>                     intro text, in order
//   // @mode <16|2> <page title>             a page per mode, in order
//                                           B16 / B2 = the same modes on a second controller (own MIDI input,
//                                           same CCs); its pages leave out the global column 8
//   // @col <mode>:<col> <heading>           column heading (default: column number; column 8 with g-tags: "8 Global")
//   // @row <mode>:<row> <label>             row label, " \ " = line break
//   // @ctl <pos> <name> | <description>
//   // @guide <heading> | <paragraph>        explanation pages after the board; same heading = more paragraphs
//   // @recipe <name> | <settings> | <use>   recipe table on the explanation pages
//   // @globalcc same                        column 8 sends the same CCs in every mode (default: Mode 2 = +48)
// <row>: k1 k2 k3 (knob rows), fader, b1 b2 (button rows)
// <pos>: <mode>:<col>.<row>, e.g. 16:1.k1 or B16:1.k1; a column range 2:1-7.k1 puts the description on the first column
//        and "as <its heading>" on the others; g.<row> = global column 8, shown on every page (CC n / n + 48).
// CC numbers are computed from the position: Mode 16 = fader 5-12, knobs 13-36, buttons 37-52; Mode 2 = +48.
import path from 'path'

const ROWS = ['k1', 'k2', 'k3', 'fader', 'b1', 'b2']
const MODE = '(B?(?:16|2))'   // B = second controller

export function parse(src, source) {
  const d = { title: path.basename(source), source, notes: [], modes: [], cols: {}, rows: {}, ctls: [], global: {}, globalSame: false, guide: [], recipes: [] }
  for (const line of src.split('\n')) {
    const m = line.match(/\/\/\s*@(layout|note|mode|col|row|ctl|guide|recipe|globalcc)\s+(.*?)\s*$/)
    if (!m) continue
    const [, tag, rest] = m
    const bad = () => { throw new Error(`${source}: cannot read tag: ${line.trim()}`) }
    if (tag === 'layout') d.title = rest
    else if (tag === 'note') d.notes.push(rest)
    else if (tag === 'mode') { const [, mode, title] = rest.match(new RegExp(`^${MODE}\\s+(.*)$`)) ?? bad(); d.modes.push({ mode, title }) }
    else if (tag === 'col') { const [, mode, col, head] = rest.match(new RegExp(`^${MODE}:([1-8])\\s+(.*)$`)) ?? bad(); d.cols[`${mode}:${col}`] = head }
    else if (tag === 'guide') {
      const [, head, text] = rest.match(/^(.*?)\s*\|\s*(.*)$/) ?? bad()
      const sec = d.guide.find(g => g.head === head) ?? (d.guide.push({ head, paras: [] }), d.guide.at(-1))
      sec.paras.push(text)
    }
    else if (tag === 'recipe') { const [, name, settings, use] = rest.match(/^(.*?)\s*\|\s*(.*?)\s*\|\s*(.*)$/) ?? bad(); d.recipes.push({ name, settings, use }) }
    else if (tag === 'globalcc') { if (!/^(same|shifted)$/.test(rest)) bad(); d.globalSame = rest === 'same' }
    else if (tag === 'row') { const [, mode, row, label] = rest.match(new RegExp(`^${MODE}:(\\w+)\\s+(.*)$`)) ?? bad(); d.rows[`${mode}:${row}`] = label }
    else {
      const [, pos, name, desc] = rest.match(/^(\S+)\s+(.*?)\s*\|\s*(.*)$/) ?? bad()
      const g = pos.match(/^g\.(\w+)$/)
      if (g && ROWS.includes(g[1])) { d.global[g[1]] = { name, desc }; continue }
      const [, mode, from, to, row] = pos.match(new RegExp(`^${MODE}:([1-8])(?:-([1-8]))?\\.(\\w+)$`)) ?? bad()
      if (!ROWS.includes(row)) bad()
      d.ctls.push({ mode, from: +from, to: +(to ?? from), row, name, desc })
    }
  }
  return d
}
