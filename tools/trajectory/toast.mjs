// Notifications over the page, top center. An error or a question stays until it is closed or answered; a plain
// message goes after a few seconds. toast(text, { kind: 'info' | 'error' | 'ask', actions: ['Promote and export'] })
// resolves with the label of the action pressed, or null when it was closed or timed out.
const SECONDS = 6

const host = () => {
  let element = document.getElementById('toasts')
  if (!element) {
    element = Object.assign(document.createElement('div'), { id: 'toasts' })
    document.body.append(element)
  }
  return element
}

export const toast = (text, { kind = 'info', actions = [] } = {}) => new Promise(resolve => {
  const element = Object.assign(document.createElement('div'), { className: `toast ${kind}`, role: kind === 'info' ? 'status' : 'alert' })
  const finish = value => {
    clearTimeout(timer)
    element.remove()
    resolve(value)
  }
  const close = Object.assign(document.createElement('button'), { className: 'toast-close', title: 'Close', textContent: '×' })
  close.onclick = () => finish(null)
  const buttons = actions.map(label => Object.assign(document.createElement('button'), { textContent: label,
    onclick: () => finish(label) }))
  element.append(Object.assign(document.createElement('span'), { textContent: text }), ...buttons, close)
  host().append(element)
  const timer = kind === 'info' ? setTimeout(() => finish(null), SECONDS * 1000) : null
})

// A text question in place of prompt() (some browser views do not support it): resolves with the text, or null when
// cancelled. Enter answers, Escape cancels.
export const askText = (question, initial = '') => new Promise(resolve => {
  const element = Object.assign(document.createElement('div'), { className: 'toast ask', role: 'dialog' })
  const input = Object.assign(document.createElement('input'), { value: initial, className: 'toast-input' })
  const finish = value => {
    element.remove()
    resolve(value)
  }
  const button = (text, value) => Object.assign(document.createElement('button'), { textContent: text, onclick: value })
  input.onkeydown = event => {
    if (event.key === 'Enter') finish(input.value)
    if (event.key === 'Escape') finish(null)
  }
  element.append(Object.assign(document.createElement('span'), { textContent: question }), input,
    button('OK', () => finish(input.value)), button('Cancel', () => finish(null)))
  host().append(element)
  input.focus()
  input.select()
})
