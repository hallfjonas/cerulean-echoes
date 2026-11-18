import test from 'node:test'
import assert from 'node:assert/strict'
import { mini } from '@strudel/mini'
import { readMidi, dumpTrack, distinctNotes, noteName, drumName } from './midi-read.mjs'

const SOURCES = [
  { file: '../../tracks/edm/012-edm-snippet/gp-edm-snippet.mid', tempo: 120, bars: 24, markers: [],
    parts: [[30, 198], [30, 140], [0, 522], [38, 13], [120, 64], [34, 58], [29, 139]],
    grids: [8, 32, 64, 8, 64, 8, 8] },
  { file: '../../tracks/classical/013-hope-for-niklas/gp-classical.mid', tempo: 110, bars: 56, markers: [1, 31, 47],
    parts: [[0, 800], [42, 296], [40, 430], [45, 484], [14, 204], [116, 1346], [61, 360], [49, 416], [0, 158]],
    grids: [8, 16, 16, 16, 8, 32, 8, 8, 16] },
]
const PROGRAM_CHANGES = { 'gp-classical.mid': { 2: [[13, 35], [31, 40], [47, 43]], 8: [[56, 55]] } }
const QUARTERS_PER_BAR = 4

const sourcePath = file => new URL(file, import.meta.url)
const roundTo = value => Math.round(value * 1e9) / 1e9
const eventKey = ({ start, length, pitch }) => `${roundTo(start)}|${roundTo(length)}|${pitch}`

function pitchLookup(track) {
  const names = new Map()
  for (let pitch = 0; pitch < 128; pitch++) names.set(track.isDrums ? drumName(pitch) : noteName(pitch), pitch)
  return names
}

function midiEventsOfBar(notes, bar, ticksPerBar) {
  const barStartTick = (bar - 1) * ticksPerBar
  return notes.filter(note => note.bar === bar).map(note => ({
    start: (note.tick - barStartTick) / ticksPerBar,
    length: (note.endTick - note.tick) / ticksPerBar,
    pitch: note.pitch,
  }))
}

function dumpEventsOfBar(line, pitches) {
  const events = mini(line.mini).queryArc(0, 1).map(hap => ({
    start: hap.whole.begin.valueOf(),
    length: hap.whole.end.valueOf() - hap.whole.begin.valueOf(),
    pitch: pitches.get(hap.value),
  }))
  for (const tie of line.tied) {
    const tiedEvent = events.find(event => roundTo(event.start * 4) === roundTo(tie.beat) &&
      event.pitch === pitches.get(tie.name) && roundTo(event.start + event.length) === 1)
    assert.ok(tiedEvent, `tie ${tie.name} at beat ${tie.beat} not found in '${line.mini}'`)
    tiedEvent.length = tie.length
  }
  return events
}

for (const source of SOURCES) {
  const name = source.file.split('/').at(-1)
  const song = readMidi(sourcePath(source.file))

  test(`${name}: summary matches the PRD source table`, () => {
    assert.equal(song.tempo, source.tempo)
    assert.equal(song.bars, source.bars)
    assert.deepEqual(song.markers.map(marker => marker.bar), source.markers)
    assert.deepEqual(song.warnings, [])
    assert.deepEqual(song.tracks.map(track => [track.programs[0].program, track.notes.length]), source.parts)
    for (const [index, changes] of Object.entries(PROGRAM_CHANGES[name] ?? {})) {
      const programs = song.tracks.find(track => track.index === Number(index)).programs.slice(1)
      assert.deepEqual(programs.map(change => [change.bar, change.program]), changes)
    }
  })

  test(`${name}: dump -> mini-notation -> same note events per part per bar`, () => {
    const ticksPerBar = song.ticksPerQuarter * QUARTERS_PER_BAR
    song.tracks.forEach((track, trackPosition) => {
      const { grid, lines } = dumpTrack(song, track)
      assert.equal(grid, source.grids[trackPosition], `grid of track ${track.index}`)
      const notes = distinctNotes(track.notes)
      const pitches = pitchLookup(track)
      for (const line of lines) {
        const expected = midiEventsOfBar(notes, line.bar, ticksPerBar).map(eventKey).sort()
        const actual = dumpEventsOfBar(line, pitches).map(eventKey).sort()
        assert.deepEqual(actual, expected, `track ${track.index} bar ${line.bar}: '${line.mini}'`)
      }
    })
  })
}

test('tempo changes and odd meters are reported as unsupported', () => {
  const header = [0x4d, 0x54, 0x68, 0x64, 0, 0, 0, 6, 0, 0, 0, 1, 0x01, 0xe0]
  const events = [
    0, 0xff, 0x58, 4, 3, 2, 24, 8,
    0, 0xff, 0x51, 3, 0x07, 0xa1, 0x20,
    0, 0x90, 60, 100,
    0x83, 0x60, 0x80, 60, 0,
    0, 0xff, 0x51, 3, 0x06, 0x1a, 0x80,
    0, 0xff, 0x2f, 0,
  ]
  const trackHeader = [0x4d, 0x54, 0x72, 0x6b, 0, 0, 0, events.length]
  const song = readMidi(new Uint8Array([...header, ...trackHeader, ...events]))
  assert.equal(song.warnings.length, 2)
  assert.match(song.warnings[0], /unsupported: tempo changes/)
  assert.match(song.warnings[1], /unsupported: time signatures other than 4\/4 \(3\/4 at bar 1\)/)
  assert.equal(song.tracks[0].notes[0].length, 0.25)
})
