// Feature tests for the stem library index on a fixture library in a temp folder (no sclang needed): grouping,
// lineage, "used by" from the track files, the filters, the CLI and GET /stems.
import test from 'node:test'
import assert from 'node:assert/strict'
import { execFileSync, spawn } from 'child_process'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { fileURLToPath } from 'url'
import { repoRoot } from './check-stems.mjs'
import { buildIndex, filterIndex, formatIndex, parseEnergy, stemIndex } from './stem-index.mjs'
import { parseArgs } from './stems.mjs'

const KICK = 'kick909/kick909-brightness-space-punch-pattern-drop-out.stem'
const KICK_2 = 'kick909/kick909-brightness-space-punch-pattern-drop-out-2.stem'
const BASS = 'bassWarm/bass-warm-brightness-space-length-pattern-octave.stem'
const FLUTE = 'flute/flute-brightness-space-complexity-pattern-echo-throw.stem'
const here = path.dirname(fileURLToPath(import.meta.url))
const toolsDir = path.join(here, '..')

const readExample = ref => JSON.parse(fs.readFileSync(path.join(repoRoot, 'sc', 'stems', ref), 'utf8'))

const writeJson = (file, data) => {
  fs.mkdirSync(path.dirname(file), { recursive: true })
  fs.writeFileSync(file, JSON.stringify(data, null, 2))
}

function fixtureLibrary() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'stem-index-'))
  const stemFile = ref => path.join(root, 'sc', 'stems', ref)
  const kick = readExample(KICK)
  writeJson(stemFile(KICK), kick)
  writeJson(stemFile(KICK_2), { ...kick, name: path.basename(KICK_2, '.stem'), parent: KICK,
    meta: { ...kick.meta, energy: 4, tags: ['909', 'hard'] } })
  writeJson(stemFile(BASS), readExample(BASS))
  const bass = readExample(BASS)
  writeJson(stemFile(FLUTE), { ...bass, name: path.basename(FLUTE, '.stem'), parent: null,
    about: 'Airy flute line.', sample: { name: 'flute' },
    meta: { role: 'lead', genres: ['ambient', 'house'], energy: 2, tags: ['airy'], harmony: 'scale' },
    controls: { ...bass.controls, k3: { ...bass.controls.k3, label: 'Complexity' },
      b2: { ...bass.controls.b2, label: 'Echo throw', addon: 'echoThrow' } } })
  fs.writeFileSync(stemFile('flute/broken.stem'), '{ not json')
  const track = (name, slots) => writeJson(path.join(root, 'sc', 'tracks', name, `${name}.track`),
    { format: 1, name, about: 'Test.', tempo: 124, genre: 'house', frame: `${name}-frame.scd`, chapters: ['Vamp'],
      slots })
  track('090-one', { '1:1': KICK, '1:4': BASS, '2:2': FLUTE })
  track('091-two', { '1:1': KICK_2, '2:3': FLUTE })
  return root
}

const root = fixtureLibrary()
test.after(() => fs.rmSync(root, { recursive: true, force: true }))

const FLUTE_NAME = path.basename(FLUTE, '.stem')
const KICK_2_NAME = path.basename(KICK_2, '.stem')
const versionNames = index => index.stems.flatMap(stem => stem.versions.map(version => version.name))
const findVersion = (index, ref) => index.stems.flatMap(stem => stem.versions).find(version => version.file === ref)

test('versions are grouped by stem: a "-2" file joins the stem of its first version', () => {
  const index = buildIndex(root)
  assert.deepEqual(index.stems.map(stem => [stem.sample, stem.versions.length]),
    [['bassWarm', 1], ['flute', 1], ['kick909', 2]])
  assert.deepEqual(index.skipped, ['flute/broken.stem'])
})

test('lineage: parent and children', () => {
  const index = buildIndex(root)
  assert.equal(findVersion(index, KICK).parent, null)
  assert.deepEqual(findVersion(index, KICK).children, [KICK_2])
  assert.equal(findVersion(index, KICK_2).parent, KICK)
  assert.equal(findVersion(index, KICK_2).parentMissing, false)
})

test('a parent that is gone is reported, not fatal', () => {
  const orphanRoot = fixtureLibrary()
  fs.rmSync(path.join(orphanRoot, 'sc', 'stems', KICK))
  const version = findVersion(buildIndex(orphanRoot), KICK_2)
  assert.equal(version.parentMissing, true)
  assert.match(formatIndex(buildIndex(orphanRoot)), /\(missing\)/)
  fs.rmSync(orphanRoot, { recursive: true, force: true })
})

test('used by: computed from the track files, with the slots', () => {
  const index = buildIndex(root)
  assert.deepEqual(findVersion(index, KICK).usedBy, [{ track: '090-one', slots: ['1:1'] }])
  assert.deepEqual(findVersion(index, KICK_2).usedBy, [{ track: '091-two', slots: ['1:1'] }])
  assert.deepEqual(findVersion(index, FLUTE).usedBy,
    [{ track: '090-one', slots: ['2:2'] }, { track: '091-two', slots: ['2:3'] }])
  const otherRoot = fixtureLibrary()
  fs.rmSync(path.join(otherRoot, 'sc', 'tracks', '091-two'), { recursive: true })
  assert.deepEqual(findVersion(buildIndex(otherRoot), KICK_2).usedBy, [])
  fs.rmSync(otherRoot, { recursive: true, force: true })
})

