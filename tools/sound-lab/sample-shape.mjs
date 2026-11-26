// The shape of a Sample Designer sound: one hit rendered dry with sc/tools/render.scd, then measured.
//   renderHit(name, { values, sclang })  → { samples: Float32Array (mono), sampleRate }
// Times in ms from the onset (first sample above -40 dB of the peak); the envelope is RMS over 10 ms, attack = 10 → 90 %
// of its peak, decay = its peak → -20 dB, length = until -60 dB; peakMs = where the envelope peaks.
//   analyzeHit(samples, sampleRate)      → { peakDb, attackMs, decayMs, lengthMs, centroidHz, strongestHz,
//                                            waveform: [[min, max] …], envelope: { stepMs, db: […] },
//                                            spectrum: { hz: […], db: […] }, spectrogram: { stepMs, hz: […], db: [[…] …] } }
// One hit = the first note of the audition pattern that is picked, on beat 1, at full velocity, Space 0; the rest of
// the render (two bars) is its tail. Numbers are measurements of the render, not a judgement of the sound.
import fs from 'fs'
import os from 'os'
import path from 'path'
import { execFile } from 'child_process'
import { promisify } from 'util'
import { applyValues, projectErrors, projectFile, readProject, repoRoot } from './sample-project.mjs'

const FLOOR_DB = -90
const db = x => x > 0 ? Math.max(FLOOR_DB, 20 * Math.log10(x)) : FLOOR_DB
const round = (x, digits = 1) => Math.round(x * 10 ** digits) / 10 ** digits

export function hitProject(project) {
  const audition = project.audition
  const picked = audition.patterns[audition.pattern] ?? audition.patterns[0]
  const firstNote = picked.notes?.match(/-?\d+(\.\d+)?/)?.[0]
  const hit = { label: 'one hit', rhythm: '<[x ~ ~ ~] ~>', ...firstNote && { notes: firstNote } }
  return { ...project, audition: { ...audition, pattern: 0, accent: 0, space: 0, patterns: [hit] } }
}

export function readWav(buffer) {
  const { channels, sampleRate } = readWavChannels(buffer)
  const samples = new Float32Array(channels[0].length)
  for (let i = 0; i < samples.length; i++) {
    let sum = 0
    for (const channel of channels) sum += channel[i]
    samples[i] = sum / channels.length
  }
  return { samples, sampleRate }
}

export function readWavChannels(buffer) {
  if (buffer.toString('ascii', 0, 4) !== 'RIFF' || buffer.toString('ascii', 8, 12) !== 'WAVE') {
    throw new Error('not a WAV file')
  }
  let at = 12
  let format = null
  while (at + 8 <= buffer.length) {
    const id = buffer.toString('ascii', at, at + 4)
    const size = buffer.readUInt32LE(at + 4)
    const body = at + 8
    if (id === 'fmt ') {
      format = { code: buffer.readUInt16LE(body), channels: buffer.readUInt16LE(body + 2),
        sampleRate: buffer.readUInt32LE(body + 4), bits: buffer.readUInt16LE(body + 14) }
      if (format.code === 0xfffe) format.code = buffer.readUInt16LE(body + 24)
    } else if (id === 'data') {
      if (!format) throw new Error('WAV: data before fmt')
      const { code, channels, bits, sampleRate } = format
      const width = bits / 8
      const frames = Math.floor(Math.min(size, buffer.length - body) / (width * channels))
      const read = code === 3 ? (o => buffer.readFloatLE(o))
        : bits === 16 ? (o => buffer.readInt16LE(o) / 32768)
          : bits === 24 ? (o => buffer.readIntLE(o, 3) / 8388608)
            : bits === 32 ? (o => buffer.readInt32LE(o) / 2147483648) : null
      if (!read) throw new Error(`WAV: ${bits}-bit format ${code} not supported`)
      const data = Array.from({ length: channels }, () => new Float32Array(frames))
      for (let i = 0; i < frames; i++) {
        for (let c = 0; c < channels; c++) data[c][i] = read(body + (i * channels + c) * width)
      }
      return { channels: data, sampleRate }
    }
    at = body + size + (size % 2)
  }
  throw new Error('WAV: no data chunk')
}

