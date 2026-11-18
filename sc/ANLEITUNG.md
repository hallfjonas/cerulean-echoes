# Bedienungsanleitung: Track 009 in SuperCollider

Stand 18.11.2026. **Alle Spalten sind portiert**: Jojo 1–7, Jonas 1–7, die globale Spalte 8 und der Launchkey.
Jede Spur wurde automatisch gegen den Strudel-Track verglichen (dieselben Noten, Lautheit meist auf 0,2 dB gleich;
Details in `sc/PORTING.md`). Optimiert (CPU, Pegel, Klang) wird erst danach.

**Track 008 (Groove Techno)** ist auch portiert: Unterschiede und Belegung in `sc/ANLEITUNG-008.md`.

## 1. Einmal einrichten

0. **Repo holen** (nur beim ersten Mal): Der SC-Teil liegt auf dem Branch `sc`, getrennt von den Strudel-Tracks.
   `git fetch && git checkout sc` (danach mit `git pull` aktualisieren). Alles Nötige steckt im Ordner `sc/`
   (inklusive der Samples, etwa 42 MB); die Strudel-Dateien bleiben unverändert.

1. **SuperCollider** installieren (Version 3.13 oder neuer, https://supercollider.github.io). Zusatz-Plugins
   (sc3-plugins) sind nicht nötig.
2. **Launch Control XL 3:** dieselben Custom Modes wie für den Strudel-Track laden
   (`tracks/house/009-house/009-house-mode1.syx` auf Slot 1, `…-mode2.syx` auf Slot 2, mit Novation Components).
   Es ändert sich nichts an der Belegung.
3. **Audio-Ausgang:** SuperCollider nimmt den Standard-Ausgang von macOS. Für die Scarlett vor dem Start in
   den Systemeinstellungen → Ton die Scarlett als Ausgang wählen.

## 2. Starten

1. Launch Control(s) anschließen, **alle Fader runter**. Controller können auch später eingesteckt oder
   umgesteckt werden: Sie werden innerhalb von 2 Sekunden automatisch erkannt.
2. In der SuperCollider-IDE `sc/live.scd` öffnen.
3. Alles markieren (Cmd-A) und ausführen (Cmd-Return).
4. Im Post-Fenster (rechts unten) erscheinen:
   - `MIDI connected: <Name> → lc` für jeden Launch Control, `→ launchkey` für den Launchkey,
     `→ ignored (unknown controller)` für alle anderen Controller.
   - `▶ 009-house — 124 BPM. Master fader (column 8) up to hear it.`
5. **Master-Fader (Spalte 8) hochziehen**, dann die Spalten-Fader. Vorher ist alles still, wie in Strudel.
6. Im Browser öffnet sich die **LC-Ansicht** (http://localhost:7770). Sie braucht Node.js (https://nodejs.org);
   ohne Node spielt der Track trotzdem, nur ohne Ansicht.

Die Spuren laufen ab dem nächsten Takt im Hintergrund mit. Man hört eine Spur, sobald ihr Fader und der
Master-Fader oben sind.

## 3. Belegung

Wie im Strudel-Track: **Mode 1 = Jojo** (Fundament), **Mode 2 = Jonas** (Farbe). Spalte 8 ist auf beiden Seiten
global. **Jeder Launch Control XL 3 bekommt die volle Belegung**, egal wie viele angeschlossen sind; bei
mehreren gilt der zuletzt bewegte Regler.

Andere Controller:
- **Launchkey MK4 25:** eigene Spur wie in Strudel (Tabelle unten): Tasten = Rhodes, Drum-Pads (Drum-Modus,
  Kanal 10) = 16 One-Shots. Jede Taste spielt eine Note fester Länge (Regler 4), wie in Strudel. Anders als in
  Strudel klingen Tasten und Pads **sofort** (wenige Millisekunden statt des Vorlaufs des Schedulers).
- **Alle anderen Controller** werden erkannt und im Post-Fenster aufgelistet, aber ignoriert. Ihre CC-Nummern
  würden sonst die Regler des Tracks verstellen. Ein neuer Controller-Typ bekommt einen Eintrag in `midiKinds`
  (`sc/lib/controls.scd`).

### Mode 1 – Jojo (Fundament)

Reihe 1 ist überall Brightness (dumpf ↔ hell), Reihe 2 Space (trocken ↔ Raum), der Fader der Pegel.
Taste 1 wechselt das Pattern ab dem nächsten Takt.

| Spalte | Reihe 3 | Taste 1 (Pattern) | Taste 2 (halten) |
|---|---|---|---|
| 1 Kick | Punch: knapp ↔ hart | 4/4 → Lücke jeden 4. Takt → jeden 8. | Drop: Kick raus |
| 2 Noise Pump | Motion: ruhig ↔ bewegt | Pump → Offbeat → 16tel | Riser: Rausch-Anstieg |
| 3 Sub | Length: lang ↔ kurz (Reihe 1: Sinus ↔ voll) | Pump → Offbeat → halbe Takte | Oktave höher |
| 4 Bass | Sound: FM → M1-Orgel → analog | 7 Basslinien, 3-3-2 zuerst | Oktave höher |
| 5 Clap | Complexity: einfach → Rim → Doppelschläge | 2 + 4 → Auftakt → Fill jeden 4. Takt | Snare-Wirbel |
| 6 Hats / Shaker | Hats ↔ Shaker | Offbeat → + 16tel → treibend | offene Hats |
| 7 Congas | Complexity: + Ghost Notes | Kissen → rollend → Latin | Conga-Lauf |

### Mode 2 – Jonas (Farbe)

Reihe 1 Brightness, Reihe 2 Space (erst Echo, ab gut einem Drittel auch Raum), Fader Pegel. Die Regler starten auf
den Werten der Labs (Brightness 60 %, Reihe 3 30 %) und behalten sie, bis man sie bewegt; die LC-Ansicht zeigt diese
Werte.

| Spalte | Reihe 3 | Taste 1 | Taste 2 |
|---|---|---|---|
| 1 Harmony | Streicher ↔ B3-Orgel | Chords: nächste der 10 Akkordfolgen (ab der nächsten 8-Takt-Phrase) | Echo-Wurf (halten) |
| 2 Keys | Length: kurz ↔ lang | 6 Rhythmen auf Am9 → 5 Riffs mit eigenen Akkorden | Sound (an/aus, s. u.) |
| 3 Vibraphone | Complexity: Kern → Figur → Füller → Doppelte | Offbeat → Tresillo → Ruf-Echo | Echo-Wurf (halten) |
| 4 Flute | Complexity: Kern → + Nachbarn → + Triller | 3-3-2 → Ruf + Antwort → gleichmäßige Achtel | Echo-Wurf (halten) |
| 5 Brass | Complexity: Kern → + Auftakte → + Extra-Stöße | 9 Figuren, die sparsamen zuletzt | Lift (halten) |
| 6 Strings | Complexity: unisono → Oktave → Terzen → Celli | 5 Figuren | Lift (halten) |
| 7 Guitar | Complexity: Linie → Dead Notes → Variation → Motor + Fill | 8 Linien | Lift: Phaser, heller |

- **Keys, Taste 2 = Sound:** jeder Druck schaltet um. Ist Sound an, mischen die drei Regler den Klang
  (Reihe 1 Piano → Rhodes, Reihe 2 Orgel B3 → M1, Reihe 3 Vibraphon → Marimba) und der Fader regelt, wie stark die
  Obertöne dem Anschlag folgen. Ein Keys-Riff bringt eigene Akkorde mit: Bass, Sub, Harmonie und Melodien folgen
  ihm, solange der Keys-Fader oben ist.
- **Lift (Brass, Strings, Guitar):** halten = die Gruppe wächst über zwei Takte (mehr Stimmen, heller, bis +3 dB),
  loslassen = sie geht über einen Takt zurück. Die Ansicht zeigt `Lift NN %`.
- **Echo-Wurf:** solange gehalten, ein langes punktiertes Achtel-Echo.

### Spalte 8 – global (beide Seiten)

| Element | Funktion |
|---|---|
| Reihe 1 | Fog: klar ↔ dumpf (alle Tiefpässe runter) |
| Reihe 2 | Thin: voll ↔ dünn (alle Hochpässe hoch) |
| Reihe 3 | Tension: Spannung – Echo, Hall, Filter auf |
| Fader | Master |
| Taste 1 | Chapter: Vamp (nur Am9) ↔ Progression (die Akkordfolge von Jonas 1; ab der nächsten 4-Takt-Phrase) |
| Taste 2 | Break: 1. Druck Kick, Pump, Sub, Bass raus, 2. Druck wieder rein auf die Eins (je ab nächstem Takt) |

### Launchkey MK4 25 (optional)

| Element | Funktion |
|---|---|
| Tasten | Rhodes (die Samples der Keys) mit zwei leicht verstimmten Kopien |
| Modulationsrad | Pegel der Tasten (× Master); auf 0 schweigen die Tasten, die Pads spielen weiter |
| Regler 1 | Helligkeit der Tasten (Tiefpass 300–6000 Hz, × Fog/Tension) |
| Regler 2 | Resonanz |
| Regler 3 | Anschlag: Hammer ↔ weiches Einschwellen |
| Regler 4 | Notenlänge: ¼ Takt ↔ 2 Takte (auch die Orgel-/Bläser-/Chor-Pads) |
| Regler 5 | Verstimmung der beiden Kopien |
| Regler 6 | Hall der Tasten |
| Regler 7 | Echo der Tasten |
| Regler 8 | Pad Fog: Drum-Pads klar ↔ dumpf |
| Drum-Pads 1–16 | Stimme „brace“, Clap, Open Hat, Rim (mit Echo), Stimme „letzte Wiese“, Bongo, Cowbell, Tom, Orgel, Bläser, Chor „ooh“, Crash rückwärts, Ride, Tamburin, Vibraphon, Snare |

## 4. LC-Ansicht: anzeigen und mit der Maus spielen

Die Ansicht zeigt beide Seiten nebeneinander wie `▣ LC big` in Strudel: alle Werte live (auch jede Bewegung an
einem Launch Control), oben Chapter, Akkorde, Break, Takt und den Akkord des Takts. Bei Jonas' Spalten steht der
Wert, mit dem die Spur wirklich spielt (die Startwerte der Labs, bis man einen Regler bewegt).

Ohne Launch Control (oder zusätzlich) lässt sich alles mit Maus oder Touch spielen:

| Element | Bedienung |
|---|---|
| Regler | hoch/runter ziehen · Shift = fein · Mausrad · Doppelklick = 0 |
| Fader | anklicken oder ziehen |
| Taste | klicken = drücken und loslassen; Maustaste festhalten = Taste halten |
| Taste halten, ohne die Maus festzuhalten | **Shift-Klick**: bleibt gedrückt (gestrichelter Rahmen), der nächste Klick lässt los (z. B. Drop, Oktave) |

Darunter die **Launchkey-Zeile** (immer da, auch ohne Gerät): 8 Regler und das Modulationsrad wie oben bedienbar,
**Pads** anklicken (mit Namen), **Tasten** anklicken oder über die Computertastatur spielen: die Reihe A–K sind die
weißen Tasten ab C, die Reihe darüber die schwarzen; die zwei Tasten links unten (Z/Y und X) oder ◀ / ▶ schieben die
Oktave. Gespielte Tasten und Pads leuchten kurz auf, auch die eines echten Launchkeys. Über Maus und Tastatur kommt
der Ton etwa 10–20 ms später als vom Gerät (Weg über Browser und Brücke) – zum Testen von Klang und Belegung reicht
das, die Spielbarkeit nur am echten Launchkey beurteilen.

Ein Klick wirkt genau wie dieselbe Bewegung am Launch Control; mit Controller gilt der zuletzt bewegte Regler.
**Handy/Tablet:** im selben WLAN die Adresse öffnen, die beim Start im Post-Fenster steht
(`phone/tablet: http://…:7770`).

Stürzt der Browser oder die Ansicht ab, laufen Musik und Launch Controls weiter (die Controller gehen direkt an
SuperCollider). Ansicht wieder öffnen: http://localhost:7770 im Browser.

## 5. Was anders ist als in Strudel

- **Regler und Fader wirken sofort**, auch auf Töne, die gerade klingen, nicht erst bei der nächsten Note.
- Tasten verhalten sich wie gewohnt: Pattern-Wechsel ab dem nächsten Takt bzw. der nächsten Phrase.
- **Lautstärke:** SuperCollider spielt 9 dB leiser als Strudel (Master-Trim), damit auch alle Fader oben mit
  Tension nicht übersteuern; am Interface bzw. an den Boxen entsprechend lauter drehen. Der Limiter (−1 dBFS) ist
  nur Notbremse. Anderer Wert: in `sc/lib/ce.scd` die Zeile `trimDb: -9` ändern (0 = so laut wie Strudel).
- **Harmonie live:** Brightness und Reihe 3 (Streicher ↔ B3-Orgel) verändern auch den gerade klingenden Akkord
  (in Strudel erst den nächsten). Die anderen Spalten von Jonas behalten den Klang vom Anschlag, wie in Strudel.
- **Echo:** Jede Spalte von Jonas hat ihr eigenes Echo (in Strudel teilen sie sich eines, das bei jeder Note
  umgestellt wird und dann knackt). Einzeln klingt jede Spalte gleich.
- Ein Regler, der auf denselben Wert bewegt wird, zählt nicht als Bewegung (wie in Strudel): Jonas' Spalten behalten
  dann ihre Startwerte.
- Der Status (welches Pattern, Chapter, Break) steht in der LC-Ansicht und zusätzlich als `▣ …`-Zeile im
  Post-Fenster.
- Ein paar Eigenheiten des Strudel-Tracks sind bewusst mitportiert, z. B. dass beim Ruf-Echo des Vibraphons der
  „Nachbarton“ (+1) nichts ändert, und dass Swing einen Ton knapp vor der Mitte eines Achtels doppelt spielt.
  Liste: `sc/PORTING.md`.

## 6. Stoppen und neu starten

- **Stoppen:** in einer leeren Zeile `~ce.stopTrack` ausführen (Cmd-Return). Das beendet auch die Brücke der
  LC-Ansicht.
- **Notbremse:** Cmd-. (Punkt) stoppt alles sofort.
- **Neu starten:** `live.scd` wieder komplett ausführen (Schritt 2).

## 7. Probleme

| Problem | Lösung |
|---|---|
| `No Launch Control XL 3 found` | Controller einstecken, er wird nach höchstens 2 Sekunden erkannt. Steht er nur als `ignored` im Post-Fenster, die Zeile `MIDI connected: …` an Claude schicken (Portnamen am Mac sind noch ungetestet). |
| Kein Ton | Master-Fader (Spalte 8) oben? Spalten-Fader oben? Richtiges Ausgabegerät in macOS? Nach Cmd-. muss `live.scd` neu gestartet werden. |
| LC-Ansicht zeigt „Bridge not reachable“ | `live.scd` neu starten, oder im Terminal `node sc/ui/bridge.mjs`. Steht im Post-Fenster `Node.js not found`: Node.js installieren. |
| LC-Ansicht zeigt „SuperCollider not running“ | SC läuft nicht (mehr): `live.scd` starten, die Ansicht verbindet sich von selbst. |
| Dumpf oder Rauschen; im Post-Fenster `Audio: 16000 Hz` | Bluetooth-Kopfhörer im Telefonmodus. Anderen Ausgang wählen (Systemeinstellungen → Ton) oder Apps schließen, die sein Mikrofon nutzen (Zoom, Teams …), dann `live.scd` neu starten. Es muss `Audio: 48000 Hz` dastehen. |
| Knackser / Aussetzer | In `live.scd` `hardwareBufferSize` von 128 auf 256 erhöhen und neu starten. |
| Fehlermeldung beim Start (`ERROR`) | Post-Fenster-Text an Claude schicken. |

## 8. A/B-Vergleich anhören

Der Ordner `sc/ab/` (44 MB) ist nicht im Repo; die Dateien liegen bei Johannes und werden per Nextcloud geteilt. Darin liegen 24 Takte Kick + Bass mit denselben Reglerfahrten und Tastendrücken:
`009-kick-bass-A-strudel.wav` (Strudel) und `009-kick-bass-B-supercollider.wav` (SuperCollider), beide −1,5 dB.
Wie die automatischen Vergleiche funktionieren: `sc/README.md`; Stand und Entscheidungen: `sc/PORTING.md`.

## 9. Samples

Die Spuren spielen dieselben Samples wie der Strudel-Track; SuperCollider liest sie aus `sc/samples/` (Herkunft
und Lizenzen: `sc/samples/CREDITS.md`). Beim Start werden alle geladen (etwa 350 Dateien); das dauert ein paar
Sekunden.
