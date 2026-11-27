// Local server for the player: serves this folder (the player at /) and relays Strudel events to every open page.
// usage (in tools/): node trajectory/server.mjs [port]   (default 8766) → open http://localhost:8766
//   POST /events      a JSON array of events from the tapped track, in the player or strudel.cc (see make-tapped.mjs)
//   GET  /stream      server-sent events: each POST body is passed on as one message
//   GET  /catalogue   the tracks the player can load, as a JSON list of { id, kind, label, taps, noTapReason?, scripts }
//                    (live tracks and lab boards, see catalogue.mjs; the file path is never sent)
//   GET  /stems       the stem library as JSON (stems/stem-index.mjs); filters ?role=&genre=&energy=2-4&tag=
//   GET  /track/<id>  the track's code, tapped on request from the track file as it is now (make-tapped.mjs)
//   GET  /perform/<track>/<script>   an auto-perform script (perform/<track>/<script>.json, see autoperform.mjs) or a
//                                    take (<script> = takes/<name>); only for this server's own pages (Origin / Host
//                                    checked, no CORS)
//   POST /take/<track>   the page's capture of its play, written as a take (take-save.mjs); own pages only
//   GET  /track/<id> also sends X-Track-Hash: sha1 of the track file text, kept in a take
//   POST /recording/<track>, PUT /recording/<track>/<name>, POST …/finish   audio recordings into recordings/, only
//                                    for this server's own pages (see recording.mjs)
//   GET /swap, POST /swap, /swap/revert, /track/save-as   the stem swap of a stem track that plays (stem-swap.mjs)
//   /sc/…            SuperCollider tracks: their LC view, live state, load / stop (see sc-link.mjs); sclang is
//                    started on the first SC load and ended with this server
//   /lab/sample/…    Sample Designer projects: save, save as, export (see sample-lab.mjs)
//   /lab/stems/…     Stem Designer projects: save, save as, add, replace, remove, promote, knob (see stem-lab.mjs)
//   /lab/space/…     Space Analyzer: stem tracks, one stem rendered alone and measured per band and time cell (see space-lab.mjs)
//   GET /sound-params?sample=<name>, GET /knobs   the parameters a knob can drive on that sound, the knob presets
// strudel.cc is a public https page; Chrome lets it reach localhost only with the CORS and private-network headers.
import crypto from 'crypto'
import http from 'http'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { tapSource } from './make-tapped.mjs'
import { find, scan, toPublic } from './catalogue.mjs'
import { handleTake } from './take-save.mjs'
import { handleRecording, useScLink } from './recording.mjs'
import { createScLink, findSclang } from './sc-link.mjs'
import { createSampleLab } from './sample-lab.mjs'
import { createStemLab } from './stem-lab.mjs'
import { createSpaceLab } from './space-lab.mjs'
import { repo } from './catalogue.mjs'
import { stemIndex } from '../stems/stem-index.mjs'
import { knobPresets, soundParams } from '../stems/knob.mjs'
import { createStemSwap } from './stem-swap.mjs'
import { createStemFit } from './stem-fit.mjs'

const root = path.dirname(fileURLToPath(import.meta.url))
const port = Number(process.argv[2] ?? 8766)
const PERFORM = path.join(root, 'perform')
const LOCAL_HOSTS = [`localhost:${port}`, `127.0.0.1:${port}`]
const fromOwnPage = request => LOCAL_HOSTS.includes(request.headers.host) &&
  (!request.headers.origin || LOCAL_HOSTS.some(host => request.headers.origin === 'http://' + host))
const TYPES = { '.html': 'text/html', '.mjs': 'text/javascript', '.js': 'text/javascript', '.css': 'text/css',
  '.wav': 'audio/wav', '.jsonl': 'application/x-ndjson' }
