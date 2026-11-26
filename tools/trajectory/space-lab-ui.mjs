// The Space Analyzer page (Labs / Space): the sidebar holds the track, the render length and one row per stem (include,
// colour, pattern, knobs); the stage holds the map. Time runs left to right, frequency bottom to top (log), and every
// cell shows which of the included stems are there. Stems are rendered one at a time by the server (space-lab.mjs) and
// kept as level grids (space-analysis.mjs); include and colour only redraw, a changed setting renders that stem again.
//   mountSpaceLab({ section, stage }) → { show() }   show() loads the stem tracks on first use and redraws
import { BANDS, DIVISIONS, FLOOR_DB, activeStems, bandHz, defaultColors, fromBase64, levelsOf, occupancy, peakDb,
  regrid } from './space-analysis.mjs'

const DIVISION_LABELS = { 32: '1/32', 16: '1/16', 8: '1/8', 4: '1/4', 2: '1/2', 1: '1/1 (whole note)' }
const BAR_CHOICES = [4, 8, 16, 32]
const SHOWN_CHOICES = [1, 2, 4, 8, 16, 32]
const VIEWS = [['stems', 'Stems'], ['crowd', 'Crowding'], ['free', 'Free space']]
const TICKS = [50, 100, 200, 500, 1000, 2000, 5000, 10000]
const MARGIN = { left: 40, right: 36, top: 4, bottom: 38 }
const PALETTE = ['#AFA9EC', '#5DCAA5', '#F0997B', '#ED93B1', '#B4B2A9', '#85B7EB', '#97C459', '#EF9F27', '#F09595',
  '#7F77DD', '#1D9E75', '#D85A30', '#D4537E', '#888780', '#378ADD', '#639922', '#BA7517', '#E24B4A',
  '#534AB7', '#0F6E56', '#993C1D', '#993556', '#5F5E5A', '#185FA5', '#3B6D11', '#854F0B', '#A32D2D']

