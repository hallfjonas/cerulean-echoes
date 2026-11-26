// The Space Analyzer routes (own pages only, POST): where a stem track's frequency and time space is free or crowded.
//   POST /lab/space/tracks {}                                    the stem tracks with their stems → { tracks }
//        a track: { track, tempo, about, slots: [{ slot, ref, name, role, patterns, controls }] } (space-render.mjs)
//   POST /lab/space/stem   { track, slot, setting, bars, force? } one stem rendered alone at the setting, measured
//        → { footprint: { cells, bands, cellsPerBar, l, r }, cached }  l, r = base64 bytes of half a dB (space-analysis.mjs)
// Renders run one at a time, in the order they arrive: a render is a heavy job on a shared machine.
import { listStemTracks } from '../sound-lab/stem-project.mjs'
import { repoRoot } from '../stems/check-stems.mjs'
import { renderStem, trackSlots } from './space-render.mjs'

const readBody = request => new Promise((resolve, reject) => {
  let body = ''
  request.on('data', chunk => { body += chunk })
  request.on('end', () => resolve(body))
  request.on('error', reject)
})

export const createSpaceLab = ({ root = repoRoot } = {}) => {
  let queue = Promise.resolve()
  const inTurn = work => {
    const job = queue.then(work)
    queue = job.catch(() => {})
    return job
  }

  const handle = async (request, response, url, fromOwnPage) => {
    const json = (status, body) =>
      response.writeHead(status, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }).end(JSON.stringify(body))
    if (request.method !== 'POST' || !fromOwnPage(request)) return response.writeHead(403).end('forbidden')
    try {
      const body = JSON.parse(await readBody(request) || '{}')
      const route = url.pathname.slice('/lab/space/'.length)
      if (route === 'tracks') {
        const tracks = listStemTracks(root).flatMap(({ track }) => {
          try { return [trackSlots(track, root)] } catch { return [] }
        })
        return json(200, { tracks })
      }
      if (route === 'stem') {
        const { track, slot, setting, bars, force } = body
        return json(200, await inTurn(() => renderStem({ track, slot, setting, bars: Number(bars), force: Boolean(force), root })))
      }
      return json(404, { error: `no route ${route}` })
    } catch (error) {
      return json(400, { error: error.message })
    }
  }
  return { handle }
}