export async function renderHit(name, { values = null, sclang, root = repoRoot } = {}) {
  if (!sclang) throw new Error('sclang not found: the shape needs a render')
  const project = hitProject(applyValues(readProject(name, root), values))
  const errors = projectErrors(project, projectFile(name, root), root)
  if (errors.length) throw new Error(`${name}: ${errors.join('; ')}`)
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'sample-shape-'))
  try {
    const scenario = path.join(temp, 'scenario.json')
    fs.writeFileSync(scenario, JSON.stringify({ cycles: 2 }))
    const projectPath = path.join(temp, `${name}.sample.json`)
    fs.writeFileSync(projectPath, JSON.stringify(project))
    const render = path.join(root, 'sc', 'tools', 'render.scd')
    const run = await promisify(execFile)(sclang, [render, projectPath, scenario, path.join(temp, 'out')],
      { encoding: 'utf8', timeout: 120e3 }).catch(error => error)
    const wav = path.join(temp, 'out.wav')
    if (!fs.existsSync(wav)) {
      const why = `${run.stdout}\n${run.stderr}`.split('\n').filter(l => /ERROR|Error/.test(l)).slice(0, 3).join(' ')
      throw new Error(`render failed: ${why || 'no WAV'}`)
    }
    return readWav(fs.readFileSync(wav))
  } finally {
    fs.rmSync(temp, { recursive: true, force: true })
  }
}

export function fft(re, im) {
  const n = re.length
  for (let i = 1, j = 0; i < n; i++) {
    let bit = n >> 1
    for (; j & bit; bit >>= 1) j ^= bit
    j ^= bit
    if (i < j) { [re[i], re[j]] = [re[j], re[i]]; [im[i], im[j]] = [im[j], im[i]] }
  }
  for (let size = 2; size <= n; size <<= 1) {
    const step = -2 * Math.PI / size
    for (let start = 0; start < n; start += size) {
      for (let k = 0; k < size / 2; k++) {
        const cos = Math.cos(step * k), sin = Math.sin(step * k)
        const a = start + k, b = a + size / 2
        const tr = re[b] * cos - im[b] * sin, ti = re[b] * sin + im[b] * cos
        re[b] = re[a] - tr; im[b] = im[a] - ti
        re[a] += tr; im[a] += ti
      }
    }
  }
}

export function magnitudes(samples, from, size) {
  const re = new Float64Array(size), im = new Float64Array(size)
  for (let i = 0; i < size; i++) {
    const x = samples[from + i] ?? 0
    re[i] = x * (0.5 - 0.5 * Math.cos(2 * Math.PI * i / (size - 1)))
  }
  fft(re, im)
  const out = new Float64Array(size / 2)
  for (let i = 0; i < size / 2; i++) out[i] = Math.hypot(re[i], im[i]) * 4 / size
  return out
}

export const logPoints = (count, lo = 20, hi = 20000) =>
  Array.from({ length: count }, (_, i) => lo * (hi / lo) ** (i / (count - 1)))

// highest magnitude between neighbouring log points: thin peaks stay visible on a log axis
export const onLogAxis = (mags, binHz, points) => points.map((hz, i) => {
  const lo = Math.max(1, Math.floor((i ? Math.sqrt(points[i - 1] * hz) : hz) / binHz))
  const hi = Math.min(mags.length - 1, Math.max(lo, Math.ceil((i < points.length - 1 ? Math.sqrt(points[i + 1] * hz) : hz) / binHz)))
  let max = 0
  for (let b = lo; b <= hi; b++) max = Math.max(max, mags[b])
  return max
})

