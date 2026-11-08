// Handbook for harmony-tutorial.strudel (intervals, scales, modes, chord types, keys).
// Compile: typst compile harmony-tutorial.typ

#set document(title: "Harmonie-Tutorial: Handbuch")
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
#let lightblue = rgb("#a9cbef")

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
#let szene(body) = box-of(rgb("#4a8a3c"), "In Techno und House:", body)

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
  #text(size: 22pt, weight: "bold")[Harmonie-Tutorial]
  #v(-0.5em)
  #text(size: 12pt, fill: luma(90))[Intervalle, Skalen, Modi, Akkorde und Tonarten hören lernen, für Techno und House]
  #v(-0.3em)
  #text(size: 9pt, fill: luma(110))[Handbuch zu `lab/tutorials/harmony-tutorial.strudel`]
]

#v(0.5em)
#outline(title: [Inhalt], depth: 1, indent: 1em)

= So arbeitest du mit dem Tutorial

== Die Idee

Musiktheorie lernt man nicht durch Lesen, sondern durch Hören: Ein Begriff wie „dorisch“ oder „vermindert“ ist erst dann verstanden, wenn du ihn erkennst, wenn er erklingt. Deshalb ist das Tutorial so gebaut:

- Jedes Kapitel ist eine *Schleife*, die endlos läuft. Es gibt keinen Zeitdruck.
- Statt Dinge nacheinander abzuspielen, gibt es *Slider*. Du stellst einen Zustand ein, hörst ihn dir in Ruhe an und änderst dann *genau eine Sache*.
- Fast jeder Schritt verändert nur *einen einzigen Ton*. So hörst du, was dieser Ton bewirkt. Das ist der Kern der Methode.
- Der wichtige Ton ist im Pianoroll *orange*.

Dieses Handbuch erklärt zu jedem Kapitel die Theorie in einfachen Worten, gibt dir konkrete Höraufgaben und sagt, wo du das in Techno und House wiederfindest. Die Kommentare im Code sind eine Kurzfassung davon.

== Bedienung

+ Öffne `harmony-tutorial.strudel` in Strudel (strudel.cc).
+ Stelle oben `const CHAPTER = 0` auf das gewünschte Kapitel (0 bis 12) und werte einmal aus (Strg+Enter).
+ Ab jetzt nur noch die *Slider des Kapitels* bewegen. Sie erscheinen direkt im Code, neben `slider(...)`. Sie wirken sofort, ohne neues Auswerten. Die Slider der anderen Kapitel sind zwar sichtbar, tun aber nichts.
+ Unter der letzten Zeile zeigt das *Pianoroll* die gespielten Töne mit Namen. Die Töne stehen an ihrer echten Tonhöhe: Lücken zwischen zwei Balken zeigen dir, ob ein Schritt groß (Ganzton) oder klein (Halbton) ist.
+ Die Drums laufen in einem eigenen Block mit dem Slider `DRUMS` (Lautstärke, 0 = aus). Für die Kapitel 0 bis 2 empfiehlt es sich, die Drums erst einmal auszuschalten.

== Wie man übt

- *Vier bis acht Takte pro Einstellung.* Das Ohr braucht eine Weile, bis es einen Klang als „Zuhause“ annimmt. Erst dann hörst du die Änderung.
- *Hin und zurück.* Nach einer Änderung immer wieder zurückschalten. Der Unterschied zeigt sich im Vergleich, nicht im einzelnen Zustand.
- *Mitsingen oder mitsummen.* Wenn du einen Ton singen kannst, hast du ihn gehört. Besonders wichtig: den Grundton jederzeit summen können.
- *Augen zu.* Erst hören, dann im Pianoroll nachsehen, ob du recht hattest.
- *Kurze Einheiten.* 20 bis 30 Minuten, dafür regelmäßig. Ein Vorschlag steht am Ende (Übungsplan).

== Notennamen und Zeichen

Strudel und das Pianoroll benutzen *englische Notennamen*. Der wichtigste Unterschied zum Deutschen:

#tbl(
  (auto, auto, 1fr),
  [*Englisch (Strudel)*], [*Deutsch*], [*Bedeutung*],
  [B], [H], [der Ton zwischen A und C],
  [B♭ (im Pianoroll `Bb`)], [B], [B um einen Halbton erniedrigt],
  [F♯ (im Pianoroll `F#`)], [Fis], [♯ = „Kreuz“, einen Halbton höher],
  [E♭ (im Pianoroll `Eb`)], [Es], [♭ = „b“, einen Halbton tiefer],
  [A3], [a (kleines a)], [die Zahl ist die Oktave. A4 = 440 Hz, A3 = 220 Hz, A1 = 55 Hz],
)

Alle Beispiele stehen auf dem Grundton *A*. Das ist eine typische Techno-Tonart, und auf der Klaviatur sind A-Moll und die meisten Modi leicht zu sehen.

In den Klaviaturgrafiken in diesem Heft gilt: *dunkelblau* = Grundton, *hellblau* = Ton der Skala oder des Akkords, *orange* = der Ton, auf den es ankommt.

#fig(onA((0, 2, 3, 5, 7, 8, 10, 12)), [Beispiel: die A-Moll-Skala (A B C D E F G A). Es sind nur weiße Tasten.])

// ============================================================
= Teil A: Abstände hören

== Kapitel 0: Grundton und Intervalle

*Worum es geht.* Ein *Ton* hat eine Tonhöhe. Der kleinste Schritt in unserer Musik ist der *Halbton*: von einer Taste zur direkt benachbarten, egal ob weiß oder schwarz. Zwölf Halbtöne ergeben eine *Oktave*; danach wiederholen sich die Tonnamen (A3 zu A4: doppelte Frequenz).

Ein *Intervall* ist der Abstand zwischen zwei Tönen, gezählt in Halbtönen. Das ist die wichtigste Grundlage überhaupt: Jede Skala und jeder Akkord ist nichts anderes als eine Auswahl von Intervallen über einem Grundton. Wer Intervalle hört, hört Harmonie.

