// Claude Code SessionStart hook: a fresh worktree has no tools/node_modules; install it (npm ci) so the other hooks
// and tools run. A marker file written after a successful install keeps it quiet; an interrupted install is redone.
import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const tools = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const done = path.join(tools, 'node_modules', '.npm-ci-done')
if (fs.existsSync(done)) process.exit(0)
try {
  execFileSync('npm', ['ci'], { cwd: tools, stdio: 'pipe', timeout: 300e3 })
  fs.writeFileSync(done, '')
  console.log('tools/node_modules was missing: npm ci done')
} catch (e) {
  console.log(`tools/node_modules is missing and npm ci failed: ${e.stderr?.toString().trim().split('\n')[0]}`)
}
