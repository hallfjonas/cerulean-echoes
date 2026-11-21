// The player's Sample Designer routes (own pages only): projects are catalogue lab entries 'sample-<name>'
// (catalogue.mjs); a project plays through /sc/load like an SC track. Values of the project that plays come from SC's
// state (designer, see sc/lib/designer.scd); a project that does not play is saved / copied / exported as on disk.
//   POST /lab/sample/save     { id }              write the playing values into the project file      → { file }
//   POST /lab/sample/save-as  { id, name }        copy to sc/lab/samples/<name>.sample.json           → { id, file }
//   POST /lab/sample/export   { id, sound? }      sc/sounds/<sound>.scd + samples/sound-lab/<sound>.wav
//                                                 → { sound, wav }
// The LC's Save button (column 8, button 2) arrives as onSave(values) from sc-link.mjs.
import path from 'path'
import { find } from './catalogue.mjs'
import { findSclang } from './sc-link.mjs'
import { exportSound, repoRoot, saveAs, saveProject } from '../sound-lab/sample-project.mjs'

const readBody = request => new Promise((resolve, reject) => {
  let body = ''
  request.on('data', chunk => { body += chunk })
  request.on('end', () => resolve(body))
  request.on('error', reject)
})

export const createSampleLab = ({ getSc, root = repoRoot, sclang = findSclang(), log = console.log }) => {
  const playing = () => {
    const track = getSc()?.host.track
    return track?.startsWith('sample-') ? track.slice('sample-'.length) : null
  }
  const valuesOf = name => playing() === name ? getSc().state.state?.designer ?? null : null
  const projectOf = id => {
    const entry = find(id)
    if (entry?.lab !== 'sample') throw new Error(`no Sample Designer project '${id}'`)
    return entry.project
  }
  const relative = file => file && path.relative(root, file)

  const onSave = values => {
    const name = playing()
    if (!name) return
    try { log('Sample Designer: saved ' + relative(saveProject(name, values, root))) } catch (error) {
      log('Sample Designer: save failed: ' + error.message)
    }
  }

  const handle = async (request, response, url, fromOwnPage) => {
    const json = (status, body) =>
      response.writeHead(status, { 'Content-Type': 'application/json' }).end(JSON.stringify(body))
    if (request.method !== 'POST' || !fromOwnPage(request)) return response.writeHead(403).end('forbidden')
    try {
      const body = JSON.parse(await readBody(request) || '{}')
      const name = projectOf(body.id)
      const route = url.pathname.slice('/lab/sample/'.length)
      if (route === 'save') return json(200, { file: relative(saveProject(name, valuesOf(name), root)) })
      if (route === 'save-as') {
        const file = saveAs(name, body.name, valuesOf(name), root)
        return json(200, { id: 'sample-' + body.name, file: relative(file) })
      }
      if (route === 'export') {
        const out = await exportSound(name,
          { ...body.sound && { soundName: body.sound }, values: valuesOf(name), sclang, root })
        return json(200, { sound: relative(out.sound), wav: relative(out.wav) })
      }
      return response.writeHead(404).end('not found')
    } catch (error) {
      return json(400, { error: error.message })
    }
  }

  return { handle, onSave }
}
