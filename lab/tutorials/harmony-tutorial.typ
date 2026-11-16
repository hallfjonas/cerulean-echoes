// Handbook for harmony-tutorial.strudel (intervals, scales, modes, chord types, keys).
// Compile: typst compile harmony-tutorial.typ

#set document(title: "Harmony Tutorial: Handbook")
#set page(paper: "a4", margin: (x: 20mm, y: 18mm), numbering: "1")
#set text(font: "Helvetica", size: 9.8pt, lang: "en")
#set par(leading: 0.68em, spacing: 1em, justify: false)
#set heading(numbering: none)
#show heading.where(level: 1): set text(size: 15pt)
#show heading.where(level: 1): it => { pagebreak(weak: true); it; v(0.3em) }
#show heading.where(level: 2): set text(size: 11.5pt)
#show heading.where(level: 3): set text(size: 10pt)
#show raw: set text(font: "Menlo", size: 8.6pt)

#let orange = rgb("#e8891c")
#let blue = rgb("#2b6cb0")
#let lightblue = rgb("#a9cbef")

#let cell-fill = (x, y) => if y == 0 { luma(232) } else { none }
#let tbl(cols, ..cells) = table(
  columns: cols, inset: 4pt, stroke: 0.4pt + luma(170), fill: cell-fill,
  align: left + top, ..cells,
)
#let box-of(color, title, body) = block(breakable: false,
  width: 100%, inset: 8pt, radius: 3pt, fill: color.lighten(85%), stroke: 0.5pt + color.lighten(30%),
)[#text(weight: "bold", fill: color.darken(20%))[#title] #h(0.4em) #body]
#let remember(body) = box-of(blue, "Remember:", body)
#let listen(body) = box-of(orange, "Listen:", body)
#let scene(body) = box-of(rgb("#4a8a3c"), "In techno and house:", body)

// Piano keyboard from C, two octaves. Keys are counted in semitones from that C (A = 9, next A = 21).
// on = light blue, root = dark blue, char = orange.
#let kb(on: (), char: (), root: (), octaves: 2, w: 4.2mm, h: 15mm) = {
  let wpc = (0, 2, 4, 5, 7, 9, 11)
  let fill-for(k, black) = if k in char { orange } else if k in root { blue } else if k in on { lightblue } else if black { luma(35) } else { white }
  let n = 7 * octaves
  let bw = w * 0.62
  box(width: n * w, height: h, {
    for i in range(n) {
      let k = calc.floor(i / 7) * 12 + wpc.at(calc.rem(i, 7))
      place(dx: i * w, rect(width: w, height: h, stroke: 0.4pt + luma(110), fill: fill-for(k, false)))
    }
    for i in range(n) {
      let wi = calc.rem(i, 7)
      if wi in (0, 1, 3, 4, 5) {
        let k = calc.floor(i / 7) * 12 + wpc.at(wi) + 1
        place(dx: (i + 1) * w - bw / 2, rect(width: bw, height: h * 0.6, stroke: 0.4pt + luma(35), fill: fill-for(k, true)))
      }
    }
  })
}
// a scale or chord on A: steps = semitones above A; c = the steps to colour orange
#let onA(steps, c: ()) = kb(
  on: steps.map(s => 9 + s), root: (9, 21).filter(k => steps.map(s => 9 + s).contains(k) or k == 9),
  char: c.map(s => 9 + s),
)
#let fig(diagram, caption) = grid(columns: (auto, 1fr), column-gutter: 5mm, align: horizon, diagram, text(size: 9pt)[#caption])

