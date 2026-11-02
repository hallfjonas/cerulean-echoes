// Compare two versions of a track: events per cycle, query time, and whether the audible events are identical.
// usage: node compare.mjs <old.strudel> <new.strudel> [--ignore-cutoff0]
//   --ignore-cutoff0: drop old events with lpf 0 (e.g. baselines faded out by their lpf knob) before comparing
import { load, run, sig, audible } from './harness.mjs'

const [OLD, NEW] = process.argv.slice(2).filter(a => !a.startsWith('--'))
const ignoreCutoff0 = process.argv.includes('--ignore-cutoff0')
if (!OLD || !NEW) { console.error('usage: node compare.mjs <old.strudel> <new.strudel> [--ignore-cutoff0]'); process.exit(1) }

const CCS = [...Array(47).keys()].map(i => i + 5).flatMap(n => [n, n + 48])   // Mode 16 CC 5-51 and Mode 2 CC 53-99
const BUTTONS = new Set(CCS.filter(n => (n % 48 >= 37 && n % 48 <= 51) || (n >= 85)))

// small seeded PRNG, so runs are reproducible
const prng = seed => () => (seed = (seed * 1664525 + 1013904223) % 4294967296) / 4294967296
const fill = x => Object.fromEntries(CCS.map(n => [n, x]))
const snapshot = seed => { const r = prng(seed); return Object.fromEntries(CCS.map(n => [n, r() < 0.35 ? 0 : r()])) }

const tri = x => 1 - Math.abs(((x % 2) + 2) % 2 - 1)
// every control moves on its own path with stretches at 0 (so gates open and close); buttons are tapped now and then
const ride = seed => {
  const r = prng(seed), p = Object.fromEntries(CCS.map(n => [n, [r() * 1.5 + 0.2, r() * 2]]))
  return (v, t) => {
    for (const n of CCS) {
      const [speed, phase] = p[n]
      v[n] = BUTTONS.has(n) ? ((t * speed + phase) % 1 < 0.06 ? 1 : 0) : Math.max(0, tri(t * speed + phase) * 1.4 - 0.4)
    }
  }
}

const statics = { 'all 0': fill(0), 'all 0.5': fill(0.5), 'all 1': fill(1), 'snapshot A': snapshot(1), 'snapshot B': snapshot(2), 'snapshot C': snapshot(3) }
const dynamics = { 'ride A': ride(4), 'ride B': ride(5) }
const CYC = 4

const keep = h => audible(h) && !(ignoreCutoff0 && h.value.cutoff === 0)
const report = (name, old, neu, msOld, msNew) => {
  const a = sig(old.filter(keep)), b = sig(neu.filter(audible))
  const same = a.length === b.length && a.every((x, i) => x === b[i])
  const dups = s => s.length - new Set(s).size
  const ms = msOld === undefined ? '' : `  query ms/cycle old ${msOld.toFixed(0)} new ${msNew.toFixed(0)}`
  console.log(`${name.padEnd(11)} events/cycle old ${(old.length / CYC).toFixed(0).padStart(4)} (audible ${(a.length / CYC).toFixed(0)}) new ${(neu.length / CYC).toFixed(0).padStart(4)}${ms}  dup onsets ${dups(a)}/${dups(b)}  identical: ${same}`)
  if (!same) {
    const sa = new Set(a), sb = new Set(b)
    console.log('  only old:', a.filter(x => !sb.has(x)).slice(0, 2))
    console.log('  only new:', b.filter(x => !sa.has(x)).slice(0, 2))
  }
  return same
}

let ok = true
for (const [name, vals] of Object.entries(statics)) {
  const r = {}
  for (const [k, f] of [['old', OLD], ['new', NEW]]) {
    const pat = await load(f, { ...vals })
    const t0 = performance.now()
    r[k] = run(pat, 0, CYC)
    r[k + 'ms'] = (performance.now() - t0) / CYC
  }
  ok = report(name, r.old, r.new, r.oldms, r.newms) && ok
}
for (const [name, script] of Object.entries(dynamics)) {
  const r = {}
  for (const [k, f] of [['old', OLD], ['new', NEW]]) {
    const vals = {}; script(vals, 0)
    r[k] = run(await load(f, vals), 0, CYC, t => script(vals, t))
  }
  ok = report(name, r.old, r.new) && ok
}
process.exit(ok ? 0 : 1)
