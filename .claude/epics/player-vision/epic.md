---
name: player-vision
status: backlog
created: 2026-11-16T10:00:00Z
updated: 2026-11-16T14:00:00Z
progress: 0%
prd: .claude/prds/player-hub.md
github: (will be set on sync)
---

# Epic: player-vision

## Overview

Split off from `player-hub`. `player-hub` builds the player as it is needed now; this epic is thinking, not code.
It answers where the player might evolve and writes the answer down as `docs/player-future.md` (the file the player-hub PRD names for the evaluation, FR7). The
two-line `VISION.md` at the repo root is not useful and is deleted in the same task; `tools/trajectory/README.md`
points to a "MUSIC ARCHITECTURE" section in it that never existed, so that link moves to `docs/player-future.md`, where
the section is written.
No code in this epic. A vision that needs code to be tried (a prototype of a measurement tool, say) becomes a
slice in a later epic.

## Deliverable

`docs/player-future.md`, written for the player and for us deciding what to build next:

- The direction in a few sentences: beginners enter easily, experts work at the next abstraction level.
- Per idea: what it is, what exists in the repo, what is missing, risks, first slice, rough effort, and its
  touchpoints with the engine seam (including a SuperCollider engine). Ideas: LLM edits from the UI, auto-perform
  beyond the open-loop script player (meta-steering and the measurement it needs; the script player itself is built
  in `player-hub`, task 9), producer mode (with its four inputs), and the music
  architecture (trajectory: pan, frequency, time) the trajectory README refers to.
- How the ideas build on each other (measure → map → steer; the virtual port shared by auto-perform and producer
  mode; one song model).
- A recommendation: which idea first, which slice, and what to leave out.

## Tasks

1. **Collect and sharpen the ideas** — go through the source material below and the player-hub PRD; talk through
   open questions with the user (which idea matters most, what a beginner and an expert each do with it).
2. **Write `docs/player-future.md`** — structure above; English, plain words, short. In the same task: delete
   `VISION.md`, and repoint the link in `tools/trajectory/README.md` to the MUSIC ARCHITECTURE section of the new file.
3. **Review with the user** — fix what is off, pick the first slice; if it becomes work, open a new epic for it.

## Success Criteria

- `docs/player-future.md` exists and covers every idea above with the fields listed; `VISION.md` is gone and
  nothing links to it.
- It ends with a recommendation naming one first slice.
- The README link to the MUSIC ARCHITECTURE section points to `docs/player-future.md` and works.

## Estimated Effort

3 tasks, one session, all with the user.

## Source material: first take on the ideas

| Idea | What exists | Needs | First slice | Gut effort |
|---|---|---|---|---|
| LLM edit from UI | `@ctl` comments name every control; LC view knows CC → name; tracks reload from source on request | click target → `{track, ctl, code range, current value}`; a chat panel that shows what is selected and how it is set now, keeps the conversation, and shows each change (diff + new value) before it plays; server endpoint calling `claude -p` (session kept per chat) on a new track file (non-destructive rule); hot reload without stop | Click a knob in LC view → panel shows control name, its code and current CC value → chat → Claude writes `NNN-<name>-v2.strudel` → player offers it, chat continues on v2 | M |
| Auto-perform (beyond the script player) | The script player and its virtual port (`LCXL3 Auto`, JSON timeline in bars, human grabs by last-moved) are built in `player-hub` task 9; the spike report is `.claude/epics/player-hub/auto-perform-spike.md` | meta-steering (closed loop on measured output) or an LLM agent per phrase, both writing into the same virtual port | `meta.mjs` measurement series, then energy curve → timeline | M (measure) / L (AI) |
| Producer mode | chapters per track, set frame for sections in sequence, Tension / Break; lab boards per role (bass, harmony, melody, guitar …) to pick sounds from | one intermediate song model (tempo, key, metre, sections, parts with notes and chords) that every input fills and one generator turns into a one-file track; a timeline that drives chapter / tension per section | Song form as JSON → timeline of chapter + Tension moves on an existing track (reuses the script player of `player-hub` task 9) | L |

Producer mode inputs (each fills the same song model, then the same generator writes `NNN-<name>.strudel` in the
one-file layout, non-destructive):

