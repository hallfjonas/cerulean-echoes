// The player's stem drawer (stem tracks): a column selection (selection.mjs, kind 'column') opens it. It lists the
// library stems (GET /stems) with filters for role (preset to the column's role, "any" shows every role), genre,
// energy and tag, and marks the stem that plays
// and the one in the track file. A pick swaps it in (POST /swap: from the next bar, or the track loads again with it,
// a short gap). Revert and Save as act on the whole track (stem-swap.mjs); the track file never changes.
// A Stem Designer project (selection field lab: true) uses the same drawer: Replace on a column, or Add (field adding: true on a free slot,
// every role) from the controllers; a pick changes the project file and plays from the next bar or loads it again
// (stem-lab.mjs). There is no Revert or Save as: the sidebar's Save as copies the project.
import { askText, toast } from './toast.mjs'

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
const roleOf = (all, ref) => all.find(version => version.file === ref)?.meta.role ?? null
const versionsOf = index => index.stems.flatMap(stem => stem.versions)

// onSaved({ id, file }) after Save as wrote a new track
export const mountStemDrawer = ({ selection, onSaved = () => {} }) => {
  const panel = el('aside', { id: 'stemDrawer', hidden: true })
  document.body.append(panel)
  let current = null, message = ''
  const filters = { role: '', genre: '', energy: '', tag: '' }

  let filteredColumn = null
  const say = text => {
    message = text
    if (text.startsWith('Error: ')) toast(text.slice(7), { kind: 'error' })
  }
  const reselect = stem => selection.select({ ...current, stem })

  const render = (state, versions, all) => {
    const slot = state.slots[current.slot]
    const lab = !!current.lab
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
        el('button', { className: version.file === slot.stem ? 'on' : '', disabled: !state.playing && !lab,
          onclick: () => pick(version) }, version.name),
        el('div', { className: 'meta', textContent: meta.filter(Boolean).join(' · ') }),
        el('div', { className: 'about', textContent: version.about })))
    }
    if (!versions.length) list.append(el('li', { textContent: 'No stem matches.' }))
    panel.replaceChildren(
      el('button', { className: 'close', title: 'Close', onclick: () => selection.clear() }, '×'),
      el('h2', {}, current.adding ? `Add a stem on ${current.slot}` : `Column ${current.slot} · ${slot.role ?? 'draft'}`),
      el('div', { className: 'row' }, choice('Role', 'role', [...new Set(all.map(v => v.meta.role))].sort()),
        choice('Genre', 'genre', [...new Set(all.flatMap(v => v.meta.genres))].sort()),
        choice('Energy', 'energy', [1, 2, 3, 4, 5]), choice('Tag', 'tag', [...new Set(all.flatMap(v => v.meta.tags))].sort())),
      list,
      ...(lab ? [] : [el('div', { className: 'row' },
        el('button', { disabled: !state.playing, onclick: revert, title: 'Put the file\'s stems back' }, 'Revert'),
        el('button', { onclick: saveAs, title: 'Write a new track file with the stems that play' }, 'Save as …'))]),
      el('output', { textContent: message || (lab ? 'Pick a stem: the project file changes.' : state.playing
        ? 'Pick a stem: it plays from the next bar.' : 'Press Play to swap; the list shows the file.') }))
  }

  const show = async () => {
    try {
      const everything = versionsOf(await getJson('stems'))
      const state = current.lab ? await labState(everything) : await getJson('swap?track=' + encodeURIComponent(current.track))
      const role = state.slots[current.slot]?.role
      if (!role && !current.lab) throw new Error(`slot ${current.slot} holds no stem`)
      const columnKey = `${current.track}/${current.slot}`
      if (filteredColumn !== columnKey) {
        filteredColumn = columnKey
        filters.role = role ?? ''
      }
      const query = new URLSearchParams(Object.entries(filters).filter(([, v]) => v))
      const found = await getJson('stems?' + query)
      render(state, versionsOf(found), everything)
    } catch (error) {
      panel.replaceChildren(el('button', { className: 'close', onclick: () => selection.clear() }, '×'),
        el('output', { textContent: 'Error: ' + error.message }))
    }
  }

  const labState = async everything => {
    const { columns, playing } = await post('lab/stems/columns', { id: current.track })
    const slots = Object.fromEntries(Object.entries(columns).map(([slot, ref]) =>
      [slot, { stem: ref, role: roleOf(everything, ref), file: ref }]))
    if (current.adding) slots[current.slot] = { stem: null, role: null, file: null }
    return { playing, slots }
  }

  const pickLab = async version => {
    const adding = !!current.adding
    const result = await post(`lab/stems/${adding ? 'add' : 'replace'}`,
      { id: current.track, slot: current.slot, stem: version.file })
    say({ 'next-bar': `${version.name} plays from the next bar.`, reload: `${version.name}: the project loaded again (a short gap).`,
      file: `${version.name} is in the project file.` }[result.mode])
    if (adding) selection.clear()
    else reselect(version.file)
  }

  const pick = async version => {
    say('swapping …')
    show()
    try {
      if (current.lab) return await pickLab(version)
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
    const name = await askText('Name of the new track (NNN-name). Empty: the next free -v2, -v3 …', '')
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
