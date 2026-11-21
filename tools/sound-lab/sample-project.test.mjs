// Feature tests for Sample Designer projects: the projects pass, the check catches broken copies, Save / Save as
// write the playing values, export writes a library sound, the player lists the projects. Loose checks only.
// The SC side (load, play, export renders and loads): tools/sc-test/sample-designer.test.mjs.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { soundInfo } from '../stems/check-stems.mjs'
import { scan } from '../trajectory/catalogue.mjs'
import { checkAll, exportSound, listProjects, paramName, projectErrors, projectFile, readProject, repoRoot, saveAs,
  saveProject, soundText } from './sample-project.mjs'

const sandboxes = []
test.after(() => sandboxes.forEach(root => fs.rmSync(root, { recursive: true, force: true })))

function sandbox() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'sample-lab-'))
  sandboxes.push(root)
  fs.cpSync(path.join(repoRoot, 'sc', 'lab', 'samples'), path.join(root, 'sc', 'lab', 'samples'), { recursive: true })
  fs.mkdirSync(path.join(root, 'sc', 'sounds'), { recursive: true })
  return root
}

const broken = change => {
  const project = readProject('kick-round')
  change(project)
  return projectErrors(project, projectFile('kick-round')).join('\n')
}

test('every Sample Designer project passes the check', () => {
  const results = checkAll()
  assert.ok(results.length >= 2, 'the drum and the synth project')
  for (const { file, errors } of results) assert.deepEqual(errors, [], file)
  const setups = new Set(listProjects().map(name => readProject(name).setup))
  assert.ok(setups.has('drum') && setups.has('synth'))
})

test('the check catches broken projects', () => {
  assert.equal(broken(() => {}), '')
  assert.match(broken(p => { p.sources[0].type = 'Wobble' }), /type "Wobble" not one of/)
  assert.match(broken(p => { p.chain.push(p.sources.pop()) }), /is a source|setup "drum"/)
  assert.match(broken(p => { p.sources[0].kind = 'laser' }), /kind/)
  assert.match(broken(p => { p.sources[0].k1 = 2 }), /above 1/)
  assert.match(broken(p => { p.audition.patterns[0].rhythm = '[x x' }), /unclosed/)
  assert.match(broken(p => { p.audition.patterns[0].rhythm = '~ ~' }), /no hit/)
  assert.match(broken(p => { p.audition.pattern = 9 }), /no such pattern/)
  assert.match(broken(p => { p.name = 'other' }), /not the project name/)
  assert.match(broken(p => { p.setup = 'free'; p.chain.push({ ...p.chain[0], id: 'env2' }) }), /at most one "env"/)
  assert.match(broken(p => { p.role = 'drums' }), /role/)
})

test('the project roles are the stem roles', () => {
  const stem = JSON.parse(fs.readFileSync(path.join(repoRoot, 'sc', 'stems', 'stem.schema.json'), 'utf8'))
  const sample = JSON.parse(fs.readFileSync(path.join(repoRoot, 'sc', 'lab', 'samples', 'sample.schema.json'), 'utf8'))
  assert.deepEqual(sample.properties.role.enum, stem.properties.meta.properties.role.enum)
})

test('Save writes the playing values, Save as copies with a parent', () => {
  const root = sandbox()
  const values = { blocks: [{ id: 'tone', on: false, type: 'Saw', k1: 0.12345, k2: 0.5, k3: 0.4, level: 0.7 }],
    audition: { pattern: 2, accent: 0.9, space: 0.3, length: 0.25, master: 0.6 } }
  saveProject('kick-round', values, root)
  const saved = readProject('kick-round', root)
  assert.deepEqual(saved.sources[0], { id: 'tone', kind: 'tone', on: false, type: 'Saw', k1: 0.123, k2: 0.5, k3: 0.4,
    level: 0.7 })
  assert.equal(saved.audition.pattern, 2)
  assert.equal(saved.audition.master, 0.6)
  saveAs('kick-round', 'kick-round-2', null, root)
  const copy = readProject('kick-round-2', root)
  assert.equal(copy.parent, 'kick-round')
  assert.deepEqual(copy.sources, saved.sources)
  assert.deepEqual(projectErrors(copy, projectFile('kick-round-2', root), root), [])
  assert.throws(() => saveAs('kick-round', 'kick-round-2', null, root), /exists already/)
  assert.throws(() => saveAs('kick-round', 'Kick Round', null, root), /lowercase/)
})

test('export writes a library sound with every block parameter live', async () => {
  const root = sandbox()
  const out = await exportSound('bass-pluck', { soundName: 'bassPluckTest', root })
  assert.equal(out.wav, null)
  const text = fs.readFileSync(out.sound, 'utf8')
  assert.match(text, /^name: \\bassPluckTest,$/m)
  assert.match(text, /^role: \\bass,$/m)
  const info = soundInfo(root, 'bassPluckTest')
  const project = readProject('bass-pluck', root)
  for (const block of [...project.sources, ...project.chain]) {
    for (const key of ['level', 'on', 'type']) assert.ok(info.params.includes(paramName(block.id, key)), block.id + key)
  }
  assert.ok(info.params.includes('osc1Tune') && info.params.includes('bright'))
  await assert.rejects(() => exportSound('bass-pluck', { soundName: 'bassPluckTest', root }), /exists already/)
  await assert.rejects(() => exportSound('bass-pluck', { soundName: 'bass-pluck', root }), /camelCase/)
  assert.match(soundText(project, 'x', root), /^mono: true,$/m)
})

test('the player lists every project under Lab, played by SuperCollider', () => {
  const entries = scan().filter(entry => entry.lab === 'sample')
  assert.deepEqual(entries.map(entry => entry.project).sort(), listProjects())
  for (const entry of entries) {
    assert.equal(entry.kind, 'lab')
    assert.equal(entry.engine, 'sc')
    assert.equal(entry.id, 'sample-' + entry.project)
  }
})