export function analyzeHit(samples, sampleRate) {
  const ms = n => n * 1000 / sampleRate
  let peak = 0
  for (let i = 0; i < samples.length; i++) peak = Math.max(peak, Math.abs(samples[i]))
  if (peak === 0) throw new Error('the render is silent')
  const onset = samples.findIndex(x => Math.abs(x) >= peak * 0.01)

  // loudness per millisecond: RMS over 10 ms around it, so a click of a few samples does not count as the peak
  const frame = Math.round(sampleRate / 1000)
  const power = []
  for (let i = onset; i < samples.length; i += frame) {
    let sum = 0
    for (let j = i; j < Math.min(i + frame, samples.length); j++) sum += samples[j] * samples[j]
    power.push(sum / frame)
  }
  const env = power.map((_, i) => {
    const from = Math.max(0, i - 5), to = Math.min(power.length, i + 5)
    let sum = 0
    for (let k = from; k < to; k++) sum += power[k]
    return Math.sqrt(sum / (to - from))
  })
  const envPeak = Math.max(...env)
  const envPeakAt = env.indexOf(envPeak)
  const firstAbove = level => env.findIndex(x => x >= envPeak * level)
  const attackMs = Math.max(0, firstAbove(0.9) - firstAbove(0.1))
  const fallTo = factor => { const i = env.findIndex((x, k) => k > envPeakAt && x < envPeak * factor); return i < 0 ? env.length : i }
  const decayMs = fallTo(0.1) - envPeakAt
  let last = env.length - 1
  while (last > 0 && env[last] < envPeak * 0.001) last--
  const lengthMs = last + 1

  const span = Math.min(samples.length - onset, Math.max(Math.round(lengthMs * 1.1 * frame), frame * 20))
  const columns = 400
  const waveform = Array.from({ length: columns }, (_, c) => {
    const from = onset + Math.floor(c * span / columns), to = onset + Math.floor((c + 1) * span / columns)
    let lo = 0, hi = 0
    for (let i = from; i < Math.max(to, from + 1); i++) { lo = Math.min(lo, samples[i] ?? 0); hi = Math.max(hi, samples[i] ?? 0) }
    return [round(lo / peak, 3), round(hi / peak, 3)]
  })
  const spanFrames = Math.min(env.length, Math.ceil(span / frame))
  const stepMs = Math.max(1, Math.ceil(spanFrames / 400))
  const envelope = { stepMs, db: [] }
  for (let i = 0; i < spanFrames; i += stepMs) {
    envelope.db.push(round(db(Math.max(...env.slice(i, i + stepMs)) / envPeak)))
  }

  const size = 8192
  const mags = magnitudes(samples, onset, size)
  const binHz = sampleRate / size
  let weighted = 0, total = 0, strongest = 1
  for (let b = 1; b < mags.length; b++) {
    const hz = b * binHz
    if (hz < 20 || hz > 20000) continue
    weighted += hz * mags[b]; total += mags[b]
    if (mags[b] > mags[strongest]) strongest = b
  }
  // between bins: the parabola through the strongest bin and its neighbours (dB) puts the peak where it is
  const [a, m, c] = [mags[strongest - 1], mags[strongest], mags[strongest + 1] ?? 0].map(v => db(v))
  const shift = a - 2 * m + c ? Math.max(-0.5, Math.min(0.5, 0.5 * (a - c) / (a - 2 * m + c))) : 0
  const specHz = logPoints(160)
  const specMags = onLogAxis(mags, binHz, specHz)
  const specMax = Math.max(...specMags)

  const gramSize = 1024, hop = 512, gramHz = logPoints(64, 30, 16000)
  const gram = []
  for (let from = onset; from < onset + span && gram.length < 300; from += hop) {
    gram.push(onLogAxis(magnitudes(samples, from, gramSize), sampleRate / gramSize, gramHz))
  }
  const gramMax = Math.max(...gram.flat())

  return {
    peakDb: round(db(peak)), attackMs: round(attackMs), decayMs: round(decayMs), lengthMs: round(lengthMs),
    centroidHz: Math.round(total ? weighted / total : 0), strongestHz: round((strongest + shift) * binHz),
    onsetMs: round(ms(onset)), peakMs: envPeakAt, spanMs: round(ms(span)),
    waveform, envelope,
    spectrum: { hz: specHz.map(h => Math.round(h)), db: specMags.map(m => round(db(m / specMax))) },
    spectrogram: { stepMs: round(ms(hop)), hz: gramHz.map(h => Math.round(h)),
      db: gram.map(col => col.map(m => Math.round(db(m / gramMax)))) },
  }
}
