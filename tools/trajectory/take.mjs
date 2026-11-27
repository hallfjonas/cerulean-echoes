// Performance capture: every MIDI message the player hears during a play, kept with its bar, and turned into an
// auto-perform script v2 with `take` meta (tools/trajectory/perform/script-format-v2.md). Pure: runs in the page
// and in Node; the page hands in midi.mjs and the engine (createRecorder), a test hands in messages (createSession).
// Bar of a message = engine.cycle() at its arrival minus the load's bar line: the start of the scheduler's next
// query, which is where midikeys places a key and from where a midin signal reads a new value.
// Conversion: the CC values the inputs hold at the load become bar-0 steps; a Launch Control button CC becomes a
// `press` at each value > 0; other Launch Control CCs and the Launchkey's mod wheel and knobs become `cc` / `lk` steps,
// cut into gestures where messages pause and thinned with Ramer-Douglas-Peucker (tolerance 1 MIDI step) into `ramp`
// steps; Launchkey note-ons become `pad` (channel 10, notes 36-51) or `keys` steps, with the note-off as `length`.
// Launch Control CCs that are not controls of the track, other Launchkey CCs and Launch Control notes are dropped.
import { LK_CCS, PADS, PAD_CHANNEL, startBarOf } from './autoperform.mjs'

const VIRTUAL_PORTS = ['LCXL3 Auto', 'Launchkey MK4 25 Auto']
export const GESTURE_GAP_MS = 100
const TOLERANCE = 1 / 127
const NOTE_NAMES = ['c', 'c#', 'd', 'd#', 'e', 'f', 'f#', 'g', 'g#', 'a', 'a#', 'b']

const round = (value, decimals) => Math.round(value * 10 ** decimals) / 10 ** decimals
const roundBar = bar => round(Math.max(0, bar), 4)
const isLaunchkey = port => port.includes('Launchkey')
const isVirtual = port => VIRTUAL_PORTS.includes(port)
export const noteName = note => `${NOTE_NAMES[note % 12]}${Math.floor(note / 12) - 1}`

// A play's buffer: meta { track, trackHash, cps, recordedAt, script?, snapshot: midi.heldCcs() at the load }, the
// messages { port, status, data, time, bar } in arrival order and the tapped events as batches (addEvents)
export const createSession = meta => ({ ...meta, snapshot: meta.snapshot ?? [], messages: [], events: [] })
export const addMessage = (session, message, bar) => session.messages.push({ ...message, bar: roundBar(bar) })

// Captures every play: start() at each track load opens a new session (the previous one is dropped). Bar 0 is the
// bar line the performer starts a script on (startBarOf): the clock has already run a query or two after the load, and
// counting from that raw cycle put every replayed step a tenth of a bar early.
// addEvents(batch): a batch of tapped events as the SC tap hands it in (sc-auto.mjs createScTap), kept with `cycle`
// counted from the same bar line. An event the clock has not reached yet is a late batch of the play before the load
// (its clock ran further) and is dropped, as is anything before the bar line.
export const createRecorder = ({ midi, engine }) => {
  let session = null
  let startCycle = 0
  midi.onMessage(message => { if (session) addMessage(session, message, engine.cycle() - startCycle) })
  return {
    start: meta => {
      startCycle = startBarOf(engine.cycle())
      session = createSession({ ...meta, recordedAt: new Date().toISOString(), snapshot: midi.heldCcs() })
      return session
    },
    session: () => session,
    addEvents: batch => {
      if (!session) return
      const reached = engine.cycle() + 1e-6
      const events = batch.filter(event => event.cycle <= reached && event.cycle >= startCycle - 1e-6)
        .map(event => ({ ...event, cycle: round(event.cycle - startCycle, 6) }))
      if (events.length) session.events.push(events)
    },
  }
}

const furthest = (points, from, to) => {
  const [a, b] = [points[from], points[to]]
  let index = -1, distance = TOLERANCE + 1e-9
  for (let i = from + 1; i < to; i++) {
    const line = a.value + (b.value - a.value) * (points[i].bar - a.bar) / (b.bar - a.bar)
    const off = Math.abs(points[i].value - line)
    if (off > distance) [index, distance] = [i, off]
  }
  return index
}

// Ramer-Douglas-Peucker on { bar, value } with the vertical distance: the points the polyline keeps
export const thin = points => {
  if (points.length < 3) return points
  const keep = new Set([0, points.length - 1])
  const split = (from, to) => {
    const index = furthest(points, from, to)
    if (index < 0) return
    keep.add(index)
    split(from, index)
    split(index, to)
  }
  split(0, points.length - 1)
  return points.filter((_, i) => keep.has(i))
}

// A control's moves as gestures (a pause over GESTURE_GAP_MS starts a new one), the last value per bar in each: the
// signal reads the value once per query, and the clock gives one bar per query
const gestures = moves => {
  const result = []
  let previous = null
  for (const move of moves) {
    if (!previous || move.time - previous.time > GESTURE_GAP_MS) result.push([])
    const gesture = result.at(-1)
    if (gesture.at(-1)?.bar === move.bar) gesture.pop()
    gesture.push({ bar: move.bar, value: move.value })
    previous = move
  }
  return result
}

