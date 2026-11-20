// Feature tests for SuperCollider in the player: the track list, and (where sclang is installed) the player's server
// starting SC, playing, switching and stopping tracks, a click reaching the track, and nothing left behind.
// Loose checks: something plays (bars count), values arrive; never "is the output identical".
import test from 'node:test'
import assert from 'node:assert/strict'
import { spawn, execFileSync } from 'child_process'
import fs from 'fs'
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

// a few ports away from a player that may be running (8766, 57131, 57140)
const PORT = 8790, OSC = 57151, SERVER = 57152
const engineProcesses = () => {
  try {
    return execFileSync('ps', ['-axo', 'pid,command'], { encoding: 'utf8' }).split('\n')
      .filter(line => line.includes('sc/engine.scd') && line.includes(String(OSC)) || line.includes(`scsynth -u ${SERVER}`))
  } catch { return [] }
}

test('SuperCollider in the player: start, play, click, switch, stop, quit', { skip: findSclang() ? false : 'sclang not installed', timeout: 180e3 }, async () => {
  const server = spawn(process.execPath, [path.join(here, 'server.mjs'), String(PORT)],
    { env: { ...process.env, CE_SC_PORT: String(OSC), CE_SC_SERVER_PORT: String(SERVER) }, stdio: 'ignore' })
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
    abort.abort()
    const exited = new Promise(resolve => server.once('exit', resolve))
    server.kill('SIGINT')
    await exited
    await new Promise(resolve => setTimeout(resolve, 1500))
  }
  assert.deepEqual(engineProcesses(), [], 'no sclang or scsynth left behind')
})
