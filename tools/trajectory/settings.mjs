// Every visual setting of the player as data: id, label, kind, default, key, tip, apply(value, context).
// kinds: 'slider' (min, max, step, show), 'toggle', 'choice' (options). A key toggles a toggle and cycles a choice.
// mountSettings builds the fields into a container from this list, restores saved values and saves every change.
import { describeWindow } from './smoothing.mjs'

export const SETTINGS = [
  { id: 'character', label: 'Hard ↔ Soft', kind: 'slider', min: 0, max: 1, step: 0.01, default: 0, key: null,
    tip: '0 = hard, sharp, wild · 1 = soft, smeared, sluggish', show: v => v.toFixed(2),
    apply: (value, { renderer }) => renderer.setCharacter(value) },
  { id: 'smoothing', label: 'Raw ↔ Smooth', kind: 'slider', min: 0, max: 1, step: 0.005, default: 0.06, key: null,
    tip: '0 = raw signals · 1 = moving average over 2^53 lines: frozen', show: describeWindow,
    apply: (value, { smoother, renderer }) => { smoother.setAmount(value); renderer.setSmoothing(value) } },
  { id: 'axes', label: 'Axes', kind: 'toggle', default: false, key: 'a', tip: 'Key A',
    apply: (value, { renderer }) => renderer.setAxes(value) },
  { id: 'labels', label: 'Labels', kind: 'toggle', default: false, key: 'l', tip: 'Key L',
    apply: (value, { renderer }) => renderer.setLabels(value) },
  { id: 'rings', label: 'Beat rings', kind: 'toggle', default: true, key: 'b', tip: 'Key B: rings from the kick on every beat',
    apply: (value, { renderer }) => renderer.setRings(value) },
  { id: 'lcFrame', label: 'LC frame', kind: 'toggle', default: true, key: 'h',
    tip: 'Key H: frame around the controller used last in the LC view / MIDI panel', apply: () => {} },
  { id: 'look', label: 'Look', kind: 'choice', options: ['deck', 'ocean', 'clean'], default: 'deck', key: 'v',
    tip: 'Key V: cycles the looks', apply: (value, { renderer }) => renderer.setLook(value) },
  // the set view of the SuperCollider MIDI panel (UI-REDESIGN.md "Set view"): four candidate views, one browser setting
  // the panel reads too; a click on the panel's label (the view's name) cycles it and the panel tells the player
  { id: 'setView', label: 'Set view', kind: 'choice', options: ['ring', 'map', 'energy', 'spectrogram'], default: 'ring', key: 'c',
    tip: 'Key C: how the box right of the spectrum shows the set so far: ring (labelled energy), map, energy area, spectrogram (SuperCollider tracks)',
    apply: value => {
      try { localStorage.setItem('ce.setView', value) } catch {}
      document.getElementById('scPanel')?.contentWindow?.postMessage({ setView: value }, location.origin)
    } },
  { id: 'widen', label: 'Pan width', kind: 'toggle', default: true, key: 'w',
    tip: 'Key W: widen the pan range the music used', apply: (value, { renderer }) => renderer.setWiden(value) },
]

const STORAGE_KEY = 'trajectory.settings'

const load = () => {
  try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) ?? {} } catch { return {} }
}

const save = values => {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(values)) } catch {}
}

const validOr = (setting, value) => {
  if (value === undefined) return setting.default
  if (setting.kind === 'toggle') return typeof value === 'boolean' ? value : setting.default
  if (setting.kind === 'choice') return setting.options.includes(value) ? value : setting.default
  return Number.isFinite(value) ? Math.min(setting.max, Math.max(setting.min, value)) : setting.default
}

const field = (setting, value, onInput) => {
  const row = document.createElement('label')
  row.title = setting.tip ?? ''
  row.dataset.setting = setting.id
  const name = Object.assign(document.createElement('span'), { textContent: setting.label })
  const input = document.createElement(setting.kind === 'choice' ? 'select' : 'input')
  const output = document.createElement('output')
  if (setting.kind === 'slider') {
    Object.assign(input, { type: 'range', min: setting.min, max: setting.max, step: setting.step, value })
    input.oninput = () => onInput(Number(input.value))
  } else if (setting.kind === 'toggle') {
    Object.assign(input, { type: 'checkbox', checked: value })
    input.onchange = () => onInput(input.checked)
  } else {
    input.replaceChildren(...setting.options.map(option => new Option(option, option)))
    input.value = value
    input.onchange = () => onInput(input.value)
  }
  row.append(name, input, output)
  return { row, input, output }
}

export const mountSettings = (container, context) => {
  const values = {}
  const stored = load()
  const fields = {}

  const set = (id, value) => {
    const setting = SETTINGS.find(entry => entry.id === id)
    values[id] = value
    const { input, output } = fields[id]
    if (setting.kind === 'toggle') input.checked = value
    else input.value = value
    output.textContent = setting.kind === 'slider' ? setting.show(value) : ''
    setting.apply(value, context)
    save(values)
  }

  for (const setting of SETTINGS) {
    values[setting.id] = validOr(setting, stored[setting.id])
    fields[setting.id] = field(setting, values[setting.id], value => set(setting.id, value))
  }
  container.replaceChildren(...SETTINGS.map(setting => fields[setting.id].row))
  for (const setting of SETTINGS) set(setting.id, values[setting.id])

  const handleKey = key => {
    const setting = SETTINGS.find(entry => entry.key === key)
    if (!setting) return false
    if (setting.kind === 'toggle') set(setting.id, !values[setting.id])
    else {
      const next = (setting.options.indexOf(values[setting.id]) + 1) % setting.options.length
      set(setting.id, setting.options[next])
    }
    return true
  }

  return {
    get: id => values[id],
    set,
    handleKey,
  }
}
