// Query a stem lab in Node for 8 bars with given MIDI values and print what each column plays (no audio).
// usage (in tools/): node stem-lab/check.mjs <board.strudel> '{"5":1,"6":1}' [pattern index per column, e.g. 2]
import { load, run } from '../strudel-sim/harness.mjs'
const [file, ccs, pick] = process.argv.slice(2)
const pat = await load(file, {})
const S = Object.values(globalThis).find(v => v && v.val && v.pend && v.seed)
for (let i = 5; i <= 12; i++) S.val[i] = 0
Object.assign(S.val, JSON.parse(ccs ?? '{}'))
if (pick) for (let i = 0; i < 8; i++) S.pend[i] = +pick   // columns with fewer patterns fail: pick an index all have
const haps = run(pat, 0, 8).filter(h => h.value.s && !/^(bd|oh|cp|sh|stein|jrh|triangle)$/.test(h.value.s))
const by = {}
for (const h of haps) (by[h.value.s] ??= []).push(h)
for (const [s, hs] of Object.entries(by)) {
  console.log(s, hs.length, 'events; bar 2-3 notes:', hs.filter(h => h.whole.begin >= 2 && h.whole.begin < 4).map(h => h.value.note ?? h.value.n).join(' '))
  const v = hs[0].value
  console.log('   e.g.', JSON.stringify({ ...v, note: undefined }).slice(0, 220))
}
process.exit(0)
