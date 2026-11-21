// Sample Designer projects (sc/lab/samples/<name>.sample.json): check, save, save as, export to the sound library.
// Format: sc/lab/samples/sample.schema.json and docs/features/sample-designer.md; block kinds:
// sc/lab/samples/blocks.json.
// Values from the running designer come from SC's state (sc/lib/designer.scd, designerValues):
//   { blocks: [{ id, on, type, level, k1, k2, k3 }], audition: { pattern, accent, space, length, master } }
import fs from 'fs'
import os from 'os'
import path from 'path'
import { execFile } from 'child_process'
import { promisify } from 'util'
import { miniErrors, repoRoot, validate } from '../stems/check-stems.mjs'

export { repoRoot }
export const samplesDir = (root = repoRoot) => path.join(root, 'sc', 'lab', 'samples')
export const projectFile = (name, root = repoRoot) => path.join(samplesDir(root), `${name}.sample.json`)
export const NAME = /^[a-z][a-z0-9]*(-[a-z0-9]+)*$/
const SOUND_NAME = /^[a-z][A-Za-z0-9]*$/
const MAX_COLUMNS = 7

const readJson = file => JSON.parse(fs.readFileSync(file, 'utf8'))
export const blocksLib = (root = repoRoot) => readJson(path.join(samplesDir(root), 'blocks.json'))
export const paramName = (id, key) => id + key[0].toUpperCase() + key.slice(1)
export const soundNameOf = name => name.replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase())
export const columnsOf = project => [...project.sources, ...project.chain]

export const listProjects = (root = repoRoot) => fs.existsSync(samplesDir(root))
  ? fs.readdirSync(samplesDir(root)).filter(f => f.endsWith('.sample.json')).map(f => f.slice(0, -12)).sort()
  : []
export const readProject = (name, root = repoRoot) => readJson(projectFile(name, root))

export function projectErrors(project, file, root = repoRoot) {
  const schema = readJson(path.join(samplesDir(root), 'sample.schema.json'))
  const errors = validate(schema, project)
  if (errors.length) return errors
  const lib = blocksLib(root)
  const base = path.basename(file, '.sample.json')
  if (base !== project.name) errors.push(`file name "${base}" is not the project name "${project.name}"`)
  if (project.parent && !fs.existsSync(projectFile(project.parent, root))) {
    errors.push(`parent "${project.parent}" not found in sc/lab/samples/`)
  }
  const columns = columnsOf(project)
  if (columns.length > MAX_COLUMNS) errors.push(`${columns.length} blocks, the LC has ${MAX_COLUMNS} block columns`)
  const ids = columns.map(b => b.id)
  for (const id of ids.filter((id, i) => ids.indexOf(id) !== i)) errors.push(`block id "${id}" used twice`)
  project.sources.forEach((b, i) => {
    if (lib.kinds[b.kind].part !== 'source') errors.push(`sources[${i}]: "${b.kind}" is not a source`)
  })
  project.chain.forEach((b, i) => {
    if (lib.kinds[b.kind].part === 'source') errors.push(`chain[${i}]: "${b.kind}" is a source, it goes in sources`)
  })
  for (const kind of ['env', 'lfo']) {
    if (columns.filter(b => b.kind === kind).length > 1) errors.push(`at most one "${kind}" block`)
  }
  columns.forEach(b => {
    const types = lib.kinds[b.kind].types
    if (!types.includes(b.type)) errors.push(`block "${b.id}": type "${b.type}" not one of ${types.join(', ')}`)
  })
  const setup = lib.setups[project.setup]
  if (setup) {
    const want = setup.blocks.map(b => `${b.id}:${b.kind}`).join(' ')
    if (columns.map(b => `${b.id}:${b.kind}`).join(' ') !== want) {
      errors.push(`setup "${project.setup}" has the blocks ${want}; use setup "free" for another chain`)
    }
  }
  const { audition } = project
  if (audition.pattern >= audition.patterns.length) errors.push('audition.pattern: no such pattern')
  audition.patterns.forEach((p, i) => {
    for (const key of ['rhythm', 'notes', 'velocity']) {
      if (p[key]) errors.push(...miniErrors(p[key]).map(e => `audition.patterns[${i}].${key}: ${e}`))
    }
    if (p.notes && /[^\d\s.~<>[\]@!-]/.test(p.notes)) errors.push(`audition.patterns[${i}].notes: MIDI numbers only`)
    if (p.velocity && /[^\d\s.~<>[\]@!]/.test(p.velocity)) errors.push(`audition.patterns[${i}].velocity: numbers only`)
    if (!/x/.test(p.rhythm)) errors.push(`audition.patterns[${i}].rhythm: no hit (x)`)
  })
  return errors
}

