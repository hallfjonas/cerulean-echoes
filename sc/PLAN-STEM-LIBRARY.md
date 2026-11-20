# Sound Lab, Library und Tracks

> Status: **Planungsphase.** Hier steht, was im Gespräch festgelegt wurde. Umgesetzt ist davon noch nichts.

Gehört zum Umstieg auf SuperCollider (`SC-MIGRATION.md`). Siehe auch: `sc/PLAN-UI.md`.

## Überblick

```
lab/          → Werkstatt (Sound Lab): experimentieren, vergleichen, verwerfen
sc/sounds/    → Sound-Bibliothek (existiert schon): einzelne Klänge, per Name referenziert
sc/stems/     → Stem-Library (neu): fertige Stems = Klang + Muster + Macro
sc/tracks/    → Tracks als kurze Textdateien: welche Stems, in welcher Reihenfolge
```

**Verhältnis zur bestehenden Sound-Bibliothek:** `sc/sounds/` enthält Klänge (ein SynthDef in festem Format, siehe `sc/sounds/README.md`). Ein Stem ist eine Ebene darüber: Er verweist per Name auf einen Klang und bringt dazu Muster, Rhythmus und die Macro-Belegung mit. Das Prinzip „per Name referenzieren statt Code kopieren“ wird damit von Klängen auf ganze Stems ausgeweitet.

**Verhältnis zu den heutigen Tracks:** `sc/tracks/009-house` usw. enthalten heute noch Spalten, Muster und Harmonie als Code. Im neuen Modell wandern Muster und Spalten in die Stems, Harmonie wird global, und ein Track schrumpft auf eine Auswahlliste.

Ein Track ist **keine Musik mehr, sondern eine Auswahl aus der Library**, ähnlich wie eine Plattentasche für einen Abend. Die ganze Logik liegt in der Library.

## Sound Lab (Werkstatt)

- Hier werden Stems entwickelt und verglichen (Vergleichs-Labs: pro Vergleich nur eine Sache ändern).
- Hier wird auch **ausgedünnt**: Variationen, die nicht schön sind, werden gelöscht, statt sie als Option zu behalten.
- Zufällige Variation nur in engen, getesteten Grenzen.
- Ein Stem wandert erst in die Library, wenn er fertig ist und den Stem-Vertrag erfüllt.

### Drei Stufen (Idee, noch offen)

> Stand 19.11.2026, erstes Gespräch. Noch wenig Erfahrung damit; Zuschnitt und Reihenfolge können sich ändern.

1. **Maschinen-Lab (low level):** Die ganze LC steuert **eine** Maschine, z. B. nur die Kick. Alle Parameter liegen offen (24 Encoder + 8 Fader, ggf. zweite Ebene). Ergebnis: Presets und die Wahl, welche Parameter (mit Bereich) später live noch bewegt werden dürfen.
2. **Options-Lab:** Spalten = Varianten (Presets/Klänge) eines Stems. Dieselben Linien in jeder Spalte, dieselben Regler in jeder Spalte. Entspricht den bisherigen Vergleichs-Labs (`docs/features/lab-boards.md`).
3. **Library:** Der Gewinner wandert als Stem in die Library (Stem-Vertrag, siehe unten). Die Spalte ist dort genauso belegt wie in Stufe 2: Was im Lab getestet wurde, spielt sich live genauso.

Übergänge: In Stufe 1 speichert ein Button ein Preset, in Stufe 2 übernimmt ein „Promote“-Button die gewählte Spalte in die Library.

### Würfel-Modus (RND-Idee)

Vorbild: Cyma Forma RND (siehe `docs/reference/gear-inspiration.md`). Bei uns kein eigenes Gerät, sondern ein Modus, den jede Stufe-1-Maschine bekommt:

- **Würfeln:** setzt alle Parameter der Maschine zufällig neu, innerhalb getesteter Grenzen (pro Parameter Bereich festlegen, damit nichts Unbrauchbares rauskommt).
- **Behalten:** speichert das Ergebnis als Preset (gleicher Mechanismus wie der Preset-Button).
- **Verwerfen / zurück:** zum vorigen Zustand.
- Optional: nur einen Teil würfeln (z. B. nur eine Spalte/einen Baustein) oder Stärke des Würfelns über einen Regler (wenig = Variation des aktuellen Klangs, viel = ganz neu).
- Optional auch für Noten-Maschinen: Sequenz würfeln (euklidisch, Skala aus der Harmonie-Zentrale).

Zweck: schnell viele Kandidaten erzeugen und aussortieren, passt zum Ausdünnen im Lab.

### LC-Schema im Maschinen-Lab

