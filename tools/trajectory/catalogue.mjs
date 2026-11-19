// The tracks and boards the player can load: live tracks (one-file, tagged '// @mode 16 Mode 1') and lab boards.
// scan() returns internal entries { id, kind, label, path, taps, noTapReason?, scripts }; path stays on the server,
// toPublic() drops it. Ids are derived from the file location, so they stay the same between scans: a live track is its
// file name ('010-ambient-house'), a lab board its folder and file joined by '-' ('lab-kick-kick-lab'); a clash gets '-2'.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { tapSource } from './make-tapped.mjs'

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
  const folders = fs.readdirSync(tracks, { withFileTypes: true })
    .filter(genre => genre.isDirectory() && !NOT_LIVE_GENRES.includes(genre.name))
    .flatMap(genre => trackFolders(path.join(tracks, genre.name)))
  return folders.flatMap(folder => fs.readdirSync(folder).sort()
    .filter(name => /^\d{3}-[\w-]+\.strudel$/.test(name))
    .map(name => path.join(folder, name))
    .filter(file => LIVE_TAG.test(fs.readFileSync(file, 'utf8'))))
    .sort((a, b) => path.basename(a).localeCompare(path.basename(b)))
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
  const add = (kind, file, id, label) => {
    const problem = tapProblem(fs.readFileSync(file, 'utf8'), path.basename(file))
    const entry = { id: unique(id), kind, label, path: file, taps: !problem, scripts: [] }
    entries.push(problem ? { ...entry, noTapReason: problem } : entry)
  }
  for (const file of liveFiles()) {
    add('live', file, slug(path.basename(file)), path.basename(file, '.strudel'))
  }
  for (const file of listFiles(path.join(repo, 'lab'))) {
    const relative = path.relative(path.join(repo, 'lab'), file)
    add('lab', file, 'lab-' + slug(relative), relative.replace(/\.strudel$/, ''))
  }
  for (const entry of entries) if (entry.kind === 'live') entry.scripts = scriptsOf(entry.id)
  return entries
}

export const toPublic = ({ path: _path, ...entry }) => entry

export const find = id => scan().find(entry => entry.id === id)
