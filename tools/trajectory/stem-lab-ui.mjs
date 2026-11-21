// The player's Stem Designer section (sidebar): shown while a Stem Designer project is picked under Lab.
// Load plays the project from its file (as Play); Save writes the selected column into it; Save as copies it under a
// new name; Promote writes the selected column's draft into the stem library (server: stem-lab.mjs).
export const mountStemLab = ({ section, selected, play, refresh }) => {
  section.innerHTML = '<h2>Stem Designer</h2><div class="row"><button data-act="load">Load</button>' +
    '<button data-act="save">Save</button><button data-act="saveAs">Save as</button>' +
    '<button data-act="promote" title="Also the LC: column 8, button 2">Promote</button></div><output></output>'
  const out = section.querySelector('output')
  const post = async (route, body) => {
    const response = await fetch('lab/stems/' + route,
      { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
    const result = await response.json().catch(() => ({}))
    if (!response.ok) throw new Error(result.error ?? `${route}: ${response.status}`)
    return result
  }
  const actions = {
    load: async () => { await play(); return 'loaded ' + selected().project },
    save: async () => 'saved ' + (await post('save', { id: selected().id })).file,
    saveAs: async () => {
      const name = prompt('Save as (lowercase words joined by "-"):', selected().project + '-2')
      if (!name) return ''
      const { id, file } = await post('save-as', { id: selected().id, name })
      await refresh(id)
      return 'wrote ' + file + ' (picked: Load plays it)'
    },
    promote: async () => {
      const { ref } = await post('promote', { id: selected().id })
      return 'new stem version ' + ref
    },
  }
  section.addEventListener('click', async event => {
    const act = event.target.dataset?.act
    if (!act) return
    try { out.textContent = await actions[act]() } catch (error) { out.textContent = 'Error: ' + error.message }
  })
  return { show: entry => { section.hidden = entry?.lab !== 'stems' } }
}
