
## Action Items

# Backend
+ Switch to Supercollider to minimize latency
- Mono low end and club safety: moved to `sc/PLAN-SOUND-QUALITY.md`, 2.7 (Club output).

# Player

## Features
- auto-perform playback control: jump to a certain chapter by clicking on it; play / pause
- reset to track's default settings (a button, or when a track or an auto-perform starts)

## UI


# Player ideas (not yet planned)

Long text of each idea: `git show 1bd1438:docs/player-future.md`.

- Meta-steering: `meta.mjs`, curve view, control-map sweep, open and closed loop are in epic `auto-perform-steering`.
  Not planned: an LLM agent per phrase that reads the curve and the measured state and replans when a human grabs a
  control.
- Producer inputs beyond Guitar Pro (the producer was removed on 2026-11-27, git history keeps it): song form plus genre, note sheet (MusicXML, MIDI,
  ABC; scans need music recognition), song name recalled by an LLM. Needs a written song model, a generator from
  that model to a one-file track, and a timeline that moves Chapter and Tension per section.
- Trajectory score: a per-bar separation number (stems apart in pan and pitch) from the Strudel path, a "good
  architecture" score, a crowd tap button, emotions from audience feedback, a link from the picture back to the
  controls. The live dots are in epic `vis-live-mapping`.
- SuperCollider engine behind the seam in `engine-strudel.mjs` (`ready`, `load`, `stop`, `cycle`); needs levels or audio
  sent back for measurement (see Backend above).
- Direction: a beginner makes music on day one (Play, faders that sound good at 0); an expert works one level up and
  says what the music should do. Click-to-inspect and LLM edits are in epic `llm-support`.
- Principles: measure, then map, then steer (nothing steers what it cannot read); one virtual port (`LCXL3 Auto`, a
  human wins by moving last); one song model for every producer input; one file per track (edits and generated tracks
  write new files and pass `npm run verify`).
