// Checks the stem library (sc/stems/<sample>/*.stem) and the stem tracks (sc/tracks/<id>/<id>.track): schema, file
// name = sample + control labels, referenced sample / code / add-on / parent / stems exist, label rules; format 2:
// layers, kits, amounts, envelopes and held chords.
// Format and rules: docs/features/stems.md.
// usage (in tools/): node stems/check-stems.mjs [<file.stem|file.track> …]   (no files: the whole library)
// Exit 1 if a file has an error.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

export const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')

const STEM_PARAMS = ['space', 'echo', 'pan']
const STEM_PARAMS_2 = [...STEM_PARAMS, 'room', 'length', 'boost', 'trim', 'transpose', 'echoTime', 'echoFeedback']
const FORMAT_2_FIELDS = ['register', 'push', 'orbit', 'echo', 'layers']
const FORMAT_2_PART = ['length', 'params', 'env', 'voices', 'strike']
const ENGINE_ARGS = ['out', 'post', 'freq']
const RESERVED = ['Brightness', 'Space', 'Level', 'Pattern', 'Chords', 'Fog', 'Thin', 'Tension', 'Master', 'Chapter',
  'Break']

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
  const base = text.match(/~ce\.loadSound\(\\(\w+)\)/)?.[1]
  const baseInfo = base && base !== name ? soundInfo(root, base) : null
  const params = [...text.matchAll(/^\s*([A-Za-z]\w*):\s*\(default:/gm)].map(m => m[1])
  const files = [...(text.match(/files:\s*\[([^\]]*)\]/)?.[1] ?? '').matchAll(/"([^"]+)"/g)].map(m => m[1])
  const argList = text.match(/SynthDef\([^{]*\{\s*\|([^|]*)\|/)?.[1] ?? ''
  const args = argList.split(',').map(arg => arg.trim().match(/^[A-Za-z]\w*/)?.[0]).filter(Boolean)
  const own = { params, files, controllable: [...new Set([...params, ...args])].filter(p => !ENGINE_ARGS.includes(p)) }
  return baseInfo ? { params: [...baseInfo.params, ...own.params], files: [...baseInfo.files, ...own.files],
    controllable: [...new Set([...baseInfo.controllable, ...own.controllable])] } : own
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
  for (const extra of stem.sample.extra ?? []) {
    if (!soundInfo(context.root, extra)) errors.push(`sample.extra: "${extra}" not found in sc/sounds/`)
  }
  for (const key of Object.keys(stem.sample.preset ?? {})) {
    if (sound && !sound.controllable.includes(key)) errors.push(`sample.preset: "${key}" is not a parameter of the sample`)
  }
  codeExists('code', stem.code)
  const reads = layerErrors(stem, sound, context, errors)
  const stemParams = stem.format === 2 ? STEM_PARAMS_2 : STEM_PARAMS
  const paramExists = (where, param) => {
    if (sound && !sound.controllable.includes(param) && !stemParams.includes(param)
      && !(stem.layers ?? []).some(layer => soundInfo(context.root, layer.sound ?? stem.sample.name)?.controllable
        .includes(param))) {
      errors.push(`${where}: "${param}" is not a parameter of the sample nor one of ${stemParams.join(', ')}`)
    }
  }
  for (const key of ['k1', 'k2', 'k3']) {
    const knob = stem.controls[key]
    const ways = ['param', 'targets', 'code'].filter(way => knob[way])
    if (ways.length > 1 || (!ways.length && !stem.code && !reads.has(key))) {
      errors.push(`${key}: needs exactly one of "param", "targets", "code" (none only with a stem "code" or a ` +
        'layer that reads it)')
    }
    if (knob.param && !knob.range && !knob.points) errors.push(`${key}: "param" needs a "range"`)
    if (knob.param) paramExists(key, knob.param)
    knob.targets?.forEach((target, i) => {
      paramExists(`${key}.targets[${i}]`, target.param)
      if (!target.range && !target.points) errors.push(`${key}.targets[${i}]: needs a "range" or "points"`)
    })
    for (const target of [knob, ...(knob.targets ?? [])]) {
      if (target.param === 'trim' && target.points) errors.push(`${key}: trim takes a "range", not "points"`)
    }
    codeExists(key, knob.code)
  }
  codeExists('b1', stem.controls.b1.code)
  const b2 = stem.controls.b2
  if ((b2.addon && b2.code) || (!b2.addon && !b2.code && !stem.code && !reads.has('b2'))) {
    errors.push('b2: needs exactly one of "addon", "code" (none only with a stem "code" or a layer that reads it)')
  }
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

const pointsErrors = (where, points) => points?.some((pt, i) => i > 0 && pt[0] < points[i - 1][0])
  ? [`${where}: points must go up in x`] : []

const usesFormat2 = stem => FORMAT_2_FIELDS.some(key => key in stem) || 'kit' in stem.sample
  || 'tensionFilter' in (stem.frame ?? {})
  || stem.patterns.some(p => FORMAT_2_PART.some(key => key in p) || typeof p.velocity === 'object')
  || ['k1', 'k2', 'k3'].some(key => [stem.controls[key], ...(stem.controls[key].targets ?? [])]
    .some(target => target.points))

// The layers of a stem (a format 1 stem: one layer of its patterns): every pattern has a rhythm or held chords, mini-
// notation brackets, layer sounds, parameters and kit notes exist. Returns the controls the layers read.
function layerErrors(stem, sound, context, errors) {
  const reads = new Set()
  if (stem.format !== 2 && usesFormat2(stem)) errors.push('uses format 2 fields: needs "format": 2')
  const kit = stem.sample.kit
  if (kit) {
    if (stem.pitch !== 'none') errors.push('a kit needs "pitch": "none" (the notes name the kit\'s files)')
    for (const [key, file] of Object.entries(kit)) {
      if (sound && !sound.files.includes(file)) errors.push(`sample.kit.${key}: "${file}" is not a file of the sample`)
    }
  }
  const layers = stem.layers ?? [{}]
  const sounds = [stem.sample.name, ...(stem.sample.extra ?? [])]
  layers.forEach((layer, li) => {
    const where = stem.layers ? `layers[${li}]` : 'patterns'
    const layerSound = layer.sound ?? stem.sample.name
    if (!sounds.includes(layerSound)) errors.push(`${where}: sound "${layerSound}" is not the sample nor in its extra`)
    const info = soundInfo(context.root, layerSound)
    const paramOk = param => !info || info.controllable.includes(param) || STEM_PARAMS_2.includes(param)
    if ((layer.patterns?.length ?? 0) > stem.patterns.length) {
      errors.push(`${where}: ${layer.patterns.length} patterns, the stem has ${stem.patterns.length}`)
    }
    stem.patterns.forEach((pattern, i) => {
      const own = layer.patterns?.[i] ?? {}
      const part = { ...pattern, ...layer, ...own, params: { ...pattern.params, ...layer.params, ...own.params } }
      const at = stem.layers ? `${where} pattern ${i}` : `patterns[${i}]`
      if (!part.rhythm && !part.strike && !stem.code) errors.push(`${at}: needs "rhythm" (or a stem "code" file)`)
      for (const key of ['rhythm', 'notes', 'length', 'velocity']) {
        if (typeof part[key] === 'string') errors.push(...miniErrors(part[key]).map(e => `${at}.${key}: ${e}`))
      }
      for (const param of Object.keys(part.params)) {
        if (!paramOk(param)) errors.push(`${at}: "${param}" is not a parameter of "${layerSound}"`)
      }
      if (kit && part.notes) {
        for (const token of part.notes.match(/[^\s[\]<>@!~]+/g) ?? []) {
          if (!(token in kit)) errors.push(`${at}.notes: "${token}" is not a key of sample.kit`)
        }
      }
    })
    for (const key of ['amount', 'chance']) {
      const a = layer[key]
      if (a && typeof a === 'object') {
        reads.add(a.source)
        errors.push(...pointsErrors(`${where}.${key}`, a.points))
        if (a.param && info && !info.controllable.includes(a.param)) {
          errors.push(`${where}.${key}: "${a.param}" is not a parameter of "${layerSound}"`)
        }
        if (a.zero === 'play' && !a.param) errors.push(`${where}.${key}: "zero": "play" needs a "param"`)
      }
    }
  })
  for (const key of ['k1', 'k2', 'k3']) {
    const knob = stem.controls[key]
    for (const [i, target] of [knob, ...(knob.targets ?? [])].entries()) {
      errors.push(...pointsErrors(i ? `${key}.targets[${i - 1}]` : key, target.points))
    }
  }
  return reads
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
    if (!fs.existsSync(path.join(context.root, 'sc', 'stems', ref))) errors.push(`slot ${slot}: stem "${ref}" not found`)
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
