// Evaluate a .strudel track in Node with fixed MIDI values and query it like the scheduler does.
import * as core from '@strudel/core'
import * as mini from '@strudel/mini'
import * as tonal from '@strudel/tonal'
import fs from 'fs'

Object.assign(globalThis, core, mini, tonal)
mini.miniAllStrings()   // plain JS has no transpiler, so parse every string as mini-notation
const AsyncFunction = (async () => {}).constructor

// vals: { cc: value 0..1 }, mutable while running. expr: return this expression (e.g. a stem name)
// instead of the master, which is the last top-level `stack(` in the file.
// A Launchkey (port name contains 'Launchkey') reads its own CCs from vals.lk<cc> (its knobs share CC numbers with the
// LC); its keys play vals.keys (mini-notation of notes, e.g. '<[f3,ab3,c4] [db3,f3,ab3]>'), else nothing.
export async function load(file, vals, expr) {
  const src = fs.readFileSync(file, 'utf8')
  const master = [...src.matchAll(/^stack\(/gm)].pop()
  if (!master) throw new Error(`${file}: no top-level stack( (master) found`)
  const body = src.slice(0, master.index) + (expr ? `return ${expr}` : 'return ' + src.slice(master.index))
  const isLaunchkey = name => typeof name === 'string' && name.includes('Launchkey')
  const env = {
    midin: async name => n => core.ref(() => (isLaunchkey(name) ? vals['lk' + n] : vals[n]) ?? 0),
    midikeys: async () => () => vals.keys ? core.note(vals.keys) : core.silence,
    slider: v => core.pure(v),
    setcpm: () => {},
    setcps: () => {},
  }
  return new AsyncFunction(...Object.keys(env), body)(...Object.values(env))
}

export const STEP = 0.05   // scheduler-sized query spans (cycles)
export function run(pat, from, to, onTick) {
  const out = []
  for (let t = from; t < to - 1e-9; t += STEP) {
    onTick?.(t)
    for (const h of pat.queryArc(t, Math.min(to, t + STEP))) if (h.hasOnset()) out.push(h)
  }
  return out
}

const sortKeys = o => Object.fromEntries(Object.entries(o).sort(([a], [b]) => a < b ? -1 : 1))
export const sig = haps => haps.map(h => h.whole.begin.valueOf().toFixed(6) + JSON.stringify(sortKeys(h.value))).sort()
export const audible = h => (h.value.gain ?? 1) * (h.value.postgain ?? 1) > 0
