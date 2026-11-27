// The Tracks lab's model of a performance, pure (no DOM, no fs): runs in the page and in Node.
// A lab file holds sections and moves; moves compile to the steps of a plain script v2 (autoperform.mjs), which
// check-perform judges. Launch Control XL 3 moves only; Launchkey steps live in Hand-made moves.
// Lab: { track, title?, bars?, mood?, story?, sections: [{ id, name, type?, from, to, intent?, energy? }],
//        moves: [{ id, kind, bar, p: { ... }, edits?: { <step index>: { at?, value?, ramp?, del? } } }] }
// Bars are 0-based and ranges half-open, as in the script: a section [from, to) ends before `to`.
// A move's parameters `p` make its steps; an edit overrides one of them by its index, so a later parameter change
// keeps the edit: `at` = bars after the move's bar (the step moves with the move), `ramp: 0` removes the ramp,
// `del: true` drops the step.
import { sectionAt } from './autoperform.mjs'

export const MAX_AT_ONCE = 6

const round = n => Math.round(n * 1e4) / 1e4
const ccStep = (bar, cc, value, ramp = 0) => ramp > 0
  ? { bar: round(bar), cc, value, ramp: round(ramp) }
  : { bar: round(bar), cc, value }
const pressStep = (bar, cc) => ({ bar: round(bar), press: cc })

const ccsWhere = (controls, test) => [...controls].filter(([, control]) => test(control)).map(([cc]) => cc)
const levelsOf = controls =>
  ccsWhere(controls, c => !c.button && / Level$/.test(c.name) && !c.name.startsWith('Global'))
const globalOf = (controls, name) => ccsWhere(controls, c => c.name === `Global ${name}`)[0]
const firstKnobOf = controls => ccsWhere(controls, c => !c.button)[0]

const nameOf = (controls, cc) => (controls.get(cc)?.name ?? `CC ${cc}`).replace(/^Global /, '')
const voiceOf = (controls, cc) => nameOf(controls, cc).replace(/ Level$/, '')

// kind → { name, group, hint, fields: [[key, label, type]], defaults(controls), steps(move), text(p, controls) }
// field types: level (a fader), levels (several faders), control (any knob or fader), button, unit (0..1), bars,
// dir ('in' | 'out'), bool
export const MOVES = {
  enter: { name: 'Enter', group: 'Entrances', hint: 'a stem comes in',
    fields: [['cc', 'Stem', 'level'], ['to', 'Level', 'unit'], ['over', 'Ramp (bars)', 'bars']],
    defaults: controls => ({ cc: levelsOf(controls)[0], to: 0.6, over: 2 }),
    steps: ({ bar, p }) => [ccStep(bar, p.cc, p.to, p.over)],
    text: (p, controls) => `${voiceOf(controls, p.cc)} in` },
  layers: { name: 'Layers', group: 'Entrances', hint: 'stems one by one, in or out',
    fields: [['dir', 'Direction', 'dir'], ['ccs', 'Stems', 'levels'], ['every', 'Every (bars)', 'bars'],
      ['over', 'Ramp (bars)', 'bars'], ['to', 'Level', 'unit']],
    defaults: controls => ({ dir: 'in', ccs: levelsOf(controls).slice(0, 3), every: 4, over: 2, to: 0.6 }),
    steps: ({ bar, p }) => p.ccs.map((cc, i) => ccStep(bar + i * p.every, cc, p.dir === 'in' ? p.to : 0, p.over)),
    text: p => `Layers ${p.dir} ×${p.ccs.length}` },
  leave: { name: 'Leave', group: 'Exits', hint: 'a stem goes out',
    fields: [['cc', 'Stem', 'level'], ['over', 'Ramp (bars)', 'bars']],
    defaults: controls => ({ cc: levelsOf(controls)[0], over: 2 }),
    steps: ({ bar, p }) => [ccStep(bar, p.cc, 0, p.over)],
    text: (p, controls) => `${voiceOf(controls, p.cc)} out` },
  build: { name: 'Build', group: 'Builds', hint: 'a control rises, then drops to 0',
    fields: [['cc', 'Control', 'control'], ['to', 'To', 'unit'], ['over', 'Over (bars)', 'bars'],
      ['release', 'Back to 0 at the end', 'bool']],
    defaults: controls => ({ cc: globalOf(controls, 'Tension'), to: 0.9, over: 8, release: true }),
    steps: ({ bar, p }) => [ccStep(bar, p.cc, p.to, p.over), ...p.release ? [ccStep(bar + p.over, p.cc, 0)] : []],
    text: (p, controls) => `Build ${nameOf(controls, p.cc)}` },
  fogDip: { name: 'Fog dip', group: 'Builds', hint: 'muffle, hold, clear',
    fields: [['cc', 'Control', 'control'], ['to', 'To', 'unit'], ['over', 'Down (bars)', 'bars'],
      ['hold', 'Hold (bars)', 'bars'], ['back', 'Back (bars)', 'bars']],
    defaults: controls => ({ cc: globalOf(controls, 'Fog'), to: 0.6, over: 4, hold: 4, back: 4 }),
    steps: ({ bar, p }) => [ccStep(bar, p.cc, p.to, p.over), ccStep(bar + p.over + p.hold, p.cc, 0, p.back)],
    text: (p, controls) => `${nameOf(controls, p.cc)} dip` },
  control: { name: 'Move control', group: 'Builds', hint: 'any knob or fader',
    fields: [['cc', 'Control', 'control'], ['to', 'To', 'unit'], ['over', 'Ramp (bars)', 'bars']],
    defaults: controls => ({ cc: firstKnobOf(controls), to: 0.8, over: 0 }),
    steps: ({ bar, p }) => [ccStep(bar, p.cc, p.to, p.over)],
    text: (p, controls) => `${nameOf(controls, p.cc)} → ${p.to}` },
  break: { name: 'Break', group: 'Breaks and changes', hint: 'out, then back on the one',
    fields: [['cc', 'Button', 'button'], ['length', 'Length (bars)', 'bars']],
    defaults: controls => ({ cc: globalOf(controls, 'Break'), length: 8 }),
    steps: ({ bar, p }) => [pressStep(bar, p.cc), pressStep(bar + p.length, p.cc)],
    text: (p, controls) => `${nameOf(controls, p.cc)} ${p.length} bars` },
  press: { name: 'Press', group: 'Breaks and changes', hint: 'Chapter, Pattern, any button',
    fields: [['cc', 'Button', 'button']],
    defaults: controls => ({ cc: globalOf(controls, 'Chapter') }),
    steps: ({ bar, p }) => [pressStep(bar, p.cc)],
    text: (p, controls) => nameOf(controls, p.cc) },
  handMade: { name: 'Hand-made', group: 'Hand-made', hint: 'steps the lab cannot explain',
    fields: [],
    defaults: () => ({ steps: [] }),
    steps: ({ bar, p }) => p.steps.map(({ at, ...step }) => ({ ...step, bar: round(bar + at) })),
    text: p => `Steps ×${p.steps.length}` },
}

