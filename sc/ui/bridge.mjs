// Bridge between the web UI and SuperCollider. No packages needed: node bridge.mjs [httpPort]
//   browser ⇄ bridge: HTTP. GET / = the LC view, GET /events = live state (Server-Sent Events), POST /cc = a click,
//   POST /lk = the Launchkey row ({ cc: [[num, value]] } or { note: [note, velocity, chan] })
//   bridge ⇄ SC: OSC over UDP. The bridge listens on 57130; SC (sclang) listens on its language port (57120).
// The Launch Controls never go through here (MIDI goes straight to SC): if the bridge or the browser stops, the
// music and the controllers go on. Reachable from a phone or tablet in the same network (address printed at start).
import http from 'http'
import dgram from 'dgram'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { fileURLToPath } from 'url'

const here = path.dirname(fileURLToPath(import.meta.url))
const HTTP_PORT = Number(process.argv[2] ?? 7770), OSC_PORT = 57130
let sc = { address: '127.0.0.1', port: 57120 }   // learnt from SC's first message

// --- OSC (int32 i, float32 f, string s) ---
const pad4 = n => (n + 3) & ~3
const oscString = s => { const b = Buffer.from(s + '\0', 'utf8'); const out = Buffer.alloc(pad4(b.length)); b.copy(out); return out }
const encode = (address, args) => {
  const tags = ',' + args.map(a => typeof a === 'string' ? 's' : Number.isInteger(a.i) ? 'i' : 'f').join('')
  return Buffer.concat([oscString(address), oscString(tags), ...args.map(a => {
    if (typeof a === 'string') return oscString(a)
    const b = Buffer.alloc(4)
    if (Number.isInteger(a.i)) b.writeInt32BE(a.i); else b.writeFloatBE(a.f)
    return b
  })])
}
const readString = (buf, at) => { const end = buf.indexOf(0, at); return [buf.toString('utf8', at, end), pad4(end + 1)] }
const decode = buf => {
  let [address, at] = readString(buf, 0), tags
  ;[tags, at] = readString(buf, at)
  const args = []
  for (const t of tags.slice(1)) {
    if (t === 'i') { args.push(buf.readInt32BE(at)); at += 4 }
    else if (t === 'f') { args.push(buf.readFloatBE(at)); at += 4 }
    else if (t === 'd') { args.push(buf.readDoubleBE(at)); at += 8 }
    else if (t === 's' || t === 'S') { const [s, next] = readString(buf, at); args.push(s); at = next }
    else if (t === 'h') { args.push(Number(buf.readBigInt64BE(at))); at += 8 }
  }
  return { address, args }
}

// --- state cache (a browser that connects gets everything at once) ---
const state = { layout: null, ccs: null, state: null, beat: null, midi: null, lk: null, sc: false }
const clients = new Set()
const broadcast = (type, data) => {
  const msg = 'data: ' + JSON.stringify({ type, data }) + '\n\n'
  for (const res of clients) res.write(msg)
}
// CC changes in batches of 25 ms (a fader sweep is many messages)
let ccBatch = {}, ccTimer = null
const queueCc = (cc, v) => {
  ccBatch[cc] = v
  if (state.ccs) state.ccs[cc] = v
  ccTimer ??= setTimeout(() => { broadcast('cc', ccBatch); ccBatch = {}; ccTimer = null }, 25)
}

