// The tracks and boards the player can load: live tracks (one-file, tagged '// @mode 16 Mode 1') and lab boards.
// SuperCollider tracks (sc/tracks/*/<name>.scd) are live tracks with engine 'sc' and keep the plain id ('009-house'):
// a stem track (sc/tracks/*/<name>.track, stems: true) too, or '<name>-stems' beside an .scd of the same name;
// once a track is ported, its SC version is the source of truth. The frozen Strudel file of a ported track stays
// playable as '<id>-strudel' (label '… (Strudel)'), its scripts still come from perform/<id>/ (base).
// Every entry has engine 'strudel' or 'sc'. Sample Designer projects (sc/lab/samples/<name>.sample.json) are lab
// entries 'sample-<name>' with engine 'sc', lab 'sample' and project <name>; Stem Designer projects
// (sc/lab/stems/<name>.stemlab.json) 'stems-<name>' with lab 'stems'.
// scan() returns internal entries { id, kind, label, path, taps, noTapReason?, scripts }; path stays on the server,
// toPublic() drops it. Ids are derived from the file location, so they stay the same between scans: a live track is its
// file name ('010-ambient-house'), a lab board its folder and file joined by '-' ('lab-tutorials-harmony-tutorial'); a clash gets '-2'.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { tapSource } from './make-tapped.mjs'
import { listProjects, projectFile } from '../sound-lab/sample-project.mjs'
import * as stemLab from '../sound-lab/stem-project.mjs'

const root = path.dirname(fileURLToPath(import.meta.url))
export const repo = path.resolve(root, '..', '..')
const PERFORM = path.join(root, 'perform')
const LIVE_TAG = /^\/\/ @mode 16 Mode 1/m

const listFiles = dir => {
  if (!fs.existsSync(dir)) return []
  return fs.readdirSync(dir, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name)).flatMap(entry => {
    const full = path.join(dir, entry.name)
    if (entry.isDirectory()) return entry.name === 'archive' ? [] : listFiles(full)
    return entry.name.endsWith('.strudel') ? [full] : []
  })
}

const NOT_LIVE_GENRES = ['historic', 'sets']

const trackFolders = dir => fs.readdirSync(dir, { withFileTypes: true })
  .filter(entry => entry.isDirectory())
  .flatMap(entry => /^\d{3}-/.test(entry.name) ? [path.join(dir, entry.name)] : trackFolders(path.join(dir, entry.name)))

const liveFiles = () => {
  const tracks = path.join(repo, 'tracks')
  if (!fs.existsSync(tracks)) return []
  const folders = fs.readdirSync(tracks, { withFileTypes: true })
    .filter(genre => genre.isDirectory() && !NOT_LIVE_GENRES.includes(genre.name))
    .flatMap(genre => trackFolders(path.join(tracks, genre.name)))
  return folders.flatMap(folder => fs.readdirSync(folder).sort()
    .filter(name => /^\d{3}-[\w-]+\.strudel$/.test(name))
    .map(name => path.join(folder, name))
    .filter(file => LIVE_TAG.test(fs.readFileSync(file, 'utf8'))))
    .sort((a, b) => path.basename(a).localeCompare(path.basename(b)))
}

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

const tapProblem = (source, name) => {
  try {
    tapSource(source, name)
    return null
  } catch (error) {
    return error.message.replace(`${name}: `, '')
  }
}

const slug = text => text.replace(/\.strudel$/, '').replace(/[^\w]+/g, '-').replace(/^-+|-+$/g, '')

export const scan = () => {
  const used = new Set()
  const unique = id => {
    let candidate = id
    for (let n = 2; used.has(candidate); n++) candidate = `${id}-${n}`
    used.add(candidate)
    return candidate
  }
  const entries = []
  const add = (kind, file, id, label, extra = {}) => {
    const problem = tapProblem(fs.readFileSync(file, 'utf8'), path.basename(file))
    const entry = { id: unique(id), kind, label, path: file, taps: !problem, scripts: [], engine: 'strudel', ...extra }
    entries.push(problem ? { ...entry, noTapReason: problem } : entry)
  }
  const scIds = new Set()
  for (const file of scFiles()) {
    const id = path.basename(file, '.scd')
    scIds.add(id)
    entries.push({ id: unique(id), kind: 'live', label: id, path: file, taps: true, scripts: [], engine: 'sc' })
  }
  for (const file of scFiles('.track')) {
    const name = path.basename(file, '.track')
    const [id, label] = scIds.has(name) ? [name + '-stems', name + ' (stems)'] : [name, name]
    scIds.add(name)
    entries.push({ id: unique(id), kind: 'live', label, path: file, taps: true, scripts: [], engine: 'sc',
      stems: true })
  }
  for (const file of liveFiles()) {
    const id = slug(path.basename(file))
    if (scIds.has(id)) add('live', file, id + '-strudel', id + ' (Strudel)', { base: id })
    else add('live', file, id, path.basename(file, '.strudel'))
  }
  for (const file of listFiles(path.join(repo, 'lab'))) {
    const relative = path.relative(path.join(repo, 'lab'), file)
    add('lab', file, 'lab-' + slug(relative), relative.replace(/\.strudel$/, ''))
  }
  for (const name of listProjects(repo)) {
    entries.push({ id: unique('sample-' + name), kind: 'lab', label: 'Sample: ' + name, path: projectFile(name, repo),
      taps: true, scripts: [], engine: 'sc', lab: 'sample', project: name })
  }
  for (const name of stemLab.listProjects(repo)) {
    entries.push({ id: unique('stems-' + name), kind: 'lab', label: 'Stems: ' + name,
      path: stemLab.projectFile(name, repo), taps: true, scripts: [], engine: 'sc', lab: 'stems', project: name })
  }
  for (const entry of entries) if (entry.kind === 'live') entry.scripts = scriptsOf(entry.base ?? entry.id)
  return entries.sort((a, b) => a.kind === b.kind && a.kind === 'live' ? a.id.localeCompare(b.id) : 0)
}

export const toPublic = ({ path: _path, ...entry }) => entry

export const find = id => scan().find(entry => entry.id === id)
