// Audio recordings of the player's master output (recorder.mjs streams them), written outside git:
// recordings/<track>/<YYYY-MM-DD>-<HHMMSS>-<human|auto>.wav (16-bit PCM, stereo) and a .json sidecar of the same name.
//   POST /recording/<track>                 body { source, script?, take?, startCycle, cps, sampleRate } → { name }
//   PUT  /recording/<track>/<name>          body: interleaved 16-bit little-endian PCM, appended (about 1 s each)
//   POST /recording/<track>/<name>/finish   body { endedBy } → the sidecar
// The track id must be in the catalogue and the name must be one this server opened; the page never names a file.
// The WAV header and the sidecar are rewritten after every chunk, so a crash or a closed tab leaves a valid file.
// Refused (507) below 2 GB free on the recordings disk.
// SuperCollider tracks: the same three routes, but SC writes the WAV itself (DiskOut, sc/engine.scd, started and stopped
// over OSC by sc-link.mjs) at the same path; the POST body says engine: 'sc' (no sampleRate: SC's own is used, the
// sidecar says engine: 'sc'), there are no PUT chunks. When SC closes the file (finish, a track load, Stop, SC ending)
// the server checks the WAV header against the file size (repairs it if needed) and writes the sidecar's length.
// The disk is watched every 5 s while SC records; below 2 GB free the recording is stopped.
import fs from 'fs'
import path from 'path'
import crypto from 'crypto'
import { find, repo } from './catalogue.mjs'

const RECORDINGS = process.env.RECORDINGS_DIR ?? path.join(repo, 'recordings')
const MIN_FREE = 2 * 1024 ** 3
const MAX_CHUNK = 8 * 1024 * 1024
const CHANNELS = 2
const BYTES_PER_FRAME = CHANNELS * 2
const SOURCES = ['human', 'auto']
const ENDINGS = ['stop', 'script-end', 'unload']
const open = new Map()
const finished = new Map()   // SuperCollider recordings that are closed: a second finish answers the same sidecar
let scLink = null

const freeBytes = () => {
  fs.mkdirSync(RECORDINGS, { recursive: true })
  const { bavail, bsize } = fs.statfsSync(RECORDINGS)
  return bavail * bsize
}

export const wavHeader = (sampleRate, dataBytes) => {
  const header = Buffer.alloc(44)
  header.write('RIFF', 0)
  header.writeUInt32LE(36 + dataBytes, 4)
  header.write('WAVEfmt ', 8)
  header.writeUInt32LE(16, 16)
  header.writeUInt16LE(1, 20)
  header.writeUInt16LE(CHANNELS, 22)
  header.writeUInt32LE(sampleRate, 24)
  header.writeUInt32LE(sampleRate * BYTES_PER_FRAME, 28)
  header.writeUInt16LE(BYTES_PER_FRAME, 32)
  header.writeUInt16LE(16, 34)
  header.write('data', 36)
  header.writeUInt32LE(dataBytes, 40)
  return header
}

const pad = n => String(n).padStart(2, '0')
const stamp = date => `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}-` +
  `${pad(date.getHours())}${pad(date.getMinutes())}${pad(date.getSeconds())}`

const freshName = (folder, base) => {
  let name = base
  for (let n = 2; fs.existsSync(path.join(folder, name + '.wav')); n++) name = `${base}-${n}`
  return name
}

const readBody = (request, limit) => new Promise((resolve, reject) => {
  const chunks = []
  let size = 0
  request.on('data', chunk => {
    size += chunk.length
    if (size > limit) {
      reject(Object.assign(new Error('body too large'), { status: 413 }))
      request.destroy()
    } else chunks.push(chunk)
  })
  request.on('end', () => resolve(Buffer.concat(chunks)))
  request.on('error', reject)
})

const readJson = async request => {
  try {
    return JSON.parse((await readBody(request, 64 * 1024)).toString('utf8') || '{}')
  } catch (error) {
    throw Object.assign(error, { status: error.status ?? 400 })
  }
}

const writeState = recording => {
  fs.writeSync(recording.fd, wavHeader(recording.meta.sampleRate, recording.bytes), 0, 44, 0)
  recording.meta.seconds = Math.round(recording.bytes / BYTES_PER_FRAME / recording.meta.sampleRate * 1000) / 1000
  fs.writeFileSync(recording.sidecar, JSON.stringify(recording.meta, null, 2) + '\n')
}

