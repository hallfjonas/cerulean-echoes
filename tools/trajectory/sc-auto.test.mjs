// Auto-perform and takes on SuperCollider tracks without SuperCollider: the SC output of the performer (what it posts,
// in order), the bar-0 values held for the load, the SC tap's per-bar events, check-perform on the SC track files, and
// a take of an SC play saved and checked as a replay. The live run against SC is sc-perform.test.mjs.
// usage (in tools/): npm test
import assert from 'node:assert/strict'
import fs from 'fs'
import path from 'path'
import test from 'node:test'
import { compile, createPerformer, pressCounts } from './autoperform.mjs'
import { PERFORM, checkTrack, scTrackFileOf } from './check-perform.mjs'
import { createRecorder } from './take.mjs'
import { AUTO_PORT, LK_AUTO_PORT, createScAuto, createScTap } from './sc-auto.mjs'

const tick = () => new Promise(resolve => setTimeout(resolve, 1))

// a post that records every request and checks that they never overlap
const recordingPost = () => {
  const sent = []
  let open = 0
  const post = async (route, body) => {
    assert.equal(open++, 0, 'one request at a time')
    sent.push([route, structuredClone(body)])
    await tick()
    open--
  }
  return { sent, post }
}

test('SC output: steps go out in order, one request at a time, consecutive CCs together', async () => {
  const { sent, post } = recordingPost()
  const auto = createScAuto({ post })
  auto.setAuto(13, 0.5)
  auto.setAuto(14, 0.25)
  auto.setAutoLk(21, 0.3)
  auto.noteAuto(36, 0.8, 10)
  auto.noteAuto(48, 1, 1)
  auto.setAuto(13, 0.6)
  await auto.idle()
  assert.deepEqual(sent, [
    ['cc', [[13, 0.5], [14, 0.25]]],
    ['lk', { cc: [[21, 0.3]], note: [36, 102, 9] }],
    ['lk', { cc: [], note: [48, 127, 0] }],
    ['cc', [[13, 0.6]]],
  ])
})

test('SC output: held before the load, sent with it; the take hears every step as the virtual port\'s MIDI', async () => {
  const { sent, post } = recordingPost()
  const auto = createScAuto({ post, now: () => 7 })
  const heard = []
  auto.onMessage(message => heard.push(message))
  auto.setAuto(20, 1)
  await auto.idle()
  sent.length = 0
  auto.hold()
  auto.resetAuto()
  auto.setAuto(13, 0.4)
  auto.setAuto(5, 0)
  auto.setAutoLk(1, 0.5)
  await auto.idle()
  assert.deepEqual(sent, [], 'nothing is sent while holding')
  assert.deepEqual(auto.loadInit(), { cc: [[13, 0.4]], lk: [[1, 0.5]] })
  assert.deepEqual(auto.heldCcs(), [{ port: AUTO_PORT, cc: 13, value: 0.4, time: 7 }, { port: AUTO_PORT, cc: 5, value: 0, time: 7 },
    { port: LK_AUTO_PORT, cc: 1, value: 0.5, time: 7 }])
  auto.live()
  auto.noteAuto(40, 0.5, 10)
  auto.noteOffAuto(40, 10)
  await auto.idle()
  assert.deepEqual(sent, [['lk', { cc: [], note: [40, 64, 9] }]], 'a note-off is not sent: SC has none')
  assert.deepEqual(heard.slice(-2).map(m => [m.port, m.status, ...m.data]), [[LK_AUTO_PORT, 0x99, 40, 64], [LK_AUTO_PORT, 0x89, 40, 0]])
  assert.deepEqual(heard[0], { port: AUTO_PORT, status: 0xbf, data: [20, 127], time: 7 })
  auto.clear()
  assert.deepEqual(auto.loadInit(), { cc: [], lk: [] })
})

