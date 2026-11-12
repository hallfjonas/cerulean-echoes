// Trajectory analysis of a stereo signal: five frequency bands stand in for stems, plus one global pulse.
// Shared by the browser page (index.html) and the Node CLI (analyse-file.mjs). Each emitted frame is a list of lines:
//   { t, stem, x, y, z, e, on }   per band: x pan -1..1, y log frequency (20 Hz-20 kHz → 0..1; the strongest partial
//                                 in tonal bands, the spectral centroid in noisy ones, blended by flatness), z depth 0..1
//                                 (L/R decorrelation, a reverb/width proxy), e energy 0..1, on 1 if an onset fell in
//                                 this frame
//   { t, pulse: { bpm, phase, density, swing } }   phase 0..1 within the beat, density = share of the last bar's 16ths
//                                 with an onset, swing = mean delay of off-16th onsets in 16ths

export const BANDS = [
  { stem: 'kick', lo: 30, hi: 110 },
  { stem: 'bass', lo: 110, hi: 350 },
  { stem: 'mid', lo: 350, hi: 2000 },
  { stem: 'presence', lo: 2000, hi: 6000 },
  { stem: 'air', lo: 6000, hi: 16000 },
]

const EPS = 1e-12
const clamp = (v, lo = 0, hi = 1) => Math.min(hi, Math.max(lo, v))
const round = v => Math.round(v * 1000) / 1000
const frac = v => v - Math.floor(v)

function fftTables(n) {
  const bits = Math.log2(n), rev = new Uint32Array(n), cos = new Float64Array(n / 2), sin = new Float64Array(n / 2)
  for (let i = 0; i < n; i++) {
    let r = 0
    for (let b = 0; b < bits; b++) r |= ((i >> b) & 1) << (bits - 1 - b)
    rev[i] = r
  }
  for (let i = 0; i < n / 2; i++) { cos[i] = Math.cos(-2 * Math.PI * i / n); sin[i] = Math.sin(-2 * Math.PI * i / n) }
  return { rev, cos, sin }
}

function fft(re, im, { rev, cos, sin }) {
  const n = re.length
  for (let i = 0; i < n; i++) {
    const j = rev[i]
    if (j > i) { [re[i], re[j]] = [re[j], re[i]]; [im[i], im[j]] = [im[j], im[i]] }
  }
  for (let len = 2; len <= n; len *= 2) {
    const half = len / 2, step = n / len
    for (let start = 0; start < n; start += len) {
      for (let k = 0; k < half; k++) {
        const a = start + k, b = a + half, wr = cos[k * step], wi = sin[k * step]
        const tr = re[b] * wr - im[b] * wi, ti = re[b] * wi + im[b] * wr
        re[b] = re[a] - tr; im[b] = im[a] - ti; re[a] += tr; im[a] += ti
      }
    }
  }
}

function createSpectrum(n) {
  return { n, tables: fftTables(n), re: new Float64Array(n), im: new Float64Array(n),
    hann: Float64Array.from({ length: n }, (_, i) => 0.5 - 0.5 * Math.cos(2 * Math.PI * i / n)) }
}

function transform(spectrum, left, right) {
  const { n, re, im, hann } = spectrum, offset = left.length - n
  for (let i = 0; i < n; i++) { re[i] = left[offset + i] * hann[i]; im[i] = right[offset + i] * hann[i] }
  fft(re, im, spectrum.tables)
}

// both channels share one complex FFT (left = real part, right = imaginary part); this splits bin k back into them
function channels({ n, re, im }, k) {
  const m = (n - k) % n
  return [(re[k] + re[m]) / 2, (im[k] - im[m]) / 2, (im[k] + im[m]) / 2, (re[m] - re[k]) / 2]
}

const binRange = (lo, hi, n, sampleRate) =>
  [Math.max(1, Math.ceil(lo * n / sampleRate)), Math.min(n / 2 - 1, Math.floor(hi * n / sampleRate))]

