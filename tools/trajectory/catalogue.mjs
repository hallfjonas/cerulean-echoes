// The tracks the player can load: SuperCollider tracks (sc/tracks/*/<name>.scd) are live tracks with engine 'sc' and keep
// the plain id ('009-house'); a stem track (sc/tracks/*/<name>.track, stems: true) too, or '<name>-stems' beside an .scd
// of the same name. Sample Designer projects (sc/lab/samples/<name>.sample.json) are lab entries 'sample-<name>' with
// lab 'sample' and project <name>; Stem Designer projects (sc/lab/stems/<name>.stemlab.json) 'stems-<name>' with lab 'stems'.
// scan() returns internal entries { id, kind, label, path, scripts, engine }; path stays on the server, toPublic()
// drops it. Ids are derived from the file location, so they stay the same between scans: a live track is its folder
// name ('010-ambient-house'); a clash gets '-2'.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { listProjects, projectFile } from '../sound-lab/sample-project.mjs'
import * as stemLab from '../sound-lab/stem-project.mjs'

const root = path.dirname(fileURLToPath(import.meta.url))
export const repo = path.resolve(root, '..', '..')
const PERFORM = path.join(root, 'perform')

// SuperCollider live tracks: sc/tracks/<name>/<name>.scd, stem tracks sc/tracks/<name>/<name>.track
const scFiles = (ext = '.scd') => {
  const dir = path.join(repo, 'sc', 'tracks')
  if (!fs.existsSync(dir)) return []
  return fs.readdirSync(dir, { withFileTypes: true }).filter(entry => entry.isDirectory() && /^\d{3}-/.test(entry.name))
    .map(entry => path.join(dir, entry.name, entry.name + ext)).filter(file => fs.existsSync(file)).sort()
}

const jsonNames = dir => fs.existsSync(dir)
  ? fs.readdirSync(dir).filter(f => /^[\w-]+\.json$/.test(f)).map(f => f.slice(0, -'.json'.length)).sort()
  : []

// The scripts of a live track, then its takes (perform/<id>/takes/, newest first) as 'takes/<name>'
const scriptsOf = id => [...jsonNames(path.join(PERFORM, id)),
  ...jsonNames(path.join(PERFORM, id, 'takes')).reverse().map(name => `takes/${name}`)]

export const scan = () => {
  const used = new Set()
  const unique = id => {
    let candidate = id
    for (let n = 2; used.has(candidate); n++) candidate = `${id}-${n}`
    used.add(candidate)
    return candidate
  }
  const entries = []
  const scIds = new Set()
  for (const file of scFiles()) {
    const id = path.basename(file, '.scd')
    scIds.add(id)
    entries.push({ id: unique(id), kind: 'live', label: id, path: file, scripts: [], engine: 'sc' })
  }
  for (const file of scFiles('.track')) {
    const name = path.basename(file, '.track')
    const [id, label] = scIds.has(name) ? [name + '-stems', name + ' (stems)'] : [name, name]
    scIds.add(name)
    entries.push({ id: unique(id), kind: 'live', label, path: file, scripts: [], engine: 'sc',
      stems: true })
  }
  for (const name of listProjects(repo)) {
    entries.push({ id: unique('sample-' + name), kind: 'lab', label: 'Sample: ' + name, path: projectFile(name, repo),
      scripts: [], engine: 'sc', lab: 'sample', project: name })
  }
  for (const name of stemLab.listProjects(repo)) {
    entries.push({ id: unique('stems-' + name), kind: 'lab', label: 'Stems: ' + name,
      path: stemLab.projectFile(name, repo), scripts: [], engine: 'sc', lab: 'stems', project: name })
  }
  for (const entry of entries) if (entry.kind === 'live') entry.scripts = scriptsOf(entry.id)
  return entries.sort((a, b) => a.kind === b.kind && a.kind === 'live' ? a.id.localeCompare(b.id) : 0)
}

export const toPublic = ({ path: _path, ...entry }) => entry

export const find = id => scan().find(entry => entry.id === id)
