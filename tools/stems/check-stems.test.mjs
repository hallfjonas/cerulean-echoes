// Feature tests for check-stems: the library passes, and each rule catches a broken copy of an example stem or track.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { checkFiles, kebab, libraryFiles, repoRoot } from './check-stems.mjs'

const KICK = 'kick909/kick909-brightness-space-punch-pattern-drop-out.stem'
const BASS = 'bassWarm/bass-warm-brightness-space-length-pattern-octave.stem'

const sandboxes = []
test.after(() => sandboxes.forEach(root => fs.rmSync(root, { recursive: true, force: true })))

function sandbox() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'check-stems-'))
  sandboxes.push(root)
  for (const dir of ['sc/stems', 'sc/sounds']) {
    fs.cpSync(path.join(repoRoot, dir), path.join(root, dir), { recursive: true })
  }
  return root
}

const readStem = (root, ref) => JSON.parse(fs.readFileSync(path.join(root, 'sc', 'stems', ref), 'utf8'))
const writeJson = (file, data) => {
  fs.mkdirSync(path.dirname(file), { recursive: true })
  fs.writeFileSync(file, JSON.stringify(data, null, 2))
  return file
}

function brokenStem(change, ref = KICK, rename = name => name) {
  const root = sandbox()
  const stem = readStem(root, ref)
  change(stem)
  const file = writeJson(path.join(root, 'sc', 'stems', rename(ref)), stem)
  if (rename(ref) !== ref) fs.rmSync(path.join(root, 'sc', 'stems', ref))
  return checkFiles([file], root)[0].errors.join('\n')
}

function track(change = () => {}) {
  const root = sandbox()
  const dir = path.join(root, 'sc', 'tracks', '099-test')
  fs.mkdirSync(dir, { recursive: true })
  fs.writeFileSync(path.join(dir, '099-test-frame.scd'), '()\n')
  const data = { format: 1, name: '099-test', about: 'Test track.', tempo: 124, genre: 'house',
    frame: '099-test-frame.scd', chapters: ['Vamp'], slots: { '1:1': KICK, '1:4': BASS } }
  change(data, root)
  return checkFiles([writeJson(path.join(dir, '099-test.track'), data)], root)[0].errors.join('\n')
}

test('every stem and stem track in the library passes', () => {
  const results = checkFiles(libraryFiles())
  assert.ok(results.length >= 2, 'the two example stems')
  for (const { file, errors } of results) assert.deepEqual(errors, [], file)
})

