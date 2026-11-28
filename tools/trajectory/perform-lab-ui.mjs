// The Tracks lab page (Labs / Tracks): a performance of a live track edited at five levels, Story (why), Sections
// (where), Moves (what), Lanes (how much) and Steps (exact). The sidebar picks the track and the performance (a script
// opens as sections and Hand-made moves, perform-lab-core.mjs importScript) or starts a new one, and holds the palette
// of the level; the stage holds the bar, the timeline, the inspector of the selection and the footer.
// The selection (a section, a move or a step) survives a level change. Story, Sections, Moves and Lanes share one
// head that stays on top while the rows scroll: the ruler and the section strip. The section selected there (or in
// the Steps dropdown) is the scope: Steps lists its steps, the timelines tint it. Drag: section edges (the head),
// moves (Moves), energy dots (Sections, Story), lane handles (Lanes: a step's dot, and a square for a ramp's start; a
// step stays between its neighbours on the lane); a click on the ruler sets the cursor, where the sidebar adds.
// Adding where you point: every stem has a Moves row and every Launch Control control a lane (empty ones too); a +
// follows the pointer over a row's or a lane's empty space, and a click there opens a popup of the moves that fit
// (perform-lab-core.mjs movesFor). A move dragged onto another Moves row moves to that stem (retarget) or snaps back.
// Lanes and valueAt follow the performer (autoperform.mjs addSegment): a step moves from the value held at its bar,
// so a step inside a running ramp cuts it there (a warning).
// Keys on this page: 1-5 the level, ⌘Z / Ctrl-Z undo, Escape clears the selection, Backspace / Delete removes the
// selected move or step. The tempo is a what-if: it changes the minutes shown, never the track.
// Bars count from 0 and ranges end before their last number, as in the script.
// Play (sidebar) plays the lab's script as it is now, saved or not, from a bar on a 4-bar line (Chapter switches on
// 4-bar phrases counted from the load); while it plays, a click on a section or the ruler starts it again there.
//   mountTracksLab({ section, stage, perform }) → { show(), progress(p) }   show() lists the tracks and their
//   performances again (new takes appear), keeping what is open;
//   perform: { play(script, id, from) → Promise<played>, stop() } (the player's auto-perform); progress(p) is the
//   performer's onChange ({ bar, script } or null)
import { MOVES, PRESS_LEAD, busiestStem, columnOf, compileTagged, controlKey, cutRamps, fitSections, importScript,
  insertSection, labWarnings, moveEdge, moveRow, moveText, movesFor, movesIn, newId, newMove, newSection, removeSection,
  retarget, sectionOf, spanOf, stemOf, stemsOf, stepEnd, toScript } from './perform-lab-core.mjs'
import { askText, toast } from './toast.mjs'

const TAKE_PREFIX = 'takes/'
const NAME = /^[a-z0-9][a-z0-9-]*$/
const CHECK_DELAY_MS = 300
const HISTORY = 100
const LABEL_WIDTH = 116
const MOVE_LANE = 26
const MOVE_GAP = 2
const LEVELS = [['story', 'Story', 'why'], ['sections', 'Sections', 'where'], ['moves', 'Moves', 'what'],
  ['lanes', 'Lanes', 'how much'], ['steps', 'Steps', 'exact']]
const LEVEL_HINTS = {
  story: 'Describe the piece: title, length, mood, story. The curve is the energy of the sections.',
  sections: 'Bar ranges with a name, an intent and an energy. Drag the edges and the energy dots.',
  moves: 'Musical gestures: a stem enters, a build, a break. Each compiles to steps. Click a row to add a move; ' +
    'drag a move along its row or onto another stem.',
  lanes: 'One lane per control, like automation. Drag a dot for value and time, a square for where a ramp starts. ' +
    'Click a lane to add a move.',
  steps: 'The exact script v2 rows of the section chosen above. Edit any field; the move that made the step keeps ' +
    'the edit.',
}
const SECTION_TYPES = {
  intro: ['Intro', 0.2, 'Fade in the foundation'], layers: ['Layers', 0.45, 'Layers join one at a time'],
  groove: ['Groove', 0.7, 'Busier rhythm'], build: ['Build', 0.8, 'Lift into the drop'],
  drop: ['Drop', 0.9, 'Release, new chords'], break: ['Break', 0.25, 'Low end out, back on the one'],
  peak: ['Peak', 1, 'Everything on'], strip: ['Strip', 0.4, 'Layers leave'], outro: ['Outro', 0.15, 'Out'],
}
const CATEGORY = { enter: 'enter', layers: 'enter', leave: 'leave', build: 'build', fogDip: 'build', control: 'build',
  break: 'change', press: 'change', handMade: 'raw' }