Der *Grundton* (auch Tonika, englisch root oder tonic) ist der Ton, der sich wie „zuhause“ anfühlt. Im Kapitel hält ein *Bordunton* (Drone: ein Ton, der die ganze Zeit liegt) das A fest. Darüber spielt die Lead abwechselnd A (weiß) und einen zweiten Ton (orange), `N` Halbtöne höher.

*Slider:* `N` = 0 bis 12 Halbtöne.

#tbl(
  (auto, auto, 1fr, 1fr),
  [*N*], [*Name*], [*Klang*], [*Wo du es triffst*],
  [0], [Prime], [derselbe Ton], [–],
  [1], [kleine Sekunde], [scharfe Reibung, Bedrohung], [phrygische Techno-Basslines (A–B♭), Horror],
  [2], [große Sekunde], [neutraler Schritt], [Melodien, sus2-Akkorde],
  [3], [kleine Terz], [dunkel, traurig: *der* Moll-Klang], [jeder Moll-Akkord, das meiste Techno],
  [4], [große Terz], [hell, fröhlich: *der* Dur-Klang], [Dur-Akkorde, Disco, euphorisches House],
  [5], [Quarte], [offen, hohl, wartend], [sus4-Akkorde, Dub-Techno-Akkorde],
  [6], [Tritonus], [instabil, unheimlich], [verminderte Akkorde, Industrial, Acid],
  [7], [Quinte], [stark, rein, „Power“], [Grundton+Quinte im Bass, Rave-Stabs],
  [8], [kleine Sexte], [dunkel, dramatisch], [Moll-Melodien (A–F), Trance-Leads],
  [9], [große Sexte], [warm, soulig], [dorisches Deep House, Jazz-Akkorde],
  [10], [kleine Septime], [bluesig, offen, groovig], [m7-Akkorde (Deep House), mixolydische Riffs],
  [11], [große Septime], [verträumt, sehnsüchtig, gespannt], [maj7-Akkorde (Nu-Disco), der Leitton],
  [12], [Oktave], [derselbe Ton, höher], [Oktav-Basslines (House, Disco)],
)

*Warum klingen manche Intervalle ruhig und andere gespannt?* Bei Oktave (2:1) und Quinte (3:2) schwingen die beiden Töne in einfachen Verhältnissen; ihre Schwingungen passen oft zusammen, das Ohr hört Verschmelzung. Bei kleiner Sekunde oder Tritonus passen sie kaum zusammen; man hört ein Flirren oder Reiben (Schwebung). Dieses Reiben nennt man *Dissonanz* (Spannung), das ruhige Verschmelzen *Konsonanz* (Entspannung).

#hoeren[
  + `N` = 0, dann 12, dann 7. Diese drei klingen fast wie „ein Ton“. Wie ruhig ist das?
  + `N` = 7, dann 6. Ein Halbton weniger, und aus der stärksten Verbindung wird die unheimlichste.
  + `N` = 3, dann 4 (mehrmals hin und her): das ist schon der ganze Unterschied zwischen Moll und Dur.
  + `N` = 1 und 11: Beide wollen weiter. Die 11 will nach oben zur 12, die 1 nach unten zur 0. Spürst du die Richtung?
  + Gehe alle Werte von 0 bis 12 durch und sortiere sie für dich in „ruhig“, „farbig“ und „gespannt“.
]

#merke[Musik lebt von Spannung und Entspannung. Spannung entsteht durch Intervalle, die reiben; Entspannung durch Intervalle, die verschmelzen.]

== Kapitel 1: Dur oder Moll – ein einziger Ton entscheidet

*Worum es geht.* Ein Akkord aus Grundton, Terz und Quinte heißt *Dreiklang*. Ob er Dur oder Moll ist, entscheidet nur die *Terz*, also der Ton drei oder vier Halbtöne über dem Grundton. Grundton, Quinte und Oktave bleiben gleich.

#fig(onA((0, 3, 7), c: (3,)), [A-Moll: A C E. Die kleine Terz (3 Halbtöne, C) ist orange.])
#fig(onA((0, 4, 7), c: (4,)), [A-Dur: A C♯ E. Die große Terz (4 Halbtöne, C♯) ist orange.])
#fig(onA((0, 7, 12)), [Ohne Terz: A E A, der „Power-Chord“ (Quintklang). Weder Dur noch Moll.])

Im Kapitel spielt die Lead die Töne nacheinander (Arpeggio), ein Stab spielt sie gleichzeitig, der Bass bleibt auf A.

*Slider:* `THIRD`: 0 = Moll, 1 = Dur, 2 = ohne Terz.

#hoeren[
  + Alle vier Takte zwischen 0 und 1 wechseln. Ein Ton wandert um einen Halbton, und die ganze Stimmung kippt.
  + Achte im Arpeggio auf das orange C beziehungsweise C♯. Kannst du es mitsingen?
  + Stelle 2 ein: Ohne Terz fehlt die Stimmung. Es klingt stark, aber neutral. Wechsle danach zu 0 und 1 zurück. Die Terz „färbt“ den Klang.
]

#szene[Techno ist überwiegend Moll oder ganz ohne Terz: Viele Stabs und Basslines bestehen nur aus Grundton und Quinte oder Oktave. So bleibt die Stimmung offen und passt unter jede Melodie. Disco, French House und Piano-House sind oft Dur.]

== Kapitel 2: Warum es Skalen gibt

*Worum es geht.* Es gibt zwölf verschiedene Töne. Eine *Skala* (Tonleiter) wählt davon sieben (manchmal fünf) aus. Warum? Die Lead spielt *zufällige* Töne, und der Slider bestimmt, aus welcher Auswahl:

- *0 chromatisch:* alle 12 Töne. Klingt ziellos und „falsch“, weil nichts dem Ohr sagt, wo zuhause ist.
- *1 A-Moll:* 7 Töne mit den Schritten G H G G H G G (G = Ganzton = 2 Halbtöne, H = Halbton). Plötzlich ist es eine Melodie: Jeder Ton gehört zum Grundton A.
- *2 A-Moll-Pentatonik:* 5 Töne. Es fehlen die zwei Töne, die nur einen Halbton von einem Nachbarn entfernt liegen (B und F). Ohne Halbtöne kann nichts mehr reiben.

