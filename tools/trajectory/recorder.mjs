// Records the engine's master output (engine.output()) to the server as a 16-bit stereo WAV, streamed in chunks of
// CHUNK_SECONDS (recording.mjs writes recordings/<track>/<name>.wav and its sidecar).
//   const recorder = createRecorder({ engine })
//   await recorder.start({ track, source: 'human' | 'auto', script?, take? })   → the server's file name
//   await recorder.stop('stop' | 'script-end')                                  → the sidecar
//   recorder.recording, recorder.name, recorder.level() (peak 0..1 of the last tenth of a second),
//   recorder.elapsed() (seconds captured), recorder.error (set when the server refused a chunk; recording stops)
// Closing the page finishes an open recording with endedBy 'unload'.
const CHUNK_SECONDS = 1

export const createRecorder = ({ engine, onError = () => {} }) => {
  let node = null, name = null, track = null, sampleRate = 0, frames = 0, peak = 0, error = null
  let queue = Promise.resolve(), done = null, loaded = null
  const base = () => `recording/${encodeURIComponent(track)}/${encodeURIComponent(name)}`

  const send = chunk => {
    queue = queue.then(async () => {
      if (error) return
      const response = await fetch(base(), { method: 'PUT', body: chunk })
      if (!response.ok) throw new Error(`recording: ${response.status} ${await response.text()}`)
    }).catch(failure => {
      error = failure
      onError(failure)
      detach()
    })
  }

  const detach = () => {
    if (!node) return
    engine.output().disconnect(node)
    node.port.onmessage = null
    node = null
  }

  const unload = () => {
    if (name) navigator.sendBeacon(base() + '/finish', JSON.stringify({ endedBy: 'unload' }))
  }

  const start = async ({ track: id, source, script = null, take = null }) => {
    if (name) throw new Error('already recording')
    const output = engine.output()
    const context = output.context
    loaded ??= context.audioWorklet.addModule(new URL('./recorder-worklet.js', import.meta.url))
    await loaded
    const response = await fetch(`recording/${encodeURIComponent(id)}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ source, script, take, startCycle: engine.cycle(), cps: engine.cps(),
        sampleRate: context.sampleRate }),
    })
    if (!response.ok) throw new Error(`recording: ${response.status} ${await response.text()}`)
    track = id
    name = (await response.json()).name
    sampleRate = context.sampleRate
    frames = 0
    peak = 0
    error = null
    queue = Promise.resolve()
    node = new AudioWorkletNode(context, 'recorder', { numberOfInputs: 1, numberOfOutputs: 0, channelCount: 2,
      channelCountMode: 'explicit', processorOptions: { seconds: CHUNK_SECONDS } })
    node.port.onmessage = ({ data }) => {
      if (data === 'done') return done?.()
      if (data.peak !== undefined) peak = data.peak
      if (data.chunk) {
        frames += data.chunk.byteLength / 4
        send(data.chunk)
      }
    }
    output.connect(node)
    addEventListener('pagehide', unload)
    return name
  }

  const stop = async (endedBy = 'stop') => {
    if (!name) return null
    if (node) {
      const flushed = new Promise(resolve => { done = resolve })
      node.port.postMessage('flush')
      await flushed
      done = null
      detach()
    }
    await queue
    removeEventListener('pagehide', unload)
    const response = await fetch(base() + '/finish', { method: 'POST',
      headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ endedBy }) })
    name = null
    peak = 0
    if (!response.ok) throw new Error(`recording: ${response.status} ${await response.text()}`)
    return response.json()
  }

  return {
    start,
    stop,
    get recording() { return !!name },
    get name() { return name },
    get error() { return error },
    level: () => peak,
    elapsed: () => sampleRate ? frames / sampleRate : 0,
  }
}
