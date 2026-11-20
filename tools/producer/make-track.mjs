// Producer: a MIDI song + a map file → a live track (one file, layout of 007-010), a design stub and a perform script.
// usage (in tools/): npm run producer -- <file.mid> [--map <map.json>] [--name <NNN-name>] [--genre <genre>]
//                                       [--out <dir>] [--force] [--perform]
//   --map    the decisions (columns, voices, sections, chapters, harmony, pads, performance); without it every
//            decision gets a default and the map is written beside the track for the user to edit and re-run with
//   --name   track id (default: the map's `track`, else the next free number + the file name)
//   --out    write every file into this folder instead of tracks/<genre>/<id>/ and trajectory/perform/<id>/
//   --force  overwrite existing files (without it nothing is written when a file exists)
//   --perform  write only the performance script (<name>.json, from the map's `performance`), overwriting it; the
//            track, its design and the performance design are left alone
// The track is built from the song template (producer/song.strudel-template: the pilot 012 with slots) and the voice
// library (producer/voices.mjs: EDM and Classical voices); @shared blocks come from tools/shared. Song bar 1 = cycle 0,
// one bar = one cycle; a performance's script bar = song bar - 1.
// A column plays one MIDI part or several (grouped), each voice entry { part?, fromBar, program, voice } from its bar
// on: a program change inside a part is a new entry of that part, an entry with another part is stacked on top.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { readMidi, dumpTrack, distinctNotes } from './midi-read.mjs'
import { VOICES, SAMPLE_SETS, SSO_URL, defaultVoice } from './voices.mjs'

const HERE = path.dirname(fileURLToPath(import.meta.url))
const TOOLS = path.resolve(HERE, '..')
const ROOT = path.resolve(TOOLS, '..')
const TEMPLATE = path.join(HERE, 'song.strudel-template')
const SHARED = path.join(TOOLS, 'shared')
const PERFORM = path.join(TOOLS, 'trajectory', 'perform')
const MAX_COLUMNS = 7
const GM_FAMILIES = ['Piano', 'Mallets', 'Organ', 'Guitar', 'Bass', 'Strings', 'Ensemble', 'Brass', 'Reed', 'Pipe',
  'Synth Lead', 'Synth Pad', 'Synth FX', 'Ethnic', 'Percussion', 'Effects']
const SHARP_NAMES = ['C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B']
const FLAT_NOTES = ['c', 'db', 'd', 'eb', 'e', 'f', 'gb', 'g', 'ab', 'a', 'bb', 'b']
const SCALES = { minor: [0, 2, 3, 5, 7, 8, 10], major: [0, 2, 4, 5, 7, 9, 11] }
const BASE = { k1: 12, k2: 20, k3: 28, fader: 4, b1: 36, b2: 44 }
const GLOBAL_NAMES = { k1: 'Fog', k2: 'Thin', k3: 'Tension', fader: 'Master', b1: 'Chapter', b2: 'Break' }
const LK_NAMES = { 'Keys Level': 1, Brightness: 21, 'Piano → Rhodes': 22, 'B3 → M1': 23, 'Vibes → Marimba': 24,
  Length: 25, Space: 26, Echo: 27, 'Pad Fog': 28 }
const PAD_NOTE_1 = 36
const VOICE_PADS = ['Brace', 'Paper', 'Wine', 'Plaenterwald', 'Wiese', 'Creatures', 'No end', 'Vast']
const EXTRA_COLUMNS = {
  edm: [
  { col: 1, id: 'clap', name: 'Clap', voice: 'clap-909' },
  { col: 2, id: 'hats', name: 'Hats', voice: 'hats-909' },
  { col: 3, id: 'pad', name: 'Pad', voice: 'supersaw-pad' },
  { col: 4, id: 'pump', name: 'Noise Pump', voice: 'noise-pump' },
  ],
}
export const EDM_PADS = [
  { name: 'Clap', s: 'rolandtr909_cp' },
  { name: 'Snare', s: 'rolandtr909_sd', gain: 1.05 },
  { name: 'Open hat', s: 'rolandtr909_oh' },
  { name: 'Crash', s: 'rolandtr909_cr', gain: 0.57 },
  { name: 'Crash reverse', s: 'rolandtr909_cr', speed: -0.6, gain: 0.54 },
  { name: 'Drop hit', about: [
    'Drop hit: 008\'s Braaam on G♯ with the tritone as the alarm, the filter opening slowly, driven, over a sine',
    'boom that falls onto G♯ (retune its notes for another key)'],
  s: 'sawtooth', gain: 0.55, once: 3.5, room: 0.9, cutoff: 1400, attack: 0.08, decay: 1.2, sustain: 0.6,
  release: 2.5, lpenv: 2, lpattack: 0.3, lpdecay: 1.5, shape: 0.5, layers: [
    { note: 32, gain: 0.5 }, { note: 44.15, gain: 0.4, pan: 0.3 }, { note: 43.85, gain: 0.4, pan: 0.7 },
    { s: 'square', note: 51, gain: 0.18 }, { note: 50, gain: 0.2 },
    { s: 'sine', note: 32, gain: 0.9, attack: 0.005, penv: 12, pdecay: 0.4, decay: 1.5, sustain: 0 }] },
  { name: 'Zap', about: ['Zap: a sine that falls four octaves in a flash (laser)'], s: 'sine', gain: 1.2, note: 80,
    penv: 48, pdecay: 0.12, attack: 0.001, decay: 0.25, sustain: 0, release: 0.05 },
  { name: 'Sweep down',
    about: ['Sweep down: white noise through a low-pass that falls from bright to dark over a second'],
    s: 'white', gain: 1.12, attack: 0.005, decay: 1.2, sustain: 0, release: 0.2, cutoff: 300, lpenv: 5,
    lpattack: 0.005, lpdecay: 1, lpsustain: 0 },
]
export const CLASSICAL_PADS = [
  { name: 'Timpani roll', about: ['Timpani roll: a crescendo roll on E (SSO timpani)'], s: 'sso_timp_roll', note: 40 },
  { name: 'Bass drum', s: 'sso_bd' },
  { name: 'Cymbals', s: 'sso_piatti' },
  { name: 'Cymbal roll', s: 'sso_cym_roll' },
  { name: 'Tam-tam', s: 'sso_tamtam' },
  { name: 'Snare roll', s: 'sso_snare_roll' },
  { name: 'Triangle', s: 'sso_triangle' },
  { name: 'Orchestra hit', about: ['Orchestra hit: strings and brass short on an E minor chord'], s: 'sso_vc', note: 40,
    gain: 0.8, layers: [{ s: 'sso_vc', note: 40 }, { s: 'sso_va', note: 59 }, { s: 'sso_vn', note: 64 },
      { s: 'sso_vn', note: 67 }, { s: 'sso_tb', note: 40 }, { s: 'sso_hn', note: 52 }, { s: 'sso_hn', note: 55 }] },
]
const PADS = { edm: EDM_PADS, classical: CLASSICAL_PADS }

const quote = text => `'${String(text).replace(/\\/g, '\\\\').replace(/'/g, '\\\'')}'`
const pascal = id => id.replace(/([a-z0-9])([A-Z])/g, '$1_$2').toUpperCase().replace(/[^A-Z0-9]+/g, '_')
const constOf = name => name.toUpperCase().replace(/[^A-Z0-9]+/g, '_').replace(/^_|_$/g, '')
const letters = index => (index < 26 ? '' : letters(Math.floor(index / 26) - 1)) + String.fromCharCode(65 + index % 26)
const pageNumber = page => (page === 2 ? 2 : 1)
const barCount = section => section.to - section.from + 1

// JS literal of a pad shot or a nested value: keys bare, text in single quotes
function literal(value) {
  if (Array.isArray(value)) return `[${value.map(literal).join(', ')}]`
  if (value && typeof value === 'object') {
    return `{ ${Object.entries(value).map(([key, v]) => `${/^\w+$/.test(key) ? key : quote(key)}: ${literal(v)}`)
      .join(', ')} }`
  }
  return typeof value === 'string' ? quote(value) : String(value)
}