const escapeHtml = text => String(text ?? '').replace(/[&<>"]/g, char =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[char])
const round = (n, digits = 4) => Math.round(n * 10 ** digits) / 10 ** digits
const fmt = n => String(round(n, 3))
const clamp = (n, low, high) => Math.min(high, Math.max(low, n))

export const snap = (n, grid) => Math.round(n / grid) * grid

// bars of 4 beats at `bpm` as m:ss
export const minutesOf = (bars, bpm) => {
  const seconds = Math.round(bars * 240 / bpm)
  return `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, '0')}`
}

export const stepKind = step => ['keys', 'pad', 'lk', 'press'].find(kind => kind in step) ?? 'cc'

// the bars the ruler labels: every 4 bars when a bar is wide, every 8 or 16 when it is narrow
export const rulerMarks = (bars, ppb) => {
  const every = ppb >= 12 ? 4 : ppb >= 6 ? 8 : 16
  return Array.from({ length: Math.floor(bars / every) + 1 }, (_, i) => i * every)
}

// pixels per bar so that `bars` fit `width`
export const fitPpb = (width, bars) => clamp(width / bars, 2, 24)

const heldAt = (segments, bar) => {
  const segment = segments.findLast(candidate => candidate.bar <= bar)
  if (!segment) return 0
  const progress = segment.ramp ? Math.min(1, Math.max(0, bar - segment.bar) / segment.ramp) : 1
  return progress === 1 ? segment.to : segment.from + (segment.to - segment.from) * progress
}

// a control's steps (in bar order) as the performer plays them: [{ bar, from, to, ramp }], `from` = the value held
// at the step's bar
export const segmentsOf = steps => steps.reduce((segments, step) => [...segments,
  { bar: step.bar, from: heldAt(segments, step.bar), to: step.value, ramp: step.ramp ?? 0 }], [])

// the value a control holds at `bar` after its steps (in bar order), a ramp read part-way
export const valueAt = (steps, bar) => heldAt(segmentsOf(steps), bar)

// the SVG path of a control lane: flat until a step, then a ramp (cut where the next step starts) or a jump to its
// value, flat to `width`
export const lanePath = (steps, x, y, width) => {
  const segments = segmentsOf(steps)
  let d = `M0,${y(0)}`
  segments.forEach((segment, i) => {
    const end = Math.min(segment.bar + segment.ramp, segments[i + 1]?.bar ?? Infinity)
    d += `L${x(segment.bar)},${y(segment.from)}L${x(end)},${y(heldAt([segment], end))}`
  })
  return d + `L${width},${y(heldAt(segments, Infinity))}`
}

// { lane: Map<id, index>, count }: boxes [{ id, left, right }] (pixels) stacked so that no two overlap, each on the
// first sub-lane free at its left edge; boxes that only touch share a sub-lane
export const packLanes = boxes => {
  const ends = [], lane = new Map()
  const ordered = [...boxes].sort((a, b) => a.left - b.left || String(a.id).localeCompare(String(b.id)))
  for (const box of ordered) {
    let index = ends.findIndex(end => end <= box.left)
    if (index < 0) index = ends.length
    ends[index] = box.right
    lane.set(box.id, index)
  }
  return { lane, count: Math.max(1, ends.length) }
}

// [low, high]: the bars a lane step may take, between the end of the step before it and the start of the step after
// it on the same lane (items: the lane's tagged steps in bar order)
export const laneRoom = (items, position, bars) => {
  const before = items[position - 1]?.step, after = items[position + 1]?.step
  return [before ? before.bar + (before.ramp ?? 0) : 0, after ? after.bar : bars]
}

// the order of a stem's controls: its main control first, then by CC
const keyRank = (key, controls) => (isMainKey(key, controls) ? 0 : 1) + (typeof key === 'number' ? key / 1000
  : key.startsWith?.('lk:') ? parseInt(key.slice(3)) / 1000 : 0)

// the control a folded stem shows on the Lanes level: a column's fader, Master for Global, the Launchkey mod wheel
export const isMainKey = (key, controls) => {
  if (typeof key !== 'number') return key === 'keys' || key === 'pad' || key === 'lk:1'
  const name = controls.get(key)?.name ?? ''
  return name === 'Global Master' || (!name.startsWith('Global') && / Level$/.test(name))
}

const overlapping = (a, b) => a.left < b.right && b.left < a.right

const option = (value, text, selected) =>
  `<option value="${escapeHtml(value)}"${selected ? ' selected' : ''}>${escapeHtml(text)}</option>`
const performanceLabel = performance => {
  const name = performance.name.startsWith(TAKE_PREFIX)
    ? `take ${performance.name.slice(TAKE_PREFIX.length)}`
    : performance.title ? `${performance.title} (${performance.name})` : performance.name
  return performance.error ? `${name} (unreadable)` : name
}
const performanceMeta = performance => [performance.bars && `${performance.bars} bars`,
  performance.sections && `${performance.sections} sections`, `${performance.steps} steps`,
  performance.design && 'design', performance.take && 'take'].filter(Boolean).join(' · ')

const phraseOf = bar => Math.max(0, Math.floor(bar / 4) * 4)
const BUTTON_MOVES = ['press', 'break']
const IDLE_PLAY_HINT = 'Plays this version, saved or not. While it plays, click a section or the ruler to go there.'

export function mountTracksLab({ section, stage, perform }) {
  section.innerHTML = '<h2>Tracks</h2>' +
    '<label>Track <select data-pick="track"></select></label>' +
    '<label>Performance <select data-pick="performance"></select></label>' +
    '<p class="hint" data-part="meta"></p><button data-act="newPerformance">New performance</button>' +
    '<output data-part="status"></output><div data-part="play"></div><div data-part="palette"></div>'
  stage.innerHTML = '<div class="tl-bar" data-part="bar"></div><div class="tl-main"><div class="tl-scroll" ' +
    'data-part="scroll"><div class="tl-hint" data-part="hint"></div><div data-part="timeline"></div></div>' +
    '<aside class="tl-inspector" data-part="inspector"></aside></div><div class="tl-foot" data-part="foot"></div>'

  const part = name => section.querySelector(`[data-part="${name}"]`) ?? stage.querySelector(`[data-part="${name}"]`)
  const pick = name => section.querySelector(`[data-pick="${name}"]`)
  const state = { tracks: null, info: null, controls: new Map(), lab: null, name: null, owned: false, level: 'moves',
    sel: null, scope: null, cursor: 0, zoom: 12, ppb: 12, bpm: null, history: [], dirty: false, stepView: 'table',
    tagged: [], spans: new Map(), errors: [], run: 0, checkRun: 0, from: 0, playing: null, playBar: null,
    playSection: null, open: { moves: new Set(), lanes: new Set() }, revealed: null }

  const post = async (route, body) => {
    const response = await fetch('lab/tracks/' + route,
      { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
    const result = await response.json().catch(() => ({}))
    if (!response.ok) {
      throw Object.assign(new Error(result.error ?? result.refused ?? `${route}: ${response.status}`), { result })
    }
    return result
  }
  const setStatus = text => { part('status').textContent = text }
  const trackOf = id => state.tracks.find(track => track.track === id)
  const controlName = cc => (state.controls.get(cc)?.name ?? `CC ${cc}`).replace(/^Global /, '')
  const keyLabel = key => key === 'keys' ? 'Keys' : key === 'pad' ? 'Pads'
    : typeof key === 'string' ? `LK ${key.slice(3)}` : controlName(key)
  const stepText = step => ({ keys: () => `keys ${step.keys}`, pad: () => `pad ${step.pad}`, lk: () => `LK ${step.lk}`,
    press: () => `press ${controlName(step.press)}`, cc: () => controlName(step.cc) })[stepKind(step)]()
  const isButton = cc => !!state.controls.get(cc)?.button

  const findSection = id => state.lab.sections.find(item => item.id === id)
  const findMove = id => state.lab.moves.find(move => move.id === id)
  const scoped = () => findSection(state.scope) ?? null
  const warningsOf = () => [...labWarnings(state.lab), ...cutRamps(state.tagged.map(item => item.step))
    .map(({ key, bar }) => `${keyLabel(key)}: a ramp is cut at bar ${fmt(bar)} by the next step`)]
  const taggedOf = (moveId, index) => state.tagged.find(item => item.move === moveId && item.index === index)
  const derive = () => {
    state.tagged = compileTagged(state.lab.moves)
    state.spans = new Map(state.lab.moves.map(move => [move.id, spanOf(move)]))
  }
  const commit = () => {
    state.history.push(JSON.stringify(state.lab))
    if (state.history.length > HISTORY) state.history.shift()
    state.dirty = true
  }
  const undo = () => {
    if (!state.history.length) return
    state.lab = JSON.parse(state.history.pop())
    state.sel = null
    render()
  }
  const selection = () => {
    const sel = state.sel
    if (sel?.type === 'section') {
      const item = findSection(sel.id)
      return item && { type: 'section', section: item, range: [item.from, item.to] }
    }
    if (sel?.type === 'move') {
      const move = findMove(sel.id)
      return move && { type: 'move', move, range: state.spans.get(move.id) }
    }
    if (sel?.type === 'step') {
      const move = findMove(sel.move), tagged = taggedOf(sel.move, sel.index)
      return move && tagged && { type: 'step', move, step: tagged.step, index: sel.index,
        range: [tagged.step.bar, Math.max(stepEnd(tagged.step), tagged.step.bar + 0.25)] }
    }
    return null
  }
  // a step changed by hand: a Hand-made move's own step, else an edit on the move that made it (bar as `at`)
  const editStep = (move, index, changes) => {
    if (move.kind === 'handMade') {
      const own = { ...move.p.steps[index] }
      for (const [key, value] of Object.entries(changes)) {
        if (key === 'bar') own.at = round(value - move.bar)
        else own[key] = value
      }
      if (own.ramp === 0) delete own.ramp
      move.p.steps[index] = own
      return
    }
    const edit = { ...move.edits?.[index] }
    if ('bar' in changes) edit.at = round(changes.bar - move.bar)
    if ('value' in changes) edit.value = changes.value
    if ('ramp' in changes) edit.ramp = changes.ramp
    move.edits = { ...move.edits, [index]: edit }
  }
  const deleteStep = (move, index) => {
    if (move.kind === 'handMade') move.p.steps.splice(index, 1)
    else move.edits = { ...move.edits, [index]: { ...move.edits?.[index], del: true } }
  }

  const width = () => state.lab.bars * state.ppb
  const bx = bar => round(bar * state.ppb, 1)
  const updatePpb = () => {
    const available = part('scroll').clientWidth - LABEL_WIDTH - 24
    state.ppb = ['story', 'sections'].includes(state.level) ? fitPpb(available, state.lab.bars) : state.zoom
  }
  const overlay = () => {
    const sel = selection()
    const scope = scoped()
    const tint = scope ? `<div class="tl-scopeband" style="left:${bx(scope.from)}px;width:${bx(scope.to -
      scope.from)}px"></div>` : ''
    const band = tint + (sel ? `<div class="tl-band" style="left:${bx(sel.range[0])}px;width:${bx(sel.range[1] -
      sel.range[0])}px"></div>` : '')
    return band + `<div class="tl-cursor" style="left:${bx(state.cursor)}px"></div>`
  }
  // fold: { level, id, open, more? } adds the caret that folds and unfolds a stem (more: lanes with steps hidden while
  // folded); attrs: data attributes of the row (data-stem on Moves, data-key on Lanes)
  const row = (label, inner, height = 0, cls = '', fold = null, attrs = '') => `<div class="tl-row ${cls}" ${attrs}>` +
    `<div class="tl-label" ` +
    `title="${escapeHtml(label)}">${fold ? `<button class="tl-caret" data-act="fold" data-level="${fold.level}" ` +
      `data-id="${fold.id}" aria-expanded="${fold.open}" title="${fold.open ? 'Fold' : 'Unfold'}">` +
      `${fold.open ? '▾' : '▸'}</button>` : ''}${escapeHtml(label)}${fold?.more && !fold.open
      ? ` <small>+${fold.more}</small>` : ''}</div><div class="tl-area" style="width:${width()}px` +
    `${height ? `;height:${height}px` : ''}">${inner}${overlay()}</div></div>`
  const byStem = (a, b) => {
    const [stemA, stemB] = [stemOf(a, state.controls), stemOf(b, state.controls)]
    return stemA.rank - stemB.rank || keyRank(a, state.controls) - keyRank(b, state.controls)
  }
  const moveBox = move => {
    const [from, to] = state.spans.get(move.id)
    const left = bx(from), boxWidth = Math.max(14, bx(to - from))
    return { id: move.id, move, left, width: boxWidth, right: left + boxWidth + MOVE_GAP }
  }
  // a newly selected move that overlaps another unfolds its stem on Moves; a step of a folded lane unfolds on Lanes
  const reveal = () => {
    const sel = state.sel
    const id = sel?.type === 'move' ? sel.id : sel?.type === 'step' ? `${sel.move}:${sel.index}` : null
    if (id === state.revealed) return
    state.revealed = id
    if (sel?.type === 'move') {
      const move = findMove(sel.id)
      if (!move) return
      const stem = moveRow(move, state.controls).id
      const box = moveBox(move)
      if (state.lab.moves.some(other => other !== move && moveRow(other, state.controls).id === stem &&
        overlapping(moveBox(other), box))) state.open.moves.add(stem)
    } else if (sel?.type === 'step') {
      const key = taggedOf(sel.move, sel.index) && controlKey(taggedOf(sel.move, sel.index).step)
      if (key === undefined) return
      const stem = stemOf(key, state.controls).id
      if (!isMainKey(key, state.controls)) state.open.lanes.add(stem)
    }
  }
  const ruler = () => `<div class="tl-row tl-ruler"><div class="tl-label">bar (from 0)</div><div class="tl-area" ` +
    `data-drag="cursor" style="width:${width()}px">${rulerMarks(state.lab.bars, state.ppb)
      .map(bar => `<span style="left:${bx(bar)}px">${bar}</span>`).join('')}${overlay()}</div></div>`
  const sectionStrip = () => row('sections', state.lab.sections.map((item, i) => {
    const on = state.sel?.type === 'section' && state.sel.id === item.id
    const playing = state.playBar !== null && item.from <= state.playBar && state.playBar < item.to
    const edge = i < state.lab.sections.length - 1 ? `<span class="tl-edge" data-drag="edge" data-i="${i}"></span>` : ''
    const about = `${item.name} · bars ${item.from}→${item.to} · ${minutesOf(item.to - item.from, state.bpm)}` +
      `${item.intent ? ` · ${item.intent}` : ''}`
    return `<div class="tl-sec${on ? ' on' : ''}${playing ? ' playing' : ''}" data-act="select" data-type="section" ` +
      `data-id="${item.id}" title="${escapeHtml(about)}" style="left:${bx(item.from)}px;width:${Math.max(2,
        bx(item.to - item.from) - 2)}px"><b>${escapeHtml(item.name)}</b><small>${item.from}→${item.to}</small>` +
      `${edge}</div>`
  }).join(''), 28)
  const head = () => `<div class="tl-head">${ruler()}${sectionStrip()}</div>`
  const energyCurve = height => {
    const { sections, bars } = state.lab
    if (!sections.length) return ''
    const y = energy => round(height - 6 - (energy ?? 0.5) * (height - 14), 1)
    const points = [[0, sections[0].energy], ...sections.map(item => [(item.from + item.to) / 2, item.energy]),
      [bars, sections.at(-1).energy]]
    const line = points.map(([bar, energy], i) => `${i ? 'L' : 'M'}${bx(bar)},${y(energy)}`).join('')
    const dots = sections.map(item => `<circle class="tl-energy" data-drag="energy" data-id="${item.id}" ` +
      `cx="${bx((item.from + item.to) / 2)}" cy="${y(item.energy)}" r="5"><title>${escapeHtml(item.name)} energy ` +
      `${fmt(item.energy ?? 0.5)}</title></circle>`).join('')
    return row('energy', `<svg width="${width()}" height="${height}"><path class="tl-energy-area" ` +
      `d="${line}L${bx(bars)},${height}L0,${height}Z"/><path class="tl-energy-line" d="${line}"/>${dots}</svg>`, height)
  }
  const heatRows = () => {
    const steps = state.tagged.map(item => item.step).filter(step => stepKind(step) === 'cc')
    const used = [...new Set(steps.map(step => step.cc))]
      .filter(cc => / Level$/.test(state.controls.get(cc)?.name ?? '') || ['Global Tension', 'Global Fog']
        .includes(state.controls.get(cc)?.name))
      .sort(byStem)
    return used.map(cc => {
      const own = steps.filter(step => step.cc === cc)
      let cells = ''
      for (let bar = 0; bar < state.lab.bars; bar++) {
        const value = valueAt(own, bar + 0.5)
        if (value > 0.02) cells += `<i style="left:${bx(bar)}px;width:${Math.max(1, bx(1) - 0.5)}px;` +
          `opacity:${round(0.15 + value * 0.85, 2)}"></i>`
      }
      return row(isMainKey(cc, state.controls) ? stemOf(cc, state.controls).title : controlName(cc), cells, 20,
        'tl-heat')
    }).join('')
  }
  const storyView = () => {
    const lab = state.lab
    const kinds = {}
    for (const { step } of state.tagged) kinds[stepKind(step)] = (kinds[stepKind(step)] ?? 0) + 1
    return `<div class="tl">${head()}${energyCurve(120)}</div><div class="tl-body"><div class="tl-grid">` +
      `<span>Title</span><input data-f="lab" data-k="title" value="${escapeHtml(lab.title)}">` +
      `<span>Length</span><div><input type="number" step="4" min="4" data-f="lab" data-k="bars" value="${lab.bars}">` +
      ` bars <span class="dim">= ${minutesOf(lab.bars, state.bpm)} at ${state.bpm} BPM</span></div>` +
      `<span>Mood</span><input data-f="lab" data-k="mood" value="${escapeHtml(lab.mood)}">` +
      `<span>Story</span><textarea rows="3" data-f="lab" data-k="story">${escapeHtml(lab.story)}</textarea>` +
      `<span>References</span><textarea rows="2" data-f="lab" data-k="refs">${escapeHtml(lab.refs)}</textarea></div>` +
      `<p class="tl-stats"><span><b>${lab.sections.length}</b> sections</span><span><b>${lab.moves.length}</b> ` +
      `moves</span><span><b>${state.tagged.length}</b> steps</span><span class="dim">${Object.entries(kinds)
        .map(([kind, n]) => `${kind} ${n}`).join(' · ')}</span></p></div>`
  }
  const sectionsView = () => `<div class="tl">${head()}${energyCurve(70)}${heatRows()}</div>`
  const movesView = () => {
    const rows = new Map(stemsOf(state.controls).map(stem => [stem.id, { ...stem, moves: [] }]))
    for (const move of state.lab.moves) {
      const stem = moveRow(move, state.controls)
      if (!rows.has(stem.id)) rows.set(stem.id, { ...stem, moves: [] })
      rows.get(stem.id).moves.push(move)
    }
    const body = [...rows.values()].sort((a, b) => a.rank - b.rank).map(({ id, title, moves }) => {
      const boxes = moves.map(moveBox)
      const packed = packLanes(boxes)
      const open = state.open.moves.has(id) && packed.count > 1
      const count = open ? packed.count : 1
      const top = move => open ? 2 + packed.lane.get(move.id) * MOVE_LANE : 4
      const fold = packed.count > 1 ? { level: 'moves', id, open } : null
      return row(title, boxes.map(({ move, left, width: boxWidth }) => {
        const on = state.sel?.type === 'move' && state.sel.id === move.id
        const edited = Object.keys(move.edits ?? {}).length
          ? '<span class="tl-edited" title="hand-edited steps">●</span> ' : ''
        const text = escapeHtml(moveText(move, state.controls))
        return `<div class="tl-move cat-${CATEGORY[move.kind]}${on ? ' on' : ''}" data-drag="move" ` +
          `data-id="${move.id}" style="left:${left}px;width:${boxWidth}px;top:${top(move)}px;` +
          `height:${MOVE_LANE - 4}px" title="${text} @ ${fmt(move.bar)}">${edited}${text}</div>`
      }).join(''), count * MOVE_LANE + 4, '', fold, `data-stem="${escapeHtml(id)}"`)
    }).join('')
    return `<div class="tl">${head()}${body}</div>`
  }
  const laneSvg = (key, items, label, fold = null, inner = false) => {
    const height = 40
    const y = value => round(height - 5 - value * (height - 10), 1)
    const selected = state.sel?.type === 'step' ? `${state.sel.move}:${state.sel.index}` : null
    const touched = state.sel?.type === 'move' || state.sel?.type === 'step'
    const chosen = state.sel?.type === 'move' ? state.sel.id : state.sel?.move
    const dim = touched && !items.some(item => item.move === chosen)
    const idOf = item => `${item.move}:${item.index}`
    const on = item => selected === idOf(item) ? ' on' : ''
    const attrs = item => `data-drag="dot" data-move="${item.move}" data-index="${item.index}"`
    let body
    if (key === 'keys') {
      body = items.map(item => `<rect class="tl-key${on(item)}" ${attrs(item)} x="${bx(item.step.bar)}" y="12" ` +
        `width="${Math.max(4, bx(item.step.length ?? 1))}" height="16"><title>${escapeHtml(item.step.keys)} @ ` +
        `${fmt(item.step.bar)}</title></rect>`).join('')
    } else if (key === 'pad') {
      body = items.map(item => `<rect class="tl-hit${on(item)}" ${attrs(item)} x="${bx(item.step.bar)}" ` +
        `y="${y((item.step.pad - 36) / 16)}" width="3" height="6"><title>pad ${item.step.pad} @ ${fmt(item.step.bar)}` +
        `</title></rect>`).join('')
    } else if (typeof key === 'number' && isButton(key)) {
      body = items.map(item => `<line class="tl-press" x1="${bx(item.step.bar)}" x2="${bx(item.step.bar)}" y1="4" ` +
        `y2="${height - 4}"/><circle class="tl-dot press${on(item)}" ${attrs(item)} cx="${bx(item.step.bar)}" cy="8" ` +
        `r="5"><title>${escapeHtml(stepText(item.step))} @ ${fmt(item.step.bar)}</title></circle>`).join('')
    } else {
      const segments = segmentsOf(items.map(item => item.step))
      const start = (item, i) => item.step.ramp ? `<rect class="tl-dot start${on(item)}" ${attrs(item)} ` +
        `data-handle="start" x="${bx(item.step.bar) - 4}" y="${y(segments[i].from) - 4}" width="8" height="8">` +
        `<title>${escapeHtml(stepText(item.step))}: ramp starts @ ${fmt(item.step.bar)}</title></rect>` : ''
      body = `<path class="tl-lane" d="${lanePath(items.map(item => item.step), bx, y, width())}"/>` +
        items.map((item, i) => `${start(item, i)}<circle class="tl-dot${on(item)}" ${attrs(item)} ` +
          `cx="${bx(item.step.bar + (item.step.ramp ?? 0))}" cy="${y(item.step.value)}" r="5"><title>` +
          `${escapeHtml(stepText(item.step))} → ` +
          `${item.step.value} @ ${fmt(item.step.bar)}${item.step.ramp ? ` over ${item.step.ramp}` : ''}</title>` +
          `</circle>`).join('')
    }
    return row(label, `<svg width="${width()}" height="${height}"${dim ? ' style="opacity:0.3"' : ''}>${body}` +
      `</svg>`, height, `tl-lane-row${inner ? ' tl-inner' : ''}${items.length ? '' : ' tl-empty'}`, fold,
    `data-key="${escapeHtml(key)}"`)
  }
  // every Launch Control control has a lane, with or without steps (Global on its Mode 1 CCs); Launchkey lanes only
  // with steps
  const laneKeys = lanes => [...new Set([...lanes.keys(), ...[...state.controls.keys()]
    .filter(cc => columnOf(cc) && !(columnOf(cc).col === 8 && cc > 52))])]
  const lanesView = () => {
    const lanes = new Map()
    for (const item of state.tagged) {
      const key = controlKey(item.step)
      lanes.set(key, [...lanes.get(key) ?? [], item])
    }
    const stems = new Map()
    for (const key of laneKeys(lanes).sort(byStem)) {
      const stem = stemOf(key, state.controls)
      if (!stems.has(stem.id)) stems.set(stem.id, { ...stem, keys: [] })
      stems.get(stem.id).keys.push(key)
    }
    const role = (key, stem) => keyLabel(key).replace(`${stem.title} `, '')
    return `<div class="tl">${head()}${[...stems.values()].map(stem => {
      const main = stem.keys.find(key => isMainKey(key, state.controls)) ?? stem.keys[0]
      const others = stem.keys.filter(key => key !== main)
      const open = state.open.lanes.has(stem.id)
      const fold = others.length ? { level: 'lanes', id: stem.id, open,
        more: others.filter(key => lanes.has(key)).length } : null
      return laneSvg(main, lanes.get(main) ?? [], stem.title, fold) + (open ? others.map(key =>
        laneSvg(key, lanes.get(key) ?? [], role(key, stem), null, true)).join('') : '')
    }).join('')}</div>`
  }
  const stepItems = () => {
    const scope = scoped()
    return scope ? state.tagged.filter(({ step }) => step.bar >= scope.from && step.bar < scope.to) : state.tagged
  }
  const stepsView = () => {
    const items = stepItems()
    const scope = scoped()
    const toolbar = `<div class="tl-body tl-tools"><span class="seg"><button data-act="stepView" data-v="table" ` +
      `aria-pressed="${state.stepView === 'table'}">Table</button><button data-act="stepView" data-v="json" ` +
      `aria-pressed="${state.stepView === 'json'}">JSON</button></span><label>Section <select data-f="scope">` +
      `${option('', 'All sections', !scope)}${state.lab.sections.map(item => option(item.id, `${item.name} ` +
        `(bars ${item.from}→${item.to})`, item === scope)).join('')}</select></label>` +
      `<span class="dim">${items.length} of ${state.tagged.length} steps</span></div>`
    if (state.stepView === 'json') {
      return toolbar + `<pre class="tl-json">${escapeHtml(JSON.stringify({ ...toScript(state.lab),
        steps: items.map(item => item.step) }, null, 1).replace(/\n\s+(?=[^\s[\]{}])/g, ' ')
        .replace(/\n\s+([}\]])/g, ' $1'))}</pre>`
    }
    const rows = items.map(item => {
      const { step } = item
      const on = state.sel?.type === 'step' ? state.sel.move === item.move && state.sel.index === item.index
        : state.sel?.type === 'move' && state.sel.id === item.move
      const field = key => key in step ? `<input data-f="step" data-move="${item.move}" data-index="${item.index}" ` +
        `data-k="${key}" value="${escapeHtml(step[key])}">` : ''
      const move = findMove(item.move)
      return `<tr class="${on ? 'on' : ''}" data-act="select" data-type="step" data-move="${item.move}" ` +
        `data-index="${item.index}"><td>${field('bar')}</td><td>${stepKind(step)}</td>` +
        `<td>${escapeHtml(stepText(step))}` +
        `</td><td>${field('value')}${field('velocity')}</td><td>${field('ramp')}${field('length')}</td><td><button ` +
        `class="chip" data-act="gotoMove" data-id="${item.move}">${escapeHtml(MOVES[move.kind].name)}</button></td>` +
        `<td><button data-act="deleteStep" data-move="${item.move}" data-index="${item.index}" title="Delete step">×` +
        `</button></td></tr>`
    }).join('')
    return toolbar + `<div class="tl-body"><table class="tl-steps"><tr><th>bar</th><th>kind</th><th>control</th>` +
      `<th>value / velocity</th><th>ramp / length</th><th>from move</th><th></th></tr>${rows}</table></div>`
  }

  const levels = () => [...state.controls].filter(([, c]) => !c.button && / Level$/.test(c.name) &&
    !c.name.startsWith('Global')).map(([cc]) => cc)
  const fieldHtml = (move, [key, label, type]) => {
    const value = move.p[key]
    const id = `data-f="param" data-id="${move.id}" data-k="${key}" data-t="${type}"`
    const options = list => list.map(cc => option(cc, controlName(cc), cc === value)).join('')
    const control = {
      level: () => `<select ${id}>${options(levels())}</select>`,
      control: () => `<select ${id}>${options([...state.controls].filter(([, c]) => !c.button).map(([cc]) => cc))}` +
        '</select>',
      button: () => `<select ${id}>${options([...state.controls].filter(([, c]) => c.button).map(([cc]) => cc))}` +
        '</select>',
      dir: () => `<select ${id}>${option('in', 'in', value === 'in')}${option('out', 'out', value === 'out')}</select>`,
      unit: () => `<input type="range" min="0" max="1" step="0.05" value="${value}" ${id} data-live="1">` +
        `<output>${fmt(value)}</output>`,
      bars: () => `<input type="number" min="0" step="0.25" value="${value}" ${id}>`,
      bool: () => `<input type="checkbox"${value ? ' checked' : ''} ${id}>`,
      levels: () => `<div class="chips">${levels().map(cc => `<button class="chip${value.includes(cc) ? ' on' : ''}" ` +
        `data-act="toggleStem" data-id="${move.id}" data-v="${cc}">${escapeHtml(controlName(cc))}</button>`)
        .join('')}` +
        '</div>',
    }[type]
    return `<div class="tl-field"><span>${label}</span><div>${control()}</div></div>`
  }
  const crumbs = sel => {
    const parts = [['Script', 'story', null]]
    const at = sel.type === 'section' ? sel.section : sectionOf(state.lab, sel.range[0])
    if (at) parts.push([at.name, 'sections', `data-type="section" data-id="${at.id}"`])
    if (sel.type !== 'section') {
      parts.push([MOVES[sel.move.kind].name, 'moves', `data-type="move" data-id="${sel.move.id}"`])
    }
    if (sel.type === 'step') parts.push([`step @ ${fmt(sel.step.bar)}`, 'steps', null])
    const crumb = ([name, level, target], i) => `${i ? '<span class="dim">›</span>' : ''}<button data-act="crumb" ` +
      `data-level="${level}" ${target ?? ''} class="${i === parts.length - 1 ? 'here' : ''}">` +
      `${escapeHtml(name)}</button>`
    return `<div class="tl-crumbs">${parts.map(crumb).join('')}</div>`
  }
  const inspectOverview = () => {
    const warnings = warningsOf()
    const list = (items, cls) => items.length ? items.map(text => `<p class="${cls}">${escapeHtml(text)}</p>`).join('')
      : '<p>None.</p>'
    return `<h3>This performance</h3><p>${escapeHtml(state.lab.title ?? 'Untitled')}: ${state.lab.sections.length} ` +
      `sections, ${state.lab.moves.length} moves, ${state.tagged.length} steps.</p><p class="hint">Click a ` +
      'section, a move or a step. The selection stays when you change the level.</p>' +
      `<h3>Check (check-perform)</h3>${list(state.errors, 'bad')}<h3>Warnings</h3>${list(warnings, 'dim')}`
  }
  const inspectSection = sel => {
    const item = sel.section
    const here = movesIn(state.lab, item)
    const count = state.tagged.filter(({ step }) => step.bar >= item.from && step.bar < item.to).length
    const input = (key, extra = '') => `<input data-f="section" data-k="${key}" data-id="${item.id}" ${extra}` +
      `value="${escapeHtml(item[key])}">`
    return `${crumbs(sel)}<h3>Section</h3><div class="tl-field"><span>Name</span>${input('name')}</div>` +
      `<div class="tl-field"><span>Type</span><select data-f="section" data-k="type" data-id="${item.id}">` +
      `${option('', '—', !item.type)}${Object.entries(SECTION_TYPES).map(([type, [name]]) =>
        option(type, name, type === item.type)).join('')}</select></div>` +
      `<div class="tl-field"><span>From → to</span><div>${input('from', 'type="number" step="4" ')} → ` +
      `${input('to', 'type="number" step="4" ')} <span class="dim">${minutesOf(item.to - item.from, state.bpm)}` +
      `</span></div></div><p class="hint">Bars count from 0; a range ends before its last number.</p>` +
      `<div class="tl-field"><span>Intent</span>${input('intent')}</div>` +
      '<div class="tl-field"><span>Energy</span><div>' +
      `<input type="range" min="0" max="1" step="0.05" data-f="section" data-k="energy" data-id="${item.id}" ` +
      `data-live="1" value="${item.energy ?? 0.5}"><output>${fmt(item.energy ?? 0.5)}</output></div></div>` +
      `<p class="chips"><button data-act="shift" data-id="${item.id}" data-v="-4">Shift −4</button><button ` +
      `data-act="shift" data-id="${item.id}" data-v="4">Shift +4</button><button data-act="deleteSection" ` +
      `data-id="${item.id}">Delete</button></p><h3>Moves here (${here.length})</h3><div class="chips">${here.map(move =>
        `<button class="chip" data-act="gotoMove" data-id="${move.id}">${escapeHtml(moveText(move, state.controls))}` +
        '</button>').join('') || '<span class="hint">None.</span>'}</div><p><button data-act="level" data-v="steps">` +
      `Show its ${count} steps</button></p>`
  }
  const inspectMove = sel => {
    const move = sel.move
    const own = state.tagged.filter(item => item.move === move.id)
    const edits = Object.keys(move.edits ?? {}).length
    const button = BUTTON_MOVES.includes(move.kind)
    return `${crumbs(sel)}<h3>${MOVES[move.kind].name} move</h3><div class="tl-field"><span>Bar</span><input ` +
      `type="number" step="${button ? 1 : 0.25}" min="0" data-f="moveBar" data-id="${move.id}" ` +
      `value="${move.bar}"></div>${button ? `<p class="hint">The bar where the button takes over (Chapter: the next ` +
        `4-bar line); it is pressed ${PRESS_LEAD} bar before.</p>` : ''}` +
      `${MOVES[move.kind].fields.map(field => fieldHtml(move, field)).join('')}<p class="chips"><button ` +
      `data-act="nudge" data-id="${move.id}" data-v="-1">Earlier</button><button data-act="nudge" ` +
      `data-id="${move.id}" ` +
      `data-v="1">Later</button></p><h3>Compiles to ${own.length} steps</h3><table class="tl-mini">${own.slice(0, 10)
        .map(item => `<tr data-act="select" data-type="step" data-move="${item.move}" data-index="${item.index}">` +
          `<td>${fmt(item.step.bar)}</td><td>${escapeHtml(stepText(item.step))}</td><td>${item.step.value ??
          item.step.velocity ?? ''}${item.step.ramp ? ` ↗${item.step.ramp}` : ''}</td></tr>`).join('')}</table>` +
      `${own.length > 10 ? `<p class="hint">+ ${own.length - 10} more</p>` : ''}` +
      `${edits ? `<p><span class="bad">${edits} hand-edited</span> <button data-act="resetEdits" ` +
        `data-id="${move.id}">Reset</button></p>` : ''}<p class="chips"><button data-act="duplicateMove" ` +
      `data-id="${move.id}">Duplicate</button><button data-act="deleteMove" data-id="${move.id}">Delete</button>` +
      '<button data-act="level" data-v="lanes">Lanes</button><button data-act="level" data-v="steps">Steps</button></p>'
  }
  const inspectStep = sel => {
    const { step, move, index } = sel
    const keys = ['bar', 'value', 'ramp', 'velocity', 'length', 'keys', 'pad', 'lk']
      .filter(key => key in step || (key === 'ramp' && 'value' in step))
      .filter(key => move.kind === 'handMade' || ['bar', 'value', 'ramp'].includes(key))
    return `${crumbs(sel)}<h3>Step</h3><p>${escapeHtml(stepText(step))}</p>${keys.map(key => `<div class="tl-field">` +
      `<span>${key}</span><input data-f="step" data-move="${move.id}" data-index="${index}" data-k="${key}" ` +
      `value="${escapeHtml(step[key] ?? 0)}"></div>`).join('')}<p class="hint">${move.kind === 'handMade'
      ? 'A step of a Hand-made move: edited as it is.'
      : `Made by the ${escapeHtml(MOVES[move.kind].name)} move. The move keeps this edit when it changes later.`}</p>` +
      `<p class="chips"><button data-act="gotoMove" data-id="${move.id}">Move</button><button data-act="deleteStep" ` +
      `data-move="${move.id}" data-index="${index}">Delete step</button></p>`
  }

  // the stem the palette adds to: the selected move's, else the busiest of the scope; null = the move's default
  const paletteStem = () => {
    const sel = selection()
    if (sel && sel.type !== 'section') return moveRow(sel.move, state.controls).id
    return scoped() ? busiestStem(state.lab, scoped(), state.controls) : null
  }
  const renderSide = () => {
    const groups = {}
    for (const [kind, spec] of Object.entries(MOVES)) {
      if (kind !== 'handMade') (groups[spec.group] ??= []).push([kind, spec])
    }
    const at = `bar ${fmt(state.cursor)}`
    const stem = state.lab && paletteStem()
    const on = stem && movesFor(stem, state.controls).length
      ? `, on ${stemsOf(state.controls).find(item => item.id === stem).title} where the move fits` : ''
    const palette = {
      story: '<p class="hint">Nothing to add here: describe the piece on the stage.</p>',
      sections: `<h2>Add a section</h2><p class="hint">At the cursor (${at}).</p><div class="tl-palette">` +
        Object.entries(SECTION_TYPES).map(([type, [name, , intent]]) => `<button data-act="addSection" ` +
          `data-v="${type}">${name}<small>${escapeHtml(intent)}</small></button>`).join('') + '</div>',
      moves: `<h2>Add a move</h2><p class="hint">At the cursor (${at})${on}; click the ruler to move it. Or ` +
        'click a row on Moves or a lane on Lanes.</p>' +
        Object.entries(groups).map(([group, list]) => `<h3>${group}</h3><div class="tl-palette">` +
          list.map(([kind, spec]) => `<button class="cat-${CATEGORY[kind]}" data-act="addMove" data-v="${kind}">` +
            `${spec.name}<small>${spec.hint}</small></button>`).join('') + '</div>').join(''),
      steps: `<h2>Add a step</h2><p class="hint">A Hand-made move at the cursor (${at}).</p><div class="tl-palette">` +
        ['cc', 'press'].map(kind => `<button class="cat-raw" data-act="addStep" data-v="${kind}">${kind}` +
          '<small>script v2 step</small></button>').join('') + '</div>',
    }
    palette.lanes = palette.moves
    part('palette').innerHTML = state.lab ? palette[state.level] : ''
  }
  const renderBar = () => {
    const track = state.info.tempo
    part('bar').innerHTML = `<span class="metric" title="length at this tempo">${state.lab.bars} bars · ` +
      `${minutesOf(state.lab.bars, state.bpm)}</span><label title="A what-if: the track keeps its tempo">♩ <input ` +
      `type="number" min="40" max="220" step="1" data-f="bpm" value="${state.bpm}"> BPM</label>` +
      `${track && state.bpm !== track ? `<button data-act="resetBpm" title="the track plays at ${track}">track ` +
        `${track}</button>` : ''}<span class="grow"></span><span class="seg" role="group" aria-label="Level">` +
      LEVELS.map(([id, name, sub], i) => `<button data-act="level" data-v="${id}" ` +
        `aria-pressed="${state.level === id}" title="Key ${i + 1}">${name}<small>${sub}</small></button>`).join('') +
      '</span><span class="grow"></span>' +
      `<button data-act="undo"${state.history.length ? '' : ' disabled'} title="⌘Z">Undo</button>`
  }
  const renderHint = () => {
    const zoom = ['moves', 'lanes'].includes(state.level) ? `<label>zoom <input type="range" min="4" max="28" ` +
      `value="${state.zoom}" data-f="zoom" data-live="1"><output>${state.zoom}</output></label>` : ''
    part('hint').innerHTML = `<span>${LEVEL_HINTS[state.level]}</span>${zoom}`
  }
  const renderFoot = () => {
    const warnings = warningsOf()
    const errors = state.errors.length
    const canSave = state.owned && state.dirty && !errors
    part('foot').innerHTML = `<span>${state.tagged.length} steps from ${state.lab.moves.length} moves</span>` +
      `<span class="${errors ? 'bad' : 'ok'}" title="${escapeHtml(state.errors.join('\n'))}">${errors
        ? `${errors} error${errors === 1 ? '' : 's'}` : '✓ check-perform'}</span>` +
      `<span class="dim">${warnings.length ? `${warnings.length} warnings` : 'no warnings'}</span>` +
      `<span class="${state.dirty ? 'bad' : 'dim'}">${state.dirty ? 'unsaved changes' : state.name ? 'as on disk' :
        'new'}</span><span class="grow"></span>` +
      '<span class="dim">keys 1–5 level · ⌘Z undo · ⌫ delete · Esc clear</span>' +
      `<button data-act="save"${canSave ? '' : ' disabled'} title="${state.owned ? 'Save over this performance'
        : 'Only performances the lab wrote are saved over: use Save as'}">Save</button>` +
      `<button data-act="saveAs"${errors ? ' disabled' : ''} title="Save as a new performance">Save as</button>`
  }
  let checkTimer = null
  const scheduleCheck = () => {
    clearTimeout(checkTimer)
    const run = ++state.checkRun
    checkTimer = setTimeout(async () => {
      if (!state.lab) return
      try {
        const { errors } = await post('check', { track: state.lab.track, script: toScript(state.lab) })
        if (run === state.checkRun) state.errors = errors
      } catch (error) {
        if (run === state.checkRun) state.errors = [error.message]
      }
      if (run !== state.checkRun || !state.lab) return
      renderFoot()
      if (!selection()) renderInspector()
    }, CHECK_DELAY_MS)
  }
  const renderTimeline = () => {
    const scroll = part('scroll')
    const [left, top] = [scroll.scrollLeft, scroll.scrollTop]
    updatePpb()
    part('timeline').innerHTML = ({ story: storyView, sections: sectionsView, moves: movesView, lanes: lanesView,
      steps: stepsView })[state.level]()
    scroll.style.setProperty('--ppb', state.ppb)
    scroll.scrollTo(left, top)
    placePlayhead()
  }
  const placePlayhead = () => {
    const timeline = part('timeline').querySelector('.tl')
    if (!timeline) return
    let head = timeline.querySelector('.tl-playhead')
    if (state.playBar === null) return head?.remove()
    if (!head) timeline.append(head = Object.assign(document.createElement('div'), { className: 'tl-playhead' }))
    head.style.left = `${LABEL_WIDTH + bx(state.playBar)}px`
  }
  const renderPlay = () => {
    if (!state.lab || !perform) return void (part('play').innerHTML = '')
    const at = state.playBar === null ? '' : `bar ${Math.floor(state.playBar)} (from 0) of ${state.lab.bars}` +
      `${sectionOf(state.lab, state.playBar) ? ` · ${sectionOf(state.lab, state.playBar).name}` : ''}`
    part('play').innerHTML = '<h2>Play</h2><label>From bar <input type="number" step="4" min="0" data-play="from" ' +
      `value="${state.from}"></label><div class="row"><button data-act="play">${state.playing ? 'Again' : 'Play'}` +
      `</button><button data-act="stop"${state.playing ? '' : ' disabled'}>Stop</button></div>` +
      `<p class="hint" data-part="playing">${state.playing ? at || 'loading …' : IDLE_PLAY_HINT}</p>`
  }
  const startPlay = from => {
    if (!perform || !state.lab) return
    state.from = phraseOf(Math.min(from, state.lab.bars - 1))
    const script = toScript(state.lab)
    const played = perform.play(script, `lab:${state.name ?? 'new'}`, state.from)
    state.playing = script
    state.playBar = null
    renderPlay()
    played.then(ok => {
      if (ok || state.playing !== script) return
      state.playing = null
      renderPlay()
    })
  }
  const renderInspector = () => {
    const sel = selection()
    part('inspector').innerHTML = !sel ? inspectOverview() : sel.type === 'section' ? inspectSection(sel)
      : sel.type === 'move' ? inspectMove(sel) : inspectStep(sel)
  }
  const render = () => {
    if (!state.lab) {
      for (const name of ['bar', 'hint', 'timeline', 'inspector', 'foot']) part(name).innerHTML = ''
      renderSide()
      return
    }
    if (state.sel?.type === 'section') state.scope = state.sel.id
    derive()
    reveal()
    renderBar()
    renderSide()
    renderHint()
    renderTimeline()
    renderInspector()
    renderFoot()
    renderPlay()
    scheduleCheck()
  }
  const renderLive = () => {
    derive()
    renderTimeline()
    renderFoot()
    scheduleCheck()
  }

  const discardOk = async () => !state.dirty || await toast('Discard the unsaved changes of this performance?',
    { kind: 'ask', actions: ['Discard'] }) === 'Discard'
  const open = (lab, name, owned = false) => {
    state.lab = lab && { story: '', refs: '', ...lab }
    state.name = name
    state.owned = owned
    state.errors = []
    state.sel = null
    state.scope = null
    state.open = { moves: new Set(), lanes: new Set() }
    state.revealed = null
    state.cursor = 0
    state.history = []
    state.dirty = false
    render()
  }
  const loadTrack = async track => {
    if (state.info?.track === track) return
    state.info = await post('track', { track })
    state.controls = new Map(state.info.controls)
    state.bpm = state.info.tempo ?? 120
  }
  const openPerformance = async () => {
    const run = ++state.run
    const track = pick('track').value
    const performance = trackOf(track)?.performances.find(entry => entry.name === pick('performance').value)
    part('meta').textContent = performance ? performanceMeta(performance) : ''
    try {
      await loadTrack(track)
      if (!performance) return void (run === state.run && (open(null, null), setStatus('No performance yet: ' +
        'press New performance.')))
      if (performance.error) return void (run === state.run && (open(null, null), setStatus(performance.error)))
      setStatus('loading …')
      const opened = await post('open', { track, name: performance.name })
      if (run !== state.run) return
      open(opened.lab ?? importScript(opened.script, state.controls), performance.name, opened.owned)
      const empty = opened.script.take && !opened.script.steps?.length
      setStatus(opened.note ?? (empty ? 'This take holds no steps: it was recorded without MIDI input (the app ' +
        'window has no Web MIDI).' : ''))
    } catch (error) {
      if (run === state.run) setStatus(error.message)
    }
  }
  const fillTrackOptions = () => {
    pick('track').innerHTML = state.tracks.map(track => option(track.track, track.performances.length
      ? `${track.label} (${track.performances.length})` : track.label)).join('')
  }
  const fillPerformanceOptions = () => {
    const performances = trackOf(pick('track').value)?.performances ?? []
    pick('performance').innerHTML = performances.map(entry => option(entry.name, performanceLabel(entry))).join('')
    pick('performance').disabled = !performances.length
  }
  const fillPerformances = () => {
    fillPerformanceOptions()
    return openPerformance()
  }
  const newPerformance = async () => {
    if (!await discardOk()) return
    await loadTrack(pick('track').value)
    const bars = 64
    open({ track: pick('track').value, title: 'New performance', bars, sections: [newSection({ name: 'Intro',
      type: 'intro', from: 0, to: bars, intent: SECTION_TYPES.intro[2], energy: SECTION_TYPES.intro[1] })],
    moves: [] }, null)
    pick('performance').append(new Option('new (unsaved)', '', true, true))
    shownPerformance = ''
    part('meta').textContent = ''
    setStatus('')
  }
  let shownTrack = '', shownPerformance = ''
  pick('track').onchange = async () => {
    const wanted = pick('track').value
    pick('track').value = shownTrack
    if (!await discardOk()) return
    pick('track').value = shownTrack = wanted
    state.dirty = false
    await fillPerformances()
    shownPerformance = pick('performance').value
  }
  pick('performance').onchange = async () => {
    const wanted = pick('performance').value
    pick('performance').value = shownPerformance
    if (!await discardOk()) return
    pick('performance').value = shownPerformance = wanted
    state.dirty = false
    openPerformance()
  }
  const load = async () => {
    setStatus('loading …')
    try {
      state.tracks = (await post('tracks', {})).tracks
      fillTrackOptions()
      pick('track').value = state.tracks.find(track => track.performances.length)?.track ?? state.tracks[0]?.track ?? ''
      shownTrack = pick('track').value
      await fillPerformances()
      shownPerformance = pick('performance').value
    } catch (error) {
      state.tracks = null
      setStatus(error.message)
    }
  }

  const refresh = async () => {
    try {
      state.tracks = (await post('tracks', {})).tracks
    } catch {
      return
    }
    fillTrackOptions()
    pick('track').value = shownTrack
    fillPerformanceOptions()
    if (shownPerformance) pick('performance').value = shownPerformance
    else if (state.lab) pick('performance').append(new Option('new (unsaved)', '', true, true))
    else if (pick('performance').value) {
      shownPerformance = pick('performance').value
      openPerformance()
    }
  }

  const slug = text => String(text ?? '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '')
  const saveAs = async () => {
    const track = state.lab.track
    const taken = trackOf(track)?.performances.map(entry => entry.name) ?? []
    let suggestion = slug(state.lab.title) || 'performance'
    for (let n = 2; taken.includes(suggestion); n++) suggestion = `${slug(state.lab.title) || 'performance'}-${n}`
    const name = (await askText('Save as (lowercase letters, digits and dashes)', suggestion))?.trim()
    if (!name) return
    if (!NAME.test(name)) return void toast('A name is lowercase letters, digits and dashes.', { kind: 'error' })
    if (taken.includes(name) && name !== state.name && await toast(`Replace ${name}?`,
      { kind: 'ask', actions: ['Replace'] }) !== 'Replace') return
    await save(name)
  }
  const save = async name => {
    const track = state.lab.track
    try {
      await post('save', { track, name, script: toScript(state.lab), lab: state.lab })
    } catch (error) {
      if (error.result?.errors) {
        state.errors = error.result.errors
        renderFoot()
        renderInspector()
      }
      return void toast(error.result?.errors ? `Not saved: ${error.result.errors.length} errors (check-perform)`
        : `Not saved: ${error.message}`, { kind: 'error' })
    }
    Object.assign(state, { name, owned: true, dirty: false })
    state.tracks = (await post('tracks', {})).tracks
    fillTrackOptions()
    pick('track').value = shownTrack = track
    fillPerformanceOptions()
    pick('performance').value = shownPerformance = name
    const performance = trackOf(track)?.performances.find(entry => entry.name === name)
    part('meta').textContent = performance ? performanceMeta(performance) : ''
    render()
    toast(`Saved perform/${track}/${name}.json`)
  }

  const change = mutate => {
    commit()
    mutate()
    render()
  }
  const select = sel => { state.sel = sel; render() }
  const ACTIONS = {
    newPerformance,
    save: () => state.owned && state.name ? save(state.name) : saveAs(),
    saveAs,
    level: el => {
      state.level = el.dataset.v
      const sel = selection(), scope = scoped()
      if (state.level === 'steps' && sel && sel.type !== 'section' && scope &&
        !(scope.from <= sel.range[0] && sel.range[0] < scope.to)) state.scope = sectionOf(state.lab, sel.range[0])?.id
      render()
    },
    select: el => {
      select(el.dataset.type === 'step' ? { type: 'step', move: el.dataset.move, index: Number(el.dataset.index) }
        : { type: el.dataset.type, id: el.dataset.id })
      if (el.dataset.type === 'section' && state.playing) startPlay(findSection(el.dataset.id).from)
    },
    play: () => startPlay(state.from),
    stop: () => perform?.stop(),
    undo,
    resetBpm: () => { state.bpm = state.info.tempo; render() },
    stepView: el => { state.stepView = el.dataset.v; render() },
    gotoMove: el => {
      state.sel = { type: 'move', id: el.dataset.id }
      if (['story', 'sections'].includes(state.level)) state.level = 'moves'
      render()
    },
    crumb: el => {
      state.level = el.dataset.level
      if (el.dataset.type) state.sel = { type: el.dataset.type, id: el.dataset.id }
      else if (el.dataset.level === 'story') state.sel = null
      render()
    },
    addMove: el => change(() => {
      const stem = paletteStem()
      const fit = stem && movesFor(stem, state.controls).find(candidate => candidate.kind === el.dataset.v)
      const move = newMove(el.dataset.v, state.cursor, state.controls, fit?.p)
      state.lab.moves.push(move)
      state.sel = { type: 'move', id: move.id }
    }),
    addStep: el => change(() => {
      const kind = el.dataset.v
      const cc = [...state.controls].find(([, control]) => control.button === (kind === 'press'))?.[0]
      const step = kind === 'press' ? { at: 0, press: cc } : { at: 0, cc, value: 0.5 }
      const move = newMove('handMade', state.cursor, state.controls, { steps: [step] })
      state.lab.moves.push(move)
      state.sel = { type: 'step', move: move.id, index: 0 }
    }),
    addSection: el => change(() => {
      const [name, energy, intent] = SECTION_TYPES[el.dataset.v]
      const from = clamp(snap(state.cursor, 4), 0, state.lab.bars - 1)
      const to = Math.min(from + 8, state.lab.bars)
      const added = newSection({ name, type: el.dataset.v, from, to, intent, energy })
      state.lab.sections = insertSection(state.lab.sections, added)
      state.sel = { type: 'section', id: added.id }
    }),
    shift: el => change(() => {
      const item = findSection(el.dataset.id)
      const by = Number(el.dataset.v)
      for (const move of movesIn(state.lab, item)) move.bar = Math.max(0, move.bar + by)
    }),
    deleteSection: el => {
      if (state.lab.sections.length < 2) return
      change(() => {
        state.lab.sections = removeSection(state.lab.sections, el.dataset.id)
        state.sel = null
      })
    },
    fold: el => {
      const open = state.open[el.dataset.level]
      if (open.has(el.dataset.id)) open.delete(el.dataset.id)
      else open.add(el.dataset.id)
      render()
    },
    toggleStem: el => change(() => {
      const move = findMove(el.dataset.id)
      const cc = Number(el.dataset.v)
      move.p.ccs = move.p.ccs.includes(cc) ? move.p.ccs.filter(x => x !== cc) : [...move.p.ccs, cc]
    }),
    nudge: el => change(() => {
      const move = findMove(el.dataset.id)
      move.bar = Math.max(0, move.bar + Number(el.dataset.v))
    }),
    resetEdits: el => change(() => { findMove(el.dataset.id).edits = {} }),
    duplicateMove: el => change(() => {
      const copy = { ...structuredClone(findMove(el.dataset.id)), id: newId('m'), edits: {} }
      copy.bar += 4
      state.lab.moves.push(copy)
      state.sel = { type: 'move', id: copy.id }
    }),
    deleteMove: el => change(() => {
      state.lab.moves = state.lab.moves.filter(move => move.id !== el.dataset.id)
      state.sel = null
    }),
    deleteStep: el => change(() => {
      const move = findMove(el.dataset.move)
      deleteStep(move, Number(el.dataset.index))
      if (move.kind === 'handMade' && !move.p.steps.length) state.lab.moves = state.lab.moves.filter(m => m !== move)
      state.sel = null
    }),
  }
  const onClick = event => {
    const el = event.target.closest('[data-act]')
    if (!el || event.target.closest('input, select, textarea')) return
    if (el.tagName === 'TR' && event.target.closest('button')) return
    ACTIONS[el.dataset.act]?.(el)
  }
  section.addEventListener('click', onClick)
  stage.addEventListener('click', onClick)

  const parseParam = (type, el) => type === 'bool' ? el.checked
    : ['unit', 'bars', 'level', 'control', 'button'].includes(type) ? Number(el.value) : el.value
  const onField = (event, live) => {
    const el = event.target.closest('[data-f]')
    if (!el || live !== !!el.dataset.live || !state.lab) return
    const kind = el.dataset.f
    if (kind === 'zoom') {
      state.zoom = Number(el.value)
      el.nextElementSibling.textContent = el.value
      return renderLive()
    }
    if (kind === 'scope') {
      state.scope = el.value || null
      state.sel = el.value ? { type: 'section', id: el.value } : state.sel?.type === 'section' ? null : state.sel
      return render()
    }
    if (kind === 'bpm') {
      state.bpm = clamp(Number(el.value) || state.info.tempo || 120, 40, 220)
      return render()
    }
    if (live) {
      if (!el.dataset.committed) { commit(); el.dataset.committed = '1' }
      const target = kind === 'param' ? findMove(el.dataset.id).p : findSection(el.dataset.id)
      target[el.dataset.k] = Number(el.value)
      el.nextElementSibling.textContent = fmt(Number(el.value))
      return renderLive()
    }
    const key = el.dataset.k
    change(() => {
      if (kind === 'lab') {
        if (key === 'bars') {
          state.lab.bars = Math.max(4, snap(Number(el.value) || state.lab.bars, 4))
          state.lab.sections = fitSections(state.lab.sections, state.lab.bars)
        } else state.lab[key] = el.value
      } else if (kind === 'section') {
        const item = findSection(el.dataset.id)
        const index = state.lab.sections.indexOf(item)
        if (key === 'to' && index < state.lab.sections.length - 1) {
          state.lab.sections = moveEdge(state.lab.sections, index, Number(el.value))
        } else if (key === 'from' && index > 0) {
          state.lab.sections = moveEdge(state.lab.sections, index - 1, Number(el.value))
        } else if (key === 'type') {
          item.type = el.value || undefined
          if (SECTION_TYPES[el.value]) item.energy = SECTION_TYPES[el.value][1]
        } else if (!['from', 'to'].includes(key)) item[key] = el.value
      } else if (kind === 'param') {
        findMove(el.dataset.id).p[key] = parseParam(el.dataset.t, el)
      } else if (kind === 'moveBar') {
        const move = findMove(el.dataset.id)
        const bar = Math.max(0, Number(el.value))
        move.bar = BUTTON_MOVES.includes(move.kind) ? Math.round(bar) : bar
      } else if (kind === 'step') {
        const value = ['keys'].includes(key) ? el.value : Number(el.value)
        editStep(findMove(el.dataset.move), Number(el.dataset.index), { [key]: value })
      }
    })
  }
  stage.addEventListener('change', event => onField(event, false))
  stage.addEventListener('input', event => { if (event.target.dataset?.live) onField(event, true) })
  stage.addEventListener('change', event => { if (event.target.dataset?.live) render() })

  // positions are read against the rectangle at pointer-down: a render replaces the elements under the pointer
  let drag = null
  const once = () => {
    let done = false
    return () => { if (!done) { commit(); done = true } }
  }
  stage.addEventListener('pointerdown', event => {
    const el = event.target.closest('[data-drag]')
    if (!el || event.button || !state.lab) return
    suppressClick = true
    const kind = el.dataset.drag
    const rect = (el.closest('svg') ?? el.closest('.tl-area')).getBoundingClientRect()
    const barAt = ev => (ev.clientX - rect.left) / state.ppb
    const start = once()
    if (kind === 'cursor') {
      const place = ev => { state.cursor = clamp(snap(barAt(ev), 1), 0, state.lab.bars); render() }
      drag = { move: place, end: () => {
        if (state.playing) return startPlay(state.cursor)
        state.from = phraseOf(state.cursor)
        renderPlay()
      } }
      return place(event)
    }
    if (kind === 'move') {
      const move = findMove(el.dataset.id)
      const [x, from, dirty] = [event.clientX, move.bar, state.dirty]
      const home = moveRow(move, state.controls).id
      let started = false, target = null
      const begin = () => { started = true; start() }
      state.sel = { type: 'move', id: move.id }
      drag = { move: ev => {
        const bar = Math.max(0, snap(from + (ev.clientX - x) / state.ppb, 1))
        if (bar !== move.bar) {
          begin()
          move.bar = bar
          renderLive()
        }
        const id = [...stage.querySelectorAll('.tl-row[data-stem]')].find(item => {
          const box = item.getBoundingClientRect()
          return box.top <= ev.clientY && ev.clientY < box.bottom
        })?.dataset.stem
        target = id && id !== home ? { id, ...retarget(move, id, state.controls) } : null
        showTarget(ev, move, target)
      }, end: () => {
        showTarget(null)
        if (target?.move) {
          begin()
          move.p.cc = target.move.p.cc
          state.revealed = null
        } else if (target) {
          move.bar = from
          if (started) state.history.pop()
          state.dirty = dirty
        }
        render()
      } }
      return render()
    }
    if (kind === 'edge') {
      const index = Number(el.dataset.i)
      drag = { move: ev => {
        const sections = moveEdge(state.lab.sections, index, snap(barAt(ev), state.ppb < 6 ? 4 : 1))
        if (sections[index].to === state.lab.sections[index].to) return
        start()
        state.lab.sections = sections
        renderLive()
      }, end: render }
      return
    }
    if (kind === 'energy') {
      const item = findSection(el.dataset.id)
      const height = Number(el.closest('svg').getAttribute('height'))
      state.sel = { type: 'section', id: item.id }
      drag = { move: ev => {
        start()
        item.energy = round(clamp(snap((height - 6 - (ev.clientY - rect.top)) / (height - 14), 0.05), 0, 1), 2)
        renderLive()
      }, end: render }
      return render()
    }
    if (kind === 'dot') {
      const move = findMove(el.dataset.move)
      const index = Number(el.dataset.index)
      const item = taggedOf(move.id, index)
      const { step } = item
      const height = Number(el.closest('svg').getAttribute('height'))
      const [bar, ramp] = [step.bar, step.ramp ?? 0]
      const end = bar + ramp
      const lane = state.tagged.filter(other => controlKey(other.step) === controlKey(step))
      const [low, high] = ['keys', 'pad'].includes(stepKind(step)) ? [0, state.lab.bars]
        : laneRoom(lane, lane.indexOf(item), state.lab.bars)
      const rampStart = el.dataset.handle === 'start'
      state.sel = { type: 'step', move: move.id, index }
      drag = { move: ev => {
        start()
        const at = snap(barAt(ev), 0.25)
        if (rampStart) {
          const from = clamp(at, Math.min(low, bar), end - 0.25)
          editStep(move, index, { bar: from, ramp: round(end - from) })
          return renderLive()
        }
        const changes = ramp > 0 ? { ramp: round(clamp(at, bar + 0.25, Math.max(high, end)) - bar) }
          : { bar: clamp(at, Math.min(low, bar), Math.max(high, bar)) }
        if ('value' in step) {
          changes.value = round(clamp(snap((height - 5 - (ev.clientY - rect.top)) / (height - 10), 0.05), 0, 1), 2)
        }
        editStep(move, index, changes)
        renderLive()
      }, end: render }
      return render()
    }
  })
  addEventListener('pointermove', event => drag?.move(event))
  addEventListener('pointerup', () => {
    const done = drag
    drag = null
    done?.end?.()
    setTimeout(() => { suppressClick = false })
  })

  // a move dragged onto another Moves row: the row tints (red where the move does not fit) and a hint names the new
  // control or the reason
  let suppressClick = false
  const dropHint = Object.assign(document.createElement('div'), { className: 'tl-drophint' })
  const roleOf = cc => controlName(cc).replace(`${stemOf(cc, state.controls).title} `, '')
  const showTarget = (ev, move, target) => {
    for (const el of stage.querySelectorAll('.tl-target, .tl-refuse')) el.classList.remove('tl-target', 'tl-refuse')
    if (!target) return dropHint.remove()
    stage.querySelector(`.tl-row[data-stem="${CSS.escape(target.id)}"]`)
      ?.classList.add(target.move ? 'tl-target' : 'tl-refuse')
    const [was, now] = target.move ? [move.p.cc, target.move.p.cc] : []
    dropHint.textContent = !target.move ? target.reason : roleOf(was) === roleOf(now)
      ? `→ ${state.controls.get(now)?.name}` : `${state.controls.get(was)?.name} → ${state.controls.get(now)?.name}`
    dropHint.classList.toggle('bad', !target.move)
    const rect = stage.getBoundingClientRect()
    Object.assign(dropHint.style, { left: `${ev.clientX - rect.left + 14}px`, top: `${ev.clientY - rect.top + 14}px` })
    stage.append(dropHint)
  }

  // the popup of the moves that fit where the pointer is (a click on a Moves row or a lane); a line
  // adds its move at that bar, a Move control or Enter on a lane at the value under the pointer
  let popup = null
  const closePopup = () => {
    popup?.el.remove()
    popup = null
  }
  const fitText = fit => `${MOVES[fit.kind].name} · ${fit.p.cc === undefined ? fit.p.dir
    : state.controls.get(fit.p.cc)?.name ?? `CC ${fit.p.cc}`}`
  const openPopup = (event, title, fits, bar, value) => {
    closePopup()
    const el = document.createElement('div')
    el.className = 'tl-pop'
    const at = `bar ${fmt(bar)}${value === undefined ? '' : ` · ${value}`}`
    const lines = fits.map((fit, i) => `<button data-pop="${i}">${escapeHtml(fitText(fit))}</button>`).join('')
    el.innerHTML = `<p class="dim">${escapeHtml(title)} · ${at}</p>${lines ||
      '<p class="hint">Nothing fits here yet: Launchkey moves come later.</p>'}`
    stage.append(el)
    const rect = stage.getBoundingClientRect()
    el.style.left = `${clamp(event.clientX - rect.left, 0, rect.width - el.offsetWidth)}px`
    el.style.top = `${clamp(event.clientY - rect.top, 0, rect.height - el.offsetHeight)}px`
    popup = { el, fits, bar, value }
    el.addEventListener('click', ev => {
      const line = ev.target.closest('[data-pop]')
      if (line) addFit(popup.fits[Number(line.dataset.pop)])
    })
  }
  const addFit = fit => {
    const { bar, value } = popup
    closePopup()
    change(() => {
      const to = value !== undefined && ['control', 'enter'].includes(fit.kind) ? { to: value } : {}
      const move = newMove(fit.kind, BUTTON_MOVES.includes(fit.kind) ? Math.round(bar) : bar, state.controls,
        { ...fit.p, ...to })
      state.lab.moves.push(move)
      state.sel = { type: 'move', id: move.id }
    })
  }
  addEventListener('pointerdown', event => { if (popup && !popup.el.contains(event.target)) closePopup() }, true)

  // Moves and Lanes: a + at the bar under the pointer on a row's or a lane's empty space; a click there opens the
  // popup. A Moves row snaps to the bar; a lane to ¼ bar, whole bars on a button, the 4-bar line on Chapter, and takes
  // the value from the height on a knob or fader.
  const plus = Object.assign(document.createElement('div'), { className: 'tl-plus', textContent: '+' })
  const addSpot = event => {
    const lanes = state.level === 'lanes'
    if (!state.lab || drag || !(lanes || state.level === 'moves') ||
      event.target.closest('.tl-move, .tl-pop, [data-drag], [data-act]')) return null
    const area = event.target.closest(lanes ? '.tl-row[data-key] > .tl-area' : '.tl-row[data-stem] > .tl-area')
    if (!area) return null
    const rect = area.getBoundingClientRect()
    const at = (event.clientX - rect.left) / state.ppb
    if (!lanes) {
      const id = area.parentNode.dataset.stem
      return { area, grid: 1, bar: clamp(Math.floor(at), 0, state.lab.bars - 1),
        title: area.parentNode.querySelector('.tl-label').title, fits: movesFor(id, state.controls) }
    }
    const raw = area.parentNode.dataset.key
    const key = /^\d+$/.test(raw) ? Number(raw) : raw
    const control = state.controls.get(key)
    const grid = control?.name === 'Global Chapter' ? 4 : control?.button ? 1 : 0.25
    const svg = area.querySelector('svg')
    const height = Number(svg.getAttribute('height')), top = svg.getBoundingClientRect().top
    const value = control && !control.button
      ? round(clamp(snap((height - 5 - (event.clientY - top)) / (height - 10), 0.05), 0, 1), 2) : undefined
    return { area, grid, bar: clamp(snap(at, grid), 0, state.lab.bars - grid), title: keyLabel(key),
      fits: movesFor(key, state.controls), value }
  }
  stage.addEventListener('pointermove', event => {
    const spot = addSpot(event)
    if (!spot) return plus.remove()
    Object.assign(plus.style, { left: `${bx(spot.bar)}px`, width: `${Math.max(14, bx(spot.grid))}px` })
    if (plus.parentNode !== spot.area) spot.area.append(plus)
  })
  stage.addEventListener('pointerleave', () => plus.remove())
  stage.addEventListener('click', event => {
    const spot = !suppressClick && addSpot(event)
    if (spot) openPopup(event, spot.title, spot.fits, spot.bar, spot.value)
  })

  const typing = target => target.closest?.('input:not([type=range]):not([type=checkbox]), textarea, select')
  stage.addEventListener('keydown', event => { if (typing(event.target)) event.stopPropagation() })
  addEventListener('keydown', event => {
    if (!state.lab || stage.closest('.off-page') || typing(event.target)) return
    if (event.key >= '1' && event.key <= '5' && !event.metaKey && !event.ctrlKey) {
      state.level = LEVELS[Number(event.key) - 1][0]
      render()
    } else if ((event.metaKey || event.ctrlKey) && event.key === 'z') {
      event.preventDefault()
      undo()
    } else if (event.key === 'Escape') popup ? closePopup() : select(null)
    else if (event.key === 'Backspace' || event.key === 'Delete') {
      const sel = state.sel
      if (sel?.type === 'move') ACTIONS.deleteMove({ dataset: { id: sel.id } })
      else if (sel?.type === 'step') ACTIONS.deleteStep({ dataset: { move: sel.move, index: sel.index } })
    }
  })
  addEventListener('resize', () => { if (state.lab && !stage.closest('.off-page')) renderTimeline() })

  section.addEventListener('change', event => {
    if (event.target.dataset?.play !== 'from' || !state.lab) return
    state.from = phraseOf(Math.min(Number(event.target.value) || 0, state.lab.bars - 1))
    renderPlay()
  })

  return {
    show: () => {
      if (!state.tracks) return load()
      if (state.lab) render()
      refresh()
    },
    progress: p => {
      if (!p) {
        if (state.playing) Object.assign(state, { playing: null, playBar: null })
      } else if (p.script === state.playing) state.playBar = p.bar
      else return
      placePlayhead()
      const playSection = state.lab && state.playBar !== null ? sectionOf(state.lab, state.playBar)?.id ?? null : null
      if (playSection !== state.playSection && state.lab) {
        state.playSection = playSection
        renderTimeline()
      }
      const line = part('playing')
      if (p && line) line.textContent = `bar ${Math.floor(p.bar)} (from 0) of ${state.lab?.bars ?? '?'}` +
        `${p.section ? ` · ${p.section.name}` : ''}`
      else renderPlay()
    },
  }
}
