// Claude Code PostToolUse hook (Edit|Write): after a .strudel file changes, regenerate its layout sheet.
// A -dual.strudel file (or the dual-lc template) also rewrites its single version (make-single.mjs) and that sheet.
// Files without @ctl tags are skipped. A broken tag or Typst error is reported back (exit 2).
import { generate } from './gen-layout.mjs'
import { makeSingle, singleOf } from './make-single.mjs'
import path from 'path'
import { fileURLToPath } from 'url'

let input = ''
for await (const chunk of process.stdin) input += chunk
const file = JSON.parse(input).tool_input?.file_path
if (!file?.endsWith('.strudel')) process.exit(0)
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
try {
  generate(file, root)
  if (singleOf(file)) generate(makeSingle(file), root)
} catch (e) {
  console.error(`layout sheet for ${path.basename(file)} not updated: ${e.stderr?.toString() || e.message}`)
  process.exit(2)
}
