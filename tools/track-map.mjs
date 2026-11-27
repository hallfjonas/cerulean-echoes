// Outline of a long track: banners, @-tag runs, helper definitions, stems, with line
// numbers, so only the needed ranges are read (sed -n).
// A SuperCollider track (.scd): `// ----` banners, `var` helpers, the track event's top-level keys (`key stems`) and
// every stem `(name: \x, …)` in it (`stem x`).
// usage (in tools/): node track-map.mjs <track.scd>
import { readFileSync } from 'node:fs'

const [trackPath] = process.argv.slice(2)
if (!trackPath) {
  console.error('usage: node track-map.mjs <track.scd>')
  process.exit(2)
}

const lines = readFileSync(trackPath, 'utf8').split('\n')
const RULE = /^\/\/\s*(?:={4,}|-{4,})\s*$/
const DASH_BANNER = /^\/\/\s*-{2,}\s*(.+?)\s*-{2,}\s*$/
const TAG = /^\/\/\s*@(ctl|mode|lk|col|layout|globalcc|row|note)\b\s*(.*)$/
const DECLARATION = /^var\s+([A-Za-z_]\w*)/
const SC_KEY = /^([A-Za-z]\w*):\s/
const SC_STEM = /^\t\(name:\s*\\(\w+)/
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

  const key = SC_KEY.exec(line)
  if (key) {
    flush()
    output.push(`  ${number}  key ${key[1]}`)
    continue
  }
  const stem = SC_STEM.exec(line)
  if (stem) {
    flush()
    output.push(`  ${number}  stem ${stem[1]}`)
  }
}
flush()

console.log(`${trackPath}  (${lines.length} lines)`)
console.log(output.join('\n'))