test('filters: role, genre, energy range, tag, and all together', () => {
  const index = buildIndex(root)
  assert.deepEqual(versionNames(filterIndex(index, { role: 'lead' })), [FLUTE_NAME])
  assert.equal(versionNames(filterIndex(index, { genre: 'house' })).length, 4)
  assert.equal(versionNames(filterIndex(index, { genre: 'ambient' })).length, 1)
  assert.deepEqual(versionNames(filterIndex(index, { energy: '4' })), [KICK_2_NAME])
  assert.equal(versionNames(filterIndex(index, { energy: '2-3' })).length, 3)
  assert.equal(versionNames(filterIndex(index, { energy: '3-' })).length, 3)
  assert.equal(versionNames(filterIndex(index, { tag: 'airy' })).length, 1)
  assert.equal(versionNames(filterIndex(index, { role: 'kick', tag: '909', energy: '3-4', genre: 'house' })).length, 2)
  assert.deepEqual(filterIndex(index, { role: 'lead', tag: 'warm' }).stems, [])
  assert.equal(filterIndex(index, {}).stems.length, 3)
})

test('energy text: a number, a range, an open range; bad text is refused', () => {
  assert.deepEqual(parseEnergy('3'), [3, 3])
  assert.deepEqual(parseEnergy('2-4'), [2, 4])
  assert.deepEqual(parseEnergy('4-'), [4, 5])
  for (const bad of ['0', '6', 'high', '4-2', '2-9']) assert.throws(() => parseEnergy(bad), /energy/)
})

test('text output: grouped, lineage always, tracks only with used-by', () => {
  const index = stemIndex({ role: 'kick' }, root)
  const plain = formatIndex(index)
  assert.match(plain, /kick909-brightness-space-punch-pattern-drop-out {2}\(sample kick909, 2 versions\)/)
  assert.match(plain, /parent: none {2}children: kick909-brightness-space-punch-pattern-drop-out-2\.stem/)
  assert.match(plain, /parent: kick909-brightness-space-punch-pattern-drop-out\.stem/)
  assert.doesNotMatch(plain, /used by/)
  const used = formatIndex(index, { usedBy: true })
  assert.match(used, /used by: 090-one \(1:1\)/)
  assert.match(used, /used by: 091-two \(1:1\)/)
  assert.match(formatIndex(stemIndex({ role: 'fx' }, root)), /no stem matches/)
})

test('CLI arguments', () => {
  assert.deepEqual(parseArgs(['--role', 'lead', '--genre', 'house', '--energy', '2-4', '--tag', 'airy', '--used-by']),
    { filters: { role: 'lead', genre: 'house', energy: '2-4', tag: 'airy' }, options: { usedBy: true, json: false } })
  assert.throws(() => parseArgs(['--role']), /needs a value/)
  assert.throws(() => parseArgs(['--colour', 'red']), /unknown option/)
})

test('npm run stems lists the repo library; a bad energy exits 1', () => {
  const run = (...args) => execFileSync(process.execPath, [path.join(here, 'stems.mjs'), ...args],
    { cwd: toolsDir, encoding: 'utf8' })
  assert.match(run('--role', 'kick', '--used-by'), /kick909/)
  const bass = JSON.parse(run('--role', 'bass', '--json')).stems
  assert.ok(bass.some(stem => stem.sample === 'bassWarm'))
  assert.ok(bass.every(stem => stem.versions.every(version => version.meta.role === 'bass')))
  assert.throws(() => run('--energy', '9'), /Command failed/)
})

test('GET /stems returns the filtered index as JSON, 400 on a bad filter', async () => {
  const port = 8792
  const server = spawn(process.execPath, [path.join(toolsDir, 'trajectory', 'server.mjs'), String(port)],
    { env: { ...process.env, CE_SC_PORT: '57161', CE_SC_SERVER_PORT: '57162' }, stdio: 'ignore' })
  const base = `http://localhost:${port}`
  try {
    for (let i = 0; i < 150; i++) {
      try { if ((await fetch(base + '/catalogue')).ok) break } catch {}
      await new Promise(resolve => setTimeout(resolve, 100))
    }
    const response = await fetch(base + '/stems?role=kick')
    assert.equal(response.status, 200)
    assert.match(response.headers.get('content-type'), /application\/json/)
    const body = await response.json()
    assert.deepEqual(body, JSON.parse(JSON.stringify(stemIndex({ role: 'kick' }))))
    assert.ok(body.stems.length >= 1 && body.stems.every(stem => stem.versions.every(v => v.meta.role === 'kick')))
    assert.ok(body.stems[0].versions[0].usedBy)
    assert.equal((await fetch(base + '/stems?energy=9')).status, 400)
  } finally {
    server.kill()
  }
})