#fig(onA((0, 2, 3, 5, 7, 8, 10, 12), c: (2, 8)), [A-Moll. Orange: B und F, die beiden Töne mit einem Halbton-Nachbarn (B–C, E–F).])
#fig(onA((0, 3, 5, 7, 10, 12)), [A-Moll-Pentatonik: A C D E G. Ohne B und F gibt es keine Halbtonschritte mehr.])

*Slider:* `SET` = Tonvorrat (0 bis 2), `SEED` = welche Zufallsmelodie (0 bis 31). Die Melodie wiederholt sich alle zwei Takte, damit du sie lernen kannst.

#hoeren[
  + `SEED` festlassen, `SET` wechseln. Rhythmus und „Zufall“ bleiben gleich, nur der Tonvorrat ändert sich.
  + `SET` = 1 oder 2 lassen und mehrere `SEED`s durchprobieren. Fast jede Melodie „funktioniert“.
  + Vergleiche 1 und 2: Moll hat mehr Charakter (auch mehr Spannung), Pentatonik klingt glatter und sicherer.
]

#szene[Die Moll-Pentatonik ist die Skala für Acid-Linien, Rave-Leads und improvisierte Synth-Soli: Man kann keinen falschen Ton spielen. Wer live mit Reglern Töne auswählt, ist mit ihr auf der sicheren Seite.]

#merke[Eine Skala ist keine Regel, sondern ein Vorrat: Sie sorgt dafür, dass alle Töne zum selben Zuhause gehören.]

// ============================================================
= Teil B: Skalen und Modi

== Kapitel 3: Die sieben Modi, von hell nach dunkel

*Worum es geht.* Spielt man nur die weißen Tasten, aber beginnt jeweils auf einem anderen Ton, entstehen sieben Skalen: die *Modi* (Kirchentonarten). Dur und Moll sind zwei davon. Im Tutorial stehen alle sieben auf A, damit du sie direkt vergleichen kannst.

Das Schöne: Sortiert man sie nach Helligkeit, ändert sich von einem Modus zum nächsten *genau ein Ton* um einen Halbton. Jeder Schritt lässt sich also als *ein* veränderter Ton hören.

#tbl(
  (auto, auto, auto, auto, 1fr),
  [*MODE*], [*Modus*], [*Schritte*], [*Änderung*], [*Klang*],
  [0], [lydisch], [G G G H G G H], [erhöhte Quarte D♯], [schwebend, traumhaft, am hellsten],
  [1], [Dur (ionisch)], [G G H G G G H], [Quarte zurück auf D], [fröhlich, aufgelöst],
  [2], [mixolydisch], [G G H G G H G], [Septime runter auf G], [Dur, aber locker, bluesig],
  [3], [dorisch], [G H G G G H G], [Terz runter auf C: jetzt Moll], [Moll, aber warm, soulig],
  [4], [Moll (äolisch)], [G H G G H G G], [Sexte runter auf F], [dunkel, melancholisch],
  [5], [phrygisch], [H G G G H G G], [Sekunde runter auf B♭], [am dunkelsten, bedrohlich],
  [6], [lokrisch], [H G G H G G G], [Quinte runter auf E♭], [kein stabiles Zuhause],
)

Jeder Modus hat einen *charakteristischen Ton*: den, der ihn von normalem Dur oder Moll unterscheidet. Er ist im Pianoroll orange.

#grid(columns: (auto, 1fr), column-gutter: 5mm, row-gutter: 2.5mm, align: horizon,
  onA((0, 2, 4, 6, 7, 9, 11, 12), c: (6,)), [*lydisch*: D♯ (übermäßige Quarte)],
  onA((0, 2, 4, 5, 7, 9, 11, 12), c: (11,)), [*Dur*: G♯ (große Septime, der Leitton)],
  onA((0, 2, 4, 5, 7, 9, 10, 12), c: (10,)), [*mixolydisch*: G (kleine Septime in Dur)],
  onA((0, 2, 3, 5, 7, 9, 10, 12), c: (9,)), [*dorisch*: F♯ (große Sexte in Moll)],
  onA((0, 2, 3, 5, 7, 8, 10, 12), c: (8,)), [*Moll*: F (kleine Sexte)],
  onA((0, 1, 3, 5, 7, 8, 10, 12), c: (1,)), [*phrygisch*: B♭ (kleine Sekunde)],
  onA((0, 1, 3, 5, 6, 8, 10, 12), c: (6,)), [*lokrisch*: E♭ (verminderte Quinte)],
)

Im Kapitel läuft die Skala in Takt 1 hoch, in Takt 2 runter. Der Stab spielt dazu den *Grundakkord* des Modus (Stufe 1, 3 und 5 übereinander).

*Slider:* `MODE` = 0 bis 6 (Start: 4 = Moll).

#hoeren[
  + Bei 4 (Moll) starten. Einen Schritt nach oben (3, dorisch): Welcher Ton ist anders? (F wird F♯.) Zurück zu 4. Mehrmals.
  + So weiter bis 0, immer einen Schritt, immer hin und zurück. Dann von 4 abwärts bis 6.
  + Achte auf den Stab: Bei 0 bis 2 ist der Grundakkord Dur, bei 3 bis 5 Moll, bei 6 *vermindert* (A C E♭). Deshalb taugt lokrisch nicht als Zuhause: Selbst der Heimakkord ist instabil.
  + Springe von 0 auf 5: Das ist der Weg vom hellsten zum dunkelsten brauchbaren Modus.
]

#merke[Modi sind keine sieben völlig verschiedenen Welten, sondern eine Helligkeitsleiter. Jede Stufe erniedrigt einen Ton.]

== Kapitel 4: Jeder Modus in seinem typischen Riff

*Worum es geht.* Skalen auf- und abwärts sind nur der erste Schritt. Jeder Modus hat typische Wendungen, die seinen charakteristischen Ton betonen, oft eine Zwei-Akkord-Schleife. Der Clou: Mit `COMPARE` = 1 spielt derselbe Riff im *Nachbarmodus*, dem genau dieser eine Ton fehlt. So hörst du, was ein einzelner Ton ausmacht.

