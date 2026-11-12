// Render one stem (or the master) offline in stereo and measure where it sits in space.
// usage: node space-render.mjs <track.strudel> <stemVariable|-> '<json cc values>' [--dry]
//   - = the master. --dry forces room and delay to 0 (for the reverb share).
// Prints one JSON line: loudness, energy per octave band (middle and side), the 125–350 Hz bass lane, side ÷ middle
// below 120 Hz and above 300 Hz, mono loss below 120 Hz, average pan. One render per process (superdough keeps its
// orbit effects per audio context).
import * as wa from 'node-web-audio-api'
import { load } from './harness.mjs'

Object.assign(globalThis, wa)
globalThis.window = globalThis
globalThis.addEventListener = () => {}
globalThis.document = { addEventListener() {} }
const sd = await import('superdough')
const out = console.log
console.log = () => {}
console.warn = () => {}

const [file, stem, json] = process.argv.slice(2)
const dry = process.argv.includes('--dry')
let pat = (await load(file, JSON.parse(json), stem === '-' ? undefined : stem))
  .filterValues(v => (v.gain ?? 1) * (v.postgain ?? 1) > 0)
if (dry) pat = pat.fmap(v => ({ ...v, room: 0, delay: 0 }))

const cps = Number(process.env.BPM ?? 140) / 4 / 60, CYC = 4, TAIL = 2, sr = 48000
const ctx = new wa.OfflineAudioContext(2, Math.ceil(sr * (CYC / cps + TAIL)), sr)
sd.setAudioContext(ctx)
await sd.initAudio({})
sd.registerSynthSounds()
await sd.samples('https://raw.githubusercontent.com/felixroos/dough-samples/main/tidal-drum-machines.json')
for (const h of pat.queryArc(0, CYC)) if (h.hasOnset()) {
  const b = h.whole.begin.valueOf()
  await sd.superdough(h.value, b / cps + 0.05, h.duration / cps, cps, b)
}
const buf = await ctx.startRendering()
const n = Math.floor(CYC / cps * sr)
const L = buf.getChannelData(0).subarray(0, n), R = buf.getChannelData(1).subarray(0, n)

// RBJ biquads, run over a whole signal
const biquad = (x, type, f, q = 0.7071) => {
  const w = 2 * Math.PI * f / sr, al = Math.sin(w) / (2 * q), c = Math.cos(w), a0 = 1 + al
  const b = type === 'lp' ? [(1 - c) / 2, 1 - c, (1 - c) / 2]
    : type === 'hp' ? [(1 + c) / 2, -(1 + c), (1 + c) / 2]
    : [al, 0, -al]
  const a1 = -2 * c / a0, a2 = (1 - al) / a0, [b0, b1, b2] = b.map(v => v / a0)
  const o = new Float32Array(x.length)
  let x1 = 0, x2 = 0, y1 = 0, y2 = 0
  for (let i = 0; i < x.length; i++) {
    const v = b0 * x[i] + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
    x2 = x1; x1 = x[i]; y2 = y1; y1 = v; o[i] = v
  }
  return o
}
const energy = x => { let e = 0; for (let i = 0; i < x.length; i++) e += x[i] * x[i]; return e / x.length }
const db = e => e > 1e-12 ? +(10 * Math.log10(e)).toFixed(1) : -120
const mid = new Float32Array(n), side = new Float32Array(n)
for (let i = 0; i < n; i++) { mid[i] = (L[i] + R[i]) / 2; side[i] = (L[i] - R[i]) / 2 }

const BANDS = [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
const bandMid  = BANDS.map(f => db(energy(biquad(mid, 'bp', f, 1.41))))
const bandSide = BANDS.map(f => db(energy(biquad(side, 'bp', f, 1.41))))
const lane = sig => biquad(biquad(biquad(biquad(sig, 'hp', 125), 'hp', 125), 'lp', 350), 'lp', 350)
const below = (sig, f) => biquad(biquad(sig, 'lp', f), 'lp', f)
const above = (sig, f) => biquad(biquad(sig, 'hp', f), 'hp', f)
const ratio = (s, m) => m > 1e-12 ? +(s / m).toFixed(3) : null

const midLow = energy(below(mid, 120)), sideLow = energy(below(side, 120))
const lowL = energy(below(L, 120)), lowR = energy(below(R, 120))
const eL = energy(L), eR = energy(R)

// BS.1770 integrated loudness (as render.mjs)
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
const kw = [kweight(L), kweight(R)]
const blk = 0.4 * sr, hop = 0.1 * sr, blocks = []
for (let s = 0; s + blk <= n; s += hop) {
  let e = 0
  for (const ch of kw) for (let i = s; i < s + blk; i++) e += ch[i] * ch[i]
  blocks.push(e / blk)
}
const LU = z => -0.691 + 10 * Math.log10(z)
const mean = a => a.reduce((s, x) => s + x, 0) / a.length
const g1 = blocks.filter(z => LU(z) > -70)
const g2 = g1.length ? g1.filter(z => LU(z) > LU(mean(g1)) - 10) : []

out(JSON.stringify({
  lufs: g2.length ? +LU(mean(g2)).toFixed(1) : null,
  energy: db(eL + eR),
  bandMid, bandSide,
  lane: db(energy(lane(mid)) + energy(lane(side))),
  sideMidLow: ratio(sideLow, midLow),
  sideMidHigh: ratio(energy(above(side, 300)), energy(above(mid, 300))),
  sideMidAll: ratio(energy(side), energy(mid)),
  monoLossLow: midLow > 1e-12 ? +(10 * Math.log10(midLow / ((lowL + lowR) / 2))).toFixed(1) : null,
  pan: eL + eR > 1e-12 ? +(eR / (eL + eR)).toFixed(3) : null,
}))
process.exit(0)
