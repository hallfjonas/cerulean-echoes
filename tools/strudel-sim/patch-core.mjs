// The @strudel/core dist bundle imports the browser-only REPL (@kabelsalat/web), which fails in Node.
// Point the package at a source entry without the REPL/scheduler/UI modules. Run by `npm install`.
import fs from 'fs'
import path from 'path'
import { fileURLToPath } from 'url'

const dir = path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'node_modules', '@strudel', 'core')
const skip = /repl|evaluate|cyclist|zyklus|speak|ui\.mjs|drawLine|clockworker/
const lines = fs.readFileSync(path.join(dir, 'index.mjs'), 'utf8').split('\n').filter(l => !skip.test(l))
fs.writeFileSync(path.join(dir, 'index-node.mjs'), lines.join('\n').replace(', createClock }', ' }'))
const pkgFile = path.join(dir, 'package.json')
const pkg = JSON.parse(fs.readFileSync(pkgFile, 'utf8'))
pkg.main = 'index-node.mjs'
delete pkg.module
delete pkg.exports
fs.writeFileSync(pkgFile, JSON.stringify(pkg, null, 2))
console.log('patched @strudel/core for Node')