Die **Funktionalität** kommt von echten Geräten (gefunden statt ausgedacht), das **Layout** ist ein eigenes, für alle Maschinen gleiches Schema:

- Spalten = Bausteine im Signalweg, von links nach rechts
- Encoder oben / Mitte / unten = Hauptparameter / Form und Zeit / Feinheit und Modulation
- Fader = Pegel des Bausteins
- Button oben = Baustein an/aus, Button unten = Typ/Modus des Bausteins umschalten
- Was nicht auf 8 Spalten passt: zweite Ebene (Shift oder Seite; beim XL 3 noch prüfen)
- Referenz-A/B: zwischen Maschine und Original-Aufnahme umschalten
- Optional „Original-Modus“: nur die Regler des Vorbilds aktiv (z. B. 909-Bassdrum: Tune, Level, Attack, Decay)

Klassische Drum Machines haben pro Stimme nur wenige Regler. Als Vorbild für die volle LC taugen eher Drum-Synths mit vollem Panel pro Stimme.

### Maschinen (Kandidaten)

Geräte, von denen wir Ideen nehmen (was sie können, was wir übernehmen): `docs/reference/gear-inspiration.md`.

| Bereich | Maschine | Vorbild für die Funktionalität |
|---|---|---|
| Klang | Kick | Jomox MBase, Microtonic-Bassdrum, 909/808-Bassdrum |
| Klang | Rumble | kein Gerät, Produktionstechnik: Hall → Filter → Sidechain → Drive |
| Klang | Drum Voice (Snare, Clap, Rim, Toms, Congas, Cowbell) | Microtonic-Stimme (Oszillator + Noise), 909 Snare/Clap |
| Klang | Metal (Hats, Rides, Cymbals) | 808/909-Metallschaltung (6 Rechtecke + Noise) |
| Klang | Mono-Bass (Bass, Acid, Leads) | TB-303, SH-101 |
| Klang | Poly (Chords, Stabs, Pads) | Juno-106 |
| Klang | FM (E-Piano, Glocken, Stabs) | DX7, vereinfacht auf 2–4 Operatoren |
| Klang | Texture (Ambient-Flächen, Drones) | Mutable Instruments Plaits/Clouds, Cyma Forma ALT, Elta Solar 42 |
| Klang | Balsam (8 Stimmen, Tonhöhe pro Fader, langsames Gleiten, reine Stimmung) | GLX Balsam |
| Klang | Wavetable (Morph durch eine Tabelle von Einzelwellen; Wellen-Effekte: Pre-Gain, Phase Shift, Harmonic Shift, Comb, Ring Mod, Chebyshev, Sample & Hold, Quantize, Slew, Low-/Highpass, Post-Gain) | OXI Coral (Wavetable-Editor, Screenshot `sc/ui/reference/oxi-coral-wavetable-editor.png`) |
| Noten | Arpeggiator | Juno/SH-101, dazu Ratchets und Wahrscheinlichkeit |
| Noten | 303-Sequencer | TB-303 (Accent, Slide, Gate), getrennt vom Klang |
| Noten | Chord Memory | Korg Polysix (eine Taste = ganzer Akkord) |
| Rhythmus | Grids | Mutable Instruments Grids (X/Y-Karte, Dichte pro Drum) |
| Noten | Turing Machine | Music Thing Modular (Zufallsschleife zwischen fest und mutierend) |
| Werkzeug | Würfel (RND) | Cyma Forma RND |
| Rhythmus | Euklidische Rhythmen | Bjorklund, Torso T-1 |
| Harmonie | Harmonie-Zentrale (Tonart, Skala, Progression) | siehe „Kapitel“ unten und `sc/PLAN-UI.md` |
| Groove | Swing, Humanize, Microtiming | MPC 60 |
| Modulation | LFOs, Hüllkurvenfolger, Szenen-Morph | Octatrack-Crossfader |
| FX | Dub-Delay, Hall, DJ-Filter/Isolator, 12-Bit, Tape, Sidechain-Pumpen, Beat-Repeat, Granular-Freeze | Space Echo, SP-1200 u. a. |
| Sampler | Chops, Pitch, Time-Stretch (für die Vocal-Pads) | SP/MPC, Torso S-4 |

Reihenfolge (Vorschlag, offen): Harmonie-Zentrale und Arp/Chord Memory → Grids → Kick, Metal, Mono-Bass, Poly → Rest.

### Maschine im Detail: Algo-Sequencer (Vorbild Torso T-1)

