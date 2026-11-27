// The Tracks lab's routes (own pages only, POST), read-only: the live tracks with their performances, and a track's
// tempo and controls.
//   POST /lab/tracks/tracks {}         → { tracks: [{ track, label, tempo, performances }] }
//        a performance: { name, title?, bars?, mood?, sections, steps, design, take } or { name, error } for a file that
//        does not parse; name as the catalogue lists it ('dance-floor', 'takes/<name>'), design = a design .md beside it
//   POST /lab/tracks/track  { track }  → { track, tempo, controls: [[cc, { name, button }]] }   (check-perform.mjs)
// The steps of a performance come from GET /perform/<track>/<name> (server.mjs). tempo = the `tempo` of the .track
// file (what the engine plays), null for a track without one.
import fs from 'fs'
import path from 'path'
import { scan } from './catalogue.mjs'
import { PERFORM, controlsOf, tagSource } from './check-perform.mjs'

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

export const trackInfo = track => {
  const entry = liveTracks().find(candidate => candidate.id === track)
  if (!entry) throw new Error(`no live track '${track}'`)
  return { track, tempo: tempoOf(entry), controls: [...controlsOf(tagSource(entry.path))] }
}

export const createPerformLab = () => {
  const handle = async (request, response, url, fromOwnPage) => {
    const json = (status, body) => response.writeHead(status, { 'Content-Type': 'application/json',
      'Cache-Control': 'no-store' }).end(JSON.stringify(body))
    if (request.method !== 'POST' || !fromOwnPage(request)) return response.writeHead(403).end('forbidden')
    try {
      const body = JSON.parse(await readBody(request) || '{}')
      const route = url.pathname.slice('/lab/tracks/'.length)
      if (route === 'tracks') return json(200, { tracks: listTracks() })
      if (route === 'track') return json(200, trackInfo(body.track))
      return json(404, { error: `no route ${route}` })
    } catch (error) {
      return json(400, { error: error.message })
    }
  }
  return { handle }
}