test('the file name comes from sample and labels', () => {
  assert.equal(kebab('bassWarm'), 'bass-warm')
  assert.equal(kebab('Hats ↔ Shaker'), 'hats-shaker')
  assert.equal(kebab('Echo throw'), 'echo-throw')
  assert.match(brokenStem(() => {}, KICK, ref => ref.replace('punch', 'kick')), /name should be/)
  assert.match(brokenStem(stem => { stem.controls.k3.label = 'Drive' }), /name should be ".*-drive-/)
  assert.deepEqual(brokenStem(stem => { stem.name += '-2' }, KICK, ref => ref.replace('.stem', '-2.stem')), '')
})

test('the stem lives in its sample folder and the sample exists', () => {
  assert.match(brokenStem(stem => { stem.sample.name = 'noSuchSound' }), /not found in sc\/sounds/)
  assert.match(brokenStem(stem => { stem.sample.name = 'noSuchSound' }), /folder "kick909" is not the sample/)
  assert.match(brokenStem(stem => { stem.sample.preset = { wobble: 1 } }), /"wobble" is not a parameter/)
})

test('labels follow the label rules', () => {
  assert.match(brokenStem(stem => { stem.controls.k1.label = 'Bright' }), /k1 label must be "Brightness"/)
  assert.match(brokenStem(stem => { stem.controls.k2.label = 'Room' }), /k2 label must be "Space"/)
  assert.match(brokenStem(stem => { stem.controls.fader.label = 'Volume' }), /controls\.fader\.label: must be "Level"/)
  assert.match(brokenStem(stem => { stem.controls.b1.label = 'Chords' }), /only on a chords stem/)
  assert.match(brokenStem(stem => { stem.controls.k3.label = 'Tension' }), /reserved/)
  assert.match(brokenStem(stem => { stem.controls.k3.about = 'x'.repeat(61) }), /61 characters, at most 60/)
  assert.match(brokenStem(stem => { stem.about = 'x'.repeat(80) }), /about: 80 characters/)
})

test('add-ons, code files, parameters and parents must exist', () => {
  assert.match(brokenStem(stem => { stem.controls.b2.addon = 'teleport' }), /add-on "teleport" not in/)
  assert.match(brokenStem(stem => { stem.controls.b2.mode = 'step' }), /has no mode "step"/)
  assert.match(brokenStem(stem => { stem.controls.b2.label = 'Drop' }), /labelled "Drop out", not "Drop"/)
  assert.match(brokenStem(stem => { stem.controls.k3 = { label: 'Punch', about: 'x.', code: 'punch.scd' } }),
    /code file "punch.scd" not found/)
  assert.match(brokenStem(stem => { stem.controls.k3.param = 'wobble' }), /"wobble" is not a parameter of the sample/)
  assert.match(brokenStem(stem => { delete stem.controls.k3.range }), /"param" needs a "range"/)
  assert.match(brokenStem(stem => { stem.parent = 'kick909/kick909-gone.stem' }), /parent .* not found/)
  assert.match(brokenStem(stem => { stem.parent = BASS }), /same sample/)
  assert.match(brokenStem(stem => { stem.sample.extra = ['sdGone'] }), /"sdGone" not found/)
})

test('only a stem with column code may leave knobs and button 2 to the code', () => {
  const open = stem => { stem.controls.k3 = { label: 'Punch', about: 'x.' }; delete stem.controls.b2.addon }
  assert.match(brokenStem(open), /k3: needs exactly one/)
  assert.match(brokenStem(open), /b2: needs exactly one/)
  const root = sandbox()
  const stem = readStem(root, KICK)
  open(stem)
  stem.code = 'kick.scd'
  fs.writeFileSync(path.join(root, 'sc', 'stems', 'kick909', 'kick.scd'), '(notes: { |col, k| [] })\n')
  const file = writeJson(path.join(root, 'sc', 'stems', KICK), stem)
  assert.deepEqual(checkFiles([file], root)[0].errors, [])
})

test('a wrapper sound has the parameters of the voice it wraps', () => {
  const errors = brokenStem(stem => { stem.controls.k3 = { label: 'Punch', about: 'x.', param: 'rate', range: [1, 2] } },
    'clap909/clap909-brightness-space-complexity-pattern-roll.stem')
  assert.doesNotMatch(errors, /"rate" is not a parameter/)
})

test('schema and patterns', () => {
  assert.match(brokenStem(stem => { stem.meta.role = 'drums' }), /meta\.role/)
  assert.match(brokenStem(stem => { stem.meta.genres = ['jazz'] }), /meta\.genres\[0\]/)
  assert.match(brokenStem(stem => { stem.colour = 'red' }), /unknown field "colour"/)
  assert.match(brokenStem(stem => { stem.patterns[1].rhythm = '<[x x x x]!3 [x x x ~>' }),
    /patterns\[1\]\.rhythm: unbalanced/)
  assert.match(brokenStem(stem => { delete stem.patterns[0].rhythm }), /needs "rhythm"/)
})

test('stem tracks point at existing stems and frames', () => {
  assert.equal(track(), '')
  assert.match(track(data => { data.slots['2:1'] = 'flute/flute-gone.stem' }), /slot 2:1: stem .* not found/)
  assert.match(track(data => { data.slots['3:1'] = KICK }), /3:1 \(name\)/)
  assert.match(track(data => { data.frame = 'gone.scd' }), /frame "gone.scd" not found/)
  assert.match(track(data => { data.name = '098-test' }), /a track lives at/)
  assert.match(track((data, root) => {
    const file = path.join(root, 'sc', 'stems', BASS)
    const stem = JSON.parse(fs.readFileSync(file, 'utf8'))
    stem.patterns.push({ label: 'fourth', rhythm: 'x' })
    fs.writeFileSync(file, JSON.stringify(stem))
  }), /Mode 1 takes at most 3 patterns/)
})

test('the schemas list the genres of docs/reference/genres.md', () => {
  const headings = fs.readFileSync(path.join(repoRoot, 'docs', 'reference', 'genres.md'), 'utf8')
    .split('\n').filter(line => line.startsWith('## ')).map(line => kebab(line.slice(3)))
  const stemSchema = JSON.parse(fs.readFileSync(path.join(repoRoot, 'sc', 'stems', 'stem.schema.json'), 'utf8'))
  const trackSchema = JSON.parse(fs.readFileSync(path.join(repoRoot, 'sc', 'stems', 'track.schema.json'), 'utf8'))
  const genres = stemSchema.properties.meta.properties.genres.items.enum
  for (const genre of genres) assert.ok(headings.includes(genre), genre)
  assert.deepEqual(trackSchema.properties.genre.enum, genres)
})
