// The shape drawing runs on a stand-in DOM and canvas: every picture draws without an error for a measured shape.
import test from 'node:test'
import assert from 'node:assert/strict'
import { analyzeHit } from '../sound-lab/sample-shape.mjs'

const RATE = 48000
const ping = Float32Array.from({ length: RATE }, (_, i) => Math.sin(2 * Math.PI * 220 * i / RATE) * Math.exp(-i / RATE / 0.1))

test('drawShape draws the numbers and four pictures', async () => {
  const calls = []
  const ctx = new Proxy({}, { get: (target, key) => key in target ? target[key] : (...args) => { calls.push(key) },
    set: (target, key, value) => { target[key] = value; return true } })
  const element = () => {
    const el = { children: [], style: {}, innerHTML: '', clientWidth: 900, clientHeight: 200,
      append: child => el.children.push(child), getContext: () => ctx,
      querySelector: sel => sel === 'canvas' ? element() : el[sel] ??= element() }
    return el
  }
  globalThis.document = { createElement: element, body: {} }
  globalThis.window = { devicePixelRatio: 2 }
  globalThis.getComputedStyle = () => ({ getPropertyValue: () => '' })
  const { drawShape } = await import('./sample-shape-ui.mjs')
  const box = element()
  drawShape(box, analyzeHit(ping, RATE))
  assert.match(box['.numbers'].innerHTML, /Strongest.*A3/)
  assert.equal(box['.plots'].children.length, 4)
  assert.ok(calls.filter(c => c === 'fillRect').length > 400 && calls.includes('stroke'))
})
