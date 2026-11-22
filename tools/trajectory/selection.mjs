// The player's selection registry: what the player points at right now. One current selection; whoever acts on it
// (the stem drawer, later llm-support's Claude drawer as context) listens. Plain module, no DOM, so Node tests use it.
// A selection is a frozen object { kind, ...fields }; KINDS names the fields each kind must have:
//   column   track: catalogue id of the stem track, slot: '1:1'-'2:7' (Mode 1 / Mode 2, column 1-7),
//            stem: the stem version on the slot now (path under sc/stems/, as in a .track file)
export const KINDS = { column: ['track', 'slot', 'stem'] }

export const columnSelection = ({ track, slot, stem }) => ({ kind: 'column', track, slot, stem })

export const createSelection = () => {
  let current = null
  const listeners = new Set()
  const notify = (ofKind, item) => {
    for (const { kind, fn } of [...listeners]) if (kind === '*' || kind === ofKind) fn(item)
  }
  return {
    // replaces the current selection and tells the listeners of its kind and '*'
    select: item => {
      const fields = KINDS[item?.kind]
      if (!fields) throw new Error(`selection: unknown kind '${item?.kind}'`)
      const missing = fields.filter(field => item[field] === undefined || item[field] === null || item[field] === '')
      if (missing.length) throw new Error(`selection ${item.kind}: missing ${missing.join(', ')}`)
      current = Object.freeze({ ...item })
      notify(current.kind, current)
    },
    // nothing selected: the listeners of the previous kind and '*' get null
    clear: () => {
      if (!current) return
      const { kind } = current
      current = null
      notify(kind, null)
    },
    current: () => current,
    // fn(selection or null) on every change of that kind ('*': every kind); returns the function that stops it
    on: (kind, fn) => {
      const listener = { kind, fn }
      listeners.add(listener)
      return () => listeners.delete(listener)
    },
  }
}