// SC's file: find the data chunk, and make the sizes in the header match what is in the file (a killed sclang leaves
// the sizes of an empty file). Returns { sampleRate, frames } or null when it is no stereo 16-bit WAV.
export const checkWav = file => {
  const wav = fs.readFileSync(file)
  if (wav.length < 12 || wav.toString('ascii', 0, 4) !== 'RIFF' || wav.toString('ascii', 8, 12) !== 'WAVE') return null
  let at = 12, sampleRate = 0, channels = 0, bits = 0
  while (at + 8 <= wav.length) {
    const id = wav.toString('ascii', at, at + 4), size = wav.readUInt32LE(at + 4)
    if (id === 'fmt ') {
      channels = wav.readUInt16LE(at + 10)
      sampleRate = wav.readUInt32LE(at + 12)
      bits = wav.readUInt16LE(at + 22)
    }
    if (id === 'data') {
      const actual = wav.length - (at + 8)
      const bytes = Math.floor(actual / BYTES_PER_FRAME) * BYTES_PER_FRAME
      if (size !== bytes || wav.readUInt32LE(4) !== at + bytes) {
        const fd = fs.openSync(file, 'r+')
        const word = Buffer.alloc(4)
        fs.writeSync(fd, (word.writeUInt32LE(bytes, 0), word), 0, 4, at + 4)
        fs.writeSync(fd, (word.writeUInt32LE(at + bytes, 0), word), 0, 4, 4)
        fs.closeSync(fd)
      }
      if (channels !== CHANNELS || bits !== 16) return null
      return { sampleRate, frames: bytes / BYTES_PER_FRAME }
    }
    at += 8 + size + (size & 1)
  }
  return null
}

const finishSc = (key, endedBy = 'stop') => {
  if (finished.has(key)) return finished.get(key)
  const recording = open.get(key)
  if (!recording) return null
  clearInterval(recording.watch)
  const info = fs.existsSync(recording.wav) ? checkWav(recording.wav) : null
  if (info) recording.meta.seconds = Math.round(info.frames / info.sampleRate * 1000) / 1000
  recording.meta.endedBy = ENDINGS.includes(recording.endedBy ?? endedBy) ? recording.endedBy ?? endedBy : 'stop'
  fs.writeFileSync(recording.sidecar, JSON.stringify(recording.meta, null, 2) + '\n')
  open.delete(key)
  finished.set(key, recording.meta)
  return recording.meta
}

// SC closed a file by itself (a load, Stop, SC ending): finish what is open
export const useScLink = link => {
  scLink = link
  link.record.onEnd(() => { for (const [key, recording] of open) if (recording.sc) finishSc(key) })
}

const startSc = async (track, entry, body) => {
  if (!scLink) return { status: 503, body: 'no SuperCollider link' }
  if (entry.engine !== 'sc') return { status: 400, body: 'engine sc needs a SuperCollider track' }
  if (!SOURCES.includes(body.source)) return { status: 400, body: 'source must be human or auto' }
  if (freeBytes() < MIN_FREE) return { status: 507, body: 'less than 2 GB free, not recording' }
  if ([...open.values()].some(recording => recording.sc)) return { status: 409, body: 'already recording' }
  const folder = path.join(RECORDINGS, track)
  fs.mkdirSync(folder, { recursive: true })
  const startedAt = new Date()
  const name = freshName(folder, `${stamp(startedAt)}-${body.source}`)
  const wav = path.join(folder, name + '.wav')
  const sampleRate = await scLink.record.start(wav)
  const meta = {
    track,
    trackHash: crypto.createHash('sha1').update(fs.readFileSync(entry.path, 'utf8')).digest('hex'),
    engine: 'sc',
    source: body.source,
    script: typeof body.script === 'string' ? body.script : null,
    take: typeof body.take === 'string' ? body.take : null,
    startCycle: Math.round((Number(body.startCycle) || 0) * 1e4) / 1e4,
    cps: Number(body.cps) || null,
    sampleRate,
    channels: CHANNELS,
    bitDepth: 16,
    startedAt: startedAt.toISOString(),
    seconds: 0,
    endedBy: null,
  }
  const key = `${track}/${name}`
  const recording = { track, meta, sc: true, wav, sidecar: path.join(folder, name + '.json') }
  recording.watch = setInterval(() => {
    if (freeBytes() < MIN_FREE) { scLink.record.stop().then(() => finishSc(key)) }
  }, 5000)
  recording.watch.unref()
  open.set(key, recording)
  fs.writeFileSync(recording.sidecar, JSON.stringify(meta, null, 2) + '\n')
  return { status: 201, json: { name } }
}

