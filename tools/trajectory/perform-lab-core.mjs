// The Tracks lab's model of a performance, pure (no DOM, no fs): runs in the page and in Node.
// A lab file holds sections and moves; moves compile to the steps of a plain script v2 (autoperform.mjs), which
// check-perform judges. Launch Control XL 3 moves only; Launchkey steps live in Hand-made moves.
// Lab: { track, title?, bars?, mood?, story?, sections: [{ id, name, type?, from, to, intent?, energy? }],
//        moves: [{ id, kind, bar, p: { ... }, edits?: { <step index>: { at?, value?, ramp?, del? } } }] }
// Bars are 0-based and ranges half-open, as in the script: a section [from, to) ends before `to`.
// A move's parameters `p` make its steps; an edit overrides one of them by its index, so a later parameter change
// keeps the edit: `at` = bars after the move's bar (the step moves with the move), `ramp: 0` removes the ramp,
// `del: true` drops the step.
// A button takes over at the next bar line after its press (Chapter at the next 4-bar line), so a Press or Break move
// sits on the bar where the button takes over and presses PRESS_LEAD bars before it (never before bar 0).
import { sectionAt } from './autoperform.mjs'

export const MAX_AT_ONCE = 6
export const PRESS_LEAD = 0.5

const round = n => Math.round(n * 1e4) / 1e4
const ccStep = (bar, cc, value, ramp = 0) => ramp > 0
  ? { bar: round(bar), cc, value, ramp: round(ramp) }
  : { bar: round(bar), cc, value }
const pressStep = (bar, cc) => ({ bar: round(Math.max(0, bar - PRESS_LEAD)), press: cc })

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

const isLevel = control => !!control && !control.button && / Level$/.test(control.name) &&
  !control.name.startsWith('Global')
const isGlobal = (control, name) => control?.name === `Global ${name}`
const sameText = step => JSON.stringify(Object.keys(step).sort().map(key => [key, step[key]]))
const compilesTo = (move, steps) => {
  const made = MOVES[move.kind].steps(move)
  return made.length === steps.length && made.every((step, i) => sameText(step) === sameText(steps[i]))
}
const moveOf = (kind, steps, p, bar = steps[0].bar) => ({ id: newId('m'), kind, bar, p, edits: {} })
const buttonMoveOf = (kind, steps, p) => moveOf(kind, steps, p, round(steps[0].bar + PRESS_LEAD))

// one Launch Control step as a move: Enter or Leave on a Level fader, Press on a button, Move control on the rest
const singleMove = (step, control) => {
  if (step.press !== undefined) return buttonMoveOf('press', [step], { cc: step.press })
  if (isLevel(control) && step.value === 0) return moveOf('leave', [step], { cc: step.cc, over: step.ramp ?? 0 })
  if (isLevel(control)) return moveOf('enter', [step], { cc: step.cc, to: step.value, over: step.ramp ?? 0 })
  return moveOf('control', [step], { cc: step.cc, to: step.value, over: step.ramp ?? 0 })
}

// a pair of steps on one control as one move: a Break (two presses on Break), a Fog dip (up, then back to 0 on Fog),
// a Build (a ramp up, then a jump to 0 where the ramp ends); null when the pair is none of them
const pairMove = (first, second, control) => {
  if (!second) return null
  if (first.press !== undefined) {
    return isGlobal(control, 'Break') ? buttonMoveOf('break', [first, second], { cc: first.press,
      length: round(second.bar - first.bar) }) : null
  }
  if (!(first.value > 0) || second.value !== 0) return null
  const over = first.ramp ?? 0
  if (isGlobal(control, 'Fog')) {
    const hold = round(second.bar - first.bar - over)
    return hold >= 0 ? moveOf('fogDip', [first, second], { cc: first.cc, to: first.value, over, hold,
      back: second.ramp ?? 0 }) : null
  }
  if (!isLevel(control) && over > 0 && second.ramp === undefined && round(first.bar + over) === second.bar) {
    return moveOf('build', [first, second], { cc: first.cc, to: first.value, over, release: true })
  }
  return null
}

const LAYERS_MIN = 3

