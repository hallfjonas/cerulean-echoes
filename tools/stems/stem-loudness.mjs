// Loudness of every stem of a stem track, each rendered alone in SuperCollider at the reference state: its fader and
// the master at 1, every knob at 0, its first pattern, Chapter Vamp (docs/features/stems.md, "Loudness"). Prints the
// integrated loudness (LUFS) and the loudest 400 ms (LUFS-M) per slot and the gain that brings LUFS-M to the target
// of its role. Needs sclang (tools/sc-port/sc-render.sh) and ffmpeg.
// usage (in tools/): node stems/stem-loudness.mjs <file.track> [--bars 8] [--work <dir>]
import fs from 'fs'
import os from 'os'
import path from 'path'
import { execFileSync } from 'child_process'
import { fileURLToPath } from 'url'
import { repoRoot } from './check-stems.mjs'

// LUFS-M at fader 1 per role: the 009-house kick (−13.7 LUFS-M, gain 1) plus the strudel-mix offsets per role
export const TARGET_KICK = -13.7
export const ROLE_OFFSET = { kick: 0, sub: -4, bass: -4, clap: -5.5, keys: -5, chords: -5, pad: -5, lead: -5, hats: -10,
  perc: -10, fx: -10, texture: -10 }

function measure(wav) {
  const text = execFileSync('sh', ['-c', `ffmpeg -hide_banner -nostats -i "${wav}" -af ebur128 -f null - 2>&1`],
    { encoding: 'utf8' })
  const ms = [...text.matchAll(/ M:\s*(-?[\d.]+)/g)].map(m => Number(m[1]))
  const integrated = Number(text.match(/I:\s*(-?[\d.]+) LUFS\s*\n\s*Threshold/)?.[1] ?? NaN)
  return { lufs: integrated, lufsM: Math.max(...ms) }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const args = process.argv.slice(2)
  const opt = (name, dflt) => { const i = args.indexOf(name); return i < 0 ? dflt : args[i + 1] }
  const file = path.resolve(process.env.INIT_CWD ?? process.cwd(), args[0])
  const bars = Number(opt('--bars', 8))
  const work = opt('--work', fs.mkdtempSync(path.join(os.tmpdir(), 'stem-loudness-')))
  const track = JSON.parse(fs.readFileSync(file, 'utf8'))
  const id = path.relative(path.join(repoRoot, 'sc', 'tracks'), file)
  console.log('slot  role     LUFS   LUFS-M  target  gain  stem')
  for (const [slot, ref] of Object.entries(track.slots).sort()) {
    const stem = JSON.parse(fs.readFileSync(path.join(repoRoot, 'sc', 'stems', ref), 'utf8'))
    const n = Number(slot[2]), fader = 4 + n + (slot[0] === '2' ? 48 : 0)
    const scen = path.join(work, `${slot.replace(':', '_')}.json`), prefix = path.join(work, slot.replace(':', '_'))
    fs.writeFileSync(scen, JSON.stringify({ bpm: track.tempo, cycles: bars, cc: { 12: 1, [fader]: 1 }, events: [] }))
    execFileSync(path.join(repoRoot, 'tools', 'sc-port', 'sc-render.sh'), [scen, prefix, `s${slot.replace(':', '_')}`],
      { env: { ...process.env, CE_TRACK: id }, stdio: 'inherit' })
    const m = measure(prefix + '.wav')
    const target = TARGET_KICK + ROLE_OFFSET[stem.meta.role]
    const gain = (stem.gain ?? 1) * 10 ** ((target - m.lufsM) / 20)
    console.log(`${slot}  ${stem.meta.role.padEnd(7)} ${m.lufs.toFixed(1).padStart(6)} ${m.lufsM.toFixed(1).padStart(7)} ` +
      `${target.toFixed(1).padStart(7)} ${gain.toFixed(2).padStart(5)}  ${ref}`)
  }
}
