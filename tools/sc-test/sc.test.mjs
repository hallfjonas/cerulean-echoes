// Runs the SuperCollider feature tests (run.scd) as part of `npm test`. Skipped when sclang is not installed (CI).
// sclang: SCLANG in the environment (a path that does not exist, e.g. SCLANG=none, skips), else the macOS app, else
// sclang on the PATH.
import test from 'node:test'
import assert from 'node:assert/strict'
import { execFileSync, spawnSync } from 'child_process'
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const here = path.dirname(fileURLToPath(import.meta.url))
const findSclang = () => {
  if (process.env.SCLANG) return fs.existsSync(process.env.SCLANG) ? process.env.SCLANG : null   // SCLANG=none: skip
  const app = '/Applications/SuperCollider.app/Contents/MacOS/sclang'
  if (fs.existsSync(app)) return app
  try { return execFileSync('which', ['sclang'], { encoding: 'utf8' }).trim() || null } catch { return null }
}
const sclang = findSclang()

test('SuperCollider: building blocks and every live track', { skip: sclang ? false : 'sclang not installed' }, () => {
  const run = spawnSync(sclang, [path.join(here, 'run.scd')], { encoding: 'utf8', timeout: 300e3 })
  const lines = `${run.stdout}\n${run.stderr}`.split('\n')
  const failed = lines.filter(line => /^FAIL|^  missing:/.test(line))
  const summary = lines.find(line => /passed, \d+ failed$/.test(line)) ?? 'no summary (sclang crashed?)'
  assert.equal(run.status, 0, `${summary}\n${failed.join('\n')}`)
})
