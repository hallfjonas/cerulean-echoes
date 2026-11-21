// Stem Designer projects (sc/lab/stems/<name>.stemlab.json): check, save, save as, promote to the stem library.
// Format: sc/lab/stems/stemlab.schema.json and docs/features/sound-lab.md. A column names a library stem version
// ('flute/flute-….stem') or a draft of the project ('draft:<id>', the stem itself in "drafts").
// The running designer reports { select: '2:4' } (the column the player moved last); everything else is on disk.
import fs from 'fs'
import os from 'os'
import path from 'path'
import { checkFiles, kebab, repoRoot, stemBaseName, validate } from '../stems/check-stems.mjs'
import { withKnob } from '../stems/knob.mjs'
import { pretty } from './sample-project.mjs'

export { repoRoot }
export const stemLabDir = (root = repoRoot) => path.join(root, 'sc', 'lab', 'stems')
export const projectFile = (name, root = repoRoot) => path.join(stemLabDir(root), `${name}.stemlab.json`)
export const NAME = /^[a-z0-9]+(-[a-z0-9]+)*$/

const readJson = file => JSON.parse(fs.readFileSync(file, 'utf8'))

export const listProjects = (root = repoRoot) => fs.existsSync(stemLabDir(root))
  ? fs.readdirSync(stemLabDir(root)).filter(f => f.endsWith('.stemlab.json')).map(f => f.slice(0, -13)).sort()
  : []
export const SLOTS = ['1:1', '1:2', '1:3', '1:4', '1:5', '1:6', '1:7', '2:1', '2:2', '2:3', '2:4', '2:5', '2:6', '2:7']

export const readProject = (name, root = repoRoot) => readJson(projectFile(name, root))

const draftErrors = (id, draft, root) => {
  if (!draft?.sample?.name) return [`draft "${id}": no sample.name`]
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'stemlab-'))
  try {
    const stem = { ...draft, name: 'x' }
    stem.name = stemBaseName(stem)
    const file = path.join(dir, stem.sample.name, `${stem.name}.stem`)
    fs.mkdirSync(path.dirname(file))
    const home = path.join(root, 'sc', 'stems', draft.parent ? path.dirname(draft.parent) : draft.sample.name)
    if (fs.existsSync(home)) {
      for (const sibling of fs.readdirSync(home).filter(name => !name.endsWith('.stem'))) {
        fs.copyFileSync(path.join(home, sibling), path.join(path.dirname(file), sibling))
      }
    }
    fs.writeFileSync(file, JSON.stringify(stem))
    return checkFiles([file], root)[0].errors.filter(e => !/ label /.test(e)).map(e => `draft "${id}": ${e}`)
  } catch (error) {
    return [`draft "${id}": ${error.message}`]
  } finally {
    fs.rmSync(dir, { recursive: true, force: true })
  }
}

export function projectErrors(project, file, root = repoRoot) {
  const schema = readJson(path.join(stemLabDir(root), 'stemlab.schema.json'))
  const errors = validate(schema, project)
  if (errors.length) return errors
  const base = path.basename(file, '.stemlab.json')
  if (base !== project.name) errors.push(`file name "${base}" is not the project name "${project.name}"`)
  if (project.parent && !fs.existsSync(projectFile(project.parent, root))) {
    errors.push(`parent "${project.parent}" not found in sc/lab/stems/`)
  }
  const track = project.context?.track
  if (track && !fs.existsSync(path.join(root, 'sc', 'tracks', track, `${track}.track`))) {
    errors.push(`context track "${track}" not found in sc/tracks/`)
  }
  if (project.select && !project.columns[project.select]) errors.push(`select: no column ${project.select}`)
  const used = new Set()
  for (const [slot, ref] of Object.entries(project.columns)) {
    if (ref.startsWith('draft:')) {
      const id = ref.slice(6)
      used.add(id)
      if (!project.drafts?.[id]) errors.push(`column ${slot}: no draft "${id}"`)
    } else if (!fs.existsSync(path.join(root, 'sc', 'stems', ref))) errors.push(`column ${slot}: stem "${ref}" not found`)
  }
  for (const id of Object.keys(project.drafts ?? {})) {
    if (!used.has(id)) errors.push(`draft "${id}" is on no column`)
    else errors.push(...draftErrors(id, project.drafts[id], root))
  }
  return errors
}

export function checkProjectFile(file, root = repoRoot) {
  let project
  try { project = readJson(file) } catch (error) { return [`not valid JSON: ${error.message}`] }
  return projectErrors(project, file, root)
}

export const checkAll = (root = repoRoot) => listProjects(root).map(name => projectFile(name, root))
  .map(file => ({ file, errors: checkProjectFile(file, root) }))

const writeProject = (project, root) => {
  const file = projectFile(project.name, root)
  const errors = projectErrors(project, file, root)
  if (errors.length) throw new Error(`${project.name}: ${errors.join('; ')}`)
  fs.writeFileSync(file, pretty(project) + '\n')
  return file
}

