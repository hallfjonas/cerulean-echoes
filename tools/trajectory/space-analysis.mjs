// Space Analyzer maths, DOM-free: the same module runs in the server (tests) and in the page.
// A footprint is what one source (a stem rendered alone) occupies: for every time cell (1/32 bar) and every one of 64
// log-spaced bands (30 Hz - 16 kHz) the level of the left and the right channel, stored as bytes of half a dB
// (0 = -90 dB). A level grid is the mono (power) sum of both channels in dB, cells × bands, band 0 the lowest.
//   encodeDb / decodeDb / toBase64 / fromBase64       bytes ↔ dB, bytes ↔ text for the wire
//   levelsOf(footprint)                               → Float32Array of dB (L and R added as power)
//   regrid(levels, { division, from, bars, mode })    → coarser cells: division 1/32 … 1/1 of a bar, a bar window
//   occupancy(grids, { referenceDb, thresholdDb })    → which stems are active in each cell and band, and the shares
//   activeStems(grids, cell, band, limit)             → the stems active in one cell, loudest first
//   defaultColors(roles)                              → one colour per stem, the same role keeps its colour
// Active = within thresholdDb below the loudest level of the included stems (referenceDb).
export const BANDS = 64
export const LOW_HZ = 30
export const HIGH_HZ = 16000
export const CELLS_PER_BAR = 32
export const FLOOR_DB = -90
export const DIVISIONS = [32, 16, 8, 4, 2, 1]

export const bandHz = band => LOW_HZ * (HIGH_HZ / LOW_HZ) ** (band / (BANDS - 1))

export const encodeDb = db => Math.max(0, Math.min(255, Math.round((db - FLOOR_DB) * 2)))
export const decodeDb = byte => byte / 2 + FLOOR_DB

export const toBase64 = bytes => {
  let text = ''
  for (let i = 0; i < bytes.length; i += 0x8000) text += String.fromCharCode(...bytes.subarray(i, i + 0x8000))
  return btoa(text)
}

export const fromBase64 = text => Uint8Array.from(atob(text), char => char.charCodeAt(0))

const POWER = Float64Array.from({ length: 256 }, (_, byte) => 10 ** (decodeDb(byte) / 10))

export function levelsOf(footprint) {
  const { l, r } = footprint
  const levels = new Float32Array(l.length)
  for (let i = 0; i < l.length; i++) {
    levels[i] = l[i] || r[i] ? Math.max(FLOOR_DB, 10 * Math.log10(POWER[l[i]] + POWER[r[i]])) : FLOOR_DB
  }
  return levels
}

export function regrid(levels, { division, from, bars, mode = 'max', bands = BANDS, cellsPerBar = CELLS_PER_BAR }) {
  const span = cellsPerBar / division
  const cells = bars * division
  const out = new Float32Array(cells * bands)
  for (let cell = 0; cell < cells; cell++) {
    for (let band = 0; band < bands; band++) {
      let max = FLOOR_DB
      let power = 0
      for (let k = 0; k < span; k++) {
        const level = levels[(from * cellsPerBar + cell * span + k) * bands + band] ?? FLOOR_DB
        if (level > max) max = level
        power += 10 ** (level / 10)
      }
      out[cell * bands + band] = mode === 'power' ? Math.max(FLOOR_DB, 10 * Math.log10(power / span)) : max
    }
  }
  return out
}

export const peakDb = gridList => {
  let peak = FLOOR_DB
  for (const grid of gridList) for (let i = 0; i < grid.length; i++) if (grid[i] > peak) peak = grid[i]
  return peak
}

export function occupancy(grids, { referenceDb, thresholdDb, bands = BANDS }) {
  const size = grids[0]?.length ?? 0
  const cells = size / bands
  const count = new Uint8Array(size)
  const loudest = new Int16Array(size).fill(-1)
  const loudestDb = new Float32Array(size).fill(FLOOR_DB)
  const limit = referenceDb - thresholdDb
  grids.forEach((grid, index) => {
    for (let i = 0; i < size; i++) {
      const level = grid[i]
      if (level <= FLOOR_DB || level < limit) continue
      count[i]++
      if (level > loudestDb[i]) { loudestDb[i] = level; loudest[i] = index }
    }
  })
  const bandShare = new Float32Array(bands)
  const cellShare = new Float32Array(cells)
  let empty = 0
  for (let cell = 0; cell < cells; cell++) {
    for (let band = 0; band < bands; band++) {
      if (count[cell * bands + band] > 0) { bandShare[band]++; cellShare[cell]++ } else empty++
    }
  }
  for (let band = 0; band < bands; band++) bandShare[band] /= cells || 1
  for (let cell = 0; cell < cells; cell++) cellShare[cell] /= bands
  return { count, loudest, loudestDb, bandShare, cellShare, emptyShare: size ? empty / size : 0, cells, bands }
}

export function activeStems(grids, cell, band, { referenceDb, thresholdDb, bands = BANDS }) {
  const limit = referenceDb - thresholdDb
  return grids.map((grid, index) => ({ index, db: grid[cell * bands + band] }))
    .filter(entry => entry.db > FLOOR_DB && entry.db >= limit)
    .sort((a, b) => b.db - a.db)
}

const ROLE_COLORS = { kick: '#D85A30', sub: '#7F77DD', bass: '#378ADD', clap: '#D4537E', hats: '#1D9E75', perc: '#BA7517',
  keys: '#EF9F27', chords: '#5DCAA5', pad: '#85B7EB', lead: '#97C459', texture: '#AFA9EC', fx: '#F0997B' }
const SPARE_COLORS = ['#993556', '#0F6E56', '#534AB7', '#854F0B', '#185FA5', '#3B6D11', '#993C1D', '#888780']

export function defaultColors(roles) {
  const taken = new Set()
  let spare = 0
  return roles.map(role => {
    let color = ROLE_COLORS[role]
    if (!color || taken.has(color)) color = SPARE_COLORS[spare++ % SPARE_COLORS.length]
    taken.add(color)
    return color
  })
}
