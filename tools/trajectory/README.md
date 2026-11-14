# Trajectory — Musik-Architektur sichtbar machen

Stand: 2026-11-12 · Phase 1, Prototyp · nichts davon ist committet

Die Idee steht in [VISION.md](../../VISION.md) (Abschnitt MUSIC-ARCHITECTUR): Jede Stimme eines Tracks hat zu jedem
Zeitpunkt einen Ort im Raum – links/rechts (Pan), tief/hoch (Frequenz) – und einen Platz im zeitlichen Dialog (Tempo,
Rhythmus, Groove). Diese Bahn (Trajektorie) wird gemessen, als Datei gespeichert und live animiert. Phase 2 (später):
Emotionen über Publikumsfeedback.

Pitch-Deck (12 Folien, Bewertung + Plan): https://claude.ai/artifact/5gM7MWgHqHCLvk3BveX9AZ

## Start: der Player

```bash
cd tools && node trajectory/server.mjs
```

Dann in Chrome **http://localhost:8766/player.html** öffnen (nicht `http://localhost:8766`).

Der Player spielt einen Track direkt auf localhost (kein strudel.cc nötig) und zeigt die Visualisierung gleich
dahinter: jeder Stem mit Namen, Tempo aus Strudels Uhr.

1. Track tappen (einmal pro Track und nach jeder Änderung am Track; landet in `trajectory/tapped/` und in der
   Zwischenablage):

   ```bash
   cd tools && node trajectory/make-tapped.mjs ../tracks/008-groove-techno/008-groove-techno.strudel
   ```

2. Im Player oben den Track wählen (alle getappten Tracks stehen in der Liste), **Play**.
3. Controller spielen. Gespielt wird nur von Menschen: jeder Regler, den der Track über `midin()` liest, kommt von
   den angeschlossenen Controllern (Web MIDI, jeder Port für sich wie in strudel.cc); ein noch nicht bewegter Regler
   steht auf 0 (oder auf dem Startwert, den der Track ihm gibt). Der Launchkey spielt mit: Tasten und Drum-Pads
   (`midikeys`), Mod-Rad und Knöpfe. Ohne Controller bleibt es still: zuerst den Master-Fader (Spalte 8) hoch.

Die Statusbox des Tracks (unten rechts) verschwindet, solange seine LC-Ansicht („▣ LC groß“) in einem anderen Fenster
offen ist.

**Regler in der Leiste** (Startwerte: Hart, Glatt 302 ms):

- **Hart ↔ Weich** (0…1): Charakter der Visuals. 0 = Sägezahn-Kämme, eckige Linien, jede vergangene Zeitscheibe
  mit Kante, sofortige Reaktion, Kamera vom Beat gestoßen; 1 = runde Wellen, dicke weiche Kämme, Bewegungsschmiere,
  träges Folgen, gleitende Kamera.
- **Roh ↔ Glatt** (0…1): gleitender Mittelwert (exponentiell gewichtet) über N = 2^(53·Regler) Zeilen auf alle
  Signale, die das Bild sieht: 0 = roh, 0.06 ≈ 302 ms, 0.1 ≈ 1.3 s, 0.3 ≈ 34 min, 0.5 ≈ 37 Tage, 1 = 2^53
  (max_int), eingefroren. Nur fürs Bild; der Ton bleibt roh.

**Schalter und Tasten** (Startwerte: Achsen und Beschriftung aus, Beat-Ringe und LC-Rahmen an): **A** Achsen ·
**L** Beschriftung (Stem-Namen, Achsenwörter) · **B** Beat-Ringe (die Kreise von der Kick) · **H** LC-Rahmen (der
Rahmen um die zuletzt benutzte Controller-Seite in der LC-Ansicht) – alle vier auch als Häkchen in der Leiste.
**F** Vollbild · **V** Look (deck / ocean / clean) · **W** Pan-Weite an/aus. Die Leiste oben blendet sich nach 3 s
ohne Maus aus.

Alte Dual-Versionen über ihre Single-Version in `old/` tappen (z. B. `tracks/009-house/old/009-house-single.strudel`).

## Fortschritt

