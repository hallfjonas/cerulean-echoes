// usage: node cdp.mjs <page url>  (Chrome already running with --remote-debugging-port=9333)
const url = process.argv[2]
const sleep = ms => new Promise(r => setTimeout(r, ms))
let tabs
for (let i = 0; i < 50 && !tabs; i++) { try { tabs = await (await fetch('http://127.0.0.1:9333/json/list')).json() } catch { await sleep(200) } }
const page = tabs.find(t => t.type === 'page')
const ws = new WebSocket(page.webSocketDebuggerUrl)
await new Promise(r => ws.onopen = r)
let id = 0; const wait = {}
ws.onmessage = m => { const d = JSON.parse(m.data); if (d.id && wait[d.id]) { wait[d.id](d.result); delete wait[d.id] } }
const send = (method, params = {}) => new Promise(r => { wait[++id] = r; ws.send(JSON.stringify({ id, method, params })) })
await send('Page.navigate', { url })
for (let i = 0; i < 240; i++) {
  await sleep(500)
  const r = await send('Runtime.evaluate', { expression: "document.getElementById('o')?.textContent ?? ''", returnByValue: true })
  const t = r?.result?.value ?? ''
  if (t.startsWith('DONE')) { console.log(t); process.exit(0) }
}
console.log('TIMEOUT'); process.exit(1)
