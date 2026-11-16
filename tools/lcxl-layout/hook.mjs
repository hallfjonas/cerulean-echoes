// Claude Code PostToolUse hook (Edit|Write): after a .strudel file changes, regenerate its layout sheet.
// A -dual.strudel file (or the dual-lc template) also rewrites its single version (make-single.mjs) and that sheet.
// Tracks (tracks/) also get their custom modes (.syx, make-syx.mjs).
// Files without @ctl tags are skipped. A broken tag or Typst error is reported back (exit 2).
// A track with a tapped copy (tools/trajectory/tapped/) gets that copy rebuilt (make-tapped.mjs).
// A track (tracks/, not old/) is compared with the sound list samples/sounds.json (check-sounds.mjs --offline): a sound
// that is broken or not checked yet is reported back (exit 2).
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
  const inTracks = f => path.resolve(f).startsWith(path.join(root, 'tracks') + path.sep)
  let checkOffline
  try {
    const { generate } = await import('./gen-layout.mjs')
    const { makeSingle, singleOf } = await import('./make-single.mjs')
    const { generate: makeSyx } = await import('./make-syx.mjs')
    const { refreshTapped } = await import('../trajectory/make-tapped.mjs')
    ;({ checkOffline } = await import('../strudel-sim/check-sounds.mjs'))
    if (refreshTapped(file)) made.push('tapped')
    const files = [file]
    if (singleOf(file)) {
      files.push(makeSingle(file))
      made.push('single')
    }
    for (const f of files) {
      if (!generate(f, root)) continue
      if (!made.includes('PDF')) made.push('PDF')
      if (inTracks(f) && makeSyx(f).length && !made.includes('syx')) made.push('syx')
    }
  } catch (e) {
    return { line: '', error: `layout sheet for ${path.basename(file)} not updated: ${e.stderr?.toString() || e.message}` }
  }
  const line = made.length ? `${path.relative(root, path.resolve(file))}: regenerated ${made.join(', ')}` : ''
  let problems = []
  try { if (inTracks(file) && !file.includes(`${path.sep}old${path.sep}`)) problems = await checkOffline(file) } catch {}
  if (!problems.length) return { line, error: '' }
  return { line, error: `sounds of ${path.basename(file)} (samples/sounds.json):\n  ${problems.join('\n  ')}\n` +
    'Check them online: cd tools && node strudel-sim/check-sounds.mjs <track>; mirror a broken bank sound with ' +
    'node strudel-sim/mirror-sound.mjs <sound>' }
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
