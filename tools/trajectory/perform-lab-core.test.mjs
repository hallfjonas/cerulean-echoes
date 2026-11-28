// The Tracks lab's core (perform-lab-core.mjs): every move compiles to steps check-perform accepts on a real track,
// a step edit survives a parameter change and follows its move, a deleted step stays deleted, bars are 0-based and
// ranges half-open, the lab's own warnings, ramps cut by the next step, the section helpers, and the importer: it
// recognises the moves, and every script and take in perform/ (takes only where check-perform accepts them) compiles
// back to its steps, compared per control in bar order. The stems: a CC's column and stem, the Moves row of a move,
// the moves that fit a row or a lane, a move dragged to another stem, the busiest stem of a section.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import path from 'path'
import { PERFORM, checkScript, controlsOf, scTrackFileOf, tagSource } from './check-perform.mjs'
import { MAX_AT_ONCE, MOVES, busiestStem, checkLab, columnOf, compileMoves, compileTagged, controlKey, cutRamps,
  fitSections, importScript, insertSection, moveEdge, moveRow, moveText, movesFor, movesIn, newMove, newSection,
  removeSection, retarget, sectionOf, spanOf, stemOf, stemsOf, toScript } from './perform-lab-core.mjs'

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

test('perform lab: a CC’s column, the Moves row of a move', () => {
  assert.deepEqual(columnOf(5), { mode: 1, col: 1 })
  assert.deepEqual(columnOf(36), { mode: 1, col: 8 })
  assert.deepEqual(columnOf(53), { mode: 2, col: 1 })
  assert.deepEqual(columnOf(100), { mode: 2, col: 8 })
  assert.equal(columnOf(1), null)
  const few = new Map([[5, { name: '1 Kick Level', button: false }],
    [13, { name: '1 Kick Brightness', button: false }], [36, { name: 'Global Tension', button: false }]])
  assert.equal(moveRow({ kind: 'enter', p: { cc: 5 } }, few).title, '1 Kick')
  assert.equal(moveRow({ kind: 'control', p: { cc: 13 } }, few).title, '1 Kick', 'a knob shares its stem’s row')
  assert.equal(moveRow({ kind: 'build', p: { cc: 36 } }, few).title, 'Global')
  assert.equal(moveRow({ kind: 'layers', p: { ccs: [5] } }, few).title, 'Layers')
  assert.equal(moveRow({ kind: 'handMade', p: { steps: [{ at: 0, keys: 'c4' }] } }, few).title, 'Keys')
  assert.equal(moveRow({ kind: 'handMade', p: { steps: [{ at: 0, lk: 1, value: 1 }] } }, few).title, 'LK knobs')
  assert.ok(moveRow({ kind: 'build', p: { cc: 36 } }, few).rank < moveRow({ kind: 'enter', p: { cc: 5 } }, few).rank,
    'Global first')
})

test('perform lab: one stem order, titled by the fader; a Mode 2 twin says its mode', () => {
  const few = new Map([[5, { name: '1 Kick Level', button: false }], [13, { name: '1 Kick Brightness' }],
    [11, { name: '7 Perc Level' }], [53, { name: '1 Chords Level' }], [12, { name: 'Global Master' }],
    [36, { name: 'Global Tension' }], [37, { name: '1 Kick Pattern', button: true }]])
  const keys = ['lk:21', 'pad', 53, 'keys', 11, 13, 36, 5, 'layers']
  assert.deepEqual(keys.map(key => stemOf(key, few)).sort((a, b) => a.rank - b.rank).map(stem => stem.title),
    ['Global', 'Layers', '1 Kick', '1 Kick', '7 Perc', '1 Chords', 'Keys', 'Pads', 'LK knobs'])
  assert.equal(stemOf(29, few).title, '1 Kick', 'a control the track does not name stays in its column')
  assert.equal(stemOf(13, few).id, stemOf(37, few).id, 'knobs and buttons share their fader’s stem')
  const twins = new Map([[7, { name: '3 Lead Level' }], [55, { name: '3 Lead Level' }]])
  assert.deepEqual([stemOf(7, twins).title, stemOf(55, twins).title], ['3 Lead', '3 Lead (Mode 2)'])
})

const nameOf = cc => controls.get(cc).name
const fitsOf = target => movesFor(target, controls).map(fit => `${fit.kind} ${fit.p.cc ? nameOf(fit.p.cc) : fit.p.dir}`)

test('perform lab: every stem with controls is a Moves row, empty ones too', () => {
  const stems = stemsOf(controls).map(stem => stem.id)
  assert.deepEqual(stems.slice(0, 3), ['global', 'layers', '1:1'])
  assert.equal(stems.length, 2 + 14, 'Global, Layers and the 14 columns of 009-house')
  assert.ok(stems.every(id => movesFor(id, controls).length), 'each row has moves to offer')
})

