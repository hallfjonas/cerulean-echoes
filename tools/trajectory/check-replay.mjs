// Replay fidelity: does a replayed take play what the original play played? A take keeps the tapped Strudel events of
// its play (take `events`, <name>.events.jsonl, take-save.mjs). Replaying a take in the player (Start on takes/<name>)
// and saving that play as a take gives a replay take: its `take.script` names the original, and it has events too.
// This compares the two event lists bar by bar (replay-check.mjs) and lists every differing bar with the reason.
// A take that cannot be checked (no events, no replay yet, original gone) is listed as such, never left out.
// usage (in tools/): node trajectory/check-replay.mjs <track.strudel | track id> [takes/<replay take>]
// Without a take: every replay take of the track. Exit 1 if a replay differs or cannot be read.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { PERFORM } from './check-perform.mjs'
import { barLine, compareEvents, parseEvents, summaryLine } from './replay-check.mjs'

const takeDir = trackId => path.join(PERFORM, trackId, 'takes')
const readTake = (trackId, id) => {
  const file = path.join(PERFORM, trackId, id + '.json')
  return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : null
}
const eventsOf = (trackId, take) => {
  const file = take?.take?.events && path.join(takeDir(trackId), path.basename(take.take.events))
  return file && fs.existsSync(file) ? parseEvents(fs.readFileSync(file, 'utf8')) : null
}

// The takes of a track as [{ id: 'takes/<name>', script }]
export const takesOf = trackId => fs.existsSync(takeDir(trackId))
  ? fs.readdirSync(takeDir(trackId)).filter(f => /^[\w-]+\.json$/.test(f)).sort()
    .map(f => `takes/${f.slice(0, -'.json'.length)}`).map(id => ({ id, script: readTake(trackId, id) }))
  : []

export const isReplay = script => script?.take?.script?.startsWith('takes/') ?? false

// { original, replay, result: compareEvents(…), trackChanged } or { original, replay, error } for a replay take
export const checkReplay = (trackId, replayId) => {
  const replay = readTake(trackId, replayId)
  if (!isReplay(replay)) return { replay: replayId, error: 'not a replay of a take' }
  const original = replay.take.script
  const source = readTake(trackId, original)
  if (!source) return { original, replay: replayId, error: `the original ${original} is gone` }
  const [originalEvents, replayEvents] = [eventsOf(trackId, source), eventsOf(trackId, replay)]
  if (!originalEvents) return { original, replay: replayId, error: 'the original has no events (saved before events ' +
    'were kept)' }
  if (!replayEvents) return { original, replay: replayId, error: 'the replay has no events' }
  return { original, replay: replayId, result: compareEvents(originalEvents, replayEvents),
    trackChanged: source.take.trackHash !== replay.take.trackHash }
}

// The report of one replay as lines
export const reportLines = check => {
  const head = `${check.replay}: replay of ${check.original ?? '?'}`
  if (check.error) return [head, `  cannot check: ${check.error}`]
  const { result } = check
  return [head,
    ...check.trackChanged ? ['  the track file changed since the original (other sha1): differences may be the edit']
      : [],
    `  bars compared: 1-${result.bars} (original finished ${result.originalBars}, replay ${result.replayBars})`,
    ...result.differing.map(diff => '  ' + barLine(diff)),
    `  ${summaryLine(result)}`]
}

const failed = check => !!check.error || !check.result.bars || check.result.differing.length > 0

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const [target, only] = process.argv.slice(2)
  if (!target) {
    console.error('usage (in tools/): node trajectory/check-replay.mjs <track.strudel | track id> [takes/<take>]')
    process.exit(2)
  }
  const trackId = path.basename(target, '.strudel')
  const takes = takesOf(trackId)
  const replays = only ? [only] : takes.filter(t => isReplay(t.script)).map(t => t.id)
  const checks = replays.map(id => checkReplay(trackId, id))
  for (const check of checks) console.log(reportLines(check).join('\n'))
  if (!only) {
    const replayed = new Set(checks.map(check => check.original))
    for (const { id, script } of takes.filter(t => !isReplay(t.script) && !replayed.has(t.id))) {
      console.log(`${id}: not checked: ${script?.take?.events ? 'no replay yet (Start it in the player, then Save ' +
        'take)' : 'no events (saved before events were kept)'}`)
    }
  }
  if (!takes.length) console.log(`${trackId}: no takes in ${path.relative(process.cwd(), takeDir(trackId))}`)
  process.exit(checks.some(failed) ? 1 : 0)
}