function wrapLine(text, indent, width = 120) {
  if (text.length <= width) return [text]
  const lines = []
  let line = ''
  for (const piece of text.split(/(?<=, )/)) {
    if ((line + piece).trimEnd().length > width && line.trim()) {
      lines.push(line.trimEnd())
      line = indent + piece
    } else line += piece
  }
  lines.push(line.trimEnd())
  return lines
}

function wrapComment(text, width = 120) {
  const lines = []
  let line = ''
  for (const word of text.replace(/^\/\/ /, '').split(' ')) {
    if (line && 3 + line.length + 1 + word.length > width) {
      lines.push(`// ${line}`)
      line = word
    } else line = line ? `${line} ${word}` : word
  }
  lines.push(`// ${line}`)
  return lines
}

// A mini-notation call; a long one is split into string pieces joined with + (as hand-written tracks do)
function miniCall(fn, mini, prefix, width = 120) {
  const call = `${fn}("${mini}")`
  if (prefix.length + call.length <= width) return call
  const pieces = []
  let piece = ''
  for (const word of mini.split(' ')) {
    const limit = (pieces.length ? width - 6 : width - prefix.length - fn.length - 6)
    if (piece && piece.length + 1 + word.length > limit) {
      pieces.push(`${piece} `)
      piece = word
    } else piece = piece ? `${piece} ${word}` : word
  }
  pieces.push(piece)
  return `${fn}(${pieces.map(p => `"${p}"`).join(' +\n    ')})`
}

// ---------- reading the song ----------

function trackStats(song, track) {
  const notes = distinctNotes(track.notes)
  const pitches = notes.map(note => note.pitch).sort((a, b) => a - b)
  const starts = new Map()
  for (const note of notes) starts.set(note.tick, (starts.get(note.tick) ?? 0) + 1)
  const ticksPerBar = song.ticksPerQuarter * 4
  const short = notes.filter(note => note.endTick - note.tick <= ticksPerBar / 8).length
  return {
    notes: notes.length,
    medianPitch: pitches[Math.floor(pitches.length / 2)] ?? 60,
    polyphonic: [...starts.values()].filter(count => count > 1).length > starts.size / 2,
    shortNotes: short > notes.length / 2,
    bars: [...new Set(notes.map(note => note.bar))].sort((a, b) => a - b),
  }
}

// Pitch-class weights (note length in ticks) of the notes starting in `bar` (all bars when null)
function pitchWeights(song, bar = null) {
  const weights = Array(12).fill(0)
  for (const track of song.tracks.filter(t => !t.isDrums)) {
    for (const note of distinctNotes(track.notes)) {
      if (bar === null || note.bar === bar) weights[note.pitch % 12] += note.endTick - note.tick
    }
  }
  return weights
}

// The bar's chord: the major or minor triad whose notes sound longest in it (the root counts a little more); a tie
// goes to the quality the whole song prefers
function chordOfBar(song, bar, songWeights = pitchWeights(song)) {
  const weights = pitchWeights(song, bar)
  if (!weights.some(Boolean)) return null
  const scored = []
  for (let root = 0; root < 12; root++) {
    for (const minor of [true, false]) {
      const third = (root + (minor ? 3 : 4)) % 12
      const fifth = (root + 7) % 12
      const score = 1.01 * weights[root] + weights[third] + weights[fifth] + 1e-6 * songWeights[third]
      scored.push({ root, minor, third, fifth, score })
    }
  }
  const { root, minor, third, fifth } = scored.sort((a, b) => b.score - a.score)[0]
  const pad = [root, third, fifth].map((pc, i, all) => FLAT_NOTES[pc] + (3 + (i > 0 && pc < all[0] ? 1 : 0)))
  return { name: SHARP_NAMES[root] + (minor ? 'm' : ''), root, minor, pad: `[${pad.join(',')}]` }
}

function defaultHarmony(song) {
  const songWeights = pitchWeights(song)
  const chords = Array.from({ length: song.bars }, (_, i) => chordOfBar(song, i + 1, songWeights))
  const known = chords.map((chord, i) => chord ?? chords.find(Boolean) ?? { name: 'C', root: 0, pad: '[c3,e3,g3]' })
  const period = [1, 2, 4, 8].find(p => known.every((chord, i) => chord.name === known[i % p].name)) ?? known.length
  return known.slice(0, period)
}

function defaultStopBars(song, columns) {
  const stops = []
  for (let bar = 4; bar <= song.bars; bar += 4) {
    const playing = columns.map(column => song.tracks.find(track => track.index === column.part))
      .map(track => distinctNotes(track.notes).filter(note => note.bar === bar))
      .filter(notes => notes.length)
    const single = playing.filter(notes => new Set(notes.map(note => note.tick)).size === 1)
    if (playing.length > 2 && single.length * 2 > playing.length && single.every(n => n[0].beat === 0)) stops.push(bar)
  }
  return stops
}

function nextTrackNumber() {
  const numbers = fs.readdirSync(path.join(ROOT, 'tracks'), { withFileTypes: true }).filter(e => e.isDirectory())
    .flatMap(genre => fs.readdirSync(path.join(ROOT, 'tracks', genre.name)))
    .map(folder => Number(folder.match(/^(\d{3})-/)?.[1])).filter(Number.isFinite)
  return String(Math.max(0, ...numbers) + 1).padStart(3, '0')
}

// ---------- the map without a map: defaults ----------

