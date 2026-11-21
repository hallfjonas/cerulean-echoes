// Knobs as data: the parameters of a stem's sound a knob can drive (read from sc/sounds/<sample>.scd), the presets of
// sc/stems/knobs.json, and a validated knob made from a definition. A knob is the JSON object of a stem's controls
// (docs/features/stems.md, "Controls"); there is no class behind it. Used by the Stem Designer's knob editor.
import fs from 'fs'
import path from 'path'
import { knobLabelErrors, repoRoot, soundInfo, STEM_PARAMS } from './check-stems.mjs'

const PARAM = /^[a-z][A-Za-z0-9]*$/
const SOUND_NAME = /^[a-z][A-Za-z0-9]*$/
const LINE = /^\s*([A-Za-z]\w*):\s*\(default:\s*(-?[\d.]+)(?:,\s*spec:\s*\[([^\]]*)\])?(?:,\s*label:\s*"([^"]*)")?(?:,\s*about:\s*"([^"]*)")?/gm
export const KNOB_NAME = { k1: 'Knob 1 (top row)', k2: 'Knob 2 (middle row)', k3: 'Knob 3 (bottom row)' }
const STEM_RANGE = { space: [0, 1], echo: [0, 1], pan: [-1, 1] }

const readSoundText = (root, name) => {
  const file = path.join(root, 'sc', 'sounds', `${name}.scd`)
  return fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null
}

function specsOf(root, name) {
  const text = readSoundText(root, name)
  if (!text) return {}
  const base = text.match(/~ce\.loadSound\(\\(\w+)\)/)?.[1]
  const specs = base && base !== name ? specsOf(root, base) : {}
  for (const [, param, fallback, spec, label, about] of text.matchAll(LINE)) {
    const [low, high, curve] = (spec ?? '').split(',').map(part => part.trim())
    specs[param] = { default: Number(fallback), range: spec ? [Number(low), Number(high)] : null,
      curve: curve === '\\exp' ? 'exp' : 'lin', label: label ?? param, about: about ?? '' }
  }
  return specs
}

export function soundParams(sample, root = repoRoot) {
  const info = SOUND_NAME.test(sample ?? '') && soundInfo(root, sample)
  if (!info) throw new Error(`no sound "${sample}" in sc/sounds/`)
  const specs = specsOf(root, sample)
  const own = info.controllable.filter(param => PARAM.test(param) && param !== 'tone').map(param => ({
    param, label: specs[param]?.label ?? param, about: specs[param]?.about ?? '', default: specs[param]?.default ?? null,
    range: specs[param]?.range ?? STEM_RANGE[param] ?? null, curve: specs[param]?.curve ?? 'lin' }))
  const stem = STEM_PARAMS.filter(param => !own.some(entry => entry.param === param)).map(param => ({
    param, label: param[0].toUpperCase() + param.slice(1), about: 'a stem parameter', default: 0,
    range: STEM_RANGE[param], curve: 'lin' }))
  return [...own.sort((a, b) => Number(!!b.range) - Number(!!a.range)), ...stem]
}

export const knobPresets = (root = repoRoot) =>
  JSON.parse(fs.readFileSync(path.join(root, 'sc', 'stems', 'knobs.json'), 'utf8')).knobs

const isNumber = value => typeof value === 'number' && Number.isFinite(value)

export function knobErrors(key, knob) {
  const errors = []
  if (!['k1', 'k2', 'k3'].includes(key)) errors.push(`"${key}" is not a knob`)
  if (typeof knob.label !== 'string' || !knob.label.length || knob.label.length > 20) errors.push('label: 1-20 characters')
  else errors.push(...knobLabelErrors(key, knob).map(error => error.replace(/^k\d /, '')))
  if (typeof knob.about !== 'string' || !knob.about.length || knob.about.length > 60) errors.push('about: 1-60 characters')
  if (typeof knob.param !== 'string' || !PARAM.test(knob.param)) errors.push('param: the name of a parameter')
  if (!Array.isArray(knob.range) || knob.range.length !== 2 || !knob.range.every(isNumber)) errors.push('range: two numbers')
  else if (knob.curve === 'exp' && knob.range.some(bound => bound <= 0)) errors.push('an exp curve needs bounds above 0')
  else if (knob.range[0] === knob.range[1]) errors.push('range: the bounds are the same')
  if (knob.curve !== undefined && !['lin', 'exp'].includes(knob.curve)) errors.push('curve: lin or exp')
  if (knob.default !== undefined && !(isNumber(knob.default) && knob.default >= 0 && knob.default <= 1)) {
    errors.push('default: a knob position from 0 to 1')
  }
  return errors
}

// A knob from the editor's fields: a preset (its fields fill what is missing) or a parameter, bounds, curve, default
export function buildKnob(key, definition, root = repoRoot) {
  const preset = definition.preset ? knobPresets(root)[definition.preset] : null
  if (definition.preset && !preset) throw new Error(`no knob preset "${definition.preset}"`)
  const { preset: _preset, ...fields } = definition
  const knob = { ...preset, ...fields }
  if (typeof knob.label === 'string') knob.label = knob.label.trim().replace(/^[a-z]/, letter => letter.toUpperCase())
  if (knob.curve === 'lin') delete knob.curve
  const errors = knobErrors(key, knob)
  if (errors.length) throw new Error(`${KNOB_NAME[key] ?? key}: ${errors.join('; ')}`)
  return Object.fromEntries(['label', 'about', 'param', 'range', 'curve', 'default']
    .filter(field => knob[field] !== undefined).map(field => [field, knob[field]]))
}

// a copy of the stem with the knob replaced: the knob's code, targets and points go with it (a knob maps one way)
export function withKnob(stem, key, knob) {
  const next = structuredClone(stem)
  next.controls[key] = knob
  return next
}
