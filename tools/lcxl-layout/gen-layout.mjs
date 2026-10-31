// Build the Launch Control XL 3 layout sheet (PDF) of a track from the @-tags in its comments.
// usage: node gen-layout.mjs <file.strudel> ...   → writes <file>-layout.pdf next to each tagged file
//
// Tags (one per comment line, anywhere in the file):
//   // @layout <title>
//   // @note <paragraph>                     intro text, in order
//   // @mode <16|2> <page title>             a page per mode, in order
//   // @col <mode>:<col> <heading>           column heading (default: column number; column 8 with g-tags: "8 Global")
//   // @row <mode>:<row> <label>             row label, " \ " = line break
//   // @ctl <pos> <name> | <description>
// <row>: k1 k2 k3 (knob rows), fader, b1 b2 (button rows)
// <pos>: <mode>:<col>.<row>, e.g. 16:1.k1; a column range 2:1-7.k1 puts the description on the first column
//        and "wie <its heading>" on the others; g.<row> = global column 8, shown on every page (CC n / n + 48).
// CC numbers are computed from the position: Mode 16 = fader 5-12, knobs 13-36, buttons 37-52; Mode 2 = +48.
import fs from 'fs'
import path from 'path'
import { execFileSync } from 'child_process'
import { fileURLToPath } from 'url'

const template = path.join(path.dirname(fileURLToPath(import.meta.url)), 'lcxl3.typ')
const ROWS = ['k1', 'k2', 'k3', 'fader', 'b1', 'b2']
const BASE = { k1: 12, k2: 20, k3: 28, fader: 4, b1: 36, b2: 44 }
const KIND = { k1: 'knob', k2: 'knob', k3: 'knob', fader: 'fader', b1: 'button', b2: 'button' }
const LABEL = { k1: 'Reihe 1', k2: 'Reihe 2', k3: 'Reihe 3', fader: 'Fader \\ Level', b1: 'Buttons 1', b2: 'Buttons 2' }
const cc = (mode, col, row) => BASE[row] + col + (mode === 2 ? 48 : 0)

export function parse(src, source) {
  const d = { title: path.basename(source), source, notes: [], modes: [], cols: {}, rows: {}, ctls: [], global: {} }
  for (const line of src.split('\n')) {
    const m = line.match(/\/\/\s*@(layout|note|mode|col|row|ctl)\s+(.*?)\s*$/)
    if (!m) continue
    const [, tag, rest] = m
    const bad = () => { throw new Error(`${source}: cannot read tag: ${line.trim()}`) }
    if (tag === 'layout') d.title = rest
    else if (tag === 'note') d.notes.push(rest)
    else if (tag === 'mode') { const [, mode, title] = rest.match(/^(16|2)\s+(.*)$/) ?? bad(); d.modes.push({ mode: +mode, title }) }
    else if (tag === 'col') { const [, mode, col, head] = rest.match(/^(16|2):([1-8])\s+(.*)$/) ?? bad(); d.cols[`${mode}:${col}`] = head }
    else if (tag === 'row') { const [, mode, row, label] = rest.match(/^(16|2):(\w+)\s+(.*)$/) ?? bad(); d.rows[`${mode}:${row}`] = label }
    else {
      const [, pos, name, desc] = rest.match(/^(\S+)\s+(.*?)\s*\|\s*(.*)$/) ?? bad()
      const g = pos.match(/^g\.(\w+)$/)
      if (g && ROWS.includes(g[1])) { d.global[g[1]] = { name, desc }; continue }
      const [, mode, from, to, row] = pos.match(/^(16|2):([1-8])(?:-([1-8]))?\.(\w+)$/) ?? bad()
      if (!ROWS.includes(row)) bad()
      d.ctls.push({ mode: +mode, from: +from, to: +(to ?? from), row, name, desc })
    }
  }
  return d
}

export function build(d) {
  if (!d.ctls.length && !Object.keys(d.global).length) return null
  const modes = d.modes.length ? d.modes : [...new Set(d.ctls.map(c => c.mode))].sort((a, b) => b - a).map(mode => ({ mode, title: `Mode ${mode}` }))
  const both = modes.length > 1
  const hasGlobal = Object.keys(d.global).length > 0
  const pages = modes.map(({ mode, title }) => {
    const heads = [...Array(8).keys()].map(i => d.cols[`${mode}:${i + 1}`] ?? (i === 7 && hasGlobal ? '8 Global' : String(i + 1)))
    const grid = Object.fromEntries(ROWS.map(r => [r, [...Array(8).keys()].map(i => ({ cc: String(cc(mode, i + 1, r)), off: true }))]))
    for (const c of d.ctls.filter(c => c.mode === mode)) {
      for (let col = c.from; col <= c.to; col++) {
        const desc = col === c.from ? c.desc : `wie ${heads[c.from - 1]}`
        grid[c.row][col - 1] = { cc: String(cc(mode, col, c.row)), name: c.name, desc, kind: KIND[c.row] }
      }
    }
    for (const [row, g] of Object.entries(d.global)) {
      const n = cc(16, 8, row)
      grid[row][7] = { cc: both ? `${n} / ${n + 48}` : String(n), name: g.name, desc: g.desc, kind: 'global' }
    }
    const rows = ROWS.map(r => ({ row: r, label: d.rows[`${mode}:${r}`] ?? LABEL[r], cells: grid[r] }))
    return { title, heads, rows }
  })
  return { title: d.title, source: d.source, notes: d.notes, global: hasGlobal, pages }
}

export function generate(file, root = process.cwd()) {
  const source = path.relative(root, path.resolve(file))
  const data = build(parse(fs.readFileSync(file, 'utf8'), source))
  if (!data) return null
  const pdf = file.replace(/\.strudel$/, '') + '-layout.pdf'
  execFileSync('typst', ['compile', template, pdf, '--input', `data=${JSON.stringify(data)}`], { stdio: ['ignore', 'ignore', 'pipe'] })
  return pdf
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
  let failed = false
  for (const f of process.argv.slice(2)) {
    try {
      const pdf = generate(f, root)
      if (pdf) console.log('layout:', path.relative(process.cwd(), pdf))
    } catch (e) {
      failed = true
      console.error(`${f}: ${e.stderr?.toString() || e.message}`)
    }
  }
  process.exit(failed ? 1 : 0)
}
