
## ROUND 9 — reverts two round-8 asks
- Global button 1 is the chapter switch again (dark → tense → warm, starts dark); the drop fill is gone. A harsher
  drop and build-up did not work out yet; it comes back later, with a fresh start.
- Room knob → Thin (the mirror of Fog: every high-pass pushed up); Tension now also raises the reverb.
- Tension's snare roll keeps playing in the break.

## ROUND 8
### GENERAL
- change chapter to F Dunkel fixed
- replace that button with drop fill (idea would be to first turn off beat; then, before bringing it back, you fill the beat; this should be a 'button down' feature: plan with a 16 beat build up; cycle by cycle; at the end of the 16th beat)
- too much melody; not enough techno
- I think needs more fast percussion eleemnts (Klanghözer, shakers, bongos, ride, dark electronic mid&high-frequency stuff)

### BAD
- Bassline --> waaaay too boring; more interesting dark techno line
- Hi-Hat --> should be open and much more crisp (much higher brightness by default)
- Chord pulse --> should be replaced by LKs; replace with nice techno pads
- Lead --> Too EDMy; replace with nice techno sounds
- Pings --> too boring; full remake --> think dark techno
- FX / Breath --> breathing is a good theme; just softer

### GOOD (Change nothing unless specifically addressed)
- Answer
- Sub
- Kicktop button -> instead of cycling through patterns, double-time (so instead of 4/4 -> 8/4 while pressed)
- Clap --> Change default brightness to 90%
- Percussions -> Change default brightness to 65% --> make pan from left to right slowly (no recognizable frequency overlap wth main track)

## SPACE VERSION — 008-groove-techno-space.strudel (2026-11-11)
Merged into 008-groove-techno.strudel after round 2 (knob defaults); the space file is gone.
Plan: 008-space-plan.html, 008-space-implementation.md. Measured with tools/strudel-sim/space.mjs (each stem alone,
fader 1, all knobs 0, master 1, 4 bars; the mix with all faders 1).

| KPI | goal | 008 (before) | space round 1 |
|---|---|---|---|
| K1 mono low end (mix S/M < 120 Hz) | ≤ 0.1 | 0.001 ok | 0.001 ok |
| K2 bass lane ownership (125–350 Hz) | ≥ 40 % | 21 % | 42 % ok |
| K3 competitors in the lane (≥ bass − 10 dB) | ≤ 2 | 6 | 5 (kick, rumble, bongos, sequence, stab) |
| K4 bass width (S/M > 300 Hz / < 120 Hz) | 0.3–0.6 / ≤ 0.05 | 0.00 / 0.00 | 0.35 / 0.04 ok |
| K5 bass − kick | −6 to −3 LU | −3.9 ok | −3.5 ok |
| K7 stems off-centre or wide | ≥ 7 | 5 of 14 | 7 of 14 ok |
| K8 reverb share, back group (pads) | ≥ 0.4 | pad 0.17, techno pad 0.00 | 0.28, 0.22 |

Round 1 changes (beyond the plan values, found by measuring):
- Bass top layer: detuned copies gave no width (short notes stay alike, as in the lab board) → hard left/right copies,
  the right one 12 ms later (Haas), high-pass 200 Hz, gain 1.5 × the core; the core is one saw (no detuned second
  voice); level range 0.6.
- Lane: pad hpf 400, techno pad 350, stab 400 (their chord fundamentals at F3 = 175 Hz sat in the lane), rumble lpf
  100–500 Hz. A sequence hpf did not lower its lane energy: the sequence stays unchanged.
- Width/depth: techno pad saws at 0.1 / 0.5 / 0.9, pad triangle sweeps against the saw, pad and techno pad Space starts
  at 0.3 (a little room at knob 0).
- Unchanged and proved identical (compare.mjs --stem): kick, sub, clap, bongos, ride, sequence, answer.
- Query time +3 %. Not heard yet. Open: K3 (kick and bongos are time-separated, rumble 8.5 dB under the bass), K8
  (pads' Space floor 0.3 → 0.5?).

### Space round 2: knob defaults (2026-11-11)
- New: KNOB_DEFAULTS / LK_DEFAULTS in the space track. A knob that has sent nothing yet reads its default; its first
  value that is not 0 takes over. The LC knobs get their defaults sent once per page load (CC on channel 16), so the
  encoders move on from there. Only in the browser; not yet tried on the hardware.
- Sweeps with space.mjs (each knob that can move a KPI): pad / techno pad Space 0–0.75, bassline Brightness × Groove,
  kick Punch. Result: only the reverb share (K8) responds. Bassline Brightness and Groove change the KPIs by < 1 dB
  (the filter envelope opens every note anyway; 0 keeps the largest lane share), kick Punch 0 is best (0.5 adds 8 dB
  in the bass lane). All other knobs at 0 are already the minimum of what competes with the bass, or move no KPI.
- Defaults set: pad Space 0.5 (wet 0.46), techno pad Space 0.75 (0.42–0.49), LK knob 6 Reverb 0.4 (0.40–0.46).
  Wet shares vary ±0.04 between renders (random oscillator phases and noise).
- Tools: harness.mjs gives the Launchkey its own CCs (vals.lk<cc>) and plays vals.keys on its keys; space.mjs
  --defaults / --keys / stem=lk1.
- Full run (15 stems incl. the LK keys pad with simulated chords, mod wheel full): K1, K4, K5, K7 (8 of 15) ok.
  K2 drops to 8 % and K3 to 6 competitors because the LK pad at full mod wheel is the loudest stem (−14 LUFS) and
  sits on F3 in the lane (lane −20 dB, the bassline −30 dB). No knob lowers that: only code (keys pad hpf 220 → 350 Hz
  like the techno pad, and/or less gain). Without the LK pad K2 stays at about 41 %.
