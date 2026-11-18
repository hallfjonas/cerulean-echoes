// Checks the recording endpoints (recording.mjs) end to end: starts the player server on a free port with a temporary
// recordings folder, records two chunks of a stereo sine, and reads the WAV and sidecar back. Also the refusals: a
// foreign page, an unknown track, a bad source, an unknown name, a chunk of half a frame.
// usage (in tools/): node trajectory/check-recording.mjs   (exit 1 on a failure)
import fs from 'fs'
import os from 'os'
import path from 'path'
import net from 'net'
import { spawn } from 'child_process'
import { fileURLToPath } from 'url'

const root = path.dirname(fileURLToPath(import.meta.url))
const TRACK = '010-ambient-house'
const SAMPLE_RATE = 48000
const folder = fs.mkdtempSync(path.join(os.tmpdir(), 'check-recording-'))
const port = await new Promise(resolve => {
  const probe = net.createServer().listen(0, '127.0.0.1', () => {
    const { port } = probe.address()
    probe.close(() => resolve(port))
  })
})
const server = spawn('node', [path.join(root, 'server.mjs'), String(port)],
  { env: { ...process.env, RECORDINGS_DIR: folder }, stdio: ['ignore', 'pipe', 'inherit'] })
await new Promise(resolve => server.stdout.once('data', resolve))

const base = `http://127.0.0.1:${port}/recording/`
const failures = []
const expect = (ok, text) => {
  console.log(`${ok ? 'ok  ' : 'FAIL'} ${text}`)
  if (!ok) failures.push(text)
}
const post = (url, body, headers = {}) => fetch(base + url, { method: 'POST', body: JSON.stringify(body),
  headers: { 'Content-Type': 'application/json', ...headers } })

const sine = (frames, offset) => {
  const pcm = Buffer.alloc(frames * 4)
  for (let i = 0; i < frames; i++) {
    const value = Math.round(Math.sin(2 * Math.PI * 440 * (offset + i) / SAMPLE_RATE) * 0x4000)
    pcm.writeInt16LE(value, i * 4)
    pcm.writeInt16LE(-value, i * 4 + 2)
  }
  return pcm
}

try {
  expect((await post(TRACK, { source: 'human', sampleRate: SAMPLE_RATE }, { Origin: 'https://strudel.cc' }))
    .status === 403, 'a foreign page is refused')
  expect((await post('no-such-track', { source: 'human', sampleRate: SAMPLE_RATE })).status === 404,
    'an unknown track is refused')
  expect((await post(TRACK, { source: 'robot', sampleRate: SAMPLE_RATE })).status === 400, 'a bad source is refused')
  expect((await fetch(base + `${TRACK}/2026-01-01-000000-human`, { method: 'PUT', body: sine(10, 0) })).status === 404,
    'a name the server did not open is refused')

  const started = await post(TRACK, { source: 'auto', script: 'every-button', startCycle: 0.123456, cps: 0.5,
    sampleRate: SAMPLE_RATE })
  const { name } = await started.json()
  expect(started.status === 201 && /^\d{4}-\d\d-\d\d-\d{6}-auto$/.test(name), `start names the file (${name})`)
  const chunks = [sine(SAMPLE_RATE, 0), sine(SAMPLE_RATE / 2, SAMPLE_RATE)]
  for (const chunk of chunks) {
    const response = await fetch(base + `${TRACK}/${name}`, { method: 'PUT', body: chunk })
    expect(response.ok, `chunk of ${chunk.length} bytes appended`)
  }
  expect((await fetch(base + `${TRACK}/${name}`, { method: 'PUT', body: Buffer.alloc(6) })).status === 400,
    'half a frame is refused')
  const wavFile = path.join(folder, TRACK, name + '.wav')
  expect(fs.readFileSync(wavFile).readUInt32LE(40) === SAMPLE_RATE * 6, 'the header is valid before finish')

  const finished = await post(`${TRACK}/${name}/finish`, { endedBy: 'script-end' })
  const meta = await finished.json()
  expect(finished.ok && meta.endedBy === 'script-end' && meta.seconds === 1.5 && meta.startCycle === 0.1235 &&
    meta.script === 'every-button' && meta.take === null && /^[0-9a-f]{40}$/.test(meta.trackHash),
    'finish returns the sidecar')
  expect(JSON.stringify(JSON.parse(fs.readFileSync(path.join(folder, TRACK, name + '.json'), 'utf8'))) ===
    JSON.stringify(meta), 'the sidecar file matches')

  const wav = fs.readFileSync(wavFile)
  const data = Buffer.concat(chunks)
  expect(wav.toString('ascii', 0, 4) === 'RIFF' && wav.toString('ascii', 8, 16) === 'WAVEfmt ' &&
    wav.readUInt32LE(4) === 36 + data.length && wav.readUInt16LE(20) === 1 && wav.readUInt16LE(22) === 2 &&
    wav.readUInt32LE(24) === SAMPLE_RATE && wav.readUInt16LE(34) === 16 && wav.readUInt32LE(40) === data.length,
    'the WAV header is right')
  expect(wav.subarray(44).equals(data), 'the samples come back unchanged')
  expect((await post(`${TRACK}/${name}/finish`, {})).status === 404, 'a finished recording is closed')
} finally {
  server.kill()
  fs.rmSync(folder, { recursive: true, force: true })
}

console.log(failures.length ? `${failures.length} failed` : 'all passed')
process.exit(failures.length ? 1 : 0)
