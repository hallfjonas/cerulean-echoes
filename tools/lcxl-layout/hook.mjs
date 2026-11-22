// Claude Code PostToolUse hook (Edit|Write): after a .strudel file changes, check its @-tags (ctl.mjs; a broken tag is
// reported back, exit 2). A -dual.strudel file (or the dual-lc template) also rewrites its single version
// (make-single.mjs; since set 011 was removed only the template has one). Layout sheets and .syx modes are no longer
// made (retired 2026-11-20); the offline sound check went with the Strudel tools (sc-migration 010).
// On success one line says what was regenerated. bash-hook.mjs runs the same `refresh` for files changed via Bash;
// both record each processed file's content hash in a shared cache, so a file is processed once per change.
import crypto from 'crypto'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { fileURLToPath } from 'url'

export const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')

const cacheFile = path.join(os.tmpdir(), 'cerulean-echoes-hooks',
  crypto.createHash('sha1').update(root).digest('hex').slice(0, 12) + '-strudel.json')
export const hashOf = file => crypto.createHash('sha1').update(fs.readFileSync(file)).digest('hex')
export function readCache() {
  try { return JSON.parse(fs.readFileSync(cacheFile, 'utf8')) } catch { return null }
}
export function writeCache(hashes) {
  fs.mkdirSync(path.dirname(cacheFile), { recursive: true })
  fs.writeFileSync(cacheFile, JSON.stringify(hashes))
}

// Regenerates everything derived from one .strudel file: { line, error } (line: what was regenerated, or '')
export async function refresh(file) {
  const made = []
  try {
    const { parse } = await import('./ctl.mjs')
    const { makeSingle, singleOf } = await import('./make-single.mjs')
    const files = [file]
    if (singleOf(file)) {
      files.push(makeSingle(file))
      made.push('single')
    }
    for (const f of files) parse(fs.readFileSync(f, 'utf8'), f)
  } catch (e) {
    return { line: '', error: `${path.basename(file)}: tags or single version: ${e.stderr?.toString() || e.message}` }
  }
  const line = made.length ? `${path.relative(root, path.resolve(file))}: regenerated ${made.join(', ')}` : ''
  return { line, error: '' }
}

// Reports back to Claude: errors on stderr with exit 2, otherwise the lines as additionalContext
export function report(lines, errors) {
  if (errors.length) {
    console.error([...lines, ...errors].join('\n'))
    process.exit(2)
  }
  if (lines.length) process.stdout.write(JSON.stringify({
    hookSpecificOutput: { hookEventName: 'PostToolUse', additionalContext: lines.join('\n') } }))
  process.exit(0)
}

if (fs.realpathSync(process.argv[1]) === fs.realpathSync(fileURLToPath(import.meta.url))) {
  console.log = console.error
  let input = ''
  for await (const chunk of process.stdin) input += chunk
  const file = JSON.parse(input).tool_input?.file_path
  if (!file?.endsWith('.strudel')) process.exit(0)
  const { line, error } = await refresh(file)
  const rel = path.relative(root, path.resolve(file))
  if (!rel.startsWith('..') && fs.existsSync(file)) {
    try { writeCache({ ...readCache(), [rel]: hashOf(file) }) } catch {}
  }
  report(line ? [line] : [], error ? [error] : [])
}
