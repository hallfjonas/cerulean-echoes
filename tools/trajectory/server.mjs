// Local server for the player: serves this folder (the player at /) and relays Strudel events to every open page.
// usage (in tools/): node trajectory/server.mjs [port]   (default 8766) → open http://localhost:8766
//   POST /events      a JSON array of events from the tapped track, in the player or strudel.cc (see make-tapped.mjs)
//   GET  /stream      server-sent events: each POST body is passed on as one message
//   GET  /catalogue   the tracks the player can load, as a JSON list of { id, kind, label, taps, noTapReason?, scripts }
//                    (live tracks and lab boards, see catalogue.mjs; the file path is never sent)
//   GET  /track/<id>  the track's code, tapped on request from the track file as it is now (make-tapped.mjs)
//   GET  /perform/<track>/<script>   an auto-perform script (perform/<track>/<script>.json, see autoperform.mjs);
//                                    only for this server's own pages (Origin / Host checked, no CORS)
//   GET /tools, POST /run/<command>[/<id>], DELETE /run   the Tools page's whitelisted commands (see tools.mjs)
// strudel.cc is a public https page; Chrome lets it reach localhost only with the CORS and private-network headers.
import http from 'http'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { tapSource } from './make-tapped.mjs'
import { find, scan, toPublic } from './catalogue.mjs'
import { handleTools } from './tools.mjs'

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

http.createServer((request, response) => {
  const url = new URL(request.url, `http://${request.headers.host}`)
  if (url.pathname.startsWith('/perform/')) {
    if (!fromOwnPage(request) || request.method !== 'GET') return response.writeHead(403).end('forbidden')
    const [id, script, ...rest] = url.pathname.slice('/perform/'.length).split('/')
    if (rest.length || !find(id)?.scripts.includes(script)) {
      return response.writeHead(404).end('not found')
    }
    return response.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' })
      .end(fs.readFileSync(path.join(PERFORM, id, script + '.json')))
  }
  if (url.pathname === '/tools' || url.pathname === '/run' || url.pathname.startsWith('/run/')) {
    return handleTools(request, response, url, fromOwnPage)
  }
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
  if (url.pathname.startsWith('/track/')) {
    const id = decodeURIComponent(url.pathname.slice('/track/'.length))
    const entry = find(id)
    if (!entry) return response.writeHead(404, CORS).end('not found')
    if (!entry.taps) return response.writeHead(409, CORS).end('this entry has no master stack to tap')
    const file = entry.path
    try {
      const { code } = tapSource(fs.readFileSync(file, 'utf8'), path.basename(file), String(port))
      return response.writeHead(200, { ...CORS, 'Content-Type': 'text/plain', 'Cache-Control': 'no-store' }).end(code)
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