export function defaultMap(song, midiFile, { name, genre = 'edm' } = {}) {
  const slug = path.basename(midiFile, '.mid').toLowerCase().replace(/^gp[-_ ]/, '').replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
  const track = name ?? `${nextTrackNumber()}-${slug}`
  const stats = new Map(song.tracks.map(t => [t.index, trackStats(song, t)]))
  const ranked = [...song.tracks].sort((a, b) => stats.get(b.index).notes - stats.get(a.index).notes)
  const byNeed = [...ranked.filter(t => t.isDrums), ...ranked.filter(t => !t.isDrums)]
  const voiceOf = (t, program = t.programs[0]?.program ?? 0) =>
    defaultVoice({ genre, isDrums: t.isDrums, program, ...stats.get(t.index) })
  const groups = groupParts(byNeed, stats, voiceOf)
  const pitchOf = group => stats.get(group[0].index).medianPitch
  const chosen = groups.sort((a, b) => (b[0].isDrums - a[0].isDrums) || pitchOf(a) - pitchOf(b))
  const phrase = song.bars % 8 === 0 ? 8 : 4
  const sections = song.markers.length
    ? song.markers.map((marker, i) => ({ name: marker.text.trim().split(/\s+/).slice(0, 2).join(' ') || `Part ${i + 1}`,
      from: marker.bar, to: (song.markers[i + 1]?.bar ?? song.bars + 1) - 1 }))
    : Array.from({ length: Math.ceil(song.bars / phrase) }, (_, i) => ({ name: `Part ${i + 1}`, from: i * phrase + 1,
      to: Math.min(song.bars, (i + 1) * phrase) }))
  if (sections[0].from > 1) sections.unshift({ name: 'Pickup', from: 1, to: sections[0].from - 1 })
  const grid = song.markers.length
    ? [8, 4, 2, 1].find(g => sections.every(s => (s.from - 1) % g === 0 && barCount(s) % g === 0)) : phrase
  const familyOf = t => (t.isDrums ? 'Drums' : GM_FAMILIES[Math.floor((t.programs[0]?.program ?? 0) / 8)])
  const groupName = group => (group.every(t => ['drum', 'hit'].includes(VOICES[voiceOf(t)].kind)) && group.length > 1
    ? 'Percussion' : [...new Set(group.map(familyOf))].join(' & '))
  const familyCount = new Map()
  const columns = chosen.map((group, i) => {
    const [t] = group
    const s = stats.get(t.index)
    const family = groupName(group)
    const twins = chosen.filter(other => groupName(other) === family).length
    familyCount.set(family, (familyCount.get(family) ?? 0) + 1)
    const name = twins > 1 ? `${family} ${familyCount.get(family)}` : family
    const id = name.toLowerCase().replace(/ (\w)/g, (_, c) => c.toUpperCase()).replace(/[^a-zA-Z0-9]/g, '')
    const voices = group.flatMap(part => part.programs.map(change => ({ ...(part === t ? {} : { part: part.index }),
      fromBar: change.bar, program: change.program, voice: voiceOf(part, change.program) })))
    const ctlOf = v => JSON.stringify(VOICES[v.voice].ctl)
    for (const v of voices) if (ctlOf(v) !== ctlOf(voices[0])) v.voice = voices[0].voice
    return { page: 1, col: i + 1, id, name, part: t.index, partName: t.name, voices, patterns: [{ name: 'Written' }] }
  })
  const stopBars = defaultStopBars(song, columns)
  const harmony = defaultHarmony(song)
  for (const column of columns) {
    const bars = stats.get(column.part).bars.filter(bar => !stopBars.includes(bar))
    const start = bars.find(bar => (bar - 1) % harmony.length === 0 &&
      harmony.every((_, k) => bars.includes(bar + k)))
    if (start) column.patterns.push({ name: 'Always', bars: harmony.map((_, k) => start + k) })
  }
  const drums = columns.find(column => VOICES[column.voices[0].voice].kind === 'drum')
  const drumBars = drums ? stats.get(drums.part).bars : []
  const barsIn = (bars, s) => bars.filter(bar => bar >= s.from && bar <= s.to).length
  const plays = drums ? sections.filter(s => barsIn(drumBars, s) >= barCount(s) / 2).map(s => s.name)
    : sections.map(s => s.name)
  const activeIn = s => columns.filter(c => barsIn(stats.get(c.part).bars, s)).length
  const busiest = [...sections].sort((a, b) => activeIn(b) - activeIn(a))[0]
  const loops = (song.markers.length ? sections : [...new Set([sections[0], busiest])])
    .filter(s => (s.from - 1) % grid === 0 && barCount(s) % grid === 0)
  const first = harmony[0]
  return {
    track, title: slug.replace(/-/g, ' '), genre, source: path.basename(midiFile), template: 'song',
    bpm: song.tempo,
    key: { name: `${SHARP_NAMES[first.root]} ${first.minor ? 'minor' : 'major'}`, root: first.root,
      scale: first.minor ? 'minor' : 'major' },
    harmony: harmony.map(({ name: chordName, pad }) => ({ name: chordName, pad })),
    sections, stopBars, grid,
    chapters: [{ name: 'Song', from: 1, to: song.bars },
      ...loops.map(s => ({ name: s.name, from: s.from, to: s.to }))],
    master: 0.6,
    columns: [
      ...columns,
      ...(EXTRA_COLUMNS[genre] ?? []).map(extra => ({ page: 2, ...extra, voices: [{ voice: extra.voice }], plays,
        patterns: VOICES[extra.voice].patterns?.map(p => ({ name: p })) ??
          [{ name: 'Written' }, { name: 'Always', figure: true }] }))
        .map(({ voice, ...column }) => column),
    ],
    launchkey: { keysGain: 0.8, pads: PADS[genre] ?? EDM_PADS },
    performance: defaultPerformance(song.bars, sections, columns, stats),
  }
}

// Parts → at most 7 groups (one per column): the beat parts (drums, hits) share one, then the smallest part joins the
// part nearest in pitch that plays the same way (chords or lines) and has the same controls
function groupParts(parts, stats, voiceOf) {
  const groups = parts.map(t => [t])
  const kindOf = t => VOICES[voiceOf(t)].kind
  const ctlOf = t => JSON.stringify(VOICES[voiceOf(t)].ctl)
  const beats = groups.filter(([t]) => ['drum', 'hit'].includes(kindOf(t)))
  if (groups.length > MAX_COLUMNS && beats.length > 1 && beats.every(([t]) => ctlOf(t) === ctlOf(beats[0][0]))) {
    beats[0].push(...beats.slice(1).flat())
    for (const beat of beats.slice(1)) groups.splice(groups.indexOf(beat), 1)
  }
  const notesOf = group => group.reduce((sum, t) => sum + stats.get(t.index).notes, 0)
  while (groups.length > MAX_COLUMNS) {
    const smallest = groups.filter(([t]) => !['drum', 'hit'].includes(kindOf(t)))
      .sort((a, b) => notesOf(a) - notesOf(b))[0]
    const [t] = smallest
    const near = groups.filter(group => group !== smallest && ctlOf(group[0]) === ctlOf(t))
      .sort((a, b) => (stats.get(a[0].index).polyphonic !== stats.get(t.index).polyphonic) -
        (stats.get(b[0].index).polyphonic !== stats.get(t.index).polyphonic) ||
        Math.abs(stats.get(a[0].index).medianPitch - stats.get(t.index).medianPitch) -
        Math.abs(stats.get(b[0].index).medianPitch - stats.get(t.index).medianPitch))[0]
    if (!near) throw new Error(`more than ${MAX_COLUMNS} parts and ${t.name} fits no column; group it in the map`)
    near.push(...smallest)
    groups.splice(groups.indexOf(smallest), 1)
  }
  return groups
}

function defaultPerformance(bars, sections, columns, stats) {
  const moves = [{ bar: 0, set: 'Master', to: 0.9 }]
  for (const column of columns) {
    const first = stats.get(column.part).bars[0]
    const section = sections.find(s => first >= s.from && first <= s.to)
    moves.push({ bar: section.from - 1, set: `${column.name} Level`, to: 0.6, ramp: 2 })
  }
  const last = sections.at(-1)
  moves.push({ bar: bars + last.from - 1, set: 'Master', to: 0, ramp: barCount(last) })
  moves.sort((a, b) => a.bar - b.bar)
  return {
    name: 'first-pass', title: 'First pass', bars: 2 * bars,
    mood: 'the song as written, parts entering where they start',
    sections: [0, 1].flatMap(run => sections.map(s => ({ name: s.name, from: run * bars + s.from - 1,
      to: run * bars + s.to, intent: run ? 'second run, everything in, fade in the last section' :
        'parts come in where the song starts them' }))),
    moves,
  }
}

// ---------- checks ----------

export function checkMap(map, song) {
  const errors = []
  const sections = map.sections
  sections.forEach((s, i) => {
    const expected = (sections[i - 1]?.to ?? 0) + 1
    if (s.from !== expected) errors.push(`section ${s.name}: starts at ${s.from}, expected ${expected}`)
  })
  if (sections.at(-1).to !== song.bars) {
    errors.push(`sections end at bar ${sections.at(-1).to}, the song has ${song.bars}`)
  }
  for (const chapter of map.chapters) {
    if (!sections.some(s => s.from === chapter.from) || !sections.some(s => s.to === chapter.to))
      errors.push(`chapter ${chapter.name}: bars ${chapter.from}-${chapter.to} do not start and end on sections`)
    if ((chapter.from - 1) % map.grid || (chapter.to - chapter.from + 1) % map.grid)
      errors.push(`chapter ${chapter.name}: bars ${chapter.from}-${chapter.to} are not on the ${map.grid}-bar grid`)
  }
  const seen = new Set()
  for (const column of map.columns) {
    const where = `column ${column.page}:${column.col} ${column.name}`
    if (seen.has(`${column.page}:${column.col}`)) errors.push(`${where}: two columns on the same place`)
    seen.add(`${column.page}:${column.col}`)
    if (!(column.col >= 1 && column.col <= MAX_COLUMNS)) errors.push(`${where}: col must be 1-${MAX_COLUMNS}`)
    if (!/^[a-z][a-zA-Z0-9]*$/.test(column.id)) errors.push(`${where}: id must be a word in camelCase`)
    for (const v of column.voices) if (!VOICES[v.voice]) errors.push(`${where}: unknown voice ${v.voice}`)
    for (const part of new Set([column.part, ...column.voices.map(v => v.part)].filter(p => p !== undefined))) {
      if (!song.tracks.some(t => t.index === part)) errors.push(`${where}: no MIDI part ${part}`)
    }
    const ctls = new Set(column.voices.filter(v => VOICES[v.voice]).map(v => JSON.stringify(VOICES[v.voice].ctl)))
    if (ctls.size > 1) errors.push(`${where}: its voices have different controls (ctl); pick voices that share them`)
    if (column.patterns.length > 3) errors.push(`${where}: at most 3 patterns`)
  }
  return errors
}