test('the performer plays a script into SC to its end: bar 0 with the load, then every step', async () => {
  const { sent, post } = recordingPost()
  const auto = createScAuto({ post })
  let cycle = 0, done
  const finished = new Promise(resolve => { done = resolve })
  const performer = createPerformer({ midi: auto, engine: { cycle: () => cycle }, onChange: p => { if (!p) done() } })
  const script = { track: 'x', steps: [{ bar: 0, cc: 13, value: 0.5 }, { bar: 0, lk: 1, value: 1 }, { bar: 1, press: 37 },
    { bar: 1.5, pad: 36 }, { bar: 2, keys: 'c3 e3' }, { bar: 2, cc: 13, value: 1, ramp: 1 }] }
  auto.hold()
  performer.prime(script)
  assert.deepEqual(auto.loadInit(), { cc: [[13, 64 / 127]], lk: [[1, 1]] })
  auto.live()
  performer.start(script)
  const clock = setInterval(() => { cycle += 0.25 }, 20)
  await finished
  clearInterval(clock)
  await auto.idle()
  const ccs = sent.filter(([route]) => route === 'cc').flatMap(([, pairs]) => pairs)
  const notes = sent.filter(([route, body]) => route === 'lk' && body.note).map(([, body]) => body.note)
  assert.deepEqual(ccs.filter(([cc]) => cc === 37).map(([, v]) => v), [1, 0], 'the press: down, then up')
  assert.equal(ccs.filter(([cc]) => cc === 13).at(-1)[1], 1, 'the ramp ends on its value')
  assert.deepEqual(notes, [[36, 102, 9], [48, 102, 0], [52, 102, 0]])
  assert.ok(!ccs.some(([cc, v]) => cc === 13 && v === 64 / 127), 'bar 0 went with the load, not again')
  assert.equal(compile(script).notes.length, 2)
})

test('the performer starts at a later bar: its values with the load, earlier presses counted, earlier notes skipped',
  async () => {
    const { sent, post } = recordingPost()
    const auto = createScAuto({ post })
    let cycle = 0, done
    const finished = new Promise(resolve => { done = resolve })
    const bars = []
    const performer = createPerformer({ midi: auto, engine: { cycle: () => cycle },
      onChange: p => p ? bars.push(p.bar) : done() })
    const script = { track: 'x', steps: [{ bar: 0, cc: 13, value: 0.2 }, { bar: 2, cc: 13, value: 1, ramp: 4 },
      { bar: 1, press: 44 }, { bar: 3, press: 44 }, { bar: 3, press: 37 }, { bar: 5, press: 44 }, { bar: 2, pad: 36 },
      { bar: 6, keys: 'c3' }] }
    assert.deepEqual(pressCounts(script, 4), [[44, 2], [37, 1]])
    assert.deepEqual(pressCounts(script, 0), [])
    auto.hold()
    performer.prime(script, 4)
    assert.deepEqual(auto.loadInit().cc, [[13, 76 / 127]], 'the value half-way up the ramp at bar 4')
    auto.live()
    performer.start(script, 4)
    assert.equal(bars[0], 4, 'the clock counts on from bar 4')
    const clock = setInterval(() => { cycle += 0.25 }, 20)
    await finished
    clearInterval(clock)
    await auto.idle()
    const ccs = sent.filter(([route]) => route === 'cc').flatMap(([, pairs]) => pairs)
    const notes = sent.filter(([route, body]) => route === 'lk' && body.note).map(([, body]) => body.note)
    assert.deepEqual(ccs.filter(([cc]) => cc === 44).map(([, v]) => v), [1, 0], 'only the press after bar 4')
    assert.equal(ccs.filter(([cc]) => cc === 37).length, 0)
    assert.deepEqual(notes, [[48, 102, 0]], 'the pad before bar 4 is skipped')
    assert.equal(ccs.filter(([cc]) => cc === 13).at(-1)[1], 1)
  })

