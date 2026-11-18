// Handbook for effects-tutorial.strudel (every Strudel effect, by ear, with its role in techno and house).
// Compile: typst compile effects-tutorial.typ

#set document(title: "Effects Tutorial: Handbook")
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
#let green = rgb("#4a8a3c")
#let red = rgb("#c0392b")

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
#let scene(body) = box-of(green, "In techno and house:", body)
#let pitfall(body) = box-of(red, "Strudel pitfall:", body)

// ---------- small plots: points are (x, y) in 0..1 ----------
#let plot(w: 52mm, h: 24mm, curves: (), vlines: (), bars: (), xl: none, yl: none) = {
  let pt(p) = (p.at(0) * w, (1 - p.at(1)) * h)
  box(width: w, height: h + (if xl != none { 4mm } else { 0mm }), {
    place(rect(width: w, height: h, stroke: 0.4pt + luma(170), fill: luma(250)))
    for vx in vlines { place(line(start: (vx * w, 0pt), end: (vx * w, h), stroke: (paint: luma(180), thickness: 0.4pt, dash: "dashed"))) }
    for (x, y, col) in bars { place(line(start: (x * w, h), end: (x * w, (1 - y) * h), stroke: 2.2pt + col)) }
    for (pts, col) in curves {
      place(curve(stroke: 1.1pt + col, curve.move(pt(pts.at(0))), ..pts.slice(1).map(p => curve.line(pt(p)))))
    }
    if xl != none { place(dy: h + 0.6mm, text(7pt, fill: luma(100))[#xl]) }
    if yl != none { place(dx: 1mm, dy: 0.8mm, text(7pt, fill: luma(100))[#yl]) }
  })
}
#let sample(f, n: 140) = range(n + 1).map(i => { let x = i / n; (x, calc.clamp(f(x), 0, 1)) })
#let fig(diagram, caption) = grid(columns: (auto, 1fr), column-gutter: 5mm, align: horizon, diagram, text(size: 9pt)[#caption])

// filter response: x = 0..1 on a log scale 20 Hz .. 20 kHz, y = -36 .. +18 dB
#let resp(kind, fc, q) = x => {
  let r = 20 * calc.pow(1000, x) / fc
  let d = calc.sqrt(calc.pow(1 - r * r, 2) + calc.pow(r / q, 2))
  let m = if kind == "lp" { 1 / d } else if kind == "hp" { r * r / d } else { (r / q) / d }
  (20 * calc.log(calc.max(m, 0.000001)) + 36) / 54
}
#let fx(f) = calc.log(f / 20) / 3   // frequency -> x

// ADSR polyline: times in seconds, total plot width = total seconds
#let adsr(a, d, s, hold, r, total) = ((0, 0), (a / total, 0.95), ((a + d) / total, s * 0.95), (hold / total, s * 0.95), ((hold + r) / total, 0), (1, 0))

#let wave(f) = sample(x => 0.5 + 0.45 * f(calc.sin(2 * calc.pi * 2 * x)))
#let tanh(x) = (calc.exp(2 * x) - 1) / (calc.exp(2 * x) + 1)

#let chain-box(t, c: luma(235)) = box(inset: (x: 4pt, y: 3pt), radius: 2pt, fill: c, stroke: 0.4pt + luma(160), text(8pt)[#t])
#let arr = text(8pt, fill: luma(120))[ → ]

// ============================================================
#align(left)[
  #text(size: 22pt, weight: "bold")[Effects Tutorial]
  #v(-0.5em)
  #text(size: 12pt, fill: luma(90))[What every Strudel effect does, how it sounds and what role it plays in techno and house]
  #v(-0.3em)
  #text(size: 9pt, fill: luma(110))[Handbook for `lab/tutorials/effects-tutorial.strudel`]
]

#v(0.5em)
#outline(title: [Contents], depth: 2, indent: 1em)

= How to work with the tutorial

== Controls

+ Open `effects-tutorial.strudel` in Strudel and set `const CHAPTER = 0` at the top to the chapter you want (0 to 16). Evaluate once (Ctrl+Enter).
+ Then move only *this chapter's sliders*. The sliders of the other chapters are visible but do nothing.
+ Below the last line a *spectrum* shows which frequencies are sounding right now: low on the left (bass), high on the right (hi-hats). With filters and distortion you see there directly what happens.
+ Every chapter brings its own drums. To mute them, comment out the chapter's drum line.

All chapters use the same dry groove (kick, hats, clap, bass, chord stab, lead in A minor, 122 BPM). So you hear every effect on familiar material.

== How to learn to hear effects

- *Always back and forth.* You hear effects by comparison, not as a state. So: effect on, four bars, off, four bars.
- *Move slowly.* Many effects only show when you sweep the slider over several bars (filter, delay feedback, reverb).
- *Listen quietly.* Louder always sounds "better". Compare effects at the same level, otherwise your ear fools you. Some chapters even out the level automatically for this.
- *Headphones and speakers.* You cannot hear stereo (chapter 15) and sub bass (chapters 0, 6) on laptop speakers at all.
- *Ask questions:* What changes: level, brightness, length, space, movement? This grid places every effect.

= Basics

== What a sound is

A sound is a vibration of the air. How fast it vibrates is the *frequency*, measured in hertz (Hz, vibrations per second). We hear roughly 20 Hz to 20,000 Hz (20 kHz). Low = slow, high = fast. Doubling the frequency is an *octave*. The ear hears in octaves, not in Hz: the step from 100 to 200 Hz sounds as big as the step from 5000 to 10000 Hz. That is why all frequency sliders in the tutorial are scaled exponentially.

A tone almost never consists of just one frequency. Above the *fundamental* lie *overtones* (multiples of the fundamental frequency). Their mix makes the *timbre*: a sine wave has no overtones (round, dull), a sawtooth wave has very many (bright, buzzing). Almost all effects work on these overtones: filters take some away, distortion adds new ones.

#grid(columns: (1fr, 1fr, 1fr), column-gutter: 3mm,
  plot(w: 46mm, h: 18mm, curves: ((wave(v => v), blue),), xl: [Sine: only the fundamental]),
  plot(w: 46mm, h: 18mm, curves: ((sample(x => 0.5 + 0.45 * (2 * calc.rem(2 * x, 1) - 1)), blue),), xl: [Sawtooth: all overtones, bright]),
  plot(w: 46mm, h: 18mm, curves: ((sample(x => if calc.rem(2 * x, 1) < 0.5 { 0.92 } else { 0.08 }), blue),), xl: [Square: odd overtones, hollow]),
)

== Frequency ranges

#tbl(
  (auto, auto, 1fr),
  [*Range*], [*roughly*], [*What lives there*],
  [Sub], [20–60 Hz], [Kick body, sub bass. Felt more than heard; small speakers cannot play it],
  [Bass], [60–250 Hz], [Kick punch, bass notes, warmth],
  [Low mids], [250–800 Hz], [Body of chords and bass; too much of it = "mud"],
  [Mids], [0.8–2.5 kHz], [Chords, leads, clap, voice: what a phone speaker plays],
  [Presence], [2.5–6 kHz], [Attack, clap snap, hats: makes sounds "close"],
  [Air], [6–20 kHz], [Hat hiss, shine, breath],
)

== Level and decibels

Level is measured in *decibels (dB)*. This too is a ratio scale: +6 dB is about double the amplitude, +10 dB sounds about twice as loud. In the digital world 0 dB is the ceiling; above it the signal gets cut off (*clipping*, ugly distortion).

== Dry and wet, local and global

- *Dry/wet:* The unprocessed signal is called *dry*, the effect's share *wet*. For delay and reverb you set only the wet share in Strudel (`delay`, `room`); the dry signal always stays.
- *Local:* Most effects are applied to each note on its own (own filter, own distortion, own envelope).
- *Global:* Delay, reverb and ducking exist only once per *orbit* (a kind of mixer channel). All sounds on the same orbit share them (chapter 12).

== The signal chain in Strudel

Strudel sends every note through a fixed order. Each effect appears in it exactly *once*, even if you call it twice (the second call overwrites the first).

#block(width: 100%, inset: 6pt, radius: 3pt, stroke: 0.4pt + luma(180))[
  #chain-box[Sound source (sample/synth, pitch envelope)] #arr #chain-box[gain + ADSR] #arr #chain-box[lpf] #arr #chain-box[hpf] #arr #chain-box[bpf] #arr #chain-box[vowel] #arr #chain-box[coarse] #arr #chain-box[crush] #arr #chain-box[shape / distort] #arr #chain-box[tremolo] #arr #chain-box[compressor] #arr #chain-box[pan] #arr #chain-box[phaser] #arr #chain-box[postgain]
  #v(0.3em)
  #arr #chain-box(c: blue.lighten(80%))[Orbit: dry + delay + reverb] #arr #chain-box(c: blue.lighten(80%))[duck] #arr #chain-box(c: blue.lighten(80%))[Mixer / output]
]