const hzText = hz => hz >= 1000 ? `${(hz / 1000).toFixed(hz >= 10000 ? 0 : 1)}k` : String(Math.round(hz))
const bandOfHz = hz => (BANDS - 1) * Math.log(hz / bandHz(0)) / Math.log(bandHz(BANDS - 1) / bandHz(0))
const escapeHtml = text => String(text).replace(/[&<>"]/g, char => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' })[char])

const savedColors = track => {
  try { return JSON.parse(localStorage.getItem(`space-colors:${track}`)) ?? {} } catch { return {} }
}
const saveColors = (track, stems) => {
  try { localStorage.setItem(`space-colors:${track}`, JSON.stringify(Object.fromEntries(stems.map(stem => [stem.slot, stem.color])))) } catch {}
}

export function mountSpaceLab({ section, stage }) {
  section.innerHTML = '<h2>Space</h2>' +
    '<label>Track <select data-field="track"></select></label>' +
    '<label>Render length <select data-field="bars"></select></label>' +
    '<div class="row"><button data-act="analyse">Analyse</button><button data-act="again" title="Render every stem again, ignoring the cache">Render again</button></div>' +
    '<output data-field="status"></output>' +
    '<div data-field="stems" class="space-stems"></div>'
  stage.innerHTML = '<div class="space-bar">' +
    `<div class="seg" data-field="view">${VIEWS.map(([id, label]) => `<button data-view="${id}" aria-pressed="${id === 'stems'}">${label}</button>`).join('')}</div>` +
    '<label>Cell size <select data-field="division"></select></label>' +
    '<label>Bars shown <select data-field="shown"></select></label>' +
    '<label>From bar <select data-field="from"></select></label>' +
    '<label>Active within <input type="range" data-field="threshold" min="10" max="60" step="1" value="35"><output data-field="thresholdText">35 dB</output></label>' +
    '</div><div class="space-map"><canvas></canvas></div><div class="space-info" data-field="info"></div>'

  const field = (root, name) => root.querySelector(`[data-field="${name}"]`)
  const side = name => field(section, name)
  const main = name => field(stage, name)
  const canvas = stage.querySelector('canvas')
  const option = (value, text, selected) => `<option value="${value}"${selected ? ' selected' : ''}>${text}</option>`

  main('division').innerHTML = DIVISIONS.map(value => option(value, DIVISION_LABELS[value], value === 8)).join('')
  side('bars').innerHTML = BAR_CHOICES.map(value => option(value, `${value} bars`, value === 8)).join('')

  let tracks = []
  let info = null
  let stems = []
  let view = 'stems'
  let run = 0
  let hover = null

  const post = async (route, body) => {
    const response = await fetch('lab/space/' + route,
      { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) })
    const result = await response.json().catch(() => ({}))
    if (!response.ok) throw new Error(result.error ?? `${route}: ${response.status}`)
    return result
  }

  const bars = () => Number(side('bars').value)
  const keyOf = stem => `${bars()}|${JSON.stringify(stem.setting)}`
  const stateOf = stem => stem.status === 'rendering' || stem.status === 'error' ? stem.status
    : stem.levels && stem.key === keyOf(stem) ? 'ready' : 'stale'
  const stale = () => stems.filter(stem => stateOf(stem) === 'stale').length

  const showStatus = text => { side('status').textContent = text ?? (stems.length
    ? (stale() ? `${stale()} of ${stems.length} stems need a render` : 'All stems rendered') : '') }

  const refreshRow = stem => {
    const state = stateOf(stem)
    stem.dot.dataset.state = state
    stem.dot.title = state === 'error' ? stem.error : { ready: 'Rendered', stale: 'Needs a render', rendering: 'Rendering …' }[state]
  }

  const palette = document.createElement('div')
  palette.className = 'space-colors'
  palette.hidden = true
  palette.innerHTML = PALETTE.map(color => `<button type="button" data-color="${color}" style="background:${color}" aria-label="${color}"></button>`).join('') +
    '<input data-field="hex" maxlength="7" placeholder="#rrggbb" aria-label="Hex colour">'
  section.append(palette)
  let picking = null

  const closeColors = () => { palette.hidden = true; picking = null }

  const openColors = (stem, anchor) => {
    if (picking?.stem === stem) return closeColors()
    picking = { stem, anchor }
    field(palette, 'hex').value = stem.color
    palette.hidden = false
    const rect = anchor.getBoundingClientRect()
    const { offsetWidth, offsetHeight } = palette
    palette.style.left = `${Math.max(8, Math.min(rect.left, innerWidth - offsetWidth - 8))}px`
    palette.style.top = `${rect.bottom + 4 + offsetHeight > innerHeight ? Math.max(8, rect.top - offsetHeight - 4) : rect.bottom + 4}px`
  }

  const setColor = color => {
    if (!picking) return
    picking.stem.color = color
    picking.anchor.style.background = color
    saveColors(info.track, stems)
    draw()
  }

  palette.onclick = event => {
    const color = event.target.dataset?.color
    if (color) { setColor(color); closeColors() }
  }
  field(palette, 'hex').onchange = event => {
    if (/^#[0-9a-f]{6}$/i.test(event.target.value)) setColor(event.target.value.toLowerCase())
  }
  document.addEventListener('pointerdown', event => {
    if (!palette.hidden && !palette.contains(event.target) && event.target !== picking?.anchor) closeColors()
  })
  document.addEventListener('keydown', event => { if (event.key === 'Escape') closeColors() })
  document.addEventListener('scroll', closeColors, true)

  const buildRows = () => {
    const container = side('stems')
    container.replaceChildren()
    const colors = savedColors(info.track)
    const fallback = defaultColors(info.slots.map(slot => slot.role))
    stems = info.slots.map((slot, index) => ({ ...slot, on: true, color: colors[slot.slot] ?? fallback[index],
      setting: { pattern: 0, k1: 0, k2: 0, k3: 0, fader: 1, b2: false }, levels: null, peak: FLOOR_DB, key: null, status: 'idle' }))
    for (const stem of stems) {
      const row = document.createElement('div')
      row.className = 'space-stem'
      const knob = key => `<label>${escapeHtml(stem.controls[key])} <output></output>` +
        `<input type="range" min="0" max="1" step="0.01" value="${stem.setting[key]}" data-setting="${key}"></label>`
      row.innerHTML = `<input type="checkbox" checked aria-label="Include ${escapeHtml(stem.name)}">` +
        `<button type="button" class="space-swatch" style="background:${stem.color}" aria-label="Colour of ${escapeHtml(stem.name)}"></button>` +
        `<span class="space-name"><i class="space-dot"></i>${escapeHtml(stem.name)} <small>${stem.slot}</small></span>` +
        `<select aria-label="Pattern of ${escapeHtml(stem.name)}">${stem.patterns.map((label, i) => option(i, escapeHtml(label))).join('')}</select>` +
        `<details><summary>Settings</summary>${['k1', 'k2', 'k3'].map(knob).join('')}` +
        `${knob('fader')}<label class="space-hold">${escapeHtml(stem.controls.b2)} (held) <input type="checkbox" data-setting="b2"></label></details>`
      stem.dot = row.querySelector('.space-dot')
      const [include, color, , pattern] = row.children
      include.onchange = () => { stem.on = include.checked; draw() }
      color.onclick = () => openColors(stem, color)
      pattern.onchange = () => { stem.setting.pattern = Number(pattern.value); change(stem) }
      for (const input of row.querySelectorAll('[data-setting]')) {
        const text = input.parentElement.querySelector('output')
        const show = () => { if (text) text.textContent = Number(input.value).toFixed(2) }
        show()
        input.oninput = () => {
          stem.setting[input.dataset.setting] = input.type === 'checkbox' ? input.checked : Number(input.value)
          show()
          change(stem)
        }
      }
      container.append(row)
      refreshRow(stem)
    }
    showStatus()
  }

  const change = stem => { refreshRow(stem); showStatus() }

  const analyse = async force => {
    if (!info) return
    const mine = ++run
    const todo = stems.filter(stem => force || stateOf(stem) !== 'ready')
    const started = Date.now()
    let done = 0
    for (const stem of todo) {
      stem.status = 'rendering'
      refreshRow(stem)
      showStatus(`Rendering ${stem.name} (${done + 1} of ${todo.length}) …`)
      try {
        const { footprint, cached } = await post('stem', { track: info.track, slot: stem.slot, setting: stem.setting, bars: bars(), force })
        if (mine !== run) return
        stem.levels = levelsOf({ l: fromBase64(footprint.l), r: fromBase64(footprint.r) })
        stem.peak = peakDb([stem.levels])
        stem.key = keyOf(stem)
        stem.status = 'idle'
        stem.error = null
        stem.cached = cached
      } catch (error) {
        if (mine !== run) return
        stem.status = 'error'
        stem.error = error.message
      }
      refreshRow(stem)
      done++
      draw()
    }
    const failed = stems.filter(stem => stem.status === 'error')
    showStatus(failed.length ? `${failed.length} failed: ${failed[0].error}`
      : `Done in ${((Date.now() - started) / 1000).toFixed(1)} s`)
  }

  const selectTrack = name => {
    run++
    info = tracks.find(entry => entry.track === name) ?? null
    stems = []
    side('stems').replaceChildren()
    if (info) buildRows()
    fillFrom()
    draw()
  }

  const fillFrom = () => {
    const shownChoices = SHOWN_CHOICES.filter(value => value <= bars())
    const current = Number(main('shown').value) || 4
    const shown = shownChoices.includes(current) ? current : shownChoices[shownChoices.length - 1]
    main('shown').innerHTML = shownChoices.map(value => option(value, value, value === shown)).join('')
    const from = Math.min(Number(main('from').value) || 1, bars() - shown + 1)
    main('from').innerHTML = Array.from({ length: bars() - shown + 1 }, (_, i) => option(i + 1, i + 1, i + 1 === from)).join('')
  }

  const colorOf = name => getComputedStyle(document.body).getPropertyValue(name).trim() || '#888'

  function draw() {
    const box = canvas.parentElement
    const width = box.clientWidth
    const height = box.clientHeight
    if (width < 80 || height < 80) return
    const ratio = window.devicePixelRatio || 1
    canvas.width = Math.round(width * ratio)
    canvas.height = Math.round(height * ratio)
    canvas.style.width = `${width}px`
    canvas.style.height = `${height}px`
    const ctx = canvas.getContext('2d')
    ctx.setTransform(ratio, 0, 0, ratio, 0, 0)
    ctx.clearRect(0, 0, width, height)
    ctx.font = '11px sans-serif'
    const dim = colorOf('--dim')
    const line = colorOf('--line')
    const ready = stems.filter(stem => stem.on && stem.levels)
    hover = null
    if (!ready.length) {
      ctx.fillStyle = dim
      ctx.textAlign = 'center'
      ctx.fillText(info ? (stems.some(stem => stem.levels) ? 'No stem is included.' : 'Press Analyse to render the stems.') : 'No stem tracks found.',
        width / 2, height / 2)
      main('info').textContent = ''
      return
    }
    const division = Number(main('division').value)
    const shown = Number(main('shown').value)
    const from = Number(main('from').value) - 1
    const thresholdDb = Number(main('threshold').value)
    const plotW = width - MARGIN.left - MARGIN.right
    const plotH = height - MARGIN.top - MARGIN.bottom
    const cells = shown * division
    const cellW = plotW / cells
    const bandH = plotH / BANDS
    const grids = ready.map(stem => regrid(stem.levels, { division, from, bars: shown }))
    const referenceDb = Math.max(...ready.map(stem => stem.peak))
    const occ = occupancy(grids, { referenceDb, thresholdDb })
    const limit = referenceDb - thresholdDb
    for (let cell = 0; cell < cells; cell++) {
      for (let band = 0; band < BANDS; band++) {
        const at = cell * BANDS + band
        const count = occ.count[at]
        const x = MARGIN.left + cell * cellW
        const y = MARGIN.top + plotH - (band + 1) * bandH
        if (view === 'stems') {
          if (!count) continue
          ctx.globalAlpha = Math.min(1, Math.max(0.15, (occ.loudestDb[at] - limit) / thresholdDb)) * 0.95
          ctx.fillStyle = ready[occ.loudest[at]].color
        } else if (view === 'crowd') {
          if (!count) continue
          ctx.globalAlpha = Math.min(1, 0.12 + count * 0.2)
          ctx.fillStyle = '#D85A30'
        } else if (count) {
          ctx.globalAlpha = 0.25
          ctx.fillStyle = line
        } else {
          ctx.globalAlpha = 0.6
          ctx.fillStyle = '#1D9E75'
        }
        ctx.fillRect(x, y, cellW + 0.5, bandH + 0.5)
      }
    }
    ctx.globalAlpha = 1
    ctx.strokeStyle = line
    ctx.lineWidth = 0.5
    ctx.globalAlpha = 0.5
    for (const hz of TICKS) {
      const y = MARGIN.top + plotH - bandOfHz(hz) / (BANDS - 1) * plotH
      ctx.beginPath(); ctx.moveTo(MARGIN.left, y); ctx.lineTo(MARGIN.left + plotW, y); ctx.stroke()
    }
    for (let cell = 0; cell <= cells; cell += Math.max(1, division / 4)) {
      ctx.beginPath(); ctx.moveTo(MARGIN.left + cell * cellW, MARGIN.top); ctx.lineTo(MARGIN.left + cell * cellW, MARGIN.top + plotH); ctx.stroke()
    }
    ctx.globalAlpha = 1
    ctx.lineWidth = 1
    for (let cell = 0; cell <= cells; cell += division) {
      ctx.beginPath(); ctx.moveTo(MARGIN.left + cell * cellW, MARGIN.top); ctx.lineTo(MARGIN.left + cell * cellW, MARGIN.top + plotH); ctx.stroke()
    }
    ctx.strokeRect(MARGIN.left, MARGIN.top, plotW, plotH)
    ctx.fillStyle = dim
    ctx.textAlign = 'right'
    ctx.textBaseline = 'middle'
    for (const hz of TICKS) ctx.fillText(hzText(hz), MARGIN.left - 5, MARGIN.top + plotH - bandOfHz(hz) / (BANDS - 1) * plotH)
    ctx.textAlign = 'center'
    ctx.textBaseline = 'top'
    const labelEvery = Math.max(1, Math.ceil(shown / Math.max(1, Math.floor(plotW / 60))))
    for (let bar = 0; bar < shown; bar += labelEvery) ctx.fillText(`bar ${from + bar + 1}`, MARGIN.left + (bar + 0.5) * division * cellW, MARGIN.top + plotH + 18)
    const stripTop = MARGIN.top + plotH + 3
    ctx.fillStyle = dim
    for (let cell = 0; cell < cells; cell++) {
      const share = occ.cellShare[cell]
      ctx.globalAlpha = 0.15 + 0.7 * share
      ctx.fillRect(MARGIN.left + cell * cellW + 0.5, stripTop + 11 * (1 - share), Math.max(1, cellW - 1), 11 * share + 1)
    }
    for (let band = 0; band < BANDS; band++) {
      const share = occ.bandShare[band]
      ctx.globalAlpha = 0.7
      ctx.fillStyle = share > 0.8 ? '#D85A30' : share < 0.2 ? '#1D9E75' : dim
      ctx.fillRect(MARGIN.left + plotW + 4, MARGIN.top + plotH - (band + 1) * bandH, (MARGIN.right - 8) * share, bandH)
    }
    ctx.globalAlpha = 1
    ctx.fillStyle = dim
    ctx.textAlign = 'left'
    ctx.fillText('used', MARGIN.left + plotW + 4, stripTop)

    let worst = 0
    occ.bandShare.forEach((share, band) => { if (share > occ.bandShare[worst]) worst = band })
    const summary = `${ready.length} stems on · ${Math.round(occ.emptyShare * 100)}% of cells empty · most used band: ` +
      `about ${hzText(bandHz(worst))} Hz (${Math.round(occ.bandShare[worst] * 100)}% of the time)`
    main('info').textContent = summary
    hover = { division, from, cells, cellW, bandH, plotW, plotH, grids, ready, referenceDb, thresholdDb, summary }
  }

  canvas.onmousemove = event => {
    if (!hover) return
    const rect = canvas.getBoundingClientRect()
    const cell = Math.floor((event.clientX - rect.left - MARGIN.left) / hover.cellW)
    const band = BANDS - 1 - Math.floor((event.clientY - rect.top - MARGIN.top) / hover.bandH)
    if (cell < 0 || cell >= hover.cells || band < 0 || band >= BANDS) return void (main('info').textContent = hover.summary)
    const active = activeStems(hover.grids, cell, band, hover)
    const bar = hover.from + Math.floor(cell / hover.division) + 1
    const beat = ((cell % hover.division) / hover.division * 4 + 1).toFixed(2)
    main('info').textContent = `bar ${bar}, beat ${beat} · about ${hzText(bandHz(band))} Hz · ` +
      (active.length ? active.map(entry => `${hover.ready[entry.index].name} ${Math.round(entry.db)} dB`).join(', ') : 'free')
  }
  canvas.onmouseleave = () => { if (hover) main('info').textContent = hover.summary }

  side('track').onchange = () => selectTrack(side('track').value)
  side('bars').onchange = () => { fillFrom(); for (const stem of stems) refreshRow(stem); showStatus(); draw() }
  section.querySelector('[data-act=analyse]').onclick = () => analyse(false)
  section.querySelector('[data-act=again]').onclick = () => analyse(true)
  for (const name of ['division', 'shown', 'from']) main(name).onchange = () => { if (name === 'shown') fillFrom(); draw() }
  main('threshold').oninput = () => { main('thresholdText').textContent = `${main('threshold').value} dB`; draw() }
  for (const button of stage.querySelectorAll('[data-view]')) {
    button.onclick = () => {
      view = button.dataset.view
      for (const other of stage.querySelectorAll('[data-view]')) other.setAttribute('aria-pressed', String(other === button))
      draw()
    }
  }
  new ResizeObserver(() => draw()).observe(canvas.parentElement)

  const show = async () => {
    if (!tracks.length) {
      try {
        tracks = (await post('tracks', {})).tracks
        side('track').innerHTML = tracks.map(entry => option(entry.track, `${entry.track} · ${entry.tempo} bpm`, entry.track === '009-house-2')).join('')
        selectTrack(side('track').value)
      } catch (error) {
        showStatus(error.message)
      }
    }
    draw()
  }
  return { show }
}
