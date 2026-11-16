// Claude Code PreToolUse hook (Bash): a `git commit` is refused (exit 2) while a staged file is over 10 MB.
import { execFileSync } from 'child_process'
import fs from 'fs'
import path from 'path'

let input = ''
for await (const chunk of process.stdin) input += chunk
const { tool_input, cwd } = JSON.parse(input)
if (!/\bgit\b.*\bcommit\b/.test(tool_input?.command ?? '')) process.exit(0)

const command = tool_input.command
const git = (args, stdin) => execFileSync('git', args, { cwd, input: stdin, encoding: 'utf8' })
const top = git(['rev-parse', '--show-toplevel']).trim()
const raw = git(['diff', '--cached', '--raw', '-z', '--no-abbrev', '--no-renames', '--diff-filter=d'])
  .split('\0').filter(Boolean)
const staged = []
for (let i = 0; i < raw.length; i += 2) staged.push({ blob: raw[i].split(' ')[3], file: raw[i + 1] })
const sizes = staged.length
  ? git(['cat-file', '--batch-check=%(objectsize)'], staged.map(s => s.blob).join('\n') + '\n').split('\n') : []
const files = staged.map((s, i) => ({ file: s.file, bytes: Number(sizes[i]) }))
// `git commit -a` and `git add … && git commit` stage files after this hook runs: check them on disk as well
if (/\bgit\s+add\b|\bgit\s+commit\s+(?:-\S+\s+)*?(?:-[a-zA-Z]*a[a-zA-Z]*|--all)\b/.test(command)) {
  const status = git(['status', '--porcelain', '-z', '--no-renames', '--untracked-files=all'])
  for (const entry of status.split('\0').filter(Boolean)) {
    if (entry.startsWith('??') && !/\bgit\s+add\b/.test(command)) continue
    const file = entry.slice(3)
    const full = path.join(top, file)
    if (fs.existsSync(full) && fs.statSync(full).isFile()) files.push({ file, bytes: fs.statSync(full).size })
  }
}
const big = [...new Map(files.map(f => [f.file, f])).values()].filter(f => f.bytes / 2 ** 20 > 10)
  .map(f => `${f.file} (${(f.bytes / 2 ** 20).toFixed(1)} MB)`)
if (big.length) {
  console.error(`commit refused: files over 10 MB staged or about to be staged:\n  ${big.join('\n  ')}\n` +
    'Unstage them (git restore --staged <file>) or leave them out of the commit.')
  process.exit(2)
}