export const newId = prefix => prefix + Math.random().toString(36).slice(2, 10)

// A move of `kind` at `bar` with the track's default controls, `p` overriding them
export const newMove = (kind, bar, controls, p = {}) =>
  ({ id: newId('m'), kind, bar, p: { ...MOVES[kind].defaults(controls), ...p }, edits: {} })

export const moveText = (move, controls) => MOVES[move.kind].text(move.p, controls)

const applyEdit = (step, bar, edit) => {
  if (!edit) return step
  const edited = { ...step }
  if (edit.at !== undefined) edited.bar = round(bar + edit.at)
  if (edit.value !== undefined && 'value' in step) edited.value = edit.value
  if (edit.ramp !== undefined && 'value' in step) edited.ramp = round(edit.ramp)
  if (edited.ramp === 0) delete edited.ramp
  return edited
}

// [{ step, move, index }]: every step of the moves with its move's id and its index there, in bar order (stable)
export const compileTagged = moves => moves.flatMap(move => MOVES[move.kind].steps(move).flatMap((step, index) => {
  const edit = move.edits?.[index]
  return edit?.del ? [] : [{ step: applyEdit(step, move.bar, edit), move: move.id, index }]
})).sort((a, b) => a.step.bar - b.step.bar)

export const compileMoves = moves => compileTagged(moves).map(({ step }) => step)

export const stepEnd = step => step.bar + (step.ramp ?? 0) + (step.length ?? 0)

// what a step acts on: a Launch Control CC (number, a control or a button), 'lk:<cc>', 'keys' or 'pad'
export const controlKey = step => step.keys !== undefined ? 'keys' : step.pad !== undefined ? 'pad'
  : step.lk !== undefined ? `lk:${step.lk}` : step.press ?? step.cc

// [from, to] bars the move's steps cover (a ramp to its end); a move without steps covers only its bar
export const spanOf = move => {
  const steps = compileMoves([move])
  if (!steps.length) return [move.bar, move.bar]
  return [Math.min(...steps.map(step => step.bar)), Math.max(...steps.map(stepEnd))]
}

export const sectionOf = (lab, bar) => sectionAt(lab, bar)
export const movesIn = (lab, section) => lab.moves.filter(move => section.from <= move.bar && move.bar < section.to)

