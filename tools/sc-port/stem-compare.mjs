// Event-by-event comparison of a hand-written SC track (.scd) and its stem track (.track) over an auto-perform script:
// both are rendered with the same controller moves (sc/tools/render.scd, events only), then every note is compared
// with every parameter its SynthDef reads (sample buffers by file, bus mappings as "bus"; keys no SynthDef input reads,
// such as the log labels tag and g, are left out). Stems are matched by name (--map).
// usage (in tools/): node sc-port/stem-compare.mjs <script.json> <workdir> [--track 009-house] [--bars 0-192]
//   [--cc '{"61":0.6}'] [--audio]
// --track: sc/tracks/<id>/<id>.scd and <id>.track; --cc: controls at bar 0 on both sides (start values);
// --audio: render audio too (WAVs in <workdir>). Prints one line per stem with its match (equal events / the larger
// side) and the overall match; exit 1 on a difference.
import fs from 'fs'
import path from 'path'
import { execFileSync } from 'child_process'
import { fileURLToPath } from 'url'

const here = path.dirname(fileURLToPath(import.meta.url))
const args = process.argv.slice(2)
const opt = (name, dflt) => { const i = args.indexOf(name); return i < 0 ? dflt : args[i + 1] }
const [scriptFile, work] = args
const id = opt('--track', '009-house')
const [from, to] = (opt('--bars', '') || '0-').split('-').map(x => x === '' ? NaN : Number(x))
const startCc = JSON.parse(opt('--cc', '{}'))
const audio = args.includes('--audio')
const nameMap = JSON.parse(opt('--map', JSON.stringify({ kick: 's1_1', noise: 's1_2', sub: 's1_3', bass: 's1_4',
  clap: 's1_5', hats: 's1_6', perc: 's1_7', harm: 's2_1', keys: 's2_2', vibes: 's2_3', flute: 's2_4', brass: 's2_5',
  strings: 's2_6', guitar: 's2_7', lk: 'lk' })))

