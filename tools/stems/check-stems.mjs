// Checks the stem library (sc/stems/<sample>/*.stem) and the stem tracks (sc/tracks/<id>/<id>.track): schema, file
// name = sample + control labels, referenced sample / code / add-on / parent / stems exist, label rules.
// Format and rules: docs/features/stems.md.
// usage (in tools/): node stems/check-stems.mjs [<file.stem|file.track> …]   (no files: the whole library)
// Exit 1 if a file has an error.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

export const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')

const STEM_PARAMS = ['space', 'echo', 'pan']
const ENGINE_ARGS = ['out', 'post', 'freq']
const RESERVED = ['Brightness', 'Space', 'Level', 'Pattern', 'Chords', 'Fog', 'Thin', 'Tension', 'Master', 'Chapter',
  'Break']
const MAX_MODE1_PATTERNS = 3

export const kebab = text => text.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase()
  .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')

export const stemBaseName = stem => [stem.sample.name, ...['k1', 'k2', 'k3', 'b1', 'b2']
  .map(key => stem.controls[key].label)].map(kebab).join('-')

const typeOf = value => value === null ? 'null' : Array.isArray(value) ? 'array'
  : Number.isInteger(value) ? 'integer' : typeof value

const typeMatches = (value, type) => type === typeOf(value) || type === 'number' && typeOf(value) === 'integer'

export function validate(schema, value, where = '', defs = schema.$defs) {
  if (schema.$ref) return validate(defs[schema.$ref.split('/').pop()], value, where, defs)
  const at = where || '(root)'
  const types = schema.type && [schema.type].flat()
  if (types && !types.some(type => typeMatches(value, type))) return [`${at}: expected ${types.join(' or ')}`]
  if ('const' in schema && value !== schema.const) return [`${at}: must be ${JSON.stringify(schema.const)}`]
  if (schema.enum && !schema.enum.includes(value)) {
    return [`${at}: ${JSON.stringify(value)} not one of ${schema.enum.join(', ')}`]
  }
  const errors = []
  if (typeof value === 'string') {
    if (schema.pattern && !new RegExp(schema.pattern).test(value)) {
      errors.push(`${at}: "${value}" does not match ${schema.pattern}`)
    }
    if (schema.minLength && value.length < schema.minLength) errors.push(`${at}: empty`)
    if (schema.maxLength && value.length > schema.maxLength) {
      errors.push(`${at}: ${value.length} characters, at most ${schema.maxLength}`)
    }
  }
  if (typeof value === 'number') {
    if ('minimum' in schema && value < schema.minimum) errors.push(`${at}: below ${schema.minimum}`)
    if ('maximum' in schema && value > schema.maximum) errors.push(`${at}: above ${schema.maximum}`)
    if ('exclusiveMinimum' in schema && value <= schema.exclusiveMinimum) {
      errors.push(`${at}: must be above ${schema.exclusiveMinimum}`)
    }
  }
  if (Array.isArray(value)) {
    if (schema.minItems && value.length < schema.minItems) errors.push(`${at}: at least ${schema.minItems} items`)
    if (schema.maxItems && value.length > schema.maxItems) errors.push(`${at}: at most ${schema.maxItems} items`)
    if (schema.uniqueItems && new Set(value.map(v => JSON.stringify(v))).size < value.length) {
      errors.push(`${at}: items repeat`)
    }
    if (schema.items) value.forEach((item, i) => errors.push(...validate(schema.items, item, `${where}[${i}]`, defs)))
  }
  if (typeOf(value) === 'object') {
    for (const key of schema.required ?? []) if (!(key in value)) errors.push(`${at}: missing "${key}"`)
    for (const [key, item] of Object.entries(value)) {
      const sub = where ? `${where}.${key}` : key
      if (schema.propertyNames) errors.push(...validate(schema.propertyNames, key, `${sub} (name)`, defs))
      if (schema.properties?.[key]) errors.push(...validate(schema.properties[key], item, sub, defs))
      else if (schema.additionalProperties === false) errors.push(`${at}: unknown field "${key}"`)
      else if (typeof schema.additionalProperties === 'object') {
        errors.push(...validate(schema.additionalProperties, item, sub, defs))
      }
    }
  }
  return errors
}

export function miniErrors(text) {
  const pairs = { ']': '[', '>': '<' }
  const open = []
  for (const ch of text) {
    if (ch === '[' || ch === '<') open.push(ch)
    else if (pairs[ch] && open.pop() !== pairs[ch]) return [`unbalanced "${ch}"`]
  }
  return open.length ? [`unclosed "${open.pop()}"`] : []
}

