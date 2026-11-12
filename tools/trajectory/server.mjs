// Local server for the trajectory page: serves this folder and relays Strudel events to every open page.
// usage (in tools/): node trajectory/server.mjs [port]   (default 8766) → open http://localhost:8766
//   POST /events  a JSON array of events from the tapped track in strudel.cc (see make-tapped.mjs)
//   GET  /stream  server-sent events: each POST body is passed on as one message
//   GET  /tapped/ the tapped tracks (make-tapped.mjs) as a JSON list, for player.html
// strudel.cc is a public https page; Chrome lets it reach localhost only with the CORS and private-network headers.
import http from 'http'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const root = path.dirname(fileURLToPath(import.meta.url))
const port = Number(process.argv[2] ?? 8766)
const TYPES = { '.html': 'text/html', '.mjs': 'text/javascript', '.js': 'text/javascript', '.wav': 'audio/wav',
  '.jsonl': 'application/x-ndjson' }
const CORS = { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type', 'Access-Control-Allow-Private-Network': 'true' }
const clients = new Set()
let received = 0

http.createServer((request, response) => {
  const url = new URL(request.url, `http://${request.headers.host}`)
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
  if (url.pathname === '/tapped/') {
    const dir = path.join(root, 'tapped')
    const files = fs.existsSync(dir) ? fs.readdirSync(dir).filter(f => f.endsWith('.strudel')).sort() : []
    return response.writeHead(200, { ...CORS, 'Content-Type': 'application/json' }).end(JSON.stringify(files))
  }
  if (url.pathname === '/stream') {
    response.writeHead(200, { ...CORS, 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache',
      Connection: 'keep-alive' })
    response.write(': connected\n\n')
    clients.add(response)
    request.on('close', () => clients.delete(response))
    return
  }
  const file = path.join(root, path.normalize(url.pathname === '/' ? '/index.html' : url.pathname))
  if (!file.startsWith(root) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    return response.writeHead(404, CORS).end('not found')
  }
  response.writeHead(200, { ...CORS, 'Content-Type': TYPES[path.extname(file)] ?? 'application/octet-stream',
    'Cache-Control': 'no-store' })
  fs.createReadStream(file).pipe(response)
}).listen(port, '127.0.0.1',
  () => console.log(`trajectory: http://localhost:${port}  (events from strudel.cc → /events)`))

setInterval(() => {
  if (received) console.log(`${received} event batches relayed to ${clients.size} page(s) in the last 10 s`)
  received = 0
}, 10000)