const withValues = (project, values) => {
  const out = structuredClone(project)
  if (values?.select && out.columns[values.select]) out.select = values.select
  return out
}

const guardDraft = (project, slot, verb) => {
  const ref = project.columns[slot]
  if (!ref) throw new Error(`no column ${slot} in "${project.name}"`)
  if (ref.startsWith('draft:')) throw new Error(`column ${slot} holds a draft: promote it before you ${verb} it`)
}

export function addColumn(name, ref, wanted, root = repoRoot) {
  const project = readProject(name, root)
  const slot = wanted ?? SLOTS.find(candidate => !project.columns[candidate])
  if (!slot) throw new Error(`"${name}" has all ${SLOTS.length} columns`)
  if (!SLOTS.includes(slot)) throw new Error(`no slot ${slot}: 1:1 to 2:7`)
  if (project.columns[slot]) throw new Error(`slot ${slot} holds a stem already: replace it`)
  project.columns[slot] = ref
  writeProject(project, root)
  return { slot }
}

export function replaceColumn(name, slot, ref, root = repoRoot) {
  const project = readProject(name, root)
  guardDraft(project, slot, 'replace')
  project.columns[slot] = ref
  writeProject(project, root)
  return { slot }
}

const freeDraftId = (project, base) => {
  let id = base
  for (let n = 2; project.drafts?.[id]; n++) id = `${base}-${n}`
  return id
}

export function stemOf(name, slot, root = repoRoot) {
  const project = readProject(name, root)
  const ref = project.columns[slot]
  if (!ref) throw new Error(`no column ${slot} in "${name}"`)
  const draft = ref.startsWith('draft:')
  return { ref, draft, stem: draft ? project.drafts[ref.slice(6)] : readJson(path.join(root, 'sc', 'stems', ref)) }
}

// the knob of a column replaced: a library stem becomes a draft of the project (parent = that version), a draft is
// changed in place; Promote writes a draft into the library
export function setKnob(name, slot, key, knob, root = repoRoot) {
  const project = readProject(name, root)
  const { ref, draft, stem } = stemOf(name, slot, root)
  const next = withKnob(stem, key, stem.code ? { ...knob, override: true } : knob)
  const id = draft ? ref.slice(6) : freeDraftId(project, `${kebab(stem.sample.name)}-${slot.replace(':', '-')}`)
  if (!draft) next.parent = ref
  project.drafts = { ...project.drafts, [id]: next }
  project.columns[slot] = `draft:${id}`
  writeProject(project, root)
  return { slot, draft: id }
}

export function removeColumn(name, slot, root = repoRoot, { discard = false } = {}) {
  const project = readProject(name, root)
  if (!discard) guardDraft(project, slot, 'remove')
  const ref = project.columns[slot]
  if (!ref) throw new Error(`no column ${slot} in "${name}"`)
  if (discard && ref.startsWith('draft:')) {
    delete project.drafts[ref.slice(6)]
    if (!Object.keys(project.drafts).length) delete project.drafts
  }
  delete project.columns[slot]
  if (project.select === slot) {
    const [first] = Object.keys(project.columns).sort()
    if (first) project.select = first
    else delete project.select
  }
  writeProject(project, root)
  return { slot }
}

export const saveProject = (name, values, root = repoRoot) => writeProject(withValues(readProject(name, root), values), root)

export function saveAs(name, newName, values, root = repoRoot) {
  if (!NAME.test(newName ?? '')) throw new Error(`"${newName}": lowercase words joined by "-" (flute-round-2)`)
  if (fs.existsSync(projectFile(newName, root))) throw new Error(`project "${newName}" exists already`)
  return writeProject({ ...withValues(readProject(name, root), values), name: newName, parent: name }, root)
}

const freeName = (dir, base) => {
  let name = base
  for (let n = 2; fs.existsSync(path.join(dir, `${name}.stem`)); n++) name = `${base}-${n}`
  return name
}

export function promote(name, slot, root = repoRoot) {
  const project = readProject(name, root)
  const ref = project.columns[slot]
  if (!ref) throw new Error(`no column ${slot} in "${name}"`)
  if (!ref.startsWith('draft:')) throw new Error(`column ${slot} is ${ref}: in the library already`)
  const id = ref.slice(6)
  const draft = project.drafts[id]
  const dir = path.join(root, 'sc', 'stems', draft.sample.name)
  const stem = { ...draft, name: '' }
  stem.name = freeName(dir, stemBaseName(stem))
  stem.parent = draft.parent ?? null
  const file = path.join(dir, `${stem.name}.stem`)
  fs.mkdirSync(dir, { recursive: true })
  fs.writeFileSync(file, pretty(stem) + '\n')
  const errors = checkFiles([file], root)[0].errors
  if (errors.length) {
    fs.rmSync(file)
    throw new Error(`promote ${id}: ${errors.join('; ')}`)
  }
  const libraryRef = `${draft.sample.name}/${stem.name}.stem`
  const next = structuredClone(project)
  next.columns[slot] = libraryRef
  delete next.drafts[id]
  if (!Object.keys(next.drafts).length) delete next.drafts
  writeProject(next, root)
  return { file, ref: libraryRef }
}

