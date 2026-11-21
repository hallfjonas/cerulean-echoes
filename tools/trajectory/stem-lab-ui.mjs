// The player's Stems & Tracks section (sidebar, Labs / Stems & Tracks). With a Stem Designer project picked: Load plays
// it from its file (as Play); Save writes the selected column into it; Save as copies it under a new name; Export track
// writes it as a stem track (sc/tracks/, the Live page lists it). New from track makes a project of a stem track's
// stems, each one in the lab (a column), in the backing (plays along) or off, and opens it. Add, Replace, Remove,
// Promote and the knob editor are in the controller panel (sc/ui/index.html); the page help explains them.
import { ICONS, iconButton } from './sidebar-icons.mjs'
import { askText, toast } from './toast.mjs'

const CHOICES = [['lab', 'Lab'], ['backing', 'Backing'], ['off', 'Off']]

export const mountStemLab = ({ section, selected, play, refresh }) => {
  section.innerHTML = '<h2>Stems &amp; Tracks</h2>' +
    '<details data-part="fromTrack"><summary>New from track</summary>' +
    '<label>Track <select data-field="track"></select></label>' +
    '<label>All stems in lab <input type="checkbox" data-field="all" checked></label>' +
    '<div data-field="stems"></div>' +
    '<label>Project name <input data-field="name"></label>' +
    '<div class="row"><button data-act="create">Create</button></div></details>' +
    '<div data-part="project"><div class="row">' +
    iconButton('load', 'Load', ICONS.load) + iconButton('save', 'Save', ICONS.save) +
    iconButton('saveAs', 'Save as', ICONS.saveAs) + iconButton('exportTrack', 'Export track', ICONS.export) +
    '</div></div>'
  const fail = error => toast(error.message, { kind: 'error' })
  const field = name => section.querySelector(`[data-field="${name}"]`)
  const post = async (route, body) => {
    const response = await fetch('lab/stems/' + route,
      { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
    const result = await response.json().catch(() => ({}))
    if (!response.ok) throw new Error(result.error ?? `${route}: ${response.status}`)
    return result
  }

  let tracks = []
  const choice = {}
  const setChoice = (slot, value) => {
    choice[slot] = value
    for (const button of section.querySelectorAll(`[data-slot="${slot}"] button`)) {
      button.setAttribute('aria-pressed', String(button.dataset.choice === value))
    }
  }
  const showStems = async () => {
    const track = tracks.find(entry => entry.track === field('track').value)
    const all = field('all').checked ? 'lab' : 'off'
    for (const slot of Object.keys(choice)) delete choice[slot]
    field('stems').replaceChildren(...Object.entries(track?.slots ?? {}).map(([slot, ref]) => {
      const row = document.createElement('div')
      row.dataset.slot = slot
      row.append(Object.assign(document.createElement('span'), { textContent: `${slot} ${ref.split('/')[0]}` }))
      const group = Object.assign(document.createElement('div'), { className: 'seg', role: 'radiogroup' })
      for (const [value, text] of CHOICES) {
        const button = Object.assign(document.createElement('button'), { textContent: text })
        button.dataset.choice = value
        group.append(button)
      }
      row.append(group)
      return row
    }))
    for (const slot of Object.keys(track?.slots ?? {})) setChoice(slot, all)
    field('name').value = track ? (await post('default-name', { track: track.track })).name : ''
  }
  const loadTracks = async () => {
    tracks = (await post('tracks', {})).tracks
    field('track').replaceChildren(...tracks.map(({ track, about }) => Object.assign(new Option(track, track),
      { title: about })))
    await showStems()
  }
  field('track').addEventListener('change', () => showStems().catch(fail))
  field('all').addEventListener('change', () => {
    for (const slot of Object.keys(choice)) setChoice(slot, field('all').checked ? 'lab' : 'off')
  })
  section.querySelector('[data-part="fromTrack"]').addEventListener('toggle', event => {
    if (event.target.open && !tracks.length) loadTracks().catch(fail)
  })

  const slotsWith = value => Object.keys(choice).filter(slot => choice[slot] === value)
  const actions = {
    load: async () => { await play(); return 'loaded ' + selected().project },
    save: async () => 'saved ' + (await post('save', { id: selected().id })).file,
    saveAs: async () => {
      const name = await askText('Save as (lowercase words joined by "-"):', selected().project + '-2')
      if (!name) return ''
      const { id, file } = await post('save-as', { id: selected().id, name })
      await refresh(id)
      return 'wrote ' + file + ' (picked: Load plays it)'
    },
    exportTrack: async () => {
      const { name: suggested, drafts } = await post('export-track', { id: selected().id })
      if (drafts.length) {
        const answer = await toast(`Changed stems on ${drafts.join(', ')} are not in the library yet. A track can only ` +
          'hold library stems.', { kind: 'ask', actions: ['Export them to the library and continue'] })
        if (!answer) return ''
      }
      const name = await askText('Track name (three digits, a dash, lowercase words):', suggested)
      if (!name) return ''
      const { file } = await post('export-track', { id: selected().id, name, promote: true })
      await refresh(selected().id)
      return 'wrote ' + file + ' (the Live page lists it)'
    },
    create: async () => {
      const { id, file } = await post('from-track', { track: field('track').value, name: field('name').value.trim(),
        columns: slotsWith('lab'), backing: slotsWith('backing') })
      await refresh(id)
      await play()
      await showStems()
      return 'wrote ' + file + ', playing it'
    },
  }
  section.addEventListener('click', async event => {
    const pick = event.target.closest('[data-slot] button')
    if (pick) return setChoice(pick.closest('[data-slot]').dataset.slot, pick.dataset.choice)
    const act = event.target.closest('[data-act]')?.dataset.act
    if (!act) return
    try {
      const message = await actions[act]()
      if (message) toast(message)
    } catch (error) {
      fail(error)
    }
  })
  return { show: entry => { section.querySelector('[data-part="project"]').hidden = entry?.lab !== 'stems' } }
}
