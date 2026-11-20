// Check sc/lib/mini.scd against Strudel's mini-notation parser: for each string, Strudel's events over the SC
// parser's period. usage: node mini-check.mjs <strings.json> → prints [{ str, period, events: [[b, d, v]] }] (JSON)
// The period comes from the SC side (sc-mini.scd); here we query 16 cycles and let the comparison cut.
import fs from 'fs'
import { mini } from '@strudel/mini'
const strs = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'))
const out = strs.map(str => ({ str, events: mini(str).queryArc(0, 16).filter(h => h.hasOnset())
  .map(h => [h.whole.begin.valueOf(), h.whole.end.valueOf() - h.whole.begin.valueOf(), h.value]) }))
console.log(JSON.stringify(out))
