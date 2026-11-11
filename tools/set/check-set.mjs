// Check the set against its four tracks: on each track's plateau the set must play exactly the track's events
// (007 at half speed on the 140 grid, 008 transposed by +4, orbits shifted), with the same knob settings and moves.
// Also prints query time per cycle on the plateaus and in the middle of each transition (CPU).
// usage: node set/check-set.mjs [cycles]   (from tools/)
import path from 'path'
import { fileURLToPath } from 'url'
import { load, run } from '../strudel-sim/harness.mjs'

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const SET = path.join(ROOT, 'tracks/011-combining-all/011-set-dual.strudel')
const TRACKS = [
  { file: 'tracks/007-ambient-soundscape/007-ambient-dual.strudel', slow: 2, orbit0: 0, transpose: 0 },
  { file: 'tracks/010-ambient-house/010-ambient-house-dual.strudel', slow: 1, orbit0: 3, transpose: 0 },
  { file: 'tracks/009-house/009-house-dual.strudel', slow: 1, orbit0: 0, transpose: 0 },
  { file: 'tracks/008-groove-techno/old/008-groove-techno-multi.strudel', slow: 1, orbit0: 3, transpose: 4 },
]
const CYC = +(process.argv[2] ?? 4)
const plateau = k => k * 0.3 + 0.05

const CCS = [...Array(47).keys()].map(i => i + 5).flatMap(n => [n, n + 48])
const BUTTONS = new Set(CCS.filter(n => (n % 48 >= 37 && n % 48 <= 51) || n >= 85))
const NO_BREAK = [52, 100]   // column 8 button 2: break in the tracks, set mode in the set
const prng = seed => () => (seed = (seed * 1664525 + 1013904223) % 4294967296) / 4294967296
const fill = x => Object.fromEntries(CCS.map(n => [n, NO_BREAK.includes(n) ? 0 : x]))
const snapshot = seed => { const r = prng(seed); return Object.fromEntries(CCS.map(n => [n, NO_BREAK.includes(n) || r() < 0.35 ? 0 : r()])) }
const tri = x => 1 - Math.abs(((x % 2) + 2) % 2 - 1)
const ride = seed => {
  const r = prng(seed), p = Object.fromEntries(CCS.map(n => [n, [r() * 1.5 + 0.2, r() * 2]]))
  return (v, t) => {
    for (const n of CCS) {
      const [speed, phase] = p[n]
      v[n] = NO_BREAK.includes(n) ? 0 : BUTTONS.has(n) ? ((t * speed + phase) % 1 < 0.06 ? 1 : 0)
        : Math.max(0, tri(t * speed + phase) * 1.4 - 0.4)
    }
  }
}
const statics = { 'all 0': fill(0), 'all 0.5': fill(0.5), 'all 1': fill(1), 'snapshot A': snapshot(1), 'snapshot B': snapshot(2) }
const dynamics = { 'ride A': ride(4), 'ride B': ride(5) }

const round = x => typeof x === 'number' ? +x.toPrecision(12) : x
const midiOf = x => typeof x === 'string' ? noteToMidi(x) : x
const norm = (h, t) => {
  const v = { ...h.value }
  if (v.note !== undefined) v.note = round(midiOf(v.note) - (t?.transpose ?? 0))
  if (t && v.orbit !== undefined) v.orbit -= t.orbit0
  const keys = Object.keys(v).sort()
  return round(h.whole.begin.valueOf() / (t?.slow ?? 1)).toFixed(6) + JSON.stringify(Object.fromEntries(keys.map(k => [k, round(v[k])])))
}
const audible = h => h.value.s !== undefined && (h.value.gain ?? 1) * (h.value.postgain ?? 1) > 0

const freshState = pos => { globalThis.setState = { pos, smooth: pos, fog: 0, mode: false, prev: null, beat: null } }
globalThis.setCheck = true

let ok = true
for (const [k, t] of TRACKS.entries()) {
  console.log(`\n${t.file} — set position ${plateau(k)}`)
  const cases = [...Object.entries(statics).map(([n, v]) => [n, () => ({ ...v }), null]),
    ...Object.entries(dynamics).map(([n, f]) => [n, () => fill(0), f])]
  for (const [name, init, move] of cases) {
    const vo = init(), vs = init()
    const orig = await load(path.join(ROOT, t.file), vo)
    freshState(plateau(k))
    const set = await load(SET, vs)
    const t0 = performance.now()
    const a = run(orig, 0, CYC, move && (x => move(vo, x))).filter(audible).map(h => norm(h)).sort()
    const t1 = performance.now()
    const b = run(set, 0, CYC * t.slow, move && (x => move(vs, Math.floor(x / t.slow / 0.05 + 1e-9) * 0.05))).filter(audible).map(h => norm(h, t)).sort()
    const t2 = performance.now()
    const same = a.length === b.length && a.every((x, i) => x === b[i])
    ok &&= same
    console.log(`${name.padEnd(11)} events ${String(a.length).padStart(5)} / ${String(b.length).padStart(5)}  ms/bar track ${((t1 - t0) / CYC).toFixed(0).padStart(3)} set ${((t2 - t1) / CYC).toFixed(0).padStart(3)}  identical: ${same}`)
    if (!same) {
      const sa = new Set(a), sb = new Set(b)
      console.log('  only track:', a.filter(x => !sb.has(x)).slice(0, 2))
      console.log('  only set:  ', b.filter(x => !sa.has(x)).slice(0, 2))
    }
  }
}

// CPU in the transitions: all knobs and faders at 0.5, the position in the middle of each transition
console.log('\nTransitions (all controls 0.5):')
for (const k of [0, 1, 2]) {
  for (const x of [0.25, 0.5, 0.75]) {
    const pos = k * 0.3 + 0.1 + 0.2 * x
    freshState(pos)
    const set = await load(SET, fill(0.5))
    const t0 = performance.now()
    const evs = run(set, 0, CYC).filter(audible)
    console.log(`${['007 → 010', '010 → 009', '009 → 008'][k]} at ${Math.round(x * 100)} %: ${(evs.length / CYC).toFixed(0)} events/bar, ${((performance.now() - t0) / CYC).toFixed(0)} ms/bar`)
  }
}
console.log(ok ? '\nall plateaus identical to their tracks' : '\nDIFFERENCES found')
process.exit(ok ? 0 : 1)