What follows from it:
- *The order is fixed.* The filter always comes *before* the distortion. "Distort first, then filter" is not possible in one chain in Strudel.
- *Values are read when a note starts.* A slider or an LFO on `lpf` only takes effect from the next note on. With long notes (pads) the value therefore jumps only once per note. Only these run continuously *within* a note: ADSR, filter and pitch envelopes, tremolo, phaser, vibrato and ducking.

// ============================================================
= Part A: Learning to listen

== Chapter 0: Frequencies – where every sound lives

*What happens.* The whole groove runs through a narrow band-pass (chapter 4) that lets only one range through. So you hear, one after another, which instrument lives in which range.

*Slider:* `BAND` 0 = everything, 1 = sub 50 Hz, 2 = bass 120 Hz, 3 = low mids 400 Hz, 4 = mids 1.2 kHz, 5 = presence 4 kHz, 6 = air 10 kHz.

#listen[
  + Step by step from 1 to 6, four bars each. Where is the kick? Where the bass? Where the hats? Where the stab?
  + The kick shows up in several bands: its body below, its click above. Almost every sound has several ranges.
  + Back to 0: now you pick out the layers in the full mix more easily.
]

#scene[A techno mix works when each range belongs to *one* lead actor: sub and bass to the kick and the bass (which take turns or make room through ducking), the mids to the stabs and leads, the highs to the hats. Almost all filter decisions later follow from this split.]

== Chapter 1: Level and accents – gain, velocity, postgain

*What it does.* Three level controls at different points of the chain:

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Range*], [*Effect*],
  [`gain`], [0–1 (more is possible, gets louder)], [Level of the note, before all effects. On a curve: 0.5 is clearly quieter, not "half"],
  [`velocity`], [0–1], [is multiplied with `gain`. Meant for accents: how hard a hit is played],
  [`postgain`], [0–… (1 = unchanged)], [Level *after* all effects],
)

The difference between `gain` and `postgain` matters as soon as distortion is involved: more `gain` before a distortion makes it *stronger*, more `postgain` only makes it *louder*.

