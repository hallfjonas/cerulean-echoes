// Measure every Launchkey drum-pad one-shot of a track (LK_SHOTS) on its own, dry: loudest 400 ms block (LUFS-M) and
// peak. gm_* sounds are not available offline and print null.
// usage (in tools/): node strudel-sim/pad-levels.mjs <track.strudel> …   (SEC=16 for the long voice samples)
import * as wa from 'node-web-audio-api'
import fs from 'fs'

Object.assign(globalThis, wa)
globalThis.window = globalThis
globalThis.addEventListener = () => {}
globalThis.document = { addEventListener() {} }
const sd = await import('superdough')
const out = console.log
console.log = () => {}

const sr = 48000, SEC = Number(process.env.SEC ?? 4)
const OWN = 'https://raw.githubusercontent.com/hallfjonas/cerulean-echoes/main/samples/'
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
const jobs = []
for (const file of process.argv.slice(2)) {
  const src = fs.readFileSync(file, 'utf8')
  const shots = new Function('return ' + src.match(/const LK_SHOTS = (\[[\s\S]*?\n\])/)[1].replace(/^\s*\/\/.*$/gm, ''))()
  shots.forEach((shot, i) => jobs.push({ file, i, shot }))
}
// One context for all shots (superdough keeps its nodes per context), one shot every SEC seconds
const ctx = new wa.OfflineAudioContext(2, sr * SEC * jobs.length, sr)
sd.setAudioContext(ctx)
await sd.initAudio({})
sd.registerSynthSounds()
await sd.samples('https://raw.githubusercontent.com/felixroos/dough-samples/main/tidal-drum-machines.json')
await sd.samples('github:tidalcycles/dirt-samples')
await sd.samples('https://raw.githubusercontent.com/felixroos/dough-samples/main/vcsl.json')
await sd.samples({ brace: 'voice/brace.m4a', lw: 'voice/letzte_wiese.m4a',
  paper: 'voice/A%20piece%20of%20paper.mp3', wine: 'voice/Plaenterwald%20Wine%20and%20cheese.mp3',
  evening: 'voice/The%20Evening%20progresses.mp3', creatures: 'voice/The%20creatures%20have%20begun%20illumination.mp3',
  noend: 'voice/The%20evening%20does%20not%20end.mp3', places: 'voice/There%20are%20places%20on%20earth.mp3' }, OWN)
for (const [k, j] of jobs.entries()) if (!/^gm_/.test(j.shot.s))
  await sd.superdough({ ...j.shot, room: 0, delay: 0, orbit: 1 }, k * SEC + 0.05, Number(process.env.DUR ?? 0.5), 1, 0).catch(e => { j.err = e.message })
const buf = await ctx.startRendering()
const chans = [0, 1].map(c => kweight(buf.getChannelData(c)))
const raw = [0, 1].map(c => buf.getChannelData(c))
let last = null
for (const [k, j] of jobs.entries()) {
  if (j.file !== last) { out('== ' + j.file); last = j.file }
  const blk = 0.4 * sr, hop = 0.05 * sr, s0 = k * SEC * sr
  let mmax = 0, peak = 0
  for (let s = s0; s + blk <= s0 + SEC * sr; s += hop) {
    let e = 0
    for (const ch of chans) for (let i = s; i < s + blk; i++) e += ch[i] * ch[i]
    mmax = Math.max(mmax, e / blk)
  }
  for (const ch of raw) for (let i = s0; i < s0 + SEC * sr; i++) peak = Math.max(peak, Math.abs(ch[i]))
  const r = /^gm_/.test(j.shot.s) ? 'null (gm_* not offline)' : j.err ? 'error ' + j.err
    : mmax > 0 ? JSON.stringify({ m: +(-0.691 + 10 * Math.log10(mmax)).toFixed(1), peak: +peak.toFixed(2) }) : 'silent'
  out(String(j.i + 1).padStart(2), JSON.stringify(j.shot).padEnd(70), r)
}
process.exit(0)
