// Handbook for effects-tutorial.strudel (every Strudel effect, by ear, with its role in techno and house).
// Compile: typst compile effects-tutorial.typ

#set document(title: "Effekte-Tutorial: Handbuch")
#set page(paper: "a4", margin: (x: 20mm, y: 18mm), numbering: "1")
#set text(font: "Helvetica", size: 9.8pt, lang: "de")
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
#let merke(body) = box-of(blue, "Merke:", body)
#let hoeren(body) = box-of(orange, "Hören:", body)
#let szene(body) = box-of(green, "In Techno und House:", body)
#let falle(body) = box-of(red, "Stolperfalle in Strudel:", body)

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
  #text(size: 22pt, weight: "bold")[Effekte-Tutorial]
  #v(-0.5em)
  #text(size: 12pt, fill: luma(90))[Was jeder Strudel-Effekt macht, wie er klingt und welche Rolle er in Techno und House spielt]
  #v(-0.3em)
  #text(size: 9pt, fill: luma(110))[Handbuch zu `lab/tutorials/effects-tutorial.strudel`]
]

#v(0.5em)
#outline(title: [Inhalt], depth: 2, indent: 1em)

= So arbeitest du mit dem Tutorial

== Bedienung

+ Öffne `effects-tutorial.strudel` in Strudel und stelle oben `const CHAPTER = 0` auf das gewünschte Kapitel (0 bis 16). Einmal auswerten (Strg+Enter).
+ Danach nur die *Slider dieses Kapitels* bewegen. Die Slider der anderen Kapitel sind sichtbar, tun aber nichts.
+ Unter der letzten Zeile zeigt ein *Spektrum*, welche Frequenzen gerade klingen: links tief (Bass), rechts hoch (Hi-Hats). Bei Filtern und Verzerrung siehst du dort direkt, was passiert.
+ Jedes Kapitel bringt seine eigenen Drums mit. Wer sie stummschalten will, kommentiert die Drum-Zeile des Kapitels aus.

Alle Kapitel benutzen denselben trockenen Groove (Kick, Hats, Clap, Bass, Akkord-Stab, Lead in A-Moll, 122 BPM). So hörst du jeden Effekt auf bekanntem Material.

== Wie man Effekte hören lernt

- *Immer hin und zurück.* Effekte hört man im Vergleich, nicht im Zustand. Also: Effekt an, vier Takte, aus, vier Takte.
- *Langsam bewegen.* Viele Effekte wirken erst, wenn man den Regler über mehrere Takte fährt (Filter, Delay-Feedback, Hall).
- *Leise hören.* Lauter klingt immer „besser“. Vergleiche Effekte bei gleicher Lautstärke, sonst täuscht dich das Ohr. Einige Kapitel gleichen die Lautstärke dafür automatisch aus.
- *Kopfhörer und Lautsprecher.* Stereo (Kapitel 15) und Sub-Bass (Kapitel 0, 6) hört man auf Laptop-Lautsprechern gar nicht.
- *Fragen stellen:* Was ändert sich: Lautstärke, Helligkeit, Länge, Raum, Bewegung? Dieses Raster ordnet jeden Effekt ein.

= Grundbegriffe

== Was ein Klang ist

Ein Klang ist eine Schwingung der Luft. Wie schnell sie schwingt, ist die *Frequenz*, gemessen in Hertz (Hz, Schwingungen pro Sekunde). Wir hören etwa 20 Hz bis 20.000 Hz (20 kHz). Tief = langsam, hoch = schnell. Eine Verdopplung der Frequenz ist eine *Oktave*. Das Ohr hört in Oktaven, nicht in Hz: Der Schritt von 100 auf 200 Hz klingt so groß wie der von 5000 auf 10000 Hz. Deshalb sind alle Frequenz-Slider im Tutorial exponentiell skaliert.

Ein Ton besteht fast nie aus nur einer Frequenz. Über dem *Grundton* liegen *Obertöne* (Vielfache der Grundfrequenz). Ihre Mischung macht die *Klangfarbe*: Eine Sinuswelle hat keine Obertöne (rund, dumpf), eine Sägezahnwelle sehr viele (hell, sägend). Fast alle Effekte arbeiten mit diesen Obertönen: Filter nehmen welche weg, Verzerrung fügt welche hinzu.

#grid(columns: (1fr, 1fr, 1fr), column-gutter: 3mm,
  plot(w: 46mm, h: 18mm, curves: ((wave(v => v), blue),), xl: [Sinus: nur der Grundton]),
  plot(w: 46mm, h: 18mm, curves: ((sample(x => 0.5 + 0.45 * (2 * calc.rem(2 * x, 1) - 1)), blue),), xl: [Sägezahn: alle Obertöne, hell]),
  plot(w: 46mm, h: 18mm, curves: ((sample(x => if calc.rem(2 * x, 1) < 0.5 { 0.92 } else { 0.08 }), blue),), xl: [Rechteck: ungerade Obertöne, hohl]),
)

== Frequenzbereiche

#tbl(
  (auto, auto, 1fr),
  [*Bereich*], [*ungefähr*], [*Was dort lebt*],
  [Sub], [20–60 Hz], [Kick-Körper, Sub-Bass. Mehr gefühlt als gehört; kleine Lautsprecher können es nicht],
  [Bass], [60–250 Hz], [Kick-Punch, Basstöne, Wärme],
  [Untere Mitten], [250–800 Hz], [Körper von Akkorden und Bass; zu viel davon = „Matsch“],
  [Mitten], [0,8–2,5 kHz], [Akkorde, Leads, Clap, Stimme: das, was ein Handy-Lautsprecher spielt],
  [Präsenz], [2,5–6 kHz], [Anschlag, Clap-Schnalzen, Hats: macht Klänge „nah“],
  [Luft], [6–20 kHz], [Hat-Zischen, Glanz, Atem],
)

== Lautstärke und Dezibel

Lautstärke misst man in *Dezibel (dB)*. Auch das ist eine Verhältnisskala: +6 dB ist etwa doppelte Amplitude, +10 dB klingt etwa doppelt so laut. 0 dB ist in der digitalen Welt die Obergrenze; darüber wird das Signal abgeschnitten (*Clipping*, hässliche Verzerrung).

== Trocken und nass, lokal und global

- *Dry/Wet:* Das unbearbeitete Signal heißt *dry* (trocken), der Anteil eines Effekts *wet* (nass). Bei Delay und Hall stellst du in Strudel nur den Wet-Anteil ein (`delay`, `room`); das trockene Signal bleibt immer.
- *Lokal:* Die meisten Effekte bekommt jede Note einzeln (eigener Filter, eigene Verzerrung, eigene Hüllkurve).
- *Global:* Delay, Hall und Ducking gibt es nur einmal pro *Orbit* (eine Art Mischpult-Kanal). Alle Klänge auf demselben Orbit teilen sie sich (Kapitel 12).

