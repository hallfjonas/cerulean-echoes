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
- **Launchkey neu (2026-11-19):** Tasten = die gemeinsamen Keys (`lib/lkkeys.scd`, wie 008 / 010), Pads = die 16
  One-Shots des neuen Strudel-009 (8 Stimmen links, `once`). Vergleich `scenarios/launchkey.json`: Ereignisse gleich,
  Tasten ±0,2 LU, Pads je ±0,5 dB (über 4 kHz SC 1–2 dB heller, s. o.). Thin jetzt nur pro Note (vorher Kanalzug
  und Note: doppelt).
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
- **Fader pro Note** (Nutzer 2026-11-19: „organischer“): wie Strudels `postgain` liest jede Note den Fader beim
  Anschlag (`~ce.noteLevel`, Eingang `post` am Ende jedes Klangs); klingende Noten behalten ihren Pegel. Fader auf 0:
  keine Noten (wie Strudels Gate). Master bleibt im Kanalzug und wirkt sofort (Notbremse). Überblendungen zwischen
  Schichten (Sea ↔ Wind, Drone Beating, Strings JX ↔ analog) liegen auf `fade:` der Lanes und wirken weiter sofort.
- **Latches** (Pattern-Tasten, Chapter, Akkordfolge): 1:1 der Strudel-`barLatch`; alle werden jedes 16tel abgefragt.
- **Hall:** Faltung mit der aus superdough gemessenen Impulsantwort (Raumgröße 0,6 / 1,2 / 2,0), ohne Vorverzögerung:
  der Anfang der Impulsantwort mit kleiner FFT, der Rest mit großer (eine FFT-Größe allein käme 20 ms zu spät).
- **Echo, bewusst anders als Strudel (gegen Artefakte):** In Strudel teilen sich Jonas' Spalten ein Echo (Orbit 3),
  dessen Zeit jede Note neu setzt: Spielen zwei Spalten mit verschiedenen Echozeiten, springt sie hin und her
  (Knacken, Echos im falschen Takt). Hier hat jede dieser Spalten ihr eigenes Echo (`ownDelay`). Ändert sich eine
  Echozeit (Echo-Wurf), springt sie nicht: zwei Verzögerungsleitungen, die neue wird in 60 ms eingeblendet.
  Einzeln gespielt klingt jede Spalte wie in Strudel.
- **Harmonie live, bewusst anders als Strudel:** Brightness (Tiefpass) und die Überblendung Streicher ↔ B3 wirken
  auf den klingenden Akkord (State-Busse `harmCut`, `harmJx`, `harmB3`; beide Schichten laufen dafür immer mit,
  die gerade stumme nicht im Event-Log). Bei festen Reglern gleich wie Strudel (alle 12 Harmonie-Szenarien).
  Grundsatz: live bei langen, gehaltenen Klängen; kurze Töne behalten den Klang vom Anschlag.
- **Launchkey ohne Vorlauf:** Anschläge gehen sofort an den Server (`ce.playNow`), nicht mit `s.latency`
  (0,2 s) wie die Patterns. Gemessen 3–4 ms bis zum Start der Synth.
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

## Track 008 (Groove Techno): Stand und Entscheidungen

Stand 18.11.2026: **alle Spuren portiert** (`sc/tracks/008-groove-techno/008-groove-techno.scd`), jede gegen
`tracks/008-groove-techno/008-groove-techno.strudel` verglichen (Szenarien `tools/sc-port/scenarios/008-*.json`,
`CE_TRACK=008-groove-techno/008-groove-techno python3 batch.py scenarios/008-kick.json /tmp/cmp-008-kick`).
Bedienung: `sc/ANLEITUNG-008.md`.

