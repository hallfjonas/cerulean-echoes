# 017 LSD FX 3 performance - feedback

017-lsd-fx-3 is 017-lsd-fx-2 (same stems and frame) with a new performance. The starting point is
`perform/017-lsd-fx-2/metal-mix.json` and the user's notes on it.

## Loop 1 / Round 1 - metal-space.md (2026-11-27)
- User: "The LKs are played by human -- don't auto-perform it." Notes on Metal Mix:
  - "increase variability of percussion elements (congas, hats, clap); let their levels slowly drift up and down over
    time, giving each other a bit space here and there; this should be noticable to the active listener but not really
    to the passive listener"
  - "end is taken down well, especially the radio is nice; but the melody at the end is cringe (the four gongs+metal or
    whatever it is)"
  - "generally a tad overloaded throughout the song (too much going on)"
  - "there is a looong phase with focus on chords (stop where clap comes in) --> this should be reduced; instead, give
    the fx more space; this offers an oppertunity to avoid overloading them too much (spread their appearance out more)"
  - "change of chords via btn1 shuold not happen while it is playing; change it while it is not playing, so that it
    will be slightly different the next time it comes back; same for lead; choose pads to fit the chords / lead resp."
  - "the hats and congas should enter more smoothly; I'm thinking a 1-bar break in which some metal sounds still play
    after that break have the hats enter at a solid level; --> same for the congas coming in during/after the keys
    focused part (maybe a 2-bar break)"
  - "clap is too present in section around chords / lead"
- Mapping (Metal Mix bars, 1-based): the melody at the end = Last 221-228 (Metal 0.7 with Rewind held 225-228, the
  figure every bar); the chord phase = Chords 33-48 and Build 49-56 (clap at 57); the hats entry = 9-12; the congas
  after the keys = Rebuild 133; the clap around chords and leads = Build, Drop 65-96 (Claps 0.5).
- Changed: new design `metal-space.md` from `metal-mix.md`. No Launchkey steps at all. Chord phase 24 -> 8 bars
  (33-40), the stab returns at 81-88 with Stab 2, pressed while silent at 44; leads Duo pressed while silent at 70;
  pads get a move per partner (Sink, Line up, Line down), pressed while silent. The fx take turns (table "Where the fx
  play"); only the Final drop has all four, two at 157 and two at 165. Hats land at a solid 0.45 after a 1-bar break
  (bar 8, the metal's Rewind alone); congas in the Rebuild land at 127 after a 2-bar break (125-126). Percussion drift
  (levels, Complexity, 2-bar rests) from 17 to 188. Claps 0.2-0.3 (were 0.5). No Metal Rewind in Groove; the end is
  the radio alone. 232 -> 224 bars (6 min 41 s).
- Decision: again (the design is not approved yet)
