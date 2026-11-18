const pages = [
  { label: 'Player', href: '/', files: ['', 'player.html'] },
  { label: 'Tools', href: 'tools.html', files: ['tools.html'] },
  { label: 'Analysis', href: 'analyse.html', files: ['analyse.html'] }
]

export const renderNav = (path = location.pathname) => {
  const file = path.split('/').pop()
  const nav = document.createElement('nav')
  for (const page of pages) {
    const link = document.createElement('a')
    link.href = page.href
    link.textContent = page.label
    if (page.files.includes(file)) link.className = 'here'
    nav.append(link)
  }
  return nav
}

document.querySelector('header')?.prepend(renderNav())
