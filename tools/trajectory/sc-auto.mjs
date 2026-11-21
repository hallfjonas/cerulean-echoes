// Auto-perform and takes on SuperCollider tracks. Pure: runs in the page and in Node (the caller hands in `post`).
//
// createScAuto: the performer's output for an SC track. autoperform.mjs plays a script into an object with midi.mjs's
// auto interface (setAuto, setAutoLk, noteAuto, noteOffAuto, releaseAutoKeys, resetAuto); on a Strudel track that is
// midi.mjs's virtual ports, on an SC track it is this: every step goes to SC through the player's server, like a click
// in the LC view: an LC CC → POST /sc/cc (→ /ce/cc), a Launchkey CC → POST /sc/lk { cc } (→ /ce/lkcc), keys and pads
// → POST /sc/lk { note: [note, velocity 1-127, channel 0-based: 9 = pads] } (→ /ce/lknote). SC plays a key at once
// and has no note-off: noteOffAuto only reaches the capture. The requests go out one after the other in step order
// (consecutive CCs of a tick share one), so a ramp never ends on an older value. The scripts stay as they are.
// hold() (before prime): nothing is sent, the values are kept and go with the load (loadInit() → POST /sc/load
// { id, cc, lk }), so SC sets a script's bar 0 before its first note, like a primed script on Strudel; live() after the
// load. Every step also reaches onMessage listeners as the MIDI message midi.mjs's virtual port would send (ports
// 'LCXL3 Auto' / 'Launchkey MK4 25 Auto'), so a take of an SC play hears the script as on Strudel; heldCcs() is the
// take's bar-0 snapshot: SC starts every load from 0, so it is what the load set, never a hardware position.
//
// createScTap: the SC counterpart of the tapped Strudel events of a play (a take's events file, check-replay): SC's
// state echoes on /sc/events (push(type, data) for each) as one batch per bar. At each bar line (beat message with
// beat 0, bar b):
//   'sc keys'  cycle b-1, the keys and pads SC played in the bar before (notes: 'note/channel …' in arrival order)
//   'sc cc'    cycle b, the LC CCs SC holds (fields cc<n>, non-zero only, in steps of CC_STEP MIDI steps, so a ramp
//              read a tick earlier or later still matches)
//   'sc lk'    cycle b, the Launchkey CCs, likewise
//   'sc state' cycle b, the pattern choices (rows.<column>: 'now>next') and the track's other state lines (JSON)
// Events have duration 1 (a bar) and are compared by replay-check.mjs like Strudel's.
export const AUTO_PORT = 'LCXL3 Auto'              // = midi.mjs AUTO_PORT
export const LK_AUTO_PORT = 'Launchkey MK4 25 Auto' // = midi.mjs LK_AUTO_PORT
export const CC_STEP = 4

const byte = value => Math.round(value * 127)