const CORS = { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type', 'Access-Control-Allow-Private-Network': 'true' }
const clients = new Set()
let received = 0
const sampleLab = createSampleLab({ getSc: () => sc })
const stemLab = createStemLab({ getSc: () => sc })
const spaceLab = createSpaceLab()
const sc = createScLink({ repo, onSave: values => sampleLab.onSave(values),
  resolveTrack: id => { const entry = find(id); return entry?.engine === 'sc' ? entry.path : null },
  onLoaded: (id, slots) => { swaps.loaded(id, slots); fits.fitOf(id).catch(() => {}) } })
const swaps = createStemSwap({ repo, find, sc })
const fits = createStemFit({ repo, find, sclang: findSclang() })
useScLink(sc)

const server = http.createServer((request, response) => {
  const url = new URL(request.url, `http://${request.headers.host}`)
  if (url.pathname.startsWith('/take/')) {
    if (!fromOwnPage(request) || request.method !== 'POST') return response.writeHead(403).end('forbidden')
    return handleTake(request, response, decodeURIComponent(url.pathname.slice('/take/'.length)))
  }
  if (url.pathname.startsWith('/perform/')) {
    if (!fromOwnPage(request) || request.method !== 'GET') return response.writeHead(403).end('forbidden')
    const [id, ...rest] = decodeURIComponent(url.pathname.slice('/perform/'.length)).split('/')
    const script = rest.join('/')
    const entry = find(id)
    if (!entry?.scripts.includes(script)) {
      return response.writeHead(404).end('not found')
    }
    return response.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' })
      .end(fs.readFileSync(path.join(PERFORM, entry.base ?? id, script + '.json')))
  }
  if (url.pathname.startsWith('/recording/')) return handleRecording(request, response, url, fromOwnPage)
  if (url.pathname === '/sc' || url.pathname.startsWith('/sc/')) return sc.handle(request, response, url, fromOwnPage)
  if (['/swap', '/swap/revert', '/track/save-as'].includes(url.pathname)) return swaps.handle(request, response, url, fromOwnPage)
  if (url.pathname.startsWith('/lab/sample/')) return sampleLab.handle(request, response, url, fromOwnPage)
  if (url.pathname.startsWith('/lab/stems/')) return stemLab.handle(request, response, url, fromOwnPage)
  if (url.pathname.startsWith('/lab/space/')) return spaceLab.handle(request, response, url, fromOwnPage)
  if (request.method === 'OPTIONS') return response.writeHead(204, CORS).end()
  if (request.method === 'POST' && url.pathname === '/events') {
    let body = ''
    request.on('data', chunk => { body += chunk })
    request.on('end', () => {
      received++
      for (const client of clients) client.write(`data: ${body}\n\n`)
      response.writeHead(204, CORS).end()
    })
    return
  }
  if (url.pathname === '/catalogue') {
    return response.writeHead(200, { ...CORS, 'Content-Type': 'application/json' })
      .end(JSON.stringify(scan().map(toPublic)))
  }
  if (url.pathname === '/stems/fit') return fits.handle(request, response, url)
  if (url.pathname === '/stems') {
    try {
      const filters = Object.fromEntries(['role', 'genre', 'energy', 'tag']
        .filter(key => url.searchParams.has(key)).map(key => [key, url.searchParams.get(key)]))
      const body = JSON.stringify(stemIndex(filters))
      return response.writeHead(200, { ...CORS, 'Content-Type': 'application/json', 'Cache-Control': 'no-store' })
        .end(body)
    } catch (error) {
      return response.writeHead(400, CORS).end(error.message)
    }
  }
  if (url.pathname === '/sound-params' || url.pathname === '/knobs') {
    try {
      const body = JSON.stringify(url.pathname === '/knobs' ? knobPresets(repo) : soundParams(url.searchParams.get('sample'), repo))
      return response.writeHead(200, { ...CORS, 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }).end(body)
    } catch (error) {
      return response.writeHead(400, CORS).end(error.message)
    }
  }
  if (url.pathname.startsWith('/track/')) {
    const id = decodeURIComponent(url.pathname.slice('/track/'.length))
    const entry = find(id)
    if (!entry) return response.writeHead(404, CORS).end('not found')
    if (entry.engine === 'sc') return response.writeHead(409, CORS).end('a SuperCollider track: the player loads it through /sc/load')
    if (!entry.taps) return response.writeHead(409, CORS).end('this entry has no master stack to tap')
    const file = entry.path
    try {
      const source = fs.readFileSync(file, 'utf8')
      const { code } = tapSource(source, path.basename(file), String(port))
      return response.writeHead(200, { ...CORS, 'Content-Type': 'text/plain', 'Cache-Control': 'no-store',
        'X-Track-Hash': crypto.createHash('sha1').update(source).digest('hex') }).end(code)
    } catch (error) {
      return response.writeHead(500, CORS).end(error.message)
    }
  }
  if (url.pathname === '/stream') {
    response.writeHead(200, { ...CORS, 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache',
      Connection: 'keep-alive' })
    response.write(': connected\n\n')
    clients.add(response)
    request.on('close', () => clients.delete(response))
    return
  }
  const file = path.join(root, path.normalize(url.pathname === '/' ? '/player.html' : url.pathname))
  if (!file.startsWith(root) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    return response.writeHead(404, CORS).end('not found')
  }
  response.writeHead(200, { ...CORS, 'Content-Type': TYPES[path.extname(file)] ?? 'application/octet-stream',
    'Cache-Control': 'no-store' })
  fs.createReadStream(file).pipe(response)
}).listen(port, '127.0.0.1',
  () => console.log(`player: http://localhost:${port}  (events from strudel.cc → /events)`))

setInterval(() => {
  if (received) console.log(`${received} event batches relayed to ${clients.size} page(s) in the last 10 s`)
  received = 0
}, 10000)

// end SuperCollider with the server (Ctrl-C or kill): no sclang / scsynth left behind
const shutdown = async () => {
  await sc.close()
  server.close()
  process.exit(0)
}
process.once('SIGINT', shutdown)
process.once('SIGTERM', shutdown)
