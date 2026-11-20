// Tests for take.mjs with hand-made message lists. usage (in tools/): npm test
import assert from 'node:assert/strict'
import fs from 'fs'
import path from 'path'
import test from 'node:test'
import { compile } from './autoperform.mjs'
import { PERFORM, checkScript, controlsOf, trackFileOf } from './check-perform.mjs'
import { addMessage, createRecorder, createSession, noteName, thin, toScript } from './take.mjs'

const LC = 'LCXL3 1 MIDI In'
const LK = 'Launchkey MK4 25 MIDI In'
const KNOB = 13, FADER = 5, BUTTON = 37
const controls = new Map([[KNOB, { button: false }], [FADER, { button: false }], [BUTTON, { button: true }]])

const session = (messages, snapshot = []) => {
  const s = createSession({ track: 'test', trackHash: 'abc', cps: 0.5, recordedAt: '2026-11-17T20:00:00Z', snapshot })
  for (const [port, status, a, b, bar, time = bar * 2000] of messages)
    addMessage(s, { port, status, data: [a, b], time }, bar)
  return s
}

const valueAt = (curve, bar) => {
  let value
  for (const segment of curve) {
    if (segment.bar > bar) break
    const progress = segment.ramp ? Math.min(1, (bar - segment.bar) / segment.ramp) : 1
    value = segment.from + (segment.to - segment.from) * progress
  }
  return value
}

test('note names in Strudel spelling', () => {
  assert.equal(noteName(60), 'c4')
  assert.equal(noteName(61), 'c#4')
  assert.equal(noteName(36), 'c2')
})

test('thinning keeps a line as two points and a corner as three', () => {
  const line = Array.from({ length: 50 }, (_, i) => ({ bar: i / 10, value: i / 49 }))
  assert.equal(thin(line).length, 2)
  const corner = [...line, ...line.slice(1).map(({ bar, value }) => ({ bar: bar + 4.9, value: 1 - value }))]
  assert.deepEqual(thin(corner).map(p => p.bar), [0, 4.9, 9.8])
})

test('a fader sweep becomes a jump and ramps that follow it within one MIDI step', () => {
  const sweep = Array.from({ length: 101 }, (_, i) => {
    const bar = 1 + i / 100
    return [LC, 0xbf, FADER, Math.round(127 * Math.sin(i / 100 * Math.PI / 2)), bar, 2000 + i * 20]
  })
  const script = toScript(session(sweep), controls)
  const steps = script.steps.filter(step => step.cc === FADER)
  assert.ok(steps.length < 15, `${steps.length} steps`)
  assert.deepEqual(steps[0], { bar: 1, cc: FADER, value: 0 })
  const curve = compile(script).curves.get(FADER)
  for (const [, , , byte, bar] of sweep)
    assert.ok(Math.abs(valueAt(curve, bar) - byte / 127) <= 1 / 127 + 1e-6, `bar ${bar}`)
})

test('a pause starts a new gesture: the value holds, then jumps', () => {
  const script = toScript(session([
    [LC, 0xbf, KNOB, 20, 1, 1000], [LC, 0xbf, KNOB, 21, 1.05, 1020],
    [LC, 0xbf, KNOB, 100, 5, 9000],
    [LC, 0xbf, KNOB, 101, 5.05, 9020], [LC, 0xbf, KNOB, 102, 5.05, 9030],
  ]), controls)
  assert.deepEqual(script.steps, [
    { bar: 1, cc: KNOB, value: 0.1575 },
    { bar: 1, cc: KNOB, value: 0.1654, ramp: 0.05 },
    { bar: 5, cc: KNOB, value: 0.7874 },
    { bar: 5, cc: KNOB, value: 0.8031, ramp: 0.05 },
  ])
})

test('buttons, keys, pads, Launchkey knobs, snapshot and dropped messages', () => {
  const snapshot = [
    { port: LC, cc: KNOB, value: 64 / 127, time: 1 },
    { port: 'LCXL3 2 MIDI In', cc: KNOB, value: 30 / 127, time: 2 },
    { port: LC, cc: FADER, value: 0, time: 1 },
    { port: LC, cc: BUTTON, value: 1, time: 1 },
    { port: LK, cc: 1, value: 1, time: 1 },
    { port: LK, cc: 105, value: 1, time: 1 },
  ]
  const script = toScript(session([
    [LC, 0xbf, BUTTON, 127, 2], [LC, 0xbf, BUTTON, 0, 2.05],
    [LC, 0xbf, 99, 50, 2.1],
    [LC, 0x90, 60, 100, 2.2],
    [LK, 0x90, 60, 127, 3], [LK, 0x90, 64, 64, 3.25], [LK, 0x90, 64, 0, 3.3], [LK, 0x80, 60, 0, 3.5],
    [LK, 0x99, 36, 100, 4], [LK, 0x89, 36, 0, 4.1], [LK, 0x99, 60, 90, 4.2],
    [LK, 0xb0, 24, 127, 6], [LK, 0xb0, 105, 127, 6],
  ], snapshot), controls)
  assert.deepEqual(script.steps, [
    { bar: 0, cc: KNOB, value: 0.2362 },
    { bar: 0, lk: 1, value: 1 },
    { bar: 2, press: BUTTON },
    { bar: 3, keys: 'c4', velocity: 1, length: 0.5 },
    { bar: 3.25, keys: 'e4', velocity: 0.504, length: 0.05 },
    { bar: 4, pad: 36, velocity: 0.787 },
    { bar: 4.2, keys: 'c4', velocity: 0.709 },
    { bar: 6, lk: 24, value: 1 },
  ])
  assert.equal(script.bars, 6)
  assert.deepEqual(script.take, { source: 'human', recordedAt: '2026-11-17T20:00:00Z', trackHash: 'abc', cps: 0.5,
    inputs: [LC, 'LCXL3 2 MIDI In', LK] })
})

