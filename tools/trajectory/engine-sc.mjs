// The player's SuperCollider engine: the same interface as engine-strudel.mjs ({ ready, load, stop, cycle, cps,
// output }), with the sound made by SC (sc/engine.scd, started by the server through sc-link.mjs). The controllers
// go straight to SC; this page only follows SC's state over /sc/events (the clock from its beats, the MIDI panel
// from sc/ui/index.html in its own frame).
// load(id) takes a catalogue id, not code. output() is null: SC's sound does not pass through the browser.
export const createScEngine = () => {
  let bpm = 120, beat = null, loadedAt = 0, playing = false, host = { running: false, ready: false, track: null }
  let source = null
  const connect = () => {
    if (source) return
    source = new EventSource('sc/events')
    source.onmessage = event => {
      const { type, data } = JSON.parse(event.data)
      if (type === 'host') host = data
      else if (type === 'layout' && data?.bpm) bpm = data.bpm
      else if (type === 'beat') beat = { bar: data.bar, beat: data.beat, at: performance.now() }
    }
  }
  const post = async (route, body) => {
    const response = await fetch('sc/' + route, { method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body ?? {}) })
    const result = await response.json().catch(() => ({}))
    if (!response.ok) throw new Error(result.error ?? `${route}: ${response.status}`)
    return result
  }
  return {
    ready: Promise.resolve(),
    // starts SC if needed (a few seconds the first time), then the track at bar 0
    load: async id => {
      connect()
      beat = null
      await post('load', { id })
      loadedAt = performance.now()
      playing = true
    },
    stop: () => {
      if (!playing) return
      playing = false
      post('stop').catch(() => {})
    },
    // bars since the load: the last beat SC reported (sent when it sounds) plus the time since, at the track's tempo
    cycle: () => {
      if (!playing) return 0
      const bps = bpm / 60
      if (!beat) return Math.max(0, (performance.now() - loadedAt) / 1000 * bps / 4)
      return beat.bar + (beat.beat + Math.min(1, (performance.now() - beat.at) / 1000 * bps)) / 4
    },
    cps: () => bpm / 240,
    output: () => null,
    host: () => host,
    playing: () => playing,
  }
}
