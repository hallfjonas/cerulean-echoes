# Where the player could go

Draft. Written from the repo and the epic notes; the open questions at the end are not yet answered by the player.

## Direction

The player (`tools/trajectory/player.html`) should let a beginner make music on day one and let an expert work one
level above single knobs. A beginner picks a track, presses Play and moves faders that already sound good at 0. An
expert says what the music should do (a build, a breakdown, a new section, a song to play) and the player turns that
into control moves or into a new track file. The track file stays the single source of truth and still plays on
strudel.cc; the engine stays swappable behind the seam in `engine-strudel.mjs`.

The engine seam today: `createEngine(midi)` returns `{ ready, load(code), stop(), cycle() }`; controller input lives
in `midi.mjs` (ports map, last value per CC, the virtual `LCXL3 Auto` port). A SuperCollider engine would implement
the same four calls and read the same `midi.mjs`.

## The ideas

### 1. LLM edits from the UI

**What it is.** Click a control in the LC view, see its name, its code and its current value, then ask in a chat
panel for a change ("make the hats darker when Brightness is low"). Claude writes a new track file, the player shows
the diff and offers to play it; the chat goes on with the new version.

**What exists.** `@ctl` comments name every control; the LC view knows CC → name; the player taps the file on every
load (`/track/<id>`), so a new file plays at once. The server already runs a fixed list of commands (`tools.mjs`).

**What is missing.** A click target → `{track, ctl, code range, current value}`; a chat panel with diff and new value
before it plays; a server endpoint that calls `claude -p` with a session per chat; writing a new file
(`NNN-<name>-v2.strudel`, non-destructive rule); reloading without Stop, so the music does not break.

**Risks.** The edit can break the layout rules (knobs at 0 must sound good, CPU gates, `@shared` blocks); every
version must pass `npm run verify` before it plays. A server that runs `claude` is a new kind of endpoint: it must
stay on 127.0.0.1 and write only new track files. Many `-v2`, `-v3` files pile up.

**First slice.** Click a knob in the LC view → a panel shows control name, its code lines and the current CC value.
No chat yet. This alone helps a beginner learn what a knob does.

**Effort.** M (panel S, chat with Claude and new file M, hot reload M).

**Engine seam.** Needs `load(code)` without a gap (or a `swap(code)` call). The code-range lookup reads the track
text, not the engine, so it works for any engine that plays Strudel code; a SuperCollider engine would need its own
source format and its own lookup.

### 2. Auto-perform beyond the script player

**What it is.** The open-loop script player is built (`autoperform.mjs`, scripts in `perform/<track>/*.json`); the
`auto-performances` epic writes one designed performance per track. Beyond that: **meta-steering**, where a target
curve ("quiet intro, slow build to 3:00, high energy to 7:00, one-minute breakdown") drives the controls.

Three levels, each on the one before:

1. **Open loop:** the curve is sampled per bar and turned into script steps through a fixed per-track map
   (energy → Tension, Brightness, Fog, Chapter, Break).
2. **Closed loop:** the player measures what it plays and nudges controls until the measured energy follows the
   curve, so one curve works on any track.
3. **Agent:** an LLM per phrase reads the curve, the measured state and the `@ctl` names, picks the next moves, and
   replans when a human grabs a control.

**What exists.** The virtual port and last-moved-wins (a human can take any control); bar-based steps on the engine
clock; `analyse.mjs` (bands, pan, depth, onsets, tempo) and `analyse-file.mjs`; the per-stem loudness tool
(`npm run audibility`, `measure`); the scenario tool (`npm run scenario`) to play a script offline.

**What is missing.** Measurement first. A `meta.mjs` that turns analysis frames into one series per bar:

| Quantity | From | Gap |
|---|---|---|
| Energy | band energy + short-term loudness | one smoothed number per bar, 0..1 on the same scale for every track |
| Density | onsets per bar, active stems | per-stem and total count per bar |
| Brightness | centroid, share of presence + air | one global value |
| Width | L/R decorrelation, pan spread | one global value |
| Build | slope of energy and brightness over the last bars | define "building" as a sustained rising slope |
| Section | chapter and Break state | read them back from the track |
| Control response | one control moved, effect measured | a sweep tool that writes a per-track map |

**Risks.** The measure must be fast and stable per bar, or the loop chases noise. "Energy" may not feel the same
across tracks even when the number matches. The curve must be tied to bars, not seconds.

**First slice.** `meta.mjs` on top of `analyse.mjs`, live and offline; then draw the series as a curve with a target
curve over it, so a performance can be judged by eye before anything steers.

**Effort.** S (curve → script steps), M (measurement and curve view), L (closed loop), L (agent).

**Engine seam.** Steering writes only into `midi.mjs` (the virtual port), so it works with any engine. Measurement
reads audio, so it needs a tap on the engine's output: today Web Audio in the browser; a SuperCollider engine would
have to send its levels or audio back (OSC or a loopback device).

### 3. Producer mode

**What it is.** The player turns a song description into a new one-file track (`NNN-<name>.strudel`, one-file layout,
every controller optional). Four inputs fill one song model (tempo, key, metre, sections, parts with notes and
chords); one generator writes the track from that model.

