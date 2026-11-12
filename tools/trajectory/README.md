# Trajectory — Musik-Architektur sichtbar machen

Stand: 2026-11-12 · Phase 1, Prototyp · nichts davon ist committet

Die Idee steht in [VISION.md](../../VISION.md) (Abschnitt MUSIC-ARCHITECTUR): Jede Stimme eines Tracks hat zu jedem
Zeitpunkt einen Ort im Raum – links/rechts (Pan), tief/hoch (Frequenz) – und einen Platz im zeitlichen Dialog (Tempo,
Rhythmus, Groove). Diese Bahn (Trajektorie) wird gemessen, als Datei gespeichert und live animiert. Phase 2 (später):
Emotionen über Publikumsfeedback.

Pitch-Deck (12 Folien, Bewertung + Plan): https://claude.ai/artifact/5gM7MWgHqHCLvk3BveX9AZ

## In 5 Minuten wieder drin

```bash
cd tools && node trajectory/server.mjs          # → http://localhost:8766
```

Dann im Chrome `http://localhost:8766` öffnen. Drei Wege, Musik hineinzubekommen:

| Weg | So geht's | Was man bekommt |
|---|---|---|
| **Datei** | „Datei …“ → z. B. `recordings/2026-11-14-beats-und-basteln/Scarlett 2i2 Input 3&4 #10.wav` (008-Mitschnitt) | Audio-Analyse, 5 Frequenzbänder als Pseudo-Stems |
| **Live-Eingang** | Scarlett wählen, **Kanal 3/4** (Loopback = was der Mac abspielt), „Live starten“ | wie Datei, live |
| **Strudel** (exakt) | Track tappen (unten), in strudel.cc einfügen und spielen; auf der Seite „Strudel“ klicken | jeder Stem mit Namen, Tempo aus Strudels Uhr |

Track für den Strudel-Weg vorbereiten (landet in `trajectory/tapped/` und in der Zwischenablage):

```bash
cd tools && node trajectory/make-tapped.mjs ../tracks/008-groove-techno/008-groove-techno.strudel
```

**Am schnellsten: `http://localhost:8766/player.html`** – Track wählen (alle getappten Tracks, z. B. 008 oder
`009-house-single`), Play. Der Player spielt den Track direkt auf localhost (kein strudel.cc nötig) und zeigt die
Visualisierung gleich dahinter. Gespielt wird nur von Menschen: jeder Regler, den der Track über `midin()` liest,
kommt von den angeschlossenen Controllern (Web MIDI); ein noch nicht bewegter Regler steht auf 0. Ohne Controller
bleibt es still. Die Statusbox des Tracks (unten rechts) verschwindet, solange seine LC-Ansicht („▣ LC groß“) in
einem anderen Fenster offen ist. Zwei Homotopie-Regler:

- **Hart ↔ Weich** (0…1): Charakter der Visuals. 0 = Sägezahn-Kämme, eckige Linien, jede vergangene Zeitscheibe
  mit Kante, sofortige Reaktion, Kamera vom Beat gestoßen; 1 = runde Wellen, dicke weiche Kämme, Bewegungsschmiere,
  träges Folgen, gleitende Kamera. (Auch auf der Visualizer-Seite.)
- **Roh ↔ Glatt** (0…1): gleitender Mittelwert (exponentiell gewichtet) über N = 2^(53·Regler) Zeilen auf alle
  Signale, die das Bild sieht: 0 = roh, 0.1 ≈ 1.3 s, 0.3 ≈ 34 min, 0.5 ≈ 37 Tage, 1 = 2^53 (max_int), eingefroren.
  Nur fürs Bild; Ton und Aufnahme bleiben roh. (Auch auf der Visualizer-Seite.)

Dual-Tracks über ihre Single-Version tappen (`tracks/009-house/009-house-single.strudel`).

Schalter und Tasten auf der Seite: **A** Achsen · **L** Beschriftung (Stem-Namen, Achsenwörter, Statuszeile) ·
**B** Beat-Ringe (die Kreise von der Kick) – alle drei auch als Häkchen in der Leiste. **F** Vollbild ·
**V** Look (deck / ocean / clean) · **W** Pan-Weite an/aus.
Die Leiste oben blendet sich nach 3 s ohne Maus aus.

Offline-Analyse einer Datei mit Zusammenfassung pro Band:

```bash
cd tools && node trajectory/analyse-file.mjs <audio> [--out x.jsonl] [--from s] [--to s]
```

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
| `make-tapped.mjs` | Kopie eines Tracks: jeder Stem bekommt seinen Namen als `.tag()`, Master sendet per `.onTrigger` (Klang unverändert) |
| `server.mjs` | statische Dateien + Relay POST `/events` → SSE `/stream`; CORS- und Private-Network-Header für strudel.cc |
| `player.html` | spielt einen getappten Track mit `@strudel/web` direkt auf localhost und zeigt ihn; Controller per Web MIDI, Regler Hart ↔ Weich, Roh ↔ Glatt |
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
