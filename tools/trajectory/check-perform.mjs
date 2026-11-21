// Checks the auto-perform scripts (perform/<track>/<script>.json, see autoperform.mjs) against their track: the meta
// fields (sections in order, inside `bars`, every step in a section), the shape of every step, every CC a control of
// the track's @ctl tags, every press one of its buttons, Launchkey pads 36-51, LK CCs 1 / 21-28, keys that parse,
// velocities 0..1, and the `take` meta field of a take (perform/<track>/takes/<take>.json, checked like a script).
// A ported track's scripts serve both its SuperCollider version (sc/tracks/<id>/<id>.scd, same @ctl tags) and its
// frozen Strudel file: by default both are checked.
// usage (in tools/): node trajectory/check-perform.mjs [<track.strudel | track.scd> …]
//   (default: every track that has scripts)
// Exit 1 if a script fails.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { parse } from '../lcxl-layout/ctl.mjs'
import { LK_CCS, PADS, isLaunchkeyStep, keyNotes } from './autoperform.mjs'

const here = path.dirname(fileURLToPath(import.meta.url))
const repo = path.resolve(here, '..', '..')
export const PERFORM = path.join(here, 'perform')
const BASE = { k1: 12, k2: 20, k3: 28, fader: 4, b1: 36, b2: 44 }
const BUTTONS = ['b1', 'b2']

// cc → { name, button } for every control the @ctl tags name (Mode 2 = CC + 48, column 8 global on both)
export const controlsOf = src => {
  const tags = parse(src, '')
  const controls = new Map()
  const add = (cc, row, name) => controls.set(cc, { name, button: BUTTONS.includes(row) })
  for (const ctl of tags.ctls) {
    for (let col = ctl.from; col <= ctl.to; col++) {
      const head = tags.cols[`${ctl.mode}:${col}`] ?? `${ctl.mode}:${col}`
      add(BASE[ctl.row] + col + (/^B?2$/.test(ctl.mode) ? 48 : 0), ctl.row, `${head} ${ctl.name}`)
    }
  }
  for (const [row, { name }] of Object.entries(tags.global)) {
    add(BASE[row] + 8, row, `Global ${name}`)
    if (!tags.globalSame) add(BASE[row] + 56, row, `Global ${name}`)
  }
  return controls
}

const isBar = bar => Number.isFinite(bar) && bar >= 0
const SCRIPT_FIELDS = ['track', 'steps', 'title', 'bars', 'mood', 'sections', 'take']
const TAKE_SOURCES = ['human', 'auto', 'mixed']
const SECTION_FIELDS = ['name', 'from', 'to', 'intent']
const isText = text => typeof text === 'string' && text.trim() !== ''
const hasOnly = (step, required, optional = []) => required.every(k => k in step) &&
  Object.keys(step).every(k => required.includes(k) || optional.includes(k))

const checkTake = take => {
  if (take === null || typeof take !== 'object' || Array.isArray(take)) return ['take must be an object']
  const errors = []
  if (!hasOnly(take, ['source', 'recordedAt', 'trackHash', 'cps', 'inputs'], ['script', 'events']))
    errors.push('take: needs source, recordedAt, trackHash, cps, inputs (script events)')
  if (!TAKE_SOURCES.includes(take.source)) errors.push(`take: source must be one of ${TAKE_SOURCES.join(', ')}`)
  if (!isText(take.recordedAt) || Number.isNaN(Date.parse(take.recordedAt)))
    errors.push('take: recordedAt must be an ISO time')
  if (!/^[0-9a-f]{40}$/.test(take.trackHash)) errors.push('take: trackHash must be a sha1 in hex')
  if (!(take.cps > 0)) errors.push('take: cps must be a number > 0')
  if (!Array.isArray(take.inputs) || !take.inputs.every(isText))
    errors.push('take: inputs must be a list of port names')
  if (take.script !== undefined && !isText(take.script)) errors.push('take: script must be a text')
  if (take.events !== undefined && !isText(take.events)) errors.push('take: events must be a text')
  return errors
}