*Sliders:* `ACCENT` (how much quieter the off-beat 16ths of the hats are), `BASSLEVEL` (gain of the bass).

#listen[
  + `ACCENT` 0 → 0.6 → 1. The rhythm stays the same, but the groove changes. At 0 it sounds like a machine, at 0.6 it "rolls".
  + `BASSLEVEL` up and down: from when does the bass feel as big as the kick? From when does it cover it?
]

#scene[Accents are the most important groove tool for hats and percussion: a 16th hat with an accent on every second or fourth note drives, one without feels stiff. Level balance (leveling) is half the work on a mix; the project also has `/strudel-mix` for that.]

== Chapter 2: Envelope – attack, decay, sustain, release

*What it does.* An *envelope* (ADSR) shapes the level of *a single note* over time:

#fig(
  plot(w: 60mm, h: 24mm, curves: ((adsr(0.08, 0.25, 0.55, 0.9, 0.5, 1.6), blue),), vlines: (0.9 / 1.6,), xl: [A · D · S (while held) · R from note end (dashed)]),
  [*Attack:* time from silence to full. *Decay:* time to the sustain level. *Sustain:* level while the note is held (0–1). *Release:* fade-out time after the note ends.],
)

#tbl(
  (auto, auto, auto, auto, auto, 1fr),
  [*Preset*], [*A*], [*D*], [*S*], [*R*], [*Sound*],
  [Pluck], [0], [0.15], [0], [0.1], [plucked, short],
  [Techno stab], [0], [0.25], [0], [0.3], [short with a bit of tail],
  [Organ], [0], [0], [1], [0.05], [on/off, like a key],
  [Pad], [0.5], [0.5], [0.7], [1.5], [fades in and out softly (LEN 4)],
  [Swell], [1], [0], [1], [0.5], [swells up (LEN 4)],
)

*Sliders:* `ATT`, `DEC`, `SUS`, `REL` (seconds or level), `LEN` = how long each note is held (`clip`: 1 = its full slot, 4 = overlapping).

#listen[
  + Start with the stab preset and move only `SUS` from 0 to 1: from stab to organ.
  + Pull `ATT` up: the attack (punch) disappears, the sound moves back.
  + `ATT` = 0.5 with `LEN` = 1, then `LEN` = 4: the note must be long enough, otherwise the attack never reaches full level.
]

#scene[Short envelopes (attack 0, sustain 0) are the language of techno: stabs, plucks, percussion. Long attacks and releases make pads and textures (deep house, ambient breaks). The *decay* is your control for a stab's "length": played live it turns a stab from dry to sweeping.]

#pitfall[`release` only acts *after* the note ends. A long release on many short notes makes them overlap and costs CPU.]

// ============================================================
= Part B: Filters

== Chapter 3: Low-pass – lpf, lpq, ftype

*What it does.* A *low-pass* filter lets the low frequencies through and removes everything above the *cutoff frequency*. Closed: dark, dull, far away. Open: bright, close, aggressive. The *resonance* (Q) boosts the frequencies right at the cutoff: from soft to "whistling" or "squealing".

#fig(
  plot(w: 60mm, h: 26mm, curves: ((sample(resp("lp", 800, 0.7)), blue), (sample(resp("lp", 800, 6)), orange)), vlines: (fx(800),), xl: [20 Hz … 20 kHz; cutoff 800 Hz]),
  [Blue: low-pass without resonance (Q 0.7). Orange: with resonance (Q 6): a peak at the cutoff. Right of the cutoff everything falls away.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Range*], [*Effect*],
  [`lpf` (cutoff, lp)], [20–20000 Hz], [Cutoff frequency],
  [`lpq` (resonance)], [0–50, useful 0–25], [Resonance at the cutoff],
  [`ftype`], [`12db`, `ladder`, `24db`], [Steepness: 12db gentle, 24db steep, ladder = Moog-like, fat, more aggressive],
)

*Sliders:* `CUT` (0 = 60 Hz, 0.5 = 775 Hz, 1 = 10 kHz), `RES`, `FTYPE`. The filter sits on bass, stab and lead; the drums stay dry.

#listen[
  + `CUT` slowly from 1 to 0.2 and back, over eight bars. That is the classic filter sweep.
  + `RES` to 15, sweep again: now the cutoff "sings".
  + At `RES` 10 compare the three `FTYPE`s.
]

#scene[The low-pass is *the* live control in techno and house. A slow sweep over 16 or 32 bars is a tension curve of its own: the track builds up without a single new note. On pads and stabs a half-closed filter keeps room free for hats and vocals.]

#pitfall[An LFO or slider on `lpf` is only read when a note starts (see chapter 9). For movement *within* a long note use the filter envelope (chapter 5).]

== Chapter 4: High-pass and band-pass – hpf, bpf

*What it does.* The *high-pass* is the counterpart: it removes everything *below* the cutoff. The *band-pass* lets only a band around a center frequency through ("telephone" or "radio" sound).

#grid(columns: (1fr, 1fr), column-gutter: 4mm,
  plot(w: 70mm, h: 22mm, curves: ((sample(resp("hp", 400, 0.7)), blue),), vlines: (fx(400),), xl: [High-pass 400 Hz: bass gone]),
  plot(w: 70mm, h: 22mm, curves: ((sample(resp("bp", 1000, 4)), blue),), vlines: (fx(1000),), xl: [Band-pass 1 kHz, Q 4: only one band remains]),
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Range*], [*Effect*],
  [`hpf` (hp, hcutoff)], [20–20000 Hz], [High-pass cutoff],
  [`hpq` (hresonance)], [0–50], [Resonance of the high-pass],
  [`bpf` (bandf, bp)], [Hz], [Center frequency of the band-pass],
  [`bpq` (bandq)], [0–…], [Width: high = narrow],
)

