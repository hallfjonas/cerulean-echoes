// Evaluate a .strudel track in Node with fixed MIDI values and query it like the scheduler does.
import * as core from '@strudel/core'
import * as mini from '@strudel/mini'
import * as tonal from '@strudel/tonal'
import fs from 'fs'
import { findMaster } from '../trajectory/make-tapped.mjs'

Object.assign(globalThis, core, mini, tonal)
mini.miniAllStrings()   // plain JS has no transpiler, so parse every string as mini-notation
const AsyncFunction = (async () => {}).constructor

// vals: { cc: value 0..1 }, mutable while running. expr: return this expression (e.g. a stem name)
// instead of the master, which is the last top-level `stack(` in the file (else its last top-level expression).
// A Launchkey (port name contains 'Launchkey') reads its own CCs from vals.lk<cc> (its knobs share CC numbers with the
// LC); its keys play vals.keys (mini-notation of notes, e.g. '<[f3,ab3,c4] [db3,f3,ab3]>'), else nothing.
// vals.midiQueue (optional array of { note, velocity, midichan }): notes that arrived since the last query, as
// midikeys' queue in the browser; each query of the keys pattern takes them all, starting at the query's begin.
// vals.keyEvents (optional, used by tools/sc-port): [{ t, note, vel, chan }] (t in cycles, chan 1-16) = notes as
// midikeys delivers them ({ note, velocity, midichan }), each as long as the note-length pattern says at its time.
// opts.ports: the MIDI input names a fake WebMidi lists while the track loads (as in the browser). The k-th LC port
// ('LCXL3', not 'DAW') reads vals[n] for k = 1, else vals['lc' + k + '.' + n]; midin of a name not listed throws.
// opts.tap(stem, hap): every onset of each stem the master names (stemXxx), audible or not, while the master runs;
// the master's haps then carry value._stem.
export async function load(file, vals, expr, opts = {}) {
  const src = fs.readFileSync(file, 'utf8')
  const master = findMaster(src, file)
  const masterSrc = opts.tap ? src.slice(master.index).replace(/\bstem\w+\b/g, m => `__tag(${m}, '${m}')`)
    : src.slice(master.index)
  const body = src.slice(0, master.index) + (expr ? `return ${expr}` : 'return ' + masterSrc)
  const isLaunchkey = name => typeof name === 'string' && name.includes('Launchkey')
  const lcPorts = (opts.ports ?? []).filter(p => p.includes('LCXL3') && !p.includes('DAW'))
  const keyOf = name => {
    const k = lcPorts.indexOf(name) + 1
    return n => isLaunchkey(name) ? 'lk' + n : k > 1 ? 'lc' + k + '.' + n : n
  }
  const findPort = name => {
    if (opts.ports && !opts.ports.some(p => p.includes(name))) throw new Error(`no MIDI input '${name}'`)
  }
  const queued = len => new core.Pattern(state => {
    const notes = vals.midiQueue?.splice(0) ?? []
    const t = state.span.begin
    const dur = typeof len === 'number' ? len : len?.queryArc?.(t, t.add(1e-4))[0]?.value ?? 0.25
    return notes.map(v => new core.Hap(new core.TimeSpan(t, t.add(dur)), new core.TimeSpan(t, t.add(dur)), v))
  })
  const env = {
    midin: async name => {
      if (name !== undefined) findPort(name)
      const key = keyOf(name)
      return n => core.ref(() => vals[key(n)] ?? 0)
    },
    midikeys: async name => {
      if (name !== undefined) findPort(name)
      return len => vals.keyEvents ? new core.Pattern(state => vals.keyEvents.flatMap(e => {
          if (e.t < state.span.begin.valueOf() || e.t >= state.span.end.valueOf()) return []
          const l = core.reify(len ?? 0.5).queryArc(e.t, e.t)[0]?.value ?? 0.5
          const span = new core.TimeSpan(core.Fraction(e.t), core.Fraction(e.t).add(l))
          return [new core.Hap(span, span, { note: e.note, velocity: (e.vel ?? 100) / 127, midichan: e.chan ?? 1 }, {})]
        }))
        : vals.midiQueue ? core.stack(vals.keys ? core.note(vals.keys) : core.silence, queued(len))
        : vals.keys ? core.note(vals.keys) : core.silence
    },
    slider: v => core.pure(v),
    setcpm: () => {},
    setcps: () => {},
    __tag: (pat, stem) => new core.Pattern(state => pat.query(state).map(h => {
      if (h.hasOnset()) opts.tap(stem, h)
      return h.withValue(v => v && typeof v === 'object' ? { ...v, _stem: stem } : v)
    })),
  }
  const saved = globalThis.WebMidi
  if (opts.ports) globalThis.WebMidi = { inputs: opts.ports.map(name => ({ name })),
    outputs: opts.ports.map(name => ({ name, send: () => {} })) }
  try { return await new AsyncFunction(...Object.keys(env), body)(...Object.values(env)) }
  finally { if (opts.ports) globalThis.WebMidi = saved }
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
