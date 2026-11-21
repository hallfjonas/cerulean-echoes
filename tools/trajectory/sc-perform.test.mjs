// Feature tests for auto-perform and takes on SuperCollider tracks, against the player's server with SC (skipped where
// sclang is not installed). Loose: steps reach SC and come back as its state, scripts end, a take saves and replays.
// Master fader forced to 0: every request this test sends to SC drops CC 12 and its Mode 2 alias 60 (the scripts
// raise the master), so nothing sounds; everything is checked through SC's state echoes (/sc/events), not audio.
//   1. every script of every ported track (perform/<id>/*.json) plays to its end on the SC track, on a fast test clock
//      (SC plays at its own tempo, the script runs through in seconds): every step is sent, and SC holds what was sent
//   2. the real bar clock (engine-sc.mjs cycle() from SC's beats): beat to beat it is off by far less than half a bar,
//      a press half a bar before a bar line takes over on that bar line, the script's bar 0 is in place at the load
//   3. a take: a short "hardware" play (CCs, a press, a pad, a key) saved through POST /take, then replayed from its
//      script on the same SC track and saved again, which runs the replay check
import assert from 'node:assert/strict'
import { spawn } from 'child_process'
import fs from 'fs'
import path from 'path'
import test from 'node:test'
import { fileURLToPath } from 'url'
import { compile, createPerformer } from './autoperform.mjs'
import { findSclang } from './sc-link.mjs'
import { createScAuto, createScTap } from './sc-auto.mjs'
import { createRecorder } from './take.mjs'

const here = path.dirname(fileURLToPath(import.meta.url))
const PERFORM = path.join(here, 'perform')
const PORT = 8793, OSC = 57181, SERVER = 57182
const base = `http://localhost:${PORT}`
const MASTER = [12, 60]
const FAST_BARS_PER_SECOND = 24
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms))
const near = (a, b) => Math.abs(a - b) < 1e-3
// column 8's Mode 2 CCs share the bus (and the echo) of its Mode 1 CCs (sc/tracks/*: aliases)
const ALIASES = new Map([20, 28, 36, 12, 44, 52].map(cc => [cc + 48, cc]))
const alias = cc => ALIASES.get(cc) ?? cc

// what this test sends to SC: never the master
const quiet = (route, body) => route === 'cc' ? body.filter(([cc]) => !MASTER.includes(cc))
  : route === 'load' ? { ...body, cc: (body.cc ?? []).filter(([cc]) => !MASTER.includes(cc)) } : body
const post = (route, body) => fetch(`${base}/sc/${route}`, { method: 'POST', headers: { Origin: base },
  body: JSON.stringify(quiet(route, body)) }).then(async response => {
  if (!response.ok) throw new Error(`${route}: ${response.status} ${await response.text()}`)
  return response.status === 204 ? null : response.json()
})

// Server-sent events over fetch (Node has no EventSource): onEvent({ type, data }) per message; returns the abort
const streams = []
const listen = (url, onData) => {
  const abort = new AbortController()
  streams.push(abort)
  fetch(base + url, { signal: abort.signal }).then(async response => {
    const decoder = new TextDecoder()
    let buffer = ''
    for await (const chunk of response.body) {
      buffer += decoder.decode(chunk, { stream: true })
      let at
      while ((at = buffer.indexOf('\n\n')) >= 0) {
        const data = buffer.slice(0, at).split('\n').find(line => line.startsWith('data: '))
        buffer = buffer.slice(at + 2)
        if (data) onData(data.slice(6))
      }
    }
  }).catch(() => {})
  return abort
}

// SC's state as the echoes tell it: LC CCs (aliased), Launchkey CCs, pattern rows, keys played; from(mark) = since then
const createEcho = () => {
  const events = []
  listen('/sc/events', data => events.push({ ...JSON.parse(data), at: performance.now() }))
  const stateSince = mark => {
    const slice = events.slice(mark)
    const lastCcs = slice.findLastIndex(e => e.type === 'ccs'), lastLk = slice.findLastIndex(e => e.type === 'lk')
    const cc = new Map(Object.entries(slice[lastCcs]?.data ?? {}).map(([n, v]) => [Number(n), v]))
    const lk = new Map(Object.entries(slice[lastLk]?.data ?? {}).map(([n, v]) => [Number(n), v]))
    slice.forEach((e, i) => {
      if (e.type === 'cc' && i > lastCcs) for (const [n, v] of Object.entries(e.data)) cc.set(Number(n), v)
      if (e.type === 'lkcc' && i > lastLk) lk.set(e.data[0], e.data[1])
    })
    return { cc, lk, notes: slice.filter(e => e.type === 'lknote').length }
  }
  const waitFor = async (testEvent, mark, ms = 15000) => {
    for (const end = Date.now() + ms; Date.now() < end; await sleep(50)) {
      const hit = events.slice(mark).find(testEvent)
      if (hit) return hit
    }
    return null
  }
  return { events, mark: () => events.length, stateSince, waitFor }
}

