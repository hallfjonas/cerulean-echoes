
## Action Items

## Decisions
- We need SC for live performance

## Open questions
- decide whether to fully switch to SC or keep Strudel alive somehwow
  - how portable
  - power of the language (sound quality and feature support)

## Next Steps
- integrate SC
  - decide whether to fully switch to SC or keep Strudel alive somehwow;
    - think of use-cases (Strudel might be more approachable, no technical hurdle)
    - will SC eventually be better in terms of sound quality?
    - anything else we might be missing
  - launch SC from our UI
  - can SC directly translate or play .strudel files (wihtout latency)
  - data management of samples with SC (should they live in a separate palce outside of repo?)

- sound lab
  - define what a stem is
    - a stem is a fixed full column set up in LC XL 3 including: sample, pattern, three knobs + slider, two buttons for add-ons --> document this
    - a stem can have multiple versions: if two stems are very similar they should be different versions of the same stem (e.g., just one knob replaced)
    - stems should be named as: <sample-name>-<knob-1>-<knob-2>-<knob-3>-<btn1>-<btn2>.stem
    - disgn a stem file format for this (based on json)
    - think if supporting the following makes sense: tags, hierarchical categories, genres, tracks, moods, ...?
  - how to utilize shared stems across tracks
  - stem lab as a full feature in the current software
  - how to design the sound lab in our software
    - Sample Designer (Synthesizer): Build and export a new sample by taking one or multiple sounds and filling up the full LC controls with various filters, patterns, and add-ons.
    - Stem Designer: The 8 (or 16) columns of the LCs should represent different stem versions where each column has a unique set of filters, patterns, and add-ons.

  - Sample Designer, two versions:
    - fixed setup: drum machine, synthesizer
    - LLM support (skill) to arrange something freely
  - Stem Designer:
    - Should be easy to use and set up with LLM support (maybe a skill). For example "I need to re-design the piano stem of the house track", "the flute in the house track is a bit boring and too repetitive, I want to explore a replacement".

  - UI support to swap a stem in a track:
    - click a stem
    - choose from a list of the stem library

  - preliminary definitons of tracks and sets:
    - a track is a unique assignment of stems to the LCs
    - a unique collection of tracks


# Backend
+ Switch to Supercollider to minimize latency

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
- Producer inputs beyond Guitar Pro (see `tools/producer/` and `.claude/prds/producer-slow-rock.md`): song form plus genre, note sheet (MusicXML, MIDI,
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