| Teil | Szenarien | Ergebnis |
|---|---|---|
| Global (Fog, Thin, Tension, Master, Chapter, Break) | in allen | – |
| Jojo 1 Kick, 3 Sub, 7 Percussion | 17 je | dieselben Noten; Null-Test −30 bis −54 dB (ohne Hall) |
| Jojo 2 Rumble | 17 | dieselben Noten; immer mit Hall (Orbit 3), trocken nachgeprüft: −45 bis −49 dB |
| Jojo 4 Bassline | 17 | dieselben Noten; −25 bis −32 dB (Filterhüllkurve + Shape, s. u.) |
| Jojo 5 Clap, 6 Hats | 17 je | dieselben Noten; 44,1-kHz-Samples, s. u. |
| Jonas 1 Pads, 3 Sequence | 18 / 17 | dieselben Noten; trocken −29 bis −39 dB |
| Jonas 2 Strings | 21 | dieselben Noten; analog trocken −30 dB, JX-10 (Supersaw) Lautheit ±0,5 dB |
| Jonas 4 Stab, 5 Answer | 17 / 13 | dieselben Noten; trocken −22 bis −28 dB bzw. −14 bis −25 dB |
| Jonas 6 Dark Perc, 7 FX / Breath | 13 je | dieselben Noten; Rauschen (nicht nullbar), Lautheit ±0,3 dB |
| Launchkey (Tasten, Pads) | 9 | dieselben Noten; Supersaw mit Zufallsphasen, s. u. |

Jojo 8 Ride ist im Strudel-Track aus (Spalte 8 ist global): nicht portiert.

**Neue Klänge** (eigene Dateien, damit 009s Stimmen unverändert bleiben; später zusammenlegbar):
- `sdSynthMod`: sdSynth + FM (`fm`/`fmh`, Modulator-Phase wie 009s FM-Bass), Tonhöhenhüllkurve (`penv`, `pdecay` …,
  Anker = Sustain wie superdough), Tiefpass-Hüllkurve (`lpenv`, `lpattack` …, exponentiell, höchstens 20 kHz),
  `shape` (superdoughs Waveshaper, nach den Filtern, vor dem Panner).
- `sdSampleMod`: sdSample + `shape` (steht mit k/(2+k) auch für `distort` mit der Standard-S-Kurve) + `cutMax`
  (eigene Obergrenze des Tiefpasses, z. B. Kuhglocke 2500 Hz). Multipliziert Motion nach der 80 Hz…18 kHz-Klammer,
  wie Strudel (die geänderte `~ce.cutoff` mit `mul` klammert danach).
- `sdSupersawWide`: Supersaw mit bis zu 8 Sägezähnen (Launchkey-Pad: `unison(7)`); Strings JX-10 laufen auch hier.
  Der Detune-Parameter heißt `dtn`: ein Event mit Schlüssel `detune` addiert ihn in Hz auf `freq` (betrifft
  `sdSupersaw` in 009: dort liegt jede Note um den Detune-Wert in Hz zu hoch, 0,08 Hz ≈ 0,4 Cent bei F4).

**Entscheidungen**
- **Live-Regler nach Absprache:** Space, Echo, globale Spalte immer sofort; Level ab der nächsten Note (seit
  2026-11-19, Master sofort). Brightness sofort nur bei langen
  Klängen: Pads, Strings (auch Sound JX ↔ analog: zwei Lanes, deren `fade` cos/sin trägt), FX / Breath,
  Launchkey-Tasten (auch Resonance, Detune). Kurze Klänge und Sub: ab der nächsten Note.
- **Space mit Skalierung** (Strudel `bus`/`dryBus` mit z. B. 0,3 + 0,7 × Space) und Echo-Würfe: State-Busse, die
  die Sprache beim Reglerereignis setzt (`spaceState`, `throwState`); Tension-Echo nur auf `bus()`-Spalten
  (Rumble, Riser, Sequence, Answer), wie in Strudel.
- **Orbits:** 1 = Raum 1,6 (Drums, Bass, Launchkey-Pads), 2 = Raum 4 (Jonas, Riser, Launchkey-Tasten), 3 = Raum 2,6
  (Rumble), Impulsantworten neu gemessen (`ir/orbit-1.6`, `-2.6`, `-4`). Alle Spalten eines Orbits haben dieselbe
  Echozeit: kein `ownDelay` nötig.
