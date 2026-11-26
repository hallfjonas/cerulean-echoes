import { test } from 'node:test'
import assert from 'node:assert/strict'
import { recordAction, recordButtonState } from './record-arm.mjs'

test('switched on: recording follows the transport', () => {
  assert.equal(recordAction({ armed: true, transport: 'playing', recording: false }), 'start')
  assert.equal(recordAction({ armed: true, transport: 'playing', recording: true }), null)
  assert.equal(recordAction({ armed: true, transport: 'stopped', recording: true }), 'stop')
  assert.equal(recordAction({ armed: true, transport: 'paused', recording: true }), 'stop')
  assert.equal(recordAction({ armed: true, transport: 'stopped', recording: false }), null)
})

test('switched off: nothing starts, a running recording stops', () => {
  assert.equal(recordAction({ armed: false, transport: 'playing', recording: false }), null)
  assert.equal(recordAction({ armed: false, transport: 'playing', recording: true }), 'stop')
  assert.equal(recordAction({ armed: false, transport: 'stopped', recording: false }), null)
})

test('button: white off, steady red armed, pulsing while a file is written', () => {
  assert.equal(recordButtonState({ armed: false, recording: false }), 'off')
  assert.equal(recordButtonState({ armed: true, recording: false }), 'armed')
  assert.equal(recordButtonState({ armed: true, recording: true }), 'recording')
  assert.equal(recordButtonState({ armed: false, recording: true }), 'recording')
})
