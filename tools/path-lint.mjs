import { execFileSync, spawnSync } from 'node:child_process'
import { readFileSync, existsSync } from 'node:fs'
import { dirname, join, normalize, relative, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const toolsDir = dirname(fileURLToPath(import.meta.url))
const root = execFileSync('git', ['rev-parse', '--show-toplevel'], { cwd: toolsDir, encoding: 'utf8' }).trim()
const git = (...args) => execFileSync('git', args, { cwd: root, encoding: 'utf8', maxBuffer: 1 << 28 })

const files = git('ls-files', '-co', '--exclude-standard', '-z').split('\0').filter(Boolean)
const known = new Set(files)
for (const file of files) {
  for (let dir = dirname(file); dir !== '.' && !known.has(dir + '/'); dir = dirname(dir)) known.add(dir + '/')
}
const entries = [...known]
const basenames = new Set(files.map(file => file.split('/').pop()))
const topLevel = new Set(files.map(file => file.split('/')[0]))

const SCANNED = [
  /^CLAUDE\.md$/, /^\.claude\/skills\/.+\/SKILL\.md$/, /^\.claude\/epics\/.+\.md$/, /^\.claude\/prds\/[^/]+\.md$/,
  /^docs\/[^/]+\.md$/, /^midi-layouts\/[^/]+\.md$/, /^tools\/[^/]+\/README\.md$/
]
const EXTENSIONS = 'mjs|js|json|md|strudel|pdf|syx|typ|html|yml|yaml|sh|sfz|wav|mp3|txt'
const hasExtension = new RegExp(`\\.(${EXTENSIONS})$`)
const placeholder = /<[A-Za-z-]+>|\bNNN\b|\*|\{[^}]*,[^}]*\}/