== Die Signalkette in Strudel

Strudel schickt jede Note durch eine feste Reihenfolge. Jeder Effekt kommt darin genau *einmal* vor, auch wenn du ihn zweimal aufrufst (der zweite Aufruf überschreibt den ersten).

#block(width: 100%, inset: 6pt, radius: 3pt, stroke: 0.4pt + luma(180))[
  #chain-box[Klangquelle (Sample/Synth, Pitch-Hüllkurve)] #arr #chain-box[gain + ADSR] #arr #chain-box[lpf] #arr #chain-box[hpf] #arr #chain-box[bpf] #arr #chain-box[vowel] #arr #chain-box[coarse] #arr #chain-box[crush] #arr #chain-box[shape / distort] #arr #chain-box[tremolo] #arr #chain-box[compressor] #arr #chain-box[pan] #arr #chain-box[phaser] #arr #chain-box[postgain]
  #v(0.3em)
  #arr #chain-box(c: blue.lighten(80%))[Orbit: dry + delay + reverb] #arr #chain-box(c: blue.lighten(80%))[duck] #arr #chain-box(c: blue.lighten(80%))[Mischpult / Ausgang]
]

Wichtig daraus:
- *Die Reihenfolge ist fest.* Der Filter kommt immer *vor* der Verzerrung. „Erst verzerren, dann filtern“ geht in Strudel nicht in einer Kette.
- *Werte werden beim Notenstart gelesen.* Ein Slider oder ein LFO auf `lpf` wirkt erst ab der nächsten Note. Bei langen Noten (Pads) springt der Wert deshalb nur einmal pro Note. Kontinuierlich *innerhalb* einer Note laufen nur: ADSR, Filter- und Pitch-Hüllkurven, Tremolo, Phaser, Vibrato und Ducking.

// ============================================================
= Teil A: Hören lernen

== Kapitel 0: Frequenzen – wo jeder Klang wohnt

*Was passiert.* Der ganze Groove läuft durch einen schmalen Bandpass (Kapitel 4), der nur einen Bereich durchlässt. So hörst du nacheinander, welches Instrument in welchem Bereich lebt.

*Slider:* `BAND` 0 = alles, 1 = Sub 50 Hz, 2 = Bass 120 Hz, 3 = untere Mitten 400 Hz, 4 = Mitten 1,2 kHz, 5 = Präsenz 4 kHz, 6 = Luft 10 kHz.

#hoeren[
  + Schritt für Schritt von 1 bis 6, je vier Takte. Wo ist die Kick? Wo der Bass? Wo die Hats? Wo der Stab?
  + Die Kick taucht in mehreren Bändern auf: unten ihr Körper, oben ihr Klick. Fast jeder Klang hat mehrere Bereiche.
  + Zurück zu 0: Jetzt hörst du die Schichten im vollen Mix leichter heraus.
]

#szene[Ein Techno-Mix funktioniert, wenn jeder Bereich *einem* Hauptdarsteller gehört: Sub und Bass der Kick und dem Bass (die sich abwechseln oder per Ducking Platz machen), die Mitten den Stabs und Leads, die Höhen den Hats. Fast alle Filter-Entscheidungen später folgen aus dieser Aufteilung.]

== Kapitel 1: Lautstärke und Akzente – gain, velocity, postgain

*Was es macht.* Drei Lautstärke-Regler an verschiedenen Stellen der Kette:

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Bereich*], [*Wirkung*],
  [`gain`], [0–1 (mehr geht, wird lauter)], [Lautstärke der Note, vor allen Effekten. Auf einer Kurve: 0,5 ist deutlich leiser, nicht „halb“],
  [`velocity`], [0–1], [wird mit `gain` multipliziert. Gedacht für Akzente: wie hart ein Schlag gespielt ist],
  [`postgain`], [0–… (1 = unverändert)], [Lautstärke *nach* allen Effekten],
)

Der Unterschied zwischen `gain` und `postgain` ist wichtig, sobald Verzerrung im Spiel ist: Mehr `gain` vor einer Verzerrung macht sie *stärker*, mehr `postgain` macht sie nur *lauter*.

*Slider:* `ACCENT` (wie viel leiser die Off-Beat-16tel der Hats sind), `BASSLEVEL` (gain des Basses).

#hoeren[
  + `ACCENT` 0 → 0,6 → 1. Der Rhythmus bleibt gleich, aber der Groove ändert sich. Bei 0 klingt es wie eine Maschine, bei 0,6 „läuft“ es.
  + `BASSLEVEL` hoch und runter: Ab wann wirkt der Bass so groß wie die Kick? Ab wann verdeckt er sie?
]

#szene[Akzente sind das wichtigste Werkzeug für Groove bei Hats und Percussion: Eine 16tel-Hat mit Akzent auf jeder zweiten oder vierten Note treibt, eine ohne wirkt steif. Lautstärke-Balance (Leveling) ist die halbe Arbeit an einem Mix; dafür gibt es im Projekt auch `/strudel-mix`.]

== Kapitel 2: Hüllkurve – attack, decay, sustain, release

*Was es macht.* Eine *Hüllkurve* (ADSR) formt die Lautstärke *einer einzelnen Note* über die Zeit:

#fig(
  plot(w: 60mm, h: 24mm, curves: ((adsr(0.08, 0.25, 0.55, 0.9, 0.5, 1.6), blue),), vlines: (0.9 / 1.6,), xl: [A · D · S (solange gehalten) · R ab Notenende (gestrichelt)]),
  [*Attack:* Zeit von Stille bis voll. *Decay:* Zeit bis zum Sustain-Pegel. *Sustain:* Pegel, solange die Note gehalten wird (0–1). *Release:* Ausklingzeit nach dem Ende der Note.],
)

#tbl(
  (auto, auto, auto, auto, auto, 1fr),
  [*Preset*], [*A*], [*D*], [*S*], [*R*], [*Klang*],
  [Pluck], [0], [0,15], [0], [0,1], [gezupft, kurz],
  [Techno-Stab], [0], [0,25], [0], [0,3], [kurz mit etwas Schwanz],
  [Orgel], [0], [0], [1], [0,05], [an/aus, wie eine Taste],
  [Pad], [0,5], [0,5], [0,7], [1,5], [weich ein- und ausblendend (LEN 4)],
  [Swell], [1], [0], [1], [0,5], [schwillt an (LEN 4)],
)

*Slider:* `ATT`, `DEC`, `SUS`, `REL` (Sekunden bzw. Pegel), `LEN` = wie lange jede Note gehalten wird (`clip`: 1 = ganzer Platz, 4 = überlappend).