// ---------- building the track ----------

const sharedBlock = name => fs.readFileSync(path.join(SHARED, `${name}.strudel-part`), 'utf8').replace(/\n$/, '')

function fillShared(text) {
  return text.replace(/^\/\/ @shared (\S+) begin\n\/\/ @shared \1 end$/gm,
    (_, name) => `// @shared ${name} begin\n${sharedBlock(name)}\n// @shared ${name} end`)
}

function fillTemplate(template, slots, values) {
  return fillShared(template)
    .replace(/^\/\/ @slot (\S+)\n/gm, (_, name) => {
      if (!(name in slots)) throw new Error(`template slot ${name} has no content`)
      return slots[name] ? `${slots[name]}\n` : ''
    })
    .replace(/\{\{(\w+)\}\}/g, (_, name) => {
      if (!(name in values)) throw new Error(`template value ${name} missing`)
      return values[name]
    })
}

const tagOf = page => (page === 2 ? '2' : '16')
const colFnOf = page => (page === 2 ? 'colJonas' : 'colJojo')
const stemOf = column => `stem${column.page === 2 ? 'N' : 'J'}${column.col}_${column.id}`

const sectionsWithNotes = (map, isPlaying) => map.sections.filter(s =>
  Array.from({ length: barCount(s) }, (_, k) => s.from + k).some(isPlaying)).map(s => s.name)

function whereText(map, names) {
  if (names.length === map.sections.length) return 'all through'
  const wordOf = name => name.replace(/\s+\d+$/, '').toLowerCase()
  const words = [...new Set(names.map(wordOf))]
  const plural = words.map(w => (names.filter(n => wordOf(n) === w).length > 1 ? `${w}s` : w))
  const text = plural.length > 1 ? `${plural.slice(0, -1).join(', ')} and ${plural.at(-1)}` : plural[0]
  return plural.length === 1 ? `${text} only` : text
}

// A column's voice entries: { part, voice, from, to }, each playing its part from its bar until the part's next entry
function voiceEntries(column) {
  return column.voices.map((v, i) => {
    const part = v.part ?? column.part
    const next = column.voices.slice(i + 1).find(other => (other.part ?? column.part) === part)
    return { ...v, part, from: v.fromBar ?? 1, to: next ? next.fromBar - 1 : Infinity }
  })
}

// A bar of a hit voice: each chord one hit on its lowest note; [chords of `accent` notes or more, the smaller ones],
// null for a layer without hits
function hitLayers(mini, accent) {
  const layer = loud => mini.split(', ').map(voice => voice.split(' ').map(step => {
    const [, body, weight = ''] = step.match(/^(.*?)(@\d+)?$/)
    if (body === '~') return step
    const notes = body.replace(/^\[|\]$/g, '').split(',')
    return (notes.length >= accent) === loud ? `${notes[0]}${weight}` : `~${weight}`
  }).join(' ')).join(', ')
  return [layer(true), layer(false)].map(m => (/^[~@\d\s,]*$/.test(m) ? null : m))
}

// The entry's bars as expressions (one per song bar, silence outside the entry's bars) and the constants they use
function barsOfEntry(id, entry, column, voice, map, song) {
  const constants = []
  const exprOf = new Map()
  const named = (mini, expr) => {
    if (!exprOf.has(mini)) {
      const name = `${pascal(id)}_${letters(constants.length)}`
      constants.push(`const ${name} = ${expr}`)
      exprOf.set(mini, name)
    }
    return exprOf.get(mini)
  }
  const warnings = []
  if (voice.kind === 'extra') {
    if (voice.harmony) return { constants, bars: [], warnings }
    const figure = named('figure', voice.figure)
    const plays = new Set(column.plays ?? [])
    const bars = Array.from({ length: song.bars }, (_, i) => {
      const bar = i + 1
      const section = map.sections.find(s => bar >= s.from && bar <= s.to)
      return plays.has(section.name) && !map.stopBars.includes(bar) ? figure : 'silence'
    })
    return { constants, bars, warnings, figure }
  }
  const track = song.tracks.find(t => t.index === entry.part)
  const { lines } = dumpTrack(song, track)
  const prefix = `const ${pascal(id)}_X = `
  const stackOf = layers => (layers.length > 1 ? `stack(\n  ${layers.join(',\n  ')})` : layers[0])
  const uniform = voices => {
    const values = new Set(voices.flatMap(v => v.velocity.split(/[\s,]+/)).map(t => t.replace(/@\d+$/, ''))
      .filter(t => t !== '~'))
    return values.size === 1 ? +[...values][0] : null
  }
  const withVelocity = (call, velocity) => (velocity === 1 ? call : `${call}.velocity(${velocity})`)
  // The notes with their loudness: velocity 1 = as written so far, one value for the bar, else a pattern per voice
  const loud = (fn, mini, voices, velocity, rename = m => m) => {
    if (velocity !== null) return withVelocity(miniCall(fn, mini, prefix), velocity)
    const lead = voices.length > 1 ? '  ' : prefix
    return stackOf(voices.map(v => {
      const call = miniCall(fn, rename(v.mini), lead)
      const level = uniform([v])
      return level === null ? `${call}\n    ${miniCall('.velocity', v.velocity, '    ')}` : withVelocity(call, level)
    }))
  }
  const bars = lines.map(line => {
    if (line.bar < entry.from || line.bar > entry.to) return 'silence'
    if (line.tied.length && !voice.ties && voice.kind !== 'hit') {
      warnings.push(`${column.name} bar ${line.bar}: ${line.tied.length} notes tied into the next bar are cut at the ` +
        'bar line')
    }
    if (line.mini === '~') return 'silence'
    if (voice.kind === 'drum') {
      const unknown = new Set()
      const rename = m => m.replace(/[a-z]+\d*/g, token => {
        if (/^[a-g]b?\d$/.test(token) && !voice.token[token]) return token
        if (!voice.token[token]) unknown.add(token)
        return voice.token[token] ?? token
      })
      const mini = rename(line.mini)
      if (unknown.size) warnings.push(`${column.name} bar ${line.bar}: no sample for drums ${[...unknown].join(', ')}`)
      const hits = mini.split(/[\s,]+/).filter(token => token && !token.startsWith('~')).length
      const roll = hits > voice.rollHits ? voice.roll : ''
      if (line.velocity !== 1) {
        return named(`${mini} ${line.velocity}`, `${loud('s', mini, line.voices, line.velocity, rename)}${roll}`)
      }
      return named(mini, `${miniCall('s', mini, `${prefix}${roll}`)}${roll}`)
    }
    if (voice.kind === 'hit') {
      const [strong, soft] = hitLayers(line.mini, voice.accent)
      const level = line.velocity ?? 1
      const lead = strong && soft ? '  ' : prefix
      const layers = [strong && withVelocity(miniCall('note', strong, lead), level),
        soft && withVelocity(miniCall('note', soft, lead), +(voice.ghost * level).toFixed(2))].filter(Boolean)
      return named(`hit ${line.mini}`, stackOf(layers))
    }
    if (voice.ties && line.ties.length) {
      const layers = [...(line.untied === '~' ? []
        : [loud('note', line.untied, line.untiedVoices, uniform(line.untiedVoices))]),
      ...line.ties.map(tie => withVelocity(`${miniCall('note', tie.mini, '  ')}.clip(${tie.clip})`, tie.velocity))]
      const expr = stackOf(layers)
      return named(expr, expr)
    }
    if (line.velocity !== 1) {
      const expr = loud('note', line.mini, line.voices, line.velocity)
      return named(expr, expr)
    }
    return named(line.mini, miniCall('note', line.mini, prefix))
  })
  return { constants, bars, warnings }
}