// One gesture: a jump to its first value, then a ramp to every point the thinning keeps
const curveSteps = (field, number, moves) => gestures(moves).flatMap(gesture => {
  const points = thin(gesture)
  const steps = [{ bar: points[0].bar, [field]: number, value: round(points[0].value, 4) }]
  for (let i = 1; i < points.length; i++) {
    const ramp = roundBar(points[i].bar - points[i - 1].bar)
    steps.push({ bar: points[i - 1].bar, [field]: number, value: round(points[i].value, 4), ...ramp > 0 && { ramp } })
  }
  return steps
})

// The latest value per control over all real inputs (several Launch Controls: the one moved last wins)
const snapshotSteps = (snapshot, controls) => {
  const latest = new Map()
  for (const held of snapshot) {
    const key = isLaunchkey(held.port) ? `lk:${held.cc}` : `cc:${held.cc}`
    if (!latest.has(key) || held.time > latest.get(key).time) latest.set(key, held)
  }
  return [...latest].flatMap(([key, { cc, value }]) => {
    const lk = key.startsWith('lk:')
    if (value === 0 || (lk ? !LK_CCS.includes(cc) : controls.get(cc)?.button !== false)) return []
    return [{ bar: 0, [lk ? 'lk' : 'cc']: cc, value: round(Math.round(value * 127) / 127, 4) }]
  })
}

const velocityOf = byte => round(byte / 127, 3)
const isPad = (channel, note) => channel === PAD_CHANNEL && note >= PADS[0] && note <= PADS[1]

const noteSteps = messages => {
  const steps = [], sounding = new Map()
  for (const { port, status, data: [note, velocity], bar } of messages) {
    const kind = status & 0xf0, channel = (status & 0x0f) + 1
    const key = `${port}:${channel}:${note}`
    if (kind === 0x90 && velocity > 0) {
      const step = isPad(channel, note) ? { bar, pad: note, velocity: velocityOf(velocity) }
        : { bar, keys: noteName(note), velocity: velocityOf(velocity) }
      steps.push(step)
      if (step.keys) sounding.set(key, step)
    } else if (sounding.has(key)) {
      const length = round(bar - sounding.get(key).bar, 2)
      if (length > 0) sounding.get(key).length = length
      sounding.delete(key)
    }
  }
  return steps
}

const sourceOf = ports => {
  const virtual = ports.filter(isVirtual).length
  return virtual === 0 ? 'human' : virtual === ports.length ? 'auto' : 'mixed'
}

const pad2 = n => String(n).padStart(2, '0')
const localTime = iso => {
  const d = new Date(iso)
  const date = `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())}`
  return `${date} ${pad2(d.getHours())}:${pad2(d.getMinutes())}`
}

const endOf = step => step.bar + (step.ramp ?? step.length ?? 0)

// The session as a v2 script with `take` meta; controls = controlsOf(track source) (cc → { name, button })
export const toScript = (session, controls) => {
  const { messages } = session
  const ccMoves = new Map(), presses = []
  for (const message of messages) {
    if ((message.status & 0xf0) !== 0xb0) continue
    const [number, byte] = message.data
    const move = { bar: message.bar, value: byte / 127, time: message.time }
    if (isLaunchkey(message.port)) {
      if (LK_CCS.includes(number)) ccMoves.set(`lk:${number}`, [...ccMoves.get(`lk:${number}`) ?? [], move])
    } else if (controls.get(number)?.button) {
      if (byte > 0) presses.push({ bar: message.bar, press: number })
    } else if (controls.has(number)) ccMoves.set(`cc:${number}`, [...ccMoves.get(`cc:${number}`) ?? [], move])
  }
  const curves = [...ccMoves].flatMap(([key, moves]) =>
    curveSteps(key.startsWith('lk:') ? 'lk' : 'cc', Number(key.slice(3)), moves))
  const notes = noteSteps(messages.filter(m => isLaunchkey(m.port) && [0x80, 0x90].includes(m.status & 0xf0)))
  const steps = [...snapshotSteps(session.snapshot, controls), ...curves, ...presses, ...notes]
    .sort((a, b) => a.bar - b.bar)
  const inputs = [...new Set([...session.snapshot.map(held => held.port), ...messages.map(m => m.port)])]
  const source = sourceOf(inputs)
  return {
    track: session.track,
    title: `Take ${localTime(session.recordedAt)}`,
    bars: Math.max(1, Math.ceil(Math.max(0, ...steps.map(endOf)))),
    take: {
      source,
      recordedAt: session.recordedAt,
      trackHash: session.trackHash,
      cps: session.cps,
      inputs,
      ...source !== 'human' && session.script && { script: session.script },
    },
    steps,
  }
}
