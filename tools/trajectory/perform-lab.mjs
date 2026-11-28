// The Tracks lab's routes (own pages only, POST): the live tracks with their performances, a track's tempo and
// controls, a performance opened, checked and saved.
//   POST /lab/tracks/tracks {}         → { tracks: [{ track, label, tempo, performances }] }
//        a performance: { name, title?, bars?, mood?, sections, steps, design, take } or { name, error } for a file
//        that does not parse; name as the catalogue lists it ('dance-floor', 'takes/<name>'), design = a design .md
//        beside it
//   POST /lab/tracks/track  { track }  → { track, tempo, controls: [[cc, { name, button }]] }   (check-perform.mjs)
//   POST /lab/tracks/open   { track, name }   → { script, lab?, owned, note? }
//   POST /lab/tracks/check  { track, script } → { errors }   check-perform's errors for the script
//   POST /lab/tracks/save   { track, name, script, lab }
//        → 200 { saved: true, name } | 422 { errors } | 409 { refused }
// tempo = the `tempo` of the .track file (what the engine plays), null for a track without one.
// Save writes perform/<track>/<name>.json (the script, check-perform's judge) and <name>.lab.json, the sidecar
// { format, scriptHash, lab } that keeps the sections and moves; scriptHash = sha1 of the .json text. Save never
// overwrites a script the lab did not write: a file is saved over only when its sidecar's hash still matches it. A
// script with errors is not written. Open returns the sidecar's lab only while the hash matches (owned); a script
// changed outside the lab opens from its steps, with a note.
import crypto from 'crypto'
import fs from 'fs'
import path from 'path'
import { scan } from './catalogue.mjs'
import { PERFORM, checkScript, controlsOf, tagSource } from './check-perform.mjs'

export const NAME = /^[a-z0-9][a-z0-9-]*$/
const OPEN_NAME = /^(takes\/)?[\w-]+$/
const SIDECAR_FORMAT = 1

const readBody = request => new Promise((resolve, reject) => {
  let body = ''
  request.on('data', chunk => { body += chunk })
  request.on('end', () => resolve(body))
  request.on('error', reject)
})

const liveTracks = () => scan().filter(entry => entry.kind === 'live')

const tempoOf = entry => entry.path.endsWith('.track')
  ? JSON.parse(fs.readFileSync(entry.path, 'utf8')).tempo ?? null
  : null

const performanceOf = (track, name) => {
  const file = path.join(PERFORM, track, name + '.json')
  const design = fs.existsSync(path.join(PERFORM, track, name + '.md'))
  try {
    const { title, bars, mood, sections = [], steps = [], take } = JSON.parse(fs.readFileSync(file, 'utf8'))
    return { name, title, bars, mood, sections: sections.length, steps: steps.length, design, take: Boolean(take) }
  } catch (error) {
    return { name, error: error.message }
  }
}

export const listTracks = () => liveTracks().map(entry => ({ track: entry.id, label: entry.label,
  tempo: tempoOf(entry), performances: entry.scripts.map(name => performanceOf(entry.id, name)) }))

const entryOf = track => {
  const entry = liveTracks().find(candidate => candidate.id === track)
  if (!entry) throw new Error(`no live track '${track}'`)
  return entry
}
const controlsFor = entry => controlsOf(tagSource(entry.path))

export const trackInfo = track => {
  const entry = entryOf(track)
  return { track, tempo: tempoOf(entry), controls: [...controlsFor(entry)] }
}

const hashOf = text => crypto.createHash('sha1').update(text).digest('hex')
const sidecarOf = file => file.replace(/\.json$/, '.lab.json')
const readSidecar = file => fs.existsSync(sidecarOf(file)) ? JSON.parse(fs.readFileSync(sidecarOf(file), 'utf8')) : null
const ownedBy = (file, sidecar) => sidecar?.scriptHash === hashOf(fs.readFileSync(file, 'utf8'))

export const checkPerformance = (track, script) => checkScript(script, controlsFor(entryOf(track)), track)

export const openPerformance = (track, name, dir = PERFORM) => {
  entryOf(track)
  if (!OPEN_NAME.test(name)) throw new Error(`no performance '${name}'`)
  const file = path.join(dir, track, name + '.json')
  const script = JSON.parse(fs.readFileSync(file, 'utf8'))
  const sidecar = readSidecar(file)
  if (!sidecar) return { script, owned: false }
  if (!ownedBy(file, sidecar)) {
    return { script, owned: false, note: `${name}.json was changed outside the lab: opened from its steps` }
  }
  return { script, lab: sidecar.lab, owned: true }
}

export const savePerformance = ({ track, name, script, lab }, dir = PERFORM) => {
  if (!NAME.test(name ?? '')) throw new Error('a name is lowercase letters, digits and dashes')
  entryOf(track)
  if (script?.track !== track) throw new Error(`the script is for '${script?.track}', not '${track}'`)
  const errors = checkPerformance(track, script)
  if (errors.length) return { saved: false, errors }
  const file = path.join(dir, track, name + '.json')
  if (fs.existsSync(file) && !ownedBy(file, readSidecar(file))) {
    return { saved: false, refused: `${name} exists and was not written by the lab: save it under a new name` }
  }
  const text = JSON.stringify(script, null, 2) + '\n'
  fs.mkdirSync(path.dirname(file), { recursive: true })
  fs.writeFileSync(file, text)
  fs.writeFileSync(sidecarOf(file), JSON.stringify({ format: SIDECAR_FORMAT, scriptHash: hashOf(text), lab }, null, 2)
    + '\n')
  return { saved: true, name }
}

export const createPerformLab = ({ dir = PERFORM } = {}) => {
  const handle = async (request, response, url, fromOwnPage) => {
    const json = (status, body) => response.writeHead(status, { 'Content-Type': 'application/json',
      'Cache-Control': 'no-store' }).end(JSON.stringify(body))
    if (request.method !== 'POST' || !fromOwnPage(request)) return response.writeHead(403).end('forbidden')
    try {
      const body = JSON.parse(await readBody(request) || '{}')
      const route = url.pathname.slice('/lab/tracks/'.length)
      if (route === 'tracks') return json(200, { tracks: listTracks() })
      if (route === 'track') return json(200, trackInfo(body.track))
      if (route === 'open') return json(200, openPerformance(body.track, body.name, dir))
      if (route === 'check') return json(200, { errors: checkPerformance(body.track, body.script) })
      if (route === 'save') {
        const result = savePerformance(body, dir)
        return json(result.saved ? 200 : result.errors ? 422 : 409, result)
      }
      return json(404, { error: `no route ${route}` })
    } catch (error) {
      return json(400, { error: error.message })
    }
  }
  return { handle }
}
