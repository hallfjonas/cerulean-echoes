// The pure parts of the Tracks lab page (perform-lab-ui.mjs): ruler marks, snap, the fitted bar width, a control's
// value at a bar as the performer plays it, the lane path, a lane step's room, a CC's column and the Moves row of a
// move.
import test from 'node:test'
import assert from 'node:assert/strict'
import { columnOf, fitPpb, lanePath, laneRoom, minutesOf, moveRow, packLanes, rulerMarks, segmentsOf, snap, valueAt }
  from './perform-lab-ui.mjs'

test('perform lab ui: ruler marks every 4, 8 or 16 bars by width, snap, fitted width', () => {
  assert.deepEqual(rulerMarks(16, 12), [0, 4, 8, 12, 16])
  assert.deepEqual(rulerMarks(32, 6), [0, 8, 16, 24, 32])
  assert.deepEqual(rulerMarks(40, 3), [0, 16, 32])
  assert.equal(snap(5.4, 4), 4)
  assert.equal(snap(6.1, 4), 8)
  assert.equal(snap(1.13, 0.25), 1.25)
  assert.equal(fitPpb(640, 64), 10)
  assert.equal(fitPpb(10000, 8), 24, 'at most 24 px a bar')
  assert.equal(fitPpb(100, 400), 2, 'at least 2 px a bar')
  assert.equal(minutesOf(64, 120), '2:08')
})

test('perform lab ui: a control’s value at a bar and its lane path', () => {
  const steps = [{ bar: 4, value: 1, ramp: 4 }, { bar: 12, value: 0.2 }]
  assert.equal(valueAt(steps, 2), 0)
  assert.equal(valueAt(steps, 6), 0.5, 'half-way up the ramp')
  assert.equal(valueAt(steps, 10), 1)
  assert.equal(valueAt(steps, 12), 0.2, 'a jump at its bar')
  const path = lanePath(steps, bar => bar * 10, value => 100 - value * 100, 200)
  assert.equal(path, 'M0,100L40,100L80,0L120,0L120,80L200,80')
})

test('perform lab ui: a step inside a running ramp cuts it, as the performer plays it', () => {
  const steps = [{ bar: 0, value: 1, ramp: 8 }, { bar: 4, value: 0 }]
  assert.deepEqual(segmentsOf(steps).map(segment => segment.from), [0, 0.5], 'the second step starts from 0.5')
  assert.equal(valueAt(steps, 6), 0, 'the ramp no longer runs after bar 4')
  const path = lanePath(steps, bar => bar * 10, value => 100 - value * 100, 100)
  assert.equal(path, 'M0,100L0,100L40,50L40,50L40,100L100,100', 'the ramp line ends at the cut, no line back')
})

test('perform lab ui: a lane step stays between its neighbours', () => {
  const lane = [{ step: { bar: 0, value: 1, ramp: 4 } }, { step: { bar: 8, value: 0.5 } },
    { step: { bar: 12, value: 0 } }]
  assert.deepEqual(laneRoom(lane, 1, 32), [4, 12], 'after the ramp before it, before the step after it')
  assert.deepEqual(laneRoom(lane, 0, 32), [0, 8])
  assert.deepEqual(laneRoom(lane, 2, 32), [8, 32])
})

test('perform lab ui: moves that overlap in a row stack on sub-lanes, touching ones share one', () => {
  const lanes = boxes => boxes.map(box => packLanes(boxes).lane.get(box.id))
  assert.deepEqual(lanes([{ id: 'a', left: 0, right: 50 }, { id: 'b', left: 40, right: 60 }]), [0, 1])
  assert.deepEqual(lanes([{ id: 'a', left: 0, right: 50 }, { id: 'b', left: 50, right: 60 }]), [0, 0])
  const enterThenPresses = [{ id: 'enter', left: 96, right: 122 }, { id: 'press1', left: 114, right: 130 },
    { id: 'press2', left: 120, right: 136 }]
  assert.deepEqual(lanes(enterThenPresses), [0, 1, 2], 'a ramp and two presses right after it')
  assert.equal(packLanes(enterThenPresses).count, 3)
  assert.equal(packLanes([]).count, 1, 'an empty row keeps one lane')
  const same = [{ id: 'b', left: 10, right: 20 }, { id: 'a', left: 10, right: 20 }]
  assert.deepEqual(lanes(same), [1, 0], 'equal left edges go by id, whatever the order')
})

test('perform lab ui: a CC’s column, the Moves row of a move', () => {
  assert.deepEqual(columnOf(5), { mode: 1, col: 1 })
  assert.deepEqual(columnOf(36), { mode: 1, col: 8 })
  assert.deepEqual(columnOf(53), { mode: 2, col: 1 })
  assert.deepEqual(columnOf(100), { mode: 2, col: 8 })
  assert.equal(columnOf(1), null)
  const controls = new Map([[5, { name: '1 Kick Level', button: false }],
    [13, { name: '1 Kick Brightness', button: false }], [36, { name: 'Global Tension', button: false }]])
  assert.equal(moveRow({ kind: 'enter', p: { cc: 5 } }, controls).key, '1 Kick')
  assert.equal(moveRow({ kind: 'control', p: { cc: 13 } }, controls).key, '1 Kick', 'a knob shares its stem’s row')
  assert.equal(moveRow({ kind: 'build', p: { cc: 36 } }, controls).key, 'Global')
  assert.equal(moveRow({ kind: 'layers', p: { ccs: [5] } }, controls).key, 'Layers')
  assert.equal(moveRow({ kind: 'handMade', p: { steps: [{ at: 0, keys: 'c4' }] } }, controls).key, 'Keys')
  assert.equal(moveRow({ kind: 'handMade', p: { steps: [{ at: 0, lk: 1, value: 1 }] } }, controls).key, 'LK knobs')
  assert.ok(moveRow({ kind: 'build', p: { cc: 36 } }, controls).rank < moveRow({ kind: 'enter', p: { cc: 5 } },
    controls).rank, 'Global first')
})
