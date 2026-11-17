// POST /take/<track>: the page sends the capture of its current play (take.mjs createRecorder session: meta, bar-0
// snapshot, messages) and the server turns it into a take with the track's controls as they are in the track file now,
// checks it like check-perform and writes perform/<track>/takes/<YYYY-MM-DD>-<HHMMSS>-<source>.json (uncommitted,
// gitignored). The track id must be a live track of the catalogue; the file name is made here, never by the page.
// Answers { id: 'takes/<name>', steps, problems: check-perform's errors (the take is written anyway) }.
import fs from 'fs'
import path from 'path'
import { find } from './catalogue.mjs'
import { PERFORM, checkScript, controlsOf } from './check-perform.mjs'
import { toScript } from './take.mjs'

const MAX_BODY = 64 * 1024 * 1024
const pad2 = n => String(n).padStart(2, '0')

const nameOf = (dir, source, now = new Date()) => {
  const date = `${now.getFullYear()}-${pad2(now.getMonth() + 1)}-${pad2(now.getDate())}`
  const base = `${date}-${pad2(now.getHours())}${pad2(now.getMinutes())}${pad2(now.getSeconds())}-${source}`
  let name = base
  for (let n = 2; fs.existsSync(path.join(dir, name + '.json')); n++) name = `${base}-${n}`
  return name
}

const isSession = session => session && typeof session === 'object' && Array.isArray(session.messages) &&
  Array.isArray(session.snapshot) && typeof session.recordedAt === 'string'

export const saveTake = (id, session) => {
  const entry = find(id)
  if (!entry || entry.kind !== 'live') return { status: 404, body: { error: `no live track '${id}'` } }
  if (!isSession(session)) return { status: 400, body: { error: 'not a capture (messages, snapshot, recordedAt)' } }
  const controls = controlsOf(fs.readFileSync(entry.path, 'utf8'))
  const script = toScript({ ...session, track: id }, controls)
  const dir = path.join(PERFORM, id, 'takes')
  fs.mkdirSync(dir, { recursive: true })
  const name = nameOf(dir, script.take.source)
  fs.writeFileSync(path.join(dir, name + '.json'), JSON.stringify(script, null, 2) + '\n')
  return { status: 200, body: { id: `takes/${name}`, steps: script.steps.length,
    problems: checkScript(script, controls, id) } }
}

export const handleTake = (request, response, id) => {
  let body = '', size = 0
  request.on('data', chunk => {
    size += chunk.length
    if (size <= MAX_BODY) body += chunk
  })
  request.on('end', () => {
    let result
    try {
      result = size > MAX_BODY ? { status: 413, body: { error: 'capture too large' } } : saveTake(id, JSON.parse(body))
    } catch (error) {
      result = { status: 400, body: { error: error.message } }
    }
    response.writeHead(result.status, { 'Content-Type': 'application/json' }).end(JSON.stringify(result.body))
  })
}