const checkMeta = script => {
  const errors = []
  const unknown = Object.keys(script).filter(k => !SCRIPT_FIELDS.includes(k))
  if (unknown.length) errors.push(`unknown field ${unknown.join(', ')} (fields: ${SCRIPT_FIELDS.join(', ')})`)
  if (script.title !== undefined && !isText(script.title)) errors.push('title must be a text')
  if (script.mood !== undefined && !isText(script.mood)) errors.push('mood must be a text')
  if (script.bars !== undefined && !(script.bars > 0)) errors.push('bars must be a number > 0')
  if (script.take !== undefined) errors.push(...checkTake(script.take))
  if (script.sections === undefined) return errors
  if (!Array.isArray(script.sections)) return [...errors, 'sections is not a list']
  script.sections.forEach((section, i) => {
    const at = `section ${i + 1} (${section.name})`
    const previous = script.sections[i - 1]
    if (!hasOnly(section, ['name', 'from', 'to'], ['intent'])) errors.push(`${at}: needs name, from, to (intent)`)
    if (!isText(section.name) || section.name.trim().split(/\s+/).length > 2)
      errors.push(`${at}: name must be one or two words`)
    if (section.intent !== undefined && !isText(section.intent)) errors.push(`${at}: intent must be a text`)
    if (!isBar(section.from) || !(section.to > section.from)) errors.push(`${at}: needs 0 ≤ from < to (bars)`)
    if (previous && section.from < previous.to) errors.push(`${at}: starts before section ${i} ends (${previous.to})`)
    if (script.bars !== undefined && section.to > script.bars) errors.push(`${at}: ends after bar ${script.bars}`)
  })
  return errors
}

const checkLaunchkeyStep = (step, at) => {
  const errors = []
  if (step.keys !== undefined) {
    if (!hasOnly(step, ['bar', 'keys'], ['velocity', 'length'])) errors.push(`${at}: needs bar, keys (velocity length)`)
    if (typeof step.keys !== 'string' || !keyNotes(step.keys))
      errors.push(`${at}: keys '${step.keys}' must be note names or MIDI numbers, space-separated ('c3 e3 g3')`)
    if (step.velocity !== undefined && !(step.velocity > 0 && step.velocity <= 1)) errors.push(`${at}: velocity 0..1`)
    if (step.length !== undefined && !(step.length > 0)) errors.push(`${at}: length must be > 0 bars`)
  } else if (step.pad !== undefined) {
    if (!hasOnly(step, ['bar', 'pad'], ['velocity'])) errors.push(`${at}: needs bar, pad (velocity)`)
    if (!(Number.isInteger(step.pad) && step.pad >= PADS[0] && step.pad <= PADS[1]))
      errors.push(`${at}: pad must be a note ${PADS[0]}-${PADS[1]}`)
    if (step.velocity !== undefined && !(step.velocity > 0 && step.velocity <= 1)) errors.push(`${at}: velocity 0..1`)
  } else {
    if (!hasOnly(step, ['bar', 'lk', 'value'], ['ramp'])) errors.push(`${at}: needs bar, lk, value (ramp)`)
    if (!LK_CCS.includes(step.lk)) errors.push(`${at}: lk ${step.lk} is not the mod wheel (1) or a knob (21-28)`)
    if (!(step.value >= 0 && step.value <= 1)) errors.push(`${at}: value must be 0..1`)
    if (step.ramp !== undefined && !(step.ramp > 0)) errors.push(`${at}: ramp must be > 0 bars`)
  }
  return errors
}

