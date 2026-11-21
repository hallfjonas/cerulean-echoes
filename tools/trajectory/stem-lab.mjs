// The player's Stem Designer routes (own pages only): projects are catalogue lab entries 'stems-<name>' (catalogue.mjs);
// a project plays through /sc/load like an SC track. The selected column (the one moved last) comes from SC's state
// (designer, see sc/lib/stemlab.scd); a project that does not play is saved / copied as on disk.
//   POST /lab/stems/save      { id }              write the selection into the project file             → { file }
//   POST /lab/stems/save-as   { id, name }        copy to sc/lab/stems/<name>.stemlab.json              → { id, file }
//   POST /lab/stems/promote   { id, slot? }       draft of the column (default: the selection) → library → { ref, file }
// The LC's Promote button (column 8, button 2) arrives as onPromote(slot) from sc-link.mjs.
import path from 'path'
import { find } from './catalogue.mjs'
import { promote, repoRoot, saveAs, saveProject } from '../sound-lab/stem-project.mjs'

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

  const onPromote = slot => {
    const name = playing()
    if (!name) return
    try { log('Stem Designer: promoted ' + relative(promote(name, slot, root).file)) } catch (error) {
      log('Stem Designer: promote failed: ' + error.message)
    }
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
        return json(200, { ref: result.ref, file: relative(result.file) })
      }
      return response.writeHead(404).end('not found')
    } catch (error) {
      return json(400, { error: error.message })
    }
  }

  return { handle, onPromote }
}