#tbl(
  (auto, auto, auto, 1fr, auto),
  [*RIFF*], [*Modus*], [*Akkorde*], [*Typisch für*], [*COMPARE*],
  [0], [lydisch], [A – B (Dur auf Stufe II)], [Ambient-Pads, Film, Progressive House], [Dur (D♯ → D)],
  [1], [Dur], [A – E], [Piano House, Disco, Hands-up], [mixolydisch (G♯ → G)],
  [2], [mixolydisch], [A – G (♭VII)], [Funky House, Disco, Chicago], [Dur (G → G♯)],
  [3], [dorisch], [Am7 – D7 (Dur-IV)], [*der* Deep-House-Vamp, Detroit], [Moll (F♯ → F)],
  [4], [Moll], [Am – F (♭VI)], [Techno, Trance, melancholisches House], [dorisch (F → F♯)],
  [5], [phrygisch], [Am – B♭ (♭II)], [harte Techno-Basslines, EBM], [Moll (B♭ → B)],
  [6], [lokrisch], [nur A°], [Spannung, Horror, Industrial], [phrygisch (E♭ → E)],
)

Ein *Vamp* ist eine Schleife aus zwei Akkorden, die endlos hin und her pendelt. Fast jedes Deep-House-Stück ist so gebaut.

*Slider:* `RIFF` = Modus (0 bis 6, Start 3), `COMPARE` = 0 (Original) oder 1 (Nachbar ohne den orangen Ton).

#hoeren[
  + `RIFF` = 3 (dorisch). Vier Takte hören, dann `COMPARE` = 1: Der Riff wird zu normalem Moll. Was geht verloren? (Meist: das Warme, Hoffnungsvolle.)
  + `RIFF` = 4 (Moll) mit `COMPARE` = 1: genau die umgekehrte Richtung. Das Paar dorisch/Moll ist für House das wichtigste überhaupt.
  + `RIFF` = 5 (phrygisch): Die Bassline pendelt zwischen A und B♭. Mit `COMPARE` = 1 wird daraus A–B: die Bedrohung ist weg.
  + `RIFF` = 2 und 1 vergleichen: mixolydisch ist Dur mit „Lässigkeit“.
]

#szene[Phrygische Halbton-Basslines (Grundton und der Ton einen Halbton darüber) sind ein Markenzeichen von hartem Techno und EBM. Der dorische Vamp i–IV (Am7–D7) ist das Fundament von Deep House und Detroit-Techno. Mixolydisch steckt in vielen Disco- und Funk-House-Riffs, lydisch in schwebenden Pads von Progressive House.]

// ============================================================
= Teil C: Akkorde

== Kapitel 5: Akkorde aus der Skala

*Worum es geht.* Einen Akkord baut man, indem man *jeden zweiten Ton* der Skala übereinanderstapelt: Stufe d, d+2, d+4 ergibt einen Dreiklang (3 Töne). Dazu d+6 ergibt einen *Septakkord* (4 Töne), dazu d+8 einen *Nonenakkord* (5 Töne).

Weil die Skala ungleiche Schritte hat (Ganz- und Halbtöne), bekommt jeder gestapelte Akkord eine andere *Qualität*: Dur, Moll oder vermindert.

#tbl(
  (auto, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  [*DEGREE*], [0], [1], [2], [3], [4], [5], [6],
  [Stufe], [i], [ii°], [III], [iv], [v], [VI], [VII],
  [Dreiklang in A-Moll], [Am], [B°], [C], [Dm], [Em], [F], [G],
  [Septakkord], [Am7], [Bm7♭5], [Cmaj7], [Dm7], [Em7], [Fmaj7], [G7],
)

*Stufenschreibweise:* Römische Zahlen zählen die Akkorde in der Skala. Groß = Dur-Akkord, klein = Moll-Akkord, ° = vermindert. Der Vorteil: „i – VI – III – VII“ beschreibt dieselbe Akkordfolge in jeder Tonart. In A-Moll ist das Am – F – C – G, in D-Moll Dm – B♭ – F – C.

*Slider:* `DEGREE` = Stufe (0 bis 6), `SIZE` = 0 Dreiklang, 1 Septakkord, 2 Nonenakkord, `SCALE5` = Skala (gleiche Reihenfolge wie Kapitel 3, Start 4 = Moll).

#hoeren[
  + `DEGREE` von 0 bis 6 durchgehen. Bei jedem Akkord: Dur oder Moll? Prüfe mit der Tabelle.
  + `DEGREE` = 1 (B°): der eine verminderte Akkord der Skala. Er klingt gequetscht und will weiter.
  + `DEGREE` = 0, `SIZE` von 0 über 1 auf 2: Aus Am wird Am7 und Am9. Weicher, jazziger, tiefer: das ist der Deep-House-Klang.
  + `SCALE5` = 3 (dorisch), `DEGREE` = 3: Aus Dm wird D-Dur. Genau dieser Akkord macht den dorischen Vamp aus Kapitel 4.
]

#merke[Eine Skala liefert ihre Akkorde gleich mit. Wer die Skala kennt, weiß, welche Akkorde „passen“.]

== Kapitel 6: Akkordtypen – fröhlich, traurig, gespannt, schwebend

*Worum es geht.* Hier stehen alle Akkorde auf A, gebaut aus Halbtonschritten über dem Grundton (die Intervalle aus Kapitel 0). Takt 1 spielt den Akkord als Stab, Takt 2 dieselben Töne nacheinander, damit du jeden einzelnen hörst.

