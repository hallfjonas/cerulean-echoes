import { readFileSync } from 'node:fs'

const [trackPath] = process.argv.slice(2)
if (!trackPath) {
  console.error('usage: node track-map.mjs <track.strudel>')
  process.exit(2)
}

const lines = readFileSync(trackPath, 'utf8').split('\n')
const RULE = /^\/\/\s*={4,}\s*$/
const DASH_BANNER = /^\/\/\s*-{2,}\s*(.+?)\s*-{2,}\s*$/
const TAG = /^\/\/\s*@(ctl|mode|lk|col|layout|globalcc)\b\s*(.*)$/
const DECLARATION = /^(?:export\s+)?(?:const|let|var|function|async function)\s+([A-Za-z_$][\w$]*)/
const MASTER = /^(?:\$:\s*)?stack\($/
const WIDTH = 120
const clip = text => (text.length > WIDTH ? text.slice(0, WIDTH - 1) + '…' : text)

const output = []
const pending = { helpers: [], tags: null }

const flushHelpers = () => {
  if (!pending.helpers.length) return
  const [first] = pending.helpers
  const last = pending.helpers.at(-1)
  const names = pending.helpers.map(h => h.name).join(' ')
  output.push(clip(`  ${first.line}-${last.line}  defs: ${names}`))
  pending.helpers = []
}

const flushTags = () => {
  const run = pending.tags
  if (!run) return
  const range = run.first === run.last ? `${run.first}` : `${run.first}-${run.last}`
  const count = run.count > 1 ? ` x${run.count}` : ''
  output.push(clip(`  ${range}  @${run.kind}${count} ${run.text}`))
  pending.tags = null
}

const flush = () => {
  flushHelpers()
  flushTags()
}

for (let i = 0; i < lines.length; i++) {
  const line = lines[i]
  const number = i + 1

  if (RULE.test(line)) {
    const next = lines[i + 1] ?? ''
    if (/^\/\//.test(next) && !RULE.test(next)) {
      flush()
      let end = i + 1
      while (end + 1 < lines.length && /^\/\//.test(lines[end + 1]) && !RULE.test(lines[end + 1])) end++
      const title = lines[i + 1].replace(/^\/\/\s*/, '')
      output.push(clip(`${number}  == ${title}`))
      i = RULE.test(lines[end + 1] ?? '') ? end + 1 : end
    }
    continue
  }

  const dash = DASH_BANNER.exec(line)
  if (dash) {
    flush()
    output.push(clip(`${number}  -- ${dash[1]}`))
    continue
  }

  const tag = TAG.exec(line)
  if (tag) {
    flushHelpers()
    const [, kind, text] = tag
    if (pending.tags?.kind === kind) {
      pending.tags.last = number
      pending.tags.count++
    } else {
      flushTags()
      pending.tags = { kind, first: number, last: number, count: 1, text }
    }
    continue
  }

  const declaration = DECLARATION.exec(line)
  if (declaration) {
    flushTags()
    const name = declaration[1]
    if (name.startsWith('stem')) {
      flushHelpers()
      output.push(`  ${number}  stem ${name}`)
    } else {
      pending.helpers.push({ line: number, name })
    }
    continue
  }

  if (MASTER.test(line)) {
    flush()
    output.push(`${number}  MASTER stack(`)
  }
}
flush()

console.log(`${trackPath}  (${lines.length} lines)`)
console.log(output.join('\n'))
