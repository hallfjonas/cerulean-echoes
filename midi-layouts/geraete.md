# Geräteliste

Unsere MIDI-Controller. Ab Werk heißen beide Launch Control XL 3 gleich (`LCXL3 1 MIDI Out`).
Deshalb sind sie in macOS umbenannt (Audio-MIDI-Setup → Fenster → MIDI-Studio einblenden → Doppelklick aufs Gerät).

| Name  | Gerät                        | Rolle in Zwei-Controller-Tracks | Custom Modes            |
|-------|------------------------------|---------------------------------|-------------------------|
| Jonas | Novation Launch Control XL 3 | Farbe (Spalten 1–7) + global (Spalte 8) | Mode 16, Mode 2, Mode 1 |
| Jojo  | Novation Launch Control XL 3 | Fundament (Beat + Bass, alle 8 Spalten) | Mode 16 |

- Beide Controller haben dasselbe CC-Layout (siehe `CLAUDE.md`, Abschnitt „Controller mapping“).
- Die Namen stehen nur in macOS, nicht auf dem Controller. Auf einem anderen Rechner heißen die Geräte wieder `LCXL3 1`.
  Steckt man sie an einen anderen USB-Anschluss, können die Namen mitwandern: kurz im MIDI-Studio prüfen.
- Nach dem Umbenennen Chrome ganz neu starten, sonst sieht Strudel noch die alten Namen.
- `setup0.syx`: Custom-Mode-Datei aus Novation Components (heißt im Gerät „New Custom Mode“).
- Ein Controller allein (`*-single.strudel`, oder Jojos Gerät fehlt): Mode 1 = Jojo, Mode 2 = Jonas.
  Mode 1 muss in Components dieselben CCs wie Mode 16 bekommen (Fader 5–12, Knöpfe 13–36, Buttons 37–52).
