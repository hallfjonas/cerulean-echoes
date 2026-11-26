# Trajectory — making music architecture visible

Phase 1, prototype

The idea: every voice of a track has, at every
moment, a place in space – left/right (pan), low/high (frequency) – and a place in the dialogue over time (tempo,
rhythm, groove). This path (trajectory) is measured, saved as a file and animated live. Phase 2 (later):
emotions through audience feedback.

Pitch deck (12 slides, assessment + plan): https://claude.ai/artifact/5gM7MWgHqHCLvk3BveX9AZ

## Start: the player

```bash
cd tools && node trajectory/server.mjs [port]
```

Then open **http://localhost:8766** in Chrome. Or without a Terminal: double-click **Cerulean Echoes.app** in the
repo folder (the launcher, `tools/launcher/`): it starts this server, shows the player in its own window (WKWebView; no Web MIDI, so Strudel tracks get no
controllers there, SC tracks are unaffected) and
stops the server and its SuperCollider when it is quit (Dock: Quit; also on a force quit). An already running player
on the port is only opened. First start: `npm ci` once, with a message. Log: `~/Library/Logs/cerulean-echoes.log`.
`tools/launcher/launch.sh check|install|start|open|alive|url|stop [--port N] [--no-browser]` does the work (also
`CE_PORT`, `CE_NO_BROWSER=1`); after changing `launcher.applescript`, rebuild the app with `npm run launcher` and commit it.
The player is the repo's main tool: it plays a track right on localhost
(no strudel.cc needed) and shows the Live page full size: both LC pages and the Launchkey row with every control's
name and value (the track's LC view). The visuals (every stem with its name, tempo from Strudel's clock) are the
a page of their own (Visuals); Labs holds the Sample and Stem Designer.
The server only answers to its own pages (Origin and Host are checked on the routes that run something).

1. Pick a track in the sidebar: **Live** holds the live tracks.
   SuperCollider tracks (`sc/tracks/`, listed under their plain id) play through SC: the server starts `sclang sc/engine.scd` on the first SC load (a few seconds) and
   ends it with itself; the Live and Labs pages show SC's LC view (`sc/ui/index.html` at `/sc/`); the controllers go straight to
   SC. Record, auto-perform, takes and the visuals work on SC tracks (below).
2. **Play**. The player taps the track file in memory each time it loads it, so editing a track and pressing Play
   plays the edit; there is no tapped copy on disk and no extra step. Picking another track while one plays stops it
   and loads the new one.
3. Play the controllers. Every control the track reads through `midin()` comes from the connected controllers (Web
   MIDI, each port on its own as in strudel.cc); a control not moved yet reads 0 (or the start value the track gives
   it). The Launchkey plays along: keys and drum pads (`midikeys`), mod wheel and knobs. With no controller, raise the
   master fader of the virtual controller with auto-perform (below).

Play never waits on Web MIDI: if the browser does not answer within 2 s (or there is none, as in a built-in browser
pane), the status line says "No MIDI" and the track plays with the virtual controller only.

### Layout

- **No top bar**: the page is the sidebar and the view. The handle on the sidebar edge holds three equal buttons, top to bottom: **‹** (hide / show the sidebar, key **S**), the **⚙** gear (Settings) and **?** ("About this page", closed on every load); with the sidebar hidden the handle stays at the left edge.
- **Sidebar** (left): the pages (Live, Labs, Visuals; Labs has the sub-tabs Samples, Stems &
  Tracks, Sets) and the sections of the page
  you are on: Live = the live track list with Play / Pause, Stop and Record (icon buttons), the status line (what plays,
  MIDI inputs, auto-perform bar) and Auto-perform (with Record audio); Labs = the project list of the sub-tab, Play /
  Pause, Stop and the designer's buttons; Visuals = Stop and the status line. Each element names its pages in
  `data-pages`; `pages.mjs` holds the page table, the pickers (Strudel lab boards are not offered) and the URL hash
  (`#live`, `#labs/<sub>`, `#visuals`).
