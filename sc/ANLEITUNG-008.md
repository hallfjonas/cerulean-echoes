# Bedienungsanleitung: Track 008 (Groove Techno) in SuperCollider

Stand 18.11.2026. **Alle Spalten sind portiert**: Jojo 1–7, Jonas 1–7, die globale Spalte 8 und der Launchkey.
Jede Spur wurde automatisch gegen den Strudel-Track `tracks/techno/008-groove-techno/008-groove-techno.strudel`
verglichen (dieselben Noten, Details in `sc/PORTING.md`, Abschnitt 008). Optimiert wird erst danach.

Einrichten, Starten, Stoppen und Probleme wie bei 009 (`sc/ANLEITUNG.md`). Unterschiede:

- **Track wählen:** in `sc/live.scd` die Zeile `var trackName = "009-house";` auf `"008-groove-techno"` ändern.
- **Custom Modes:** dieselben wie für den Strudel-Track: `tracks/techno/008-groove-techno/008-groove-techno-mode1.syx`
  (Slot 1) und `…-mode2.syx` (Slot 2). Die Belegung ändert sich nicht.
- **Startwerte wie in Strudel:** Jonas' Pad-Space steht beim Start auf 50 %, der Launchkey-Hall (Regler 6) auf
  40 %, bis man den Regler bewegt.

## Was sofort wirkt

- **Immer sofort**, auch auf klingende Töne: alle Fader, Space (Hall), Echo-Würfe, die globale Spalte (Fog, Thin,
  Tension, Master).
- **Brightness sofort** nur bei den langen Klängen: Pads, Strings (dort auch Reihe 3 Sound: JX-10 ↔ analog),
  FX / Breath und die Launchkey-Tasten (dort auch Resonance und Detune).
- **Ab dem nächsten Ton:** Brightness und Reihe 3 aller kurzen Klänge (Kick, Rumble, Sub, Bassline, Clap, Hats,
  Percussion, Sequence, Stab, Answer, Dark Perc), Launchkey Attack und Länge.
- **Ab dem nächsten Takt:** alle Pattern-Tasten (Taste 1), Chapter, Break, Pad-Farbe (Pad-Taste 2).

## Belegung

Dieselbe wie im Strudel-Track (Layout-Sheet `tracks/techno/008-groove-techno/008-groove-techno-layout.pdf`).
Mode 1 = Jojo (Kick, Rumble, Sub, Bassline, Clap, Hats, Percussion), Mode 2 = Jonas (Pads, Strings, Sequence,
Stab, Answer, Dark Perc, FX / Breath), Spalte 8 global: Fog, Thin, Tension, Master, Chapter (dunkel → gespannt →
warm), Break. Jojos Spalte 8 (Ride) ist wie in Strudel aus.

Launchkey MK4 25: Tasten = dunkles Supersaw-Pad (Modrad = Lautstärke), Drum-Pads (Kanal 10) = 16 dunkle
One-Shots. Regler 1 Brightness, 2 Resonance, 3 Attack, 4 Länge, 5 Detune, 6 Hall, 7 Echo, 8 Pad-Fog.