export function checkProjectFile(file, root = repoRoot) {
  let project
  try { project = readJson(file) } catch (error) { return [`not valid JSON: ${error.message}`] }
  return projectErrors(project, file, root)
}

export const checkAll = (root = repoRoot) => listProjects(root).map(name => projectFile(name, root))
  .map(file => ({ file, errors: checkProjectFile(file, root) }))

const round = v => Math.round(Math.min(1, Math.max(0, +v)) * 1000) / 1000

export function applyValues(project, values) {
  if (!values) return structuredClone(project)
  const out = structuredClone(project)
  for (const block of columnsOf(out)) {
    const v = values.blocks?.find(b => b.id === block.id)
    if (!v) continue
    block.on = !!v.on
    if (typeof v.type === 'string') block.type = v.type
    for (const key of ['k1', 'k2', 'k3', 'level']) if (v[key] !== undefined) block[key] = round(v[key])
  }
  const a = values.audition ?? {}
  if (Number.isInteger(a.pattern)) out.audition.pattern = a.pattern
  for (const key of ['accent', 'space', 'length', 'master']) if (a[key] !== undefined) out.audition[key] = round(a[key])
  return out
}

const inline = value => {
  if (Array.isArray(value)) return `[${value.map(inline).join(', ')}]`
  if (typeof value !== 'object' || value === null) return JSON.stringify(value)
  return `{ ${Object.entries(value).map(([k, v]) => `${JSON.stringify(k)}: ${inline(v)}`).join(', ')} }`
}
export function pretty(value, indent = '', keyWidth = 0) {
  const flat = inline(value)
  if (typeof value !== 'object' || value === null || indent.length + keyWidth + flat.length < 120) return flat
  const inner = indent + '  '
  if (Array.isArray(value)) return `[\n${value.map(v => inner + pretty(v, inner)).join(',\n')}\n${indent}]`
  return `{\n${Object.entries(value).map(([k, v]) => `${inner}${JSON.stringify(k)}: ${pretty(v, inner, k.length + 4)}`)
    .join(',\n')}\n${indent}}`
}

const writeProject = (project, root) => {
  const file = projectFile(project.name, root)
  const errors = projectErrors(project, file, root)
  if (errors.length) throw new Error(`${project.name}: ${errors.join('; ')}`)
  fs.writeFileSync(file, pretty(project) + '\n')
  return file
}

export const saveProject = (name, values, root = repoRoot) =>
  writeProject(applyValues(readProject(name, root), values), root)

export function saveAs(name, newName, values, root = repoRoot) {
  if (!NAME.test(newName ?? '')) throw new Error(`"${newName}": lowercase words joined by "-" (kick-deep)`)
  if (fs.existsSync(projectFile(newName, root))) throw new Error(`project "${newName}" exists already`)
  const project = applyValues(readProject(name, root), values)
  return writeProject({ ...project, name: newName, parent: name }, root)
}

