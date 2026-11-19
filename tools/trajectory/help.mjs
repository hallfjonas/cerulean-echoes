// Collapsible help panel on the right of every page: what the page or tool does, its inputs and outputs, how to use it.
// mountHelp(sections) adds a Help button (key ?) to the header and returns { setSections } to swap the content, as the
// Tools page does when another command is picked. A section is { heading, text } with text a string or a list of
// strings (shown as numbered steps). Open by default and opening or closing it is remembered across pages; a page that
// passes startOpen: false always starts with it closed.
const STORAGE_KEY = 'trajectory-help-open'

const readOpen = () => {
  try {
    return localStorage.getItem(STORAGE_KEY) !== '0'
  } catch {
    return true
  }
}

const writeOpen = open => {
  try {
    localStorage.setItem(STORAGE_KEY, open ? '1' : '0')
  } catch {}
}

const renderSection = ({ heading, text }) => {
  const section = document.createElement('section')
  const title = document.createElement('h3')
  title.textContent = heading
  section.append(title)
  if (Array.isArray(text)) {
    const steps = document.createElement('ol')
    steps.append(...text.map(step => Object.assign(document.createElement('li'), { textContent: step })))
    section.append(steps)
  } else {
    section.append(Object.assign(document.createElement('p'), { textContent: text }))
  }
  return section
}

export const mountHelp = (sections, { title = 'Help', button = 'Help', startOpen = readOpen() } = {}) => {
  const panel = document.createElement('aside')
  panel.id = 'help'
  const heading = Object.assign(document.createElement('h2'), { textContent: title })
  const body = document.createElement('div')
  panel.append(heading, body)

  const toggle = Object.assign(document.createElement('button'), { id: 'helpToggle', textContent: button })
  toggle.title = title + ' (key ?)'

  const setOpen = (open, remember = true) => {
    document.body.classList.toggle('help-open', open)
    panel.hidden = !open
    toggle.classList.toggle('on', open)
    if (remember) writeOpen(open)
  }
  const setSections = next => body.replaceChildren(...next.map(renderSection))

  toggle.onclick = () => setOpen(panel.hidden)
  addEventListener('keydown', event => {
    if (event.key === '?' && !['SELECT', 'INPUT', 'TEXTAREA'].includes(event.target.tagName)) setOpen(panel.hidden)
  })

  setSections(sections)
  document.body.append(panel)
  document.querySelector('header')?.append(toggle)
  setOpen(startOpen, false)
  return { setSections }
}
