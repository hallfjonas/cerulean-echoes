// The player's link to SuperCollider: starts `sclang sc/engine.scd` when an SC track is first loaded, talks OSC with
// it (UDP 57131, the messages of sc/lib/ui.scd and sc/engine.scd; 57130 stays free for the LC view bridge of
// sc/live.scd, so both can run) and passes its state to the pages over
// Server-Sent Events. Takes over the job of sc/ui/bridge.mjs inside the player's server (one process, one port).
// The controllers never go through here: MIDI goes straight to SC, so a crash of Node or the browser stops neither
// the music nor the controllers.
//   GET  /sc/         the LC view of the SC track (sc/ui/index.html), shown in the player's MIDI panel
//   GET  /sc/events   live state: layout, ccs, cc, state, beat, midi, lk, lkcc, lknote, spectrum (48 bands 0..1), plus host
//                     ({ running, ready, track, error }); for the set view: sethistory (every set sample of this server
//                     session, sent once on connect) and setsample (each new one, every 10 s; see setSample below)
//   POST /sc/cc       [[cc, value], …] a click in the LC view, the same as a MIDI message   (own pages only)
//   POST /sc/lk       { cc: [[num, value]] } or { note: [note, velocity, chan] }             (own pages only)
//   POST /sc/load     { id } start the track (SC is started first if needed) → { track }      (own pages only)
//   POST /sc/stop     stop what plays (SC keeps running)                                      (own pages only)
// load(id, slots) also takes a stem track's slots in place of its file's ({ '1:4': stem }); swap(slot, stem) puts a stem
// on a slot of the stem track that plays → { live: true } (from the next bar) or { live: false, reason } (load it
// instead). onLoaded(id, slots) is called after every load SC answers.
// SC → here: /ce/save <json> (the Save button of a Sample Designer project) calls onSave(values); /ce/promote <slot>
// (Promote of a Stem Designer project) calls onPromote(slot).
import { spawn, execFileSync } from 'child_process'
import dgram from 'dgram'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { encode, decode } from './osc.mjs'

export const OSC_PORT = Number(process.env.CE_SC_PORT ?? 57131)
// CE_SC_PORT / CE_SC_SERVER_PORT pin the ports (taken = error); without them the link takes the first free pair from
// 57131 / 57140 up, so several player servers (worktrees, sessions) run side by side
const PORTS_PINNED = process.env.CE_SC_PORT !== undefined || process.env.CE_SC_SERVER_PORT !== undefined
const PORT_TRIES = 40
const portFree = (port, address) => new Promise(resolve => {
  const probe = dgram.createSocket('udp4')
  probe.once('error', () => resolve(false))
  probe.bind(port, address, () => probe.close(() => resolve(true)))
})
export const firstFreePort = async (from, skip = []) => {
  for (let port = from; port < from + PORT_TRIES; port++)
    if (!skip.includes(port) && await portFree(port, '127.0.0.1') && await portFree(port, '0.0.0.0')) return port
  throw new Error(`no free UDP port from ${from} to ${from + PORT_TRIES - 1}`)
}
// SC's own sound server (not the IDE's 57110, so the player and an IDE session can run side by side)
export const SERVER_PORT = Number(process.env.CE_SC_SERVER_PORT ?? 57140)
const BOOT_TIMEOUT = 60e3, LOAD_TIMEOUT = 60e3

// sclang: SCLANG in the environment (a path that does not exist, e.g. SCLANG=none, means none), else the macOS app,
// else sclang on the PATH
export const findSclang = () => {
  if (process.env.SCLANG) return fs.existsSync(process.env.SCLANG) ? process.env.SCLANG : null
  const app = '/Applications/SuperCollider.app/Contents/MacOS/sclang'
  if (fs.existsSync(app)) return app
  try { return execFileSync('which', ['sclang'], { encoding: 'utf8' }).trim() || null } catch { return null }
}

const readBody = request => new Promise((resolve, reject) => {
  let body = ''
  request.on('data', chunk => { body += chunk })
  request.on('end', () => resolve(body))
  request.on('error', reject)
})
const clamp01 = v => Math.min(1, Math.max(0, +v))
const round = (v, digits) => Math.round(v * 10 ** digits) / 10 ** digits
// a set sample from SC's /ce/setsample (sc/lib/ui.scd uiSetFrame) as the pages get it: t = when it came (ms since
// 1970), e = energy in dB (loudness power, floor -70), p = punch 0..1, x = tension 0..1, s = 64 bands 0..1 (20 Hz-20 kHz)
export const setSample = (args, t = Date.now()) => ({ t, e: round(+args[0], 2), p: round(clamp01(args[1]), 3),
  x: round(clamp01(args[2]), 3), s: args.slice(3, 67).map(v => round(clamp01(v), 3)) })

// a fast sample from /ce/setfast (every second): t (ms since 1970), e = energy in dB, g = 12 band groups 0..1
export const setFastSample = (args, t = Date.now()) => ({ t, e: round(+args[0], 2), g: args.slice(1, 13).map(v => round(clamp01(v), 3)) })
export const FAST_KEEP = 3 * 3600   // fast samples kept: 3 hours