const scString = text => '"' + text.replace(/\\/g, '\\\\').replace(/"/g, '\\"') + '"'

export function soundText(project, soundName, root = repoRoot) {
  const lib = blocksLib(root)
  const machine = fs.readFileSync(path.join(samplesDir(root), 'machine.scd'), 'utf8').trimEnd()
  const columns = columnsOf(project)
  const params = columns.flatMap(b => {
    const kind = lib.kinds[b.kind]
    return [
      ...kind.knobs.map((k, i) =>
        [paramName(b.id, k.key), b[`k${i + 1}`], '[0, 1]', `${kind.label} ${k.label}`, k.about]),
      [paramName(b.id, 'level'), b.level, '[0, 1]', `${kind.label} ${kind.fader.label}`, kind.fader.about],
      [paramName(b.id, 'on'), b.on ? 1 : 0, '[0, 1, \\lin, 1]', `${kind.label} On`, 'block on / off'],
      [paramName(b.id, 'type'), kind.types.indexOf(b.type), `[0, ${kind.types.length - 1}, \\lin, 1]`,
        `${kind.label} Type`, kind.types.join(', ')]
    ]
  })
  params.push(['bright', 1, '[0, 1]', 'Brightness', 'dull ↔ open'],
    ['tone', 1, '[0.05, 2.5, \\exp]', 'Tone', 'global factor (Fog, Tension)'])
  const mono = !columns.some(b => b.kind === 'chorus' && b.on)
  return [
    `// ${project.about}`,
    `// Exported by the Sample Designer from sc/lab/samples/${project.name}.sample.json; blocks: ` +
      columns.map(b => `${b.id} (${b.type}${b.on ? '' : ', off'})`).join(', ') + '.',
    '// The machine below is a copy of sc/lab/samples/machine.scd at export time: every block parameter stays live.',
    '(',
    'var machine = (',
    machine,
    ');',
    'var params = (',
    ...params.map(([key, value, spec, label, about]) =>
      `\t${key}: (default: ${value}, spec: ${spec}, label: ${scString(label)}, about: ${scString(about)}),`),
    ');',
    '(',
    `name: \\${soundName},`,
    `role: \\${project.role},`,
    `about: ${scString(project.about)},`,
    `mono: ${mono},`,
    'hpf: 0,',
    'params: params,',
    `def: machine.(\\ce_${soundName}, [${columns.map(b => `[\\${b.id}, \\${b.kind}]`).join(', ')}], ` +
      'params.collect(_[\\default])),',
    ')',
    ')',
    ''
  ].join('\n')
}

// Writes sc/sounds/<soundName>.scd and, with a sclang, renders 2 bars of the audition with that sound into
// samples/sound-lab/<soundName>.wav (sc/tools/render.scd). Never overwrites a sound or a WAV.
export async function exportSound(name,
  { soundName = soundNameOf(name), values = null, sclang = null, root = repoRoot } = {}) {
  if (!SOUND_NAME.test(soundName)) throw new Error(`"${soundName}": a sound name is camelCase (kickDeep)`)
  const soundFile = path.join(root, 'sc', 'sounds', `${soundName}.scd`)
  const wavFile = path.join(root, 'samples', 'sound-lab', `${soundName}.wav`)
  for (const file of [soundFile, wavFile]) {
    if (fs.existsSync(file)) throw new Error(`${path.relative(root, file)} exists already`)
  }
  const project = applyValues(readProject(name, root), values)
  const errors = projectErrors(project, projectFile(name, root), root)
  if (errors.length) throw new Error(`${name}: ${errors.join('; ')}`)
  fs.writeFileSync(soundFile, soundText(project, soundName, root))
  if (!sclang) return { sound: soundFile, wav: null }
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), 'sample-export-'))
  try {
    const scenario = path.join(temp, 'scenario.json')
    fs.writeFileSync(scenario, JSON.stringify({ cycles: 2, sound: soundName }))
    const projectPath = path.join(temp, `${name}.sample.json`)
    fs.writeFileSync(projectPath, JSON.stringify(project))
    const render = path.join(root, 'sc', 'tools', 'render.scd')
    const run = await promisify(execFile)(sclang, [render, projectPath, scenario, path.join(temp, 'out')],
      { encoding: 'utf8', timeout: 120e3 }).catch(error => error)
    if (!fs.existsSync(path.join(temp, 'out.wav'))) {
      fs.rmSync(soundFile)
      const why = `${run.stdout}\n${run.stderr}`.split('\n').filter(l => /ERROR|Error/.test(l)).slice(0, 3).join(' ')
      throw new Error(`render failed, sound not exported: ${why || 'no WAV'}`)
    }
    fs.mkdirSync(path.dirname(wavFile), { recursive: true })
    fs.copyFileSync(path.join(temp, 'out.wav'), wavFile)
    return { sound: soundFile, wav: wavFile }
  } finally {
    fs.rmSync(temp, { recursive: true, force: true })
  }
}
