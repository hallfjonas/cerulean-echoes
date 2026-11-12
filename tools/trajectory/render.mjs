// Draws a live trajectory on a canvas. Stems are created as they arrive, so it shows five audio bands as well as the
// sixteen stems of a tapped Strudel track. Feed it lines in the trajectory format (see analyse.mjs) with `push`.
// Pan is widened to the range the music used over the last ~20 s (up to ×5), so a narrow mix still shows its
// left-right movement.
// Two looks (toggleLook):
//   'ocean' (default): every stem is a layer of liquid seen from a slowly drifting camera. Across = pan (the wave
//     swells where the stem sits), height = pitch, wave height = energy, depth = time: the last seconds flow away
//     from the viewer as slices, so each stem leaves a liquid sheet of its trajectory. Plain alpha blending, no flashes.
//   'clean': each stem a comet with a tail, rings on the beat, sparks on onsets, fixed colours.

const BAND_STYLE = {
  kick: { color: [245, 165, 90], size: 40, hue: 30 },
  bass: { color: [79, 179, 224], size: 30, hue: 200 },
  mid: { color: [130, 145, 235], size: 24, hue: 235 },
  presence: { color: [110, 220, 200], size: 18, hue: 165 },
  air: { color: [225, 238, 242], size: 13, hue: 190 },
}
const TAIL_SECONDS = 2.5
const RING_SECONDS = 1.6
const SPARK_SECONDS = 0.45
const HISTORY_SECONDS = 5
const SLICE_RATE = 6
const PROFILE_POINTS = 44

const clamp = (v, lo = 0, hi = 1) => Math.min(hi, Math.max(lo, v))
const rgba = ([r, g, b], a) => `rgba(${r}, ${g}, ${b}, ${clamp(a)})`
const hsla = (h, s, l, a) => `hsla(${((h % 360) + 360) % 360}, ${s}%, ${l}%, ${clamp(a)})`

function styleFor(stem, index) {
  if (BAND_STYLE[stem]) return BAND_STYLE[stem]
  const low = /kick|sub|bass|rumble/i.test(stem), high = /hat|ride|perc|clap|fx/i.test(stem)
  const hue = (index * 137.5 + 90) % 360
  const [r, g, b] = [0, 8, 4].map(k => Math.round(255 * (0.55 + 0.45 * Math.cos((hue / 360 + k / 12) * 2 * Math.PI))))
  return { color: [r, g, b], size: /kick/i.test(stem) ? 40 : low ? 30 : high ? 15 : 22, hue }
}

