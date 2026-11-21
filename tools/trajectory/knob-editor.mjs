// The player's knob editor (Stem Designer): a click on a knob's label in the controller panel opens it for that knob of
// the stem on that slot. It changes what the knob drives: a parameter of the stem's sound (or Space / Echo / Pan), the
// bounds the knob moves it between, the curve, the knob's default position and its name. A preset (sc/stems/knobs.json) fills the
// fields. Apply writes the knob into a draft of the project (a library stem becomes a draft, Promote in the panel's
// header exports it) and loads the project again (server: stem-lab.mjs, stems/knob.mjs).
const el = (tag, props = {}, ...children) => {
  const element = Object.assign(document.createElement(tag), props)
  element.append(...children)
  return element
}
const getJson = async url => {
  const response = await fetch(url, { cache: 'no-store' })
  if (!response.ok) throw new Error(await response.text())
  return response.json()
}
const post = async (route, body) => {
  const response = await fetch(route, { method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body) })
  const result = await response.json().catch(() => ({}))
  if (!response.ok) throw new Error(result.error ?? `${route}: ${response.status}`)
  return result
}
const CONVENTIONAL = { k1: { label: 'Brightness', param: 'bright' }, k2: { label: 'Space', param: 'space' } }
const capital = text => text.replace(/^[a-z]/, letter => letter.toUpperCase())
const KNOB_NAMES = { k1: 'knob 1 (top row)', k2: 'knob 2 (middle row)', k3: 'knob 3 (bottom row)' }

export const mountKnobEditor = ({ onOpen = () => {} }) => {
  const panel = el('aside', { id: 'knobEditor', hidden: true })
  document.body.append(panel)

  const close = () => {
    panel.hidden = true
    document.body.classList.remove('drawer-open')
  }

  const open = async ({ track, slot, key }) => {
    onOpen()
    panel.hidden = false
    document.body.classList.add('drawer-open')
    panel.replaceChildren(el('output', { textContent: 'loading …' }))
    try {
      const stem = await post('lab/stems/stem', { id: track, slot })
      const [params, presets] = await Promise.all([getJson('sound-params?sample=' + encodeURIComponent(stem.sample)),
        getJson('knobs')])
      render({ track, slot, key, stem, params, presets })
    } catch (error) {
      panel.replaceChildren(el('button', { className: 'close', onclick: close }, '×'),
        el('output', { textContent: 'Error: ' + error.message }))
    }
  }

  const render = ({ track, slot, key, stem, params, presets }) => {
    const knob = stem.controls[key]
    const driven = !!knob.param
    const field = (label, input, wide = false) => el('label', { className: wide ? 'wide' : '' }, el('span', { textContent: label }), input)
    const number = value => el('input', { type: 'number', step: 'any', value: value ?? '' })

    const param = el('select')
    const withBounds = params.filter(p => p.range), other = params.filter(p => !p.range)
    for (const [label, list] of [['Parameters with bounds', withBounds], ['Other parameters', other]]) {
      if (!list.length) continue
      const group = el('optgroup', { label })
      group.append(...list.map(p => new Option(`${p.label} (${p.param})`, p.param)))
      param.append(group)
    }
    param.value = driven ? knob.param : withBounds[0]?.param ?? params[0].param
    const preset = el('select', {}, new Option('none', ''),
      ...Object.entries(presets).map(([id, p]) => new Option(p.label, id)))
    const label = el('input', { value: knob.label, maxLength: 20 })
    const about = el('input', { value: knob.about, maxLength: 60 })
    const low = number(knob.range?.[0]), high = number(knob.range?.[1])
    const curve = el('select', {}, new Option('linear', 'lin'), new Option('exponential', 'exp'))
    curve.value = knob.curve ?? 'lin'
    const start = el('input', { type: 'range', min: 0, max: 1, step: 0.01, value: knob.default ?? 0 })
    const startText = el('span', { textContent: Number(start.value).toFixed(2) })
    start.oninput = () => { startText.textContent = Number(start.value).toFixed(2) }
    const hint = el('div', { className: 'hint' })
    const out = el('output', { textContent: driven ? '' : 'This knob is driven by the stem\'s own code. Applying replaces that with the parameter below.' })

    const showHint = () => {
      const p = params.find(entry => entry.param === param.value)
      hint.textContent = p?.range ? `Sound range ${p.range[0]} to ${p.range[1]}${p.default !== null ? ', default ' + p.default : ''}.`
        : 'This parameter declares no range: pick the bounds by ear.'
    }
    const fillFromParam = () => {
      const p = params.find(entry => entry.param === param.value)
      const convention = CONVENTIONAL[key]
      if (convention && label.value === convention.label && param.value !== convention.param) label.value = capital(p?.label ?? param.value)
      if (p?.range) { [low.value, high.value] = p.range; curve.value = p.curve }
      if (p?.range && p.default !== null) {
        const [a, b] = p.range
        start.value = Math.min(1, Math.max(0, (p.default - a) / (b - a)))
        start.oninput()
      }
      showHint()
    }
    param.onchange = fillFromParam
    preset.onchange = () => {
      const p = presets[preset.value]
      if (!p) return
      param.value = p.param
      label.value = p.label
      about.value = p.about
      ;[low.value, high.value] = p.range
      curve.value = p.curve ?? 'lin'
      start.value = p.default ?? 0
      start.oninput()
      showHint()
    }
    if (!driven) fillFromParam()
    else showHint()

    const apply = async () => {
      out.textContent = 'applying: the project loads again …'
      try {
        const definition = { label: label.value, about: about.value, param: param.value,
          range: [Number(low.value), Number(high.value)], curve: curve.value, default: Number(start.value) }
        await post('lab/stems/knob', { id: track, slot, key, definition })
        out.textContent = stem.draft ? 'Changed.' : 'Changed: the column is a draft now (Promote exports it).'
      } catch (error) {
        out.textContent = 'Error: ' + error.message
      }
    }

    panel.replaceChildren(
      el('button', { className: 'close', title: 'Close', onclick: close }, '×'),
      el('h2', {}, `Column ${slot} · ${KNOB_NAMES[key]} · ${knob.label}`),
      el('p', { className: 'hint' }, 'Choose what this knob controls and how far it turns it. The name on the controller '
        + 'follows. Nothing is saved until you press Apply.'),
      field('Name on the controller', label, true), field('Short description', about, true),
      field('Start from a preset', preset, true), field('Controls', param, true), hint,
      field('Value at knob 0', low), field('Value at knob 1', high), field('Curve', curve),
      field('Knob starts at', el('span', {}, start, ' ', startText), true),
      el('div', { className: 'row' }, el('button', { onclick: apply }, 'Apply'), el('button', { onclick: close }, 'Cancel')),
      out)
  }

  return { open, close }
}
