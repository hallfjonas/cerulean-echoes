import test from 'node:test'
import assert from 'node:assert/strict'
import fs from 'fs'
import os from 'os'
import path from 'path'
import { fileURLToPath } from 'url'
import { readMidi } from './midi-read.mjs'
import { buildTrack, buildScript, checkMap, defaultMap, formatMap, produce } from './make-track.mjs'
import { load, run, sig, audible } from '../strudel-sim/harness.mjs'

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..')
const PILOT = path.join(ROOT, 'tools/producer/fixtures/012-edm-snippet')
const PILOT_TRACK = path.join(PILOT, '012-edm-snippet.strudel-fixture')
const PILOT_MIDI = path.join(PILOT, 'gp-edm-snippet.mid')
const PILOT_SCRIPT = path.join(PILOT, 'rise-and-drop.json')
const CLASSICAL = path.join(ROOT, 'tools/producer/fixtures/013-hope-for-niklas')
const CLASSICAL_MIDI = path.join(CLASSICAL, 'gp-classical.mid')
const CLASSICAL_MAP = path.join(CLASSICAL, '013-hope-for-niklas-map.json')
const CLASSICAL_SCRIPT = path.join(CLASSICAL, 'one-hope.json')
const SONG_BARS = 24
const PHRASE = 8
const PATTERN_BUTTONS = [...[37, 38, 39, 40, 41, 42, 43], ...[85, 86, 87, 88, 89, 90, 91]]
const CHAPTER_BUTTON = 44

const pilotMap = JSON.parse(fs.readFileSync(path.join(PILOT, '012-edm-snippet-map.json'), 'utf8'))
const pilotSong = readMidi(PILOT_MIDI)
const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'producer-test-'))
const writeTrack = (name, text) => {
  const file = path.join(scratch, name)
  fs.writeFileSync(file, text)
  return file
}

// Every fader up, every knob at 0.4 (Tension's snare roll and the knob layers included); presses happen in onTick
function fullMix() {
  const vals = {}
  for (let column = 1; column <= 8; column++) {
    for (const page of [0, 48]) {
      vals[4 + column + page] = 1
      for (const row of [12, 20, 28]) vals[row + column + page] = 0.4
    }
  }
  return vals
}

// Press the pattern buttons `patternPresses` times and Chapter `chapterPresses` times in the first cycle
const pressing = (vals, patternPresses, chapterPresses) => t => {
  const press = (cc, times) => {
    const k = Math.floor((t - 0.1) / 0.2)
    vals[cc] = t >= 0.1 && k < times && (t - 0.1) % 0.2 < 0.1 ? 1 : 0
  }
  for (const cc of PATTERN_BUTTONS) press(cc, patternPresses)
  press(CHAPTER_BUTTON, chapterPresses)
}

async function songEvents(file, patternPresses, chapterPresses) {
  const vals = fullMix()
  const cycles = chapterPresses ? 2 * PHRASE : SONG_BARS
  const pattern = await load(file, vals, 'stack(stemJ1_kick, stemJ2_sub, stemJ3_bass, stemJ4_chords, stemJ5_lead, ' +
    'stemJ6_arp, stemJ7_riser, stemN1_clap, stemN2_hats, stemN3_pad, stemN4_pump, stateTaps)')
  return sig(run(pattern, 0, cycles, pressing(vals, patternPresses, chapterPresses)).filter(audible))
}

test('012 map passes the checks', () => {
  assert.deepEqual(checkMap(pilotMap, pilotSong), [])
})

test('012 map regenerates the approved performance script step for step', () => {
  assert.deepEqual(buildScript(pilotMap), JSON.parse(fs.readFileSync(PILOT_SCRIPT, 'utf8')))
})

test('012 regenerated from the map plays the hand-built events: every pattern in every chapter', async () => {
  const { text, warnings } = buildTrack(pilotMap, pilotSong)
  assert.deepEqual(warnings, [])
  const generated = writeTrack('012-edm-snippet.strudel', text)
  const scenarios = new Set()
  for (let patternPresses = 0; patternPresses < 3; patternPresses++) {
    for (let chapterPresses = 0; chapterPresses < pilotMap.chapters.length; chapterPresses++) {
      const expected = await songEvents(PILOT_TRACK, patternPresses, chapterPresses)
      const actual = await songEvents(generated, patternPresses, chapterPresses)
      assert.ok(expected.length > 0, `pattern ${patternPresses}, chapter ${chapterPresses}: no events`)
      assert.deepEqual(actual, expected, `pattern ${patternPresses}, chapter ${chapterPresses}`)
      scenarios.add(expected.join('\n'))
    }
  }
  assert.equal(scenarios.size, 3 * pilotMap.chapters.length, 'every press changes what plays')
})

test('013 map regenerates the track and the performance script', () => {
  const map = JSON.parse(fs.readFileSync(CLASSICAL_MAP, 'utf8'))
  assert.deepEqual(checkMap(map, readMidi(CLASSICAL_MIDI)), [])
  assert.equal(buildTrack(map, readMidi(CLASSICAL_MIDI)).text,
    fs.readFileSync(path.join(CLASSICAL, '013-hope-for-niklas.strudel-fixture'), 'utf8'))
  assert.deepEqual(buildScript(map), JSON.parse(fs.readFileSync(CLASSICAL_SCRIPT, 'utf8')))
})

test('--perform writes only the performance script, over an existing one', () => {
  const out = fs.mkdtempSync(path.join(scratch, 'perform-'))
  const script = path.join(out, 'one-hope.json')
  fs.writeFileSync(script, 'old')
  const { files } = produce({ midi: CLASSICAL_MIDI, map: CLASSICAL_MAP, out, perform: true })
  assert.deepEqual(files, [script])
  assert.deepEqual(fs.readdirSync(out), ['one-hope.json'])
  assert.deepEqual(JSON.parse(fs.readFileSync(script, 'utf8')), JSON.parse(fs.readFileSync(CLASSICAL_SCRIPT, 'utf8')))
})

for (const [midi, genre] of [[PILOT_MIDI, 'edm'], [CLASSICAL_MIDI, 'edm'], [CLASSICAL_MIDI, 'classical']]) {
  test(`${path.basename(midi)} without a map (${genre}): defaults pass the checks and the track plays`, async () => {
    const song = readMidi(midi)
    const map = defaultMap(song, midi, { name: '999-default-test', genre })
    assert.deepEqual(checkMap(map, song), [])
    assert.deepEqual(JSON.parse(formatMap(map)), map)
    assert.ok(map.columns.filter(column => column.page === 1).length <= 7)
    const { text } = buildTrack(map, song)
    buildScript(map)
    const vals = fullMix()
    const pattern = await load(writeTrack(`${path.basename(midi)}-${genre}.strudel`, text), vals)
    assert.ok(run(pattern, 0, 2).filter(audible).length > 0)
  })
}
