// Space meter: where each stem sits (low ↔ high, left ↔ right, near ↔ far) and the KPIs of the space plan
// (tracks/008-groove-techno/008-space-plan.html).
// usage: node space.mjs <track.strudel> stem=faderCC ... [--bass stem] [--kick stem] [--front a,b] [--back c,d]
//          [--base '<json cc values>'] [--defaults] [--keys '<notes>'] [--out results.json] [--no-wet] [--no-mix]
//   faderCC may be lk<cc> for a Launchkey control (e.g. stemLK=lk1, the mod wheel). --defaults adds the track's
//   KNOB_DEFAULTS / LK_DEFAULTS to the base; --keys plays these notes on the Launchkey keys (harness.mjs).
//   Each stem is rendered alone with its fader at 1 (and twice more for the reverb share: dry, see space-render.mjs);
//   the mix renders all given faders at 1. Default base: master faders (CC 12, 60) = 1, everything else 0.
//   Renders run one after another (one process at a time).
import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const here = path.dirname(fileURLToPath(import.meta.url))
const args = process.argv.slice(2)
const opt = name => args.includes(name) ? args[args.indexOf(name) + 1] : undefined
const OPTS = ['--bass', '--kick', '--front', '--back', '--base', '--out', '--keys']
const file = args[0]
const specs = args.slice(1).filter((a, i, all) => a.includes('=') && !OPTS.includes(all[i]) && !OPTS.includes(all[i - 1]))
  .map(a => { const [stem, cc] = a.split('='); return { stem, cc: /^\d+$/.test(cc) ? Number(cc) : cc } })
if (!file || !specs.length || specs.some(s => !/^(\d+|lk\d+)$/.test(String(s.cc)))) {
  console.error('usage: node space.mjs <track.strudel> stem=faderCC ... [--bass stem] [--kick stem] [--front a,b] [--back c,d]')
  process.exit(1)
}
const base = { 12: 1, 60: 1 }
if (args.includes('--defaults')) {
  const { load } = await import('./harness.mjs')
  const log = console.log; console.log = () => {}; console.warn = () => {}
  const [knobs, lk] = await load(file, {}, '[KNOB_DEFAULTS, LK_DEFAULTS]')
  console.log = log
  Object.assign(base, knobs, Object.fromEntries(Object.entries(lk).map(([n, v]) => ['lk' + (20 + Number(n)), v])))
}
Object.assign(base, opt('--base') ? JSON.parse(opt('--base')) : {})
if (opt('--keys')) base.keys = opt('--keys')
const list = name => (opt(name) ?? '').split(',').filter(Boolean)
const render = (stem, vals, dry) => JSON.parse(execFileSync('node',
  [path.join(here, 'space-render.mjs'), file, stem, JSON.stringify(vals), ...(dry ? ['--dry'] : [])],
  { maxBuffer: 1 << 24 }).toString().trim().split('\n').pop())

const pow = d => Math.pow(10, d / 10)
const LANE_OCTAVES = Math.log2(350 / 125)
const results = {}
for (const { stem, cc } of specs) {
  const vals = { ...base, [cc]: 1 }
  const r = render(stem, vals)
  if (!args.includes('--no-wet')) {
    const d = render(stem, vals, true)
    r.wet = r.energy > -120 ? +Math.max(0, 1 - pow(d.energy) / pow(r.energy)).toFixed(2) : null
  }
  results[stem] = r
  process.stderr.write('.')
}
if (!args.includes('--no-mix')) results._mix = render('-', { ...base, ...Object.fromEntries(specs.map(s => [s.cc, 1])) })
process.stderr.write('\n')

const stems = specs.map(s => s.stem).filter(s => results[s].energy > -120)
const fmt = (v, d = 2) => v === null || v === undefined ? '–' : typeof v === 'number' ? v.toFixed(d) : String(v)
console.log('stem'.padEnd(14), 'LUFS'.padStart(6), 'pan'.padStart(5), 'S/M all'.padStart(8), 'S/M<120'.padStart(8),
  'S/M>300'.padStart(8), 'lane dB'.padStart(8), 'wet'.padStart(5), '  loudest band')
for (const s of stems) {
  const r = results[s], top = r.bandMid.indexOf(Math.max(...r.bandMid))
  console.log(s.padEnd(14), fmt(r.lufs, 1).padStart(6), fmt(r.pan).padStart(5), fmt(r.sideMidAll).padStart(8),
    fmt(r.sideMidLow).padStart(8), fmt(r.sideMidHigh).padStart(8), fmt(r.lane, 1).padStart(8), fmt(r.wet).padStart(5),
    '  ' + [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000][top] + ' Hz')
}

// KPIs
const kpi = []
const check = (id, name, value, ok, goal) => kpi.push({ id, name, value, ok, goal })
if (results._mix) check('K1', 'mono low end (mix S/M < 120 Hz)', results._mix.sideMidLow, results._mix.sideMidLow <= 0.1, '≤ 0.1')
const bass = opt('--bass'), kick = opt('--kick')
const laneTotal = stems.reduce((sum, s) => sum + pow(results[s].lane), 0)
if (bass && results[bass]) {
  const share = pow(results[bass].lane) / laneTotal
  check('K2', 'bass lane ownership (share of 125–350 Hz)', +(100 * share).toFixed(0) + ' %', share >= 0.4, '≥ 40 %')
}
// Competitors: other stems whose energy in 125–350 Hz comes within 10 dB of the bassline's there
if (bass && results[bass]) {
  const crowd = stems.filter(s => s !== bass && results[s].lane >= results[bass].lane - 10)
  check('K3', 'competitors in the bass lane (≥ bass − 10 dB)', crowd.length + ' (' + crowd.join(', ') + ')', crowd.length <= 2, '≤ 2')
}
if (bass && results[bass]) {
  const r = results[bass]
  check('K4', 'bass width (S/M > 300 Hz, < 120 Hz)', fmt(r.sideMidHigh) + ', ' + fmt(r.sideMidLow),
    r.sideMidHigh >= 0.3 && r.sideMidHigh <= 0.6 && r.sideMidLow <= 0.05, '0.3–0.6, ≤ 0.05')
}
if (bass && kick && results[bass] && results[kick]) {
  const d = +(results[bass].lufs - results[kick].lufs).toFixed(1)
  check('K5', 'bass presence (LUFS bass − kick)', d + ' LU', d >= -6 && d <= -3, '−6 to −3 LU')
}
const sides = stems.filter(s => Math.abs(results[s].pan - 0.5) > 0.15 || results[s].sideMidAll >= 0.15)
check('K7', 'use of the sides', sides.length + ' of ' + stems.length + ' (' + sides.join(', ') + ')', sides.length >= 7, '≥ 7')
const front = list('--front').filter(s => results[s]?.wet !== undefined), back = list('--back').filter(s => results[s]?.wet !== undefined)
if (front.length || back.length) {
  const badF = front.filter(s => results[s].wet > 0.15), badB = back.filter(s => results[s].wet < 0.4)
  check('K8', 'front ↔ back (reverb share)', badF.length + badB.length ? 'off: ' + [...badF, ...badB].join(', ') : 'all in place',
    !badF.length && !badB.length, 'front ≤ 0.15, back ≥ 0.4')
}
console.log('\nKPI')
for (const k of kpi) console.log(' ', (k.ok ? 'ok  ' : 'MISS'), k.id.padEnd(3), k.name.padEnd(42), String(k.value).padEnd(28), 'goal', k.goal)
if (opt('--out')) fs.writeFileSync(opt('--out'), JSON.stringify({ file, results, kpi }, null, 1))