- **Sequence-Extras:** Strudel erzeugt sie mit `Array.sort` und Zufallsvergleich (Reihenfolge von V8); die Tabelle
  steht ausgerechnet im SC-Track.
- **Startwerte live:** Pad-Space 0,5 und Launchkey-Hall 0,4 bis zur ersten Bewegung, wie `KNOB_DEFAULTS` /
  `LK_DEFAULTS` in Strudel (nur mit Web MIDI; die Vergleiche starten wie die Node-Tools bei den Szenariowerten).
- **Werkzeuge:** `batch.py` / `sc-render.sh` wählen den Track mit `CE_TRACK` (Standard 009). `strudel-run.mjs` lädt
  zusätzlich strudel.cc's Dirt-Samples (metal, space, wind: Launchkey-Pads).

**Erklärbare Abweichungen (nicht repariert)**
- Hall: superdough würfelt sein Hall-Rauschen; Spalten mit Mindest-Hall (Pads, Strings, Sequence, Stab, Answer, FX,
  Rumble) wurden zusätzlich trocken verglichen (`.room(0)` gegen eine Kopie ohne Hall).
- Clap und Hats (44,1-kHz-Samples): in SC über 5 kHz bis 4 dB heller (Resampler der Referenz); bei den Hats, die
  fast nur Höhen haben, +1 dB Lautheit.
- Bassline und Stab: Filterhüllkurve mit Resonanz und Shape; Abweichungen über 10 kHz (bis 3 dB). Vermutlich rechnet
  die Referenz in Node die Filterkoeffizienten gröber als SC (pro Sample); nicht weiter untersucht.
- Kurze, hohe Töne (Answer): die Notenanfänge liegen um knapp ein Sample auseinander (16tel bei 140 BPM fallen nicht
  auf ganze Samples, beide runden verschieden); bei 1–1,4 kHz reicht das für einen Null-Test von nur −14 dB.
- Rauschen (Shaker, FX, Riser), Supersaw (JX-10 Strings, Launchkey-Tasten): Zufall in beiden Systemen (Rauschpuffer,
  Startphasen). Bei 48 Launchkey-Tönen Lautheit −0,1 / +0,8 dB.
- Launchkey-Pads 1 und 5 (m4a): 48 ms Versatz in der Referenz (wie 009).

**Offen (Optimierung):** CPU live auf dem M2 messen (im Container mit Dummy-Audio, alle Spuren an: 60–80 %).

## 007 Ambient (Stand 18.11.2026)

Alle Spalten portiert (`sc/tracks/007-ambient/007-ambient.scd`), Szenarien `tools/sc-port/scenarios/007-*.json`
(Strudel-Datei liegt jetzt in Genre-Ordnern: `batch.py` findet `tracks/**/<name>.strudel` selbst,
`CE_TRACK=007-ambient/007-ambient`).

**Ergebnis:** Ereignisse gleich in allen Szenarien (rund 260, Ausnahmen unten). Trocken (ohne Hall/Echo, `.room(0).delay(0)`
gegen eine Kopie ohne Sends) Null-Tests −25 bis −57 dB, Lautheit ±0,05 dB; auch Wobble, Beating, Voice-Distortion,
Vokalfilter. Mit Hall/Echo ±0,5 bis 2 dB, siehe unten.

**Neue Klänge** (eigene Dateien, Bibliothek und 009 unberührt): `sdSbd` (superdoughs `sbd`: Dreieck mit
exponentiellem Pitch-Abfall, tanh(2x), Braunrausch-Klick), `sdSynthFx` (sdSynthMod + Vokalfilter wie `vowel.mjs` +
Tonhöhen-Offset in Cent als Bus: Drone-Beating und Launchkey-Detune live), `sdSampleFx` (Sampler + Vibrato, Vorverstärkung,
coarse/crush/shape/distort in superdoughs Reihenfolge, alles als Bus: Voice live), `sdCrackle` (superdoughs `crackle`).