*Sliders:* `MODE4` 0 = high-pass on the whole groove, 1 = only on stab and lead (cleaning up), 2 = band-pass on the stab. `FREQ4` 0 = 20 Hz, 0.5 = 400 Hz, 1 = 8 kHz.

#listen[
  + `MODE4` 0: push `FREQ4` to 0.6 over four bars, then drop it to 0 at once on a bar start. That is a drop.
  + `MODE4` 1, `FREQ4` around 0.5: the mix gets clearer, the bass feels bigger, although nothing on the bass changed.
  + `MODE4` 2: the stab gets thin and nasal, but cuts through without being louder.
]

#scene[The high-pass is the tool for *build-ups*: kick and bass slowly disappear, tension rises, at the drop they come back. DJ mixers have exactly this control. In the mix a high-pass on pads, stabs, hats and reverb clears out the low end so kick and bass have the bottom to themselves. Band-passes make sounds "small": breaks, radio effects, percussion.]

== Chapter 5: Filter envelope and acid – lpenv, lpattack, lpdecay

*What it does.* A *filter envelope* opens the filter at the start of every note and closes it again. Like a hand turning the cutoff knob in a flash on every note. Each note gets a "wow" or "pew".

#fig(
  plot(w: 60mm, h: 24mm, curves: ((sample(x => 0.15 + 0.75 * calc.exp(-calc.rem(x * 4, 1) * 7)), orange),), xl: [Cutoff over four notes: jump up, fall with lpdecay]),
  [The cutoff rests at `lpf` and jumps up by `lpenv` octaves at every note start, then falls back with `lpdecay`.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Range*], [*Effect*],
  [`lpenv` (lpe)], [0–8, negative too], [Amount in octaves above the cutoff (negative: downwards)],
  [`lpattack` (lpa)], [seconds], [how fast the filter opens],
  [`lpdecay` (lpd)], [seconds], [how fast it closes again],
  [`lpsustain` (lps)], [0–1], [how far open it stays during the note],
  [`lprelease` (lpr)], [seconds], [closing after the note ends],
  [`fanchor`], [0–1], [where the cutoff sits within the sweep: 0 = cutoff is the closed value (as in the tutorial)],
)

The same exists for high-pass (`hpenv`, `hpa` …) and band-pass (`bpenv`, `bpa` …).

*Acid.* Low-pass + filter envelope + lots of resonance on a sawtooth bassline in 16ths: that is the sound of the Roland TB-303. The accents (`velocity`) let some notes open further, like the 303's accent button.

*Sliders:* `CUT5` (resting cutoff, 40 Hz–4 kHz), `ENV` (amount in octaves), `DECAY5`, `RES5`.

#listen[
  + `ENV` 0 → 4: the line comes alive.
  + `DECAY5` 0.05 (ticking) against 0.4 (wowing).
  + `RES5` 0 against 20: from soft to squealing.
  + The acid live move: raise `CUT5` and `RES5` slowly together over 16 bars.
]

#scene[Acid is a genre of its own (acid house, acid techno), but the technique is everywhere: plucks, stabs and basslines get bite from a short filter envelope. Played live, cutoff, resonance and decay are the three controls with which a single bassline carries a whole track.]

== Chapter 6: Pitch envelope – building a kick from a sine

*What it does.* A *pitch envelope* bends the pitch of every note: it starts higher and falls to the actual note. A kick is exactly that: a low sine (here A1 = 55 Hz) that starts much higher and falls fast.

#fig(
  plot(w: 60mm, h: 24mm, curves: ((sample(x => 0.1 + 0.85 * calc.exp(-x * 14)), blue), (sample(x => 0.1 + 0.85 * (1 - calc.min(x * 5, 1))), orange)), xl: [Pitch over 0.3 s: blue exponential, orange linear]),
  [With `pcurve` = 1 (blue) the pitch falls fast first, then slowly: that sounds like a real kick. Linear (orange) sounds like a "laser".],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Range*], [*Effect*],
  [`penv`], [semitones, negative too], [how far the pitch is bent (36 = three octaves)],
  [`pattack` (patt)], [seconds], [time to the peak of the bend],
  [`pdecay` (pdec)], [seconds], [how fast the pitch falls],
  [`prelease` (prel)], [seconds], [bend after the note ends],
  [`pcurve`], [0 / 1], [linear or exponential],
  [`panchor`], [0–1], [0 = bend above the note, 1 = below],
)

*Sliders:* `PENV`, `PDEC`, `PCURVE`, `KDEC` (length of the kick, amplitude decay), `SOURCE` (0 = synth kick, 1 = 909 sample for comparison).

#listen[
  + `PENV` 0: just a sine, a dull "boop". Then 12, 24, 36.
  + `PDEC` 0.02 (short click) against 0.3 ("boing", tom).
  + `KDEC` 0.15 (dry) against 0.8 (droning techno "rumble").
  + The kick is tuned to A, the key of the bass. Listen to how kick and bass merge.
]

#scene[Almost every electronic kick is a sine with a pitch envelope (the 808 and 909 too). Long kicks with distortion (chapter 7) and reverb are the "rumble" of hard and hypnotic techno. Tuned kicks (to the root) are common. The same technique makes toms, laser zaps and risers.]

// ============================================================
= Part C: Saturation, distortion, colour

== Chapter 7: Drive – distort, crush, coarse

