// Write Launch Control XL 3 custom modes (.syx, for Novation Components) from the @-tags of a two-controller track,
// so the controller's display shows each control's name.
// usage: node make-syx.mjs <NNN-name-dual.strudel> ...  → NNN-name-jojo.syx (B16 tags), NNN-name-jonas.syx (16 + g tags)
//        (all tracks: npm run syx in tools/)
//        node make-syx.mjs <NNN-name-single.strudel> ... → NNN-name-single-mode1.syx (16 tags, "Beat" = foundation),
//                                                          NNN-name-single-mode2.syx (2 tags, "Chords" = colour, CC + 48)
//        any other tagged track → NNN-name-mode16.syx, NNN-name-mode2.syx (CC + 48)
//        column 8 is global (g tags); in Mode 2 it keeps the Mode 16 CCs with "@globalcc same", else + 48
//
// Format (decoded from midi-layouts/setup0.syx, a blank mode exported by Components; same CCs as Mode 16):
//   page:    F0 00 20 29 02 15 05 00 45 <page 00|03> 7F  20 <name length> <name>  <blocks>  F7
//   control: 49 <id> 02 <position> <behaviour> 01 <40 knob/fader | 50 button> 00 <CC> 7F 00
//            buttons keep Components' default (03 .. 50) = momentary, which every button in our tracks expects
//   label:   <60 + length> <id> <ASCII, max 15>
// Control ids: knob rows 0x10 / 0x18 / 0x20, faders 0x28, button rows 0x30 / 0x38 (+ column - 1).
// Page 0 = knobs (controls, then labels); page 1 = faders (controls, labels), then buttons (controls, labels).
// Check: node make-syx.mjs --selftest rebuilds setup0.syx byte for byte.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { parse } from './gen-layout.mjs'

const ROWS = {
  k1:    { id: 0x10, pos: 0x05, cc: 12 },
  k2:    { id: 0x18, pos: 0x09, cc: 20 },
  k3:    { id: 0x20, pos: 0x0d, cc: 28 },
  fader: { id: 0x28, pos: 0x00, cc: 4 },
  b1:    { id: 0x30, pos: 0x19, cc: 36 },
  b2:    { id: 0x38, pos: 0x25, cc: 44 },
}
const BUTTON = r => r === 'b1' || r === 'b2'
// Display names: short column name + control name, at most 15 characters. The short name is the heading's first word
// ("Sea / Wind" → "Sea", "Noise Pump" → "Noise") unless listed here
const SHORT_COL = { 'Organ Bass': 'OrgBass', 'Rubber Bass': 'RubBass', 'Funk Guitar': 'Guitar', 'Deep Chords': 'Chords',
  'Dub Chord': 'DubChord', 'Dub Chords': 'DubChord', 'Glass Bells': 'Bells', Glockenspiel: 'Glock', 'Music Box': 'MusicBox', 'Percussion': 'Perc' }
const shortCol = head => SHORT_COL[head] ?? (/^Melody \d$/.test(head) ? head.replace('Melody', 'Mel') : head.split(/\s*[\s/+]\s*/)[0])
const SHORT_CTL = { Brightness: 'Bright', 'Ghost notes': 'Ghosts', 'Echo throw': 'Echo', 'Master Level': 'Master', 'Break / Drop': 'Break/Drop' }
const MAX_LABEL = 15
const MAX_NAME = 18

const ascii = s => s.replace(/\s*[↔→]\s*/g, '/').normalize('NFKD').replace(/[^\x20-\x7e]/g, '').replace(/\s+/g, ' ').trim()
const text = (s, max) => [...ascii(s).slice(0, max)].map(c => c.charCodeAt(0))

const control = (row, col, shift) => {
  const r = ROWS[row]
  return [0x49, r.id + col - 1, 0x02, r.pos, BUTTON(row) ? 0x03 : 0x00, 0x01, BUTTON(row) ? 0x50 : 0x40, 0x00, r.cc + col + shift(col), 0x7f, 0x00]
}
const label = (row, col, s) => { const t = text(s, MAX_LABEL); return [0x60 + t.length, ROWS[row].id + col - 1, ...t] }