**Entscheidungen:**
- **Globale Spalte:** 007 hat Room statt Thin. Der Kanalzug-Eingang `tension` hebt jeden Hall Richtung 0,95 — bei 007
  ist das Room (`global.tension` = Room-CC); Fog × Tension wirkt über eine eigene Map (`tone`), Tensions Echo
  (0 → 0,5) über State-Busse pro Spur (`echoState`: max(min(0,9, Echo × 2 × Space), Tension-Echo), Echo-Wurf 0,65),
  Tensions Wobble (Vibrato 0,15 Hz, Tiefe 0 → 0,1) als Map-Bus auf den langen Klängen (live). Thin = CC 127 (unbenutzt).
- **Live** (Absprache): Sea↔Wind und Drone-Beating über Lane-Pegel (beide Schichten laufen immer, die stumme nicht im
  Event-Log), Brightness bei Sea/Wind, Drone, Bass, Pad, Eno, Shimmer, Choir, Voice, Launchkey-Tasten; Voice-Distortion
  per Map-Bussen auf die laufenden Silben (die Beat-Scheiben bleiben 1:1). Groove, Swell, Complexity: ab der nächsten Note.
- **Lab-Spalten** (Shaker, Eno, Marimba, Toms): Space 0,25 + 0,75 × Regler als State-Bus, Brightness-±2-dB als Trim-Map.
- **Marimba/Toms:** die Lab-Figuren als Schichten (Figur, Schritte pro Takt, Versatz); Polymeter, Kanon-Versatz,
  Euklid, Build-up, Dichte-Stufen (Hash wie im Lab), Clapping Music (Versatz pro Takt) 1:1.

**Abweichungen (erklärbar, nicht repariert):**
- **Hall:** superdough würfelt seine Impulsantwort bei jedem Laden (Strudel gegen sich selbst ±0,6 dB); bei
  schmalbandigen, gehaltenen Klängen (Drone, Bass, Eno) hängt der Hallpegel stark von der Würfelung ab (±2 dB).
- **Echo auf gehaltenen Tönen** (Drone, Choir mit Tension): Echo und Original interferieren; das hängt an Bruchteilen
  einer Millisekunde der Echozeit (WebAudio-Verzögerung im Rückkopplungskreis) — Null-Test schlecht, Pegel ±1,5 dB.
- **80-Hz-Untergrenze:** 007s `toned()` hat als einziger Track keine Untergrenze (Tiefpass × Fog kann unter 80 Hz
  fallen, z. B. Bass bei Fog); die SC-Bibliothek klemmt bei 80 Hz wie die anderen Tracks. Entschieden (Nutzer,
  18.11.): bleibt bei 80 Hz.
- **44,1-kHz-Samples** (Shaker, Glockenspiel): in SC heller (Resampler der Referenz), Shaker bei Brightness 1 bis +2,8 dB.
- **Toms „Crossing“:** Strudel integriert den Drift zwischen Scheduler-Abfragen (offline gar nicht); SC pro 16tel wie live.
- **Shimmer nach Pattern-Wechsel:** Strudel liest den Latch durch `reseed` auch zu späteren Zeiten (Zustandsfehler des
  barLatch); SC nimmt die gemeinte Logik (gleiche Note bis auf diesen Fall).
- **Erste Abfrage:** Shaker-Ghosts bei Reihe 3 = 1 hat SC eine Note mehr bei t = 0 (Strudel liest den Regler beim ersten
  Abfragen noch nicht).
- **Launchkey:** Regler auf CC 21–28, der Voreinstellung des Geräts (`lkCC[20 + n]`; bis 2026-11-20: 31–38).
  Pads mit `once` sperren über die Sprachzeit.
