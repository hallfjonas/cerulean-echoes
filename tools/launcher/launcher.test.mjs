// Feature tests for the launcher (tools/launcher/launch.sh and "Cerulean Echoes.app"): the checks give plain
// messages, the player starts on a test port and answers, an already running player is only opened, quitting (also a
// force quit of the app) leaves no process behind, SuperCollider included. Never opens a browser (CE_NO_BROWSER=1), never
// touches a player on 8766. Loose checks: the page answers, processes are gone.
import test from 'node:test'
import assert from 'node:assert/strict'
import { spawn, spawnSync, execFileSync } from 'child_process'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { fileURLToPath } from 'url'
import { findSclang } from '../trajectory/sc-link.mjs'

const here = path.dirname(fileURLToPath(import.meta.url))
const repo = path.resolve(here, '../..')
const script = path.join(here, 'launch.sh')
const app = path.join(repo, 'Cerulean Echoes.app')
// away from a running player (8766 / 57131 / 57140) and from the other tests' ports
const PORT = 8796, OSC = 57176, SERVER = 57177
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'launcher-test-'))
const env = { ...process.env, CE_PORT: String(PORT), CE_NO_BROWSER: '1', CE_LOG: path.join(scratch, 'launcher.log'),
  CE_STATE_DIR: path.join(scratch, 'state'), CE_SC_PORT: String(OSC), CE_SC_SERVER_PORT: String(SERVER) }
const run = (args, extra = {}) => spawnSync('/bin/bash', [script, ...args], { env: { ...env, ...extra }, encoding: 'utf8' })
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms))
const answers = async () => { try { return (await fetch(`http://localhost:${PORT}/`)).ok } catch { return false } }
// every process of ours still alive: the server on the test port, its sclang / scsynth, the launcher's watcher
// (by program name and arguments, so a shell whose command line merely mentions them does not count)
const leftovers = () => execFileSync('ps', ['-axo', 'ucomm=,args='], { encoding: 'utf8' }).split('\n').filter(line => {
  const [name] = line.trim().split(/\s+/, 1)
  return name === 'node' && line.trimEnd().endsWith(`server.mjs ${PORT}`) ||
    name === 'sclang' && line.trimEnd().endsWith(`engine.scd ${OSC} ${SERVER}`) ||
    name === 'scsynth' && line.includes(`scsynth -u ${SERVER} `) ||
    name === 'bash' && new RegExp(`cerulean-echoes-watch-${PORT} \\d+ \\d+$`).test(line.trimEnd())
})
const until = async (test, ms) => {
  for (const end = Date.now() + ms; Date.now() < end; await sleep(200)) if (await test()) return true
  return false
}

test.after(() => { if (!process.env.KEEP) fs.rmSync(scratch, { recursive: true, force: true }) })

test('check: plain messages, "install" when the helpers are missing', () => {
  const missing = run(['check'], { SCLANG: path.join(scratch, 'no-sclang') })
  assert.equal(missing.status, 1)
  assert.match(missing.stderr, /SuperCollider is missing\. Install it once from https:\/\/supercollider\.github\.io/)
  const ok = run(['check'], { SCLANG: process.execPath })
  assert.equal(ok.status, 0, ok.stderr)
  assert.equal(ok.stdout.trim(), fs.existsSync(path.join(repo, 'tools', 'node_modules')) ? 'ok' : 'install')
  assert.match(fs.readFileSync(env.CE_LOG, 'utf8'), /launcher: check: node /, 'the log names the node it found')
  assert.equal(run(['url']).stdout.trim(), `http://localhost:${PORT}`)
})

test('start, open without a browser, stop: the page answers, then nothing is left', { timeout: 60e3 }, async () => {
  assert.equal(run(['alive']).status, 3, 'nothing started yet')
  const started = run(['start'])
  assert.equal(started.status, 0, started.stderr)
  assert.match(started.stdout, /^started \d+/)
  assert.ok(await answers(), 'the player answers')
  assert.equal(run(['alive']).status, 0)
  assert.equal(run(['start']).stdout.trim(), started.stdout.trim(), 'a second start keeps the same server')
  assert.equal(run(['open']).stdout.trim(), 'skipped', 'no browser in the test')
  assert.equal(run(['stop']).stdout.trim(), 'stopped')
  assert.equal(await answers(), false)
  assert.deepEqual(leftovers(), [])
  assert.equal(run(['alive']).status, 3)
})

