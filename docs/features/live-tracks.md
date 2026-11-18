# Live tracks

## What it is

A live track is one Strudel file you play like an instrument. Strudel is a language for music code that runs in the
browser. The tracks are 007 ambient, 008 groove techno, 009 house and 010 ambient house, in `tracks/`. Each part of
the sound (kick, bass, pad, keys and so on) is a column of controls on the controller.

## When to use it

- To perform: raise parts in, shape them, and build a set by hand.
- To play with a friend: one plays the foundation, one the colour.

## How

Open a track in the [player](player.md) and press Play. Everything starts quiet. Raise the master fader in column 8.

**Two pages.** Mode 1 is the foundation: the beat and the bass, on columns 1 to 7. Mode 2 is the colour: chords and
melodies, on columns 1 to 7. Column 8 is global on both.

**Every column has the same rows:**

| Control | Name | What it does |
|---|---|---|
| Knob row 1 | Brightness | dull to bright. In audio terms: a filter. It cuts the high tones (dull) or lets them through (bright). |
| Knob row 2 | Space | dry to roomy. Reverb is the sound of a room, a delay is an echo. |
| Knob row 3 | named for the column | for example Length, Complexity, Octave. Its label says what it does. |
| Fader | Level | how loud this part is. |
| Button 1 | Pattern | the next pattern, at the next bar. On a harmony column it is called Chords. |
| Button 2 | named for the column | a moment while held, for example Drop, Riser, Echo throw. |

**The global column (column 8):**

| Control | Name | What it does |
|---|---|---|
| Knob 1 | Fog | clear to muffled: all low-passes down (all high tones fade). |
| Knob 2 | Thin | full to thin: all high-passes up (all low tones fade). In 007 this knob is Room. |
| Knob 3 | Tension | a build-up: echo, reverb and open filters; the top adds a snare roll. |
| Fader | Master | volume of everything. In 008 it is called Wumms: more low end and punch. |
| Button 1 | Chapter | the next mood or chord progression, at the next bar or phrase. |
| Button 2 | Break | first press: the low end goes out. Second press: all back on the one. |

Each control's own text is on the LC display (after loading the `.syx` files) and in the layout sheet PDF. A good way
to start: raise the master, bring in the kick or the pad, turn Brightness and Space, press Pattern.

## Good to know

- All knobs at 0 must already sound good. Start there.
- Pattern changes happen at the next bar, so a press always lands on the beat.
- Tracks 012 and 013 are different: songs from Guitar Pro. See [producer mode](producer-mode.md).
- Each live track is one file. Edit that file; do not make copies. A new version goes into a new file.
- The same file plays on [strudel.cc](strudel-cc.md) as well.

## Related

- [Controllers](controllers.md), [player](player.md), [auto-perform](auto-perform.md)
- [Layout sheets](layout-sheets.md), [sets](sets.md)
- [Glossary](../reference/glossary.md)