#tbl(
  (auto, auto, auto, auto, 1fr, 1fr),
  [*TYPE*], [*Name*], [*Schritte*], [*Töne*], [*Klang*], [*Techno / House*],
  [0], [5 (Power)], [0 7 12], [A E A], [neutral, stark], [Rave-Stabs, Hoover, Techno-Bass],
  [1], [Dur], [0 4 7], [A C♯ E], [hell, fröhlich], [Disco, French House, Piano House],
  [2], [Moll], [0 3 7], [A C E], [dunkel, traurig], [das meiste Techno, Trance],
  [3], [sus2], [0 2 7], [A B E], [offen, unaufgelöst], [Progressive House, Melodic-Techno-Pads],
  [4], [sus4], [0 5 7], [A D E], [hohl, wartend], [Melodic-Techno-Stabs, löst sich in 1 oder 2 auf],
  [5], [vermindert (dim)], [0 3 6], [A C E♭], [gequetscht, unruhig], [Spannungs-Stabs, Durchgang, Horror],
  [6], [übermäßig (aug)], [0 4 8], [A C♯ F], [unheimlich, schwebend], [Riser, Breaks, nur kurz],
  [7], [maj7], [0 4 7 11], [A C♯ E G♯], [verträumt, sehnsüchtig], [Nu-Disco, Balearic, Lounge House],
  [8], [7 (Dominant-Sept)], [0 4 7 10], [A C♯ E G], [bluesig, will weiter], [Chicago-House-Orgeln, Gospel House],
  [9], [m7], [0 3 7 10], [A C E G], [weich, warmes Moll], [Deep House: *der* House-Akkord],
  [10], [m9], [0 3 7 10 14], [A C E G B], [üppig, jazzig], [Deep House, Detroit, Dub Techno],
  [11], [Quartenstapel], [0 5 10 15], [A D G C], [hohl, modern, offen], [Dub-Techno-/Detroit-Stab],
  [12], [m7♭5 (halbvermindert)], [0 3 6 10], [A C E♭ G], [dunkle, jazzige Spannung], [Deep-House-Wendungen vor Moll],
  [13], [dim7 (vermindert sept)], [0 3 6 9], [A C E♭ F♯], [sehr gespannt, symmetrisch], [Builds, Horror, vor dem Drop],
)

=== Warum klingen sie so?

- *Die Terz entscheidet Dur (4) oder Moll (3).* Akkorde ohne Terz (Power, sus, Quartenstapel) sind weder noch; ihre Stimmung bleibt offen. Deshalb liebt Techno diese Akkorde: Sie passen zu jeder Bassline und klingen nie „fröhlich“ oder „traurig“.
- *Die Quinte entscheidet stabil oder instabil.* Eine reine Quinte (7) gibt dem Akkord Halt. *Vermindert* senkt sie auf den Tritonus (6), *übermäßig* hebt sie auf 8. Beide verlieren dadurch ihr stabiles Zentrum: Sie klingen, als würden sie fallen oder schweben.
- *Die Septime gibt Farbe.* Die kleine Septime (10) bringt Groove, Blues und Weichheit, die große Septime (11) Sehnsucht und Traum.
- *sus* heißt „suspended“, aufgehängt: Die Terz ist durch die Sekunde (sus2) oder Quarte (sus4) ersetzt. Der Akkord wartet auf eine Auflösung, bekommt sie aber oft nicht. Genau das macht ihn für langgezogene Spannungsbögen nützlich.

=== Vermindert und übermäßig genauer

#fig(onA((0, 3, 6), c: (6,)), [*Vermindert* (A°): zwei kleine Terzen übereinander (3+3). Die Quinte ist um einen Halbton erniedrigt (E → E♭).])
#fig(onA((0, 3, 6, 9), c: (6, 9)), [*Vermindert-Sept* (A°7): drei kleine Terzen (3+3+3). Der Abstand von F♯ zum nächsten A ist wieder 3. Der Akkord ist vollkommen symmetrisch.])
#fig(onA((0, 3, 6, 10), c: (6,)), [*Halbvermindert* (Am7♭5): verminderter Dreiklang mit kleiner Septime. Weicher als dim7, typisch in Jazz und Deep House.])
#fig(onA((0, 4, 8), c: (8,)), [*Übermäßig* (A+): zwei große Terzen (4+4). Die Quinte ist erhöht (E → F). Ebenfalls symmetrisch.])

Symmetrische Akkorde (vermindert, übermäßig) bestehen nur aus gleich großen Schritten. Kein Ton hebt sich als Grundton hervor, das Ohr verliert sein „Zuhause“. Das macht sie zu idealen Spannungsmachern und zu schlechten Heimakkorden.

*Slider:* `TYPE` = 0 bis 13 (Start 2 = Moll).

#hoeren[
  + 1 → 2 → 5 (Dur, Moll, vermindert): Jeder Schritt senkt einen Ton um einen Halbton (erst die Terz, dann die Quinte).
  + 1 → 6 (Dur, übermäßig): Nur die Quinte steigt. Hörst du, wie der Boden wegschwimmt?
  + 2 → 9 → 10 (Moll, m7, m9): immer tieferes House.
  + 9 → 12 → 13 (m7, halbvermindert, dim7): immer mehr Spannung.
  + 3, 4 und 11 (sus2, sus4, Quartenstapel): Klingen sie Dur oder Moll? (Antwort: keins von beiden.)
]

== Kapitel 7: Verminderte Akkorde im Einsatz

*Worum es geht.* Verminderte Akkorde sind selten „der“ Akkord eines Tracks. Sie sind Werkzeuge für Spannung. Das Kapitel zeigt drei typische Verwendungen (Slider `USE`):

*0 – Durchgangsakkord.* Die Schleife spielt Am | Dm | G♯°7 | Am. Der G♯°7 (G♯ B D F) steht einen Halbton unter dem Grundton A. Alle seine Töne lehnen sich an Am an: G♯ will nach A, B nach C, F nach E. Hör auf den Übergang von Takt 4 zu Takt 1: Der Akkord „fällt“ nach Hause. Klassisch in House-Piano, Garage und Gospel-House, oft auch direkt vor einem Drop.

#fig(kb(on: (8, 11, 14, 17), char: (8,)), [G♯°7: G♯ B D F. Orange: G♯, der Leitton einen Halbton unter A.])

