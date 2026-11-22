// The @ tags of a stem track (sc/tracks/<id>/<id>.track): modes, a heading and six @ctl lines per slot from its stems,
// then the frame file's own `// @` lines. sc/lib/stemtrack.scd (~ce.stemTrackTags) makes the same lines for the web
// UI; check-perform reads these. usage (in tools/): node stems/stem-tags.mjs <file.track>
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { repoRoot } from './check-stems.mjs'

export const SLOTS = ['1:1', '1:2', '1:3', '1:4', '1:5', '1:6', '1:7', '2:1', '2:2', '2:3', '2:4', '2:5', '2:6', '2:7']
const ROWS = ['k1', 'k2', 'k3', 'fader', 'b1', 'b2']

export function trackTags(file, root = repoRoot) {
  const track = JSON.parse(fs.readFileSync(file, 'utf8'))
  const lines = [`// @layout ${track.name} (stem track)`, '// @mode 16 Mode 1 — Foundation',
    '// @mode 2 Mode 2 — Colour']
  for (const slot of SLOTS.filter(s => track.slots[s])) {
    const stem = JSON.parse(fs.readFileSync(path.join(root, 'sc', 'stems', track.slots[slot]), 'utf8'))
    const [mode, n] = [slot[0] === '1' ? '16' : '2', slot[2]]
    const role = stem.meta.role
    lines.push(`// @col ${mode}:${n} ${n} ${role[0].toUpperCase()}${role.slice(1)}`)
    for (const row of ROWS) {
      lines.push(`// @ctl ${mode}:${n}.${row} ${stem.controls[row].label} | ${stem.controls[row].about}`)
    }
  }
  const frame = fs.readFileSync(path.join(path.dirname(file), track.frame), 'utf8')
  return [...lines, ...frame.split('\n').filter(line => line.startsWith('// @'))].join('\n')
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  console.log(trackTags(path.resolve(process.env.INIT_CWD ?? process.cwd(), process.argv[2])))
}
