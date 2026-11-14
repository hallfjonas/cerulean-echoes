// The sample banks the player loads, the ones of strudel.cc's prebake that the tracks use (same URLs, so a sound loads
// in the player exactly when it loads on strudel.cc), shared with the sound check (tools/strudel-sim/check-sounds.mjs).
export const BANKS = [
  'https://raw.githubusercontent.com/tidalcycles/dirt-samples/master/strudel.json',
  'https://raw.githubusercontent.com/felixroos/dough-samples/main/tidal-drum-machines.json',
  'https://raw.githubusercontent.com/felixroos/dough-samples/main/vcsl.json',
  'https://raw.githubusercontent.com/felixroos/dough-samples/main/piano.json',
]

// Soundfonts (gm_*): the instrument list and where the font files come from, as in @strudel/soundfonts
export const SOUNDFONTS = 'https://unpkg.com/@strudel/soundfonts@1.2.6/'
export const SOUNDFONT_FILES = 'https://felixroos.github.io/webaudiofontdata/sound/'

// This repository's samples/ folder as the tracks load it, and the bank of mirrored sounds in it (mirror-sound.mjs)
export const OWN_SAMPLES = 'https://raw.githubusercontent.com/hallfjonas/cerulean-echoes/main/samples/'
export const MIRROR = OWN_SAMPLES + 'mirror/mirror.json'