test('a player that already runs is only opened, never stopped', { timeout: 60e3 }, async () => {
  const other = spawn(process.execPath, [path.join(repo, 'tools/trajectory/server.mjs'), String(PORT)],
    { env: { ...env, SCLANG: 'none' }, stdio: 'ignore' })
  try {
    assert.ok(await until(answers, 10e3), 'the other player answers')
    assert.equal(run(['start']).stdout.trim(), 'running')
    assert.equal(run(['alive']).status, 3)
    assert.equal(run(['stop']).stdout.trim(), 'not running')
    assert.ok(await answers(), 'the other player still runs')
  } finally {
    const exited = new Promise(resolve => other.once('exit', resolve))
    other.kill('SIGINT')
    await exited
  }
})

test('--watch: the player stops when the watched process (the app) ends without quitting', { timeout: 60e3 }, async () => {
  const parent = spawn('sleep', ['600'], { stdio: 'ignore' })
  try {
    const started = run(['start', '--watch', String(parent.pid)])
    assert.equal(started.status, 0, started.stderr)
    assert.ok(await answers())
    parent.kill('SIGKILL')
    assert.ok(await until(async () => !(await answers()) && leftovers().length === 0, 10e3), 'server and watcher end')
    assert.equal(run(['alive']).status, 1, 'alive reports an end the launcher did not ask for')
  } finally {
    parent.kill('SIGKILL')
    run(['stop'])
  }
})

// the app itself: a double-click (open), SuperCollider on the first load, Quit (the Dock's polite quit) ends all
const appPids = () => execFileSync('ps', ['-axo', 'pid=,args='], { encoding: 'utf8' }).split('\n')
  .filter(line => line.trimEnd().endsWith(`${app}/Contents/MacOS/applet`)).map(line => +line.trim().split(/\s+/)[0])
const quitApp = pid => execFileSync('osascript', ['-l', 'JavaScript', '-e',
  `ObjC.import('AppKit'); $.NSRunningApplication.runningApplicationWithProcessIdentifier(${pid}).terminate`])
const appSkip = process.platform !== 'darwin' ? 'macOS only' : !fs.existsSync(app) ? 'no app' : false

test('the app: one double-click starts the player, SuperCollider plays on a load, Quit leaves nothing', { skip: appSkip, timeout: 180e3 }, async () => {
  const before = new Set(appPids())
  // without SuperCollider the app's check needs some sclang path (the load below is then left out)
  const appEnv = { ...env, SCLANG: findSclang() ?? process.execPath }
  const pass = Object.entries(appEnv).filter(([k]) => /^CE_|^SCLANG$/.test(k)).flatMap(([k, v]) => ['--env', `${k}=${v}`])
  execFileSync('open', ['-n', ...pass, app], { env: appEnv })
  let pid = null
  try {
    assert.ok(await until(() => (pid = appPids().find(p => !before.has(p))), 15e3), 'the app runs')
    assert.ok(await until(answers, 20e3), 'the player answers on the test port')
    if (findSclang()) {
      const base = `http://localhost:${PORT}`
      // the master fader (CC 12) at 0: nothing sounds
      const response = await fetch(base + '/sc/load', { method: 'POST', headers: { Origin: base },
        body: JSON.stringify({ id: '009-house', cc: [[12, 0]] }) })
      assert.equal(response.status, 200, await response.clone().text())
      assert.ok(leftovers().some(line => line.trim().startsWith('sclang')), 'SuperCollider runs')
    }
    quitApp(pid)
    assert.ok(await until(() => !appPids().includes(pid) && leftovers().length === 0, 20e3),
      `the app, the player and SuperCollider end: ${leftovers().join(' | ')}`)
  } finally {
    if (pid && appPids().includes(pid)) process.kill(pid, 'SIGKILL')
    run(['stop'])
  }
})

test('the committed app holds the current launcher.applescript (rebuild: npm run launcher)', { skip: appSkip }, () => {
  const squash = text => text.replace(/\s+/g, '')
  const compiled = execFileSync('osadecompile', [path.join(app, 'Contents/Resources/Scripts/main.scpt')], { encoding: 'utf8' })
  assert.equal(squash(compiled), squash(fs.readFileSync(path.join(here, 'launcher.applescript'), 'utf8')))
  assert.ok(fs.statSync(path.join(app, 'Contents/MacOS/applet')).mode & 0o111, 'the applet is executable')
})
