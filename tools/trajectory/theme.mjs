// The look of the whole player page and of the SuperCollider MIDI panel (sc/ui/index.html): a style, Minimal (calm,
// flat, Torso-like; data-theme black in the panel) or Retro (Teenage Engineering-like; te), each dark or light; tone
// Auto follows the system. Chosen only in the player's Settings view (Theme), not in the panel. Saved in localStorage
// ce.style / ce.tone, which the panel reads too; the panel also gets { theme } by message (sendTheme).
export const STYLES = ['minimal', 'retro']
export const TONES = ['auto', 'dark', 'light']
const read = key => { try { return localStorage.getItem(key) } catch { return null } }
const write = (key, value) => { try { localStorage.setItem(key, value) } catch {} }
const dark = matchMedia('(prefers-color-scheme: dark)')

export const mountTheme = (container, { panel }) => {
  const old = read('ce.panelTheme')   // before 2026-11-21 only the panel had a theme: black / te
  const theme = {
    style: STYLES.includes(read('ce.style')) ? read('ce.style') : old === 'te' ? 'retro' : 'minimal',
    tone: TONES.includes(read('ce.tone')) ? read('ce.tone') : 'auto',
  }
  const segmented = (key, options) => {
    const group = Object.assign(document.createElement('div'), { className: 'seg', role: 'radiogroup' })
    group.append(...options.map(option => {
      const button = Object.assign(document.createElement('button'), { type: 'button', textContent: option })
      button.dataset.value = option
      button.onclick = () => set({ [key]: option })
      return button
    }))
    return group
  }
  const style = segmented('style', STYLES), tone = segmented('tone', TONES)
  container.replaceChildren(style, tone)
  const sendTheme = () => panel()?.contentWindow?.postMessage({ theme: { ...theme } }, location.origin)
  const apply = () => {
    const root = document.documentElement
    root.dataset.style = theme.style
    root.dataset.tone = theme.tone === 'auto' ? (dark.matches ? 'dark' : 'light') : theme.tone
    for (const [group, value] of [[style, theme.style], [tone, theme.tone]])
      for (const button of group.children) button.setAttribute('aria-pressed', String(button.dataset.value === value))
    sendTheme()
  }
  const set = next => {
    Object.assign(theme, next)
    write('ce.style', theme.style)
    write('ce.tone', theme.tone)
    apply()
  }
  dark.addEventListener('change', apply)
  apply()
  return { sendTheme, cycleStyle: () => set({ style: STYLES[(STYLES.indexOf(theme.style) + 1) % STYLES.length] }) }
}
