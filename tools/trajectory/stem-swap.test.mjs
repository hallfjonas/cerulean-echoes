// Feature tests for the stem swap endpoints (stem-swap.mjs) and the selection registry (selection.mjs), without
// SuperCollider: a stand-in for sc-link plays the track. The swap with SC itself is in sc-link.test.mjs.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import http from 'http'
import os from 'os'
import path from 'path'
import { fileURLToPath } from 'url'
import { createStemSwap } from './stem-swap.mjs'
import { createSelection, columnSelection } from './selection.mjs'

const repo = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const KICK_2 = 'kick909/kick909-brightness-space-punch-pattern-drop-out-2.stem'
const BASS_FM = 'bassFM/bass-fm-brightness-space-sound-pattern-octave.stem'

// a copy of the library and the demo track, so Save as writes into a throwaway folder
const tempRepo = () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'stem-swap-'))
  fs.cpSync(path.join(repo, 'sc', 'stems'), path.join(dir, 'sc', 'stems'), { recursive: true })
  fs.cpSync(path.join(repo, 'sc', 'tracks', '090-stem-demo'), path.join(dir, 'sc', 'tracks', '090-stem-demo'), { recursive: true })
  return dir
}

test('stem swap: the endpoint changes the slot, Save as writes a new track, the original is unchanged', async () => {
  const root = tempRepo()
  const trackFile = path.join(root, 'sc', 'tracks', '090-stem-demo', '090-stem-demo.track')
  const original = fs.readFileSync(trackFile, 'utf8')
  const find = id => id === '090-stem-demo' ? { id, stems: true, engine: 'sc', path: trackFile } : undefined
  // stand-in for sc-link: the bass FM stem needs another strip (a reload), everything else swaps live
  const calls = []
  const sc = {
    host: { track: null },
    load: async (id, slots) => { calls.push(['load', id, slots]); sc.host.track = id; swaps.loaded(id, slots) },
    swap: async (slot, stem) => {
      calls.push(['swap', slot, stem])
      return stem === BASS_FM ? { live: false, reason: 'the new stem needs another mixer strip' } : { live: true }
    },
  }
  const swaps = createStemSwap({ repo: root, find, sc })
  const server = http.createServer((request, response) =>
    swaps.handle(request, response, new URL(request.url, 'http://localhost'), () => true))
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve))
  const base = `http://127.0.0.1:${server.address().port}`
  const post = async (route, body) => {
    const response = await fetch(base + route, { method: 'POST', body: JSON.stringify(body) })
    return { status: response.status, body: await response.json() }
  }
  const get = async () => (await fetch(base + '/swap?track=090-stem-demo')).json()
  try {
    let state = await get()
    assert.equal(state.playing, false)
    assert.equal(state.slots['1:1'].role, 'kick')
    assert.equal((await post('/swap', { track: '090-stem-demo', slot: '1:1', stem: KICK_2 })).status, 409,
      'no swap while the track does not play')

    await sc.load('090-stem-demo')
    let result = await post('/swap', { track: '090-stem-demo', slot: '1:1', stem: KICK_2 })
    assert.equal(result.status, 200, JSON.stringify(result.body))
    assert.equal(result.body.mode, 'next-bar')
    assert.equal(result.body.slots['1:1'], KICK_2)
    assert.deepEqual(calls.at(-1), ['swap', '1:1', KICK_2])
    state = await get()
    assert.equal(state.slots['1:1'].stem, KICK_2, 'the slot holds the new stem')
    assert.notEqual(state.slots['1:1'].file, KICK_2, 'the file keeps its stem')

    result = await post('/swap', { track: '090-stem-demo', slot: '1:4', stem: BASS_FM })
    assert.equal(result.body.mode, 'reload', 'a stem the strip does not fit: the track loads again with it')
    assert.match(result.body.reason, /strip/)
    assert.deepEqual(calls.at(-1)[2], { ...JSON.parse(original).slots, '1:1': KICK_2, '1:4': BASS_FM })
    assert.equal((await get()).slots['1:4'].stem, BASS_FM)

    assert.equal((await post('/swap', { track: '090-stem-demo', slot: '1:2', stem: KICK_2 })).status, 400, 'empty slot')
    assert.equal((await post('/swap', { track: '090-stem-demo', slot: '1:1', stem: 'kick909/nope.stem' })).status, 400)

    result = await post('/track/save-as', { track: '090-stem-demo' })
    assert.equal(result.status, 201, JSON.stringify(result.body))
    assert.equal(result.body.id, '090-stem-demo-v2')
    const saved = JSON.parse(fs.readFileSync(path.join(root, result.body.file), 'utf8'))
    assert.equal(saved.name, '090-stem-demo-v2')
    assert.deepEqual(saved.slots, { '1:1': KICK_2, '1:4': BASS_FM })
    assert.ok(fs.existsSync(path.join(root, 'sc', 'tracks', '090-stem-demo-v2', saved.frame)), 'the frame is next to it')
    assert.equal((await post('/track/save-as', { track: '090-stem-demo', name: '090-stem-demo-v2' })).status, 409,
      'never overwrites')
    assert.equal((await post('/track/save-as', { track: '090-stem-demo', name: 'Bad Name' })).status, 400)
    assert.equal((await post('/track/save-as', { track: '090-stem-demo' })).body.id, '090-stem-demo-v3')
    assert.equal(fs.readFileSync(trackFile, 'utf8'), original, 'the track file is unchanged')

    result = await post('/swap/revert', { track: '090-stem-demo' })
    assert.equal(result.status, 200)
    assert.deepEqual(result.body.slots, JSON.parse(original).slots, 'Revert: the file\'s stems again')
    assert.equal(fs.readFileSync(trackFile, 'utf8'), original)
  } finally {
    server.close()
    fs.rmSync(root, { recursive: true, force: true })
  }
})

test('selection: a column selection reaches the listeners of its kind; incomplete ones are refused', () => {
  const selection = createSelection()
  const columns = [], all = []
  const stop = selection.on('column', item => columns.push(item))
  selection.on('*', item => all.push(item))
  selection.select(columnSelection({ track: '009-house-stems', slot: '2:4', stem: 'flute/flute-x.stem' }))
  assert.deepEqual(selection.current(), { kind: 'column', track: '009-house-stems', slot: '2:4', stem: 'flute/flute-x.stem' })
  assert.ok(Object.isFrozen(selection.current()))
  assert.throws(() => selection.select({ kind: 'column', track: 'x', slot: '1:1' }), /missing stem/)
  assert.throws(() => selection.select({ kind: 'knob' }), /unknown kind/)
  selection.clear()
  stop()
  selection.select(columnSelection({ track: 't', slot: '1:1', stem: 's' }))
  assert.equal(columns.length, 2)
  assert.equal(columns[1], null, 'clear tells the listeners')
  assert.equal(all.length, 3)
})
