// Replay fidelity, the pure part: compares the tapped Strudel events of an original play with those of its replay and
// reports, per bar, what differs and the likely reason. Runs in Node (check-replay.mjs, take-save.mjs) and in tests.
// An event is { stem, cycle, value, duration, … } as the tap posts it (make-tapped.mjs), `cycle` counted from the
// load's bar line (take.mjs); `delay` and `cps` are when it was sent, not what was played, and are left out.
// Two events are the same when stem, cycle (6 decimals), duration (4 decimals) and every tapped value match.
// A difference is paired up where it can be, which names the reason:
//   value   same stem and place, other values: a control read another value at that query (a take's ramps follow the
//           played moves within 1 MIDI step, so one step off is expected now and then)
//   timing  same stem and values, up to TIMING_BARS away: a key, press or move landed one query off
//   only    an event of one play with no partner: a stem or pattern state differs (button state, level, randomness)
// Bars are compared from 0 up to the last bar both plays finished (Save cuts the last bar off).
export const TIMING_BARS = 0.1
const EPSILON = 1e-6

const sortedValue = value => Object.fromEntries(Object.entries(value ?? {}).sort(([a], [b]) => a < b ? -1 : 1))
const valueKey = event => JSON.stringify(sortedValue(event.value))
const placeKey = event => `${event.stem}|${event.cycle.toFixed(6)}|${(event.duration ?? 0).toFixed(4)}`
const keyOf = event => `${placeKey(event)}|${valueKey(event)}`
const barOf = event => Math.floor(event.cycle + EPSILON)

// The events of an events file (take-save.mjs: one batch per line)
export const parseEvents = text => text.split('\n').filter(line => line.trim()).flatMap(line => JSON.parse(line))

const byBar = events => {
  const bars = new Map()
  for (const event of events) {
    const bar = barOf(event)
    if (bar >= 0) bars.set(bar, [...bars.get(bar) ?? [], event])
  }
  return bars
}

const unmatched = (original, replay) => {
  const counts = new Map()
  for (const event of replay) counts.set(keyOf(event), [...counts.get(keyOf(event)) ?? [], event])
  const missing = []
  for (const event of original) {
    const same = counts.get(keyOf(event))
    if (same?.length) same.pop()
    else missing.push(event)
  }
  return { missing, extra: [...counts.values()].flat() }
}

const changedFields = (a, b) => [...new Set([...Object.keys(a.value ?? {}), ...Object.keys(b.value ?? {})])]
  .filter(key => a.value?.[key] !== b.value?.[key]).sort()

const takePartner = (extra, test) => {
  const index = extra.findIndex(test)
  return index < 0 ? null : extra.splice(index, 1)[0]
}

// One bar's differences: { values: [{ stem, cycle, fields }], timing: [{ stem, cycle, shift }], onlyOriginal,
// onlyReplay } (events), all empty when the bar is identical
export const compareBar = (original, replay) => {
  const { missing, extra } = unmatched(original, replay)
  const values = [], timing = [], onlyOriginal = []
  for (const event of missing) {
    const sameplace = takePartner(extra, other => placeKey(other) === placeKey(event))
    if (sameplace) {
      values.push({ stem: event.stem, cycle: event.cycle, fields: changedFields(event, sameplace) })
      continue
    }
    const shifted = takePartner(extra, other => other.stem === event.stem && valueKey(other) === valueKey(event) &&
      Math.abs(other.cycle - event.cycle) <= TIMING_BARS + EPSILON)
    if (shifted) timing.push({ stem: event.stem, cycle: event.cycle, shift: shifted.cycle - event.cycle })
    else onlyOriginal.push(event)
  }
  return { values, timing, onlyOriginal, onlyReplay: extra }
}

const isSame = diff => !diff.values.length && !diff.timing.length && !diff.onlyOriginal.length &&
  !diff.onlyReplay.length

const lastFullBar = events => events.length ? Math.max(...events.map(barOf)) : 0

// { bars: compared bar count, originalBars, replayBars, same: identical bar count, differing: [{ bar, ...diff }] }
// (bar 0-based; originalBars / replayBars: the bars each play finished)
export const compareEvents = (original, replay) => {
  const originalBars = lastFullBar(original), replayBars = lastFullBar(replay)
  const bars = Math.min(originalBars, replayBars)
  const [a, b] = [byBar(original), byBar(replay)]
  const differing = []
  for (let bar = 0; bar < bars; bar++) {
    const diff = compareBar(a.get(bar) ?? [], b.get(bar) ?? [])
    if (!isSame(diff)) differing.push({ bar, ...diff })
  }
  return { bars, originalBars, replayBars, same: bars - differing.length, differing }
}

const stemList = events => {
  const counts = new Map()
  for (const { stem } of events) counts.set(stem, (counts.get(stem) ?? 0) + 1)
  return [...counts].map(([stem, n]) => `${stem} ${n}`).join(', ')
}
const round = (value, decimals) => Math.round(value * 10 ** decimals) / 10 ** decimals
const signed = value => (value > 0 ? '+' : '') + round(value, 3)

// One line for a differing bar (bar numbers 1-based, as the player shows them): what differs, then why
export const barLine = ({ bar, values, timing, onlyOriginal, onlyReplay }) => {
  const parts = []
  if (values.length) {
    const fields = [...new Set(values.flatMap(v => v.fields))].join(', ')
    parts.push(`${values.length} events with other ${fields} (${stemList(values)}): a control read another value ` +
      '(a thinned ramp is off by up to 1 MIDI step, or a move landed a query off)')
  }
  if (timing.length) {
    const shifts = [...new Set(timing.map(t => signed(t.shift)))].join(' ')
    parts.push(`${timing.length} events moved ${shifts} bar (${stemList(timing)}): a key, press or move landed a ` +
      'query off')
  }
  if (onlyOriginal.length) parts.push(`only in the original: ${stemList(onlyOriginal)}`)
  if (onlyReplay.length) parts.push(`only in the replay: ${stemList(onlyReplay)}`)
  if (onlyOriginal.length || onlyReplay.length) parts.push('a stem or pattern state differs (button state, level, ' +
    'randomness)')
  return `bar ${bar + 1}: ${parts.join('; ')}`
}

// The verdict as one line
export const summaryLine = result => {
  if (!result.bars) return 'cannot check: no bar finished in both plays'
  if (!result.differing.length) return `reproduced: all ${result.bars} bars identical`
  const first = result.differing.map(d => d.bar + 1).slice(0, 5).join(', ')
  return `NOT reproduced: ${result.differing.length} of ${result.bars} bars differ (bar ${first}` +
    `${result.differing.length > 5 ? ' …' : ''})`
}
