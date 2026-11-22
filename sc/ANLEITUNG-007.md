# Bedienungsanleitung: Track 007 (Ambient) in SuperCollider

Stand 18.11.2026. **Alle Spalten sind portiert**: Jojo 1–7, Jonas 1–7, die globale Spalte 8 und der Launchkey.
Jede Spur wurde automatisch gegen den Strudel-Track `(git history) tracks/ambient/007-ambient-soundscape/007-ambient.strudel`
verglichen (dieselben Noten, Details in `sc/PORTING.md`, Abschnitt 007). Optimiert wird erst danach.

Einrichten, Starten, Stoppen und Probleme wie bei 009 (`sc/ANLEITUNG.md`). Unterschiede:

- **Track wählen:** in `sc/live.scd` die Zeile `var trackName = …;` auf `"007-ambient"` ändern.
- **Custom Modes:** die gemeinsamen (`midi-layouts/lcxl3-mode1.syx` / `-mode2.syx`, Slots 1 und 2). Die Belegung ändert sich nicht.
- **Samples:** `sc/samples/voice/david.flac` (Jonas 7, die gesprochene Aufnahme, 9:13 min) ist 46 MB groß und wird
  beim Start geladen (ein, zwei Sekunden).

## Was sofort wirkt

- **Immer sofort**, auch auf klingende Töne: Space (Hall), Echo-Würfe, die globale Spalte (Fog, Room, Tension,
  Master; auch Tensions Echo und das Tape-Wobble auf den langen Klängen).
- **Fader und Modrad ab dem nächsten Ton** (wie in Strudel): klingende Töne behalten ihre Lautstärke, der nächste
  Anschlag kommt lauter oder leiser. Nur Master wirkt sofort (Notbremse).
- **Brightness sofort** bei den langen Klängen: Sea / Wind, Drone, Bass, Pad, Eno, Shimmer, Choir, Voice und die
  Launchkey-Tasten (dort auch Resonance und Detune).
- **Reihe 3 sofort:** Sea ↔ Wind (Überblendung), Drone Beating (Anteil und Verstimmung), Voice Distortion (Radio →
  kaputt, auf jede laufende Silbe).
- **Ab dem nächsten Ton:** Brightness der kurzen Klänge (Pulse, Rim, Shaker, Wood, Marimba, Toms, Glitter), Reihe 3
  von Pulse, Bass (Groove), Rim, Shaker, Wood, Pad (Swell), Eno, Marimba, Toms, Choir, Glitter; Launchkey Attack
  und Länge.
- **Ab dem nächsten Takt:** alle Pattern-Tasten (Taste 1), Chapter, Break, Eno / Shimmer (Jonas 2, Taste 2).

## Belegung

Dieselbe wie im Strudel-Track (die `@ctl`-Texte im Track, in der LC-Ansicht). Mode 1 = Jojo (Pulse, Sea / Wind, Drone, Bass, Rim,
Shaker, Wood / Drops), Mode 2 = Jonas (Pad, Eno / Shimmer, Marimba, Toms, Choir, Glitter, Voice), Spalte 8 global:
Fog, Room, Tension, Master, Chapter (schwebend → melancholisch → seltsam), Break. Jojos Spalte 8 (Crackle) ist wie
in Strudel aus.

Launchkey MK4 25: Tasten = weiches Glas-Pad (Modrad = Lautstärke), Drum-Pads (Kanal 10) = 16 Ambient-One-Shots
(links die gesprochenen Samples, rechts Glocken, Stimmen, Wind). Regler 1 Brightness, 2 Resonance, 3 Attack,
4 Länge, 5 Detune, 6 Hall, 7 Echo, 8 Pad-Fog.

## Abweichungen von Strudel

Siehe `sc/PORTING.md`, Abschnitt 007. Hörbar am ehesten: der Hall (superdough würfelt seine Impulsantwort bei
jedem Laden neu, SC nimmt eine feste) und die 80-Hz-Untergrenze der Tiefpässe (siehe dort).
