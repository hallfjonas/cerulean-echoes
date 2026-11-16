// The Tools page's commands: a fixed whitelist of the scripts in tools/, each run as `node <script> <args>` in tools/.
// A command takes a catalogue entry of one of its kinds ('live' track, 'lab' board) or, with no kinds, nothing.
// Paths never come from the request: the target is a catalogue id, its file is looked up in the catalogue.
//   GET    /tools                 the commands as [{ id, label, kinds }]
//   POST   /run/<command>[/<id>]  runs it; the response is server-sent events: 'start', 'stdout' / 'stderr' (one
//                                 line each), 'exit' (exit code or signal). One job at a time: 409 while one runs.
//   DELETE /run                   stops the running job (its whole process group)
// Every route is only for this server's own pages (the caller passes its Origin / Host check), never with CORS.
import fs from 'fs'
import path from 'path'
import { spawn } from 'child_process'
import { fileURLToPath } from 'url'
import { find } from './catalogue.mjs'

const TOOLS_DIR = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..')
const ENGINE_BANNER = '// ============================================================\n// ENGINE'
const ALL_FADERS_UP = JSON.stringify(Object.fromEntries([...Array(8).keys()].map(i => [i + 5, 1])))

export const COMMANDS = {
  'check-sounds': { label: 'Check sounds', kinds: ['live', 'lab'],
    steps: file => [['strudel-sim/check-sounds.mjs', file]] },
  loudness: { label: 'Loudness (every stem, keys, pads)', kinds: ['live'],
    steps: file => [['strudel-sim/audibility.mjs', file]] },
  layouts: { label: 'Layout sheet + syx', kinds: ['live'],
    steps: file => [['lcxl-layout/gen-layout.mjs', file], ['lcxl-layout/make-syx.mjs', file]] },
  'stem-lab-sync': { label: 'Stem lab: sync engine', kinds: ['lab'], accepts: source => source.includes(ENGINE_BANNER),
    steps: file => [['stem-lab/sync.mjs', file]] },
  'stem-lab-check': { label: 'Stem lab: what each column plays', kinds: ['lab'],
    steps: file => [['stem-lab/check.mjs', file, ALL_FADERS_UP]] },
  set: { label: 'Build set 011', kinds: [], steps: () => [['set/make-set.mjs'], ['set/check-set.mjs', '2']] },
}

const plan = (commandId, targetId) => {
  if (!Object.hasOwn(COMMANDS, commandId)) return { status: 404, message: 'unknown command' }
  const command = COMMANDS[commandId]
  if (!command.kinds.length) return targetId ? { status: 404, message: 'takes no target' } : { steps: command.steps() }
  const entry = targetId && find(targetId)
  if (!entry || !command.kinds.includes(entry.kind)) return { status: 404, message: 'not a target of this command' }
  if (command.accepts && !command.accepts(fs.readFileSync(entry.path, 'utf8'))) {
    return { status: 422, message: 'this board has no ENGINE banner to sync' }
  }
  const file = path.relative(TOOLS_DIR, entry.path)
  return { label: `${command.label}: ${entry.label ?? entry.id}`, steps: command.steps(file) }
}

let job = null

const send = (response, event, data) =>
  response.write(`event: ${event}\n${String(data).split('\n').map(line => `data: ${line}`).join('\n')}\n\n`)

const pipeLines = (stream, response, event) => {
  let rest = ''
  stream.on('data', chunk => {
    const lines = (rest + chunk).split('\n')
    rest = lines.pop()
    for (const line of lines) send(response, event, line)
  })
  stream.on('end', () => rest && send(response, event, rest))
}

const runSteps = (steps, response, done) => {
  const [step, ...later] = steps
  send(response, 'start', `node ${step.join(' ')}`)
  const child = spawn(process.execPath, step, { cwd: TOOLS_DIR, detached: true, stdio: ['ignore', 'pipe', 'pipe'] })
  job.child = child
  pipeLines(child.stdout, response, 'stdout')
  pipeLines(child.stderr, response, 'stderr')
  child.on('close', (code, signal) => {
    send(response, 'exit', signal ?? code)
    if (code === 0 && later.length && !job.stopped) return runSteps(later, response, done)
    done()
  })
}

const stop = () => {
  if (!job) return false
  job.stopped = true
  try {
    process.kill(-job.child.pid, 'SIGTERM')
  } catch {}
  return true
}

export const handleTools = (request, response, url, fromOwnPage) => {
  if (!fromOwnPage(request)) return response.writeHead(403).end('forbidden')
  if (url.pathname === '/tools' && request.method === 'GET') {
    const list = Object.entries(COMMANDS).map(([id, { label, kinds }]) => ({ id, label, kinds }))
    return response.writeHead(200, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' })
      .end(JSON.stringify(list))
  }
  if (url.pathname === '/run' && request.method === 'DELETE') {
    return stop() ? response.writeHead(204).end() : response.writeHead(404).end('no job running')
  }
  if (!url.pathname.startsWith('/run/') || request.method !== 'POST') return response.writeHead(404).end('not found')
  const [commandId, targetId, ...rest] = url.pathname.slice('/run/'.length).split('/').map(decodeURIComponent)
  const planned = rest.length ? { status: 404, message: 'not found' } : plan(commandId, targetId)
  if (!planned.steps) return response.writeHead(planned.status).end(planned.message)
  if (job) return response.writeHead(409).end(`busy: ${job.label}`)
  job = { label: planned.label ?? COMMANDS[commandId].label, stopped: false }
  request.resume()
  response.writeHead(200, { 'Content-Type': 'text/event-stream', 'Cache-Control': 'no-cache',
    Connection: 'keep-alive' })
  response.on('close', () => !response.writableEnded && stop())
  runSteps(planned.steps, response, () => {
    job = null
    response.end()
  })
}
