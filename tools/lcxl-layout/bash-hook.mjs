// Claude Code PostToolUse hook (Bash): tracks edited via Bash (python3 -, sed -i) get the same regeneration as an
// Edit (hook.mjs). Candidates are the .strudel files git sees as modified or untracked; a content hash per file
// (cache in the OS temp dir, one per checkout, shared with hook.mjs) tells which changed since the last run. Outputs
// the processing writes itself (-single files, the dual-lc test file) are skipped; tapped copies are git-ignored.
// A file not in the cache yet is processed only if it changed in the last 10 minutes. An error is reported once per
// content change, not on every later Bash call.
import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'
import { root, refresh, report, hashOf, readCache, writeCache } from './hook.mjs'

console.log = console.error
for await (const _ of process.stdin);

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

const cache = readCache()
const hashes = {}
const changed = []
for (const rel of dirty) {
  const abs = path.join(root, rel)
  hashes[rel] = hashOf(abs)
  if (cache?.[rel] ? cache[rel] !== hashes[rel] : Date.now() - fs.statSync(abs).mtimeMs < 10 * 60e3) changed.push(rel)
}
const lines = []
const errors = []
for (const rel of changed) {
  const { line, error } = await refresh(path.join(root, rel))
  if (line) lines.push(line)
  if (error) errors.push(error)
}
const keys = Object.keys(hashes)
if (!cache || Object.keys(cache).length !== keys.length || keys.some(rel => cache[rel] !== hashes[rel])) {
  writeCache(hashes)
}
report(lines, errors)