#hoeren[
  + Mit dem Stab-Preset starten und nur `SUS` von 0 auf 1 fahren: vom Stab zur Orgel.
  + `ATT` hochziehen: Der Anschlag (Punch) verschwindet, der Klang rückt nach hinten.
  + `ATT` = 0,5 bei `LEN` = 1, dann `LEN` = 4: Die Note muss lang genug sein, sonst erreicht der Attack nie die volle Lautstärke.
]

#szene[Kurze Hüllkurven (Attack 0, Sustain 0) sind die Sprache von Techno: Stabs, Plucks, Percussion. Lange Attacks und Releases machen Pads und Flächen (Deep House, Ambient-Breaks). Der *Decay* ist dein Regler für „Länge“ eines Stabs: Live gefahren macht er einen Stab von trocken zu ausladend.]

#falle[`release` wirkt erst *nach* dem Notenende. Ein langer Release bei vielen kurzen Noten lässt sie überlappen und kostet Rechenleistung.]

// ============================================================
= Teil B: Filter

== Kapitel 3: Tiefpass – lpf, lpq, ftype

*Was es macht.* Ein *Tiefpass* (Low-Pass) lässt die tiefen Frequenzen durch und nimmt alles über der *Cutoff-Frequenz* weg. Zu: dunkel, dumpf, weit weg. Offen: hell, nah, aggressiv. Die *Resonanz* (Q) hebt die Frequenzen genau am Cutoff an: von weich bis „pfeifend“ oder „quietschend“.

#fig(
  plot(w: 60mm, h: 26mm, curves: ((sample(resp("lp", 800, 0.7)), blue), (sample(resp("lp", 800, 6)), orange)), vlines: (fx(800),), xl: [20 Hz … 20 kHz; Cutoff 800 Hz]),
  [Blau: Tiefpass ohne Resonanz (Q 0,7). Orange: mit Resonanz (Q 6): Spitze am Cutoff. Rechts vom Cutoff fällt alles ab.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Bereich*], [*Wirkung*],
  [`lpf` (cutoff, lp)], [20–20000 Hz], [Cutoff-Frequenz],
  [`lpq` (resonance)], [0–50, sinnvoll 0–25], [Resonanz am Cutoff],
  [`ftype`], [`12db`, `ladder`, `24db`], [Steilheit: 12db sanft, 24db steil, ladder = Moog-artig, fett, aggressiver],
)

*Slider:* `CUT` (0 = 60 Hz, 0,5 = 775 Hz, 1 = 10 kHz), `RES`, `FTYPE`. Der Filter liegt auf Bass, Stab und Lead; die Drums bleiben trocken.

#hoeren[
  + `CUT` langsam von 1 auf 0,2 und zurück, über acht Takte. Das ist der klassische Filter-Sweep.
  + `RES` auf 15, noch einmal sweepen: Jetzt „singt“ der Cutoff.
  + Bei `RES` 10 die drei `FTYPE`s vergleichen.
]

#szene[Der Tiefpass ist *der* Live-Regler in Techno und House. Ein langsamer Sweep über 16 oder 32 Takte ist eine eigene Spannungskurve: Der Track baut sich auf, ohne dass ein neuer Ton dazukommt. Auf Pads und Stabs hält ein halb geschlossener Filter Platz für Hats und Vocals frei.]

#falle[Ein LFO oder Slider auf `lpf` wird nur beim Notenstart gelesen (siehe Kapitel 9). Für Bewegung *innerhalb* einer langen Note nimm die Filterhüllkurve (Kapitel 5).]

== Kapitel 4: Hochpass und Bandpass – hpf, bpf

*Was es macht.* Der *Hochpass* (High-Pass) ist das Gegenstück: Er nimmt alles *unter* dem Cutoff weg. Der *Bandpass* lässt nur ein Band um eine Mittenfrequenz durch („Telefon“- oder „Radio“-Klang).

#grid(columns: (1fr, 1fr), column-gutter: 4mm,
  plot(w: 70mm, h: 22mm, curves: ((sample(resp("hp", 400, 0.7)), blue),), vlines: (fx(400),), xl: [Hochpass 400 Hz: Bässe weg]),
  plot(w: 70mm, h: 22mm, curves: ((sample(resp("bp", 1000, 4)), blue),), vlines: (fx(1000),), xl: [Bandpass 1 kHz, Q 4: nur ein Band bleibt]),
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Bereich*], [*Wirkung*],
  [`hpf` (hp, hcutoff)], [20–20000 Hz], [Hochpass-Cutoff],
  [`hpq` (hresonance)], [0–50], [Resonanz des Hochpasses],
  [`bpf` (bandf, bp)], [Hz], [Mittenfrequenz des Bandpasses],
  [`bpq` (bandq)], [0–…], [Breite: hoch = schmal],
)

*Slider:* `MODE4` 0 = Hochpass auf dem ganzen Groove, 1 = nur auf Stab und Lead (Aufräumen), 2 = Bandpass auf dem Stab. `FREQ4` 0 = 20 Hz, 0,5 = 400 Hz, 1 = 8 kHz.

#hoeren[
  + `MODE4` 0: `FREQ4` vier Takte lang auf 0,6 schieben, dann auf einem Taktanfang schlagartig auf 0. Das ist ein Drop.
  + `MODE4` 1, `FREQ4` um 0,5: Der Mix wird klarer, der Bass wirkt größer, obwohl am Bass nichts geändert wurde.
  + `MODE4` 2: Der Stab wird dünn und nasal, sticht aber heraus, ohne lauter zu sein.
]

#szene[Der Hochpass ist das Werkzeug für *Build-ups*: Kick und Bass verschwinden langsam, die Spannung steigt, beim Drop kommen sie zurück. DJ-Mixer haben genau diesen Regler. Im Mix räumt ein Hochpass auf Pads, Stabs, Hats und Hall die Bässe frei, damit Kick und Bass den Platz unten allein haben. Bandpässe machen Klänge „klein“: Breaks, Radio-Effekte, Percussion.]

== Kapitel 5: Filterhüllkurve und Acid – lpenv, lpattack, lpdecay

*Was es macht.* Eine *Filterhüllkurve* öffnet den Filter am Anfang jeder Note und schließt ihn wieder. Wie eine Hand, die bei jeder Note blitzschnell am Cutoff-Regler dreht. Jede Note bekommt dadurch ein „Wau“ oder „Pjuu“.

