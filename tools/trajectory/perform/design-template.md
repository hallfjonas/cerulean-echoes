# Performance design template

One design per track and script: copy this file to `perform/<track>/<name>.md` and fill it in. The user reads it,
corrects it, and says "approved" before any script (`<name>.json`) is written. Names are English and short; controls
are named as in the track's `@ctl` tags (Brightness, Space, Level, Pattern, Fog, Thin, Tension, Master, Chapter, Break).

Feedback rounds go into `perform/<track>/feedback.md` (format at the end of this file).

## Preparing a track

Before the first draft the agent reads, in this order:

1. `cd tools && npm run track-map -- <track>`: outline of the track; then `sed -n` ranges for the parts that matter.
2. The `// @ctl` tags in the track: which control does what, per column.
3. `npm run scenario -- <track> --view`: the LC view as text, to see what a control change does at the default state.
4. The track folder's `feedback.md` (what the user liked or rejected) and `docs/reference/listening-list.md` for the genre.

Every control in a design must exist in the `@ctl` tags; `node trajectory/check-perform.mjs <track>` checks this once
the script exists.

## Design file

```markdown
# <Title>

## Meta
- Track: <NNN-name>
- Length: <N> bars = <M> min at <BPM> BPM
- Mood: <a few words>
- Story: <two lines: where it starts, where it goes, how it ends>
- References: <links from docs/reference/listening-list.md, with what to listen for>

## Sections
| Section | Bars | LC controls (by @ctl name) | Launchkey | Intent |
|---|---|---|---|---|
| Intro | 1-16 | Master 0 -> 0.6 ramp 8; Col 1 Level up | - | Fade in the foundation |
| Build 1 | 17-32 | Tension 0.2 -> 0.7; Chapter press at 32 | pad C1 on beat | Lift into the first drop |

## Risks
- CPU peak: <section, why>
- Clipping: <section, which stems>
- Silent stretches: <bars, intended or not>

## Open questions
- <question for the user>
```

Rules for the table: bar ranges are contiguous and cover the whole length; a control the design never names stays at
0; Launchkey column says keys (notes or chords), pads (note names, drum C1 = 36) or knobs (CC 21-28, mod wheel CC 1),
or `-`; intent is one short phrase.

## Feedback log format

`perform/<track>/feedback.md`. Two loops, each in rounds, newest last. Loop 1 reviews the design, loop 2 the sound
once the script plays in the player.

```markdown
# <Track> performance - feedback

## Loop 1 / Round 1 - <name>.md (YYYY-MM-DD)
- User: "<the user's words, section and bar where possible>"
- Changed: <what changed in the design>
- Decision: again

## Loop 1 / Round 2 - <name>.md (YYYY-MM-DD)
- User: "<...>"
- Changed: <...>
- Decision: approved
- Approval: Design approved by the user on YYYY-MM-DD ("<the words>").

## Loop 2 / Round 1 - <name>.json (YYYY-MM-DD)
- User: "Break 1, bar 48: too long"
- Changed: <step or section edited, new bar numbers>
- Decision: again

## Loop 2 / Round N - <name>.json (YYYY-MM-DD)
- User: "<...>"
- Changed: <...>
- Decision: approved
- Approval: Performance approved by the user on YYYY-MM-DD ("<the words>").

## Lessons
- <what this track taught about section length, control moves, Launchkey use; one line each>
```

Rules:
- Decision is `approved` or `again`. Only the user's own words count as approval; the Approval line quotes them.
- Loop 2 does not start before the Loop 1 approval line exists; nothing is scripted before it.
- Each round names what changed in the files, so a later reader can follow the edits.
- Lessons are written at the end of the loop and feed the next track's design.
