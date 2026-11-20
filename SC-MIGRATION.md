# Umstieg auf SuperCollider – Kontext für Coding-Agents

Stand: 17.11.2026. Entscheidungen aus einem Planungsgespräch. Gilt für das Repo `cerulean-echoes` (bisher Strudel-Tracks + Sound-Lab).

## Ausgangslage

- Zwei Musiker (klassisches Klavier/Chor; E-Bass), vorher keine elektronische Musik. In ca. 4 Wochen mit Strudel eine eigene Live-UI und mehrere Sets gebaut, die Fremde mit minimaler Erklärung spielen konnten. **Diese Bedienbarkeit ist der eigentliche Vorsprung und muss beim Umstieg erhalten bleiben.**
- **Es wird live nicht gecodet.** Code ist vorbereitet, gespielt wird ausschließlich über MIDI-Controller („code-basiertes klassisches Live-Set“). Den Code schreibt Claude, nicht die Musiker.
- Genres: House und Techno (trocken, oldschool, straight), Ambient House, Ambient.
- Gespielt wird meist B2B: ein Laptop (MacBook Air), zwei Controller. Auch in Clubs, daher möglichst leichtes, robustes Setup.
- Hardware: Novation Launch Control XL 3 (perspektivisch 2× Launch Control + 1 Launchkey oder Launchpad), Casio GP-310, geplant Focusrite Scarlett 4i4. Zusätzlich ein Pad für live ausgelöste Samples (z. B. Vocals).

## Grundentscheidung

**Komplett SuperCollider. Kein Tidal, kein Strudel-Hybrid (Strudel→SuperDirt), kein Ableton.**

Gründe:
- Hauptmotiv: Regler sollen **sofort** wirken, auch auf bereits klingende Töne. In Strudel werden Parameter nur beim Event-Onset gelesen.
- Tidal bringt nur kompaktes Live-Tippen – wird nicht gebraucht.
- Ableton wäre Overhead (zweite App, CPU, Mapping an zwei Orten); Sync bei Bedarf über Ableton Link (`LinkClock`).
- Zwei Codebasen (Strudel + SC) sollen **nicht** parallel gepflegt werden.

## Architektur-Vorgaben

### Kontinuierliche Kontrolle
- Regler (`MIDIdef.cc`) schreiben in **Control-Busse**; Synths lesen diese laufend (`.map` / `In.kr`). Lautstärke, Filter, FX etc. ändern sich sofort.
- Kurzes `Lag` (10–50 ms) gegen Zipper-Noise.
- Pro Spur ein **Mixer-Kanal** (Group + Gain/Channel-Synth), Fader steuert den Kanal, nicht jede Note.
- Pro Control bewusst festlegen: **sofort** (Regler, Sample-Pads) oder **auf den Takt quantisiert** (Spuren starten/stoppen).

### Latenz
- Patterns (Pdef/Pbind) dürfen mit `s.latency` (Default 0.2 s) laufen – für sequenzierte Spuren unproblematisch.
- Controller-Eingriffe und Sample-Pads gehen **direkt** an Synths/Busse, ohne diesen Vorlauf.
- Interface-Puffer klein halten.

### Set-Modell
- Spuren = `Pdef`s, per Button gestartet/gestoppt (quantisiert).
- Kontinuierliche Klänge (Pads, Drones) ggf. als `Ndef`.
- Controller-Layout aus Strudel übernehmen: Spaltenreihenfolge tief links → hoch rechts, globaler Drop-Button, Drum-Modus + zweiter Modus für melodische Parts.

### Sound-Bibliothek (behebt das Lab→Track-Problem)
Bisher hat Claude Sounds aus dem Lab-Ordner in Tracks hineinkopiert – mit wechselndem Erfolg. Neu:
- Jeder Sound ist ein **SynthDef in festem Format**: Name, Parameter mit Wertebereich und Default, Zuordnung zu Controller-Slots, Default-Hochpass.
- **Tracks referenzieren Sounds per Name + Preset**, statt Code zu kopieren. Verbesserungen wirken automatisch überall.
- Lab → Bibliothek ist ein klarer Schritt: Ein Sound ist „fertig“, wenn er dem Format entspricht.
- Die Konventionen werden zusätzlich als **Skill** festgeschrieben.
- Später optional: kleine **Audition-UI** zum Anhören/Vergleichen von Sounds im Track-Kontext, Presets speichern (möglichst mit demselben Controller).

