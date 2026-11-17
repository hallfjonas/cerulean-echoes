# Trajectory — making music architecture visible

Phase 1, prototype

The idea is in [player-future.md](../../docs/player-future.md#4-music-architecture-trajectory): every voice of a track has, at every
moment, a place in space – left/right (pan), low/high (frequency) – and a place in the dialogue over time (tempo,
rhythm, groove). This path (trajectory) is measured, saved as a file and animated live. Phase 2 (later):
emotions through audience feedback.

Pitch deck (12 slides, assessment + plan): https://claude.ai/artifact/5gM7MWgHqHCLvk3BveX9AZ

## Start: the player

```bash
cd tools && node trajectory/server.mjs [port]
```

Then open **http://localhost:8766** in Chrome. The player is the repo's main tool: it plays a track right on localhost
(no strudel.cc needed) and shows the visuals right behind it: every stem with its name, tempo from Strudel's clock.
The server only answers to its own pages (Origin and Host are checked on the routes that run something).

1. Pick a track in the list at the top: **Live** holds the one-file live tracks (007-010), **Lab** the boards from
   `lab/`. Boards without a master `stack(` cannot be tapped and are greyed out.
2. **Play**. The player taps the track file in memory each time it loads it, so editing a track and pressing Play
   plays the edit; there is no tapped copy on disk and no extra step. Picking another track while one plays stops it
   and loads the new one.
3. Play the controllers. Every control the track reads through `midin()` comes from the connected controllers (Web
   MIDI, each port on its own as in strudel.cc); a control not moved yet reads 0 (or the start value the track gives
   it). The Launchkey plays along: keys and drum pads (`midikeys`), mod wheel and knobs. With no controller, raise the
   master fader of the virtual controller with auto-perform (below).

Play never waits on Web MIDI: if the browser does not answer within 2 s (or there is none, as in a built-in browser
pane), the status line says "No MIDI" and the track plays with the virtual controller only.

The track's status box (bottom right) hides while its LC view ("▣ LC big") is open in another window.

The top bar holds the track list, Play, Stop, the status line, Settings and the page links (Player, Tools,
Analysis). It hides after 3 s without the mouse.

### Settings drawer

**Settings** (or key **S**) opens a drawer; it is generated from `settings.mjs` and every value is kept in
`localStorage`.

- **Hard ↔ Soft** (0…1, start 0): character of the visuals. 0 = sawtooth crests, angular lines, every past time slice
  with an edge, instant response, camera pushed by the beat; 1 = round waves, thick soft crests, motion smear, sluggish
  following, gliding camera.
- **Raw ↔ Smooth** (0…1, start 0.06 ≈ 302 ms): moving average (exponentially weighted) over N = 2^(53·slider) lines on
  all signals the visuals see: 0 = raw, 0.1 ≈ 1.3 s, 0.3 ≈ 34 min, 0.5 ≈ 37 days, 1 = 2^53 (max_int), frozen. Visuals
  only; the sound stays raw.
- Switches with keys (start: axes and labels off, beat rings and LC frame on): **A** axes · **L** labels (stem names,
  axis words) · **B** beat rings (the circles from the kick) · **H** LC frame (the frame around the controller page
  used last in the LC view) · **V** look (deck / ocean / clean) · **W** pan width (stretches the range the music
  used).
- **F** toggles fullscreen.
- **Auto-perform** section, key **P**: see below.

### Auto-perform

Auto-perform plays a script of control moves and button presses into a virtual controller, so a track and the player
can be tried without hardware. It is open loop: the script does not listen to what it hears.

- The virtual input is `LCXL3 Auto` in the ports map of `midi.mjs`. Its name contains `LCXL3`, so every one-file track
  gives it the full single layout. A real controller moved later takes a control over (last moved wins per CC).
- Scripts are JSON in `perform/<track>/*.json`, listed with the track in the catalogue: `{ track, steps }` with steps
  `{ bar, cc, value, ramp? }` (value 0…1, ramp in bars) and `{ bar, press }` (press = CC of a momentary button). Bars
  count from the start; a control the script never sets stays at 0. Every live track has `every-button.json`; 010 also
  has `spike-run.json`.
- Steps follow the engine's cycle clock, not a timer, so they stay on the bar whatever the tempo; a press is held for
  two scheduler ticks so the tracks' `cycleButton` sees it.
- Pick a script in the drawer, **Start** (or **P**) reloads the track so the script begins from silence; **Stop** (or
  **P**) ends it.
- Every CC a script names must exist in the track's `@ctl` tags: `node trajectory/check-perform.mjs [<track> …]`
  checks it, and `npm run verify` runs it.

### Tools page

**http://localhost:8766/tools.html** runs the Node checks from the browser: pick a command, pick a track or board
from the catalogue (filtered by what the command accepts), **Run** (live log) or **Stop**. One job runs at a time
(a second request gets 409). The commands are a fixed list in `tools.mjs`: check sounds, loudness of every stem, layout
sheet + syx, stem lab sync and check (boards), build set 011. Paths never come from the page: a target is a catalogue
id. **Analysis** (`analyse.html`) is a tool on the same page: the audio analysis from a file or input, with recording.

### Help panel

Every page has a **Help** button (key **?**) that opens a collapsible panel on the right (open by default): what the page does, its input
and output, how to use it. On the Tools page it follows the chosen command; the text lives with the command in
`tools.mjs` (`help`: `does`, `input`, `output`, `use`). Closing it is remembered. A new page calls
`mountHelp(sections)` from `help.mjs`.

### Strudel.cc

Every live track file plays on strudel.cc as it is; the player adds nothing to it. To see the visuals of a track that
plays on strudel.cc, put the tapped code on the clipboard (macOS) and paste it into strudel.cc next to the player:

```bash
cd tools && node trajectory/make-tapped.mjs ../tracks/techno/008-groove-techno/008-groove-techno.strudel
```

Old dual versions are tapped through their single version (e.g.
`tracks/sets/011-combining-all/011-set-single.strudel`); set 011 is not in the player's list.

## Progress

| Day | Content | Status |
|---|---|---|
| 1 · Sound in | Web Audio analysis → JSONL | done; BPM exact (synth 126.0, 008: 139.9 at 140) |
| 2 · Picture out | renderer, fullscreen, mono fix, level meter | done, rated 10/10 by Jonas |
| 3 · Strudel | tapped track → server → exact stems | done; 008 (11–16 stems, 140.0 BPM), 009 house (15 stems, 124.0 BPM) |
| Follow-up | channel 3/4, look "ocean" (liquid, 4D, soft) | built, hardware test pending |
| Deck look | default look like slide 6 of the pitch deck (comets, rings, axes); ocean/clean via V | built, checked with simulated stems |
| 4 · Capture | playback, video export, Demucs | postponed |
| 5 · Rehearsal | projector, polish, KPI display | open |

## How it is built

```
 Audio (file / input) ──analyse.mjs──┐
                                     ├─► trajectory (lines) ─► render.mjs ─► canvas
 strudel.cc / player ──server.mjs──┘   strudel-source.mjs              └► recording (JSONL)
        (tapped in memory, make-tapped.mjs)
```

Both inputs write **the same format**; the renderer does not know where the music comes from:

```
{"t":12.533,"stem":"bass","x":-0.12,"y":0.31,"z":0.20,"e":0.72,"on":1}
{"t":12.533,"pulse":{"bpm":140,"phase":0.25,"density":0.6,"swing":0.04}}
```

`x` pan −1…1 · `y` pitch log 20 Hz–20 kHz → 0…1 · `z` depth (audio: L/R decorrelation; Strudel: `room`) ·
`e` energy 0…1 · `on` onset · `pulse` tempo, bar phase, density (share of filled 16ths in the last bar), swing.

| File | Job |
|---|---|
| `analyse.mjs` | core of the audio analysis (browser + Node): FFT 2048 for level/pan/onsets, 8192 for the pitch of kick and bass, tempo by autocorrelation |
| `analyse-file.mjs` | CLI: file → JSONL + summary (drift = movement within 8 bars) |
| `render.mjs` | picture. "deck" (default, like slide 6 of the deck): glowing comets with tails, rings from the kick, axes. "ocean": stems as liquid layers, time into depth, floating camera. "clean": comets, rings |
| `smoothing.mjs` | slider Raw ↔ Smooth: moving average, window grows exponentially up to 2^53 lines |
| `strudel-source.mjs` | Strudel events → lines, each event appears when it sounds (`delay`) |
| `make-tapped.mjs` | `tapSource(src, name)`: every stem gets its readable name from the track (`@col` column name, Jojo's column 8: the name of its Pattern button, `stemLK` = Launchkey) as `.tag()`, the master sends via `.onTrigger` (sound unchanged); also a CLI that copies the tapped code to the clipboard |
| `server.mjs` | `/` player, static pages, `/catalogue`, `/track/<id>` (tapped on request), `/perform/<track>/<script>`, `/tools` and `/run` (Tools page), relay POST `/events` → SSE `/stream`; CORS and private-network headers on the relay for strudel.cc |
| `player.html` | the player page: loads a track through the engine, shows it with `render.mjs`, top bar and drawer |
| `engine-strudel.mjs` | everything Strudel: `initStrudel`, sample banks and `gm_*` soundfonts, evaluate, stop, `cycle()`, the `midin` / `midikeys` shims |
| `midi.mjs` | Web MIDI: ports map, last value per CC, key queue, virtual `LCXL3 Auto` port |
| `autoperform.mjs` | the script player and the drawer section |
| `settings.mjs` | every visual setting as data; builds the drawer and the keys |
| `catalogue.mjs` | scans live tracks and lab boards, their auto-perform scripts |
| `tools.mjs` | the Tools page commands (whitelist), job runner |
| `tools.html`, `nav.mjs`, `help.mjs`, `ui.css` | the Tools page, the shared top navigation, the Help panel and look |
| `banks.mjs` | sample banks and soundfonts the player loads, as strudel.cc does |
| `analyse.html` | the analysis page: sources, channel choice, recording, keys |

## What we learned

- **Bands are not stems.** In the 008 recording the sub part of the bass lands in the kick band; the summary
  therefore shows the kick "moving" more than the bass, although it stays fixed within a section (60–120 s: 43 Hz).
  Only Strudel makes it exact (or Demucs later).
- **Microphone ≠ music.** The Scarlett mic arrives on the left only (→ now treated as mono); the MacBook mic is mono.
  The music is on the Scarlett loopback 3/4.
- **The 008 mix sits in the middle of the stereo field.** That is why pan width (×1 to ×5, key W) stretches it to
  the range in use.
- **Liked:** day 2 ("10/10"). **Not liked:** sharp lines ("blades"), dazzling additive light.
  Wanted: dense liquid with waves on top, soft light, angled view with a wandering viewpoint –
  that became "ocean". After that: back to the look of slide 6 of the deck ("deck", now the default).

## Limits of the player

The player is meant for visuals and rehearsals, not as a full replacement for strudel.cc.

**Sounds in the player:** Strudel's built-in synths, dirt samples, drum machines, VCSL, piano, the `gm_*` soundfonts
and all samples a track loads itself; `banks.mjs` loads the same banks as strudel.cc. A sound that does not load is
listed in `samples/sounds.json` (check: `node strudel-sim/check-sounds.mjs <track>`).
Controllers: every Launch Control XL 3, the Launchkey (keys, drum pads, mod wheel, knobs) and the virtual
`LCXL3 Auto` port.

## Open (by priority)

1. **Test with hardware:** does Chrome get 4 channels from the Scarlett? The status line says so ("measuring 3/4" or
   "channel 3/4 missing"). If missing: use the Strudel path or a virtual device (BlackHole).
2. **strudel.cc in your own Chrome** with controllers + the tapped code (blocked in the browser pane; in Chrome maybe
   allow the "local network" prompt).
3. **Ocean look:** liked? Measure performance in fullscreen (not measured; "clean" was at 1–3 ms per frame).
4. **Day 5:** projector rehearsal, KPI "Spatial Trajectory Harmony" (separation × anchor × movement) as a number in
   the picture, crowd tap button (timestamps for audience reactions = starting point of phase 2).
5. **Day 4:** playback of recordings, video export, Demucs (heavy: PyTorch, long compute time on the M2 Air).

Link to the music ([TODO.md](../../TODO.md)): "segment the space" and "build-up across lows/mids/highs" for
008 can be seen and measured directly with the Strudel path.
