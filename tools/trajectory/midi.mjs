// Web MIDI for the player: it listens to every input (DAW ports left out) so a take can record what the players do on
// the controllers. The controllers themselves go straight to SuperCollider; this page only hears them.
// onMessage(callback) gets { port, status, data: [a, b], time } for every message of every input; count() is the number
// of inputs, available() whether the browser gave Web MIDI access (refused or unanswered after 2 s, the player still
// plays: "No MIDI").
let access = null
let inputCount = 0
const listeners = new Set()

const listen = () => {
  inputCount = 0
  for (const input of access.inputs.values()) {
    if (/DAW/.test(input.name)) continue
    inputCount++
    input.onmidimessage = ({ data: [status, a, b] }) => {
      const message = { port: input.name, status, data: [a, b], time: performance.now() }
      for (const listener of listeners) listener(message)
    }
  }
}

const ACCESS_TIMEOUT_MS = 2000
const settle = request => Promise.race([request, new Promise(resolve => setTimeout(resolve, ACCESS_TIMEOUT_MS, null))])

export const ready = settle(navigator.requestMIDIAccess?.() ?? Promise.resolve(null))
  .then(midiAccess => {
    if (!midiAccess) return
    access = midiAccess
    listen()
    access.onstatechange = listen
  })
  .catch(() => {})

export const count = () => inputCount
export const available = () => access !== null

export const onMessage = callback => {
  listeners.add(callback)
  return () => listeners.delete(callback)
}
