// The Tracks lab's core (perform-lab-core.mjs): every move compiles to steps check-perform accepts on a real track,
// a step edit survives a parameter change and follows its move, a deleted step stays deleted, bars are 0-based and
// ranges half-open, the lab's own warnings, ramps cut by the next step, the section helpers, and the importer: it
// recognises the moves, and every script and take in perform/ (takes only where check-perform accepts them) compiles
// back to its steps, compared per control in bar order.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import path from 'path'
import { PERFORM, checkScript, controlsOf, scTrackFileOf, tagSource } from './check-perform.mjs'
import { MAX_AT_ONCE, MOVES, checkLab, compileMoves, compileTagged, controlKey, cutRamps, fitSections, importScript,
  insertSection, moveEdge, moveText, movesIn, newMove, newSection, removeSection, sectionOf, spanOf, toScript }
  from './perform-lab-core.mjs'

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
    [{ bar: 7.5, press: 52 }, { bar: 11.5, press: 52 }], 'pressed half a bar early, so Break takes over on bar 8')
  assert.deepEqual(compileMoves([newMove('press', 0, controls)]), [{ bar: 0, press: 44 }], 'never before bar 0')
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
  const outside = labOf([newMove('control', 64, controls)])
  assert.ok(check(outside).errors.some(error => /in no section|ends after bar 64/.test(error)),
    'a step at the end bar is outside the script')
})

