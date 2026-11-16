// Claude Code SessionStart hook: a fresh worktree has no tools/node_modules; install it so the other hooks and tools
// run. An existing install (the transpiler package is there) is never touched, so a checkout where other sessions
// run tools is not wiped. No node_modules at all: npm ci; an incomplete one: npm install.
import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const tools = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const modules = path.join(tools, 'node_modules')
if (fs.existsSync(path.join(modules, '@strudel', 'transpiler'))) process.exit(0)
const command = fs.existsSync(modules) ? 'install' : 'ci'
try {
  execFileSync('npm', [command], { cwd: tools, stdio: 'pipe', timeout: 280e3 })
  console.log(`tools/node_modules was missing: npm ${command} done`)
} catch (e) {
  console.log(`tools/node_modules is missing and npm ${command} failed: ` +
    `${(e.stderr?.toString().trim() || e.message).split('\n')[0]}`)
}