const noteNumber = name => {
  if (/^\d+$/.test(name)) return Number(name)
  const m = name.toLowerCase().match(/^([a-g])(#|b)?(-?\d)$/)
  return 12 * (Number(m[3]) + 1) + { c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11 }[m[1]] + (m[2] === '#') - (m[2] === 'b')
}

// script v2 → render scenario (bars = cycles; ramps in 16th steps; a press held a tenth of a bar)
export function scenarioOf(script, cc = {}, bars = script.bars) {
  const events = [], keyEvents = []
  const now = {}
  const steps = [...script.steps].sort((a, b) => a.bar - b.bar)
  for (const s of steps) {
    if (s.keys) {
      for (const n of String(s.keys).split(/\s+/)) {
        keyEvents.push({ t: s.bar, note: noteNumber(n), vel: Math.max(1, Math.round((s.velocity ?? 0.8) * 127)), chan: 1 })
      }
    } else if ('pad' in s) {
      keyEvents.push({ t: s.bar, note: s.pad, vel: Math.max(1, Math.round((s.velocity ?? 0.8) * 127)), chan: 10 })
    } else if ('press' in s) {
      events.push({ t: s.bar, cc: s.press, v: 1 }, { t: s.bar + 0.1, cc: s.press, v: 0 })
    } else {
      const key = 'lk' in s ? `lk${s.lk}` : s.cc
      if (s.ramp) {
        const v0 = now[key] ?? 0, n = Math.round(s.ramp * 16)
        for (let i = 1; i <= n; i++) events.push({ t: s.bar + i / 16, cc: key, v: v0 + (s.value - v0) * i / n })
      } else events.push({ t: s.bar, cc: key, v: s.value })
      now[key] = s.value
    }
  }
  return { bpm: 124, cycles: bars, cc, events, keyEvents }
}

const render = (scenFile, prefix, track) => {
  const env = { ...process.env, CE_TRACK: track }
  if (!audio) env.CE_NO_AUDIO = '1'
  execFileSync(path.join(here, 'sc-render.sh'), [scenFile, prefix], { env, stdio: 'inherit' })
}

const norm = (prefix, map) => {
  const bufs = JSON.parse(fs.readFileSync(prefix + '.buffers.json', 'utf8'))
  const inputs = JSON.parse(fs.readFileSync(prefix + '.controls.json', 'utf8'))
  return JSON.parse(fs.readFileSync(prefix + '.events.json', 'utf8')).map(e => {
    const v = {}
    const reads = inputs[e.v.instrument]?.length ? new Set(inputs[e.v.instrument]) : null
    for (const [k, x] of Object.entries(e.v)) {
      if (['instrument', 'id', 'isPlaying', 'hasGate', 'msgFunc'].includes(k) || (reads && !reads.has(k))) continue
      v[k] = (/buf$/i.test(k) || k === 'bd') ? bufs[x] ?? x : (typeof x === 'string' && /^c\d+$/.test(x)) ? 'bus' : x
    }
    return { b: e.b, stem: map[e.stem] ?? e.stem, inst: e.v.instrument, v }
  })
}
const sig = e => `${e.b.toFixed(4)} ${e.inst} ` + Object.keys(e.v).sort().map(k => `${k}=${e.v[k]}`).join(' ')

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  fs.mkdirSync(work, { recursive: true })
  const script = JSON.parse(fs.readFileSync(scriptFile, 'utf8'))
  const bars = Number.isFinite(to) ? to : script.bars
  const scenFile = path.join(work, 'scenario.json')
  fs.writeFileSync(scenFile, JSON.stringify(scenarioOf(script, startCc, bars)))
  const pa = path.join(work, 'scd'), pb = path.join(work, 'track')
  render(scenFile, pa, `${id}/${id}`)
  render(scenFile, pb, `${id}/${id}.track`)
  const inRange = e => e.b >= from - 1e-9 && e.b < bars - 1e-9
  const A = norm(pa, nameMap).filter(inRange), B = norm(pb, {}).filter(inRange)
  const stems = [...new Set([...A, ...B].map(e => e.stem))].sort()
  let diff = 0, matched = 0, total = 0
  const report = {}
  for (const st of stems) {
    const count = list => { const m = new Map(); for (const e of list) m.set(sig(e), (m.get(sig(e)) ?? 0) + 1); return m }
    const ca = count(A.filter(e => e.stem === st)), cb = count(B.filter(e => e.stem === st))
    const only = (x, y) => [...x].flatMap(([k, n]) => Array(Math.max(0, n - (y.get(k) ?? 0))).fill(k))
    const oa = only(ca, cb), ob = only(cb, ca)
    const na = [...ca.values()].reduce((s, n) => s + n, 0), nb = [...cb.values()].reduce((s, n) => s + n, 0)
    const same = na - oa.length, size = Math.max(na, nb)
    const match = size ? 100 * same / size : 100
    matched += same
    total += size
    report[st] = { scd: na, track: nb, match: Number(match.toFixed(2)), onlyScd: oa.slice(0, 5), onlyTrack: ob.slice(0, 5) }
    if (oa.length || ob.length) diff++
    console.log(`${st.padEnd(6)} scd ${String(na).padStart(6)}  track ${String(nb).padStart(6)}  ` +
      (oa.length || ob.length ? `DIFF ${match.toFixed(1)}% (${oa.length} only scd, ${ob.length} only track)` : 'equal'))
  }
  const overall = total ? 100 * matched / total : 100
  report.overall = Number(overall.toFixed(2))
  fs.writeFileSync(path.join(work, 'report.json'), JSON.stringify(report, null, 1))
  console.log(diff ? `${diff} stems differ, ${overall.toFixed(2)}% of events equal (details: ${path.join(work, 'report.json')})`
    : 'all stems equal, event by event')
  process.exit(diff ? 1 : 0)
}
