// Play a controller scenario on a track in Node and report what sounds: CCs, button presses, Launchkey pads, knobs and
// keys from the command line, one or more LC XL 3s, optionally the LC view text. Usage: USAGE (or run without args).
import { load, STEP } from './harness.mjs'
import fs from 'fs'

const USAGE = `usage (in tools/): node strudel-sim/scenario.mjs <track.strudel> [steps…] [output]
steps (values 0..1, sent as MIDI 0..127; @c = at cycle c, default 0; lists with commas, flags may repeat):
  --cc 13=0.5,85=1@2     LC 1 CCs (Mode 1 = CC 5-51, Mode 2 = CC + 48, column 8 on both)
  --press 37@2,37@2.5    LC 1 button presses (momentary: 1, then 0 one tick = ${STEP} cycles later)
  --lc 2                 number of LC XL 3s connected (default 1; 0 = none)
  --cc2 …  --press2 …    the same for LC 2 (--cc3 for LC 3 …); per CC the one moved last wins, as in the tracks
  --faders 1             every fader of LC 1 (CC 5-12 and 53-60) to this value at cycle 0
  --pad 36@1,40@2        Launchkey drum pads (channel 10, notes 36-51)
  --lk 31=0.7@1          Launchkey knobs (CC 31-38)       --wheel 0.8@1   mod wheel (CC 1)
  --keys '<c3 e3>'       Launchkey keys play this mini-notation all along
  --no-lk                no Launchkey connected
window: --from 0 --to 4 (cycles; the run always starts at 0, so earlier presses count)
        --before 0-4 --after 4-8   two windows, prints what changed between them
output: default audible events per sound · --stems per stem: events and audible ones · --events every audible event
        --view the status box and the LC view (▣ LC big) as text at the end of each window`

const args = process.argv.slice(2)
const track = args.find((a, i) => !a.startsWith('--') && (i === 0 || !args[i - 1].startsWith('--') ||
  ['--stems', '--events', '--view', '--no-lk'].includes(args[i - 1])))
if (!track) { console.error(USAGE); process.exit(1) }
const flag = name => args.includes(name)
const values = name => args.flatMap((a, i) => a === name ? args[i + 1].split(',') : [])
const one = (name, d) => flag(name) ? values(name).at(-1) : d
const span = s => s.split('-').map(Number)

const lcCount = Number(one('--lc', 1))
const ports = [...Array(lcCount).keys()].flatMap(i => [`LCXL3 ${i + 1} MIDI`, `LCXL3 ${i + 1} DAW`])
  .concat(flag('--no-lk') ? [] : ['Launchkey MK4 25 MIDI', 'Launchkey MK4 25 DAW'])
const LK_PORT = 'Launchkey MK4 25 MIDI'
const WINDOW = ['--from', '--to', '--before', '--after']
const windows = flag('--before') ? [span(one('--before')), span(one('--after'))]
  : [[Number(one('--from', 0)), Number(one('--to', Number(one('--from', 0)) + 4))]]

// Every step: at cycle `at`, set vals[key] (or queue a note) and tell the LC view on its port
const steps = []
const midi = v => Math.round(Number(v) * 127)
const parseAt = s => { const [what, at = 0] = s.split('@'); return [what, Number(at)] }
const ccKey = (lc, cc) => lc === 1 ? cc : 'lc' + lc + '.' + cc
const lcPort = lc => `LCXL3 ${lc} MIDI`
for (const a of new Set(args.filter(a => /^--(cc|press)\d*$/.test(a)))) {
  const [, kind, n] = a.match(/^--(cc|press)(\d*)$/), lc = Number(n || 1)
  for (const s of values(a)) {
    const [what, at] = parseAt(s)
    if (kind === 'cc') {
      const [cc, v] = what.split('=').map(Number)
      steps.push({ at, key: ccKey(lc, cc), v: midi(v), port: lcPort(lc), data: [0xbf, cc] })
    } else {
      const cc = Number(what)
      steps.push({ at, key: ccKey(lc, cc), v: 127, port: lcPort(lc), data: [0xbf, cc] },
        { at: at + STEP, key: ccKey(lc, cc), v: 0, port: lcPort(lc), data: [0xbf, cc] })
    }
  }
}
for (const v of values('--faders'))
  for (const cc of [5, 6, 7, 8, 9, 10, 11, 12].flatMap(c => [c, c + 48]))
    steps.push({ at: 0, key: cc, v: midi(v), port: lcPort(1), data: [0xbf, cc] })
