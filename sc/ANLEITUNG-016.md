# Bedienungsanleitung: Track 016 (Groove Techno, Opus) in SuperCollider

Stand 20.11.2026. **Alle Spalten sind portiert**: Mode 1 Spalten 1–7, Mode 2 Spalten 1–7 (Spalte 3 = Stab Shape),
die globale Spalte 8 und der Launchkey. Jede Spur wurde automatisch gegen den Strudel-Track
`tracks/techno/groove/016-grroove-opus/016-grroove-opus.strudel` verglichen (dieselben Noten, Details in
`sc/PORTING.md`, Abschnitt 016). **Noch nicht mit dem Ohr abgenommen.** Optimiert wird erst danach.

Einrichten, Starten, Stoppen und Probleme wie bei 009 (`sc/ANLEITUNG.md`). Unterschiede:

- **Track wählen:** im Player (`tools/trajectory`, Katalog: „016-grroove-opus“) oder in `sc/live.scd` die Zeile
  `var trackName = …;` auf `"016-grroove-opus"` ändern.
- **Custom Modes:** die gemeinsamen (`midi-layouts/lcxl3-mode1.syx` / `-mode2.syx`, Slots 1 und 2).
- **Kein Master-Fader.** Der Fader von Spalte 8 heißt **Wumms** (wie in Strudel): mehr Tiefe, Punch und Zerrung
  auf Kick, Rumble, Sub und Bass. Ton gibt es also schon mit den Spalten-Fadern; Wumms auf 0 = der normale Mix.
- **Startwerte wie in Strudel:** der Pad-Space steht beim Start auf 50 %, bis man den Regler bewegt.

## Was sofort wirkt

- **Immer sofort**, auch auf klingende Töne: Space (Hall), Echo-Würfe (Strings, Stab), die globale Spalte (Fog,
  Thin, Tension). **Tension blendet Pads und Strings live ein** (Pads 30 % → voll über die erste Hälfte, Strings ab
  0,2, voll ab 0,7): ein schon klingender Akkord wird lauter (in Strudel erst der nächste).
- **Fader, Modrad und Wumms ab dem nächsten Ton** (wie in Strudel): klingende Töne behalten ihre Lautstärke.
- **Brightness sofort** nur bei den langen Klängen: Pads, Strings, Launchkey-Tasten.
- **Ab dem nächsten Ton:** Brightness und Reihe 3 aller kurzen Klänge (Kick, Rumble, Sub, Bass, Wood, Hats,
  Percussion, Stab, Answer, Accents, FX), die ganze Stab-Shape-Spalte (Snap, Length, Resonance, Drive), Strings-Swell,
  Launchkey-Klangmischung (Regler 2–4) und Länge.
- **Ab dem nächsten Takt:** alle Pattern-Tasten (Taste 1), Stab Shape Taste 1 (Vanish), Chapter, Break,
  Pad-Farbe (Pad-Taste 2).

## Belegung

Dieselbe wie im Strudel-Track (die `@ctl`-Texte im Track, in der LC-Ansicht).
Mode 1 = Foundation (Kick, Rumble, Sub, Bass, Wood, Hats, Percussion), Mode 2 = Colour (Pads, Strings, Stab Shape,
Stab, Answer, Accents, FX), Spalte 8 global: Fog, Thin, Tension, Wumms, Chapter (dunkel → gespannt → warm), Break.
Stab Shape (Mode 2, Spalte 3) hat keinen eigenen Klang: Reihe 1 Snap, Reihe 2 Length, Reihe 3 Resonance,
Fader Drive, Taste 1 Vanish (Stab raus / wieder rein), Taste 2 Ratchet.

Launchkey MK4 25 (Regler CC 21–28), wie 008: Tasten = Jonas' Keys aus 009 (Modrad = Lautstärke), Drum-Pads
(Kanal 10) = 16 One-Shots (Stimmen, Toms, Braaam …). Regler 1 Brightness, 2 Piano → Rhodes, 3 B3 → M1,
4 Vibes → Marimba, 5 Länge, 6 Hall, 7 Echo, 8 Pad-Fog. Regler 2 steht auf Piano + Rhodes, bis man ihn dreht.

## Abweichungen von Strudel (bewusst)

- Tension blendet Pads und Strings live (s. o.); Strings laufen dafür auch unter Tension 0,2 stumm mit.
- Strudel-Eigenheiten sind übernommen (Answer kann eine Note doppelt spielen, die Accents wählen Klang und Tonhöhe
  aus derselben Zufallszahl, die entscheidet, ob sie spielen, und spielen ohne FM; der eigene Tiefpass des FX-Saw wird vom Spalten-Tiefpass
  überschrieben). Details und offene Fragen: `sc/PORTING.md`, Abschnitt 016.
