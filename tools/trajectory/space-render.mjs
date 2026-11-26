// Space Analyzer, server side: one stem of a stem track rendered alone in SuperCollider (tools/sc-port/sc-render.sh)
// at a setting, measured into a footprint (space-analysis.mjs) and cached on disk.
//   settingOf(partial)                      → { pattern, k1, k2, k3, fader, b2 } with defaults and limits
//   ccsOf(slot)                             → the CC numbers of the column: fader, k1, k2, k3, b1, b2 (Mode 2 = + 48)
//   scenarioOf({ tempo, slot, setting, bars }) → the render scenario: the setting at bar 0, nothing moves
//   footprintOf(left, right, sampleRate, { tempo, bars }) → { cells, l, r } bytes, 1/32 bar per cell
//   trackSlots(track, root)                 → { track, tempo, about, slots: [{ slot, ref, name, role, patterns, controls }] }
//   renderStem({ track, slot, setting, bars, force, root, cacheDir }) → { footprint, cached }
//                                           (cache in recordings/space/ unless cacheDir says otherwise)
// The setting is the reference state of stems/stem-loudness.mjs (fader 1, knobs 0, first pattern, master 1) unless set.
// A pattern is picked by pressing the Pattern button that many times at bar 0, which takes effect at once.
// Each cell is the loudest bin per band of a 4096-sample Hann window around its middle: lows are smeared over
// about 85 ms, which is more than one 1/32 cell at 124 bpm.
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { execFile } from 'child_process'
import { promisify } from 'util'
import { fileURLToPath } from 'url'
import { BANDS, CELLS_PER_BAR, FLOOR_DB, HIGH_HZ, LOW_HZ, encodeDb, toBase64 } from './space-analysis.mjs'
import { logPoints, magnitudes, onLogAxis, readWavChannels } from '../sound-lab/sample-shape.mjs'
import { listStemTracks } from '../sound-lab/stem-project.mjs'
import { SLOTS } from '../stems/stem-tags.mjs'
import { repoRoot } from '../stems/check-stems.mjs'

const run = promisify(execFile)
const WINDOW = 4096
export const VERSION = 1
export const MAX_BARS = 32
const KNOBS = ['k1', 'k2', 'k3']

const clamp = (value, low, high, fallback) => Number.isFinite(Number(value)) ? Math.min(high, Math.max(low, Number(value))) : fallback

export const settingOf = (partial = {}) => ({
  pattern: Math.round(clamp(partial.pattern, 0, 9, 0)),
  k1: clamp(partial.k1, 0, 1, 0),
  k2: clamp(partial.k2, 0, 1, 0),
  k3: clamp(partial.k3, 0, 1, 0),
  fader: clamp(partial.fader, 0, 1, 1),
  b2: Boolean(partial.b2),
})

export function ccsOf(slot) {
  if (!SLOTS.includes(slot)) throw new Error(`no slot "${slot}"`)
  const n = Number(slot[2])
  const plus = slot[0] === '2' ? 48 : 0
  return { fader: 4 + n + plus, k1: 12 + n + plus, k2: 20 + n + plus, k3: 28 + n + plus, b1: 36 + n + plus, b2: 44 + n + plus }
}

export function scenarioOf({ tempo, slot, setting, bars }) {
  const ccs = ccsOf(slot)
  const cc = { 12: 1, [ccs.fader]: setting.fader }
  for (const knob of KNOBS) if (setting[knob] > 0) cc[ccs[knob]] = setting[knob]
  if (setting.b2) cc[ccs.b2] = 1
  const events = []
  for (let press = 0; press < setting.pattern; press++) {
    events.push({ t: press * 0.02, cc: ccs.b1, v: 1 }, { t: press * 0.02 + 0.01, cc: ccs.b1, v: 0 })
  }
  return { bpm: tempo, cycles: bars, cc, events }
}

export function footprintOf(left, right, sampleRate, { tempo, bars }) {
  const cells = bars * CELLS_PER_BAR
  const cellSamples = sampleRate * 60 / tempo * 4 / CELLS_PER_BAR
  const points = logPoints(BANDS, LOW_HZ, HIGH_HZ)
  const binHz = sampleRate / WINDOW
  const l = new Uint8Array(cells * BANDS)
  const r = new Uint8Array(cells * BANDS)
  for (let cell = 0; cell < cells; cell++) {
    const from = Math.round((cell + 0.5) * cellSamples - WINDOW / 2)
    for (const [channel, out] of [[left, l], [right, r]]) {
      const bands = onLogAxis(magnitudes(channel, from, WINDOW), binHz, points)
      for (let band = 0; band < BANDS; band++) {
        out[cell * BANDS + band] = encodeDb(bands[band] > 0 ? Math.max(FLOOR_DB, 20 * Math.log10(bands[band])) : FLOOR_DB)
      }
    }
  }
  return { cells, l, r }
}