- **Settings** (the gear): lays over the current page; the sound keeps playing. A list of sections on the left jumps to
  **Theme**, **Visuals**, **MIDI panel**, **Recording** and **Keyboard shortcuts**. Every value is kept in `localStorage`.
- **Theme** (Settings, Theme): one look for the page and the SuperCollider panel (`theme.mjs`, `ui.css`): **Minimal**
  (calm, flat, Torso-like) or **Retro** (Teenage Engineering-like), each **Auto** (as the system), **Dark** or **Light**;
  key **T** switches the style. Set in Settings only; the panel has no switch of its own. The Strudel tracks' LC view
  keeps its own look.
- **Live** (the start page): the track's LC view, drawn into the page instead of its own window. A board
  without an LC view says so; its visuals still play.
- **Visuals**: the visuals full screen behind the sidebar. Switching views keeps the sound playing; the visuals
  pause while Live or Labs shows. The track's status box
  (bottom right) shows only in this view; its "▣ LC big" still opens the LC view in its own window, and the Live
  panel takes it back when it shows again.

### Settings

The sections Visuals, MIDI panel and Recording of the Settings view are generated from `settings.mjs` (each setting
has a `group`); every value is kept in `localStorage`. Visuals:

- **Hard ↔ Soft** (0…1, start 0): character of the visuals. 0 = sawtooth crests, angular lines, every past time slice
  with an edge, instant response, camera pushed by the beat; 1 = round waves, thick soft crests, motion smear, sluggish
  following, gliding camera.
- **Raw ↔ Smooth** (0…1, start 0.06 ≈ 302 ms): moving average (exponentially weighted) over N = 2^(53·slider) lines on
  all signals the visuals see: 0 = raw, 0.1 ≈ 1.3 s, 0.3 ≈ 34 min, 0.5 ≈ 37 days, 1 = 2^53 (max_int), frozen. Visuals
  only; the sound stays raw.
- Switches with keys (start: axes and labels off, beat rings on): **A** axes · **L** labels (stem names, axis words) ·
  **B** beat rings (the circles from the kick) · **V** look (deck / ocean / clean) · **W** pan width (stretches the range
  the music used).
