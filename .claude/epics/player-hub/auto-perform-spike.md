---
name: auto-perform-spike
created: 2026-11-16T12:00:00Z
epic: player-hub
type: report
---

# Report: auto-perform spike (track 010 played without a controller)

The player (`tools/trajectory/player.html`) played track 010 for about four minutes with no Launch Control
connected: stems came in one by one, Tension built and dropped, Chapter and Break were pressed, Fog swept in and out,
and the master faded out at the end. Nothing in the repo was changed; everything was injected into the open page.
This is the epic's "auto-perform, open loop" idea (script player into a virtual port) done by hand, and it shows the
idea works with today's code.

## Setup
- Server: `node tools/trajectory/server.mjs 8766` (the `trajectory` entry in `.claude/launch.json`), page
  `http://localhost:8766/player.html`, which lists the tapped copies of 007-010 (`tools/trajectory/tapped/`).
- Browser: Claude Code's built-in browser pane. Claude in Chrome was not connected; the pane plays audio through the
  Mac like Chrome does.

## How it worked
1. **Virtual Launch Control.** The one-file tracks find their controllers through three page globals the player
   defines: `WebMidi.inputs` (port names), `midin(name)` (a CC reader) and `midikeys(name)`. Before starting the
   track these were replaced from the page console:
   ```js
   window.VCC = {}
   const PORT = 'LCXL3 Virtual MIDI Out'
   globalThis.WebMidi = { inputs: [{ name: PORT }], outputs: [] }
   globalThis.midin = async name => {
     if (name && !PORT.includes(name)) throw new Error('MIDI input not found: ' + name)
     return cc => signal(() => window.VCC[cc] ?? 0)
   }
   globalThis.midikeys = async name => { throw new Error('MIDI input not found: ' + name) }
   ```
   The track sees one port whose name contains `LCXL3`, so it gives it the full single layout (Mode 1 CCs and
   Mode 2 = CC + 48). The Launchkey lookup fails, so `stemLK` stays silent, exactly as with no Launchkey plugged in.
   `signal` reads `VCC` on every query, so a value written there is heard at the next scheduler tick.
2. **Three helpers** wrote into `VCC`: `cc(n, v)` sets a control, `ramp(n, to, sec)` moves it over time (50 ms steps),
   `press(n)` holds a momentary button at 1 for 350 ms, long enough for `cycleButton` to see the rising edge.
3. **A timeline** of `setTimeout` cues (seconds from start), using the CC map from `CLAUDE.md`:

   | Time | Move | CCs |
   |---|---|---|
   | 0 | Master 0.8; pad (Mode 2 col 1) fades in, its Space 0.5 | 12, 60; 53; 69 |
   | 8-32 | Kick, sub, hats, clap + congas fade in one by one | 5, 7, 10, 9, 11 |
   | 40 | Deep chords (Mode 2 col 2) | 54 |
   | 56 | Tension ramps to 0.9 over 16 s, noise pump rises | 36; 6 |
   | 72 | Drop: Tension to 0, Chapter pressed | 36; 44 |
   | 88 / 104 | Break pressed (low end out), pressed again (back on the one) | 52 |
   | 120 | Kick Pattern pressed, hat Complexity up | 37; 34 |
   | 136-160 | Fog in, Fog out | 20 |
   | 170 | Chapter pressed, rolling bass in | 44; 8 |
   | 200 | Conga Pattern pressed, conga Complexity up | 43; 35 |
   | 240 | Master fades to 0 over 20 s | 12, 60 |

4. **Starting the track.** The page's Play button did nothing in the browser pane: its handler first awaits
   `navigator.requestMIDIAccess()`, which never settles there (no permission prompt). The track was evaluated
   directly instead, with the same steps the button takes:
   ```js
   const { evaluate } = await import('https://unpkg.com/@strudel/web@1.2.6/dist/index.mjs')
   const code = await fetch('tapped/010-ambient-house-tapped.strudel', { cache: 'no-store' }).then(r => r.text())
   globalThis.strudelMirror = { code }
   await evaluate(code)
   ```
   The module URL is the one the player imports, so it is the same Strudel instance (already initialised, samples
   loaded, audio context running after a click on the page). The LC view and the trajectory visuals worked as with
   real controllers.

## What it shows for this epic
- **The virtual port needs no engine change.** `midin` and `WebMidi` are the only seam; a script player only has to
  provide a port the tracks recognise and feed it values. The epic's first slice (JSON timeline into a virtual port)
  is small, as estimated.
- **Last-moved-wins is still open.** The spike replaced `midin`, so a real controller would have been ignored. The
  real version should add the virtual port to the player's `ports` map (`ports.set('Auto', …)` as the epic says), so
  the existing per-CC last-moved rule lets a human grab any control.
- **Timing is wall-clock, not musical.** `setTimeout` cues drift against bars; the timeline should be in cycles and
  quantised to bars or phrases (Chapter already waits for the next 4-bar phrase, other moves do not).
- **Button presses need a minimum hold** (one or two scheduler ticks), or `cycleButton` misses them.
- **Defaults matter.** All faders start at 0 (silence), so a timeline must set Master and at least one fader first.
- **Play depends on Web MIDI.** If `requestMIDIAccess` hangs or is refused, Play never starts. A timeout or
  "continue without MIDI" in `player.html` would let the player run in more browsers; that is a fix for `player-hub`.
- **Set 011 is not in the player.** Only the tapped one-file tracks 007-010 are listed, so "play the set" meant one
  track; auto-perform across the set needs a tapped `011-set-dual` or a timeline that switches tracks.
