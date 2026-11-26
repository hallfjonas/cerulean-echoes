// Feature tests for the Space Analyzer maths: byte coding, coarser cells, which stems are active where.
// Loose checks on small synthetic grids.
import test from 'node:test'
import assert from 'node:assert/strict'
import { BANDS, CELLS_PER_BAR, FLOOR_DB, activeStems, bandHz, decodeDb, defaultColors, encodeDb, fromBase64, levelsOf,
  occupancy, peakDb, regrid, toBase64 } from './space-analysis.mjs'

const gridOf = (bars, fill) => {
  const levels = new Float32Array(bars * CELLS_PER_BAR * BANDS).fill(FLOOR_DB)
  for (let cell = 0; cell < bars * CELLS_PER_BAR; cell++) {
    for (let band = 0; band < BANDS; band++) {
      const level = fill(cell, band)
      if (level !== undefined) levels[cell * BANDS + band] = level
    }
  }
  return levels
}

test('bytes keep half a dB and travel as text', () => {
  assert.equal(decodeDb(encodeDb(-12.3)), -12.5)
  assert.equal(encodeDb(-200), 0)
  const bytes = Uint8Array.from({ length: 70000 }, (_, i) => i % 256)
  assert.deepEqual(fromBase64(toBase64(bytes)), bytes)
})

test('the band axis runs from 30 Hz to 16 kHz', () => {
  assert.equal(Math.round(bandHz(0)), 30)
  assert.equal(Math.round(bandHz(BANDS - 1)), 16000)
})

test('left and right add as power: two equal channels are 3 dB louder', () => {
  const l = new Uint8Array([encodeDb(-20)])
  const levels = levelsOf({ l, r: l })
  assert.ok(Math.abs(levels[0] - -17) < 0.2)
  assert.equal(levelsOf({ l: new Uint8Array([0]), r: new Uint8Array([0]) })[0], FLOOR_DB)
})

test('regrid keeps the peak of a cell and cuts the bar window', () => {
  const levels = gridOf(2, (cell, band) => cell === 5 && band === 3 ? -10 : undefined)
  const wholeBar = regrid(levels, { division: 1, from: 0, bars: 1 })
  assert.equal(wholeBar.length, BANDS)
  assert.equal(wholeBar[3], -10)
  const quarters = regrid(levels, { division: 4, from: 0, bars: 2 })
  assert.equal(quarters.length, 8 * BANDS)
  assert.equal(quarters[0 * BANDS + 3], -10)
  assert.equal(quarters[1 * BANDS + 3], FLOOR_DB)
  const secondBar = regrid(levels, { division: 32, from: 1, bars: 1 })
  assert.equal(Math.max(...secondBar), FLOOR_DB)
  const averaged = regrid(levels, { division: 1, from: 0, bars: 1, mode: 'power' })
  assert.ok(averaged[3] < -10 && averaged[3] > FLOOR_DB)
})

test('regrid past the rendered bars is silence', () => {
  const levels = gridOf(1, () => -5)
  const outside = regrid(levels, { division: 1, from: 3, bars: 1 })
  assert.equal(Math.max(...outside), FLOOR_DB)
})

test('occupancy counts the stems above the threshold and finds the loudest', () => {
  const kick = regrid(gridOf(1, (cell, band) => band < 8 ? -6 : undefined), { division: 1, from: 0, bars: 1 })
  const bass = regrid(gridOf(1, (cell, band) => band >= 4 && band < 16 ? -30 : undefined), { division: 1, from: 0, bars: 1 })
  const referenceDb = peakDb([kick, bass])
  assert.equal(referenceDb, -6)
  const tight = occupancy([kick, bass], { referenceDb, thresholdDb: 10 })
  assert.equal(tight.count[2], 1)
  assert.equal(tight.count[10], 0)
  const wide = occupancy([kick, bass], { referenceDb, thresholdDb: 40 })
  assert.equal(wide.count[2], 1)
  assert.equal(wide.count[5], 2)
  assert.equal(wide.count[10], 1)
  assert.equal(wide.loudest[5], 0)
  assert.equal(wide.loudest[10], 1)
  assert.equal(wide.count[40], 0)
  assert.equal(wide.bandShare[5], 1)
  assert.equal(wide.bandShare[40], 0)
  assert.ok(Math.abs(wide.cellShare[0] - 16 / BANDS) < 1e-9)
  assert.ok(Math.abs(wide.emptyShare - (BANDS - 16) / BANDS) < 1e-9)
})

test('activeStems lists the stems of one cell, loudest first', () => {
  const quiet = new Float32Array(BANDS).fill(-30)
  const loud = new Float32Array(BANDS).fill(-6)
  const silent = new Float32Array(BANDS).fill(FLOOR_DB)
  const list = activeStems([quiet, loud, silent], 0, 7, { referenceDb: -6, thresholdDb: 40 })
  assert.deepEqual(list.map(entry => entry.index), [1, 0])
})

test('a repeated role gets another colour, a role keeps its colour', () => {
  const colors = defaultColors(['kick', 'keys', 'keys', 'unknown'])
  assert.equal(new Set(colors).size, 4)
  assert.equal(colors[0], defaultColors(['kick'])[0])
})
