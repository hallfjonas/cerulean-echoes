// Turns SuperCollider's notes (SSE event 'notes' of sc-link.mjs, sent by sc/lib/steps.scd when each note sounds) into
// trajectory lines (README, "How it is built"), so render.mjs draws SC tracks. A note: [stem, instrument, Hz (0 = a sample), pan 0..1, level, seconds, room 0..1]. The pulse comes from SC's
// beat messages and the layout's bpm.

const DRUM_HZ = [[/(kick|bd)/i, 60], [/(snare|clap|rim|sd|cp)/i, 1800], [/(hat|hh|ride|cym|shaker)/i, 8000]]
const clamp = (v, lo = 0, hi = 1) => Math.min(hi, Math.max(lo, v))
const round = v => Math.round(v * 1000) / 1000
const frac = v => v - Math.floor(v)

const pitchOf = (hz, instrument, stem) => {
  if (hz > 0) return hz
  const drum = DRUM_HZ.find(([pattern]) => pattern.test(instrument) || pattern.test(stem))
  return drum ? drum[1] : 1000
}

export function createScSource({ onLine, onStatus = () => {}, url = 'sc/events', fps = 30 }) {
  const stems = new Map()
  const onsets = []
  const t0 = performance.now() / 1000
  const now = () => performance.now() / 1000 - t0
  let bpm = 120, beat = null, notes = 0

  function hit([stemName, instrument, hz, pan, amp, seconds, room]) {
    const t = now()
    const stem = stems.get(stemName) ?? { x: 0, y: 0.5, z: 0, peak: 1e-6, level: 0, hold: 0.2, lastHit: -Infinity, on: 0 }
    stems.set(stemName, stem)
    stem.x = clamp(pan * 2 - 1, -1, 1)
    stem.y = clamp(Math.log(clamp(pitchOf(hz, instrument, stemName), 20, 20000) / 20) / Math.log(1000))
    stem.z = clamp(room)
    stem.peak = Math.max(amp, stem.peak * 0.995)
    const level = clamp(amp / stem.peak) ** 0.5
    stem.level = Math.max(level, stem.level * Math.exp(-(t - stem.lastHit) / stem.hold))
    stem.hold = clamp(seconds, 0.08, 2)
    stem.lastHit = t
    stem.on = 1
    onsets.push({ t, slot: Math.floor(t * bpm / 60 * 4) })
    notes++
  }

  const stream = new EventSource(url)
  stream.onopen = () => onStatus('connected, waiting for SuperCollider …')
  stream.onerror = () => onStatus('no connection to the server')
  stream.onmessage = ({ data }) => {
    const { type, data: payload } = JSON.parse(data)
    if (type === 'notes') for (const note of payload) hit(note)
    else if (type === 'layout' && payload?.bpm) bpm = payload.bpm
    else if (type === 'beat') beat = { bar: payload.bar, beat: payload.beat, at: now() }
    else if (type === 'host' && !payload.track) { stems.clear(); onsets.length = 0; beat = null; notes = 0 }
  }

  const timer = setInterval(() => {
    const t = now()
    for (const [name, stem] of stems) {
      const e = stem.level * Math.exp(-(t - stem.lastHit) / stem.hold)
      onLine({ t: round(t), stem: name, x: round(stem.x), y: round(stem.y), z: round(stem.z), e: round(e), on: stem.on })
      stem.on = 0
    }
    if (!beat) return
    while (onsets.length && onsets[0].t < t - 240 / bpm) onsets.shift()
    const beats = beat.beat + (t - beat.at) * bpm / 60
    onLine({ t: round(t), pulse: { bpm, phase: round(frac(beats)),
      density: round(clamp(new Set(onsets.map(o => o.slot % 16)).size / 16)), swing: 0 } })
    onStatus(`SuperCollider · ${stems.size} stems · ${notes} notes`)
  }, 1000 / fps)

  return { close: () => { clearInterval(timer); stream.close() } }
}
