// Copies a bank sound that browsers cannot load from its bank (check-sounds.mjs lists it as broken) into this
// repository: every file of the sound, in its order (so n stays the same), into samples/mirror/<sound>/, and adds the
// sound to the sample map samples/mirror/mirror.json. A track that loads that map (samples(MIRROR) from banks.mjs'
// URL) then plays the copy under the same name. The copy loads once it is pushed to main.
// usage (in tools/): node strudel-sim/mirror-sound.mjs <sound> …
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'
import { BANKS, OWN_SAMPLES } from '../trajectory/banks.mjs'

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..')
const dir = path.join(root, 'samples', 'mirror')
const mapFile = path.join(dir, 'mirror.json')
const mirror = fs.existsSync(mapFile) ? JSON.parse(fs.readFileSync(mapFile, 'utf8')) : {}
const banks = await Promise.all(BANKS.map(url => fetch(url).then(r => r.json())))

for (const sound of process.argv.slice(2)) {
  const bank = banks.find(map => map[sound])
  if (!bank) throw new Error(sound + ': in none of the banks')
  if (!Array.isArray(bank[sound])) throw new Error(sound + ': a pitched sample map, not mirrored')
  fs.mkdirSync(path.join(dir, sound), { recursive: true })
  const files = []
  for (const file of bank[sound]) {
    const name = decodeURIComponent(path.basename(file)).replace(/[^\w.-]+/g, '_')
    const res = await fetch(bank._base + file)
    if (!res.ok) throw new Error(sound + ': HTTP ' + res.status + ' for ' + file)
    fs.writeFileSync(path.join(dir, sound, name), Buffer.from(await res.arrayBuffer()))
    files.push(sound + '/' + name)
  }
  mirror[sound] = files
  console.log(sound + ': ' + files.length + ' files')
}
const { _base, ...sounds } = mirror
fs.writeFileSync(mapFile, JSON.stringify({ _base: OWN_SAMPLES + 'mirror/', ...sounds }, null, 2) + '\n')