for (const s of values('--lk')) {
  const [what, at] = parseAt(s), [cc, v] = what.split('=').map(Number)
  steps.push({ at, key: 'lk' + cc, v: midi(v), port: LK_PORT, data: [0xb0, cc] })
}
for (const s of values('--wheel')) {
  const [v, at] = parseAt(s)
  steps.push({ at, key: 'lk1', v: midi(v), port: LK_PORT, data: [0xb0, 1] })
}
for (const s of values('--pad')) {
  const [note, at] = parseAt(s).map(Number)
  steps.push({ at, pad: { note, velocity: 100 / 127, midichan: 10 }, v: 100, port: LK_PORT, data: [0x99, note] },
    { at: at + STEP, v: 0, port: LK_PORT, data: [0x89, note] })
}
steps.sort((a, b) => a.at - b.at)

// A page for the tracks' status box and LC view: elements that only keep their text, Web MIDI that only listens
const fakePage = src => {
  const made = [], listeners = {}
  const el = tag => {
    const e = { tagName: tag, style: {}, children: [], textContent: '', innerHTML: '',
      contentWindow: { open: () => null },
      append: (...c) => e.children.push(...c), appendChild: c => e.children.push(c),
      prepend: (...c) => e.children.unshift(...c), remove: () => {}, addEventListener: () => {},
      querySelector: () => null, querySelectorAll: () => [] }
    made.push(e)
    return e
  }
  globalThis.document = { createElement: el, body: el('body'), head: el('head'), querySelectorAll: () => [] }
  const inputs = new Map(ports.map(name => [name, { name, addEventListener: (type, f) => { listeners[name] = f } }]))
  const access = { inputs, addEventListener: () => {} }
  const navigator = { requestMIDIAccess: async () => access }
  Object.defineProperty(globalThis, 'navigator', { value: navigator, configurable: true })
  globalThis.strudelMirror = { code: src }
  return {
    send: (port, data) => listeners[port]?.({ data: new Uint8Array(data) }),
    status: () => made.find(e => e.tagName === 'pre')?.textContent ?? '',
    lc: () => {
      const view = globalThis.lcxlView
      if (!view) return ''
      const root = el('div')
      view.win = { closed: false, document: { getElementById: id => id === 'lc' ? root : null } }
      view.draw()
      view.win = null
      return viewText(root.innerHTML)
    },
  }
}

// The LC view's HTML as lines: the head, one line per column of each page, the Launchkey row and pads
const ROWS = ['k1', 'k2', 'k3', 'fader', 'b1', 'b2']
const parseHtml = html => {
  const root = { cls: [], kids: [] }, open = [root]
  const decode = s => s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&amp;/g, '&')
  for (const [, close, tag, attrs, text] of html.matchAll(/<(\/?)(\w+)([^>]*)>|([^<]+)/g)) {
    if (text) open.at(-1).kids.push(decode(text))
    else if (close) open.length > 1 && open.pop()
    else {
      const m = attrs.match(/class=(?:"([^"]*)"|(\S+))/)
      const node = { tag, cls: (m?.[1] ?? m?.[2] ?? '').split(' '), kids: [] }
      open.at(-1).kids.push(node)
      if (!['br', 'img', 'hr', 'input'].includes(tag)) open.push(node)
    }
  }
  return root
}
const textOf = n => typeof n === 'string' ? n : n.kids.map(textOf).join(' ').replace(/\s+/g, ' ').trim()
const find = (n, cls) => typeof n === 'string' ? [] : n.cls.includes(cls) ? [n] : n.kids.flatMap(k => find(k, cls))
const elems = n => n.kids.filter(k => typeof k !== 'string')
const viewText = html => {
  const root = parseHtml(html), out = []
  for (const head of find(root, 'head')) out.push(elems(head).map(textOf).join(' · '))
  for (const page of find(root, 'page')) {
    out.push(textOf(page.kids[0]) + (page.cls.includes('live') ? '  [moved last]' : ''))
    const grid = elems(find(page, 'grid')[0]), cols = grid.slice(0, 8), cells = grid.slice(8)
    cols.forEach((c, i) => out.push('  ' + textOf(c).padEnd(14) + ' ' + ROWS.map((r, j) => {
      const cell = cells[j * 8 + i]
      return r + ' ' + (cell ? textOf(cell) + (cell.cls.includes('on') ? ' [on]' : '') : '')
    }).join(' | ')))
  }
  for (const lk of find(root, 'lk')) {
    out.push('Launchkey  ' + [...find(lk, 'lkrow').flatMap(elems), ...elems(find(lk, 'lkbody')[0]).slice(1)]
      .map(textOf).join(' | '))
    out.push('  pads  ' + find(lk, 'lkpads').flatMap(elems).map(p => textOf(p) + (p.cls.includes('on') ? '*' : ''))
      .join(' | '))
  }
  return out.join('\n')
}

const src = fs.readFileSync(track, 'utf8')
const page = flag('--view') ? fakePage(src) : null
const vals = { midiQueue: [] }
if (flag('--keys')) vals.keys = one('--keys')
const tapped = [], seen = new Set()
const tap = (stem, h) => {
  const id = stem + h.whole.begin.valueOf() + JSON.stringify(h.value)
  if (!seen.has(id)) { seen.add(id); tapped.push({ stem, h }) }
}
const pat = await load(track, vals, undefined, { ports, tap })
await new Promise(r => setImmediate(r))

