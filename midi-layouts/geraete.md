# Geräteliste

Unsere MIDI-Controller. Ab Werk heißen beide Launch Control XL 3 gleich (`LCXL3 1 MIDI Out`).
Deshalb sind sie in macOS umbenannt (Audio-MIDI-Setup → Fenster → MIDI-Studio einblenden → Doppelklick aufs Gerät).

| Name      | Gerät                        | Rolle (Set 011 und alte Zwei-Controller-Versionen) | Custom Modes            |
|-----------|------------------------------|---------------------------------|-------------------------|
| Jonas     | Novation Launch Control XL 3 | Farbe (Spalten 1–7) + global (Spalte 8) | Mode 16, Mode 2, Mode 1 |
| Jojo      | Novation Launch Control XL 3 | Fundament (Beat + Bass, alle 8 Spalten) | Mode 16 |
| Launchkey | Novation Launchkey MK4 25    | Dritte Person: Tasten + Drum-Pads (Ein-Datei-Tracks 007–010) | Werkseinstellung |

- Beide Controller haben dasselbe CC-Layout (siehe `CLAUDE.md`, Abschnitt „Controller mapping“).
- Die Namen stehen nur in macOS, nicht auf dem Controller. Auf einem anderen Rechner heißen die Geräte wieder `LCXL3 1`.
  Steckt man sie an einen anderen USB-Anschluss, können die Namen mitwandern: kurz im MIDI-Studio prüfen.
- Nach dem Umbenennen Chrome ganz neu starten, sonst sieht Strudel noch die alten Namen.
- `setup0.syx`: Custom-Mode-Datei aus Novation Components (heißt im Gerät „New Custom Mode“).
- Ein Controller allein (Ein-Datei-Track, `*-single.strudel`, oder Jojos Gerät fehlt): Mode 1 = Jojo, Mode 2 = Jonas.
  Mode 1 muss in Components dieselben CCs wie Mode 16 bekommen (Fader 5–12, Knöpfe 13–36, Buttons 37–52).

## Ein-Datei-Tracks (007, 008, 009, 010)

Eine Datei für jede Kombination von Controllern, alle optional:

- Jeder angeschlossene Launch Control XL 3 wird gefunden, egal wie er heißt (Port mit `LCXL3` im Namen, ohne `DAW`).
  Umbenennen ist dafür nicht nötig. Jeder bekommt das volle Layout: Mode 1 = Fundament, Mode 2 = Farbe.
  Auf jedes Gerät gehören beide Custom Modes des Tracks (`NNN-…-mode1.syx` in Slot 1, `-mode2.syx` in Slot 2).
- Zwei LCs steuern dieselben Klänge: Pro Regler gilt der Controller, der zuletzt bewegt wurde. Button-Drücke zählen
  von beiden. Vorher absprechen, wer welche Seite spielt.
- Kein LC gefunden: Warnung in der Konsole, alles bleibt still.

### Launchkey MK4 25

macOS zeigt zwei Ports: `Launchkey MK4 25 MIDI Out` (Tasten, Pads, Knöpfe) und `Launchkey MK4 25 DAW Out` (nicht
benutzt). Fehlt das Gerät, bleibt sein Teil stumm.

| Bedienelement | Nachricht | Wirkung |
|---|---|---|
| Tasten | Noten, Kanal 1 | Pad je Track: 007 Glas-Pad, 008 dunkles Techno-Pad, 009 Rhodes Mark I, 010 warmes Pad |
| Mod-Wheel | CC 1 | Lautstärke der Tasten (× Master-Fader); auf 0 stumm |
| Drehknöpfe 1–8 | CC 21–28, Kanal 1 | 1 Cutoff, 2 Resonanz, 3 Attack, 4 Notenlänge, 5 Detune, 6 Hall, 7 Echo, 8 One-Shots dunkler |
| Drum-Pads (Drum-Mode) | Noten 36–51, Kanal 10 | 16 One-Shots je Track (Pad 1 und 5 = die zwei Stimm-Samples); 008: dunkel (909, 808, Modular, Metal, Space, Wind), 007: Glocken, Chor, Wind, Rauschen, 009: House-Kit (909, 727, Orgel-, Bläser-Stab), 010: Congas, Marimba, Shaker |

- Die Tasten haben kein Note-off: Strudel spielt jede Note mit fester Länge (Knopf 4), Halten verlängert nichts.
- Kanal 10 für die Pads ist angenommen, nicht nachgemessen. Spielen die Pads stattdessen den Pad-Klang, senden sie auf
  einem anderen Kanal: `LK_PAD_CHAN` im Track anpassen.
