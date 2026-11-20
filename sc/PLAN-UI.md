# UI-Plan: Live-Set-Steuerung

> Status: **Planungsphase.** Hier steht, was im Gespräch festgelegt wurde. Umgesetzt ist davon noch nichts.

Gehört zum Umstieg auf SuperCollider (`SC-MIGRATION.md`). Die Anzeige läuft in der bestehenden Web-UI (`sc/ui/`), die per OSC an SC angebunden ist. Die Controller gehen per MIDI direkt an SC.

Siehe auch: `sc/PLAN-STEM-LIBRARY.md` (Sound Lab, Library, Tracks).

## Grundsatz

- Gespielt wird **nur am Controller** (Launch Control). Den Laptop fasst man während des Sets nicht an.
- Der Laptop **zeigt an** und wird höchstens zum spontanen Suchen in der Bibliothek benutzt.
- Höchstens **eine Shift-Ebene**, damit man live nicht nachdenken muss.

## Drei Steuerebenen

| Ebene | Was | Wie oft |
|---|---|---|
| Global | Tempo, Grundton, Harmonie-Zustand, aktiver Track | selten, bewusst |
| Spalte | welcher Stem geladen ist | gelegentlich |
| Regler | Pegel (Fader), Intensität (Macro) | ständig |

## Stems wechseln (pro Spalte)

- Jede Spalte hat eine **Bank** mit 3–5 Stems derselben Rolle, sortiert nach Energie/Stil.
- **Shift + Spaltentaste:** nächsten Stem vorladen
- **Shift + zweite Taste der Spalte:** vorherigen Stem vorladen (oder Spalte halten, siehe unten)
- **Spaltentaste:** Spalte an/aus. Ein vorgeladener Stem wird **beim Wiedereinschalten** übernommen.
- Der Wechsel greift auf der **Phrasengrenze**. Wird eine Spalte gewechselt, die gerade klingt, gibt es einen kurzen Crossfade statt eines Sprungs.
- **Regler nach dem Wechsel:** Der neue Stem übernimmt den aktuellen Fader- und Macro-Wert. Das setzt den einheitlichen Macro-Vertrag voraus (siehe Sound-Lab-Dokument).
- Prinzip: **eine Änderung zur Zeit**. Das Set verwandelt sich Spalte für Spalte.

## Tracks wechseln

- **Shift + Pfeiltasten:** globaler Track-Wechsel.
- Ein Track-Wechsel ändert, **was in den Banks zur Verfügung steht**, nicht was gerade klingt. Jede Spalte steigt erst beim nächsten Blättern bzw. Wiedereinschalten um.
- **Spalte halten:** Eine Spalte kann ihren alten Track behalten (z. B. das Ambient-Pad bleibt, während der Rest schon auf House steht).
- Wenn man ständig Spalten hält, sind die Tracks falsch zugeschnitten, oder ein Stem gehört in mehrere Tracks.

## Harmonie

- Ein globaler **Harmonie-Zustand**: Modus (Dur, Moll, dorisch …) und Progression (statisch, 2 Akkorde, 4 Akkorde …).
- Weiterschalten per Taste oder Shift-Kombination. Der Wechsel greift auf der Phrasengrenze, am besten nach einem Breakdown oder wenn der Bass kurz raus ist.
- Progressionen sind **kuratiert** (gefunden statt ausgedacht), nicht live zusammengestellt.
- Rhythmus-Spalten sind von der Harmonie nicht betroffen.

## Spontan nachladen (Laptop)

- Die Bibliothek durchsuchen, gefiltert nach Rolle, Energie und Harmonie-Verträglichkeit. Angezeigt wird nur, was gerade passt.
- Der gefundene Stem landet in der Bank der Spalte und wird ganz normal am Controller reingeholt.
- Im B2B macht das die Person, die gerade nicht führt.
- Dafür ist **Vorhören** (Cue auf Kopfhörer) sinnvoll, z. B. über die zusätzlichen Ausgänge des Scarlett 4i4.

## Anzeige am Laptop

**Live:**
- Pro Spalte: was läuft, was vorgeladen ist, was als Nächstes in der Bank kommt, gehalten ja/nein
- Aktiver Track, Harmonie-Zustand, Tempo
- Position in der Phrase *(existiert bereits)*
- **Headroom und Clipping** am Master
- **Geglättete Energie** als Oktav-Histogramm (8–10 Bänder, über etwa einen Takt gemittelt), optional mit einer Referenzkurve aus echten Platten pro Stil
- **Safety:** SuperCollider-CPU (Durchschnitt und Spitzen), Anzahl der Synths, Warnungen über verspätete Events, MIDI-Verbindung beider Controller

**Bewusst weggelassen (vorerst):**
- Pegel pro Spalte. Erst nachrüsten, wenn sich in Sets ein echtes Problem zeigt (z. B. unerklärliche Lautheitssprünge nach einem Stem-Wechsel).
- Volle Spektrogramme und viele Zahlen. Das lenkt ab.

**Nach dem Set (Analyse):**
- Energieverlauf über das ganze Set
- Protokoll aller Aktionen (Stem-Wechsel, Harmonie, Track) mit Zeitstempel, zusammen mit der Aufnahme. Das ist die Grundlage zum Ausdünnen der Banks.

## Soundcheck und Klangkorrektur

Ziel: Der Klang im Raum soll näher an der Zielkurve liegen (Referenzkurve aus echten Platten, siehe Energieanzeige).

**Stufe 1 – Messung vor dem Set (zuerst bauen):**
- Ein kalibriertes USB-Messmikrofon (z. B. miniDSP UMIK-1) am Hörplatz, an mehreren Positionen gemessen und gemittelt.
- Einen Sinus-Sweep oder rosa Rauschen durch die Anlage schicken und den Frequenzgang von Raum plus Anlage messen.
- Daraus ein **festes Korrektur-EQ** im Master ableiten: breitbandig und geglättet, hauptsächlich absenken statt anheben (Headroom), tiefe Auslöschungen nicht auffüllen. Der größte Effekt liegt im Bassbereich.

**Stufe 2 – Live während des Sets (später):**
- Erst nur **anzeigen**: gemessen gegen Ziel.
- Danach optional eine automatische Nachführung: die Übertragungsfunktion aus Master-Signal und Mikrofonsignal schätzen (Kreuzspektrum durch Autospektrum, gewichtet mit Kohärenz), also mit der laufenden Musik als Messsignal.
- Über Minuten mitteln, nur kleine Korrekturen in engen Grenzen, langsam nachführen, Frequenzen mit niedriger Kohärenz ignorieren. Das Publikum verändert den Raum.

**Grenzen:**
- Im Club korrigieren wir nur unseren eigenen Ausgang, die Anlage gehört dem Haus-Techniker. Nicht gegen dessen EQ arbeiten, kurz absprechen.
- Raumkorrektur und Mix-Abgleich sind zwei verschiedene Dinge. Weicht der Mix von der Referenzkurve ab, korrigieren wir das von Hand, nicht automatisch.

## Offene Fragen

- Wie viele freie Tasten bleiben nach dem bestehenden Mapping noch übrig?
- Bringt ein Track Grundton und Tempo mit, oder bleibt beides manuell?
- Braucht die Rhythmus- oder die Harmonie-Hälfte größere Banks?