#let circle-of-fifths = {
  let maj = ("C", "G", "D", "A", "E", "B", "F♯", "D♭", "A♭", "E♭", "B♭", "F")
  let min = ("Am", "Em", "Bm", "F♯m", "C♯m", "G♯m", "E♭m", "B♭m", "Fm", "Cm", "Gm", "Dm")
  let cam = range(12).map(i => calc.rem(i + 7, 12) + 1)
  let c = 38mm
  box(width: 2 * c, height: 2 * c, {
    place(dx: c - 35mm, dy: c - 35mm, circle(radius: 35mm, stroke: 0.4pt + luma(170)))
    place(dx: c - 18mm, dy: c - 18mm, circle(radius: 18mm, stroke: 0.4pt + luma(200)))
    for i in range(12) {
      let a = i * 30deg
      let at(r, body) = place(dx: c + r * calc.sin(a) - 7mm, dy: c - r * calc.cos(a) - 2.2mm, box(width: 14mm, align(center, body)))
      at(30mm, text(10pt, weight: "bold")[#maj.at(i)])
      at(23.5mm, text(6.5pt, fill: luma(110))[#cam.at(i)B / #(cam.at(i))A])
      at(12.5mm, text(8.5pt, fill: blue)[#min.at(i)])
    }
  })
}

// ============================================================
#align(left)[
  #text(size: 22pt, weight: "bold")[Harmony Tutorial]
  #v(-0.5em)
  #text(size: 12pt, fill: luma(90))[Learning to hear intervals, scales, modes, chords and keys, for techno and house]
  #v(-0.3em)
  #text(size: 9pt, fill: luma(110))[Handbook for `lab/tutorials/harmony-tutorial.strudel`]
]

#v(0.5em)
#outline(title: [Contents], depth: 1, indent: 1em)

= How to work with the tutorial

== The idea

You do not learn music theory by reading but by listening: a term like "Dorian" or "diminished" is only understood once you recognise it when it sounds. That is why the tutorial is built like this:

- Every chapter is a *loop* that runs endlessly. There is no time pressure.
- Instead of playing things one after another, there are *sliders*. You set a state, listen to it calmly and then change *exactly one thing*.
- Almost every step changes only *a single note*. So you hear what this note does. That is the core of the method.
- The important note is *orange* in the piano roll.

For each chapter this handbook explains the theory in simple words, gives you concrete listening tasks and says where you find it in techno and house. The comments in the code are a short version of it.

== Controls

+ Open `harmony-tutorial.strudel` in Strudel (strudel.cc).
+ Set `const CHAPTER = 0` at the top to the chapter you want (0 to 12) and evaluate once (Ctrl+Enter).
+ From then on move only *the chapter's sliders*. They appear right in the code, next to `slider(...)`. They act immediately, without evaluating again. The sliders of the other chapters are visible but do nothing.
+ Below the last line the *piano roll* shows the notes played, with names. The notes sit at their real pitch: gaps between two bars show you whether a step is big (whole tone) or small (semitone).
+ The drums run in their own block with the slider `DRUMS` (level, 0 = off). For chapters 0 to 2 it is best to switch the drums off at first.

== How to practise

- *Four to eight bars per setting.* The ear needs a while to accept a sound as "home". Only then do you hear the change.
- *Back and forth.* After a change, always switch back again. The difference shows in the comparison, not in a single state.
- *Sing or hum along.* If you can sing a note, you have heard it. Most important: being able to hum the root at any time.
- *Eyes closed.* Listen first, then check in the piano roll whether you were right.
- *Short sessions.* 20 to 30 minutes, but regularly. A suggestion is at the end (practice plan).

== Note names and symbols

Strudel and the piano roll use *English note names*:

#tbl(
  (auto, 1fr),
  [*Name (Strudel)*], [*Meaning*],
  [B], [the note between A and C (called H in German)],
  [B♭ (in the piano roll `Bb`)], [B lowered by a semitone (called B in German)],
  [F♯ (in the piano roll `F#`)], [♯ = "sharp", one semitone higher],
  [E♭ (in the piano roll `Eb`)], [♭ = "flat", one semitone lower],
  [A3], [the number is the octave. A4 = 440 Hz, A3 = 220 Hz, A1 = 55 Hz],
)

All examples are on the root *A*. That is a typical techno key, and on the keyboard A minor and most modes are easy to see.

In the keyboard pictures in this booklet: *dark blue* = root, *light blue* = note of the scale or chord, *orange* = the note that matters.

#fig(onA((0, 2, 3, 5, 7, 8, 10, 12)), [Example: the A minor scale (A B C D E F G A). Only white keys.])

// ============================================================
= Part A: Hearing distances

== Chapter 0: Root and intervals

*What it is about.* A *note* has a pitch. The smallest step in our music is the *semitone*: from one key to the very next one, whether white or black. Twelve semitones make an *octave*; after that the note names repeat (A3 to A4: double frequency).

An *interval* is the distance between two notes, counted in semitones. This is the most important foundation of all: every scale and every chord is nothing but a choice of intervals above a root. If you hear intervals, you hear harmony.

The *root* (also tonic) is the note that feels like "home". In the chapter a *drone* (a note that sounds all the time) holds the A. Above it the lead alternates between A (white) and a second note (orange), `N` semitones higher.

*Slider:* `N` = 0 to 12 semitones.

#tbl(
  (auto, auto, 1fr, 1fr),
  [*N*], [*Name*], [*Sound*], [*Where you meet it*],
  [0], [unison], [the same note], [–],
  [1], [minor second], [sharp friction, threat], [Phrygian techno basslines (A–B♭), horror],
  [2], [major second], [neutral step], [melodies, sus2 chords],
  [3], [minor third], [dark, sad: *the* minor sound], [every minor chord, most techno],
  [4], [major third], [bright, happy: *the* major sound], [major chords, disco, euphoric house],
  [5], [fourth], [open, hollow, waiting], [sus4 chords, dub techno chords],
  [6], [tritone], [unstable, eerie], [diminished chords, industrial, acid],
  [7], [fifth], [strong, pure, "power"], [root + fifth in the bass, rave stabs],
  [8], [minor sixth], [dark, dramatic], [minor melodies (A–F), trance leads],
  [9], [major sixth], [warm, soulful], [Dorian deep house, jazz chords],
  [10], [minor seventh], [bluesy, open, groovy], [m7 chords (deep house), Mixolydian riffs],
  [11], [major seventh], [dreamy, longing, tense], [maj7 chords (nu-disco), the leading tone],
  [12], [octave], [the same note, higher], [octave basslines (house, disco)],
)

*Why do some intervals sound calm and others tense?* With the octave (2:1) and the fifth (3:2) the two notes vibrate in simple ratios; their vibrations often line up, and the ear hears them merge. With a minor second or a tritone they hardly line up; you hear a shimmer or rub (beating). This rubbing is called *dissonance* (tension), the calm merging *consonance* (release).

#listen[
  + `N` = 0, then 12, then 7. These three sound almost like "one note". How calm is that?
  + `N` = 7, then 6. One semitone less, and the strongest bond becomes the eeriest.
  + `N` = 3, then 4 (back and forth several times): that is the whole difference between minor and major.
  + `N` = 1 and 11: both want to move on. 11 wants up to 12, 1 wants down to 0. Do you feel the direction?
  + Go through all values from 0 to 12 and sort them for yourself into "calm", "colourful" and "tense".
]

#remember[Music lives on tension and release. Tension comes from intervals that rub; release from intervals that merge.]

== Chapter 1: Major or minor – a single note decides

*What it is about.* A chord of root, third and fifth is called a *triad*. Whether it is major or minor is decided only by the *third*, i.e. the note three or four semitones above the root. Root, fifth and octave stay the same.

#fig(onA((0, 3, 7), c: (3,)), [A minor: A C E. The minor third (3 semitones, C) is orange.])
#fig(onA((0, 4, 7), c: (4,)), [A major: A C♯ E. The major third (4 semitones, C♯) is orange.])
#fig(onA((0, 7, 12)), [Without a third: A E A, the "power chord" (fifth chord). Neither major nor minor.])

In the chapter the lead plays the notes one after another (arpeggio), a stab plays them together, the bass stays on A.

*Slider:* `THIRD`: 0 = minor, 1 = major, 2 = no third.

#listen[
  + Switch between 0 and 1 every four bars. One note moves by a semitone, and the whole mood tips over.
  + In the arpeggio listen for the orange C or C♯. Can you sing it?
  + Set 2: without a third the mood is missing. It sounds strong but neutral. Then switch back to 0 and 1. The third "colours" the sound.
]