*1 – Symmetrie.* Ein dim7 besteht aus 3+3+3 Halbtönen. Verschiebt man ihn um 3 Halbtöne, erhält man *dieselben vier Töne* wieder (nur in anderer Lage). Es gibt deshalb nur drei verschiedene dim7-Akkorde. Im Kapitel steigt eine dim7-Form in Halbtönen (A°7, B♭°7, B°7, C°7), während der Bass auf A liegen bleibt. Sie steigt und steigt und landet nie: ein typischer Aufbau vor einem Drop.

*2 – Bedrohungs-Stab.* Der Bass bleibt auf A, der Stab wechselt jeden Takt zwischen A-Moll (A C E) und A-vermindert (A C E♭). Nur die Quinte sinkt um einen Halbton (orange). Der Tritonus A–E♭ macht es bedrohlich: harter Techno, Acid, EBM.

#hoeren[
  + `USE` = 0 mit Drums auf 0. Summe die Melodie mit. Nach Takt 4 spürst du, wohin die Musik muss.
  + `USE` = 1: Achte darauf, dass es nie „ankommt“. Stell dir vor, an der Stelle von Takt 1 käme der Drop.
  + `USE` = 2: Ein einziger Halbton in einem Akkord verwandelt Melancholie in Bedrohung.
]

#szene[Verminderte Akkorde kommen meist kurz vor: als Stab mit viel Hall, als Durchgang in einer House-Piano-Figur, als steigende Kette im Build-up. Ein ganzer Track auf einem verminderten Akkord ist selten, aber im Industrial und in dunklem Acid nicht unüblich.]

== Kapitel 8: Chord Memory – eine Form, verschoben

*Worum es geht.* Viele Techno- und House-Tracks ignorieren die Skala komplett: Sie nehmen *eine* Akkordform und verschieben die ganze Form nach oben und unten. Alte Synthesizer hatten dafür eine „Chord Memory“-Taste: Ein gespeicherter Akkord liegt auf jeder Taste. Die Töne verlassen dabei die Tonart, aber das Ohr akzeptiert es, weil die Farbe des Akkords gleich bleibt (*Parallelverschiebung*).

*Slider:* `SHAPE`: 0 Moll, 1 m7, 2 m9, 3 Quartenstapel (der Dub-Techno-Akkord), 4 maj7. `MOVE`: 0 bleibt auf A, 1 A–C–D–C (House), 2 A–G–F–G (Dub, absinkend), 3 A–B♭ (dunkler Techno-Halbton).

Das lange Delay ist der Dub-Techno-Trick: Die Echos füllen den Raum zwischen den kurzen Stabs.

#hoeren[
  + `MOVE` festhalten, `SHAPE` wechseln: gleicher Rhythmus, aber Moll = Techno, m9 = Deep House, Quartenstapel = Dub Techno, maj7 = Nu-Disco.
  + `SHAPE` = 3, `MOVE` = 2: der Basic-Channel-/Dub-Techno-Klang.
  + Vergleiche mit Kapitel 5: Dort folgen die Akkorde der Skala (ihre Qualität wechselt), hier bleibt die Qualität gleich und die Tonart wird verlassen.
]

#szene[Chord Memory prägt Detroit-Techno, Dub Techno (Basic Channel, Deepchord) und viel Deep House. Für dich als Live-Performer ist es besonders praktisch: Eine einzige Akkordform plus eine Grundton-Folge reicht für einen ganzen Track.]

// ============================================================
= Teil D: Tonarten

== Kapitel 9: Eine Tonart – Zuhause und Sog

*Worum es geht.* Eine *Tonart* ist eine Skala plus ein Heimakkord. In der Tonart A-Moll ist Am das Zuhause, alle anderen Akkorde sind Schritte davon weg und wieder zurück. Die Schleife spielt Am | F | Dm | ? und beginnt dann wieder mit Am. Der Slider `LAST` wählt den Akkord vor der Rückkehr:

#tbl(
  (auto, auto, auto, 1fr),
  [*LAST*], [*Akkord*], [*Stufe*], [*Wirkung*],
  [0], [Am], [i], [bleibt zuhause: keine Bewegung, flach],
  [1], [G], [VII], [natürliches Moll: weich, offen, wenig Sog. Typische Techno-/Trance-Schleife],
  [2], [Em], [v], [natürliches Moll: sanft, etwas traurig],
  [3], [E], [V], [mit G♯ aus harmonisch Moll: starker Sog nach Hause],
  [4], [E7], [V7], [noch stärker: die klassische Kadenz],
  [5], [G♯°7], [vii°7], [die verminderte Variante desselben Sogs (Kapitel 7)],
)

*Der Leitton.* Der Sog kommt von G♯ (orange), einen Halbton unter A. Ein Ton einen Halbton unter dem Grundton heißt *Leitton*: Er „leitet“ nach Hause, weil der Halbtonschritt so klein ist, dass das Ohr ihn vervollständigen will (siehe Intervall 11 in Kapitel 0). Natürliches Moll hat G, zwei Halbtöne unter A, und zieht deshalb nicht. Darum gibt es *harmonisch Moll* (A B C D E F G♯): Moll, aber mit Leitton.

#fig(onA((0, 2, 3, 5, 7, 8, 11, 12), c: (11,)), [Harmonisch Moll auf A: wie Moll, aber G♯ statt G. Zwischen F und G♯ liegt ein auffälliger Schritt von 3 Halbtönen („orientalischer“ Klang).])

Eine *Kadenz* ist die Akkordfolge, die einen Abschnitt beendet, hier der Schritt vom vierten Takt zurück zu Am.

#hoeren[
  + 1 und 3 mehrmals vergleichen. Bei 3 will Takt 4 in Takt 1 „hineinfallen“, bei 1 schwebt es weiter.
  + 0: Ohne Bewegung fehlt die Spannung, also auch die Erleichterung bei der Rückkehr.
  + 4 und 5: noch mehr Sog. Welche Variante wirkt für dich am dramatischsten?
]

#szene[Techno vermeidet den Sog oft bewusst (LAST = 0 oder 1): Die Schleife löst sich nie auf und wirkt dadurch hypnotisch. House und Trance setzen den Sog gezielt ein, um einen Drop oder eine Rückkehr zu landen. Harmonisch Moll ist typisch für Trance-Leads.]

== Kapitel 10: Gleiche Töne, anderes Zuhause

