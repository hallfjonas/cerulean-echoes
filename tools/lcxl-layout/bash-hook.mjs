// Claude Code PostToolUse hook (Bash): tracks edited via Bash (python3 -, sed -i) get the same regeneration as an
// Edit (hook.mjs). Candidates are the .strudel files git sees as modified or untracked; a content hash per file
// (cache in the OS temp dir, one per checkout) tells which changed since the last run. Outputs the processing writes
// itself (-single files, the dual-lc test file) are skipped; tapped copies are git-ignored.
// On the first run without a cache only files changed in the last 10 minutes are processed.
import { execFileSync } from 'child_process'
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { root, refresh, report } from './hook.mjs'

console.log = console.error
for await (const _ of process.stdin);

const cacheFile = path.join(os.tmpdir(), 'cerulean-echoes-hooks',
  crypto.createHash('sha1').update(root).digest('hex').slice(0, 12) + '-strudel.json')
const status = execFileSync('git', ['status', '--porcelain', '-z', '--untracked-files=all', '--', '*.strudel'],
  { cwd: root, encoding: 'utf8' }).split('\0')
const dirty = []
for (let i = 0; i < status.length; i++) {
  if (!status[i]) continue
  if (/^[RC]/.test(status[i])) i++
  const rel = status[i].slice(3)
  if (/-single\.strudel$|(^|\/)dual-lc-test\.strudel$/.test(rel) || !fs.existsSync(path.join(root, rel))) continue
  dirty.push(rel)
}

let cache = null
try { cache = JSON.parse(fs.readFileSync(cacheFile, 'utf8')) } catch {}
const hashes = {}
const changed = []
for (const rel of dirty) {
  const abs = path.join(root, rel)
  hashes[rel] = crypto.createHash('sha1').update(fs.readFileSync(abs)).digest('hex')
  if (cache ? cache[rel] !== hashes[rel] : Date.now() - fs.statSync(abs).mtimeMs < 10 * 60e3) changed.push(rel)
}
const lines = []
const errors = []
for (const rel of changed) {
  const { line, error } = await refresh(path.join(root, rel))
  if (line) lines.push(line)
  if (error) { errors.push(error); delete hashes[rel] }
}
const keys = Object.keys(hashes)
if (!cache || Object.keys(cache).length !== keys.length || keys.some(rel => cache[rel] !== hashes[rel])) {
  fs.mkdirSync(path.dirname(cacheFile), { recursive: true })
  fs.writeFileSync(cacheFile, JSON.stringify(hashes))
}
report(lines, errors)
