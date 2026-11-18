import fs from 'fs'
import { fileURLToPath } from 'url'

const BEATS_PER_BAR = 4
const NOTE_NAMES = ['c', 'db', 'd', 'eb', 'e', 'f', 'gb', 'g', 'ab', 'a', 'bb', 'b']
const GM_DRUM_NAMES = {
  35: 'kick2', 36: 'kick', 37: 'stick', 38: 'snare', 39: 'clap', 40: 'snare2', 41: 'tomlo2', 42: 'hhclosed',
  43: 'tomlo', 44: 'hhpedal', 45: 'tommid2', 46: 'hhopen', 47: 'tommid', 48: 'tomhi2', 49: 'crash', 50: 'tomhi',
  51: 'ride', 52: 'china', 53: 'ridebell', 54: 'tambourine', 55: 'splash', 56: 'cowbell', 57: 'crash2',
  59: 'ride2', 75: 'claves', 81: 'triangleopen',
}
const DRUM_CHANNEL = 9
const MAX_GRID = 1024

export function noteName(pitch) {
  return NOTE_NAMES[pitch % 12] + (Math.floor(pitch / 12) - 1)
}

export function drumName(pitch) {
  return GM_DRUM_NAMES[pitch] ?? `drum${pitch}`
}

function readChunks(bytes) {
  const chunks = []
  let position = 0
  while (position + 8 <= bytes.length) {
    const type = String.fromCharCode(...bytes.subarray(position, position + 4))
    const length = new DataView(bytes.buffer, bytes.byteOffset + position + 4, 4).getUint32(0)
    chunks.push({ type, data: bytes.subarray(position + 8, position + 8 + length) })
    position += 8 + length
  }
  return chunks
}

function readTrackEvents(data) {
  const events = []
  let position = 0
  let tick = 0
  let runningStatus = 0
  const readVariableLength = () => {
    let value = 0
    let byte
    do {
      byte = data[position++]
      value = value * 128 + (byte & 0x7f)
    } while (byte & 0x80)
    return value
  }
  while (position < data.length) {
    tick += readVariableLength()
    let status = data[position]
    if (status & 0x80) position++
    else status = runningStatus
    if (status === 0xff) {
      const metaType = data[position++]
      const length = readVariableLength()
      events.push({ tick, kind: 'meta', metaType, data: data.subarray(position, position + length) })
      position += length
      if (metaType === 0x2f) break
    } else if (status === 0xf0 || status === 0xf7) {
      const length = readVariableLength()
      position += length
    } else {
      runningStatus = status
      const type = status >> 4
      const channel = status & 0x0f
      const first = data[position++]
      const second = type === 0xc || type === 0xd ? undefined : data[position++]
      events.push({ tick, kind: 'channel', type, channel, first, second })
    }
  }
  return events
}

const decodeText = data => new TextDecoder('latin1').decode(data).replace(/\0+$/, '')

