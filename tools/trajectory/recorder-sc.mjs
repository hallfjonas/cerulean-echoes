// The recorder for SuperCollider tracks: same interface as recorder.mjs (start, stop, recording, name, error, level,
// elapsed), but the sound never passes through this page. SC writes the WAV itself (recording.mjs asks it over OSC);
// the page only starts and finishes it, and takes the level meter from SC's `level` events (/sc/events, 10 per second).
export const createScRecorder = ({ engine, onError = () => {} }) => {
  let name = null, track = null, startedAt = 0, peak = 0, error = null, source = null
  const base = () => `recording/${encodeURIComponent(track)}/${encodeURIComponent(name)}`

  const close = () => {
    source?.close()
    source = null
    removeEventListener('pagehide', unload)
  }
  const unload = () => {
    if (name) navigator.sendBeacon(base() + '/finish', JSON.stringify({ endedBy: 'unload' }))
  }

  const start = async ({ track: id, source: kind, script = null, take = null }) => {
    if (name) throw new Error('already recording')
    const response = await fetch(`recording/${encodeURIComponent(id)}`, { method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ engine: 'sc', source: kind, script, take, startCycle: engine.cycle(), cps: engine.cps() }) })
    if (!response.ok) throw new Error(`recording: ${response.status} ${await response.text()}`)
    track = id
    name = (await response.json()).name
    startedAt = performance.now()
    peak = 0
    error = null
    source = new EventSource('sc/events')
    source.onmessage = event => {
      const { type, data } = JSON.parse(event.data)
      if (type === 'level') peak = data
      else if (type === 'host' && !data.running && name) {
        error = new Error('SuperCollider ended while recording')
        onError(error)
      }
    }
    addEventListener('pagehide', unload)
    return name
  }

  const stop = async (endedBy = 'stop') => {
    if (!name) return null
    close()
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
    elapsed: () => name ? (performance.now() - startedAt) / 1000 : 0,
  }
}
