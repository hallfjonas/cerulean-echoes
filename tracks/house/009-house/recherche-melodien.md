# Recherche Melodien (2026-11-08) — [V] geprüft, [S] nur Suchtreffer, [U] unbelegt; nichts angehört

## Escravos De Jo
- [S] Trompete Winston Byrd, Flöte Talib Kibwe, Gitarre Stephen Ulrich, Perc. Claussell (Bandcamp-Snippet, Seite heute 404).
- [V] 118.9 BPM, 5:26 (cs.uwaterloo.ca/~dtompkin/music/disc/SPBRAZIL_ELC.html). [S] rollender Baião-Groove, Nascimento-Melodie.
- [U] Trompetenlinie selbst: keine Beschreibung gefunden.
- [V] Volkslied „Escravos de Jó“ (mamalisa.com/?t=es&p=208, MIDI mamalisa.com/midi/escravos.mid), C-Dur, 2/4:
  Teil 1: Auftakt G4 | C5 B4 A4 | G4 … G4 | F4 E4 F4 A4 | G4. Teil 2: G4 E4 G4 E4 | G4 E4 G4 C5 | E5 E5 D5 | C5 …
  „Guerreiros…“ G A G G | G A G G | A G A B | C5. Eine Quinte hoch (G-Dur) = genau die Töne von A-dorisch;
  Teil 1 landet dann auf D (Grundton D9). Rechte [U]: traditionell/anonym; nur die Volksmelodie nutzen.

## Wie Bläser-/Vibe-Linien gebaut sind
- Sax über House: strikte 8-Takt-Phrasen, einfache Rhythmen, Lick wiederholen, Lücken füllen statt konkurrieren,
  A-Moll-Pentatonik (saxschoolonline.com/articles/dj-sax-how-to-get-started/) [V].
- Afro House: bewusst einfache Lead-Linie (3 Töne), wiederholte Motive, 118–122 BPM (native-instruments.com/blogs/blog/afro-house-production-101) [V].
- Latin-Brass: Stabs kurz, auf Offbeat [S]; Louie Vega: „melody is key“, auch bei kurzem Hook [S]; schnelle Linien liegen Bläsern
  schlecht; Ruf – Pause – Antwort [S].
- Folgerung: ein 2–4-Takt-Motiv (pentatonisch/dorisch, 8tel + Offbeat-16tel, lange Landetöne), 1–2 Takte Pause, Antwort;
  Varianten ändern nur Ende, Einsatz oder Stufe.

## Variation statt Zufall (Strudel, im Quellcode geprüft)
- `pick`: zwischen geschriebenen Varianten wählen; Plan z. B. "<0!2 0!2 1!2 0!2>" (A A B A je 2 Takte).
- `ribbon(offset, cycles)`: einmal zufällig, dann fester 8-Takt-Plan (Knopf = Offset → anderer, aber fester Plan).
- `wchooseCycles`, `lastOf(4, x => x.late(1/16))` (Verschiebung), `linger` (Fragment), `.add(...)` vor `.scale` (Stufe),
  Ruf/Antwort zwischen Spalten per `mask("<1 1 0 0>")` / `"<0 0 1 1>"`.

## Klangquellen
- VCSL (in Strudel): sax, sax_stacc, sax_vib, saxello, vibraphone, vibraphone_soft, marimba (Oktave prüfen: evtl. +1).
- VSCO 2 CE: Trompete sus / susvib / stac / straightM-sus / harmonM-sus (Harmon-Dämpfer = „Miles“-Farbe); Dateinamen eine Oktave
  zu tief (D4 klingt D5).
- Karoryfer Weresax (Alt), Bear Sax (Bariton), CC0.
- Aufgenommene Phrasen (Freesound): 77706–77717 sorohanro „Jazz Trumpet Loops in F“ (CC BY, 12 echte Phrasen, 90 BPM → als One-Shots);
  424876 / 424894 emirdemirel „Improvisation on Dorian“ Trompete / Sax (CC BY, Bb dorisch, zum Schneiden);
  479052 Tenor-Phrase G dorisch (CC0); 131275 Sax-Loop 120 BPM 8 Takte (CC0); 753346 Vibraphon-Melodie (CC0).
  Keine echte Bläser-Phrase bei 120–126 BPM in A gefunden.

## Phrasen-Entwürfe (Agent, nicht gehört) — 16 Schritte pro Takt, ungerade Takte Am9, gerade D9
- T1 „Escravos-Ruf“ (Volkslied Teil 1, Quinte hoch): b1 g5@3 ~ f#5 e5@2 d5@7 ~ d5 | b2 c5@2 b4 c5@2 e5@2 d5@5 ~@4 | b3 ~@16 | b4 ~@14 d5@2
  Varianten: gerader Volkslied-Rhythmus; offenes Ende auf F#; eine Stufe höher.
- T2 „Antwort“ (Volkslied Teil 2): b3 ~@4 d5 ~ e5 d5 ~@2 d5 ~ e5 ~ f#5@2 | b4 g5@2 f#5@6 ~@6 d5@2
- T3 „Pentatonik-Hook“: [~@2 e5 ~ g5@2 ~ a5@3 g5 e5@2 ~@3] [~@2 d5 ~ c5@2 ~ a4@6 ~@3] (+ Varianten Ende E / Einsatz später)
- T4 „Lange Töne“ (Harmon-Dämpfer) [U].
- V1 Vibe-Offbeat-Begleitung, V2 Vibe-Echo von T1 eine Oktave tiefer in Takt 3–4, V3 Tresillo 3-3-2 (Vibe/Marimba).
