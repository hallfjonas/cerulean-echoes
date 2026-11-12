// Turns Strudel events (from a tapped track, relayed by server.mjs) into trajectory lines, the same format the audio
// analysis writes (analyse.mjs), so the renderer does not care where the music comes from. Unlike the audio analysis,
// every stem is exact: pan, pitch, reverb share and level come from the events themselves, the pulse from Strudel's
// clock. Each event is played out when it sounds (its `delay`), not when the scheduler sends it.

const DRUM_HZ = [[/^(bd|kick|tr\d*_bd)/i, 60], [/^(sd|cp|clap|rim|snare)/i, 1800], [/^(hh|oh|hat|ride|rd|cr|cy)/i, 8000]]
const NOTE_STEPS = { c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11 }
const clamp = (v, lo = 0, hi = 1) => Math.min(hi, Math.max(lo, v))
const round = v => Math.round(v * 1000) / 1000
const frac = v => v - Math.floor(v)

function noteToMidi(note) {
  if (typeof note === 'number') return note
  const match = /^([a-gA-G])([#sbf]*)(-?\d+)?$/.exec(String(note).trim())
  if (!match) return undefined
  const [, letter, accidentals, octave = '3'] = match
  const shift = [...accidentals].reduce((s, a) => s + (a === '#' || a === 's' ? 1 : -1), 0)
  return NOTE_STEPS[letter.toLowerCase()] + shift + (Number(octave) + 1) * 12
}

function frequencyOf({ freq, note, n, s, lpf, cutoff, hpf }) {
  if (typeof freq === 'number') return freq
  const midi = noteToMidi(note ?? (typeof s === 'string' && /^(sine|sawtooth|square|triangle|supersaw)/.test(s) ? n : undefined))
  if (midi !== undefined) return 440 * 2 ** ((midi - 69) / 12)
  const drum = DRUM_HZ.find(([pattern]) => pattern.test(s ?? ''))
  if (drum) return Math.max(drum[1], hpf ?? 0)
  return Math.max(lpf ?? cutoff ?? 1000, hpf ?? 0)
}

export function createStrudelSource({ onLine, onStatus = () => {}, url = '/stream', fps = 30, beatsPerCycle = 4 }) {
  const stems = new Map()
  const onsets = []
  const t0 = performance.now() / 1000
  const now = () => performance.now() / 1000 - t0
  let clock = null, batches = 0

  function hit(event) {
    const t = now(), v = event.value
    const name = event.stem.replace(/^stem/, '')
    const stem = stems.get(name) ?? { x: 0, y: 0.5, z: 0, peak: 1e-6, level: 0, hold: 0.2, lastHit: -Infinity, on: 0 }
    stems.set(name, stem)
    if (typeof v.pan === 'number') stem.x = clamp(v.pan * 2 - 1, -1, 1)
    stem.y = clamp(Math.log(clamp(frequencyOf(v), 20, 20000) / 20) / Math.log(1000))
    if (typeof v.room === 'number') stem.z = clamp(v.room)
    const amplitude = (v.gain ?? 1) * (v.postgain ?? 1) * (v.velocity ?? 1)
    stem.peak = Math.max(amplitude, stem.peak * 0.995)
    const level = clamp(amplitude / stem.peak) ** 0.5
    const current = stem.level * Math.exp(-(t - stem.lastHit) / stem.hold)
    stem.level = Math.max(level, current)
    stem.hold = clamp(event.duration, 0.08, 2)
    stem.lastHit = t
    stem.on = 1
    clock = { cycle: event.cycle, time: t, cps: event.cps }
    onsets.push({ t, slot: Math.floor(event.cycle * 16 + 1e-6) })
  }

  const stream = new EventSource(url)
  stream.onopen = () => onStatus('verbunden, warte auf Strudel …')
  stream.onerror = () => onStatus('keine Verbindung zum Server (node trajectory/server.mjs)')
  stream.onmessage = ({ data }) => {
    batches++
    for (const event of JSON.parse(data)) setTimeout(() => hit(event), Math.max(0, event.delay * 1000 - 5))
  }

  const timer = setInterval(() => {
    const t = now()
    for (const [name, stem] of stems) {
      const e = stem.level * Math.exp(-(t - stem.lastHit) / stem.hold)
      onLine({ t: round(t), stem: name, x: round(stem.x), y: round(stem.y), z: round(stem.z), e: round(e), on: stem.on })
      stem.on = 0
    }
    if (!clock) return
    while (onsets.length && onsets[0].t < t - 1 / clock.cps) onsets.shift()
    const cycle = clock.cycle + (t - clock.time) * clock.cps
    onLine({ t: round(t), pulse: { bpm: round(clock.cps * 60 * beatsPerCycle), phase: round(frac(cycle * beatsPerCycle)),
      density: round(clamp(new Set(onsets.map(o => o.slot)).size / 16)), swing: 0 } })
    onStatus(`Strudel · ${stems.size} Stems · ${batches} Pakete`)
  }, 1000 / fps)

  return { close: () => { clearInterval(timer); stream.close() } }
}