// { section name: expression } of an entry, identical sections shared through one constant
function songObject(id, bars, map, suffix = 'SONG') {
  const entries = map.sections.map(s => {
    const list = bars.slice(s.from - 1, s.to)
    return [s.name, list.every(b => b === 'silence') ? null : `cat(${list.join(', ')})`]
  }).filter(([, expr]) => expr)
  const counts = new Map()
  for (const [, expr] of entries) counts.set(expr, (counts.get(expr) ?? 0) + 1)
  const hoisted = new Map()
  const lines = []
  for (const [name, expr] of entries) {
    if (counts.get(expr) > 1 && !hoisted.has(expr)) {
      const constant = `${pascal(id)}_${constOf(name)}${suffix === 'SONG' ? '' : `_${suffix}`}`
      hoisted.set(expr, constant)
      lines.push(...wrapLine(`const ${constant} = ${expr}`, '  '))
    }
  }
  const songName = `${pascal(id)}_${suffix}`
  lines.push(`const ${songName} = {`)
  for (const [name, expr] of entries) lines.push(...wrapLine(`  ${quote(name)}: ${hoisted.get(expr) ?? expr},`, '    '))
  lines.push('}')
  return { lines, songName }
}

// Pattern number `index` of an entry; a column's own bars and figures (bars, mini) play in its first entry only
function patternExpr(pattern, index, { songName, barConst, figure, map, column, first }) {
  if (index === 0) {
    if (pattern.bars || pattern.mini || pattern.transpose || pattern.phrase || pattern.off || pattern.figure)
      throw new Error(`${column.name}: the first pattern is the song as written; give it only a name`)
    return `songOf(${songName})`
  }
  if (pattern.off) return 'silence'
  if (pattern.figure) return figure
  if (pattern.transpose !== undefined) return `songOf(${songName}).add(note(${pattern.transpose}))`
  if (pattern.phrase) {
    const section = map.sections.find(s => s.name === pattern.phrase)
    const length = barCount(section)
    return `arrange([${map.grid - length}, silence], [${length}, ${songName}[${quote(pattern.phrase)}]])`
  }
  if (!first) return 'silence'
  const list = pattern.bars ? pattern.bars.map(barConst) : pattern.mini.map(mini =>
    VOICES[column.voices[0].voice].kind === 'drum' ? `s("${mini}")` : `note("${mini}")`)
  return list.length === 1 ? list[0] : `everyBar(${list.join(', ')})`
}

const camel = text => text.replace(/^(orch|sso)-/, '').replace(/-(\w)/g, (_, c) => c.toUpperCase())
const capital = text => text[0].toUpperCase() + text.slice(1)

// What a column with several entries plays: per part its voices in turn (with bars), parts joined by +
function entriesText(entries, song) {
  const parts = [...new Set(entries.map(e => e.part))]
  return parts.map(part => entries.filter(e => e.part === part).map(e => {
    const to = Math.min(e.to, song.bars)
    return entries.length > parts.length ? `${VOICES[e.voice].what} ${e.from}–${to}` : VOICES[e.voice].what
  }).join(' → ')).join(' + ')
}

function columnCode(column, map, song, warnings) {
  const entries = voiceEntries(column)
  const single = entries.length === 1
  const voice = VOICES[entries[0].voice]
  const used = new Map()
  const built = entries.map((entry, k) => {
    const base = camel(entry.voice)
    used.set(base, (used.get(base) ?? 0) + 1)
    const suffix = used.get(base) > 1 ? `${base}${used.get(base)}` : base
    const id = single ? column.id : `${column.id}${capital(suffix)}`
    const entryVoice = VOICES[entry.voice]
    const result = barsOfEntry(id, entry, column, entryVoice, map, song)
    warnings.push(...result.warnings)
    return { ...result, entry, id, suffix, voice: entryVoice, first: k === 0 }
  })
  const names = column.patterns.map(p => p.name)
  const prefix = `${tagOf(column.page)}:${column.col}`
  const isPlaying = bar => built.some(b => (b.voice.kind === 'extra' && b.voice.harmony) ||
    b.bars[bar - 1] !== 'silence')
  const where = whereText(map, sectionsWithNotes(map, isPlaying))
  const partNames = [...new Set(entries.map(e => e.part))].filter(part => part !== undefined)
    .map(part => (part === column.part ? column.partName : null) ?? song.tracks.find(t => t.index === part)?.name ??
      `track ${part}`)
  const about = single ? voice.about : entriesText(entries, song)
  const what = column.what ?? (single ? voice.what : entriesText(entries, song))
  const header = [
    '// ============================================================',
    ...wrapComment(`// ${column.page === 2 ? 'MODE 2 · ' : ''}${column.col} ${column.name.toUpperCase()} — ` +
      `${about} (${partNames.length ? `song part${partNames.length > 1 ? 's' : ''}: ${partNames.join(', ')}, ` : ''}` +
      `${where})`),
    '// ============================================================',
    `// @ctl ${prefix}.k1 ${voice.ctl.k1}`,
    `// @ctl ${prefix}.k2 ${voice.ctl.k2}`,
    `// @ctl ${prefix}.k3 ${voice.ctl.k3}`,
    `// @ctl ${prefix}.fader Level | ${what}, ${where}.${voice.whatSuffix ?? ''}`,
    `// @ctl ${prefix}.b1 Pattern | ${names.join(' → ')}.`,
    `// @ctl ${prefix}.b2 ${voice.ctl.b2}`,
    `const ${column.id}Col = ${colFnOf(column.page)}(${column.col})`,
    `const ${column.id}Var = change(${column.id}Col.btn, '${column.page === 2 ? 'jonas' : 'jojo'}', ` +
      `${quote(column.name)}, ${names.length}, [${names.map(quote).join(', ')}])`,
  ]
  const stem = stemOf(column)
  const bodies = built.map(b => {
    const bID = pascal(b.id)
    const context = {
      id: b.id, ID: bID, stem: single ? stem : `${stem}_${b.suffix}`, col: `${column.id}Col`, var: `${column.id}Var`,
      pats: `${bID}_PATS`, noisePats: `${bID}_NOISE_PATS`,
      harmonyNotes: map.harmony.map(chord => `note("${chord.pad}")`).join(', '),
    }
    const barConst = bar => b.bars[bar - 1]
    context.patsOf = () => {
      if (b.voice.harmony) return ''
      const out = [...b.constants]
      const songObj = songObject(b.id, b.bars, map)
      out.push(...songObj.lines)
      const list = column.patterns.map((p, i) => patternExpr(p, i, { songName: songObj.songName, barConst,
        figure: b.figure, map, column, first: b.first }))
      out.push(...wrapLine(`const ${bID}_PATS = [${list.join(', ')}]`, '  '))
      if (b.voice.noise) {
        const noiseBars = b.bars.map(x => (x === 'silence' ? 'silence' : `${bID}_NOISE`))
        out.push(`const ${bID}_NOISE = s("white*16")`)
        const noise = songObject(b.id, noiseBars, map, 'NOISE_SONG')
        out.push(...noise.lines)
        const noiseList = column.patterns.map((p, i) => (p.bars || p.mini || p.transpose !== undefined ? 'silence'
          : patternExpr(p, i, { songName: noise.songName, barConst, figure: b.figure, map, column, first: b.first })))
        out.push(...wrapLine(`const ${bID}_NOISE_PATS = [${noiseList.join(', ')}]`, '  '))
      }
      return out.join('\n')
    }
    return { code: b.voice.code(context).replace(/^\n+/, '').replace(/\n{3,}/g, '\n\n'), stem: context.stem }
  })
  const code = [...header, bodies.map(b => b.code).join('\n\n')]
  if (!single) {
    const range = e => `bars ${e.from}–${Math.min(e.to, song.bars)}`
    const parts = built.map(b => `${VOICES[b.entry.voice].what} (part ${b.entry.part}, ${range(b.entry)})`)
    code.push('', ...wrapComment(`// The column: ${parts.join(', ')}`),
      `const ${stem} = stack(${bodies.map(b => b.stem).join(', ')})`)
  }
  return { code: code.join('\n'), stem, lowEnd: voice.lowEnd, voices: built.map(b => b.voice) }
}

function chapterBarsText(chapter) {
  return `bars ${chapter.from}–${chapter.to}`
}

