// Regenerate layout sheets (and for tracks the .syx custom modes) whenever a .strudel file in tracks/ (with its
// subfolders), lab/ (any subfolder) is saved (for hand edits); a track with a tapped copy also gets that rebuilt.
// usage: npm run watch (in tools/), stop with Ctrl+C
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { generate } from './gen-layout.mjs'
import { generate as makeSyx } from './make-syx.mjs'
import { refreshTapped } from '../trajectory/make-tapped.mjs'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const timers = {}
for (const dir of ['tracks', 'lab']) {
  fs.watch(path.join(root, dir), { recursive: true }, (_, name) => {
    if (!name?.endsWith('.strudel')) return
    const file = path.join(root, dir, name)
    clearTimeout(timers[file])
    timers[file] = setTimeout(() => {
      try {
        if (refreshTapped(file)) console.log('tapped:', name)
        const pdf = generate(file, root)
        if (pdf) console.log('layout:', path.relative(root, pdf))
        if (pdf && dir === 'tracks') for (const { out } of makeSyx(file)) console.log('custom mode:', path.relative(root, out))
      } catch (e) { console.error(`${name}: ${e.stderr?.toString() || e.message}`) }
    }, 300)
  })
}
console.log('watching tracks/ and lab/ …')
