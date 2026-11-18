// One check for edited tracks: transpile, compare with the HEAD version, sounds, layout sheet + .syx, tap, auto-perform
// scripts (every CC in the track's @ctl, trajectory/check-perform.mjs).
// usage (in tools/): node verify/verify.mjs [--online] [<file.strudel> …]
//   no files: every .strudel file changed vs HEAD (git status), and the track of every changed auto-perform script
//   --online: check sounds online and update samples/sounds.json (default: offline against the list)
// A compare difference is reported as "changed", not as a failure (the edit may be meant to change the sound).
// Exit 1 if a step fails.
import fs from 'fs'
import os from 'os'
import path from 'path'
import { execFileSync, spawnSync } from 'child_process'
import { fileURLToPath } from 'url'
import { generate as makeLayout } from '../lcxl-layout/gen-layout.mjs'
import { makeSingle, singleOf } from '../lcxl-layout/make-single.mjs'
import { generate as makeSyx } from '../lcxl-layout/make-syx.mjs'
import { tapSource } from '../trajectory/make-tapped.mjs'
import { checkOffline } from '../strudel-sim/check-sounds.mjs'
import { checkTrack, trackFileOf } from '../trajectory/check-perform.mjs'

const tools = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const root = path.resolve(tools, '..')
const args = process.argv.slice(2)
const online = args.includes('--online')

const git = (...a) => execFileSync('git', a, { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] })
const node = (script, ...a) => spawnSync('node', [path.join(tools, script), ...a], { cwd: tools, encoding: 'utf8' })
const changed = () => git('status', '--porcelain', '--untracked-files=all').split('\n')
  .filter(l => l && l[0] !== 'D' && l[1] !== 'D').map(l => l.slice(3).split(' -> ').pop())
const changedFiles = () => {
  const files = changed()
  const scriptTracks = files.map(f => f.match(/^tools\/trajectory\/perform\/([\w-]+)\/[\w-]+\.json$/)?.[1])
    .filter(Boolean).map(trackFileOf).filter(Boolean)
  return [...new Set([...files.filter(f => f.endsWith('.strudel')).map(f => path.join(root, f)), ...scriptTracks])]
}
const isTrack = file => file.startsWith(path.join(root, 'tracks') + path.sep)

const files = args.filter(a => a.endsWith('.strudel')).map(f => path.resolve(process.env.INIT_CWD ?? process.cwd(), f))
if (!files.length) files.push(...changedFiles())
if (!files.length) {
  console.log('no changed .strudel files')
  process.exit(0)
}

function transpile(file) {
  const r = node('strudel-sim/transpile-check.mjs', file)
  return r.status ? ['FAIL', r.stdout.split(' — ').slice(1).join(' — ').trim()] : ['ok', '']
}

function compare(file) {
  let old
  try { old = git('show', 'HEAD:' + path.relative(root, file)) } catch { return ['skip', 'new file, nothing in HEAD'] }
  if (old === fs.readFileSync(file, 'utf8')) return ['ok', 'identical (file unchanged vs HEAD)']
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'verify-'))
  const oldFile = path.join(dir, path.basename(file))
  fs.writeFileSync(oldFile, old)
  const r = node('strudel-sim/compare.mjs', oldFile, file)
  fs.rmSync(dir, { recursive: true })
  const scenarios = r.stdout.split('\n').filter(l => l.includes('identical: '))
  if (!scenarios.length) return ['FAIL', (r.stderr.trim().split('\n').find(l => /Error/.test(l)) ?? 'compare crashed')]
  const differ = scenarios.filter(l => l.endsWith('identical: false'))
  if (!differ.length) return ['ok', `identical (${scenarios.length} scenarios)`]
  const sample = r.stdout.match(/only new: \[\s*'([^']*)/)?.[1] ?? ''
  return ['changed', `${differ.length}/${scenarios.length} scenarios differ (${differ.map(l => l.slice(0, 11).trim())
    .join(', ')}); first new: ${sample.slice(0, 100)}`]
}

async function sounds(file) {
  if (!isTrack(file)) return ['skip', 'not a track']
  if (online) {
    const r = node('strudel-sim/check-sounds.mjs', file)
    return [r.status ? 'FAIL' : 'ok', r.stdout.trim().split('\n').join('; ').replace(/^[^:]*: /, '')]
  }
  const problems = await checkOffline(file)
  return problems.length ? ['FAIL', problems.join('; ')] : ['ok', 'all sounds in samples/sounds.json']
}

function layout(file) {
  const written = []
  for (const f of singleOf(file) ? [file, makeSingle(file)] : [file]) {
    const pdf = makeLayout(f, root)
    if (!pdf) continue
    written.push(path.basename(pdf))
    if (isTrack(f)) written.push(...makeSyx(f).map(({ out }) => path.basename(out)))
  }
  return written.length ? ['ok', written.join(', ')] : ['skip', 'no @ctl tags']
}

function tap(file) {
  try { return ['ok', `${tapSource(fs.readFileSync(file, 'utf8'), path.basename(file)).stems.length} stems`] }
  catch (e) { return ['skip', e.message] }
}

function perform(file) {
  const results = Object.entries(checkTrack(file))
  if (!results.length) return ['skip', 'no auto-perform scripts']
  const failed = results.filter(([, errors]) => errors.length)
  if (!failed.length) return ['ok', `${results.length} scripts: ${results.map(([f]) => path.basename(f)).join(', ')}`]
  return ['FAIL', failed.map(([f, errors]) => `${path.basename(f)}: ${errors.join('; ')}`).join(' | ')]
}

const steps = { transpile, compare, sounds, layout, tap, perform }
let failed = false
for (const file of files) {
  const name = path.basename(file)
  if (!fs.existsSync(file)) {
    console.log(`${name.padEnd(28)} ${'file'.padEnd(10)} FAIL     not found`)
    failed = true
    continue
  }
  for (const [step, run] of Object.entries(steps)) {
    const t0 = performance.now()
    let status, detail
    try { [status, detail] = await run(file) }
    catch (e) { [status, detail] = ['FAIL', e.stderr?.toString() || e.message] }
    failed ||= status === 'FAIL'
    const secs = ((performance.now() - t0) / 1000).toFixed(1).padStart(5) + 's'
    console.log(`${name.padEnd(28)} ${step.padEnd(10)} ${status.padEnd(8)} ${secs}  ${detail.split('\n')[0]}`)
  }
}
process.exit(failed ? 1 : 0)
