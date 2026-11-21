// The shape of a Sample Designer sound, drawn under the LCs of the SC MIDI panel (sc/ui/index.html): one hit of the
// sound, rendered dry by the server (POST /lab/sample/shape, sample-shape.mjs) each time a control moves, drawn four ways:
//   waveform     the hit over time, scaled to its peak
//   envelope     loudness over time in dB, with the attack (10 → 90 %) and the decay to -20 dB marked
//   spectrum     which frequencies the hit has (log axis 20 Hz-20 kHz, dB), with the centroid marked
//   spectrogram  how the frequencies change over time (bright = loud)
// and the numbers: peak, attack, decay, length, strongest frequency, centroid.
// Colours come from the page's CSS variables (the panel themes: --text, --off, --track, --accent).
const css = name => getComputedStyle(document.body).getPropertyValue(name).trim()
const ink = { fg: () => css('--text') || '#eee', dim: () => css('--off') || '#888', line: () => css('--track') || '#333',
  accent: () => css('--accent') || '#4fb3e0', mark: () => '#D85A30' }
const note = hz => {
  const names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
  const midi = Math.round(69 + 12 * Math.log2(hz / 440))
  return names[((midi % 12) + 12) % 12] + (Math.floor(midi / 12) - 1)
}
const hzText = hz => hz >= 1000 ? (hz / 1000).toFixed(1) + ' kHz' : Math.round(hz) + ' Hz'

const canvas = (box, title, width, height) => {
  const wrap = document.createElement('figure')
  wrap.innerHTML = `<figcaption>${title}</figcaption><canvas></canvas>`
  box.append(wrap)
  const el = wrap.querySelector('canvas')
  const ratio = window.devicePixelRatio || 1
  el.style.width = width + 'px'
  el.style.height = height + 'px'
  el.width = width * ratio
  el.height = height * ratio
  const ctx = el.getContext('2d')
  ctx.scale(ratio, ratio)
  ctx.font = '11px system-ui, sans-serif'
  return { ctx, width, height }
}

const axisText = (ctx, text, x, y, align = 'left') => {
  ctx.fillStyle = ink.dim()
  ctx.textAlign = align
  ctx.fillText(text, x, y)
}

const drawWaveform = ({ ctx, width, height }, shape) => {
  const mid = height / 2
  ctx.fillStyle = ink.accent()
  shape.waveform.forEach(([lo, hi], i) => {
    const x = i * width / shape.waveform.length
    ctx.fillRect(x, mid - hi * (mid - 4), Math.max(1, width / shape.waveform.length), Math.max(1, (hi - lo) * (mid - 4)))
  })
  axisText(ctx, '0', 2, height - 3)
  axisText(ctx, Math.round(shape.spanMs) + ' ms', width - 2, height - 3, 'right')
}

const drawEnvelope = ({ ctx, width, height }, shape) => {
  const { db, stepMs } = shape.envelope
  const span = db.length * stepMs
  const x = ms => ms / span * width
  const y = v => (Math.max(-60, v) / -60) * (height - 14) + 2
  ctx.strokeStyle = ink.line()
  for (const level of [-20, -40]) {
    ctx.beginPath(); ctx.moveTo(0, y(level)); ctx.lineTo(width, y(level)); ctx.stroke()
    axisText(ctx, level + ' dB', 2, y(level) - 2)
  }
  ctx.fillStyle = 'rgba(181, 101, 29, 0.35)'
  const peakAt = shape.peakMs
  ctx.fillRect(x(Math.max(0, peakAt - shape.attackMs)), 0, Math.max(1, x(shape.attackMs)), height - 12)
  ctx.fillStyle = 'rgba(79, 179, 224, 0.18)'
  ctx.fillRect(x(peakAt), 0, x(shape.decayMs), height - 12)
  ctx.strokeStyle = ink.fg()
  ctx.lineWidth = 1.5
  ctx.beginPath()
  db.forEach((v, i) => { const px = x(i * stepMs), py = y(v); i ? ctx.lineTo(px, py) : ctx.moveTo(px, py) })
  ctx.stroke()
  ctx.lineWidth = 1
  axisText(ctx, 'attack', x(peakAt), height - 2, 'right')
  axisText(ctx, 'decay to -20 dB', x(peakAt + shape.decayMs / 2), height - 2, 'center')
}

