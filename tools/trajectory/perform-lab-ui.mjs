// The Tracks lab page (Labs / Tracks): the sidebar picks a live track and one of its performances (perform-lab.mjs
// lists them); the stage shows the performance, for now at the Steps level: its script v2 steps in bar order, bars
// counted from 0, with the track's control names.
//   mountTracksLab({ section, stage }) → { show() }   show() loads the tracks on first use
const TAKE_PREFIX = 'takes/'

const escapeHtml = text => String(text).replace(/[&<>"]/g, char =>
  ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[char])
const option = (value, text) => `<option value="${escapeHtml(value)}">${escapeHtml(text)}</option>`

// bars of 4 beats at `bpm` as m:ss
export const minutesOf = (bars, bpm) => {
  const seconds = Math.round(bars * 240 / bpm)
  return `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, '0')}`
}

export const stepKind = step => ['keys', 'pad', 'lk', 'press'].find(kind => kind in step) ?? 'cc'

const stepRow = (step, controls) => {
  const kind = stepKind(step)
  const control = { keys: () => step.keys, pad: () => `pad ${step.pad}`, lk: () => `LK ${step.lk}`,
    press: () => controls.get(step.press)?.name ?? `CC ${step.press}`,
    cc: () => controls.get(step.cc)?.name ?? `CC ${step.cc}` }[kind]()
  const value = step.value ?? step.velocity ?? ''
  const span = step.ramp ?? step.length ?? ''
  return `<tr><td>${step.bar}</td><td>${kind}</td><td>${escapeHtml(control)}</td><td>${value}</td><td>${span}</td></tr>`
}

const performanceLabel = performance => {
  const name = performance.name.startsWith(TAKE_PREFIX)
    ? `take ${performance.name.slice(TAKE_PREFIX.length)}`
    : performance.title ? `${performance.title} (${performance.name})` : performance.name
  return performance.error ? `${name} (unreadable)` : name
}

export function mountTracksLab({ section, stage }) {
  section.innerHTML = '<h2>Tracks</h2>' +
    '<label>Track <select data-field="track"></select></label>' +
    '<label>Performance <select data-field="performance"></select></label>' +
    '<output data-field="status"></output>'
  stage.innerHTML = '<div class="tracks-head" data-field="head"></div><div class="tracks-body" data-field="body"></div>'

  const field = (root, name) => root.querySelector(`[data-field="${name}"]`)
  const side = name => field(section, name)
  const main = name => field(stage, name)
  let tracks = null, info = null, run = 0

  const post = async (route, body) => {
    const response = await fetch('lab/tracks/' + route,
      { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
    const result = await response.json().catch(() => ({}))
    if (!response.ok) throw new Error(result.error ?? `${route}: ${response.status}`)
    return result
  }
  const trackOf = id => tracks.find(track => track.track === id)

  const showScript = (script, performance) => {
    const controls = new Map(info.controls)
    const bars = script.bars ?? Math.ceil(Math.max(0, ...script.steps.map(step =>
      step.bar + (step.ramp ?? 0) + (step.length ?? 0))))
    const length = info.tempo ? `${bars} bars · ${minutesOf(bars, info.tempo)} at ${info.tempo} BPM` : `${bars} bars`
    main('head').innerHTML = `<h2>${escapeHtml(script.title ?? performance.name)}</h2>` +
      `<p>${escapeHtml([length, `${script.steps.length} steps`, script.mood].filter(Boolean).join(' · '))}</p>`
    const steps = [...script.steps].sort((a, b) => a.bar - b.bar)
    main('body').innerHTML = '<table class="tracks-steps"><tr><th>bar (from 0)</th><th>kind</th><th>control</th>' +
      `<th>value</th><th>ramp / length</th></tr>${steps.map(step => stepRow(step, controls)).join('')}</table>`
  }

  const openPerformance = async () => {
    const mine = ++run
    const track = side('track').value
    const performance = trackOf(track)?.performances.find(entry => entry.name === side('performance').value)
    main('head').innerHTML = ''
    main('body').innerHTML = ''
    if (!performance) return void (side('status').textContent = 'No performance for this track yet.')
    if (performance.error) return void (side('status').textContent = performance.error)
    side('status').textContent = 'loading …'
    try {
      if (info?.track !== track) info = await post('track', { track })
      const response = await fetch(`perform/${encodeURIComponent(track)}/${encodeURIComponent(performance.name)}`,
        { cache: 'no-store' })
      if (!response.ok) throw new Error(`${performance.name}: ${response.status}`)
      const script = await response.json()
      if (mine !== run) return
      showScript(script, performance)
      side('status').textContent = ''
    } catch (error) {
      if (mine === run) side('status').textContent = error.message
    }
  }

  const fillPerformances = () => {
    const performances = trackOf(side('track').value)?.performances ?? []
    side('performance').innerHTML = performances.map(entry => option(entry.name, performanceLabel(entry))).join('')
    side('performance').disabled = !performances.length
    openPerformance()
  }

  side('track').onchange = fillPerformances
  side('performance').onchange = openPerformance

  const load = async () => {
    side('status').textContent = 'loading …'
    try {
      tracks = (await post('tracks', {})).tracks
      side('track').innerHTML = tracks.map(track => option(track.track, track.performances.length
        ? `${track.label} (${track.performances.length})` : track.label)).join('')
      side('track').value = tracks.find(track => track.performances.length)?.track ?? tracks[0]?.track ?? ''
      fillPerformances()
    } catch (error) {
      tracks = null
      side('status').textContent = error.message
    }
  }

  return { show: () => { if (!tracks) load() } }
}