const TRACK_NAME = /^[0-9]{3}-[a-z0-9]+(-[a-z0-9]+)*$/
const trackDir = (name, root) => path.join(root, 'sc', 'tracks', name)
const trackFile = (name, root) => path.join(trackDir(name, root), `${name}.track`)
const readTrack = (name, root) => {
  if (!fs.existsSync(trackFile(name, root))) throw new Error(`no stem track "${name}" in sc/tracks/`)
  return readJson(trackFile(name, root))
}

export const listStemTracks = (root = repoRoot) => {
  const dir = path.join(root, 'sc', 'tracks')
  if (!fs.existsSync(dir)) return []
  return fs.readdirSync(dir).filter(name => TRACK_NAME.test(name) && fs.existsSync(trackFile(name, root))).sort()
    .map(name => {
      const { about, slots } = readTrack(name, root)
      return { track: name, about, slots }
    })
}

const freeNumbered = (base, taken) => {
  let name = base
  for (let n = 2; taken(name); n++) name = `${base}-${n}`
  return name
}

export const freeProjectName = (base, root = repoRoot) => freeNumbered(base, name => fs.existsSync(projectFile(name, root)))

export const freeTrackName = (base, root = repoRoot) => freeNumbered(base, name => fs.existsSync(trackDir(name, root)))

// a new project from the stems of a stem track: the slots in columns are explored, those in backing play along
export function projectFromTrack(track, { name, columns = [], backing = [] }, root = repoRoot) {
  if (!NAME.test(name ?? '')) throw new Error(`"${name}": lowercase words joined by "-" (009-house-stems)`)
  if (fs.existsSync(projectFile(name, root))) throw new Error(`project "${name}" exists already`)
  const { slots } = readTrack(track, root)
  if (!columns.length) throw new Error('pick at least one stem for the lab')
  for (const slot of [...columns, ...backing]) {
    if (!slots[slot]) throw new Error(`slot ${slot} holds no stem in ${track}`)
  }
  const both = columns.filter(slot => backing.includes(slot))
  if (both.length) throw new Error(`slot ${both.join(', ')}: lab or backing, not both`)
  const sorted = [...columns].sort()
  return writeProject({
    format: 1, name, parent: null, about: `Stems of ${track}.`,
    context: { track, chapter: 0, backing: [...backing].sort() },
    select: sorted[0],
    columns: Object.fromEntries(sorted.map(slot => [slot, slots[slot]])),
  }, root)
}

const writeTrack = (trackName, newName, slots, root) => {
  if (!TRACK_NAME.test(newName ?? '')) throw new Error(`"${newName}": three digits, a dash, lowercase words (009-house-v2)`)
  const dir = trackDir(newName, root)
  if (fs.existsSync(dir)) throw new Error(`sc/tracks/${newName} exists: pick another name`)
  const json = readTrack(trackName, root)
  const frame = `${newName}-frame.scd`
  fs.mkdirSync(dir)
  fs.copyFileSync(path.join(trackDir(trackName, root), json.frame), path.join(dir, frame))
  const file = trackFile(newName, root)
  const sorted = Object.fromEntries(Object.entries(slots).sort(([a], [b]) => a.localeCompare(b)))
  fs.writeFileSync(file, JSON.stringify({ ...json, name: newName, frame, slots: sorted }, null, 2) + '\n')
  const errors = checkFiles([file], root)[0].errors
  if (errors.length) {
    fs.rmSync(dir, { recursive: true })
    throw new Error(`${newName}: ${errors.join('; ')}`)
  }
  return file
}

export function trackWith(trackName, newName, slots, root = repoRoot) {
  const json = readTrack(trackName, root)
  for (const [slot, ref] of Object.entries(slots)) {
    if (!json.slots[slot]) throw new Error(`slot ${slot} holds no stem in ${trackName}`)
    if (ref.startsWith('draft:')) throw new Error(`slot ${slot}: promote the draft first`)
  }
  return writeTrack(trackName, newName, { ...json.slots, ...slots }, root)
}

// a project as a stem track: the context track's frame and backing stems, the project's columns on top
export const draftSlots = (name, root = repoRoot) => Object.entries(readProject(name, root).columns)
  .filter(([, ref]) => ref.startsWith('draft:')).map(([slot]) => slot).sort()

export function trackFromProject(name, newName, root = repoRoot) {
  const project = readProject(name, root)
  const track = project.context?.track
  if (!track) throw new Error(`"${name}" has no context track: its frame is what a track plays in`)
  const drafts = draftSlots(name, root)
  if (drafts.length) throw new Error(`promote the drafts on ${drafts.join(', ')} first`)
  const { slots } = readTrack(track, root)
  const backing = Object.fromEntries((project.context.backing ?? []).filter(slot => slots[slot])
    .map(slot => [slot, slots[slot]]))
  return writeTrack(track, newName, { ...backing, ...project.columns }, root)
}
