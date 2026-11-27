// Feature tests for the @ctl lines of a stem track: made from its stems and frame, read by check-perform like the
// comments of an SC track. (SC makes the same lines: compared in sc-test/sc.test.mjs.)
import test from 'node:test'
import assert from 'node:assert/strict'
import path from 'path'
import { repoRoot } from './check-stems.mjs'
import { trackTags } from './stem-tags.mjs'
import { controlsOf, tagSource, trackFileOf } from '../trajectory/check-perform.mjs'

const demo = path.join(repoRoot, 'sc', 'tracks', '090-stem-demo', '090-stem-demo.track')

test('stem track tags: six @ctl lines per stem, then the frame lines', () => {
  const lines = trackTags(demo).split('\n')
  assert.ok(lines.includes('// @col 16:4 4 Bass'))
  assert.ok(lines.includes('// @ctl 16:4.k3 Length | short ↔ long.'))
  assert.ok(lines.includes('// @ctl g.b1 Chapter | Vamp (Am9) ↔ Progression (Am9 D9).'))
  assert.equal(lines.filter(line => line.startsWith('// @ctl 16:1.')).length, 6)
})

test('check-perform finds a stem track and reads its controls from the stems', () => {
  assert.equal(trackFileOf('090-stem-demo'), demo)
  const controls = controlsOf(tagSource(demo))
  assert.deepEqual(controls.get(40), { name: '4 Bass Pattern', button: true })
  assert.deepEqual(controls.get(45), { name: '1 Kick Drop out', button: true })
  assert.deepEqual(controls.get(44), { name: 'Global Chapter', button: true })
  assert.equal(controls.get(9), undefined, 'an empty slot has no controls')
})