const start = async (request, track) => {
  const entry = find(track)
  if (!entry) return { status: 404, body: 'unknown track' }
  const body = await readJson(request)
  if (body.engine === 'sc') return startSc(track, entry, body)
  if (entry.engine === 'sc') return { status: 400, body: 'a SuperCollider track records with engine sc' }
  const sampleRate = Number(body.sampleRate)
  if (!SOURCES.includes(body.source)) return { status: 400, body: 'source must be human or auto' }
  if (!Number.isInteger(sampleRate) || sampleRate < 8000 || sampleRate > 192000) {
    return { status: 400, body: 'bad sampleRate' }
  }
  if (freeBytes() < MIN_FREE) return { status: 507, body: 'less than 2 GB free, not recording' }
  const folder = path.join(RECORDINGS, track)
  fs.mkdirSync(folder, { recursive: true })
  const startedAt = new Date()
  const name = freshName(folder, `${stamp(startedAt)}-${body.source}`)
  const text = fs.readFileSync(entry.path, 'utf8')
  const meta = {
    track,
    trackHash: crypto.createHash('sha1').update(text).digest('hex'),
    source: body.source,
    script: typeof body.script === 'string' ? body.script : null,
    take: typeof body.take === 'string' ? body.take : null,
    startCycle: Math.round((Number(body.startCycle) || 0) * 1e4) / 1e4,
    cps: Number(body.cps) || null,
    sampleRate,
    channels: CHANNELS,
    bitDepth: 16,
    startedAt: startedAt.toISOString(),
    seconds: 0,
    endedBy: null,
  }
  const recording = { track, meta, bytes: 0, fd: fs.openSync(path.join(folder, name + '.wav'), 'w'),
    sidecar: path.join(folder, name + '.json') }
  open.set(`${track}/${name}`, recording)
  writeState(recording)
  return { status: 201, json: { name } }
}

const append = async (request, recording) => {
  if (recording.sc) return { status: 400, body: 'SuperCollider writes this file itself' }
  const data = await readBody(request, MAX_CHUNK)
  if (data.length % BYTES_PER_FRAME) return { status: 400, body: 'chunk is not whole stereo 16-bit frames' }
  if (freeBytes() < MIN_FREE) return { status: 507, body: 'less than 2 GB free, recording stopped' }
  fs.writeSync(recording.fd, data, 0, data.length, 44 + recording.bytes)
  recording.bytes += data.length
  writeState(recording)
  return { status: 200, json: { seconds: recording.meta.seconds } }
}

const finish = async (request, key, recording) => {
  const body = await readJson(request)
  if (recording.sc) {
    recording.endedBy ??= ENDINGS.includes(body.endedBy) ? body.endedBy : 'stop'
    await scLink.record.stop()
    return { status: 200, json: finishSc(key) }
  }
  recording.meta.endedBy = ENDINGS.includes(body.endedBy) ? body.endedBy : 'stop'
  writeState(recording)
  fs.closeSync(recording.fd)
  open.delete(key)
  return { status: 200, json: recording.meta }
}

const route = (request, url) => {
  const [track, name, action, ...rest] = url.pathname.slice('/recording/'.length).split('/').map(decodeURIComponent)
  if (rest.length) return { status: 404, body: 'not found' }
  if (!name && request.method === 'POST') return start(request, track)
  const key = `${track}/${name}`
  const recording = open.get(key)
  if (!recording && action === 'finish' && request.method === 'POST' && finished.has(key)) {
    return { status: 200, json: finished.get(key) }
  }
  if (!recording) return { status: 404, body: 'no open recording of that name' }
  if (!action && request.method === 'PUT') return append(request, recording)
  if (action === 'finish' && request.method === 'POST') return finish(request, key, recording)
  return { status: 404, body: 'not found' }
}

export const handleRecording = (request, response, url, fromOwnPage) => {
  if (!fromOwnPage(request)) return response.writeHead(403).end('forbidden')
  Promise.resolve().then(() => route(request, url)).then(({ status, body, json }) => {
    if (json) response.writeHead(status, { 'Content-Type': 'application/json' }).end(JSON.stringify(json))
    else response.writeHead(status).end(body)
  }, error => {
    if (!response.headersSent) response.writeHead(error.status ?? 500).end(error.message)
  })
}
