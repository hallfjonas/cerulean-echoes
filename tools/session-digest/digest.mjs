// Turns Claude Code session transcripts (JSONL) of this project into compact Markdown digests for review.
// Usage: node session-digest/digest.mjs [--since 2026-11-10] [--only <session-id-prefix>] [--dir <transcript dir>]
// Writes tools/session-digest/out/<session>.md (git-ignored: it holds private chat content) and out/index.md.
// Each digest lists user messages (flagged corrections), per turn the tool sequence, errors, hook output, skills and
// subagents, handover notes, repeated tool sequences, edit reverts, and a short summary of every subagent transcript.
import fs from 'fs'
import os from 'os'
import path from 'path'
import { fileURLToPath } from 'url'

const args = process.argv.slice(2)
const option = (name, fallback) => (args.includes(name) ? args[args.indexOf(name) + 1] : fallback)
const since = option('--since', '2026-11-10')
const only = option('--only', null)
const projectSlug = '-Users-jonas-hall-Documents-GitHub-cerulean-echoes'
const transcriptDir = option('--dir', path.join(os.homedir(), '.claude', 'projects', projectSlug))
const outDir = path.join(path.dirname(fileURLToPath(import.meta.url)), 'out')

const USER_TEXT_LIMIT = 1500
const ASSISTANT_TEXT_LIMIT = 500
const ERROR_LIMIT = 300
const BOILERPLATE_HOOK_TEXT = [/^CAVEMAN MODE/, /^A preview server is running/]
const CORRECTION_START =
  /^\s*(no\b|nein|nope|not\b|don'?t|do not|doch|falsch|wrong|stop|again|nochmal|noch mal|immer noch|still\b|why\b|warum|wieso|weshalb|actually|eigentlich|hmm|that'?s not|das ist nicht|das war nicht|nicht so|undo|revert|zurück)/i
