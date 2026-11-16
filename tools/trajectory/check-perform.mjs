// Checks the auto-perform scripts (perform/<track>/<script>.json, see autoperform.mjs) against their track: the shape
// of every step, every CC a control of the track's @ctl tags, every press one of its buttons.
// usage (in tools/): node trajectory/check-perform.mjs [<track.strudel> …]   (default: every track that has scripts)
// Exit 1 if a script fails.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { parse } from '../lcxl-layout/gen-layout.mjs'

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

export const checkScript = (script, controls, trackId) => {
  const errors = []
  if (script.track !== trackId) errors.push(`track is '${script.track}', expected '${trackId}'`)
  if (!Array.isArray(script.steps)) return [...errors, 'steps is not a list']
  script.steps.forEach((step, i) => {
    const at = `step ${i + 1} (bar ${step.bar})`
    const keys = Object.keys(step).sort().join(',')
    if (!isBar(step.bar)) errors.push(`${at}: bar must be a number ≥ 0`)
    if (step.press !== undefined) {
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

const trackIdOf = file => path.basename(file, '.strudel')
export const scriptFiles = trackId => {
  const dir = path.join(PERFORM, trackId)
  if (!fs.existsSync(dir)) return []
  return fs.readdirSync(dir).filter(f => f.endsWith('.json')).sort().map(f => path.join(dir, f))
}

export const trackFileOf = trackId => {
  const tracks = path.join(repo, 'tracks')
  const files = fs.readdirSync(tracks).flatMap(genre => fs.statSync(path.join(tracks, genre)).isDirectory()
    ? fs.readdirSync(path.join(tracks, genre)).map(folder => path.join(tracks, genre, folder, trackId + '.strudel'))
    : [])
  return files.find(file => fs.existsSync(file)) ?? null
}

// { file: errors[] } for every script of the track
export const checkTrack = file => {
  const controls = controlsOf(fs.readFileSync(file, 'utf8'))
  return Object.fromEntries(scriptFiles(trackIdOf(file)).map(script => {
    try { return [script, checkScript(JSON.parse(fs.readFileSync(script, 'utf8')), controls, trackIdOf(file))] }
    catch (error) { return [script, [error.message]] }
  }))
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2).map(f => path.resolve(process.env.INIT_CWD ?? process.cwd(), f))
  const files = args.length ? args : fs.readdirSync(PERFORM).sort().map(id => trackFileOf(id) ?? path.join(PERFORM, id))
  let failed = false
  for (const file of files) {
    if (!fs.existsSync(file)) {
      console.log(`${path.basename(file)}: FAIL no track file for these scripts`)
      failed = true
      continue
    }
    for (const [script, errors] of Object.entries(checkTrack(file))) {
      const name = path.relative(PERFORM, script)
      console.log(errors.length ? `${name}: FAIL\n  ${errors.join('\n  ')}` : `${name}: ok`)
      failed ||= errors.length > 0
    }
  }
  process.exit(failed ? 1 : 0)
}
