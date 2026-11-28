# Auto-perform script format v2 (scripts and takes)

Agreed in task 1 (spike). Tasks 4, 5 and 6 build on it. v2 is the format `autoperform.mjs` already reads (merged
with the auto-performances epic: `keys`, `pad`, `lk` steps and the virtual Launchkey) plus three additions: a
`velocity` on pad steps, the `take` meta field, and the bar tolerance. No new step kind is invented for keys or
Launchkey CCs: the Launchkey CC tag is the `lk` field, not `input: 'lk'`, so there is one spelling per job.
Every v1 script stays valid and plays exactly as before.

## Script

```
{
  track:    string             required, the catalogue id ('010-ambient-house'); must equal the folder name
  title?:   string
  bars?:    number > 0         length; steps and sections must end by it
  mood?:    string
  sections?: [{ name, from, to, intent? }]      bar ranges [from, to), in order, not overlapping
  take?:    Take               present only in a take (see below); a script without it is hand-written
  steps:    Step[]             any order; the performer sorts by bar
}
```

`bar` everywhere: bars of the playing track counted from the load (1 cycle = 1 bar in every live track), a float
≥ 0. Hand-written scripts use readable values (4, 7.5); takes keep the clock's value rounded to 4 decimals.

## Steps

| Kind | Shape | Input | Range / default |
|---|---|---|---|
| LC control | `{ bar, cc, value, ramp? }` | `LCXL3 Auto` | `cc` a control of the track's `@ctl` tags; `value` 0..1; `ramp` > 0 bars from the value at `bar` |
| LC button | `{ bar, press }` | `LCXL3 Auto` | `press` a button CC of the track; held 2 scheduler ticks |
| Keys | `{ bar, keys, velocity?, length? }` | `Launchkey MK4 25 Auto`, channel 1 | `keys` note names or MIDI numbers, space-separated ('c3 e3 g3', '60'); `velocity` (0..1], default 0.8; `length` > 0 bars, default 1 |
| Pad | `{ bar, pad, velocity? }` | `Launchkey MK4 25 Auto`, channel 10 | `pad` note 36-51; `velocity` (0..1], default 0.8 (**new in v2**) |
| LK control | `{ bar, lk, value, ramp? }` | `Launchkey MK4 25 Auto`, channel 1 | `lk` 1 (mod wheel) or 21-28 (knobs); `value` 0..1; `ramp` as above |

A step has exactly the fields of its row (check-perform refuses others). The kind is decided by the field present, in
this order: `keys`, `pad`, `lk`, `press`, else `cc`.

- `length` of a keys step only times the note-off seen by the LC view: `midikeys` has no note-off, the sound length is
  the track's. A take writes it from the recorded note-off when one came (rounded to 0.01 bar), else leaves it out.
- `velocity` is sent as MIDI `max(1, round(v × 127))`; takes write `byte / 127` rounded to 3 decimals.
- A take writes one keys step per note-on (no chord merging), note names with `#` ('c#4').

## Virtual inputs

- `LCXL3 Auto` (`midi.AUTO_PORT`): CC on channel 16, read by every nameless `midin()`.
- `Launchkey MK4 25 Auto` (`midi.LK_AUTO_PORT`): contains the name the tracks look up (`'Launchkey MK4 25'`), so
  `midin` / `midikeys` hear it as a second Launchkey; left out of nameless lookups like the real one. In the ports
  map only while the script has Launchkey steps (`usesLaunchkey`). Both are also in the wrapped
  `navigator.requestMIDIAccess` (LC view). Not `Launchkey Auto`: that name would not match the tracks' lookup.

## On SuperCollider tracks

The same scripts and takes play on SC tracks (sc-migration 004), unchanged. Instead of the virtual inputs the steps go
to SC through the player's server (`sc-auto.mjs`): LC control / press → `/ce/cc`, LK control → `/ce/lkcc`, keys and
pads → `/ce/lknote` (note, velocity byte, channel 0-based: 9 = pads; no note-off, `length` only reaches the take).
Bar 0 is sent with the load and set before the first note. `bar` follows SC's clock (`engine-sc.mjs` `cycle()`, from
`/ce/beat`, when the beat sounds). A take of an SC play has `trackHash` = sha1 of the `.scd` file and keeps SC's state
echoes per bar as its events (stems `sc cc`, `sc lk`, `sc state`, `sc keys`).

## Bar tolerance (performer)

A step fires on the first performer tick where `step.bar <= bar + 1e-6`, with `bar = engine.cycle() - startBar`.
The tolerance absorbs the 4-decimal rounding of take bars; hand-written bars are unaffected.

## Take meta

```
take: {
  source:     'human' | 'auto' | 'mixed'   inputs heard: real ports only, virtual only, or both
  recordedAt: string                       ISO time of the load the capture started at
  trackHash:  string                       sha1 (hex) of the track file text the take was played on
  cps:        number                       the scheduler's cps at bar 0
  inputs:     string[]                     port names heard, e.g. ['LCXL3 1 MIDI In', 'Launchkey MK4 25 MIDI In']
  script?:    string                       the auto-perform script id that played, when source is not 'human'
  events?:    string                       file name of the tapped events of the original play (task 7)
}
```

`title` of a take defaults to `Take <recordedAt local time>`; `bars` = last step bar (+ ramp/length) rounded up.

## Take conversion (task 6)

- Bar 0 snapshot: every CC value the ports hold at the load (`midi.mjs` keeps values moved before Play; the virtual
  ports hold a primed script's bar 0 when the play is a replay, task 7) becomes a `cc` / `lk` step at bar 0.
- Capture bar = `engine.cycle()` at message arrival minus the load's start cycle (0 after a fresh load). That is the
  scheduler's `lastEnd`, the start of the next query, which is exactly where `midikeys` places the key and from where
  a `midin` signal reads the new value; replaying at that bar lands the same place.
- CC on a button (`controlsOf(...).button`) → `press` at the value-127 message (value 0 dropped); other LC CCs → `cc`
  steps thinned with Ramer-Douglas-Peucker (tolerance 1/127) into `ramp` steps; LK CC 1 / 21-28 → `lk` steps, same
  thinning; other LK CCs dropped. Note-on channel 10, notes 36-51 → `pad`; other note-ons → `keys`.

## Files

| File | Content |
|---|---|
| `tools/trajectory/perform/<track>/takes/<YYYY-MM-DD>-<HHMMSS>-<source>.json` | the take (a script with `take`) |
| `tools/trajectory/perform/<track>/takes/<same name>.events.jsonl` | tapped events of the play, one batch per line as posted to `/events`, `cycle` counted from the load's bar line (task 7) |
| `recordings/<track>/<YYYY-MM-DD>-<HHMMSS>-<human\|auto>.wav` | audio, 16-bit PCM, context sample rate, stereo |
| `recordings/<track>/<same name>.json` | audio sidecar (below) |

Audio sidecar:

```
{
  track: string, trackHash: string, source: 'human' | 'auto',
  script: string | null,          auto-perform script id
  take: string | null,            take file name, when the recording was a take replay
  startCycle: number,             engine.cycle() at the first sample, 4 decimals
  cps: number, sampleRate: number, channels: 2, bitDepth: 16,
  startedAt: string,              ISO time
  seconds: number,                length written
  endedBy: 'stop' | 'script-end' | 'unload'
}
```

Names are made by the server; the page only sends the track id (checked against the catalogue) and the source.
