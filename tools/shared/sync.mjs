// Shared regions: a block that several tracks hold word for word is marked in each of them with
// `// @shared <name> begin` … `// @shared <name> end`. Its canonical copy is tools/shared/<name>.strudel-part.
// usage (in tools/): node shared/sync.mjs [--check] [--from <track>] [<name>]
//   (no flag)       write the canonical block into every track that marks the region
//   --check         report each track whose region differs from the canonical block (unified diff); exit 1 on drift
//   --from <track>  the region as it is in this track (path or part of its file name) becomes canonical, then write
//   <name>          only this region (default: all)
import fs from 'fs'
import os from 'os'
import path from 'path'
import { spawnSync } from 'child_process'
import { fileURLToPath } from 'url'

const HERE = path.dirname(fileURLToPath(import.meta.url))
const ROOT = path.resolve(HERE, '../..')
const MARK = /^\/\/ @shared (\S+) (begin|end)$/

const args = process.argv.slice(2)
const check = args.includes('--check')
const from = args.includes('--from') ? args[args.indexOf('--from') + 1] : undefined
const only = args.find((a, i) => !a.startsWith('--') && args[i - 1] !== '--from')
if (check && from) {
  console.error('--check and --from do not go together')
  process.exit(1)
}

const walk = dir => fs.readdirSync(dir, { withFileTypes: true }).flatMap(e =>
  e.isDirectory() ? walk(path.join(dir, e.name)) : e.name.endsWith('.strudel') ? [path.join(dir, e.name)] : [])

const regionsOf = file => {
  const lines = fs.readFileSync(file, 'utf8').split('\n')
  const found = {}
  let open = null
  lines.forEach((line, i) => {
    const m = line.match(MARK)
    if (!m) return
    const [, name, edge] = m
    const where = path.relative(ROOT, file) + ':' + (i + 1)
    if (edge === 'begin') {
      if (open) throw new Error(where + ': region ' + name + ' begins inside region ' + open.name)
      if (found[name]) throw new Error(where + ': region ' + name + ' appears twice')
      open = { name, begin: i }
    } else {
      if (open?.name !== name) throw new Error(where + ': end of ' + name + ' without its begin')
      found[name] = { begin: open.begin, end: i, body: lines.slice(open.begin + 1, i).join('\n') }
      open = null
    }
  })
  if (open) throw new Error(path.relative(ROOT, file) + ': region ' + open.name + ' has no end')
  return { lines, found }
}

const tracks = walk(path.join(ROOT, 'tracks')).filter(f => fs.readFileSync(f, 'utf8').includes('// @shared '))
  .map(file => ({ file, ...regionsOf(file) }))
const partFile = name => path.join(HERE, name + '.strudel-part')
const names = [...new Set(tracks.flatMap(t => Object.keys(t.found)))].filter(n => !only || n === only).sort()
if (only && !names.length) {
  console.error('no track marks region ' + only)
  process.exit(1)
}

if (from) {
  const hits = tracks.filter(t => path.resolve(from) === t.file || path.basename(t.file).includes(from))
  if (hits.length !== 1) {
    console.error('--from ' + from + ' matches ' + hits.length + ' tracks with shared regions')
    process.exit(1)
  }
  if (only && !hits[0].found[only]) {
    console.error(path.relative(ROOT, hits[0].file) + ' does not mark region ' + only)
    process.exit(1)
  }
  for (const name of names) {
    if (!hits[0].found[name]) continue
    fs.writeFileSync(partFile(name), hits[0].found[name].body + '\n')
    console.log('canonical', name, '←', path.relative(ROOT, hits[0].file))
  }
}

const unified = (a, b, label) => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'shared-'))
  fs.writeFileSync(path.join(dir, 'canonical'), a)
  fs.writeFileSync(path.join(dir, 'track'), b)
  const out = spawnSync('diff', ['-u', '--label', 'canonical', '--label', label, 'canonical', 'track'], { cwd: dir })
  fs.rmSync(dir, { recursive: true })
  return out.stdout.toString()
}

let drift = 0
for (const name of names) {
  if (!fs.existsSync(partFile(name))) {
    console.error('region ' + name + ': no canonical copy ' + path.relative(ROOT, partFile(name)) +
      ' (make it with --from <track> ' + name + ')')
    drift++
    continue
  }
  const canonical = fs.readFileSync(partFile(name), 'utf8').replace(/\n$/, '')
  for (const t of tracks.filter(t => t.found[name])) {
    const rel = path.relative(ROOT, t.file)
    if (t.found[name].body === canonical) {
      if (check) console.log('same   ', name.padEnd(16), rel)
      continue
    }
    if (check) {
      drift++
      console.log('DRIFT  ', name.padEnd(16), rel)
      console.log(unified(canonical + '\n', t.found[name].body + '\n', rel))
      continue
    }
    const { begin, end } = regionsOf(t.file).found[name]
    const lines = fs.readFileSync(t.file, 'utf8').split('\n')
    lines.splice(begin + 1, end - begin - 1, ...canonical.split('\n'))
    fs.writeFileSync(t.file, lines.join('\n'))
    console.log('wrote  ', name.padEnd(16), rel)
  }
}
process.exit(drift ? 1 : 0)