#fig(
  plot(w: 60mm, h: 24mm, curves: ((sample(x => 0.15 + 0.75 * calc.exp(-calc.rem(x * 4, 1) * 7)), orange),), xl: [Cutoff über vier Noten: Sprung hoch, Abfall mit lpdecay]),
  [Der Cutoff ruht bei `lpf` und springt bei jedem Notenstart um `lpenv` Oktaven nach oben, dann fällt er mit `lpdecay` zurück.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Bereich*], [*Wirkung*],
  [`lpenv` (lpe)], [0–8, auch negativ], [Hub in Oktaven über dem Cutoff (negativ: nach unten)],
  [`lpattack` (lpa)], [Sekunden], [wie schnell der Filter aufgeht],
  [`lpdecay` (lpd)], [Sekunden], [wie schnell er wieder zugeht],
  [`lpsustain` (lps)], [0–1], [wie weit offen er während der Note bleibt],
  [`lprelease` (lpr)], [Sekunden], [Schließen nach Notenende],
  [`fanchor`], [0–1], [wo der Cutoff im Hub liegt: 0 = Cutoff ist der geschlossene Wert (so im Tutorial)],
)

Dasselbe gibt es für Hochpass (`hpenv`, `hpa` …) und Bandpass (`bpenv`, `bpa` …).

*Acid.* Tiefpass + Filterhüllkurve + viel Resonanz auf einer Sägezahn-Bassline in 16teln: das ist der Klang der Roland TB-303. Die Akzente (`velocity`) lassen manche Noten weiter aufgehen, wie der Accent-Knopf der 303.

*Slider:* `CUT5` (Ruhe-Cutoff, 40 Hz–4 kHz), `ENV` (Hub in Oktaven), `DECAY5`, `RES5`.

#hoeren[
  + `ENV` 0 → 4: Die Linie erwacht zum Leben.
  + `DECAY5` 0,05 (Ticken) gegen 0,4 (Wauen).
  + `RES5` 0 gegen 20: von weich zu quietschend.
  + Der Acid-Live-Move: `CUT5` und `RES5` über 16 Takte langsam gemeinsam hochfahren.
]

#szene[Acid ist ein eigenes Genre (Acid House, Acid Techno), aber die Technik steckt überall: Plucks, Stabs und Basslines bekommen durch eine kurze Filterhüllkurve Biss. Live gespielt sind Cutoff, Resonanz und Decay die drei Regler, mit denen eine einzige Bassline einen ganzen Track trägt.]

== Kapitel 6: Pitch-Hüllkurve – eine Kick aus einem Sinus bauen

*Was es macht.* Eine *Pitch-Hüllkurve* biegt die Tonhöhe jeder Note: Sie startet höher und fällt auf den eigentlichen Ton. Eine Kick ist genau das: ein tiefer Sinus (hier A1 = 55 Hz), der viel höher beginnt und schnell abfällt.

#fig(
  plot(w: 60mm, h: 24mm, curves: ((sample(x => 0.1 + 0.85 * calc.exp(-x * 14)), blue), (sample(x => 0.1 + 0.85 * (1 - calc.min(x * 5, 1))), orange)), xl: [Tonhöhe über 0,3 s: blau exponentiell, orange linear]),
  [Mit `pcurve` = 1 (blau) fällt die Tonhöhe erst schnell, dann langsam: das klingt nach echter Kick. Linear (orange) klingt nach „Laser“.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Bereich*], [*Wirkung*],
  [`penv`], [Halbtöne, auch negativ], [um wie viel die Tonhöhe verbogen wird (36 = drei Oktaven)],
  [`pattack` (patt)], [Sekunden], [Zeit bis zum Höhepunkt der Biegung],
  [`pdecay` (pdec)], [Sekunden], [wie schnell die Tonhöhe fällt],
  [`prelease` (prel)], [Sekunden], [Biegung nach Notenende],
  [`pcurve`], [0 / 1], [linear oder exponentiell],
  [`panchor`], [0–1], [0 = Biegung über dem Ton, 1 = darunter],
)

*Slider:* `PENV`, `PDEC`, `PCURVE`, `KDEC` (Länge der Kick, Amplituden-Decay), `SOURCE` (0 = Synth-Kick, 1 = 909-Sample zum Vergleich).

#hoeren[
  + `PENV` 0: nur ein Sinus, ein dumpfes „Bup“. Dann 12, 24, 36.
  + `PDEC` 0,02 (kurzer Klick) gegen 0,3 („Boing“, Tom).
  + `KDEC` 0,15 (trocken) gegen 0,8 (dröhnender Techno-„Rumble“).
  + Die Kick ist auf A gestimmt, die Tonart des Basses. Hör, wie Kick und Bass verschmelzen.
]

#szene[Fast jede elektronische Kick ist ein Sinus mit Pitch-Hüllkurve (die 808 und 909 auch). Lange Kicks mit Verzerrung (Kapitel 7) und Hall sind der „Rumble“ von hartem und Hypno-Techno. Gestimmte Kicks (auf den Grundton) sind üblich. Dieselbe Technik macht Toms, Laser-Zaps und Riser.]

// ============================================================
= Teil C: Sättigung, Verzerrung, Farbe

== Kapitel 7: Drive – distort, crush, coarse

*Was es macht.* Verzerrung drückt eine Welle über ihre Grenze und biegt ihre Form. Eine verbogene Welle hat *neue Obertöne*: Der Klang wirkt lauter, heller, rauer, präsenter.

#grid(columns: (1fr, 1fr, 1fr, 1fr), column-gutter: 2mm,
  plot(w: 36mm, h: 16mm, curves: ((wave(v => v), blue),), xl: [Original]),
  plot(w: 36mm, h: 16mm, curves: ((wave(v => tanh(3 * v) / tanh(3)), blue),), xl: [soft: rund gesättigt]),
  plot(w: 36mm, h: 16mm, curves: ((wave(v => calc.clamp(2.5 * v, -1, 1)), blue),), xl: [hard: abgeschnitten]),
  plot(w: 36mm, h: 16mm, curves: ((wave(v => calc.sin(2.6 * v * calc.pi / 2)), blue),), xl: [fold: zurückgefaltet]),
)

#tbl(
  (auto, auto, 1fr, 1fr),
  [*TYPE7*], [*Effekt*], [*Was passiert*], [*Klang*],
  [0], [`distort` soft], [weiche Sättigung], [Band, Röhre: wärmer, fetter, „Kleber“],
  [1], [`distort` hard], [hartes Abschneiden], [aggressiv, schnarrend],
  [2], [`distort` diode], [wie eine übersteuerte Analogschaltung], [körnig; typisch für Acid- und Techno-Bässe],
  [3], [`distort` fold], [Welle wird zurückgefaltet], [metallisch, synthetisch, stark vom Amount abhängig],
  [4], [`crush`], [weniger Lautstärkestufen (16 Bit → 2 Bit)], [digital, körnig, Lo-Fi],
  [5], [`coarse`], [niedrigere Abtastrate], [Aliasing, robotisch, metallisches Pfeifen (am besten in Chrome)],
)

