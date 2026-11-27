// The drawer's fit check (stem-fit.mjs): a stem that needs what the track's frame lacks is a misfit with its reason, a
// Stem Designer project is checked against its context track, a second ask is answered from the cache.
import test from 'node:test'
import assert from 'node:assert/strict'
import path from 'path'
import { fileURLToPath } from 'url'
import { findSclang } from './sc-link.mjs'
import { createStemFit } from './stem-fit.mjs'

const repo = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const sclang = findSclang()
const organ = 'sdSynthMod/sd-synth-mod-brightness-space-decay-pattern-echo-throw.stem'
const track = id => ({ id, stems: true, path: path.join(repo, 'sc', 'tracks', id, `${id}.track`) })
const entries = { '017-lsd-fx-2': track('017-lsd-fx-2'), '002-groove': track('002-groove'), '009-house': track('009-house'),
  'stems-flute-explore': { id: 'stems-flute-explore', lab: 'stems', project: 'flute-explore' } }

test('stem fit: misfits with their reason, projects through their track, cached',
  { skip: sclang ? false : 'sclang not installed', timeout: 120e3 }, async () => {
  const fits = createStemFit({ repo, find: id => entries[id], sclang })
  const lsd = await fits.fitOf('017-lsd-fx-2')
  assert.equal(lsd.misfits[organ], 'the frame has no tonesAt', 'the 002 organ needs tonesAt')
  assert.equal((await fits.fitOf('002-groove')).misfits[organ], undefined, 'it fits its own track')
  const started = Date.now()
  assert.equal(await fits.fitOf('017-lsd-fx-2'), lsd)
  assert.ok(Date.now() - started < 1000, 'the second ask comes from the cache')
  const house = await fits.fitOf('009-house')
  assert.equal(await fits.fitOf('stems-flute-explore'), house, 'a project uses its context track')
  await assert.rejects(fits.fitOf('nope'), /no stem track/)
})
