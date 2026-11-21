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
import { addColumn, checkAll, freeProjectName, freeTrackName, listProjects, listStemTracks, projectErrors, projectFile,
  projectFromTrack, promote, readProject, removeColumn, repoRoot, replaceColumn, saveAs, saveProject, setKnob,
  draftSlots, trackFromProject, trackWith }
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

test('a project from a track: lab stems become columns, backing stems play along, the rest stays off', () => {
  const root = sandbox()
  const house = listStemTracks(root).find(entry => entry.track === '009-house')
  assert.equal(house.slots['2:4'], FLUTE)
  const name = freeProjectName('009-house-stems', root)
  assert.equal(name, '009-house-stems')
  const file = projectFromTrack('009-house', { name, columns: ['2:4', '2:3'], backing: ['1:1', '1:3'] }, root)
  const project = JSON.parse(fs.readFileSync(file, 'utf8'))
  assert.deepEqual(project.columns, { '2:3': house.slots['2:3'], '2:4': FLUTE })
  assert.deepEqual(project.context, { track: '009-house', chapter: 0, backing: ['1:1', '1:3'] })
  assert.equal(project.select, '2:3')
  assert.deepEqual(projectErrors(project, file, root), [])
  assert.equal(freeProjectName('009-house-stems', root), '009-house-stems-2')
  assert.throws(() => projectFromTrack('009-house', { name, columns: ['2:4'] }, root), /exists/)
  const fresh = { name: '009-house-x', backing: [] }
  assert.throws(() => projectFromTrack('009-house', { ...fresh, columns: [] }, root), /at least one/)
  assert.throws(() => projectFromTrack('009-house', { ...fresh, columns: ['2:4'], backing: ['2:4'] }, root), /not both/)
  assert.throws(() => projectFromTrack('090-nope', { ...fresh, columns: ['1:1'] }, root), /no stem track/)
})

test('a project as a track: backing and columns on their slots, drafts refused, a context track needed', () => {
  const root = sandbox()
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(withDraft(readProject('flute-explore', root))))
  assert.deepEqual(draftSlots('flute-explore', root), ['1:1'])
  assert.throws(() => trackFromProject('flute-explore', '009-house-v2', root), /promote the drafts on 1:1 first/)
  const { ref } = promote('flute-explore', '1:1', root)
  assert.deepEqual(draftSlots('flute-explore', root), [])
  assert.equal(freeTrackName('009-house', root), '009-house-2')
  const file = trackFromProject('flute-explore', '009-house-2', root)
  const track = JSON.parse(fs.readFileSync(file, 'utf8'))
  const house = listStemTracks(root).find(entry => entry.track === '009-house')
  assert.equal(track.slots['1:1'], ref)
  assert.equal(track.slots['1:2'], FIXTURE.columns['1:2'])
  assert.equal(track.slots['2:4'], undefined)
  assert.deepEqual(Object.keys(track.slots).sort(), ['1:1', '1:2', '1:3', '1:4'])
  assert.equal(track.tempo, 124)
  assert.ok(house.slots['1:1'] !== ref)
  assert.deepEqual(checkFiles([file], root)[0].errors, [])
  assert.equal(freeTrackName('009-house', root), '009-house-3')
  const lone = { ...readProject('flute-explore', root), name: 'lone' }
  delete lone.context
  fs.writeFileSync(projectFile('lone', root), JSON.stringify(lone))
  assert.throws(() => trackFromProject('lone', '009-house-3', root), /no context track/)
})

test('a knob change on a column-code stem overrides what the code did with that knob', () => {
  const root = sandbox()
  const brass = 'brassSection/brass-section-brightness-space-complexity-pattern-lift.stem'
  const withBrass = readProject('flute-explore', root)
  withBrass.columns['1:2'] = brass
  withBrass.columns['1:3'] = 'bassFM/bass-fm-brightness-space-sound-pattern-octave.stem'
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(withBrass))
  const pan = buildKnob('k1', { param: 'pan', range: [-1, 1], default: 0.5, label: 'Pan', about: 'left ↔ right' })
  setKnob('flute-explore', '1:2', 'k1', pan, root)
  const draft = Object.values(readProject('flute-explore', root).drafts)[0]
  assert.equal(draft.controls.k1.override, true)
  setKnob('flute-explore', '1:3', 'k1', pan, root)
  const plain = readProject('flute-explore', root).drafts['bass-fm-1-3']
  assert.equal(plain.controls.k1.override, undefined)
  assert.deepEqual(projectErrors(readProject('flute-explore', root), projectFile('flute-explore', root), root), [])
})