*Worum es geht.* Die Lead spielt nur weiße Tasten, also die Töne von C-Dur, die zugleich die Töne von A-Moll sind. Nur Drone und Bass ändern sich; sie bestimmen, welcher Ton das Zuhause ist. Reihenfolge wie in Kapitel 3, von hell nach dunkel:

#tbl(
  (1fr, 1fr, 1fr, 1fr, 1fr, 1fr, 1fr),
  [*0*], [*1*], [*2*], [*3*], [*4*], [*5*], [*6*],
  [F lydisch], [C Dur], [G mixolydisch], [D dorisch], [A Moll], [E phrygisch], [B lokrisch],
)

Das ist das Prinzip der *Paralleltonarten*: C-Dur und A-Moll teilen alle Töne (keine Vorzeichen), nur das Zuhause ist ein anderes. Und es ist eine zweite Sicht auf die Modi: Die Modi sind dieselben Töne mit einem anderen Grundton.

*Slider:* `HOME` = 0 bis 6 (Start 4 = A).

#hoeren[
  + Summe die Melodie mit. Dann `HOME` wechseln: Kein einziger Ton der Melodie ändert sich, aber ihre Stimmung schon.
  + 1 (C) gegen 4 (A): Dur und Moll mit denselben Tönen.
  + 3 (D dorisch) und 5 (E phrygisch): Wie klingt dieselbe Melodie über diesen Grundtönen?
]

#merke[In einem Track legt der Bass das Zuhause fest (und eine gestimmte Kick), nicht die Melodie. Wer den Bass ändert, ändert die Tonart, auch wenn sonst alles gleich bleibt.]

== Kapitel 11: Alle Tonarten – Transponieren und Quintenzirkel

*Worum es geht.* Derselbe kleine Track in jeder Tonart: in Dur mit I – V – vi – IV, in Moll mit i – VI – III – VII. *Transponieren* heißt, alles um denselben Abstand zu verschieben. Die Form bleibt gleich, nur die Tonhöhe ändert sich.

Der Slider `KEY` wandert den *Quintenzirkel* entlang: Jeder Schritt geht eine Quinte (7 Halbtöne) nach oben.

#align(center, circle-of-fifths)

Außen die Dur-Tonarten, innen die Moll-Paralleltonarten (gleiche Töne, Grundton 3 Halbtöne tiefer). In der Mitte die Camelot-Nummern (B = Dur, A = Moll), wie DJ-Software sie anzeigt.

*Nachbarn teilen sechs von sieben Tönen.* Ein Schritt im Uhrzeigersinn fügt ein Kreuz hinzu (oder nimmt ein ♭ weg). Der neue Ton ist im Pianoroll orange: in Dur die Septime (der Leitton der neuen Tonart), in Moll die Sekunde. Mit `MINOR` = 1 spielt der Track die Moll-Tonart auf demselben Grundton (C-Moll, G-Moll …).

#tbl(
  (auto, auto, auto, auto),
  [*Dur*], [*Moll (parallel)*], [*Vorzeichen*], [*Camelot*],
  [C], [Am], [keine], [8B / 8A],
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

*Slider:* `KEY` = Position im Quintenzirkel (0 = C … 11 = F, Start 3 = A), `MINOR` = 0 Dur, 1 Moll.

#hoeren[
  + `KEY` um einen Schritt verschieben und den einen orangen, neuen Ton suchen.
  + Von 0 auf 6 springen (C → F♯): Fast alle Töne ändern sich. Diese beiden Tonarten passen am schlechtesten zusammen.
  + Achte auf den Bass: Tiefe Tonarten (E, F) machen ihn schwer, hohe (B, C) heller. Die Tonart wählt man in elektronischer Musik oft nach dem Bass.
]

#szene[*Harmonisches Mischen:* DJs blenden Tracks in benachbarten Tonarten ineinander (gleiche Camelot-Zahl, oder ±1). Für deine eigenen Tracks heißt das: Alle tonalen Elemente (Bass, Pad, Stab, Vocal-Sample) gehören in dieselbe Tonart, sonst reibt es sofort. Viele Produzenten stimmen auch die Kick auf den Grundton.]

== Kapitel 12: Spielwiese

*Worum es geht.* Ein kleiner Track, der nur in Skalenstufen geschrieben ist. Deshalb folgt er jeder Tonart, jedem Modus und jeder Akkordgröße.

#tbl(
  (auto, 1fr),
  [*Slider*], [*Funktion*],
  [`ROOT`], [Tonart: Halbtöne über A (0 = A, 3 = C, 5 = D, −4 = F …)],
  [`MODE12`], [Skala, von hell nach dunkel (Kapitel 3)],
  [`PROG`], [Akkordfolge: 0 i–VI–III–VII (Techno/Trance), 1 i–iv (Deep-House-Vamp), 2 i–VII (hypnotisch), 3 i–II (phrygische Bedrohung)],
  [`CHORDS`], [0 Dreiklänge, 1 Septakkorde, 2 Nonenakkorde (Kapitel 5)],
)

Startpunkte zum Ausprobieren:

#tbl(
  (auto, auto, auto, auto, 1fr),
  [*MODE12*], [*PROG*], [*CHORDS*], [*ROOT*], [*Ergebnis*],
  [3 (dorisch)], [1], [2], [0], [Deep House],
  [5 (phrygisch)], [3], [0], [−4 (F)], [harter Techno],
  [1 (Dur)], [0], [1], [3 (C)], [euphorisches House],
  [4 (Moll)], [2], [0], [0], [hypnotischer Techno],
  [0 (lydisch)], [2], [2], [3], [schwebendes Ambient/Progressive],
)

// ============================================================
= Anhang

== Übungsplan