export const checkScript = (script, controls, trackId) => {
  const errors = []
  if (script.track !== trackId) errors.push(`track is '${script.track}', expected '${trackId}'`)
  if (!Array.isArray(script.steps)) return [...errors, 'steps is not a list']
  errors.push(...checkMeta(script))
  const sections = Array.isArray(script.sections) && script.sections.length ? script.sections : null
  script.steps.forEach((step, i) => {
    const at = `step ${i + 1} (bar ${step.bar})`
    const keys = Object.keys(step).sort().join(',')
    if (!isBar(step.bar)) errors.push(`${at}: bar must be a number ≥ 0`)
    else if (sections && !sections.some(s => s.from <= step.bar && step.bar < s.to))
      errors.push(`${at}: in no section`)
    if (script.bars !== undefined && step.bar + (step.ramp ?? 0) > script.bars)
      errors.push(`${at}: ends after bar ${script.bars}`)
    if (isLaunchkeyStep(step)) errors.push(...checkLaunchkeyStep(step, at))
    else if (step.press !== undefined) {
      if (keys !== 'bar,press') errors.push(`${at}: a press step has only bar and press`)
      else if (!controls.has(step.press)) errors.push(`${at}: press ${step.press} is not a control of the track`)
      else if (!controls.get(step.press).button) errors.push(`${at}: press ${step.press} is not a button`)
    } else {
      if (!['bar,cc,value', 'bar,cc,ramp,value'].includes(keys)) errors.push(`${at}: needs bar, cc, value (ramp)`)
      else if (!controls.has(step.cc)) errors.push(`${at}: cc ${step.cc} is not a control of the track`)
      if (!(step.value >= 0 && step.value <= 1)) errors.push(`${at}: value must be 0..1`)
      if (step.ramp !== undefined && !(step.ramp > 0)) errors.push(`${at}: ramp must be > 0 bars`)
    }
  })
  return errors
}

const trackIdOf = file => path.basename(file).replace(/\.(strudel|scd)$/, '')
const jsonFiles = dir => fs.existsSync(dir)
  ? fs.readdirSync(dir).filter(f => f.endsWith('.json')).sort().map(f => path.join(dir, f))
  : []
export const scriptFiles = trackId => jsonFiles(path.join(PERFORM, trackId))
const takeFiles = trackId => jsonFiles(path.join(PERFORM, trackId, 'takes'))

const findFile = (dir, name) => {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name)
    const found = entry.isDirectory() ? findFile(full, name) : entry.name === name ? full : null
    if (found) return found
  }
  return null
}

export const trackFileOf = trackId => findFile(path.join(repo, 'tracks'), trackId + '.strudel')
// The SuperCollider version of a track, or null
export const scTrackFileOf = trackId => {
  const file = path.join(repo, 'sc', 'tracks', trackId, trackId + '.scd')
  return fs.existsSync(file) ? file : null
}

// { file: errors[] } for every script and take of the track
export const checkTrack = file => {
  const controls = controlsOf(fs.readFileSync(file, 'utf8'))
  return Object.fromEntries([...scriptFiles(trackIdOf(file)), ...takeFiles(trackIdOf(file))].map(script => {
    try { return [script, checkScript(JSON.parse(fs.readFileSync(script, 'utf8')), controls, trackIdOf(file))] }
    catch (error) { return [script, [error.message]] }
  }))
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2).map(f => path.resolve(process.env.INIT_CWD ?? process.cwd(), f))
  const files = args.length ? args : fs.readdirSync(PERFORM, { withFileTypes: true }).filter(e => e.isDirectory())
    .map(e => e.name).sort().flatMap(id => {
      const found = [scTrackFileOf(id), trackFileOf(id)].filter(Boolean)
      return found.length ? found : [path.join(PERFORM, id)]
    })
  let failed = false
  for (const file of files) {
    if (!fs.existsSync(file)) {
      console.log(`${path.basename(file)}: FAIL no track file for these scripts`)
      failed = true
      continue
    }
    for (const [script, errors] of Object.entries(checkTrack(file))) {
      const name = path.relative(PERFORM, script) + (file.endsWith('.scd') ? ' (SuperCollider)' : '')
      console.log(errors.length ? `${name}: FAIL\n  ${errors.join('\n  ')}` : `${name}: ok`)
      failed ||= errors.length > 0
    }
  }
  process.exit(failed ? 1 : 0)
}
