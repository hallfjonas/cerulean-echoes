// Stem swap: another library stem on a slot of the stem track SuperCollider plays. Live from the next bar when the
// slot's mixer strip fits the new stem (sc/lib/stemtrack.scd, ~ce.swapProblem), else the track is loaded again with
// the stem (a short gap, mode 'reload'). The track file never changes: Save as writes the swaps as a new track,
// Revert puts the file's stems back. A load of the track (Play) plays the file again.
//   GET  /swap?track=<id>   { track, playing, slots: { '1:1': { stem, role, file }, … } }: stem = what plays (the
//                           file's when the track does not play), file = the file's stem on that slot
//   POST /swap              { track, slot, stem } → { track, slot, stem, mode: 'next-bar' | 'reload', reason?, slots }
//                           (track must be playing; slot must hold a stem; stem = path under sc/stems/)
//   POST /swap/revert       { track } → { track, mode: 'next-bar' | 'reload' | 'none', slots }
//   POST /track/save-as     { track, name? } → 201 { id, name, file, slots }: sc/tracks/<name>/<name>.track with the
//                           slots that play (the file's when it does not play) and a copy of the frame as
//                           <name>-frame.scd; never overwrites (409). No name: <track name>-v2, -v3 … (first free)
// slots in answers: { '1:1': stem, … }. POSTs only from the player's own pages. Errors: { error } with 400/404/409/500.
import fs from 'fs'
import path from 'path'

const SLOT = /^[12]:[1-7]$/
const STEM_REF = /^[A-Za-z0-9]+\/[a-z0-9-]+\.stem$/
const TRACK_NAME = /^[0-9]{3}-[a-z0-9]+(-[a-z0-9]+)*$/
const readJson = file => JSON.parse(fs.readFileSync(file, 'utf8'))
const fail = (status, message) => Object.assign(new Error(message), { status })
const sorted = slots => Object.fromEntries(Object.entries(slots).sort(([a], [b]) => a.localeCompare(b)))
const readBody = request => new Promise((resolve, reject) => {
  let body = ''
  request.on('data', chunk => { body += chunk })
  request.on('end', () => resolve(body))
  request.on('error', reject)
})

// sc: { host: { track }, load(id, slots?), swap(slot, stem) → { live, reason? } } (sc-link.mjs); call loaded(id, slots)
// after every load SC answers, so the swaps follow what plays
export const createStemSwap = ({ repo, find, sc }) => {
  const stemsDir = path.join(repo, 'sc', 'stems')
  let session = null   // the stem track SC plays: { id, fileSlots, slots }

  const stemTrack = id => {
    const entry = find(id)
    if (!entry?.stems) throw fail(404, `no stem track '${id}'`)
    return { entry, json: readJson(entry.path) }
  }
  const playing = id => session?.id === id && !!sc.host.track
  const roleOf = stem => { try { return readJson(path.join(stemsDir, stem)).meta.role } catch { return null } }
  const checkStem = stem => {
    if (!STEM_REF.test(stem ?? '') || !fs.existsSync(path.join(stemsDir, stem))) throw fail(400, `no stem '${stem}'`)
  }
  const answer = (track, extra) => ({ track, ...extra, slots: sorted(session.slots) })

  const loaded = (id, slots) => {
    const entry = find(id)
    if (!entry?.stems) return void (session = null)
    const fileSlots = readJson(entry.path).slots
    session = { id, fileSlots, slots: { ...fileSlots, ...slots } }
  }

  const state = track => {
    const { json } = stemTrack(track)
    const now = playing(track) ? session.slots : json.slots
    return { track, playing: playing(track), slots: Object.fromEntries(Object.entries(sorted(now))
      .map(([slot, stem]) => [slot, { stem, role: roleOf(stem), file: json.slots[slot] ?? null }])) }
  }

  const swap = async ({ track, slot, stem }) => {
    stemTrack(track)
    if (!playing(track)) throw fail(409, `${track} does not play: press Play first`)
    if (!SLOT.test(slot ?? '') || !session.slots[slot]) throw fail(400, `slot '${slot}' holds no stem`)
    checkStem(stem)
    const result = await sc.swap(slot, stem)
    if (result.live) {
      session.slots[slot] = stem
      return answer(track, { slot, stem, mode: 'next-bar' })
    }
    await sc.load(track, { ...session.slots, [slot]: stem })
    return answer(track, { slot, stem, mode: 'reload', reason: result.reason })
  }

  const revert = async ({ track }) => {
    stemTrack(track)
    if (!playing(track)) throw fail(409, `${track} does not play: press Play first`)
    const changed = Object.keys(session.slots).filter(slot => session.slots[slot] !== session.fileSlots[slot])
    for (const slot of changed) {
      const result = await sc.swap(slot, session.fileSlots[slot])
      if (!result.live) {
        await sc.load(track)
        return answer(track, { mode: 'reload' })
      }
      session.slots[slot] = session.fileSlots[slot]
    }
    return answer(track, { mode: changed.length ? 'next-bar' : 'none' })
  }

  const freeName = base => {
    const stem = base.replace(/-v\d+$/, '')
    for (let n = 2; ; n++) if (!fs.existsSync(path.join(repo, 'sc', 'tracks', `${stem}-v${n}`))) return `${stem}-v${n}`
  }

  const saveAs = ({ track, name }) => {
    const { entry, json } = stemTrack(track)
    const target = name || freeName(json.name)
    if (!TRACK_NAME.test(target)) throw fail(400, `name '${target}': three digits, a dash, lowercase words (009-house-v2)`)
    const dir = path.join(repo, 'sc', 'tracks', target)
    try {
      fs.mkdirSync(dir)
    } catch (error) {
      if (error.code === 'EEXIST') throw fail(409, `sc/tracks/${target} exists: pick another name`)
      throw error
    }
    const frame = `${target}-frame.scd`
    fs.copyFileSync(path.join(path.dirname(entry.path), json.frame), path.join(dir, frame))
    const slots = sorted(playing(track) ? session.slots : json.slots)
    const file = path.join(dir, `${target}.track`)
    fs.writeFileSync(file, JSON.stringify({ ...json, name: target, frame, slots }, null, 2) + '\n', { flag: 'wx' })
    return { id: target, name: target, file: path.relative(repo, file).split(path.sep).join('/'), slots }
  }

  const handle = async (request, response, url, fromOwnPage) => {
    const json = (status, body) => response.writeHead(status, { 'Content-Type': 'application/json', 'Cache-Control': 'no-store' })
      .end(JSON.stringify(body))
    try {
      if (request.method === 'GET' && url.pathname === '/swap') return json(200, state(url.searchParams.get('track')))
      if (request.method !== 'POST' || !fromOwnPage(request)) return json(403, { error: 'forbidden' })
      let body
      try { body = JSON.parse(await readBody(request) || '{}') } catch { throw fail(400, 'the body is not JSON') }
      if (url.pathname === '/swap') return json(200, await swap(body))
      if (url.pathname === '/swap/revert') return json(200, await revert(body))
      if (url.pathname === '/track/save-as') return json(201, saveAs(body))
      return json(404, { error: 'not found' })
    } catch (error) {
      return json(error.status ?? 500, { error: error.message })
    }
  }

  return { handle, loaded, state, swap, revert, saveAs }
}
