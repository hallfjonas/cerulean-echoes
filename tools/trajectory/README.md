# Trajectory — making music architecture visible

As of: 2026-11-12 · phase 1, prototype · none of this is committed

The idea is in [VISION.md](../../VISION.md) (section MUSIC ARCHITECTURE): every voice of a track has, at every
moment, a place in space – left/right (pan), low/high (frequency) – and a place in the dialogue over time (tempo,
rhythm, groove). This path (trajectory) is measured, saved as a file and animated live. Phase 2 (later):
emotions through audience feedback.

Pitch deck (12 slides, assessment + plan): https://claude.ai/artifact/5gM7MWgHqHCLvk3BveX9AZ

## Start: the player

```bash
cd tools && node trajectory/server.mjs
```

Then open **http://localhost:8766/player.html** in Chrome (not `http://localhost:8766`).

The player plays a track right on localhost (no strudel.cc needed) and shows the visuals right behind it:
every stem with its name, tempo from Strudel's clock.

1. Tap the track (once per track; after that the layout hook or `npm run watch` rebuilds the copy after every change
   to the track; it lands in `trajectory/tapped/` and on the clipboard):

   ```bash
   cd tools && node trajectory/make-tapped.mjs ../tracks/techno/008-groove-techno/008-groove-techno.strudel
   ```

2. Choose the track at the top of the player (all tapped tracks are in the list), **Play**.
3. Play the controllers. Only humans play: every control the track reads through `midin()` comes from the
   connected controllers (Web MIDI, each port on its own as in strudel.cc); a control not moved yet reads 0 (or the
   start value the track gives it). The Launchkey plays along: keys and drum pads (`midikeys`), mod wheel and knobs.
   Without controllers it stays silent: first raise the master fader (column 8).

The track's status box (bottom right) hides while its LC view ("▣ LC big") is open in another window.

**Sliders in the bar** (start values: Hard, Smooth 302 ms):

- **Hard ↔ Soft** (0…1): character of the visuals. 0 = sawtooth crests, angular lines, every past time slice with
  an edge, instant response, camera pushed by the beat; 1 = round waves, thick soft crests, motion smear, sluggish
  following, gliding camera.
- **Raw ↔ Smooth** (0…1): moving average (exponentially weighted) over N = 2^(53·slider) lines on all signals the
  visuals see: 0 = raw, 0.06 ≈ 302 ms, 0.1 ≈ 1.3 s, 0.3 ≈ 34 min, 0.5 ≈ 37 days, 1 = 2^53 (max_int), frozen. Visuals
  only; the sound stays raw.

**Switches and keys** (start values: axes and labels off, beat rings and LC frame on): **A** axes ·
**L** labels (stem names, axis words) · **B** beat rings (the circles from the kick) · **H** LC frame (the frame
around the controller page used last in the LC view) – all four also as checkboxes in the bar.
**F** fullscreen · **V** look (deck / ocean / clean) · **W** pan width on/off. The bar at the top hides after 3 s
without the mouse.

Tap old dual versions through their single version (e.g. `tracks/sets/011-combining-all/011-set-single.strudel`).

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
 strudel.cc / player.html ──server.mjs──┘   strudel-source.mjs              └► recording (JSONL)
        (tapped track, make-tapped.mjs)
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
| `make-tapped.mjs` | copy of a track: every stem gets its readable name from the track (`@col` column name, Jojo's column 8: the name of its Pattern button, `stemLK` = Launchkey) as `.tag()`, the master sends via `.onTrigger` (sound unchanged) |
| `server.mjs` | static files + relay POST `/events` → SSE `/stream`; CORS and private-network headers for strudel.cc |
| `player.html` | plays a tapped track with `@strudel/web` right on localhost and shows it; controllers via Web MIDI (`midin` per port, `midikeys` for Launchkey keys and pads), sliders Hard ↔ Soft, Raw ↔ Smooth; without `gm_*` sounds (see limits) |
| `index.html` | the page: sources, channel choice, recording, keys |

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

`player.html` is meant for visuals and rehearsals, not as a full replacement for strudel.cc.

**Sounds in the player:** Strudel's built-in synths (`sine`, `sawtooth`, `supersaw`, …), dirt samples, drum
machines (909, 808, 727, 707), VCSL, piano and all samples a track loads itself (voices, Rhodes, Steinway).
Controllers: every Launch Control XL 3 and the Launchkey (keys, drum pads, mod wheel, knobs).

**Silent:** General MIDI sounds (`gm_*`). `@strudel/web` (1.2.6 as well as 1.3.0) does not register them; in the
bundle `registerSoundfonts()` is commented out. An event with `gm_*` stays silent, without an error.

| Track | silent in the player |
|---|---|
| 008 | nothing |
| 007 | Launchkey pads: glockenspiel, marimba, choir, "ooh", agogo, tom, vibraphone (Jonas' marimba, toms and glitter play VCSL recordings) |
| 009, 009-riffs | vibraphone, marimba and others; Launchkey: organ and brass stab, "ooh" |
| 010 | Launchkey pads: marimba, glockenspiel, agogo, vibraphone, "ooh" (Jonas' glockenspiel: VCSL; keys: synth pad as in 007) |

For the full sound of these tracks: paste the tapped track into strudel.cc and play; the controllers there are
the same.

**Tried, failed:** attaching `@strudel/soundfonts@1.2.6` to the same `@strudel/web` bundle via an import map (the
exports it needs are all there). It imports `sfumato@0.1.2`, and its `soundfont2@^0.4.0` delivers no
`DEFAULT_GENERATOR_VALUES` through esm.sh; not with `soundfont2@0.5.0` either. The module then does not load, and the
whole page hangs at "loading Strudel …".

**Possible next steps** (recommendation first):

1. **Replace `sfumato` with an empty stub** (a few lines in the import map): `sfumato` is only needed for `.sf2`
   files; the `gm_*` sounds come from webaudiofont data. Small, but prove it in the browser first.
2. **Build our own bundle** (`@strudel/web` + `@strudel/soundfonts` with esbuild in `tools/`): one file, one sound
   registry, independent of esm.sh. Cleaner, but one more build step.
3. **Stay on strudel.cc** for tracks with `gm_*`; the player only for 008 and rehearsals.

## Open (by priority)

1. **Test with hardware:** does Chrome get 4 channels from the Scarlett? The status line says so ("measuring 3/4" or
   "channel 3/4 missing"). If missing: use the Strudel path or a virtual device (BlackHole).
2. **strudel.cc in your own Chrome** with controllers + tapped track (blocked in the browser pane; in Chrome maybe
   allow the "local network" prompt).
3. **Ocean look:** liked? Measure performance in fullscreen (not measured; "clean" was at 1–3 ms per frame).
4. **Tidy up:** `tools/trajectory/tapped/` into `.gitignore`, then commit.
5. **Day 5:** projector rehearsal, KPI "Spatial Trajectory Harmony" (separation × anchor × movement) as a number in
   the picture, crowd tap button (timestamps for audience reactions = starting point of phase 2).
6. **Day 4:** playback of recordings, video export, Demucs (heavy: PyTorch, long compute time on the M2 Air).

Link to the music ([TODO.md](../../TODO.md)): "segment the space" and "build-up across lows/mids/highs" for
008 can be seen and measured directly with the Strudel path.
