// Tests for replay fidelity (replay-check.mjs, check-replay.mjs), event capture (take.mjs) and the primed performer.
// usage (in tools/): npm test
import assert from 'node:assert/strict'
import fs from 'fs'
import path from 'path'
import test from 'node:test'
import { createPerformer } from './autoperform.mjs'
import { PERFORM, controlsOf, tagSource, trackFileOf } from './check-perform.mjs'
import { checkReplay, reportLines } from './check-replay.mjs'
import { barLine, compareEvents, parseEvents, summaryLine } from './replay-check.mjs'
import { createRecorder, createSession } from './take.mjs'

const event = (stem, cycle, value = {}, duration = 0.25) =>
  ({ stem, cycle, value: { s: 'bd', gain: 1, ...value }, duration, delay: Math.random(), cps: 0.5 })
const bars = n => Array.from({ length: n * 4 }, (_, i) => event('Kick', i / 4))

test('identical plays are reproduced; the unfinished last bar is not compared', () => {
  const original = [...bars(4), event('Kick', 4)]
  const replay = [...bars(4).reverse(), event('Kick', 4), event('Kick', 4.25)]
  const result = compareEvents(original, replay)
  assert.deepEqual([result.bars, result.same, result.differing.length], [4, 4, 0])
  assert.equal(summaryLine(result), 'reproduced: all 4 bars identical')
})

test('a value, a shift and an unpaired event are told apart, per bar', () => {
  const original = [...bars(4), event('Bass', 3.5, { note: 40 }), event('Kick', 4)]
  const replay = bars(4).map(e => {
    if (e.cycle === 1) return { ...e, value: { ...e.value, gain: 0.5 } }
    if (e.cycle === 2.25) return { ...e, cycle: 2.3 }
    return e
  }).concat(event('Pad', 3.75), event('Kick', 4))
  const result = compareEvents(original, replay)
  assert.deepEqual(result.differing.map(d => d.bar), [1, 2, 3])
  const [value, timing, only] = result.differing
  assert.deepEqual(value.values, [{ stem: 'Kick', cycle: 1, fields: ['gain'] }])
  assert.equal(timing.timing.length, 1)
  assert.ok(Math.abs(timing.timing[0].shift - 0.05) < 1e-9)
  assert.deepEqual([only.onlyOriginal.map(e => e.stem), only.onlyReplay.map(e => e.stem)], [['Bass'], ['Pad']])
  assert.match(barLine(value), /^bar 2: 1 events with other gain \(Kick 1\): a control read another value \(/)
  assert.match(barLine(timing), /^bar 3: 1 events moved \+0\.05 bar \(Kick 1\)/)
  assert.match(barLine(only), /only in the original: Bass 1; only in the replay: Pad 1; a stem or pattern state/)
  assert.equal(summaryLine(result), 'NOT reproduced: 3 of 4 bars differ (bar 2, 3, 4)')
})

test('a play with no finished bar cannot be checked; events files parse batch by batch', () => {
  assert.equal(summaryLine(compareEvents([event('Kick', 0)], [])), 'cannot check: no bar finished in both plays')
  const text = JSON.stringify([event('Kick', 0)]) + '\n\n' + JSON.stringify([event('Kick', 1), event('Kick', 2)]) + '\n'
  assert.deepEqual(parseEvents(text).map(e => e.cycle), [0, 1, 2])
})

test('the recorder keeps tapped events from the bar line and drops a late batch of the play before', () => {
  let cycle = 30
  const midi = { onMessage: () => {}, heldCcs: () => [] }
  const recorder = createRecorder({ midi, engine: { cycle: () => cycle } })
  recorder.addEvents([event('Kick', 29.5)])
  cycle = 0.1
  recorder.start({ track: 'test', trackHash: 'abc', cps: 0.5 })
  recorder.addEvents([event('Kick', 29.75), event('Kick', 0), event('Kick', 0.05)])
  cycle = 0.6
  recorder.addEvents([event('Kick', 0.5)])
  assert.deepEqual(recorder.session().events.map(batch => batch.map(e => e.cycle)), [[0, 0.05], [0.5]])
  assert.deepEqual(createSession({}).events, [])
})

test('a primed performer sets bar 0 before the load and resets nothing after it', () => {
  const sent = []
  let resets = 0
  const midi = { resetAuto: () => resets++, setAuto: (cc, v) => sent.push([cc, v]), setAutoLk: () => {},
    releaseAutoKeys: () => {}, noteAuto: () => {}, noteOffAuto: () => {} }
  const engine = { cycle: () => 0.1 }
  const performer = createPerformer({ midi, engine })
  const script = { track: 'test', steps: [{ bar: 0, cc: 13, value: 0.5 }, { bar: 2, cc: 13, value: 1 }] }
  performer.prime(script)
  assert.deepEqual([resets, sent], [1, [[13, 64 / 127]]])
  performer.start(script)
  performer.stop()
  assert.deepEqual([resets, sent], [1, [[13, 64 / 127]]])
  performer.start(script)
  performer.stop()
  assert.equal(resets, 2)
})

test('POST /take keeps the events; saving a replay answers its verdict, check-replay reports the bars', async () => {
  const { saveTake } = await import('./take-save.mjs')
  const track = '010-ambient-house'
  const button = [...controlsOf(tagSource(trackFileOf(track)))].find(([, c]) => c.button)[0]
  const capture = (events, script) => {
    const s = createSession({ track, trackHash: 'a'.repeat(40), cps: 0.5, recordedAt: '2026-11-17T20:00:00Z',
      ...script && { script } })
    s.messages.push({ port: script ? 'LCXL3 Auto' : 'LCXL3 1 MIDI In', status: 0xbf, data: [button, 127], time: 1,
      bar: 1 })
    s.events = events
    return s
  }
  const dir = path.join(PERFORM, track, 'takes')
  const written = []
  try {
    const original = saveTake(track, capture([bars(2), bars(4).slice(8)]))
    written.push(original.body.id)
    const take = JSON.parse(fs.readFileSync(path.join(PERFORM, track, original.body.id + '.json'), 'utf8'))
    assert.equal(take.take.events, path.basename(original.body.id) + '.events.jsonl')
    assert.equal(original.body.replay, undefined)
    const same = saveTake(track, capture([bars(4)], original.body.id))
    written.push(same.body.id)
    assert.equal(same.body.replay, 'reproduced: all 3 bars identical')
    const changed = bars(4).map(e => e.cycle === 2 ? { ...e, value: { ...e.value, gain: 0 } } : e)
    const other = saveTake(track, capture([changed], original.body.id))
    written.push(other.body.id)
    assert.equal(other.body.replay, 'NOT reproduced: 1 of 3 bars differ (bar 3)')
    const lines = reportLines(checkReplay(track, other.body.id))
    assert.ok(lines.some(line => line.startsWith('  bar 3: 1 events with other gain')), lines.join('\n'))
    assert.match(reportLines(checkReplay(track, original.body.id))[1], /cannot check: not a replay/)
  } finally {
    for (const file of written.flatMap(id => [id + '.json', id + '.events.jsonl']))
      fs.rmSync(path.join(PERFORM, track, file), { force: true })
    if (fs.existsSync(dir) && !fs.readdirSync(dir).length) fs.rmdirSync(dir)
  }
})