function headerSlot(map, song) {
  const sectionText = map.sections.map(s => `${s.name} ${s.from}-${s.to}`).join(' · ')
  const mode1 = map.columns.filter(c => c.page !== 2)
  const mode2 = map.columns.filter(c => c.page === 2)
  return [
    '// ============================================================',
    `// TRACK ${map.track.split('-')[0]} — ${map.title} in ${map.key.name}, ${map.bpm} BPM, after ${map.source} ` +
      `(${song.bars} bars)`,
    '// One file for any number of controllers, all optional: every Launch Control XL 3 that is connected gets the ' +
      'full',
    '// layout (Mode 1 + Mode 2), a Launchkey MK4 25 adds keys (as in 008-010) and drum pads (one-shots).',
    `// Generated by \`npm run producer\` (tools/producer/make-track.mjs) from ${map.track}-map.json; every part`,
    '// plays its notes as written, stored per section, re-voiced. Change the map and re-run rather than editing by ' +
      'hand.',
    `// One bar = one cycle; song bar 1 = cycle 0; the song loops every ${song.bars} bars:`,
    ...wrapComment(`//   ${sectionText}`),
    ...(map.stopBars.length ? [`//   Stop bars (one hit, then silence): ${map.stopBars.join(', ')}.`] : []),
    `// Mode 1 = ${mode1.map(c => c.name).join(', ')}; Mode 2 = ${mode2.map(c => c.name).join(', ') || 'empty'}.`,
    ...wrapComment(`// Chapter (global button 1): ${map.chapters.map(c => `${c.name} (${chapterBarsText(c)})`)
      .join(' → ')}, at the next ${map.grid}-bar phrase.`),
    '// ============================================================',
  ].join('\n')
}

function tagsSlot(map, song) {
  const number = map.track.split('-')[0]
  const mode1 = map.columns.filter(c => c.page !== 2)
  const mode2 = map.columns.filter(c => c.page === 2)
  const colTag = (page, columns) => Array.from({ length: MAX_COLUMNS }, (_, i) =>
    `// @col ${page}:${i + 1} ${i + 1} ${columns.find(c => c.col === i + 1)?.name ?? '–'}`)
  const rows = page => ['k1 Row 1 \\ Brightness', 'k2 Row 2 \\ Space', 'k3 Row 3 \\ Character', 'fader Fader \\ Level',
    'b1 Button 1 \\ Change', 'b2 Button 2 \\ Moment'].map(row => `// @row ${page}:${row}`)
  const sectionText = map.sections.map(s => `${s.name} (${s.from}–${s.to})`).join(', ')
  const loops = map.chapters.slice(1)
  return [
    `// @layout Track ${number} — ${map.title}`,
    '// @globalcc same',
    `// @note ${map.title} in ${map.key.name}, ${map.bpm} BPM, ${song.bars} bars that loop: ${sectionText}. ` +
      `Mode 1 plays the song's parts exactly as written; ` +
      `${mode2.length ? 'Mode 2 adds what the song does not have.' : 'Mode 2 is empty.'}`,
    '// @note Every row means the same everywhere: row 1 = brightness, row 2 = space, row 3 = character, fader = ' +
      'level, ' +
      'button 1 = next pattern (at the next bar), button 2 = a moment while held.',
    '// @note Start with all faders down. Nothing sounds until the Master fader (column 8) is up. All knobs at 0 = ' +
      'the ' +
      'song as written, dry and clear.',
    '// @note Every Launch Control XL 3 gets this full layout: Mode 1 = the song (columns 1–7, same CCs as Mode 16), ' +
      `Mode 2 = ${mode2.length ? 'extras' : 'empty'}. Column 8 is global on both pages. Two controllers: the control ` +
      'moved last wins.',
    `// @mode 16 Mode 1 — Song (the parts as written) · same CCs as Mode 16`,
    '// @col 16:8 8 Global',
    ...colTag(16, mode1),
    ...rows(16),
    `// @mode 2 Mode 2 — ${map.mode2 ?? 'Extras'} (${mode2.map(c => c.name.toLowerCase()).join(', ') || 'none'}) · ` +
      'CC + 48',
    ...colTag(2, mode2),
    '// @col 2:8 8 Global',
    ...rows(2),
    '// @guide The song | Mode 1 is the song: every column plays its part as written, where the song has it. Faders ' +
      'decide who plays; Pattern can make a part play in every bar.',
    `// @guide The song | The song loops every ${song.bars} bars.` + (loops.length ? ' Chapter holds it in ' +
      `${loops.map(c => `the ${c.name} (bars ${c.from}–${c.to})`).join(' or ')} as long as you like; Song lets it ` +
      'run on.' : ''),
    hasClap(map) ? '// @guide Build-up and drop | Turn Tension up (with the Clap fader up for its snare roll), press ' +
      'Break at the top: the low end goes out. Break again: everything lands on the one.'
      : '// @guide Build-up and drop | Turn Tension up, press Break at the top: the low end goes out. Break again: ' +
      'everything lands on the one.',
    '// @guide Every position sounds good | No filter closes completely. At Space 0 everything is dry.',
    '// @guide Status box | The status box at the bottom right of the Strudel page shows chapter, break and each ' +
      'stem\'s pattern. Its button “as window” opens it as a small window that stays on top (Chrome/Edge).',
    '// @guide Playing together | Both Launch Controls have the full layout and steer the same sounds: whoever moves ' +
      'a ' +
      'control last sets its value, a button press counts from either. Agree who plays which page.',
  ].join('\n')
}

// Chapters whose first bar lies on a multiple of their length play bar = cycle mod length; others are shifted, so a
// chapter always plays the bar the song itself would play in its first run (switching keeps the song's place)
const chaptersAligned = map => map.chapters.every(c => (c.from - 1) % (c.to - c.from + 1) === 0)
const hasClap = map => map.columns.some(column => column.voices.some(v => v.voice === 'clap-909'))

function chaptersSlot(map) {
  const aligned = chaptersAligned(map)
  return [
    '// ============================================================',
    `// CHAPTERS — where the song plays; each switches at the next ${map.grid}-bar phrase ` +
      (aligned ? '(a chapter\'s bar = cycle mod its length)'
        : '(each plays the bar the song is at)'),
    '// ============================================================',
    'const SECTIONS = [',
    ...map.sections.map(s => `  { name: ${quote(s.name)}, from: ${s.from}, to: ${s.to} },`),
    ']',
    'const CHAPTERS = [',
    ...map.chapters.map(c => `  { name: ${quote(c.name)}, bars: ${quote(chapterBarsText(c))}, from: ${c.from}, ` +
      `to: ${c.to} },`),
    ']',
    '// Song bar that plays in cycle c under chapter ch',
    aligned ? 'const songBarOf = (c, ch) => CHAPTERS[ch].from + c % (CHAPTERS[ch].to - CHAPTERS[ch].from + 1)'
      : 'const songBarOf = (c, ch) => { const { from, to } = CHAPTERS[ch], length = to - from + 1\n' +
        '  return from + ((c - from + 1) % length + length) % length }',
    'const sectionOf = bar => SECTIONS.find(s => bar <= s.to).name',
  ].join('\n')
}

function globalCtlSlot(map) {
  return [
    '// @ctl g.k1 Fog | clear ↔ muffled (all low-passes down).',
    '// @ctl g.k2 Thin | full ↔ thin (all high-passes up).',
    `// @ctl g.k3 Tension | build-up: echo, reverb, open filters${hasClap(map) ? '; Clap rolls' : ''}.`,
    '// @ctl g.fader Master | volume of everything.',
    `// @ctl g.b1 Chapter | ${map.chapters.map(c => c.name).join(' → ')}, at the next ${map.grid}-bar phrase.`,
    '// @ctl g.b2 Break | 1st: low end out. 2nd: all back on the one.',
  ].join('\n')
}

