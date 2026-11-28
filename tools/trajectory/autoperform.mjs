// Auto-perform: plays a script of control moves and button presses into the virtual input 'LCXL3 Auto' and keys, drum
// pads and knobs into the virtual Launchkey 'Launchkey MK4 25 Auto' (sc-auto.mjs), so a track can be tried without a
// controller. Open loop: the script does not listen to what it hears.
// Script: { track, title?, bars?, mood?, sections?: [{ name, from, to, intent? }], steps } with steps
//   { bar, cc, value, ramp? }            a Launch Control CC (value 0..1, sent as MIDI 0..127)
//   { bar, press }                       a momentary Launch Control button (its CC)
//   { bar, keys, velocity?, length? }    Launchkey keys: note names played together ('c3 e3 g3' = chord)
//   { bar, pad, velocity? }              a Launchkey drum pad (note 36-51, channel 10)
//   { bar, lk, value, ramp? }            a Launchkey CC: mod wheel 1 (keys level), knob 21-28 (keys) or 31-38 (drum pads)
// Bars of the playing track (1 cycle = 1 bar in every live track), counted from the start; ramp = bars to move from
// the control's value at `bar` to `value`. A control the script never sets stays at 0. velocity 0..1 (default 0.8);
// length = bars a key is held (default 1): the tracks' midikeys has no note-off, so the sound's length is the track's
// (knob 5 Length in 009/010); length only sets when the note-off reaches the LC view. Sections: bar ranges [from, to).
// Steps follow the engine's cycle clock, read every scheduler tick, so they stay on the bar whatever the tempo; a step
// fires once the clock is within BAR_TOLERANCE of its bar (takes round bars to 4 decimals); a press is held for two
// scheduler ticks, or the tracks' cycleButton can miss it. A take (a recorded script) adds the meta field `take`,
// which playing ignores.
// prime(script) before the track loads, then start(script) after it: the last run's values are reset and the script's
// bar-0 values set before the load, so the first query already reads them (and a capture of the play sees neither
// the reset nor a late bar-0 step). start alone does both just after the load, a query or two late.
// prime(script, from) / start(script, from) start at bar `from` instead: the values the script holds there are set
// before the load, the presses before it go with the load as counts (pressCounts, so patterns and chapters are where
// the script put them), keys and pads before it are skipped, and the clock counts on from `from`.
export const TICK_MS = 50
export const HOLD_TICKS = 2
export const BAR_TOLERANCE = 1e-6
export const PADS = [36, 51]
export const LK_CCS = [1, 21, 22, 23, 24, 25, 26, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38]   // knobs: bank A CC 21-28 (keys), bank B 31-38 (pads)
export const PAD_CHANNEL = 10
const KEYS_CHANNEL = 1
const DEFAULT_VELOCITY = 0.8
const DEFAULT_LENGTH = 1

const midiValue = value => Math.round(value * 127) / 127