#scene[Techno is mostly minor or has no third at all: many stabs and basslines consist only of root and fifth or octave. That keeps the mood open and fits under any melody. Disco, French house and piano house are often major.]

== Chapter 2: Why scales exist

*What it is about.* There are twelve different notes. A *scale* picks seven (sometimes five) of them. Why? The lead plays *random* notes, and the slider sets which set they come from:

- *0 chromatic:* all 12 notes. Sounds aimless and "wrong", because nothing tells the ear where home is.
- *1 A minor:* 7 notes with the steps W H W W H W W (W = whole tone = 2 semitones, H = half tone = semitone). Suddenly it is a melody: every note belongs to the root A.
- *2 A minor pentatonic:* 5 notes. The two notes that lie only a semitone from a neighbour (B and F) are missing. Without semitones nothing can rub any more.

#fig(onA((0, 2, 3, 5, 7, 8, 10, 12), c: (2, 8)), [A minor. Orange: B and F, the two notes with a semitone neighbour (B–C, E–F).])
#fig(onA((0, 3, 5, 7, 10, 12)), [A minor pentatonic: A C D E G. Without B and F there are no semitone steps left.])

*Sliders:* `SET` = note set (0 to 2), `SEED` = which random melody (0 to 31). The melody repeats every two bars so you can learn it.

#listen[
  + Keep `SEED` fixed, change `SET`. Rhythm and "randomness" stay the same, only the note set changes.
  + Leave `SET` = 1 or 2 and try several `SEED`s. Almost every melody "works".
  + Compare 1 and 2: minor has more character (and more tension), pentatonic sounds smoother and safer.
]

#scene[Minor pentatonic is the scale for acid lines, rave leads and improvised synth solos: you cannot play a wrong note. If you pick notes live with knobs, it keeps you on the safe side.]

#remember[A scale is not a rule but a supply: it makes sure all notes belong to the same home.]

// ============================================================
= Part B: Scales and modes

== Chapter 3: The seven modes, from bright to dark

*What it is about.* If you play only the white keys but start on a different note each time, you get seven scales: the *modes* (church modes). Major and minor are two of them. In the tutorial all seven are on A, so you can compare them directly.

The nice part: sorted by brightness, *exactly one note* changes by a semitone from one mode to the next. So every step can be heard as *one* changed note.

#tbl(
  (auto, auto, auto, auto, 1fr),
  [*MODE*], [*Mode*], [*Steps*], [*Change*], [*Sound*],
  [0], [Lydian], [W W W H W W H], [raised fourth D♯], [floating, dreamlike, brightest],
  [1], [major (Ionian)], [W W H W W W H], [fourth back to D], [happy, resolved],
  [2], [Mixolydian], [W W H W W H W], [seventh down to G], [major, but relaxed, bluesy],
  [3], [Dorian], [W H W W W H W], [third down to C: now minor], [minor, but warm, soulful],
  [4], [minor (Aeolian)], [W H W W H W W], [sixth down to F], [dark, melancholic],
  [5], [Phrygian], [H W W W H W W], [second down to B♭], [darkest, threatening],
  [6], [Locrian], [H W W H W W W], [fifth down to E♭], [no stable home],
)

Every mode has a *characteristic note*: the one that sets it apart from plain major or minor. It is orange in the piano roll.

