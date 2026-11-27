// Which library stems fit a stem track: sc/tools/stem-fit.scd plays every library stem on the track's slots offline
// (its own sclang, no sound) and names the ones whose code fails in the track's frame. The answer is kept while the
// server runs, per frame file and library state (any change under sc/stems or sc/lib checks again); the stem drawer
// greys the misfits out (stem-drawer.mjs).
//   GET /stems/fit?track=<id>   (a stem track, or a Stem Designer project: its context track) → { misfits: { ref:
//                               reason } }, after the check (a few seconds the first time); { misfits: {}, error }
//                               when it could not run
import { spawn } from 'child_process'
import crypto from 'crypto'
import fs from 'fs'
import path from 'path'
import { readProject } from '../sound-lab/stem-project.mjs'

const newest = dir => fs.readdirSync(dir, { withFileTypes: true }).reduce((latest, entry) => {
  const file = path.join(dir, entry.name)
  return Math.max(latest, entry.isDirectory() ? newest(file) : fs.statSync(file).mtimeMs)
}, 0)

// find(id) → catalogue entry (catalogue.mjs); sclang: path or null (sc-link.mjs findSclang)
export const createStemFit = ({ repo, find, sclang }) => {
  const checks = new Map()   // key → Promise<{ misfits }>
  const script = path.join(repo, 'sc', 'tools', 'stem-fit.scd')

  const trackFileOf = id => {
    const entry = find(id)
    if (entry?.lab === 'stems') return trackFileOf(readProject(entry.project, repo).context?.track)
    if (!entry?.stems) throw Object.assign(new Error(`no stem track '${id}'`), { status: 404 })
    return entry.path
  }
  const keyOf = file => {
    const frame = path.join(path.dirname(file), JSON.parse(fs.readFileSync(file, 'utf8')).frame)
    const library = ['stems', 'lib'].map(dir => newest(path.join(repo, 'sc', dir))).join(':')
    return crypto.createHash('sha1').update(fs.readFileSync(frame)).update(library).digest('hex')
  }
  const check = file => new Promise((resolve, reject) => {
    if (!sclang) return reject(new Error('SuperCollider is not installed (no sclang found)'))
    const child = spawn(sclang, [script, file], { stdio: ['ignore', 'pipe', 'pipe'] })
    let out = ''
    child.stdout.on('data', chunk => { out += chunk })
    child.on('error', reject)
    child.on('exit', code => {
      if (code !== 0) return reject(new Error(`the fit check ended with code ${code}`))
      const misfits = {}
      for (const line of out.split('\n')) {
        const m = line.match(/^MISFIT \S+ (\S+) \| (.*)$/)
        if (m) misfits[m[1]] = m[2]
      }
      resolve({ misfits })
    })
  })

  const fitOf = async id => {
    const file = trackFileOf(id), key = keyOf(file)
    if (!checks.has(key)) checks.set(key, check(file).catch(error => { checks.delete(key); throw error }))
    return checks.get(key)
  }

  const handle = async (request, response, url) => {
    const json = (status, body) => response
      .writeHead(status, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' }).end(JSON.stringify(body))
    try {
      return json(200, await fitOf(url.searchParams.get('track')))
    } catch (error) {
      if (error.status) return json(error.status, { error: error.message })
      return json(200, { misfits: {}, error: error.message })
    }
  }
  return { fitOf, handle }
}