export const newSection = fields => ({ id: newId('s'), energy: 0.5, ...fields })

// The sections with `added` in its place: sections it overlaps are cut around it (a cut one keeps its id before it)
export const insertSection = (sections, added) => [...sections.flatMap(section => {
  if (section.to <= added.from || section.from >= added.to) return [section]
  return [{ ...section, to: added.from }, { ...section, id: newId('s'), from: added.to }]
    .filter(part => part.to > part.from)
}), added].sort((a, b) => a.from - b.from)

// The sections without `id`; the one before takes over its bars (the one after, if it was the first)
export const removeSection = (sections, id) => {
  const index = sections.findIndex(section => section.id === id)
  if (index < 0) return sections
  const removed = sections[index]
  const rest = sections.filter(section => section.id !== id)
  if (index > 0) rest[index - 1] = { ...rest[index - 1], to: removed.to }
  else if (rest.length) rest[0] = { ...rest[0], from: removed.from }
  return rest
}

// The edge between section `index` and the next one moved to `bar`, each keeping at least one bar
export const moveEdge = (sections, index, bar) => {
  const [left, right] = [sections[index], sections[index + 1]]
  const edge = Math.min(right.to - 1, Math.max(left.from + 1, bar))
  return sections.map((section, i) => i === index ? { ...section, to: edge } : i === index + 1
    ? { ...section, from: edge } : section)
}

// The sections cut to `bars`: the last one ends there, sections that start after it are dropped
export const fitSections = (sections, bars) => {
  const kept = sections.filter(section => section.from < bars)
  return kept.map((section, i) => i === kept.length - 1 ? { ...section, to: bars } : section)
}

// A script as a lab: its sections (or one over the whole length), its steps as Hand-made moves, one per section and
// control. compileMoves gives back the script's steps.
export const importScript = script => {
  const steps = [...script.steps].sort((a, b) => a.bar - b.bar)
  const bars = script.bars ?? Math.max(1, Math.ceil(Math.max(0, ...steps.map(stepEnd))))
  const sections = (script.sections?.length ? script.sections : [{ name: 'All', from: 0, to: bars }])
    .map(({ name, from, to, intent }) => newSection({ name, from, to, ...intent && { intent } }))
  const groups = new Map()
  for (const step of steps) {
    const section = sections.findIndex(({ from, to }) => from <= step.bar && step.bar < to)
    const key = `${section}|${controlKey(step)}`
    groups.set(key, [...groups.get(key) ?? [], step])
  }
  const moves = [...groups.values()].map(list => ({ id: newId('m'), kind: 'handMade', bar: list[0].bar,
    p: { steps: list.map(({ bar, ...step }) => ({ at: round(bar - list[0].bar), ...step })) }, edits: {} }))
  return { track: script.track, ...script.title && { title: script.title }, bars,
    ...script.mood && { mood: script.mood }, sections, moves }
}

const scriptSection = ({ name, from, to, intent }) => intent ? { name, from, to, intent } : { name, from, to }

// The plain script v2 the lab compiles to (the lab-only fields stay in the lab file)
export const toScript = lab => ({
  track: lab.track,
  ...lab.title && { title: lab.title },
  ...lab.bars && { bars: lab.bars },
  ...lab.mood && { mood: lab.mood },
  ...lab.sections?.length && { sections: lab.sections.map(scriptSection) },
  steps: compileMoves(lab.moves),
})

// a move is busy from its first step to its last step's end, and for at least the bar it starts in
const busyAt = ([from, to], bar) => from <= bar && bar < Math.max(to, from + 1)

const busiestBar = (moves, section) => {
  const spans = moves.filter(move => move.kind !== 'handMade').map(spanOf)
  let best = { bar: section.from, count: 0 }
  for (const [bar] of spans) {
    if (bar < section.from || bar >= section.to) continue
    const count = spans.filter(span => busyAt(span, bar)).length
    if (count > best.count) best = { bar, count }
  }
  return best
}

// The lab's own warnings: a section without moves, too many moves at once
export const labWarnings = lab => (lab.sections ?? []).flatMap(section => {
  const label = `${section.name} (bars ${section.from}→${section.to})`
  const { bar, count } = busiestBar(lab.moves, section)
  return [...movesIn(lab, section).length ? [] : [`${label} has no moves`],
    ...count > MAX_AT_ONCE ? [`${label}: ${count} moves at once at bar ${bar}`] : []]
})

// { errors, warnings }: errors are check-perform's on the compiled script (checkScript from check-perform.mjs, handed
// in so this module stays free of fs), warnings the lab's own
export const checkLab = (lab, { controls, trackId, checkScript }) =>
  ({ errors: checkScript(toScript(lab), controls, trackId), warnings: labWarnings(lab) })
