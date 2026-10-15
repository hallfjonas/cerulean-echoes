# Launch Control XL 3 — Strudel Mapping

## Main layer

| Column | Source | Orbit | Knob 1 | Knob 2 | Knob 3 | Fader |
|---|---|---:|---|---|---|---|
| 1 | Kick | 0 | Punch | Body | Brightness | Level |
| 2 | Bass | 1 | Brightness | Movement | Space | Level |
| 3 | Hats | 0 | Openness | Density | Groove | Level |
| 4 | Clap | 0 | Density | Brightness | Space | Level |
| 5 | Texture | 3 | BPM | Energy | Space | Level |
| 6 | Lead | 2 | Decay | Echo | Space | Level |
| 7 | Lead FX | 2 | Brightness | Feedback | Echo Time | Level |

## Shift layer

Use Shift to access global controls without sacrificing the 8 channel columns.

| Shift + control | Global function |
|---|---|
| Column 1 K1 | BPM |
| Column 1 K2 | Energy |
| Column 1 K3 | Space |
| Column 1 Fader | Master Level |

Other shifted controls: **reserved for future use**.

## Buttons

Reserved for discrete performance controls such as:

- Mute / solo
- Pattern variations
- Fills
- Scenes
- Future performance functions

## Global variables

```js
const bpm = 140
const globalEnergy = 1.0
const globalSpace = 0.0
const masterLevel = 1.0
```

## Orbit structure

- **Orbit 0:** Rhythm — Kick, Hats, Percussion
- **Orbit 1:** Bass
- **Orbit 2:** Lead — Lead + Lead FX
- **Orbit 3:** Texture
