// Analyse an audio file into a trajectory (JSONL) and print a summary per band.
// usage (in tools/): node trajectory/analyse-file.mjs <audio> [--out trajectory.jsonl] [--from s] [--to s]
// Decodes with ffmpeg (any format it reads), stereo at 44.1 kHz; a mono file has the same signal on both sides.
import { execFileSync } from 'child_process'
import fs from 'fs'
import { createAnalyser, BANDS } from './analyse.mjs'

const args = process.argv.slice(2)
const option = name => args.includes(name) ? args[args.indexOf(name) + 1] : undefined
const file = args.find((a, i) => !a.startsWith('--') && !args[i - 1]?.startsWith('--'))
if (!file) {
  console.error('usage: node trajectory/analyse-file.mjs <audio> [--out trajectory.jsonl] [--from s] [--to s]')
  process.exit(1)
}
const sampleRate = 44100
const range = [...(option('--from') ? ['-ss', option('--from')] : []), ...(option('--to') ? ['-to', option('--to')] : [])]
const raw = execFileSync('ffmpeg', ['-v', 'error', ...range, '-i', file, '-f', 'f32le', '-ac', '2', '-ar', `${sampleRate}`, '-'],
  { maxBuffer: 2 ** 31 })
const interleaved = new Float32Array(raw.buffer, raw.byteOffset, raw.byteLength / 4)
const frames = interleaved.length / 2
const left = new Float32Array(frames), right = new Float32Array(frames)
for (let i = 0; i < frames; i++) { left[i] = interleaved[2 * i]; right[i] = interleaved[2 * i + 1] }

const { size, hop, analyse } = createAnalyser({ sampleRate })
const lines = []
for (let start = 0; start + size <= frames; start += hop) {
  lines.push(...analyse(left.subarray(start, start + size), right.subarray(start, start + size), (start + size) / sampleRate))
}
if (option('--out')) fs.writeFileSync(option('--out'), lines.map(l => JSON.stringify(l)).join('\n') + '\n')

const hz = y => 20 * 1000 ** y
const weightedStats = (values, weights) => {
  const total = weights.reduce((s, w) => s + w, 0) || 1
  const mean = values.reduce((s, v, i) => s + v * weights[i], 0) / total
  return [mean, Math.sqrt(values.reduce((s, v, i) => s + (v - mean) ** 2 * weights[i], 0) / total)]
}
const pulses = lines.filter(l => l.pulse).map(l => l.pulse).filter(p => p.bpm)
const median = values => [...values].sort((a, b) => a - b)[Math.floor(values.length / 2)] ?? 0
const bpm = median(pulses.map(p => p.bpm)) || 120
const drift = (own, key, window = 2 * 60 / bpm) => {
  const buckets = new Map()
  for (const l of own) {
    const b = buckets.get(Math.floor(l.t / window)) ?? { sum: 0, weight: 0 }
    b.sum += l[key] * l.e; b.weight += l.e
    buckets.set(Math.floor(l.t / window), b)
  }
  const means = [...buckets.values()].filter(b => b.weight > 0.5).map(b => b.sum / b.weight)
  const blocks = []
  for (let i = 0; i + 16 <= means.length; i += 16) blocks.push(weightedStats(means.slice(i, i + 16), Array(16).fill(1))[1])
  return median(blocks)
}
const seconds = frames / sampleRate
console.log(`${file}: ${seconds.toFixed(1)} s, ${lines.length} lines`)
console.log('drift = spread of the 2-beat averages within 8 bars, median over the track: how far a band travels while a\n'
  + '        part plays (not the jitter within one hit, not the change between sections)')
console.log('band       pan mean  drift   pitch mean (y)  drift   depth  energy  onsets/min')
for (const { stem } of BANDS) {
  const own = lines.filter(l => l.stem === stem), weights = own.map(l => l.e)
  const [x] = weightedStats(own.map(l => l.x), weights)
  const [y] = weightedStats(own.map(l => l.y), weights)
  const [z] = weightedStats(own.map(l => l.z), weights)
  const e = own.reduce((s, l) => s + l.e, 0) / own.length
  const onsets = own.reduce((s, l) => s + l.on, 0) / seconds * 60
  console.log(`${stem.padEnd(9)} ${x.toFixed(2).padStart(6)}    ${drift(own, 'x').toFixed(3)}   `
    + `${hz(y).toFixed(0).padStart(5)} Hz (${y.toFixed(3)})  ${drift(own, 'y').toFixed(3)}   ${z.toFixed(2)}   `
    + `${e.toFixed(2)}   ${onsets.toFixed(0).padStart(6)}`)
}
console.log(`pulse: bpm median ${bpm.toFixed(1)}, density median `
  + `${median(pulses.map(p => p.density)).toFixed(2)}, swing median ${median(pulses.map(p => p.swing)).toFixed(3)}`)
