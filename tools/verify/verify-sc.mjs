// One check for edited SuperCollider tracks (successor of the Strudel `verify`, retired in sc-migration 010):
//   tags     the @-tags parse (lcxl-layout/ctl.mjs; a stem track's come from its stems and frame, stems/stem-tags.mjs)
//   perform  its auto-perform scripts and takes are valid (trajectory/check-perform.mjs)
//   load     the track loads headless in sclang and plays (sc-test/run.scd with only this track: notes with the
//            faders up, Launchkey knob 1 arrives, every sample file exists, the Pattern button changes what plays);
//            skipped without sclang (SCLANG=none skips too)
// Stems: when a .stem / .track file (or a stem's code under sc/stems) is named, or anything under sc/stems, sc/sounds or a .track file changed, the whole
// stem library is checked (stems/check-stems.mjs). Sample Designer projects: when a .sample.json is named or anything
// under sc/lab/samples changed, every project is checked (sound-lab/sample-project.mjs).
// usage (in tools/): npm run verify-sc -- [<track.scd | track.track | file.stem | file.sample.json> …]
//   no files: every SC track whose folder (sc/tracks/<id>/) changed vs HEAD (git status), and the SC track of every
//   changed auto-perform script
// No sound: sclang plays into a score in the language, no server starts. Exit 1 if a step fails.
import fs from 'fs'
import path from 'path'
import { execFileSync, spawnSync } from 'child_process'
import { fileURLToPath } from 'url'
import { parse } from '../lcxl-layout/ctl.mjs'
import { checkTrack, tagSource } from '../trajectory/check-perform.mjs'
import { findSclang } from '../trajectory/sc-link.mjs'
import { checkFiles, libraryFiles } from '../stems/check-stems.mjs'
import { checkAll } from '../sound-lab/sample-project.mjs'

const tools = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const root = path.resolve(tools, '..')
const scTracks = path.join(root, 'sc', 'tracks')
const args = process.argv.slice(2)
const cwd = process.env.INIT_CWD ?? process.cwd()

const git = (...a) => execFileSync('git', a, { cwd: root, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] })
const changed = () => git('status', '--porcelain', '--untracked-files=all').split('\n')
  .filter(l => l && l[0] !== 'D' && l[1] !== 'D').map(l => l.slice(3).split(' -> ').pop())

// the live track files of an SC track folder: <id>.scd and / or the stem track <id>.track
const tracksOf = id => ['.scd', '.track'].map(ext => path.join(scTracks, id, id + ext)).filter(f => fs.existsSync(f))
const changedTracks = () => {
  const ids = changed().map(f => f.match(/^sc\/tracks\/([\w-]+)\//)?.[1]
    ?? f.match(/^tools\/trajectory\/perform\/([\w-]+)\/(takes\/)?[\w-]+\.json$/)?.[1]).filter(Boolean)
  return [...new Set(ids)].flatMap(tracksOf)
}

const line = (name, step, status, detail, secs = '') =>
  console.log(`${name.padEnd(28)} ${step.padEnd(8)} ${status.padEnd(6)} ${secs.padStart(6)}  ${detail.split('\n')[0]}`)
let failed = false

const named = args.filter(a => /\.(scd|stem|track)$/.test(a))
for (const strudel of args.filter(a => a.endsWith('.strudel')))
  line(path.basename(strudel), 'file', 'skip', 'a Strudel file: frozen, its checks were retired (sc-migration 010)')
const inStems = a => path.resolve(cwd, a).startsWith(path.join(root, 'sc', 'stems') + path.sep)
const stemsChanged = named.length ? named.some(a => /\.(stem|track)$/.test(a) || inStems(a))
  : changed().some(f => /^sc\/(stems|sounds)\/|\.track$/.test(f))
if (stemsChanged) {
  const results = checkFiles(libraryFiles())
  const broken = results.filter(r => r.errors.length)
  failed ||= broken.length > 0
  line('stem library', 'stems', broken.length ? 'FAIL' : 'ok', broken.length
    ? broken.map(r => `${path.basename(r.file)}: ${r.errors.join('; ')}`).join(' | ') : `${results.length} stem and track files`)
}

const samplesNamed = args.filter(a => a.endsWith('.sample.json'))
if (samplesNamed.length || (!named.length && changed().some(f => f.startsWith('sc/lab/samples/')))) {
  const results = checkAll()
  const broken = results.filter(r => r.errors.length)
  failed ||= broken.length > 0
  line('Sample Designer', 'projects', broken.length ? 'FAIL' : 'ok', broken.length
    ? broken.map(r => `${path.basename(r.file)}: ${r.errors.join('; ')}`).join(' | ') : `${results.length} projects`)
}

// a named .scd that is not a track itself (a frame, a stem's code) stands for the track(s) of its folder
const files = named.length
  ? [...new Set(named.filter(a => !a.endsWith('.stem') && !inStems(a)).map(a => path.resolve(cwd, a)).flatMap(file => {
    const id = path.basename(path.dirname(file))
    return path.dirname(path.dirname(file)) === scTracks && path.basename(file, path.extname(file)) !== id
      ? tracksOf(id) : [file]
  }))]
  : args.length ? [] : changedTracks()
if (!files.length) {
  if (!stemsChanged && !samplesNamed.length) console.log('no changed SuperCollider tracks')
  process.exit(failed ? 1 : 0)
}

function tags(file) {
  const tagged = parse(tagSource(file), file)
  return tagged.ctls.length ? ['ok', `${tagged.ctls.length} controls`] : ['FAIL', 'no @ctl tags']
}

function perform(file) {
  const results = Object.entries(checkTrack(file))
  if (!results.length) return ['skip', 'no auto-perform scripts']
  const broken = results.filter(([, errors]) => errors.length)
  if (!broken.length) return ['ok', `${results.length} scripts: ${results.map(([f]) => path.basename(f)).join(', ')}`]
  return ['FAIL', broken.map(([f, errors]) => `${path.basename(f)}: ${errors.join('; ')}`).join(' | ')]
}

const sclang = findSclang()
function load(file) {
  if (!sclang) return ['skip', 'sclang not installed']
  const run = spawnSync(sclang, [path.join(tools, 'sc-test', 'run.scd'), file], { encoding: 'utf8', timeout: 300e3 })
  const out = `${run.stdout}\n${run.stderr}`.split('\n')
  const checks = out.filter(l => /^(PASS|FAIL) /.test(l))
  const fails = out.filter(l => /^FAIL|^ {2}missing:/.test(l))
  if (run.status === 0 && checks.length) return ['ok', `${checks.length} checks passed`]
  return ['FAIL', fails.join(' | ') || out.filter(Boolean).slice(-3).join(' | ') || 'sclang crashed']
}

const steps = { tags, perform, load }
for (const file of files) {
  const name = path.basename(file)
  if (!fs.existsSync(file)) {
    line(name, 'file', 'FAIL', 'not found')
    failed = true
    continue
  }
  if (!/\.(scd|track)$/.test(file) || path.dirname(path.dirname(file)) !== scTracks) {
    line(name, 'file', 'FAIL', 'not an SC track (sc/tracks/<id>/<id>.scd or .track)')
    failed = true
    continue
  }
  for (const [step, run] of Object.entries(steps)) {
    const t0 = performance.now()
    let status, detail
    try { [status, detail] = run(file) } catch (e) { [status, detail] = ['FAIL', e.message] }
    failed ||= status === 'FAIL'
    line(name, step, status, detail, ((performance.now() - t0) / 1000).toFixed(1) + 's')
  }
}
process.exit(failed ? 1 : 0)