| Input | Parse | Risk | Effort |
|---|---|---|---|
| Song form + genre ("indie pop: intro, verse, chorus …") | LLM or hand-written JSON | no melody given: the generator invents parts | M |
| Note sheet (MusicXML, MIDI, ABC; scan or photo) | parse digital files directly; scans need music recognition (e.g. Audiveris) or an LLM reading the image | recognition errors; repeats and D.S. must be unrolled | M digital / L scan |
| Song name ("Rudolph the Red-Nosed Reindeer") | LLM recalls melody, chords, form as ABC or JSON; the user corrects by ear | recall is often wrong in detail; copyrighted songs fine at home, not to publish | S–M |
| Guitar Pro file | alphaTab (JS) or a MIDI export | tab techniques (bends, palm mute) have no Strudel twin; GM drums → banks | M |

**What exists.** Chapters per track; the set frame plays sections in sequence; Tension and Break; lab boards per
role (bass, harmony, melody, guitar …) to pick sounds from; the template `midi-layouts/templates/dual-lc.strudel`.
The producer mode builds the Guitar Pro path: a MIDI reader, the hand-built pilot 012 and a converter (`npm run producer`,
`tools/producer/`, `/producer`) that generated 013. Its map file is the first real source of the song model.

**What is missing.** The song model as a written format; the generator (song model → playable layout, not just
notes); a timeline that moves Chapter and Tension per section.

**Risks.** A generated track must follow the house rules: rhythm in every stem, knobs at 0 sound good, CPU gates.
A song with many parts can be too heavy for the browser. Without a melody (song form input) the result may sound
generic.

**First slice.** Song form as JSON → an auto-perform script of Chapter and Tension moves on an existing track (reuses
the script player). No new track, but the form is already heard.

**Effort.** L for the whole; the first slice is S.

**Engine seam.** The generator writes Strudel code, so it is tied to the Strudel engine. If a SuperCollider engine
comes, the song model is the part that carries over; the generator would need a second back end.

### 4. Music architecture (trajectory)

**What it is.** Every voice of a track has, at every moment, a place in space: left/right (pan), low/high
(frequency), and a place in time (tempo, rhythm, groove, the dialogue between voices). The player measures this path
(trajectory), saves it and animates it live. Later: emotions, from audience feedback (a crowd tap button as a first
step).

**What exists.** All of the trajectory tool: `analyse.mjs` (audio → lines), `strudel-source.mjs` (exact stems from
Strudel events), the line format (`x` pan, `y` pitch, `z` depth, `e` energy, `on`, `pulse`), `render.mjs` (deck,
ocean, clean), JSONL recording. The `vis-live-mapping` epic makes the dots follow the live sound (filter moves y,
loudness sets size).

**What is missing.** A number for "good architecture" (the README's idea: separation × anchor × movement, shown in
the picture); playback of recordings; the crowd tap; a link from what is seen back to the controls.

**Risks.** Bands are not stems: audio analysis mixes voices (the sub of the bass lands in the kick band); only the
Strudel path is exact. A score for "good" may reward the wrong thing.

**First slice.** A per-bar separation number (how far apart the stems sit in pan and pitch) from the Strudel path,
shown in the corner of the picture.

**Effort.** M for the number, L for audience feedback.

**Engine seam.** The visuals read lines, not the engine. The Strudel path taps events (`.onTrigger`), so another
engine must send the same lines (stem, pan, pitch, energy) or the audio path is used.

## How the ideas build on each other

- **Measure → map → steer.** The trajectory numbers (idea 4) and `meta.mjs` (idea 2) are one measurement layer.
  The control map (sweep tool) sits on it, steering sits on the map. Nothing steers what it cannot read.
- **One virtual port.** Auto-perform, the producer-mode timeline and an LLM agent all write into `LCXL3 Auto`, and a
  human always wins by moving a control last.
- **One song model.** Every producer-mode input fills the same model; the generator writes the track and the
  timeline writes the auto-perform script. A meta-steering curve is a song model without notes.
- **One file per track.** LLM edits and producer mode both write new track files and run `npm run verify` before the
  player offers them.

## Recommendation (draft)

Start with measurement: `meta.mjs` (energy, density, brightness, width per bar) with a curve view in the player, run
on the existing 010 performance. It is the base of auto-perform steering and of the trajectory score, it needs no
LLM and no new endpoint, and it lets us judge the `auto-performances` scripts by eye.

Leave out for now: closed-loop and agent steering, scanned note sheets, the SuperCollider engine, and LLM edits
beyond the click-to-inspect panel. Producer mode grows through `tools/producer` and its map file, not a second path.

This pick depends on the questions below.

## Questions for the user

1. Which idea matters most to you right now: LLM edits from the UI, smarter auto-perform, producer mode, or the
   trajectory score?
2. Who is the first user: a beginner who should get sound fast, or you and Jojo as experts on stage?
3. Is the click-to-inspect panel (control name, code, value) worth building on its own, without the chat?
4. Should the trajectory visuals keep a "good architecture" score as a goal, or stay a picture only?
