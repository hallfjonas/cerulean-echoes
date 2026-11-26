# SuperCollider-Version (Umstieg, siehe `SC-MIGRATION.md`)

Stand 18.11.2026: Track 009 komplett (alle Spalten, globale Spalte 8, Launchkey), jede Spur gegen Strudel
verglichen. Bedienung: `ANLEITUNG.md`; Stand und Entscheidungen: `PORTING.md`.

## Live spielen

1. SuperCollider ≥ 3.13 installieren (keine sc3-plugins nötig).
2. `sc/live.scd` in der SuperCollider-IDE öffnen, alles markieren, Cmd-Return.
   Der Server bootet, der Track lädt, jeder Launch Control XL 3 (Portname enthält `LCXL3`, nicht `DAW`) wird
   verbunden, die Spuren starten auf dem nächsten Takt. Wie in Strudel: alle Fader unten, Ton erst mit dem
   Master-Fader (Spalte 8).
3. Stoppen: `~ce.stopTrack`.

Controller-Belegung = die des Strudel-Tracks (dieselben Custom Modes, `midi-layouts/lcxl3-mode1.syx` / `-mode2.syx`). Unterschied: **Regler wirken
sofort**, auch auf klingende Töne (Control-Busse, 20 ms Glättung); Fader wie in Strudel ab der nächsten Note, Master
sofort. Pattern-Tasten schalten wie bisher auf
den nächsten Takt bzw. die nächste Phrase.

## Aufbau

```
sc/
  live.scd                 Live-Start (Server-Optionen, Latenz, MIDI)
  lib/                     Kern, für alle Tracks gleich
    ce.scd                 lädt alles → ~ce
    controls.scd           CC → Control-Bus, Tasten, Latches (Umschalten auf den Takt), MIDI
    mixer.scd              Kanalzug (Thin, Master, Überblend-Pegel, Hall-Send; Fader pro Note), Hall-Return, Master (Trim, Limiter −1 dBFS)
    sounds.scd             Sound-Bibliothek: Laden + Formatprüfung, Hüllkurven/Filter wie superdough
    steps.scd              Step-Engine: pro 16tel eine Funktion k → Noten
    mini.scd               Strudels Mini-Notation (Schritte, @, !, [ ], < >)
    strudel.scd            Strudels Zufall und Signale bitgenau (rand, perlin, sine …, der hash der Lab-Spalten)
    ui.scd                 Zustand für die LC-Ansicht (OSC an die Brücke)
    setup.scd / score.scd  Busse, Gruppen, Buffer; Offline-Rendern
  sounds/                  ein Klang = eine Datei im festen Format (sounds/README.md)
  tracks/009-house/ und 008-groove-techno/   die Tracks: Spalten, Muster, Harmonie — verweist auf Klänge per Name
  samples/                 Samples und Hall-Impulsantworten (CREDITS.md)
  tools/render.scd         Offline-Render eines Szenarios
```

## Werkzeuge (`tools/sc-port/`)

`stem-compare.mjs` (Stem-Track gegen den handgeschriebenen Track), `soundfont-extract.py` (gm-Soundfonts für SC),
`reverb-ir.mjs` (Hall-Impulsantworten), `noise-buffers.py`. Ein **Szenario** (JSON: Reglerstellungen + Tastendrücke
über die Zeit) in `scenarios/` wird mit `sc/tools/render.scd` offline gerendert.
