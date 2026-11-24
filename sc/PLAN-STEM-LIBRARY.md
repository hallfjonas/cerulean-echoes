# Sound-Lab-Ideen (Sound Machine und Modi, Maschinen, Algo-Sequencer, Würfel-Modus)

> Stem, Library, Tracks und Lab sind umgesetzt: siehe `docs/features/stems.md` und `docs/features/sound-lab.md`.
> Hier bleiben nur Ideen, die noch nicht gebaut sind. Siehe auch: `SC-MIGRATION.md`, `sc/PLAN-UI.md`.

### Grundsätze: eine Sound Machine, mehrere Modi (Stand 24.11.2026)

Das Sound Lab ist **ein** Instrument, die Sound Machine, mit mehreren Modi. Jeder Modus ist eine eigene Maschine mit
eigener Klangerzeugung, eigenen Parametern und eigenen Generatoren. Gemeinsam ist die Technik, nicht das Instrument.
Der Stem Designer (Stems vergleichen, kombinieren, ausdünnen) bleibt ein eigener Arbeitsschritt danach.

| Modus | Was er macht | Maschinen aus der Tabelle unten |
|---|---|---|
| Kick | Bassdrum (mit Rumble) | Kick, Rumble |
| Bass | Sub, Bass, Acid (303-Klang mit seinem Sequencer) | Mono-Bass, 303-Sequencer |
| Percussion | alle anderen Drums: Snare, Clap, Rim, Toms, Congas, Hats, Becken | Drum Voice, Metal, Grids |
| Harmonie | mehrere Töne gleichzeitig: Akkorde, Pads, Stabs (z. B. Stab in 008, `techno-stab.scd`) | Poly, Chord Memory |
| Melodie | eine Linie: Leads, Antworten, Sequenzen, Arps, Glocken (z. B. Answer und Glocken-Sequenz in 008, `techno-answer.scd`, `techno-seq.scd`) | FM, Wavetable, Arpeggiator, Turing Machine, Antwort |
| Drone / Soundscape | Flächen, Drones, Texturen | Texture, Balsam |

Kick-Prinzip: immer nur ein Sample gleichzeitig; alle Regler formen dieses Sample, ein Knopf schaltet durch die
Grundsounds. (Das Drum-Setup im Sample Designer baut die Kick dagegen aus Tone, Noise und Click.)
Die Harmonie-Zentrale (Tonart, Skala, Progression) ist kein Modus, sondern geteilte Technik, die jeder Modus liest.

**Gemeinsame Technik** (geteilt, wo es passt; kein Universal-Framework): Clock und Sync, Event-Scheduling, Zufall
(reproduzierbare Folgen, Würfel), Wahrscheinlichkeit, Modulation (LFOs, Hüllkurven), Pattern-Speicher,
Harmonie-Zentrale (global, pro Maschine höchstens Override), Groove (Swing), Stem-Vertrag und Promote in die Library,
die Regel „alle Regler auf 0 klingen schon gut“. Schon da: die Bausteine des Sample Designers
(`sc/lab/samples/blocks.json`, `sc/lab/samples/machine.scd`); offen, ob sie ein Modus unter mehreren werden oder
geteilte Teile.

**Eigen pro Maschine:** Klangerzeugung, Art des Sequencers, welche Generatoren sie kombiniert, eigene Zufallsregeln,
eigene Spezialfunktionen. Keine Maschine muss alles können, keine wird der Einheitlichkeit wegen beschnitten.

**Musikalische Generierung und Klang-Modulation** sind getrennte Systeme, die zusammenwirken dürfen.
Generierung = Ereignisse (Sequencer, Noten, Rhythmus, Arp, Wahrscheinlichkeit, Variation).
Modulation = Klangparameter über die Zeit (LFOs, Hüllkurven, Random-Modulation, Filter-, Sample-Position-,
FX-Modulation). Noten-Generatoren sind geteilte Bausteine und hängen an einem Klang: eine Lab-Spalte = Klang +
Generator(en), allein spielbar, keine eigene Spalte für den Generator. Beispiele: Melodie kombiniert Step-Sequencer,
Arp, Akkord-Generator und Zufallsnoten; Percussion kombiniert Sample-Sequencing, rhythmische Variation,
Wahrscheinlichkeit und Sample-Auswahl.

