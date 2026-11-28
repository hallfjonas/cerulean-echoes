// The pages of the player: Live, Labs (Samples, Stems, Space, Tracks, Sets) and Visuals. DOM-free: which catalogue
// entries a page offers, which sidebar sections it shows and how a page is written in the URL hash.
export const PAGES = [
  { id: 'live', label: 'Live', subs: [] },
  { id: 'labs', label: 'Labs', subs: [
    { id: 'samples', label: 'Samples' },
    { id: 'stems', label: 'Stems' },
    { id: 'space', label: 'Space' },
    { id: 'tracks', label: 'Tracks' },
    { id: 'sets', label: 'Sets', placeholder: 'Set Designer: planned (.claude/epics/set-designer).' }] },
  { id: 'visuals', label: 'Visuals', subs: [] },
]

export const DEFAULT_PAGE = { id: 'live', sub: null }

export const parseHash = hash => {
  const [id, sub = null] = String(hash ?? '').replace(/^#/, '').split('/')
  const page = PAGES.find(entry => entry.id === id)
  if (!page) return { ...DEFAULT_PAGE }
  if (!page.subs.length) return { id: page.id, sub: null }
  return { id: page.id, sub: page.subs.some(entry => entry.id === sub) ? sub : page.subs[0].id }
}

export const hashFor = ({ id, sub }) => '#' + (sub ? `${id}/${sub}` : id)

export const pageKey = ({ id, sub }) => sub ? `${id}/${sub}` : id

export const placeholderFor = ({ id, sub }) =>
  PAGES.find(entry => entry.id === id)?.subs.find(entry => entry.id === sub)?.placeholder ?? null

// a sidebar element lists its pages in data-pages: "live", "labs" (every sub-tab) or "labs/stems" (one)
export const shownOn = (tokens, page) => String(tokens).split(/\s+/).filter(Boolean)
  .some(token => token === page.id || token === pageKey(page))

// the picker of a page: Live lists live tracks, Samples and Stems their designer projects
export const entriesFor = (page, catalogue) => {
  if (page.id === 'live') return catalogue.filter(entry => entry.kind === 'live')
  if (page.id === 'labs' && page.sub === 'samples') return catalogue.filter(entry => entry.lab === 'sample')
  if (page.id === 'labs' && page.sub === 'stems') return catalogue.filter(entry => entry.lab === 'stems')
  return []
}

export const showsShape = page => page.id === 'labs' && page.sub === 'samples'
