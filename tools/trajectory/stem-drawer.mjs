// The player's stem drawer (stem tracks): a column selection (selection.mjs, kind 'column') opens it. It lists the
// library stems of the column's role (GET /stems) with filters for genre, energy and tag, and marks the stem that plays
// and the one in the track file. A pick swaps it in (POST /swap: from the next bar, or the track loads again with it,
// a short gap). Revert and Save as act on the whole track (stem-swap.mjs); the track file never changes.
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
const versionsOf = index => index.stems.flatMap(stem => stem.versions)

// onSaved({ id, file }) after Save as wrote a new track
export const mountStemDrawer = ({ selection, onSaved = () => {} }) => {
  const panel = el('aside', { id: 'stemDrawer', hidden: true })
  document.body.append(panel)
  let current = null, message = ''
  const filters = { genre: '', energy: '', tag: '' }

  const say = text => { message = text }
  const reselect = stem => selection.select({ ...current, stem })

  const render = (state, versions, all) => {
    const slot = state.slots[current.slot]
    const choice = (label, key, values) => {
      const select = el('select', { title: label }, new Option(`${label}: any`, ''),
        ...values.map(value => new Option(String(value), String(value))))
      select.value = filters[key]
      select.onchange = () => { filters[key] = select.value; show() }
      return select
    }
    const list = el('ul')
    for (const version of versions) {
      const marks = [version.file === slot.stem && 'plays', version.file === slot.file && 'in the file'].filter(Boolean)
      const meta = [`energy ${version.meta.energy}`, version.meta.genres.join(', '), version.meta.tags.join(', '), ...marks]
      list.append(el('li', {},
        el('button', { className: version.file === slot.stem ? 'on' : '', disabled: !state.playing,
          onclick: () => pick(version) }, version.name),
        el('div', { className: 'meta', textContent: meta.filter(Boolean).join(' · ') }),
        el('div', { className: 'about', textContent: version.about })))
    }
    if (!versions.length) list.append(el('li', { textContent: 'No stem matches.' }))
    panel.replaceChildren(
      el('button', { className: 'close', title: 'Close', onclick: () => selection.clear() }, '×'),
      el('h2', {}, `Column ${current.slot} · ${slot.role}`),
      el('div', { className: 'row' }, choice('Genre', 'genre', [...new Set(all.flatMap(v => v.meta.genres))].sort()),
        choice('Energy', 'energy', [1, 2, 3, 4, 5]), choice('Tag', 'tag', [...new Set(all.flatMap(v => v.meta.tags))].sort())),
      list,
      el('div', { className: 'row' },
        el('button', { disabled: !state.playing, onclick: revert, title: 'Put the file\'s stems back' }, 'Revert'),
        el('button', { onclick: saveAs, title: 'Write a new track file with the stems that play' }, 'Save as …')),
      el('output', { textContent: message || (state.playing ? 'Pick a stem: it plays from the next bar.'
        : 'Press Play to swap; the list shows the file.') }))
  }

  const show = async () => {
    try {
      const state = await getJson('swap?track=' + encodeURIComponent(current.track))
      const role = state.slots[current.slot]?.role
      if (!role) throw new Error(`slot ${current.slot} holds no stem`)
      const query = new URLSearchParams({ role, ...Object.fromEntries(Object.entries(filters).filter(([, v]) => v)) })
      const [found, all] = await Promise.all([getJson('stems?' + query), getJson('stems?role=' + encodeURIComponent(role))])
      render(state, versionsOf(found), versionsOf(all))
    } catch (error) {
      panel.replaceChildren(el('button', { className: 'close', onclick: () => selection.clear() }, '×'),
        el('output', { textContent: 'Error: ' + error.message }))
    }
  }

  const pick = async version => {
    say('swapping …')
    show()
    try {
      const result = await post('swap', { track: current.track, slot: current.slot, stem: version.file })
      say(result.mode === 'reload'
        ? `${version.name}: the track loaded again with it (a short gap: ${result.reason}).`
        : `${version.name} plays from the next bar.`)
      reselect(version.file)
    } catch (error) {
      say('Error: ' + error.message)
      show()
    }
  }

  async function revert () {
    try {
      const result = await post('swap/revert', { track: current.track })
      say({ none: 'Nothing to revert.', reload: 'The file\'s stems: the track loaded again (a short gap).' }[result.mode]
        ?? 'The file\'s stems play from the next bar.')
      reselect(result.slots[current.slot])
    } catch (error) {
      say('Error: ' + error.message)
      show()
    }
  }

  async function saveAs () {
    const name = prompt('Name of the new track (NNN-name). Empty: the next free -v2, -v3 …', '')
    if (name === null) return
    try {
      const result = await post('track/save-as', { track: current.track, name: name.trim() })
      say(`Saved as ${result.file}: pick ${result.id} in the track list.`)
      onSaved(result)
    } catch (error) {
      say('Error: ' + error.message)
    }
    show()
  }

  selection.on('column', item => {
    if (!item) {
      current = null
      panel.hidden = true
      document.body.classList.remove('drawer-open')
      return
    }
    if (current?.track !== item.track || current?.slot !== item.slot) say('')
    current = item
    panel.hidden = false
    document.body.classList.add('drawer-open')
    show()
  })
}
