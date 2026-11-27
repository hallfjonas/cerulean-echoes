// The Tracks lab's routes (perform-lab.mjs): every performance of every track is listed with its meta, a stem
// track's controls and tempo come from its .track file, the routes answer only POSTs from the player's own pages.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import http from 'http'
import path from 'path'
import { PERFORM } from './check-perform.mjs'
import { createPerformLab, listTracks, trackInfo } from './perform-lab.mjs'

const jsonNames = dir => fs.existsSync(dir) ? fs.readdirSync(dir).filter(name => /^[\w-]+\.json$/.test(name))
  .map(name => name.slice(0, -'.json'.length)) : []

test('perform lab routes: every performance of every track is listed', () => {
  const tracks = listTracks()
  const folders = fs.readdirSync(PERFORM, { withFileTypes: true }).filter(entry => entry.isDirectory())
  assert.ok(folders.length > 0)
  for (const { name: track } of folders) {
    const listed = tracks.find(entry => entry.track === track)
    assert.ok(listed, `${track} is listed`)
    const expected = [...jsonNames(path.join(PERFORM, track)),
      ...jsonNames(path.join(PERFORM, track, 'takes')).map(name => `takes/${name}`)].sort()
    assert.deepEqual(listed.performances.map(entry => entry.name).sort(), expected, track)
  }
  const danceFloor = tracks.find(entry => entry.track === '009-house').performances
    .find(entry => entry.name === 'dance-floor')
  const script = JSON.parse(fs.readFileSync(path.join(PERFORM, '009-house', 'dance-floor.json'), 'utf8'))
  assert.deepEqual(danceFloor, { name: 'dance-floor', title: script.title, bars: script.bars, mood: script.mood,
    sections: script.sections.length, steps: script.steps.length, design: true, take: false })
})

test('perform lab routes: a stem track’s tempo and controls', () => {
  for (const [track, tempo] of [['009-house', 124], ['017-lsd-fx-2', 134]]) {
    const info = trackInfo(track)
    assert.equal(info.tempo, tempo, track)
    const controls = new Map(info.controls)
    assert.deepEqual(controls.get(20), { name: 'Global Fog', button: false }, track)
    assert.deepEqual(controls.get(52), { name: 'Global Break', button: true }, track)
    assert.ok([...controls.values()].some(control => / Level$/.test(control.name)), `${track} has Level faders`)
  }
  assert.throws(() => trackInfo('999-nothing'), /no live track/)
})

test('perform lab routes: POST from own pages only', async () => {
  const lab = createPerformLab()
  let own = true
  const server = http.createServer((request, response) =>
    lab.handle(request, response, new URL(request.url, 'http://localhost'), () => own))
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve))
  const base = `http://127.0.0.1:${server.address().port}/lab/tracks/`
  const post = (route, body) => fetch(base + route, { method: 'POST', body: JSON.stringify(body) })
  try {
    const tracks = await post('tracks', {})
    assert.equal(tracks.status, 200)
    assert.ok((await tracks.json()).tracks.some(entry => entry.track === '009-house'))
    const info = await (await post('track', { track: '009-house' })).json()
    assert.equal(info.tempo, 124)
    assert.equal((await post('track', { track: 'nope' })).status, 400)
    assert.equal((await post('other', {})).status, 404)
    assert.equal((await fetch(base + 'tracks')).status, 403, 'GET is refused')
    own = false
    assert.equal((await post('tracks', {})).status, 403, 'another page is refused')
  } finally {
    server.close()
  }
})
