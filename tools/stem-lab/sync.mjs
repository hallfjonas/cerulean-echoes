// Stem labs for 009 (lab/horns, lead, vocal, mallets, organ, pad): every board = its own head (BOARD, bpm, COLS,
// samples) + the shared engine. This copies engine.strudel-part over everything from the ENGINE banner on.
// usage: node stem-lab/sync.mjs <board.strudel> …  (in tools/)
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { transpiler } from '@strudel/transpiler/transpiler.mjs'
// round-1 boards (with BOARD and COLS) use engine.strudel-part, round 2 on (with makeCols) engine2.strudel-part,
// boards with a line `// @engine 3` engine3.strudel-part (chord progressions, fire buttons), `// @engine techno`
// engine-techno.strudel-part (track 008: F dorian, 140 BPM, techno context)
const dir = path.dirname(fileURLToPath(import.meta.url))
const MARK = '// ============================================================\n// ENGINE'
for (const f of process.argv.slice(2)) {
  const src = fs.readFileSync(f, 'utf8'), at = src.indexOf(MARK)
  const name = /^\/\/ @engine techno/m.test(src) ? 'engine-techno.strudel-part' : /^\/\/ @engine 3/m.test(src) ? 'engine3.strudel-part' : /const makeCols/.test(src) ? 'engine2.strudel-part' : 'engine.strudel-part'
  const engine = fs.readFileSync(path.join(dir, name), 'utf8')
  fs.writeFileSync(f, (at < 0 ? src.trimEnd() + '\n\n' : src.slice(0, at)) + engine)
  // check with Strudel's own transpiler (as strudel.cc): the Node harness does not parse double-quoted strings etc.
  try { transpiler(fs.readFileSync(f, 'utf8'), { wrapAsync: true, addReturn: true }); console.log('engine synced:', f) }
  catch (e) { console.log('engine synced, BUT TRANSPILE ERROR:', f, '—', e.message); process.exitCode = 1 }
}