Weitere Typen für `distorttype`: `scurve`, `cubic`, `asym`, `sinefold`, `chebyshev`. Die Kurzschreibweise `distort("3:0.5:diode")` heißt: Menge 3, Lautstärke 0,5, Typ diode. Der ältere Effekt `shape` ist veraltet; `distort` ist berechenbarer.

*Slider:* `TYPE7`, `AMOUNT` (0–1, pro Typ skaliert), `TARGET` 0 = Bass, 1 = Drums, 2 = alles. Die Lautstärke wird ausgeglichen (`postgain`).

#hoeren[
  + `TARGET` 0, `TYPE7` 0, `AMOUNT` langsam hoch: Erst wird der Bass nur „größer“, später rau.
  + `TARGET` 1, `TYPE7` 2 oder 4: Die Drums werden hart und industriell.
  + `TYPE7` 4 und 5 mit `AMOUNT` 1: Lo-Fi bis kaputt.
]

#szene[Sättigung in kleinen Mengen liegt in Techno auf fast allem: Sie macht Klänge dichter und lässt sie auf kleinen Lautsprechern hörbar werden (die neuen Obertöne liegen höher als der Bass). Starke Verzerrung auf der Kick ist das Fundament von Hard Techno, Industrial und Schranz; verzerrte, gefilterte Kick-Fahnen sind der „Rumble“. Bitcrush und Coarse sind Farbe für Breaks, Percussion und Lo-Fi-House.]

#falle[Verzerrung kann *sehr laut* werden. Immer mit `postgain` oder dem zweiten Wert (`distort("4:0.5")`) ausgleichen. Und: Der Filter kommt in Strudel *vor* der Verzerrung; den rauen Klang hinterher wieder zu filtern geht nur auf einem anderen Weg (z. B. per Orbit-Hall mit `roomlp`).]

== Kapitel 8: Vowel – ein Formantfilter, der Synths „sprechen“ lässt

*Was es macht.* Unser Mund ist ein Filter: Die Vokale a, e, i, o, u unterscheiden sich nur darin, welche Frequenzen der Mundraum anhebt (die *Formanten*). `vowel` bildet diesen Filter nach, sodass ein Synth klingt, als würde er den Vokal sagen.

*Werte:* `a e i o u` und weitere (`ae aa oe ue y uh un en an on`). Wirkt am stärksten auf hellen Klängen (Sägezahn).

*Slider:* `VOWEL` 0 aus, 1–5 = a e i o u, 6 = wechselnde Vokale auf jeder Achtel („sprechen“).

#hoeren[
  + 0 → 1 → 5: von offen zu geschlossen.
  + 6: der „sprechende“ Bass.
]

#szene[Formant- und Vowel-Filter machen die „Yoi“- und „Wah“-Bässe in Techno, Electro und Tech House. Auf Stabs geben sie einen menschlichen, fast vokalen Charakter, ohne Vocal-Sample.]

// ============================================================
= Teil D: Bewegung

== Kapitel 9: Modulation – Filter-LFO, Tremolo, Gate, Phaser

*Was es macht.* Ein *LFO* (Low Frequency Oscillator) ist eine langsame Welle, die für dich an einem Regler dreht, immer wieder.

#tbl(
  (auto, auto, 1fr, 1fr),
  [*MOD*], [*Effekt*], [*Was passiert*], [*Einsatz*],
  [1], [Filter-LFO], [eine Sinuswelle bewegt den Cutoff], [Wah über mehrere Takte, lebendige Basslines],
  [2], [`tremolo` sinus], [Lautstärke geht auf und ab], [schwebende Pads, Vintage-Keys],
  [3], [`tremolo` square], [Lautstärke wird zerhackt], [Trance-Gate, rhythmische Pads],
  [4], [`phaser`], [kreisende Kerbfilter], [70er, Disco, psychedelisch, Hats und Pads],
)

#tbl(
  (auto, 1fr),
  [*Parameter*], [*Wirkung*],
  [`tremolosync`], [Geschwindigkeit pro Takt (Zyklus): 4 = viermal pro Takt],
  [`tremolo`], [Geschwindigkeit in Hz (nicht an das Tempo gebunden)],
  [`tremolodepth`, `tremoloshape`, `tremoloskew`, `tremolophase`], [Tiefe; Form (`sine tri square saw ramp`); Schiefe; Startpunkt],
  [`phaser`, `phaserdepth`, `phasercenter`, `phasersweep`], [Geschwindigkeit (Hz); Tiefe (Standard 0,75); Mittenfrequenz (1000 Hz); Hub (2000 Hz)],
)

*Slider:* `MOD` (0–4), `SPEED` (0–4: 1, 2, 4, 8, 16 pro Takt; beim Filter-LFO ein Sweep alle 16, 8, 4, 2, 1 Takte; beim Phaser 0,25–4 Hz), `DEPTH`.

#falle[*Der wichtigste Strudel-Unterschied:* Werte wie `lpf` werden nur beim *Notenstart* gelesen. Der Filter-LFO (MOD 1) bewegt deshalb den Pad (ein Akkord = eine Note pro Takt) nur einmal pro Takt, den 16tel-Bass dagegen fließend. Tremolo, Phaser und alle Hüllkurven laufen dagegen *innerhalb* einer Note. Abhilfe für lange Noten: die Note mit `.seg(16)` in 16 Stücke schneiden, oder eine Filterhüllkurve benutzen.]

#hoeren[
  + `MOD` 1, `SPEED` 2: Achte darauf, dass der Bass fließt, der Pad aber springt.
  + `MOD` 3, `SPEED` 3 und 4: Rhythmus aus einem gehaltenen Akkord.
  + `MOD` 4, `SPEED` 0: der langsame Phaser-Schwung.
]

#szene[Bewegung ist in repetitiver Musik alles: Ein Loop, der sich nie ändert, ermüdet. LFOs auf Filter, Lautstärke oder Phaser lassen Loops atmen, ohne dass ein Ton dazukommt. Das Trance-Gate (Square-Tremolo in 16teln) ist ein eigener Klassiker; Phaser auf Hats und Pads ist typisch für Disco- und Deep House.]

// ============================================================
= Teil E: Raum

== Kapitel 10: Delay – Echos im Takt

*Was es macht.* Ein *Delay* nimmt den Klang auf und spielt ihn später wieder ab, immer wieder, jedes Mal leiser.

