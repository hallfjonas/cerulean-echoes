// Feature tests for Stem Designer projects: the projects pass, the check catches broken copies, Save / Save as write
// the selection, Promote writes a new library version and never overwrites. Loose checks only.
// The SC side (load, play, A/B): tools/sc-test/stem-designer.test.mjs.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { checkFiles } from '../stems/check-stems.mjs'
import { buildKnob } from '../stems/knob.mjs'
import { scan } from '../trajectory/catalogue.mjs'
import { addColumn, checkAll, listProjects, projectErrors, projectFile, promote, readProject, removeColumn, repoRoot, replaceColumn, saveAs, saveProject, setKnob, trackWith }
  from './stem-project.mjs'

const sandboxes = []
test.after(() => sandboxes.forEach(root => fs.rmSync(root, { recursive: true, force: true })))

function sandbox() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'stem-lab-'))
  sandboxes.push(root)
  for (const dir of ['lab/stems', 'stems', 'sounds', 'tracks/009-house']) {
    fs.cpSync(path.join(repoRoot, 'sc', dir), path.join(root, 'sc', dir), { recursive: true })
  }
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(FIXTURE))
  return root
}

const FIXTURE = {
  format: 1, name: 'flute-explore', parent: null, about: 'Flute of 009-house against the library\'s other leads.',
  context: { track: '009-house', chapter: 0, backing: ['1:1', '1:3', '1:4'] }, select: '1:1',
  columns: {
    '1:1': 'flute/flute-brightness-space-complexity-pattern-echo-throw.stem',
    '1:2': 'brassSection/brass-section-brightness-space-complexity-pattern-lift.stem',
    '1:3': 'stringSection/string-section-brightness-space-complexity-pattern-lift.stem',
    '1:4': 'strat/strat-brightness-space-complexity-pattern-lift.stem',
  },
}

const FLUTE = 'flute/flute-brightness-space-complexity-pattern-echo-throw.stem'
const withDraft = (project, id = 'airy') => {
  const stem = JSON.parse(fs.readFileSync(path.join(repoRoot, 'sc', 'stems', FLUTE), 'utf8'))
  stem.parent = FLUTE
  stem.about = 'Flute, airier.'
  project.drafts = { [id]: stem }
  project.columns['1:1'] = `draft:${id}`
  return project
}

test('every Stem Designer project passes the check', () => {
  const results = checkAll()
  assert.ok(results.length >= 1)
  for (const { file, errors } of results) assert.deepEqual(errors, [], file)
})

test('the check catches broken projects', () => {
  const root = sandbox()
  const broken = change => {
    const project = readProject('flute-explore', root)
    change(project)
    return projectErrors(project, projectFile('flute-explore', root), root).join('\n')
  }
  assert.equal(broken(() => {}), '')
  assert.match(broken(p => { p.columns['1:1'] = 'flute/nope.stem' }), /not found/)
  assert.match(broken(p => { p.columns['3:1'] = FLUTE }), /3:1/)
  assert.match(broken(p => { p.columns['1:1'] = 'draft:gone' }), /no draft "gone"/)
  assert.match(broken(p => { p.context.track = '999-none' }), /context track/)
  assert.match(broken(p => { p.select = '1:7' }), /no column 1:7/)
  assert.match(broken(p => { p.name = 'other' }), /file name/)
  assert.match(broken(p => { withDraft(p).drafts.airy.sample = {} }), /draft "airy"/)
  assert.match(broken(p => { withDraft(p).drafts.spare = {} }), /on no column/)
})

test('Save writes the selected column, Save as copies with the parent', () => {
  const root = sandbox()
  saveProject('flute-explore', { select: '1:3' }, root)
  assert.equal(readProject('flute-explore', root).select, '1:3')
  const file = saveAs('flute-explore', 'flute-round-2', { select: '1:2' }, root)
  assert.equal(file, projectFile('flute-round-2', root))
  const copy = readProject('flute-round-2', root)
  assert.deepEqual([copy.parent, copy.select], ['flute-explore', '1:2'])
  assert.throws(() => saveAs('flute-explore', 'flute-round-2', null, root), /exists already/)
  assert.throws(() => saveAs('flute-explore', 'Bad Name', null, root), /lowercase/)
})

test('Promote writes a new stem version with the parent, never overwrites', () => {
  const root = sandbox()
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(withDraft(readProject('flute-explore', root))))
  const first = promote('flute-explore', '1:1', root)
  assert.equal(path.basename(first.file), path.basename(FLUTE).replace('.stem', '-2.stem'))
  assert.equal(JSON.parse(fs.readFileSync(first.file, 'utf8')).parent, FLUTE)
  assert.deepEqual(checkFiles([first.file], root)[0].errors, [])
  const project = readProject('flute-explore', root)
  assert.equal(project.columns['1:1'], first.ref)
  assert.equal(project.drafts, undefined)
  assert.throws(() => promote('flute-explore', '1:1', root), /in the library already/)
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(withDraft(project)))
  assert.notEqual(promote('flute-explore', '1:1', root).ref, first.ref)
})

