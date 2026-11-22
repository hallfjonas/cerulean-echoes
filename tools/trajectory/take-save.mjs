// POST /take/<track>: the page sends the capture of its current play (take.mjs createRecorder session: meta, bar-0
// snapshot, messages) and the server turns it into a take with the track's controls as they are in the track file now,
// checks it like check-perform and writes perform/<track>/takes/<YYYY-MM-DD>-<HHMMSS>-<source>.json (uncommitted,
// gitignored), and the tapped events of the play next to it as <name>.events.jsonl (one batch per line, named by the
// take's `events` field). The track id must be a live track of the catalogue; the file name is made here, never by the
// page. A SuperCollider track's capture has no trackHash (the page gets no track text): the sha1 of the .scd file is
// filled in here; its events are SC's state echoes per bar (sc-auto.mjs createScTap), checked by check-replay alike. Answers { id: 'takes/<name>', steps, problems: check-perform's errors (the take is written anyway), replay?:
// the verdict of check-replay when the play was the replay of a take with events }.
import crypto from 'crypto'
import fs from 'fs'
import path from 'path'
import { find } from './catalogue.mjs'
import { PERFORM, checkScript, controlsOf, tagSource } from './check-perform.mjs'
import { toScript } from './take.mjs'
import { checkReplay, isReplay } from './check-replay.mjs'
import { summaryLine } from './replay-check.mjs'

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
  const source = fs.readFileSync(entry.path, 'utf8')
  const controls = controlsOf(tagSource(entry.path))
  const trackHash = session.trackHash ?? crypto.createHash('sha1').update(source).digest('hex')
  const script = toScript({ ...session, track: id, trackHash }, controls)
  const dir = path.join(PERFORM, id, 'takes')
  fs.mkdirSync(dir, { recursive: true })
  const name = nameOf(dir, script.take.source)
  const events = Array.isArray(session.events) ? session.events.filter(Array.isArray) : []
  if (events.length) {
    script.take.events = name + '.events.jsonl'
    fs.writeFileSync(path.join(dir, script.take.events), events.map(batch => JSON.stringify(batch) + '\n').join(''))
  }
  fs.writeFileSync(path.join(dir, name + '.json'), JSON.stringify(script, null, 2) + '\n')
  const replay = isReplay(script) && checkReplay(id, `takes/${name}`)
  const verdict = replay && (replay.error ? `cannot check: ${replay.error}` : summaryLine(replay.result))
  return { status: 200, body: { id: `takes/${name}`, steps: script.steps.length,
    problems: checkScript(script, controls, id), ...verdict && { replay: verdict } } }
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
