# Bedienungsanleitung: Track 008 (Groove Techno) in SuperCollider

Stand 18.11.2026. **Alle Spalten sind portiert**: Jojo 1–7, Jonas 1–7, die globale Spalte 8 und der Launchkey.
Jede Spur wurde automatisch gegen den Strudel-Track `tracks/techno/008-groove-techno/008-groove-techno.strudel`
verglichen (dieselben Noten, Details in `sc/PORTING.md`, Abschnitt 008). Optimiert wird erst danach.

Einrichten, Starten, Stoppen und Probleme wie bei 009 (`sc/ANLEITUNG.md`). Unterschiede:

- **Track wählen:** in `sc/live.scd` die Zeile `var trackName = "009-house";` auf `"008-groove-techno"` ändern.
- **Custom Modes:** die gemeinsamen: `midi-layouts/lcxl3-mode1.syx` (Slot 1) und `-mode2.syx` (Slot 2). Die Belegung ändert sich nicht.
- **Startwerte wie in Strudel:** Jonas' Pad-Space steht beim Start auf 50 %, bis man den Regler bewegt.

## Was sofort wirkt

- **Immer sofort**, auch auf klingende Töne: Space (Hall), Echo-Würfe, die globale Spalte (Fog, Thin, Tension,
  Master).
- **Fader und Modrad ab dem nächsten Ton** (wie in Strudel): klingende Töne behalten ihre Lautstärke, der nächste
  Anschlag kommt lauter oder leiser. Nur Master wirkt sofort (Notbremse).
- **Brightness sofort** nur bei den langen Klängen: Pads, Strings (dort auch Reihe 3 Sound: JX-10 ↔ analog),
  FX / Breath und die Launchkey-Tasten (dort auch Hall und Echo).
- **Ab dem nächsten Ton:** Brightness und Reihe 3 aller kurzen Klänge (Kick, Rumble, Sub, Bassline, Clap, Hats,
  Percussion, Sequence, Stab, Answer, Dark Perc), Launchkey-Klangmischung (Regler 2–4) und Länge.
- **Ab dem nächsten Takt:** alle Pattern-Tasten (Taste 1), Chapter, Break, Pad-Farbe (Pad-Taste 2).

## Belegung

Dieselbe wie im Strudel-Track (die `@ctl`-Texte im Track, in der LC-Ansicht).
Mode 1 = Jojo (Kick, Rumble, Sub, Bassline, Clap, Hats, Percussion), Mode 2 = Jonas (Pads, Strings, Sequence,
Stab, Answer, Dark Perc, FX / Breath), Spalte 8 global: Fog, Thin, Tension, Master, Chapter (dunkel → gespannt →
warm), Break. Jojos Spalte 8 (Ride) ist wie in Strudel aus.

Launchkey MK4 25 (Regler CC 31–38): Tasten = Jonas' Keys aus 009 (Modrad = Lautstärke), Drum-Pads (Kanal 10) = 16
One-Shots (Stimmen, Toms, Braaam …). Regler 1 Brightness, 2 Piano → Rhodes, 3 B3 → M1, 4 Vibes → Marimba, 5 Länge,
6 Hall, 7 Echo, 8 Pad-Fog. Regler 2 steht auf Piano + Rhodes, bis man ihn dreht.