- **Launchkey-Pads 1 und 5** (m4a): Versatz in der Referenz wie bei 009; Rausch-Swell zufällig. Trocken sonst ±0,3 dB.
- **Werkzeug:** `strudel-run.mjs` dekodiert WAVs, die node-web-audio-api ablehnt (VCSL-Shaker: „malformed fmt_pcm
  chunk“), über ffmpeg neu; GM-Einträge für gm_glockenspiel und gm_choir_aahs ergänzt. Launchkey-Szenarien über
  `vals.keyEvents` des Harness.

## 008 Launchkey neu (18.11.2026)

Der Strudel-008 hat einen neuen Launchkey: Tasten = Jonas' Keys aus 009 (Regler 2–4 je ein Paar: Piano → Rhodes,
B3 → M1, Vibraphon → Marimba, Drittel-Überblendung; Regler 2 steht auf 0,5, bis er gedreht wird), Pads neu (Stimmen,
Toms, „Braaam“-Drop). Portiert; die Tasten liegen als gemeinsames Stück in `sc/lib/lkkeys.scd` (`~ce.lkKeysNotes`,
vom Track geladen, für 008 / 009 / 010). Regler auf CC 21–28. Vergleich `scenarios/008-lk.json`: Ereignisse gleich,
Lautheit ±0,4 dB. Abweichung: Strudel nimmt den Launchkey jetzt nicht mehr mal Master (`postgain(lkKeysLevel)`, Pads
ohne postgain); SC behält Master (der Kanalzug multipliziert immer) — bei Master 1 gleich.

## 010 Ambient House (Stand 18.11.2026)

Alle Spalten portiert (`sc/tracks/010-ambient-house/010-ambient-house.scd`), Szenarien `tools/sc-port/scenarios/010-*.json`
(`CE_TRACK=010-ambient-house/010-ambient-house`).

**Ergebnis:** Ereignisse gleich in allen Szenarien (rund 230; Ausnahmen: Rundung in der 3. Nachkommastelle und die
erste Abfrage bei t = 0, wie bei 007). Trocken Null-Tests −21 bis −56 dB, Lautheit ±0,1 dB; mit Hall/Echo ±0,5 bis
1,7 dB (Hall-Würfelung wie bei 007; Orbit 2 = Raumgröße 5, IR neu gemessen).

**Entscheidungen:**
- **Global:** Fog und Thin wie die Bibliothek; Tension hat in 010 eigene Kurven: Tiefpass × (1 + 1,5 t²) (Map `tone`),
  Echo 0 → 0,4 über 0..0,7, Hall + 0,5 t. Dafür ist der Tension-Eingang der Kanalzüge aus (CC 127); jede Schicht
  hat Room- und Echo-State-Busse (`self.fx`), die bei Space / Tension / Echo-Wurf sofort neu gesetzt werden.
- **Live:** Brightness bei Noise Pump, Pad, Lead und den Launchkey-Tasten; sonst ab der nächsten Note.
- **Freeze** (Pad-Taste 2): wie Strudel der Grundton im Moment des Drückens, für alle (jede harmonische Spur fragt
  den Grundton jedes 16tel ab, wie Strudel bei jedem Tick).
- **Launchkey:** Tasten aus `sc/lib/lkkeys.scd` (wie 008), Regler CC 21–28, Pads wie Strudel (Rim mit Echo 0,3,
  Räume 0,3 / 0,6 / 0,7 + 0,5 t).
- Hats „Shuffle“: Strudels swingBy(0,4, 8) = jede zweite 16tel 0,4 16tel später.

**Abweichungen (erklärbar):** Hall-Würfelung (s. 007); der Strudel-Offline-Render kam einige Male kaputt heraus
(fast stumm ab einem Takt): neu gerendert passt er (Null −45 dB). Rauschen (Noise Pump) zufällig, Pegel ±0,9 dB.

## 016 Groove Techno (Opus) (Stand 20.11.2026)