function songFormSlot(map) {
  return [
    '// ============================================================',
    '// SONG FORM — each part is stored per section, every bar a pattern of one cycle from the MIDI dump',
    '// (producer/midi-read.mjs --dump). songOf plays a part where the chapter is: the sections inside the ' +
      'chapter\'s bars.',
    '// ============================================================',
    'const songOf = parts => pick(chapterLatch, CHAPTERS.map(ch => arrange(...SECTIONS',
    `  .filter(s => s.from >= ch.from && s.to <= ch.to).map(s => [s.to - s.from + 1, parts[s.name] ?? silence]))` +
      `${chaptersAligned(map) ? '' : '\n  .late(ch.from - 1)'}))`,
    ...wrapComment(`// Chord of the bar for the patterns that play in every bar: ${map.harmony.map(c => c.name).join(', ')} ` +
      'in turn'),
    'const everyBar = (...bars) => cat(...bars)',
  ].join('\n')
}

function viewSlot(map) {
  return [
    `// Keys in ${map.key.name} (pitch class ${map.key.root}), the track's scale, light up softly in the LC view`,
    `const SCALE = [${SCALES[map.key.scale].join(', ')}]`,
    `const inKey = m => SCALE.includes(((m - ${map.key.root}) % 12 + 12) % 12)`,
    `// Where the music is (LC view): the beat in the bar and the bar in the ${map.grid}-bar phrase (every chapter ` +
      'switches on it).',
    '// chordAt(bar) = the chord of that bar',
    `const CYCLE   = ${map.grid}`,
    ...wrapLine(`const HARMONY = [${map.harmony.map(c => quote(c.name)).join(', ')}]`, '  '),
    'const chordAt = bar => HARMONY[bar % HARMONY.length]',
  ].join('\n')
}

function launchkeyHeadSlot(map) {
  return [
    '// ============================================================',
    '// LAUNCHKEY MK4 25 — keys play the sounds of Jonas\' keys (009, column 2), the 16 drum pads play one-shots',
    '// ============================================================',
    '// Mod wheel (CC 1) = keys level (× master). Knob 1 brightness; knobs 2-4 the sound mix (2 piano → Rhodes, 3 ' +
      'organ',
    '// B3 → M1, 4 vibraphone → marimba): 0 off, a third = the first sound, then it blends into the second, alone at ' +
      'two',
    '// thirds, which fades out towards full. 5 length, 6 space, 7 echo, 8 pad fog (one-shot darkness, 0 = open). ' +
      'Until',
    '// knob 2 is turned the keys play piano + Rhodes. Drum pads (Drum mode, channel 10, notes 36-51) ignore knobs ' +
      '1-7.',
    `// Same knobs and keys as in 008-010; only the pads differ. The song is in ${map.key.name}.`,
    '// Names for the LC view (its Launchkey row).',
    '// @lk level Keys Level | mod wheel: volume of the keys (× master).',
    '// @lk k1 Brightness | dull ↔ bright; harder keys brighter.',
    '// @lk k2 Piano → Rhodes | off → piano → Rhodes → off.',
    '// @lk k3 B3 → M1 | off → organ B3 → M1 → off.',
    '// @lk k4 Vibes → Marimba | off → vibraphone → marimba → off.',
    '// @lk k5 Length | short notes ↔ long.',
    '// @lk k6 Space | a little air ↔ room.',
    '// @lk k7 Echo | dry ↔ long echo.',
    '// @lk k8 Pad Fog | drum pads: clear ↔ muffled, like the global Fog.',
  ].join('\n')
}

function padsSlot(map) {
  return map.launchkey.pads.flatMap(({ about, ...shot }) => [
    ...(about ?? []).map(line => `  // ${line}`),
    ...wrapLine(`  ${literal(shot)},`, '    '),
  ]).join('\n')
}

// The sample sets the voices and pads play, loaded as in 009 (SSO_URL + folder + file)
function voiceSamplesSlot(map) {
  const names = new Set([
    ...map.columns.flatMap(column => column.voices.flatMap(v => VOICES[v.voice].samples ?? [])),
    ...map.launchkey.pads.flatMap(pad => [pad.s, ...(pad.layers ?? []).map(layer => layer.s)]),
  ].filter(name => SAMPLE_SETS[name]))
  if (!names.size) return ''
  const groupCode = ([dir, prefix, notes, suffix]) => (notes.length
    ? `ssoMap('${dir}', '${prefix}', [${notes.map(quote).join(', ')}], '${suffix}')`
    : `[SSO + '${dir}/${prefix}${suffix}']`)
  return [
    '// Orchestra samples: Sonatina Symphonic Orchestra (github.com/peastman/sso), a name per section and articulation',
    `const SSO = '${SSO_URL}'`,
    'const ssoMap = (dir, pre, names, post) => Object.fromEntries(names.map(n => [n.toLowerCase(),',
    '  SSO + dir + \'/\' + pre + n.replace(\'#\', \'%23\') + post]))',
    'if (typeof samples === \'function\') await samples({',
    ...[...names].flatMap(name => {
      const groups = SAMPLE_SETS[name]
      const value = groups.length === 1 ? groupCode(groups[0])
        : `{ ${groups.map(g => `...${groupCode(g)}`).join(', ')} }`
      return wrapLine(`  ${name}: ${value},`, '    ')
    }),
    '})',
  ].join('\n')
}

export function buildTrack(map, song, template = fs.readFileSync(TEMPLATE, 'utf8')) {
  const warnings = []
  const columns = [...map.columns].sort((a, b) => pageNumber(a.page) - pageNumber(b.page) || a.col - b.col)
  const built = columns.map(column => columnCode(column, map, song, warnings))
  const slots = {
    header: headerSlot(map, song),
    tags: tagsSlot(map, song),
    chapters: chaptersSlot(map),
    'global-ctl': globalCtlSlot(map),
    'song-form': songFormSlot(map),
    stems: built.map(b => b.code).join('\n\n'),
    view: viewSlot(map),
    'launchkey-head': launchkeyHeadSlot(map),
    pads: padsSlot(map),
    'voice-samples': voiceSamplesSlot(map),
    master: ['stack(', ...built.map(b => `  ${b.stem},`), '  stemLK,', '  stateTaps'].join('\n'),
  }
  const text = fillTemplate(template, slots, { bpm: map.bpm, master: map.master, keysGain: map.launchkey.keysGain,
    grid: map.grid, mode2: map.mode2 ?? 'Extras' })
  return { text, warnings, stems: built.map(b => b.stem) }
}

// ---------- the performance ----------

export function controlTable(map) {
  const table = new Map()
  for (const [row, name] of Object.entries(GLOBAL_NAMES)) table.set(name, { cc: BASE[row] + 8, button: row[0] === 'b' })
  for (const column of map.columns) {
    const voice = VOICES[column.voices[0].voice]
    const names = { ...voice.ctl, fader: 'Level', b1: 'Pattern' }
    for (const [row, text] of Object.entries(names)) {
      table.set(`${column.name} ${text.split(' | ')[0]}`, { cc: BASE[row] + column.col + (column.page === 2 ? 48 : 0),
        button: row[0] === 'b' })
    }
  }
  return table
}

export function buildScript(map) {
  const performance = map.performance
  const controls = controlTable(map)
  const pads = [...VOICE_PADS, ...map.launchkey.pads.map(p => p.name)]
  const steps = performance.moves.map((move, i) => {
    const at = `performance move ${i + 1} (bar ${move.bar})`
    const control = name => {
      if (!controls.has(name)) {
        throw new Error(`${at}: no control '${name}' (names: ${[...controls.keys()].join(', ')})`)
      }
      return controls.get(name)
    }
    if (move.set !== undefined) {
      return { bar: move.bar, cc: control(move.set).cc, value: move.to, ...(move.ramp ? { ramp: move.ramp } : {}) }
    }
    if (move.press !== undefined) return { bar: move.bar, press: control(move.press).cc }
    if (move.pad !== undefined) {
      const index = pads.indexOf(move.pad)
      if (index < 0) throw new Error(`${at}: no pad '${move.pad}' (pads: ${pads.join(', ')})`)
      return { bar: move.bar, pad: PAD_NOTE_1 + index }
    }
    if (move.lk !== undefined) {
      if (!(move.lk in LK_NAMES)) throw new Error(`${at}: no Launchkey control '${move.lk}'`)
      return { bar: move.bar, lk: LK_NAMES[move.lk], value: move.to, ...(move.ramp ? { ramp: move.ramp } : {}) }
    }
    if (move.keys !== undefined) return { ...move }
    throw new Error(`${at}: needs set, press, pad, lk or keys`)
  })
  return {
    track: map.track, title: performance.title, bars: performance.bars, mood: performance.mood,
    sections: performance.sections, steps,
  }
}

