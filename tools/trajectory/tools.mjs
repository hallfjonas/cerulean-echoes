// The Tools page's commands: a fixed whitelist of the scripts in tools/, each run as `node <script> <args>` in tools/.
// A command takes a catalogue entry of one of its kinds ('live' track, 'lab' board) or, with no kinds, nothing.
// Paths never come from the request: the target is a catalogue id, its file is looked up in the catalogue.
//   GET    /tools                 the commands as [{ id, label, kinds, help }]; help = { does, input, output, use }
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
    help: {
      does: 'Plays the track in the simulator with every control and Launchkey pad, collects the sounds it uses and checks '
        + 'that each one loads in a browser.',
      input: 'A live track or lab board from the catalogue.',
      output: 'A log line per sound (ok, broken, or plays only after push to main). Updates samples/sounds.json. '
        + 'Exit code 1 when the track uses a broken sound.',
      use: ['Pick a track or board.', 'Run; it fetches every sound, so it needs network access.',
        'Fix or replace every sound reported broken.']
    },
    steps: file => [['strudel-sim/check-sounds.mjs', file]] },
  loudness: { label: 'Loudness (every stem, keys, pads)', kinds: ['live'],
    help: {
      does: 'Renders the mix, every stem alone, the Launchkey keys and every pad at the default state '
        + '(faders up, knobs at 0) and measures how loud each one is.',
      input: 'A live track from the catalogue.',
      output: 'One loudness line per part, flagged SILENT (no sound), LOW (more than 12 dB below the median stem) '
        + 'or CLIPS (peak above 1). Nothing is written to disk.',
      use: ['Pick a track.', 'Run; every part renders one after another, so it takes a while.',
        'Raise a LOW part or lower a CLIPS part in the track, then run again.']
    },
    steps: file => [['strudel-sim/audibility.mjs', file]] },
  layouts: { label: 'Layout sheet + syx', kinds: ['live'],
    help: {
      does: 'Builds the printable controller layout sheet and the Launch Control XL 3 custom modes from the @ctl '
        + 'comments of the track.',
      input: 'A live track from the catalogue (its @ctl, @mode and @col comments are the source).',
      output: 'Writes <track>-layout.pdf, <track>-mode1.syx and <track>-mode2.syx next to the track file.',
      use: ['Pick a track.', 'Run.', 'Load the .syx files into the controller with Novation Components '
        + '(slots 1 and 2); print or open the PDF.']
    },
    steps: file => [['lcxl-layout/gen-layout.mjs', file], ['lcxl-layout/make-syx.mjs', file]] },
  'stem-lab-sync': { label: 'Stem lab: sync engine', kinds: ['lab'], accepts: source => source.includes(ENGINE_BANNER),
    help: {
      does: 'Copies the shared engine over everything from the ENGINE banner on in a stem lab board, so every board '
        + 'runs the same engine and keeps only its own head (columns, samples).',
      input: 'A lab board that has the ENGINE banner (other boards are refused).',
      output: 'Rewrites the board file in place.',
      use: ['Edit the engine part in tools/stem-lab, not in a board.', 'Pick a board.', 'Run, then check the git diff.']
    },
    steps: file => [['stem-lab/sync.mjs', file]] },
  'stem-lab-check': { label: 'Stem lab: what each column plays', kinds: ['lab'],
    help: {
      does: 'Queries a board for 8 bars with every fader up and prints what each column plays. No audio.',
      input: 'A lab board from the catalogue.',
      output: 'Events per column and bar in the log. Nothing is written to disk.',
      use: ['Pick a board.', 'Run.', 'Use it to see that every column plays rhythm and not just held notes.']
    },
    steps: file => [['stem-lab/check.mjs', file, ALL_FADERS_UP]] },
  set: { label: 'Build set 011', kinds: [],
    help: {
      does: 'Builds the set (007 → 010 → 009 → 008 as one performance) from the frozen dual tracks and the set frame, '
        + 'then proves that each track plays event by event on its plateau.',
      input: 'None. The sources are in tracks/sets/011-combining-all/sources and tools/set/set-frame.strudel.',
      output: 'Writes 011-set-dual.strudel, its layout sheet and .syx modes; the log shows the check per track and '
        + 'the query time per cycle.',
      use: ['Run after changing a frozen source or the frame.', 'Read the check lines; every plateau must match.']
    },
    steps: () => [['set/make-set.mjs'], ['set/check-set.mjs', '2']] },
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
    const list = Object.entries(COMMANDS).map(([id, { label, kinds, help }]) => ({ id, label, kinds, help }))
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