// labels: { 'k1:1': 'Kick Bright', ... }, shift(col) = CC offset → the two SysEx pages as one byte array
export function build(name, labels, shift = () => 0) {
  const head = p => { const n = text(name, MAX_NAME); return [0xf0, 0x00, 0x20, 0x29, 0x02, 0x15, 0x05, 0x00, 0x45, p, 0x7f, 0x20, n.length, ...n] }
  const group = rows => [
    ...rows.flatMap(row => [1, 2, 3, 4, 5, 6, 7, 8].flatMap(col => control(row, col, shift))),
    ...rows.flatMap(row => [1, 2, 3, 4, 5, 6, 7, 8].flatMap(col => label(row, col, labels[`${row}:${col}`] ?? ''))),
  ]
  return [...head(0x00), ...group(['k1', 'k2', 'k3']), 0xf7, ...head(0x03), ...group(['fader']), ...group(['b1', 'b2']), 0xf7]
}

// One mode's labels from the parsed tags; global = column 8 gets the g tags
function labelsFor(d, mode, global) {
  const out = {}
  for (const c of d.ctls) {
    if (c.mode !== mode) continue
    for (let col = c.from; col <= c.to; col++) {
      const head = (d.cols[`${mode}:${col}`] ?? `${col}`).replace(/^\d+\s+/, '')
      const short = shortCol(head)
      const ctl = ascii(SHORT_CTL[c.name] ?? c.name)
      const room = MAX_LABEL - ctl.length - 1
      // "Sea ↔ Wind" in the Sea column needs no prefix; a long control name keeps only a prefix of 3+ letters
      out[`${c.row}:${col}`] = ctl.toLowerCase().includes(short.toLowerCase()) || room < 3 ? ctl : `${short.slice(0, room)} ${ctl}`
    }
  }
  if (global) for (const [row, g] of Object.entries(d.global)) out[`${row}:8`] = SHORT_CTL[g.name] ?? g.name
  return out
}

// Mode name: "NNN <first word of the track name> <Role>", e.g. "009 Happy Chords"; the word is cut to fit
function modeName(file, player) {
  const [, num, rest] = path.basename(file).match(/^(\d+)-(.*?)(?:-dual|-single)?\.strudel$/) ?? [null, '', path.basename(file)]
  const word = rest.split('-')[0].replace(/^./, c => c.toUpperCase())
  const room = MAX_NAME - [num, player].filter(Boolean).join(' ').length - 1
  return [num, word.slice(0, Math.max(0, room)), player].filter(Boolean).join(' ')
}

export function generate(file) {
  const src = fs.readFileSync(file, 'utf8')
  const d = parse(src, file)
  // One file for any number of Launch Controls (e.g. 008) uses the single layout without the -single suffix
  const singleLayout = file.endsWith('-single.strudel') || /^\/\/ @mode 16 Mode 1 /m.test(src)
  const base = file.replace(/(-dual)?\.strudel$/, '')
  const plus48 = col => col === 8 && d.globalSame ? 0 : 48
  const hasGlobal = Object.keys(d.global).length > 0
  // [tag mode, file suffix, word in the mode name, column 8 global, CC shift]
  // Role names, not player names: Beat = foundation (beat + bass), Chords = colour (chords + melodies)
  const modes = singleLayout
    ? [['16', 'mode1', 'Beat', true, () => 0], ['2', 'mode2', 'Chords', true, plus48]]
    : file.endsWith('-dual.strudel')
    ? [['B16', 'jojo', 'Beat', false, () => 0], ['16', 'jonas', 'Chords', true, () => 0]]
    : [['16', 'mode16', 'M16', hasGlobal, () => 0], ['2', 'mode2', 'M2', hasGlobal, plus48]]
  const written = []
  for (const [mode, suffix, player, global, shift] of modes) {
    const labels = labelsFor(d, mode, global)
    if (!Object.keys(labels).length) continue
    const out = `${base}-${suffix}.syx`
    fs.writeFileSync(out, Buffer.from(build(modeName(file, player), labels, shift)))
    written.push({ out, name: modeName(file, player), labels })
  }
  return written
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2)
  if (args[0] === '--selftest') {
    const ref = fs.readFileSync(path.join(path.dirname(fileURLToPath(import.meta.url)), '..', '..', 'midi-layouts', 'setup0.syx'))
    const ok = Buffer.from(build('*New Custom Mode', {})).equals(ref)
    console.log(ok ? 'selftest: identical to setup0.syx' : 'selftest: DIFFERS from setup0.syx')
    process.exit(ok ? 0 : 1)
  }
  for (const f of args) {
    for (const { out, name, labels } of generate(f)) {
      console.log(`${path.relative(process.cwd(), out)}  "${name}"`)
      for (const [k, v] of Object.entries(labels)) console.log(`  ${k.padEnd(8)} ${v}`)
    }
  }
}
