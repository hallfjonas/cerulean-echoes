// Offline loudness of one lab-board column (superdough). Copy into tools/strudel-sim/ to run:
// BOARD=melodie3 BARS=8 K3=1 node strudel-sim/level-render.mjs <board> <column> <phrase> <progression>
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
const [file, col, pick, harm] = [process.argv[2], ...process.argv.slice(3).map(Number)]
const cps = 124 / 240, sr = 48000, BARS = +(process.env.BARS ?? 8)
globalThis.samples = sd.samples
const L = z => -0.691 + 10 * Math.log10(z)
const kweight = x => {
  const stages = [[[1.53512485958697, -2.69169618940638, 1.19839281085285], [1, -1.69065929318241, 0.73248077421585]],
                  [[1, -2, 1], [1, -1.99004745483398, 0.99007225036621]]]
  let y = x
  for (const [b, a] of stages) { const o = new Float32Array(y.length); let x1 = 0, x2 = 0, y1 = 0, y2 = 0
    for (let i = 0; i < y.length; i++) { const v = b[0] * y[i] + b[1] * x1 + b[2] * x2 - a[1] * y1 - a[2] * y2; x2 = x1; x1 = y[i]; y2 = y1; y1 = v; o[i] = v }
    y = o }
  return y
}
globalThis[process.env.BOARD] = { val: {}, held: {}, pend: { [col]: pick, harm }, at: {}, seed: {} }
const S = globalThis[process.env.BOARD]
for (let i = 5; i <= 12; i++) S.val[i] = 0
S.val[5 + col] = 1; S.val[29 + col] = +(process.env.K3 ?? 1); S.val[58] = 0; S.val[59] = 0; S.val[60] = 0
const ctx = new wa.OfflineAudioContext(2, Math.ceil(sr * (BARS / cps + 3)), sr)
sd.setAudioContext(ctx)
await sd.initAudio({}); sd.registerSynthSounds(); await sd.samples('https://raw.githubusercontent.com/felixroos/dough-samples/main/vcsl.json')
const pat = await load(file, {}, 'column(' + col + ')')
for (const h of pat.queryArc(0, BARS)) if (h.hasOnset()) await sd.superdough(h.value, h.whole.begin.valueOf() / cps + 0.05, h.duration / cps, cps, h.whole.begin.valueOf())
const buf = await ctx.startRendering()
const n = buf.length, chans = [0, 1].map(c => kweight(buf.getChannelData(c)))
const blk = 0.4 * sr, hop = 0.1 * sr, blocks = []
for (let s = 0; s + blk <= n; s += hop) { let e = 0; for (const ch of chans) for (let i = s; i < s + blk; i++) e += ch[i] * ch[i]; blocks.push(e / blk) }
const mean = a => a.reduce((s, x) => s + x, 0) / a.length
const g1 = blocks.filter(z => L(z) > -70), g2 = g1.filter(z => L(z) > L(mean(g1)) - 10)
let peak = 0; for (const c of [0, 1]) for (const v of buf.getChannelData(c)) peak = Math.max(peak, Math.abs(v))
out(JSON.stringify({ lufs: g2.length ? +L(mean(g2)).toFixed(1) : null, peak: +peak.toFixed(2), mmax: +L(Math.max(...blocks)).toFixed(1) }))
process.exit(0)
