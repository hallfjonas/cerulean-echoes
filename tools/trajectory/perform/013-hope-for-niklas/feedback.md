# 013 A Hope for Niklas performance - feedback

## Loop 1 / Round 1 - one-hope.md (2026-11-18)
- User: (no answer yet)
- Changed: first draft after the approved song design: 57 bars = 2 min 4 s, the song once (Dawn, Groove, Rise,
  Drive, March, Ending), shaped by faders, Fog and Chapter, no drops, one Launchkey gesture (Tam-tam on the final
  hits). The script is generated from the map's `performance` section (`npm run producer -- ... --perform`), written
  in the same step so the first listen can answer the design and the sound together.
- Open questions: a repeat (needs restart chapters), the fog opening, the dynamic range, the tam-tam, Chapter as a
  label only (see the design).
- Decision: open, waiting for the user

## Loop 2 / Round 1 - one-hope.json (2026-11-18)
- How to listen: player (`cd tools && node trajectory/server.mjs 8767`, http://localhost:8767/player.html in Chrome),
  pick 013-hope-for-niklas, P, choose `one-hope`, Start (restarts the song at bar 1).
- Listen for:
  - Dawn (bars 1-12): is the opening too quiet or too far away (Fog 0.4 clearing by bar 13)? Do the violin's soft A5
    16ths and the pizzicato at bar 7 come in audibly but gently?
  - Groove (13-18): timpani, fretless synth and strings arrive together; is the fretless synth too modern next to the
    orchestra?
  - Rise (19-30): brass at 19, then a 6-bar crescendo (Master, Strings, Brass) into the cymbal crescendo of bar 30.
    Does it grow enough?
  - Drive (31-46): the violin arpeggio on top (raised to 0.7 at bar 30.5), brass swelling into the A major bar 46.
    CPU: densest stretch, listen for dropouts.
  - March (47-54): bells, bass drum and contrabass; balance of the bells against brass (one fader).
  - Ending (55-57): the violin's E alone in bar 55, the two hits in bar 56 with a tam-tam, then silence (Master 0 at
    56.5). Does the tam-tam fit, and does the end cut the tails?
- Checked: `check-perform` ok; `verify` ok (transpile, sounds, layout/syx, tap 8 stems, perform); scenario per
  section: 4-8 stems heard, no SILENT; Chapter reads Part 2 at bar 33 and Part 3 at bar 49 (LC view), every part plays
  all its notes (place kept); audibility at the default state: no CLIPS, bars 1-4 only cello and piano (the other five
  stems SILENT there by the score); mix rendered at the script's levels: −27.6 LUFS (Dawn) to −17.1 LUFS (March), peak
  at most 0.57. Not checked: CPU in the player.
- Decision: open, waiting for the user's listen

## Approved

2026-11-18: user said "Approved" after listening: performance design and script one-hope, as written; open questions stay as drafted.
