// Auto-perform: plays a script of control moves and button presses into the virtual input 'LCXL3 Auto' (midi.mjs), so
// a track can be tried without a controller. Open loop: the script does not listen to what it hears.
// Script: { track, steps: [{ bar, cc, value, ramp? }, { bar, press }] }. Bars of the playing track (1 cycle = 1 bar in
// every live track), counted from the start; value 0..1 (sent as MIDI 0..127); ramp = bars to move from the control's
// value at `bar` to `value`; press = the CC of a momentary button. A control the script never sets stays at 0.
// Steps follow the engine's cycle clock, read every scheduler tick, so they stay on the bar whatever the tempo; a press
// is held for two scheduler ticks, or the tracks' cycleButton can miss it.
export const TICK_MS = 50
export const HOLD_TICKS = 2

const midiValue = value => Math.round(value * 127) / 127

const valueOn = (curve, bar) => {
  const segment = curve.findLast(s => s.bar <= bar)
  if (!segment) return undefined
  const progress = segment.ramp ? Math.min(1, (bar - segment.bar) / segment.ramp) : 1
  return midiValue(segment.from + (segment.to - segment.from) * progress)
}

export const compile = script => {
  const curves = new Map()
  const presses = []
  for (const step of [...script.steps].sort((a, b) => a.bar - b.bar)) {
    if (step.press !== undefined) {
      presses.push({ bar: step.bar, cc: step.press })
      continue
    }
    const curve = curves.get(step.cc) ?? []
    curves.set(step.cc, curve)
    curve.push({ bar: step.bar, from: valueOn(curve, step.bar) ?? 0, to: step.value, ramp: step.ramp ?? 0 })
  }
  const ends = [...curves.values()].flat().map(s => s.bar + s.ramp).concat(presses.map(p => p.bar))
  return { curves, presses, end: Math.max(0, ...ends) }
}

// Every change of a control value, sampled every `stepBars` bars: [{ bar, cc, value }] (for the Node scenario tool)
export const valueChanges = (script, stepBars) => {
  const { curves, end } = compile(script)
  const changes = []
  for (const [cc, curve] of curves) {
    let last
    for (let bar = curve[0].bar; bar <= end + 1e-9; bar += stepBars) {
      const value = valueOn(curve, bar)
      if (value !== last) changes.push({ bar, cc, value })
      last = value
    }
  }
  return changes.sort((a, b) => a.bar - b.bar)
}

export const createPerformer = ({ midi, engine, onChange = () => {} }) => {
  let timer = null, compiled = null, startBar = 0, fired = 0, held = []
  const written = new Map()

  const release = () => {
    for (const press of held) midi.setAuto(press.cc, 0)
    held = []
  }
  const stop = () => {
    clearInterval(timer)
    timer = null
    release()
    onChange(null)
  }
  const tick = () => {
    const bar = engine.cycle() - startBar
    for (const [cc, curve] of compiled.curves) {
      const value = valueOn(curve, bar)
      if (value === undefined || written.get(cc) === value) continue
      written.set(cc, value)
      midi.setAuto(cc, value)
    }
    held = held.filter(press => {
      if (--press.ticks > 0) return true
      midi.setAuto(press.cc, 0)
      return false
    })
    for (; fired < compiled.presses.length && compiled.presses[fired].bar <= bar; fired++) {
      const { cc } = compiled.presses[fired]
      midi.setAuto(cc, 1)
      held.push({ cc, ticks: HOLD_TICKS })
    }
    if (bar > compiled.end && !held.length) stop()
    else onChange({ bar, end: compiled.end })
  }

  return {
    start: script => {
      if (timer) stop()
      compiled = compile(script)
      midi.resetAuto()
      written.clear()
      fired = 0
      startBar = Math.floor(engine.cycle())
      timer = setInterval(tick, TICK_MS)
      tick()
    },
    stop: () => { if (timer) stop() },
    running: () => timer !== null,
  }
}

// The Auto-perform section of the settings drawer: script select, Start / Stop (key P in the player)
export const mountAutoPerform = (container, { onStart, onStop }) => {
  const heading = Object.assign(document.createElement('h2'), { textContent: 'Auto-perform' })
  const select = document.createElement('select')
  const button = Object.assign(document.createElement('button'), { textContent: 'Start', title: 'Key P' })
  const state = Object.assign(document.createElement('output'), { textContent: '' })
  const row = document.createElement('label')
  row.append(Object.assign(document.createElement('span'), { textContent: 'Script' }), state, select)
  container.replaceChildren(heading, row, button)
  let running = false
  const toggle = () => running ? onStop() : select.value && onStart(select.value)
  button.onclick = toggle
  return {
    toggle,
    setScripts: ids => {
      select.replaceChildren(...ids.map(id => new Option(id, id)))
      button.disabled = !ids.length
      state.textContent = ids.length ? '' : 'none for this track'
    },
    show: (isRunning, text = '') => {
      running = isRunning
      button.textContent = isRunning ? 'Stop' : 'Start'
      state.textContent = text
    },
  }
}