**Zufall in drei Arten**, in jedem Modus, pro Maschine angepasst:
- Pattern (was passiert: Noten, Trigger, Samples, Steps) und Performance (wie: Velocity, Timing, Akzente, Länge):
  Zufall pro Parameter nach dem T-1 (siehe unten).
- Klang (wie es klingt: Pitch, Filter, Decay, Sample-Position, FX): Würfel-Modus (siehe unten).
- Steuerung: Menge, Wahrscheinlichkeit, Bereich, Lock, neu würfeln, reproduzierbar (wiederholende Folge, Seed);
  Ebenen: Pattern, Spur, Parameter, einzelner Step.

**LC-Belegung: noch festzulegen.** Tendenz: Reihen statt Spalten. Jede Reihe hat in allen Maschinen dieselbe Rolle,
die Maschine bestimmt die Parameter darin; die Spalten sind dann die Layer oder Stimmen einer Maschine.

| Reihe | Rolle |
|---|---|
| Knöpfe 1 | Klangerzeugung |
| Knöpfe 2 | Hüllkurven, Filter, Formung |
| Knöpfe 3 | Charakter, Modulation, Effekte |
| Fader | Pegel, Layer-Balance, Makros |

Bisher sind Sample Designer und T-1-Entwurf spaltenweise (Spalte = Baustein, Reihen = Haupt / Form und Zeit / Fein).
Die Live-Stems behalten ihr eigenes Reihenschema (Brightness, Space, benannt).

**Seiten:** Sequencing, Zufall und Generatoren bekommen eigene Seiten auf denselben Reglern, statt in die drei
Klangreihen gequetscht zu werden. Dafür der LC im DAW-Modus (`.claude/prds/lcxl3-daw-mode.md`: Track = Maschine,
Page = Seite/Preset, Shift); die Belegung kommt mit der Folge-PRD. Arbeitsweise nicht-linear: frei wechseln zwischen
Klang, Pattern, Variation, Vorhören und Resampling.

### Würfel-Modus (RND-Idee)

Vorbild: Cyma Forma RND (siehe `docs/reference/gear-inspiration.md`). Bei uns kein eigenes Gerät, sondern ein Modus, den jede Stufe-1-Maschine bekommt:

- **Würfeln:** setzt alle Parameter der Maschine zufällig neu, innerhalb getesteter Grenzen (pro Parameter Bereich festlegen, damit nichts Unbrauchbares rauskommt).
- **Behalten:** speichert das Ergebnis als Preset (gleicher Mechanismus wie der Preset-Button).
- **Verwerfen / zurück:** zum vorigen Zustand.
- Optional: nur einen Teil würfeln (z. B. nur eine Spalte/einen Baustein) oder Stärke des Würfelns über einen Regler (wenig = Variation des aktuellen Klangs, viel = ganz neu).
- Optional auch für Noten-Maschinen: Sequenz würfeln (euklidisch, Skala aus der Harmonie-Zentrale).

Zweck: schnell viele Kandidaten erzeugen und aussortieren, passt zum Ausdünnen im Lab.


### Maschinen (Kandidaten)

Geräte, von denen wir Ideen nehmen (was sie können, was wir übernehmen): `docs/reference/gear-inspiration.md`.
Zuordnung zu den Modi: siehe Grundsätze oben.

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
| Noten | Antwort (Call and Response) | kein Gerät, aus 008 (`techno-answer.scd`): kurze Phrase am Ende jedes zweiten Takts, Akkordtöne zufällig, Stimmen dazu |
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

#### Belegung auf der LC (Entwurf, nach unserem LC-Schema; spaltenweise, siehe „LC-Belegung: noch festzulegen“ oben)

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


## Offene Fragen

- Welche Referenz-Progressionen und Referenz-Spektren nehmen wir aus echten Platten?
- Maschinen-Lab: Wie viele Parameter pro Maschine, ab wann eine zweite Ebene?
- LC-Belegung: Reihen (Tendenz) oder Spalten pro Baustein? Noch festzulegen, siehe Grundsätze.
- Sample-Designer-Bausteine: ein Modus unter mehreren oder geteilte Teile?
- Beantwortet (24.11.2026): Noten-Generatoren hängen an einem Klang, keine eigenen Spalten.