| Input | Example | Parse | Gap / risk | Gut effort |
|---|---|---|---|---|
| Song form + genre | indie pop: 8-bar intro, verse 1, chorus, verse 2, chorus, outro | LLM or hand-written JSON | no melody given: generator must invent parts | M |
| Note sheet | MusicXML / MIDI export, ABC; scanned PDF or photo | MusicXML / MIDI / ABC parse directly; PDF or photo needs optical music recognition (e.g. Audiveris) or an LLM reading the image | recognition errors on scans; repeats, voltas and D.S. must be unrolled into sections | M (digital) / L (scan) |
| Popular song name | Rudolph the Red-Nosed Reindeer | LLM recalls melody, chords, form as ABC or JSON; user corrects by ear | recall is often wrong in detail (rhythm, bridge); copyrighted songs fine to play at home, not to publish | S–M |
| Guitar Pro file | `.gp3`–`.gp5`, `.gpx`, `.gp` | alphaTab (JS) reads tracks, tempo, metre, notes, bends, palm mute, drum kit | one GP track → one stem by instrument; tab techniques have no Strudel equivalent (bends → pitch glide at best); drums map GM → bank | M |

Auto-perform ideas:

| Idea | What it means | Parse | Gap / risk | Gut effort |
|---|---|---|---|---|
| Meta-steering | The performance is steered by a target trajectory. High-level: "low-energy intro, slow curious build to 3:00, high energy 3:00-7:00, 1 minute gradual breakdown". Concrete: an energy curve or keyframes (time → energy, plus optional Fog / Tension / chapter targets) | LLM or hand-written JSON turns the brief into an energy curve over time | "energy" must map to controls per track (Tension, Brightness, Fog, chapter, Break) and sound plausible at each point; the curve must be tied to bars, not wall-clock time, so tempo changes do not drift | S (curve → timeline) / M (LLM brief → curve) / L (closed loop) |

Meta-steering levels, each built on the one before:

1. **Open loop:** the curve is sampled per bar and written into the virtual port as CC moves (the script player,
   built in `player-hub`). A fixed energy → control map per track; the human can still override by last-moved.
2. **Closed loop:** the player measures the real output (per-stem loudness, event density, brightness from the
   analysis tap) and nudges controls until the measured energy follows the curve, so the same curve works on any track.
3. **Agent:** an LLM per phrase reads the trajectory, the measured state and the control names (`@ctl`), then picks
   the next moves; it may also replan when the human grabs a control.

Meta-steering needs measurement first: a controller can only follow a curve it can read. Order of work:
measure, then map, then steer.

| Meta quantity | Measured from | Exists | Gap |
|---|---|---|---|
| Energy | summed band energy `e` + loudness (LUFS, short-term) | `trajectory/analyse.mjs` bands, per-stem loudness tool | one smoothed, bar-quantised energy number per track; calibrated 0..1 so "low" and "high" mean the same across tracks |
| Density / activity | onsets per bar, active stems (`on`, `pulse.density`) | `analyse.mjs` pulse | per-stem and total count per bar |
| Brightness | spectral centroid, share of `presence` + `air` | `analyse.mjs` y per band | one global value |
| Space / width | L/R decorrelation `z`, pan spread | `analyse.mjs` x, z | one global value |
| Tension / build | slope of energy and brightness over the last bars, rising filter, riser layers | nothing | derived from the series above; define "building" as a sustained positive slope |
| Section / phase | position in the trajectory, chapter and Break state of the track | chapter control via `midin` | read the current chapter and Break back from the track |
| Control response | what energy one control step changes, per track | nothing | a sweep tool: move one CC, measure, write a per-track map (control → effect on each quantity) |

Slices: (1) a `meta.mjs` module on top of `analyse.mjs` that turns frames into one series per bar (energy, density,
brightness, width, slope), usable live in the player and offline on a rendered file (`analyse-file.mjs`);
(2) show the series as a curve with the target curve over it, so a performance can be judged by eye before any
steering exists; (3) the sweep tool that builds the control map; (4) only then closed-loop steering. Risk: the
measure must be fast enough to follow bar by bar and stable (smoothing, no jitter), else the loop chases noise.

Shared risks: arrangements need rhythm per stem (house rule: no held notes only) and every knob at 0 must already
sound good, so the generator writes a playable layout, not just notes; CPU for many parts (gate as in the set).