### Live-UI
- **Bestehende Web-UI weiterverwenden**, nicht durch SC-Qt-GUI oder Open Stage Control ersetzen.
- UI ↔ SC über **OSC**, mit kleiner Brücke (Node oder Python, WebSocket ↔ OSC).
- Controller gehen **per MIDI direkt an SC**, nicht über den Browser. Die UI zeigt an und steuert Unkritisches.
- Pegelanzeigen (Spuren + Summe) und optional Spektrum in die UI.
- Für Installationen: UI auch vom Handy/Tablet erreichbar, SC headless.

### Master-Kette / Gain-Staging
- Spuren peaken bei ca. −12 bis −18 dBFS, Summe vor dem Limiter bei ca. −6 dBFS.
- `Limiter.ar` als letztes Glied auf dem Master-Bus, Ceiling ca. −1 dBFS, soll kaum arbeiten.
- macOS-/Software-Ausgang fest; lauter wird am Club-Pult gemacht.
- Bass und Kick mono; alle anderen Spuren mit Hochpass (Defaults: Leads/Stabs 100–200 Hz, Pads 150–250, Vocals 100–150, Hats/Perc 200–500, Hall-/Delay-Returns 200–300; Kick/Bass höchstens 20–30 Hz). Feintuning im Lab, Wert im Preset.
- Bandbegrenzte Oszillatoren (`Saw`, `Pulse`) für hörbare Töne, nicht `LFSaw`/`LFPulse` (Aliasing).
- Samples als WAV, 24 Bit.

### Ausgänge
- Hauptsumme → Scarlett Out 1/2 (symmetrisch ins Club-Pult).
- **Separater Cue-Bus** für Vorhören (Scarlett Out 3/4 bzw. Kopfhörer; Routing in Focusrite Control 2 prüfen).
- Abhör-Simulationen (Realphones, Club-EQ-Profil) **nur auf dem Abhörweg**, nie auf dem Hauptausgang.

### Optional / später
- Club-„Softproof“: Frequenzgang einer realen Anlage mit Messmikro (z. B. UMIK-1) + REW messen und als EQ-Kurve auf den Abhör-Bus legen.
- Lauffähig auf Raspberry Pi + Audio-Hat für Klanginstallationen (headless, Autostart, Sensoren/Controller).
- Veröffentlichung als Open-Source-Framework (Interface + Sound-Format + Beispiel-Sounds); Positionierung: KI-geschriebenes, generatives Performance-Instrument, keine DAW-Alternative.

## Vorgehen

1. Einen Track (Vorschlag: 009, House) inkl. Controller-Mapping in SC nachbauen.
2. Direkt mit der Strudel-Version vergleichen und spielen.
3. Track für Track umziehen; Strudel-Sets bleiben fürs Spielen, bis die SC-Version mindestens gleichwertig ist. Danach Strudel aufgeben.

## Arbeitsregeln für Agents (aus dem Projekt)

- Nur umsetzen, worum gebeten wurde; Zusatzänderungen (z. B. Layout) vorher fragen.
- Finden statt ausdenken: echte Vorlagen (Platten, Analysen, Quellen) statt erfundener Riffs/Linien.
- Vergleichs-Labs: pro Vergleich nur eine Sache ändern (Klang **oder** Linien); Spalten = Klänge, Tasten = dieselben Linien in jeder Spalte.
- Jede Lab-Spalte ist später eine einzelne, allein spielbare Track-Spalte.
- Steigerungen (Komplexität/Dichte/Schichten) über einen Regler, immer organisch, kein Sprung.