const CORRECTION_ANYWHERE =
  /(i said|ich hab(e)? (doch|gesagt)|wie gesagt|as i said|you forgot|du hast vergessen|still (not|broken|wrong|missing)|immer noch|again\?|schon wieder|not what i|nicht was ich|didn'?t (work|help)|funktioniert (immer noch )?nicht|klingt (immer noch )?(nicht|schlecht|falsch)|zu laut|zu leise|too (loud|quiet))/i
const HANDOVER_FILE = /(uebergabe|übergabe|handover|hand-over|prompt-naechster-agent|next-agent)/i

const readJsonl = file =>
  fs
    .readFileSync(file, 'utf8')
    .split('\n')
    .filter(Boolean)
    .flatMap(line => {
      try {
        return [JSON.parse(line)]
      } catch {
        return []
      }
    })

const clip = (text, limit) => {
  const flat = String(text ?? '').replace(/\s+\n/g, '\n').trim()
  return flat.length > limit ? flat.slice(0, limit) + ` …[+${flat.length - limit}]` : flat
}
const oneLine = (text, limit) => clip(String(text ?? '').replace(/\s+/g, ' '), limit)
const time = iso => (iso ? iso.slice(5, 16).replace('T', ' ') : '?')
const minutes = (a, b) => (a && b ? Math.round((Date.parse(b) - Date.parse(a)) / 60000) : 0)
const textOf = content =>
  typeof content === 'string'
    ? content
    : (content ?? []).filter(part => part.type === 'text').map(part => part.text).join('\n')

const repoRelative = file => String(file ?? '').replace(/^.*?cerulean-echoes\/(\.claude\/worktrees\/[^/]+\/)?/, '')

function describeToolCall(call) {
  const input = call.input ?? {}
  switch (call.name) {
    case 'Bash':
      return `Bash(${oneLine(input.description || String(input.command ?? '').replace(/^cd [^;&]+(;|&&)\s*/, ''), 90)})`
    case 'Read':
    case 'Edit':
    case 'Write':
    case 'MultiEdit':
    case 'NotebookEdit':
      return `${call.name}(${repoRelative(input.file_path)})`
    case 'Grep':
    case 'Glob':
      return `${call.name}(${oneLine(input.pattern, 60)})`
    case 'Skill':
      return `Skill(${input.skill}${input.args ? ' ' + oneLine(input.args, 60) : ''})`
    case 'Agent':
    case 'Task':
      return `Agent[${input.subagent_type ?? 'general'}](${oneLine(input.description, 70)})`
    default:
      return call.name.replace(/^mcp__/, 'mcp:')
  }
}

const isHumanMessage = record =>
  record.type === 'user' &&
  !record.isMeta &&
  !record.isSidechain &&
  (record.origin?.kind === 'human' || record.origin === undefined) &&
  textOf(record.message?.content).trim() !== '' &&
  !(Array.isArray(record.message?.content) && record.message.content.some(part => part.type === 'tool_result'))

const isCorrection = text => CORRECTION_START.test(text) || CORRECTION_ANYWHERE.test(text)

function repeatedSequences(calls, size = 3, minCount = 3) {
  const names = calls.map(call => call.name).filter(name => !name.startsWith('mcp__ccd_turn__'))
  const counts = new Map()
  for (let i = 0; i + size <= names.length; i++) {
    const key = names.slice(i, i + size).join(' → ')
    if (new Set(names.slice(i, i + size)).size === 1) continue
    counts.set(key, (counts.get(key) ?? 0) + 1)
  }
  return [...counts].filter(([, n]) => n >= minCount).sort((a, b) => b[1] - a[1]).slice(0, 8)
}

function editReverts(calls) {
  const edits = calls.filter(call => call.name === 'Edit' && call.input?.old_string && call.input?.new_string)
  const reverts = []
  for (let i = 0; i < edits.length; i++)
    for (let j = i + 1; j < edits.length; j++) {
      const [a, b] = [edits[i].input, edits[j].input]
      if (a.file_path === b.file_path && a.old_string === b.new_string && a.new_string === b.old_string)
        reverts.push(`${repoRelative(a.file_path)}: edit at ${time(edits[i].timestamp)} undone at ${time(edits[j].timestamp)}`)
    }
  return reverts
}

function parseSession(records) {
  const turns = []
  const calls = []
  const toolNames = new Map()
  const stats = { compactions: 0, prs: new Set(), titles: new Set(), branches: new Set(), queued: [], peer: [] }
  let turn = null
  const startTurn = (record, kind, text) => {
    turn = { kind, text, start: record.timestamp, end: record.timestamp, calls: [], errors: [], hooks: [], replies: [] }
    turns.push(turn)
  }
  for (const record of records) {
    if (record.isSidechain) continue
    if (record.timestamp && turn) turn.end = record.timestamp
    if (record.gitBranch) stats.branches.add(record.gitBranch)
    if (record.type === 'custom-title' && record.customTitle) stats.titles.add(record.customTitle)
    if (record.type === 'pr-link') stats.prs.add(record.prUrl)
    if (record.type === 'system' && record.subtype === 'compact_boundary') stats.compactions++
    if (record.type === 'system' && record.hookErrors?.length && turn)
      turn.hooks.push(`stop hook error: ${oneLine(record.hookErrors.join(' | '), ERROR_LIMIT)}`)
    if (record.type === 'attachment') {
      const attachment = record.attachment
      if (attachment.type === 'queued_command' && attachment.origin?.kind === 'human' && turn)
        turn.replies.push(`USER (mid-turn): ${clip(attachment.prompt, USER_TEXT_LIMIT)}`)
      if (attachment.type === 'hook_additional_context' || attachment.type?.startsWith('hook_')) {
        const content = [attachment.content, attachment.stdout, attachment.stderr].flat().filter(Boolean).join(' ')
        const boilerplate = BOILERPLATE_HOOK_TEXT.some(pattern => pattern.test(content))
        if (content && !boilerplate && turn && attachment.hookEvent !== 'SessionStart')
          turn.hooks.push(`${attachment.hookName ?? attachment.type}: ${oneLine(content, ERROR_LIMIT)}`)
      }
      continue
    }
    if (record.type === 'user' && record.origin?.kind && record.origin.kind !== 'human' && !record.isMeta) {
      const text = textOf(record.message?.content)
      if (text) startTurn(record, record.origin.kind, clip(text, 400))
      continue
    }
    if (isHumanMessage(record) && textOf(record.message.content).startsWith('[Request interrupted')) {
      if (turn) turn.replies.push('USER INTERRUPTED')
      continue
    }
    if (isHumanMessage(record)) {
      startTurn(record, 'human', clip(textOf(record.message.content), USER_TEXT_LIMIT))
      continue
    }
    if (record.type === 'assistant' && turn) {
      for (const part of record.message?.content ?? []) {
        if (part.type === 'tool_use') {
          const call = { name: part.name, input: part.input, timestamp: record.timestamp, id: part.id }
          toolNames.set(part.id, call)
          turn.calls.push(call)
          calls.push(call)
        }
        if (part.type === 'text' && part.text.trim()) turn.lastText = part.text
      }
    }
    if (record.type === 'user' && Array.isArray(record.message?.content) && turn) {
      for (const part of record.message.content) {
        if (part.type !== 'tool_result') continue
        const text = textOf(part.content)
        const call = toolNames.get(part.tool_use_id)
        if (part.is_error) turn.errors.push(`${call ? describeToolCall(call) : '?'}: ${oneLine(text, ERROR_LIMIT)}`)
        else if (/hook (error|blocking)|layout sheet .* not updated|PostToolUse/i.test(text))
          turn.hooks.push(`${call ? describeToolCall(call) : '?'}: ${oneLine(text, ERROR_LIMIT)}`)
      }
    }
  }
  return { turns, calls, stats }
}

function compressSequence(calls) {
  const parts = []
  for (const call of calls) {
    const label = describeToolCall(call)
    const last = parts.at(-1)
    if (last && last.label === label) last.count++
    else parts.push({ label, count: 1 })
  }
  return parts.map(part => (part.count > 1 ? `${part.label} ×${part.count}` : part.label))
}

function summarizeSubagent(file) {
  const records = readJsonl(file)
  const metaFile = file.replace(/\.jsonl$/, '.meta.json')
  const meta = fs.existsSync(metaFile) ? JSON.parse(fs.readFileSync(metaFile, 'utf8')) : {}
  const prompt = records.find(record => record.type === 'user' && typeof record.message?.content !== 'undefined')
  const calls = []
  const errors = []
  let lastText = ''
  for (const record of records) {
    if (record.type === 'assistant')
      for (const part of record.message?.content ?? []) {
        if (part.type === 'tool_use') calls.push({ name: part.name, input: part.input })
        if (part.type === 'tool_use' && part.name === 'SubagentHandback') lastText = part.input?.message ?? lastText
        if (part.type === 'text' && part.text.trim()) lastText = part.text
      }
    if (record.type === 'user' && Array.isArray(record.message?.content))
      for (const part of record.message.content)
        if (part.type === 'tool_result' && part.is_error) errors.push(oneLine(textOf(part.content), 200))
  }
  const stamps = records.map(record => record.timestamp).filter(Boolean)
  const counts = {}
  for (const call of calls) counts[call.name] = (counts[call.name] ?? 0) + 1
  return [
    `### Subagent ${path.basename(file, '.jsonl')} — ${meta.agentType ?? '?'}: ${meta.description ?? ''}`,
    `- ${time(stamps[0])} → ${time(stamps.at(-1))} (${minutes(stamps[0], stamps.at(-1))} min), ${calls.length} tool calls: ` +
      Object.entries(counts).map(([name, n]) => `${name.replace(/^mcp__/, 'mcp:')} ${n}`).join(', '),
    `- Prompt: ${oneLine(textOf(prompt?.message?.content), 500)}`,
    ...(errors.length ? [`- Errors (${errors.length}): ${errors.slice(0, 5).join(' | ')}`] : []),
    `- Result: ${oneLine(lastText, 700)}`,
    ''
  ].join('\n')
}

function digest(sessionFile) {
  const id = path.basename(sessionFile, '.jsonl')
  const records = readJsonl(sessionFile)
  const stamps = records.map(record => record.timestamp).filter(Boolean).sort()
  if (!stamps.length || stamps[0].slice(0, 10) < since) return null
  const { turns, calls, stats } = parseSession(records)
  const humanTurns = turns.filter(turn => turn.kind === 'human')
  const corrections = humanTurns.filter(turn => isCorrection(turn.text))
  const skills = calls.filter(call => call.name === 'Skill').map(call => call.input?.skill)
  const agents = calls.filter(call => ['Agent', 'Task'].includes(call.name)).map(describeToolCall)
  const handovers = calls
    .filter(call => ['Write', 'Edit'].includes(call.name) && HANDOVER_FILE.test(call.input?.file_path ?? ''))
    .map(call => repoRelative(call.input.file_path))
  const filesEdited = {}
  for (const call of calls)
    if (['Edit', 'Write', 'MultiEdit'].includes(call.name)) {
      const file = repoRelative(call.input?.file_path)
      filesEdited[file] = (filesEdited[file] ?? 0) + 1
    }
  const errorCount = turns.reduce((sum, turn) => sum + turn.errors.length, 0)
  const subagentDir = path.join(path.dirname(sessionFile), id, 'subagents')
  const subagentFiles = fs.existsSync(subagentDir)
    ? fs.readdirSync(subagentDir).filter(name => name.endsWith('.jsonl')).map(name => path.join(subagentDir, name))
    : []
  const titleFile = path.join(path.dirname(sessionFile), id, 'custom-title.json')
  if (fs.existsSync(titleFile)) stats.titles.add(JSON.parse(fs.readFileSync(titleFile, 'utf8')).customTitle)

  const lines = [
    `# Session ${id}`,
    `- Title: ${[...stats.titles].filter(Boolean).join(' / ') || '?'}`,
    `- Time: ${stamps[0]} → ${stamps.at(-1)} (${minutes(stamps[0], stamps.at(-1))} min wall clock)`,
    `- Branches: ${[...stats.branches].join(', ') || '?'}`,
    `- Turns: ${humanTurns.length} human, ${turns.length - humanTurns.length} other (peer/task-notification); ` +
      `${calls.length} tool calls; ${errorCount} tool errors; ${stats.compactions} compactions; ` +
      `${subagentFiles.length} subagent transcripts`,
    `- Flagged corrections: ${corrections.length}`,
    `- Skills: ${skills.length ? [...new Set(skills)].map(s => `${s} ×${skills.filter(x => x === s).length}`).join(', ') : 'none'}`,
    `- Subagents: ${agents.length ? agents.join('; ') : 'none'}`,
    `- PRs: ${[...stats.prs].join(', ') || 'none'}`,
    `- Handover files written: ${handovers.length ? [...new Set(handovers)].join(', ') : 'none'}`,
    `- Most edited files: ${Object.entries(filesEdited).sort((a, b) => b[1] - a[1]).slice(0, 8).map(([f, n]) => `${f} ×${n}`).join(', ') || 'none'}`,
    ''
  ]
  const sequences = repeatedSequences(calls)
  if (sequences.length) lines.push('## Repeated tool sequences (≥3×)', ...sequences.map(([s, n]) => `- ${s} ×${n}`), '')
  const reverts = editReverts(calls)
  if (reverts.length) lines.push('## Edit reverts', ...reverts.map(r => `- ${r}`), '')

  lines.push('## Turns')
  turns.forEach((turn, index) => {
    const flag = turn.kind === 'human' && isCorrection(turn.text) ? ' ⚠ CORRECTION?' : ''
    const who = turn.kind === 'human' ? 'USER' : turn.kind.toUpperCase()
    lines.push(
      `### T${index + 1} ${time(turn.start)} (${minutes(turn.start, turn.end)} min, ${turn.calls.length} calls)${flag}`,
      `${who}: ${turn.text}`,
      ...turn.replies
    )
    if (turn.calls.length) lines.push(`TOOLS: ${compressSequence(turn.calls).join(' → ')}`)
    if (turn.errors.length) lines.push(...turn.errors.slice(0, 8).map(error => `ERROR: ${error}`))
    if (turn.hooks.length) lines.push(...[...new Set(turn.hooks)].slice(0, 6).map(hook => `HOOK: ${hook}`))
    if (turn.lastText) lines.push(`CLAUDE (last): ${oneLine(turn.lastText, ASSISTANT_TEXT_LIMIT)}`)
    lines.push('')
  })
  if (subagentFiles.length) lines.push('## Subagent transcripts', ...subagentFiles.map(summarizeSubagent))
  return {
    id,
    start: stamps[0],
    title: [...stats.titles].filter(Boolean).at(-1) ?? '?',
    humanTurns: humanTurns.length,
    corrections: corrections.length,
    calls: calls.length,
    errors: errorCount,
    subagents: subagentFiles.length,
    text: lines.join('\n')
  }
}

fs.mkdirSync(outDir, { recursive: true })
const sessionFiles = fs
  .readdirSync(transcriptDir)
  .filter(name => name.endsWith('.jsonl') && (!only || name.startsWith(only)))
  .map(name => path.join(transcriptDir, name))
const results = []
for (const file of sessionFiles) {
  try {
    const result = digest(file)
    if (!result) continue
    fs.writeFileSync(path.join(outDir, `${result.id}.md`), result.text)
    results.push(result)
    console.log(`${result.id}  ${(result.text.length / 1024).toFixed(0)} KB  ${result.title}`)
  } catch (error) {
    console.error(`${path.basename(file)} failed: ${error.message}`)
    process.exitCode = 1
  }
}
results.sort((a, b) => a.start.localeCompare(b.start))
if (!only) {
  const index = [
    `# Session digests since ${since}`,
    '',
    '| Start | Session | Title | Human turns | Corrections? | Tool calls | Errors | Subagents |',
    '|---|---|---|---|---|---|---|---|',
    ...results.map(r =>
      `| ${time(r.start)} | ${r.id.slice(0, 8)} | ${r.title} | ${r.humanTurns} | ${r.corrections} | ${r.calls} | ${r.errors} | ${r.subagents} |`)
  ]
  fs.writeFileSync(path.join(outDir, 'index.md'), index.join('\n') + '\n')
}
console.log(`${results.length} digests written to ${outDir}`)