#grid(columns: (auto, 1fr), column-gutter: 5mm, row-gutter: 2.5mm, align: horizon,
  onA((0, 2, 4, 6, 7, 9, 11, 12), c: (6,)), [*Lydian*: D♯ (augmented fourth)],
  onA((0, 2, 4, 5, 7, 9, 11, 12), c: (11,)), [*Major*: G♯ (major seventh, the leading tone)],
  onA((0, 2, 4, 5, 7, 9, 10, 12), c: (10,)), [*Mixolydian*: G (minor seventh in major)],
  onA((0, 2, 3, 5, 7, 9, 10, 12), c: (9,)), [*Dorian*: F♯ (major sixth in minor)],
  onA((0, 2, 3, 5, 7, 8, 10, 12), c: (8,)), [*Minor*: F (minor sixth)],
  onA((0, 1, 3, 5, 7, 8, 10, 12), c: (1,)), [*Phrygian*: B♭ (minor second)],
  onA((0, 1, 3, 5, 6, 8, 10, 12), c: (6,)), [*Locrian*: E♭ (diminished fifth)],
)

In the chapter the scale runs up in bar 1 and down in bar 2. The stab plays the mode's *home chord* along with it (degrees 1, 3 and 5 stacked).

*Slider:* `MODE` = 0 to 6 (start: 4 = minor).

#listen[
  + Start at 4 (minor). One step up (3, Dorian): which note is different? (F becomes F♯.) Back to 4. Several times.
  + Go on like this to 0, always one step, always back and forth. Then from 4 downwards to 6.
  + Listen to the stab: at 0 to 2 the home chord is major, at 3 to 5 minor, at 6 *diminished* (A C E♭). That is why Locrian is no good as a home: even the home chord is unstable.
  + Jump from 0 to 5: that is the way from the brightest to the darkest usable mode.
]

#remember[Modes are not seven completely different worlds but a ladder of brightness. Each rung lowers one note.]

== Chapter 4: Every mode in its typical riff

*What it is about.* Scales up and down are only the first step. Every mode has typical turns that stress its characteristic note, often a two-chord loop. The trick: with `COMPARE` = 1 the same riff plays in the *neighbouring mode*, which lacks exactly this one note. So you hear what a single note makes.

#tbl(
  (auto, auto, auto, 1fr, auto),
  [*RIFF*], [*Mode*], [*Chords*], [*Typical for*], [*COMPARE*],
  [0], [Lydian], [A – B (major on degree II)], [ambient pads, film, progressive house], [major (D♯ → D)],
  [1], [major], [A – E], [piano house, disco, hands-up], [Mixolydian (G♯ → G)],
  [2], [Mixolydian], [A – G (♭VII)], [funky house, disco, Chicago], [major (G → G♯)],
  [3], [Dorian], [Am7 – D7 (major IV)], [*the* deep house vamp, Detroit], [minor (F♯ → F)],
  [4], [minor], [Am – F (♭VI)], [techno, trance, melancholic house], [Dorian (F → F♯)],
  [5], [Phrygian], [Am – B♭ (♭II)], [hard techno basslines, EBM], [minor (B♭ → B)],
  [6], [Locrian], [only A°], [tension, horror, industrial], [Phrygian (E♭ → E)],
)

A *vamp* is a loop of two chords that swings back and forth endlessly. Almost every deep house piece is built like this.

*Sliders:* `RIFF` = mode (0 to 6, start 3), `COMPARE` = 0 (original) or 1 (neighbour without the orange note).

#listen[
  + `RIFF` = 3 (Dorian). Listen for four bars, then `COMPARE` = 1: the riff turns into plain minor. What gets lost? (Usually: the warm, hopeful part.)
  + `RIFF` = 4 (minor) with `COMPARE` = 1: exactly the opposite direction. The Dorian/minor pair is the most important of all for house.
  + `RIFF` = 5 (Phrygian): the bassline swings between A and B♭. With `COMPARE` = 1 it becomes A–B: the threat is gone.
  + Compare `RIFF` = 2 and 1: Mixolydian is major with "swagger".
]

#scene[Phrygian semitone basslines (root and the note a semitone above) are a hallmark of hard techno and EBM. The Dorian vamp i–IV (Am7–D7) is the foundation of deep house and Detroit techno. Mixolydian is in many disco and funk house riffs, Lydian in the floating pads of progressive house.]

// ============================================================
= Part C: Chords

== Chapter 5: Chords from the scale

*What it is about.* You build a chord by stacking *every other note* of the scale: degrees d, d+2, d+4 give a triad (3 notes). Adding d+6 gives a *seventh chord* (4 notes), adding d+8 a *ninth chord* (5 notes).

Because the scale has unequal steps (whole and half tones), every stacked chord gets a different *quality*: major, minor or diminished.

#tbl(
  (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  [*DEGREE*], [0], [1], [2], [3], [4], [5], [6],
  [Degree], [i], [ii°], [III], [iv], [v], [VI], [VII],
  [Triad in A minor], [Am], [B°], [C], [Dm], [Em], [F], [G],
  [Seventh chord], [Am7], [Bm7♭5], [Cmaj7], [Dm7], [Em7], [Fmaj7], [G7],
)