// The page's environment for engine-sc.mjs in Node: EventSource and fetch with the page's relative URLs
const pageGlobals = () => {
  const realFetch = globalThis.fetch
  globalThis.fetch = (url, options = {}) => realFetch(new URL(url, base + '/'), { ...options,
    headers: { ...options.headers, Origin: base } })
  globalThis.EventSource = class {
    constructor(url) { listen('/' + url, data => this.onmessage?.({ data })) }
  }
  return () => { globalThis.fetch = realFetch; delete globalThis.EventSource }
}

// a promise that a performer's onChange(null) resolves through done.resolve
const whenDone = done => new Promise(resolve => { done.resolve = resolve })

test('auto-perform and takes on SuperCollider tracks', { skip: findSclang() ? false : 'sclang not installed', timeout: 900e3 }, async t => {
  const server = spawn(process.execPath, [path.join(here, 'server.mjs'), String(PORT)],
    { env: { ...process.env, CE_SC_PORT: String(OSC), CE_SC_SERVER_PORT: String(SERVER) }, stdio: 'ignore' })
  const restore = pageGlobals()
  try {
    for (let i = 0; i < 50; i++) {
      try { if ((await fetch(base + '/catalogue')).ok) break } catch {}
      await sleep(100)
    }
    const catalogue = await (await fetch(base + '/catalogue')).json()
    const echo = createEcho()

    await t.test('every script of every ported track plays to its end, its steps reach SC', async () => {
      const runs = catalogue.filter(entry => entry.engine === 'sc')
        .flatMap(entry => entry.scripts.filter(id => !id.startsWith('takes/')).map(id => [entry.id, id]))
      assert.ok(runs.length >= 10, `scripts of the ported tracks: ${runs.length}`)
      for (const [track, id] of runs) {
        const script = JSON.parse(fs.readFileSync(path.join(PERFORM, track, id + '.json'), 'utf8'))
        const compiled = compile(script)
        const sent = []
        const auto = createScAuto({ post: (route, body) => { sent.push([route, quiet(route, body)]); return post(route, body) },
          onError: error => sent.push(['error', error.message]) })
        let start = null, endBar = 0
        const done = {}
        const finished = whenDone(done)
        const engine = { cycle: () => start === null ? 0 : (performance.now() - start) / 1000 * FAST_BARS_PER_SECOND }
        const performer = createPerformer({ midi: auto, engine, onChange: progress => {
          if (!progress) { endBar = engine.cycle(); done.resolve() }
        } })
        auto.hold()
        performer.prime(script)
        const mark = echo.mark()
        const init = quiet('load', auto.loadInit())
        sent.push(['load', init])
        assert.deepEqual(await post('load', { id: track, ...init }), { track })
        auto.live()
        start = performance.now()
        performer.start(script)
        await finished
        await auto.idle()
        await sleep(500)
        const at = `${track}/${id}`
        assert.ok(endBar >= compiled.end, `${at}: played to bar ${endBar} of ${compiled.end}`)
        assert.deepEqual(sent.filter(([route]) => route === 'error'), [], `${at}: every request answered`)
        // every step was sent: each control's last value is the script's last value, every press and note went out
        const ccsSent = sent.flatMap(([route, body]) => route === 'cc' ? body : route === 'load' ? body.cc : [])
        const lkSent = sent.flatMap(([route, body]) => route === 'lk' ? body.cc : route === 'load' ? body.lk : [])
        const notesSent = sent.filter(([route, body]) => route === 'lk' && body.note).length
        for (const [cc, curve] of compiled.curves) {
          if (MASTER.includes(cc)) continue
          const value = Math.round(curve.at(-1).to * 127) / 127
          assert.ok(near(ccsSent.findLast(([n]) => n === cc)?.[1] ?? 0, value), `${at}: cc ${cc} ends on ${value}`)
        }
        for (const [number, curve] of compiled.lkCurves)
          assert.ok(near(lkSent.findLast(([n]) => n === number)?.[1] ?? 0, Math.round(curve.at(-1).to * 127) / 127),
            `${at}: lk ${number}`)
        for (const { cc } of compiled.presses) assert.ok(ccsSent.some(([n, v]) => n === cc && v === 1), `${at}: press ${cc}`)
        assert.equal(notesSent, compiled.notes.reduce((sum, n) => sum + n.notes.length, 0), `${at}: every key and pad`)
        assert.ok(!ccsSent.some(([cc]) => MASTER.includes(cc)), 'the master is never sent')
        // SC holds what was sent (its echoes), keys and pads came back one by one, the master stayed at 0
        const state = echo.stateSince(mark)
        const lastSent = new Map(ccsSent.map(([cc, v]) => [alias(cc), v]))
        for (const [cc, value] of lastSent) assert.ok(near(state.cc.get(cc) ?? 0, value), `${at}: SC holds cc ${cc} = ${value} (has ${state.cc.get(cc)})`)
        for (const [number, value] of new Map(lkSent)) assert.ok(near(state.lk.get(number) ?? 0, value), `${at}: SC holds lk ${number}`)
        assert.equal(state.notes, notesSent, `${at}: SC played every key and pad`)
        assert.equal(state.cc.get(12) ?? 0, 0, 'the master stays at 0')
        t.diagnostic(`${at}: ${script.steps.length} steps, ${Math.ceil(compiled.end)} bars, ${sent.length} requests`)
      }
    })

    await t.test('the bar clock from SC: precise beat to beat, a press half a bar early takes over on the bar line', async () => {
      const { createScEngine } = await import('./engine-sc.mjs')
      const beats = [], rows = []
      let engine, loaded = false
      engine = createScEngine({ onEvent: (type, data) => {
        if (type === 'beat' && loaded) beats.push({ beat: data.bar * 4 + data.beat, at: performance.now() })
        if (type === 'state' && data?.rows?.['jojo:1']) rows.push({ now: data.rows['jojo:1'][0], bar: engine.cycle() })
        if (type === 'cc' && data['13'] !== undefined) rows.push({ cc13: data['13'], bar: engine.cycle() })
      } })
      const auto = createScAuto({ post })
      const done = {}
      const finished = whenDone(done)
      const performer = createPerformer({ midi: auto, engine, onChange: progress => { if (!progress) done.resolve() } })
      const script = { track: '009-house', steps: [{ bar: 0, cc: 13, value: 0.3 }, { bar: 1.5, press: 37 },
        { bar: 2, cc: 13, value: 0.7, ramp: 1 }, { bar: 6, cc: 13, value: 0.7 }] }
      auto.hold()
      performer.prime(script)
      const mark = echo.mark()
      await engine.load('009-house', quiet('load', auto.loadInit()))
      loaded = true
      auto.live()
      performer.start(script)
      await finished
      // bar 0 of the script was set by the load: SC's controls at the load already hold it
      const ccs = echo.events.slice(mark).findLast(e => e.type === 'ccs')
      assert.ok(near(ccs?.data[13] ?? 0, 0.3) || near(echo.stateSince(mark).cc.get(13), 0.3), 'bar 0 arrives with the load')
      // beat to beat: where the clock had got to when the next beat came, against that beat (the jump it makes)
      const bps = 124 / 60
      const jumps = beats.slice(1).map((b, i) => Math.abs((b.beat - beats[i].beat) - (b.at - beats[i].at) / 1000 * bps) / 4)
      const worst = Math.max(...jumps)
      t.diagnostic(`clock: ${beats.length} beats, worst jump ${(worst * 1000).toFixed(1)} thousandths of a bar ` +
        `(${(worst * 4 * 60 / 124 * 1000).toFixed(1)} ms)`)
      assert.ok(beats.length >= 20, `beats heard: ${beats.length}`)
      assert.ok(worst < 0.02, `the clock jumps at most 0.02 bar at a beat (worst ${worst.toFixed(4)})`)
      // the press at bar 1.5 is shown at once as 'next' and takes over on bar 2 (SC switches its latch when it makes
      // bar 2's notes, s.latency before they sound: the state comes a little before bar 2 on the page's clock)
      const first = rows.filter(r => r.now !== undefined && r.bar < 1).at(-1)
      const switched = rows.find(r => r.now !== undefined && r.bar >= 1 && r.now !== first.now)
      assert.ok(switched, 'the pattern switched')
      t.diagnostic(`press at bar 1.5: pattern switched at page bar ${switched.bar.toFixed(3)}`)
      assert.ok(switched.bar > 1.5 && switched.bar < 2.1, `it takes over on bar 2 (at ${switched.bar.toFixed(3)})`)
      // the ramp from bar 2: its first value comes back at bar 2 on the page's clock
      const ramp = rows.find(r => r.cc13 !== undefined && r.cc13 > 0.31)
      t.diagnostic(`ramp from bar 2: first value back at page bar ${ramp.bar.toFixed(3)}`)
      assert.ok(ramp.bar >= 2 && ramp.bar < 2.15, `the ramp starts at bar 2 (${ramp.bar.toFixed(3)})`)
      engine.stop()
    })

    await t.test('a take saves and replays on an SC track', async () => {
      const { createScEngine } = await import('./engine-sc.mjs')
      const track = '009-house'
      const takes = path.join(PERFORM, track, 'takes'), hadTakes = fs.existsSync(takes)
      const written = []
      const hardware = new Set()
      const auto = createScAuto({ post })
      let tap = null
      const engine = createScEngine({ onEvent: (type, data) => tap?.push(type, data) })
      const recorder = createRecorder({ engine, midi: {
        onMessage: callback => { hardware.add(callback); auto.onMessage(callback) },
        heldCcs: () => auto.heldCcs(),
      } })
      tap = createScTap({ onBatch: batch => recorder.addEvents(batch) })
      // a controller: SC gets its MIDI straight, the page hears it through Web MIDI
      const LC = 'LCXL3 1 MIDI In', LK = 'Launchkey MK4 25 MIDI In'
      const midiIn = (port, status, a, b) => { for (const cb of hardware) cb({ port, status, data: [a, b], time: performance.now() }) }
      const knob = (cc, value) => { midiIn(LC, 0xbf, cc, Math.round(value * 127)); return post('cc', [[cc, Math.round(value * 127) / 127]]) }
      const until = async bar => { while (engine.cycle() < bar) await sleep(10) }
      const save = async session => {
        const response = await fetch(`${base}/take/${track}`, { method: 'POST', headers: { Origin: base }, body: JSON.stringify(session) })
        const body = await response.json()
        assert.equal(response.status, 200, JSON.stringify(body))
        const file = path.join(PERFORM, track, body.id + '.json')
        written.push(file)
        const take = JSON.parse(fs.readFileSync(file, 'utf8'))
        if (take.take.events) written.push(path.join(takes, take.take.events))
        return { body, take }
      }
      try {
        auto.clear()
        await engine.load(track, auto.loadInit())
        recorder.start({ track, trackHash: null, cps: engine.cps() })
        auto.live()
        await until(0.5); await knob(13, 0.5)
        await until(1.25); await knob(37, 1); await sleep(100); await knob(37, 0)
        await until(1.5); midiIn(LK, 0x99, 36, 100); await post('lk', { note: [36, 100, 9] })
        await until(2); midiIn(LK, 0x90, 48, 90); await post('lk', { note: [48, 90, 0] })
        await until(2.5); midiIn(LK, 0x80, 48, 0)
        for (let i = 1; i <= 8; i++) { await until(2.5 + i / 20); await knob(5, i / 10) }
        await until(5.2)
        const original = await save(recorder.session())
        assert.deepEqual(original.body.problems, [], 'the take passes check-perform')
        assert.equal(original.take.take.source, 'human')
        assert.match(original.take.take.trackHash, /^[0-9a-f]{40}$/)
        const kinds = new Set(original.take.steps.map(step => Object.keys(step).find(k => ['cc', 'press', 'pad', 'keys'].includes(k))))
        assert.deepEqual([...kinds].sort(), ['cc', 'keys', 'pad', 'press'], 'knobs, the press, the pad and the key are in it')
        const events = fs.readFileSync(path.join(takes, original.take.take.events), 'utf8')
        assert.match(events, /"stem":"sc state"/, 'SC\'s state per bar is kept as the take\'s events')

        // the replay: Start on the take, from a fresh load, as the player does
        const response = await fetch(`${base}/perform/${track}/${original.body.id}`, { headers: { Origin: base } })
        assert.equal(response.status, 200, 'the catalogue lists the take for the SC track')
        const script = await response.json()
        const done = {}
        const finished = whenDone(done)
        const performer = createPerformer({ midi: auto, engine, onChange: progress => { if (!progress) done.resolve() } })
        auto.hold()
        performer.prime(script)
        await engine.load(track, quiet('load', auto.loadInit()))
        recorder.start({ track, trackHash: null, cps: engine.cps(), script: original.body.id })
        auto.live()
        performer.start(script)
        await finished
        await until(5.2)
        const replay = await save(recorder.session())
        assert.equal(replay.take.take.source, 'auto')
        assert.equal(replay.take.take.script, original.body.id)
        t.diagnostic(`replay check: ${replay.body.replay}`)
        if (!/^reproduced/.test(replay.body.replay ?? '')) {
          const { checkReplay, reportLines } = await import('./check-replay.mjs')
          for (const line of reportLines(checkReplay(track, replay.body.id))) t.diagnostic(line)
        }
        assert.match(replay.body.replay ?? '', /^(reproduced|NOT reproduced)/, 'the replay check compared the bars')
        engine.stop()
      } finally {
        for (const file of written) fs.rmSync(file, { force: true })
        if (!hadTakes && fs.existsSync(takes) && !fs.readdirSync(takes).length) fs.rmdirSync(takes)
      }
    })
  } finally {
    restore()
    for (const abort of streams) abort.abort()
    const exited = new Promise(resolve => server.once('exit', resolve))
    server.kill('SIGINT')
    await exited
  }
})
