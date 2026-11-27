// The player's SuperCollider engine ({ ready, load, stop, cycle, cps, output }), with the sound made by SC (sc/engine.scd, started by the server through sc-link.mjs). The controllers
// go straight to SC; this page only follows SC's state over /sc/events (the clock from its beats, the MIDI panel
// from sc/ui/index.html in its own frame).
// load(id, init?) takes a catalogue id, not code; init = { cc: [[cc, value]], lk: [[number, value]] } is set before
// the first note (an auto-perform script's bar 0, sc-auto.mjs). output() is null: SC's sound does not pass through the
// browser. onEvent(type, data) gets every message of /sc/events after the engine has read it (the take's SC tap).
export const createScEngine = ({ onEvent = () => {} } = {}) => {
  let bpm = 120, beat = null, loadedAt = 0, playing = false, host = { running: false, ready: false, track: null }
  let lastCycle = 0, loading = false
  let source = null
  const connect = () => {
    if (source) return
    source = new EventSource('sc/events')
    source.onmessage = event => {
      const { type, data } = JSON.parse(event.data)
      if (type === 'host') host = data
      else if (type === 'layout' && data?.bpm) bpm = data.bpm
      else if (type === 'beat') {
        // a beat of the track before (on its way during a load, or sent on connect) is not this load's: this load's
        // beats start at 0 and never run ahead of the time since the load
        const at = performance.now()
        if (loading || data.bar * 4 + data.beat > (at - loadedAt) / 1000 * bpm / 60 + 1) return
        beat = { bar: data.bar, beat: data.beat, at }
      }
      onEvent(type, data)
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
    load: async (id, init = {}) => {
      connect()
      beat = null
      lastCycle = 0
      loading = true
      try {
        await post('load', { id, ...init })
      } finally {
        loading = false
        loadedAt = performance.now()
      }
      playing = true
    },
    stop: () => {
      if (!playing) return
      playing = false
      post('stop').catch(() => {})
    },
    // bars since the load: the last beat SC reported (sent when it sounds) plus the time since, at the track's tempo.
    // Never backwards: before the first beat the time since the load runs ahead of the sound (SC's latency), and the
    // first beat would pull the clock back; it waits instead (scripts and takes need a clock that only moves on).
    cycle: () => {
      if (!playing) return 0
      const bps = bpm / 60
      const now = !beat ? Math.max(0, (performance.now() - loadedAt) / 1000 * bps / 4)
        : beat.bar + (beat.beat + Math.min(1, (performance.now() - beat.at) / 1000 * bps)) / 4
      return (lastCycle = Math.max(lastCycle, now))
    },
    cps: () => bpm / 240,
    output: () => null,
    host: () => host,
    playing: () => playing,
  }
}