*Roman numeral notation:* Roman numerals count the chords in the scale. Upper case = major chord, lower case = minor chord, ° = diminished. The advantage: "i – VI – III – VII" describes the same chord progression in every key. In A minor it is Am – F – C – G, in D minor Dm – B♭ – F – C.

*Sliders:* `DEGREE` = degree (0 to 6), `SIZE` = 0 triad, 1 seventh chord, 2 ninth chord, `SCALE5` = scale (same order as chapter 3, start 4 = minor).

#listen[
  + Go through `DEGREE` from 0 to 6. For each chord: major or minor? Check with the table.
  + `DEGREE` = 1 (B°): the one diminished chord of the scale. It sounds squeezed and wants to move on.
  + `DEGREE` = 0, `SIZE` from 0 via 1 to 2: Am becomes Am7 and Am9. Softer, jazzier, deeper: that is the deep house sound.
  + `SCALE5` = 3 (Dorian), `DEGREE` = 3: Dm becomes D major. Exactly this chord makes the Dorian vamp from chapter 4.
]

#remember[A scale comes with its chords. If you know the scale, you know which chords "fit".]

== Chapter 6: Chord types – happy, sad, tense, floating

*What it is about.* Here all chords are on A, built from semitone steps above the root (the intervals from chapter 0). Bar 1 plays the chord as a stab, bar 2 the same notes one after another, so you hear each one.

#tbl(
  (auto, auto, auto, auto, 1fr, 1fr),
  [*TYPE*], [*Name*], [*Steps*], [*Notes*], [*Sound*], [*Techno / house*],
  [0], [5 (power)], [0 7 12], [A E A], [neutral, strong], [rave stabs, hoover, techno bass],
  [1], [major], [0 4 7], [A C♯ E], [bright, happy], [disco, French house, piano house],
  [2], [minor], [0 3 7], [A C E], [dark, sad], [most techno, trance],
  [3], [sus2], [0 2 7], [A B E], [open, unresolved], [progressive house, melodic techno pads],
  [4], [sus4], [0 5 7], [A D E], [hollow, waiting], [melodic techno stabs, resolves to 1 or 2],
  [5], [diminished (dim)], [0 3 6], [A C E♭], [squeezed, restless], [tension stabs, passing chord, horror],
  [6], [augmented (aug)], [0 4 8], [A C♯ F], [eerie, floating], [risers, breaks, only briefly],
  [7], [maj7], [0 4 7 11], [A C♯ E G♯], [dreamy, longing], [nu-disco, Balearic, lounge house],
  [8], [7 (dominant seventh)], [0 4 7 10], [A C♯ E G], [bluesy, wants to move on], [Chicago house organs, gospel house],
  [9], [m7], [0 3 7 10], [A C E G], [soft, warm minor], [deep house: *the* house chord],
  [10], [m9], [0 3 7 10 14], [A C E G B], [lush, jazzy], [deep house, Detroit, dub techno],
  [11], [stacked fourths], [0 5 10 15], [A D G C], [hollow, modern, open], [dub techno / Detroit stab],
  [12], [m7♭5 (half-diminished)], [0 3 6 10], [A C E♭ G], [dark, jazzy tension], [deep house turns before minor],
  [13], [dim7 (diminished seventh)], [0 3 6 9], [A C E♭ F♯], [very tense, symmetric], [builds, horror, before the drop],
)

=== Why do they sound like this?

- *The third decides major (4) or minor (3).* Chords without a third (power, sus, stacked fourths) are neither; their mood stays open. That is why techno loves these chords: they fit any bassline and never sound "happy" or "sad".
- *The fifth decides stable or unstable.* A perfect fifth (7) gives the chord a footing. *Diminished* lowers it to the tritone (6), *augmented* raises it to 8. Both lose their stable centre: they sound as if they were falling or floating.
- *The seventh adds colour.* The minor seventh (10) brings groove, blues and softness, the major seventh (11) longing and dream.
- *sus* means "suspended": the third is replaced by the second (sus2) or fourth (sus4). The chord waits for a resolution but often does not get it. That is exactly what makes it useful for long tension arcs.

=== Diminished and augmented in more detail

#fig(onA((0, 3, 6), c: (6,)), [*Diminished* (A°): two minor thirds stacked (3+3). The fifth is lowered by a semitone (E → E♭).])
#fig(onA((0, 3, 6, 9), c: (6, 9)), [*Diminished seventh* (A°7): three minor thirds (3+3+3). The distance from F♯ to the next A is 3 again. The chord is perfectly symmetric.])
#fig(onA((0, 3, 6, 10), c: (6,)), [*Half-diminished* (Am7♭5): diminished triad with a minor seventh. Softer than dim7, typical in jazz and deep house.])
#fig(onA((0, 4, 8), c: (8,)), [*Augmented* (A+): two major thirds (4+4). The fifth is raised (E → F). Symmetric as well.])

Symmetric chords (diminished, augmented) consist only of equal steps. No note stands out as the root, and the ear loses its "home". That makes them ideal tension makers and poor home chords.

*Slider:* `TYPE` = 0 to 13 (start 2 = minor).

