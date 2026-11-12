// Homotopy between the raw trajectory (amount 0) and its running average (amount 1), for the visuals.
// Each stem's x, y, z and e and the pulse's bpm, density and swing pass through an exponential moving average over
// N lines, N = 2^(53 · amount): 1 at 0 (raw), ~40 lines (≈ 1.3 s per stem at 30 lines/s) at 0.1, and at 1 the largest
// safe integer (2^53), where the average no longer moves. Onsets and the beat phase pass through unchanged.
// The averages keep running at every amount, so turning it up starts from where the music is, not from zero.

const MAX_BITS = Math.log2(Number.MAX_SAFE_INTEGER + 1)
export const LINES_PER_SECOND = 30

export const windowLines = amount => 2 ** (MAX_BITS * Math.min(1, Math.max(0, amount)))

export function describeWindow(amount) {
  if (amount >= 1) return '∞ (max_int)'
  const seconds = windowLines(amount) / LINES_PER_SECOND
  const units = [[365 * 86400, 'J'], [86400, 'd'], [3600, 'h'], [60, 'min'], [1, 's']]
  if (seconds < 1) return amount === 0 ? 'roh' : `${Math.round(seconds * 1000)} ms`
  const [size, unit] = units.find(([size]) => seconds >= size)
  const value = seconds / size
  return `${value < 10 ? value.toFixed(1) : Math.round(value).toLocaleString('de')} ${unit}`
}

export function createSmoother(onLine) {
  let amount = 0
  const averages = new Map()
  const average = (key, value) => {
    const previous = averages.get(key)
    const next = previous === undefined ? value : previous + (value - previous) / windowLines(amount)
    averages.set(key, next)
    return next
  }
  return {
    push(line) {
      if (line.pulse) {
        const { bpm, density, swing } = line.pulse
        onLine({ ...line, pulse: { ...line.pulse, bpm: average('bpm', bpm), density: average('density', density),
          swing: average('swing', swing) } })
        return
      }
      const key = line.stem
      onLine({ ...line, x: average(key + ':x', line.x), y: average(key + ':y', line.y), z: average(key + ':z', line.z),
        e: average(key + ':e', line.e) })
    },
    setAmount: value => { amount = Math.min(1, Math.max(0, value)) },
  }
}
