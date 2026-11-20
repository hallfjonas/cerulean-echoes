// Lists the stem library: versions grouped by stem, lineage, and (with --used-by) the tracks that use each version.
// usage (in tools/): node stems/stems.mjs [--role lead] [--genre house] [--energy 2-4] [--tag airy] [--used-by]
//   [--json]
import { fileURLToPath } from 'url'
import { formatIndex, stemIndex } from './stem-index.mjs'

const VALUE_FLAGS = ['role', 'genre', 'energy', 'tag']

export function parseArgs(args) {
  const filters = {}
  const options = { usedBy: false, json: false }
  for (let i = 0; i < args.length; i++) {
    const flag = args[i].replace(/^--/, '')
    if (VALUE_FLAGS.includes(flag)) {
      if (i + 1 >= args.length || args[i + 1].startsWith('--')) throw new Error(`--${flag} needs a value`)
      filters[flag] = args[++i]
    } else if (flag === 'used-by') options.usedBy = true
    else if (flag === 'json') options.json = true
    else throw new Error(`unknown option "${args[i]}"`)
  }
  return { filters, options }
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  try {
    const { filters, options } = parseArgs(process.argv.slice(2))
    const index = stemIndex(filters)
    console.log(options.json ? JSON.stringify(index, null, 2) : formatIndex(index, options))
  } catch (error) {
    console.error(error.message)
    process.exit(1)
  }
}
