// Feature tests for the Space Analyzer's render side: the setting as a scenario, the band measurement and the cache.
// Loose checks; the real render needs sclang and skips without it.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { BANDS, CELLS_PER_BAR, fromBase64, levelsOf } from './space-analysis.mjs'
import { ccsOf, footprintOf, renderStem, scenarioOf, settingOf, trackSlots } from './space-render.mjs'
import { findSclang } from './sc-link.mjs'
import { repoRoot } from '../stems/check-stems.mjs'

test('a column maps to its CCs, Mode 2 is 48 higher', () => {
  assert.deepEqual(ccsOf('1:1'), { fader: 5, k1: 13, k2: 21, k3: 29, b1: 37, b2: 45 })
  assert.deepEqual(ccsOf('1:7'), { fader: 11, k1: 19, k2: 27, k3: 35, b1: 43, b2: 51 })
  assert.equal(ccsOf('2:3').b1, 36 + 3 + 48)
  assert.throws(() => ccsOf('3:1'))
})

test('a setting keeps to its limits and defaults to the reference state', () => {
  assert.deepEqual(settingOf(), { pattern: 0, k1: 0, k2: 0, k3: 0, fader: 1, b2: false })
  const odd = settingOf({ pattern: 2.4, k1: 7, k2: -1, fader: 'x', b2: 1 })
  assert.deepEqual(odd, { pattern: 2, k1: 1, k2: 0, k3: 0, fader: 1, b2: true })
})

test('the scenario carries the setting: levels at bar 0, one press per pattern step', () => {
  const scenario = scenarioOf({ tempo: 124, slot: '2:2', setting: settingOf({ pattern: 2, k1: 0.5, fader: 0.8 }), bars: 4 })
  assert.equal(scenario.bpm, 124)
  assert.equal(scenario.cycles, 4)
  assert.equal(scenario.cc[12], 1)
  assert.equal(scenario.cc[ccsOf('2:2').fader], 0.8)
  assert.equal(scenario.cc[ccsOf('2:2').k1], 0.5)
  assert.equal(scenario.cc[ccsOf('2:2').k2], undefined)
  assert.equal(scenario.events.filter(event => event.v === 1 && event.cc === ccsOf('2:2').b1).length, 2)
  assert.equal(scenarioOf({ tempo: 124, slot: '1:1', setting: settingOf(), bars: 1 }).events.length, 0)
})

test('a tone lands in its band during its bars only', () => {
  const rate = 48000
  const tempo = 120
  const bar = rate * 60 / tempo * 4
  const left = new Float32Array(bar * 2)
  for (let i = 0; i < bar; i++) left[i] = 0.5 * Math.sin(2 * Math.PI * 1000 * i / rate)
  const levels = levelsOf(footprintOf(left, left, rate, { tempo, bars: 2 }))
  const cellAt = cell => Array.from(levels.subarray(cell * BANDS, (cell + 1) * BANDS))
  const strongest = cellAt(10).indexOf(Math.max(...cellAt(10)))
  const expected = (BANDS - 1) * Math.log(1000 / 30) / Math.log(16000 / 30)
  assert.ok(Math.abs(strongest - expected) <= 1.5, `band ${strongest}, expected about ${expected}`)
  assert.ok(Math.max(...cellAt(10)) > -15)
  assert.ok(Math.max(...cellAt(CELLS_PER_BAR + 12)) < -80)
})

test('a left-only tone leaves the right channel silent', () => {
  const rate = 48000
  const left = Float32Array.from({ length: rate * 2 }, (_, i) => 0.5 * Math.sin(2 * Math.PI * 440 * i / rate))
  const { l, r } = footprintOf(left, new Float32Array(left.length), rate, { tempo: 120, bars: 1 })
  assert.ok(Math.max(...l) > 150)
  assert.equal(Math.max(...r), 0)
})

test('stem tracks list their stems with patterns and control names', () => {
  const info = trackSlots('009-house-2', repoRoot)
  assert.equal(info.tempo, 124)
  const kick = info.slots.find(entry => entry.slot === '1:1')
  assert.equal(kick.role, 'kick')
  assert.ok(kick.patterns.length >= 2)
  assert.equal(kick.controls.k1, 'Brightness')
  assert.throws(() => trackSlots('no-such-track', repoRoot))
})

test('a rendered kick sits low, on the beat, and the second run comes from the cache', { skip: !findSclang() }, async () => {
  const cacheDir = fs.mkdtempSync(path.join(os.tmpdir(), 'space-test-'))
  try {
    const args = { track: '009-house-2', slot: '1:1', setting: {}, bars: 2, cacheDir }
    const first = await renderStem(args)
    assert.equal(first.cached, false)
    assert.equal(first.footprint.cells, 2 * CELLS_PER_BAR)
    const levels = levelsOf({ l: fromBase64(first.footprint.l), r: fromBase64(first.footprint.r) })
    const lowEnergy = cell => Math.max(...levels.subarray(cell * BANDS, cell * BANDS + 20))
    const onBeat = Math.max(...[0, 1, 8, 9, 16, 17, 24, 25].map(lowEnergy))
    const offBeat = Math.min(...[4, 12, 20, 28].map(lowEnergy))
    assert.ok(onBeat > offBeat + 10, `on the beat ${onBeat} dB, off it ${offBeat} dB`)
    const high = Math.max(...levels.subarray(0, 2 * CELLS_PER_BAR * BANDS).filter((_, i) => i % BANDS >= 50))
    assert.ok(high < onBeat)
    assert.equal((await renderStem(args)).cached, true)
    assert.equal((await renderStem({ ...args, setting: { k1: 1 } })).cached, false)
  } finally {
    fs.rmSync(cacheDir, { recursive: true, force: true })
  }
})
