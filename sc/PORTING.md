# Portierung Strudel → SuperCollider: Stand und Entscheidungen

## Stand (18.11.2026): alle Spuren portiert

| Teil | Status | Geprüft (Szenarien Strudel ↔ SC) |
|---|---|---|
| Kern (`lib/`): Busse, MIDI, Latches, Kanalzug, Hall, Echo, Master, Offline-Render | fertig | Live-Pfad mit Dummy-Audiotreiber |
| Globale Spalte 8: Fog, Thin, Tension, Master, Chapter, Break | fertig | in allen Szenarien |
| Jojo 1 Kick | fertig | 19 |
| Jojo 2 Noise Pump, 3 Sub, 5 Clap, 6 Hats/Shaker, 7 Congas | fertig | 62 |
| Jojo 4 Bass | fertig | 23 |
| Jonas 1 Harmony | fertig | 12 |
| Jonas 2 Keys (inkl. Vibraphon/Marimba im Sound-Modus) | fertig | 19 |
| Jonas 3 Vibraphone | fertig | 15 |
| Jonas 4 Flute | fertig | 14 |
| Jonas 5 Brass | fertig | 18 |
| Jonas 6 Strings | fertig | 17 |
| Jonas 7 Guitar | fertig | 18 |
| Launchkey MK4 25 (Tasten, Pads, Regler) | fertig | 6 |
| Jojo 8 Tamb/Ride | im Strudel-Track stumm (Spalte 8 ist dort global): nicht portiert | – |
| LC-Ansicht (Web-UI) mit Maus/Touch, Brücke | fertig (`ui/`); zeigt die Startwerte der Lab-Spalten, Lift % | – |
| Cue-Bus, Pegelanzeigen in der UI, Pegelplan (Master-Trim) | offen (Optimierung) | – |

Ergebnis: in allen Szenarien **dieselben Noten** (Einsatz, Tonhöhe, Länge, Anschlag/Gain), auch dort, wo Strudel
würfelt (`rand`, `perlin`, `degradeBy`, `sometimesBy`, der `hash` der Lab-Spalten: bitgenau nachgebaut). Lautheit
meist innerhalb 0,2 dB. Null-Test (Rest nach Abziehen): −30 bis −52 dB, wo kein Hall im Spiel ist (praktisch
identisch); mit Hall −5 bis −17 dB, weil superdough sein Hall-Rauschen in jeder Sitzung neu würfelt.

Bekannte Abweichungen, die an der **Referenz** liegen (Strudel in Node, nicht im Browser):
- Samples mit 44,1 kHz klingen in SC über 5 kHz bis 2–4 dB heller: der Resampler von node-web-audio-api dämpft dort.
  Im Browser ist das nicht so; SC liegt näher am Original.
- Die m4a-Stimmen der Launchkey-Pads beginnen in der Referenz 48 ms später (AAC-Vorlauf, den Browser verwerfen).
- Die Referenz spielt die erste Note eines Szenarios manchmal nicht (die Lab-Spalten lesen ihre Regler erst nach
  der ersten Abfrage); verglichen wird deshalb ab dem zweiten Durchgang (`from`).
- Lift (Brass, Strings, Guitar): in Strudel hängt es vom Abfragefenster des Schedulers ab, ob eine Note den Lift-
  Schritt ihres 16tels schon hört (± 1/32 Lift, < 0,1 dB). SC: immer den des vorigen 16tels.

## Entscheidungen

- **Klänge 1:1 nach superdough nachgebaut**, nicht nach Gehör: Hüllkurven wie `getParamADSR` (`~ce.adsr`),
  WebAudio-Biquads (Q in dB → `~ce.rq`, Bandpass/Notch linear), Oszillatoren mit WebAudio-Pegel und -Phase
  (Wavetables), Supersaw-Worklet, Sampler (Startpunkt, rückwärts, ganze Datei ohne clip/release), Phaser (eine
  Notch, Dreieck-LFO), General-MIDI-Soundfonts (`sounds/sdFont.scd`: Zone, Tonhöhe, Schleife, Hüllkurve mit
  Spitze 0,3).
- **Mini-Notation** (`lib/mini.scd`): Schritte, Pausen, `@`, `!`, `[ ]`, `< >` — gegen Strudels Parser geprüft
  (`tools/sc-port/mini-check.mjs`). Die Strudel-Strings stehen so im SC-Track wie im Strudel-Track.