- MIDI panel: **H** LC frame (the frame around the controller page used last, on at start) · **C** set view (the
  SuperCollider panel's set view).
- Recording: **Save take on record stop** (see Takes).
- **F** toggles fullscreen.
- **Auto-perform** (sidebar), key **P**: see below.

### Auto-perform

Auto-perform plays a script of control moves and button presses into a virtual controller, so a track and the player
can be tried without hardware. It is open loop: the script does not listen to what it hears.

- The virtual input is `LCXL3 Auto` in the ports map of `midi.mjs`. Its name contains `LCXL3`, so every one-file track
  gives it the full single layout. A real controller moved later takes a control over (last moved wins per CC).
- Launchkey steps go to a second virtual input, `Launchkey MK4 25 Auto`. Its name contains `Launchkey MK4 25`, the
  name every live track looks up with `midin` and `midikeys`, so the track hears it as a Launchkey (keys and pads in
  `stemLK`, knobs, mod wheel) and the LC view shows it. It is connected only while a script with Launchkey steps
  plays; a script without them plays as with no Launchkey.
- **Real and virtual Launchkey together.** Both inputs match the tracks' lookup, and `midi.mjs` reads them as one:
  the keys and pads of both land in the same queue (`takeKeys` takes from every matching input), so your own keys
  and pads sound next to the scripted ones; a knob or the mod wheel follows whichever moved last, so turning it takes
  it over from the script until the script sets it again (a ramp sets it on every tick). Your keys need the mod wheel
  up like the script's: if the script last set `lk` 1 to 0, or you have not moved the wheel since the track loaded,
  move it. The track looks the Launchkey up once, when it loads: with Play or a script without Launchkey steps, a
  real Launchkey has to be connected before that; with Launchkey steps the lookup finds the virtual one, and a real
  Launchkey plugged in later is heard as well.
- Scripts are JSON in `perform/<track>/*.json`, listed with the track in the catalogue. Every live track has
  `every-button.json`; 010 also has `spike-run.json`. Bars count from the start (1 cycle = 1 bar); values are 0…1
  (sent as MIDI 0…127); a ramp moves from the value at `bar` to `value` over that many bars; a control the script
  never sets stays at 0.

  ```json
  {
    "track": "010-ambient-house",
    "title": "Sunrise",
    "bars": 64,
    "mood": "warm, slow rise, one drop",
    "sections": [
      { "name": "Intro", "from": 0, "to": 16, "intent": "pad alone, kick fades in" },
      { "name": "Drop", "from": 16, "to": 64, "intent": "full groove, keys answer the chords" }
    ],
    "steps": [
      { "bar": 0, "cc": 12, "value": 0.8 },
      { "bar": 4, "cc": 5, "value": 0.7, "ramp": 2 },
      { "bar": 16, "press": 44 },
      { "bar": 16, "lk": 1, "value": 0.8 },
      { "bar": 16.5, "keys": "d3 f3 a3", "velocity": 0.7, "length": 2 },
      { "bar": 20, "pad": 36 }
    ]
  }
  ```

  | Field / step | Meaning |
  |---|---|
  | `track` | the track id (required) |
  | `title`, `mood` | optional text: the performance's name, its mood in one line |
  | `bars` | optional length in bars; no step and no section may end after it |
  | `sections` | optional `[{ name, from, to, intent? }]`: bar ranges `[from, to)` in order, not overlapping, name one or two words; when there are sections, every step starts inside one |
  | `{ bar, cc, value, ramp? }` | a Launch Control CC (Mode 1 CC 5-51, Mode 2 = CC + 48) |
  | `{ bar, press }` | a momentary Launch Control button (its CC), held for two scheduler ticks |
  | `{ bar, keys, velocity?, length? }` | Launchkey keys played together: note names as in Strudel (`c4` = 60, `eb3`, `f#2`) or MIDI numbers, space-separated (`"c3 e3 g3"` = chord); velocity 0…1 (default 0.8); length in bars (default 1) |
  | `{ bar, pad, velocity? }` | a Launchkey drum pad: note 36-51 (drum C1 = 36), channel 10; velocity 0…1 (default 0.8) |
  | `{ bar, lk, value, ramp? }` | a Launchkey CC: mod wheel `1` (keys level) or knob `31`-`38` |

  The tracks' `midikeys` has no note-off: how long a key sounds is the track's own (LK knob 5 Length in 009/010);
  `length` only sets when the note-off reaches the LC view. Keys stay silent while the mod wheel (`lk` 1) is at 0, and
  keys or pads at bar 0 are dropped (the tracks drop what waits in the queue on their first query): start them later.
- Steps follow the engine's cycle clock, not a timer, so they stay on the bar whatever the tempo; a press is held for
  two scheduler ticks so the tracks' `cycleButton` sees it. The clock is the cycle the scheduler queries next (it
  runs ahead of what sounds), so a step is heard within one scheduler tick of its bar. A step fires once the clock is
  within 1e-6 bar of its bar, which absorbs the 4-decimal rounding of takes.
- **Every load restarts the clock.** `engine.load` calls `hush()` before it evaluates, so the scheduler starts at
  cycle 0: bar 0 of a script is cycle 0, alternations (`<a b>`) and slow patterns start in the same phase on every
  Play and Start, and the query grid is the same on every run. Values set before a load survive it (the ports keep
  their last value per CC), which is why a script is primed before the load (see Takes).
- Pick a script in the sidebar, **Start** (or **P**) reloads the track so the script begins from silence; **Stop** (or
  **P**) ends it and releases held keys (the controls keep their values). The next Start sets every control of both
  virtual inputs back to 0 before the track loads, then sets the script's bar-0 values.