| Tag | Inhalt | Status |
|---|---|---|
| 1 · Ton rein | Web-Audio-Analyse → JSONL | fertig; BPM exakt (Synth 126.0, 008: 139.9 bei 140) |
| 2 · Bild raus | Renderer, Vollbild, Mono-Fix, Pegelanzeige | fertig, von Jonas mit 10/10 bewertet |
| 3 · Strudel | getappter Track → Server → exakte Stems | fertig; 008 (11–16 Stems, 140.0 BPM), 009 House (15 Stems, 124.0 BPM) |
| Nachbesserung | Kanal 3/4, Look „ocean“ (Flüssigkeit, 4D, weich) | gebaut, Hardware-Test steht aus |
| Deck-Look | Standard-Look wie Folie 6 des Pitch-Decks (Kometen, Ringe, Achsen); ocean/clean über V | gebaut, mit simulierten Stems geprüft |
| 4 · Festhalten | Wiedergabe, Video-Export, Demucs | zurückgestellt |
| 5 · Probe | Beamer, Feinschliff, KPI-Anzeige | offen |

## Wie es gebaut ist

```
 Audio (Datei / Eingang) ──analyse.mjs──┐
                                        ├─► Trajektorie (Zeilen) ─► render.mjs ─► Canvas
 strudel.cc / player.html ──server.mjs──┘   strudel-source.mjs                   └► Aufnahme (JSONL)
        (getappter Track, make-tapped.mjs)
```

Beide Eingänge schreiben **dasselbe Format**, der Renderer weiß nicht, woher die Musik kommt:

```
{"t":12.533,"stem":"bass","x":-0.12,"y":0.31,"z":0.20,"e":0.72,"on":1}
{"t":12.533,"pulse":{"bpm":140,"phase":0.25,"density":0.6,"swing":0.04}}
```

`x` Pan −1…1 · `y` Tonhöhe log 20 Hz–20 kHz → 0…1 · `z` Tiefe (Audio: L/R-Dekorrelation; Strudel: `room`) ·
`e` Energie 0…1 · `on` Anschlag · `pulse` Tempo, Taktphase, Dichte (Anteil belegter 16tel im letzten Takt), Swing.

| Datei | Aufgabe |
|---|---|
| `analyse.mjs` | Kern der Audio-Analyse (Browser + Node): FFT 2048 für Pegel/Pan/Onsets, 8192 für die Tonhöhe von Kick und Bass, Tempo per Autokorrelation |
| `analyse-file.mjs` | CLI: Datei → JSONL + Zusammenfassung (Drift = Bewegung innerhalb von 8 Takten) |
| `render.mjs` | Bild. „deck“ (Standard, wie Folie 6 des Decks): leuchtende Kometen mit Schweifen, Ringe von der Kick, Achsen. „ocean“: Stems als Flüssigkeitsschichten, Zeit in die Tiefe, schwebende Kamera. „clean“: Kometen, Ringe |
| `smoothing.mjs` | Regler Roh ↔ Glatt: gleitender Mittelwert, Fenster wächst exponentiell bis 2^53 Zeilen |
| `strudel-source.mjs` | Strudel-Events → Zeilen, jedes Event erscheint, wenn es klingt (`delay`) |
| `make-tapped.mjs` | Kopie eines Tracks: jeder Stem bekommt seinen lesbaren Namen aus dem Track (`@col`-Spaltenname, Spalte 8 von Jojo: Name ihres Pattern-Knopfs, `stemLK` = Launchkey) als `.tag()`, Master sendet per `.onTrigger` (Klang unverändert) |
| `server.mjs` | statische Dateien + Relay POST `/events` → SSE `/stream`; CORS- und Private-Network-Header für strudel.cc |
| `player.html` | spielt einen getappten Track mit `@strudel/web` direkt auf localhost und zeigt ihn; Controller per Web MIDI (`midin` pro Port, `midikeys` für Launchkey-Tasten und -Pads), Regler Hart ↔ Weich, Roh ↔ Glatt; ohne `gm_*`-Klänge (siehe Grenzen) |
| `index.html` | die Seite: Quellen, Kanalwahl, Aufnahme, Tasten |

## Was wir gelernt haben

- **Bänder sind keine Stems.** In der 008-Aufnahme landet der Sub-Anteil des Basses im Kick-Band; die Zusammenfassung
  zeigt die Kick deshalb „bewegter“ als den Bass, obwohl sie innerhalb eines Abschnitts fest steht (60–120 s: 43 Hz).
  Exakt wird es nur über Strudel (oder später Demucs).
- **Mikrofon ≠ Musik.** Scarlett-Mikro kommt nur links an (→ wird jetzt als Mono behandelt), MacBook-Mikro ist mono.
  Die Musik liegt auf dem Scarlett-Loopback 3/4.
- **Der 008-Mix ist im Panorama mittig.** Darum streckt die Pan-Weite (×1 bis ×5, Taste W) auf den genutzten Bereich.
- **Gefallen hat:** Tag 2 („10/10“). **Nicht gefallen:** scharfe Linien („Klingen“), blendendes Additiv-Licht.
  Gewünscht: dichte Flüssigkeit mit Wellen obendrauf, weiches Licht, schräger Blick mit wanderndem Blickwinkel –
  daraus wurde „ocean“. Danach: zurück zum Look von Folie 6 des Decks („deck“, jetzt Standard).

