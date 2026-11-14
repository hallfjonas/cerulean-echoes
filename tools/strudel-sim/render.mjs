// Render one stem offline with superdough and measure its loudness.
// usage: node render.mjs <track.strudel> <stemVariable> '<json cc values>'  → prints {"lufs":…, "peak":…}
import * as wa from 'node-web-audio-api'
import { load } from './harness.mjs'

Object.assign(globalThis, wa)
globalThis.window = globalThis
globalThis.addEventListener = () => {}
globalThis.document = { addEventListener() {} }
const sd = await import('superdough')
const out = console.log
console.log = () => {}   // superdough logs every sample load

const [file, stem, json] = process.argv.slice(2)
const pat = (await load(file, JSON.parse(json), stem)).filterValues(v => (v.gain ?? 1) * (v.postgain ?? 1) > 0)

const cps = Number(process.env.BPM ?? 140) / 4 / 60, CYC = 4, TAIL = 2, sr = 48000   // BPM=70 node measure.mjs … for slower tracks
const ctx = new wa.OfflineAudioContext(2, Math.ceil(sr * (CYC / cps + TAIL)), sr)
sd.setAudioContext(ctx)
await sd.initAudio({})
sd.registerSynthSounds()
await sd.samples('https://raw.githubusercontent.com/felixroos/dough-samples/main/tidal-drum-machines.json')
await sd.samples('https://raw.githubusercontent.com/felixroos/dough-samples/main/vcsl.json')
for (const h of pat.queryArc(0, CYC)) if (h.hasOnset()) {
  const b = h.whole.begin.valueOf()
  await sd.superdough(h.value, b / cps + 0.05, h.duration / cps, cps, b)
}
const buf = await ctx.startRendering()

// BS.1770 K-weighting (48 kHz coefficients), gated integrated loudness over the CYC cycles (tail excluded)
const kweight = x => {
  const stages = [[[1.53512485958697, -2.69169618940638, 1.19839281085285], [1, -1.69065929318241, 0.73248077421585]],
                  [[1, -2, 1], [1, -1.99004745483398, 0.99007225036621]]]
  let y = x
  for (const [b, a] of stages) {
    const o = new Float32Array(y.length)
    let x1 = 0, x2 = 0, y1 = 0, y2 = 0
    for (let i = 0; i < y.length; i++) {
      const v = b[0] * y[i] + b[1] * x1 + b[2] * x2 - a[1] * y1 - a[2] * y2
      x2 = x1; x1 = y[i]; y2 = y1; y1 = v; o[i] = v
    }
    y = o
  }
  return y
}
const n = Math.floor(CYC / cps * sr)
const chans = [0, 1].map(c => kweight(buf.getChannelData(c).subarray(0, n)))
const blk = 0.4 * sr, hop = 0.1 * sr, blocks = []
for (let s = 0; s + blk <= n; s += hop) {
  let e = 0
  for (const ch of chans) for (let i = s; i < s + blk; i++) e += ch[i] * ch[i]
  blocks.push(e / blk)
}
const L = z => -0.691 + 10 * Math.log10(z)
const mean = a => a.reduce((s, x) => s + x, 0) / a.length
const g1 = blocks.filter(z => L(z) > -70)
const g2 = g1.length ? g1.filter(z => L(z) > L(mean(g1)) - 10) : []
let peak = 0
for (const c of [0, 1]) for (const v of buf.getChannelData(c)) peak = Math.max(peak, Math.abs(v))
// Extra measures for leveling by role: loudest 400 ms block (momentary max: fair for sparse hits), share of
// energy above 2 kHz (RBJ high-pass, Q 0.707, on the raw signal), and how much of the time the stem sounds at all
const hp = x => { const w = 2 * Math.PI * 2000 / sr, al = Math.sin(w) / (2 * 0.7071), c = Math.cos(w), a0 = 1 + al
  const b = [(1 + c) / 2 / a0, -(1 + c) / a0, (1 + c) / 2 / a0], a = [-2 * c / a0, (1 - al) / a0]
  const o = new Float32Array(x.length); let x1 = 0, x2 = 0, y1 = 0, y2 = 0
  for (let i = 0; i < x.length; i++) { const v = b[0] * x[i] + b[1] * x1 + b[2] * x2 - a[0] * y1 - a[1] * y2
    x2 = x1; x1 = x[i]; y2 = y1; y1 = v; o[i] = v }
  return o }
let eAll = 0, eHi = 0
for (const c of [0, 1]) { const raw = buf.getChannelData(c).subarray(0, n), h = hp(raw)
  for (let i = 0; i < n; i++) { eAll += raw[i] * raw[i]; eHi += h[i] * h[i] } }
const mmax = blocks.length ? Math.max(...blocks) : 0
out(JSON.stringify({ lufs: g2.length ? +L(mean(g2)).toFixed(1) : null, peak: +peak.toFixed(3),
  mmax: mmax > 0 ? +L(mmax).toFixed(1) : null, hf: eAll > 0 ? +(100 * eHi / eAll).toFixed(0) : null,
  dens: blocks.length ? +(100 * g1.length / blocks.length).toFixed(0) : 0 }))
process.exit(0)
