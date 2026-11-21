// Feature tests for the shape of a Sample Designer sound: the WAV reader, the measurements on known signals, the
// one-hit audition, and (with sclang) a real render of a project. Loose checks only.
import test from 'node:test'
import assert from 'node:assert/strict'
import { findSclang } from '../trajectory/sc-link.mjs'
import { analyzeHit, hitProject, readWav, renderHit } from './sample-shape.mjs'
import { readProject } from './sample-project.mjs'

const RATE = 48000
const signal = (seconds, fn) => Float32Array.from({ length: Math.round(seconds * RATE) }, (_, i) => fn(i / RATE))
const ping = (hz, attack, decay) => signal(1.5, t => t < 0.1 ? 0
  : Math.sin(2 * Math.PI * hz * t) * Math.min(1, (t - 0.1) / attack) * Math.exp(-Math.max(0, t - 0.1 - attack) / decay))

test('a ping: attack, decay, length and its frequency are measured', () => {
  const shape = analyzeHit(ping(440, 0.02, 0.1), RATE)
  assert.ok(shape.attackMs >= 10 && shape.attackMs <= 25, `attack ${shape.attackMs}`)
  assert.ok(shape.decayMs >= 180 && shape.decayMs <= 300, `decay to -20 dB ${shape.decayMs}`)
  assert.ok(shape.lengthMs > shape.decayMs && shape.lengthMs < 900, `length ${shape.lengthMs}`)
  assert.ok(Math.abs(shape.strongestHz - 440) < 3, `strongest ${shape.strongestHz}`)
  assert.ok(shape.centroidHz > 300 && shape.centroidHz < 1500, `centroid ${shape.centroidHz}`)
  assert.ok(Math.abs(shape.onsetMs - 100) < 2)
})

test('a slow attack is slower than a fast one; a brighter sound has a higher centroid', () => {
  const fast = analyzeHit(ping(200, 0.002, 0.2), RATE), slow = analyzeHit(ping(200, 0.15, 0.2), RATE)
  assert.ok(slow.attackMs > fast.attackMs * 5)
  assert.ok(analyzeHit(ping(3000, 0.01, 0.1), RATE).centroidHz > fast.centroidHz * 4)
})

test('the pictures have their sizes and stay in range', () => {
  const shape = analyzeHit(ping(440, 0.01, 0.1), RATE)
  assert.equal(shape.waveform.length, 400)
  assert.ok(shape.waveform.every(([lo, hi]) => lo >= -1 && hi <= 1 && lo <= hi))
  assert.equal(Math.max(...shape.envelope.db), 0)
  assert.equal(shape.spectrum.hz.length, shape.spectrum.db.length)
  assert.equal(Math.max(...shape.spectrum.db), 0)
  assert.ok(shape.spectrogram.db.length > 5 && shape.spectrogram.db.every(col => col.length === 64))
})

test('silence is an error, not a shape', () => {
  assert.throws(() => analyzeHit(new Float32Array(4800), RATE), /silent/)
})

test('the WAV reader reads float and 16-bit stereo as mono', () => {
  const wav = (code, bits, values) => {
    const width = bits / 8, data = Buffer.alloc(values.length * width)
    values.forEach((v, i) => code === 3 ? data.writeFloatLE(v, i * 4) : data.writeInt16LE(Math.round(v * 32767), i * 2))
    const fmt = Buffer.alloc(24)
    fmt.write('fmt ', 0); fmt.writeUInt32LE(16, 4); fmt.writeUInt16LE(code, 8); fmt.writeUInt16LE(2, 10)
    fmt.writeUInt32LE(RATE, 12); fmt.writeUInt32LE(RATE * 2 * width, 16); fmt.writeUInt16LE(2 * width, 20)
    fmt.writeUInt16LE(bits, 22)
    const head = Buffer.alloc(20)
    head.write('RIFF', 0); head.writeUInt32LE(36 + data.length, 4); head.write('WAVE', 8)
    head.write('data', 12); head.writeUInt32LE(data.length, 16)
    return Buffer.concat([head.subarray(0, 12), fmt, head.subarray(12), data])
  }
  for (const [code, bits] of [[3, 32], [1, 16]]) {
    const { samples, sampleRate } = readWav(wav(code, bits, [0.5, 0.25, -1, 0]))
    assert.equal(sampleRate, RATE)
    assert.ok(Math.abs(samples[0] - 0.375) < 1e-3 && Math.abs(samples[1] + 0.5) < 1e-3)
  }
})

test('one hit: the first note of the picked pattern, dry, full velocity', () => {
  const project = readProject('bass-pluck')
  project.audition.pattern = 1
  const hit = hitProject(project).audition
  assert.deepEqual([hit.patterns.length, hit.pattern, hit.space, hit.accent], [1, 0, 0, 0])
  assert.equal(hit.patterns[0].notes, '33')
  assert.equal(hitProject(readProject('kick-round')).audition.patterns[0].notes, undefined)
})

const sclang = findSclang()
test('a project renders to one hit with a shape', { skip: sclang ? false : 'sclang not installed' }, async () => {
  const { samples, sampleRate } = await renderHit('kick-round', { sclang })
  const shape = analyzeHit(samples, sampleRate)
  assert.ok(shape.peakDb > -40, `peak ${shape.peakDb}`)
  assert.ok(shape.attackMs < 30, `a kick has a short attack: ${shape.attackMs}`)
  assert.ok(shape.lengthMs < 1500, `one hit, not the bar: ${shape.lengthMs}`)
})