## Grenzen des Players

`player.html` ist für Visualisierung und Proben gedacht, nicht als vollständiger Ersatz für strudel.cc.

**Klingt im Player:** Strudels eingebaute Synths (`sine`, `sawtooth`, `supersaw`, …), Dirt-Samples, Drum-Machines
(909, 808, 727, 707), VCSL, Piano und alle Samples, die ein Track selbst lädt (Stimmen, Rhodes, Steinway). Controller:
jeder Launch Control XL 3 und der Launchkey (Tasten, Drum-Pads, Mod-Rad, Knöpfe).

**Klingt nicht:** General-MIDI-Klänge (`gm_*`). `@strudel/web` (1.2.6 wie 1.3.0) registriert sie nicht, im Bundle
ist `registerSoundfonts()` auskommentiert. Ein Event mit `gm_*` bleibt still, ohne Fehlermeldung.

| Track | stumm im Player |
|---|---|
| 008 | nichts |
| 007 | Launchkey-Pads: Glockenspiel, Marimba, Chor, „ooh“, Agogo, Tom, Vibrafon (Marimba, Toms und Glitter von Jonas spielen VCSL-Aufnahmen) |
| 009, 009-riffs | Vibrafon, Marimba u. a.; Launchkey: Orgel-, Bläser-Stab, „ooh“ |
| 010 | Launchkey-Pads: Marimba, Glockenspiel, Agogo, Vibrafon, „ooh“ (Glockenspiel von Jonas: VCSL; Tasten: Synth-Pad wie 007) |

Für den vollen Klang dieser Tracks: den getappten Track in strudel.cc einfügen und spielen; die Controller sind
dort dieselben.

**Versucht, gescheitert:** `@strudel/soundfonts@1.2.6` per Import-Map an dasselbe `@strudel/web`-Bundle hängen (die
Exporte, die es braucht, sind alle da). Es importiert `sfumato@0.1.2`, und dessen `soundfont2@^0.4.0` liefert über
esm.sh kein `DEFAULT_GENERATOR_VALUES`; auch mit `soundfont2@0.5.0` nicht. Das Modul lädt dann nicht, und die ganze
Seite bleibt bei „lädt Strudel …“ stehen.

**Mögliche nächste Schritte** (Empfehlung zuerst):

1. **`sfumato` durch einen leeren Platzhalter ersetzen** (ein paar Zeilen in der Import-Map): `sfumato` wird nur für
   `.sf2`-Dateien gebraucht, die `gm_*`-Klänge kommen aus webaudiofont-Daten. Klein, aber erst im Browser beweisen.
2. **Eigenes Bundle bauen** (`@strudel/web` + `@strudel/soundfonts` mit esbuild in `tools/`): eine Datei, eine
   Klang-Registry, unabhängig von esm.sh. Sauberer, aber ein Build-Schritt mehr.
3. **Auf strudel.cc bleiben** für Tracks mit `gm_*`; der Player nur für 008 und Proben.

## Offen (nach Priorität)

1. **Testen mit Hardware:** Liefert Chrome vom Scarlett 4 Kanäle? Die Statuszeile sagt es („misst 3/4“ oder
   „Kanal 3/4 fehlt“). Falls es fehlt: Strudel-Weg nutzen oder ein virtuelles Gerät (BlackHole).
2. **strudel.cc im eigenen Chrome** mit Controllern + getapptem Track (im Browser-Pane blockiert; in Chrome evtl.
   Abfrage „lokales Netzwerk“ erlauben).
3. **Ocean-Look:** Gefallen? Performance im Vollbild messen (nicht gemessen; „clean“ lag bei 1–3 ms pro Bild).
4. **Aufräumen:** `tools/trajectory/tapped/` in `.gitignore`, dann committen.
5. **Tag 5:** Beamer-Probe, KPI „Spatial Trajectory Harmony“ (Trennung × Anker × Bewegung) als Zahl im Bild,
   Crowd-Tap-Knopf (Zeitstempel für Publikumsreaktionen = Startpunkt Phase 2).
6. **Tag 4:** Wiedergabe von Aufnahmen, Video-Export, Demucs (schwer: PyTorch, lange Rechenzeit auf dem M2 Air).

Querverbindung zur Musik ([TODO.md](../../TODO.md)): „Raum segmentieren“ und „Build-up über Tiefen/Mitten/Höhen“ für
008 lassen sich mit dem Strudel-Weg direkt sehen und messen.
