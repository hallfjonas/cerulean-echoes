// Run one stem of a Strudel track offline: export its events (JSON) and render it to a WAV with superdough.
// usage: node strudel-run.mjs <track.strudel> <stemExpr> <scenario.json> <out-prefix> [--no-wav]
//   scenario: { "bpm": 124, "cycles": 8, "cc": { "5": 1, ... },
//               "events": [ { "t": 2.5, "cc": 37, "v": 1 }, { "t": 2.55, "cc": 37, "v": 0 } ] }
//   cc values are 0..1 (as midin delivers them). Events change a CC at cycle t (button presses, knob moves).
// Writes <out-prefix>.events.json (every hap with an onset: begin/end in cycles + value) and <out-prefix>.wav
// (48 kHz float stereo, no tail trimming).
import * as wa from 'node-web-audio-api'
import fs from 'fs'
import { load, run } from '../strudel-sim/harness.mjs'

Object.assign(globalThis, wa)
globalThis.window = globalThis
globalThis.addEventListener = () => {}
globalThis.document = { addEventListener() {}, dispatchEvent(e) { process.stderr.write('strudel: ' + (e.detail?.message ?? '') + '\n') } }
const out = console.log
console.log = () => {}

const [file, expr, scenFile, prefix, flag] = process.argv.slice(2)
// The track registers its own samples (keys, flute, brass …): give it superdough's samples(), and serve the
// files of our own repository from disk (its GitHub branches may not be reachable)
const sdEarly = await import('superdough')
globalThis.samples = (...a) => sdEarly.samples(...a)
const repoRoot = new URL('../../', import.meta.url).pathname
const realFetch = globalThis.fetch
globalThis.fetch = async (url, ...rest) => {
  const m = String(url).match(/raw\.githubusercontent\.com\/hallfjonas\/cerulean-echoes\/[^/]+\/(samples\/.*)$/)
  if (m) {
    const f = repoRoot + decodeURIComponent(m[1])
    if (fs.existsSync(f)) { const b = fs.readFileSync(f); return new Response(b) }
  }
  // other GitHub files (dough-samples maps, VCSL …): a disk cache, so repeated renders do not download them again
  const g = String(url).match(/^https:\/\/raw\.githubusercontent\.com\/(.*)$/)
  if (g) {
    const f = (process.env.FETCH_CACHE ?? '/tmp/strudel-fetch-cache') + '/' + decodeURIComponent(g[1])
    if (!fs.existsSync(f)) {
      const r = await realFetch(url, ...rest)
      if (!r.ok) return r
      fs.mkdirSync(f.slice(0, f.lastIndexOf('/')), { recursive: true })
      fs.writeFileSync(f, Buffer.from(await r.arrayBuffer()))
    }
    return new Response(fs.readFileSync(f))
  }
  return realFetch(url, ...rest)
}
const scen = JSON.parse(fs.readFileSync(scenFile, 'utf8'))
const vals = Object.fromEntries(Object.entries(scen.cc ?? {}).map(([k, v]) => [k, v]))
if (scen.keyEvents) vals.keyEvents = scen.keyEvents   // Launchkey keys / pads (harness midikeys)
const evs = [...(scen.events ?? [])].sort((a, b) => a.t - b.t)
// the stem plus every stateful tap, so button presses count while the stem is gated (as the master does)
const pat = (await load(file, vals, `stack(${expr}, stateTaps)`)).filterValues(v => (v.gain ?? 1) * (v.postgain ?? 1) > 0)
const cyc = scen.cycles ?? 8, cps = (scen.bpm ?? 124) / 4 / 60
let ei = 0
const haps = run(pat, 0, cyc, t => { while (ei < evs.length && evs[ei].t <= t + 1e-9) { vals[evs[ei].cc] = evs[ei].v; ei++ } })
const plain = v => Object.fromEntries(Object.entries(v).filter(([, x]) => typeof x !== 'function' && typeof x !== 'object'))
fs.writeFileSync(prefix + '.events.json', JSON.stringify(haps.map(h => ({
  b: +h.whole.begin.valueOf().toFixed(6), e: +h.whole.end.valueOf().toFixed(6), v: plain(h.value) })), null, 0))