*What it does.* Distortion pushes a wave past its limit and bends its shape. A bent wave has *new overtones*: the sound feels louder, brighter, rougher, more present.

#grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 2mm,
  plot(w: 36mm, h: 16mm, curves: ((wave(v => v), blue),), xl: [Original]),
  plot(w: 36mm, h: 16mm, curves: ((wave(v => tanh(3 * v) / tanh(3)), blue),), xl: [soft: roundly saturated]),
  plot(w: 36mm, h: 16mm, curves: ((wave(v => calc.clamp(2.5 * v, -1, 1)), blue),), xl: [hard: cut off]),
  plot(w: 36mm, h: 16mm, curves: ((wave(v => calc.sin(2.6 * v * calc.pi / 2)), blue),), xl: [fold: folded back]),
)

#tbl(
  (auto, auto, 1fr, 1fr),
  [*TYPE7*], [*Effect*], [*What happens*], [*Sound*],
  [0], [`distort` soft], [soft saturation], [tape, tube: warmer, fatter, "glue"],
  [1], [`distort` hard], [hard clipping], [aggressive, buzzing],
  [2], [`distort` diode], [like an overdriven analog circuit], [grainy; typical for acid and techno basses],
  [3], [`distort` fold], [wave is folded back], [metallic, synthetic, depends strongly on the amount],
  [4], [`crush`], [fewer level steps (16 bit → 2 bit)], [digital, grainy, lo-fi],
  [5], [`coarse`], [lower sample rate], [aliasing, robotic, metallic whistling (best in Chrome)],
)

More types for `distorttype`: `scurve`, `cubic`, `asym`, `sinefold`, `chebyshev`. The shorthand `distort("3:0.5:diode")` means: amount 3, level 0.5, type diode. The older effect `shape` is deprecated; `distort` is more predictable.

*Sliders:* `TYPE7`, `AMOUNT` (0–1, scaled per type), `TARGET` 0 = bass, 1 = drums, 2 = everything. The level is evened out (`postgain`).

#listen[
  + `TARGET` 0, `TYPE7` 0, `AMOUNT` slowly up: at first the bass only gets "bigger", later rough.
  + `TARGET` 1, `TYPE7` 2 or 4: the drums get hard and industrial.
  + `TYPE7` 4 and 5 with `AMOUNT` 1: lo-fi to broken.
]

#scene[In small amounts saturation sits on almost everything in techno: it makes sounds denser and lets them be heard on small speakers (the new overtones lie higher than the bass). Heavy distortion on the kick is the foundation of hard techno, industrial and schranz; distorted, filtered kick tails are the "rumble". Bitcrush and coarse are colour for breaks, percussion and lo-fi house.]

#pitfall[Distortion can get *very loud*. Always compensate with `postgain` or the second value (`distort("4:0.5")`). And: in Strudel the filter comes *before* the distortion; filtering the rough sound again afterwards only works another way (e.g. via orbit reverb with `roomlp`).]

== Chapter 8: Vowel – a formant filter that makes synths "talk"

*What it does.* Our mouth is a filter: the vowels a, e, i, o, u differ only in which frequencies the mouth cavity boosts (the *formants*). `vowel` models this filter, so a synth sounds as if it were saying the vowel.

*Values:* `a e i o u` and more (`ae aa oe ue y uh un en an on`). Works most strongly on bright sounds (sawtooth).

*Slider:* `VOWEL` 0 off, 1–5 = a e i o u, 6 = changing vowels on every 8th ("talking").

#listen[
  + 0 → 1 → 5: from open to closed.
  + 6: the "talking" bass.
]

#scene[Formant and vowel filters make the "yoi" and "wah" basses in techno, electro and tech house. On stabs they give a human, almost vocal character, without a vocal sample.]

// ============================================================
= Part D: Movement

== Chapter 9: Modulation – filter LFO, tremolo, gate, phaser

*What it does.* An *LFO* (low frequency oscillator) is a slow wave that turns a knob for you, again and again.

#tbl(
  (auto, auto, 1fr, 1fr),
  [*MOD*], [*Effect*], [*What happens*], [*Use*],
  [1], [Filter LFO], [a sine wave moves the cutoff], [wah over several bars, lively basslines],
  [2], [`tremolo` sine], [level goes up and down], [floating pads, vintage keys],
  [3], [`tremolo` square], [level gets chopped], [trance gate, rhythmic pads],
  [4], [`phaser`], [sweeping notch filters], [70s, disco, psychedelic, hats and pads],
)

#tbl(
  (auto, 1fr),
  [*Parameter*], [*Effect*],
  [`tremolosync`], [speed per bar (cycle): 4 = four times per bar],
  [`tremolo`], [speed in Hz (not tied to the tempo)],
  [`tremolodepth`, `tremoloshape`, `tremoloskew`, `tremolophase`], [depth; shape (`sine tri square saw ramp`); skew; start point],
  [`phaser`, `phaserdepth`, `phasercenter`, `phasersweep`], [speed (Hz); depth (default 0.75); center frequency (1000 Hz); sweep (2000 Hz)],
)

*Sliders:* `MOD` (0–4), `SPEED` (0–4: 1, 2, 4, 8, 16 per bar; with the filter LFO one sweep every 16, 8, 4, 2, 1 bars; with the phaser 0.25–4 Hz), `DEPTH`.

#pitfall[*The most important Strudel difference:* values like `lpf` are read only at *note start*. The filter LFO (MOD 1) therefore moves the pad (one chord = one note per bar) only once per bar, but the 16th bass smoothly. Tremolo, phaser and all envelopes, on the other hand, run *within* a note. Remedy for long notes: cut the note into 16 pieces with `.seg(16)`, or use a filter envelope.]

