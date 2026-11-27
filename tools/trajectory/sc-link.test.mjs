// Feature tests for SuperCollider in the player: the track list, and (where sclang is installed) the player's server
// starting SC, playing, switching and stopping tracks, a click reaching the track, and nothing left behind.
// Loose checks: something plays (bars count), values arrive; never "is the output identical".
import test from 'node:test'
import assert from 'node:assert/strict'
import { spawn, execFileSync } from 'child_process'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { fileURLToPath } from 'url'
import { encode, decode } from './osc.mjs'
import { findSclang } from './sc-link.mjs'

const here = path.dirname(fileURLToPath(import.meta.url))

test('OSC: what the link sends reads back the same', () => {
  const m = decode(encode('/ce/cc', [{ i: 13 }, { f: 0.5 }, 'x']))
  assert.equal(m.address, '/ce/cc')
  assert.deepEqual(m.args, [13, 0.5, 'x'])
})

test('track list: every SC track is a live track on engine sc; a ported track keeps its Strudel copy', async () => {
  const { scan } = await import('./catalogue.mjs')
  const live = scan().filter(entry => entry.kind === 'live')
  const sc = live.filter(entry => entry.engine === 'sc')
  assert.ok(sc.length >= 4, 'at least the four ported tracks')
  for (const entry of sc) {
    assert.match(entry.path, entry.stems ? /\.track$/ : /\.scd$/)
    assert.ok(entry.taps, `${entry.id} playable`)
    const copy = live.find(other => other.base === entry.id)
    if (copy) assert.equal(copy.engine, 'strudel')
  }
  assert.equal(new Set(live.map(entry => entry.id)).size, live.length, 'ids are unique')
  assert.ok(sc.some(entry => entry.stems && entry.id === '090-stem-demo'), 'the stem demo track is listed')
})

// the set view's data path without SuperCollider: OSC /ce/setsample (as sc/lib/ui.scd sends it every 10 s) → kept by
// the link → SSE setsample to open pages, and the whole history as one sethistory event to a page that connects later;
// a failed column (/ce/stemerror) is passed on too
test('set samples: passed on as they come, a new page gets the history; failed columns reach the page',
  { timeout: 30e3 }, async () => {
  const port = 8792, osc = 57171
  const server = spawn(process.execPath, [path.join(here, 'server.mjs'), String(port)],
    { env: { ...process.env, CE_SC_PORT: String(osc), CE_SC_SERVER_PORT: '57172', SCLANG: 'none' }, stdio: 'ignore' })
  const base = `http://localhost:${port}`
  const streams = []
  const listen = () => {
    const events = [], abort = new AbortController()
    streams.push(abort)
    fetch(base + '/sc/events', { signal: abort.signal }).then(async response => {
      const decoder = new TextDecoder()
      let buffer = ''
      for await (const chunk of response.body) {
        buffer += decoder.decode(chunk, { stream: true })
        let at
        while ((at = buffer.indexOf('\n\n')) >= 0) {
          const data = buffer.slice(0, at).split('\n').find(line => line.startsWith('data: '))
          buffer = buffer.slice(at + 2)
          if (data) events.push(JSON.parse(data.slice(6)))
        }
      }
    }).catch(() => {})
    return events
  }
  const until = async (test, ms = 5000) => {
    for (const end = Date.now() + ms; Date.now() < end; await new Promise(resolve => setTimeout(resolve, 50))) { const hit = test(); if (hit) return hit }
    return null
  }
  const udp = (await import('dgram')).default.createSocket('udp4')
  const sample = (energy, punch, tension) => new Promise(resolve =>
    udp.send(encode('/ce/setsample', [{ f: energy }, { f: punch }, { f: tension }, ...Array.from({ length: 64 }, (_, i) => ({ f: i / 63 }))]), osc, '127.0.0.1', resolve))
  try {
    for (let i = 0; i < 50; i++) {
      try { if ((await fetch(base + '/catalogue')).ok) break } catch {}
      await new Promise(resolve => setTimeout(resolve, 100))
    }
    const first = listen()
    assert.deepEqual((await until(() => first.find(e => e.type === 'sethistory')))?.data, [], 'a fresh server has no history')
    await sample(-20.5, 0.4, 0.25)
    await sample(-18, 1.7, -1)
    const live = await until(() => first.filter(e => e.type === 'setsample').length >= 2 && first.filter(e => e.type === 'setsample'))
    assert.ok(live, 'both samples reach the open page')
    assert.deepEqual(Object.keys(live[0].data).sort(), ['e', 'p', 's', 't', 'x'])
    assert.equal(live[0].data.e, -20.5)
    assert.equal(live[0].data.s.length, 64)
    assert.equal(live[1].data.p, 1, 'punch is clamped to 0..1')
    assert.equal(live[1].data.x, 0, 'tension is clamped to 0..1')
    const later = listen()
    const history = await until(() => later.find(e => e.type === 'sethistory'))
    assert.deepEqual(history?.data, live.map(e => e.data), 'a page that connects later gets the whole history')
    const failed = ['2:1', 'pump-chords-colour-2', "Message 'atBar' not understood."]
    await new Promise(resolve => udp.send(encode('/ce/stemerror', failed), osc, '127.0.0.1', resolve))
    const shown = await until(() => first.find(e => e.type === 'stemerror'))
    assert.deepEqual(shown?.data, failed, 'a failed column reaches the page')
  } finally {
    udp.close()
    for (const abort of streams) abort.abort()
    const exited = new Promise(resolve => server.once('exit', resolve))
    server.kill('SIGINT')
    await exited
  }
})