export function createRenderer(canvas) {
  const g = canvas.getContext('2d')
  const scale = Math.min(devicePixelRatio, 2)
  let W = 0, H = 0, labels = true, look = 'ocean', pulse = null, lastPhase = 0, energy = 0
  let previous = performance.now() / 1000, widen = true, panReach = 0.1, panGain = 1
  const comets = new Map()
  const rings = [], sparks = []
  const bubbles = Array.from({ length: 90 }, () => ({ x: Math.random() * 2 - 1, y: Math.random(), z: Math.random(),
    speed: 0.01 + Math.random() * 0.03, size: 1 + Math.random() * 3 }))

  const resize = () => {
    W = canvas.width = Math.round(innerWidth * scale)
    H = canvas.height = Math.round(innerHeight * scale)
    canvas.style.width = innerWidth + 'px'
    canvas.style.height = innerHeight + 'px'
  }
  resize()
  addEventListener('resize', resize)

  const toScreen = (x, y) => [W / 2 + clamp(x * panGain, -1, 1) * W * 0.4, H * (0.9 - y * 0.8)]
  const kickComet = () => [...comets.entries()].find(([stem]) => /kick/i.test(stem))?.[1]
  const crowd = () => Math.sqrt(5 / Math.max(5, comets.size))

  function push(line) {
    const now = performance.now() / 1000
    if (line.pulse) {
      if (line.pulse.bpm && line.pulse.phase < lastPhase - 0.5) rings.push({ born: now, strength: 0.4 + (kickComet()?.e ?? 0.5) })
      lastPhase = line.pulse.phase
      pulse = line.pulse
      return
    }
    let comet = comets.get(line.stem)
    if (!comet) {
      comet = { style: styleFor(line.stem, comets.size), x: line.x, y: line.y, e: 0, z: 0, tail: [], history: [],
        seen: now, phase: Math.random() * 10 }
      comets.set(line.stem, comet)
    }
    comet.target = line
    comet.seen = now
    if (line.on) sparks.push({ comet, x: line.x, y: line.y, born: now, e: line.e })
  }

  function step(now, dt) {
    const follow = 1 - Math.exp(-dt * 5)
    for (const [stem, comet] of comets) {
      if (now - comet.seen > 10) { comets.delete(stem); continue }
      const target = comet.target
      comet.x += (target.x - comet.x) * follow
      comet.y += (target.y - comet.y) * follow
      comet.e += (target.e - comet.e) * (target.e > comet.e ? 1 - Math.exp(-dt * 40) : 1 - Math.exp(-dt * 6))
      comet.z += (target.z - comet.z) * (1 - Math.exp(-dt * 3))
      comet.tail.push({ x: comet.x, y: comet.y, e: comet.e, t: now })
      while (comet.tail.length && comet.tail[0].t < now - TAIL_SECONDS) comet.tail.shift()
      const last = comet.history.at(-1)
      if (!last || now - last.t >= 1 / SLICE_RATE) comet.history.push({ x: comet.x, y: comet.y, e: comet.e, t: now })
      else last.e = Math.max(last.e, comet.e)
      while (comet.history.length && comet.history[0].t < now - HISTORY_SECONDS) comet.history.shift()
    }
    const all = [...comets.values()]
    const reach = Math.max(0, ...all.map(c => Math.abs(c.x)))
    panReach = Math.max(reach, panReach * Math.exp(-dt / 20))
    panGain += ((widen ? clamp(0.8 / Math.max(panReach, 0.05), 1, 5) : 1) - panGain) * (1 - Math.exp(-dt))
    const mean = all.length ? all.reduce((s, c) => s + c.e, 0) / all.length : 0
    energy += (mean - energy) * (1 - Math.exp(-dt * 1.5))
    while (rings.length && rings[0].born < now - RING_SECONDS) rings.shift()
    while (sparks.length && sparks[0].born < now - SPARK_SECONDS) sparks.shift()
    for (const bubble of bubbles) {
      bubble.y += dt * bubble.speed * (0.4 + energy)
      if (bubble.y > 1.1) { bubble.y = -0.1; bubble.x = Math.random() * 2 - 1; bubble.z = Math.random() }
    }
  }

  // ---------- ocean ----------

  function camera(now) {
    const yaw = 0.32 * Math.sin(now * 0.043) + 0.12 * Math.sin(now * 0.011)
    const tilt = 0.42 + 0.12 * Math.sin(now * 0.031 + 1)
    const [cy, sy, ct, st] = [Math.cos(yaw), Math.sin(yaw), Math.cos(tilt), Math.sin(tilt)]
    const focal = Math.min(W, H) * 1.15, distance = 3.1, centreY = H * 0.64
    return (x, y, z) => {
      const xr = x * cy - z * sy, zr = x * sy + z * cy
      const yr = y * ct - zr * st, zd = y * st + zr * ct + distance
      return [W / 2 + focal * xr / zd, centreY - focal * yr / zd, zd]
    }
  }

  function profile(comet, slice, now, age) {
    const crest = clamp(slice.x * panGain, -1, 1) * 1.5
    const amplitude = (0.03 + 0.32 * slice.e) * (0.4 + 0.6 * (1 - comet.style.size / 60))
    const wavelength = 0.9 - 0.6 * slice.y
    const tempo = (pulse?.bpm || 120) / 60
    const t = now - age
    const points = []
    for (let i = 0; i <= PROFILE_POINTS; i++) {
      const x = -1.9 + 3.8 * i / PROFILE_POINTS
      const swell = Math.exp(-(((x - crest) / 0.7) ** 2))
      const wave = 0.65 * Math.sin(x / wavelength * 2 * Math.PI - t * tempo * 1.2 + comet.phase)
        + 0.35 * Math.sin(x / (wavelength * 0.43) * 2 * Math.PI + t * tempo * 0.7 + comet.phase * 2)
      points.push([x, (slice.y - 0.45) * 1.5 + amplitude * (swell * (0.75 + 0.35 * wave) + 0.18 * wave)])
    }
    return points
  }

  function curve(points) {
    g.moveTo(points[0][0], points[0][1])
    for (let i = 1; i < points.length - 1; i++) {
      const [x, y] = points[i], [nx, ny] = points[i + 1]
      g.quadraticCurveTo(x, y, (x + nx) / 2, (y + ny) / 2)
    }
    g.lineTo(points.at(-1)[0], points.at(-1)[1])
  }

  function drawOcean(now) {
    g.globalCompositeOperation = 'source-over'
    const sky = g.createLinearGradient(0, 0, 0, H)
    sky.addColorStop(0, '#04060d')
    sky.addColorStop(0.55, hsla(250 + now * 2, 45, 7 + 5 * energy, 1))
    sky.addColorStop(1, '#03050a')
    g.fillStyle = sky
    g.fillRect(0, 0, W, H)
    const project = camera(now)
    const beat = pulse?.bpm ? (1 - pulse.phase) ** 2 : 0

    for (const bubble of bubbles) {
      const [x, y, depth] = project(bubble.x * 1.8, bubble.y * 1.6 - 0.7, bubble.z * 3)
      g.fillStyle = hsla(200 + bubble.z * 120 + now * 4, 60, 70, (0.05 + 0.08 * energy) * (1 - bubble.z * 0.6))
      g.beginPath(); g.arc(x, y, bubble.size * scale * 3 / depth, 0, 2 * Math.PI); g.fill()
    }

    const slices = []
    for (const comet of comets.values()) {
      for (const slice of comet.history) {
        const age = now - slice.t
        if (slice.e > 0.02) slices.push({ comet, slice, age })
      }
    }
    slices.sort((a, b) => b.age - a.age || b.slice.y - a.slice.y)
    const dim = crowd()
    for (const { comet, slice, age } of slices) {
      const nearness = 1 - age / HISTORY_SECONDS, z = age / HISTORY_SECONDS * 4.2 - 0.6
      const points = profile(comet, slice, now, age).map(([x, y]) => project(x, y, z))
      const [, floorY] = project(0, (slice.y - 0.45) * 1.5 - 0.22, z)
      const top = Math.min(...points.map(p => p[1]))
      const hue = comet.style.hue + now * 3 + slice.e * 25
      const body = g.createLinearGradient(0, top, 0, Math.max(top + 1, floorY))
      body.addColorStop(0, hsla(hue, 70, 44, (0.16 + 0.4 * slice.e) * nearness ** 0.6 * dim))
      body.addColorStop(0.5, hsla(hue + 20, 70, 28, (0.08 + 0.2 * slice.e) * nearness ** 0.8 * dim))
      body.addColorStop(1, hsla(hue + 30, 65, 12, 0))
      g.fillStyle = body
      g.beginPath()
      curve(points)
      g.lineTo(points.at(-1)[0], floorY)
      g.lineTo(points[0][0], floorY)
      g.closePath()
      g.fill()
      if (comet.history.at(-1) !== slice) continue
      g.strokeStyle = hsla(hue - 10, 75, 60 + 6 * beat * slice.e, (0.15 + 0.45 * slice.e) * dim)
      g.lineWidth = scale * (1.5 + 2.5 * slice.e)
      g.beginPath()
      curve(points)
      g.stroke()
    }

    if (labels) {
      g.font = `${12 * scale}px system-ui, sans-serif`
      for (const [stem, comet] of comets) {
        const slice = comet.history.at(-1)
        if (!slice || comet.e < 0.05) continue
        const crest = clamp(slice.x * panGain, -1, 1) * 1.5
        const [x, y] = project(crest, (slice.y - 0.45) * 1.5 + 0.05 + 0.32 * slice.e, -0.6)
        g.fillStyle = hsla(comet.style.hue + now * 3, 60, 75, 0.7)
        g.fillText(stem, x + 8 * scale, y)
      }
    }
  }

  // ---------- clean ----------

  function drawClean(now) {
    g.globalCompositeOperation = 'source-over'
    g.fillStyle = '#071521'
    g.fillRect(0, 0, W, H)
    const beatGlow = pulse?.bpm ? (1 - pulse.phase) ** 3 : 0
    const kick = kickComet()
    const [kx, ky] = kick ? toScreen(kick.x, kick.y) : toScreen(0, 0.05)
    const room = g.createRadialGradient(kx, ky, 0, kx, ky, Math.max(W, H) * 0.9)
    room.addColorStop(0, rgba([30, 80, 110], 0.12 + 0.3 * energy + 0.1 * beatGlow * (kick?.e ?? 0)))
    room.addColorStop(1, rgba([7, 21, 33], 0))
    g.fillStyle = room
    g.fillRect(0, 0, W, H)
    g.globalCompositeOperation = 'lighter'
    const dim = crowd()
    for (const ring of rings) {
      const age = (now - ring.born) / RING_SECONDS
      g.strokeStyle = rgba(BAND_STYLE.kick.color, (1 - age) ** 2 * 0.35 * ring.strength)
      g.lineWidth = (1 + 5 * (1 - age)) * scale
      g.beginPath(); g.arc(kx, ky, 30 * scale + age * Math.max(W, H) * 0.45, 0, 2 * Math.PI); g.stroke()
    }
    const ordered = [...comets.values()].sort((a, b) => b.style.size - a.style.size)
    g.lineCap = 'round'
    for (const comet of ordered) {
      const tail = comet.tail, n = tail.length, { color, size } = comet.style
      for (let i = 1; i < n; i++) {
        const age = i / n, [x1, y1] = toScreen(tail[i - 1].x, tail[i - 1].y), [x2, y2] = toScreen(tail[i].x, tail[i].y)
        g.strokeStyle = rgba(color, age ** 1.6 * (0.05 + 0.3 * tail[i].e) * dim)
        g.lineWidth = size * scale * 0.4 * age * (0.3 + tail[i].e)
        g.beginPath(); g.moveTo(x1, y1); g.lineTo(x2, y2); g.stroke()
      }
    }
    for (const comet of ordered) {
      const [x, y] = toScreen(comet.x, comet.y), { color, size } = comet.style
      const radius = size * scale * (0.5 + comet.e) * (1 + comet.z), fade = 1 - 0.4 * comet.z
      const halo = g.createRadialGradient(x, y, 0, x, y, radius * 2.2)
      halo.addColorStop(0, rgba(color, (0.25 + 0.45 * comet.e) * fade * dim))
      halo.addColorStop(0.3, rgba(color, (0.06 + 0.18 * comet.e) * fade * dim))
      halo.addColorStop(1, rgba(color, 0))
      g.fillStyle = halo
      g.beginPath(); g.arc(x, y, radius * 2.2, 0, 2 * Math.PI); g.fill()
    }
    for (const spark of sparks) {
      const age = (now - spark.born) / SPARK_SECONDS, [x, y] = toScreen(spark.x, spark.y)
      g.strokeStyle = rgba(spark.comet.style.color, (1 - age) ** 2 * 0.4 * spark.e * dim)
      g.lineWidth = 1.5 * scale
      g.beginPath(); g.arc(x, y, spark.comet.style.size * scale * (0.6 + age * 1.5), 0, 2 * Math.PI); g.stroke()
    }
    g.globalCompositeOperation = 'source-over'
    if (labels) {
      g.font = `${12 * scale}px system-ui, sans-serif`
      for (const [stem, comet] of comets) {
        if (comet.e < 0.05) continue
        const [x, y] = toScreen(comet.x, comet.y)
        g.fillStyle = rgba(comet.style.color, 0.75)
        g.fillText(stem, x + comet.style.size * scale * 0.9, y - comet.style.size * scale * 0.5)
      }
    }
  }

  function drawStatus() {
    const p = pulse ?? { bpm: 0, phase: 0, density: 0, swing: 0 }
    g.fillStyle = 'rgba(127, 163, 178, 0.8)'
    g.font = `${12 * scale}px ui-monospace, monospace`
    g.fillText(`bpm ${p.bpm.toFixed(1)}   density ${p.density.toFixed(2)}   swing ${p.swing.toFixed(3)}   `
      + `pan ×${panGain.toFixed(1)}   ${look}`, 20 * scale, H - 20 * scale)
  }

  function frame() {
    const now = performance.now() / 1000, dt = Math.min(0.1, now - previous)
    previous = now
    step(now, dt)
    if (look === 'ocean') drawOcean(now)
    else drawClean(now)
    if (labels) drawStatus()
    requestAnimationFrame(frame)
  }
  requestAnimationFrame(frame)

  return {
    push,
    toggleLabels: () => { labels = !labels },
    toggleWiden: () => { widen = !widen },
    toggleLook: () => { look = look === 'ocean' ? 'clean' : 'ocean' },
  }
}