test('perform lab: the moves that fit a row or a lane', () => {
  assert.deepEqual(fitsOf('global'), ['build Global Tension', 'fogDip Global Fog', 'break Global Break',
    'press Global Chapter', 'control Global Master', 'control Global Thin', 'control Global Fog',
    'control Global Tension'], 'Global once: its Mode 2 aliases are left out')
  assert.deepEqual(fitsOf('1:4'), ['enter 4 Bass Level', 'leave 4 Bass Level', 'control 4 Bass Brightness',
    'control 4 Bass Space', 'control 4 Bass Sound', 'control 4 Bass Level', 'build 4 Bass Brightness',
    'build 4 Bass Space', 'build 4 Bass Sound', 'press 4 Bass Pattern', 'press 4 Bass Octave'])
  assert.deepEqual(fitsOf('2:1').slice(0, 1), ['enter 1 Chords Level'], 'a Mode 2 column on its own CCs')
  assert.deepEqual(fitsOf('layers'), ['layers in', 'layers out'])
  assert.deepEqual(fitsOf(8), ['enter 4 Bass Level', 'leave 4 Bass Level', 'control 4 Bass Level'])
  assert.deepEqual(fitsOf(12), ['control Global Master', 'build Global Master'])
  assert.deepEqual(fitsOf(68), ['control Global Fog', 'build Global Fog', 'fogDip Global Fog'],
    'a Mode 2 alias lane adds on Mode 1')
  assert.equal(movesFor(68, controls)[0].p.cc, 20)
  assert.deepEqual(fitsOf(52), ['press Global Break', 'break Global Break'])
  assert.deepEqual(fitsOf(40), ['press 4 Bass Pattern'])
  for (const target of ['keys', 'pad', 'lk:1', 'lk', 'handMade']) assert.deepEqual(fitsOf(target), [], target)
})

test('perform lab: every move from a row or a lane passes check-perform', () => {
  const targets = [...stemsOf(controls).map(stem => stem.id), ...controls.keys()]
  const moves = targets.flatMap(target => movesFor(target, controls)).map(fit => newMove(fit.kind, 8, controls, fit.p))
  for (const move of moves) assert.deepEqual(check(labOf([move])).errors, [], JSON.stringify(move))
})

test('perform lab: a move dragged to another stem keeps its place on the LC', () => {
  const to = (move, stem) => {
    const result = retarget(move, stem, controls)
    return result.move ? nameOf(result.move.p.cc) : result.reason
  }
  const enter = newMove('enter', 4, controls, { cc: 5 })
  assert.equal(to(enter, '1:5'), '5 Clap Level')
  assert.equal(to(enter, '2:1'), '1 Chords Level', 'across modes')
  assert.equal(to(enter, 'global'), 'Enter works on a stem’s Level only')
  const punch = newMove('control', 4, controls, { cc: 29 })
  assert.equal(to(punch, '1:2'), '2 Fx Motion', 'row 3 under its own name')
  assert.equal(to(punch, '2:7'), '7 Lead Complexity')
  assert.equal(retarget(newMove('control', 4, controls, { cc: 77 }), 'global', controls).move.p.cc, 36,
    'into Global on the Mode 1 CC')
  assert.equal(to(newMove('fogDip', 4, controls), '1:1'), 'Fog dip works on Global Fog only')
  assert.equal(to(newMove('break', 4, controls), '1:1'), 'Break works on Global Break only')
  assert.equal(to(newMove('layers', 4, controls), '1:1'), 'Layers stays in the Layers row')
  assert.equal(to(enter, 'layers'), 'Enter does not fit the Layers row')
  assert.match(to(newMove('handMade', 4, controls, { steps: [{ at: 0, cc: 13, value: 0.5 }] }), '1:2'), /Hand-made/)
  assert.equal(retarget(enter, '1:1', controls).move, enter, 'its own stem: unchanged')
  const edited = { ...newMove('build', 4, controls, { cc: 13 }), edits: { 1: { at: 6 } } }
  const moved = retarget(edited, '1:6', controls).move
  assert.equal(nameOf(moved.p.cc), '6 Hats Brightness')
  assert.deepEqual(moved.edits, { 1: { at: 6 } }, 'edits stay')
  assert.equal(compileMoves([moved])[1].bar, 10)
})

test('perform lab: the busiest stem of a section', () => {
  const lab = labOf([newMove('enter', 2, controls, { cc: 8 }), newMove('control', 4, controls, { cc: 16 }),
    newMove('build', 6, controls), newMove('enter', 20, controls, { cc: 5 }),
    newMove('handMade', 3, controls, { steps: [{ at: 0, keys: 'c4' }] })])
  assert.equal(busiestStem(lab, sections[0], controls), '1:4')
  assert.equal(busiestStem(lab, sections[1], controls), '1:1')
  assert.equal(busiestStem(labOf([]), sections[0], controls), null)
})
