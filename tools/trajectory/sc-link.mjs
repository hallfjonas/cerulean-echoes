// The player's link to SuperCollider: starts `sclang sc/engine.scd` when an SC track is first loaded, talks OSC with
// it (UDP 57131, the messages of sc/lib/ui.scd and sc/engine.scd; 57130 stays free for the LC view bridge of
// sc/live.scd, so both can run) and passes its state to the pages over
// Server-Sent Events. Takes over the job of sc/ui/bridge.mjs inside the player's server (one process, one port).
// The controllers never go through here: MIDI goes straight to SC, so a crash of Node or the browser stops neither
// the music nor the controllers.
//   GET  /sc/         the LC view of the SC track (sc/ui/index.html), shown in the player's MIDI panel
//   GET  /sc/events   live state: layout, ccs, cc, state, beat, midi, lk, lkcc, lknote, plus host
//                     ({ running, ready, track, error })
//   POST /sc/cc       [[cc, value], …] a click in the LC view, the same as a MIDI message   (own pages only)
//   POST /sc/lk       { cc: [[num, value]] } or { note: [note, velocity, chan] }             (own pages only)
//   POST /sc/load     { id } start the track (SC is started first if needed) → { track }      (own pages only)
//   POST /sc/stop     stop what plays (SC keeps running)                                      (own pages only)
// load(id, slots) also takes a stem track's slots in place of its file's ({ '1:4': stem }); swap(slot, stem) puts a stem
// on a slot of the stem track that plays → { live: true } (from the next bar) or { live: false, reason } (load it
// instead). onLoaded(id, slots) is called after every load SC answers.
// SC → here: /ce/save <json> (the Save button of a Sample Designer project) calls onSave(values).
import { spawn, execFileSync } from 'child_process'
import dgram from 'dgram'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { encode, decode } from './osc.mjs'

export const OSC_PORT = Number(process.env.CE_SC_PORT ?? 57131)
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

export const createScLink = ({ repo, resolveTrack, onSave = null, sclang = findSclang(), log = console.log,
  onLoaded = () => {} }) => {
  const engineFile = path.join(repo, 'sc', 'engine.scd')
  const viewFile = path.join(repo, 'sc', 'ui', 'index.html')
  const logFile = path.join(os.tmpdir(), `cerulean-sc-engine-${OSC_PORT}.log`)
  let sc = { address: '127.0.0.1', port: 57120 }   // learnt from SC's first message
  let child = null, bound = false, bindError = null
  const state = { layout: null, ccs: null, state: null, beat: null, midi: null, lk: null }
  const host = { running: false, ready: false, track: null, error: null }
  const clients = new Set()
  const waiters = new Set()

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
    }
    for (const waiter of [...waiters]) if (waiter.test(m)) {
      clearTimeout(waiter.timer)
      waiters.delete(waiter)
      waiter.resolve(m)
    }
  })
  udp.on('error', error => { bindError = error; log(`SuperCollider link: UDP ${OSC_PORT}: ${error.message} (a second player server running?)`) })
  udp.bind(OSC_PORT, '127.0.0.1', () => { bound = true })

  // start sclang with the engine once; resolves when SC has booted
  let starting = null
  const start = () => {
    if (host.ready) return Promise.resolve()
    if (starting) return starting
    if (bindError) return Promise.reject(new Error(`SuperCollider link: UDP ${OSC_PORT} is taken (${bindError.message})`))
    if (!sclang) return Promise.reject(new Error('SuperCollider is not installed (no sclang found)'))
    const out = fs.openSync(logFile, 'w')
    child = spawn(sclang, [engineFile, String(OSC_PORT), String(SERVER_PORT)], { cwd: path.dirname(engineFile), stdio: ['ignore', out, out] })
    fs.closeSync(out)
    setHost({ running: true, ready: false, track: null, error: null })
    log(`SuperCollider: starting (log: ${logFile})`)
    child.on('exit', code => {
      child = null
      starting = null
      setHost({ running: false, ready: false, track: null, error: code ? `sclang ended (code ${code}), log: ${logFile}` : null })
    })
    starting = waitFor(m => m.address === '/ce/ready', BOOT_TIMEOUT, 'boot').finally(() => { starting = null })
    return starting
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

  return { handle, load, swap, stop, quit, close, host, state, logFile }
}