export function readMidi(input) {
  const bytes = input instanceof Uint8Array ? input : new Uint8Array(fs.readFileSync(input))
  const [header, ...trackChunks] = readChunks(bytes)
  if (header?.type !== 'MThd') throw new Error('not a MIDI file (no MThd header)')
  const format = header.data[0] << 8 | header.data[1]
  const division = header.data[4] << 8 | header.data[5]
  if (division & 0x8000) throw new Error('SMPTE time division is not supported')
  const ticksPerBar = division * BEATS_PER_BAR
  const barOf = tick => Math.floor(tick / ticksPerBar) + 1
  const warnings = []
  const tempoChanges = []
  const timeSignatures = []
  const markers = []
  const tracks = []
  let lastTick = 0

  trackChunks.filter(chunk => chunk.type === 'MTrk').forEach((chunk, trackIndex) => {
    const events = readTrackEvents(chunk.data)
    const track = { index: trackIndex, name: '', channels: new Set(), programs: [], notes: [] }
    const openNotes = new Map()
    for (const event of events) {
      lastTick = Math.max(lastTick, event.tick)
      if (event.kind === 'meta') {
        if (event.metaType === 0x03 && !track.name) track.name = decodeText(event.data)
        else if (event.metaType === 0x51) {
          const microsecondsPerQuarter = event.data[0] << 16 | event.data[1] << 8 | event.data[2]
          const bpm = +(60e6 / microsecondsPerQuarter).toFixed(3)
          tempoChanges.push({ bar: barOf(event.tick), tick: event.tick, bpm })
        } else if (event.metaType === 0x58) {
          timeSignatures.push({ bar: barOf(event.tick), tick: event.tick, numerator: event.data[0],
            denominator: 2 ** event.data[1] })
        } else if (event.metaType === 0x06) {
          markers.push({ bar: barOf(event.tick), tick: event.tick, text: decodeText(event.data) })
        }
        continue
      }
      const { type, channel, first, second } = event
      if (type === 0xc) {
        track.channels.add(channel)
        const bar = barOf(event.tick)
        const previous = track.programs.at(-1)
        if (!previous || previous.program !== first) track.programs.push({ bar, tick: event.tick, program: first })
      } else if (type === 0x9 && second > 0) {
        track.channels.add(channel)
        const key = channel * 128 + first
        if (!openNotes.has(key)) openNotes.set(key, [])
        openNotes.get(key).push({ tick: event.tick, velocity: second, channel, pitch: first })
      } else if (type === 0x8 || type === 0x9) {
        const started = openNotes.get(channel * 128 + first)?.shift()
        if (started) track.notes.push({ ...started, endTick: event.tick })
      }
    }
    for (const pending of openNotes.values()) {
      for (const started of pending) {
        warnings.push(`track ${trackIndex}: note ${started.pitch} at tick ${started.tick} has no note-off`)
      }
    }
    if (track.notes.length) tracks.push(track)
  })

  const distinctTempos = [...new Set(tempoChanges.map(change => change.bpm))]
  if (distinctTempos.length > 1) {
    warnings.push(`unsupported: tempo changes (${tempoChanges.map(c => `${c.bpm} at bar ${c.bar}`).join(', ')});` +
      ' positions use the first tempo only')
  }
  const oddMeters = timeSignatures.filter(signature => signature.numerator !== 4 || signature.denominator !== 4)
  if (oddMeters.length) {
    warnings.push(`unsupported: time signatures other than 4/4 (${oddMeters.map(s =>
      `${s.numerator}/${s.denominator} at bar ${s.bar}`).join(', ')}); bars are counted as 4/4`)
  }

  const lastNoteEnd = Math.max(0, ...tracks.flatMap(track => track.notes.map(note => note.endTick)))
  const bars = Math.ceil(lastNoteEnd / ticksPerBar)
  return {
    format,
    ticksPerQuarter: division,
    tempo: tempoChanges[0]?.bpm ?? 120,
    tempoChanges,
    timeSignatures,
    markers,
    bars,
    endOfTrackBars: lastTick / ticksPerBar,
    warnings,
    tracks: tracks.map(track => ({
      index: track.index,
      name: track.name,
      channels: [...track.channels].sort((a, b) => a - b),
      isDrums: track.channels.has(DRUM_CHANNEL),
      programs: track.programs.map(({ bar, program }) => ({ bar, program })),
      notes: track.notes
        .sort((a, b) => a.tick - b.tick || a.pitch - b.pitch)
        .map(note => ({
          bar: barOf(note.tick),
          beat: (note.tick % ticksPerBar) / division,
          length: (note.endTick - note.tick) / ticksPerBar,
          pitch: note.pitch,
          velocity: note.velocity,
          channel: note.channel,
          tick: note.tick,
          endTick: note.endTick,
        })),
    })),
  }
}

