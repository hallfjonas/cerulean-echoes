// Which sounds a track uses, and whether each one loads in a browser (the player tools/trajectory/player.html loads the
// same banks and soundfonts as strudel.cc, so the answer holds for both).
// The result is the sound list samples/sounds.json: `ok` (whitelist: name → where it loads from) and `broken`
// (blacklist: name → why). The sounds a track uses come from playing it in the simulator with every control moving
// (plus every Launchkey pad); a sound is checked by fetching the first byte of the file it plays, as a browser would.
// usage (in tools/): node strudel-sim/check-sounds.mjs <track.strudel> …            check online, update the list
//                    node strudel-sim/check-sounds.mjs --offline <track.strudel> …  only compare with the list
// Exit 1 if a track uses a broken sound or (offline) one the list does not know yet.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { load, run } from './harness.mjs'
import { BANKS, SOUNDFONTS, SOUNDFONT_FILES, OWN_SAMPLES } from '../trajectory/banks.mjs'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const LIST = path.join(root, 'samples', 'sounds.json')

// Superdough's synths (registerSynthSounds) and noises: no file to load
const SYNTHS = ['sine', 'square', 'triangle', 'sawtooth', 'tri', 'saw', 'sin', 'sqr', 'supersaw', 'pulse', 'user',
  'white', 'pink', 'brown', 'crackle', 'sbd', 'bytebeat', 'zzfx']

const CCS = [...Array(47).keys()].map(i => i + 5).flatMap(n => [n, n + 48])
const BUTTONS = new Set(CCS.filter(n => (n % 48 >= 37 && n % 48 <= 51) || n >= 85))
const prng = seed => () => (seed = (seed * 1664525 + 1013904223) % 4294967296) / 4294967296
const tri = x => 1 - Math.abs(((x % 2) + 2) % 2 - 1)
const ride = seed => {
  const r = prng(seed), p = Object.fromEntries(CCS.map(n => [n, [r() * 1.5 + 0.2, r() * 2]]))
  return (v, t) => {
    for (const n of CCS) {
      const [speed, phase] = p[n]
      v[n] = BUTTONS.has(n) ? ((t * speed + phase) % 1 < 0.06 ? 1 : 0) : Math.max(0, tri(t * speed + phase) * 1.4 - 0.4)
    }
  }
}

// The sounds (name and sample index n) a track plays, and the sample maps it registers itself
export async function usedSounds(file, cycles = 24) {
  const own = []
  // A sample map of this repository is read from disk (raw.githubusercontent only has it once it is pushed)
  const ownJson = url => url.startsWith(OWN_SAMPLES)
    ? JSON.parse(fs.readFileSync(path.join(root, 'samples', url.slice(OWN_SAMPLES.length)), 'utf8'))
    : fetch(url).then(r => r.json())
  globalThis.samples = async (map, base = '') => own.push(typeof map === 'string'
    ? { map: await ownJson(map), base, from: map.replace(OWN_SAMPLES, 'samples/') }
    : { map, base, from: 'the track\'s own samples()' })
  const used = new Map()
  const add = (s, n = 0) => { if (typeof s === 'string') used.set(s + ':' + n, { s, n }) }
  for (const seed of [11, 12, 13]) {
    const vals = { keys: '<[c3,e3,g3] [d3,f3,a3]>' }
    const script = ride(seed)
    script(vals, 0)
    const pat = await load(file, vals)
    for (const h of run(pat, 0, cycles, t => script(vals, t)))
      add(h.value.bank ? h.value.bank + '_' + h.value.s : h.value.s, h.value.n)
  }
  const src = fs.readFileSync(file, 'utf8')
  const shots = src.match(/const LK_SHOTS = (\[[\s\S]*?\n\])/)?.[1]
  if (shots) for (const shot of new Function('return ' + shots.replace(/^\s*\/\/.*$/gm, ''))()) add(shot.s, shot.n)
  delete globalThis.samples
  return { used: [...used.values()].sort((a, b) => a.s < b.s ? -1 : 1), own }
}

const files = v => typeof v === 'string' ? [v] : Array.isArray(v) ? v.flatMap(files) : Object.values(v).flatMap(files)
const fileOf = (entry, n) => { const list = files(entry); return list[((n % list.length) + list.length) % list.length] }

let banks = null, soundfonts = null
const loadBanks = async () => banks ??= await Promise.all(BANKS.map(url => fetch(url).then(r => r.json())
  .then(map => ({ url, map }))))
const loadSoundfonts = async () => soundfonts ??= await fetch(SOUNDFONTS + 'gm.mjs').then(r => r.text()).then(text => {
  const fonts = {}
  for (const [, name, body] of text.replace(/\/\/.*$/gm, '').matchAll(/(gm_\w+):\s*\[([^\]]*)\]/g))
    fonts[name] = [...body.matchAll(/'([^']+)'/g)].map(m => m[1])
  return fonts
})

