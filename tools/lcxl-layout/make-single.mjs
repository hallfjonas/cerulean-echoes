// Derive the one-controller version of a two-controller track: <name>-dual.strudel → <name>-single.strudel
// (and of the template: midi-layouts/templates/dual-lc.strudel → dual-lc-test.strudel).
// usage: node make-single.mjs <file-dual.strudel> ...   (the hook runs it after every edit of a -dual file)
//
// One controller only: Mode 1 = Jojo's foundation, columns 1-7 (same CCs as Mode 16, so tagged 16), Mode 2 = Jonas'
// colour (CC + 48). The sound code stays identical; only `const SINGLE = false` becomes true and the layout tags move:
// B16 → 16 (Mode 1), 16 → 2. Jojo's column 8 has no place (it is the global column) and is left out.
// Never edit a -single file by hand.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

// Where the single version of a file goes, or null if it has none
export const singleOf = file => file.endsWith('-dual.strudel') ? file.replace(/-dual\.strudel$/, '-single.strudel')
  : path.basename(file) === 'dual-lc.strudel' ? file.replace(/dual-lc\.strudel$/, 'dual-lc-test.strudel') : null

export function makeSingle(dualFile) {
  const out = singleOf(dualFile)
  if (!out) throw new Error(`${dualFile}: not a -dual.strudel file or the dual-lc template`)
  const src = fs.readFileSync(dualFile, 'utf8')
  // tracks need the switch; the template has no code
  if (/^const /m.test(src) && !src.includes('\nconst SINGLE = false\n')) throw new Error(`${dualFile}: no "const SINGLE = false" line`)
  const col8 = src.match(/^\/\/ @col B16:8 \d+ (.*)$/m)?.[1] ?? 'column 8'
  const lines = src.split('\n')
  const lastNote = lines.findLastIndex(l => l.startsWith('// @note '))
  // The board page has room for as many notes as the dual sheet: the status box note moves to the guide pages
  const statusNote = lines.find(l => l.startsWith('// @note ') && l.includes('status box'))
  const res = []
  lines.forEach((line, i) => {
    if (/^\/\/ @(col|ctl) B16:8\b/.test(line)) return
    if (line === statusNote && i !== lastNote) return
    let l = line.replace(/^(\/\/ @(?:col|row|ctl) )(B?)16:/, (m, tag, b) => tag + (b ? '16:' : '2:'))
    if (l.startsWith('// @mode B16 ')) l = '// @mode 16 Mode 1 — Jojo: Foundation (beat + bass) · same CCs as Mode 16'
    else if (l.startsWith('// @mode 16 ')) l = '// @mode 2 Mode 2 — Jonas: Colour (chords + melodies) · CC + 48'
    if (l.startsWith('// @layout ')) l = l.includes('(two controllers)') ? l.replace('(two controllers)', '(one controller)') : l + ' (one controller)'
    if (l === 'const SINGLE = false') l = 'const SINGLE = true'
    if (line !== statusNote) res.push(l)
    if (i === 0) res.push(`// GENERATED from ${path.basename(dualFile)} by tools/lcxl-layout/make-single.mjs — edit the dual file, not this one.`)
    if (l.startsWith('// @layout ')) res.push('// @globalcc same')
    if (i === lastNote) res.push(
      `// @note One controller: Mode 1 = Jojo (foundation, columns 1–7; Jojo's column 8 (${col8}) stays off; Mode 1 sends the same CCs as Mode 16), Mode 2 = Jonas (colour). Column 8 is global on both pages.`)
    if (l.startsWith('// @mode 16 ')) res.push('// @col 16:8 8 Global')
  })
  const lastGuide = res.findLastIndex(l => l.startsWith('// @guide '))
  res.splice(lastGuide + 1, 0,
    ...(statusNote ? [statusNote.replace('// @note ', '// @guide Status box | ')] : []),
    '// @guide Playing alone | A run is: build the beat in Mode 1, switch to Mode 2, add colour, use column 8 for the drop. Mode 1 is set up in Components with the same CCs as Mode 16.',
    '// @guide Playing alone | Faders are shared hardware: after a mode switch each sound keeps its value until you touch its fader, then it jumps to where the fader physically is. Move faders gently after switching.')
  fs.writeFileSync(out, res.join('\n'))
  return out
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  for (const f of process.argv.slice(2)) console.log(makeSingle(path.resolve(f)))
}