> Stand 19.11.2026, erster Entwurf. Quelle: offizielle T-1-Dokumentation (docs.torsoelectronics.com/t1).
> Wo die Doku nur Bilder zeigt (Formen von Phrase und Groove), legen wir eigene Formen fest, am besten aus echten Platten.

**Was die Maschine ist:** kein Klangerzeuger, sondern ein **Noten- und Rhythmus-Generator**. Sie erzeugt Noten
(Zeitpunkt, Tonhöhe, Lautstärke, Länge) und schickt sie an eine Klang-Maschine oder einen Stem. Beim T-1 heißt das
„algorithmischer Sequencer“; „Drum Machine“ wäre falsch, weil er selbst keinen Ton macht. Sie deckt die Kandidaten
„Euklidische Rhythmen“ und „Arpeggiator“ aus der Tabelle ab, dazu Note-Repeats (Ratchets).

**Grundprinzip (vom T-1):** Melodie beginnt beim Rhythmus. Erst entscheiden Steps und Pulses, *wann* Noten kommen;
dann entscheiden Pitch, Scale/Root, Voicing/Style und Range/Phrase, *welche* Noten es sind und wie sie sich bewegen.
Statt Noten einzeln zu programmieren, gibt man Regeln vor und dreht an ihnen.

#### Bausteine und was sie tun

| Baustein | Parameter | Was er tut (T-1) | Umsetzung bei uns |
|---|---|---|---|
| Rhythmus | Steps | Anzahl Schritte im Muster (z. B. 16, 12, 8) | Länge des Rasters |
| | Pulses | Anzahl Anschläge, so gleichmäßig wie möglich über die Steps verteilt (euklidisch) | Bjorklund-Algorithmus |
| | Rotate | verschiebt den Startpunkt, ohne die innere Struktur zu ändern | Rotation des Rasters |
| Tempo des Rasters | Division | Notenwert eines Steps, Default 1/16; auch Triolen und stufenlos („Free Division“) | 1/4 … 1/32, Triolen; stufenlos optional |
| Wiederholung | Cycles | jeder Cycle speichert eine eigene Version der Spur (Default 4, bis 16); Spur verändert sich von Durchgang zu Durchgang; einzelne Cycles stummschaltbar | Liste von Parameter-Sätzen, reihum gespielt |
| Note-Repeats | Repeats | 0–48 Zusatz-Anschläge nach jedem Pulse, Rechtsanschlag = unendlich | Ratchets nach jedem Anschlag |
| | Ramp | Lautstärke der Repeats steigt (rechts) oder fällt (links) | Velocity-Rampe über die Repeats |
| | Time | Abstand der Repeats als Notenwert (gerade, Triolen, frei) | Abstand in Notenwerten |
| | Pace | Repeats werden im Verlauf schneller (links) oder langsamer (rechts), Mitte = gleichmäßig | geometrisch wachsende/schrumpfende Abstände |
| | Choke / Tail | Choke: neuer Pulse schneidet alte Repeats ab. Tail: Repeats überlagern sich | Umschalter |
| Töne | Pitch | welche Töne die Spur benutzt (beim T-1 bis zu 8, als Akkord), Knopf transponiert innerhalb der Skala | Tonvorrat; bei uns aus der Harmonie-Zentrale (aktueller Akkord) |
| | Harmony | verschiebt jeweils einen Akkordton nach oben/unten; Ergebnis hängt vom Weg ab | Akkordton-Verschiebung in Skalenstufen |
| | Scale / Root | Tonleiter und Grundton, pro Cycle verschieden möglich | global aus der Harmonie-Zentrale; pro Maschine höchstens Override |
| Akkord-Bewegung | Voicing | Menge der Bewegung: tiefster Ton eine Oktave hoch bzw. höchster Ton eine Oktave runter (Umkehrungen, Spreizung) | Anzahl Umkehrungs-Schritte |
| | Style | wie das Voicing über die Zeit läuft: Fixed, Ramp, Climb (2 vor, 1 zurück), Up/Down, Climb Up/Down; jeweils poly (zusammen) oder mono (nacheinander = Arpeggiator); Richtung auf/ab | 5 Bewegungsarten × poly/mono × auf/ab |
| Melodie-Bewegung | Range | wie weit die Tonhöhe wandert; klein = kontrolliert, groß = lebhaft | Abweichung in Skalenstufen |
| | Phrase | Form, der die Bewegung folgt: Cadence 1–4, Saw, Triangle, Sine, Pulse; Länge 1–64 Takte (Default 4) | eigene Formen; Kadenzen aus echten Platten |
| Dynamik | Velocity | Grund-Lautstärke | Grund-Velocity |
| | Accent | Velocity schwankt um den Grundwert | Stärke der Schwankung |
| | Groove | Muster der Schwankung: Agogo, Timbales, Congas, Bongo, Saw, Triangle, Sine, Pulse; Länge 1–64 Takte | eigene Akzent-Muster (Percussion-Vorbilder) |
| | Probability | wie oft Noten ausgelassen werden (0–100 %); nur Pulses (mit ihren Repeats) oder alle Noten | Auslass-Wahrscheinlichkeit, zwei Modi |
| Timing | Timing | verschiebt jeden zweiten Step früher/später (Swing/Shuffle), Unterteilung ×1/×2/×4 | Swing; global aus dem Groove-Baustein, pro Maschine Offset |
| | Delay | verschiebt die ganze Spur gegen das Raster (vor/hinter den Beat) | Offset in ms |
| | Sustain | Notenlänge relativ zum Step, Default 50 % = eine Division; mehr = Überlappung | Notenlänge (`hold`) |

