// Minimal OSC 1.0 codec for the SuperCollider link (sc-link.mjs) and the stand-alone LC view bridge (sc/ui/bridge.mjs).
// encode(address, args): args are strings, { i } (int32) or { f } (float32). decode(buffer) → { address, args }.
const pad4 = n => (n + 3) & ~3
const oscString = s => {
  const b = Buffer.from(s + '\0', 'utf8')
  const out = Buffer.alloc(pad4(b.length))
  b.copy(out)
  return out
}
export const encode = (address, args = []) => {
  const tags = ',' + args.map(a => typeof a === 'string' ? 's' : Number.isInteger(a.i) ? 'i' : 'f').join('')
  return Buffer.concat([oscString(address), oscString(tags), ...args.map(a => {
    if (typeof a === 'string') return oscString(a)
    const b = Buffer.alloc(4)
    if (Number.isInteger(a.i)) b.writeInt32BE(a.i); else b.writeFloatBE(a.f)
    return b
  })])
}
const readString = (buf, at) => {
  const end = buf.indexOf(0, at)
  return [buf.toString('utf8', at, end), pad4(end + 1)]
}
export const decode = buf => {
  let [address, at] = readString(buf, 0), tags
  ;[tags, at] = readString(buf, at)
  const args = []
  for (const t of tags.slice(1)) {
    if (t === 'i') { args.push(buf.readInt32BE(at)); at += 4 }
    else if (t === 'f') { args.push(buf.readFloatBE(at)); at += 4 }
    else if (t === 'd') { args.push(buf.readDoubleBE(at)); at += 8 }
    else if (t === 's' || t === 'S') { const [s, next] = readString(buf, at); args.push(s); at = next }
    else if (t === 'h') { args.push(Number(buf.readBigInt64BE(at))); at += 8 }
  }
  return { address, args }
}
