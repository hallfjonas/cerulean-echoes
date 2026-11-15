#!/usr/bin/env node
// Scans tracked text files for German: umlauts/ß, common German words and old German path names.
// Usage: node tools/lang-scan.mjs [--files] [path-prefix...]   Exits 1 on any hit not covered by tools/lang-scan-allow.txt.
import { execSync } from 'node:child_process'
import { readFileSync, existsSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const args = process.argv.slice(2)
const filesOnly = args.includes('--files')
const prefixes = args.filter(a => !a.startsWith('--'))

const textExt = /\.(md|typ|strudel|strudel-part|str|mjs|js|py|json|html|txt|yml|yaml|sh|css)$/
const skipPath = new RegExp('(^|/)(node_modules|package-lock\\.json)|^samples/sounds\\.json$|^docs/glossary\\.md$'
  + '|^tools/lang-scan(-allow\\.txt|\\.mjs)$|^\\.claude/(prds|epics)/english-repo')

const words = [
  'und', 'der', 'den', 'dem', 'des', 'nicht', 'mit', 'ist', 'ein', 'eine', 'einen', 'einem', 'einer', 'auf', 'wenn',
  'oder', 'auch', 'noch', 'nur', 'wird', 'werden', 'sind', 'bei', 'aus', 'wie', 'zum', 'zur', 'kein', 'keine', 'schon',
  'dann', 'jetzt', 'hier', 'ganz', 'immer', 'sehr', 'mehr', 'weil', 'dass', 'sich', 'nach', 'vom', 'beim', 'ohne',
  'gegen', 'unter', 'zwischen', 'damit', 'aber', 'wieder', 'soll', 'muss', 'kann', 'gut', 'neu', 'neue', 'alle',
  'jede', 'jeder', 'jedes', 'klingt', 'Klang', 'Spur', 'Regler', 'Knopf', 'Tasten', 'leise', 'laut', 'hell', 'dunkel',
  'Akkord', 'Akkorde', 'Zufall', 'Wurf', 'Dichte', 'Umfang', 'langsam', 'schnell', 'Takt', 'Takte', 'Stimme', 'Ebene', 'zeigt', 'spielt',
  'harmonie', 'melodie', 'einwurf', 'einwuerfe', 'blaeser', 'gitarre', 'streicher', 'geraete', 'recherche',
  'uebergabe', 'hoerliste', 'groß', 'gross',
]
const wordRe = new RegExp(`\\b(${words.join('|')})\\b`, 'gi')
const umlautRe = /[äöüÄÖÜß]/g

const allowFile = join(root, 'tools/lang-scan-allow.txt')
const allow = existsSync(allowFile)
  ? readFileSync(allowFile, 'utf8').split('\n').map(l => l.trim()).filter(l => l && !l.startsWith('#'))
  : []

const files = execSync('git ls-files', { cwd: root, encoding: 'utf8' }).split('\n')
  .filter(f => f && textExt.test(f) && !skipPath.test(f) && existsSync(join(root, f)))
  .filter(f => !prefixes.length || prefixes.some(p => f.startsWith(p)))

let total = 0
const perFile = []
for (const file of files) {
  const lines = readFileSync(join(root, file), 'utf8').split('\n')
  let count = 0
  lines.forEach((line, i) => {
    const clean = allow.reduce((s, a) => s.split(a).join(''), line)
    const hits = [...(clean.match(umlautRe) ?? []), ...(clean.match(wordRe) ?? [])]
    if (!hits.length) return
    count++
    if (!filesOnly) console.log(`${file}:${i + 1}: [${[...new Set(hits)].join(' ')}] ${line.trim().slice(0, 140)}`)
  })
  if (count) perFile.push([file, count])
  total += count
}
if (filesOnly) for (const [f, c] of perFile.sort((a, b) => b[1] - a[1])) console.log(`${String(c).padStart(5)}  ${f}`)
console.log(`${total} German lines in ${perFile.length} files`)
process.exit(total ? 1 : 0)
