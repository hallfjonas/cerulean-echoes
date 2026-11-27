// Runs the SuperCollider feature tests (run.scd) as part of `npm test`. Skipped when sclang is not installed (CI).
// sclang: SCLANG in the environment (a path that does not exist, e.g. SCLANG=none, skips), else the macOS app, else
// sclang on the PATH.
import test from 'node:test'
import assert from 'node:assert/strict'
import { execFileSync, spawnSync } from 'child_process'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { trackTags } from '../stems/stem-tags.mjs'
import { exportSound, projectFile } from '../sound-lab/sample-project.mjs'

const here = path.dirname(fileURLToPath(import.meta.url))
const findSclang = () => {
  if (process.env.SCLANG) return fs.existsSync(process.env.SCLANG) ? process.env.SCLANG : null   // SCLANG=none: skip
  const app = '/Applications/SuperCollider.app/Contents/MacOS/sclang'
  if (fs.existsSync(app)) return app
  try { return execFileSync('which', ['sclang'], { encoding: 'utf8' }).trim() || null } catch { return null }
}
const sclang = findSclang()
const demoTrack = path.join(here, '..', '..', 'sc', 'tracks', '090-stem-demo', '090-stem-demo.track')

test('SuperCollider: building blocks and every live track', { skip: sclang ? false : 'sclang not installed' }, () => {
  const run = spawnSync(sclang, [path.join(here, 'run.scd')], { encoding: 'utf8', timeout: 300e3 })
  const lines = `${run.stdout}\n${run.stderr}`.split('\n')
  const failed = lines.filter(line => /^FAIL|^  missing:/.test(line))
  const summary = lines.find(line => /passed, \d+ failed$/.test(line)) ?? 'no summary (sclang crashed?)'
  const scTags = lines.filter(line => line.startsWith('TAG ')).map(line => line.slice(4))
  assert.deepEqual(scTags, trackTags(demoTrack).split('\n'), 'SC and stem-tags.mjs make the same @ctl lines')
  assert.equal(run.status, 0, `${summary}\n${failed.join('\n')}`)
})

// Sample Designer (sample-designer.scd), after an export of the drum project: the export renders a WAV with
// sc/tools/render.scd, and the exported sound must load (~ce.checkSound) and play the project. In this file, so it
// runs after the test above (one sclang at a time); the exported files are removed afterwards.
test('Sample Designer: projects load and play, an export writes a sound that loads and a WAV',
  { skip: sclang ? false : 'sclang not installed' }, async () => {
    const soundName = `zzExportTest${process.pid}`
    const repo = path.join(here, '..', '..')
    let out = { sound: path.join(repo, 'sc', 'sounds', `${soundName}.scd`), wav: null }
    try {
      out = await exportSound('kick-round', { soundName, sclang })
      assert.ok(out.wav && fs.statSync(out.wav).size > 48000, 'a WAV of the audition')
      const run = spawnSync(sclang, [path.join(here, 'sample-designer.scd'), soundName, projectFile('kick-round')],
        { encoding: 'utf8', timeout: 180e3 })
      const lines = `${run.stdout}\n${run.stderr}`.split('\n')
      const summary = lines.find(line => /passed, \d+ failed$/.test(line)) ?? 'no summary (sclang crashed?)'
      assert.equal(run.status, 0, `${summary}\n${lines.filter(line => /^FAIL/.test(line)).join('\n')}`)
    } finally {
      for (const file of [out.sound, out.wav]) if (file && fs.existsSync(file)) fs.rmSync(file)
      const dir = path.join(repo, 'samples', 'sound-lab')
      if (fs.existsSync(dir) && !fs.readdirSync(dir).length) fs.rmdirSync(dir)
    }
  })

// Stem Designer (stem-designer.scd): projects load and play their columns and backing stems, A/B, Promote, drafts,
// fourteen columns.
test('Stem Designer: projects load and play, A/B swaps, Promote reaches the player',
  { skip: sclang ? false : 'sclang not installed' }, () => {
    const run = spawnSync(sclang, [path.join(here, 'stem-designer.scd')], { encoding: 'utf8', timeout: 280e3 })
    const lines = `${run.stdout}\n${run.stderr}`.split('\n')
    const summary = lines.find(line => /passed, \d+ failed$/.test(line)) ?? 'no summary (sclang crashed?)'
    assert.equal(run.status, 0, `${summary}\n${lines.filter(line => /^FAIL/.test(line)).join('\n')}`)
  })

// Every library stem in every stem track's frame (sc/tools/stem-fit.scd, the player's drawer check): a stem whose code
// fails in a frame goes quiet there. stem-frames-known.json lists the known failures ({ track: { stem ref: error } });
// the test fails on a new one and on a listed one that works now. STEM_FRAMES_WRITE=1 writes the file from this run.
test('Stems in every frame: only the known failures', { skip: sclang ? false : 'sclang not installed' }, () => {
  const tracksDir = path.join(here, '..', '..', 'sc', 'tracks')
  const tracks = fs.readdirSync(tracksDir).map(id => path.join(tracksDir, id, `${id}.track`)).filter(fs.existsSync)
  const run = spawnSync(sclang, [path.join(here, '..', '..', 'sc', 'tools', 'stem-fit.scd'), ...tracks],
    { encoding: 'utf8', timeout: 1300e3 })
  const lines = `${run.stdout}\n${run.stderr}`.split('\n')
  assert.equal(run.status, 0, lines.filter(line => /^FAIL|^ERROR:/.test(line)).join('\n') || 'sclang failed')
  const found = {}
  for (const line of lines) {
    const m = line.match(/^MISFIT (\S+) (\S+) \| (.*)$/)
    if (m) (found[m[1]] ??= {})[m[2]] = m[3]
  }
  const knownFile = path.join(here, 'stem-frames-known.json')
  if (process.env.STEM_FRAMES_WRITE === '1') fs.writeFileSync(knownFile, JSON.stringify(found, null, 2) + '\n')
  const known = JSON.parse(fs.readFileSync(knownFile, 'utf8'))
  const pairs = map => Object.entries(map).flatMap(([track, stems]) => Object.keys(stems).map(ref => `${track} ${ref}`))
  const fresh = pairs(found).filter(pair => !pairs(known).includes(pair))
  const fixed = pairs(known).filter(pair => !pairs(found).includes(pair))
  assert.deepEqual({ fresh, fixed }, { fresh: [], fixed: [] },
    'fresh: stems that fail in a frame (fix the stem or frame, or list it); fixed: listed failures that work now')
})