// a few ports away from a player that may be running (8766, 57131, 57140)
const PORT = +(process.env.CE_TEST_HTTP ?? 8790), OSC = +(process.env.CE_TEST_OSC ?? 57151), SERVER = +(process.env.CE_TEST_SERVER ?? 57152)
const engineProcesses = () => {
  try {
    return execFileSync('ps', ['-axo', 'pid,command'], { encoding: 'utf8' }).split('\n')
      .filter(line => line.includes('sc/engine.scd') && line.includes(String(OSC)) || line.includes(`scsynth -u ${SERVER}`))
  } catch { return [] }
}

test('SuperCollider in the player: start, play, click, switch, stop, quit', { skip: findSclang() ? false : 'sclang not installed', timeout: 180e3 }, async () => {
  const folder = fs.mkdtempSync(path.join(os.tmpdir(), 'sc-link-recordings-'))
  const server = spawn(process.execPath, [path.join(here, 'server.mjs'), String(PORT)],
    { env: { ...process.env, CE_SC_PORT: String(OSC), CE_SC_SERVER_PORT: String(SERVER), CE_SC_MUTE: '1', RECORDINGS_DIR: folder }, stdio: 'ignore' })
  const base = `http://localhost:${PORT}`
  const post = (route, body) => fetch(base + '/sc/' + route, { method: 'POST', headers: { Origin: base },
    body: JSON.stringify(body ?? {}) })
  const events = []
  const abort = new AbortController()
  try {
    for (let i = 0; i < 50; i++) {
      try { if ((await fetch(base + '/catalogue')).ok) break } catch {}
      await new Promise(resolve => setTimeout(resolve, 100))
    }
    // the page's view of SC: every event in order
    fetch(base + '/sc/events', { signal: abort.signal }).then(async response => {
      const decoder = new TextDecoder()
      let buffer = ''
      for await (const chunk of response.body) {
        buffer += decoder.decode(chunk, { stream: true })
        let at
        while ((at = buffer.indexOf('\n\n')) >= 0) {
          const block = buffer.slice(0, at)
          buffer = buffer.slice(at + 2)
          const data = block.split('\n').find(line => line.startsWith('data: '))
          if (data) events.push(JSON.parse(data.slice(6)))
        }
      }
    }).catch(() => {})
    const since = () => events.length
    const waitFor = async (test, from, ms = 15000) => {
      const end = Date.now() + ms
      while (Date.now() < end) {
        const hit = events.slice(from).find(test)
        if (hit) return hit
        await new Promise(resolve => setTimeout(resolve, 100))
      }
      return null
    }
    const bars = from => events.slice(from).filter(e => e.type === 'beat').map(e => e.data.bar + e.data.beat / 4)

    let mark = since()
    let response = await post('load', { id: '009-house' })
    assert.equal(response.status, 200, await response.clone().text())
    assert.deepEqual(await response.json(), { track: '009-house' })
    assert.equal((await waitFor(e => e.type === 'layout', mark))?.data.bpm, 124, 'the LC view gets the track')
    assert.ok(await waitFor(e => e.type === 'beat' && e.data.bar >= 1, mark), 'bars count from the load')
    assert.equal(bars(mark)[0], 0, 'the first bar is bar 0')
    // the master output's spectrum (sc/lib/ui.scd): 48 bands 0..1, several frames a second
    const spectrum = await waitFor(e => e.type === 'spectrum', mark)
    assert.equal(spectrum?.data.length, 48, 'the spectrum arrives with 48 bands')
    assert.ok(spectrum.data.every(v => v >= 0 && v <= 1), 'bands are 0..1')
    // the set view's sample (sc/lib/ui.scd uiSetFrame), every 10 s: energy in dB, punch, tension, 64 bands
    const setsample = await waitFor(e => e.type === 'setsample', mark, 25000)
    assert.ok(setsample, 'a set sample arrives within 10 s of the load')
    assert.equal(setsample.data.s.length, 64)
    assert.ok(setsample.data.e >= -70 && setsample.data.e <= 10, 'energy in dB')

    // a click in the LC view (the same as a MIDI message) reaches the track and comes back as its state
    mark = since()
    assert.equal((await post('cc', [[13, 0.5]])).status, 204)
    assert.ok(await waitFor(e => e.type === 'cc' && Math.abs(e.data['13'] - 0.5) < 1e-3, mark), 'the click arrives')

    // switching: the other track, bars from 0 again
    mark = since()
    response = await post('load', { id: '008-groove-techno' })
    assert.equal(response.status, 200, await response.clone().text())
    assert.equal((await waitFor(e => e.type === 'layout', mark))?.data.bpm, 140)
    assert.ok(await waitFor(e => e.type === 'beat', mark), 'the new track plays')
    assert.equal(bars(mark)[0], 0, 'a switch starts at bar 0')
    assert.ok(await waitFor(e => e.type === 'spectrum', mark), 'the spectrum comes back after a switch (all nodes were freed)')

    // recording: SC writes the master to recordings/<track>/ (a temporary folder here); a valid WAV and a matching sidecar
    // (loose: the length and the header, not the loudness)
    const rec = (route, body) => fetch(`${base}/recording/${route}`, { method: 'POST', headers: { Origin: base },
      body: JSON.stringify(body ?? {}) })
    mark = since()
    response = await rec('008-groove-techno', { engine: 'sc', source: 'human', startCycle: 0, cps: 140 / 240 })
    assert.equal(response.status, 201, await response.clone().text())
    const { name } = await response.json()
    assert.match(name, /^\d{4}-\d\d-\d\d-\d{6}-human$/)
    const level = await waitFor(e => e.type === 'level', mark)
    assert.ok(level && level.data >= 0 && level.data <= 1, 'the meter gets a peak from SC')
    assert.equal((await rec('009-house', { engine: 'sc', source: 'human' })).status, 409, 'one recording at a time')
    await new Promise(resolve => setTimeout(resolve, 2000))
    response = await rec(`008-groove-techno/${name}/finish`, { endedBy: 'stop' })
    const meta = await response.json()
    assert.equal(response.status, 200)
    assert.equal(meta.engine, 'sc')
    assert.equal(meta.endedBy, 'stop')
    assert.ok(meta.sampleRate >= 8000 && meta.seconds > 1 && meta.seconds < 6, `length ${meta.seconds} s`)
    const file = path.join(folder, '008-groove-techno', name)
    const wav = fs.readFileSync(file + '.wav')
    assert.equal(wav.toString('ascii', 0, 4), 'RIFF')
    assert.equal(wav.readUInt16LE(22), 2, 'stereo')
    assert.equal(wav.readUInt32LE(24), meta.sampleRate)
    assert.equal(wav.readUInt16LE(34), 16)
    assert.ok(Math.abs((wav.length - 44) / 4 / meta.sampleRate - meta.seconds) < 0.01, 'the sidecar length matches the file')
    assert.deepEqual(JSON.parse(fs.readFileSync(file + '.json', 'utf8')), meta, 'the sidecar file matches')
    assert.equal((await rec(`008-groove-techno/${name}/finish`)).status, 200, 'a second finish answers the same sidecar')
    // a track load ends a recording (the nodes are freed): the file is closed and the sidecar written
    response = await rec('008-groove-techno', { engine: 'sc', source: 'human' })
    const second = (await response.json()).name
    await new Promise(resolve => setTimeout(resolve, 1000))
    assert.equal((await post('load', { id: '009-house' })).status, 200)
    await new Promise(resolve => setTimeout(resolve, 500))
    const cut = JSON.parse(fs.readFileSync(path.join(folder, '008-groove-techno', second + '.json'), 'utf8'))
    assert.ok(cut.endedBy === 'stop' && cut.seconds > 0, 'a load leaves a finished sidecar')
    // the sidecar rounds seconds to 3 decimals
    assert.ok(Math.abs(fs.readFileSync(path.join(folder, '008-groove-techno', second + '.wav')).readUInt32LE(40) / 4 / cut.sampleRate - cut.seconds) < 0.001, 'the WAV length matches the sidecar')
    // a stem track: its @ctl texts come from its stems
    mark = since()
    response = await post('load', { id: '090-stem-demo' })
    assert.equal(response.status, 200, await response.clone().text())
    const layout = await waitFor(e => e.type === 'layout', mark)
    assert.equal(layout?.data.tags['16:4.k3'], 'Length | short ↔ long.', 'the stem track shows its stems')
    assert.ok(await waitFor(e => e.type === 'beat', mark), 'the stem track plays')

    // stem swap (stem-swap.mjs): kick version 2 fits the kick's strip (from the next bar); the FM bass needs another
    // strip (the track loads again with it); Revert plays the file's stems; the track file never changes
    const demoFile = path.join(here, '..', '..', 'sc', 'tracks', '090-stem-demo', '090-stem-demo.track')
    const demoText = fs.readFileSync(demoFile, 'utf8')
    const swap = (route, body) => fetch(base + route, { method: 'POST', headers: { Origin: base }, body: JSON.stringify(body) })
      .then(async r => ({ status: r.status, body: await r.json() }))
    const kick2 = 'kick909/kick909-brightness-space-punch-pattern-drop-out-2.stem'
    const bassFm = 'bassFM/bass-fm-brightness-space-sound-pattern-octave.stem'
    let swapped = await swap('/swap', { track: '090-stem-demo', slot: '1:1', stem: kick2 })
    assert.equal(swapped.status, 200, JSON.stringify(swapped.body))
    assert.equal(swapped.body.mode, 'next-bar')
    mark = since()
    swapped = await swap('/swap', { track: '090-stem-demo', slot: '1:4', stem: bassFm })
    assert.equal(swapped.status, 200, JSON.stringify(swapped.body))
    assert.equal(swapped.body.mode, 'reload')
    assert.ok(await waitFor(e => e.type === 'layout' && e.data.tags['16:4.k3'] === 'Sound | FM → M1 organ → analog.',
      mark), 'the reload plays the FM bass')
    const state = await (await fetch(base + '/swap?track=090-stem-demo')).json()
    assert.deepEqual([state.slots['1:1'].stem, state.slots['1:4'].stem], [kick2, bassFm])
    swapped = await swap('/swap/revert', { track: '090-stem-demo' })
    assert.equal(swapped.status, 200, JSON.stringify(swapped.body))
    assert.deepEqual(swapped.body.slots, JSON.parse(demoText).slots)
    assert.equal(fs.readFileSync(demoFile, 'utf8'), demoText, 'the track file is unchanged')

    // stop: no more bars
    assert.equal((await post('stop')).status, 200)
    await new Promise(resolve => setTimeout(resolve, 1500))
    mark = since()
    await new Promise(resolve => setTimeout(resolve, 1500))
    assert.equal(bars(mark).length, 0, 'nothing plays after Stop')

    // an unknown track is an error, not a hang
    response = await post('load', { id: 'no-such-track' })
    assert.equal(response.status, 500)
  } finally {
    fs.rmSync(folder, { recursive: true, force: true })
    abort.abort()
    const exited = new Promise(resolve => server.once('exit', resolve))
    server.kill('SIGINT')
    await exited
    await new Promise(resolve => setTimeout(resolve, 1500))
  }
  assert.deepEqual(engineProcesses(), [], 'no sclang or scsynth left behind')
})
