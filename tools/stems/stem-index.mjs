// The stem library as data: versions grouped by stem, lineage (parent / children) and the tracks that use each
// version, computed from sc/tracks/*/*.track and never stored. Shared by `npm run stems` and GET /stems.
// Format and rules: docs/features/stems.md.
import fs from 'fs'
import path from 'path'
import { libraryFiles, repoRoot, stemBaseName } from './check-stems.mjs'

const readJson = file => {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')) } catch { return null }
}

const toSlash = file => file.split(path.sep).join('/')

const isReadableStem = stem => stem?.name && stem.sample?.name && stem.meta && stem.controls

export function parseEnergy(text) {
  const match = /^([1-5])(?:(-)([1-5])?)?$/.exec(String(text).trim())
  if (!match) throw new Error(`energy "${text}": use 3, 2-4 or 3- (from 3 up)`)
  const low = Number(match[1])
  const high = match[2] ? Number(match[3] ?? 5) : low
  if (low > high) throw new Error(`energy "${text}": the low end is above the high end`)
  return [low, high]
}

function trackUsage(root) {
  const usage = new Map()
  for (const file of libraryFiles(root).filter(f => f.endsWith('.track'))) {
    const track = readJson(file)
    if (!track?.slots) continue
    for (const [slot, ref] of Object.entries(track.slots)) {
      if (!usage.has(ref)) usage.set(ref, new Map())
      const tracks = usage.get(ref)
      tracks.set(track.name, [...(tracks.get(track.name) ?? []), slot])
    }
  }
  return usage
}

export function buildIndex(root = repoRoot) {
  const stemsDir = path.join(root, 'sc', 'stems')
  const usage = trackUsage(root)
  const groups = new Map()
  const skipped = []
  const versions = []
  for (const file of libraryFiles(root).filter(f => f.endsWith('.stem'))) {
    const relative = toSlash(path.relative(stemsDir, file))
    const stem = readJson(file)
    if (!isReadableStem(stem)) {
      skipped.push(relative)
      continue
    }
    const version = {
      file: relative,
      name: stem.name,
      parent: stem.parent ?? null,
      children: [],
      about: stem.about ?? '',
      meta: stem.meta,
      usedBy: [...(usage.get(relative) ?? [])].map(([track, slots]) => ({ track, slots }))
        .sort((a, b) => a.track.localeCompare(b.track))
    }
    versions.push(version)
    const group = stemBaseName(stem)
    if (!groups.has(group)) groups.set(group, { stem: group, sample: stem.sample.name, versions: [] })
    groups.get(group).versions.push(version)
  }
  const byFile = new Map(versions.map(version => [version.file, version]))
  for (const version of versions) byFile.get(version.parent)?.children.push(version.file)
  for (const version of versions) {
    version.parentMissing = Boolean(version.parent) && !byFile.has(version.parent)
    version.children.sort()
  }
  const stems = [...groups.values()].sort((a, b) => a.sample.localeCompare(b.sample) || a.stem.localeCompare(b.stem))
  for (const stem of stems) stem.versions.sort((a, b) => a.file.localeCompare(b.file))
  return { stems, skipped: skipped.sort() }
}

export function filterIndex(index, { role, genre, energy, tag } = {}) {
  const [low, high] = energy === undefined ? [1, 5] : parseEnergy(energy)
  const keep = ({ meta }) => (!role || meta.role === role) && (!genre || meta.genres?.includes(genre)) &&
    (!tag || meta.tags?.includes(tag)) && meta.energy >= low && meta.energy <= high
  const stems = index.stems.map(stem => ({ ...stem, versions: stem.versions.filter(keep) }))
    .filter(stem => stem.versions.length)
  return { ...index, stems }
}

export const stemIndex = (filters, root = repoRoot) => filterIndex(buildIndex(root), filters)

const baseName = file => path.posix.basename(file)

function versionLines(version, usedBy) {
  const { role, genres, energy, tags } = version.meta
  const parent = version.parent ? baseName(version.parent) + (version.parentMissing ? ' (missing)' : '') : 'none'
  const children = version.children.length ? `  children: ${version.children.map(baseName).join(', ')}` : ''
  const lines = [
    `  ${version.name}`,
    `    ${role} | ${genres.join(', ')} | energy ${energy} | ${tags.join(', ') || '-'}  ${version.about}`,
    `    parent: ${parent}${children}`
  ]
  if (usedBy) {
    const used = version.usedBy.map(({ track, slots }) => `${track} (${slots.join(', ')})`).join(', ')
    lines.push(`    used by: ${used || 'no track'}`)
  }
  return lines
}

export function formatIndex(index, { usedBy = false } = {}) {
  const lines = []
  for (const stem of index.stems) {
    const count = stem.versions.length
    lines.push(`${stem.stem}  (sample ${stem.sample}, ${count} version${count === 1 ? '' : 's'})`)
    for (const version of stem.versions) lines.push(...versionLines(version, usedBy))
  }
  if (!index.stems.length) lines.push('no stem matches')
  for (const file of index.skipped) lines.push(`skipped (not a readable stem): ${file}`)
  return lines.join('\n')
}
