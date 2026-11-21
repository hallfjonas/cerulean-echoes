// Symbols for the sidebar's lab buttons (Load, Save, Save as, Export), drawn like the transport buttons Play, Stop and
// Record in player.html: a 16 px glyph in an `.icon.transport` button; the name shows as the tooltip.
const glyph = paths => `<svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor" fill-rule="evenodd" ` +
  `aria-hidden="true">${paths}</svg>`

const FLOPPY_BODY = 'M17 3H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V7zM15 9H5V5h10z'

export const ICONS = {
  load: glyph('<path d="M20 6h-8l-2-2H4a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2zm0 12H4V8h16z"/>'),
  save: glyph(`<path d="${FLOPPY_BODY}M12 13a3 3 0 1 0 0 6 3 3 0 0 0 0-6z"/>`),
  saveAs: glyph(`<path d="${FLOPPY_BODY}M11.2 12.8h1.6v2.4h2.4v1.6h-2.4v2.4h-1.6v-2.4H8.8v-1.6h2.4z"/>`),
  export: glyph('<path d="M9 16h6v-6h4l-7-7-7 7h4zm-4 2h14v2H5z"/>'),
}

export const iconButton = (act, label, svg, title = label) =>
  `<button class="icon transport" data-act="${act}" title="${title}" aria-label="${label}">${svg}</button>`