test('the flute story: draft → promote → a new track with the new version, all checks pass', () => {
  const root = sandbox()
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(withDraft(readProject('flute-explore', root))))
  const { ref } = promote('flute-explore', '1:1', root)
  const file = trackWith('009-house', '009-house-v2', { '2:4': ref }, root)
  const track = JSON.parse(fs.readFileSync(file, 'utf8'))
  assert.equal(track.slots['2:4'], ref)
  assert.equal(track.slots['2:5'], JSON.parse(fs.readFileSync(
    path.join(repoRoot, 'sc', 'tracks', '009-house', '009-house.track'), 'utf8')).slots['2:5'])
  assert.deepEqual(checkFiles([file], root)[0].errors, [])
  assert.throws(() => trackWith('009-house', '009-house-v2', {}, root), /exists/)
  assert.throws(() => trackWith('009-house', '009-house-v3', { '2:4': 'draft:x' }, root), /promote the draft/)
  assert.ok(!fs.existsSync(path.join(root, 'sc', 'tracks', '009-house-v3')))
})

test('the player lists the projects under Lab', () => {
  const entry = scan().find(e => e.id === 'stems-flute-explore')
  assert.ok(entry, 'catalogue entry')
  assert.deepEqual([entry.kind, entry.engine, entry.lab, entry.project], ['lab', 'sc', 'stems', 'flute-explore'])
  assert.ok(listProjects().includes('flute-explore'))
})

test('add takes the slot asked for, replace keeps the slot, remove leaves the slot free', () => {
  const root = sandbox()
  const stems = ['brassSection/brass-section-brightness-space-complexity-pattern-lift.stem',
    'strat/strat-brightness-space-complexity-pattern-lift.stem']
  assert.deepEqual(addColumn('flute-explore', FLUTE, undefined, root), { slot: '1:5' })
  assert.deepEqual(addColumn('flute-explore', FLUTE, '2:3', root), { slot: '2:3' })
  assert.throws(() => addColumn('flute-explore', FLUTE, '2:3', root), /holds a stem already/)
  assert.deepEqual(replaceColumn('flute-explore', '1:5', stems[0], root), { slot: '1:5' })
  assert.equal(readProject('flute-explore', root).columns['1:5'], stems[0])
  removeColumn('flute-explore', '1:2', root)
  const { columns } = readProject('flute-explore', root)
  assert.deepEqual(Object.keys(columns).sort(), ['1:1', '1:3', '1:4', '1:5', '2:3'])
  assert.throws(() => addColumn('flute-explore', 'flute/nope.stem', undefined, root), /not found/)
})

test('add stops at 14 columns, a draft column is neither replaced nor removed', () => {
  const root = sandbox()
  for (let count = 4; count < 14; count++) addColumn('flute-explore', FLUTE, undefined, root)
  assert.throws(() => addColumn('flute-explore', FLUTE, undefined, root), /all 14 columns/)
  const project = withDraft(readProject('flute-explore', root))
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(project))
  assert.throws(() => removeColumn('flute-explore', '1:1', root), /promote it before you remove/)
  assert.throws(() => replaceColumn('flute-explore', '1:1', FLUTE, root), /promote it before you replace/)
})

test('a draft column goes only when its changes are given up', () => {
  const root = sandbox()
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(withDraft(readProject('flute-explore', root))))
  assert.throws(() => removeColumn('flute-explore', '1:1', root), /promote it before you remove/)
  removeColumn('flute-explore', '1:1', root, { discard: true })
  const project = readProject('flute-explore', root)
  assert.equal(project.columns['1:1'], undefined)
  assert.equal(project.drafts, undefined)
})

test('the last column can go', () => {
  const root = sandbox()
  for (const slot of ['1:1', '1:2', '1:3', '1:4']) removeColumn('flute-explore', slot, root)
  assert.deepEqual(readProject('flute-explore', root).columns, {})
})

test('a knob change makes a draft of a library column, changes a draft in place, and Promote writes it to the library', () => {
  const root = sandbox()
  const echo = buildKnob('k3', { preset: 'echo', label: 'Wet', default: 0.3 })
  assert.deepEqual(setKnob('flute-explore', '1:1', 'k3', echo, root), { slot: '1:1', draft: 'flute-1-1' })
  let project = readProject('flute-explore', root)
  assert.equal(project.columns['1:1'], 'draft:flute-1-1')
  assert.equal(project.drafts['flute-1-1'].parent, FLUTE)
  assert.equal(project.drafts['flute-1-1'].controls.k3.default, 0.3)
  setKnob('flute-explore', '1:1', 'k3', buildKnob('k3', { preset: 'echo', label: 'Wet', default: 0.6 }), root)
  project = readProject('flute-explore', root)
  assert.deepEqual(Object.keys(project.drafts), ['flute-1-1'])
  assert.equal(project.drafts['flute-1-1'].controls.k3.default, 0.6)
  const { ref } = promote('flute-explore', '1:1', root)
  assert.match(ref, /^flute\/flute-brightness-space-wet-pattern-echo-throw\.stem$/)
  assert.equal(readProject('flute-explore', root).columns['1:1'], ref)
  assert.throws(() => setKnob('flute-explore', '2:1', 'k3', echo, root), /no column 2:1/)
})
