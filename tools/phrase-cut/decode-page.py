import sys, json
urls = [l.strip() for l in open(sys.argv[1]) if l.strip()]
open(sys.argv[2], 'w').write('''<!doctype html><meta charset=utf-8><body><pre id=o>running</pre><script>
const U = %s, out = [];
(async () => { const ac = new OfflineAudioContext(1, 44100, 44100)
 await Promise.all(U.map(async u => { try { const r = await fetch(u); if (!r.ok) throw new Error('HTTP ' + r.status)
  const b = await ac.decodeAudioData(await r.arrayBuffer()); out.push('OK   ' + b.duration.toFixed(2) + 's ' + u) }
  catch (e) { out.push('FAIL ' + e.message + ' ' + u) } }))
 document.getElementById('o').textContent = 'DONE\\n' + out.sort().join('\\n') })()
</script>''' % json.dumps(urls))
