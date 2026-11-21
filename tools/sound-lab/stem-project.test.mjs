// Feature tests for Stem Designer projects: the projects pass, the check catches broken copies, Save / Save as write
// the selection, Promote writes a new library version and never overwrites. Loose checks only.
// The SC side (load, play, A/B): tools/sc-test/stem-designer.test.mjs.
import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { checkFiles } from '../stems/check-stems.mjs'
import { scan } from '../trajectory/catalogue.mjs'
import { checkAll, listProjects, projectErrors, projectFile, promote, readProject, repoRoot, saveAs, saveProject }
  from './stem-project.mjs'

const sandboxes = []
test.after(() => sandboxes.forEach(root => fs.rmSync(root, { recursive: true, force: true })))

function sandbox() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'stem-lab-'))
  sandboxes.push(root)
  for (const dir of ['lab/stems', 'stems', 'sounds', 'tracks/009-house']) {
    fs.cpSync(path.join(repoRoot, 'sc', dir), path.join(root, 'sc', dir), { recursive: true })
  }
  return root
}

const FLUTE = 'flute/flute-brightness-space-complexity-pattern-echo-throw.stem'
const withDraft = (project, id = 'airy') => {
  const stem = JSON.parse(fs.readFileSync(path.join(repoRoot, 'sc', 'stems', FLUTE), 'utf8'))
  stem.parent = FLUTE
  stem.about = 'Flute, airier.'
  project.drafts = { [id]: stem }
  project.columns['2:4'] = `draft:${id}`
  return project
}

test('every Stem Designer project passes the check', () => {
  const results = checkAll()
  assert.ok(results.length >= 1)
  for (const { file, errors } of results) assert.deepEqual(errors, [], file)
})

test('the check catches broken projects', () => {
  const broken = change => {
    const project = readProject('flute-explore')
    change(project)
    return projectErrors(project, projectFile('flute-explore')).join('\n')
  }
  assert.equal(broken(() => {}), '')
  assert.match(broken(p => { p.columns['2:4'] = 'flute/nope.stem' }), /not found/)
  assert.match(broken(p => { p.columns['3:1'] = FLUTE }), /3:1/)
  assert.match(broken(p => { p.columns['2:4'] = 'draft:gone' }), /no draft "gone"/)
  assert.match(broken(p => { p.context.track = '999-none' }), /context track/)
  assert.match(broken(p => { p.select = '1:1' }), /no column 1:1/)
  assert.match(broken(p => { p.name = 'other' }), /file name/)
  assert.match(broken(p => { withDraft(p).drafts.airy.sample = {} }), /draft "airy"/)
  assert.match(broken(p => { withDraft(p).drafts.spare = {} }), /on no column/)
})

test('Save writes the selected column, Save as copies with the parent', () => {
  const root = sandbox()
  saveProject('flute-explore', { select: '2:6' }, root)
  assert.equal(readProject('flute-explore', root).select, '2:6')
  const file = saveAs('flute-explore', 'flute-round-2', { select: '2:5' }, root)
  assert.equal(file, projectFile('flute-round-2', root))
  const copy = readProject('flute-round-2', root)
  assert.deepEqual([copy.parent, copy.select], ['flute-explore', '2:5'])
  assert.throws(() => saveAs('flute-explore', 'flute-round-2', null, root), /exists already/)
  assert.throws(() => saveAs('flute-explore', 'Bad Name', null, root), /lowercase/)
})

test('Promote writes a new stem version with the parent, never overwrites', () => {
  const root = sandbox()
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(withDraft(readProject('flute-explore', root))))
  const first = promote('flute-explore', '2:4', root)
  assert.equal(path.basename(first.file), path.basename(FLUTE).replace('.stem', '-2.stem'))
  assert.equal(JSON.parse(fs.readFileSync(first.file, 'utf8')).parent, FLUTE)
  assert.deepEqual(checkFiles([first.file], root)[0].errors, [])
  const project = readProject('flute-explore', root)
  assert.equal(project.columns['2:4'], first.ref)
  assert.equal(project.drafts, undefined)
  assert.throws(() => promote('flute-explore', '2:4', root), /in the library already/)
  fs.writeFileSync(projectFile('flute-explore', root), JSON.stringify(withDraft(project)))
  assert.notEqual(promote('flute-explore', '2:4', root).ref, first.ref)
})

test('the player lists the projects under Lab', () => {
  const entry = scan().find(e => e.id === 'stems-flute-explore')
  assert.ok(entry, 'catalogue entry')
  assert.deepEqual([entry.kind, entry.engine, entry.lab, entry.project], ['lab', 'sc', 'stems', 'flute-explore'])
  assert.ok(listProjects().includes('flute-explore'))
})