// Where a sound plays from: the file URL (null for a synth) and its source, or null if nowhere
async function locate({ s, n }, own) {
  const key = s.toLowerCase()
  for (const { map, base, from } of [...own].reverse()) {
    const entry = Object.entries(map).find(([k]) => k.toLowerCase() === key)?.[1]
    if (entry) return { url: (map._base ?? base) + fileOf(entry, n), from }
  }
  if (SYNTHS.includes(key)) return { url: null, from: 'synth' }
  for (const { url, map } of await loadBanks()) {
    const entry = Object.entries(map).find(([k]) => k.toLowerCase() === key)?.[1]
    if (!entry) continue
    return { url: map._base + fileOf(entry, n), from: path.basename(url) }
  }
  const fonts = (await loadSoundfonts())[key]
  if (fonts) return { url: SOUNDFONT_FILES + fonts[n % fonts.length] + '.js', from: 'soundfont' }
  return null
}

// A browser can load the file: it answers, allows other origins, and has no Content-Disposition with a comma
// (raw.githubusercontent sends one for a path with a comma; Chrome: ERR_RESPONSE_HEADERS_MULTIPLE_CONTENT_DISPOSITION).
// A file of this repository is checked on disk: it loads once pushed to main.
const checked = new Map()
const loadable = url => checked.get(url) ?? checked.set(url, (async () => {
  if (url.startsWith(OWN_SAMPLES)) {
    const local = decodeURIComponent(url.slice(OWN_SAMPLES.length))
    if (local.includes(',')) return 'comma in the path: ' + url
    return fs.existsSync(path.join(root, 'samples', local)) ? null : 'missing in samples/: ' + local
  }
  try {
    const res = await fetch(url, { headers: { Range: 'bytes=0-0' } })
    if (res.status !== 200 && res.status !== 206) return 'HTTP ' + res.status + ': ' + url
    if (res.headers.get('content-disposition')?.includes(',')) return 'comma in Content-Disposition (Chrome refuses): ' + url
    if (!res.headers.get('access-control-allow-origin')) return 'no CORS header: ' + url
    return null
  } catch (e) { return e.message + ': ' + url }
})()).get(url)

async function checkOnline(file) {
  const { used, own } = await usedSounds(file)
  const result = {}
  for (const sound of used) {
    const at = await locate(sound, own)
    const err = !at ? 'unknown sound' : at.url && await loadable(at.url)
    const name = sound.n ? sound.s + ':' + sound.n : sound.s
    result[name] = err ? { broken: err } : { ok: at.from }
  }
  return result
}

const readList = () => fs.existsSync(LIST) ? JSON.parse(fs.readFileSync(LIST, 'utf8')) : { ok: {}, broken: {} }

// Offline: the sounds of a track that the list has as broken or does not know
export async function checkOffline(file) {
  const list = readList()
  const { used } = await usedSounds(file, 12)
  return used.map(({ s, n }) => n ? s + ':' + n : s).flatMap(name =>
    list.broken[name] ? [name + ' — broken: ' + list.broken[name]] : list.ok[name] ? [] : [name + ' — not checked yet'])
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const offline = process.argv.includes('--offline')
  const tracks = process.argv.slice(2).filter(a => a.endsWith('.strudel'))
  let bad = false
  if (offline) {
    for (const file of tracks) {
      const problems = await checkOffline(file)
      console.log(path.basename(file) + ': ' + (problems.length ? '\n  ' + problems.join('\n  ') : 'all sounds ok'))
      bad ||= problems.length > 0
    }
  } else {
    const list = readList()
    for (const file of tracks) {
      const result = await checkOnline(file)
      const broken = Object.entries(result).filter(([, r]) => r.broken)
      console.log(`${path.basename(file)}: ${Object.keys(result).length} sounds, ${broken.length} broken` +
        broken.map(([name, r]) => '\n  ' + name + ' — ' + r.broken).join(''))
      for (const [name, r] of Object.entries(result)) {
        delete list.ok[name]; delete list.broken[name]
        if (r.broken) list.broken[name] = r.broken
        else list.ok[name] = r.ok
      }
      bad ||= broken.length > 0
    }
    const sorted = o => Object.fromEntries(Object.entries(o).sort(([a], [b]) => a < b ? -1 : 1))
    fs.writeFileSync(LIST, JSON.stringify({
      about: 'Generated by tools/strudel-sim/check-sounds.mjs: ok = loads in a browser (where from), broken = does not ' +
        '(why). name:n = sample index n. Fix a broken bank sound with tools/strudel-sim/mirror-sound.mjs.',
      checked: new Date().toISOString().slice(0, 10), ok: sorted(list.ok), broken: sorted(list.broken) }, null, 2) + '\n')
  }
  process.exit(bad ? 1 : 0)
}