#listen[
  + `MOD` 1, `SPEED` 2: notice that the bass flows but the pad jumps.
  + `MOD` 3, `SPEED` 3 and 4: rhythm from a held chord.
  + `MOD` 4, `SPEED` 0: the slow phaser swirl.
]

#scene[In repetitive music movement is everything: a loop that never changes gets tiring. LFOs on filter, level or phaser let loops breathe without a single new note. The trance gate (square tremolo in 16ths) is a classic of its own; phaser on hats and pads is typical of disco and deep house.]

// ============================================================
= Part E: Space

== Chapter 10: Delay – echoes in time

*What it does.* A *delay* records the sound and plays it back later, again and again, each time quieter.

#fig(
  plot(w: 64mm, h: 22mm, bars: ((0.04, 0.95, blue),) + range(1, 7).map(i => (0.04 + i * 0.15, 0.95 * calc.pow(0.55, i), orange)), xl: [Original (blue) and echoes with feedback 0.55]),
  [Each echo comes after `delaytime` and has `delayfeedback` times the level of the previous one.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Range*], [*Effect*],
  [`delay`], [0–1], [Level of the echoes (wet share)],
  [`delaytime` (delayt, dt)], [seconds], [Spacing of the echoes],
  [`delayfeedback` (delayfb, dfb)], [0–0.95], [how much of each echo is repeated. Never 1 or more: keeps getting louder],
)

*Echo times in tempo* (at 122 BPM one beat is 0.49 s): 1/16 = 0.12 s, 1/8 = 0.25 s, *dotted 1/8 = 0.37 s*, 1/4 = 0.49 s, 8th triplet = 0.16 s. In Strudel in general: `delaytime(60 / BPM * 0.75)` for a dotted 8th.

*Sliders:* `LEVEL10`, `TIME10` (0 = 1/16, 1 = 1/8, 2 = dotted 1/8, 3 = 1/4, 4 = 8th triplet), `FEEDBACK`. The delay sits only on the sparse stab and the lead, on orbit 2.

#listen[
  + `TIME10` 2: the echoes fall between the beats and create a new, rolling rhythm.
  + `TIME10` 3: the echoes hide behind the kick.
  + `FEEDBACK` to 0.8 for one bar, then back: a "delay throw", a classic live move.
]

#scene[The dotted 8th is *the* delay of dub techno and deep house: a single chord stab per bar becomes a whole rhythmic texture (Basic Channel). In techno, delays on percussion and stabs are a groove tool; in a live set, delay throws (a burst of feedback on a single element) are a transition trick.]

== Chapter 11: Reverb – room, roomsize, roomlp

*What it does.* Reverb imitates a room: thousands of tiny echoes merge into a tail. Reverb places a sound in space: dry = close and direct, wet = far away and big.

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Range*], [*Effect*],
  [`room`], [0–1], [Amount of reverb (wet share)],
  [`roomsize` (size, sz, rsize)], [0–10], [Room size: small room … huge hall],
  [`roomfade` (rfade)], [seconds], [Decay time],
  [`roomlp` (rlp)], [Hz], [Brightness of the tail: low value = dark reverb],
  [`roomdim` (rdim)], [Hz], [how dark the tail gets at the end],
  [`iresponse` (ir)], [sample], [a recorded real room as reverb (convolution reverb)],
)

*Sliders:* `LEVEL11`, `SIZE11` (0.5 / 2 / 4 / 8), `DARK` (16 / 5 / 1.5 kHz), `ONKICK` (0 = reverb only on clap and stab, 1 = on the kick too).

#listen[
  + `LEVEL11` 0 → 0.6 at `SIZE11` 2: the stab moves back.
  + `DARK` 0 against 2 with lots of reverb: a dark reverb is there but does not get in the way.
  + `ONKICK` 1: the low end gets washed out, the kick loses its punch.
]

#scene[Techno almost always keeps the kick dry; reverb belongs on clap, stabs, percussion and pads, usually darkened and high-passed (the low end in a reverb is mud). Exception: hypnotic and dub techno deliberately put filtered reverb on the kick to create the "rumble". In house, short rooms on drums and long tails on vocals and pads are typical.]

#pitfall[`roomsize`, `roomlp`, `roomfade` and `roomdim` *rebuild the reverb* when their value changes. That costs CPU and can click. Do not ride them like a knob; set fixed values per orbit instead. And: reverb is global per orbit (chapter 12).]

// ============================================================
= Part F: Routing and dynamics

== Chapter 12: Orbits – why effects steal from each other

*What it does.* Most effects are *local*: every note gets its own filter, its own distortion. Delay and reverb are *global*: there is only *one* delay and *one* reverb per *orbit*, and all sounds on this orbit share it. If two sounds on the same orbit use different room sizes or delay times, the latest note decides for all of them.

*Slider:* `FIX` 0 = everything on orbit 1: the stab wants a huge hall (size 8) and a dotted delay, the hats a tiny room and a 1/16 delay. They overwrite each other. `FIX` 1 = the stab gets orbit 2, both keep their settings.

#listen[
  + Switch `FIX` 0 / 1 and listen to the stab's tail: at 0 the hall keeps collapsing, the echoes jump.
]

#remember[One orbit per *kind of space*: for example 1 = dry drums, 2 = stabs and pads with reverb, 3 = delays. Within an orbit use the same `roomsize`, `roomlp` and `delaytime` everywhere. This also saves CPU, because the reverb is not rebuilt all the time.]

