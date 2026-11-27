// The Tracks lab's routes (perform-lab.mjs): every performance of every track is listed with its meta, a stem
// track's controls and tempo come from its .track file, the routes answer only POSTs from the player's own pages.
// Save (into a temporary folder): a new script and its sidecar are written and pass check-perform, a script the lab
// did not write is never overwritten, a script with errors is not written, a script changed outside the lab opens
// from its steps.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import http from 'http'
import os from 'os'
import path from 'path'
import { PERFORM, checkScript, controlsOf, scTrackFileOf, tagSource } from './check-perform.mjs'
import { createPerformLab, listTracks, openPerformance, savePerformance, trackInfo } from './perform-lab.mjs'
import { importScript, toScript } from './perform-lab-core.mjs'

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

const track = '009-house'
const original = JSON.parse(fs.readFileSync(path.join(PERFORM, track, 'dance-floor.json'), 'utf8'))
const lab = importScript(original)
const script = toScript(lab)
const temporary = () => fs.mkdtempSync(path.join(os.tmpdir(), 'perform-lab-'))

test('perform lab save: a new script and its sidecar, check-perform accepts it, it opens as the lab', () => {
  const dir = temporary()
  try {
    assert.deepEqual(savePerformance({ track, name: 'lab-copy', script, lab }, dir), { saved: true, name: 'lab-copy' })
    const file = path.join(dir, track, 'lab-copy.json')
    const written = JSON.parse(fs.readFileSync(file, 'utf8'))
    assert.deepEqual(checkScript(written, controlsOf(tagSource(scTrackFileOf(track))), track), [])
    assert.ok(fs.existsSync(path.join(dir, track, 'lab-copy.lab.json')))
    const opened = openPerformance(track, 'lab-copy', dir)
    assert.equal(opened.owned, true)
    assert.deepEqual(opened.lab, lab)
    const changed = { ...lab, title: 'Dance Floor again' }
    assert.equal(savePerformance({ track, name: 'lab-copy', script: toScript(changed), lab: changed }, dir).saved, true,
      'the lab saves over its own script')
    assert.equal(openPerformance(track, 'lab-copy', dir).lab.title, 'Dance Floor again')
  } finally {
    fs.rmSync(dir, { recursive: true, force: true })
  }
})

test('perform lab save: never over a script the lab did not write, never with errors', () => {
  const dir = temporary()
  try {
    fs.mkdirSync(path.join(dir, track))
    const handWritten = path.join(dir, track, 'dance-floor.json')
    fs.writeFileSync(handWritten, JSON.stringify(original))
    const refused = savePerformance({ track, name: 'dance-floor', script, lab }, dir)
    assert.equal(refused.saved, false)
    assert.match(refused.refused, /new name/)
    assert.equal(fs.readFileSync(handWritten, 'utf8'), JSON.stringify(original), 'the file is untouched')
    savePerformance({ track, name: 'mine', script, lab }, dir)
    const mine = path.join(dir, track, 'mine.json')
    fs.writeFileSync(mine, fs.readFileSync(mine, 'utf8').replace('"bars": 192', '"bars": 200'))
    assert.match(openPerformance(track, 'mine', dir).note, /changed outside the lab/)
    assert.equal(openPerformance(track, 'mine', dir).lab, undefined)
    assert.equal(savePerformance({ track, name: 'mine', script, lab }, dir).saved, false, 'edited outside: refused')
    const broken = { ...script, steps: [...script.steps, { bar: 4, cc: 999, value: 1 }] }
    const result = savePerformance({ track, name: 'broken', script: broken, lab }, dir)
    assert.equal(result.saved, false)
    assert.ok(result.errors.some(error => /cc 999/.test(error)))
    assert.equal(fs.existsSync(path.join(dir, track, 'broken.json')), false)
    assert.throws(() => savePerformance({ track, name: '../escape', script, lab }, dir), /lowercase/)
    assert.throws(() => savePerformance({ track, name: 'x', script: { ...script, track: '010-ambient-house' }, lab },
      dir), /not '009-house'/)
  } finally {
    fs.rmSync(dir, { recursive: true, force: true })
  }
})

test('perform lab save: the routes answer 200, 422 and 409', async () => {
  const dir = temporary()
  const server = http.createServer((request, response) =>
    createPerformLab({ dir }).handle(request, response, new URL(request.url, 'http://localhost'), () => true))
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve))
  const post = (route, body) => fetch(`http://127.0.0.1:${server.address().port}/lab/tracks/${route}`,
    { method: 'POST', body: JSON.stringify(body) })
  try {
    assert.equal((await post('save', { track, name: 'route', script, lab })).status, 200)
    assert.equal((await post('save', { track, name: 'route', script: { ...script, bars: -1 }, lab })).status, 422)
    fs.writeFileSync(path.join(dir, track, 'other.json'), '{}')
    assert.equal((await post('save', { track, name: 'other', script, lab })).status, 409)
    assert.deepEqual(await (await post('check', { track, script })).json(), { errors: [] })
    assert.equal((await (await post('open', { track, name: 'route' })).json()).owned, true)
  } finally {
    server.close()
    fs.rmSync(dir, { recursive: true, force: true })
  }
})