test('SC tap: one batch per bar with controls, pattern state and the keys of the bar before', () => {
  const batches = []
  const tap = createScTap({ onBatch: batch => batches.push(batch) })
  tap.push('layout', { bpm: 124 })
  tap.push('ccs', [0, 0, 0, 0, 0, 0.5])
  tap.push('lk', { 1: 1, 21: 0 })
  tap.push('state', { rows: { 'jojo:1': ['1', '1'] }, head: ['Vamp'] })
  tap.push('lknote', [36, 9])
  tap.push('beat', { bar: 0, beat: 0 })
  tap.push('beat', { bar: 0, beat: 1 })
  tap.push('cc', { 13: 0.3 })
  tap.push('state', { rows: { 'jojo:1': ['1', '2'] }, head: ['Vamp'] })
  tap.push('lknote', [48, 0])
  tap.push('beat', { bar: 1, beat: 0 })
  tap.push('beat', { bar: 1, beat: 0 })
  assert.equal(batches.length, 2, 'one batch per bar line')
  assert.deepEqual(batches[0], [
    { stem: 'sc cc', cycle: 0, duration: 1, value: { cc5: 16 } },
    { stem: 'sc lk', cycle: 0, duration: 1, value: { lk1: 32 } },
    { stem: 'sc state', cycle: 0, duration: 1, value: { 'rows.jojo:1': '1>1', head: '["Vamp"]' } },
  ])
  assert.deepEqual(batches[1][0], { stem: 'sc keys', cycle: 0, duration: 1, value: { notes: '36/9 48/0' } },
    'keys before the first bar line count to bar 0')
  assert.deepEqual(batches[1][1].value, { cc5: 16, cc13: 10 })
  assert.equal(batches[1][3].value['rows.jojo:1'], '1>2')
})

test('check-perform: every script of a ported track fits its SuperCollider version', () => {
  const ids = fs.readdirSync(PERFORM).filter(id => scTrackFileOf(id))
  assert.ok(ids.length >= 4, ids.join(', '))
  for (const id of ids) {
    const results = Object.entries(checkTrack(scTrackFileOf(id)))
    assert.ok(results.length, `${id} has scripts`)
    for (const [script, errors] of results) assert.deepEqual(errors, [], path.basename(script))
  }
})

test('a take of an SC play: saved with the .scd file\'s sha1, its SC events checked when it is replayed', async () => {
  const { saveTake } = await import('./take-save.mjs')
  const { find } = await import('./catalogue.mjs')
  const track = '009-house'
  assert.equal(find(track).engine, 'sc')
  const play = script => {
    let listener, cycle = 0
    const recorder = createRecorder({ midi: { onMessage: cb => { listener = cb }, heldCcs: () => [] }, engine: { cycle: () => cycle } })
    const tap = createScTap({ onBatch: batch => recorder.addEvents(batch) })
    recorder.start({ track, trackHash: null, cps: 124 / 240, ...script && { script } })
    for (let bar = 0; bar < 4; bar++) {
      cycle = bar
      if (bar === 1) {
        cycle = 1.5
        listener({ port: script ? AUTO_PORT : 'LCXL3 1 MIDI In', status: 0xbf, data: [13, 64], time: 3000 })
        tap.push('cc', { 13: 64 / 127 })
      }
      cycle = bar
      tap.push('beat', { bar, beat: 0 })
    }
    return recorder.session()
  }
  const written = [], takes = path.join(PERFORM, track, 'takes'), hadTakes = fs.existsSync(takes)
  try {
    const original = saveTake(track, play())
    assert.equal(original.status, 200, JSON.stringify(original.body))
    assert.deepEqual(original.body.problems, [])
    const file = path.join(PERFORM, track, original.body.id + '.json')
    written.push(file)
    const take = JSON.parse(fs.readFileSync(file, 'utf8'))
    written.push(path.join(path.dirname(file), take.take.events))
    assert.match(take.take.trackHash, /^[0-9a-f]{40}$/)
    assert.equal(take.take.source, 'human')
    assert.deepEqual(take.steps, [{ bar: 1.5, cc: 13, value: 0.5039 }])
    const replay = saveTake(track, play(original.body.id))
    const replayFile = path.join(PERFORM, track, replay.body.id + '.json')
    written.push(replayFile, replayFile.replace(/\.json$/, '.events.jsonl'))
    assert.equal(replay.body.replay, 'reproduced: all 3 bars identical')
  } finally {
    for (const file of written) fs.rmSync(file, { force: true })
    if (!hadTakes && !fs.readdirSync(takes).length) fs.rmdirSync(takes)
  }
})
