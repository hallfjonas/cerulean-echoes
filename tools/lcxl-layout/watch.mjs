// Regenerate layout sheets whenever a .strudel file in tracks/, sounds/lab/ or sounds/parts/ is saved (for hand edits).
// usage: npm run watch (in tools/), stop with Ctrl+C
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { generate } from './gen-layout.mjs'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const timers = {}
for (const dir of ['tracks', 'sounds/lab', 'sounds/parts']) {
  fs.watch(path.join(root, dir), (_, name) => {
    if (!name?.endsWith('.strudel')) return
    const file = path.join(root, dir, name)
    clearTimeout(timers[file])
    timers[file] = setTimeout(() => {
      try {
        const pdf = generate(file, root)
        if (pdf) console.log('layout:', path.relative(root, pdf))
      } catch (e) { console.error(`${name}: ${e.stderr?.toString() || e.message}`) }
    }, 300)
  })
}
console.log('watching tracks/ and sounds/ …')
