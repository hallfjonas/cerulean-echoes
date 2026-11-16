// Audibility check: is every layer of a track heard at the default state, and does anything clip?
// usage (in tools/): node strudel-sim/audibility.mjs <track.strudel> [--cc '<json cc values>'] [--keys '<notes>']
// Default state: every LC fader (CC 5-12, Mode 2 CC 53-60) at 1, every knob and button at 0, plus the track's
// KNOB_DEFAULTS / LK_DEFAULTS. --cc overrides it (Launchkey controls as lk<cc>, e.g. lk1 = mod wheel).
// Renders, one process after another (render.mjs): the whole mix; every stem of the master solo; the Launchkey keys
// (stemLK) playing --keys with the mod wheel up; every LK_SHOTS pad once, dry. Flags: SILENT (no sound), LOW (loudest
// moment more than 12 dB below the median of the stems), CLIPS (sample peak above 1).
import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { load } from './harness.mjs'

const LOW_DB = 12
const PAD_SECONDS = 16
const here = path.dirname(fileURLToPath(import.meta.url))
const args = process.argv.slice(2)
const opt = name => args.includes(name) ? args[args.indexOf(name) + 1] : undefined
const file = args[0]
if (!file || !fs.existsSync(file)) {
  console.error(`usage: node audibility.mjs <track.strudel> [--cc '<json>'] [--keys '<notes>']`)
  process.exit(1)
}
const src = fs.readFileSync(file, 'utf8')
const bpm = Number(process.env.BPM ?? src.match(/^const bpm\s*=\s*([\d.]+)/m)?.[1] ?? 140)
const masterSrc = src.slice([...src.matchAll(/^stack\(/gm)].pop().index).split(/^\)/m)[0]
const stems = [...new Set(masterSrc.match(/\bstem\w+/g))].filter(s => s !== 'stemLK')

const log = console.log
console.log = () => {}
console.warn = () => {}
const has = name => `typeof ${name} === 'undefined' ? null : ${name}`
const [knobDefaults, lkDefaults, lkKnob1, shots] =
  await load(file, {}, `[${['KNOB_DEFAULTS', 'LK_DEFAULTS', 'LK_KNOB_1', 'LK_SHOTS'].map(has).join(', ')}]`)
console.log = log

const base = Object.fromEntries([...Array(8).keys()].flatMap(i => [[5 + i, 1], [53 + i, 1]]))
Object.assign(base, knobDefaults)
for (const [n, v] of Object.entries(lkDefaults ?? {})) base['lk' + ((lkKnob1 ?? 21) + Number(n) - 1)] = v
Object.assign(base, JSON.parse(opt('--cc') ?? '{}'))
const keys = opt('--keys') ?? '<[d3,f3,a3] [c3,e3,g3] [bb2,d3,f3] [a2,c3,e3]>*2'

const render = (expr, vals, cycles = 4) => JSON.parse(execFileSync('node',
  [path.join(here, 'render.mjs'), file, expr, JSON.stringify(vals)],
  { env: { ...process.env, BPM: String(bpm), CYC: String(cycles) }, maxBuffer: 1 << 24 })
  .toString().trim().split('\n').pop())

const padCycles = Math.ceil(PAD_SECONDS * bpm / 240)
const layers = [{ name: 'MIX', expr: '' }, ...stems.map(s => ({ name: s, expr: s, stem: true }))]
if (/^const stemLK\b/m.test(src))
  layers.push({ name: 'LK keys (wheel 1)', expr: 'stemLK', vals: { lk1: 1, keys } })
for (const [i, shot] of (shots ?? []).entries()) layers.push({ name: `pad ${i + 1} ${shot.name ?? shot.s}`,
  expr: `pure(LK_SHOTS[${i}]).fmap(({ name, once, ...v }) => ({ ...v, room: 0, delay: 0 }))` +
    `.struct('x ~@${4 * padCycles - 1}').slow(${padCycles})`, cycles: padCycles })

log(`${path.basename(file)} at ${bpm} BPM. State: faders 1, knobs/buttons 0` +
  (knobDefaults || lkDefaults ? ' + KNOB_DEFAULTS/LK_DEFAULTS' : '') + (opt('--cc') ? ' + --cc' : '') +
  `. Keys: ${keys}. Rendering ${layers.length} layers…`)
for (const l of layers) l.r = render(l.expr, { ...base, ...l.vals }, l.cycles)

const sorted = layers.filter(l => l.stem && l.r.mmax !== null).map(l => l.r.mmax).sort((a, b) => a - b)
const median = sorted.length ? sorted[Math.floor((sorted.length - 1) / 2)] : null
const num = (v, w = 6) => (v === null || v === undefined ? '–' : String(v)).padStart(w)
log('layer'.padEnd(28), ['LUFS', 'LUFS-M', 'peak', 'Δmed'].map(h => h.padStart(6)).join(' '), ' flag')
for (const { name, r } of layers) {
  const silent = r.mmax === null || r.peak < 1e-4
  const delta = silent || median === null ? null : +(r.mmax - median).toFixed(1)
  const low = name !== 'MIX' && delta !== null && delta < -LOW_DB
  const flags = [silent && 'SILENT', low && 'LOW', r.peak > 1 && 'CLIPS']
  log(`${name.slice(0, 28).padEnd(28)} ${num(r.lufs)} ${num(r.mmax)} ${num(r.peak.toFixed(2))} ${num(delta)}  ` +
    flags.filter(Boolean).join(' '))
}
log(`LUFS = integrated (gated), LUFS-M = loudest 400 ms, Δmed = LUFS-M minus the stems' median (${median}).` +
  ` LOW below −${LOW_DB} dB. Pads dry, one hit; stems and keys over 4 cycles.`)