export function gridOf(notes, ticksPerBar) {
  const fitsGrid = (tick, steps) => (tick * steps) % ticksPerBar === 0
  for (let steps = 1; steps <= MAX_GRID; steps *= 2) {
    if (notes.every(note => fitsGrid(note.tick, steps) && fitsGrid(note.endTick, steps))) return steps
  }
  return null
}

export function distinctNotes(notes) {
  const seen = new Set()
  return notes.filter(note => {
    const key = `${note.tick}:${note.endTick}:${note.pitch}`
    if (seen.has(key)) return false
    seen.add(key)
    return true
  })
}

function splitIntoVoices(notes) {
  const voices = []
  for (const note of notes) {
    const voice = voices.find(candidate => {
      const last = candidate.at(-1)
      return last.endTick <= note.tick || (last.tick === note.tick && last.endTick === note.endTick)
    })
    if (voice) voice.push(note)
    else voices.push([note])
  }
  return voices
}

const velocityOf = notes => String(+(Math.max(...notes.map(note => note.velocity)) / 127).toFixed(2))

const greatestCommonDivisor = (a, b) => (b ? greatestCommonDivisor(b, a % b) : a)

// One voice of a bar as mini-notation: note names, or with `velocity` each step's velocity (0-1) in the same rhythm
function formatVoice(voice, barStartTick, barEndTick, nameOf, velocity = false) {
  const steps = []
  let cursor = barStartTick
  for (let index = 0; index < voice.length;) {
    const chord = voice.filter(note => note.tick === voice[index].tick)
    index += chord.length
    if (chord[0].tick > cursor) steps.push({ token: '~', ticks: chord[0].tick - cursor })
    const names = chord.map(note => nameOf(note.pitch))
    const endTick = Math.min(chord[0].endTick, barEndTick)
    const token = velocity ? velocityOf(chord) : names.length === 1 ? names[0] : `[${names.join(',')}]`
    steps.push({ token, ticks: endTick - chord[0].tick })
    cursor = endTick
  }
  if (cursor < barEndTick) steps.push({ token: '~', ticks: barEndTick - cursor })
  const unit = steps.reduce((divisor, step) => greatestCommonDivisor(divisor, step.ticks), 0)
  return steps.map(({ token, ticks }) => (ticks === unit ? token : `${token}@${ticks / unit}`)).join(' ')
}

export function dumpTrack(song, track, { fromBar = 1, toBar = song.bars } = {}) {
  const ticksPerBar = song.ticksPerQuarter * BEATS_PER_BAR
  const grid = gridOf(track.notes, ticksPerBar)
  if (!grid) throw new Error(`track ${track.index} (${track.name}): no power-of-two grid up to 1/${MAX_GRID} fits`)
  const nameOf = track.isDrums ? drumName : noteName
  const notes = distinctNotes(track.notes)
  const lines = []
  for (let bar = fromBar; bar <= toBar; bar++) {
    const barStartTick = (bar - 1) * ticksPerBar
    const barEndTick = barStartTick + ticksPerBar
    const starting = notes.filter(note => note.bar === bar)
    const tied = starting.filter(note => note.endTick > barEndTick)
    if (!starting.length) {
      lines.push({ bar, mini: '~', tied: [], untied: '~', ties: [], velocity: 1, voices: [], untiedVoices: [] })
      continue
    }
    const voicesOf = group => splitIntoVoices(group).map(voice => ({
      mini: formatVoice(voice, barStartTick, barEndTick, nameOf),
      velocity: formatVoice(voice, barStartTick, barEndTick, nameOf, true),
    }))
    const format = group => (group.length ? voicesOf(group).map(voice => voice.mini).join(', ') : '~')
    const mini = format(starting)
    const tiedNotes = tied.map(note => ({ name: nameOf(note.pitch), beat: note.beat, length: note.length }))
    const untiedNotes = starting.filter(note => note.endTick <= barEndTick)
    const untied = format(untiedNotes)
    const ties = tied.map(note => ({ mini: formatVoice([note], barStartTick, barEndTick, nameOf),
      clip: +((note.endTick - note.tick) / (barEndTick - note.tick)).toFixed(4), velocity: +velocityOf([note]) }))
    const velocities = new Set(starting.map(note => note.velocity))
    lines.push({ bar, mini, tied: tiedNotes, untied, ties,
      velocity: velocities.size === 1 ? +velocityOf(starting) : null,
      voices: voicesOf(starting), untiedVoices: untiedNotes.length ? voicesOf(untiedNotes) : [] })
  }
  return { grid, lines }
}

