// Claude Code PreToolUse hook (Bash): a `git commit` is refused (exit 2) while a file over 10 MB would go into it:
// already staged, staged by a `git add` in the same command (named paths, or everything with -A / --all / .), or by
// `git commit -a`. Large files left out of the command never block. Any git failure lets the command through.
import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'

let input = ''
for await (const chunk of process.stdin) input += chunk
const { tool_input, cwd } = JSON.parse(input)
const command = tool_input?.command ?? ''
if (!/\bgit\b.*\bcommit\b/.test(command)) process.exit(0)

const LIMIT_MB = 10
const git = (args, stdin) => execFileSync('git', args, { cwd, input: stdin, encoding: 'utf8', stdio: 'pipe' })

function filesGoingIn() {
  const top = git(['rev-parse', '--show-toplevel']).trim()
  const raw = git(['diff', '--cached', '--raw', '-z', '--no-abbrev', '--no-renames', '--diff-filter=d'])
    .split('\0').filter(Boolean)
  const staged = []
  for (let i = 0; i < raw.length; i += 2) staged.push({ blob: raw[i].split(' ')[3], file: raw[i + 1] })
  const sizes = staged.length
    ? git(['cat-file', '--batch-check=%(objectsize)'], staged.map(s => s.blob).join('\n') + '\n').split('\n') : []
  const files = staged.map((s, i) => ({ file: s.file, bytes: Number(sizes[i]) }))

  const addArgs = [...command.matchAll(/\bgit\s+add\s+([^;&|]*)/g)].flatMap(m => m[1].trim().split(/\s+/))
  const addAll = addArgs.some(arg => ['-A', '--all', '.'].includes(arg))
  const addPaths = addArgs.filter(arg => arg && !arg.startsWith('-'))
    .map(arg => path.relative(top, path.resolve(cwd, arg.replace(/^['"]|['"]$/g, ''))))
  const commitAll = /\bgit\s+commit\s+(?:-\S+\s+)*?(?:-[a-zA-Z]*a[a-zA-Z]*|--all)\b/.test(command)
  const named = file => addPaths.some(p => p === '' || file === p || file.startsWith(p + '/'))
  if (!addAll && !addPaths.length && !commitAll) return files

  const status = git(['status', '--porcelain', '-z', '--no-renames', '--untracked-files=all'])
  for (const entry of status.split('\0').filter(Boolean)) {
    const file = entry.slice(3)
    const untracked = entry.startsWith('??')
    if (!(addAll || named(file) || (commitAll && !untracked))) continue
    const full = path.join(top, file)
    if (fs.existsSync(full) && fs.statSync(full).isFile()) files.push({ file, bytes: fs.statSync(full).size })
  }
  return files
}

let files
try { files = filesGoingIn() } catch { process.exit(0) }
const big = [...new Map(files.map(f => [f.file, f])).values()].filter(f => f.bytes / 2 ** 20 > LIMIT_MB)
  .map(f => `${f.file} (${(f.bytes / 2 ** 20).toFixed(1)} MB)`)
if (big.length) {
  console.error(`commit refused: files over ${LIMIT_MB} MB would be committed:\n  ${big.join('\n  ')}\n` +
    'Leave them out of git add / commit -a; if already staged, unstage with git restore --staged <file>.')
  process.exit(2)
}