#### Zufall (Random) beim T-1

- Zufall wird **pro Parameter** zugewiesen (RANDOM halten + Parameter drehen = Menge). Er ist keine echte Würfelei,
  sondern eine **pseudo-zufällige, sich wiederholende Folge**: dieselbe Variation kommt wieder, bis man sie verschiebt.
- **Variance** (RANDOM drehen): wie stark die Folge über die Zeit wegdriftet. **Rate**: wie oft sich der Wert ändert.
- Manche Parameter ändern sich **einmal pro Cycle** (Steps, Pulses, Cycles, Division, Velocity, Pitch, Scale),
  die anderen mit der **Rate** (Repeats, Time, Voicing, Range, Sustain, Accent, Timing).
- Drehrichtung beim Zuweisen: rechts = jeder Akkordton anders, links = alle Akkordtöne gleich (bei Steps/Pulses:
  hinzufügen/wegnehmen; bei Scale: Skala bzw. Skala + Grundton; bei Cycles: nächsten überspringen bzw. aktuellen wiederholen).
- „Lock“ friert die Folge eines Parameters ein.

Für uns: genau das Prinzip „Zufall in engen, getesteten Grenzen“ aus dem Sound Lab. Die wiederholende Folge passt
besser zu House/Techno als echter Zufall, weil Muster wiedererkennbar bleiben.

#### Belegung auf der LC (Entwurf, nach unserem LC-Schema)

Spalten = Bausteine von links nach rechts; Encoder oben/Mitte/unten = Hauptparameter / Form und Zeit / Feinheit;
**Fader = Zufallsmenge des Bausteins** (0 = fest); Button oben = Baustein an/aus, Button unten = Modus.

| Spalte | Encoder oben | Encoder Mitte | Encoder unten | Fader | Button oben | Button unten |
|---|---|---|---|---|---|---|
| 1 Rhythmus | Pulses | Steps | Rotate | Zufall Rhythmus | an/aus | Cycles-Ansicht |
| 2 Raster | Division | Swing (Timing) | Delay | Zufall Division | — | gerade/Triole |
| 3 Repeats | Repeats | Time | Pace | Zufall Repeats | an/aus | Choke/Tail |
| 4 Töne | Pitch (transponieren) | Harmony | Oktave | Zufall Pitch | — | Tonvorrat: Akkord/Skala |
| 5 Voicing | Voicing | Style | Richtung | Zufall Voicing | an/aus | poly/mono |
| 6 Melodie | Range | Phrase | Phrase-Länge | Zufall Range | an/aus | Phrase weiter |
| 7 Dynamik | Velocity | Accent | Groove | Zufall Accent | — | Groove weiter |
| 8 Global | Probability | Sustain | Zufalls-Rate | Variance (Drift) | Lock | Probability-Modus |

Offen: ob „Ramp“ (Repeats) und „Ramp“ (Style) eine zweite Ebene brauchen; ob Cycles eine eigene Seite bekommen
(beim T-1 bis zu 16 Versionen der Spur). Per-Step-Editing braucht ein Raster: Launchpad oder Web-UI
(Euklid-Kreis und Step-Raster sind dort auch gut zu zeigen).

#### Was wir bewusst weglassen oder anders machen

- CC-Spuren, FX-Spuren (MIDI-Effekt auf eingehende Noten), CV-Eingang als Phrase, Ableton Link: brauchen wir nicht.
- Scale/Root pro Spur: bei uns global (Harmonie-Zentrale), damit alle Stems zusammenpassen.
- 16 Spuren in einem Gerät: bei uns eine Maschine pro Lab-Spalte, live 8 Spalten mit nur den wichtigsten Reglern
  (Pulses, Rotate, Dichte, Zufall).