#fig(
  plot(w: 64mm, h: 22mm, bars: ((0.04, 0.95, blue),) + range(1, 7).map(i => (0.04 + i * 0.15, 0.95 * calc.pow(0.55, i), orange)), xl: [Original (blau) und Echos mit Feedback 0,55]),
  [Jedes Echo kommt nach `delaytime` und hat `delayfeedback` mal die Lautstärke des vorigen.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Bereich*], [*Wirkung*],
  [`delay`], [0–1], [Lautstärke der Echos (Wet-Anteil)],
  [`delaytime` (delayt, dt)], [Sekunden], [Abstand der Echos],
  [`delayfeedback` (delayfb, dfb)], [0–0,95], [wie viel jedes Echo wiederholt wird. Nie 1 oder mehr: wird immer lauter],
)

*Echo-Zeiten im Takt* (bei 122 BPM ist ein Schlag 0,49 s): 1/16 = 0,12 s, 1/8 = 0,25 s, *punktierte 1/8 = 0,37 s*, 1/4 = 0,49 s, Achteltriole = 0,16 s. In Strudel allgemein: `delaytime(60 / BPM * 0.75)` für eine punktierte Achtel.

*Slider:* `LEVEL10`, `TIME10` (0 = 1/16, 1 = 1/8, 2 = punktierte 1/8, 3 = 1/4, 4 = Achteltriole), `FEEDBACK`. Das Delay liegt nur auf dem sparsamen Stab und der Lead, auf Orbit 2.

#hoeren[
  + `TIME10` 2: Die Echos fallen zwischen die Schläge und erzeugen einen neuen, rollenden Rhythmus.
  + `TIME10` 3: Die Echos verstecken sich hinter der Kick.
  + `FEEDBACK` für einen Takt auf 0,8, dann zurück: ein „Delay-Throw“, ein klassischer Live-Move.
]

#szene[Die punktierte Achtel ist *das* Delay von Dub Techno und Deep House: Aus einem einzigen Akkord-Stab pro Takt wird eine ganze rhythmische Fläche (Basic Channel). In Techno sind Delays auf Percussion und Stabs ein Groove-Werkzeug; im Live-Set sind Delay-Throws (kurz viel Feedback auf ein einzelnes Element) ein Übergangs-Trick.]

== Kapitel 11: Hall – room, roomsize, roomlp

*Was es macht.* Hall (Reverb) ahmt einen Raum nach: Tausende winziger Echos verschmelzen zu einer Fahne. Hall setzt einen Klang in den Raum: trocken = nah und direkt, nass = weit weg und groß.

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Bereich*], [*Wirkung*],
  [`room`], [0–1], [Menge des Halls (Wet-Anteil)],
  [`roomsize` (size, sz, rsize)], [0–10], [Raumgröße: kleiner Raum … riesige Halle],
  [`roomfade` (rfade)], [Sekunden], [Ausklingzeit],
  [`roomlp` (rlp)], [Hz], [Helligkeit der Fahne: tiefer Wert = dunkler Hall],
  [`roomdim` (rdim)], [Hz], [wie dunkel die Fahne am Ende wird],
  [`iresponse` (ir)], [Sample], [ein aufgenommener echter Raum als Hall (Faltungshall)],
)

*Slider:* `LEVEL11`, `SIZE11` (0,5 / 2 / 4 / 8), `DARK` (16 / 5 / 1,5 kHz), `ONKICK` (0 = Hall nur auf Clap und Stab, 1 = auch auf der Kick).

#hoeren[
  + `LEVEL11` 0 → 0,6 bei `SIZE11` 2: Der Stab rückt nach hinten.
  + `DARK` 0 gegen 2 bei viel Hall: Ein dunkler Hall ist da, stört aber nicht.
  + `ONKICK` 1: Der Bassbereich wird verwaschen, die Kick verliert ihren Punch.
]

#szene[Techno hält die Kick fast immer trocken; Hall gehört auf Clap, Stabs, Percussion und Pads, meist abgedunkelt und mit Hochpass (der Bassbereich im Hall ist Matsch). Ausnahme: Hypno- und Dub-Techno legen bewusst gefilterten Hall auf die Kick, um den „Rumble“ zu erzeugen. In House sind kurze Räume auf Drums und lange Fahnen auf Vocals und Pads typisch.]

#falle[`roomsize`, `roomlp`, `roomfade` und `roomdim` *bauen den Hall neu*, wenn sich ihr Wert ändert. Das kostet Rechenleistung und kann knacksen. Nicht wie einen Regler fahren, sondern feste Werte pro Orbit setzen. Und: Hall ist global pro Orbit (Kapitel 12).]

// ============================================================
= Teil F: Routing und Dynamik

== Kapitel 12: Orbits – warum Effekte sich gegenseitig bestehlen

*Was es macht.* Die meisten Effekte sind *lokal*: Jede Note bekommt ihren eigenen Filter, ihre eigene Verzerrung. Delay und Hall sind *global*: Es gibt nur *ein* Delay und *einen* Hall pro *Orbit*, und alle Klänge auf diesem Orbit teilen ihn sich. Benutzen zwei Klänge auf demselben Orbit unterschiedliche Raumgrößen oder Delay-Zeiten, bestimmt die jeweils letzte Note für alle.

*Slider:* `FIX` 0 = alles auf Orbit 1: Der Stab will eine riesige Halle (Größe 8) und ein punktiertes Delay, die Hats einen winzigen Raum und ein 1/16-Delay. Sie überschreiben sich gegenseitig. `FIX` 1 = der Stab bekommt Orbit 2, beide behalten ihre Einstellungen.

#hoeren[
  + `FIX` 0 / 1 umschalten und auf die Fahne des Stabs achten: Bei 0 bricht die Halle immer wieder zusammen, die Echos springen.
]

#merke[Ein Orbit pro *Art von Raum*: zum Beispiel 1 = trockene Drums, 2 = Stabs und Pads mit Hall, 3 = Delays. Innerhalb eines Orbits überall dieselbe `roomsize`, `roomlp` und `delaytime`. Das spart auch Rechenleistung, weil der Hall nicht ständig neu gebaut wird.]

#szene[Das entspricht den *Send-Effekten* eines Mischpults oder einer DAW: ein Hall-Bus und ein Delay-Bus, zu denen man von jedem Kanal mehr oder weniger hinschickt. So arbeiten praktisch alle Techno- und House-Produktionen und Live-Setups.]

== Kapitel 13: Sidechain und Ducking – der pumpende House-Sound

*Was es macht.* Beim *Ducking* drückt jeder Kick-Schlag einen ganzen Orbit leiser, der dann wieder hochkommt. Ursprünglich ein Trick, damit Kick und Bass sich nicht stören (*Sidechain-Kompression*); dann wurde es ein eigener Klang: das Pumpen.

