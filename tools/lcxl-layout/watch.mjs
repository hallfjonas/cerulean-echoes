// Regenerate layout sheets (and for tracks the .syx custom modes) whenever a .strudel file in tracks/ (with its
// subfolders), lab/ (any subfolder) is saved (for hand edits).
// usage: npm run watch (in tools/), stop with Ctrl+C
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { generate } from './gen-layout.mjs'
import { generate as makeSyx } from './make-syx.mjs'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const timers = {}
for (const dir of ['tracks', 'lab']) {
  fs.watch(path.join(root, dir), { recursive: true }, (_, name) => {
    if (!name?.endsWith('.strudel')) return
    const file = path.join(root, dir, name)
    clearTimeout(timers[file])
    timers[file] = setTimeout(() => {
      try {
        const pdf = generate(file, root)
        if (pdf) console.log('layout:', path.relative(root, pdf))
        if (pdf && dir === 'tracks') for (const { out } of makeSyx(file)) console.log('custom mode:', path.relative(root, out))
      } catch (e) { console.error(`${name}: ${e.stderr?.toString() || e.message}`) }
    }, 300)
  })
}
console.log('watching tracks/ and lab/ …')
