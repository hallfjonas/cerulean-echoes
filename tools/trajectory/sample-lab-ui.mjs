// The player's Sample Designer section (sidebar): shown while a Sample Designer project is picked under Lab.
// Load plays the project from its file (as Play); Save writes the playing values into it; Save as copies it (with the
// playing values) under a new name; Export writes the library sound and its WAV; Shape renders one hit and draws it
// (waveform, envelope, spectrum, spectrogram: sample-shape-ui.mjs) (server: sample-lab.mjs).
export const mountSampleLab = ({ section, selected, play, refresh, shapePanel }) => {
  section.innerHTML = '<h2>Sample Designer</h2><div class="row"><button data-act="load">Load</button>' +
    '<button data-act="save" title="Also the LC: column 8, button 2">Save</button>' +
    '<button data-act="saveAs">Save as</button><button data-act="export">Export</button>' +
    '<button data-act="shape" title="Render one hit and show its waveform, envelope and spectrum">Shape</button>' +
    '</div><output></output>'
  const out = section.querySelector('output')
  const post = async (route, body) => {
    const response = await fetch('lab/sample/' + route,
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
    export: async () => {
      const sound = prompt('Sound name in sc/sounds/ (camelCase):',
        selected().project.replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase()))
      if (!sound) return ''
      out.textContent = 'exporting (renders the WAV) …'
      const { sound: file, wav } = await post('export', { id: selected().id, sound })
      return 'wrote ' + [file, wav].filter(Boolean).join(', ')
    },
    shape: async () => {
      const name = selected().project
      shapePanel.busy(name)
      try { shapePanel.show(await post('shape', { id: selected().id }), name) } catch (error) {
        shapePanel.error(error.message)
        throw error
      }
      return 'shape of ' + name
    },
  }
  section.addEventListener('click', async event => {
    const act = event.target.dataset?.act
    if (!act) return
    try { out.textContent = await actions[act]() } catch (error) { out.textContent = 'Error: ' + error.message }
  })
  return { show: entry => { section.hidden = entry?.lab !== 'sample' } }
}