const readJson = file => JSON.parse(fs.readFileSync(file, 'utf8'))

export function trackSlots(track, root = repoRoot) {
  const entry = listStemTracks(root).find(item => item.track === track)
  if (!entry) throw new Error(`no stem track "${track}"`)
  const file = readJson(path.join(root, 'sc', 'tracks', track, `${track}.track`))
  const slots = SLOTS.filter(slot => entry.slots[slot]).map(slot => {
    const stem = readJson(path.join(root, 'sc', 'stems', entry.slots[slot]))
    const controls = Object.fromEntries(['k1', 'k2', 'k3', 'fader', 'b1', 'b2'].map(key => [key, stem.controls[key]?.label ?? key]))
    return { slot, ref: entry.slots[slot], name: stem.meta.label ?? stem.meta.role, role: stem.meta.role,
      patterns: (stem.patterns ?? []).map((pattern, index) => pattern.label ?? `Pattern ${index + 1}`), controls }
  })
  return { track, tempo: file.tempo, about: file.about, slots }
}

const hashOf = (...parts) => {
  const hash = crypto.createHash('sha1')
  for (const part of parts) hash.update(Buffer.isBuffer(part) ? part : String(part ?? '')).update('\u0000')
  return hash.digest('hex')
}
const fileBytes = file => fs.existsSync(file) ? fs.readFileSync(file) : ''

export function cacheKey({ track, slot, setting, bars }, root = repoRoot) {
  const trackFile = readJson(path.join(root, 'sc', 'tracks', track, `${track}.track`))
  const stemFile = path.join(root, 'sc', 'stems', trackFile.slots[slot])
  const stem = readJson(stemFile)
  return hashOf(VERSION, fileBytes(stemFile), stem.code ? fileBytes(path.join(path.dirname(stemFile), stem.code)) : '',
    fileBytes(path.join(root, 'sc', 'tracks', track, trackFile.frame)), trackFile.tempo, trackFile.swing,
    slot, JSON.stringify(setting), bars)
}

const cacheFile = (key, cacheDir) => path.join(cacheDir, `${key}.json`)

const pack = ({ cells, l, r }) => ({ cells, bands: BANDS, cellsPerBar: CELLS_PER_BAR, l: toBase64(l), r: toBase64(r) })

export async function renderStem({ track, slot, setting, bars, force = false, root = repoRoot,
  cacheDir = path.join(root, 'recordings', 'space') }) {
  if (!Number.isInteger(bars) || bars < 1 || bars > MAX_BARS) throw new Error(`bars: 1 to ${MAX_BARS}`)
  const info = trackSlots(track, root)
  if (!info.slots.some(entry => entry.slot === slot)) throw new Error(`track ${track} has no stem on slot ${slot}`)
  const clean = settingOf(setting)
  const key = cacheKey({ track, slot, setting: clean, bars }, root)
  const file = cacheFile(key, cacheDir)
  if (!force && fs.existsSync(file)) return { footprint: readJson(file), cached: true }
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'space-'))
  try {
    const scenario = path.join(temp, 'scenario.json')
    const prefix = path.join(temp, 'out')
    fs.writeFileSync(scenario, JSON.stringify(scenarioOf({ tempo: info.tempo, slot, setting: clean, bars })))
    try {
      await run(path.join(root, 'tools', 'sc-port', 'sc-render.sh'),
        [scenario, prefix, `s${slot.replace(':', '_')}`], { env: { ...process.env, CE_TRACK: `${track}/${track}.track` } })
    } catch (error) {
      throw new Error(`render failed: ${String(error.stdout ?? error.message).split('\n').slice(0, 4).join(' ')}`)
    }
    const { channels, sampleRate } = readWavChannels(fs.readFileSync(`${prefix}.wav`))
    const footprint = pack(footprintOf(channels[0], channels[1] ?? channels[0], sampleRate, { tempo: info.tempo, bars }))
    fs.mkdirSync(path.dirname(file), { recursive: true })
    fs.writeFileSync(file, JSON.stringify(footprint))
    return { footprint, cached: false }
  } finally {
    fs.rmSync(temp, { recursive: true, force: true })
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [track, slot, bars = '8'] = process.argv.slice(2)
  const started = Date.now()
  const { footprint, cached } = await renderStem({ track, slot, setting: {}, bars: Number(bars) })
  console.log(`${track} ${slot}: ${footprint.cells} cells, ${cached ? 'cached' : 'rendered'} in ${Date.now() - started} ms`)
}
