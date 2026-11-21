// Feature tests for knobs as data: the sound's parameters, the presets, a built knob, and a knob change on a stem.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import { checkFiles, libraryFiles, repoRoot } from './check-stems.mjs'
import { buildKnob, knobPresets, soundParams, withKnob } from './knob.mjs'

test('a sound lists its parameters with bounds where it declares them, and the stem parameters', () => {
  const params = soundParams('kick909')
  assert.deepEqual(params.find(p => p.param === 'body').range, [24, 48])
  assert.equal(params.find(p => p.param === 'lo').curve, 'exp')
  for (const stemParam of ['space', 'echo', 'pan']) assert.ok(params.some(p => p.param === stemParam))
  assert.throws(() => soundParams('nope'), /no sound/)
})

test('every preset builds a knob', () => {
  const key = { brightness: 'k1', space: 'k2' }
  for (const id of Object.keys(knobPresets())) assert.ok(buildKnob(key[id] ?? 'k3', { preset: id }).param, id)
})

test('buildKnob takes a preset and what the user changed, and refuses broken knobs', () => {
  const knob = buildKnob('k3', { preset: 'echo', label: 'Wet', range: [0, 0.5], default: 0.25 })
  assert.deepEqual(knob, { label: 'Wet', about: 'dry ↔ echo.', param: 'echo', range: [0, 0.5], default: 0.25 })
  assert.throws(() => buildKnob('k3', { preset: 'echo', range: [0, 0] }), /same/)
  assert.throws(() => buildKnob('k3', { preset: 'echo', curve: 'exp', range: [0, 1] }), /above 0/)
  assert.throws(() => buildKnob('k3', { preset: 'echo', default: 2 }), /default/)
  assert.throws(() => buildKnob('k1', { preset: 'brightness', label: 'Shine' }), /must be "Brightness"/)
  assert.equal(buildKnob('k1', { preset: 'echo', label: 'Wet' }).label, 'Wet')
  assert.throws(() => buildKnob('k3', { preset: 'brightness' }), /reserved/)
  assert.throws(() => buildKnob('k3', { preset: 'echo', label: '  ' }), /1-20 characters/)
  assert.throws(() => buildKnob('k9', { preset: 'echo' }), /not a knob/)
})

test('a label gets its capital letter, an error names the knob the way the player does', () => {
  assert.equal(buildKnob('k1', { preset: 'echo', label: 'pan' }).label, 'Pan')
  assert.throws(() => buildKnob('k1', { preset: 'brightness', label: 'shine' }), /^Error: Knob 1 \(top row\): label must be "Brightness"/)
})

test('withKnob changes a copy: the knob is replaced, nothing else', () => {
  const file = libraryFiles(repoRoot).find(f => f.endsWith('flute-brightness-space-complexity-pattern-echo-throw.stem'))
  const stem = JSON.parse(fs.readFileSync(file, 'utf8'))
  const next = withKnob(stem, 'k3', buildKnob('k3', { preset: 'echo', label: 'Wet' }))
  assert.equal(stem.controls.k3.label, 'Complexity')
  assert.equal(next.controls.k3.label, 'Wet')
  assert.deepEqual(next.controls.k1, stem.controls.k1)
})

test('the library passes the check with the new default field', () => {
  for (const { file, errors } of checkFiles(libraryFiles(repoRoot), repoRoot)) assert.deepEqual(errors, [], file)
})
