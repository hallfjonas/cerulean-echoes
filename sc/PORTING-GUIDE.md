# Anleitung für einen Agent: einen Strudel-Track nach SuperCollider portieren (007, 008, 010)

Stand 18.11.2026. Aus der Portierung von 009 (alle Spalten, Launchkey, global) gelernt. Vorher lesen:
`SC-MIGRATION.md` (Ziele, Entscheidungen), `CLAUDE.md` (Regeln, Beschriftung), `sc/README.md` (Aufbau),
`sc/PORTING.md` (Entscheidungen bei 009), `sc/tracks/009-house/009-house.scd` (das Vorbild, ausführlich kommentiert).

## Ziel und Reihenfolge

1. **Zuerst 1:1.** Der SC-Track spielt dieselben Noten (Zeit, Tonhöhe, Länge, Gain) wie der Strudel-Track und klingt
   bei festen Reglerstellungen gleich. Auch Strudel-Eigenheiten werden übernommen und in `PORTING.md` notiert
   (bei 009: Swing verdoppelt/verschluckt Töne, `+1` auf Notennamen tut nichts). Nichts „verbessern“, ohne zu fragen.
2. **Ausnahmen, die immer gelten** (vom Nutzer so gewollt, bei 009 schon umgesetzt):
   - Level, Space, Echo, Fog, Thin, Tension wirken **live auf klingende Noten** (Kanalzüge, Control-Busse).
   - **Lange, gehaltene Klänge** (Flächen, Harmonien, Swells, z. B. die Strings in 008): Brightness und
     Klang-Überblendungen wirken ebenfalls live auf die klingenden Noten (State-Busse, die die Noten gemappt lesen:
     `lo: ce.stateMap(\xCut)`, `mix: ce.stateMap(\xMix)`; Schichten, die überblendet werden, laufen dafür immer mit,
     stumm mit `nolog: true` im Event-Log). **Kurze Töne** behalten den Klang vom Anschlag, wie in Strudel. Im
     Zweifel den Nutzer fragen. Vorbild: Harmonie in 009 (Brightness und Streicher ↔ Orgel).
     Regler, die bestimmen, *was* gespielt wird (Pattern, Complexity, Length), wirken ab der nächsten Note.
   - **Launchkey-Tasten und -Pads klingen sofort**, ohne Vorlauf: Anschläge gehen ohne Zeitstempel an den Server
     (`ce.playNow`, aus `ce.midiNote`), nicht über die Patterns mit `s.latency`. Gemessen bei 009: 3–4 ms vom
     MIDI-Eingang bis zum Start der Synth, dazu der Audiopuffer. Das ist einer der Hauptgründe für SuperCollider.
   - **Keine Artefakte aus geteilten Effekten:** Spalten mit eigener Echozeit bekommen `ownDelay` (eigene
     Verzögerung statt des gemeinsamen Orbit-Echos). Zeitwechsel blendet `ce_delay` selbst über.
   - Master-Trim −9 dB, Limiter nur Notbremse (gilt für alle Tracks, `lib/ce.scd`).
3. **Danach optimieren** – nur mit Nutzer.

Arbeite Spalte für Spalte: portieren → automatisch vergleichen → nächste. Erst Kick/Bass/global (das Gerüst),
dann Jojos Spalten, dann Jonas', dann Launchkey. Neue Sounds in `sc/sounds/`, neue Bibliotheks-Funktionen in
`sc/lib/` (nie trackspezifisch), alles Trackspezifische in `sc/tracks/NNN-name/NNN-name.scd`.

## Die Bausteine (alle schon da)