#listen[
  + 1 → 2 → 5 (major, minor, diminished): each step lowers one note by a semitone (first the third, then the fifth).
  + 1 → 6 (major, augmented): only the fifth rises. Do you hear the ground floating away?
  + 2 → 9 → 10 (minor, m7, m9): deeper and deeper house.
  + 9 → 12 → 13 (m7, half-diminished, dim7): more and more tension.
  + 3, 4 and 11 (sus2, sus4, stacked fourths): do they sound major or minor? (Answer: neither.)
]

== Chapter 7: Diminished chords in use

*What it is about.* Diminished chords are rarely "the" chord of a track. They are tools for tension. The chapter shows three typical uses (slider `USE`):

*0 – Passing chord.* The loop plays Am | Dm | G♯°7 | Am. The G♯°7 (G♯ B D F) sits a semitone below the root A. All its notes lean towards Am: G♯ wants to A, B to C, F to E. Listen to the move from bar 4 to bar 1: the chord "falls" home. Classic in house piano, garage and gospel house, often right before a drop too.

#fig(kb(on: (8, 11, 14, 17), char: (8,)), [G♯°7: G♯ B D F. Orange: G♯, the leading tone a semitone below A.])

*1 – Symmetry.* A dim7 consists of 3+3+3 semitones. Shift it by 3 semitones and you get *the same four notes* again (just in a different position). So there are only three different dim7 chords. In the chapter a dim7 shape rises in semitones (A°7, B♭°7, B°7, C°7) while the bass stays on A. It rises and rises and never lands: a typical build before a drop.

*2 – Threat stab.* The bass stays on A, the stab switches every bar between A minor (A C E) and A diminished (A C E♭). Only the fifth drops by a semitone (orange). The tritone A–E♭ makes it threatening: hard techno, acid, EBM.

#listen[
  + `USE` = 0 with drums at 0. Hum the melody along. After bar 4 you feel where the music has to go.
  + `USE` = 1: notice that it never "arrives". Imagine the drop coming at the place of bar 1.
  + `USE` = 2: a single semitone in a chord turns melancholy into threat.
]

#scene[Diminished chords mostly appear briefly: as a stab with lots of reverb, as a passing chord in a house piano figure, as a rising chain in a build-up. A whole track on a diminished chord is rare, but not unusual in industrial and dark acid.]

== Chapter 8: Chord memory – one shape, shifted

*What it is about.* Many techno and house tracks ignore the scale completely: they take *one* chord shape and shift the whole shape up and down. Old synthesizers had a "chord memory" button for this: a stored chord sits on every key. The notes leave the key, but the ear accepts it because the chord's colour stays the same (*parallel motion*).

*Sliders:* `SHAPE`: 0 minor, 1 m7, 2 m9, 3 stacked fourths (the dub techno chord), 4 maj7. `MOVE`: 0 stays on A, 1 A–C–D–C (house), 2 A–G–F–G (dub, sinking), 3 A–B♭ (dark techno semitone).

The long delay is the dub techno trick: the echoes fill the space between the short stabs.

#listen[
  + Keep `MOVE` fixed, change `SHAPE`: same rhythm, but minor = techno, m9 = deep house, stacked fourths = dub techno, maj7 = nu-disco.
  + `SHAPE` = 3, `MOVE` = 2: the Basic Channel / dub techno sound.
  + Compare with chapter 5: there the chords follow the scale (their quality changes), here the quality stays the same and the key is left.
]

#scene[Chord memory shapes Detroit techno, dub techno (Basic Channel, Deepchord) and a lot of deep house. For you as a live performer it is especially handy: a single chord shape plus a sequence of roots is enough for a whole track.]

// ============================================================
= Part D: Keys

== Chapter 9: A key – home and pull

*What it is about.* A *key* is a scale plus a home chord. In the key of A minor, Am is home; all other chords are steps away from it and back. The loop plays Am | F | Dm | ? and then starts again with Am. The slider `LAST` picks the chord before the return:

#tbl(
  (auto, auto, auto, 1fr),
  [*LAST*], [*Chord*], [*Degree*], [*Effect*],
  [0], [Am], [i], [stays home: no movement, flat],
  [1], [G], [VII], [natural minor: soft, open, little pull. Typical techno/trance loop],
  [2], [Em], [v], [natural minor: gentle, a bit sad],
  [3], [E], [V], [with G♯ from harmonic minor: strong pull home],
  [4], [E7], [V7], [even stronger: the classic cadence],
  [5], [G♯°7], [vii°7], [the diminished version of the same pull (chapter 7)],
)

*The leading tone.* The pull comes from G♯ (orange), a semitone below A. A note a semitone below the root is called the *leading tone*: it "leads" home, because the semitone step is so small that the ear wants to complete it (see interval 11 in chapter 0). Natural minor has G, two semitones below A, and so does not pull. That is why *harmonic minor* exists (A B C D E F G♯): minor, but with a leading tone.

#fig(onA((0, 2, 3, 5, 7, 8, 11, 12), c: (11,)), [Harmonic minor on A: like minor, but G♯ instead of G. Between F and G♯ lies a striking step of 3 semitones ("oriental" sound).])

A *cadence* is the chord progression that ends a section, here the step from the fourth bar back to Am.