export function soundInfo(root, name) {
  const file = path.join(root, 'sc', 'sounds', `${name}.scd`)
  if (!fs.existsSync(file)) return null
  const text = fs.readFileSync(file, 'utf8')
  const params = [...text.matchAll(/^\s*([A-Za-z]\w*):\s*\(default:/gm)].map(m => m[1])
  const argList = text.match(/SynthDef\([^{]*\{\s*\|([^|]*)\|/)?.[1] ?? ''
  const args = argList.split(',').map(arg => arg.trim().match(/^[A-Za-z]\w*/)?.[0]).filter(Boolean)
  return { params, controllable: [...new Set([...params, ...args])].filter(p => !ENGINE_ARGS.includes(p)) }
}

const readJson = (file, errors) => {
  try { return JSON.parse(fs.readFileSync(file, 'utf8')) } catch (e) {
    errors.push(`not valid JSON: ${e.message}`)
    return null
  }
}

const loadContext = root => ({
  root,
  stemSchema: JSON.parse(fs.readFileSync(path.join(root, 'sc', 'stems', 'stem.schema.json'), 'utf8')),
  trackSchema: JSON.parse(fs.readFileSync(path.join(root, 'sc', 'stems', 'track.schema.json'), 'utf8')),
  addons: JSON.parse(fs.readFileSync(path.join(root, 'sc', 'stems', 'addons.json'), 'utf8')).addons
})

function nameErrors(file, stem) {
  const errors = []
  const folder = path.basename(path.dirname(file))
  const base = path.basename(file, '.stem')
  if (folder !== stem.sample.name) errors.push(`folder "${folder}" is not the sample "${stem.sample.name}"`)
  if (base !== stem.name) errors.push(`file name "${base}" is not the stem name "${stem.name}"`)
  const expected = stemBaseName(stem)
  const suffix = base.startsWith(expected) ? base.slice(expected.length) : null
  if (suffix === null || !(suffix === '' || /^-([2-9]|[1-9]\d+)$/.test(suffix))) {
    errors.push(`name should be "${expected}" (or "${expected}-2", "-3" …), from sample + control labels`)
  }
  return errors
}

function labelErrors(stem) {
  const errors = []
  const { controls, meta } = stem
  if (controls.k1.label !== 'Brightness') errors.push('k1 label must be "Brightness"')
  if (controls.k2.label !== 'Space') errors.push('k2 label must be "Space"')
  if (controls.b1.label === 'Chords' && meta.role !== 'chords') errors.push('b1 "Chords" only on a chords stem')
  for (const key of ['k3', 'b2']) {
    const { label } = controls[key]
    if (RESERVED.includes(label)) errors.push(`${key} label "${label}" is reserved for another job`)
    if (!/^[A-Z0-9]/.test(label)) errors.push(`${key} label "${label}" must start with a capital letter`)
    if (!kebab(label)) errors.push(`${key} label "${label}" has no letters for the file name`)
  }
  return errors
}

function referenceErrors(file, stem, context) {
  const errors = []
  const dir = path.dirname(file)
  const codeExists = (where, code) => {
    if (code && !fs.existsSync(path.join(dir, code))) {
      errors.push(`${where}: code file "${code}" not found next to the stem`)
    }
  }
  const sound = soundInfo(context.root, stem.sample.name)
  if (!sound) errors.push(`sample "${stem.sample.name}" not found in sc/sounds/`)
  for (const key of Object.keys(stem.sample.preset ?? {})) {
    if (sound && !sound.params.includes(key)) errors.push(`sample.preset: "${key}" is not a parameter of the sample`)
  }
  codeExists('code', stem.code)
  stem.patterns.forEach((pattern, i) => {
    if (!pattern.rhythm && !stem.code) errors.push(`patterns[${i}]: needs "rhythm" (or a stem "code" file)`)
    for (const key of ['rhythm', 'notes', 'velocity']) {
      if (pattern[key]) errors.push(...miniErrors(pattern[key]).map(e => `patterns[${i}].${key}: ${e}`))
    }
  })
  const paramExists = (where, param) => {
    if (sound && !sound.controllable.includes(param) && !STEM_PARAMS.includes(param)) {
      errors.push(`${where}: "${param}" is not a parameter of the sample nor one of ${STEM_PARAMS.join(', ')}`)
    }
  }
  for (const key of ['k1', 'k2', 'k3']) {
    const knob = stem.controls[key]
    const ways = ['param', 'targets', 'code'].filter(way => knob[way])
    if (ways.length !== 1) errors.push(`${key}: needs exactly one of "param", "targets", "code"`)
    if (knob.param && !knob.range) errors.push(`${key}: "param" needs a "range"`)
    if (knob.param) paramExists(key, knob.param)
    knob.targets?.forEach((target, i) => paramExists(`${key}.targets[${i}]`, target.param))
    codeExists(key, knob.code)
  }
  codeExists('b1', stem.controls.b1.code)
  const b2 = stem.controls.b2
  if (!!b2.addon === !!b2.code) errors.push('b2: needs exactly one of "addon", "code"')
  if (b2.addon) {
    const addon = context.addons[b2.addon]
    if (!addon) errors.push(`b2: add-on "${b2.addon}" not in sc/stems/addons.json`)
    else {
      if (b2.label !== addon.label) {
        errors.push(`b2: add-on "${b2.addon}" is labelled "${addon.label}", not "${b2.label}"`)
      }
      if (!addon.modes.includes(b2.mode)) errors.push(`b2: add-on "${b2.addon}" has no mode "${b2.mode}"`)
    }
  }
  codeExists('b2', b2.code)
  if (stem.parent) {
    const parent = path.join(context.root, 'sc', 'stems', stem.parent)
    if (!fs.existsSync(parent)) errors.push(`parent "${stem.parent}" not found`)
    if (path.dirname(stem.parent) !== stem.sample.name) errors.push('parent must be a version of the same sample')
    if (path.resolve(parent) === path.resolve(file)) errors.push('parent is the stem itself')
  }
  return errors
}

export function checkStem(file, context = loadContext(repoRoot)) {
  const errors = []
  const stem = readJson(file, errors)
  if (!stem) return errors
  const schemaErrors = validate(context.stemSchema, stem)
  if (schemaErrors.length) return schemaErrors
  return [...nameErrors(file, stem), ...labelErrors(stem), ...referenceErrors(file, stem, context)]
}

export function checkTrack(file, context = loadContext(repoRoot)) {
  const errors = []
  const track = readJson(file, errors)
  if (!track) return errors
  const schemaErrors = validate(context.trackSchema, track)
  if (schemaErrors.length) return schemaErrors
  const folder = path.basename(path.dirname(file))
  if (folder !== track.name || path.basename(file, '.track') !== track.name) {
    errors.push(`a track lives at sc/tracks/${track.name}/${track.name}.track`)
  }
  if (!fs.existsSync(path.join(path.dirname(file), track.frame))) errors.push(`frame "${track.frame}" not found`)
  for (const [slot, ref] of Object.entries(track.slots)) {
    const stemFile = path.join(context.root, 'sc', 'stems', ref)
    if (!fs.existsSync(stemFile)) {
      errors.push(`slot ${slot}: stem "${ref}" not found`)
      continue
    }
    const stem = readJson(stemFile, [])
    if (slot.startsWith('1:') && stem?.patterns?.length > MAX_MODE1_PATTERNS) {
      errors.push(`slot ${slot}: Mode 1 takes at most ${MAX_MODE1_PATTERNS} patterns, "${ref}" has ` +
        `${stem.patterns.length}`)
    }
  }
  return errors
}

const walk = (dir, ext) => !fs.existsSync(dir) ? [] : fs.readdirSync(dir, { withFileTypes: true })
  .flatMap(entry => entry.isDirectory() ? walk(path.join(dir, entry.name), ext)
    : entry.name.endsWith(ext) ? [path.join(dir, entry.name)] : [])

export function libraryFiles(root = repoRoot) {
  return [...walk(path.join(root, 'sc', 'stems'), '.stem'), ...walk(path.join(root, 'sc', 'tracks'), '.track')]
}

export function checkFiles(files, root = repoRoot) {
  const context = loadContext(root)
  return files.map(file => ({ file, errors: (file.endsWith('.track') ? checkTrack : checkStem)(file, context) }))
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2).map(f => path.resolve(process.env.INIT_CWD ?? process.cwd(), f))
  const results = checkFiles(args.length ? args : libraryFiles())
  for (const { file, errors } of results) {
    const name = path.relative(repoRoot, file)
    if (!errors.length) console.log(`ok    ${name}`)
    for (const error of errors) console.log(`FAIL  ${name}: ${error}`)
  }
  const failed = results.filter(r => r.errors.length).length
  console.log(`${results.length} files, ${failed} with errors`)
  process.exit(failed ? 1 : 0)
}