const drawSpectrum = ({ ctx, width, height }, shape) => {
  const { hz, db } = shape.spectrum
  const lo = Math.log(hz[0]), hi = Math.log(hz[hz.length - 1])
  const x = f => (Math.log(f) - lo) / (hi - lo) * width
  const y = v => (Math.max(-80, v) / -80) * (height - 14) + 2
  ctx.strokeStyle = ink.line()
  for (const f of [50, 100, 500, 1000, 5000, 10000]) {
    ctx.beginPath(); ctx.moveTo(x(f), 0); ctx.lineTo(x(f), height - 12); ctx.stroke()
    axisText(ctx, hzText(f), x(f), height - 2, 'center')
  }
  ctx.fillStyle = 'rgba(79, 179, 224, 0.35)'
  ctx.strokeStyle = ink.accent()
  ctx.beginPath()
  ctx.moveTo(0, y(-80))
  hz.forEach((f, i) => ctx.lineTo(x(f), y(db[i])))
  ctx.lineTo(width, y(-80))
  ctx.fill()
  ctx.stroke()
  ctx.strokeStyle = ink.mark()
  ctx.setLineDash([4, 3])
  ctx.beginPath(); ctx.moveTo(x(shape.centroidHz), 0); ctx.lineTo(x(shape.centroidHz), height - 12); ctx.stroke()
  ctx.setLineDash([])
  axisText(ctx, 'centroid', x(shape.centroidHz) + 3, 11)
}

const drawSpectrogram = ({ ctx, width, height }, shape) => {
  const { db, hz, stepMs } = shape.spectrogram
  const cols = db.length, rows = hz.length, h = height - 12
  for (let c = 0; c < cols; c++) {
    for (let r = 0; r < rows; r++) {
      const level = Math.max(0, 1 + db[c][r] / 70)
      ctx.fillStyle = `hsl(${200 - level * 170}, 80%, ${level * 62}%)`
      ctx.fillRect(c * width / cols, h - (r + 1) * h / rows, Math.ceil(width / cols), Math.ceil(h / rows))
    }
  }
  axisText(ctx, hzText(hz[rows - 1]), 2, 11)
  axisText(ctx, hzText(hz[0]), 2, h - 2)
  axisText(ctx, Math.round(cols * stepMs) + ' ms', width - 2, height - 2, 'right')
}

const ms = v => v < 1 ? '< 1 ms' : v + ' ms'

// box: an element with a .numbers and a .plots child; the plots share its width side by side
export const drawShape = (box, shape) => {
  const items = [['Peak', shape.peakDb + ' dB'], ['Attack', ms(shape.attackMs)], ['Decay', ms(shape.decayMs)],
    ['Length', ms(shape.lengthMs)], ['Strongest', hzText(shape.strongestHz) + ' (' + note(shape.strongestHz) + ')'],
    ['Centroid', hzText(shape.centroidHz)]]
  box.querySelector('.numbers').innerHTML = items.map(([k, v]) => `<span><b>${k}</b> ${v}</span>`).join('')
  const plots = box.querySelector('.plots')
  const width = Math.max(120, Math.floor((plots.clientWidth - 3 * 12) / 4))
  const height = Math.max(80, plots.clientHeight - 22)
  plots.innerHTML = ''
  drawWaveform(canvas(plots, 'Waveform', width, height), shape)
  drawEnvelope(canvas(plots, 'Envelope (dB)', width, height), shape)
  drawSpectrum(canvas(plots, 'Spectrum', width, height), shape)
  drawSpectrogram(canvas(plots, 'Spectrogram', width, height), shape)
}
