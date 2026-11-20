# LC-Ansicht (Web-UI) für die SuperCollider-Version

`live.scd` startet sie mit: die Brücke (`bridge.mjs`, Node.js, keine Pakete nötig) und einen Browser-Tab auf
http://localhost:7770. Vom Handy oder Tablet im selben Netz: die Adresse, die die Brücke beim Start ins
Post-Fenster schreibt (`phone/tablet: http://…:7770`).

```
Launch Controls ──MIDI──▶ SuperCollider ◀──OSC (UDP 57130 ⇄ 57120)──▶ bridge.mjs ◀──HTTP──▶ Browser
```

Die Launch Controls gehen nie über die Brücke: Stürzen Browser oder Brücke ab, laufen Musik und Controller weiter.

- **Anzeige:** beide Seiten nebeneinander wie `▣ LC big` in Strudel, Werte live (auch jede Bewegung an einem LC),
  Chapter, Akkorde, Break, Takt, Akkord des Takts. Die zuletzt benutzte Seite hat einen farbigen Rahmen.
- **Bedienen mit Maus oder Touch:** Regler hoch/runter ziehen (Shift = fein, Doppelklick = 0, Mausrad),
  Fader anklicken oder ziehen, Tasten drücken. **Shift-Klick** hält eine Taste gedrückt (Drop, Oktave), bis man
  sie wieder anklickt. Ein Klick schickt dieselbe CC wie ein Launch Control: Für den Track ist es egal, woher er
  kommt; mit LC gilt der zuletzt bewegte Regler.
- **Namen** der Spalten und Regler kommen aus den `// @col` / `// @ctl`-Zeilen der Track-Datei
  (`sc/tracks/…/….scd`), im selben Format wie in den Strudel-Tracks. Noch nicht portierte Spalten sind grau.
- Brücke von Hand starten: `node sc/ui/bridge.mjs` (läuft weiter, wenn SC neu startet; sie holt sich alles neu).