Alle Spalten portiert (`sc/tracks/016-grroove-opus/016-grroove-opus.scd`), Szenarien
`tools/sc-port/scenarios/016-*.json` (`CE_TRACK=016-grroove-opus/016-grroove-opus`, 134 BPM). Bedienung:
`sc/ANLEITUNG-016.md`. **Noch nicht mit dem Ohr abgenommen.** Gebaut auf 008 (Rumble, Sub, Bongos, Pad, JX-Strings,
Stab, Answer, Launchkey wie dort), neu: Kick, Bass, Wood, Hats, Conga-Slap, Stab Shape, Accents, FX.

| Spalte | Szenarien | Ereignisse | Lautheit Δ (SC − Strudel) |
|---|---|---|---|
| Mode 1/1 Kick | 16 | gleich | trocken ≤ 0,04 dB (Null −38 … −51 dB); mit Space/Tension −0,7 … −1,0 dB (Hall) |
| Mode 1/2 Rumble | 17 | gleich | −0,2 … +0,6 dB (immer Hall, Orbit 3) |
| Mode 1/3 Sub | 17 | gleich | trocken 0,00 dB (Null −54 dB); mit Hall −0,7 dB |
| Mode 1/4 Bass | 18 | gleich | trocken ≤ 0,03 dB (Null −27 … −33 dB); mit Hall +0,2 / +0,5 dB |
| Mode 1/5 Wood | 17 | gleich¹ | ≤ 0,14 dB (Null −24 dB trocken) |
| Mode 1/6 Hats | 14 | gleich | +1,1 dB (44,1-kHz-Samples, über 5 kHz bis 4 dB heller, wie 008) |
| Mode 1/7 Percussion | 15 | gleich | ≤ 0,18 dB (Null −33 dB trocken) |
| Mode 2/1 Pads | 17 | gleich | trocken 0,01 dB (Null −40 dB); mit Hall −0,5 … −3,4 dB² |
| Mode 2/2 Strings | 16 | gleich | trocken ±0,4 dB (Supersaw-Zufallsphasen); mit Hall −0,7 … −1,7 dB² |
| Mode 2/3+4 Stab Shape + Stab | 21 | gleich | −0,1 … −0,6 dB (Mindest-Hall) |
| Mode 2/5 Answer | 19 | gleich (auch Füllung, Doppelnoten) | −0,5 … +0,1 dB; Tension 1: −1,4 dB (Hall + Echo) |
| Mode 2/6 Accents | 16 | gleich (nach Korrektur: ohne FM, s. u.) | trocken 0,00 dB (Spektrum gleich; Null schlecht: reine 3,3-kHz-Sinustöne, Anschläge um Sample-Bruchteile versetzt); mit Hall −0,5 … −3,3 dB² |
| Mode 2/7 FX | 16 | gleich¹ | trocken −0,05 / −0,16 dB; mit Hall bis −2,5 dB² |
| Launchkey | 6 | gleich | Tasten ±0,1 dB, Hall −0,9 dB, Pads +0,5 dB (wie 008) |
| Global (Fog, Thin, Tension, Wumms, Chapter, Break) | in allen | – | – |

¹ Einzige Abweichung im Vergleich: der Log-Gain liegt genau auf einer Rundungsgrenze (0,4725 / 0,3375; SC schreibt
6 Stellen, Strudel volle Länge) — kein hörbarer Unterschied. Wood bei Tension 1: eine Note mehr bei t = 0 (Strudel
liest den Regler bei der ersten Abfrage noch nicht, wie bei 007/010).
² Trocken identisch (`.room(0).delay(0)` gegen eine Kopie ohne Hall). Mit Hall ist SC bei gehaltenen Klängen auf
Orbit 2 (Raum 4) leiser, je mehr Hall, desto mehr (Pads bei Tension 1: −3,4 dB; Strudel gegen sich selbst nur ±0,35 dB).
Das liegt am gemeinsamen Hall (Impulsantwort `ir/orbit-4.wav` / Faltung), nicht an 016 — betrifft 008 genauso
(dort nur trocken verglichen). Offen, s. u.