const stripToken = raw => raw
  .replace(/^[("'`[]+|[)"'`\],.;:!?]+$/g, '')
  .replace(/#[\w-]*$/, '')
  .replace(/:\d+(-\d+)?$/, '')

const looksLikePath = token => {
  if (!token || /:\/\/|^[@\-~$#]|[$()[\]|=\s↔→…]/.test(token) && !/[*<>{}]/.test(token)) return false
  if (/^[\d\-–./ ]+$/.test(token) || token.startsWith('/') || token.includes('node_modules')) return false
  if (/^<[A-Za-z-]+>\//.test(token) || /^\.[a-z]+$/.test(token) || /^\.\.\.|\.\.\.$/.test(token)) return false
  if (!/^[\w.<>*{},@+\-/]+$/.test(token)) return false
  if (token.includes('/')) {
    const first = token.split('/')[0]
    return hasExtension.test(token) || token.endsWith('/') || placeholder.test(token) || topLevel.has(first) ||
      first === '..' || first === '.' || existsSync(join(toolsDir, first))
  }
  return hasExtension.test(token)
}

const globRegex = pattern => {
  let source = ''
  for (let i = 0; i < pattern.length; i++) {
    const rest = pattern.slice(i)
    let match
    if (rest.startsWith('**/')) { source += '(?:.*/)?'; i += 2 }
    else if (rest.startsWith('**')) { source += '.*'; i += 1 }
    else if (pattern[i] === '*') source += '[^/]*'
    else if ((match = rest.match(/^<[A-Za-z-]+>/))) { source += '[^/]+'; i += match[0].length - 1 }
    else if ((match = rest.match(/^NNN/)) && !/[A-Za-z0-9]/.test(pattern[i - 1] ?? '')) { source += '[0-9A-Za-z]+'; i += 2 }
    else if ((match = rest.match(/^\{([^}]*)\}/))) {
      source += `(?:${match[1].split(',').map(part => part.replace(/[.+^$()|[\]\\]/g, '\\$&')).join('|')})`
      i += match[0].length - 1
    }
    else source += pattern[i].replace(/[.+^${}()|[\]\\?]/g, '\\$&')
  }
  return new RegExp(`^${source}/?$`)
}

const exists = (path, anywhere = true) => {
  const clean = normalize(path).replace(/^\.\//, '').replace(/\/$/, '')
  const matches = entry => {
    const bare = entry.replace(/\/$/, '')
    return placeholder.test(clean) ? globRegex(clean).test(bare) : bare === clean
  }
  if (!anywhere) return entries.some(matches)
  const parent = dirname(clean)
  if (/<[A-Za-z-]+>|NNN/.test(clean.split('/').pop()) ) {
    return parent === '.' || exists(parent)
  }
  if (placeholder.test(clean)) {
    const regex = globRegex(`(?:.*/)?${clean}`.replace('(?:.*/)?', '**/'))
    return entries.some(entry => regex.test(entry.replace(/\/$/, '')))
  }
  return entries.some(entry => entry.replace(/\/$/, '').endsWith(clean) &&
    (entry.replace(/\/$/, '') === clean || entry.replace(/\/$/, '').endsWith('/' + clean)))
}

const candidates = (token, docPath) => {
  const list = [token, join('tools', token)]
  const docDir = dirname(docPath)
  if (docDir !== '.') list.push(join(docDir, token))
  return list.map(candidate => relative(root, resolve(root, candidate)))
}

const resolves = (token, docPath) => {
  if (!token.includes('/') && !placeholder.test(token)) return basenames.has(token)
  return candidates(token, docPath).some(candidate => exists(candidate))
}

const extractTokens = line => {
  const tokens = []
  for (const match of line.matchAll(/\]\(([^)\s]+)\)/g)) tokens.push(match[1])
  for (const match of line.matchAll(/`([^`]+)`/g)) tokens.push(...match[1].split(/\s+/))
  return tokens
}

const findings = []
for (const docPath of files.filter(file => SCANNED.some(pattern => pattern.test(file)))) {
  const lines = readFileSync(join(root, docPath), 'utf8').split('\n')
  let inFence = false
  lines.forEach((line, index) => {
    if (/^\s*```/.test(line)) { inFence = !inFence; return }
    if (inFence) return
    const seen = new Set()
    for (const raw of extractTokens(line)) {
      const token = stripToken(raw)
      if (seen.has(token) || !looksLikePath(token)) continue
      seen.add(token)
      if (!resolves(token, docPath)) findings.push({ docPath, line: index + 1, token, candidates: candidates(token, docPath) })
    }
  })
}

const packageJson = JSON.parse(readFileSync(join(toolsDir, 'package.json'), 'utf8'))
const toolsFiles = files.filter(file => file.startsWith('tools/')).map(file => file.slice('tools/'.length))
for (const [name, script] of Object.entries(packageJson.scripts ?? {})) {
  for (const word of script.split(/\s+/)) {
    const token = stripToken(word)
    if (!looksLikePath(token) || token.startsWith('-')) continue
    const normalized = normalize(join('tools', token))
    const matched = placeholder.test(token)
      ? toolsFiles.length && files.some(file => globRegex(normalized).test(file))
      : exists(normalized, false)
    if (!matched) findings.push({ docPath: 'tools/package.json', line: 0, token: `scripts.${name}: ${token}`, candidates: [normalized] })
  }
}

const literalPrefix = candidate => {
  const literal = candidate.split('/').filter((_, i, parts) => !parts.slice(0, i + 1).some(part => placeholder.test(part)))
  return literal.join('/')
}
const checkable = [...new Set(findings.flatMap(finding => finding.candidates).map(literalPrefix).filter(Boolean))]
const ignoredRun = spawnSync('git', ['check-ignore', '--stdin', '-z'], {
  cwd: root, encoding: 'utf8', input: checkable.join('\0')
})
const ignored = new Set(ignoredRun.stdout.split('\0').filter(Boolean).map(path => path.replace(/\/$/, '')))
const isIgnored = finding => finding.candidates.some(candidate => {
  const prefix = literalPrefix(candidate).replace(/\/$/, '')
  return prefix && ignored.has(prefix)
})

const reported = findings.filter(finding => !isIgnored(finding))
for (const finding of reported) console.log(`${finding.docPath}:${finding.line}: ${finding.token}`)
if (reported.length) console.error(`${reported.length} missing path(s)`)
process.exit(reported.length ? 1 : 0)
