// Sample Designer projects from the terminal (the player does the same with Save / Save as / Export).
// usage (in tools/):
//   node sound-lab/sample-lab.mjs check [<file.sample.json> …]   project check (no files: every project), exit 1 on
//                                                                errors
//   node sound-lab/sample-lab.mjs save-as <name> <new-name>       copy a project (parent = name)
//   node sound-lab/sample-lab.mjs export <name> [--as <sound>] [--no-wav]
//                                    sc/sounds/<sound>.scd + samples/sound-lab/<sound>.wav (needs sclang for the WAV)
import path from 'path'
import { findSclang } from '../trajectory/sc-link.mjs'
import { checkAll, checkProjectFile, exportSound, saveAs } from './sample-project.mjs'

const [command, ...args] = process.argv.slice(2)
const option = name => { const i = args.indexOf(name); return i < 0 ? null : args[i + 1] }

try {
  if (command === 'check') {
    const results = args.length
      ? args.map(f => path.resolve(process.env.INIT_CWD ?? process.cwd(), f))
        .map(file => ({ file, errors: checkProjectFile(file) }))
      : checkAll()
    for (const { file, errors } of results) console.log(`${errors.length ? 'FAIL' : 'ok  '} ${path.basename(file)}` +
      (errors.length ? '\n  ' + errors.join('\n  ') : ''))
    process.exit(results.some(r => r.errors.length) ? 1 : 0)
  } else if (command === 'save-as') {
    console.log('wrote ' + saveAs(args[0], args[1]))
  } else if (command === 'export') {
    const sclang = args.includes('--no-wav') ? null : findSclang()
    const out = await exportSound(args[0], { ...option('--as') && { soundName: option('--as') }, sclang })
    console.log('wrote ' + [out.sound, out.wav].filter(Boolean).join('\n      '))
    if (!out.wav) console.log('no WAV: ' + (sclang ? 'skipped' : 'sclang not found'))
  } else {
    console.log('usage: node sound-lab/sample-lab.mjs check [files] | save-as <name> <new> | export <name> [--as <s>]')
    process.exit(2)
  }
} catch (error) {
  console.error(error.message)
  process.exit(1)
}