#fig(
  plot(w: 64mm, h: 22mm, curves: ((sample(x => 0.92 - 0.75 * calc.exp(-calc.rem(x * 4, 1) * 9)), blue),), bars: range(4).map(i => (i / 4 + 0.005, 0.98, orange)), xl: [Lautstärke des Pads über einen Takt; orange = Kick]),
  [Jede Kick drückt die Lautstärke herunter (`duckdepth`); wie schnell sie zurückkommt, bestimmt `duckattack`.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Bereich*], [*Wirkung*],
  [`duckorbit` (duck)], [Orbit-Nummer(n), z. B. `2` oder `"2:3"`], [welcher Orbit geduckt wird. Steht auf der *Kick*],
  [`duckdepth`], [0–1], [wie tief es runtergeht],
  [`duckattack` (duckatt, datt)], [Sekunden], [wie schnell es wieder hochkommt],
  [`duckonset`], [Sekunden], [wie schnell es runtergeht],
)

*Slider:* `DEPTH13`, `RETURN` (Rückkehrzeit). Die Kick (Orbit 1) duckt Orbit 2, auf dem Pad und Bass spielen.

#hoeren[
  + `DEPTH13` 0 gegen 0,8.
  + `RETURN` 0,05 (straff) gegen 0,3: Bei 0,3 „atmet“ der Pad in Vierteln.
]

#szene[Starkes Pumpen ist der Sound von French House (Daft Punk, Stardust) und vielen modernen House-Tracks. In Techno ist Ducking subtiler: Es schafft der Kick Platz im Bass, sodass Kick und Bass laut sein können, ohne sich zu verdecken.]

== Kapitel 14: Kompressor – Punch und Sustain einzelner Schläge

*Was es macht.* Ein Kompressor macht laute Stellen leiser: Alles über der *Schwelle* (Threshold, in dB) wird um das *Verhältnis* (Ratio) reduziert. Bei Ratio 4 werden aus 4 dB über der Schwelle 1 dB. Leise Stellen bleiben, der Klang wird gleichmäßiger und dichter.

#fig(
  plot(w: 46mm, h: 30mm, curves: ((((0, 0), (1, 1)), luma(170)), (((0, 0), (0.6, 0.6), (1, 0.7)), blue)), vlines: (0.6,), xl: [Eingang (dB) → Ausgang (dB)]),
  [Grau: ohne Kompressor. Blau: Threshold bei der gestrichelten Linie, Ratio 4. Über der Schwelle wächst der Ausgang nur noch ein Viertel so schnell.],
)

#tbl(
  (auto, auto, 1fr),
  [*Parameter*], [*Bereich*], [*Wirkung*],
  [`compressor`], [dB, z. B. −20], [Schwelle (Threshold)],
  [`compressorRatio`], [1–20], [Stärke],
  [`compressorKnee`], [dB], [weicher Übergang an der Schwelle],
  [`compressorAttack`], [Sekunden], [wie schnell er zugreift. *Langsam = mehr Punch* (der Anschlag rutscht durch)],
  [`compressorRelease`], [Sekunden], [wie schnell er loslässt],
)

Kurzschreibweise: `compressor("-20:4:6:.01:.1")` = Threshold, Ratio, Knee, Attack, Release.

*Slider:* `THRESH`, `RATIO`, `ATTACK14`, `RELEASE14`, `MAKEUP` (Lautstärke danach, `postgain`). Der Kompressor liegt auf den Drums.

#hoeren[
  + `THRESH` −40, `RATIO` 10, dann `ATTACK14` 0,001 gegen 0,03: flach gegen knackig.
  + `MAKEUP` hoch: Die Fahnen von Hats und Clap werden lauter, die Drums klingen dichter.
]

#falle[In Strudel arbeitet der Kompressor *pro Note* (lokal), nicht auf dem ganzen Mix. Er formt also jeden Schlag einzeln (Punch, Sustain), ist aber kein „Kleber“ für den Mix. Den Platz im Mix schafft in Strudel das Ducking (Kapitel 13).]

#szene[Kompression ist in Techno und House allgegenwärtig: auf Kicks für Punch, auf Drum-Bussen für Dichte, auf dem Master für Lautheit. In Strudel nutzt du sie vor allem, um einzelne Drums knackiger oder voller zu machen.]

== Kapitel 15: Stereo – pan, jux

*Was es macht.* `pan` setzt einen Klang zwischen links (0), Mitte (0,5) und rechts (1). `jux` spielt eine veränderte Kopie nur rechts; `juxBy` stellt ein, wie weit die beiden Seiten auseinanderliegen.

*Slider:* `MOVE` (Hats wandern von links nach rechts, Auto-Pan), `WIDTH` (der Stab bekommt auf einer Seite eine um ein paar Millisekunden spätere Kopie: er klingt breit, *Haas-Effekt*).

#hoeren[
  + Mit Kopfhörern: `MOVE` 0 → 1, `WIDTH` 0 → 1.
]

#szene[Clubanlagen spielen oft (fast) mono, und tiefe Frequenzen sind ohnehin nicht ortbar. Deshalb gilt: *Kick, Bass und Clap in die Mitte*, nur Hats, Percussion, Pads und Effekte in die Breite. Breite Klänge können in Mono dünner werden. Auto-Pan auf Percussion ist ein typisches Mittel für Bewegung in Minimal und Tech House.]

== Kapitel 16: Performance-Kette – die Effekte, die du live fährst

*Was es macht.* Live bewegt man selten zwanzig Parameter. Diese fünf Makros decken die meisten Techno- und House-Moves ab und passen zu den Reglern eines Stems in deinen Tracks (`col(n)`: hpf, lpf, char, level):

#tbl(
  (auto, 1fr, 1fr),
  [*Slider*], [*Wirkung*], [*Live-Einsatz*],
  [`HP`], [Hochpass auf der Musik], [Build-up, ausdünnen],
  [`LP`], [Tiefpass auf Stab und Lead (der Bass behält seinen eigenen)], [Sweeps, Dunkelheit],
  [`CHAR`], [Verzerrung auf dem Bass + Resonanz am Filter], [„Charakter“, Druck],
  [`SPACE`], [Hall und Delay auf dem Stab], [Weite, Übergänge],
  [`PUMP`], [Ducking-Tiefe von der Kick], [Groove, Platz für die Kick],
)

#hoeren[
  Einen 32-Takt-Bogen bauen: Start mit `LP` 0,3 und `SPACE` 0,2. `LP` über 16 Takte öffnen, `CHAR` dazu. Dann `HP` vier Takte hoch und mit hohem `PUMP` zurückfallen lassen. Danach überlegen, welches Makro auf welchen Regler gehört.
]

// ============================================================
= Anhang

== Rezepte

