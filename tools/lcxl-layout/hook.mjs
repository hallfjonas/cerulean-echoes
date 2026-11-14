// Claude Code PostToolUse hook (Edit|Write): after a .strudel file changes, regenerate its layout sheet.
// A -dual.strudel file (or the dual-lc template) also rewrites its single version (make-single.mjs) and that sheet.
// Tracks (tracks/) also get their custom modes (.syx, make-syx.mjs).
// Files without @ctl tags are skipped. A broken tag or Typst error is reported back (exit 2).
// A track with a tapped copy (tools/trajectory/tapped/) gets that copy rebuilt (make-tapped.mjs).
// A track (tracks/, not old/) is compared with the sound list samples/sounds.json (check-sounds.mjs --offline): a sound
// that is broken or not checked yet is reported back (exit 2).
import { generate } from './gen-layout.mjs'
import { makeSingle, singleOf } from './make-single.mjs'
import { generate as makeSyx } from './make-syx.mjs'
import { refreshTapped } from '../trajectory/make-tapped.mjs'
import { checkOffline } from '../strudel-sim/check-sounds.mjs'
import path from 'path'
import { fileURLToPath } from 'url'

let input = ''
for await (const chunk of process.stdin) input += chunk
const file = JSON.parse(input).tool_input?.file_path
if (!file?.endsWith('.strudel')) process.exit(0)
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
try {
  refreshTapped(file)
  const files = [file]
  if (singleOf(file)) files.push(makeSingle(file))
  for (const f of files) {
    if (!generate(f, root)) continue
    if (path.resolve(f).startsWith(path.join(root, 'tracks') + path.sep)) makeSyx(f)
  }
} catch (e) {
  console.error(`layout sheet for ${path.basename(file)} not updated: ${e.stderr?.toString() || e.message}`)
  process.exit(2)
}

const isTrack = path.resolve(file).startsWith(path.join(root, 'tracks') + path.sep) && !file.includes(`${path.sep}old${path.sep}`)
let problems = []
try { if (isTrack) problems = await checkOffline(file) } catch {}
if (problems.length) {
  console.error(`sounds of ${path.basename(file)} (samples/sounds.json):\n  ${problems.join('\n  ')}\n` +
    'Check them online: cd tools && node strudel-sim/check-sounds.mjs <track>; mirror a broken bank sound with ' +
    'node strudel-sim/mirror-sound.mjs <sound>')
  process.exit(2)
}
