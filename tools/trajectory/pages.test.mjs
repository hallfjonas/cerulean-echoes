import { test } from 'node:test'
import assert from 'node:assert/strict'
import { parseHash, hashFor, shownOn, entriesFor, showsShape, placeholderFor } from './pages.mjs'

const catalogue = [
  { id: 'a', kind: 'live', engine: 'sc' },
  { id: 'b', kind: 'live', engine: 'strudel' },
  { id: 'lab-board', kind: 'lab', engine: 'strudel' },
  { id: 'sample-kick', kind: 'lab', lab: 'sample' },
  { id: 'stems-flute', kind: 'lab', lab: 'stems' },
]

test('hash: every page round-trips, unknown hashes land on Live, Labs defaults to Samples', () => {
  for (const hash of ['#live', '#labs/samples', '#labs/stems', '#labs/tracks', '#labs/sets', '#visuals'])
    assert.equal(hashFor(parseHash(hash)), hash)
  assert.deepEqual(parseHash(''), { id: 'live', sub: null })
  assert.deepEqual(parseHash('#nonsense'), { id: 'live', sub: null })
  assert.deepEqual(parseHash('#labs'), { id: 'labs', sub: 'samples' })
  assert.deepEqual(parseHash('#labs/nope'), { id: 'labs', sub: 'samples' })
})

test('pickers: Live lists live tracks, Samples and Stems their projects, Strudel boards never', () => {
  const ids = page => entriesFor(parseHash(page), catalogue).map(entry => entry.id)
  assert.deepEqual(ids('#live'), ['a', 'b'])
  assert.deepEqual(ids('#labs/samples'), ['sample-kick'])
  assert.deepEqual(ids('#labs/stems'), ['stems-flute'])
  assert.deepEqual(ids('#labs/tracks'), [])
  assert.deepEqual(ids('#visuals'), [])
})

test('sections: a token names a page, all its sub-tabs or one sub-tab', () => {
  const live = parseHash('#live'), stems = parseHash('#labs/stems'), samples = parseHash('#labs/samples')
  assert.ok(shownOn('live', live) && !shownOn('live', stems))
  assert.ok(shownOn('labs', stems) && shownOn('labs', samples))
  assert.ok(shownOn('labs/stems', stems) && !shownOn('labs/stems', samples))
  assert.ok(shownOn('live labs/samples', samples) && !shownOn('live labs/samples', stems))
})

test('the waveform analysis belongs to Labs / Samples; Tracks and Sets are placeholders', () => {
  assert.ok(showsShape(parseHash('#labs/samples')))
  for (const hash of ['#live', '#labs/stems', '#visuals']) assert.ok(!showsShape(parseHash(hash)))
  assert.ok(placeholderFor(parseHash('#labs/tracks')) && placeholderFor(parseHash('#labs/sets')))
  assert.equal(placeholderFor(parseHash('#labs/samples')), null)
})