function describeProgram(programs) {
  return programs.map((change, index) => (index === 0 ? `${change.program}` : `${change.program} at bar ${change.bar}`))
    .join(' -> ')
}

const gridText = grid => (grid ? `1/${grid}` : `finer than 1/${MAX_GRID} (triplets?)`)

export function summary(song) {
  const ticksPerBar = song.ticksPerQuarter * BEATS_PER_BAR
  const lines = [
    `format ${song.format}, ${song.ticksPerQuarter} ticks per quarter, tempo ${song.tempo}, ${song.bars} bars`,
    `time signatures: ${song.timeSignatures.map(s => `${s.numerator}/${s.denominator} at bar ${s.bar}`).join(', ')
      || 'none (4/4)'}`,
    `markers: ${song.markers.map(m => `bar ${m.bar} '${m.text}'`).join(', ') || 'none'}`,
  ]
  for (const track of song.tracks) {
    const pitches = [...new Set(track.notes.map(note => note.pitch))].sort((a, b) => a - b)
    const pitchText = track.isDrums ? pitches.map(p => `${p} ${drumName(p)}`).join(', ')
      : `${noteName(pitches[0])}-${noteName(pitches.at(-1))}`
    const duplicates = track.notes.length - distinctNotes(track.notes).length
    const duplicateText = duplicates ? ` (${duplicates} exact duplicates, the dump prints each once)` : ''
    lines.push(`track ${track.index} '${track.name}': channels ${track.channels.join('+')}, program ` +
      `${describeProgram(track.programs)}, ${track.notes.length} notes${duplicateText}, ` +
      `grid ${gridText(gridOf(track.notes, ticksPerBar))}, ` +
      `pitches ${pitchText}`)
  }
  for (const warning of song.warnings) lines.push(`warning: ${warning}`)
  return lines.join('\n')
}

function parseBarRange(text, bars) {
  if (!text) return { fromBar: 1, toBar: bars }
  const [from, to] = text.split('-').map(Number)
  return { fromBar: from, toBar: to ?? from }
}

function main(args) {
  const optionsWithValue = ['--track', '--bars']
  const file = args.find((arg, index) => !arg.startsWith('--') && !optionsWithValue.includes(args[index - 1]))
  if (!file) {
    console.error('usage: node producer/midi-read.mjs <file.mid> [--dump] [--track n] [--bars a-b] [--json]')
    process.exit(1)
  }
  const optionValue = name => {
    const index = args.indexOf(name)
    return index >= 0 ? args[index + 1] : undefined
  }
  const song = readMidi(file)
  if (args.includes('--json')) {
    console.log(JSON.stringify(song, null, 2))
    return
  }
  console.log(summary(song))
  if (!args.includes('--dump')) return
  const trackFilter = optionValue('--track')
  const range = parseBarRange(optionValue('--bars'), song.bars)
  for (const track of song.tracks) {
    if (trackFilter !== undefined && track.index !== Number(trackFilter)) continue
    const { grid, lines } = dumpTrack(song, track, range)
    console.log(`\n// track ${track.index} '${track.name}' (grid 1/${grid})`)
    for (const line of lines) {
      const ties = line.tied.map(tie => `${tie.name} at beat ${tie.beat} lasts ${tie.length} bars`).join(', ')
      console.log(`/* ${String(line.bar).padStart(3)} */ '${line.mini}'${ties ? ` // tied: ${ties}` : ''}`)
    }
  }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) main(process.argv.slice(2))
