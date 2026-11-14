// Build the set (tracks/011-combining-all/011-set-dual.strudel) from the four dual tracks and set-frame.strudel.
// usage: node make-set.mjs   (also: npm run set in tools/) — run it again after changing one of the tracks.
//
// Each track's code (helpers, harmony, stems) goes into its own function scope, unchanged except for a few patches:
//   - column 8 comes from the set (fog / set position on the Fog knob, Tension limited, no break)
//   - button presses count only for the track that has the focus
//   - chapter latches get the set's phrase length; each track gets its own orbits (two tracks crossfade without
//     sharing a reverb, which would be rebuilt on every event with a different room size)
//   - layout tags become per-track tags (// @007 ctl …) for the LC view; the set's own tags describe the columns
// The status box, the LC view and the MIDI setup are taken once from the first track.
// Afterwards the single version, the layout sheets and the .syx modes are written as the hook would.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { makeSingle } from '../lcxl-layout/make-single.mjs'
import { generate } from '../lcxl-layout/gen-layout.mjs'
import { generate as makeSyx } from '../lcxl-layout/make-syx.mjs'

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const OUT = path.join(ROOT, 'tracks/011-combining-all/011-set-dual.strudel')
// grid = BPM of the clock on its plateau; slow = how many clock bars make one bar of the track; phrase = chapter
// latch length in the set (orig = in the track); orbit0 = added to the track's orbits; transpose in semitones
const TRACKS = [
  { id: '007', name: 'Ambient',       file: 'tracks/007-ambient-soundscape/old/007-ambient-dual.strudel',       grid: 140, slow: 2, phrase: 4, orig: 1, orbit0: 0, transpose: 0 },
  { id: '010', name: 'Ambient House', file: 'tracks/010-ambient-house/old/010-ambient-house-dual.strudel', grid: 120, slow: 1, phrase: 8, orig: 4, orbit0: 3, transpose: 0 },
  { id: '009', name: 'Cool House',    file: 'tracks/009-house/old/009-house-dual.strudel',    grid: 122, slow: 1, phrase: 8, orig: 4, orbit0: 0, transpose: 0 },
  { id: '008', name: 'Groove Techno', file: 'tracks/008-groove-techno/old/008-groove-techno-multi.strudel', grid: 140, slow: 1, phrase: 4, orig: 1, orbit0: 3, transpose: 4,
    text: [[/'F ' \+ MOODS/g, "'A ' + MOODS"], [/'Kapitel {5}F '/g, "'Kapitel     A '"]] },
]
const TAG = /^\/\/ @(layout|note|mode|col|row|ctl|guide|recipe|globalcc)\b/

