// Web MIDI for the player, independent of the audio engine: each input (DAW ports left out) keeps the last value of
// every CC with the time it came, and the keys pressed since they were last taken. The engine reads it through
// cc(name, number) and takeKeys(name); a control not moved yet reads 0.
// The virtual input 'LCXL3 Auto' (addAuto, fed by autoperform.mjs through setAuto) sits in the same ports map: the
// tracks treat it as one more Launch Control, so a real controller moved later takes a control over (last moved wins).
// The virtual input 'Launchkey MK4 25 Auto' (setAutoLk, noteAuto, noteOffAuto) contains the name the tracks look up
// with midin / midikeys ('Launchkey MK4 25'), so they hear it as a second Launchkey; like the real one it is left out
// of the nameless lookup (matching).
// The tracks' LC view asks the browser for Web MIDI itself: navigator.requestMIDIAccess is wrapped so its answer also
// holds both virtual inputs (sending what setAuto sets as channel-16 CC messages, the Launchkey's as channel-1 CCs and
// note-on / note-off, pads on channel 10); refused or unanswered after 2 s (like ready), it holds the virtual inputs
// alone.
let access = null
let inputCount = 0
const ports = new Map()
const listeners = new Set()
const emit = (port, status, a, b) => {
  const message = { port, status, data: [a, b], time: performance.now() }
  for (const listener of listeners) listener(message)
}

const listen = () => {
  inputCount = 0
  for (const input of access.inputs.values()) {
    if (/DAW/.test(input.name)) continue
    inputCount++
    const port = ports.get(input.name) ?? { cc: new Map(), keys: [] }
    ports.set(input.name, port)
    input.onmidimessage = ({ data: [status, a, b] }) => {
      emit(input.name, status, a, b)
      const kind = status & 0xf0
      if (kind === 0xb0) port.cc.set(a, { value: b / 127, time: performance.now() })
      else if (kind === 0x90 && b > 0) port.keys.push({ note: a, velocity: b / 127, midichan: (status & 0x0f) + 1 })
    }
  }
}

const ACCESS_TIMEOUT_MS = 2000
const nativeRequest = navigator.requestMIDIAccess?.bind(navigator)
const settle = request => Promise.race([request, new Promise(resolve => setTimeout(resolve, ACCESS_TIMEOUT_MS, null))])

export const ready = settle(nativeRequest?.() ?? Promise.resolve(null))
  .then(midiAccess => {
    if (!midiAccess) return
    access = midiAccess
    listen()
    access.onstatechange = listen
  })
  .catch(() => {})

export const AUTO_PORT = 'LCXL3 Auto'
export const LK_AUTO_PORT = 'Launchkey MK4 25 Auto'
const virtualPort = name => ({
  name,
  state: { cc: new Map(), keys: [] },
  input: Object.assign(new EventTarget(), { name, type: 'input', state: 'connected' }),
})
const auto = virtualPort(AUTO_PORT)
const lkAuto = virtualPort(LK_AUTO_PORT)
const lkHeld = new Map()
const send = (port, ...bytes) => {
  emit(port.name, ...bytes)
  port.input.dispatchEvent(Object.assign(new Event('midimessage'), { data: new Uint8Array(bytes) }))
}
const sendAuto = (number, value) => send(auto, 0xbf, number, Math.round(value * 127))
const sendLk = (number, value) => send(lkAuto, 0xb0, number, Math.round(value * 127))

const requestReal = options => (nativeRequest?.(options) ?? Promise.resolve(null)).catch(() => nativeRequest())
navigator.requestMIDIAccess = options => settle(requestReal(options)).catch(() => null)
  .then(real => ({
    inputs: new Map([...(real?.inputs ?? []), [AUTO_PORT, auto.input], [LK_AUTO_PORT, lkAuto.input]]),
    outputs: real?.outputs ?? new Map(),
    addEventListener: (...args) => real?.addEventListener(...args),
  }))

// The virtual Launchkey is in the ports map only while a script plays Launchkey steps, so a script without them plays
// as with no Launchkey connected
export const addAuto = ({ launchkey = false } = {}) => {
  if (launchkey) ports.set(LK_AUTO_PORT, lkAuto.state)
  else ports.delete(LK_AUTO_PORT)
  if (ports.has(AUTO_PORT)) return false
  ports.set(AUTO_PORT, auto.state)
  return true
}
export const setAuto = (number, value) => {
  auto.state.cc.set(number, { value, time: performance.now() })
  sendAuto(number, value)
}
export const setAutoLk = (number, value) => {
  lkAuto.state.cc.set(number, { value, time: performance.now() })
  sendLk(number, value)
}
export const noteAuto = (note, velocity, midichan) => {
  const velocityByte = Math.max(1, Math.round(velocity * 127))
  lkAuto.state.keys.push({ note, velocity: velocityByte / 127, midichan })
  lkHeld.set(`${midichan}:${note}`, { note, midichan })
  send(lkAuto, 0x90 | (midichan - 1), note, velocityByte)
}
export const noteOffAuto = (note, midichan) => {
  lkHeld.delete(`${midichan}:${note}`)
  send(lkAuto, 0x80 | (midichan - 1), note, 0)
}
export const releaseAutoKeys = () => {
  for (const { note, midichan } of [...lkHeld.values()]) noteOffAuto(note, midichan)
}
export const resetAuto = () => {
  for (const number of auto.state.cc.keys()) sendAuto(number, 0)
  auto.state.cc.clear()
  for (const number of lkAuto.state.cc.keys()) sendLk(number, 0)
  lkAuto.state.cc.clear()
  releaseAutoKeys()
  lkAuto.state.keys.length = 0
}

const virtualInputs = () => [AUTO_PORT, LK_AUTO_PORT].filter(name => ports.has(name)).map(name => ({ name }))
export const inputs = () => [...(access ? access.inputs.values() : []), ...virtualInputs()]
export const outputs = () => access ? [...access.outputs.values()] : []
export const count = () => inputCount
export const available = () => access !== null

// Inputs whose name contains `name`; without a name every input but the Launchkey (its knobs send the same CC
// numbers as the Launch Controls' second knob row)
const matching = name =>
  [...ports].filter(([n]) => name ? n.includes(name) : !n.includes('Launchkey')).map(([, p]) => p)

export const has = name => matching(name).length > 0

export const cc = (name, number) => {
  let last = null
  for (const port of matching(name)) {
    const v = port.cc.get(number)
    if (v && (!last || v.time > last.time)) last = v
  }
  return last?.value ?? 0
}

// Every message of every non-DAW input and of both virtual inputs as { port, status, data: [a, b], time }; returns
// the unsubscribe
export const onMessage = callback => {
  listeners.add(callback)
  return () => listeners.delete(callback)
}

// The CC values the real inputs hold now as [{ port, cc, value (0..1), time }]
export const heldCcs = () => [...ports].filter(([name]) => name !== AUTO_PORT && name !== LK_AUTO_PORT)
  .flatMap(([port, { cc }]) => [...cc].map(([number, { value, time }]) => ({ port, cc: number, value, time })))

export const takeKeys = name => matching(name).flatMap(port => port.keys.splice(0))
