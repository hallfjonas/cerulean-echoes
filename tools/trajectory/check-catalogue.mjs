// Does every catalogue entry that taps evaluate with only what strudel.cc provides (no player globals)?
// Per entry: the Strudel transpiler accepts the code (as strudel.cc runs it) and strudel-sim evaluates it, plain and
// tapped, with only Strudel's own functions, a fake LC XL 3 input, empty Web MIDI access and, for a board that writes
// to the page unguarded, a minimal fake page. --all also tries the entries that do not tap.
// usage (in tools/): node trajectory/check-catalogue.mjs [--all]   → exit 1 when a checked entry fails
import fs from 'fs'
import os from 'os'
import path from 'path'
import { transpiler } from '@strudel/transpiler/transpiler.mjs'
import { load } from '../strudel-sim/harness.mjs'
import { scan } from './catalogue.mjs'
import { tapSource } from './make-tapped.mjs'

const PORTS = ['LCXL3 MIDI', 'LCXL3 DAW']
navigator.requestMIDIAccess ??= async () => ({ inputs: new Map(), outputs: new Map(), addEventListener: () => {} })
const all = process.argv.includes('--all')
const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'catalogue-'))
const log = console.log
const warn = console.warn

const PAGE = { getElementById: () => null, createElement: () => ({ style: {} }), body: { appendChild: () => {} } }

const attempt = async (label, file, code) => {
  try {
    transpiler(code, { wrapAsync: true, addReturn: true })
    const pattern = await load(file, {}, undefined, { ports: PORTS })
    pattern.queryArc(0, 1)
    return null
  } catch (error) {
    const problem = `${label}: ${error.message.split('\n')[0]}`
    if (error.message !== 'document is not defined' || globalThis.document) return problem
    globalThis.document = PAGE
    try { return await attempt(label, file, code) } finally { delete globalThis.document }
  }
}

let failed = 0
for (const entry of scan()) {
  if (!entry.taps && !all) continue
  const source = fs.readFileSync(entry.path, 'utf8')
  const problems = []
  console.log = console.warn = () => {}
  problems.push(await attempt('plain', entry.path, source))
  if (entry.taps) {
    const tapped = path.join(temp, entry.id + '.strudel')
    const { code } = tapSource(source, path.basename(entry.path))
    fs.writeFileSync(tapped, code)
    problems.push(await attempt('tapped', tapped, code))
  }
  console.log = log
  console.warn = warn
  const found = problems.filter(Boolean)
  if (found.length && entry.taps) failed++
  log(`${found.length ? 'FAIL' : 'ok  '} ${entry.kind.padEnd(4)} ${entry.id}${entry.taps ? '' : ' (no tap)'}` +
    found.map(problem => `\n       ${problem}`).join(''))
}
fs.rmSync(temp, { recursive: true, force: true })
process.exit(failed ? 1 : 0)