**Entscheidungen**
- **Kein Master:** Spalte 8 Fader ist in 016 Wumms (Kick, Rumble, Sub, Bass lauter, länger, gezerrt), kein Master.
  Bibliothek: `global.master` darf fehlen, die Kanalzüge stehen dann auf 1 (`lib/setup.scd`). Wumms wirkt wie in
  Strudel pro Note (beim Anschlag gelesen): kurze Klänge.
- **Tension blendet Pads und Strings live** (Grundsatz „Tension wirkt live“): ihr Anteil (Pads 0,3 → 1, Strings
  0 → 1 über 0,2 … 0,7) liegt als Map-Bus auf dem Trim des Kanalzugs (`maps: padIn, strIn`); im Log steht er im `g`
  wie in Strudels Gain. Strings laufen dafür auch unter Tension 0,2 mit (stumm, nicht im Log).
- **Live** außerdem Brightness bei Pads, Strings und Launchkey-Tasten; alles andere ab der nächsten Note (kurze Klänge),
  auch die ganze Stab-Shape-Spalte und Strings-Swell (Attack).
- **Stab Shape** (Mode 2, Spalte 3) ist keine Spur: ihre Regler setzen Filterhüllkurve, Länge, Resonanz, Drive (Fader)
  des Stabs pro Note; Taste 1 = Latch „Stab in/out“, Taste 2 = Ratchet (`ply(2)`). Vanish (Stab Reihe 3) = `rand` am
  Taktanfang; die Answer liest denselben Wert und spielt in den freien Takten (nur wenn der Stab-Fader > 0).
- **Swing** (Wood `swingBy(0,1 + 0,4 × Bounce, 8)`, Hats 0,12 / 0,2): ungerade 16tel um den Betrag später (auf ganzen
  16teln gibt es keine Doppel/Wegfall-Fälle).
- **Übernommene Strudel-Eigenheiten** (1:1, nicht verbessert):
  - Answer: die Schichten (jeder 2. Takt, Spill/Random, Füllung bei fehlendem Stab) sind ein `stack`: fallen zwei auf
    dasselbe 16tel, spielt die Note doppelt (lauter).
  - Accents: `irand(5)`, `irand(7)` und `degradeBy` lesen alle dieselbe Zufallszahl des 16tels; da nur Zahlen über
    1 − 4^Rate/32 (≥ 0,875) durchkommen, spielt **immer Schuss 4 auf Note 104 (A♭7)** (bzw. bei Burst gelegentlich
    andere). Und die Schüsse tragen ihr FM als rohen Schlüssel `fm`, den superdough nicht liest (nur die Funktion
    `.fm()` wird zu `fmi`): kein FM, reiner Sinus. Gemeint war laut Kommentar „jedes Mal ein anderer Klang“.
  - FX: der eigene Tiefpass des steigenden Saw (`.lpf(saw …)`) wird vom Spalten-Tiefpass überschrieben (`strip` setzt
    `lpf` danach).
- **Launchkey:** wie 008 (der Strudel-Abschnitt ist identisch); ohne Master wie Strudel (`postgain` = Modrad).
- **Werkzeug:** `tools/sc-port/strudel-run.mjs` dekodiert jetzt den Repo-Pfad (Leerzeichen → `%20` in der URL):
  vorher fand es die gm-Soundfonts (Launchkey-Vibraphon) und eigene Samples auf der Platte nicht, wenn der Pfad
  Leerzeichen hat.

**Offen (Fragen an die Spieler)**
- Hall auf Orbit 2 bei gehaltenen Klängen in SC 1 … 3 dB leiser als in Strudel (s. ²): Impulsantwort neu messen /
  Hall-Pegel prüfen? Betrifft auch 008.
- Accents: so lassen (1:1) oder wie gemeint (verschiedene Schüsse/Tonhöhen, mit FM) — dann in Strudel und SC ändern?
- Wumms pro Note (wie Strudel) oder live wie früher Master?