- Takes you saved (below) are listed with the scripts as `takes/<name>` and play the same way.
- **On a SuperCollider track** the same scripts play (from `perform/<id>/`, one set per track id),
  but the steps go to SC instead of the virtual inputs (`sc-auto.mjs`): an LC CC as `/sc/cc` (→ `/ce/cc`), a
  Launchkey CC as `/sc/lk` (→ `/ce/lkcc`), keys and pads as `/sc/lk` notes (→ `/ce/lknote`; SC has no note-off), one
  request after the other in step order. The script's bar 0 goes with the load (`/sc/load { id, cc, lk }`), so SC
  sets it before the first note. The bar clock is SC's: `engine-sc.mjs` `cycle()` follows the `/ce/beat` messages
  (sent when the beat sounds) and runs on at the track's tempo in between, never backwards; beat to beat it is a few
  ms off, far less than the half bar scripts place presses early.
- While a script plays, the sidebar shows its title, mood and sections (the current one in bold, `intent` on hover),
  and the status line the current section and the bars left in it (`Drop · 3 bars left`); without sections only the bar.
- `node trajectory/check-perform.mjs [<track> …]` checks every script: the meta fields and sections, the shape of each
  step, every CC in the track's `@ctl` tags, every press a button, pads 36-51, LK CCs 1 / 21-28, keys that parse,
  and the `take` meta field of a take. `npm run verify-sc` runs it (with the track's headless load in SC).

### Recording audio

**Record** (button in the sidebar, key **R**) is a switch, always clickable (`record-arm.mjs`): while it is on, whatever
plays is written as a WAV file of the master output. White = off; steady red = on, nothing plays; pulsing red and white
= a file is being written.

- Human recording: from Play to Stop (or another track, or switching Record off). Stop leaves the switch on, so the next
  Play records again. Auto-perform with **Record audio** ticked, or with the switch on, records from Start to the end of
  the script plus 4 s (then a human recording continues if the track still plays); Stop, another track or a new Start
  ends it earlier. A failed start (SuperCollider down, disk full) switches Record off and shows the error.
- Files: `recordings/<track>/<YYYY-MM-DD>-<HHMMSS>-<human|auto>.wav` (16-bit PCM, stereo, the audio context's sample
  rate, 48 kHz in Chrome) and a `.json` sidecar of the same name (track, track hash, script, take, start cycle, cps,
  sample rate, length, how it ended). `recordings/` is outside git. The server makes every name; the page sends only
  the track id and the source. Recording is refused below 2 GB of free disk.
- How, SuperCollider tracks: SC writes the WAV itself (DiskOut, `sc/engine.scd`), started and stopped over OSC; the page
  only starts and finishes it (`recorder-sc.mjs`) and takes the level meter from SC.
- How, Strudel tracks: the engine wraps `AudioNode.prototype.connect` so that everything that connects to the context's destination
  goes through one master bus that also feeds the recorder worklet (`recorder-worklet.js`, `recorder.mjs`). The
  worklet streams 1 s chunks to `PUT /recording/<track>/<name>` (`recording.mjs`); the file and the sidecar are
  rewritten after every chunk, so a crash leaves a valid file. Closing the tab ends the recording with `endedBy:
  'unload'` and loses the last partial second.
- `node trajectory/check-recording.mjs` tests the endpoints with a WAV roundtrip.

### Takes and replay

Every load (Play, auto-perform Start) opens a capture of all MIDI input: controllers, virtual inputs and Launchkey
keys, pads, knobs and mod wheel (`take.mjs`). The capture before it is dropped. The setting **Save take on record stop** (Settings, Recording)
turns the current capture into an auto-perform script when a recording ends and writes it, uncommitted (`tools/trajectory/perform/*/takes/`
is gitignored):

- `perform/<track>/takes/<YYYY-MM-DD>-<HHMMSS>-<human|auto|mixed>.json`: a script v2 with a `take` field (source:
  real ports, virtual ports or both; recording time; sha1 of the track text it was played on; cps; ports heard; the
  auto-perform script that played). It is listed with the track's scripts as `takes/<name>`.
- `…/<same name>.events.jsonl`: the tapped Strudel events of that play, one batch per line.

How a capture becomes steps: the CC values the ports hold at the load become bar-0 steps; a message's bar is the
engine's clock at its arrival, which is the start of the scheduler's next query, exactly where a key is placed and
from where a control reads its new value, so a replay lands in the same place. A Launch Control button becomes a
`press` at each press; other controls and the Launchkey mod wheel and knobs become `cc` / `lk` steps, cut into gestures
and thinned with Ramer-Douglas-Peucker (tolerance 1 MIDI step) into `ramp` steps; keys become one `keys` step per
note (note-off as `length`), drum pads 36-51 `pad` steps with their `velocity`. Controls the track does not have and
other Launchkey CCs are dropped.

**Replay:** pick the take in the Auto-perform list and Start. The performer sets the take's bar-0 values before the
load, the load restarts the clock, and the steps play into the virtual inputs, so the track does what your hands did.
What you play on top is captured as well (last moved wins). A tab in the background throttles its timers to 1 s and
spoils a capture or a replay; keep the player visible.

**Keeping a take:** move it from `takes/` up to `perform/<track>/`, give it a name and a title, run `check-perform`
and commit it.

**Replay fidelity.** Save the replay as a take as well: it names its original (`take.script`), and saving answers
with the verdict in the sidebar. `node trajectory/check-replay.mjs <track> [takes/<replay take>]` (Tools: Check replay
fidelity) compares the events of every replay take with those of its original, bar by bar, and lists each differing
bar with a reason: `value` (a control read another value, one MIDI step off is expected on thinned ramps), `timing`
(a key, press or move landed one query off) or `only` (an event of one play with no partner: button state, level or
randomness). Takes with no events, no replay or no original are listed as such. Exit code 1 when a replay differs.

**Takes on SuperCollider tracks:** the capture still hears the controllers in the page (Web MIDI; SC gets the same
MIDI straight) and the script (the SC output posts each step as the virtual port's message); the bar comes from SC's
clock. SC starts every load from 0, so the bar-0 snapshot is only what the load set, never a hardware position. The
take's events are SC's state echoes, one batch per bar (`sc-auto.mjs` `createScTap`): controls (in steps of 4 MIDI
steps), Launchkey controls, pattern choices and head line, and the keys and pads of each bar; the server fills in the
sha1 of the `.scd` file as `trackHash`. `check-replay` compares them like Strudel's events.

### Help panel

Every page has a **Help** button (key **?**) that opens a collapsible panel on the right (open by default): what the page does, its input
and output, how to use it. Closing it is remembered. A new page calls
`mountHelp(sections)` from `help.mjs`.

### Strudel.cc

A Strudel track file plays on strudel.cc as it is; the player adds nothing to it. The repo holds none any more (git history). To see the visuals of a track that
plays on strudel.cc, put the tapped code on the clipboard (macOS) and paste it into strudel.cc next to the player:

```bash
cd tools && node trajectory/make-tapped.mjs <track.strudel>
```

Strudel is deprecated; every Strudel track was removed from the repo.

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
 strudel.cc / player ──server.mjs──► strudel-source.mjs ─► trajectory (lines) ─► render.mjs ─► canvas
        (tapped in memory, make-tapped.mjs)
```

The lines have one format; the renderer does not know where the music comes from (the audio analysis that also wrote
it was retired on 2026-11-20):

```
{"t":12.533,"stem":"bass","x":-0.12,"y":0.31,"z":0.20,"e":0.72,"on":1}
{"t":12.533,"pulse":{"bpm":140,"phase":0.25,"density":0.6,"swing":0.04}}
```

`x` pan −1…1 · `y` pitch log 20 Hz–20 kHz → 0…1 · `z` depth (audio: L/R decorrelation; Strudel: `room`) ·
`e` energy 0…1 · `on` onset · `pulse` tempo, bar phase, density (share of filled 16ths in the last bar), swing.

| File | Job |
|---|---|
| `render.mjs` | picture. "deck" (default, like slide 6 of the deck): glowing comets with tails, rings from the kick, axes. "ocean": stems as liquid layers, time into depth, floating camera. "clean": comets, rings |
| `smoothing.mjs` | slider Raw ↔ Smooth: moving average, window grows exponentially up to 2^53 lines |
| `strudel-source.mjs` | Strudel events → lines, each event appears when it sounds (`delay`) |
| `make-tapped.mjs` | `tapSource(src, name)`: every stem gets its readable name from the track (`@col` column name, Jojo's column 8: the name of its Pattern button, `stemLK` = Launchkey) as `.tag()`, the master sends via `.onTrigger` (sound unchanged); also a CLI that copies the tapped code to the clipboard |
| `server.mjs` | `/` player, static pages, `/catalogue`, `/track/<id>` (tapped on request), `/perform/<track>/<script>`, `/take/<track>`, `/recording/<track>`, relay POST `/events` → SSE `/stream`; CORS and private-network headers on the relay for strudel.cc |
| `player.html` | the player page: loads a track through the engine, the sidebar, the Live / Labs panel (the track's LC view in an iframe), the visuals (`render.mjs`) and the Settings view |
| `pages.mjs` | the pages (Live, Labs with Samples / Stems & Tracks / Sets, Visuals): pickers, `data-pages` matching, URL hash; test `pages.test.mjs` |
| `engine-strudel.mjs` | everything Strudel: `initStrudel`, sample banks and `gm_*` soundfonts, evaluate, stop, `cycle()` (the cycle the scheduler queries next), the `midin` / `midikeys` shims |
| `midi.mjs` | Web MIDI: ports map, last value per CC, key queue, virtual `LCXL3 Auto` and `Launchkey MK4 25 Auto` ports |
| `autoperform.mjs` | the script player (script v2: LC, keys, pads, Launchkey CCs) and the sidebar section |
| `take.mjs`, `take-save.mjs` | the capture of a play's MIDI input and its conversion to a take script; `POST /take/<track>` writes the take and its events |
| `recorder.mjs`, `recorder-worklet.js`, `recording.mjs` | the audio recorder in the page (master bus tap, PCM worklet) and the server side that writes the WAV and sidecar |
| `record-arm.mjs` | the rules of the Record switch: when to start or stop recording, how the button looks |
| `replay-check.mjs`, `check-replay.mjs` | replay fidelity: the pure event comparison and its CLI |
| `check-recording.mjs` | end-to-end test of the recording endpoints |
| `settings.mjs` | every general setting as data, in groups; builds the Settings sections and the keys |
| `catalogue.mjs` | scans live tracks (Strudel and SuperCollider, field `engine`) and lab boards, their auto-perform scripts |
| `sc-source.mjs` | SuperCollider notes (SSE `notes`, sent by `sc/lib/steps.scd` when each note sounds) → lines |
| `engine-sc.mjs` | the SuperCollider engine in the page: load / stop over `/sc/…`, `cycle()` from SC's beats, no audio output in the page |
| `sc-auto.mjs` | auto-perform and takes on SC: the performer's output to SC (`/sc/cc`, `/sc/lk`, bar 0 with the load) and the per-bar state tap for takes |
| `sc-link.mjs`, `osc.mjs` | the server's link to SC: starts `sc/engine.scd`, OSC on UDP 57131 (SC's own server on 57140, not the IDE's 57110), `/sc/` routes and live state for the pages |
| `help.mjs`, `ui.css`, `theme.mjs` | the Help panel; the look (colour tokens per style and tone); the Theme switch |
| `banks.mjs` | sample banks and soundfonts the player loads, as strudel.cc does |

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
silent there (the Strudel sound check was removed with sc-migration 010; SC tracks load their samples from disk).
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