export const createScAuto = ({ post, now = () => performance.now(), onError = () => {} }) => {
  const lc = new Map(), lk = new Map(), sounding = new Map(), listeners = new Set()
  let holding = false, queue = [], sending = null

  const emit = (port, status, a, b) => {
    const message = { port, status, data: [a, b], time: now() }
    for (const listener of listeners) listener(message)
  }
  // the next request: consecutive LC CCs as one /sc/cc, or consecutive Launchkey CCs plus the note after them as /sc/lk
  const nextRequest = () => {
    if (queue[0].kind === 'cc') {
      const pairs = []
      while (queue[0]?.kind === 'cc') pairs.push(queue.shift().pair)
      return ['cc', pairs]
    }
    const body = { cc: [] }
    while (queue[0]?.kind === 'lk') body.cc.push(queue.shift().pair)
    if (queue[0]?.kind === 'note') body.note = queue.shift().note
    return ['lk', body]
  }
  const pump = async () => {
    while (queue.length) {
      const [route, body] = nextRequest()
      try { await post(route, body) } catch (error) { onError(error) }
    }
    sending = null
  }
  const enqueue = op => {
    if (holding) return
    queue.push(op)
    sending ??= Promise.resolve().then(pump)   // after this tick: its steps go together
  }
  const releaseAutoKeys = () => {
    for (const { note, midichan } of [...sounding.values()]) noteOffAuto(note, midichan)
  }
  const noteOffAuto = (note, midichan) => {
    sounding.delete(`${midichan}:${note}`)
    emit(LK_AUTO_PORT, 0x80 | (midichan - 1), note, 0)
  }
  const setAuto = (cc, value) => {
    lc.set(cc, { value, time: now() })
    emit(AUTO_PORT, 0xbf, cc, byte(value))
    enqueue({ kind: 'cc', pair: [cc, value] })
  }
  const setAutoLk = (number, value) => {
    lk.set(number, { value, time: now() })
    emit(LK_AUTO_PORT, 0xb0, number, byte(value))
    enqueue({ kind: 'lk', pair: [number, value] })
  }
  const pairs = map => [...map].filter(([, { value }]) => value > 0).map(([number, { value }]) => [number, value])
  const held = (map, port) => [...map].map(([cc, { value, time }]) => ({ port, cc, value, time }))

  return {
    setAuto,
    setAutoLk,
    noteAuto: (note, velocity, midichan) => {
      const velocityByte = Math.max(1, byte(velocity))
      sounding.set(`${midichan}:${note}`, { note, midichan })
      emit(LK_AUTO_PORT, 0x90 | (midichan - 1), note, velocityByte)
      enqueue({ kind: 'note', note: [note, velocityByte, midichan - 1] })
    },
    noteOffAuto,
    releaseAutoKeys,
    // back to 0: every value this output set (sent while live; while holding only forgotten, the load starts SC at 0)
    resetAuto: () => {
      for (const cc of lc.keys()) setAuto(cc, 0)
      for (const number of lk.keys()) setAutoLk(number, 0)
      lc.clear()
      lk.clear()
      releaseAutoKeys()
    },
    hold: () => { holding = true; queue = [] },
    live: () => { holding = false },
    // forget every value without sending (before a load without a script: SC starts from 0)
    clear: () => { lc.clear(); lk.clear(); sounding.clear() },
    // what the load sets before the first note: { cc: [[cc, value]], lk: [[number, value]] } (non-zero values)
    loadInit: () => ({ cc: pairs(lc), lk: pairs(lk) }),
    heldCcs: () => [...held(lc, AUTO_PORT), ...held(lk, LK_AUTO_PORT)],
    onMessage: callback => {
      listeners.add(callback)
      return () => listeners.delete(callback)
    },
    // resolves when every step so far has been sent
    idle: () => sending ?? Promise.resolve(),
  }
}

const fields = (map, prefix) => Object.fromEntries([...map].map(([n, v]) => [prefix + n, Math.round(v * 127 / CC_STEP)])
  .filter(([, steps]) => steps > 0).sort(([a], [b]) => parseInt(a.slice(prefix.length)) - parseInt(b.slice(prefix.length))))
const stateFields = state => {
  if (!state || typeof state !== 'object') return {}
  const { rows = {}, ...rest } = state
  const value = {}
  for (const key of Object.keys(rows).sort()) value[`rows.${key}`] = [].concat(rows[key]).join('>')
  for (const key of Object.keys(rest).sort()) value[key] = JSON.stringify(rest[key])
  return value
}
const entries = data => Object.entries(data ?? {}).map(([n, v]) => [Number(n), Number(v) || 0])

export const createScTap = ({ onBatch = () => {} } = {}) => {
  let ccs = new Map(), lks = new Map(), state = null, keys = [], lastBar = null
  const event = (stem, cycle, value) => ({ stem, cycle, duration: 1, value })
  const push = (type, data) => {
    if (type === 'layout') { keys = []; lastBar = null }
    else if (type === 'ccs') ccs = new Map(entries(data))
    else if (type === 'cc') for (const [n, v] of entries(data)) ccs.set(n, v)
    else if (type === 'lk') lks = new Map(entries(data))
    else if (type === 'lkcc') lks.set(Number(data[0]), Number(data[1]))
    else if (type === 'state') state = data
    else if (type === 'lknote') keys.push(`${data[0]}/${data[1]}`)
    else if (type === 'beat' && data.beat === 0 && data.bar !== lastBar) {
      // keys before the first bar line seen belong to that bar
      const bar = data.bar, first = lastBar === null
      const batch = [
        ...!first && keys.length ? [event('sc keys', bar - 1, { notes: keys.join(' ') })] : [],
        event('sc cc', bar, fields(ccs, 'cc')),
        event('sc lk', bar, fields(lks, 'lk')),
        event('sc state', bar, stateFields(state)),
      ]
      if (!first) keys = []
      lastBar = bar
      onBatch(batch)
      return batch
    }
    return null
  }
  return { push }
}
