// Check the continuum (tracks/011-combining-all/011-continuum-dual.strudel) in Node:
// 1. it evaluates and plays at every position with all controls at 0, 0.5 and 1 (events per bar, query time = CPU)
// 2. continuity: per column, the summed loudness of every 16th step, compared between neighbouring positions
//    (a step of 1 % of the set). A column that swaps instruments or patterns shows as a jump.
// usage: node set/check-continuum.mjs   (from tools/)
import path from 'path'
import { fileURLToPath } from 'url'
import { load, run } from '../strudel-sim/harness.mjs'

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const FILE = path.join(ROOT, 'tracks/011-combining-all/011-continuum-dual.strudel')
globalThis.continuumCheck = true
const CCS = [...Array(47).keys()].map(i => i + 5).flatMap(n => [n, n + 48])
const BUTTONS = new Set(CCS.filter(n => (n % 48 >= 37 && n % 48 <= 51) || n >= 85))
const fill = x => Object.fromEntries(CCS.map(n => [n, BUTTONS.has(n) ? 0 : x]))
const audible = h => h.value.s !== undefined && (h.value.gain ?? 1) * (h.value.postgain ?? 1) > 0
const setPos = p => { globalThis.continuumState = { pos: p, smooth: p, fog: 0, prev: null, held: false, moved: false } }

console.log('position  controls  events/bar  ms/bar')
for (const p of [0, 0.17, 0.33, 0.5, 0.67, 0.83, 1]) for (const x of [0, 0.5, 1]) {
  setPos(p)
  const pat = await load(FILE, fill(x === 0 ? 0 : x))
  // faders must be up to hear anything: level CCs 5-12 (Jojo) at x, master (Jonas col 8 fader = 12) at least 0.8
  const t0 = performance.now()
  const evs = run(pat, 0, 4).filter(audible)
  console.log(String(p).padEnd(9), String(x).padEnd(9), String(evs.length / 4).padEnd(11), ((performance.now() - t0) / 4).toFixed(1))
}

// Continuity: faders 0.8, knobs 0. Per sound (s), the loudness in each 16th of 4 bars, summed over 3 neighbouring
// 16ths (so a hit that slides by a 16th, like the sub moving behind the kick, counts as moving, not as a jump)
const vals = { ...fill(0) }
for (let n = 5; n <= 12; n++) vals[n] = 0.8
const profile = async p => {
  setPos(p)
  const pat = await load(FILE, vals)
  const out = {}
  for (const h of run(pat, 0, 4).filter(audible)) {
    const x = h.value.s === undefined ? 0 : h.whole.begin.valueOf() * 16, b = Math.floor(x), f = x - b
    const g = (h.value.gain ?? 1) * (h.value.postgain ?? 1)
    // split between the two nearest 16ths, then spread over the neighbours
    for (const [c, share] of [[b, 1 - f], [b + 1, f]])
      for (const j of [c - 1, c, c + 1]) out[h.value.s + ' ' + j] = (out[h.value.s + ' ' + j] ?? 0) + g * share
  }
  return out
}
let prev = await profile(0), worst = []
for (let i = 1; i <= 100; i++) {
  const cur = await profile(i / 100)
  for (const k of new Set([...Object.keys(prev), ...Object.keys(cur)])) {
    const d = Math.abs((cur[k] ?? 0) - (prev[k] ?? 0))
    worst.push([d, i / 100, k])
  }
  prev = cur
}
worst.sort((a, b) => b[0] - a[0])
console.log('\nlargest changes of loudness in one place between neighbouring positions (1 % apart):')
for (const [d, p, k] of worst.slice(0, 6)) console.log(`  ${d.toFixed(3)} at ${p} (${k})`)