#tbl(
  (auto, 1fr),
  [*Klang*], [*Zutaten*],
  [Acid-Bass], [`s('sawtooth')`, 16tel, `.lpf(300).fanchor(0).lpenv(4).lpd(.15).lps(0).lpq(15).ftype('ladder')`, Akzente mit `velocity`, etwas `distort` (diode)],
  [Dub-Techno-Akkord], [m7/m9 oder Quartenstapel, sehr kurz (`decay(.2).sustain(0)`), `lpf` 800–1500, `delay(.5).delaytime(punktierte 1/8).delayfeedback(.6)`, eigener Orbit mit dunklem Hall],
  [Rumble-Kick], [Kick + `distort` + eigener Orbit mit viel Hall, `roomlp` tief (300–600 Hz), Hall per Ducking von der trockenen Kick pumpen lassen],
  [Synth-Kick], [`note('a1').s('sine').penv(36).pdecay(.08).pcurve(1).decay(.35).sustain(0)`],
  [Pumpendes Pad], [Pad auf eigenem Orbit, Kick mit `duckorbit(n).duckdepth(.8).duckattack(.25)`],
  [Trance-Gate], [gehaltener Akkord, `tremolosync(16).tremoloshape('square').tremolodepth(1)`],
  [Build-up], [`hpf` über 8–16 Takte von 20 auf 1000–2000 Hz, dazu `room` hoch, am Drop alles schlagartig zurück],
  [Telefon/Radio], [`bpf(1500).bpq(4)`, etwas `crush(8)`],
)

== Übungsplan

#tbl(
  (auto, auto, 1fr),
  [*Einheit*], [*Kapitel*], [*Ziel*],
  [1], [0, 1, 2], [Frequenzbereiche hören; Akzente; Hüllkurven erkennen],
  [2], [3, 4], [Filter-Sweeps, Build-up mit Hochpass],
  [3], [5, 6], [Acid und Kick-Bau: Hüllkurven auf Filter und Tonhöhe],
  [4], [7, 8], [Sättigung bis Zerstörung; Vowel],
  [5], [9, 10, 11], [Bewegung und Raum],
  [6], [12, 13, 14, 15], [Routing, Ducking, Kompression, Stereo],
  [danach], [16], [Performance-Bögen üben, dann auf eigene Tracks übertragen],
)

Danach: In einem eigenen Track für jeden Stem überlegen, *in welchem Frequenzbereich* er lebt, *welchen Raum* er bekommt (Orbit) und *welcher Effekt* live auf den Regler gehört.

== Effekt-Referenz (alle Parameter der Strudel-Effektseite)

#tbl(
  (auto, 1fr),
  [*Gruppe*], [*Parameter (Aliase in Klammern)*],
  [Filter], [`lpf` (cutoff, ctf, lp), `lpq` (resonance), `hpf` (hp, hcutoff), `hpq` (hresonance), `bpf` (bandf, bp), `bpq` (bandq), `ftype` (12db, ladder, 24db), `vowel`],
  [Filter-Hüllkurven], [`lpattack lpdecay lpsustain lprelease lpenv` (lpa lpd lps lpr lpe), dasselbe mit `hp…` und `bp…`, `fanchor`],
  [Lautstärke-Hüllkurve], [`attack` (att), `decay` (dec), `sustain` (sus), `release` (rel), `adsr("a:d:s:r")`, `clip`],
  [Pitch-Hüllkurve], [`penv`, `pattack` (patt), `pdecay` (pdec), `prelease` (prel), `pcurve`, `panchor`],
  [Amplitudenmodulation], [`tremolo` (trem), `tremolosync`, `tremolodepth`, `tremoloskew`, `tremolophase`, `tremoloshape`],
  [Dynamik], [`gain`, `velocity` (vel), `postgain`, `compressor` (+ `compressorRatio Knee Attack Release`), `xfade`],
  [Stereo], [`pan`, `jux`, `juxBy`],
  [Waveshaping], [`distort` (dist; + `distorttype`, `distortvol`), `crush`, `coarse`, `shape` (veraltet)],
  [Global (pro Orbit)], [`orbit` (o), `delay`, `delaytime` (delayt, dt), `delayfeedback` (delayfb, dfb), `room`, `roomsize` (rsize, sz, size), `roomfade` (rfade), `roomlp` (rlp), `roomdim` (rdim), `iresponse` (ir), `phaser` (ph), `phaserdepth`, `phasercenter`, `phasersweep`, `duckorbit` (duck), `duckattack`, `duckdepth`, `duckonset`],
)

Kurzschreibweisen mit Doppelpunkt: `lpf("1000:10")` = Cutoff und Resonanz, `delay(".5:.375:.6")` = Menge, Zeit, Feedback, `room(".6:4")` = Menge, Größe.

== Glossar

#tbl(
  (auto, auto, 1fr),
  [*Deutsch*], [*Englisch*], [*Erklärung*],
  [Frequenz], [frequency], [Schwingungen pro Sekunde (Hz); bestimmt die Tonhöhe],
  [Obertöne], [overtones, harmonics], [Vielfache des Grundtons, machen die Klangfarbe],
  [Dezibel], [decibel (dB)], [Maß für Lautstärkeverhältnisse; +6 dB ≈ doppelte Amplitude],
  [Hüllkurve], [envelope (ADSR)], [Verlauf eines Werts über eine Note: Attack, Decay, Sustain, Release],
  [Tiefpass, Hochpass, Bandpass], [low-pass, high-pass, band-pass], [Filter, die Höhen, Tiefen oder alles außer einem Band entfernen],
  [Cutoff], [cutoff], [Grenzfrequenz eines Filters],
  [Resonanz], [resonance, Q], [Anhebung am Cutoff],
  [Sättigung, Verzerrung], [saturation, distortion], [Verbiegen der Welle, erzeugt neue Obertöne],
  [Formant], [formant], [Resonanzbereich, der einen Vokal ausmacht],
  [LFO], [low frequency oscillator], [langsame Welle, die einen Parameter bewegt],
  [Hall, Delay], [reverb, delay], [Raum aus vielen Echos; einzelne Echos im Takt],
  [trocken, nass], [dry, wet], [Original- und Effektanteil],
  [Orbit, Send/Bus], [orbit, send/bus], [gemeinsamer Effektkanal für mehrere Klänge],
  [Ducking, Sidechain], [ducking, sidechain], [ein Signal (Kick) drückt ein anderes leiser],
  [Kompressor], [compressor], [macht laute Stellen leiser, den Klang dichter],
  [Clipping], [clipping], [Abschneiden über 0 dB],
  [Aliasing], [aliasing], [falsche, metallische Töne durch zu niedrige Abtastrate],
)
