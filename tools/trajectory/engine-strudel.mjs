// The player's audio engine: everything Strudel lives here (initStrudel, sample banks and gm_* soundfonts, evaluate,
// hush, the midin / midikeys shims and the WebMidi / strudelMirror globals the tracks read). The page talks to it only
// through { ready, load(code), stop(), cycle(), cps(), output() }; controller input comes from midi.mjs, so another
// engine can take the same input.
import { initStrudel, evaluate, samples, hush, signal, reify, Pattern, Hap, TimeSpan }
  from 'https://unpkg.com/@strudel/web@1.2.6/dist/index.mjs'
import { BANKS, SOUNDFONTS } from './banks.mjs'

// Every connect to a context's destination goes to that context's master bus instead, which feeds the destination,
// so the whole output can be tapped (recorder.mjs). superdough's output node is not exported, and it and the dough
// worklet connect to the destination directly; a rebuilt output node is caught the same way.
const masterBuses = new WeakMap()
const nativeConnect = AudioNode.prototype.connect
const nativeDisconnect = AudioNode.prototype.disconnect
const masterBusOf = context => {
  if (!masterBuses.has(context)) {
    const bus = context.createGain()
    nativeConnect.call(bus, context.destination)
    masterBuses.set(context, bus)
  }
  return masterBuses.get(context)
}
const toBus = target => target instanceof AudioDestinationNode ? masterBusOf(target.context) : target
AudioNode.prototype.connect = function (target, ...rest) {
  return nativeConnect.call(this, toBus(target), ...rest)
}
AudioNode.prototype.disconnect = function (target, ...rest) {
  return target === undefined ? nativeDisconnect.call(this) : nativeDisconnect.call(this, toBus(target), ...rest)
}

export const createEngine = midi => {
  globalThis.WebMidi = {
    get inputs() { return midi.inputs() },
    get outputs() { return midi.outputs() },
  }
  globalThis.midin = async name => {
    if (name && !midi.has(name)) throw new Error('MIDI input not found: ' + name)
    return cc => signal(() => midi.cc(name, cc))
  }
  // Every key pressed since the last query as a note of `length` cycles from the start of that query (no note-off, as
  // in strudel.cc). Each query empties the queue, so a track reads it through one query.
  globalThis.midikeys = async name => {
    if (!midi.has(name)) throw new Error('MIDI input not found: ' + name)
    return length => new Pattern(state => {
      const keys = midi.takeKeys(name)
      if (!keys.length) return []
      const begin = state.span.begin
      const cycles = reify(length).query(state.setSpan(new TimeSpan(begin, begin.add(1 / 64))))[0]?.value ?? 0.5
      const whole = new TimeSpan(begin, begin.add(cycles))
      return keys.map(key => new Hap(whole, state.span.intersection(whole), key))
    })
  }

  let repl = null
  const ready = initStrudel({
    prebake: () => Promise.all([
      ...BANKS.map(url => samples(url)),
      import(SOUNDFONTS + 'fontloader.mjs').then(({ registerSoundfonts }) => registerSoundfonts()),
    ]),
  }).then(r => { repl = r })

  return {
    ready,
    // The track's LC view reads the control names from strudel.cc's editor text; here the track itself stands in.
    // A fresh start: evaluate alone swaps the pattern on the running clock; hush first restarts it at cycle 0, so
    // alternations and slow patterns start in the same phase on every load and bar 0 of a script is cycle 0.
    load: async code => {
      globalThis.strudelMirror = { code }
      hush()
      await evaluate(code)
    },
    stop: () => hush(),
    // The cycle the scheduler's next query starts at, not now(): it queries ahead, so a control set or a key queued
    // now is heard from this cycle on (with now() every scripted step came about a tenth of a bar late)
    cycle: () => repl?.scheduler.lastEnd ?? repl?.scheduler.now() ?? 0,
    cps: () => repl?.scheduler.cps ?? 0.5,
    output: () => masterBusOf(globalThis.getAudioContext()),
  }
}
