// Web MIDI for the player, independent of the audio engine: each input (DAW ports left out) keeps the last value of
// every CC with the time it came, and the keys pressed since they were last taken. The engine reads it through
// cc(name, number) and takeKeys(name); a control not moved yet reads 0.
// The virtual input 'LCXL3 Auto' (addAuto, fed by autoperform.mjs through setAuto) sits in the same ports map: the
// tracks treat it as one more Launch Control, so a real controller moved later takes a control over (last moved wins).
// The tracks' LC view asks the browser for Web MIDI itself: navigator.requestMIDIAccess is wrapped so its answer also
// holds the virtual input (sending what setAuto sets as channel-16 CC messages); refused or unanswered after 2 s (like
// ready), it holds the virtual input alone.
let access = null
let inputCount = 0
const ports = new Map()

const listen = () => {
  inputCount = 0
  for (const input of access.inputs.values()) {
    if (/DAW/.test(input.name)) continue
    inputCount++
    const port = ports.get(input.name) ?? { cc: new Map(), keys: [] }
    ports.set(input.name, port)
    input.onmidimessage = ({ data: [status, a, b] }) => {
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
const auto = { cc: new Map(), keys: [] }
const autoInput = Object.assign(new EventTarget(), { name: AUTO_PORT, type: 'input', state: 'connected' })
const sendAuto = (number, value) => autoInput.dispatchEvent(
  Object.assign(new Event('midimessage'), { data: new Uint8Array([0xbf, number, Math.round(value * 127)]) }))

const requestReal = options => (nativeRequest?.(options) ?? Promise.resolve(null)).catch(() => nativeRequest())
navigator.requestMIDIAccess = options => settle(requestReal(options)).catch(() => null)
  .then(real => ({
    inputs: new Map([...(real?.inputs ?? []), [AUTO_PORT, autoInput]]),
    outputs: real?.outputs ?? new Map(),
    addEventListener: (...args) => real?.addEventListener(...args),
  }))

export const addAuto = () => {
  if (ports.has(AUTO_PORT)) return false
  ports.set(AUTO_PORT, auto)
  return true
}
export const setAuto = (number, value) => {
  auto.cc.set(number, { value, time: performance.now() })
  sendAuto(number, value)
}
export const resetAuto = () => {
  for (const number of auto.cc.keys()) sendAuto(number, 0)
  auto.cc.clear()
}

const virtualInputs = () => ports.has(AUTO_PORT) ? [{ name: AUTO_PORT }] : []
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

export const takeKeys = name => matching(name).flatMap(port => port.keys.splice(0))