export const createScLink = ({ repo, resolveTrack, onSave = null, onPromote = null, sclang = findSclang(), log = console.log,
  onLoaded = () => {} }) => {
  const engineFile = path.join(repo, 'sc', 'engine.scd')
  const viewFile = path.join(repo, 'sc', 'ui', 'index.html')
  let oscPort = OSC_PORT, serverPort = SERVER_PORT
  let logFile = path.join(os.tmpdir(), `cerulean-sc-engine-${oscPort}.log`)
  let sc = { address: '127.0.0.1', port: 57120 }   // learnt from SC's first message
  let child = null, bound = false, bindError = null
  const state = { layout: null, ccs: null, state: null, beat: null, midi: null, lk: null }
  const host = { running: false, ready: false, track: null, error: null }
  const clients = new Set()
  const waiters = new Set()
  // the set's history for the set view: kept for the whole server session (survives track loads and SC restarts),
  // ~720 samples for a 2-hour set
  const setHistory = [], setFast = []

  const send = (res, type, data) => res.write('data: ' + JSON.stringify({ type, data }) + '\n\n')
  const broadcast = (type, data) => { for (const res of clients) send(res, type, data) }
  const setHost = changes => { Object.assign(host, changes); broadcast('host', host) }
  // resolves with the first OSC message for which test(message) is true; rejects after ms
  const waitFor = (test, ms, what) => new Promise((resolve, reject) => {
    const waiter = { test, resolve, reject }
    waiter.timer = setTimeout(() => { waiters.delete(waiter); reject(new Error(`SuperCollider: no ${what} after ${ms / 1000} s (log: ${logFile})`)) }, ms)
    waiters.add(waiter)
  })

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
    try { m = decode(buf) } catch { return }
    sc = { address: rinfo.address, port: rinfo.port }
    const json = () => JSON.parse(m.args[0])
    switch (m.address) {
      case '/ce/ready': setHost({ running: true, ready: true, error: null }); break
      case '/ce/loaded': setHost({ track: m.args[0], error: null }); break
      case '/ce/stopped': setHost({ track: null }); break
      case '/ce/error': setHost({ error: m.args[0] }); break
      case '/ce/layout': state.layout = json(); broadcast('layout', state.layout); break
      case '/ce/ccs': state.ccs = json(); broadcast('ccs', state.ccs); break
      case '/ce/cc': queueCc(m.args[0], m.args[1]); break
      case '/ce/state': state.state = json(); broadcast('state', state.state); break
      case '/ce/beat': state.beat = { bar: m.args[0], beat: m.args[1], chord: m.args[2] }; broadcast('beat', state.beat); break
      case '/ce/midi': state.midi = json(); broadcast('midi', state.midi); break
      case '/ce/lkccs': state.lk = json(); broadcast('lk', state.lk); break
      case '/ce/lkcc': (state.lk ??= {})[m.args[0]] = m.args[1]; broadcast('lkcc', [m.args[0], m.args[1]]); break
      case '/ce/lknote': broadcast('lknote', [m.args[0], m.args[1]]); break
      case '/ce/save': onSave?.(json()); break
      case '/ce/promote': onPromote?.(String(m.args[0])); break
      // the master output's spectrum, ~20 frames a second: passed on, not kept for new pages
      case '/ce/spectrum': broadcast('spectrum', m.args.map(v => Math.round(v * 1000) / 1000)); break
      // one set sample every 10 s: kept, and passed on
      case '/ce/setsample': { const sample = setSample(m.args); setHistory.push(sample); broadcast('setsample', sample); break }
      case '/ce/setfast': { const sample = setFastSample(m.args); setFast.push(sample); if (setFast.length > FAST_KEEP) setFast.shift(); broadcast('setfast', sample); break }
    }
    for (const waiter of [...waiters]) if (waiter.test(m)) {
      clearTimeout(waiter.timer)
      waiters.delete(waiter)
      waiter.resolve(m)
    }
  })
  udp.on('error', error => { bindError = error; log(`SuperCollider link: UDP ${oscPort}: ${error.message} (a second player server running?)`) })
  const binding = (async () => {
    try {
      if (!PORTS_PINNED) oscPort = await firstFreePort(OSC_PORT)
      logFile = path.join(os.tmpdir(), `cerulean-sc-engine-${oscPort}.log`)
      await new Promise(resolve => udp.bind(oscPort, '127.0.0.1', () => { bound = true; resolve() }).once('error', resolve))
    } catch (error) { bindError = error }
  })()

  // start sclang with the engine once; resolves when SC has booted
  let starting = null
  const start = () => {
    if (host.ready) return Promise.resolve()
    if (starting) return starting
    starting = begin().finally(() => { starting = null })
    return starting
  }
  const begin = async () => {
    await binding
    if (bindError) throw new Error(`SuperCollider link: UDP ${oscPort}: ${bindError.message}`)
    if (!sclang) throw new Error('SuperCollider is not installed (no sclang found)')
    if (!PORTS_PINNED) serverPort = await firstFreePort(SERVER_PORT, [oscPort])
    const out = fs.openSync(logFile, 'w')
    child = spawn(sclang, [engineFile, String(oscPort), String(serverPort)], { cwd: path.dirname(engineFile), stdio: ['ignore', out, out] })
    fs.closeSync(out)
    setHost({ running: true, ready: false, track: null, error: null })
    log(`SuperCollider: starting (log: ${logFile})`)
    child.on('exit', code => {
      child = null
      starting = null
      setHost({ running: false, ready: false, track: null, error: code ? `sclang ended (code ${code}), log: ${logFile}` : null })
    })
    return waitFor(m => m.address === '/ce/ready', BOOT_TIMEOUT, 'boot')
  }

  const load = async (id, slots) => {
    const file = resolveTrack(id)
    if (!file) throw new Error(`no SuperCollider track '${id}'`)
    await start()
    const loaded = waitFor(m => m.address === '/ce/loaded' || m.address === '/ce/error', LOAD_TIMEOUT, 'answer to the load')
    toSc('/ce/load', file, ...slots ? [JSON.stringify(slots)] : [])
    const answer = await loaded
    if (answer.address === '/ce/error') throw new Error('SuperCollider: ' + answer.args[0])
    onLoaded(id, slots)
    return answer.args[0]
  }
  const SWAP_ANSWERS = ['/ce/swapped', '/ce/swapReload', '/ce/swapError']
  const swap = async (slot, stem) => {
    if (!host.track) throw new Error('nothing plays')
    const answered = waitFor(m => SWAP_ANSWERS.includes(m.address) && m.args[0] === slot, LOAD_TIMEOUT, 'answer to the swap')
    toSc('/ce/swap', slot, stem)
    const answer = await answered
    if (answer.address === '/ce/swapError') throw new Error('SuperCollider: ' + answer.args[1])
    return answer.address === '/ce/swapped' ? { live: true } : { live: false, reason: answer.args[1] }
  }
  const stop = () => { if (host.ready) toSc('/ce/stop') }

  // end sclang (and with it the sound server); waits up to 3 s, then kills
  const quit = () => new Promise(resolve => {
    if (!child) return resolve()
    const proc = child
    proc.once('exit', () => resolve())
    toSc('/ce/quit')
    setTimeout(() => { if (child === proc) proc.kill('SIGTERM') }, 3000).unref()
  })
  const close = async () => {
    await quit()
    if (bound) udp.close()
    for (const res of clients) res.end()
  }

  const handle = async (request, response, url, fromOwnPage) => {
    const route = url.pathname.slice('/sc'.length)
    if (request.method === 'GET' && (route === '/' || route === '')) {
      if (route === '') return response.writeHead(301, { Location: '/sc/' }).end()
      return response.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-store' })
        .end(fs.readFileSync(viewFile))
    }
    if (request.method === 'GET' && route === '/events') {
      response.writeHead(200, { 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-store', Connection: 'keep-alive' })
      response.write('retry: 1000\n\n')
      for (const k of ['layout', 'ccs', 'state', 'beat', 'midi', 'lk']) if (state[k]) send(response, k, state[k])
      send(response, 'sc', host.ready)
      send(response, 'host', host)
      send(response, 'sethistory', setHistory)
      send(response, 'setfasthistory', setFast)
      clients.add(response)
      request.on('close', () => clients.delete(response))
      if (host.ready && !state.layout) toSc('/ce/hello')
      return
    }
    if (request.method !== 'POST' || !fromOwnPage(request)) return response.writeHead(403).end('forbidden')
    const json = (status, body) => response.writeHead(status, { 'Content-Type': 'application/json' }).end(JSON.stringify(body))
    try {
      const body = await readBody(request)
      if (route === '/cc') {
        for (const [cc, v] of JSON.parse(body)) toSc('/ce/cc', { i: cc | 0 }, { f: clamp01(v) })
        return response.writeHead(204).end()
      }
      if (route === '/lk') {
        const b = JSON.parse(body)
        for (const [n, v] of b.cc ?? []) toSc('/ce/lkcc', { i: n | 0 }, { f: clamp01(v) })
        if (b.note) toSc('/ce/lknote', { i: b.note[0] | 0 }, { i: b.note[1] | 0 }, { i: b.note[2] | 0 })
        return response.writeHead(204).end()
      }
      if (route === '/load') return json(200, { track: await load(JSON.parse(body).id) })
      if (route === '/stop') { stop(); return json(200, { stopped: true }) }
      return response.writeHead(404).end('not found')
    } catch (error) {
      return json(500, { error: error.message })
    }
  }

  // keep the event streams open through proxies and sleep
  setInterval(() => { for (const res of clients) res.write(': ping\n\n') }, 15000).unref()

  return { handle, load, swap, stop, quit, close, host, state, setHistory, get logFile() { return logFile },
    get ports() { return { osc: oscPort, server: serverPort } } }
}
