// Stem Designer projects from the terminal (the player does the same with Save / Save as / Promote).
// usage (in tools/):
//   node sound-lab/stem-lab.mjs check [<file.stemlab.json> …]   project check (no files: every project), exit 1 on errors
//   node sound-lab/stem-lab.mjs save-as <name> <new-name>        copy a project (parent = name)
//   node sound-lab/stem-lab.mjs promote <name> <slot>            the draft of the column → sc/stems/<sample>/ (new version)
//   node sound-lab/stem-lab.mjs track-with <track> <new-track> <slot>=<ref> …
//                                                                new stem track = a copy of <track> with those slots
//   node sound-lab/stem-lab.mjs from-track <track> <name> <slot>… [--backing <slot>…]
//                                                                new project: those slots of <track> as columns
//   node sound-lab/stem-lab.mjs export-track <name> <new-track>  the project as a stem track (context frame + backing)
import path from 'path'
import { checkAll, checkProjectFile, projectFromTrack, promote, saveAs, trackFromProject, trackWith } from './stem-project.mjs'

const [command, ...args] = process.argv.slice(2)

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
  } else if (command === 'promote') {
    const { file, ref } = promote(args[0], args[1])
    console.log(`wrote ${file}\ncolumn ${args[1]} is now ${ref}`)
  } else if (command === 'track-with') {
    const slots = Object.fromEntries(args.slice(2).map(pair => pair.split('=')))
    console.log('wrote ' + trackWith(args[0], args[1], slots))
  } else if (command === 'from-track') {
    const split = args.indexOf('--backing')
    const columns = args.slice(2, split < 0 ? undefined : split)
    const backing = split < 0 ? [] : args.slice(split + 1)
    console.log('wrote ' + projectFromTrack(args[0], { name: args[1], columns, backing }))
  } else if (command === 'export-track') {
    console.log('wrote ' + trackFromProject(args[0], args[1]))
  } else {
    console.log('usage: node sound-lab/stem-lab.mjs check [files] | save-as <name> <new> | promote <name> <slot> | ' +
      'track-with <track> <new-track> <slot>=<ref> … | from-track <track> <name> <slot>… [--backing <slot>…] | ' +
      'export-track <name> <new-track>')
    process.exit(2)
  }
} catch (error) {
  console.error(error.message)
  process.exit(1)
}