| Strudel | SC |
|---|---|
| `midin` / `col(n)`, Mode 1/2, Spalte 8 global | Control-Busse pro CC (`ce.ccMap(cc)`), `col`/`jonas` wie in 009; Aliasse für Spalte 8 |
| `cycleButton`, `barLatch`, `change()` | `ce.cycleButton`, `ce.latch` (`atBar`), `ce.change(cc, n, label, names)` |
| Lab-Spalte mit Startwerten (`V.val`, nur Änderungen zählen) | `self.labCol(n, start, update)` → State-Busse (`ce.setState`) |
| `rand`, `perlin`, `irand`, `sine` …, Track-`hash` | `ce.rand(t)`, `ce.perlin(t)` … `ce.hash3(a, b, c)` – bitgenau (`lib/strudel.scd`) |
| Mini-Notation (`'<[0 ~ 2]!3 [~ 4@2]>'`) | `ce.mini(str)` → `(period, events)`; Strings 1:1 übernehmen (`lib/mini.scd`) |
| `swingBy(x, 8)` | `self.swingAt(p)` aus 009 (inkl. Doppel/Wegfall!) – mit `x` als Parameter verallgemeinern |
| `degradeBy(x)` | behalten, wenn `rand(whole.begin) > x` |
| `sometimesBy(x, f)` | `r > x`: unverändert; `1 − r > 1 − x`: `f` (`r` am Notenbeginn, *vor* `f`) |
| `ply(2)` | zwei halbe Noten; spätere Zufallsentscheidungen am Beginn jeder Hälfte |
| `n(...).scale('A3:dorian')` | Stufen → MIDI wie im Vibraphon von 009 (Oktav-Umbruch, negative Stufen) |
| superdough-Synth (`sine`, `saw`, `square`, `supersaw`, `fm`) | `sdSynth`, `sdSupersaw`, `bassFM` (Phasen, Wavetables, 0,3 Pegel) |
| Samples (`s('x').bank(...)`, Note-Maps) | `sdSample`; nächste Taste in der Reihenfolge der Map (bei Gleichstand die erste), `rate = 2^((m−key)/12)` |
| `gm_*` | `sdFont` + `tools/sc-port/soundfont-extract.py <preset>` (erstes Preset = Strudels Standard) |
| `phaser*` | `sdSamplePh` (Notch + Dreieck-LFO); nur verwenden, wenn der Phaser an ist |
| Noise (`pink`/`white`/`brown`) | `sdNoise` mit superdoughs Puffern |
| Orbit (room, roomsize, delay) | `orbits:` im Track (IR je Raumgröße: `tools/sc-port/reverb-ir.mjs <size>` messen), `ownDelay` |
| `postgain(level × master)`, Thin, Fog/Tension-Tiefpass | Kanalzug (`ce_strip`); Tiefpass pro Note mit `tone`-Bus |
| `midikeys` (Launchkey) | `lkNote` / `lkCtl` im Track, Kanal 10 = Pads |

**Neu für 007/008/010** (in 009 nicht gebraucht, vor dem Einbau gegen superdough-Quellcode prüfen,
`tools/node_modules/superdough/*.mjs`): `vowel` (Formantfilter), `shape` (Waveshaper), `penv`/`pdecay`
(Tonhöhenhüllkurve), `lpenv`/`ftype` (Filterhüllkurve), `superimpose`, `slice`/`splice`, evtl. `chop`.
Jeweils als Parameter des passenden `sd*`-Sounds oder als eigener Sound, nicht im Track.

## Semantik, an der es bei 009 hing (bitte genau so)

- **ADSR:** superdoughs `getADSRValues`: fehlt Decay/Sustain bei gesetzter Attack → Sustain 1; Synth-Standard
  `[0.001, 0.05, 0.6, 0.01]`, Sample `[0.001, 0.001, 1, 0.01]`. `ce.sdADSR(a, d, s, r)` benutzen.
- **Gain:** Standard-`gain` 0,8, mal `velocity`. Im Event-Log steht `g` = gain × velocity (ohne Standard 0,8).
- **Dauer:** Note = Hap-Dauer × `clip`. Sampler ohne `clip`/`release`: ganze Datei. Mit `clip`/`release`:
  `end` wird ignoriert. Negative `speed`: rückwärts ab Dateiende.
- **Filter:** WebAudio-Biquad; LP/HP-Q in dB (`ce.rq`), Bandpass/Notch linear. Tiefpass = Cutoff × Fog/Tension,
  geklemmt 80…18000 Hz.
- **Signale (`signal`, `midin`) sind zyklisch strukturiert:** `knob.fmap(...)` mit `appLeft` liest am
  Taktanfang bzw. am Beginn der Note. Lab-Spalten lesen ihre Regler beim ersten Abfragen noch nicht → in den
  Vergleichen `from` ≥ ein Durchgang.
- **Latches** jedes 16tel abfragen (`tickLatches`), nicht nur bei Noten.
- **Stateful Tap (Lift u. Ä.):** wird in Strudel *nach* den Stems abgefragt → die Note hört den Stand des vorigen
  16tels (`self.liftStep`).
- **`add` auf Steuer-Objekte** (`note('g3').add(1)`) wirft in Strudel nur eine Warnung: Wert bleibt.
- **`midikeys`** liefert in npm 1.3.0 keinen Kanal; der Track meint Kanal 10 = Pads → so portieren, notieren.
- **Swing auf Off-Grid-Noten** (Gewichte wie `@3` in 17er-Teilungen, Humanize in ms): `swingAt` regelt
  Doppel/Wegfall; nicht `k.odd`.