// Replace exactly `count` occurrences (or at least one if count is omitted), else stop: a track changed its shape
const must = (src, from, to, what, count) => {
  const n = (src.match(from instanceof RegExp ? new RegExp(from.source, from.flags.includes('g') ? from.flags : from.flags + 'g')
    : new RegExp(from.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g')) ?? []).length
  if (count === undefined ? n < 1 : n !== count) throw new Error(`${what}: expected ${count ?? '≥ 1'} × ${from}, found ${n}`)
  return from instanceof RegExp ? src.replace(from, to) : src.split(from).join(to)
}
const cut = (src, start, end, what) => {
  const a = src.indexOf(start), b = src.indexOf(end, a + 1)
  if (a < 0 || b < 0) throw new Error(`${what}: section ${JSON.stringify(start)} … ${JSON.stringify(end)} not found`)
  return [src.slice(0, a), src.slice(a, b), src.slice(b)]
}
const retag = (code, id) => code.split('\n').map(l => l.replace(TAG, `// @${id} $1`)).join('\n')

function split(t) {
  const src = fs.readFileSync(path.join(ROOT, t.file), 'utf8')
  const what = t.file
  const top = src.slice(0, src.indexOf('\nconst JOJO'))
  const [, midi] = cut(src, '\nconst JOJO', '\nconst ramp', what)
  const fromRamp = src.slice(src.indexOf('\nconst ramp'))
  const [, header, rest] = cut(fromRamp, '\nconst ramp', '\n// ====', what)
  const [, beforeView] = cut(rest, '\n// ====', '\nif (lcView) {', what)
  const [, view] = cut(rest, '\nif (lcView) {', '\nshowStatus()', what)
  const [preUi, ui, postUi] = cut(beforeView, '\n// Status box at the bottom right', '\n// Rows of the status box', what)
  const master = src.slice(src.lastIndexOf('\nstack('))
  const stems = [...master.matchAll(/^\s+(stem([JN]\d)_\w+),?\s*$/gm)].map(m => [m[2], m[1]])
  if (stems.length < 10) throw new Error(`${what}: master stack has only ${stems.length} stems`)

  let h = header
  h = must(h, '\nsetcpm(bpm / 4)', '', `${what} setcpm`, 1)
  h = must(h, 'const colJonas = n => ', 'const colJonas = n => n === 8 ? SET.glob : ', `${what} colJonas`, 1)
  h = must(h, 'const cycleButton = (button, n, onChange = () => {}) => {',
    'const cycleButton = (button, n, onChange = () => {}) => {\n  button = focusOnly(button)   // set: presses count only for the track in focus', `${what} cycleButton`, 1)
  if (h.includes('const barLatch = () => {')) {
    h = must(h, 'const barLatch = () => {', 'const barLatch = (len = 1) => {', `${what} barLatch`, 1)
    h = must(h, 'const bar = Math.floor(Number(t))', 'const bar = Math.floor(Number(t) / len)', `${what} barLatch bar`, 1)
  }

  let b = preUi + postUi
  b = b.replace(/\n\/\/ Stateful controls[^\n]*\n(\/\/[^\n]*\n)*const stateTaps = [^\n]*\n/, '\n')
  if (b.includes('const stateTaps')) throw new Error(`${what}: stateTaps not removed`)
  const latch = b.match(/^const (chapterLatch|moodLatch) += barLatch\(\d*\)/m)?.[1]
  if (!latch) throw new Error(`${what}: no chapter latch`)
  b = must(b, new RegExp(`^const ${latch}( +)= barLatch\\(\\d*\\)`, "m"), `const ${latch}$1= barLatch(PHRASE)`, `${what} phrase`)
  b = must(b, '.orbit(orbit)', '.orbit(orbit + ORBIT0)', `${what} orbits`, 2)
  b = must(b, '  if (!statusUi) return', '  if (!statusUi || SET.focus() !== ID) return', `${what} showStatus`, 1)
  b = must(b, 'statusUi.text.textContent = [', 'statusUi.text.textContent = [\n    ...SET.statusLines(),', `${what} status lines`, 1)
  // The break line of the status box (one line, or two when the first ends with +)
  const lines = b.split('\n'), k = lines.findIndex(l => l.trimStart().startsWith("'Break       '"))
  if (k < 0) throw new Error(`${what}: no Break line in the status box`)
  lines.splice(k, lines[k].trimEnd().endsWith('+') ? 2 : 1)
  b = lines.join('\n')
  for (const [from, to] of t.text ?? []) b = must(b, from, to, `${what} text`)

  const tags = top.split('\n').filter(l => TAG.test(l))
  return { src, midi, ui, view, tags, header: h, body: b, stems, latch }
}

// The set's own tags: column roles from the template, per-track instrument names in each description
function setTags(parts) {
  const tpl = fs.readFileSync(path.join(ROOT, 'midi-layouts/templates/dual-lc.strudel'), 'utf8')
  const tplCol = Object.fromEntries([...tpl.matchAll(/^\/\/ @col (B?16:\d) \d (.*)$/gm)].map(m => [m[1], m[2]]))
  const tplCtl = Object.fromEntries([...tpl.matchAll(/^\/\/ @ctl (B?16:\d\.\w+) (.*?) \| (.*)$/gm)].map(m => [m[1], { name: m[2], desc: m[3] }]))
  const colName = (p, key) => p.tags.map(l => l.match(new RegExp(`^// @col ${key} \\d (.*)$`))?.[1]).find(Boolean)
  const ctlName = (p, key) => [...p.body.matchAll(new RegExp(`^// @ctl ${key.replace('.', '\\.')} (.*?) \\|`, 'gm'))].map(m => m[1])[0]
  const out = [
    '// @layout Track 011 — the set: 007 → 010 → 009 → 008 (two controllers)',
    '// @note One continuous set through four tracks: 007 ambient (70 BPM) → 010 ambient house (120) → 009 cool house (122) → 008 groove techno (140, here in A). Every column keeps its role; the sounds behind it change with the track.',
    '// @note Jonas’ column 8 button 2 switches the Fog knob between Fog and the set position. In set mode, turning it moves through the set: each track has a plateau, between two plateaus a slow transformation: column by column the old sound turns into the new one (hits move to their new place, pitch, decay and filters glide; what has no partner thins out or fades). Air and pad first, then the low end, drums, melodies last. Leave it anywhere: a halfway position is its own sound.',
    '// @note Chapter, the buttons and the LC view belong to the track in focus (the nearer one in a transition). Chapters change at the next 8-bar phrase (007, 008: 4 bars). No Break / Drop in the set.',
    '// @note The status box at the bottom right of the Strudel page shows the set position, chapter and each stem\'s pattern. Its button “als Fenster” opens it as a small window that stays on top (Chrome/Edge).',
    '// @mode B16 Jojo — Foundation (beat + bass)',
    ...[1, 2, 3, 4, 5, 6, 7, 8].map(c => `// @col B16:${c} ${c} ${tplCol['B16:' + c]}`),
    '// @row B16:k1 Row 1 \\ Brightness', '// @row B16:k2 Row 2 \\ Space', '// @row B16:k3 Row 3 \\ Character',
    '// @row B16:fader Fader \\ Level', '// @row B16:b1 Button 1 \\ Change', '// @row B16:b2 Button 2 \\ Moment',
    '// @mode 16 Jonas — Colour (chords + melodies) · column 8 = global + set',
    ...[1, 2, 3, 4, 5, 6, 7].map(c => `// @col 16:${c} ${c} ${tplCol['16:' + c]}`),
    '// @col 16:8 8 Global + Set',
    '// @row 16:k1 Row 1 \\ Brightness', '// @row 16:k2 Row 2 \\ Space', '// @row 16:k3 Row 3 \\ Character',
    '// @row 16:fader Fader \\ Level', '// @row 16:b1 Button 1 \\ Change', '// @row 16:b2 Button 2 \\ Moment',
  ]
  const ROWS = ['k1', 'k2', 'k3', 'fader', 'b1', 'b2']
  for (const [mode, cols] of [['B16', [1, 2, 3, 4, 5, 6, 7, 8]], ['16', [1, 2, 3, 4, 5, 6, 7]]]) {
    for (const c of cols) for (const r of ROWS) {
      const names = parts.map(p => ctlName(p, `${mode}:${c}.${r}`))
      if (names.every(n => !n)) continue
      // Fader row: which instrument the column is in each track. Other rows: the template's meaning, plus the
      // tracks whose control has another name than the one shown
      const tpl = tplCtl[`${mode}:${c}.${r}`]
      const uniq = [...new Set(names.filter(Boolean))]
      const name = uniq.length === 1 ? uniq[0] : uniq.length === 2 && uniq.join(' / ').length <= 22 ? uniq.join(' / ') : tpl?.name ?? uniq[0]
      const others = name.split(' / ')
      const byName = {}
      names.forEach((n, k) => { if (n && !others.includes(n)) (byName[n] ??= []).push(TRACKS[k].id) })
      const deviations = Object.entries(byName).map(([n, ids]) => `${ids.join('/')}: ${n}`).join(' · ')
      const desc = r === 'fader'
        ? parts.map((p, k) => `${TRACKS[k].id} ${colName(p, `${mode}:${c}`)?.replace(/^\d+\s*/, '') ?? '–'}`).join(' · ') + '.'
        : (tpl?.desc.replace(/^A: .*$/, '').replace(/\s*A: .*$/, '') || 'as in each track.') + (deviations ? ` ${deviations}.` : '')
      out.push(`// @ctl ${mode}:${c}.${r} ${name} | ${desc}`)
    }
  }
  out.push(
    '// @ctl g.k1 Fog / Set | Fog: 0 = clear, up = everything muffled. Set mode (button 2): the set position, 007 → 010 → 009 → 008.',
    '// @ctl g.k2 Room | 0 = each sound\'s own room (row 2), up = everything drowns in reverb.',
    '// @ctl g.k3 Tension | build-up: echo grows, filters open (in the set at most 75 %). Back to 0 = release.',
    '// @ctl g.fader Master Level | volume of everything, both controllers. 0 = silence.',
    '// @ctl g.b1 Chapter | next chords of the track in focus, at the next phrase.',
    '// @ctl g.b2 Set mode | Fog knob: Fog ↔ set position.',
    '// @guide The journey | 007 → 010 → 009 → 008: from a floating heartbeat to techno. The Fog knob in set mode is the map: a full turn is the whole set, each track sits on a plateau where small moves change nothing.',
    '// @guide The journey | A transition takes as long as you turn: slowly, over 16–32 bars, is best. Even a fast spin glides over at least 5 seconds. The tempo moves with it: 70 → 60 (007 slows a little, then 010 doubles it to 120), 120 → 122, 122 → 140.',
    '// @guide The journey | Faders stay where they are: the same column has the same job in the next track. Bring the faders of a new track’s extra sounds up only after the transition.',
    '// @guide Less is more | One change at a time, every 8 bars at most. Let a loop run before it changes again. Chapters wait for the next phrase on purpose.',
    '// @guide Less is more | Fog and Room hide a transition: muffle or drown everything a little, move the set on, then clear up again.',
  )
  return out.join('\n')
}

const frame = fs.readFileSync(path.join(ROOT, 'tools/set/set-frame.strudel'), 'utf8')
const parts = TRACKS.map(split)
const first = parts[0]

// LC view, adapted: names from the focus track's tags (+ the set's column 8), its status rows and chapter,
// the set mode instead of the break, the set header with the beats
let view = first.view
const V = 'LC view'
view = must(view, 'for (const m of code.matchAll(/^\\/\\/ @(?:mode|col|ctl) (\\S+) (.*)$/gm)) TAGS[m[1]] = m[2]',
  "const TAGS_OF = SET_TRACKS.map(t => {\n" +
  "    const T = {}\n" +
  "    for (const m of code.matchAll(new RegExp('^// @' + t.id + ' (?:mode|col|ctl) (\\\\S+) (.*)$', 'gm'))) T[m[1]] = m[2]\n" +
  "    for (const m of code.matchAll(/^\\/\\/ @ctl (g\\.\\S+) (.*)$/gm)) T[m[1]] = m[2]\n" +
  "    return T\n" +
  "  })", V, 1)
view = must(view, '  const TAGS = {}\n', '', V, 1)
view = must(view, 'TAGS[', 'TAGS_OF[SET.focus()][', V)
view = must(view, "const prefix = page => page === 'jojo' ? (isSingleFile ? '16' : 'B16') : (isSingleFile ? '2' : '16')",
  "const prefix = page => page === 'jojo' ? 'B16' : '16'   // per-track tags stay in the dual form", V, 1)
view = must(view, '  const isSingleFile = /^\\/\\/ @ctl 2:/m.test(code)\n', '', V, 1)
view = must(view, 'STATUS[page]', 'SET.track().STATUS[page]', V, 1)
view = must(view, 'lcChapter()', 'SET.track().lcChapter()', V)
view = must(view, 'lcHead()', 'SET.track().lcHead()', V, 1)
view = must(view, 'breakLatch.pending === 1', 'setState.mode', V, 1)
view = must(view, "pending(breakLatch.now ? 'Beat aus' : 'Beat an', breakLatch.pending ? 'Beat aus' : 'Beat an')\n", "esc(setState.mode ? 'Set' : 'Fog')\n", V, 1)
view = must(view, "'<div><span class=k>Break</span>' + pending(breakLatch.now ? 'Beat aus' : 'Beat an', breakLatch.pending ? 'Beat aus' : 'Beat an') + '</div>'",
  'SET.headHtml(esc)', V, 1)
// The track's own bar/beat line goes: the set shows its own (SET.headHtml, phrase of the set position)
view = must(view, "      '<div><span class=k>Takt</span>' + beatHtml() + '</div>' +\n", '', V, 1)
if (/breakLatch/.test(view)) throw new Error('LC view: breakLatch left')

const trackCode = parts.map((p, k) => {
  const t = TRACKS[k]
  const stems = p.stems.map(([c, name]) => `${c}: ${name}`).join(', ')
  return [
    '// ============================================================',
    `// TRACK ${t.id} — ${t.name} (from ${t.file})`,
    '// ============================================================',
    retag(p.tags.join('\n'), t.id),
    `const T${t.id} = await (async () => {`,   // async: a track may load samples with await
    `const ID = ${k}`,
    `const PHRASE = phraseOf(SET_TRACKS[${k}])`,
    `const ORBIT0 = ${t.orbit0}`,
    `const focusOnly = button => button.fmap(v => SET.focus() === ID ? v : 0)`,
    retag(p.header, t.id),
    retag(p.body, t.id),
    `return { taps, showStatus, STATUS, lcChapter, lcHead, stems: { ${stems} } }`,
    '})()',
  ].join('\n')
}).join('\n\n')

const setTracks = 'const SET_TRACKS = [\n' + TRACKS.map(t =>
  `  { id: '${t.id}', name: '${t.name}', grid: ${t.grid}, slow: ${t.slow}, phrase: ${t.phrase}, orig: ${t.orig}, transpose: ${t.transpose} },`).join('\n') + '\n]'

const line = (src, mark, text) => must(src, new RegExp(`^// @@${mark}$`, 'm'), () => text, `frame ${mark}`, 1)
let out = frame
out = line(out, 'SET_TAGS', setTags(parts))
out = line(out, 'MIDI', first.midi.trim())
out = line(out, 'UI', first.ui.trim())
out = line(out, 'SET_TRACKS', setTracks)
out = line(out, 'TRACKS', trackCode)
out = line(out, 'VIEW', view.trim() + '\nSET.refresh()')
out = must(out, '/*@@TRACK_NAMES*/', TRACKS.map(t => 'T' + t.id).join(', '), 'frame names', 1)

fs.mkdirSync(path.dirname(OUT), { recursive: true })
fs.writeFileSync(OUT, out)
console.log(path.relative(process.cwd(), OUT), out.split('\n').length, 'lines')
const single = makeSingle(OUT)
console.log(path.relative(process.cwd(), single))
for (const f of [OUT, single]) {
  const pdf = generate(f, ROOT)
  if (pdf) console.log(path.relative(process.cwd(), pdf))
  makeSyx(f)
}
