# Bedienungsanleitung: Track 010 (Ambient House) in SuperCollider

Stand 18.11.2026. **Alle Spalten sind portiert**: Jojo 1–7, Jonas 1–7, die globale Spalte 8 und der Launchkey.
Jede Spur wurde automatisch gegen den Strudel-Track `tracks/ambient-house/010-ambient-house/010-ambient-house.strudel`
verglichen (dieselben Noten, Details in `sc/PORTING.md`, Abschnitt 010). Optimiert wird erst danach.

Einrichten, Starten, Stoppen und Probleme wie bei 009 (`sc/ANLEITUNG.md`). Unterschiede:

- **Track wählen:** in `sc/live.scd` die Zeile `var trackName = …;` auf `"010-ambient-house"` ändern.
- **Custom Modes:** die gemeinsamen (`midi-layouts/lcxl3-mode1.syx` / `-mode2.syx`, Slots 1 und 2).

## Was sofort wirkt

- **Immer sofort**, auch auf klingende Töne: Space (Hall), der Echo-Wurf (Lead), die globale Spalte (Fog, Thin,
  Tension, Master; auch Tensions Echo und Hall).
- **Fader und Modrad ab dem nächsten Ton** (wie in Strudel): klingende Töne behalten ihre Lautstärke, der nächste
  Anschlag kommt lauter oder leiser. Nur Master wirkt sofort (Notbremse).
- **Brightness sofort** bei den langen Klängen: Noise Pump, Pad, Lead und die Launchkey-Tasten.
- **Ab dem nächsten Ton:** Brightness der kurzen Klänge (Kick, Sub, Bass, Clap, Hats, Congas, Deep Chords, Arp,
  Marimba, Glockenspiel, Birds) und Reihe 3 überall; Launchkey-Klangmischung (Regler 2–4) und Länge.
- **Ab dem nächsten Takt:** alle Pattern-Tasten (Taste 1), Break. **Chapter** (Akkordfolge) ab der nächsten
  4-Takt-Phrase. Pad-Taste 2 (Freeze) hält den Akkord für alle, solange sie gedrückt ist.

## Belegung

Dieselbe wie im Strudel-Track. Mode 1 = Jojo (Kick, Noise Pump, Sub, Bassline, Clap / Rim, Hats, Congas),
Mode 2 = Jonas (Pad, Deep Chords, Pluck Arp, Lead, Marimba, Glockenspiel, Birds), Spalte 8 global: Fog, Thin,
Tension, Master, Chapter (Dusk → Sunrise → Floating → Warmth), Break. Jojos Spalte 8 (Shaker / Ride) ist wie in
Strudel aus.

Launchkey MK4 25 (Regler CC 21–28): Tasten = Jonas' Keys (wie 008), Drum-Pads (Kanal 10) = 16 One-Shots
(Stimmen, Rim, Marimba, Glocken, Shaker, Wind …). Regler 1 Brightness, 2 Piano → Rhodes, 3 B3 → M1, 4 Vibes →
Marimba, 5 Länge, 6 Hall, 7 Echo, 8 Pad-Fog.