// runs of Enter (or Leave) moves on different faders, the same level and ramp, at a steady distance: Layers
const withLayers = moves => {
  const result = []
  const fits = (run, move) => {
    const last = run.at(-1)
    const every = round(run.length > 1 ? run[1].bar - run[0].bar : move.bar - last.bar)
    return move.kind === last.kind && move.p.over === last.p.over && move.p.to === last.p.to && every > 0 &&
      round(move.bar - last.bar) === every && !run.some(other => other.p.cc === move.p.cc)
  }
  let run = []
  const close = () => {
    if (run.length >= LAYERS_MIN) {
      const layers = moveOf('layers', [run[0]], { dir: run[0].kind === 'enter' ? 'in' : 'out',
        ccs: run.map(move => move.p.cc), every: round(run[1].bar - run[0].bar), over: run[0].p.over,
        to: run[0].p.to ?? 0.6 })
      const steps = run.map(move => move.steps[0])
      result.push(compilesTo(layers, steps) ? { ...layers, steps } : run)
    } else result.push(run)
    run = []
  }
  for (const move of moves) {
    if (!['enter', 'leave'].includes(move.kind)) result.push(move)
    else if (run.length && fits(run, move)) run.push(move)
    else {
      close()
      run = [move]
    }
  }
  close()
  return result.flat()
}

// A script as a lab: its meta and sections (or one section over the whole length), its Launch Control steps
// recognised as moves (Enter, Leave, Layers, Build, Fog dip, Break, Press, Move control) by the track's controls
// (cc → { name, button }), every other step (Launchkey keys, pads, knobs) in Hand-made moves, one per section and
// control. A guess that would not compile back to its steps is not made: compileMoves gives back the script's steps.
export const importScript = (script, controls = new Map()) => {
  const steps = [...script.steps].sort((a, b) => a.bar - b.bar)
  const bars = script.bars ?? Math.max(1, Math.ceil(Math.max(0, ...steps.map(stepEnd))))
  const sections = (script.sections?.length ? script.sections : [{ name: 'All', from: 0, to: bars }])
    .map(({ name, from, to, intent }) => newSection({ name, from, to, ...intent && { intent } }))
  const order = new Map(steps.map((step, i) => [step, i]))
  const byControl = new Map(), handMade = new Map()
  for (const step of steps) {
    const key = controlKey(step)
    if (typeof key === 'number') byControl.set(key, [...byControl.get(key) ?? [], step])
    else {
      const section = sections.findIndex(({ from, to }) => from <= step.bar && step.bar < to)
      handMade.set(`${section}|${key}`, [...handMade.get(`${section}|${key}`) ?? [], step])
    }
  }
  const recognised = []
  for (const [cc, list] of byControl) {
    for (let i = 0; i < list.length; i++) {
      const pair = pairMove(list[i], list[i + 1], controls.get(cc))
      if (pair && compilesTo(pair, [list[i], list[i + 1]])) {
        recognised.push({ ...pair, steps: [list[i], list[++i]] })
        continue
      }
      const single = singleMove(list[i], controls.get(cc))
      const { bar: _bar, ...rest } = list[i]
      recognised.push({ ...compilesTo(single, [list[i]]) ? single
        : moveOf('handMade', [list[i]], { steps: [{ at: 0, ...rest }] }), steps: [list[i]] })
    }
  }
  const lcMoves = withLayers(recognised.sort((a, b) => order.get(a.steps[0]) - order.get(b.steps[0])))
  const handMoves = [...handMade.values()].map(list => ({ ...moveOf('handMade', list,
    { steps: list.map(({ bar, ...step }) => ({ at: round(bar - list[0].bar), ...step })) }), steps: list }))
  const moves = [...lcMoves, ...handMoves].sort((a, b) => order.get(a.steps[0]) - order.get(b.steps[0]))
    .map(({ steps: _steps, ...move }) => move)
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

// [{ key, bar }]: where a value step (steps in bar order) starts inside the ramp of the step before it on the same
// control (controlKey); the performer cuts that ramp there
export const cutRamps = steps => {
  const last = new Map(), cuts = []
  for (const step of steps) {
    if (!('value' in step)) continue
    const key = controlKey(step), before = last.get(key)
    if (before?.ramp && step.bar < before.bar + before.ramp) cuts.push({ key, bar: step.bar })
    last.set(key, step)
  }
  return cuts
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