- Neu bei uns: ein **Intensitäts-Macro** (Stem-Vertrag), das organisch Pulses, Repeats und Range gemeinsam hochfährt.

### Bausteine in SuperCollider (zum Prüfen)

- mi-UGens (Ports der Mutable-Instruments-Module)
- SC-808 (Yoshinosuke Horiuchi), synthetisierte 808
- VSTPlugin (VSTs in SC)
- Synths aus SuperDirt
- Pmini (Mini-Notation in SC-Patterns), Bjorklund
- Modality Toolkit (MKtl; für den XL 3 vermutlich eigene Beschreibung nötig) oder direkt `MIDIdef`

## Library (kuratierter Stand)

- Wird groß. Rechnung für 1h+ über mehrere Stile: eher 40–60 Stems.
- Wird **per Referenz** in Tracks geladen, nicht kopiert. Verbesserungen kommen automatisch in allen Tracks an.
- **Vor einem Gig den Stand einfrieren** (Git-Tag), damit sich nichts unbemerkt ändert.

### Stem-Vertrag

Jeder Stem in der Library erfüllt:

- **Rolle:** z. B. Kick, Perc, Hats, Bass, Keys, Pad, Lead, Textur. Die Rolle bestimmt, in welche Spalte er passt.
- **Tonhöhe relativ:** Bass relativ zum aktuellen Akkordgrundton, Pads mit den aktuellen Akkordtönen, Leads in Skalenstufen im aktuellen Modus. Grundton, Modus und Progression kommen global.
- **Tempo und Swing global:** Ein Stem gibt höchstens an, ob er Swing mitmacht.
- **Gleiche Lautheit:** auf einen gemeinsamen Zielpegel normalisiert.
- **Gleiche Regler-Bedeutung:** Fader = Pegel, Macro 0→1 = Intensität (Dichte, Filter, Schichten), immer organisch und ohne Sprünge.
- **Metadaten:** Rolle, Energie-Level, passende Stile (Ambient bis Techno), Harmonie-Verträglichkeit (z. B. „nur statisch“, „nicht in Dur“).

Die Metadaten von Anfang an konsequent pflegen. Bei einer großen Library findet man Stems nur darüber wieder.

## Tracks (kurze Textdateien)

Ein Track legt nur fest:

- pro Spalte die **Bank**: Liste von Stem-Referenzen, nach Energie/Stil sortiert
- welcher Stem pro Spalte **beim Start** geladen ist
- welche **Harmonie-Zustände** verfügbar sind (Modus, Progressionen)
- **globale Regler:** Tempo-Bereich und Start-Tempo, ggf. Grundton

Skizze (Format noch offen):

```
name: warmup-ambient-house
tempo: 118 (112–122)
harmony: [moll-statisch, dorisch-2akk, moll-4akk]

rhythm:
  1: [kick/soft-round, kick/dry-909]
  2: [perc/shaker-loose, perc/congas-light]
  ...
melodic:
  1: [bass/sub-roots, bass/rolling-8th]
  2: [pad/warm-choir, pad/eno-tape]
  ...
```

Folgen:

- Ein neuer Track braucht keinen Code, nur eine Auswahl.
- Ein Stem kann in mehreren Tracks vorkommen.
- Mehrere Tracks hintereinander ergeben den Bogen über 1h+ (z. B. Warm-up → House → Techno).

## Kapitel (bisher in den Tracks)

Die bisherigen Kapitel wechseln vor allem die Harmonie (Dur/Moll/…, mit oder ohne Progression). Sie werden zum **globalen Harmonie-Zustand**, der nicht mehr an einen Track gebunden ist. Was die Kapitel sonst noch machen, übernehmen Stem-Wechsel (Patterns) und Macro (Intensität).

## Offene Fragen

- „Track“ umbenennen in „Set“ oder „Crate“, damit klar ist, dass es eine Auswahl ist?
- Format der Track-Datei (YAML, JSON, eigenes)?
- Wo stehen die Metadaten: im Stem-Code selbst oder in einer Sidecar-Datei?
- Welche Referenz-Progressionen und Referenz-Spektren nehmen wir aus echten Platten?
- Maschinen-Lab: Wie viele Parameter pro Maschine, ab wann eine zweite Ebene?
- Sind Noten-Generatoren (Arp, Grids, Turing Machine) eigene Spalten, oder hängen sie an einem Klang-Stem?
- Wie viele Regler pro Stem bleiben live übrig? Der Stem-Vertrag sagt bisher: ein Macro (Intensität). Im Gespräch kamen auch 3 Makros pro Spalte vor.