if (flag !== '--no-wav') {
  const sd = await import('superdough')
  const sr = 48000, TAIL = 2
  const ctx = new wa.OfflineAudioContext(2, Math.ceil(sr * (cyc / cps + TAIL)), sr)
  sd.setAudioContext(ctx)
  // node-web-audio-api rejects some WAV headers browsers accept (VCSL shaker: "malformed fmt_pcm chunk"): such files
  // are re-encoded with ffmpeg (float WAV) and decoded again
  const realDecode = ctx.decodeAudioData.bind(ctx)
  ctx.decodeAudioData = async (data, ...rest) => {
    try { return await realDecode(data.slice(0), ...rest) } catch (e) {
      const { execFileSync } = await import('child_process')
      const out = execFileSync('ffmpeg', ['-v', 'quiet', '-i', 'pipe:0', '-f', 'wav', '-c:a', 'pcm_f32le', 'pipe:1'],
        { input: Buffer.from(data), maxBuffer: 1 << 30 })
      return realDecode(out.buffer.slice(out.byteOffset, out.byteOffset + out.length), ...rest)
    }
  }
  await sd.initAudio({})
  sd.registerSynthSounds()
  await sd.samples('https://raw.githubusercontent.com/felixroos/dough-samples/main/tidal-drum-machines.json')
  // strudel.cc's built-in VCSL instruments (vibraphone …)
  await sd.samples('https://raw.githubusercontent.com/felixroos/dough-samples/main/vcsl.json')
  // strudel.cc's default sample pack (Dirt-Samples: metal, space, wind … — 008's Launchkey pads)
  await sd.samples('https://raw.githubusercontent.com/tidalcycles/dirt-samples/main/strudel.json')
  // strudel.cc's General MIDI soundfonts (gm_*), as @strudel/soundfonts plays them, from the zones that
  // soundfont-extract.py wrote (sc/samples/gm): the same decoded audio SuperCollider plays; only the first preset
  const GM = { gm_vibraphone: '0110_JCLive_sf2_file', gm_marimba: '0120_JCLive_sf2_file', gm_drawbar_organ: '0160_JCLive_sf2_file',
    gm_brass_section: '0610_JCLive_sf2_file', gm_voice_oohs: '0530_Aspirin_sf2_file',
    gm_glockenspiel: '0090_JCLive_sf2_file', gm_choir_aahs: '0520_Aspirin_sf2_file' }
  const gmDir = repoRoot + 'sc/samples/'
  const zoneBuf = {}
  for (const [name, preset] of Object.entries(GM)) {
    if (!fs.existsSync(gmDir + 'gm/' + preset + '/zones.json')) continue
    const zones = JSON.parse(fs.readFileSync(gmDir + 'gm/' + preset + '/zones.json', 'utf8'))
    sd.registerSound(name, async (time, value, onended) => {
      const [attack, decay, sustain, release] = sd.getADSRValues([value.attack, value.decay, value.sustain, value.release])
      const midi = typeof value.note === 'number' ? value.note : 69 + 12 * Math.log2((value.freq ?? 440) / 440)
      const zone = zones.find(z => z.keyRangeLow <= midi && z.keyRangeHigh + 1 >= midi)
      if (!zone?.file) return
      zoneBuf[zone.file] ??= await ctx.decodeAudioData(fs.readFileSync(gmDir + zone.file).buffer.slice(0))
      const src = ctx.createBufferSource()
      src.buffer = zoneBuf[zone.file]
      const baseDetune = zone.originalPitch - 100 * zone.coarseTune - zone.fineTune
      src.playbackRate.value = Math.pow(2, (100 * midi - baseDetune) / 1200)
      if (zone.loopStart > 1 && zone.loopStart < zone.loopEnd) {
        src.loop = true; src.loopStart = zone.loopStart / zone.sampleRate; src.loopEnd = zone.loopEnd / zone.sampleRate
      }
      src.start(time)
      const envGain = ctx.createGain(), node = src.connect(envGain), holdEnd = time + value.duration
      sd.getParamADSR(node.gain, attack, decay, sustain, release, 0, 0.3, time, holdEnd, 'linear')
      src.stop(holdEnd + release + 0.01)
      src.onended = () => onended()
      return { node, stop: () => {} }
    }, { type: 'soundfont', prebake: true })
  }
  for (const h of haps) {
    const b = h.whole.begin.valueOf()
    await sd.superdough({ ...h.value }, b / cps, h.duration / cps, cps, b)
  }
  const buf = await ctx.startRendering()
  const L = buf.getChannelData(0), R = buf.getChannelData(1), n = L.length
  const wav = Buffer.alloc(44 + n * 8)
  wav.write('RIFF', 0); wav.writeUInt32LE(36 + n * 8, 4); wav.write('WAVE', 8); wav.write('fmt ', 12)
  wav.writeUInt32LE(16, 16); wav.writeUInt16LE(3, 20); wav.writeUInt16LE(2, 22); wav.writeUInt32LE(sr, 24)
  wav.writeUInt32LE(sr * 8, 28); wav.writeUInt16LE(8, 32); wav.writeUInt16LE(32, 34); wav.write('data', 36); wav.writeUInt32LE(n * 8, 40)
  for (let i = 0; i < n; i++) { wav.writeFloatLE(L[i], 44 + 8 * i); wav.writeFloatLE(R[i], 48 + 8 * i) }
  fs.writeFileSync(prefix + '.wav', wav)
}
out(JSON.stringify({ haps: haps.length }))
process.exit(0)
