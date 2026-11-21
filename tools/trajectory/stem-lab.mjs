// The player's Stem Designer routes (own pages only): projects are catalogue lab entries 'stems-<name>' (catalogue.mjs);
// a project plays through /sc/load like an SC track. The selected column (the one moved last) comes from SC's state
// (designer, see sc/lib/stemlab.scd); a project that does not play is saved / copied as on disk.
//   POST /lab/stems/save      { id }              write the selection into the project file             → { file }
//   POST /lab/stems/save-as   { id, name }        copy to sc/lab/stems/<name>.stemlab.json              → { id, file }
//   POST /lab/stems/promote   { id, slot? }       draft of the column (default: the selection) → library → { ref, file }
//   POST /lab/stems/columns   { id }                      the columns as played, Mode 1 first   → { columns, select, playing }
//   POST /lab/stems/stem      { id, slot }                the column's sample and knobs (for the knob editor) → { sample, draft, controls }
//   POST /lab/stems/knob      { id, slot, key, definition }  the knob k1-k3 of the column made from the definition
//                                                         (stems/knob.mjs buildKnob); a library stem becomes a draft  → { slot, draft, mode }
//   POST /lab/stems/add       { id, stem }                the stem (sc/stems/ path) on the first free slot → { slot, mode }
//   POST /lab/stems/replace   { id, slot, stem }          another stem on that slot                       → { slot, mode }
//   POST /lab/stems/remove    { id, slot, discard? }      the column leaves, its slot is free (a draft only with discard) → { slot, mode }
// add, replace and remove change the project file (Save as keeps a copy first). A project that plays follows: a
// replace from the next bar when the slot's mixer strip fits the stem (mode 'next-bar'), else the project loads again
// (mode 'reload', a short gap; every load costs the sound server memory, so a load only where a column comes or goes).
// The panel's header symbols (sc/ui/index.html) post add, remove and promote here. Replace is the stem drawer of the
// Live page, opened by a click on a stem's title.
import path from 'path'
import { find } from './catalogue.mjs'
import { buildKnob } from '../stems/knob.mjs'
import { addColumn, promote, readProject, removeColumn, replaceColumn, repoRoot, saveAs, saveProject, setKnob, stemOf } from '../sound-lab/stem-project.mjs'

const readBody = request => new Promise((resolve, reject) => {
  let body = ''
  request.on('data', chunk => { body += chunk })
  request.on('end', () => resolve(body))
  request.on('error', reject)
})

export const createStemLab = ({ getSc, root = repoRoot, log = console.log }) => {
  const playing = () => {
    const track = getSc()?.host.track
    return track?.startsWith('stems-') ? track.slice('stems-'.length) : null
  }
  const valuesOf = name => playing() === name ? getSc().state.state?.designer ?? null : null
  const projectOf = id => {
    const entry = find(id)
    if (entry?.lab !== 'stems') throw new Error(`no Stem Designer project '${id}'`)
    return entry.project
  }
  const relative = file => file && path.relative(root, file)

  const follow = async (name, change) => {
    if (playing() !== name) return 'file'
    if (change.replace) {
      const result = await getSc().swap(change.slot, change.replace)
      if (result.live) return 'next-bar'
    }
    await getSc().load('stems-' + name)
    return 'reload'
  }

  const handle = async (request, response, url, fromOwnPage) => {
    const json = (status, body) =>
      response.writeHead(status, { 'Content-Type': 'application/json' }).end(JSON.stringify(body))
    if (request.method !== 'POST' || !fromOwnPage(request)) return response.writeHead(403).end('forbidden')
    try {
      const body = JSON.parse(await readBody(request) || '{}')
      const name = projectOf(body.id)
      const route = url.pathname.slice('/lab/stems/'.length)
      if (route === 'save') return json(200, { file: relative(saveProject(name, valuesOf(name), root)) })
      if (route === 'save-as') {
        const file = saveAs(name, body.name, valuesOf(name), root)
        return json(200, { id: 'stems-' + body.name, file: relative(file) })
      }
      if (route === 'promote') {
        const slot = body.slot ?? valuesOf(name)?.select
        if (!slot) throw new Error('no column selected: move a control of the column first')
        const result = promote(name, slot, root)
        await follow(name, {})
        return json(200, { ref: result.ref, file: relative(result.file) })
      }
      if (route === 'columns') {
        const project = readProject(name, root)
        return json(200, { columns: project.columns, select: valuesOf(name)?.select ?? project.select,
          playing: playing() === name })
      }
      if (route === 'stem') {
        const { stem, draft } = stemOf(name, body.slot, root)
        return json(200, { sample: stem.sample.name, draft, controls: stem.controls })
      }
      if (route === 'knob') {
        const result = setKnob(name, body.slot, body.key, buildKnob(body.key, body.definition ?? {}, root), root)
        return json(200, { ...result, mode: await follow(name, {}) })
      }
      if (route === 'add') {
        const { slot } = addColumn(name, body.stem, body.slot, root)
        return json(200, { slot, mode: await follow(name, {}) })
      }
      if (route === 'replace') {
        const { slot } = replaceColumn(name, body.slot, body.stem, root)
        return json(200, { slot, mode: await follow(name, { slot, replace: body.stem }) })
      }
      if (route === 'remove') {
        const { slot } = removeColumn(name, body.slot, root, { discard: body.discard === true })
        return json(200, { slot, mode: await follow(name, {}) })
      }
      return response.writeHead(404).end('not found')
    } catch (error) {
      return json(400, { error: error.message })
    }
  }

  return { handle }
}