- **Swing** (`swingBy(0.12, 8)`) exakt wie Strudel: ein Ton in der zweiten Hälfte eines Achtels kommt 0,12 16tel
  später und **fällt weg**, wenn er dadurch ins nächste Achtel rutscht; ein Ton knapp vor der Mitte (≤ 0,12 16tel)
  **klingt zweimal** (Flöte „Call + answer“ mit seinen 17er-Schritten). Beides sind Eigenheiten von Strudel, bewusst
  übernommen (1:1 zuerst, optimiert wird danach).
- **Weitere übernommene Eigenheiten:** Vibraphon „Call echo“: der Nachbarton (+1) ändert an einem Notennamen nichts
  (Strudel warnt nur). Ein Regler, der auf denselben Wert bewegt wird, zählt nicht als Bewegung.
- **FM-Bass:** Der Browser startet den Modulator beim Einplanen der Note, die Phase ist pro Note zufällig. Live
  genauso (`modPhase = -1`); nur für den Vergleich wird die Phase des Offline-Renders nachgestellt.
- **Regler wirken sofort** (Control-Busse, 20 ms Lag) statt erst bei der nächsten Note. Bei festen Reglerstellungen
  identisch, bei Reglerfahrten reagiert SC früher. Gewollt: Hauptgrund für den Umstieg.
- **Fader auf 0:** Strudel erzeugt dann keine Noten (CPU); SC spielt stumm weiter (ein Fader-Hochziehen wirkt
  sofort, auch auf eine klingende Note).
- **Latches** (Pattern-Tasten, Chapter, Akkordfolge): 1:1 der Strudel-`barLatch`; alle werden jedes 16tel abgefragt.
- **Hall:** Faltung mit der aus superdough gemessenen Impulsantwort (Raumgröße 0,6 / 1,2 / 2,0), ohne Vorverzögerung:
  der Anfang der Impulsantwort mit kleiner FFT, der Rest mit großer (eine FFT-Größe allein käme 20 ms zu spät).
- **Echo, bewusst anders als Strudel (gegen Artefakte):** In Strudel teilen sich Jonas' Spalten ein Echo (Orbit 3),
  dessen Zeit jede Note neu setzt: Spielen zwei Spalten mit verschiedenen Echozeiten, springt sie hin und her
  (Knacken, Echos im falschen Takt). Hier hat jede dieser Spalten ihr eigenes Echo (`ownDelay`). Ändert sich eine
  Echozeit (Echo-Wurf), springt sie nicht: zwei Verzögerungsleitungen, die neue wird in 60 ms eingeblendet.
  Einzeln gespielt klingt jede Spalte wie in Strudel.
- **Echo pro Note** (Strings: 0 / 0,3 / 0,5 × Space; Launchkey-Rim): eine „Lane“ pro Echo-Menge, jede mit eigenem
  Kanalzug am selben Fader. Gitarre: Echo-Menge als State-Bus, pro 16tel gesetzt.
- **Launchkey:** In Strudel liefert `midikeys` (npm 1.3.0) keinen MIDI-Kanal, dort würden die Pads also Rhodes
  spielen; der Track meint aber Kanal 10 = Pads, so ist es portiert. Tasten und Pads klingen sofort (kein Raster).
  Kein Tension-Echo auf dieser Spur (Strudel gibt ihr keins).
- **Samples:** dieselben Dateien wie Strudel (`samples/CREDITS.md`), Gitarre auf 1,5 s gekürzt (FLAC).
- **Master:** Trim −9 dB, Limiter bei −1 dBFS als letztes Glied (nur Notbremse). Gemessen: alle Fader auf 1 gibt
  ohne Trim Spitzen von +3 dBFS, mit Tension und vollen Spalten +6 dBFS (Strudel übersteuert dort); mit −9 dB also
  −6 bis −3 dBFS. Die Vergleichs-Renders laufen ohne Trim und Limiter.

## Offen (Optimierung, nach der 1:1-Portierung)

- **CPU live** mit allen Spuren auf dem M2 messen (Offline rendert alles ohne Fehler).
- **Punch** (Kick) und andere Klangwünsche: erst jetzt, auf Basis der 1:1-Version.
- **Werkzeug:** Der Strudel-Offline-Render kommt gelegentlich kaputt heraus; `batch.py` rendert dann einmal neu.