const CHROMA = { c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11 }
const ACCIDENTAL = { '#': 1, s: 1, b: -1, f: -1 }
// A note name (c4 = 60, octave 3 if left out, # / s sharp, b / f flat) or a MIDI number
export const noteNumber = name => {
  if (/^\d+$/.test(name)) return Number(name) <= 127 ? Number(name) : null
  const match = name.match(/^([a-g])([#sbf]*)(-?\d)?$/i)
  if (!match) return null
  const [, letter, accidentals, octave = '3'] = match
  const note = (Number(octave) + 1) * 12 + CHROMA[letter.toLowerCase()] +
    [...accidentals].reduce((sum, a) => sum + ACCIDENTAL[a], 0)
  return note >= 0 && note <= 127 ? note : null
}
// The MIDI notes of a keys step, or null if one of them is not a note
export const keyNotes = keys => {
  const notes = String(keys).trim().split(/\s+/).map(noteNumber)
  return notes.length && notes.every(n => n !== null) ? notes : null
}

export const isLaunchkeyStep = step => step.keys !== undefined || step.pad !== undefined || step.lk !== undefined
export const usesLaunchkey = script => (script.steps ?? []).some(isLaunchkeyStep)

// The section that holds `bar`, or null
export const sectionAt = (script, bar) => (script.sections ?? []).find(s => s.from <= bar && bar < s.to) ?? null

const valueOn = (curve, bar, tolerance = 0) => {
  const segment = curve.findLast(s => s.bar <= bar + tolerance)
  if (!segment) return undefined
  const progress = segment.ramp ? Math.min(1, Math.max(0, bar - segment.bar) / segment.ramp) : 1
  return midiValue(segment.from + (segment.to - segment.from) * progress)
}

const addSegment = (curves, cc, step) => {
  const curve = curves.get(cc) ?? []
  curves.set(cc, curve)
  curve.push({ bar: step.bar, from: valueOn(curve, step.bar) ?? 0, to: step.value, ramp: step.ramp ?? 0 })
}

// curves / lkCurves: CC → value segments; presses: [{ bar, cc }]; notes: Launchkey note-ons in bar order
// [{ bar, notes, velocity, length, midichan }] (a pad's length is 0: its note-off follows on the next tick)
export const compile = script => {
  const curves = new Map(), lkCurves = new Map()
  const presses = [], notes = []
  for (const step of [...script.steps].sort((a, b) => a.bar - b.bar)) {
    if (step.press !== undefined) presses.push({ bar: step.bar, cc: step.press })
    else if (step.keys !== undefined) notes.push({ bar: step.bar, notes: keyNotes(step.keys) ?? [],
      velocity: step.velocity ?? DEFAULT_VELOCITY, length: step.length ?? DEFAULT_LENGTH, midichan: KEYS_CHANNEL })
    else if (step.pad !== undefined) notes.push({ bar: step.bar, notes: [step.pad],
      velocity: step.velocity ?? DEFAULT_VELOCITY, length: 0, midichan: PAD_CHANNEL })
    else if (step.lk !== undefined) addSegment(lkCurves, step.lk, step)
    else addSegment(curves, step.cc, step)
  }
  const ends = [...curves.values(), ...lkCurves.values()].flat().map(s => s.bar + s.ramp)
    .concat(presses.map(p => p.bar), notes.map(n => n.bar + n.length))
  return { curves, lkCurves, presses, notes, end: Math.max(0, script.bars ?? 0, ...ends) }
}

const changesOf = (curves, end, stepBars, lk) => {
  const changes = []
  for (const [cc, curve] of curves) {
    let last
    for (let bar = curve[0].bar; bar <= end + 1e-9; bar += stepBars) {
      const value = valueOn(curve, bar)
      if (value !== last) changes.push(lk ? { bar, cc, value, lk } : { bar, cc, value })
      last = value
    }
  }
  return changes
}

// Every change of a control value, sampled every `stepBars` bars: [{ bar, cc, value, lk? }] (for the Node scenario
// tool; lk: true for a Launchkey CC)
export const valueChanges = (script, stepBars) => {
  const { curves, lkCurves, end } = compile(script)
  return [...changesOf(curves, end, stepBars, false), ...changesOf(lkCurves, end, stepBars, true)]
    .sort((a, b) => a.bar - b.bar)
}

// [[cc, count]]: how often each button is pressed before `bar`
export const pressCounts = (script, bar) => {
  const counts = new Map()
  for (const step of script.steps) if (step.press !== undefined && step.bar < bar - BAR_TOLERANCE) {
    counts.set(step.press, (counts.get(step.press) ?? 0) + 1)
  }
  return [...counts]
}

// The bar line the script starts on: the nearest one, never before 0. Rounding down turned a clock reading just below
// 0 or just below a bar line into the bar before and played the whole script a bar early.
export const startBarOf = cycle => Math.max(0, Math.round(cycle))

export const createPerformer =({ midi, engine, onChange = () => {} }) => {
  let timer = null, script = null, compiled = null, primed = null
  let startBar = 0, from = 0, fired = 0, firedNotes = 0, held = [], sounding = []
  const written = new Map(), lkWritten = new Map()

  const release = () => {
    for (const press of held) midi.setAuto(press.cc, 0)
    held = []
    midi.releaseAutoKeys()
    sounding = []
  }
  const stop = () => {
    clearInterval(timer)
    timer = null
    release()
    onChange(null)
  }
  const write = (curves, cache, send, bar) => {
    for (const [cc, curve] of curves) {
      const value = valueOn(curve, bar, BAR_TOLERANCE)
      if (value === undefined || cache.get(cc) === value) continue
      cache.set(cc, value)
      send(cc, value)
    }
  }
  const prepare = (next, at) => {
    script = next
    from = at
    compiled = compile(script)
    midi.resetAuto()
    written.clear()
    lkWritten.clear()
    fired = compiled.presses.filter(press => press.bar < from - BAR_TOLERANCE).length
    firedNotes = compiled.notes.filter(note => note.bar < from - BAR_TOLERANCE).length
    write(compiled.curves, written, midi.setAuto, from)
    write(compiled.lkCurves, lkWritten, midi.setAutoLk, from)
  }
  const tick = () => {
    const bar = engine.cycle() - startBar + from
    const reached = bar + BAR_TOLERANCE
    write(compiled.curves, written, midi.setAuto, bar)
    write(compiled.lkCurves, lkWritten, midi.setAutoLk, bar)
    held = held.filter(press => {
      if (--press.ticks > 0) return true
      midi.setAuto(press.cc, 0)
      return false
    })
    sounding = sounding.filter(note => {
      if (note.off > bar) return true
      midi.noteOffAuto(note.note, note.midichan)
      return false
    })
    for (; fired < compiled.presses.length && compiled.presses[fired].bar <= reached; fired++) {
      const { cc } = compiled.presses[fired]
      midi.setAuto(cc, 1)
      held.push({ cc, ticks: HOLD_TICKS })
    }
    for (; firedNotes < compiled.notes.length && compiled.notes[firedNotes].bar <= reached; firedNotes++) {
      const { notes, velocity, length, midichan } = compiled.notes[firedNotes]
      for (const note of notes) {
        midi.noteAuto(note, velocity, midichan)
        sounding.push({ note, midichan, off: bar + length })
      }
    }
    if (bar > compiled.end && !held.length && !sounding.length) stop()
    else onChange({ bar, end: compiled.end, script, section: sectionAt(script, bar) })
  }

  return {
    start: (next, at = 0) => {
      if (timer) stop()
      if (next !== primed || at !== from) prepare(next, at)
      primed = null
      startBar = startBarOf(engine.cycle())
      timer = setInterval(tick, TICK_MS)
      tick()
    },
    prime: (next, at = 0) => {
      if (timer) stop()
      prepare(next, at)
      primed = next
    },
    stop: () => { if (timer) stop() },
    running: () => timer !== null,
  }
}

// Top bar text for the section that holds `bar`: its name and the bars left in it, or '' without a section
export const sectionLabel = (section, bar) => {
  if (!section) return ''
  const left = Math.ceil(section.to - bar)
  return `${section.name} · ${left} bar${left === 1 ? '' : 's'} left`
}

const element = (tag, props) => Object.assign(document.createElement(tag), props)

// Title, mood and section list of the playing script; items: [{ item, section }] to mark the current section
const scriptInfo = script => {
  if (!script) return { nodes: [], items: [] }
  const items = (script.sections ?? []).map(section => ({ section, item: element('li', {
    textContent: `${section.name} (bars ${section.from + 1}-${section.to})`, title: section.intent ?? '' }) }))
  const list = element('ol', { className: 'script-sections' })
  list.append(...items.map(({ item }) => item))
  const nodes = [
    script.title && element('div', { className: 'script-title', textContent: script.title }),
    script.mood && element('div', { className: 'script-mood', textContent: script.mood }),
    items.length && list,
  ].filter(Boolean)
  return { nodes, items }
}

// The Auto-perform section of the player sidebar: script select, Start / Stop (key P in the player), and while a
// script plays its title, mood and sections with the current one marked
export const mountAutoPerform = (container, { onStart, onStop }) => {
  const heading = element('h2', { textContent: 'Auto-perform' })
  const select = document.createElement('select')
  const button = element('button', { textContent: 'Start', title: 'Key P' })
  const state = element('output', { textContent: '' })
  const row = document.createElement('label')
  row.append(element('span', { textContent: 'Script' }), state, select)
  const info = element('div', { className: 'script-info' })
  container.replaceChildren(heading, row, button, info)
  let running = false, shown = null, items = []
  const toggle = () => running ? onStop() : select.value && onStart(select.value)
  button.onclick = toggle
  return {
    toggle,
    setScripts: ids => {
      select.replaceChildren(...ids.map(id => new Option(id, id)))
      button.disabled = !ids.length
      state.textContent = ids.length ? '' : 'none for this track'
    },
    show: (isRunning, text = '', progress = null) => {
      running = isRunning
      button.textContent = isRunning ? 'Stop' : 'Start'
      state.textContent = text
      if ((progress?.script ?? null) !== shown) {
        shown = progress?.script ?? null
        const built = scriptInfo(shown)
        info.replaceChildren(...built.nodes)
        items = built.items
      }
      for (const { item, section } of items) item.classList.toggle('now', section === progress?.section)
    },
  }
}
