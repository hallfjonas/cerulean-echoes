# Ideen für später

## Custom-Mode-Datei (.syx) aus dem Strudel-File erzeugen (Skill)
Ziel: Das OLED des Launch Control XL 3 zeigt für jeden Regler den Namen aus dem Track (z. B. „Kick Softness“),
nicht nur die CC-Nummer. Ein Skill/Tool liest die `@col`/`@ctl`-Tags eines Tracks (dual und single) und schreibt
pro Controller und Mode eine `.syx`, die man in Novation Components lädt.

Was wir aus `midi-layouts/setup0.syx` (ein leerer Custom Mode aus Components) schon ablesen können:
- Zwei SysEx-Nachrichten (Seiten), je `F0 00 20 29 02 15 05 00 45 <seite> 7F 20 10 <Name, 16 Zeichen> …  F7`.
- Pro Regler ein Block `49 <regler-id> 02 <typ/kanal> 00 01 <40|50> 00 <CC> 7F 00`
  (ids 0x10–0x27 = Knöpfe, 0x28–0x2F = Fader, 0x30–0x3F = Buttons).
- Danach pro Regler `60 <regler-id>` – vermutlich die Stelle für den Namen (in der Datei leer).
Offen: genaues Format der Namen (Länge, Zeichensatz), Bedeutung der übrigen Bytes. Am besten in Components einem
Regler einen Namen geben, exportieren und mit dieser Datei vergleichen.