#tbl(
  (auto, 1fr, 1fr),
  [*Einheit*], [*Kapitel*], [*Ziel*],
  [1], [0, 1], [Intervalle 3, 4, 7, 12 sicher erkennen; Dur und Moll unterscheiden],
  [2], [2, 3], [Skala als Tonvorrat; die Helligkeitsleiter von Moll aus nach oben],
  [3], [3, 4], [jeden Modus über seinen orangen Ton erkennen; dorisch gegen Moll],
  [4], [5, 6], [Akkordqualitäten: Dur, Moll, vermindert, übermäßig, sus, 7er],
  [5], [7, 8], [Spannung mit verminderten Akkorden; Chord Memory],
  [6], [9, 10, 11], [Leitton und Kadenz; Paralleltonarten; Quintenzirkel],
  [danach], [12], [eigene Kombinationen, dann in einen eigenen Track übertragen],
)

Zum Wiederholen: Wähle ein Kapitel, stelle einen Slider blind (ohne hinzusehen) auf einen Zufallswert und rate, was du hörst. Dann im Code nachsehen.

== Häufige Akkordfolgen

#tbl(
  (auto, auto, 1fr),
  [*Stufen*], [*in A-Moll / C-Dur*], [*Charakter und Einsatz*],
  [i – VI – III – VII], [Am – F – C – G], [dunkel-episch: Techno, Trance, Electronica],
  [i – VII – VI – VII], [Am – G – F – G], [treibend: Trance, Breakdowns],
  [i – iv], [Am – Dm (dorisch: Am – D)], [Deep-House-Vamp],
  [i – VII], [Am – G], [hypnotisch, endlos],
  [i – ♭II], [Am – B♭], [phrygisch, bedrohlich: harter Techno, EBM],
  [i – iv – v], [Am – Dm – Em], [klassisches Moll],
  [i – VI – iv – V], [Am – F – Dm – E], [Moll mit Leitton: Sog zum Drop],
  [I – V – vi – IV], [C – G – Am – F], [Pop- und House-Hymnen, hell bis gefühlvoll],
  [I – ♭VII], [A – G], [mixolydisch: Disco, Funk House],
)

== Strudel-Spickzettel

#tbl(
  (auto, 1fr),
  [*Code*], [*Bedeutung*],
  [`n("0 2 4").scale('A:minor')`], [Skalenstufen (0 = Grundton) in eine Skala setzen. Stufe 7 = Grundton eine Oktave höher],
  [`'A:dorian'`, `'C3:major'`], [Grundton (optional mit Oktave), Doppelpunkt, Skalenname auf Englisch],
  [`n("[0,2,4]")`], [Komma = gleichzeitig: ein Akkord aus Stufe 1, 3 und 5],
  [`.trans(-12)`], [alle Töne um Halbtöne verschieben (−12 = eine Oktave tiefer)],
  [`note("a3 c4 e4")`], [feste Tonnamen statt Stufen],
  [`.struct("~ x ~ x")`], [Rhythmus aufprägen (x = spielen, \~ = Pause)],
)

Skalennamen in Strudel: `major`, `minor`, `dorian`, `phrygian`, `lydian`, `mixolydian`, `locrian`, `harmonic minor`, `melodic minor`, `major pentatonic`, `minor pentatonic`, `chromatic` (auch `ionian` und `aeolian`).

Wer in einem eigenen Track mit Stufen statt Tonnamen schreibt, kann Tonart und Modus später mit einem einzigen Wert ändern, genau wie in Kapitel 12.

== Weitere Skalen (nicht im Tutorial)

#tbl(
  (auto, auto, auto, 1fr),
  [*Skala*], [*Schritte*], [*auf A*], [*Klang und Einsatz*],
  [melodisch Moll], [G H G G G G H], [A B C D E F♯ G♯], [Moll mit heller Sexte und Septime: Melodien, Leads],
  [Dur-Pentatonik], [G G 3 G 3], [A B C♯ E F♯], [hell, offen: Hooks, Piano-Loops],
  [Blues], [3 G H H 3 G], [A C D E♭ E G], [Moll-Pentatonik mit „Blue Note“: Acid- und Blues-Anklänge],
  [Ganzton], [G G G G G G], [A B C♯ D♯ F G], [ohne Zentrum, traumhaft: Ambient, experimenteller Techno],
)

(3 = drei Halbtöne.)

== Glossar

#tbl(
  (auto, auto, 1fr),
  [*Deutsch*], [*Englisch*], [*Erklärung*],
  [Halbton, Ganzton], [semitone, whole tone], [kleinster Abstand (1 Taste); zwei Halbtöne ergeben einen Ganzton],
  [Oktave], [octave], [Abstand mit doppelter Frequenz (12 Halbtöne); die Tonnamen wiederholen sich],
  [Intervall], [interval], [Abstand zwischen zwei Tönen],
  [Grundton, Tonika], [root, tonic], [das Zentrum einer Skala oder Tonart, das „Zuhause“],
  [Skala, Tonleiter], [scale], [Auswahl von Tönen innerhalb einer Oktave],
  [Modus], [mode], [eine der sieben Skalen der weißen Tasten, z. B. dorisch],
  [Stufe], [degree], [Position eines Tons oder Akkords in der Skala (I, II, III …)],
  [Dreiklang], [triad], [Grundton, Terz und Quinte übereinander],
  [Septakkord], [seventh chord], [Dreiklang plus Septime],
  [vermindert], [diminished (dim, °)], [kleine Terz + verminderte Quinte (0 3 6)],
  [übermäßig], [augmented (aug, +)], [große Terz + übermäßige Quinte (0 4 8)],
  [Vorhalt], [suspended (sus)], [Terz durch Sekunde oder Quarte ersetzt],
  [Leitton], [leading tone], [Ton einen Halbton unter dem Grundton, zieht nach Hause],
  [Kadenz], [cadence], [Akkordfolge, die einen Abschnitt abschließt],
  [Paralleltonart], [relative key], [Dur- und Moll-Tonart mit denselben Tönen],
  [Quintenzirkel], [circle of fifths], [alle Tonarten im Quintabstand angeordnet],
  [Konsonanz, Dissonanz], [consonance, dissonance], [Verschmelzen (ruhig) und Reiben (gespannt) von Tönen],
  [Bordunton], [drone], [ein lange liegender Ton, der das Zuhause hörbar macht],
  [Vamp], [vamp], [Schleife aus wenigen Akkorden, die endlos pendelt],
)
