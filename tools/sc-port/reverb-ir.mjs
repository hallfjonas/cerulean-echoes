// Measure the impulse response of Strudel's orbit reverb (superdough: generated noise IR in a ConvolverNode, with
// the browser's normalisation) for one room size, and write it as a stereo WAV for SuperCollider (PartConv).
// usage: node reverb-ir.mjs <roomsize> <out.wav> [sampleRate = 48000]
import * as wa from 'node-web-audio-api'
import fs from 'fs'
Object.assign(globalThis, wa)
globalThis.window = globalThis
globalThis.addEventListener = () => {}
globalThis.document = { addEventListener() {} }
console.log = () => {}
const sd = await import('superdough')
const [size, outFile] = [Number(process.argv[2]), process.argv[3]]
const sr = Number(process.argv[4] ?? 48000), T = 1, len = Math.ceil(size * 1.5 * sr) + 512
const ctx = new wa.OfflineAudioContext(2, Math.ceil(sr * T) + len, sr)
sd.setAudioContext(ctx)
await sd.initAudio({})
// a one-sample impulse as a sound
sd.registerSound('dirac', (t, value, onended) => {
  const b = ctx.createBuffer(1, 2, sr); b.getChannelData(0)[0] = 1
  const s = ctx.createBufferSource(); s.buffer = b; s.start(t)
  return { node: s, stop: () => {} }
}, { type: 'synth' })
// a first, silent note creates the orbit reverb; its IR is generated asynchronously
await sd.superdough({ s: 'dirac', gain: 0, room: 1, roomsize: size, orbit: 1 }, 0.01, 0.1, 0.5)
await new Promise(r => setTimeout(r, 1500))
await sd.superdough({ s: 'dirac', gain: 1, room: 1, roomsize: size, orbit: 1 }, T, 0.1, 0.5)
const buf = await ctx.startRendering()
const i0 = Math.round(T * sr)
const ch = [0, 1].map(c => buf.getChannelData(c).slice(i0, i0 + len))
for (const c of ch) c[0] -= 1                     // remove the dry impulse
const n = len, wav = Buffer.alloc(44 + n * 8)
wav.write('RIFF', 0); wav.writeUInt32LE(36 + n * 8, 4); wav.write('WAVE', 8); wav.write('fmt ', 12)
wav.writeUInt32LE(16, 16); wav.writeUInt16LE(3, 20); wav.writeUInt16LE(2, 22); wav.writeUInt32LE(sr, 24)
wav.writeUInt32LE(sr * 8, 28); wav.writeUInt16LE(8, 32); wav.writeUInt16LE(32, 34); wav.write('data', 36); wav.writeUInt32LE(n * 8, 40)
for (let i = 0; i < n; i++) { wav.writeFloatLE(ch[0][i], 44 + 8 * i); wav.writeFloatLE(ch[1][i], 48 + 8 * i) }
fs.writeFileSync(outFile, wav)
let e = 0; for (const c of ch) for (const v of c) e += v * v
process.stdout.write(JSON.stringify({ size, frames: n, energy: e, peak: ch[0].reduce((m, v) => Math.max(m, Math.abs(v)), 0) }) + '\n')
process.exit(0)