#scene[This matches the *send effects* of a mixer or a DAW: a reverb bus and a delay bus that every channel sends more or less to. Practically all techno and house productions and live setups work this way.]

== Chapter 13: Sidechain and ducking – the pumping house sound

*What it does.* With *ducking* every kick hit pushes a whole orbit down in level, and it then comes back up. Originally a trick so kick and bass do not get in each other's way (*sidechain compression*); then it became a sound of its own: the pumping.

#fig(
  plot(w: 64mm, h: 22mm, curves: ((sample(x => 0.92 - 0.75 * calc.exp(-calc.rem(x * 4, 1) * 9)), blue),), bars: range(4).map(i => (i / 4 + 0.005, 0.98, orange)), xl: [Level of the pad over one bar; orange = kick]),
  [Each kick pushes the level down (`duckdepth`); how fast it comes back is set by `duckattack`.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Range*], [*Effect*],
  [`duckorbit` (duck)], [orbit number(s), e.g. `2` or `"2:3"`], [which orbit gets ducked. Goes on the *kick*],
  [`duckdepth`], [0–1], [how deep it goes down],
  [`duckattack` (duckatt, datt)], [seconds], [how fast it comes back up],
  [`duckonset`], [seconds], [how fast it goes down],
)

*Sliders:* `DEPTH13`, `RETURN` (return time). The kick (orbit 1) ducks orbit 2, where pad and bass play.

#listen[
  + `DEPTH13` 0 against 0.8.
  + `RETURN` 0.05 (tight) against 0.3: at 0.3 the pad "breathes" in quarters.
]

#scene[Strong pumping is the sound of French house (Daft Punk, Stardust) and many modern house tracks. In techno ducking is subtler: it makes room for the kick in the bass, so kick and bass can both be loud without covering each other.]

== Chapter 14: Compressor – punch and sustain of single hits

*What it does.* A compressor makes loud parts quieter: everything above the *threshold* (in dB) is reduced by the *ratio*. At ratio 4, 4 dB above the threshold become 1 dB. Quiet parts stay, the sound gets more even and denser.

#fig(
  plot(w: 46mm, h: 30mm, curves: ((((0, 0), (1, 1)), luma(170)), (((0, 0), (0.6, 0.6), (1, 0.7)), blue)), vlines: (0.6,), xl: [Input (dB) → output (dB)]),
  [Grey: without compressor. Blue: threshold at the dashed line, ratio 4. Above the threshold the output grows only a quarter as fast.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Range*], [*Effect*],
  [`compressor`], [dB, e.g. −20], [Threshold],
  [`compressorRatio`], [1–20], [Strength],
  [`compressorKnee`], [dB], [soft transition at the threshold],
  [`compressorAttack`], [seconds], [how fast it grabs. *Slow = more punch* (the attack slips through)],
  [`compressorRelease`], [seconds], [how fast it lets go],
)

Shorthand: `compressor("-20:4:6:.01:.1")` = threshold, ratio, knee, attack, release.

*Sliders:* `THRESH`, `RATIO`, `ATTACK14`, `RELEASE14`, `MAKEUP` (level afterwards, `postgain`). The compressor sits on the drums.

#listen[
  + `THRESH` −40, `RATIO` 10, then `ATTACK14` 0.001 against 0.03: flat against snappy.
  + `MAKEUP` up: the tails of hats and clap get louder, the drums sound denser.
]

#pitfall[In Strudel the compressor works *per note* (local), not on the whole mix. So it shapes each hit on its own (punch, sustain), but it is no "glue" for the mix. In Strudel, ducking makes room in the mix (chapter 13).]

#scene[Compression is everywhere in techno and house: on kicks for punch, on drum buses for density, on the master for loudness. In Strudel you mostly use it to make single drums snappier or fuller.]

== Chapter 15: Stereo – pan, jux

*What it does.* `pan` places a sound between left (0), center (0.5) and right (1). `jux` plays a changed copy on the right only; `juxBy` sets how far apart the two sides are.

*Sliders:* `MOVE` (hats wander from left to right, auto-pan), `WIDTH` (the stab gets a copy a few milliseconds later on one side: it sounds wide, *Haas effect*).

#listen[
  + With headphones: `MOVE` 0 → 1, `WIDTH` 0 → 1.
]

#scene[Club systems often play (almost) mono, and low frequencies cannot be located anyway. So the rule is: *kick, bass and clap in the center*, only hats, percussion, pads and effects go wide. Wide sounds can get thinner in mono. Auto-pan on percussion is a typical means of movement in minimal and tech house.]

== Chapter 16: Performance chain – the effects you ride live

*What it does.* Live you rarely move twenty parameters. These five macros cover most techno and house moves and match the controls of a stem in your tracks (`col(n)`: hpf, lpf, char, level):

#tbl(
  (auto, 1fr, 1fr),
  [*Slider*], [*Effect*], [*Live use*],
  [`HP`], [high-pass on the music], [build-up, thinning out],
  [`LP`], [low-pass on stab and lead (the bass keeps its own)], [sweeps, darkness],
  [`CHAR`], [distortion on the bass + resonance on the filter], ["character", drive],
  [`SPACE`], [reverb and delay on the stab], [width, transitions],
  [`PUMP`], [ducking depth from the kick], [groove, room for the kick],
)

#listen[
  Build a 32-bar arc: start with `LP` 0.3 and `SPACE` 0.2. Open `LP` over 16 bars, add `CHAR`. Then raise `HP` for four bars and let it fall back with high `PUMP`. Afterwards think about which macro belongs on which control.
]

