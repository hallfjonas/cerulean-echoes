// Loudness of each stem solo, at its fader = 1, with an optional sweep of one character/density knob.
// usage: node measure.mjs <track.strudel> [--base '<json cc values>'] stem=faderCC[,charCC] ...
//   e.g. node measure.mjs ../tracks/006-lean-mix.strudel stem1_kick=5,29 stem4_hats=8,32 stem_melody1=53,77 stem_baseline1=69
//   A stem with only one CC (like a baseline faded in by its lpf knob) gets that CC = 1.
//   Default base: both global faders (CC 12, 60) = 1, Mode 16 knob row 2 (lpf, CC 21-28) = 1, everything else 0.
// Renders run one after another (one process at a time).
import { execFileSync } from 'child_process'
import path from 'path'
import { fileURLToPath } from 'url'

const here = path.dirname(fileURLToPath(import.meta.url))
const args = process.argv.slice(2)
const file = args[0]
const bi = args.indexOf('--base')
const base = bi > 0 ? JSON.parse(args[bi + 1]) : { 12: 1, 60: 1, ...Object.fromEntries([...Array(8).keys()].map(i => [21 + i, 1])) }
const specs = args.slice(1).filter((a, i, all) => a !== '--base' && all[i] !== '--base' && a.includes('='))
if (!file || !specs.length) { console.error('usage: node measure.mjs <track.strudel> [--base JSON] stem=faderCC[,charCC] ...'); process.exit(1) }

const render = (stem, vals) => JSON.parse(execFileSync('node', [path.join(here, 'render.mjs'), file, stem, JSON.stringify(vals)])
  .toString().trim().split('\n').pop())
const fmt = r => `${String(r.lufs).padStart(6)} LUFS  pk ${r.peak.toFixed(2)}`

console.log(`${'stem'.padEnd(16)} ${'char 0'.padEnd(22)} ${'char 0.5'.padEnd(22)} char 1`)
for (const spec of specs) {
  const [stem, ccs] = spec.split('=')
  const [fader, char] = ccs.split(',').map(Number)
  const cols = (char === undefined ? [undefined] : [0, 0.5, 1]).map(c => {
    const v = { ...base, [fader]: 1 }
    if (c !== undefined) v[char] = c
    return fmt(render(stem, v))
  })
  console.log(stem.padEnd(16), cols.map(c => c.padEnd(22)).join(' '))
}