## Fallen in SuperCollider (alle bei 009 passiert)

- Event-Schlüssel, die Methoden sind: `value`, `kind`, `keys`, `name`, `note`, `at`, `p`, `len` … → **immer**
  `e[\key]` lesen. `Event`-Typ `\ceLk` nutzt `key:` statt `note:` (Events haben ein Standard-`note`).
- Ganzzahl-Literale > 2³¹ laufen über → `4294967296.0` (Float) schreiben.
- Operatoren links nach rechts: `a < b + c` ist `(a < b) + c` → klammern.
- `var` nur am Blockanfang; zwischen Top-Level-`( )`-Blöcken Semikolon.
- `Select` rechnet alle Zweige (nur CPU, kein Fehler).
- NRT: Setup-Bundles ≤ 16 kB (`ce.clumpMsgs`), eigene OSC-Datei pro Render (sonst überschreiben parallele Renders
  einander). Trotzdem **Renders nie parallel** laufen lassen (gemeinsame Ausgabedateien).
- Mac: Bluetooth-Headset mit offenem Mikro → 16 kHz; `live.scd` pinnt den Eingang. Doppelter Start → Guard.

## Prüfen (Pflicht, pro Spalte)

```
cd tools/sc-port
python3 batch.py scenarios/<spur>.json /tmp/cmp-<spur>            # Strudel ↔ SC, Ereignisse + Audio
```
- Szenario-JSON wie `scenarios/vibraphone.json`: `strudel` = Stem-Ausdruck im Strudel-Track, `sc` = Stem-Name,
  `scen`: `bpm`, `cycles`, `from`, `cc` (Start), `events` (Reglerfahrten/Tasten; Tastendrücke ≥ 0,1 Zyklen Abstand),
  `keyEvents` (Launchkey). Abdecken: Grundzustand, jeder Regler auf 0/0,5/1, jedes Pattern, Taste 2,
  Chapter/Akkordwechsel, Fog+Tension, Thin, Break, Space.
- **Muss:** `events ok` (dieselben Noten). Lautheit ±0,3 dB. Null-Test ohne Hall ≤ −25 dB.
- **Erklärbar (nicht reparieren):** Hall (superdough würfelt sein Hall-Rauschen), 44,1-kHz-Samples in SC bis
  4 dB heller über 5 kHz (Resampler der Referenz), m4a 48 ms Versatz, zufällige Phasen (Supersaw, FM live),
  Taps/Lift ± ein 16tel.
- Bei Abweichung: Event-Listen beider Seiten nebeneinander (`*-strudel.events.json`, `*-sc.events.json`), die
  Strudel-Funktion im Quelltext von `@strudel/core` nachlesen, nicht raten.
- Neue Sprachmittel zuerst isoliert prüfen: Mini-Notation mit `mini-check.mjs`, Zufall/Hash mit einem kleinen
  Node-↔-sclang-Vergleich (siehe Hash in 009).
- Am Ende: alle Szenarien des Tracks erneut (Regression), ein Render mit allen Spuren (keine Fehler, Spitzen),
  ein Live-Test (`live.scd`, wenn möglich mit Dummy-Audio), dann Anleitung und `PORTING.md` des Tracks.

## Abliefern

- `sc/tracks/NNN-name/NNN-name.scd` mit `// @layout`, `// @mode`, `// @col`, `// @ctl`, `// @lk` wie im Strudel-Track
  (dieselben englischen Kurztexte, CLAUDE.md), `uiHead`/`uiGlobal`/`uiCols` für die LC-Ansicht.
- Samples nach `sc/samples/` (FLAC verlustfrei, wo möglich; Herkunft/Lizenz in `samples/CREDITS.md`),
  Szenarien nach `tools/sc-port/scenarios/NNN-*.json`.
- `sc/ANLEITUNG.md` um den Track erweitern (Belegung, Abweichungen), `sc/PORTING.md` um Stand und Entscheidungen.
- `live.scd` kennt den Track über `trackName` – zum Wechseln die Zeile ändern (oder einen Track-Wahlschalter
  vorschlagen, nicht eigenmächtig bauen).
- Den Strudel-Track nicht ändern (nicht-destruktiv). Klang, Effekte, Orbits, Beschriftung, Belegung: vorher fragen.
- Mit dem Nutzer Deutsch reden, Code-Kommentare Englisch, kurz.