const end = Math.max(...windows.map(w => w[1]))
const played = [], views = []
let next = 0
for (let t = 0; t < end - 1e-9; t += STEP) {
  for (; next < steps.length && steps[next].at <= t + 1e-9; next++) {
    const s = steps[next]
    if (s.pad) vals.midiQueue.push(s.pad)
    else if (s.key !== undefined) vals[s.key] = s.v / 127
    page?.send(s.port, [...s.data, s.v])
  }
  for (const h of pat.queryArc(t, Math.min(end, t + STEP))) if (h.hasOnset()) played.push(h)
  for (const [i, w] of windows.entries()) if (!views[i] && t + STEP >= w[1] - 1e-9)
    views[i] = page ? [page.status(), page.lc()].filter(Boolean).join('\n\n') : ''
}

const r3 = x => Math.round(x * 1000) / 1000
const soundOf = v => v.bank ? v.bank + '_' + v.s : v.s
const inWin = ([a, b]) => h => h.whole.begin.valueOf() >= a - 1e-9 && h.whole.begin.valueOf() < b - 1e-9
const count = (list, key) => list.reduce((m, x) => m.set(key(x), (m.get(key(x)) ?? 0) + 1), new Map())
const report = w => {
  const audibleHaps = played.filter(inWin(w)).filter(h => h.value?.s !== undefined)
  const stems = new Map([...count(tapped.filter(x => inWin(w)(x.h)), x => x.stem)].map(([k, n]) => [k, [n, 0]]))
  for (const [k, n] of count(audibleHaps, h => h.value._stem ?? '?')) stems.set(k, [stems.get(k)?.[0] ?? n, n])
  return { audibleHaps, stems, sounds: count(audibleHaps, h => soundOf(h.value)) }
}
const reports = windows.map(report)
const table = (rows, head) => [head, ...rows].map(r => r.map((c, i) => i ? String(c).padStart(9) : String(c).padEnd(22))
  .join('')).join('\n')
const sorted = m => [...m].sort(([a], [b]) => a < b ? -1 : 1)
const eventLine = h => {
  const v = h.value, gain = (v.gain ?? 1) * (v.postgain ?? 1)
  return '  ' + r3(h.whole.begin.valueOf()).toFixed(3).padStart(8) + '  ' + (v._stem ?? '').padEnd(16) +
    soundOf(v).padEnd(22) + (v.note !== undefined ? ' note ' + v.note : '') + (v.n !== undefined ? ' n ' + v.n : '') +
    ' gain ' + r3(gain)
}
const showWindow = (w, rep) => {
  console.log(`\n== cycles ${w[0]}-${w[1]}: ${rep.audibleHaps.length} audible events`)
  const stemRows = () => sorted(rep.stems).map(([k, [n, a]]) => [k, n, a])
  if (flag('--stems')) console.log(table(stemRows(), ['stem', 'events', 'audible']))
  else console.log(table(sorted(rep.sounds), ['sound', 'audible']))
  if (flag('--events')) console.log(rep.audibleHaps.map(eventLine).join('\n'))
}

console.log(`${track}\nports: ${ports.filter(p => !p.includes('DAW')).join(', ') || 'none'}\nsteps: ` +
  (args.filter((a, i) => a !== track && !['--stems', '--events', '--view'].includes(a) &&
    !WINDOW.some(w => w === a || w === args[i - 1])).join(' ') || 'none'))
windows.forEach((w, i) => {
  showWindow(w, reports[i])
  if (views[i]) console.log('\n-- view at cycle ' + w[1] + '\n' + views[i])
})
if (windows.length === 2) {
  const [a, b] = reports
  const rows = (ma, mb, val) => [...new Set([...ma.keys(), ...mb.keys()])].sort()
    .map(k => [k, val(ma.get(k)), val(mb.get(k))]).filter(([, x, y]) => x !== y).map(([k, x, y]) => [k, x, y, y - x])
  console.log(`\n== changed from ${windows[0].join('-')} to ${windows[1].join('-')} (audible events)`)
  const changed = flag('--stems') ? rows(a.stems, b.stems, v => v?.[1] ?? 0) : rows(a.sounds, b.sounds, v => v ?? 0)
  console.log(changed.length ? table(changed, [flag('--stems') ? 'stem' : 'sound', 'before', 'after', 'change'])
    : '  nothing')
  if (views[0] && views[1]) {
    const va = views[0].split('\n'), vb = views[1].split('\n')
    const diff = vb.flatMap((l, i) => l === va[i] ? [] : [...(va[i] !== undefined ? ['- ' + va[i]] : []), '+ ' + l])
    console.log('\n== view changes\n' + (diff.join('\n') || '  nothing'))
  }
}
process.exit(0)