test('source: virtual inputs only is auto, both is mixed and names the script', () => {
  const auto = session([['LCXL3 Auto', 0xbf, KNOB, 10, 1]])
  auto.script = 'journey'
  assert.equal(toScript(auto, controls).take.source, 'auto')
  assert.equal(toScript(auto, controls).take.script, 'journey')
  const mixed = session([['LCXL3 Auto', 0xbf, KNOB, 10, 1], [LC, 0xbf, KNOB, 20, 2]])
  assert.equal(toScript(mixed, controls).take.source, 'mixed')
  assert.equal(toScript(session([[LC, 0xbf, KNOB, 20, 2]]), controls).take.source, 'human')
})

test('the recorder keeps bars from the load cycle and starts a new session per load', () => {
  let listener, cycle = 12
  const midi = { onMessage: cb => { listener = cb }, heldCcs: () => [{ port: LC, cc: KNOB, value: 0.5, time: 1 }] }
  const recorder = createRecorder({ midi, engine: { cycle: () => cycle } })
  listener({ port: LC, status: 0xbf, data: [KNOB, 1], time: 0 })
  assert.equal(recorder.session(), null)
  recorder.start({ track: 'test', trackHash: 'abc', cps: 0.5 })
  cycle = 13.123456
  listener({ port: LC, status: 0xbf, data: [KNOB, 5], time: 1 })
  assert.equal(recorder.session().messages[0].bar, 1.1235)
  assert.equal(recorder.session().snapshot.length, 1)
  recorder.start({ track: 'test', trackHash: 'abc', cps: 0.5 })
  assert.equal(recorder.session().messages.length, 0)
})

test('a take on a live track passes check-perform (take meta and pad velocity left out until task 5)', () => {
  const track = '010-ambient-house'
  const real = controlsOf(fs.readFileSync(trackFileOf(track), 'utf8'))
  const button = [...real].find(([, c]) => c.button)[0]
  const knob = [...real].find(([, c]) => !c.button)[0]
  const s = session([
    ...Array.from({ length: 30 }, (_, i) => [LC, 0xbf, knob, i * 4, 1 + i / 20, 2000 + i * 20]),
    [LC, 0xbf, button, 127, 3], [LK, 0x90, 62, 100, 4], [LK, 0x99, 40, 100, 5], [LK, 0xb0, 21, 90, 6],
  ], [{ port: LC, cc: knob, value: 0.25, time: 1 }])
  s.track = track
  const { take, ...script } = toScript(s, real)
  script.steps = script.steps.map(step => step.pad === undefined ? step : { bar: step.bar, pad: step.pad })
  assert.ok(take)
  assert.deepEqual(checkScript(script, real, track), [])
})

test('POST /take: a live track gets a take in perform/<track>/takes/ that the catalogue lists', async () => {
  const { saveTake } = await import('./take-save.mjs')
  const { find } = await import('./catalogue.mjs')
  const track = '010-ambient-house'
  const real = controlsOf(fs.readFileSync(trackFileOf(track), 'utf8'))
  const button = [...real].find(([, c]) => c.button)[0]
  const s = session([[LC, 0xbf, button, 127, 3], [LK, 0x99, 40, 100, 5], [LK, 0x90, 62, 90, 6]])
  s.trackHash = 'a'.repeat(40)
  assert.equal(saveTake('lab-kick-kick-lab', s).status, 404)
  assert.equal(saveTake(track, { messages: [] }).status, 400)
  const { status, body } = saveTake(track, s)
  assert.equal(status, 200)
  assert.match(body.id, /^takes\/\d{4}-\d\d-\d\d-\d{6}-human(-\d+)?$/)
  const file = path.join(PERFORM, track, body.id + '.json')
  try {
    assert.deepEqual(body.problems, [])
    assert.equal(JSON.parse(fs.readFileSync(file, 'utf8')).steps.length, 3)
    assert.ok(find(track).scripts.includes(body.id))
  } finally {
    fs.rmSync(file)
  }
})