function dominantFrequency(spectrum, [from, to], sampleRate) {
  const bins = to - from + 1, power = new Float64Array(bins)
  let total = 0, weighted = 0, logSum = 0, top = 0
  for (let i = 0; i < bins; i++) {
    const [lRe, lIm, rRe, rIm] = channels(spectrum, from + i)
    power[i] = lRe * lRe + lIm * lIm + rRe * rRe + rIm * rIm
    total += power[i]; weighted += power[i] * (from + i); logSum += Math.log(power[i] + EPS)
    if (power[i] > power[top]) top = i
  }
  if (total <= EPS) return (from + to) / 2 * sampleRate / spectrum.n
  const [a, b, c] = [power[top - 1] ?? 0, power[top], power[top + 1] ?? 0].map(p => Math.log(p + EPS))
  const shift = top > 0 && top < bins - 1 && a - 2 * b + c < 0 ? clamp(0.5 * (a - c) / (a - 2 * b + c), -0.5, 0.5) : 0
  const tonality = clamp(1 - 4 * Math.exp(logSum / bins) / (total / bins))
  return (tonality * (from + top + shift) + (1 - tonality) * weighted / total) * sampleRate / spectrum.n
}

// Bands up to `pitchLimit` Hz take their pitch from a long window: at 2048 samples one bin is 21.5 Hz wide, wider
// than the step between two bass notes. Energy, pan, depth and onsets always come from the short, fast window.
export function createAnalyser({ sampleRate, size = 2048, pitchSize = 8192, pitchLimit = 400, hop = 512, fps = 30,
  tempoWindow = 6 }) {
  const frameRate = sampleRate / hop
  const short = createSpectrum(size), long = createSpectrum(pitchSize)
  const peakDecay = 0.25 ** (1 / (10 * frameRate))
  const historyLength = Math.round(0.5 * frameRate)
  const bands = BANDS.map(({ stem, lo, hi }) => {
    const [from, to] = binRange(lo, hi, size, sampleRate), pitchSpectrum = hi <= pitchLimit ? long : short
    return { stem, from, to, pitchSpectrum, pitchBins: binRange(lo, hi, pitchSpectrum.n, sampleRate),
      prev: new Float64Array(to - from + 1), peak: EPS, flux: [], fluxMean: EPS, lastOnset: -1, on: 0 }
  })
  const envLength = Math.round(tempoWindow * frameRate)
  const env = new Float64Array(envLength)
  const bpmEstimates = []
  const onsets = []
  let frame = 0, nextEmit = 0, bpm = 0, anchor = 0, lastTempoFrame = -Infinity

  function analyseBand(band, t) {
    let powerL = 0, powerR = 0, cross = 0, flux = 0
    for (let k = band.from; k <= band.to; k++) {
      const [lRe, lIm, rRe, rIm] = channels(short, k)
      const pL = lRe * lRe + lIm * lIm, pR = rRe * rRe + rIm * rIm, i = k - band.from
      powerL += pL; powerR += pR; cross += lRe * rRe + lIm * rIm
      const mag = Math.log1p(1000 * Math.sqrt(pL + pR) / size)
      flux += Math.max(0, mag - band.prev[i])
      band.prev[i] = mag
    }
    const power = powerL + powerR
    band.peak = Math.max(power, band.peak * peakDecay)
    const e = clamp(1 + 10 * Math.log10((power + EPS) / band.peak) / 40)
    const ampL = Math.sqrt(powerL), ampR = Math.sqrt(powerR)
    const frequency = dominantFrequency(band.pitchSpectrum, band.pitchBins, sampleRate)

    const history = band.flux
    const mean = history.reduce((s, v) => s + v, 0) / (history.length || 1)
    const std = Math.sqrt(history.reduce((s, v) => s + (v - mean) ** 2, 0) / (history.length || 1))
    const [beforeLast, last] = [history.at(-2) ?? 0, history.at(-1) ?? 0]
    if (last > beforeLast && last >= flux && last > mean + 1.5 * std && e > 0.3 && t - band.lastOnset > 0.05) {
      band.lastOnset = t
      band.on = 1
      onsets.push(t - 1 / frameRate)
    }
    history.push(flux)
    if (history.length > historyLength) history.shift()
    band.fluxMean = 0.99 * band.fluxMean + 0.01 * flux

    return {
      stem: band.stem,
      x: (ampR - ampL) / (ampR + ampL + EPS),
      y: clamp(Math.log(frequency / 20) / Math.log(1000)),
      z: power > EPS ? clamp(1 - cross / Math.sqrt(powerL * powerR + EPS)) : 0,
      e,
      flux: flux / (band.fluxMean + EPS),
    }
  }

  function updateTempo(t) {
    const filled = Math.min(frame, envLength)
    if (filled < envLength / 2) return
    const series = Array.from({ length: filled }, (_, i) => env[(frame - filled + i) % envLength])
    const mean = series.reduce((s, v) => s + v, 0) / filled
    const centred = series.map(v => v - mean)
    const lagFor = b => 60 * frameRate / b
    const minLag = Math.floor(lagFor(180)), maxLag = Math.ceil(lagFor(80))
    const score = []
    for (let lag = minLag; lag <= maxLag + 1; lag++) {
      let sum = 0
      for (let i = lag; i < filled; i++) sum += centred[i] * centred[i - lag]
      const candidate = 60 * frameRate / lag
      score[lag] = sum / (filled - lag) * Math.exp(-0.5 * (Math.log2(candidate / 125) / 0.6) ** 2)
    }
    let best = minLag + 1
    for (let lag = minLag + 1; lag <= maxLag; lag++) if (score[lag] > score[best]) best = lag
    const [a, b, c] = [score[best - 1], score[best], score[best + 1]]
    const offset = a - 2 * b + c === 0 ? 0 : 0.5 * (a - c) / (a - 2 * b + c)
    bpmEstimates.push(60 * frameRate / (best + clamp(offset, -0.5, 0.5)))
    if (bpmEstimates.length > 5) bpmEstimates.shift()
    bpm = [...bpmEstimates].sort((p, q) => p - q)[Math.floor(bpmEstimates.length / 2)]

    const period = lagFor(bpm)
    let bestShift = 0, bestScore = -Infinity
    for (let shift = 0; shift < Math.ceil(period); shift++) {
      let sum = 0
      for (let k = 0; shift + k * period < filled; k++) sum += series[filled - 1 - Math.round(shift + k * period)]
      if (sum > bestScore) { bestScore = sum; bestShift = shift }
    }
    anchor = t - bestShift / frameRate
  }

  function pulse(t) {
    if (!bpm) return { bpm: 0, phase: 0, density: 0, swing: 0 }
    const beat = 60 / bpm, sixteenth = beat / 4
    while (onsets.length && onsets[0] < t - 8 * beat) onsets.shift()
    const slots = new Set(onsets.filter(o => o >= t - 4 * beat).map(o => Math.round((o - anchor) / sixteenth)))
    const positions = onsets.map(o => (o - anchor) / sixteenth)
    const meanDeviation = ps => ps.length ? ps.reduce((s, p) => s + p - Math.round(p), 0) / ps.length : 0
    const offbeats = positions.filter(p => Math.round(p) % 2 !== 0), onbeats = positions.filter(p => Math.round(p) % 2 === 0)
    const swing = offbeats.length && onbeats.length ? meanDeviation(offbeats) - meanDeviation(onbeats) : 0
    return { bpm: round(bpm), phase: round(frac((t - anchor) / beat)), density: round(clamp(slots.size / 16)),
      swing: round(swing) }
  }

  // left, right: the newest `pitchSize` samples of each channel; t: time in seconds of the last sample
  function analyse(left, right, t) {
    transform(short, left, right)
    transform(long, left, right)
    const results = bands.map(band => analyseBand(band, t))
    env[frame % envLength] = results.reduce((s, r) => s + r.flux, 0)
    frame++
    if (frame - lastTempoFrame >= frameRate / 2) { updateTempo(t); lastTempoFrame = frame }
    if (t < nextEmit) return []
    nextEmit = Math.max(nextEmit + 1 / fps, t)
    const time = round(t)
    const lines = results.map(({ stem, x, y, z, e }, i) => {
      const line = { t: time, stem, x: round(x), y: round(y), z: round(z), e: round(e), on: bands[i].on }
      bands[i].on = 0
      return line
    })
    lines.push({ t: time, pulse: pulse(t) })
    return lines
  }

  return { size: pitchSize, hop, frameRate, analyse }
}