// ============================================================
= Appendix

== Recipes

#tbl(
  (auto, 1fr),
  [*Sound*], [*Ingredients*],
  [Acid bass], [`s('sawtooth')`, 16ths, `.lpf(300).fanchor(0).lpenv(4).lpd(.15).lps(0).lpq(15).ftype('ladder')`, accents with `velocity`, a bit of `distort` (diode)],
  [Dub techno chord], [m7/m9 or stacked fourths, very short (`decay(.2).sustain(0)`), `lpf` 800–1500, `delay(.5).delaytime(dotted 1/8).delayfeedback(.6)`, own orbit with dark reverb],
  [Rumble kick], [kick + `distort` + own orbit with lots of reverb, `roomlp` low (300–600 Hz), let the reverb pump via ducking from the dry kick],
  [Synth kick], [`note('a1').s('sine').penv(36).pdecay(.08).pcurve(1).decay(.35).sustain(0)`],
  [Pumping pad], [pad on its own orbit, kick with `duckorbit(n).duckdepth(.8).duckattack(.25)`],
  [Trance gate], [held chord, `tremolosync(16).tremoloshape('square').tremolodepth(1)`],
  [Build-up], [`hpf` over 8–16 bars from 20 to 1000–2000 Hz, raise `room` with it, at the drop everything back at once],
  [Telephone/radio], [`bpf(1500).bpq(4)`, a bit of `crush(8)`],
)

== Practice plan

#tbl(
  (auto, auto, 1fr),
  [*Session*], [*Chapters*], [*Goal*],
  [1], [0, 1, 2], [hear frequency ranges; accents; recognise envelopes],
  [2], [3, 4], [filter sweeps, build-up with high-pass],
  [3], [5, 6], [acid and kick building: envelopes on filter and pitch],
  [4], [7, 8], [saturation to destruction; vowel],
  [5], [9, 10, 11], [movement and space],
  [6], [12, 13, 14, 15], [routing, ducking, compression, stereo],
  [after that], [16], [practise performance arcs, then carry them over to your own tracks],
)

After that: in a track of your own, think for each stem about *which frequency range* it lives in, *which space* it gets (orbit) and *which effect* belongs on its live control.

== Effect reference (all parameters of the Strudel effects page)

#tbl(
  (auto, 1fr),
  [*Group*], [*Parameters (aliases in brackets)*],
  [Filters], [`lpf` (cutoff, ctf, lp), `lpq` (resonance), `hpf` (hp, hcutoff), `hpq` (hresonance), `bpf` (bandf, bp), `bpq` (bandq), `ftype` (12db, ladder, 24db), `vowel`],
  [Filter envelopes], [`lpattack lpdecay lpsustain lprelease lpenv` (lpa lpd lps lpr lpe), the same with `hp…` and `bp…`, `fanchor`],
  [Amplitude envelope], [`attack` (att), `decay` (dec), `sustain` (sus), `release` (rel), `adsr("a:d:s:r")`, `clip`],
  [Pitch envelope], [`penv`, `pattack` (patt), `pdecay` (pdec), `prelease` (prel), `pcurve`, `panchor`],
  [Amplitude modulation], [`tremolo` (trem), `tremolosync`, `tremolodepth`, `tremoloskew`, `tremolophase`, `tremoloshape`],
  [Dynamics], [`gain`, `velocity` (vel), `postgain`, `compressor` (+ `compressorRatio Knee Attack Release`), `xfade`],
  [Stereo], [`pan`, `jux`, `juxBy`],
  [Waveshaping], [`distort` (dist; + `distorttype`, `distortvol`), `crush`, `coarse`, `shape` (deprecated)],
  [Global (per orbit)], [`orbit` (o), `delay`, `delaytime` (delayt, dt), `delayfeedback` (delayfb, dfb), `room`, `roomsize` (rsize, sz, size), `roomfade` (rfade), `roomlp` (rlp), `roomdim` (rdim), `iresponse` (ir), `phaser` (ph), `phaserdepth`, `phasercenter`, `phasersweep`, `duckorbit` (duck), `duckattack`, `duckdepth`, `duckonset`],
)

Shorthands with a colon: `lpf("1000:10")` = cutoff and resonance, `delay(".5:.375:.6")` = amount, time, feedback, `room(".6:4")` = amount, size.

== Glossary

#tbl(
  (auto, 1fr),
  [*Term*], [*Meaning*],
  [frequency], [vibrations per second (Hz); sets the pitch],
  [overtones, harmonics], [multiples of the fundamental, they make the timbre],
  [decibel (dB)], [measure of level ratios; +6 dB ≈ double amplitude],
  [envelope (ADSR)], [course of a value over one note: attack, decay, sustain, release],
  [low-pass, high-pass, band-pass], [filters that remove the highs, the lows, or everything except one band],
  [cutoff], [corner frequency of a filter],
  [resonance, Q], [boost at the cutoff],
  [saturation, distortion], [bending the wave, creates new overtones],
  [formant], [resonance range that makes up a vowel],
  [LFO], [low frequency oscillator: slow wave that moves a parameter],
  [reverb, delay], [space made of many echoes; single echoes in time],
  [dry, wet], [original and effect share],
  [orbit, send/bus], [shared effect channel for several sounds],
  [ducking, sidechain], [one signal (kick) pushes another one down in level],
  [compressor], [makes loud parts quieter, the sound denser],
  [clipping], [cutting off above 0 dB],
  [aliasing], [false, metallic tones from too low a sample rate],
)