#listen[
  + Compare 1 and 3 several times. At 3 bar 4 wants to "fall into" bar 1, at 1 it keeps floating.
  + 0: without movement the tension is missing, and so is the relief on returning.
  + 4 and 5: even more pull. Which version feels most dramatic to you?
]

#scene[Techno often avoids the pull on purpose (LAST = 0 or 1): the loop never resolves and so feels hypnotic. House and trance use the pull deliberately to land a drop or a return. Harmonic minor is typical for trance leads.]

== Chapter 10: Same notes, different home

*What it is about.* The lead plays only white keys, i.e. the notes of C major, which are also the notes of A minor. Only drone and bass change; they decide which note is home. Order as in chapter 3, from bright to dark:

#tbl(
  (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  [*0*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*],
  [F Lydian], [C major], [G Mixolydian], [D Dorian], [A minor], [E Phrygian], [B Locrian],
)

That is the principle of *relative keys*: C major and A minor share all notes (no sharps or flats), only the home is a different one. And it is a second view of the modes: the modes are the same notes with a different root.

*Slider:* `HOME` = 0 to 6 (start 4 = A).

#listen[
  + Hum the melody along. Then change `HOME`: not a single note of the melody changes, but its mood does.
  + 1 (C) against 4 (A): major and minor with the same notes.
  + 3 (D Dorian) and 5 (E Phrygian): how does the same melody sound over these roots?
]

#remember[In a track the bass sets the home (and a tuned kick), not the melody. Change the bass and you change the key, even if everything else stays the same.]

== Chapter 11: All keys – transposing and the circle of fifths

*What it is about.* The same little track in every key: in major with I – V – vi – IV, in minor with i – VI – III – VII. *Transposing* means shifting everything by the same distance. The shape stays the same, only the pitch changes.

The slider `KEY` walks along the *circle of fifths*: each step goes up a fifth (7 semitones).

#align(center, circle-of-fifths)

Outside the major keys, inside the relative minor keys (same notes, root 3 semitones lower). In the middle the Camelot numbers (B = major, A = minor), as DJ software shows them.

*Neighbours share six of seven notes.* One step clockwise adds a sharp (or removes a ♭). The new note is orange in the piano roll: in major the seventh (the leading tone of the new key), in minor the second. With `MINOR` = 1 the track plays the minor key on the same root (C minor, G minor …).

#tbl(
  (auto, auto, auto, auto),
  [*Major*], [*Minor (relative)*], [*Key signature*], [*Camelot*],
  [C], [Am], [none], [8B / 8A],
  [G], [Em], [1 ♯ (F♯)], [9B / 9A],
  [D], [Bm], [2 ♯ (F♯ C♯)], [10B / 10A],
  [A], [F♯m], [3 ♯], [11B / 11A],
  [E], [C♯m], [4 ♯], [12B / 12A],
  [B], [G♯m], [5 ♯], [1B / 1A],
  [F♯ / G♭], [D♯m / E♭m], [6 ♯ / 6 ♭], [2B / 2A],
  [D♭], [B♭m], [5 ♭], [3B / 3A],
  [A♭], [Fm], [4 ♭], [4B / 4A],
  [E♭], [Cm], [3 ♭ (B♭ E♭ A♭)], [5B / 5A],
  [B♭], [Gm], [2 ♭ (B♭ E♭)], [6B / 6A],
  [F], [Dm], [1 ♭ (B♭)], [7B / 7A],
)

*Sliders:* `KEY` = position on the circle of fifths (0 = C … 11 = F, start 3 = A), `MINOR` = 0 major, 1 minor.

#listen[
  + Move `KEY` by one step and look for the one orange, new note.
  + Jump from 0 to 6 (C → F♯): almost all notes change. These two keys fit together worst.
  + Listen to the bass: low keys (E, F) make it heavy, high ones (B, C) brighter. In electronic music the key is often chosen by the bass.
]

#scene[*Harmonic mixing:* DJs blend tracks in neighbouring keys (same Camelot number, or ±1). For your own tracks this means: all tonal elements (bass, pad, stab, vocal sample) belong in the same key, otherwise it rubs at once. Many producers also tune the kick to the root.]

== Chapter 12: Playground

*What it is about.* A small track written only in scale degrees. That is why it follows every key, every mode and every chord size.

#tbl(
  (auto, 1fr),
  [*Slider*], [*Function*],
  [`ROOT`], [key: semitones above A (0 = A, 3 = C, 5 = D, −4 = F …)],
  [`MODE12`], [scale, from bright to dark (chapter 3)],
  [`PROG`], [chord progression: 0 i–VI–III–VII (techno/trance), 1 i–iv (deep house vamp), 2 i–VII (hypnotic), 3 i–II (Phrygian threat)],
  [`CHORDS`], [0 triads, 1 seventh chords, 2 ninth chords (chapter 5)],
)

Starting points to try:

#tbl(
  (auto, auto, auto, auto, 1fr),
  [*MODE12*], [*PROG*], [*CHORDS*], [*ROOT*], [*Result*],
  [3 (Dorian)], [1], [2], [0], [deep house],
  [5 (Phrygian)], [3], [0], [−4 (F)], [hard techno],
  [1 (major)], [0], [1], [3 (C)], [euphoric house],
  [4 (minor)], [2], [0], [0], [hypnotic techno],
  [0 (Lydian)], [2], [2], [3], [floating ambient/progressive],
)

