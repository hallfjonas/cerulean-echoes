// Run Strudel's own transpiler over files, as strudel.cc does before evaluating: catches what Node's plain-JS
// harness misses (double-quoted strings are mini-notation there, syntax the transpiler rejects).
// usage (in tools/): node strudel-sim/transpile-check.mjs <file.strudel> …   → exit 1 on any error
import fs from 'fs'
import { transpiler } from '@strudel/transpiler/transpiler.mjs'
let bad = 0
for (const f of process.argv.slice(2)) {
  try {
    transpiler(fs.readFileSync(f, 'utf8'), { wrapAsync: true, addReturn: true })
    console.log('ok   ', f)
  } catch (e) {
    bad++
    console.log('ERROR', f, '—', e.message)
  }
}
process.exit(bad ? 1 : 0)