// ---------- design stubs ----------

function designStub(map, song) {
  const partText = index => {
    const t = song.tracks.find(track => track.index === index)
    return `${t.name} (program ${t.programs.map(p => p.program).join(' → ')}, ${distinctNotes(t.notes).length} notes)`
  }
  const rows = map.columns.map(column => {
    const entries = column.part === undefined ? [] : voiceEntries(column)
    const parts = [...new Set(entries.map(e => e.part))].map(partText).join(' + ') || '– (extra)'
    const where = e => `${e.part === column.part ? '' : `part ${e.part}, `}bars ${e.from}-${Math.min(e.to, song.bars)}`
    const voices = entries.length > 1 ? entries.map(e => `${e.voice} (${where(e)})`).join(', ') : column.voices[0].voice
    return `| ${column.page === 2 ? 'Mode 2' : 'Mode 1'} · ${column.col} | ${column.name} | ${parts} | ${voices} | ` +
      `${column.patterns.map(p => p.name).join(' → ')} |`
  })
  return [
    `# ${map.track} — song design (generated stub)`,
    '',
    `Generated by \`npm run producer\` from \`${map.source}\` and \`${map.track}-map.json\`. Fill in and discuss in`,
    '`feedback.md`; decisions go into the map, then re-run the producer.',
    '',
    '## The song',
    '',
    `- ${map.bpm} BPM, ${song.bars} bars, key ${map.key.name}, chords per bar: ` +
      `${map.harmony.map(c => c.name).join(', ')}.`,
    `- Stop bars: ${map.stopBars.join(', ') || 'none'}.`,
    ...song.warnings.map(w => `- MIDI warning: ${w}`),
    '',
    '| Section | Song bars | Script bars (run 1) |',
    '|---|---|---|',
    ...map.sections.map(s => `| ${s.name} | ${s.from}-${s.to} | ${s.from - 1}-${s.to - 1} |`),
    '',
    `Script bar = song bar − 1 + ${song.bars} × run.`,
    '',
    '## Layout',
    '',
    '| Column | Name | MIDI part | Voice | Pattern (button 1) |',
    '|---|---|---|---|---|',
    ...rows,
    '',
    ...(map.unassigned?.length ? ['Parts without a column: ' + map.unassigned.map(u =>
      `${u.partName} (program ${u.program}, ${u.notes} notes)`).join(', ') + '.', ''] : []),
    `Chapter: ${map.chapters.map(c => `${c.name} (bars ${c.from}-${c.to})`).join(' → ')}, ` +
      `at the next ${map.grid}-bar phrase.`,
    '',
    '## Open questions',
    '',
    '- Columns, voices and patterns above: right for the song?',
    '- Levels: run `npm run audibility -- <track>` before the performance is written.',
    '',
  ].join('\n')
}

function performStub(map, script) {
  return [
    `# ${script.title}`,
    '',
    `Design for \`perform/${map.track}/${map.performance.name}.json\` (generated stub from \`${map.track}-map.json\`).`,
    'Status: generated, waiting for the user.',
    '',
    '## Meta',
    `- Track: ${map.track}`,
    `- Length: ${script.bars} bars at ${map.bpm} BPM`,
    `- Mood: ${script.mood}`,
    '',
    'Script bar = song bar − 1 (+ song length × run).',
    '',
    '## Sections',
    '| Section | Bars | Intent |',
    '|---|---|---|',
    ...script.sections.map(s => `| ${s.name} | ${s.from + 1}-${s.to} | ${s.intent ?? ''} |`),
    '',
  ].join('\n')
}

// ---------- the map file: a value on one line when it fits, else one entry per line ----------

export function formatMap(map) {
  const compact = value => JSON.stringify(value, null, 1).replace(/\n\s*/g, ' ')
    .replace(/\[ /g, '[').replace(/ \]/g, ']')
  const format = (value, indent) => {
    const flat = compact(value)
    if (indent.length + flat.length <= 116 || !value || typeof value !== 'object') return flat
    const inner = indent + '  '
    if (Array.isArray(value)) return `[\n${value.map(item => inner + format(item, inner)).join(',\n')}\n${indent}]`
    return `{\n${Object.entries(value).map(([key, v]) => `${inner}${JSON.stringify(key)}: ${format(v, inner)}`)
      .join(',\n')}\n${indent}}`
  }
  return format(map, '') + '\n'
}

// ---------- the command ----------

function parseArgs(args) {
  const options = { force: args.includes('--force'), perform: args.includes('--perform') }
  const valueOf = name => (args.includes(name) ? args[args.indexOf(name) + 1] : undefined)
  for (const name of ['map', 'name', 'genre', 'out']) options[name] = valueOf(`--${name}`)
  const withValue = ['--map', '--name', '--genre', '--out']
  options.midi = args.find((arg, i) => !arg.startsWith('--') && !withValue.includes(args[i - 1]))
  return options
}

export function produce(options) {
  const cwd = process.env.INIT_CWD ?? process.cwd()
  const midi = path.resolve(cwd, options.midi)
  const song = readMidi(midi)
  const given = options.map ? JSON.parse(fs.readFileSync(path.resolve(cwd, options.map), 'utf8')) : null
  const map = given ?? defaultMap(song, midi, { name: options.name, genre: options.genre })
  if (options.name) map.track = options.name
  if (options.genre) map.genre = options.genre
  const errors = checkMap(map, song)
  if (errors.length) throw new Error(`map:\n  ${errors.join('\n  ')}`)
  const trackDir = options.out ? path.resolve(cwd, options.out) : path.join(ROOT, 'tracks', map.genre, map.track)
  const performDir = options.out ? trackDir : path.join(PERFORM, map.track)
  const { text, warnings } = buildTrack(map, song)
  const script = buildScript(map)
  const scriptFile = [path.join(performDir, `${map.performance.name}.json`), JSON.stringify(script, null, 2) + '\n']
  const files = options.perform ? [scriptFile] : [
    [path.join(trackDir, `${map.track}.strudel`), text],
    [path.join(trackDir, `${map.track}-design.md`), designStub(map, song)],
    scriptFile,
    [path.join(performDir, `${map.performance.name}.md`), performStub(map, script)],
  ]
  if (!given && !options.perform) files.push([path.join(trackDir, `${map.track}-map.json`), formatMap(map)])
  if (path.dirname(midi) !== trackDir && !options.out && !options.perform) {
    files.push([path.join(trackDir, path.basename(midi)), fs.readFileSync(midi)])
  }
  const existing = options.perform ? [] :
    files.filter(([file]) => fs.existsSync(file)).map(([file]) => path.relative(cwd, file))
  if (existing.length && !options.force) {
    throw new Error(`these files exist; choose another --name or --out, or pass --force:\n  ${existing.join('\n  ')}`)
  }
  for (const [file, content] of files) {
    fs.mkdirSync(path.dirname(file), { recursive: true })
    fs.writeFileSync(file, content)
  }
  return { map, files: files.map(([file]) => file), warnings: [...song.warnings, ...warnings] }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const options = parseArgs(process.argv.slice(2))
  if (!options.midi) {
    console.error('usage: npm run producer -- <file.mid> [--map <map.json>] [--name <NNN-name>] [--genre <genre>] ' +
      '[--out <dir>] [--force] [--perform]')
    process.exit(1)
  }
  try {
    const { files, warnings } = produce(options)
    const cwd = process.env.INIT_CWD ?? process.cwd()
    for (const file of files) console.log(`wrote ${path.relative(cwd, file)}`)
    for (const warning of warnings) console.log(`warning: ${warning}`)
  } catch (error) {
    console.error(error.message)
    process.exit(1)
  }
}
