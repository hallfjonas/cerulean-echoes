// The Tracks lab's core (perform-lab-core.mjs): every move compiles to steps check-perform accepts on a real track,
// a step edit survives a parameter change and follows its move, a deleted step stays deleted, bars are 0-based and
// ranges half-open, the lab's own warnings.
import test from 'node:test'
import assert from 'node:assert/strict'
import { checkScript, controlsOf, scTrackFileOf, tagSource } from './check-perform.mjs'
import { MAX_AT_ONCE, MOVES, checkLab, compileMoves, compileTagged, moveText, movesIn, newMove, sectionOf, spanOf,
  toScript } from './perform-lab-core.mjs'

const trackId = '009-house'
const controls = controlsOf(tagSource(scTrackFileOf(trackId)))
const sections = [{ id: 's1', name: 'Intro', from: 0, to: 16 }, { id: 's2', name: 'Groove', from: 16, to: 64 }]
const labOf = moves => ({ track: trackId, title: 'Test', bars: 64, sections, moves })
const check = lab => checkLab(lab, { controls, trackId, checkScript })
const handMadeSteps = [{ at: 0, cc: 13, value: 0.5 }, { at: 0.5, keys: 'a3 c4 e4', velocity: 0.7 },
  { at: 1, pad: 36 }, { at: 1, lk: 1, value: 0.8, ramp: 2 }]

test('perform lab: every move compiles to steps check-perform accepts', () => {
  for (const kind of Object.keys(MOVES)) {
    const move = newMove(kind, 20, controls, kind === 'handMade' ? { steps: handMadeSteps } : {})
    const steps = compileMoves([move])
    assert.ok(steps.length, `${kind} makes steps`)
    assert.deepEqual(check(labOf([move])).errors, [], `${kind}: ${JSON.stringify(steps)}`)
    assert.ok(moveText(move, controls), `${kind} has a text`)
  }
})

test('perform lab: defaults name the track’s controls', () => {
  const name = cc => controls.get(cc).name
  assert.equal(name(newMove('build', 0, controls).p.cc), 'Global Tension')
  assert.equal(name(newMove('fogDip', 0, controls).p.cc), 'Global Fog')
  assert.equal(name(newMove('break', 0, controls).p.cc), 'Global Break')
  assert.equal(name(newMove('press', 0, controls).p.cc), 'Global Chapter')
  assert.match(name(newMove('enter', 0, controls).p.cc), / Level$/)
  assert.deepEqual(compileMoves([newMove('break', 8, controls, { length: 4 })]),
    [{ bar: 8, press: 52 }, { bar: 12, press: 52 }])
  assert.deepEqual(compileMoves([newMove('control', 3, controls, { cc: 13, to: 0.5, over: 0 })]),
    [{ bar: 3, cc: 13, value: 0.5 }], 'no ramp field for a jump')
})

test('perform lab: an edit by step index survives a parameter change and moves with its move', () => {
  const move = newMove('layers', 16, controls, { ccs: [5, 6, 7], every: 4, over: 2 })
  move.edits = { 1: { at: 5, value: 0.3 } }
  assert.deepEqual(compileMoves([move]).map(step => [step.bar, step.cc, step.value]),
    [[16, 5, 0.6], [21, 6, 0.3], [24, 7, 0.6]])
  move.p.every = 8
  move.p.to = 0.9
  assert.deepEqual(compileMoves([move]).map(step => [step.bar, step.cc, step.value]),
    [[16, 5, 0.9], [21, 6, 0.3], [32, 7, 0.9]], 'the edited step keeps its edit, the others follow')
  move.bar = 24
  assert.deepEqual(compileMoves([move]).map(step => step.bar), [24, 29, 40], 'a dragged move takes its edit along')
  move.edits[0] = { ramp: 0 }
  assert.equal('ramp' in compileMoves([move])[0], false, 'ramp 0 removes the ramp')
})

test('perform lab: a deleted step stays deleted', () => {
  const move = newMove('fogDip', 8, controls)
  move.edits = { 1: { del: true } }
  assert.deepEqual(compileMoves([move]), [{ bar: 8, cc: 20, value: 0.6, ramp: 4 }])
  move.p.hold = 12
  move.p.to = 0.8
  assert.deepEqual(compileMoves([move]), [{ bar: 8, cc: 20, value: 0.8, ramp: 4 }])
  assert.deepEqual(compileTagged([move]).map(({ move: id, index }) => [id, index]), [[move.id, 0]])
})

test('perform lab: bars are 0-based, ranges half-open', () => {
  const lab = labOf([newMove('enter', 0, controls), newMove('press', 16, controls)])
  assert.equal(sectionOf(lab, 0).name, 'Intro')
  assert.equal(sectionOf(lab, 15.99).name, 'Intro')
  assert.equal(sectionOf(lab, 16).name, 'Groove', 'a section ends before its `to`')
  assert.equal(sectionOf(lab, 64), null)
  assert.deepEqual(movesIn(lab, sections[0]).map(move => move.kind), ['enter'])
  assert.deepEqual(movesIn(lab, sections[1]).map(move => move.kind), ['press'])
  assert.deepEqual(spanOf(newMove('enter', 0, controls, { over: 2 })), [0, 2])
  assert.equal(compileMoves(lab.moves)[0].bar, 0)
  const outside = labOf([newMove('press', 64, controls)])
  assert.ok(check(outside).errors.some(error => /in no section|ends after bar 64/.test(error)),
    'a step at the end bar is outside the script')
})

test('perform lab: steps come out in bar order, the script has only script v2 fields', () => {
  const lab = labOf([newMove('press', 30, controls), newMove('enter', 2, controls), newMove('leave', 20, controls)])
  assert.deepEqual(toScript(lab).steps.map(step => step.bar), [2, 20, 30])
  assert.deepEqual(Object.keys(toScript(lab)), ['track', 'title', 'bars', 'sections', 'steps'])
  assert.deepEqual(toScript(lab).sections[0], { name: 'Intro', from: 0, to: 16 })
})

test('perform lab: warnings for a section without moves and for too many moves at once', () => {
  assert.deepEqual(check(labOf([newMove('enter', 2, controls)])).warnings, ['Groove (bars 16→64) has no moves'])
  const crowd = Array.from({ length: MAX_AT_ONCE + 1 }, (_, i) =>
    newMove('control', 20, controls, { cc: 13 + i, to: 0.5, over: 4 }))
  const lab = labOf([newMove('enter', 2, controls), ...crowd])
  assert.deepEqual(check(lab).warnings, [`Groove (bars 16→64): ${MAX_AT_ONCE + 1} moves at once at bar 20`])
  assert.deepEqual(check(lab).errors, [])
})