// ============================================================
= Appendix

== Practice plan

#tbl(
  (auto, 1fr, 1fr),
  [*Session*], [*Chapters*], [*Goal*],
  [1], [0, 1], [recognise intervals 3, 4, 7, 12 reliably; tell major and minor apart],
  [2], [2, 3], [scale as a note supply; the brightness ladder upwards from minor],
  [3], [3, 4], [recognise every mode by its orange note; Dorian against minor],
  [4], [5, 6], [chord qualities: major, minor, diminished, augmented, sus, sevenths],
  [5], [7, 8], [tension with diminished chords; chord memory],
  [6], [9, 10, 11], [leading tone and cadence; relative keys; circle of fifths],
  [after that], [12], [your own combinations, then carry them over to a track of your own],
)

To review: pick a chapter, set a slider blind (without looking) to a random value and guess what you hear. Then check in the code.

== Common chord progressions

#tbl(
  (auto, auto, 1fr),
  [*Degrees*], [*in A minor / C major*], [*Character and use*],
  [i – VI – III – VII], [Am – F – C – G], [dark and epic: techno, trance, electronica],
  [i – VII – VI – VII], [Am – G – F – G], [driving: trance, breakdowns],
  [i – iv], [Am – Dm (Dorian: Am – D)], [deep house vamp],
  [i – VII], [Am – G], [hypnotic, endless],
  [i – ♭II], [Am – B♭], [Phrygian, threatening: hard techno, EBM],
  [i – iv – v], [Am – Dm – Em], [classic minor],
  [i – VI – iv – V], [Am – F – Dm – E], [minor with a leading tone: pull towards the drop],
  [I – V – vi – IV], [C – G – Am – F], [pop and house anthems, bright to emotional],
  [I – ♭VII], [A – G], [Mixolydian: disco, funk house],
)

== Strudel cheat sheet

#tbl(
  (auto, 1fr),
  [*Code*], [*Meaning*],
  [`n("0 2 4").scale('A:minor')`], [put scale degrees (0 = root) into a scale. Degree 7 = root an octave higher],
  [`'A:dorian'`, `'C3:major'`], [root (optionally with octave), colon, scale name in English],
  [`n("[0,2,4]")`], [comma = at the same time: a chord of degrees 1, 3 and 5],
  [`.trans(-12)`], [shift all notes by semitones (−12 = one octave lower)],
  [`note("a3 c4 e4")`], [fixed note names instead of degrees],
  [`.struct("~ x ~ x")`], [impose a rhythm (x = play, \~ = rest)],
)

Scale names in Strudel: `major`, `minor`, `dorian`, `phrygian`, `lydian`, `mixolydian`, `locrian`, `harmonic minor`, `melodic minor`, `major pentatonic`, `minor pentatonic`, `chromatic` (also `ionian` and `aeolian`).

If you write a track of your own in degrees instead of note names, you can change key and mode later with a single value, just like in chapter 12.

== More scales (not in the tutorial)

#tbl(
  (auto, auto, auto, 1fr),
  [*Scale*], [*Steps*], [*on A*], [*Sound and use*],
  [melodic minor], [W H W W W W H], [A B C D E F♯ G♯], [minor with a bright sixth and seventh: melodies, leads],
  [major pentatonic], [W W 3 W 3], [A B C♯ E F♯], [bright, open: hooks, piano loops],
  [blues], [3 W H H 3 W], [A C D E♭ E G], [minor pentatonic with a "blue note": acid and blues touches],
  [whole tone], [W W W W W W], [A B C♯ D♯ F G], [no centre, dreamlike: ambient, experimental techno],
)

(W = whole tone, H = semitone, 3 = three semitones.)

== Glossary

#tbl(
  (auto, 1fr),
  [*Term*], [*Meaning*],
  [semitone, whole tone], [smallest distance (1 key); two semitones make a whole tone],
  [octave], [distance with double frequency (12 semitones); the note names repeat],
  [interval], [distance between two notes],
  [root, tonic], [the centre of a scale or key, the "home"],
  [scale], [choice of notes within an octave],
  [mode], [one of the seven scales of the white keys, e.g. Dorian],
  [degree], [position of a note or chord in the scale (I, II, III …)],
  [triad], [root, third and fifth stacked],
  [seventh chord], [triad plus seventh],
  [diminished (dim, °)], [minor third + diminished fifth (0 3 6)],
  [augmented (aug, +)], [major third + augmented fifth (0 4 8)],
  [suspended (sus)], [third replaced by the second or fourth],
  [leading tone], [note a semitone below the root, pulls home],
  [cadence], [chord progression that closes a section],
  [relative key], [major and minor key with the same notes],
  [circle of fifths], [all keys arranged a fifth apart],
  [consonance, dissonance], [merging (calm) and rubbing (tense) of notes],
  [drone], [a long held note that makes the home audible],
  [vamp], [loop of a few chords that swings back and forth endlessly],
)