const udp = dgram.createSocket('udp4')
const toSc = (address, ...args) => udp.send(encode(address, args), sc.port, sc.address)
udp.on('message', (buf, rinfo) => {
  let m
  try { m = decode(buf) } catch (e) { return }
  if (!state.sc) { state.sc = true; broadcast('sc', true) }
  sc = { address: rinfo.address, port: rinfo.port }
  const json = () => JSON.parse(m.args[0])
  switch (m.address) {
    case '/ce/layout': state.layout = json(); broadcast('layout', state.layout); break
    case '/ce/ccs': state.ccs = json(); broadcast('ccs', state.ccs); break
    case '/ce/cc': queueCc(m.args[0], m.args[1]); break
    case '/ce/state': state.state = json(); broadcast('state', state.state); break
    case '/ce/beat': state.beat = { bar: m.args[0], beat: m.args[1], chord: m.args[2] }; broadcast('beat', state.beat); break
    case '/ce/midi': state.midi = json(); broadcast('midi', state.midi); break
    case '/ce/lkccs': state.lk = json(); broadcast('lk', state.lk); break
    case '/ce/lkcc': (state.lk ??= {})[m.args[0]] = m.args[1]; broadcast('lkcc', [m.args[0], m.args[1]]); break
    case '/ce/lknote': broadcast('lknote', [m.args[0], m.args[1]]); break
  }
})
udp.on('error', e => { console.error('OSC port ' + OSC_PORT + ': ' + e.message); process.exit(1) })
udp.bind(OSC_PORT, '127.0.0.1', () => toSc('/ce/hello'))   // if SC already runs, it sends everything

const server = http.createServer((req, res) => {
  if (req.method === 'GET' && (req.url === '/' || req.url === '/index.html')) {
    res.writeHead(200, { 'content-type': 'text/html; charset=utf-8', 'cache-control': 'no-store' })
    res.end(fs.readFileSync(path.join(here, 'index.html')))
  } else if (req.method === 'GET' && req.url === '/events') {
    res.writeHead(200, { 'content-type': 'text/event-stream', 'cache-control': 'no-store', connection: 'keep-alive' })
    res.write('retry: 1000\n\n')
    for (const k of ['layout', 'ccs', 'state', 'beat', 'midi', 'lk']) if (state[k]) res.write('data: ' + JSON.stringify({ type: k, data: state[k] }) + '\n\n')
    res.write('data: ' + JSON.stringify({ type: 'sc', data: state.sc }) + '\n\n')
    clients.add(res)
    req.on('close', () => clients.delete(res))
    if (!state.layout) toSc('/ce/hello')
  } else if (req.method === 'POST' && req.url === '/cc') {
    let body = ''
    req.on('data', d => { body += d })
    req.on('end', () => {
      try {
        for (const [cc, v] of JSON.parse(body)) toSc('/ce/cc', { i: cc | 0 }, { f: Math.min(1, Math.max(0, +v)) })
        res.writeHead(204); res.end()
      } catch (e) { res.writeHead(400); res.end(String(e)) }
    })
  } else if (req.method === 'POST' && req.url === '/lk') {
    let body = ''
    req.on('data', d => { body += d })
    req.on('end', () => {
      try {
        const b = JSON.parse(body)
        for (const [n, v] of b.cc ?? []) toSc('/ce/lkcc', { i: n | 0 }, { f: Math.min(1, Math.max(0, +v)) })
        if (b.note) toSc('/ce/lknote', { i: b.note[0] | 0 }, { i: b.note[1] | 0 }, { i: b.note[2] | 0 })
        res.writeHead(204); res.end()
      } catch (e) { res.writeHead(400); res.end(String(e)) }
    })
  } else { res.writeHead(404); res.end() }
})
// SC stopped? Mark it after 3 s without a beat
setInterval(() => { if (state.sc && state.lastSeen && Date.now() - state.lastSeen > 3000) { state.sc = false; broadcast('sc', false) } }, 1000)
udp.on('message', () => { state.lastSeen = Date.now() })
// keep the event streams open through proxies and sleep
setInterval(() => { for (const res of clients) res.write(': ping\n\n') }, 15000)

server.on('error', e => { console.error('HTTP port ' + HTTP_PORT + ': ' + e.message + ' (a bridge already running?)'); process.exit(1) })
server.listen(HTTP_PORT, '0.0.0.0', () => {
  const lan = Object.values(os.networkInterfaces()).flat().filter(a => a && a.family === 'IPv4' && !a.internal).map(a => a.address)
  console.log('LC view: http://localhost:' + HTTP_PORT + lan.map(a => '  ·  phone/tablet: http://' + a + ':' + HTTP_PORT).join(''))
})
