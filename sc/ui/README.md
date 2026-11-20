# LC-Ansicht (Web-UI) für die SuperCollider-Version

> Im Player (`tools/trajectory`, `node trajectory/server.mjs`) erscheint dieselbe Seite als MIDI-Panel der SC-Tracks
> (unter `/sc/`, über `sc-link.mjs`, ohne diese Brücke; eigene Ports, läuft neben `live.scd`). Die Brücke hier bleibt für
> das Spielen aus der SuperCollider-IDE mit `live.scd`.

`live.scd` startet sie mit: die Brücke (`bridge.mjs`, Node.js, keine Pakete nötig) und einen Browser-Tab auf
http://localhost:7770. Vom Handy oder Tablet im selben Netz: die Adresse, die die Brücke beim Start ins
Post-Fenster schreibt (`phone/tablet: http://…:7770`).

```
Launch Controls ──MIDI──▶ SuperCollider ◀──OSC (UDP 57130 ⇄ 57120)──▶ bridge.mjs ◀──HTTP──▶ Browser
```

Die Launch Controls gehen nie über die Brücke: Stürzen Browser oder Brücke ab, laufen Musik und Controller weiter.

- **Anzeige:** beide Seiten nebeneinander wie `▣ LC big` in Strudel, Werte live (auch jede Bewegung an einem LC),
  Chapter, Akkorde, Break, Takt, Akkord des Takts. Die zuletzt benutzte Seite hat einen farbigen Rahmen.
- **Aussehen:** zwei Themes nach `UI-REDESIGN.md`, „Black“ (Torso-artig, Standard) und „TE“ (Teenage-Engineering-artig);
  umschalten unten in der Statusleiste (`Black / TE`) oder im Player unter Visual settings („Panel theme“, Taste T).
- **Bedienen mit Maus oder Touch:** Regler hoch/runter ziehen (Shift = fein, Doppelklick = 0, Mausrad),
  Fader anklicken oder ziehen, Tasten drücken. **Shift-Klick** hält eine Taste gedrückt (Drop, Oktave), bis man
  sie wieder anklickt. Ein Klick schickt dieselbe CC wie ein Launch Control: Für den Track ist es egal, woher er
  kommt; mit LC gilt der zuletzt bewegte Regler.
- **Namen** der Spalten und Regler kommen aus den `// @col` / `// @ctl`-Zeilen der Track-Datei
  (`sc/tracks/…/….scd`), im selben Format wie in den Strudel-Tracks. Noch nicht portierte Regler bleiben leer.
- **Spektrum** (unter Mode 2): der Master-Ausgang aus SuperCollider (`/ce/spectrum`, 48 Bänder, `lib/ui.scd`).
- Brücke von Hand starten: `node sc/ui/bridge.mjs` (läuft weiter, wenn SC neu startet; sie holt sich alles neu).