test('perform lab: steps come out in bar order, the script has only script v2 fields', () => {
  const lab = labOf([newMove('press', 30, controls), newMove('enter', 2, controls), newMove('leave', 20, controls)])
  assert.deepEqual(toScript(lab).steps.map(step => step.bar), [2, 20, 29.5])
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

test('perform lab: a step inside the ramp before it on the same control is a cut', () => {
  const steps = [{ bar: 0, cc: 36, value: 1, ramp: 8 }, { bar: 2, cc: 12, value: 0.5 }, { bar: 4, cc: 36, value: 0 },
    { bar: 8, cc: 12, value: 1, ramp: 4 }, { bar: 12, cc: 12, value: 0 }, { bar: 9, press: 44 }]
  assert.deepEqual(cutRamps(steps), [{ key: 36, bar: 4 }], 'a step where the ramp ends is no cut, presses are none')
})

test('perform lab: sections are cut around an inserted one, a removed one leaves no gap, edges keep a bar', () => {
  const base = [{ id: 'a', name: 'A', from: 0, to: 16 }, { id: 'b', name: 'B', from: 16, to: 32 }]
  const inserted = insertSection(base, newSection({ name: 'N', from: 4, to: 12 }))
  assert.deepEqual(inserted.map(({ name, from, to }) => [name, from, to]),
    [['A', 0, 4], ['N', 4, 12], ['A', 12, 16], ['B', 16, 32]])
  assert.equal(inserted[0].id, 'a')
  assert.notEqual(inserted[2].id, 'a', 'the cut-off part is a section of its own')
  assert.deepEqual(insertSection(base, newSection({ name: 'N', from: 0, to: 16 })).map(s => s.name), ['N', 'B'])
  assert.deepEqual(removeSection(base, 'b').map(({ id, from, to }) => [id, from, to]), [['a', 0, 32]])
  assert.deepEqual(removeSection(base, 'a').map(({ id, from, to }) => [id, from, to]), [['b', 0, 32]])
  assert.deepEqual(moveEdge(base, 0, 20).map(({ from, to }) => [from, to]), [[0, 20], [20, 32]])
  assert.deepEqual(moveEdge(base, 0, 40).map(({ from, to }) => [from, to]), [[0, 31], [31, 32]])
  assert.deepEqual(fitSections(base, 24).map(({ from, to }) => [from, to]), [[0, 16], [16, 24]])
  assert.deepEqual(fitSections(base, 12).map(({ from, to }) => [from, to]), [[0, 12]])
  assert.deepEqual(fitSections(base, 48).map(({ from, to }) => [from, to]), [[0, 16], [16, 48]])
})

const perControl = steps => {
  const lists = new Map()
  for (const step of [...steps].sort((a, b) => a.bar - b.bar)) {
    const key = String(controlKey(step))
    lists.set(key, [...lists.get(key) ?? [], JSON.stringify(Object.keys(step).sort().map(k => [k, step[k]]))])
  }
  return Object.fromEntries([...lists].sort())
}

test('perform lab: an imported script keeps its meta and sections, one section when it has none', () => {
  const script = { track: trackId, title: 'T', bars: 32, mood: 'calm', sections: [
    { name: 'A', from: 0, to: 16, intent: 'in' }, { name: 'B', from: 16, to: 32 }], steps: [{ bar: 2, press: 44 }] }
  const lab = importScript(script, controls)
  assert.deepEqual([lab.title, lab.bars, lab.mood], ['T', 32, 'calm'])
  assert.deepEqual(lab.sections.map(({ name, from, to, intent }) => [name, from, to, intent]),
    [['A', 0, 16, 'in'], ['B', 16, 32, undefined]])
  const plain = importScript({ track: trackId, steps: [{ bar: 3, cc: 5, value: 1, ramp: 2 }] }, controls)
  assert.deepEqual([plain.bars, plain.sections.map(({ from, to }) => [from, to])], [5, [[0, 5]]],
    'no sections: one over the whole length, which ends with the last step')
})

test('perform lab: the importer recognises the moves, Launchkey steps stay Hand-made', () => {
  const steps = [
    { bar: 0, cc: 5, value: 0.7, ramp: 2 }, { bar: 16, cc: 5, value: 0, ramp: 4 },
    { bar: 4, cc: 6, value: 0.6, ramp: 2 }, { bar: 8, cc: 7, value: 0.6, ramp: 2 },
    { bar: 12, cc: 8, value: 0.6, ramp: 2 },
    { bar: 20, cc: 36, value: 0.9, ramp: 8 }, { bar: 28, cc: 36, value: 0 },
    { bar: 24, cc: 20, value: 0.6, ramp: 4 }, { bar: 32, cc: 20, value: 0, ramp: 4 },
    { bar: 40, press: 52 }, { bar: 48, press: 52 }, { bar: 36, press: 44 },
    { bar: 10, cc: 13, value: 0.5 }, { bar: 50, cc: 28, value: 0.8, ramp: 4 }, { bar: 60, cc: 28, value: 0 },
    { bar: 2.5, keys: 'c4 e4', velocity: 0.6 }, { bar: 17.3333, lk: 1, value: 1 }]
  const lab = importScript({ track: trackId, bars: 64, steps }, controls)
  assert.deepEqual(lab.moves.map(move => move.kind), ['enter', 'handMade', 'layers', 'control', 'leave',
    'handMade', 'build', 'fogDip', 'press', 'break', 'control', 'control'])
  assert.deepEqual(lab.moves.find(move => move.kind === 'layers').p, { dir: 'in', ccs: [6, 7, 8], every: 4, over: 2,
    to: 0.6 })
  assert.deepEqual(lab.moves.find(move => move.kind === 'fogDip').p, { cc: 20, to: 0.6, over: 4, hold: 4, back: 4 })
  assert.deepEqual(lab.moves.find(move => move.kind === 'break').p, { cc: 52, length: 8 })
  assert.equal(lab.moves.find(move => move.kind === 'break').bar, 40.5, 'a press on bar 40 takes over on 41')
  assert.equal(importScript({ track: trackId, bars: 8, steps: [{ bar: 3.5, press: 44 }] }, controls).moves[0].bar, 4,
    'pressed half a bar early: the move sits on the bar where the button takes over')
  assert.deepEqual(perControl(compileMoves(lab.moves)), perControl(steps))
  assert.equal(lab.moves.filter(move => move.kind === 'build').length, 1,
    'a ramp whose jump to 0 comes later than its end is not a Build')
})

test('perform lab: every script and take in perform/ compiles back to its steps', () => {
  const tracks = fs.readdirSync(PERFORM, { withFileTypes: true }).filter(entry => entry.isDirectory())
  let count = 0
  for (const { name: track } of tracks) {
    const trackControls = controlsOf(tagSource(scTrackFileOf(track)))
    for (const dir of [path.join(PERFORM, track), path.join(PERFORM, track, 'takes')]) {
      if (!fs.existsSync(dir)) continue
      for (const file of fs.readdirSync(dir).filter(f => f.endsWith('.json') && !f.endsWith('.lab.json'))) {
        const script = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'))
        if (dir.endsWith('takes') && checkScript(script, trackControls, track).length) continue
        const lab = importScript(script, trackControls)
        assert.deepEqual(perControl(compileMoves(lab.moves)), perControl(script.steps), `${track}/${file}`)
        count++
      }
    }
  }
  assert.ok(count >= 15, `${count} scripts`)
})
